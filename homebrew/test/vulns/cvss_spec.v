module vulns

import homebrew.vulns as cvss_core

// Translated from Homebrew/brew `test/vulns/cvss_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "scores` at line 27.
pub fn ruby_cvss_spec_l27_d1_scores(vector string, expected f64) bool {
	return cvss_core.cvss_base_score(vector) or { return false } == expected
}

// Ruby it `it "ignores temporal and environmental metrics" do` at line 32.
pub fn ruby_cvss_spec_l32_d2_ignores() bool {
	vector := 'CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H/E:P/RL:O/RC:C'
	return cvss_core.cvss_base_score(vector) or { return false } == 9.8
}

// Ruby it `it "returns nil for CVSS v4.0 vectors" do` at line 37.
pub fn ruby_cvss_spec_l37_d3_returns() bool {
	return cvss_core.cvss_base_score('CVSS:4.0/AV:N/AC:L/AT:N/PR:H/UI:N/VC:L/VI:L/VA:N/SC:N/SI:N/SA:N') == none
}

// Ruby it `it "returns nil for CVSS v2 vectors" do` at line 43.
pub fn ruby_cvss_spec_l43_d4_returns() bool {
	return cvss_core.cvss_base_score('AV:N/AC:L/Au:N/C:C/I:C/A:C') == none
}

// Ruby it `it "returns nil for a vector missing required base metrics" do` at line 47.
pub fn ruby_cvss_spec_l47_d5_returns() bool {
	return cvss_core.cvss_base_score('CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H') == none
}

// Ruby it `it "returns nil for a vector with an unknown metric value" do` at line 51.
pub fn ruby_cvss_spec_l51_d6_returns() bool {
	return cvss_core.cvss_base_score('CVSS:3.1/AV:X/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H') == none
}

// Ruby it `it "returns nil for garbage input" do` at line 55.
pub fn ruby_cvss_spec_l55_d7_returns() bool {
	for vector in ['', 'INVALID-CVSS', 'CVSS:3.1/'] {
		if cvss_core.cvss_base_score(vector) != none {
			return false
		}
	}
	return true
}

// Ruby it `it "buckets a 9.8 vector as critical" do` at line 64.
pub fn ruby_cvss_spec_l64_d8_buckets() bool {
	severity := cvss_core.cvss_severity('CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H') or {
		return false
	}
	return severity == .critical
}

// Ruby it `it "buckets an 8.8 vector as high" do` at line 68.
pub fn ruby_cvss_spec_l68_d9_buckets() bool {
	severity := cvss_core.cvss_severity('CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H') or {
		return false
	}
	return severity == .high
}

// Ruby it `it "buckets a 5.5 vector as medium" do` at line 72.
pub fn ruby_cvss_spec_l72_d10_buckets() bool {
	severity := cvss_core.cvss_severity('CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N') or {
		return false
	}
	return severity == .medium
}

// Ruby it `it "buckets a 1.8 vector as low" do` at line 76.
pub fn ruby_cvss_spec_l76_d11_buckets() bool {
	severity := cvss_core.cvss_severity('CVSS:3.1/AV:L/AC:H/PR:H/UI:R/S:U/C:L/I:N/A:N') or {
		return false
	}
	return severity == .low
}

// Ruby it `it "returns nil for a zero-impact vector" do` at line 80.
pub fn ruby_cvss_spec_l80_d12_returns() bool {
	return cvss_core.cvss_severity('CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N') == none
}

// Ruby it `it "returns nil for an unsupported version" do` at line 84.
pub fn ruby_cvss_spec_l84_d13_returns() bool {
	return cvss_core.cvss_severity('CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N') == none
}

// Ruby it `it "returns nil for an unparseable vector" do` at line 90.
pub fn ruby_cvss_spec_l90_d14_returns() bool {
	return cvss_core.cvss_severity('INVALID-CVSS') == none
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/cvss"
// 5:
// 6: RSpec.describe Homebrew::Vulns::CVSS do
// 7:   describe ".base_score" do
// 8:     # Vectors and expected scores from FIRST CVSS v3.1 examples and NVD entries
// 9:     # used in the brew-vulns gem's test suite.
// 10:     test_each_hash({
// 11:       "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H" => 9.8,
// 12:       "CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H" => 9.8,
// 13:       "CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:H" => 9.6,
// 14:       "CVSS:3.0/AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:H" => 9.6,
// 15:       "CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H" => 8.8,
// 16:       "CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H" => 8.8,
// 17:       "CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H" => 8.8,
// 18:       "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N" => 7.5,
// 19:       "CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:L/I:L/A:N" => 6.4,
// 20:       "CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N" => 5.5,
// 21:       "CVSS:3.1/AV:N/AC:H/PR:N/UI:R/S:C/C:L/I:L/A:N" => 4.7,
// 22:       "CVSS:3.1/AV:N/AC:L/PR:H/UI:N/S:U/C:L/I:L/A:N" => 3.8,
// 23:       "CVSS:3.1/AV:L/AC:H/PR:H/UI:R/S:U/C:L/I:N/A:N" => 1.8,
// 24:       "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N" => 0.0,
// 25:       "CVSS:3.1/AV:P/AC:H/PR:H/UI:R/S:U/C:N/I:N/A:N" => 0.0,
// 26:     }) do |vector, score|
// 27:       it "scores #{vector} as #{score}" do
// 28:         expect(described_class.base_score(vector)).to eq score
// 29:       end
// 30:     end
// 31:
// 32:     it "ignores temporal and environmental metrics" do
// 33:       vector = "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H/E:P/RL:O/RC:C"
// 34:       expect(described_class.base_score(vector)).to eq 9.8
// 35:     end
// 36:
// 37:     it "returns nil for CVSS v4.0 vectors" do
// 38:       expect(described_class.base_score(
// 39:                "CVSS:4.0/AV:N/AC:L/AT:N/PR:H/UI:N/VC:L/VI:L/VA:N/SC:N/SI:N/SA:N",
// 40:              )).to be_nil
// 41:     end
// 42:
// 43:     it "returns nil for CVSS v2 vectors" do
// 44:       expect(described_class.base_score("AV:N/AC:L/Au:N/C:C/I:C/A:C")).to be_nil
// 45:     end
// 46:
// 47:     it "returns nil for a vector missing required base metrics" do
// 48:       expect(described_class.base_score("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H")).to be_nil
// 49:     end
// 50:
// 51:     it "returns nil for a vector with an unknown metric value" do
// 52:       expect(described_class.base_score("CVSS:3.1/AV:X/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")).to be_nil
// 53:     end
// 54:
// 55:     it "returns nil for garbage input" do
// 56:       expect(described_class.base_score("")).to be_nil
// 57:       expect(described_class.base_score("INVALID-CVSS")).to be_nil
// 58:       expect(described_class.base_score("CVSS:3.1/")).to be_nil
// 59:     end
// 60:   end
// 61:
// 62:   describe ".severity" do
// 63:     # Vectors from brew-vulns test/brew/test_vulnerability.rb
// 64:     it "buckets a 9.8 vector as critical" do
// 65:       expect(described_class.severity("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")).to eq :critical
// 66:     end
// 67:
// 68:     it "buckets an 8.8 vector as high" do
// 69:       expect(described_class.severity("CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H")).to eq :high
// 70:     end
// 71:
// 72:     it "buckets a 5.5 vector as medium" do
// 73:       expect(described_class.severity("CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N")).to eq :medium
// 74:     end
// 75:
// 76:     it "buckets a 1.8 vector as low" do
// 77:       expect(described_class.severity("CVSS:3.1/AV:L/AC:H/PR:H/UI:R/S:U/C:L/I:N/A:N")).to eq :low
// 78:     end
// 79:
// 80:     it "returns nil for a zero-impact vector" do
// 81:       expect(described_class.severity("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")).to be_nil
// 82:     end
// 83:
// 84:     it "returns nil for an unsupported version" do
// 85:       expect(described_class.severity(
// 86:                "CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N",
// 87:              )).to be_nil
// 88:     end
// 89:
// 90:     it "returns nil for an unparseable vector" do
// 91:       expect(described_class.severity("INVALID-CVSS")).to be_nil
// 92:     end
// 93:   end
// 94: end
