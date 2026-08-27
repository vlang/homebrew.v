module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/app.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `install_phase(` at line 22.
pub fn ruby_app_l22_d1_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/moved"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `app` stanza.
// 9:     class App < Moved
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
// 22:       def install_phase(
// 23:         adopt: false,
// 24:         auto_updates: false,
// 25:         force: false,
// 26:         verbose: false,
// 27:         predecessor: nil,
// 28:         successor: nil,
// 29:         reinstall: false,
// 30:         command: SystemCommand
// 31:       )
// 32:         super
// 33:
// 34:         return if target.ascend.none? { OS::Mac.system_dir?(it) }
// 35:
// 36:         odebug "Fixing up '#{target}' permissions for installation to '#{target.parent}'"
// 37:         # Ensure that globally installed applications can be accessed by all users.
// 38:         # We shell out to `chmod` instead of using `FileUtils.chmod` so that using `+X` works correctly.
// 39:         command.run!("chmod", args: ["-R", "a+rX", target], sudo: !target.writable?)
// 40:       end
// 41:     end
// 42:   end
// 43: end
