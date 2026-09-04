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
