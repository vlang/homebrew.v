module requirements

import brew_runtime
import homebrew

// Translated from Homebrew/brew `requirements/xcode_requirement.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct XcodeRequirement {
pub:
	version ?string
	tags    []string
	fatal   bool = true
}

fn looks_like_xcode_version(value string) bool {
	mut dot_groups := 0
	for index, character in value {
		if character == `.` && index > 0 && index + 1 < value.len && value[index - 1].is_digit() && value[index + 1].is_digit() {
			dot_groups++
		}
	}
	return dot_groups > 0
}

pub fn new_xcode_requirement(tags []string) XcodeRequirement {
	if tags.len > 0 && looks_like_xcode_version(tags[0]) {
		return XcodeRequirement{
			version: tags[0]
			tags: tags[1..].clone()
		}
	}
	return XcodeRequirement{
		tags: tags.clone()
	}
}

pub fn (requirement XcodeRequirement) xcode_installed_version(installed bool,
	installed_version string) bool {
	if !installed {
		return false
	}
	required := requirement.version or { return true }
	current := homebrew.new_version(installed_version) or { return false }
	minimum := homebrew.new_version(required) or { return false }
	return current.compare_to(minimum) >= 0
}

pub fn (requirement XcodeRequirement) satisfied() bool {
	if brew_runtime.kernel_info().name == 'Linux' {
		return true
	}
	installed_version := brew_runtime.environment_value('HOMEBREW_XCODE_VERSION')
	return requirement.xcode_installed_version(installed_version.len > 0, installed_version)
}

pub fn (requirement XcodeRequirement) message(latest_version string,
	macos_version string) string {
	required := requirement.version or { '' }
	version_suffix := if required.len > 0 { ' ${required}' } else { '' }
	mut output := 'A full installation of Xcode.app${version_suffix} is required to compile\nthis software. Installing just the Command Line Tools is not sufficient.\n'
	latest := homebrew.new_version(latest_version) or { homebrew.null_version() }
	minimum := homebrew.new_version(required) or { homebrew.null_version() }
	if required.len > 0 && !latest.is_null() && latest.compare_to(minimum) < 0 {
		output += '\nXcode${version_suffix} cannot be installed on macOS ${macos_version}.\nYou must upgrade your version of macOS.\n'
	} else {
		output += '\nXcode can be installed from the App Store.\n'
	}
	return output
}

pub fn (requirement XcodeRequirement) inspect() string {
	version_text := requirement.version or { 'nil' }
	quoted := if version_text == 'nil' { version_text } else { '"${version_text}"' }
	return '#<XcodeRequirement: version>=${quoted} ${requirement_tags_inspect(requirement.tags)}>'
}

pub fn (requirement XcodeRequirement) display_s() string {
	version := requirement.version or { return 'Xcode (on macOS)' }
	return 'Xcode >= ${version} (on macOS)'
}

// Ruby attr_reader `attr_reader :version` at line 13.
pub fn ruby_xcode_requirement_l13_d1_version(requirement XcodeRequirement) ?string {
	return requirement.version
}

// Ruby method `initialize(tags = [])` at line 21.
pub fn ruby_xcode_requirement_l21_d2_initialize(tags []string) XcodeRequirement {
	return new_xcode_requirement(tags)
}

// Ruby method `xcode_installed_version!` at line 28.
pub fn ruby_xcode_requirement_l28_d3_xcode_installed_version(requirement XcodeRequirement) bool {
	return requirement.satisfied()
}

// Ruby method `message` at line 36.
pub fn ruby_xcode_requirement_l36_d4_message(requirement XcodeRequirement) string {
	return requirement.message(brew_runtime.environment_value('HOMEBREW_LATEST_XCODE_VERSION'), brew_runtime.environment_value('HOMEBREW_MACOS_VERSION'))
}

// Ruby method `inspect` at line 57.
pub fn ruby_xcode_requirement_l57_d5_inspect(requirement XcodeRequirement) string {
	return requirement.inspect()
}

// Ruby method `display_s` at line 62.
pub fn ruby_xcode_requirement_l62_d6_display_s(requirement XcodeRequirement) string {
	return requirement.display_s()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "requirement"
// 5:
// 6: # A requirement on Xcode.
// 7: class XcodeRequirement < Requirement
// 8:   Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 9:
// 10:   fatal true
// 11:
// 12:   sig { returns(T.nilable(String)) }
// 13:   attr_reader :version
// 14:
// 15:   satisfy(build_env: false) do
// 16:     T.bind(self, XcodeRequirement)
// 17:     xcode_installed_version!
// 18:   end
// 19:
// 20:   sig { params(tags: T::Array[T.any(String, Symbol)]).void }
// 21:   def initialize(tags = [])
// 22:     version = tags.shift if tags.first.to_s.match?(/(\d\.)+\d/)
// 23:     @version = T.let(version&.to_s, T.nilable(String))
// 24:     super
// 25:   end
// 26:
// 27:   sig { returns(T::Boolean) }
// 28:   def xcode_installed_version!
// 29:     return false unless MacOS::Xcode.installed?
// 30:     return true unless @version
// 31:
// 32:     MacOS::Xcode.version >= @version
// 33:   end
// 34:
// 35:   sig { returns(String) }
// 36:   def message
// 37:     version = " #{@version}" if @version
// 38:     message = <<~EOS
// 39:       A full installation of Xcode.app#{version} is required to compile
// 40:       this software. Installing just the Command Line Tools is not sufficient.
// 41:     EOS
// 42:     if @version && Version.new(MacOS::Xcode.latest_version) < Version.new(@version)
// 43:       message + <<~EOS
// 44:
// 45:         Xcode#{version} cannot be installed on macOS #{MacOS.version}.
// 46:         You must upgrade your version of macOS.
// 47:       EOS
// 48:     else
// 49:       message + <<~EOS
// 50:
// 51:         Xcode can be installed from the App Store.
// 52:       EOS
// 53:     end
// 54:   end
// 55:
// 56:   sig { returns(String) }
// 57:   def inspect
// 58:     "#<#{self.class.name}: version>=#{@version.inspect} #{tags.inspect}>"
// 59:   end
// 60:
// 61:   sig { returns(String) }
// 62:   def display_s
// 63:     return "#{name.capitalize} (on macOS)" unless @version
// 64:
// 65:     "#{name.capitalize} >= #{@version} (on macOS)"
// 66:   end
// 67: end
// 68:
// 69: require "extend/os/requirements/xcode_requirement"
