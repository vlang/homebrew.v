module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/development_tools.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `locate(tool)` at line 15.
pub fn ruby_development_tools_l15_d1_locate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locate', ...args)
}

// Ruby method `installed?` at line 31.
pub fn ruby_development_tools_l31_d2_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed?', ...args)
}

// Ruby method `default_compiler` at line 36.
pub fn ruby_development_tools_l36_d3_default_compiler(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default_compiler', ...args)
}

// Ruby method `ld64_version` at line 41.
pub fn ruby_development_tools_l41_d4_ld64_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ld64_version', ...args)
}

// Ruby method `curl_handles_most_https_certificates?` at line 53.
pub fn ruby_development_tools_l53_d5_curl_handles_most_https_certificates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('curl_handles_most_https_certificates?', ...args)
}

// Ruby method `installation_instructions` at line 60.
pub fn ruby_development_tools_l60_d6_installation_instructions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installation_instructions', ...args)
}

// Ruby method `custom_installation_instructions` at line 65.
pub fn ruby_development_tools_l65_d7_custom_installation_instructions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('custom_installation_instructions', ...args)
}

// Ruby method `build_system_info` at line 73.
pub fn ruby_development_tools_l73_d8_build_system_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_system_info', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/xcode"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module DevelopmentTools
// 9:       module ClassMethods
// 10:         extend T::Helpers
// 11:
// 12:         requires_ancestor { ::DevelopmentTools }
// 13:
// 14:         sig { params(tool: T.any(String, Symbol)).returns(T.nilable(::Pathname)) }
// 15:         def locate(tool)
// 16:           @locate ||= T.let({}, T.nilable(T::Hash[T.any(String, Symbol), Pathname]))
// 17:           @locate.fetch(tool) do |key|
// 18:             @locate[key] = if (located_tool = super(tool))
// 19:               located_tool
// 20:             elsif installed?
// 21:               path = Utils.popen_read("/usr/bin/xcrun", "-no-cache", "-find", tool.to_s, err: :close).chomp
// 22:               ::Pathname.new(path) if File.executable?(path)
// 23:             end
// 24:           end
// 25:         end
// 26:
// 27:         # Checks if the user has any developer tools installed, either via Xcode
// 28:         # or the CLT. Convenient for guarding against formula builds when building
// 29:         # is impossible.
// 30:         sig { returns(T::Boolean) }
// 31:         def installed?
// 32:           MacOS::Xcode.installed? || MacOS::CLT.installed?
// 33:         end
// 34:
// 35:         sig { returns(Symbol) }
// 36:         def default_compiler
// 37:           :clang
// 38:         end
// 39:
// 40:         sig { returns(Version) }
// 41:         def ld64_version
// 42:           @ld64_version ||= T.let(begin
// 43:             json = Utils.popen_read("/usr/bin/ld", "-version_details")
// 44:             if $CHILD_STATUS.success?
// 45:               Version.parse(JSON.parse(json)["version"])
// 46:             else
// 47:               Version::NULL
// 48:             end
// 49:           end, T.nilable(Version))
// 50:         end
// 51:
// 52:         sig { returns(T::Boolean) }
// 53:         def curl_handles_most_https_certificates?
// 54:           # The system Curl is too old for some modern HTTPS certificates on
// 55:           # older macOS versions.
// 56:           ENV["HOMEBREW_SYSTEM_CURL_TOO_OLD"].nil?
// 57:         end
// 58:
// 59:         sig { returns(String) }
// 60:         def installation_instructions
// 61:           MacOS::CLT.installation_instructions
// 62:         end
// 63:
// 64:         sig { returns(String) }
// 65:         def custom_installation_instructions
// 66:           <<~EOS
// 67:             Install GNU's GCC:
// 68:               brew install gcc
// 69:           EOS
// 70:         end
// 71:
// 72:         sig { returns(T::Hash[String, T.nilable(String)]) }
// 73:         def build_system_info
// 74:           build_info = {
// 75:             "xcode"          => MacOS::Xcode.version.to_s.presence,
// 76:             "clt"            => MacOS::CLT.version.to_s.presence,
// 77:             "preferred_perl" => MacOS.preferred_perl_version,
// 78:           }
// 79:           super.merge build_info
// 80:         end
// 81:       end
// 82:     end
// 83:   end
// 84: end
// 85:
// 86: DevelopmentTools.singleton_class.prepend(OS::Mac::DevelopmentTools::ClassMethods)
