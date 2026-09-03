module services

import brew_runtime

// Translated from Homebrew/brew `services/formulae.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub fn service_formula_value(formula ServiceFormula) brew_runtime.Value {
	return brew_runtime.structured_value('FormulaWrapper', formula.name, {
		'name':        formula.name
		'has_service': formula.has_service.str()
		'loaded':      formula.loaded.str()
		'owner':       formula.owner
		'file':        formula.file
		'status':      formula.status
		'user':        formula.user
	})
}

fn service_formula_from_value(value brew_runtime.Value) ServiceFormula {
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

pub fn service_formula_status_value(status ServiceFormulaStatus) brew_runtime.Value {
	return brew_runtime.map_value({
		'file':   brew_runtime.string_value(status.file)
		'name':   brew_runtime.string_value(status.name)
		'status': brew_runtime.string_value(status.status)
		'user':   brew_runtime.string_value(status.user)
	})
}

// Ruby method `self.available_services(loaded: nil, skip_root: false)` at line 12.
pub fn ruby_formulae_l12_d1_self_available_services(args ...brew_runtime.Value) brew_runtime.Value {
	formulae := if args.len > 0 {
		args[0].as_array() or { []brew_runtime.Value{} }
	} else {
		[]brew_runtime.Value{}
	}
	loaded := if args.len > 1 && args[1].type_name == 'Bool' {
		?bool(args[1].bool_data)
	} else {
		none
	}
	skip_root := args.len > 2 && (args[2].as_bool() or { false })
	available := available_services(formulae.map(service_formula_from_value(it)), loaded, skip_root)
	return brew_runtime.array_value(available.map(service_formula_value(it)))
}

// Ruby method `self.services_list` at line 28.
pub fn ruby_formulae_l28_d2_self_services_list(args ...brew_runtime.Value) brew_runtime.Value {
	formulae := if args.len > 0 {
		args[0].as_array() or { []brew_runtime.Value{} }
	} else {
		[]brew_runtime.Value{}
	}
	statuses := services_list(formulae.map(service_formula_from_value(it)))
	return brew_runtime.array_value(statuses.map(service_formula_status_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/formula_wrapper"
// 5:
// 6: module Homebrew
// 7:   module Services
// 8:     module Formulae
// 9:       # All available services, with optional filters applied
// 10:       # @private
// 11:       sig { params(loaded: T.nilable(T::Boolean), skip_root: T::Boolean).returns(T::Array[Services::FormulaWrapper]) }
// 12:       def self.available_services(loaded: nil, skip_root: false)
// 13:         require "formula"
// 14:
// 15:         formulae = Formula.installed
// 16:                           .map { |formula| FormulaWrapper.new(formula) }
// 17:                           .select(&:service?)
// 18:                           .sort_by(&:name)
// 19:
// 20:         formulae = formulae.select { |formula| formula.loaded? == loaded } unless loaded.nil?
// 21:         formulae = formulae.reject { |formula| formula.owner == "root" } if skip_root
// 22:
// 23:         formulae
// 24:       end
// 25:
// 26:       # List all available services with status, user, and path to the file.
// 27:       sig { returns(T::Array[T::Hash[Symbol, T.anything]]) }
// 28:       def self.services_list
// 29:         available_services.map(&:to_hash)
// 30:       end
// 31:     end
// 32:   end
// 33: end
