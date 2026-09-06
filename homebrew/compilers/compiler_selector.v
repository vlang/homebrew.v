module compilers

import ruby
import homebrew

// Translated from Homebrew/brew `compilers/compiler_selector.rb`.
pub struct CompilerDependency {
pub:
	name     string
	required bool
	test     bool
	build    bool
}

pub struct StaticCompilerVersions {
pub:
	gcc_versions   map[string]homebrew.Version
	build_versions map[string]homebrew.Version
}

pub type CompilerPredicate = fn (Compiler) bool

pub type PreferredGccVersionLookup = fn () !string

@[heap]
pub struct CompilerSelector {
pub:
	formula          ruby.Value
	failures         []&CompilerFailure
	versions         StaticCompilerVersions
	compiler_names   []string
	preferred_gcc    string
	preferred_exists bool
}

pub fn supported_gnu_gcc_versions() []string {
	return ['8', '9', '10', '11', '12', '13', '14', '15', '16']
}

pub fn compiler_priorities(default_compiler string) ![]string {
	return match default_compiler.trim_string_left(':') {
		'clang' { ['clang', 'llvm_clang', 'gnu'] }
		'gcc' { ['gnu', 'gcc', 'llvm_clang', 'clang'] }
		else {
			return error('unknown default compiler: ${default_compiler}')
		}
	}
}

pub fn dependencies_prefer_gnu(dependencies []CompilerDependency, testing_formula bool) bool {
	mut selected := []string{}
	for dependency in dependencies {
		if dependency.required || (testing_formula && dependency.test) || (!testing_formula && dependency.build) {
			selected << dependency.name
		}
	}
	return !selected.any(it == 'llvm') && selected.any(it == 'gcc' || (it.starts_with('gcc@') && it.len > 4 && it[4..].bytes().all(it.is_digit())))
}

pub fn prioritized_gnu_gcc_versions(preferred_version string, preferred_exists bool) []string {
	versions := supported_gnu_gcc_versions()
	if !preferred_exists {
		return versions
	}
	major := leading_digits(preferred_version)
	if major == '' {
		return versions
	}
	mut prioritized := versions.filter(it != major)
	prioritized << major
	return prioritized
}

pub fn prioritized_gnu_gcc_versions_with(lookup PreferredGccVersionLookup) []string {
	preferred_version := lookup() or { return supported_gnu_gcc_versions() }
	return prioritized_gnu_gcc_versions(preferred_version, true)
}

fn leading_digits(value string) string {
	mut start := -1
	mut end := -1
	for index, character in value {
		if character.is_digit() {
			if start < 0 {
				start = index
			}
			end = index + 1
		} else if start >= 0 {
			break
		}
	}
	return if start < 0 { '' } else { value[start..end] }
}

fn is_supported_gcc_name(name string) bool {
	return name == 'gcc' || (name.starts_with('gcc-') && name[4..] in supported_gnu_gcc_versions())
}

pub fn (versions StaticCompilerVersions) compiler_version(name string) homebrew.Version {
	if is_supported_gcc_name(name) {
		return versions.gcc_versions[name] or { homebrew.null_version() }
	}
	return versions.build_versions[name] or { homebrew.null_version() }
}

pub fn (selector &CompilerSelector) gnu_gcc_versions() []string {
	return prioritized_gnu_gcc_versions(selector.preferred_gcc, selector.preferred_exists)
}

pub fn (selector &CompilerSelector) available_compilers() []Compiler {
	mut available := []Compiler{}
	for compiler_name in selector.compiler_names {
		match compiler_name {
			'gnu' {
				versions := selector.gnu_gcc_versions()
				for index := versions.len - 1; index >= 0; index-- {
					executable := 'gcc-${versions[index]}'
					version := selector.versions.compiler_version(executable)
					if !version.is_null() {
						available << Compiler{
							compiler_type: 'gcc'
							name: executable
							version: version
						}
					}
				}
			}
			'llvm' {}
			else {
				version := selector.versions.compiler_version(compiler_name)
				if !version.is_null() {
					available << Compiler{
						compiler_type: compiler_name
						name: compiler_name
						version: version
					}
				}
			}
		}
	}
	return available
}

pub fn (selector &CompilerSelector) fails_with(compiler Compiler) bool {
	return selector.failures.any(it.fails_with(compiler))
}

pub fn (selector &CompilerSelector) find_compiler(predicate CompilerPredicate) ?Compiler {
	for compiler in selector.available_compilers() {
		if predicate(compiler) {
			return compiler
		}
	}
	return none
}

pub fn (selector &CompilerSelector) compiler() !string {
	if compiler := selector.find_compiler(fn [selector] (candidate Compiler) bool {
		return !selector.fails_with(candidate)
	}) {
		return compiler.name
	}
	return error('CompilerSelectionError: ${selector.formula.as_string()} cannot be built with any available compilers.')
}

fn formula_dependencies(value ruby.Value) []CompilerDependency {
	raw := value.map_data['dependencies'] or { return []CompilerDependency{} }
	mut dependencies := []CompilerDependency{}
	for dependency in raw.array_data {
		dependencies << CompilerDependency{
			name: dependency.attribute('name') or { dependency.as_string() }
			required: (dependency.attribute('required') or { 'false' }) == 'true'
			test: (dependency.attribute('test') or { 'false' }) == 'true'
			build: (dependency.attribute('build') or { 'false' }) == 'true'
		}
	}
	return dependencies
}

fn host_default_compiler() string {
	return $if macos { 'clang' } $else { 'gcc' }
}
