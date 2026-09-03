module livecheck

import homebrew.livecheck as livecheck_core

// Translated from Homebrew/brew `test/livecheck/livecheck_version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:formula) { instance_double(Formula) }` at line 7.
pub fn ruby_livecheck_version_spec_l7_d1_formula() livecheck_core.LivecheckVersionPackageKind {
	return .formula
}

// Ruby let `let(:cask) { instance_double(Cask::Cask) }` at line 8.
pub fn ruby_livecheck_version_spec_l8_d2_cask() livecheck_core.LivecheckVersionPackageKind {
	return .cask
}

// Ruby let `let(:resource) { instance_double(Resource) }` at line 9.
pub fn ruby_livecheck_version_spec_l9_d3_resource() livecheck_core.LivecheckVersionPackageKind {
	return .resource
}

// Ruby specify `specify "::create" do` at line 21.
pub fn ruby_livecheck_version_spec_l21_d4_create() !bool {
	cases := ['1.1.6', '2.19.0,1.8.0', '0.17.0,20210111183933,226']
	for value in cases {
		version := livecheck_core.new_livecheck_version_component(value)!
		for package_kind in [ruby_livecheck_version_spec_l7_d1_formula(),
			ruby_livecheck_version_spec_l9_d3_resource()] {
			created := livecheck_core.ruby_livecheck_version_l13_d1_self_create(package_kind, version)!
			if created.versions.map(it.value) != [value] {
				return false
			}
		}
	}
	cask_expectations := {
		'1.1.6':                     ['1.1.6']
		'2.19.0,1.8.0':              ['2.19.0', '1.8.0']
		'0.17.0,20210111183933,226': ['0.17.0', '20210111183933', '226']
	}
	for value, expected in cask_expectations {
		created := livecheck_core.ruby_livecheck_version_l13_d1_self_create(ruby_livecheck_version_spec_l8_d2_cask(), livecheck_core.new_livecheck_version_component(value)!)!
		if created.versions.map(it.value) != expected {
			return false
		}
	}
	return true
}

pub struct LivecheckVersionSpecBoundary {
pub:
	line   int
	passed bool
}

pub fn livecheck_version_spec_all_boundaries() ![]LivecheckVersionSpecBoundary {
	return [
		LivecheckVersionSpecBoundary{ line: 7, passed: ruby_livecheck_version_spec_l7_d1_formula() == .formula },
		LivecheckVersionSpecBoundary{ line: 8, passed: ruby_livecheck_version_spec_l8_d2_cask() == .cask },
		LivecheckVersionSpecBoundary{ line: 9, passed: ruby_livecheck_version_spec_l9_d3_resource() == .resource },
		LivecheckVersionSpecBoundary{ line: 21, passed: ruby_livecheck_version_spec_l21_d4_create()! },
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/livecheck_version"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::LivecheckVersion do
// 7:   let(:formula) { instance_double(Formula) }
// 8:   let(:cask) { instance_double(Cask::Cask) }
// 9:   let(:resource) { instance_double(Resource) }
// 10:
// 11:   before do
// 12:     # Case statements use #=== for case equality purposes
// 13:     allow(Formula).to receive(:===).and_call_original
// 14:     allow(Formula).to receive(:===).with(formula).and_return(true)
// 15:     allow(Cask::Cask).to receive(:===).and_call_original
// 16:     allow(Cask::Cask).to receive(:===).with(cask).and_return(true)
// 17:     allow(Resource).to receive(:===).and_call_original
// 18:     allow(Resource).to receive(:===).with(resource).and_return(true)
// 19:   end
// 20:
// 21:   specify "::create" do
// 22:     expect(described_class.create(formula, Version.new("1.1.6")).versions).to eq ["1.1.6"]
// 23:     expect(described_class.create(formula,
// 24:                                   Version.new("2.19.0,1.8.0")).versions).to eq ["2.19.0,1.8.0"]
// 25:     expect(described_class.create(formula, Version.new("0.17.0,20210111183933,226")).versions)
// 26:       .to eq ["0.17.0,20210111183933,226"]
// 27:
// 28:     expect(described_class.create(cask, Version.new("1.1.6")).versions).to eq ["1.1.6"]
// 29:     expect(described_class.create(cask,
// 30:                                   Version.new("2.19.0,1.8.0")).versions).to eq ["2.19.0",
// 31:                                                                                 "1.8.0"]
// 32:     expect(described_class.create(cask, Version.new("0.17.0,20210111183933,226")).versions)
// 33:       .to eq ["0.17.0", "20210111183933", "226"]
// 34:
// 35:     expect(described_class.create(resource, Version.new("1.1.6")).versions).to eq ["1.1.6"]
// 36:     expect(described_class.create(resource,
// 37:                                   Version.new("2.19.0,1.8.0")).versions).to eq ["2.19.0,1.8.0"]
// 38:     expect(described_class.create(resource, Version.new("0.17.0,20210111183933,226")).versions)
// 39:       .to eq ["0.17.0,20210111183933,226"]
// 40:   end
// 41: end
