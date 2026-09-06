module homebrew

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
