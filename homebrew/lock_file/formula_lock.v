module lock_file

import ruby

// Translated from Homebrew/brew `lock_file/formula_lock.rb`.

pub fn new_formula_lock_target(rack_name string, homebrew_cellar string) LockTarget {
	return LockTarget{
		kind: 'formula'
		path: ruby.join_path(homebrew_cellar, rack_name)
	}
}
