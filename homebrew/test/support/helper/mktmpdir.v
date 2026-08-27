module helper

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/mktmpdir.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `mktmpdir(prefix_suffix = nil, &block)` at line 13.
pub fn ruby_mktmpdir_l13_d1_mktmpdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mktmpdir', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Test
// 5:   module Helper
// 6:     module MkTmpDir
// 7:       sig {
// 8:         type_parameters(:U).params(
// 9:           prefix_suffix: T.nilable(T.any(String, T::Array[String])),
// 10:           block:         T.nilable(T.proc.params(path: Pathname).returns(T.type_parameter(:U))),
// 11:         ).returns(T.any(Pathname, T.type_parameter(:U)))
// 12:       }
// 13:       def mktmpdir(prefix_suffix = nil, &block)
// 14:         new_dir = Pathname.new(Dir.mktmpdir(prefix_suffix, HOMEBREW_TEMP))
// 15:         return yield(new_dir) if block
// 16:
// 17:         new_dir
// 18:       end
// 19:     end
// 20:   end
// 21: end
