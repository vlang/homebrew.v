module diagnostic

import brew_runtime
import homebrew.diagnostic as core

// Translated from Homebrew/brew `test/diagnostic/finding_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns an empty string when no text or commands are given" do` at line 9.
pub fn ruby_finding_spec_l9_d1_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(core.new_remediation([], '').string() == '')
}

// Ruby it `it "prefers the text over commands" do` at line 13.
pub fn ruby_finding_spec_l13_d2_prefers(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(core.new_remediation(['brew fix'], 'Do this instead').string() == 'Do this instead')
}

// Ruby it `it "formats commands when no text is given" do` at line 18.
pub fn ruby_finding_spec_l18_d3_formats(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(core.new_remediation(['brew fix', 'brew doctor'], '').string() == 'You can solve this by running:\n  brew fix\n  brew doctor')
}

// Ruby it `it "returns the commands and text" do` at line 25.
pub fn ruby_finding_spec_l25_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	value := core.new_remediation(['brew fix'], 'Do this').to_value().as_map() or {
		return brew_runtime.bool_value(false)
	}
	commands := value['commands'].as_string_array() or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(commands == ['brew fix'] && value['text'].as_string() == 'Do this')
}

// Ruby it `it "wraps a string remediation in a Remediation" do` at line 33.
pub fn ruby_finding_spec_l33_d5_wraps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	finding := core.new_finding('Something is wrong', '1', [], [], core.Remediation{
		text: 'Fix it'
	})
	remediation := finding.remediation or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(remediation.text == 'Fix it')
}

// Ruby it `it "keeps a Remediation remediation as-is" do` at line 38.
pub fn ruby_finding_spec_l38_d6_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	remediation := core.Remediation{
		text: 'Fix it'
	}
	finding := core.new_finding('Something is wrong', '1', [], [], remediation)
	kept := finding.remediation or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(kept == remediation)
}

// Ruby it `it "defaults remediation to nil and tier to 1" do` at line 44.
pub fn ruby_finding_spec_l44_d7_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	finding := core.new_finding('Something is wrong', '', [], [], none)
	return brew_runtime.bool_value(finding.remediation == none && finding.tier == '1')
}

// Ruby it `it "serialises all attributes" do` at line 52.
pub fn ruby_finding_spec_l52_d8_serialises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	finding := core.new_finding('Something is wrong', '2', ['foo'], ['https://brew.sh'], core.Remediation{
		text: 'Fix it'
	})
	value := finding.to_value().as_map() or { return brew_runtime.bool_value(false) }
	remediation := value['remediation'].as_map() or { return brew_runtime.bool_value(false) }
	affects := value['affects'].as_string_array() or { return brew_runtime.bool_value(false) }
	links := value['links'].as_string_array() or { return brew_runtime.bool_value(false) }
	commands := remediation['commands'].as_string_array() or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(value['text'].as_string() == 'Something is wrong' && value['tier'].as_string() == '2' && affects == [
		'foo',
	] && links == ['https://brew.sh'] && commands.len == 0 && remediation['text'].as_string() == 'Fix it')
}

// Ruby it `it "serialises a nil remediation as nil" do` at line 69.
pub fn ruby_finding_spec_l69_d9_serialises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	value := core.new_finding('Something is wrong', '', [], [], none).to_value().as_map() or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(value['remediation'].type_name == 'NilClass')
}

// Ruby it `it "includes only the text for a Tier 1 finding without remediation" do` at line 75.
pub fn ruby_finding_spec_l75_d10_includes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(core.new_finding('Something is wrong', '1', [], [], none).string() == 'Something is wrong')
}

// Ruby it `it "includes the remediation text" do` at line 79.
pub fn ruby_finding_spec_l79_d11_includes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	finding := core.new_finding('Something is wrong', '1', [], [], core.Remediation{
		text: 'Fix it'
	})
	return brew_runtime.bool_value(finding.string() == 'Something is wrong\nFix it')
}

// Ruby it `it "returns nil for Tier 1" do` at line 90.
pub fn ruby_finding_spec_l90_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(core.support_tier_message('1', false, '') == '')
}

// Ruby it `it "links to the tier-specific documentation" do` at line 94.
pub fn ruby_finding_spec_l94_d13_links(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(core.support_tier_message('2', false, '').contains('https://docs.brew.sh/Support-Tiers#tier-2'))
}

// Ruby it `it "describes unsupported configurations" do` at line 99.
pub fn ruby_finding_spec_l99_d14_describes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	message := core.support_tier_message('unsupported', false, '')
	return brew_runtime.bool_value(message.contains('This is a Unsupported configuration:') && message.contains('https://docs.brew.sh/Support-Tiers#unsupported'))
}

// Ruby it `it "points Nix-managed installs at the upstream Nix project" do` at line 105.
pub fn ruby_finding_spec_l105_d15_points(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(core.support_tier_message('2', true, '').contains('Report issues to the upstream Nix project, not'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "diagnostic/finding"
// 5:
// 6: RSpec.describe Homebrew::Diagnostic::Finding do
// 7:   describe Homebrew::Diagnostic::Finding::Remediation do
// 8:     describe "#to_s" do
// 9:       it "returns an empty string when no text or commands are given" do
// 10:         expect(described_class.new.to_s).to eq("")
// 11:       end
// 12:
// 13:       it "prefers the text over commands" do
// 14:         remediation = described_class.new(text: "Do this instead", commands: ["brew fix"])
// 15:         expect(remediation.to_s).to eq("Do this instead")
// 16:       end
// 17:
// 18:       it "formats commands when no text is given" do
// 19:         remediation = described_class.new(commands: ["brew fix", "brew doctor"])
// 20:         expect(remediation.to_s).to eq("You can solve this by running:\n  brew fix\n  brew doctor")
// 21:       end
// 22:     end
// 23:
// 24:     describe "#to_h" do
// 25:       it "returns the commands and text" do
// 26:         remediation = described_class.new(text: "Do this", commands: ["brew fix"])
// 27:         expect(remediation.to_h).to eq(commands: ["brew fix"], text: "Do this")
// 28:       end
// 29:     end
// 30:   end
// 31:
// 32:   describe "#initialize" do
// 33:     it "wraps a string remediation in a Remediation" do
// 34:       finding = described_class.new("Something is wrong", remediation: "Fix it")
// 35:       expect(finding.remediation).to be_a(Homebrew::Diagnostic::Finding::Remediation)
// 36:     end
// 37:
// 38:     it "keeps a Remediation remediation as-is" do
// 39:       remediation = Homebrew::Diagnostic::Finding::Remediation.new(text: "Fix it")
// 40:       finding = described_class.new("Something is wrong", remediation:)
// 41:       expect(finding.remediation).to be(remediation)
// 42:     end
// 43:
// 44:     it "defaults remediation to nil and tier to 1" do
// 45:       finding = described_class.new("Something is wrong")
// 46:       expect(finding.remediation).to be_nil
// 47:       expect(finding.tier).to eq(1)
// 48:     end
// 49:   end
// 50:
// 51:   describe "#to_h" do
// 52:     it "serialises all attributes" do
// 53:       finding = described_class.new(
// 54:         "Something is wrong",
// 55:         tier:        2,
// 56:         affects:     ["foo"],
// 57:         links:       ["https://brew.sh"],
// 58:         remediation: "Fix it",
// 59:       )
// 60:       expect(finding.to_h).to eq(
// 61:         text:        "Something is wrong",
// 62:         tier:        2,
// 63:         affects:     ["foo"],
// 64:         links:       ["https://brew.sh"],
// 65:         remediation: { commands: [], text: "Fix it" },
// 66:       )
// 67:     end
// 68:
// 69:     it "serialises a nil remediation as nil" do
// 70:       expect(described_class.new("Something is wrong").to_h[:remediation]).to be_nil
// 71:     end
// 72:   end
// 73:
// 74:   describe "#to_s" do
// 75:     it "includes only the text for a Tier 1 finding without remediation" do
// 76:       expect(described_class.new("Something is wrong").to_s).to eq("Something is wrong")
// 77:     end
// 78:
// 79:     it "includes the remediation text" do
// 80:       finding = described_class.new("Something is wrong", remediation: "Fix it")
// 81:       expect(finding.to_s).to eq("Something is wrong\nFix it")
// 82:     end
// 83:   end
// 84:
// 85:   describe "#support_tier_message" do
// 86:     before do
// 87:       allow(OS).to receive(:nix_managed_homebrew?).and_return(false)
// 88:     end
// 89:
// 90:     it "returns nil for Tier 1" do
// 91:       expect(described_class.support_tier_message(tier: 1)).to be_nil
// 92:     end
// 93:
// 94:     it "links to the tier-specific documentation" do
// 95:       message = described_class.support_tier_message(tier: 2)
// 96:       expect(message).to include("https://docs.brew.sh/Support-Tiers#tier-2")
// 97:     end
// 98:
// 99:     it "describes unsupported configurations" do
// 100:       message = described_class.support_tier_message(tier: :unsupported)
// 101:       expect(message).to include("This is a Unsupported configuration:")
// 102:         .and include("https://docs.brew.sh/Support-Tiers#unsupported")
// 103:     end
// 104:
// 105:     it "points Nix-managed installs at the upstream Nix project" do
// 106:       allow(OS).to receive(:nix_managed_homebrew?).and_return(true)
// 107:
// 108:       message = described_class.support_tier_message(tier: 2)
// 109:       expect(message).to include("Report issues to the upstream Nix project, not")
// 110:     end
// 111:   end
// 112: end
