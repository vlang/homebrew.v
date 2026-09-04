module linux

import ruby
import os

// Translated from Homebrew/brew `extend/os/linux/development_tools.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `locate(tool)` at line 13.
pub fn ruby_development_tools_l13_d1_locate(args ...ruby.Value) ruby.Value {
	mut tools, offset := linux_development_tools_from_args(args)
	if args.len <= offset {
		return ruby.object_value('NilClass', 'nil')
	}
	path := tools.locate(args[offset].as_string()) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.object_value('Pathname', path)
}

// Ruby method `default_compiler = :gcc` at line 31.
pub fn ruby_development_tools_l31_d2_default_compiler(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', 'gcc')
}

// Ruby method `installation_instructions` at line 34.
pub fn ruby_development_tools_l34_d3_installation_instructions(args ...ruby.Value) ruby.Value {
	return ruby.string_value(linux_development_tools_installation_instructions())
}

// Ruby method `custom_installation_instructions` at line 43.
pub fn ruby_development_tools_l43_d4_custom_installation_instructions(args ...ruby.Value) ruby.Value {
	return ruby.string_value(linux_development_tools_custom_installation_instructions())
}

// Ruby method `needs_libc_formula?` at line 51.
pub fn ruby_development_tools_l51_d5_needs_libc_formula(args ...ruby.Value) ruby.Value {
	mut tools, _ := linux_development_tools_from_args(args)
	return ruby.bool_value(tools.needs_libc_formula())
}

// Ruby method `host_gcc_path` at line 63.
pub fn ruby_development_tools_l63_d6_host_gcc_path(args ...ruby.Value) ruby.Value {
	tools, _ := linux_development_tools_from_args(args)
	return ruby.object_value('Pathname', tools.host_gcc_path())
}

// Ruby method `needs_compiler_formula?` at line 72.
pub fn ruby_development_tools_l72_d7_needs_compiler_formula(args ...ruby.Value) ruby.Value {
	mut tools, _ := linux_development_tools_from_args(args)
	return ruby.bool_value(tools.needs_compiler_formula())
}

// Ruby method `build_system_info` at line 84.
pub fn ruby_development_tools_l84_d8_build_system_info(args ...ruby.Value) ruby.Value {
	tools, _ := linux_development_tools_from_args(args)
	mut result := map[string]ruby.Value{}
	for key, value in tools.build_system_info() {
		result[key] = if value == '' {
			ruby.object_value('NilClass', 'nil')
		} else {
			ruby.string_value(value)
		}
	}
	return ruby.map_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module DevelopmentTools
// 7:       module ClassMethods
// 8:         extend T::Helpers
// 9:
// 10:         requires_ancestor { ::DevelopmentTools }
// 11:
// 12:         sig { params(tool: T.any(String, Symbol)).returns(T.nilable(::Pathname)) }
// 13:         def locate(tool)
// 14:           @locate ||= T.let({}, T.nilable(T::Hash[T.any(String, Symbol), ::Pathname]))
// 15:           @locate.fetch(tool) do |key|
// 16:             @locate[key] = if ::DevelopmentTools.needs_build_formulae? &&
// 17:                               (binutils_path = HOMEBREW_PREFIX/"opt/binutils/bin/#{tool}").executable?
// 18:               binutils_path
// 19:             elsif ::DevelopmentTools.needs_build_formulae? &&
// 20:                   (glibc_path = HOMEBREW_PREFIX/"opt/glibc/bin/#{tool}").executable?
// 21:               glibc_path
// 22:             elsif (homebrew_path = HOMEBREW_PREFIX/"bin/#{tool}").executable?
// 23:               homebrew_path
// 24:             elsif File.executable?(system_path = "/usr/bin/#{tool}")
// 25:               ::Pathname.new system_path
// 26:             end
// 27:           end
// 28:         end
// 29:
// 30:         sig { returns(Symbol) }
// 31:         def default_compiler = :gcc
// 32:
// 33:         sig { returns(String) }
// 34:         def installation_instructions
// 35:           <<~EOS
// 36:             Install a system C compiler and the standard development tools for
// 37:             your Linux distribution. See:
// 38:               https://docs.brew.sh/Homebrew-on-Linux#requirements
// 39:           EOS
// 40:         end
// 41:
// 42:         sig { returns(String) }
// 43:         def custom_installation_instructions
// 44:           <<~EOS
// 45:             Install GNU's GCC:
// 46:               brew install gcc
// 47:           EOS
// 48:         end
// 49:
// 50:         sig { returns(T::Boolean) }
// 51:         def needs_libc_formula?
// 52:           return @needs_libc_formula unless @needs_libc_formula.nil?
// 53:
// 54:           @needs_libc_formula = T.let(nil, T.nilable(T::Boolean))
// 55:
// 56:           # Undocumented environment variable to make it easier to test libc
// 57:           # formula automatic installation.
// 58:           @needs_libc_formula = true if ENV["HOMEBREW_FORCE_LIBC_FORMULA"]
// 59:           @needs_libc_formula ||= OS::Linux::Glibc.below_ci_version?
// 60:         end
// 61:
// 62:         sig { returns(::Pathname) }
// 63:         def host_gcc_path
// 64:           # Prioritise versioned path if installed
// 65:           path = ::Pathname.new("/usr/bin/#{OS::LINUX_PREFERRED_GCC_COMPILER_FORMULA.tr("@", "-")}")
// 66:           return path if path.exist?
// 67:
// 68:           super
// 69:         end
// 70:
// 71:         sig { returns(T::Boolean) }
// 72:         def needs_compiler_formula?
// 73:           return @needs_compiler_formula unless @needs_compiler_formula.nil?
// 74:
// 75:           @needs_compiler_formula = T.let(nil, T.nilable(T::Boolean))
// 76:
// 77:           # Undocumented environment variable to make it easier to test compiler
// 78:           # formula automatic installation.
// 79:           @needs_compiler_formula = true if ENV["HOMEBREW_FORCE_COMPILER_FORMULA"]
// 80:           @needs_compiler_formula ||= OS::Linux::Libstdcxx.below_ci_version?
// 81:         end
// 82:
// 83:         sig { returns(T::Hash[String, T.nilable(String)]) }
// 84:         def build_system_info
// 85:           super.merge({
// 86:             "glibc_version"     => OS::Linux::Glibc.version.to_s.presence,
// 87:             "oldest_cpu_family" => ::Hardware.oldest_cpu.to_s,
// 88:           })
// 89:         end
// 90:       end
// 91:     end
// 92:   end
// 93: end
// 94:
// 95: DevelopmentTools.singleton_class.prepend(OS::Linux::DevelopmentTools::ClassMethods)
