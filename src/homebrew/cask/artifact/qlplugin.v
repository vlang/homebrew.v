module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/qlplugin.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.english_name` at line 11.
pub fn ruby_qlplugin_l11_d1_self_english_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.english_name', ...args)
}

// Ruby method `install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,` at line 28.
pub fn ruby_qlplugin_l28_d2_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `uninstall_phase(skip: false, force: false, adopt: false, verbose: false, successor: nil, upgrade: false,` at line 47.
pub fn ruby_qlplugin_l47_d3_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
}

// Ruby method `reload_quicklook(command: SystemCommand)` at line 56.
pub fn ruby_qlplugin_l56_d4_reload_quicklook(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reload_quicklook', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/moved"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `qlplugin` stanza.
// 9:     class Qlplugin < Moved
// 10:       sig { override.returns(String) }
// 11:       def self.english_name
// 12:         "Quick Look Plugin"
// 13:       end
// 14:
// 15:       sig {
// 16:         override.params(
// 17:           adopt:        T::Boolean,
// 18:           auto_updates: T.nilable(T::Boolean),
// 19:           force:        T::Boolean,
// 20:           verbose:      T::Boolean,
// 21:           predecessor:  T.nilable(Cask),
// 22:           successor:    T.nilable(Cask),
// 23:           reinstall:    T::Boolean,
// 24:           command:      T.class_of(SystemCommand),
// 25:           options:      T.anything,
// 26:         ).void
// 27:       }
// 28:       def install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,
// 29:                         successor: nil, reinstall: false, command: SystemCommand, **options)
// 30:         super
// 31:         reload_quicklook(command:)
// 32:       end
// 33:
// 34:       sig {
// 35:         override.params(
// 36:           skip:      T::Boolean,
// 37:           force:     T::Boolean,
// 38:           adopt:     T::Boolean,
// 39:           verbose:   T::Boolean,
// 40:           successor: T.nilable(Cask),
// 41:           upgrade:   T::Boolean,
// 42:           reinstall: T::Boolean,
// 43:           command:   T.class_of(SystemCommand),
// 44:           options:   T.anything,
// 45:         ).void
// 46:       }
// 47:       def uninstall_phase(skip: false, force: false, adopt: false, verbose: false, successor: nil, upgrade: false,
// 48:                           reinstall: false, command: SystemCommand, **options)
// 49:         super
// 50:         reload_quicklook(command:)
// 51:       end
// 52:
// 53:       private
// 54:
// 55:       sig { params(command: T.class_of(SystemCommand)).void }
// 56:       def reload_quicklook(command: SystemCommand)
// 57:         command.run!("/usr/bin/qlmanage", args: ["-r"])
// 58:       end
// 59:     end
// 60:   end
// 61: end
