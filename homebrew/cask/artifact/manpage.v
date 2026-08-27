module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/manpage.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :section` at line 11.
pub fn ruby_manpage_l11_d1_section(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('section', ...args)
}

// Ruby method `self.from_args(cask, source, _target_hash = nil)` at line 20.
pub fn ruby_manpage_l20_d2_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_args', ...args)
}

// Ruby method `initialize(cask, source, section)` at line 29.
pub fn ruby_manpage_l29_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `resolve_target(target, base_dir: nil)` at line 36.
pub fn ruby_manpage_l36_d4_resolve_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolve_target', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/symlinked"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `manpage` stanza.
// 9:     class Manpage < Symlinked
// 10:       sig { returns(String) }
// 11:       attr_reader :section
// 12:
// 13:       sig {
// 14:         override.params(
// 15:           cask:         Cask,
// 16:           source:       T.any(String, Pathname),
// 17:           _target_hash: T.anything,
// 18:         ).returns(T.attached_class)
// 19:       }
// 20:       def self.from_args(cask, source, _target_hash = nil)
// 21:         section = source.to_s[/\.([1-8]|n|l)(?:\.gz)?$/, 1]
// 22:
// 23:         raise CaskInvalidError, "'#{source}' is not a valid man page name" unless section
// 24:
// 25:         new(cask, source, section)
// 26:       end
// 27:
// 28:       sig { params(cask: Cask, source: T.any(String, Pathname), section: String).void }
// 29:       def initialize(cask, source, section)
// 30:         @section = section
// 31:
// 32:         super(cask, source)
// 33:       end
// 34:
// 35:       sig { override.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 36:       def resolve_target(target, base_dir: nil)
// 37:         config.manpagedir.join("man#{section}", target)
// 38:       end
// 39:     end
// 40:   end
// 41: end
