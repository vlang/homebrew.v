module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/mdimporter.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.english_name` at line 11.
pub fn ruby_mdimporter_l11_d1_self_english_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.english_name', ...args)
}

// Ruby method `install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,` at line 27.
pub fn ruby_mdimporter_l27_d2_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `reload_spotlight(command:, **_options)` at line 36.
pub fn ruby_mdimporter_l36_d3_reload_spotlight(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reload_spotlight', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/moved"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `mdimporter` stanza.
// 9:     class Mdimporter < Moved
// 10:       sig { override.returns(String) }
// 11:       def self.english_name
// 12:         "Spotlight metadata importer"
// 13:       end
// 14:
// 15:       sig {
// 16:         override.params(
// 17:           adopt:        T::Boolean,
// 18:           auto_updates: T.nilable(T::Boolean),
// 19:           force:        T::Boolean,
// 20:           verbose:      T::Boolean,
// 21:           predecessor:  T.nilable(Cask),
// 22:           reinstall:    T::Boolean,
// 23:           command:      T.class_of(SystemCommand),
// 24:           options:      T.anything,
// 25:         ).void
// 26:       }
// 27:       def install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,
// 28:                         reinstall: false, command: SystemCommand, **options)
// 29:         super
// 30:         reload_spotlight(command:, **options)
// 31:       end
// 32:
// 33:       private
// 34:
// 35:       sig { params(command: T.class_of(SystemCommand), _options: T.anything).void }
// 36:       def reload_spotlight(command:, **_options)
// 37:         command.run!("/usr/bin/mdimport", args: ["-r", target])
// 38:       end
// 39:     end
// 40:   end
// 41: end
