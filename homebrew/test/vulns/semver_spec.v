module vulns

import homebrew.vulns as semver_core

// Translated from Homebrew/brew `test/vulns/semver_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn semver_spec_comparison(left string, right string, expected int) bool {
	comparison := semver_core.compare_semver(left, right) or { return false }
	return comparison == expected
}

fn semver_spec_invalid(left string, right string) bool {
	return semver_core.compare_semver(left, right) == none
}

// Ruby it `it "orders major versions numerically" do` at line 9.
pub fn ruby_semver_spec_l9_d1_orders() bool {
	return semver_spec_comparison('1.0.0', '2.0.0', -1) && semver_spec_comparison('2.0.0', '1.9.9', 1) && semver_spec_comparison('1.0.0', '1.0.0', 0)
}

// Ruby it `it "orders minor and patch versions numerically" do` at line 15.
pub fn ruby_semver_spec_l15_d2_orders() bool {
	return semver_spec_comparison('1.9.0', '1.10.0', -1) && semver_spec_comparison('1.0.9', '1.0.10', -1)
}

// Ruby it `it "treats missing minor/patch as zero" do` at line 20.
pub fn ruby_semver_spec_l20_d3_treats() bool {
	return semver_spec_comparison('1', '1.0.0', 0) && semver_spec_comparison('1.2', '1.2.0', 0)
}

// Ruby it `it "strips a leading v prefix" do` at line 25.
pub fn ruby_semver_spec_l25_d4_strips() bool {
	return semver_spec_comparison('v1.2.3', '1.2.3', 0) && semver_spec_comparison('V2.0.0', '1.9.9', 1)
}

// Ruby it `it "ignores build metadata" do` at line 31.
pub fn ruby_semver_spec_l31_d5_ignores() bool {
	return semver_spec_comparison('1.0.0+1', '1.0.0+2', 0) && semver_spec_comparison('1.0.0+20130313144700', '1.0.0', 0) && semver_spec_comparison('1.0.0-beta+exp.sha.5114f85', '1.0.0-beta', 0)
}

// Ruby it `it "orders prerelease below the associated release" do` at line 39.
pub fn ruby_semver_spec_l39_d6_orders() bool {
	return semver_spec_comparison('1.0.0-alpha', '1.0.0', -1) && semver_spec_comparison('1.0.0', '1.0.0-rc.1', 1)
}

// Ruby it `it "compares numeric prerelease identifiers numerically" do` at line 45.
pub fn ruby_semver_spec_l45_d7_compares() bool {
	return semver_spec_comparison('1.0.0-alpha.9', '1.0.0-alpha.10', -1) && semver_spec_comparison('1.0.0-1', '1.0.0-2', -1)
}

// Ruby it `it "compares alphanumeric prerelease identifiers lexically" do` at line 50.
pub fn ruby_semver_spec_l50_d8_compares() bool {
	return semver_spec_comparison('1.0.0-alpha', '1.0.0-beta', -1) && semver_spec_comparison('1.0.0-rc', '1.0.0-beta', 1)
}

// Ruby it `it "orders numeric prerelease identifiers below alphanumeric ones" do` at line 57.
pub fn ruby_semver_spec_l57_d9_orders() bool {
	return semver_spec_comparison('1.0.0-alpha.1', '1.0.0-alpha.beta', -1) && semver_spec_comparison('1.0.0-2', '1.0.0-1a', -1)
}

// Ruby it `it "orders shorter prerelease field lists below longer ones" do` at line 64.
pub fn ruby_semver_spec_l64_d10_orders() bool {
	return semver_spec_comparison('1.0.0-alpha', '1.0.0-alpha.1', -1)
}

// Ruby it `it "matches the spec's precedence example chain" do` at line 69.
pub fn ruby_semver_spec_l69_d11_matches() bool {
	chain := ['1.0.0-alpha', '1.0.0-alpha.1', '1.0.0-alpha.beta', '1.0.0-beta', '1.0.0-beta.2',
		'1.0.0-beta.11', '1.0.0-rc.1', '1.0.0']
	for index in 0 .. chain.len - 1 {
		if !semver_spec_comparison(chain[index], chain[index + 1], -1) || !semver_spec_comparison(chain[index + 1], chain[index], 1) {
			return false
		}
	}
	return true
}

// Ruby it `it "handles single-segment zero" do` at line 89.
pub fn ruby_semver_spec_l89_d12_handles() bool {
	return semver_spec_comparison('0', '0.1.0', -1) && semver_spec_comparison('0', '0.0.0', 0)
}

// Ruby it `it "handles versions used in OSV range fixtures" do` at line 95.
pub fn ruby_semver_spec_l95_d13_handles() bool {
	return semver_spec_comparison('1.2.0', '1.5.0', -1) && semver_spec_comparison('1.4.9', '1.5.0', -1) && semver_spec_comparison('1.5.0', '1.5.0', 0) && semver_spec_comparison('4.17.20', '4.17.21', -1)
}

// Ruby it `it "returns nil when either side is unparseable" do` at line 102.
pub fn ruby_semver_spec_l102_d14_returns() bool {
	return semver_spec_invalid('not-a-version', '1.0.0') && semver_spec_invalid('1.0.0', '')
}

// Ruby it `it "returns nil for leading zeroes in core segments" do` at line 107.
pub fn ruby_semver_spec_l107_d15_returns() bool {
	return semver_spec_invalid('01.0.0', '1.0.0') && semver_spec_invalid('1.02.0', '1.0.0') && semver_spec_invalid('1.0.00', '1.0.0')
}

// Ruby it `it "returns nil for leading zeroes in numeric prerelease identifiers" do` at line 113.
pub fn ruby_semver_spec_l113_d16_returns() bool {
	return semver_spec_invalid('1.0.0-01', '1.0.0') && semver_spec_invalid('1.0.0-alpha.01', '1.0.0')
}

// Ruby it `it "accepts leading zeroes in alphanumeric prerelease identifiers" do` at line 118.
pub fn ruby_semver_spec_l118_d17_accepts() bool {
	return semver_spec_comparison('1.0.0-0a', '1.0.0-0a', 0)
}

// Ruby it `it "returns nil for empty prerelease or build identifiers" do` at line 122.
pub fn ruby_semver_spec_l122_d18_returns() bool {
	for version in ['1.0.0-', '1.0.0-alpha..1', '1.0.0-alpha.', '1.0.0+', '1.0.0+build..1'] {
		if !semver_spec_invalid(version, '1.0.0') {
			return false
		}
	}
	return true
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/semver"
// 5:
// 6: RSpec.describe Homebrew::Vulns::Semver do
// 7:   describe ".compare" do
// 8:     # From vers gem: basic numeric ordering
// 9:     it "orders major versions numerically" do
// 10:       expect(described_class.compare("1.0.0", "2.0.0")).to eq(-1)
// 11:       expect(described_class.compare("2.0.0", "1.9.9")).to eq 1
// 12:       expect(described_class.compare("1.0.0", "1.0.0")).to eq 0
// 13:     end
// 14:
// 15:     it "orders minor and patch versions numerically" do
// 16:       expect(described_class.compare("1.9.0", "1.10.0")).to eq(-1)
// 17:       expect(described_class.compare("1.0.9", "1.0.10")).to eq(-1)
// 18:     end
// 19:
// 20:     it "treats missing minor/patch as zero" do
// 21:       expect(described_class.compare("1", "1.0.0")).to eq 0
// 22:       expect(described_class.compare("1.2", "1.2.0")).to eq 0
// 23:     end
// 24:
// 25:     it "strips a leading v prefix" do
// 26:       expect(described_class.compare("v1.2.3", "1.2.3")).to eq 0
// 27:       expect(described_class.compare("V2.0.0", "1.9.9")).to eq 1
// 28:     end
// 29:
// 30:     # SemVer 2.0 spec section 11: build metadata is ignored for precedence
// 31:     it "ignores build metadata" do
// 32:       expect(described_class.compare("1.0.0+1", "1.0.0+2")).to eq 0
// 33:       expect(described_class.compare("1.0.0+20130313144700", "1.0.0")).to eq 0
// 34:       expect(described_class.compare("1.0.0-beta+exp.sha.5114f85", "1.0.0-beta")).to eq 0
// 35:     end
// 36:
// 37:     # SemVer 2.0 spec section 11: a version with a prerelease has lower
// 38:     # precedence than the same version without one
// 39:     it "orders prerelease below the associated release" do
// 40:       expect(described_class.compare("1.0.0-alpha", "1.0.0")).to eq(-1)
// 41:       expect(described_class.compare("1.0.0", "1.0.0-rc.1")).to eq 1
// 42:     end
// 43:
// 44:     # SemVer 2.0 spec section 11: prerelease identifiers compared field by field
// 45:     it "compares numeric prerelease identifiers numerically" do
// 46:       expect(described_class.compare("1.0.0-alpha.9", "1.0.0-alpha.10")).to eq(-1)
// 47:       expect(described_class.compare("1.0.0-1", "1.0.0-2")).to eq(-1)
// 48:     end
// 49:
// 50:     it "compares alphanumeric prerelease identifiers lexically" do
// 51:       expect(described_class.compare("1.0.0-alpha", "1.0.0-beta")).to eq(-1)
// 52:       expect(described_class.compare("1.0.0-rc", "1.0.0-beta")).to eq 1
// 53:     end
// 54:
// 55:     # SemVer 2.0 spec section 11 rule 3: numeric identifiers always have lower
// 56:     # precedence than alphanumeric identifiers
// 57:     it "orders numeric prerelease identifiers below alphanumeric ones" do
// 58:       expect(described_class.compare("1.0.0-alpha.1", "1.0.0-alpha.beta")).to eq(-1)
// 59:       expect(described_class.compare("1.0.0-2", "1.0.0-1a")).to eq(-1)
// 60:     end
// 61:
// 62:     # SemVer 2.0 spec section 11 rule 4: a larger set of prerelease fields has
// 63:     # higher precedence than a smaller set, if all preceding identifiers match
// 64:     it "orders shorter prerelease field lists below longer ones" do
// 65:       expect(described_class.compare("1.0.0-alpha", "1.0.0-alpha.1")).to eq(-1)
// 66:     end
// 67:
// 68:     # SemVer 2.0 spec section 11: full precedence chain example
// 69:     it "matches the spec's precedence example chain" do
// 70:       chain = %w[
// 71:         1.0.0-alpha
// 72:         1.0.0-alpha.1
// 73:         1.0.0-alpha.beta
// 74:         1.0.0-beta
// 75:         1.0.0-beta.2
// 76:         1.0.0-beta.11
// 77:         1.0.0-rc.1
// 78:         1.0.0
// 79:       ]
// 80:       chain.each_cons(2) do |pair|
// 81:         a = pair.fetch(0)
// 82:         b = pair.fetch(1)
// 83:         expect(described_class.compare(a, b)).to(eq(-1), "expected #{a} < #{b}")
// 84:         expect(described_class.compare(b, a)).to(eq(1), "expected #{b} > #{a}")
// 85:       end
// 86:     end
// 87:
// 88:     # From brew-vulns test_vulnerability.rb: OSV uses "0" as an open lower bound
// 89:     it "handles single-segment zero" do
// 90:       expect(described_class.compare("0", "0.1.0")).to eq(-1)
// 91:       expect(described_class.compare("0", "0.0.0")).to eq 0
// 92:     end
// 93:
// 94:     # From brew-vulns test_vulnerability.rb range checks
// 95:     it "handles versions used in OSV range fixtures" do
// 96:       expect(described_class.compare("1.2.0", "1.5.0")).to eq(-1)
// 97:       expect(described_class.compare("1.4.9", "1.5.0")).to eq(-1)
// 98:       expect(described_class.compare("1.5.0", "1.5.0")).to eq 0
// 99:       expect(described_class.compare("4.17.20", "4.17.21")).to eq(-1)
// 100:     end
// 101:
// 102:     it "returns nil when either side is unparseable" do
// 103:       expect(described_class.compare("not-a-version", "1.0.0")).to be_nil
// 104:       expect(described_class.compare("1.0.0", "")).to be_nil
// 105:     end
// 106:
// 107:     it "returns nil for leading zeroes in core segments" do
// 108:       expect(described_class.compare("01.0.0", "1.0.0")).to be_nil
// 109:       expect(described_class.compare("1.02.0", "1.0.0")).to be_nil
// 110:       expect(described_class.compare("1.0.00", "1.0.0")).to be_nil
// 111:     end
// 112:
// 113:     it "returns nil for leading zeroes in numeric prerelease identifiers" do
// 114:       expect(described_class.compare("1.0.0-01", "1.0.0")).to be_nil
// 115:       expect(described_class.compare("1.0.0-alpha.01", "1.0.0")).to be_nil
// 116:     end
// 117:
// 118:     it "accepts leading zeroes in alphanumeric prerelease identifiers" do
// 119:       expect(described_class.compare("1.0.0-0a", "1.0.0-0a")).to eq 0
// 120:     end
// 121:
// 122:     it "returns nil for empty prerelease or build identifiers" do
// 123:       expect(described_class.compare("1.0.0-", "1.0.0")).to be_nil
// 124:       expect(described_class.compare("1.0.0-alpha..1", "1.0.0")).to be_nil
// 125:       expect(described_class.compare("1.0.0-alpha.", "1.0.0")).to be_nil
// 126:       expect(described_class.compare("1.0.0+", "1.0.0")).to be_nil
// 127:       expect(described_class.compare("1.0.0+build..1", "1.0.0")).to be_nil
// 128:     end
// 129:   end
// 130: end
