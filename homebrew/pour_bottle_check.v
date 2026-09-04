module homebrew

import ruby

pub struct PourBottleFormula {
pub:
	name string
pub mut:
	unsatisfied_reason  string
	pour_bottle_defined bool
	pour_bottle_allowed bool
}

pub struct PourBottleCheck {
pub mut:
	formula PourBottleFormula
}

// Translated from Homebrew/brew `pour_bottle_check.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(formula)` at line 8.
pub fn ruby_pour_bottle_check_l8_d1_initialize(args ...ruby.Value) ruby.Value {
	formula := PourBottleFormula{
		name: if args.len > 0 { args[0].as_string() } else { '' }
	}
	return pour_bottle_check_value(new_pour_bottle_check(formula))
}

// Ruby method `reason(reason)` at line 13.
pub fn ruby_pour_bottle_check_l13_d2_reason(args ...ruby.Value) ruby.Value {
	mut check := new_pour_bottle_check(PourBottleFormula{
		name: if args.len > 0 { args[0].as_string() } else { '' }
	})
	check.reason(if args.len > 1 { args[1].as_string() } else { '' })
	return pour_bottle_check_value(check)
}

// Ruby method `satisfy(&block)` at line 18.
pub fn ruby_pour_bottle_check_l18_d3_satisfy(args ...ruby.Value) ruby.Value {
	mut check := new_pour_bottle_check(PourBottleFormula{
		name: if args.len > 0 { args[0].as_string() } else { '' }
	})
	check.satisfy(args.len > 1 && args[1].bool_data)
	return pour_bottle_check_value(check)
}

// Ruby define_method `@formula.send(:define_method, :pour_bottle?, &block)` at line 19.
pub fn ruby_pour_bottle_check_l19_d4_pour_bottle(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && args[0].bool_data)
}

pub fn new_pour_bottle_check(formula PourBottleFormula) PourBottleCheck {
	return PourBottleCheck{ formula: formula }
}

pub fn (mut check PourBottleCheck) reason(reason string) {
	check.formula.unsatisfied_reason = reason
}

pub fn (mut check PourBottleCheck) satisfy(allowed bool) {
	check.formula.pour_bottle_defined = true
	check.formula.pour_bottle_allowed = allowed
}

fn pour_bottle_check_value(check PourBottleCheck) ruby.Value {
	return ruby.structured_value('PourBottleCheck', check.formula.name, {
		'formula':                              check.formula.name
		'pour_bottle_check_unsatisfied_reason': check.formula.unsatisfied_reason
		'pour_bottle_defined':                  check.formula.pour_bottle_defined.str()
		'pour_bottle':                          check.formula.pour_bottle_allowed.str()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class PourBottleCheck
// 5:   include OnSystem::MacOSAndLinux
// 6:
// 7:   sig { params(formula: T.class_of(Formula)).void }
// 8:   def initialize(formula)
// 9:     @formula = formula
// 10:   end
// 11:
// 12:   sig { params(reason: String).void }
// 13:   def reason(reason)
// 14:     @formula.pour_bottle_check_unsatisfied_reason = reason
// 15:   end
// 16:
// 17:   sig { params(block: T.proc.bind(::Formula).returns(T::Boolean)).void }
// 18:   def satisfy(&block)
// 19:     @formula.send(:define_method, :pour_bottle?, &block)
// 20:   end
// 21: end
