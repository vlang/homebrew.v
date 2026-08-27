module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/keyboard_layout.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,` at line 22.
pub fn ruby_keyboard_layout_l22_d1_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `uninstall_phase(skip: false, force: false, adopt: false, verbose: false, successor: nil, upgrade: false,` at line 40.
pub fn ruby_keyboard_layout_l40_d2_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
}

// Ruby method `delete_keyboard_layout_cache(command: SystemCommand)` at line 49.
pub fn ruby_keyboard_layout_l49_d3_delete_keyboard_layout_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete_keyboard_layout_cache', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/moved"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `keyboard_layout` stanza.
// 9:     class KeyboardLayout < Moved
// 10:       sig {
// 11:         override.params(
// 12:           adopt:        T::Boolean,
// 13:           auto_updates: T.nilable(T::Boolean),
// 14:           force:        T::Boolean,
// 15:           verbose:      T::Boolean,
// 16:           predecessor:  T.nilable(Cask),
// 17:           successor:    T.nilable(Cask),
// 18:           reinstall:    T::Boolean,
// 19:           command:      T.class_of(SystemCommand),
// 20:         ).void
// 21:       }
// 22:       def install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,
// 23:                         successor: nil, reinstall: false, command: SystemCommand)
// 24:         super
// 25:         delete_keyboard_layout_cache(command:)
// 26:       end
// 27:
// 28:       sig {
// 29:         override.params(
// 30:           skip:      T::Boolean,
// 31:           force:     T::Boolean,
// 32:           adopt:     T::Boolean,
// 33:           verbose:   T::Boolean,
// 34:           successor: T.nilable(Cask),
// 35:           upgrade:   T::Boolean,
// 36:           reinstall: T::Boolean,
// 37:           command:   T.class_of(SystemCommand),
// 38:         ).void
// 39:       }
// 40:       def uninstall_phase(skip: false, force: false, adopt: false, verbose: false, successor: nil, upgrade: false,
// 41:                           reinstall: false, command: SystemCommand)
// 42:         super
// 43:         delete_keyboard_layout_cache(command:)
// 44:       end
// 45:
// 46:       private
// 47:
// 48:       sig { params(command: T.class_of(SystemCommand)).void }
// 49:       def delete_keyboard_layout_cache(command: SystemCommand)
// 50:         command.run!(
// 51:           "/bin/rm",
// 52:           args:         ["-f", "--", "/System/Library/Caches/com.apple.IntlDataCache.le*"],
// 53:           sudo:         true,
// 54:           sudo_as_root: true,
// 55:         )
// 56:       end
// 57:     end
// 58:   end
// 59: end
