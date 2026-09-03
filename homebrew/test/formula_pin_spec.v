module test

import brew_runtime
import homebrew
import os

// Translated from Homebrew/brew `test/formula_pin_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn formula_pin_spec_paths(suffix string) (string, string, string) {
	root := os.join_path(os.temp_dir(), 'brew-v-formula-pin-${os.getpid()}-${suffix}')
	return root, os.join_path(root, 'Cellar', 'double'), os.join_path(root, 'PinnedKegs')
}

fn formula_pin_spec_prepare(suffix string) !(&homebrew.FormulaPin, string) {
	root, rack, pinned := formula_pin_spec_paths(suffix)
	os.rmdir_all(root) or {}
	os.mkdir_all(rack)!
	return homebrew.new_formula_pin('double', rack, pinned), root
}

// Ruby subject `subject(:formula_pin) { described_class.new(formula) }` at line 7.
pub fn ruby_formula_pin_spec_l7_d1_formula_pin(args ...brew_runtime.Value) brew_runtime.Value {
	_, rack, pinned := formula_pin_spec_paths('subject')
	return homebrew.formula_pin_boundary(homebrew.new_formula_pin('double', rack, pinned))
}

// Ruby let `let(:name) { "double" }` at line 9.
pub fn ruby_formula_pin_spec_l9_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('double')
}

// Ruby let `let(:formula) { instance_double(Formula, name:, rack: HOMEBREW_CELLAR/name) }` at line 10.
pub fn ruby_formula_pin_spec_l10_d3_formula(args ...brew_runtime.Value) brew_runtime.Value {
	_, rack, pinned := formula_pin_spec_paths('formula')
	return brew_runtime.structured_value('Formula', 'double', {
		'name':        'double'
		'rack':        rack
		'pinned_kegs': pinned
	})
}

// Ruby it `it "is not pinnable by default" do` at line 24.
pub fn ruby_formula_pin_spec_l24_d4_is(args ...brew_runtime.Value) brew_runtime.Value {
	pin, root := formula_pin_spec_prepare('not-pinnable') or {
		return brew_runtime.bool_value(false)
	}
	result := !pin.pinnable()
	os.rmdir_all(root) or {}
	return brew_runtime.bool_value(result)
}

// Ruby it `it "is pinnable if the Keg exists" do` at line 28.
pub fn ruby_formula_pin_spec_l28_d5_is(args ...brew_runtime.Value) brew_runtime.Value {
	pin, root := formula_pin_spec_prepare('pinnable') or {
		return brew_runtime.bool_value(false)
	}
	os.mkdir_all(os.join_path(pin.rack, '0.1')) or {
		os.rmdir_all(root) or {}
		return brew_runtime.bool_value(false)
	}
	result := pin.pinnable()
	os.rmdir_all(root) or {}
	return brew_runtime.bool_value(result)
}

// Ruby specify `specify "#pin and` at line 33.
pub fn ruby_formula_pin_spec_l33_d6_pin(args ...brew_runtime.Value) brew_runtime.Value {
	pin, root := formula_pin_spec_prepare('pin-unpin') or {
		return brew_runtime.bool_value(false)
	}
	os.mkdir_all(os.join_path(pin.rack, '0.1')) or {
		os.rmdir_all(root) or {}
		return brew_runtime.bool_value(false)
	}
	pin.pin_latest() or {
		os.rmdir_all(root) or {}
		return brew_runtime.bool_value(false)
	}
	pinned := pin.pinned() && os.is_dir(pin.path()) && (os.ls(pin.pinned_kegs) or { []string{} }).len == 1
	pin.unpin() or {
		os.rmdir_all(root) or {}
		return brew_runtime.bool_value(false)
	}
	result := pinned && !pin.pinned() && !os.is_dir(pin.pinned_kegs)
	os.rmdir_all(root) or {}
	return brew_runtime.bool_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula_pin"
// 5:
// 6: RSpec.describe FormulaPin do
// 7:   subject(:formula_pin) { described_class.new(formula) }
// 8:
// 9:   let(:name) { "double" }
// 10:   let(:formula) { instance_double(Formula, name:, rack: HOMEBREW_CELLAR/name) }
// 11:
// 12:   before do
// 13:     formula.rack.mkpath
// 14:
// 15:     allow(formula).to receive(:installed_prefixes) do
// 16:       formula.rack.directory? ? formula.rack.subdirs.sort : []
// 17:     end
// 18:
// 19:     allow(formula).to receive(:installed_kegs) do
// 20:       formula.installed_prefixes.map { |prefix| Keg.new(prefix) }
// 21:     end
// 22:   end
// 23:
// 24:   it "is not pinnable by default" do
// 25:     expect(formula_pin).not_to be_pinnable
// 26:   end
// 27:
// 28:   it "is pinnable if the Keg exists" do
// 29:     (formula.rack/"0.1").mkpath
// 30:     expect(formula_pin).to be_pinnable
// 31:   end
// 32:
// 33:   specify "#pin and #unpin" do
// 34:     (formula.rack/"0.1").mkpath
// 35:
// 36:     formula_pin.pin
// 37:     expect(formula_pin).to be_pinned
// 38:     expect(HOMEBREW_PINNED_KEGS/name).to be_a_directory
// 39:     expect(HOMEBREW_PINNED_KEGS.children.count).to eq(1)
// 40:
// 41:     formula_pin.unpin
// 42:     expect(formula_pin).not_to be_pinned
// 43:     expect(HOMEBREW_PINNED_KEGS).not_to be_a_directory
// 44:   end
// 45: end
