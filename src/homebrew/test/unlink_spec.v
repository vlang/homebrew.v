module test

import brew_runtime

// Translated from Homebrew/brew `test/unlink_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:formula) { instance_double(Formula, keg_only?: false) }` at line 8.
pub fn ruby_unlink_spec_l8_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby let `let(:linked_keg_only_keg) { instance_double(Keg, directory?: true) }` at line 9.
pub fn ruby_unlink_spec_l9_d2_linked_keg_only_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linked_keg_only_keg', ...args)
}

// Ruby let `let(:linked_keg_only_formula) do` at line 10.
pub fn ruby_unlink_spec_l10_d3_linked_keg_only_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linked_keg_only_formula', ...args)
}

// Ruby let `let(:linked_non_keg_only_keg) { instance_double(Keg, directory?: true) }` at line 13.
pub fn ruby_unlink_spec_l13_d4_linked_non_keg_only_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linked_non_keg_only_keg', ...args)
}

// Ruby let `let(:linked_non_keg_only_formula) do` at line 14.
pub fn ruby_unlink_spec_l14_d5_linked_non_keg_only_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linked_non_keg_only_formula', ...args)
}

// Ruby let `let(:unlinked_formula) do` at line 18.
pub fn ruby_unlink_spec_l18_d6_unlinked_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlinked_formula', ...args)
}

// Ruby it `it "only unlinks linked keg-only sibling formulae for non-keg-only formulae" do` at line 22.
pub fn ruby_unlink_spec_l22_d7_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Ruby it `it "unlinks all linked sibling formulae for keg-only formulae" do` at line 31.
pub fn ruby_unlink_spec_l31_d8_unlinks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlinks', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "unlink"
// 5:
// 6: RSpec.describe Homebrew::Unlink do
// 7:   describe ".unlink_link_overwrite_formulae" do
// 8:     let(:formula) { instance_double(Formula, keg_only?: false) }
// 9:     let(:linked_keg_only_keg) { instance_double(Keg, directory?: true) }
// 10:     let(:linked_keg_only_formula) do
// 11:       instance_double(Formula, linked?: true, keg_only?: true, any_installed_keg: linked_keg_only_keg)
// 12:     end
// 13:     let(:linked_non_keg_only_keg) { instance_double(Keg, directory?: true) }
// 14:     let(:linked_non_keg_only_formula) do
// 15:       instance_double(Formula, linked?: true, keg_only?: false,
// 16:                                any_installed_keg: linked_non_keg_only_keg)
// 17:     end
// 18:     let(:unlinked_formula) do
// 19:       instance_double(Formula, linked?: false, keg_only?: true, any_installed_keg: nil)
// 20:     end
// 21:
// 22:     it "only unlinks linked keg-only sibling formulae for non-keg-only formulae" do
// 23:       allow(formula).to receive(:link_overwrite_formulae)
// 24:         .and_return([linked_keg_only_formula, linked_non_keg_only_formula, unlinked_formula])
// 25:       expect(described_class).to receive(:unlink).with(linked_keg_only_keg, verbose: true).once
// 26:       expect(described_class).not_to receive(:unlink).with(linked_non_keg_only_keg, verbose: true)
// 27:
// 28:       described_class.unlink_link_overwrite_formulae(formula, verbose: true)
// 29:     end
// 30:
// 31:     it "unlinks all linked sibling formulae for keg-only formulae" do
// 32:       allow(formula).to receive_messages(keg_only?:               true,
// 33:                                          link_overwrite_formulae: [linked_keg_only_formula,
// 34:                                                                    linked_non_keg_only_formula,
// 35:                                                                    unlinked_formula])
// 36:       expect(described_class).to receive(:unlink).with(linked_keg_only_keg, verbose: true).once
// 37:       expect(described_class).to receive(:unlink).with(linked_non_keg_only_keg, verbose: true).once
// 38:
// 39:       described_class.unlink_link_overwrite_formulae(formula, verbose: true)
// 40:     end
// 41:   end
// 42: end
