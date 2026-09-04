module services

import ruby

// Translated from Homebrew/brew `services/formulae.rb`.

// ServiceFormula is the portion of FormulaWrapper used while discovering and
// rendering services. Keeping it independent of the operating-system service
// manager makes this source boundary deterministic and testable.
pub struct ServiceFormula {
pub:
	name        string
	has_service bool
	loaded      bool
	owner       string
	file        string
	status      string
	user        string
}

pub struct ServiceFormulaStatus {
pub:
	file   string
	name   string
	status string
	user   string
}

pub fn available_services(formulae []ServiceFormula, loaded ?bool, skip_root bool) []ServiceFormula {
	mut available := formulae.filter(it.has_service)
	available.sort_with_compare(fn (left &ServiceFormula, right &ServiceFormula) int {
		return left.name.compare(right.name)
	})
	if loaded_value := loaded {
		available = available.filter(it.loaded == loaded_value)
	}
	if skip_root {
		available = available.filter(it.owner != 'root')
	}
	return available
}

pub fn services_list(formulae []ServiceFormula) []ServiceFormulaStatus {
	return formulae.map(ServiceFormulaStatus{
		file: it.file
		name: it.name
		status: it.status
		user: it.user
	})
}

pub fn service_formula_value(formula ServiceFormula) ruby.Value {
	return ruby.structured_value('FormulaWrapper', formula.name, {
		'name':        formula.name
		'has_service': formula.has_service.str()
		'loaded':      formula.loaded.str()
		'owner':       formula.owner
		'file':        formula.file
		'status':      formula.status
		'user':        formula.user
	})
}

fn service_formula_from_value(value ruby.Value) ServiceFormula {
	return ServiceFormula{
		name: value.attribute('name') or { value.as_string() }
		has_service: (value.attribute('has_service') or { 'true' }) == 'true'
		loaded: (value.attribute('loaded') or { 'false' }) == 'true'
		owner: value.attribute('owner') or { '' }
		file: value.attribute('file') or { '' }
		status: value.attribute('status') or { 'unknown' }
		user: value.attribute('user') or { '' }
	}
}

pub fn service_formula_status_value(status ServiceFormulaStatus) ruby.Value {
	return ruby.map_value({
		'file':   ruby.string_value(status.file)
		'name':   ruby.string_value(status.name)
		'status': ruby.string_value(status.status)
		'user':   ruby.string_value(status.user)
	})
}
