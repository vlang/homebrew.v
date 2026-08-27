module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/installer.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `install_phase(command: SystemCommand, **_options)` at line 17.
pub fn ruby_installer_l17_d1_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `self.from_args(cask, **args)` at line 40.
pub fn ruby_installer_l40_d2_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_args', ...args)
}

// Ruby attr_reader `attr_reader :path` at line 65.
pub fn ruby_installer_l65_d3_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby attr_reader `attr_reader :args` at line 68.
pub fn ruby_installer_l68_d4_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby attr_reader `attr_reader :manual_install` at line 71.
pub fn ruby_installer_l71_d5_manual_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('manual_install', ...args)
}

// Ruby method `initialize(cask, **args)` at line 74.
pub fn ruby_installer_l74_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `summarize = path.to_s` at line 94.
pub fn ruby_installer_l94_d7_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('summarize', ...args)
}

// Ruby method `to_h` at line 97.
pub fn ruby_installer_l97_d8_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_artifact"
// 5: require "extend/hash/keys"
// 6:
// 7: module Cask
// 8:   module Artifact
// 9:     # Artifact corresponding to the `installer` stanza.
// 10:     class Installer < AbstractArtifact
// 11:       VALID_KEYS = T.let(Set.new([
// 12:         :manual,
// 13:         :script,
// 14:       ]).freeze, T::Set[Symbol])
// 15:
// 16:       sig { params(command: T.class_of(SystemCommand), _options: T.anything).void }
// 17:       def install_phase(command: SystemCommand, **_options)
// 18:         if manual_install
// 19:           puts <<~EOS
// 20:             Cask #{cask} only provides a manual installer. To run it and complete the installation:
// 21:               open #{cask.staged_path.join(path).to_s.shellescape}
// 22:           EOS
// 23:         else
// 24:           ohai "Running #{self.class.dsl_key} script '#{path}'"
// 25:
// 26:           executable_path = staged_path_join_executable(path)
// 27:
// 28:           command.run!(
// 29:             executable_path,
// 30:             **args,
// 31:             env:       { "PATH" => PATH.new(
// 32:               HOMEBREW_PREFIX/"bin", HOMEBREW_PREFIX/"sbin", ENV.fetch("PATH")
// 33:             ) },
// 34:             reset_uid: !args[:sudo],
// 35:           )
// 36:         end
// 37:       end
// 38:
// 39:       sig { params(cask: Cask, args: T.untyped).returns(T.attached_class) }
// 40:       def self.from_args(cask, **args)
// 41:         raise CaskInvalidError.new(cask, "'installer' stanza requires an argument.") if args.empty?
// 42:
// 43:         if args.key?(:script) && !args[:script].respond_to?(:key?)
// 44:           if args.key?(:executable)
// 45:             raise CaskInvalidError.new(cask, "'installer' stanza gave arguments for both :script and :executable.")
// 46:           end
// 47:
// 48:           args[:executable] = args[:script]
// 49:           args.delete(:script)
// 50:           args = { script: args }
// 51:         end
// 52:
// 53:         if args.keys.count != 1
// 54:           raise CaskInvalidError.new(
// 55:             cask,
// 56:             "invalid 'installer' stanza: Only one of #{VALID_KEYS.inspect} is permitted.",
// 57:           )
// 58:         end
// 59:
// 60:         args.assert_valid_keys(*VALID_KEYS)
// 61:         new(cask, **args)
// 62:       end
// 63:
// 64:       sig { returns(Pathname) }
// 65:       attr_reader :path
// 66:
// 67:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 68:       attr_reader :args
// 69:
// 70:       sig { returns(T::Boolean) }
// 71:       attr_reader :manual_install
// 72:
// 73:       sig { params(cask: Cask, args: T.untyped).void }
// 74:       def initialize(cask, **args)
// 75:         super
// 76:
// 77:         if args.key?(:manual)
// 78:           @path = T.let(Pathname(args[:manual]), Pathname)
// 79:           @args = T.let({}, T::Hash[Symbol, T.untyped])
// 80:           @manual_install = T.let(true, T::Boolean)
// 81:         else
// 82:           script_path, script_args = self.class.read_script_arguments(
// 83:             args[:script], self.class.dsl_key.to_s, { must_succeed: true, sudo: false }, print_stdout: true
// 84:           )
// 85:           raise CaskInvalidError.new(cask, "#{self.class.dsl_key} missing executable") if script_path.nil?
// 86:
// 87:           @path = T.let(Pathname(script_path), Pathname)
// 88:           @args = T.let(script_args, T::Hash[Symbol, T.untyped])
// 89:           @manual_install = T.let(false, T::Boolean)
// 90:         end
// 91:       end
// 92:
// 93:       sig { override.returns(String) }
// 94:       def summarize = path.to_s
// 95:
// 96:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 97:       def to_h
// 98:         { path: }.tap do |h|
// 99:           h[:args] = args unless manual_install
// 100:         end
// 101:       end
// 102:     end
// 103:   end
// 104: end
