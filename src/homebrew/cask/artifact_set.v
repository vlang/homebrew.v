module cask

import brew_runtime

// Translated from Homebrew/brew `cask/artifact_set.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `each(&block)` at line 12.
pub fn ruby_artifact_set_l12_d1_each(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each', ...args)
}

// Ruby method `to_a` at line 20.
pub fn ruby_artifact_set_l20_d2_to_a(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_a', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Cask
// 5:   # Sorted set containing all cask artifacts.
// 6:   class ArtifactSet < ::Set
// 7:     extend T::Generic
// 8:
// 9:     Elem = type_member(:out) { { fixed: Artifact::AbstractArtifact } }
// 10:
// 11:     sig { params(block: T.nilable(T.proc.params(arg0: Elem).returns(T.untyped))).void }
// 12:     def each(&block)
// 13:       return enum_for(T.must(__method__)) { size } unless block
// 14:
// 15:       to_a.each(&block)
// 16:       self
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Artifact::AbstractArtifact]) }
// 20:     def to_a
// 21:       super.sort
// 22:     end
// 23:   end
// 24: end
