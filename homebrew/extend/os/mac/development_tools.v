module mac

import brew_runtime

pub struct MacDevelopmentTools {
pub mut:
	locate_cache map[string]string
	xcrun_calls  []string
	ld64_cached  bool
	ld64_version string
pub:
	base_tools                    map[string]string
	xcrun_results                 map[string]string
	executable_paths              []string
	xcode_installed               bool
	clt_installed                 bool
	ld64_output                   string
	ld64_success                  bool
	system_curl_too_old           bool
	clt_installation_instructions string
	xcode_version                 string
	clt_version                   string
	preferred_perl_version        string
	base_build_info               map[string]string
}

pub fn new_mac_development_tools() &MacDevelopmentTools {
	return &MacDevelopmentTools{
		locate_cache: map[string]string{}
		xcrun_calls: []string{}
	}
}

pub fn (tools MacDevelopmentTools) installed() bool {
	return tools.xcode_installed || tools.clt_installed
}

pub fn (mut tools MacDevelopmentTools) locate(tool string) ?string {
	if tool in tools.locate_cache {
		cached := tools.locate_cache[tool]
		return if cached == '' { none } else { cached }
	}
	if base := tools.base_tools[tool] {
		if base != '' {
			tools.locate_cache[tool] = base
			return base
		}
	}
	if !tools.installed() {
		tools.locate_cache[tool] = ''
		return none
	}
	tools.xcrun_calls << '/usr/bin/xcrun -no-cache -find ${tool}'
	path := (tools.xcrun_results[tool] or { '' }).trim_right('\n')
	if path == '' || path !in tools.executable_paths {
		tools.locate_cache[tool] = ''
		return none
	}
	tools.locate_cache[tool] = path
	return path
}

fn ld64_json_version(output string) string {
	marker := '"version"'
	if !output.contains(marker) {
		return ''
	}
	rest := output.all_after(marker).all_after(':').trim_space()
	return rest.trim_left('"').all_before('"').trim_space()
}

pub fn (mut tools MacDevelopmentTools) parsed_ld64_version() string {
	if tools.ld64_cached {
		return tools.ld64_version
	}
	tools.ld64_cached = true
	tools.ld64_version = if tools.ld64_success { ld64_json_version(tools.ld64_output) } else { '' }
	return tools.ld64_version
}

pub fn (tools MacDevelopmentTools) build_system_info() map[string]string {
	mut result := tools.base_build_info.clone()
	result['xcode'] = tools.xcode_version
	result['clt'] = tools.clt_version
	result['preferred_perl'] = tools.preferred_perl_version
	return result
}

fn development_tools_value(tools &MacDevelopmentTools) brew_runtime.Value {
	return brew_runtime.structured_value('DevelopmentTools', '', {
		'mac_development_tools_address': u64(voidptr(tools)).str()
	})
}

fn development_tools_from_value(value brew_runtime.Value) &MacDevelopmentTools {
	return unsafe { &MacDevelopmentTools(voidptr(value.attributes['mac_development_tools_address'].u64())) }
}

pub fn mac_development_tools_boundary(tools &MacDevelopmentTools) brew_runtime.Value {
	return development_tools_value(tools)
}

// Translated from Homebrew/brew `extend/os/mac/development_tools.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `locate(tool)` at line 15.
pub fn ruby_development_tools_l15_d1_locate(args ...brew_runtime.Value) brew_runtime.Value {
	mut tools := development_tools_from_value(args[0])
	path := tools.locate(args[1].as_string()) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_value(path)
}

// Ruby method `installed?` at line 31.
pub fn ruby_development_tools_l31_d2_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(development_tools_from_value(args[0]).installed())
}

// Ruby method `default_compiler` at line 36.
pub fn ruby_development_tools_l36_d3_default_compiler(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', 'clang')
}

// Ruby method `ld64_version` at line 41.
pub fn ruby_development_tools_l41_d4_ld64_version(args ...brew_runtime.Value) brew_runtime.Value {
	mut tools := development_tools_from_value(args[0])
	version := tools.parsed_ld64_version()
	return if version == '' {
		brew_runtime.object_value('Version::NULL', '')
	} else {
		brew_runtime.string_value(version)
	}
}

// Ruby method `curl_handles_most_https_certificates?` at line 53.
pub fn ruby_development_tools_l53_d5_curl_handles_most_https_certificates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(!development_tools_from_value(args[0]).system_curl_too_old)
}

// Ruby method `installation_instructions` at line 60.
pub fn ruby_development_tools_l60_d6_installation_instructions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(development_tools_from_value(args[0]).clt_installation_instructions)
}

// Ruby method `custom_installation_instructions` at line 65.
pub fn ruby_development_tools_l65_d7_custom_installation_instructions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value("Install GNU's GCC:\n  brew install gcc\n")
}

// Ruby method `build_system_info` at line 73.
pub fn ruby_development_tools_l73_d8_build_system_info(args ...brew_runtime.Value) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in development_tools_from_value(args[0]).build_system_info() {
		result[key] = if value == '' {
			brew_runtime.object_value('NilClass', 'nil')
		} else {
			brew_runtime.string_value(value)
		}
	}
	return brew_runtime.map_value(result)
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
