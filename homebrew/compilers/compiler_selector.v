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

pub fn new_compiler_selector(formula ruby.Value, failures []&CompilerFailure,
	versions StaticCompilerVersions, compiler_names []string, preferred_gcc string,
	preferred_exists bool) &CompilerSelector {
	return &CompilerSelector{
		formula: formula
		failures: failures.clone()
		versions: versions
		compiler_names: compiler_names.map(it.trim_string_left(':'))
		preferred_gcc: preferred_gcc
		preferred_exists: preferred_exists
	}
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

pub fn select_for(formula ruby.Value, failures []&CompilerFailure,
	dependencies []CompilerDependency, versions StaticCompilerVersions, requested_compilers []string,
	has_requested_compilers bool, default_compiler string, testing_formula bool,
	preferred_gcc string, preferred_exists bool) !string {
	mut compiler_names := if has_requested_compilers {
		requested_compilers.clone()
	} else {
		compiler_priorities(default_compiler)!
	}
	if !has_requested_compilers && default_compiler.trim_string_left(':') == 'clang' && dependencies_prefer_gnu(dependencies, testing_formula) {
		compiler_names = ['clang', 'gnu', 'llvm_clang']
	}
	return new_compiler_selector(formula, failures, versions, compiler_names, preferred_gcc, preferred_exists).compiler()
}

fn static_versions_value(versions StaticCompilerVersions) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, version in versions.gcc_versions {
		values[name] = compiler_failure_version_value(version)
	}
	for name, version in versions.build_versions {
		values['${name}_build_version'] = compiler_failure_version_value(version)
	}
	return ruby.map_value(values)
}

fn static_versions_from_value(value ruby.Value) StaticCompilerVersions {
	mut gcc_versions := map[string]homebrew.Version{}
	mut build_versions := map[string]homebrew.Version{}
	for name, version_value in value.map_data {
		if name.ends_with('_build_version') {
			build_versions[name.trim_string_right('_build_version')] = compiler_failure_version_from_value(version_value)
		} else {
			gcc_versions[name] = compiler_failure_version_from_value(version_value)
		}
	}
	return StaticCompilerVersions{
		gcc_versions: gcc_versions
		build_versions: build_versions
	}
}

fn formula_failures(value ruby.Value) []&CompilerFailure {
	raw := value.map_data['compiler_failures'] or { return []&CompilerFailure{} }
	return raw.array_data.map(compiler_failure_from_value(it))
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

fn compiler_selector_value(selector &CompilerSelector) ruby.Value {
	return ruby.structured_value('CompilerSelector', '#<CompilerSelector>', {
		'compiler_selector_address': u64(voidptr(selector)).str()
	})
}

fn compiler_selector_from_value(value ruby.Value) &CompilerSelector {
	address := value.attribute('compiler_selector_address') or {
		panic('${value.type_name} has no translated CompilerSelector state')
	}
	return unsafe { &CompilerSelector(voidptr(address.u64())) }
}

fn compiler_names_from_value(value ruby.Value) []string {
	return value.as_string_array() or { panic(err) }.map(it.trim_string_left(':'))
}

fn selector_from_boundary(formula ruby.Value, versions_value ruby.Value,
	compiler_names []string) &CompilerSelector {
	preferred := formula.attribute('preferred_gcc_version') or { '' }
	return new_compiler_selector(formula, formula_failures(formula), static_versions_from_value(versions_value), compiler_names, preferred, preferred != '')
}

// Ruby method `self.select_for(formula, compilers = nil, testing_formula: false)` at line 23.
pub fn ruby_compiler_selector_l23_self_select_for(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerSelector.select_for requires a formula')
	}
	formula := args[0]
	versions_value := formula.map_data['versions'] or { ruby.map_value({}) }
	has_requested := args.len > 1 && args[1].type_name == 'Array'
	requested := if has_requested { compiler_names_from_value(args[1]) } else { []string{} }
	testing_formula := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	default_compiler := formula.attribute('default_compiler') or { host_default_compiler() }
	preferred := formula.attribute('preferred_gcc_version') or { '' }
	selected := select_for(formula, formula_failures(formula), formula_dependencies(formula), static_versions_from_value(versions_value), requested, has_requested, default_compiler, testing_formula, preferred, preferred != '') or { panic(err) }
	return if selected.starts_with('gcc-') {
		ruby.string_value(selected)
	} else {
		ruby.object_value('Symbol', selected)
	}
}

// Ruby method `self.compilers` at line 34.
pub fn ruby_compiler_selector_l34_self_compilers(args ...ruby.Value) ruby.Value {
	default_compiler := if args.len > 0 { args[0].as_string() } else { host_default_compiler() }
	return ruby.string_array_value(compiler_priorities(default_compiler) or { panic(err) })
}

// Ruby attr_reader `formula` at line 39.
pub fn ruby_compiler_selector_l39_formula(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerSelector#formula requires a receiver')
	}
	return compiler_selector_from_value(args[0]).formula
}

// Ruby attr_reader `failures` at line 42.
pub fn ruby_compiler_selector_l42_failures(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerSelector#failures requires a receiver')
	}
	return ruby.array_value(compiler_selector_from_value(args[0]).failures.map(compiler_failure_value(it)))
}

// Ruby attr_reader `versions` at line 45.
pub fn ruby_compiler_selector_l45_versions(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerSelector#versions requires a receiver')
	}
	return static_versions_value(compiler_selector_from_value(args[0]).versions)
}

// Ruby attr_reader `compilers` at line 48.
pub fn ruby_compiler_selector_l48_compilers(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerSelector#compilers requires a receiver')
	}
	return ruby.string_array_value(compiler_selector_from_value(args[0]).compiler_names)
}

// Ruby method `initialize(formula, versions, compilers)` at line 57.
pub fn ruby_compiler_selector_l57_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('CompilerSelector#initialize requires formula, versions, and compilers')
	}
	return compiler_selector_value(selector_from_boundary(args[0], args[1], compiler_names_from_value(args[2])))
}

// Ruby method `compiler` at line 65.
pub fn ruby_compiler_selector_l65_compiler(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerSelector#compiler requires a receiver')
	}
	selected := compiler_selector_from_value(args[0]).compiler() or { panic(err) }
	return if selected.starts_with('gcc-') {
		ruby.string_value(selected)
	} else {
		ruby.object_value('Symbol', selected)
	}
}

// Ruby method `self.preferred_gcc` at line 71.
pub fn ruby_compiler_selector_l71_self_preferred_gcc(args ...ruby.Value) ruby.Value {
	return ruby.string_value('gcc')
}

// Ruby method `gnu_gcc_versions` at line 78.
pub fn ruby_compiler_selector_l78_gnu_gcc_versions(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value(supported_gnu_gcc_versions())
	}
	return ruby.string_array_value(compiler_selector_from_value(args[0]).gnu_gcc_versions())
}

// Ruby method `find_compiler(&_block)` at line 87.
pub fn ruby_compiler_selector_l87_find_compiler(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerSelector#find_compiler requires a receiver')
	}
	return ruby.array_value(compiler_selector_from_value(args[0]).available_compilers().map(compiler_value(it)))
}

// Ruby method `fails_with?(compiler)` at line 106.
pub fn ruby_compiler_selector_l106_fails_with(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('CompilerSelector#fails_with? requires a receiver and compiler')
	}
	return ruby.bool_value(compiler_selector_from_value(args[0]).fails_with(compiler_from_value(args[1])))
}

// Ruby method `compiler_version(name)` at line 111.
pub fn ruby_compiler_selector_l111_compiler_version(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('CompilerSelector#compiler_version requires a receiver and compiler name')
	}
	version := compiler_selector_from_value(args[0]).versions.compiler_version(args[1].as_string())
	return compiler_failure_version_value(version)
}
