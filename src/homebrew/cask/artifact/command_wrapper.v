module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/command_wrapper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.dirmethod = :binarydir` at line 16.
pub fn ruby_command_wrapper_l16_d1_self_dirmethod(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dirmethod', ...args)
}

// Ruby method `self.from_args(cask, name, options = nil)` at line 25.
pub fn ruby_command_wrapper_l25_d2_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_args', ...args)
}

// Ruby method `initialize(cask, name, content: nil, executable: nil, args: [], env: {})` at line 42.
pub fn ruby_command_wrapper_l42_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `install_phase(force: false, adopt: false, command: SystemCommand, **options)` at line 72.
pub fn ruby_command_wrapper_l72_d4_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `to_args` at line 84.
pub fn ruby_command_wrapper_l84_d5_to_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_args', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/binary"
// 5: require "extend/pathname"
// 6: require "shellwords"
// 7:
// 8: module Cask
// 9:   module Artifact
// 10:     # Artifact corresponding to the `command_wrapper` stanza.
// 11:     class CommandWrapper < Binary
// 12:       Arguments = T.type_alias { T.any(String, Pathname, T::Array[T.any(String, Pathname)]) }
// 13:       Environment = T.type_alias { T::Hash[T.any(String, Symbol), T.any(String, Pathname)] }
// 14:
// 15:       sig { override.returns(Symbol) }
// 16:       def self.dirmethod = :binarydir
// 17:
// 18:       sig {
// 19:         override.params(
// 20:           cask:    Cask,
// 21:           name:    T.any(String, Pathname),
// 22:           options: T.untyped,
// 23:         ).returns(T.attached_class)
// 24:       }
// 25:       def self.from_args(cask, name, options = nil)
// 26:         options ||= {}
// 27:         options.assert_valid_keys(:content, :executable, :args, :env)
// 28:
// 29:         new(cask, name, **options)
// 30:       end
// 31:
// 32:       sig {
// 33:         params(
// 34:           cask:       Cask,
// 35:           name:       T.any(String, Pathname),
// 36:           content:    T.nilable(String),
// 37:           executable: T.nilable(T.any(String, Pathname)),
// 38:           args:       Arguments,
// 39:           env:        Environment,
// 40:         ).void
// 41:       }
// 42:       def initialize(cask, name, content: nil, executable: nil, args: [], env: {})
// 43:         name = Pathname(name)
// 44:         if name.basename != name || [".", ".."].include?(name.to_s)
// 45:           raise CaskInvalidError.new(cask, "'command_wrapper' requires a command name without path components")
// 46:         end
// 47:         if content.blank? && executable.to_s.blank?
// 48:           raise CaskInvalidError.new(cask, "'command_wrapper' requires content or executable")
// 49:         end
// 50:         if content.present? && executable.to_s.present?
// 51:           raise CaskInvalidError.new(cask, "'command_wrapper' requires content or executable, not both")
// 52:         end
// 53:         if content.present? && (args.present? || env.present?)
// 54:           raise CaskInvalidError.new(cask, "'command_wrapper' args and env require executable")
// 55:         end
// 56:
// 57:         super(cask, ".homebrew-command-wrappers/#{name}", target: name)
// 58:         @content = T.let(content.presence, T.nilable(String))
// 59:         @executable = T.let(executable&.to_s.presence, T.nilable(String))
// 60:         @args = T.let(Array(args).map(&:to_s), T::Array[String])
// 61:         @env = T.let(env.to_h { |key, value| [key.to_s, value.to_s] }, T::Hash[String, String])
// 62:       end
// 63:
// 64:       sig {
// 65:         override.params(
// 66:           force:   T::Boolean,
// 67:           adopt:   T::Boolean,
// 68:           command: T.class_of(SystemCommand),
// 69:           options: T.anything,
// 70:         ).void
// 71:       }
// 72:       def install_phase(force: false, adopt: false, command: SystemCommand, **options)
// 73:         if (content = @content)
// 74:           source.dirname.mkpath
// 75:           source.write(content)
// 76:         elsif (executable = @executable)
// 77:           args = @args.map { |arg| Shellwords.shellescape(arg) }
// 78:           source.write_env_script(executable, args, @env)
// 79:         end
// 80:         super
// 81:       end
// 82:
// 83:       sig { override.returns(T::Array[T.anything]) }
// 84:       def to_args
// 85:         options = {}
// 86:         if (content = @content)
// 87:           options[:content] = content
// 88:         else
// 89:           options[:executable] = @executable
// 90:           options[:args] = @args if @args.present?
// 91:           options[:env] = @env if @env.present?
// 92:         end
// 93:         [@target_string, options]
// 94:       end
// 95:     end
// 96:   end
// 97: end
