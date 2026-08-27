module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/appimage.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `resolve_target(target, base_dir: nil)` at line 11.
pub fn ruby_appimage_l11_d1_resolve_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolve_target', ...args)
}

// Ruby method `link(force: false, adopt: false, command: SystemCommand, **_options)` at line 23.
pub fn ruby_appimage_l23_d2_link(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('link', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/symlinked"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `app_image` stanza.
// 9:     class AppImage < Symlinked
// 10:       sig { override.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 11:       def resolve_target(target, base_dir: nil)
// 12:         Pathname.new("#{config.appimagedir}/#{target}")
// 13:       end
// 14:
// 15:       sig {
// 16:         override.params(
// 17:           force:    T::Boolean,
// 18:           adopt:    T::Boolean,
// 19:           command:  T.class_of(SystemCommand),
// 20:           _options: T.anything,
// 21:         ).void
// 22:       }
// 23:       def link(force: false, adopt: false, command: SystemCommand, **_options)
// 24:         super
// 25:         return if source.executable?
// 26:
// 27:         if source.writable?
// 28:           FileUtils.chmod "+x", source
// 29:         else
// 30:           command.run!("chmod", args: ["+x", source], sudo: true)
// 31:         end
// 32:       end
// 33:     end
// 34:   end
// 35: end
