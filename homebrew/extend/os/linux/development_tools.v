module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/development_tools.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `locate(tool)` at line 13.
pub fn ruby_development_tools_l13_d1_locate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locate', ...args)
}

// Ruby method `default_compiler = :gcc` at line 31.
pub fn ruby_development_tools_l31_d2_default_compiler(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default_compiler', ...args)
}

// Ruby method `installation_instructions` at line 34.
pub fn ruby_development_tools_l34_d3_installation_instructions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installation_instructions', ...args)
}

// Ruby method `custom_installation_instructions` at line 43.
pub fn ruby_development_tools_l43_d4_custom_installation_instructions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('custom_installation_instructions', ...args)
}

// Ruby method `needs_libc_formula?` at line 51.
pub fn ruby_development_tools_l51_d5_needs_libc_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('needs_libc_formula?', ...args)
}

// Ruby method `host_gcc_path` at line 63.
pub fn ruby_development_tools_l63_d6_host_gcc_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('host_gcc_path', ...args)
}

// Ruby method `needs_compiler_formula?` at line 72.
pub fn ruby_development_tools_l72_d7_needs_compiler_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('needs_compiler_formula?', ...args)
}

// Ruby method `build_system_info` at line 84.
pub fn ruby_development_tools_l84_d8_build_system_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_system_info', ...args)
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
