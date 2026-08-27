module helper

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/files.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.find_files` at line 7.
pub fn ruby_files_l7_d1_self_find_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.find_files', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: module Test
// 5:   module Helper
// 6:     module Files
// 7:       def self.find_files
// 8:         return [] unless File.exist?(TEST_TMPDIR)
// 9:
// 10:         Find.find(TEST_TMPDIR)
// 11:             .reject { |f| File.basename(f) == ".DS_Store" }
// 12:             .reject { |f| TEST_DIRECTORIES.include?(Pathname(f)) }
// 13:             .map { |f| f.sub(TEST_TMPDIR, "") }
// 14:       end
// 15:     end
// 16:   end
// 17: end
