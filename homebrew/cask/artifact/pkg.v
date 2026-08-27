module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/pkg.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :path` at line 13.
pub fn ruby_pkg_l13_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby attr_reader `attr_reader :stanza_options` at line 16.
pub fn ruby_pkg_l16_d2_stanza_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stanza_options', ...args)
}

// Ruby method `self.from_args(cask, path, **stanza_options)` at line 19.
pub fn ruby_pkg_l19_d3_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_args', ...args)
}

// Ruby method `initialize(cask, path, **stanza_options)` at line 26.
pub fn ruby_pkg_l26_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `summarize` at line 33.
pub fn ruby_pkg_l33_d5_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('summarize', ...args)
}

// Ruby method `install_phase(command: SystemCommand, verbose: false, **_options)` at line 44.
pub fn ruby_pkg_l44_d6_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `run_installer(command: SystemCommand, verbose: false)` at line 51.
pub fn ruby_pkg_l51_d7_run_installer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run_installer', ...args)
}

// Ruby method `with_choices_file(&_blk)` at line 96.
pub fn ruby_pkg_l96_d8_with_choices_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with_choices_file', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/user"
// 5: require "cask/artifact/abstract_artifact"
// 6: require "extend/hash/keys"
// 7:
// 8: module Cask
// 9:   module Artifact
// 10:     # Artifact corresponding to the `pkg` stanza.
// 11:     class Pkg < AbstractArtifact
// 12:       sig { returns(Pathname) }
// 13:       attr_reader :path
// 14:
// 15:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 16:       attr_reader :stanza_options
// 17:
// 18:       sig { params(cask: Cask, path: T.any(String, Pathname), stanza_options: T.untyped).returns(T.attached_class) }
// 19:       def self.from_args(cask, path, **stanza_options)
// 20:         # odeprecated: `allow_untrusted` disables certificate verification and is being removed.
// 21:         stanza_options.assert_valid_keys(:allow_untrusted, :choices)
// 22:         new(cask, path, **stanza_options)
// 23:       end
// 24:
// 25:       sig { params(cask: Cask, path: T.any(String, Pathname), stanza_options: T.untyped).void }
// 26:       def initialize(cask, path, **stanza_options)
// 27:         super
// 28:         @path = T.let(cask.staged_path.join(path), Pathname)
// 29:         @stanza_options = stanza_options
// 30:       end
// 31:
// 32:       sig { override.returns(String) }
// 33:       def summarize
// 34:         path.relative_path_from(cask.staged_path).to_s
// 35:       end
// 36:
// 37:       sig {
// 38:         params(
// 39:           command:  T.class_of(SystemCommand),
// 40:           verbose:  T::Boolean,
// 41:           _options: T.anything,
// 42:         ).void
// 43:       }
// 44:       def install_phase(command: SystemCommand, verbose: false, **_options)
// 45:         run_installer(command:, verbose:)
// 46:       end
// 47:
// 48:       private
// 49:
// 50:       sig { params(command: T.class_of(SystemCommand), verbose: T::Boolean).void }
// 51:       def run_installer(command: SystemCommand, verbose: false)
// 52:         ohai "Running installer for #{cask} with `sudo` (which may request your password)..."
// 53:         unless path.exist?
// 54:           pkg = path.relative_path_from(cask.staged_path)
// 55:           pkgs = Pathname.glob(cask.staged_path/"**"/"*.pkg").map { |path| path.relative_path_from(cask.staged_path) }
// 56:
// 57:           message = "Could not find PKG source file '#{pkg}'"
// 58:           message += ", found #{pkgs.map { |path| "'#{path}'" }.to_sentence} instead" if pkgs.any?
// 59:           message += "."
// 60:
// 61:           raise CaskError, message
// 62:         end
// 63:
// 64:         args = [
// 65:           "-pkg",    path,
// 66:           "-target", "/"
// 67:         ]
// 68:         args << "-verboseR" if verbose
// 69:         # odeprecated: `allow_untrusted` disables certificate verification and is being removed.
// 70:         args << "-allowUntrusted" if stanza_options.fetch(:allow_untrusted, false)
// 71:         with_choices_file do |choices_path|
// 72:           args << "-applyChoiceChangesXML" << choices_path if choices_path
// 73:
// 74:           current_user_str = User.current&.to_s
// 75:           env = {
// 76:             "LOGNAME"  => current_user_str,
// 77:             "USER"     => current_user_str,
// 78:             "USERNAME" => current_user_str,
// 79:           }
// 80:
// 81:           command.run!(
// 82:             "/usr/sbin/installer",
// 83:             sudo:         true,
// 84:             sudo_as_root: true,
// 85:             args:,
// 86:             print_stdout: true,
// 87:             env:,
// 88:           )
// 89:         end
// 90:       end
// 91:
// 92:       sig {
// 93:         params(_blk: T.proc.params(choices_path: T.nilable(String)).void)
// 94:           .void
// 95:       }
// 96:       def with_choices_file(&_blk)
// 97:         choices = stanza_options.fetch(:choices, {})
// 98:         return yield nil if choices.empty?
// 99:
// 100:         require "plist"
// 101:         Tempfile.open(["choices", ".xml"]) do |file|
// 102:           file.write Plist::Emit.dump(choices)
// 103:           file.close
// 104:           yield file.path
// 105:         ensure
// 106:           file.unlink
// 107:         end
// 108:       end
// 109:     end
// 110:   end
// 111: end
