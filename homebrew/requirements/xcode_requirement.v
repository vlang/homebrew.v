module requirements

import brew_runtime

// Translated from Homebrew/brew `requirements/xcode_requirement.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :version` at line 13.
pub fn ruby_xcode_requirement_l13_d1_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby method `initialize(tags = [])` at line 21.
pub fn ruby_xcode_requirement_l21_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `xcode_installed_version!` at line 28.
pub fn ruby_xcode_requirement_l28_d3_xcode_installed_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('xcode_installed_version!', ...args)
}

// Ruby method `message` at line 36.
pub fn ruby_xcode_requirement_l36_d4_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('message', ...args)
}

// Ruby method `inspect` at line 57.
pub fn ruby_xcode_requirement_l57_d5_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby method `display_s` at line 62.
pub fn ruby_xcode_requirement_l62_d6_display_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('display_s', ...args)
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
