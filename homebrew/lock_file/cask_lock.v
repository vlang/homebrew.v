module lock_file

import ruby

// Translated from Homebrew/brew `lock_file/cask_lock.rb`.

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
