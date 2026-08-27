module dsl

import brew_runtime

// Translated from Homebrew/brew `cask/dsl/base.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :cask` at line 14.
pub fn ruby_base_l14_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby attr_reader `attr_reader :command` at line 17.
pub fn ruby_base_l17_d2_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby method `initialize(cask, command = SystemCommand)` at line 20.
pub fn ruby_base_l20_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d4_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('token', ...args)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d5_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d6_caskroom_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('caskroom_path', ...args)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d7_staged_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('staged_path', ...args)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d8_appdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('appdir', ...args)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d9_language(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('language', ...args)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d10_arch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arch', ...args)
}

// Ruby method `system_command(executable, **options)` at line 28.
pub fn ruby_base_l28_d11_system_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('system_command', ...args)
}

// Ruby method `method_missing(method, *_args)` at line 33.
pub fn ruby_base_l33_d12_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby method `respond_to_missing?(_method, _include_private = false)` at line 38.
pub fn ruby_base_l38_d13_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('respond_to_missing?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5:
// 6: module Cask
// 7:   class DSL
// 8:     # Superclass for all stanzas which take a block.
// 9:     class Base
// 10:       extend Forwardable
// 11:       include ::Utils::Path
// 12:
// 13:       sig { returns(Cask) }
// 14:       attr_reader :cask
// 15:
// 16:       sig { returns(T.class_of(SystemCommand)) }
// 17:       attr_reader :command
// 18:
// 19:       sig { params(cask: Cask, command: T.class_of(SystemCommand)).void }
// 20:       def initialize(cask, command = SystemCommand)
// 21:         @cask = cask
// 22:         @command = command
// 23:       end
// 24:
// 25:       def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch
// 26:
// 27:       sig { params(executable: String, options: T.untyped).returns(T.nilable(SystemCommand::Result)) }
// 28:       def system_command(executable, **options)
// 29:         @command.run!(executable, **options)
// 30:       end
// 31:
// 32:       sig { params(method: Symbol, _args: T.untyped).returns(T.noreturn) }
// 33:       def method_missing(method, *_args)
// 34:         raise NoMethodError, "undefined method '#{method}' for Cask '#{@cask}'"
// 35:       end
// 36:
// 37:       sig { params(_method: Symbol, _include_private: T::Boolean).returns(T::Boolean) }
// 38:       def respond_to_missing?(_method, _include_private = false)
// 39:         false
// 40:       end
// 41:     end
// 42:   end
// 43: end
