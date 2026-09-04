module env

import ruby

// Translated from Homebrew/brew `extend/ENV/super.rb`.
pub const superenv_sanitized_variables = [
	'CDPATH',
	'CLICOLOR_FORCE',
	'CPATH',
	'C_INCLUDE_PATH',
	'CPLUS_INCLUDE_PATH',
	'OBJC_INCLUDE_PATH',
	'CC',
	'CXX',
	'OBJC',
	'OBJCXX',
	'CPP',
	'MAKE',
	'LD',
	'LDSHARED',
	'CFLAGS',
	'CXXFLAGS',
	'OBJCFLAGS',
	'OBJCXXFLAGS',
	'LDFLAGS',
	'CPPFLAGS',
	'MACOSX_DEPLOYMENT_TARGET',
	'SDKROOT',
	'DEVELOPER_DIR',
	'CMAKE_PREFIX_PATH',
	'CMAKE_INCLUDE_PATH',
	'CMAKE_FRAMEWORK_PATH',
	'GOBIN',
	'GOPATH',
	'GOROOT',
	'PERL_MB_OPT',
	'PERL_MM_OPT',
	'LIBRARY_PATH',
	'LD_LIBRARY_PATH',
	'LD_PRELOAD',
	'LD_RUN_PATH',
	'RUSTFLAGS',
]

pub type SuperenvPathPredicate = fn (string) bool

pub type SuperenvAction = fn (mut SuperenvState) !ruby.Value

pub type SuperenvVoidAction = fn (mut SuperenvState) !

pub struct SuperenvDependency {
pub:
	name                  string
	version               string
	opt_prefix            string
	any_version_installed bool = true
}

pub struct SuperenvConfig {
pub:
	shims_path           string
	superenv_bin         ?string
	brew_file            string
	prefix               string
	cellar               string
	temp                 string
	make_jobs            int = 1
	compiler             string = 'clang'
	effective_arch       string
	rustflags_target_cpu string
	optimization_flags   map[string]string
	arch_flags           map[string]string
	gcc_runtime_paths    map[string]string
}

pub struct SuperenvBuildOptions {
pub:
	formula_prefix  ?string
	cc              ?string
	build_bottle    bool
	bottle_arch     ?string
	testing_formula bool
	debug_symbols   bool
}

@[heap]
pub struct SuperenvState {
pub:
	config SuperenvConfig
mut:
	environment     map[string]string
	keg_only_deps   []SuperenvDependency
	deps            []SuperenvDependency
	run_time_deps   []SuperenvDependency
	formula_prefix  ?string
	homebrew_cc     string
	compiler        string
	effective_arch  string
	build_bottle    bool
	bottle_arch     ?string
	testing_formula bool
}

pub fn new_superenv(config SuperenvConfig, environment map[string]string) &SuperenvState {
	return &SuperenvState{
		config: config
		environment: environment.clone()
		compiler: config.compiler
		effective_arch: config.effective_arch
	}
}

pub fn (state &SuperenvState) to_map() map[string]string {
	return state.environment.clone()
}

pub fn (state &SuperenvState) value(key string) ?string {
	return state.environment[key]
}

// These typed mutation/access boundaries expose Ruby's Hash-like environment
// receiver to OS-specific Superenv extensions without duplicating its state.
pub fn (mut state SuperenvState) set_value(key string, value string) {
	state.environment[key] = value
}

pub fn (mut state SuperenvState) remove_value(key string) {
	state.environment.delete(key)
}

pub fn (state &SuperenvState) dependencies() []SuperenvDependency {
	return state.deps.clone()
}

pub fn (state &SuperenvState) compiler_name() string {
	return state.compiler
}

pub fn superenv_use_compiler(mut state SuperenvState, compiler string) {
	state.homebrew_cc = compiler
	state.compiler = compiler
	state.environment['HOMEBREW_CC'] = compiler
	if compiler == 'llvm_clang' {
		state.environment['CC'] = 'clang'
		state.environment['OBJC'] = 'clang'
		state.environment['CXX'] = 'clang++'
		state.environment['OBJCXX'] = 'clang++'
	} else {
		state.environment['CC'] = compiler
		state.environment['OBJC'] = compiler
		cxx := compiler.replace('gcc', 'g++').replace('clang', 'clang++')
		state.environment['CXX'] = cxx
		state.environment['OBJCXX'] = cxx
	}
}

pub fn (mut state SuperenvState) append_cccfg(value string) {
	state.append_to_cccfg(value)
}

fn join_path(left string, right string) string {
	if left == '' {
		return right
	}
	if right == '' {
		return left
	}
	return '${left.trim_string_right('/')}/${right.trim_string_left('/')}'
}

fn parent_path(path string) string {
	cleaned := path.trim_string_right('/')
	index := cleaned.last_index('/') or { return '.' }
	if index == 0 {
		return '/'
	}
	return cleaned[..index]
}

fn dependency_prefix(dependency SuperenvDependency, prefix string) string {
	if dependency.opt_prefix != '' {
		return dependency.opt_prefix
	}
	return join_path(join_path(prefix, 'opt'), dependency.name)
}

fn dependency_path(dependency SuperenvDependency, prefix string, suffix string) string {
	return join_path(dependency_prefix(dependency, prefix), suffix)
}

fn existing_path(paths []string, exists SuperenvPathPredicate) ?string {
	mut seen := map[string]bool{}
	mut selected := []string{}
	for path in paths {
		if path == '' || path in seen || !exists(path) {
			continue
		}
		seen[path] = true
		selected << path
	}
	if selected.len == 0 {
		return none
	}
	return selected.join(':')
}

fn version_parts(version string) []int {
	mut parts := []int{}
	mut current := ''
	for character in version {
		if character.is_digit() {
			current += character.ascii_str()
		} else if current != '' {
			parts << current.int()
			current = ''
		}
	}
	if current != '' {
		parts << current.int()
	}
	return parts
}

fn compare_versions(left string, right string) int {
	left_parts := version_parts(left)
	right_parts := version_parts(right)
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_part := if index < left_parts.len { left_parts[index] } else { 0 }
		right_part := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_part < right_part {
			return -1
		}
		if left_part > right_part {
			return 1
		}
	}
	return 0
}

fn is_python_dependency(name string) bool {
	if name == 'python' || name == 'python3' {
		return true
	}
	for prefix in ['python@', 'python3@'] {
		if name.starts_with(prefix) && name[prefix.len..].split('.').all(it.bytes().all(it.is_digit())) {
			return true
		}
	}
	return false
}

fn is_llvm_dependency(name string) bool {
	if name == 'llvm' {
		return true
	}
	return name.starts_with('llvm@') && name[5..].bytes().all(it.is_digit())
}

fn is_gnu_compiler(compiler string) bool {
	return compiler == 'gcc' || (compiler.starts_with('gcc-') && compiler[4..].bytes().all(it.is_digit()))
}

fn (mut state SuperenvState) append_to_cccfg(value string) {
	state.environment['HOMEBREW_CCCFG'] = (state.environment['HOMEBREW_CCCFG'] or { '' }) + value
}

fn (mut state SuperenvState) reset_environment() {
	for key in superenv_sanitized_variables {
		state.environment.delete(key)
	}
	state.environment.delete('as_nl')
}

pub fn (state &SuperenvState) determine_cc() string {
	if state.homebrew_cc != '' {
		return state.homebrew_cc
	}
	return state.compiler
}

pub fn (state &SuperenvState) extra_python_paths() []string {
	mut python_dependencies := state.deps.filter(is_python_dependency(it.name))
	python_dependencies.sort_with_compare(fn (left &SuperenvDependency, right &SuperenvDependency) int {
		return compare_versions(right.version, left.version)
	})
	return python_dependencies.map(dependency_path(it, state.config.prefix, 'libexec/bin'))
}

pub fn (state &SuperenvState) path(exists SuperenvPathPredicate) ?string {
	mut paths := []string{}
	if superenv_bin := state.config.superenv_bin {
		paths << superenv_bin
	}
	paths << state.deps.map(dependency_path(it, state.config.prefix, 'bin'))
	paths << state.extra_python_paths()
	paths << ['/usr/bin', '/bin', '/usr/sbin', '/sbin']
	if is_gnu_compiler(state.homebrew_cc) {
		name := state.homebrew_cc.replace('-', '@')
		matching_dependencies := state.deps.filter(it.name == name || it.name == state.homebrew_cc)
		if matching_dependencies.len > 0 {
			paths << dependency_path(matching_dependencies[0], state.config.prefix, 'bin')
		}
	}
	return existing_path(paths, exists)
}

pub fn (state &SuperenvState) pkg_config_path(exists SuperenvPathPredicate) ?string {
	mut paths := []string{}
	for dependency in state.deps {
		paths << dependency_path(dependency, state.config.prefix, 'lib/pkgconfig')
	}
	for dependency in state.deps {
		paths << dependency_path(dependency, state.config.prefix, 'share/pkgconfig')
	}
	return existing_path(paths, exists)
}

pub fn (state &SuperenvState) pkg_config_libdir(exists SuperenvPathPredicate) ?string {
	return existing_path([], exists)
}

pub fn (state &SuperenvState) aclocal_path(exists SuperenvPathPredicate) ?string {
	mut paths := state.keg_only_deps.map(dependency_path(it, state.config.prefix, 'share/aclocal'))
	paths << join_path(state.config.prefix, 'share/aclocal')
	return existing_path(paths, exists)
}

pub fn (state &SuperenvState) isystem_paths(exists SuperenvPathPredicate) ?string {
	return existing_path([join_path(state.config.prefix, 'include')], exists)
}

pub fn (state &SuperenvState) include_paths(exists SuperenvPathPredicate) ?string {
	return existing_path(state.keg_only_deps.map(dependency_path(it, state.config.prefix, 'include')), exists)
}

pub fn (state &SuperenvState) library_paths(exists SuperenvPathPredicate) ?string {
	mut paths := []string{}
	if is_gnu_compiler(state.compiler) {
		if runtime_path := state.config.gcc_runtime_paths[state.compiler] {
			paths << runtime_path
		}
	}
	for dependency in state.keg_only_deps {
		if !is_llvm_dependency(dependency.name) {
			paths << dependency_path(dependency, state.config.prefix, 'lib')
		}
	}
	paths << join_path(state.config.prefix, 'lib')
	return existing_path(paths, exists)
}

pub fn (state &SuperenvState) cmake_prefix_path(exists SuperenvPathPredicate) ?string {
	mut paths := []string{}
	if superenv_bin := state.config.superenv_bin {
		paths << parent_path(superenv_bin)
	}
	paths << state.keg_only_deps.map(dependency_prefix(it, state.config.prefix))
	paths << state.config.prefix
	return existing_path(paths, exists)
}

pub fn (state &SuperenvState) cmake_framework_path(exists SuperenvPathPredicate) ?string {
	return existing_path(state.deps.map(dependency_path(it, state.config.prefix, 'Frameworks')), exists)
}

pub fn (state &SuperenvState) optimization_flags() string {
	return state.config.optimization_flags[state.effective_arch] or {
		state.config.arch_flags[state.effective_arch] or { '' }
	}
}

pub fn (state &SuperenvState) dependencies_string() string {
	return state.deps.map(it.name).join(',')
}

fn set_optional(mut environment map[string]string, key string, value ?string) {
	if unwrapped := value {
		environment[key] = unwrapped
	} else {
		environment.delete(key)
	}
}

pub fn (mut state SuperenvState) setup(options SuperenvBuildOptions,
	exists SuperenvPathPredicate) {
	state.formula_prefix = options.formula_prefix
	state.build_bottle = options.build_bottle
	state.bottle_arch = options.bottle_arch
	state.testing_formula = options.testing_formula
	state.compiler = options.cc or { state.config.compiler }
	state.homebrew_cc = options.cc or { '' }
	state.effective_arch = options.bottle_arch or { state.config.effective_arch }
	state.reset_environment()
	if state.compiler == 'clang' || state.compiler == 'llvm_clang' {
		state.environment['CC'] = 'clang'
		state.environment['OBJC'] = 'clang'
		state.environment['CXX'] = 'clang++'
		state.environment['OBJCXX'] = 'clang++'
	} else if is_gnu_compiler(state.compiler) {
		state.environment['CC'] = 'gcc'
		state.environment['OBJC'] = 'gcc'
		state.environment['CXX'] = 'g++'
		state.environment['OBJCXX'] = 'g++'
	}
	if state.homebrew_cc != '' {
		state.environment['HOMEBREW_CC'] = state.homebrew_cc
	}
	state.environment['HOMEBREW_ENV'] = 'super'
	if 'MAKEFLAGS' !in state.environment {
		state.environment['MAKEFLAGS'] = '-j${state.config.make_jobs}'
	}
	state.environment['RUSTC_WRAPPER'] = join_path(state.config.shims_path, 'shared/rustc_wrapper')
	state.environment['HOMEBREW_RUSTFLAGS'] = state.config.rustflags_target_cpu
	set_optional(mut state.environment, 'PATH', state.path(exists))
	set_optional(mut state.environment, 'PKG_CONFIG_PATH', state.pkg_config_path(exists))
	state.environment['PKG_CONFIG_LIBDIR'] = state.pkg_config_libdir(exists) or { '' }
	state.environment['HOMEBREW_CCCFG'] = ''
	state.environment['HOMEBREW_OPTIMIZATION_LEVEL'] = if is_gnu_compiler(state.compiler) {
		'O2'
	} else {
		'Os'
	}
	state.environment['HOMEBREW_BREW_FILE'] = state.config.brew_file
	state.environment['HOMEBREW_PREFIX'] = state.config.prefix
	state.environment['HOMEBREW_CELLAR'] = state.config.cellar
	state.environment['HOMEBREW_OPT'] = join_path(state.config.prefix, 'opt')
	state.environment['HOMEBREW_TEMP'] = state.config.temp
	state.environment['HOMEBREW_OPTFLAGS'] = state.optimization_flags()
	state.environment['HOMEBREW_MAKE_JOBS'] = state.config.make_jobs.str()
	set_optional(mut state.environment, 'CMAKE_PREFIX_PATH', state.cmake_prefix_path(exists))
	set_optional(mut state.environment, 'CMAKE_FRAMEWORK_PATH', state.cmake_framework_path(exists))
	state.environment.delete('CMAKE_INCLUDE_PATH')
	state.environment.delete('CMAKE_LIBRARY_PATH')
	set_optional(mut state.environment, 'ACLOCAL_PATH', state.aclocal_path(exists))
	if state.deps.any(it.name == 'libtool') {
		state.environment['M4'] = join_path(state.config.prefix, 'opt/m4/bin/m4')
	}
	set_optional(mut state.environment, 'HOMEBREW_ISYSTEM_PATHS', state.isystem_paths(exists))
	set_optional(mut state.environment, 'HOMEBREW_INCLUDE_PATHS', state.include_paths(exists))
	set_optional(mut state.environment, 'HOMEBREW_LIBRARY_PATHS', state.library_paths(exists))
	state.environment['HOMEBREW_DEPENDENCIES'] = state.dependencies_string()
	if formula_prefix := state.formula_prefix {
		state.environment['HOMEBREW_FORMULA_PREFIX'] = formula_prefix
	}
	state.environment['OPENSSL_NO_VENDOR'] = '1'
	state.environment['GOTOOLCHAIN'] = 'local'
	state.environment['MATURIN_NO_INSTALL_RUST'] = '1'
	state.environment['HIDAPI_SYSTEM_HIDAPI'] = '1'
	state.environment['PYZMQ_NO_BUNDLE'] = '1'
	state.environment['SODIUM_INSTALL'] = 'system'
	if options.debug_symbols {
		state.append_to_cccfg('D')
	}
}

// Ruby attr_accessor `attr_accessor :run_time_deps` at line 29.
pub fn super_run_time_deps(state &SuperenvState) []SuperenvDependency {
	return state.run_time_deps.clone()
}

fn with_optimization_level(mut state SuperenvState, level string,
	block ?SuperenvVoidAction) ! {
	if action := block {
		old_level := state.environment['HOMEBREW_OPTIMIZATION_LEVEL'] or { '' }
		had_level := 'HOMEBREW_OPTIMIZATION_LEVEL' in state.environment
		state.environment['HOMEBREW_OPTIMIZATION_LEVEL'] = level
		defer {
			if had_level {
				state.environment['HOMEBREW_OPTIMIZATION_LEVEL'] = old_level
			} else {
				state.environment.delete('HOMEBREW_OPTIMIZATION_LEVEL')
			}
		}
		action(mut state)!
		return
	}
	state.environment['HOMEBREW_OPTIMIZATION_LEVEL'] = level
}
