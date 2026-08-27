module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/leaves_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints nothing" do` at line 11.
pub fn ruby_leaves_spec_l11_d1_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "prints all installed Formulae" do` at line 22.
pub fn ruby_leaves_spec_l22_d2_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "prints all installed Formulae that are not dependencies of another installed Formula", :integration_test do` at line 41.
pub fn ruby_leaves_spec_l41_d3_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "does not list a renamed formula as a leaf when a stale tab records its old name" do` at line 53.
pub fn ruby_leaves_spec_l53_d4_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/leaves"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Leaves do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   context "when there are no installed Formulae" do
// 11:     it "prints nothing" do
// 12:       allow(Formula).to receive(:installed).and_return([])
// 13:       allow(Cask::Caskroom).to receive(:casks).and_return([])
// 14:
// 15:       expect { described_class.new([]).run }
// 16:         .to not_to_output.to_stdout
// 17:         .and not_to_output.to_stderr
// 18:     end
// 19:   end
// 20:
// 21:   context "when there are only installed Formulae without dependencies" do
// 22:     it "prints all installed Formulae" do
// 23:       allow(Formula).to receive(:installed).and_return([
// 24:         instance_double(
// 25:           Formula,
// 26:           any_installed_keg:                      nil,
// 27:           full_name:                              "foo",
// 28:           installed_runtime_formula_dependencies: [],
// 29:           possible_names:                         ["foo"],
// 30:         ),
// 31:       ])
// 32:       allow(Cask::Caskroom).to receive(:casks).and_return([])
// 33:
// 34:       expect { described_class.new([]).run }
// 35:         .to output("foo\n").to_stdout
// 36:         .and not_to_output.to_stderr
// 37:     end
// 38:   end
// 39:
// 40:   context "when there are installed Formulae", :no_api do
// 41:     it "prints all installed Formulae that are not dependencies of another installed Formula", :integration_test do
// 42:       setup_test_formula "foo"
// 43:       setup_test_formula "bar"
// 44:       (HOMEBREW_CELLAR/"foo/0.1/somedir").mkpath
// 45:       (HOMEBREW_CELLAR/"bar/0.1/somedir").mkpath
// 46:
// 47:       expect { brew "leaves" }
// 48:         .to output("bar\n").to_stdout
// 49:         .and not_to_output.to_stderr
// 50:         .and be_a_success
// 51:     end
// 52:
// 53:     it "does not list a renamed formula as a leaf when a stale tab records its old name" do
// 54:       # Simulate: "foo" was renamed to "newname"; "bar" depends on it but its tab
// 55:       # still records the old dependency name under a tap-qualified full_name
// 56:       # (not yet regenerated after rename). Also exercises the tap-prefix strip path.
// 57:       allow(Formula).to receive(:installed).and_return([
// 58:         instance_double(
// 59:           Formula,
// 60:           any_installed_keg:                      nil,
// 61:           full_name:                              "newname",
// 62:           installed_runtime_formula_dependencies: [],
// 63:           possible_names:                         %w[newname foo],
// 64:         ),
// 65:         instance_double(
// 66:           Formula,
// 67:           any_installed_keg:                      instance_double(
// 68:             Keg,
// 69:             runtime_dependencies: [{ "full_name" => "homebrew/core/foo" }],
// 70:           ),
// 71:           full_name:                              "bar",
// 72:           installed_runtime_formula_dependencies: [],
// 73:           possible_names:                         ["bar"],
// 74:         ),
// 75:       ])
// 76:       allow(Cask::Caskroom).to receive(:casks).and_return([])
// 77:
// 78:       expect { described_class.new([]).run }
// 79:         .to output("bar\n").to_stdout
// 80:         .and not_to_output.to_stderr
// 81:     end
// 82:   end
// 83: end
