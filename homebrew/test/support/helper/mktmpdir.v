module helper

import brew_runtime
import os
import time

pub type MkTmpDirAction = fn(string) !brew_runtime.Value

pub fn make_test_tmpdir(prefix string, suffix string, parent string) !string {
	os.mkdir_all(parent)!
	for attempt in 0 .. 100 {
		candidate := os.join_path(parent, '${prefix}${os.getpid()}-${time.now().unix_nano()}-${attempt}${suffix}')
		if !os.exists(candidate) {
			os.mkdir(candidate)!
			return candidate
		}
	}
	return error('unable to create a temporary directory in ${parent}')
}

pub fn with_test_tmpdir(prefix string, suffix string, parent string,
	action ?MkTmpDirAction) !brew_runtime.Value {
	path := make_test_tmpdir(prefix, suffix, parent)!
	if callback := action {
		return callback(path)
	}
	return brew_runtime.string_value(path)
}

// Translated from Homebrew/brew `test/support/helper/mktmpdir.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `mktmpdir(prefix_suffix = nil, &block)` at line 13.
pub fn ruby_mktmpdir_l13_d1_mktmpdir(prefix_suffix []string, parent string,
	action ?MkTmpDirAction) !brew_runtime.Value {
	prefix := if prefix_suffix.len > 0 { prefix_suffix[0] } else { 'd' }
	suffix := if prefix_suffix.len > 1 { prefix_suffix[1] } else { '' }
	return with_test_tmpdir(prefix, suffix, parent, action)
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
