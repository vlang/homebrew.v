module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/artifact.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.english_name` at line 11.
pub fn ruby_artifact_l11_d1_self_english_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.english_name', ...args)
}

// Ruby method `self.from_args(cask, source, options = nil)` at line 22.
pub fn ruby_artifact_l22_d2_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_args', ...args)
}

// Ruby method `resolve_target(target, base_dir: nil)` at line 33.
pub fn ruby_artifact_l33_d3_resolve_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolve_target', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/moved"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Generic artifact corresponding to the `artifact` stanza.
// 9:     class Artifact < Moved
// 10:       sig { override.returns(String) }
// 11:       def self.english_name
// 12:         "Generic Artifact"
// 13:       end
// 14:
// 15:       sig {
// 16:         override.params(
// 17:           cask:    Cask,
// 18:           source:  T.any(String, Pathname),
// 19:           options: T.untyped, # required due to https://github.com/sorbet/sorbet/issues/10114
// 20:         ).returns(T.attached_class)
// 21:       }
// 22:       def self.from_args(cask, source, options = nil)
// 23:         raise CaskInvalidError.new(cask.token, "No source provided for #{english_name}.") if source.blank?
// 24:
// 25:         unless options&.key?(:target)
// 26:           raise CaskInvalidError.new(cask.token, "#{english_name} '#{source}' requires a target.")
// 27:         end
// 28:
// 29:         new(cask, source, **options)
// 30:       end
// 31:
// 32:       sig { override.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 33:       def resolve_target(target, base_dir: nil)
// 34:         super
// 35:       end
// 36:     end
// 37:   end
// 38: end
