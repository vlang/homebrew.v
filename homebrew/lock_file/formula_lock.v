module lock_file

import brew_runtime

// Translated from Homebrew/brew `lock_file/formula_lock.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(rack_name)` at line 7.
pub fn ruby_formula_lock_l7_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	rack_name := if args.len > 0 { args[0].as_string() } else { '' }
	cellar := if args.len > 1 {
		args[1].as_string()
	} else {
		brew_runtime.environment_value('HOMEBREW_CELLAR')
	}
	target := new_formula_lock_target(rack_name, cellar)
	return lock_target_value(target)
}

pub fn new_formula_lock_target(rack_name string, homebrew_cellar string) LockTarget {
	return LockTarget{
		kind: 'formula'
		path: brew_runtime.join_path(homebrew_cellar, rack_name)
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A lock file for a formula.
// 5: class FormulaLock < LockFile
// 6:   sig { params(rack_name: String).void }
// 7:   def initialize(rack_name)
// 8:     super(:formula, HOMEBREW_CELLAR/rack_name)
// 9:   end
// 10: end
