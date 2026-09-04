module linux

import ruby
import os

// Translated from Homebrew/brew `extend/os/linux/development_tools.rb`.
pub struct LinuxDevelopmentTools {
pub:
	prefix                     string
	executable_paths           []string
	force_libc_formula         bool
	glibc_below_ci_version     bool
	force_compiler_formula     bool
	libstdcxx_below_ci_version bool
	preferred_gcc_formula      string = 'gcc'
	glibc_version              string
	oldest_cpu_family          string
	base_build_info            map[string]string
mut:
	locate_cache    map[string]string
	libc_cached     bool
	needs_libc      bool
	compiler_cached bool
	needs_compiler  bool
}

pub fn new_linux_development_tools(prefix string) &LinuxDevelopmentTools {
	return &LinuxDevelopmentTools{
		prefix: prefix
		force_libc_formula: os.getenv_opt('HOMEBREW_FORCE_LIBC_FORMULA') != none
		force_compiler_formula: os.getenv_opt('HOMEBREW_FORCE_COMPILER_FORMULA') != none
		oldest_cpu_family: os.getenv('HOMEBREW_PROCESSOR')
		locate_cache: map[string]string{}
	}
}

fn (tools LinuxDevelopmentTools) executable(path string) bool {
	if tools.executable_paths.len > 0 {
		return path in tools.executable_paths
	}
	return os.is_file(path) && os.is_executable(path)
}

pub fn (mut tools LinuxDevelopmentTools) needs_libc_formula() bool {
	if !tools.libc_cached {
		tools.libc_cached = true
		tools.needs_libc = tools.force_libc_formula || tools.glibc_below_ci_version
	}
	return tools.needs_libc
}

pub fn (mut tools LinuxDevelopmentTools) needs_compiler_formula() bool {
	if !tools.compiler_cached {
		tools.compiler_cached = true
		tools.needs_compiler = tools.force_compiler_formula || tools.libstdcxx_below_ci_version
	}
	return tools.needs_compiler
}

pub fn (mut tools LinuxDevelopmentTools) needs_build_formulae() bool {
	return tools.needs_libc_formula() || tools.needs_compiler_formula()
}

pub fn (mut tools LinuxDevelopmentTools) locate(tool string) ?string {
	if tool in tools.locate_cache {
		cached := tools.locate_cache[tool]
		return if cached == '' { none } else { cached }
	}
	needs_build := tools.needs_build_formulae()
	candidates := [
		if needs_build { os.join_path(tools.prefix, 'opt', 'binutils', 'bin', tool) } else { '' },
		if needs_build { os.join_path(tools.prefix, 'opt', 'glibc', 'bin', tool) } else { '' },
		os.join_path(tools.prefix, 'bin', tool),
		'/usr/bin/${tool}',
	]
	mut path := ''
	for candidate in candidates {
		if candidate != '' && tools.executable(candidate) {
			path = candidate
			break
		}
	}
	tools.locate_cache[tool] = path
	return if path == '' { none } else { path }
}

pub fn linux_development_tools_installation_instructions() string {
	return 'Install a system C compiler and the standard development tools for\nyour Linux distribution. See:\n  https://docs.brew.sh/Homebrew-on-Linux#requirements\n'
}

pub fn linux_development_tools_custom_installation_instructions() string {
	return "Install GNU's GCC:\n  brew install gcc\n"
}

pub fn (tools LinuxDevelopmentTools) host_gcc_path() string {
	versioned := '/usr/bin/${tools.preferred_gcc_formula.replace('@', '-')}'
	return if os.exists(versioned) || versioned in tools.executable_paths {
		versioned
	} else {
		'/usr/bin/gcc'
	}
}

pub fn (tools LinuxDevelopmentTools) build_system_info() map[string]string {
	mut result := tools.base_build_info.clone()
	result['glibc_version'] = tools.glibc_version
	result['oldest_cpu_family'] = tools.oldest_cpu_family
	return result
}

fn linux_development_tools_value(tools &LinuxDevelopmentTools) ruby.Value {
	return ruby.structured_value('DevelopmentTools', '', {
		'linux_development_tools_address': u64(voidptr(tools)).str()
	})
}

fn linux_development_tools_from_args(args []ruby.Value) (&LinuxDevelopmentTools, int) {
	if args.len > 0 && 'linux_development_tools_address' in args[0].attributes {
		return unsafe { &LinuxDevelopmentTools(voidptr(args[0].attributes['linux_development_tools_address'].u64())) }, 1
	}
	return new_linux_development_tools(os.getenv('HOMEBREW_PREFIX')), 0
}

pub fn linux_development_tools_boundary(tools &LinuxDevelopmentTools) ruby.Value {
	return linux_development_tools_value(tools)
}
