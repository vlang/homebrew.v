module env

import ruby

// Translated from Homebrew/brew `extend/ENV/super.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type SuperenvPathPredicate = fn(string) bool

pub type SuperenvAction = fn(mut SuperenvState) !ruby.Value

pub type SuperenvVoidAction = fn(mut SuperenvState) !

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

// Ruby attr_accessor `attr_accessor :keg_only_deps` at line 23.
pub fn ruby_super_l23_d1_keg_only_deps(state &SuperenvState) []SuperenvDependency {
	return state.keg_only_deps.clone()
}

// Ruby attr_accessor `attr_accessor :keg_only_deps` at line 23.
pub fn ruby_super_l23_d2_keg_only_deps(mut state SuperenvState, dependencies []SuperenvDependency) {
	state.keg_only_deps = dependencies.clone()
}

// Ruby attr_accessor `attr_accessor :deps` at line 26.
pub fn ruby_super_l26_d3_deps(state &SuperenvState) []SuperenvDependency {
	return state.deps.clone()
}

// Ruby attr_accessor `attr_accessor :deps` at line 26.
pub fn ruby_super_l26_d4_deps(mut state SuperenvState, dependencies []SuperenvDependency) {
	state.deps = dependencies.clone()
}

// Ruby attr_accessor `attr_accessor :run_time_deps` at line 29.
pub fn ruby_super_l29_d5_run_time_deps(state &SuperenvState) []SuperenvDependency {
	return state.run_time_deps.clone()
}

// Ruby attr_accessor `attr_accessor :run_time_deps` at line 29.
pub fn ruby_super_l29_d6_run_time_deps(mut state SuperenvState, dependencies []SuperenvDependency) {
	state.run_time_deps = dependencies.clone()
}

// Ruby method `self.extended(base)` at line 32.
pub fn ruby_super_l32_d7_self_extended(mut state SuperenvState) {
	state.keg_only_deps = []
	state.deps = []
	state.run_time_deps = []
}

// Ruby method `self.shims_path` at line 42.
pub fn ruby_super_l42_d8_self_shims_path(config SuperenvConfig) string {
	return join_path(config.shims_path, 'super')
}

// Ruby method `self.bin; end` at line 47.
pub fn ruby_super_l47_d9_self_bin(config SuperenvConfig) ?string {
	return config.superenv_bin
}

// Ruby method `initialize` at line 50.
pub fn ruby_super_l50_d10_initialize(config SuperenvConfig, environment map[string]string) &SuperenvState {
	return new_superenv(config, environment)
}

// Ruby method `reset` at line 59.
pub fn ruby_super_l59_d11_reset(mut state SuperenvState) {
	state.reset_environment()
}

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil, testing_formula: false,` at line 76.
pub fn ruby_super_l76_d12_setup_build_environment(mut state SuperenvState,
	options SuperenvBuildOptions, exists SuperenvPathPredicate) {
	state.setup(options, exists)
}

// Ruby method `llvm_clang` at line 146.
pub fn ruby_super_l146_d13_llvm_clang(mut state SuperenvState) {
	superenv_use_compiler(mut state, 'llvm_clang')
}

// Ruby method `cc=(val)` at line 155.
pub fn ruby_super_l155_d14_cc(mut state SuperenvState, value string) {
	state.homebrew_cc = value
	state.compiler = value
	state.environment['CC'] = value
	state.environment['OBJC'] = value
	state.environment['HOMEBREW_CC'] = value
}

// Ruby method `determine_cxx` at line 161.
pub fn ruby_super_l161_d15_determine_cxx(state &SuperenvState) string {
	return state.determine_cc().replace('gcc', 'g++').replace('clang', 'clang++')
}

// Ruby method `homebrew_extra_paths` at line 166.
pub fn ruby_super_l166_d16_homebrew_extra_paths(state &SuperenvState) []string {
	return state.extra_python_paths()
}

// Ruby method `determine_path` at line 175.
pub fn ruby_super_l175_d17_determine_path(state &SuperenvState,
	exists SuperenvPathPredicate) ?string {
	return state.path(exists)
}

// Ruby method `homebrew_extra_pkg_config_paths` at line 194.
pub fn ruby_super_l194_d18_homebrew_extra_pkg_config_paths(_ &SuperenvState) []string {
	return []
}

// Ruby method `determine_pkg_config_path` at line 199.
pub fn ruby_super_l199_d19_determine_pkg_config_path(state &SuperenvState,
	exists SuperenvPathPredicate) ?string {
	return state.pkg_config_path(exists)
}

// Ruby method `determine_pkg_config_libdir` at line 207.
pub fn ruby_super_l207_d20_determine_pkg_config_libdir(state &SuperenvState,
	exists SuperenvPathPredicate) ?string {
	return state.pkg_config_libdir(exists)
}

// Ruby method `determine_aclocal_path` at line 214.
pub fn ruby_super_l214_d21_determine_aclocal_path(state &SuperenvState,
	exists SuperenvPathPredicate) ?string {
	return state.aclocal_path(exists)
}

// Ruby method `homebrew_extra_isystem_paths` at line 222.
pub fn ruby_super_l222_d22_homebrew_extra_isystem_paths(_ &SuperenvState) []string {
	return []
}

// Ruby method `determine_isystem_paths` at line 227.
pub fn ruby_super_l227_d23_determine_isystem_paths(state &SuperenvState,
	exists SuperenvPathPredicate) ?string {
	return state.isystem_paths(exists)
}

// Ruby method `determine_include_paths` at line 235.
pub fn ruby_super_l235_d24_determine_include_paths(state &SuperenvState,
	exists SuperenvPathPredicate) ?string {
	return state.include_paths(exists)
}

// Ruby method `homebrew_extra_library_paths` at line 240.
pub fn ruby_super_l240_d25_homebrew_extra_library_paths(_ &SuperenvState) []string {
	return []
}

// Ruby method `determine_library_paths` at line 245.
pub fn ruby_super_l245_d26_determine_library_paths(state &SuperenvState,
	exists SuperenvPathPredicate) ?string {
	return state.library_paths(exists)
}

// Ruby method `determine_dependencies` at line 270.
pub fn ruby_super_l270_d27_determine_dependencies(state &SuperenvState) string {
	return state.dependencies_string()
}

// Ruby method `determine_cmake_prefix_path` at line 275.
pub fn ruby_super_l275_d28_determine_cmake_prefix_path(state &SuperenvState,
	exists SuperenvPathPredicate) ?string {
	return state.cmake_prefix_path(exists)
}

// Ruby method `homebrew_extra_cmake_include_paths` at line 284.
pub fn ruby_super_l284_d29_homebrew_extra_cmake_include_paths(_ &SuperenvState) []string {
	return []
}

// Ruby method `determine_cmake_include_path` at line 289.
pub fn ruby_super_l289_d30_determine_cmake_include_path(_ &SuperenvState,
	_ SuperenvPathPredicate) ?string {
	return none
}

// Ruby method `homebrew_extra_cmake_library_paths` at line 294.
pub fn ruby_super_l294_d31_homebrew_extra_cmake_library_paths(_ &SuperenvState) []string {
	return []
}

// Ruby method `determine_cmake_library_path` at line 299.
pub fn ruby_super_l299_d32_determine_cmake_library_path(_ &SuperenvState,
	_ SuperenvPathPredicate) ?string {
	return none
}

// Ruby method `homebrew_extra_cmake_frameworks_paths` at line 304.
pub fn ruby_super_l304_d33_homebrew_extra_cmake_frameworks_paths(_ &SuperenvState) []string {
	return []
}

// Ruby method `determine_cmake_frameworks_path` at line 309.
pub fn ruby_super_l309_d34_determine_cmake_frameworks_path(state &SuperenvState,
	exists SuperenvPathPredicate) ?string {
	return state.cmake_framework_path(exists)
}

// Ruby method `determine_make_jobs` at line 317.
pub fn ruby_super_l317_d35_determine_make_jobs(state &SuperenvState) string {
	return state.config.make_jobs.str()
}

// Ruby method `determine_optflags` at line 322.
pub fn ruby_super_l322_d36_determine_optflags(state &SuperenvState) string {
	return state.optimization_flags()
}

// Ruby method `determine_cccfg` at line 330.
pub fn ruby_super_l330_d37_determine_cccfg(_ &SuperenvState) string {
	return ''
}

// Ruby method `deparallelize(&block)` at line 340.
pub fn ruby_super_l340_d38_deparallelize(mut state SuperenvState,
	block ?SuperenvAction) !string {
	old_makeflags := state.environment['MAKEFLAGS'] or { '' }
	old_make_jobs := state.environment['HOMEBREW_MAKE_JOBS'] or { '' }
	had_makeflags := 'MAKEFLAGS' in state.environment
	had_make_jobs := 'HOMEBREW_MAKE_JOBS' in state.environment
	state.environment.delete('MAKEFLAGS')
	state.environment.delete('HOMEBREW_MAKE_JOBS')
	state.environment['HOMEBREW_MAKE_JOBS'] = '1'
	if action := block {
		defer {
			if had_makeflags {
				state.environment['MAKEFLAGS'] = old_makeflags
			} else {
				state.environment.delete('MAKEFLAGS')
			}
			if had_make_jobs {
				state.environment['HOMEBREW_MAKE_JOBS'] = old_make_jobs
			} else {
				state.environment.delete('HOMEBREW_MAKE_JOBS')
			}
		}
		action(mut state)!
	}
	return old_makeflags
}

// Ruby method `make_jobs` at line 357.
pub fn ruby_super_l357_d39_make_jobs(state &SuperenvState) int {
	makeflags := state.environment['MAKEFLAGS'] or { '' }
	for start, character in makeflags {
		if character != `-` {
			continue
		}
		mut index := start + 1
		for index < makeflags.len {
			if makeflags[index] == `j` && index + 1 < makeflags.len && makeflags[index + 1].is_digit() {
				mut end := index + 1
				for end < makeflags.len && makeflags[end].is_digit() {
					end++
				}
				jobs := makeflags[index + 1..end].int()
				return if jobs > 1 { jobs } else { 1 }
			}
			if !makeflags[index].is_alnum() && makeflags[index] != `_` {
				break
			}
			index++
		}
	}
	return 1
}

// Ruby method `permit_arch_flags` at line 363.
pub fn ruby_super_l363_d40_permit_arch_flags(mut state SuperenvState) {
	state.append_to_cccfg('K')
}

// Ruby method `runtime_cpu_detection` at line 368.
pub fn ruby_super_l368_d41_runtime_cpu_detection(mut state SuperenvState) {
	state.append_to_cccfg('d')
}

// Ruby method `cxx11` at line 373.
pub fn ruby_super_l373_d42_cxx11(mut state SuperenvState) {
	state.append_to_cccfg('x')
	if state.homebrew_cc == 'clang' {
		state.append_to_cccfg('g')
	}
}

// Ruby method `libcxx` at line 379.
pub fn ruby_super_l379_d43_libcxx(mut state SuperenvState) {
	if state.compiler == 'clang' {
		state.append_to_cccfg('g')
	}
}

// Ruby method `set_debug_symbols` at line 384.
pub fn ruby_super_l384_d44_set_debug_symbols(mut state SuperenvState) {
	state.append_to_cccfg('D')
}

// Ruby method `refurbish_args` at line 389.
pub fn ruby_super_l389_d45_refurbish_args(mut state SuperenvState) {
	state.append_to_cccfg('O')
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

// Ruby method `O0(&block)` at line 396.
pub fn ruby_super_l396_d46_o0(mut state SuperenvState, block ?SuperenvVoidAction) ! {
	with_optimization_level(mut state, 'O0', block)!
}

// Ruby method `O1(&block)` at line 405.
pub fn ruby_super_l405_d47_o1(mut state SuperenvState, block ?SuperenvVoidAction) ! {
	with_optimization_level(mut state, 'O1', block)!
}

// Ruby method `O3(&block)` at line 414.
pub fn ruby_super_l414_d48_o3(mut state SuperenvState, block ?SuperenvVoidAction) ! {
	with_optimization_level(mut state, 'O3', block)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/ENV/shared"
// 5: require "development_tools"
// 6: require "utils/output"
// 7:
// 8: # ### Why `superenv`?
// 9: #
// 10: # 1. Only specify the environment we need (*NO* LDFLAGS for cmake)
// 11: # 2. Only apply compiler-specific options when we are calling that compiler
// 12: # 3. Force all incpaths and libpaths into the cc instantiation (fewer bugs)
// 13: # 4. Cater toolchain usage to specific Xcode versions
// 14: # 5. Remove flags that we don't want or that will break builds
// 15: # 6. Simpler code
// 16: # 7. Simpler formulae that *just work*
// 17: # 8. Build-system agnostic configuration of the toolchain
// 18: module Superenv
// 19:   include SharedEnvExtension
// 20:   include Utils::Output::Mixin
// 21:
// 22:   sig { returns(T::Array[Formula]) }
// 23:   attr_accessor :keg_only_deps
// 24:
// 25:   sig { returns(T::Array[Formula]) }
// 26:   attr_accessor :deps
// 27:
// 28:   sig { returns(T::Array[Formula]) }
// 29:   attr_accessor :run_time_deps
// 30:
// 31:   sig { params(base: Superenv).void }
// 32:   def self.extended(base)
// 33:     base.keg_only_deps = []
// 34:     base.deps = []
// 35:     base.run_time_deps = []
// 36:   end
// 37:
// 38:   # The location of Homebrew's shims.
// 39:   #
// 40:   # @api public
// 41:   sig { returns(Pathname) }
// 42:   def self.shims_path
// 43:     HOMEBREW_SHIMS_PATH/"super"
// 44:   end
// 45:
// 46:   sig { returns(T.nilable(Pathname)) }
// 47:   def self.bin; end
// 48:
// 49:   sig { void }
// 50:   def initialize
// 51:     @keg_only_deps = T.let([], T::Array[Formula])
// 52:     @deps = T.let([], T::Array[Formula])
// 53:     @run_time_deps = T.let([], T::Array[Formula])
// 54:
// 55:     @formula = T.let(nil, T.nilable(Formula))
// 56:   end
// 57:
// 58:   sig { void }
// 59:   def reset
// 60:     super
// 61:     # Configure scripts generated by autoconf 2.61 or later export as_nl, which
// 62:     # we use as a heuristic for running under configure
// 63:     delete("as_nl")
// 64:   end
// 65:
// 66:   sig {
// 67:     params(
// 68:       formula:         T.nilable(Formula),
// 69:       cc:              T.nilable(String),
// 70:       build_bottle:    T.nilable(T::Boolean),
// 71:       bottle_arch:     T.nilable(String),
// 72:       testing_formula: T::Boolean,
// 73:       debug_symbols:   T.nilable(T::Boolean),
// 74:     ).void
// 75:   }
// 76:   def setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil, testing_formula: false,
// 77:                               debug_symbols: false)
// 78:     super
// 79:     send(compiler)
// 80:
// 81:     self["HOMEBREW_ENV"] = "super"
// 82:     self["MAKEFLAGS"] ||= "-j#{determine_make_jobs}"
// 83:     self["RUSTC_WRAPPER"] = "#{HOMEBREW_SHIMS_PATH}/shared/rustc_wrapper"
// 84:     self["HOMEBREW_RUSTFLAGS"] = Hardware.rustflags_target_cpu(effective_arch)
// 85:     self["PATH"] = determine_path&.to_s
// 86:     self["PKG_CONFIG_PATH"] = determine_pkg_config_path&.to_s
// 87:     self["PKG_CONFIG_LIBDIR"] = (determine_pkg_config_libdir || "").to_s
// 88:     self["HOMEBREW_CCCFG"] = determine_cccfg
// 89:     self["HOMEBREW_OPTIMIZATION_LEVEL"] = compiler.match?(GNU_GCC_REGEXP) ? "O2" : "Os"
// 90:     self["HOMEBREW_BREW_FILE"] = HOMEBREW_BREW_FILE.to_s
// 91:     self["HOMEBREW_PREFIX"] = HOMEBREW_PREFIX.to_s
// 92:     self["HOMEBREW_CELLAR"] = HOMEBREW_CELLAR.to_s
// 93:     self["HOMEBREW_OPT"] = "#{HOMEBREW_PREFIX}/opt"
// 94:     self["HOMEBREW_TEMP"] = HOMEBREW_TEMP.to_s
// 95:     self["HOMEBREW_OPTFLAGS"] = determine_optflags
// 96:     self["HOMEBREW_MAKE_JOBS"] = determine_make_jobs.to_s
// 97:     self["CMAKE_PREFIX_PATH"] = determine_cmake_prefix_path&.to_s
// 98:     self["CMAKE_FRAMEWORK_PATH"] = determine_cmake_frameworks_path&.to_s
// 99:     self["CMAKE_INCLUDE_PATH"] = determine_cmake_include_path&.to_s
// 100:     self["CMAKE_LIBRARY_PATH"] = determine_cmake_library_path&.to_s
// 101:     self["ACLOCAL_PATH"] = determine_aclocal_path&.to_s
// 102:     self["M4"] = "#{HOMEBREW_PREFIX}/opt/m4/bin/m4" if deps.any? { |d| d.name == "libtool" }
// 103:     self["HOMEBREW_ISYSTEM_PATHS"] = determine_isystem_paths&.to_s
// 104:     self["HOMEBREW_INCLUDE_PATHS"] = determine_include_paths&.to_s
// 105:     self["HOMEBREW_LIBRARY_PATHS"] = determine_library_paths&.to_s
// 106:     self["HOMEBREW_DEPENDENCIES"] = determine_dependencies
// 107:     self["HOMEBREW_FORMULA_PREFIX"] = @formula.prefix.to_s unless @formula.nil?
// 108:     # Prevent the OpenSSL rust crate from building a vendored OpenSSL.
// 109:     # https://github.com/sfackler/rust-openssl/blob/994e5ff8c63557ab2aa85c85cc6956b0b0216ca7/openssl/src/lib.rs#L65
// 110:     self["OPENSSL_NO_VENDOR"] = "1"
// 111:     # Prevent Go from automatically downloading a newer toolchain than the one that we have.
// 112:     # https://tip.golang.org/doc/toolchain
// 113:     self["GOTOOLCHAIN"] = "local"
// 114:     # Prevent maturin from automatically downloading its own rust
// 115:     self["MATURIN_NO_INSTALL_RUST"] = "1"
// 116:     # Prevent Python packages from using bundled libraries by default.
// 117:     # Currently for hidapi, pyzmq and pynacl
// 118:     self["HIDAPI_SYSTEM_HIDAPI"] = "1"
// 119:     self["PYZMQ_NO_BUNDLE"] = "1"
// 120:     self["SODIUM_INSTALL"] = "system"
// 121:
// 122:     set_debug_symbols if debug_symbols
// 123:
// 124:     # The HOMEBREW_CCCFG ENV variable is used by the ENV/cc tool to control
// 125:     # compiler flag stripping. It consists of a string of characters which act
// 126:     # as flags. Some of these flags are mutually exclusive.
// 127:     #
// 128:     # O - Enables argument refurbishing. Only active under the
// 129:     #     make/bsdmake wrappers currently.
// 130:     # x - Enable C++11 mode.
// 131:     # g - Enable "-stdlib=libc++" for clang.
// 132:     # h - Enable "-stdlib=libstdc++" for clang.
// 133:     # K - Don't strip -arch <arch>, -m32, or -m64
// 134:     # d - Don't strip -march=<target>. Use only in formulae that
// 135:     #     have runtime detection of CPU features.
// 136:     # D - Generate debugging information
// 137:     # w - Pass `-no_weak_imports` to the linker
// 138:     # f - Pass `-no_fixup_chains` to `ld` whenever it
// 139:     #     is invoked with `-undefined dynamic_lookup`
// 140:     # c - Pass `-ld_classic` to `ld` whenever it is invoked
// 141:     #     with `-dead_strip_dylibs`
// 142:     # b - Pass `-mbranch-protection=standard` to the compiler
// 143:   end
// 144:
// 145:   sig { void }
// 146:   def llvm_clang
// 147:     super
// 148:     self["CC"] = self["OBJC"] = "clang"
// 149:     self["CXX"] = self["OBJCXX"] = "clang++"
// 150:   end
// 151:
// 152:   private
// 153:
// 154:   sig { params(val: T.any(String, Pathname)).void }
// 155:   def cc=(val)
// 156:     super
// 157:     self["HOMEBREW_CC"] = val.to_s
// 158:   end
// 159:
// 160:   sig { returns(String) }
// 161:   def determine_cxx
// 162:     determine_cc.to_s.gsub("gcc", "g++").gsub("clang", "clang++")
// 163:   end
// 164:
// 165:   sig { returns(T::Array[Pathname]) }
// 166:   def homebrew_extra_paths
// 167:     # Reverse sort by version so that we prefer the newest when there are multiple.
// 168:     deps.select { |d| d.name.match? Version.formula_optionally_versioned_regex(:python) }
// 169:         .sort_by(&:version)
// 170:         .reverse
// 171:         .map { |d| d.opt_libexec/"bin" }
// 172:   end
// 173:
// 174:   sig { returns(T.nilable(PATH)) }
// 175:   def determine_path
// 176:     path = PATH.new(Superenv.bin)
// 177:
// 178:     # Formula dependencies can override standard tools.
// 179:     path.append(deps.map(&:opt_bin))
// 180:     path.append(homebrew_extra_paths)
// 181:     path.append("/usr/bin", "/bin", "/usr/sbin", "/sbin")
// 182:
// 183:     begin
// 184:       path.append(gcc_version_formula(T.must(homebrew_cc)).opt_bin) if homebrew_cc&.match?(GNU_GCC_REGEXP)
// 185:     rescue FormulaUnavailableError
// 186:       # Don't fail and don't add these formulae to the path if they don't exist.
// 187:       nil
// 188:     end
// 189:
// 190:     path.existing
// 191:   end
// 192:
// 193:   sig { returns(T::Array[Pathname]) }
// 194:   def homebrew_extra_pkg_config_paths
// 195:     []
// 196:   end
// 197:
// 198:   sig { returns(T.nilable(PATH)) }
// 199:   def determine_pkg_config_path
// 200:     PATH.new(
// 201:       deps.map { |d| d.opt_lib/"pkgconfig" },
// 202:       deps.map { |d| d.opt_share/"pkgconfig" },
// 203:     ).existing
// 204:   end
// 205:
// 206:   sig { returns(T.nilable(PATH)) }
// 207:   def determine_pkg_config_libdir
// 208:     PATH.new(
// 209:       homebrew_extra_pkg_config_paths,
// 210:     ).existing
// 211:   end
// 212:
// 213:   sig { returns(T.nilable(PATH)) }
// 214:   def determine_aclocal_path
// 215:     PATH.new(
// 216:       keg_only_deps.map { |d| d.opt_share/"aclocal" },
// 217:       HOMEBREW_PREFIX/"share/aclocal",
// 218:     ).existing
// 219:   end
// 220:
// 221:   sig { returns(T::Array[Pathname]) }
// 222:   def homebrew_extra_isystem_paths
// 223:     []
// 224:   end
// 225:
// 226:   sig { returns(T.nilable(PATH)) }
// 227:   def determine_isystem_paths
// 228:     PATH.new(
// 229:       HOMEBREW_PREFIX/"include",
// 230:       homebrew_extra_isystem_paths,
// 231:     ).existing
// 232:   end
// 233:
// 234:   sig { returns(T.nilable(PATH)) }
// 235:   def determine_include_paths
// 236:     PATH.new(keg_only_deps.map(&:opt_include)).existing
// 237:   end
// 238:
// 239:   sig { returns(T::Array[Pathname]) }
// 240:   def homebrew_extra_library_paths
// 241:     []
// 242:   end
// 243:
// 244:   sig { returns(T.nilable(PATH)) }
// 245:   def determine_library_paths
// 246:     paths = []
// 247:     if compiler.match?(GNU_GCC_REGEXP)
// 248:       # Add path to GCC runtime libs for version being used to compile,
// 249:       # so that the linker will find those libs before any that may be linked in $HOMEBREW_PREFIX/lib.
// 250:       # https://github.com/Homebrew/brew/pull/11459#issuecomment-851075936
// 251:       begin
// 252:         f = gcc_version_formula(compiler.to_s)
// 253:       rescue FormulaUnavailableError
// 254:         nil
// 255:       else
// 256:         paths << (f.opt_lib/"gcc"/f.version.major) if f.any_version_installed?
// 257:       end
// 258:     end
// 259:
// 260:     # Don't add `llvm` to library paths; this leads to undesired linkage to LLVM's `libunwind`
// 261:     paths += keg_only_deps.reject { |dep| dep.name.match?(/^llvm(@\d+)?$/) }
// 262:                           .map(&:opt_lib)
// 263:     paths << (HOMEBREW_PREFIX/"lib")
// 264:
// 265:     paths += homebrew_extra_library_paths
// 266:     PATH.new(paths).existing
// 267:   end
// 268:
// 269:   sig { returns(String) }
// 270:   def determine_dependencies
// 271:     deps.map(&:name).join(",")
// 272:   end
// 273:
// 274:   sig { returns(T.nilable(PATH)) }
// 275:   def determine_cmake_prefix_path
// 276:     PATH.new(
// 277:       Superenv.bin&.parent,
// 278:       keg_only_deps.map(&:opt_prefix),
// 279:       HOMEBREW_PREFIX.to_s,
// 280:     ).existing
// 281:   end
// 282:
// 283:   sig { returns(T::Array[Pathname]) }
// 284:   def homebrew_extra_cmake_include_paths
// 285:     []
// 286:   end
// 287:
// 288:   sig { returns(T.nilable(PATH)) }
// 289:   def determine_cmake_include_path
// 290:     PATH.new(homebrew_extra_cmake_include_paths).existing
// 291:   end
// 292:
// 293:   sig { returns(T::Array[Pathname]) }
// 294:   def homebrew_extra_cmake_library_paths
// 295:     []
// 296:   end
// 297:
// 298:   sig { returns(T.nilable(PATH)) }
// 299:   def determine_cmake_library_path
// 300:     PATH.new(homebrew_extra_cmake_library_paths).existing
// 301:   end
// 302:
// 303:   sig { returns(T::Array[Pathname]) }
// 304:   def homebrew_extra_cmake_frameworks_paths
// 305:     []
// 306:   end
// 307:
// 308:   sig { returns(T.nilable(PATH)) }
// 309:   def determine_cmake_frameworks_path
// 310:     PATH.new(
// 311:       deps.map(&:opt_frameworks),
// 312:       homebrew_extra_cmake_frameworks_paths,
// 313:     ).existing
// 314:   end
// 315:
// 316:   sig { returns(String) }
// 317:   def determine_make_jobs
// 318:     Homebrew::EnvConfig.make_jobs
// 319:   end
// 320:
// 321:   sig { returns(String) }
// 322:   def determine_optflags
// 323:     Hardware::CPU.optimization_flags.fetch(effective_arch)
// 324:   rescue KeyError
// 325:     odebug "Building a bottle for custom architecture (#{effective_arch})..."
// 326:     Hardware::CPU.arch_flag(effective_arch)
// 327:   end
// 328:
// 329:   sig { returns(String) }
// 330:   def determine_cccfg
// 331:     ""
// 332:   end
// 333:
// 334:   public
// 335:
// 336:   # Removes the MAKEFLAGS environment variable, causing make to use a single job.
// 337:   # This is useful for makefiles with race conditions.
// 338:   # When passed a block, MAKEFLAGS is removed only for the duration of the block and is restored after its completion.
// 339:   sig { params(block: T.nilable(T.proc.returns(T.untyped))).returns(T.untyped) }
// 340:   def deparallelize(&block)
// 341:     old_makeflags = delete("MAKEFLAGS")
// 342:     old_make_jobs = delete("HOMEBREW_MAKE_JOBS")
// 343:     self["HOMEBREW_MAKE_JOBS"] = "1"
// 344:     if block
// 345:       begin
// 346:         yield
// 347:       ensure
// 348:         self["MAKEFLAGS"] = old_makeflags
// 349:         self["HOMEBREW_MAKE_JOBS"] = old_make_jobs
// 350:       end
// 351:     end
// 352:
// 353:     old_makeflags
// 354:   end
// 355:
// 356:   sig { returns(Integer) }
// 357:   def make_jobs
// 358:     self["MAKEFLAGS"] =~ /-\w*j(\d+)/
// 359:     [Regexp.last_match(1).to_i, 1].max
// 360:   end
// 361:
// 362:   sig { void }
// 363:   def permit_arch_flags
// 364:     append_to_cccfg "K"
// 365:   end
// 366:
// 367:   sig { void }
// 368:   def runtime_cpu_detection
// 369:     append_to_cccfg "d"
// 370:   end
// 371:
// 372:   sig { void }
// 373:   def cxx11
// 374:     append_to_cccfg "x"
// 375:     append_to_cccfg "g" if homebrew_cc == "clang"
// 376:   end
// 377:
// 378:   sig { void }
// 379:   def libcxx
// 380:     append_to_cccfg "g" if compiler == :clang
// 381:   end
// 382:
// 383:   sig { void }
// 384:   def set_debug_symbols
// 385:     append_to_cccfg "D"
// 386:   end
// 387:
// 388:   sig { void }
// 389:   def refurbish_args
// 390:     append_to_cccfg "O"
// 391:   end
// 392:
// 393:   # This is an exception where we want to use this method name format.
// 394:   # rubocop: disable Naming/MethodName
// 395:   sig { params(block: T.nilable(T.proc.void)).void }
// 396:   def O0(&block)
// 397:     if block
// 398:       with_env(HOMEBREW_OPTIMIZATION_LEVEL: "O0", &block)
// 399:     else
// 400:       self["HOMEBREW_OPTIMIZATION_LEVEL"] = "O0"
// 401:     end
// 402:   end
// 403:
// 404:   sig { params(block: T.nilable(T.proc.void)).void }
// 405:   def O1(&block)
// 406:     if block
// 407:       with_env(HOMEBREW_OPTIMIZATION_LEVEL: "O1", &block)
// 408:     else
// 409:       self["HOMEBREW_OPTIMIZATION_LEVEL"] = "O1"
// 410:     end
// 411:   end
// 412:
// 413:   sig { params(block: T.nilable(T.proc.void)).void }
// 414:   def O3(&block)
// 415:     if block
// 416:       with_env(HOMEBREW_OPTIMIZATION_LEVEL: "O3", &block)
// 417:     else
// 418:       self["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
// 419:     end
// 420:   end
// 421:   # rubocop: enable Naming/MethodName
// 422: end
// 423:
// 424: require "extend/os/extend/ENV/super"
