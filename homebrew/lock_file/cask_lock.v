module lock_file

import ruby

// Translated from Homebrew/brew `lock_file/cask_lock.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(cask_token)` at line 7.
pub fn ruby_cask_lock_l7_d1_initialize(args ...ruby.Value) ruby.Value {
	token := if args.len > 0 { args[0].as_string() } else { '' }
	prefix := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby.environment_value('HOMEBREW_PREFIX')
	}
	target := new_cask_lock_target(token, prefix)
	return lock_target_value(target)
}

pub struct LockTarget {
pub:
	kind string
	path string
}

pub fn new_cask_lock_target(cask_token string, homebrew_prefix string) LockTarget {
	return LockTarget{
		kind: 'cask'
		path: ruby.join_path(homebrew_prefix, 'Caskroom/${cask_token}')
	}
}

fn lock_target_value(target LockTarget) ruby.Value {
	return ruby.structured_value('CaskLock', target.path, {
		'kind': target.kind
		'path': target.path
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A lock file for a cask.
// 5: class CaskLock < LockFile
// 6:   sig { params(cask_token: String).void }
// 7:   def initialize(cask_token)
// 8:     super(:cask, HOMEBREW_PREFIX/"Caskroom/#{cask_token}")
// 9:   end
// 10: end
