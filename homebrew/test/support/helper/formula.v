module helper

import brew_runtime

pub struct HelperFormula {
pub:
	name       string
	path       string
	spec       string = 'stable'
	alias_path string
	tap        string
}

pub struct StubFormulaLoader {
pub:
	formula       HelperFormula
	ref           string
	call_original bool
}

// Translated from Homebrew/brew `test/support/helper/formula.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `formula(name = "formula_name", path: nil, spec: :stable, alias_path: nil, tap: nil, &block)` at line 19.
pub fn ruby_formula_l19_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	formula := helper_formula(
		if args.len > 0 { args[0].as_string() } else { 'formula_name' },
		if args.len > 1 { args[1].as_string() } else { '' },
		if args.len > 2 { args[2].as_string() } else { 'stable' },
		if args.len > 3 { args[3].as_string() } else { '' },
		if args.len > 4 { args[4].as_string() } else { '' },
	)
	return helper_formula_value(formula)
}

// Ruby method `stub_formula_loader(formula, ref = formula.full_name, call_original: false)` at line 27.
pub fn ruby_formula_l27_d2_stub_formula_loader(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'stub_formula_loader requires a formula')
	}
	formula := helper_formula_from_value(args[0])
	loader := stub_formula_loader(formula, if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].as_string()
	} else {
		formula.name
	}, args.len > 2 && args[2].bool_data)
	return brew_runtime.structured_value('Formulary::FormulaLoader', loader.ref, {
		'name':          loader.formula.name
		'path':          loader.formula.path
		'ref':           loader.ref
		'call_original': loader.call_original.str()
	})
}

pub fn helper_formula(name string, path string, spec string, alias_path string, tap string) HelperFormula {
	return HelperFormula{
		name: name
		path: path
		spec: if spec == '' { 'stable' } else { spec }
		alias_path: alias_path
		tap: tap
	}
}

pub fn stub_formula_loader(formula HelperFormula, ref string, call_original bool) StubFormulaLoader {
	return StubFormulaLoader{
		formula: formula
		ref: if ref == '' { formula.name } else { ref }
		call_original: call_original
	}
}

fn helper_formula_value(formula HelperFormula) brew_runtime.Value {
	return brew_runtime.structured_value('Formula', formula.name, {
		'name':       formula.name
		'path':       formula.path
		'spec':       formula.spec
		'alias_path': formula.alias_path
		'tap':        formula.tap
	})
}

fn helper_formula_from_value(value brew_runtime.Value) HelperFormula {
	return helper_formula(value.attributes['name'] or { value.as_string() }, value.attributes['path'] or { '' }, value.attributes['spec'] or { 'stable' }, value.attributes['alias_path'] or { '' }, value.attributes['tap'] or { '' })
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formulary"
// 5:
// 6: module Test
// 7:   module Helper
// 8:     module Formula
// 9:       extend T::Helpers
// 10:
// 11:       requires_ancestor { RSpec::Mocks::ExampleMethods }
// 12:
// 13:       sig {
// 14:         params(
// 15:           name: String, path: T.nilable(Pathname), spec: Symbol, alias_path: T.nilable(Pathname),
// 16:           tap: T.nilable(Tap), block: T.nilable(T.proc.void)
// 17:         ).returns(::Formula)
// 18:       }
// 19:       def formula(name = "formula_name", path: nil, spec: :stable, alias_path: nil, tap: nil, &block)
// 20:         path ||= Formulary.find_formula_in_tap(name, tap || CoreTap.instance)
// 21:         Class.new(::Formula, &block).new(name, path, spec, alias_path:, tap:)
// 22:       end
// 23:
// 24:       # Use a stubbed {Formulary::FormulaLoader} to make a given formula be found
// 25:       # when loading from {Formulary} with `ref`.
// 26:       sig { params(formula: ::Formula, ref: T.nilable(T.any(String, Pathname)), call_original: T::Boolean).void }
// 27:       def stub_formula_loader(formula, ref = formula.full_name, call_original: false)
// 28:         allow(Formulary).to receive(:loader_for).and_call_original if call_original
// 29:
// 30:         loader = instance_double(Formulary::FormulaLoader, get_formula: formula, name: formula.name)
// 31:         allow(Formulary).to receive(:loader_for).with(ref, any_args).and_return(loader)
// 32:       end
// 33:     end
// 34:   end
// 35: end
