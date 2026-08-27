module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/zshcompletion.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `resolve_target(target, base_dir: nil)` at line 11.
pub fn ruby_zshcompletion_l11_d1_resolve_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolve_target', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/shellcompletion"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `zsh_completion` stanza.
// 9:     class ZshCompletion < ShellCompletion
// 10:       sig { override.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 11:       def resolve_target(target, base_dir: nil)
// 12:         name = if target.to_s.start_with? "_"
// 13:           target
// 14:         else
// 15:           new_name = "_#{File.basename(target, File.extname(target))}"
// 16:           odebug "Renaming completion #{target} to #{new_name}"
// 17:
// 18:           new_name
// 19:         end
// 20:
// 21:         config.zsh_completion/name
// 22:       end
// 23:     end
// 24:   end
// 25: end
