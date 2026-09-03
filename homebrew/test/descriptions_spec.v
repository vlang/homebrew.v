module test

import homebrew

// Translated from Homebrew/brew `test/descriptions_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:descriptions) { described_class.new(descriptions_hash) }` at line 7.
pub fn ruby_descriptions_spec_l7_d1_descriptions() homebrew.Descriptions {
	return homebrew.new_descriptions(ruby_descriptions_spec_l9_d2_descriptions_hash(), {})
}

// Ruby let `let(:descriptions_hash) { {} }` at line 9.
pub fn ruby_descriptions_spec_l9_d2_descriptions_hash() map[string]homebrew.DescriptionValue {
	return map[string]homebrew.DescriptionValue{}
}

// Ruby it `it "can print description for a core Formula" do` at line 11.
pub fn ruby_descriptions_spec_l11_d3_can() bool {
	descriptions := homebrew.new_descriptions({
		'homebrew/core/foo': homebrew.description_formula('Core foo')
	}, {})
	return descriptions.print_output(false) == 'foo: Core foo\n'
}

// Ruby it `it "can print description for an external Formula" do` at line 16.
pub fn ruby_descriptions_spec_l16_d4_can() bool {
	descriptions := homebrew.new_descriptions({
		'somedev/external/foo': homebrew.description_formula('External foo')
	}, {})
	return descriptions.print_output(false) == 'foo: External foo\n'
}

// Ruby it `it "can print descriptions for duplicate Formulae" do` at line 21.
pub fn ruby_descriptions_spec_l21_d5_can() bool {
	descriptions := homebrew.new_descriptions({
		'homebrew/core/foo':    homebrew.description_formula('Core foo')
		'somedev/external/foo': homebrew.description_formula('External foo')
	}, {})
	return descriptions.print_output(false) == 'homebrew/core/foo: Core foo\nsomedev/external/foo: External foo\n'
}

// Ruby it `it "can print descriptions for duplicate core and external Formulae" do` at line 33.
pub fn ruby_descriptions_spec_l33_d6_can() bool {
	descriptions := homebrew.new_descriptions({
		'homebrew/core/foo':     homebrew.description_formula('Core foo')
		'somedev/external/foo':  homebrew.description_formula('External foo')
		'otherdev/external/foo': homebrew.description_formula('Other external foo')
	}, {})
	return descriptions.print_output(false) == 'homebrew/core/foo: Core foo\notherdev/external/foo: Other external foo\nsomedev/external/foo: External foo\n'
}

// Ruby it `it "can print description for a cask" do` at line 47.
pub fn ruby_descriptions_spec_l47_d7_can() bool {
	descriptions := homebrew.new_descriptions({
		'homebrew/cask/foo': homebrew.description_cask('Foo', 'Cask foo')
	}, {})
	return descriptions.print_output(false) == 'foo: (Foo) Cask foo\n'
}

// Ruby it `it "skips formulae without a description" do` at line 52.
pub fn ruby_descriptions_spec_l52_d8_skips() bool {
	descriptions := homebrew.new_descriptions({
		'homebrew/core/foo': homebrew.description_formula(none)
	}, {})
	return descriptions.print_output(false) == ''
}

// Ruby it `it "skips casks without a description" do` at line 58.
pub fn ruby_descriptions_spec_l58_d9_skips() bool {
	descriptions := homebrew.new_descriptions({
		'homebrew/cask/foo': homebrew.description_cask('Foo', none)
	}, {})
	return descriptions.print_output(false) == ''
}

// Ruby it `it "prints casks without a description when requested" do` at line 64.
pub fn ruby_descriptions_spec_l64_d10_prints() bool {
	descriptions := homebrew.new_descriptions({
		'homebrew/cask/foo': homebrew.description_cask('Foo', none)
	}, {})
	return descriptions.print_output(true) == 'foo: (Foo) [no description]\n'
}

// Ruby it `it "prints casks with an incomplete description" do` at line 70.
pub fn ruby_descriptions_spec_l70_d11_prints() bool {
	descriptions := homebrew.new_descriptions({
		'homebrew/cask/foo': homebrew.description_cask('Foo', none)
	}, {})
	return descriptions.print_output(true) == 'foo: (Foo) [no description]\n'
}

// Ruby it `it "prints trailing status for interactive formula descriptions" do` at line 76.
pub fn ruby_descriptions_spec_l76_d12_prints() bool {
	descriptions := homebrew.new_descriptions_with_state({
		'homebrew/core/foo': homebrew.description_formula('Core foo')
	}, {}, [
		homebrew.DescriptionInstalledItem{
			name: 'foo'
			full_name: 'homebrew/core/foo'
		},
	], [], {
		'homebrew/core/foo': homebrew.DescriptionStatus{}
	}, true, true)
	output := descriptions.print_output(false)
	return output.contains('foo') && output.contains('(installed)') && output.ends_with(': Core foo\n')
}

// Ruby it `it "uses installed and deprecation metadata without loading formulae" do` at line 89.
pub fn ruby_descriptions_spec_l89_d13_uses() bool {
	descriptions := homebrew.new_descriptions_with_state({
		'homebrew/core/foo': homebrew.description_formula('Core foo')
	}, {
		'homebrew/core/foo': homebrew.DescriptionStatus{
			deprecated: true
		}
	}, [
		homebrew.DescriptionInstalledItem{
			name: 'foo'
			full_name: 'homebrew/core/foo'
		},
	], [], {}, true, true)
	output := descriptions.print_output(false)
	return output.contains('(installed)') && output.contains('(deprecated)')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "descriptions"
// 5:
// 6: RSpec.describe Descriptions do
// 7:   subject(:descriptions) { described_class.new(descriptions_hash) }
// 8:
// 9:   let(:descriptions_hash) { {} }
// 10:
// 11:   it "can print description for a core Formula" do
// 12:     descriptions_hash["homebrew/core/foo"] = "Core foo"
// 13:     expect { descriptions.print }.to output("foo: Core foo\n").to_stdout
// 14:   end
// 15:
// 16:   it "can print description for an external Formula" do
// 17:     descriptions_hash["somedev/external/foo"] = "External foo"
// 18:     expect { descriptions.print }.to output("foo: External foo\n").to_stdout
// 19:   end
// 20:
// 21:   it "can print descriptions for duplicate Formulae" do
// 22:     descriptions_hash["homebrew/core/foo"] = "Core foo"
// 23:     descriptions_hash["somedev/external/foo"] = "External foo"
// 24:
// 25:     expect { descriptions.print }.to output(
// 26:       <<~EOS,
// 27:         homebrew/core/foo: Core foo
// 28:         somedev/external/foo: External foo
// 29:       EOS
// 30:     ).to_stdout
// 31:   end
// 32:
// 33:   it "can print descriptions for duplicate core and external Formulae" do
// 34:     descriptions_hash["homebrew/core/foo"] = "Core foo"
// 35:     descriptions_hash["somedev/external/foo"] = "External foo"
// 36:     descriptions_hash["otherdev/external/foo"] = "Other external foo"
// 37:
// 38:     expect { descriptions.print }.to output(
// 39:       <<~EOS,
// 40:         homebrew/core/foo: Core foo
// 41:         otherdev/external/foo: Other external foo
// 42:         somedev/external/foo: External foo
// 43:       EOS
// 44:     ).to_stdout
// 45:   end
// 46:
// 47:   it "can print description for a cask" do
// 48:     descriptions_hash["homebrew/cask/foo"] = ["Foo", "Cask foo"]
// 49:     expect { descriptions.print }.to output("foo: (Foo) Cask foo\n").to_stdout
// 50:   end
// 51:
// 52:   it "skips formulae without a description" do
// 53:     descriptions_hash["homebrew/core/foo"] = nil
// 54:
// 55:     expect { descriptions.print }.not_to output.to_stdout
// 56:   end
// 57:
// 58:   it "skips casks without a description" do
// 59:     descriptions_hash["homebrew/cask/foo"] = ["Foo", nil]
// 60:
// 61:     expect { descriptions.print }.not_to output.to_stdout
// 62:   end
// 63:
// 64:   it "prints casks without a description when requested" do
// 65:     descriptions_hash["homebrew/cask/foo"] = ["Foo", nil]
// 66:
// 67:     expect { descriptions.print(show_missing: true) }.to output("foo: (Foo) [no description]\n").to_stdout
// 68:   end
// 69:
// 70:   it "prints casks with an incomplete description" do
// 71:     descriptions_hash["homebrew/cask/foo"] = ["Foo"]
// 72:
// 73:     expect { descriptions.print(show_missing: true) }.to output("foo: (Foo) [no description]\n").to_stdout
// 74:   end
// 75:
// 76:   it "prints trailing status for interactive formula descriptions" do
// 77:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 78:     descriptions_hash["homebrew/core/foo"] = "Core foo"
// 79:
// 80:     allow(Formula).to receive(:installed).and_return(
// 81:       [instance_double(Formula, name: "foo", full_name: "homebrew/core/foo")],
// 82:     )
// 83:     formula = instance_double(Formula, any_version_installed?: true, deprecated?: false, disabled?: false)
// 84:     allow(Formulary).to receive(:factory).with("homebrew/core/foo").and_return(formula)
// 85:
// 86:     expect { descriptions.print }.to output(/foo .*: Core foo/).to_stdout
// 87:   end
// 88:
// 89:   it "uses installed and deprecation metadata without loading formulae" do
// 90:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 91:     descriptions_hash["homebrew/core/foo"] = "Core foo"
// 92:
// 93:     descriptions = described_class.new(
// 94:       descriptions_hash,
// 95:       status_data: { "homebrew/core/foo" => { deprecated: true, disabled: false } },
// 96:     )
// 97:
// 98:     allow(Formula).to receive(:installed).and_return(
// 99:       [instance_double(Formula, name: "foo", full_name: "homebrew/core/foo")],
// 100:     )
// 101:     expect(Formulary).not_to receive(:factory)
// 102:     expect(Cask::CaskLoader).not_to receive(:load)
// 103:
// 104:     expect { descriptions.print }.to output(/foo .*deprecated.*: Core foo/).to_stdout
// 105:   end
// 106: end
