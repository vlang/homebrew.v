module bundle

import brew_runtime
import homebrew.bundle as bundle_impl

// Translated from Homebrew/brew `test/bundle/remover_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:remover) { described_class }` at line 8.
pub fn ruby_remover_spec_l8_d1_remover(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Homebrew::Bundle::Remover', 'Homebrew::Bundle::Remover')
}

// Ruby let `let(:name) { "foo" }` at line 10.
pub fn ruby_remover_spec_l10_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('foo')
}

// Ruby it `it "raises no errors when requested" do` at line 14.
pub fn ruby_remover_spec_l14_d3_raises(args ...brew_runtime.Value) brew_runtime.Value {
	bundle_impl.possible_bundle_names('foo', []bundle_impl.BundlePackage{}, false) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/remover"
// 6:
// 7: RSpec.describe Homebrew::Bundle::Remover do
// 8:   subject(:remover) { described_class }
// 9:
// 10:   let(:name) { "foo" }
// 11:
// 12:   before { allow(Formulary).to receive(:factory).with(name).and_raise(FormulaUnavailableError.new(name)) }
// 13:
// 14:   it "raises no errors when requested" do
// 15:     expect { remover.possible_names(name, raise_error: false) }.not_to raise_error
// 16:   end
// 17: end
