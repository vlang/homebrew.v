module helper

import brew_runtime
import os

fn collect_test_paths(path string, mut paths []string) {
	paths << path
	if !os.is_dir(path) {
		return
	}
	mut entries := os.ls(path) or { return }
	entries.sort()
	for entry in entries {
		collect_test_paths(os.join_path(path, entry), mut paths)
	}
}

pub fn find_test_files(test_tmpdir string, test_directories []string) []string {
	if !os.exists(test_tmpdir) {
		return []
	}
	mut paths := []string{}
	collect_test_paths(test_tmpdir, mut paths)
	return paths.filter(os.base(it) != '.DS_Store' && it !in test_directories).map(if it.starts_with(test_tmpdir) {
		it[test_tmpdir.len..]
	} else {
		it
	})
}

// Translated from Homebrew/brew `test/support/helper/files.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.find_files` at line 7.
pub fn ruby_files_l7_d1_self_find_files(args ...brew_runtime.Value) brew_runtime.Value {
	test_tmpdir := if args.len > 0 {
		args[0].as_string()
	} else {
		brew_runtime.environment_value('TEST_TMPDIR')
	}
	test_directories := if args.len > 1 { args[1].string_array_data } else { []string{} }
	return brew_runtime.string_array_value(find_test_files(test_tmpdir, test_directories))
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
