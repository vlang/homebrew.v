module language

import brew_runtime

// Translated from Homebrew/brew `language/java.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.find_openjdk_formula(version = nil)` at line 10.
pub fn ruby_java_l10_d1_self_find_openjdk_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.find_openjdk_formula', ...args)
}

// Ruby method `self.java_home(version = nil)` at line 39.
pub fn ruby_java_l39_d2_self_java_home(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.java_home', ...args)
}

// Ruby method `self.java_home_shell(version = nil)` at line 44.
pub fn ruby_java_l44_d3_self_java_home_shell(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.java_home_shell', ...args)
}

// Ruby method `self.java_home_env(version = nil)` at line 63.
pub fn ruby_java_l63_d4_self_java_home_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.java_home_env', ...args)
}

// Ruby method `self.overridable_java_home_env(version = nil)` at line 80.
pub fn ruby_java_l80_d5_self_overridable_java_home_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.overridable_java_home_env', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Language
// 5:   # Helper functions for Java formulae.
// 6:   #
// 7:   # @api public
// 8:   module Java
// 9:     sig { params(version: T.nilable(String)).returns(T.nilable(Formula)) }
// 10:     def self.find_openjdk_formula(version = nil)
// 11:       can_be_newer = version&.end_with?("+")
// 12:       version = version.to_i
// 13:
// 14:       openjdk = Formula["openjdk"]
// 15:       [openjdk, *openjdk.versioned_formulae].find do |f|
// 16:         next false unless f.any_version_installed?
// 17:
// 18:         unless version.zero?
// 19:           major = T.must(f.any_installed_version).major
// 20:           next false if major < version
// 21:           next false if major > version && !can_be_newer
// 22:         end
// 23:
// 24:         true
// 25:       end
// 26:     rescue FormulaUnavailableError
// 27:       nil
// 28:     end
// 29:     private_class_method :find_openjdk_formula
// 30:
// 31:     # Returns the directory of the newest matching OpenJDK installation or
// 32:     # `nil` if none is available. When used in a {Formula}, there should be
// 33:     # a dependency and corresponding `version` for reproducible output.
// 34:     #
// 35:     # @api public
// 36:     # @param version OpenJDK version constraint which can be specific
// 37:     #   (e.g. `"21"`) or a lower-bounded range (e.g. `"21+"`)
// 38:     sig { params(version: T.nilable(String)).returns(T.nilable(Pathname)) }
// 39:     def self.java_home(version = nil)
// 40:       find_openjdk_formula(version)&.opt_libexec
// 41:     end
// 42:
// 43:     sig { params(version: T.nilable(String)).returns(String) }
// 44:     def self.java_home_shell(version = nil)
// 45:       java_home(version).to_s
// 46:     end
// 47:     private_class_method :java_home_shell
// 48:
// 49:     # Returns a `JAVA_HOME` environment variable to use a specific OpenJDK.
// 50:     # Usually combined with either {Pathname#write_env_script} or
// 51:     # {Pathname#env_script_all_files}.
// 52:     #
// 53:     # ### Example
// 54:     #
// 55:     # Use `openjdk@21` for all commands:
// 56:     #
// 57:     # ```ruby
// 58:     # bin.env_script_all_files libexec/"bin", Language::Java.java_home_env("21")
// 59:     # ```
// 60:     #
// 61:     # @api public
// 62:     sig { params(version: T.nilable(String)).returns({ JAVA_HOME: String }) }
// 63:     def self.java_home_env(version = nil)
// 64:       { JAVA_HOME: java_home_shell(version) }
// 65:     end
// 66:
// 67:     # Returns a `JAVA_HOME` environment variable to use a default OpenJDK.
// 68:     # Unlike {.java_home_env} the OpenJDK can be overridden at runtime.
// 69:     #
// 70:     # ### Example
// 71:     #
// 72:     # Use latest `openjdk` as default:
// 73:     #
// 74:     # ```ruby
// 75:     # bin.env_script_all_files libexec/"bin", Language::Java.overridable_java_home_env
// 76:     # ```
// 77:     #
// 78:     # @api public
// 79:     sig { params(version: T.nilable(String)).returns({ JAVA_HOME: String }) }
// 80:     def self.overridable_java_home_env(version = nil)
// 81:       { JAVA_HOME: "${JAVA_HOME:-#{java_home_shell(version)}}" }
// 82:     end
// 83:   end
// 84: end
// 85:
// 86: require "extend/os/language/java"
