module artifact

import brew_runtime
import homebrew.cask

// Translated from Homebrew/brew `extend/os/mac/cask/artifact/abstract_uninstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `undeletable?(target)` at line 16.
pub fn ruby_abstract_uninstall_l16_d1_undeletable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('undeletable? requires a target')
	}
	return brew_runtime.bool_value(cask.macos_undeletable(args[0].as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/macos"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Cask
// 9:       module Artifact
// 10:         module AbstractUninstall
// 11:           extend T::Helpers
// 12:
// 13:           requires_ancestor { ::Cask::Artifact::AbstractUninstall }
// 14:
// 15:           sig { params(target: ::Pathname).returns(T::Boolean) }
// 16:           def undeletable?(target)
// 17:             MacOS.undeletable?(target)
// 18:           end
// 19:         end
// 20:       end
// 21:     end
// 22:   end
// 23: end
// 24:
// 25: Cask::Artifact::AbstractUninstall.prepend(OS::Mac::Cask::Artifact::AbstractUninstall)
