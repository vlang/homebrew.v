module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/shellcompletion.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `resolve_target(_, base_dir: nil)` at line 11.
pub fn ruby_shellcompletion_l11_d1_resolve_target(args ...brew_runtime.Value) brew_runtime.Value {
	panic(shell_completion_error().msg())
}

pub fn shell_completion_error() IError {
	return error('Shell completion without shell info')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/symlinked"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Superclass for all artifacts that are installed as shell completions.
// 9:     class ShellCompletion < Symlinked
// 10:       sig { override.overridable.params(_: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 11:       def resolve_target(_, base_dir: nil)
// 12:         raise CaskInvalidError, "Shell completion without shell info"
// 13:       end
// 14:     end
// 15:   end
// 16: end
