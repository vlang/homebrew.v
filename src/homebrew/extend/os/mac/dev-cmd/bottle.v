module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/dev-cmd/bottle.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `tar_args` at line 9.
pub fn ruby_bottle_l9_d1_tar_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tar_args', ...args)
}

// Ruby method `gnu_tar(gnu_tar_formula)` at line 14.
pub fn ruby_bottle_l14_d2_gnu_tar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gnu_tar', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module DevCmd
// 7:       module Bottle
// 8:         sig { returns(T::Array[String]) }
// 9:         def tar_args
// 10:           ["--no-mac-metadata", "--no-acls", "--no-xattrs"].freeze
// 11:         end
// 12:
// 13:         sig { params(gnu_tar_formula: Formula).returns(String) }
// 14:         def gnu_tar(gnu_tar_formula)
// 15:           "#{gnu_tar_formula.opt_bin}/gtar"
// 16:         end
// 17:       end
// 18:     end
// 19:   end
// 20: end
// 21:
// 22: Homebrew::DevCmd::Bottle.prepend(OS::Mac::DevCmd::Bottle)
