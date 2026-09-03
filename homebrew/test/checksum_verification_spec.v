module test

import brew_runtime
import crypto.sha256

pub struct ChecksumFormulaFixture {
pub:
	url    string
	sha256 string
}

// Translated from Homebrew/brew `test/checksum_verification_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `formula(*args, **kwargs, &block)` at line 7.
pub fn ruby_checksum_verification_spec_l7_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	fixture_dir := if args.len > 0 { args[0].as_string() } else { 'test/support/fixtures' }
	checksum := if args.len > 1 { args[1].as_string() } else { '' }
	formula := checksum_formula(fixture_dir, checksum)
	return brew_runtime.structured_value('Formula', formula.url, {
		'url':    formula.url
		'sha256': formula.sha256
	})
}

// Ruby it `it "does not raise an error when the checksum matches" do` at line 16.
pub fn ruby_checksum_verification_spec_l16_d2_does(args ...brew_runtime.Value) brew_runtime.Value {
	contents := if args.len > 0 { args[0].as_string() } else { 'testball archive' }
	expected := if args.len > 1 { args[1].as_string() } else { sha256.hexhash(contents) }
	verify_formula_checksum(contents, expected) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(true)
}

// Ruby it `it "raises an error when the checksum doesn't match" do` at line 29.
pub fn ruby_checksum_verification_spec_l29_d3_raises(args ...brew_runtime.Value) brew_runtime.Value {
	contents := if args.len > 0 { args[0].as_string() } else { 'testball archive' }
	expected := if args.len > 1 {
		args[1].as_string()
	} else {
		'dcbf5f44743b74add648c7e35e414076632fa3b24463d68d1f6afc5be77024f8'
	}
	verify_formula_checksum(contents, expected) or {
		return brew_runtime.bool_value(err.msg().contains('ChecksumMismatchError'))
	}
	return brew_runtime.bool_value(false)
}

pub fn checksum_formula(fixture_dir string, checksum string) ChecksumFormulaFixture {
	return ChecksumFormulaFixture{
		url: 'file://${fixture_dir.trim_right('/')}/tarballs/testball-0.1.tbz'
		sha256: checksum
	}
}

pub fn verify_formula_checksum(contents string, expected string) ! {
	actual := sha256.hexhash(contents)
	if actual != expected {
		return error('ChecksumMismatchError: expected ${expected}, got ${actual}')
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5:
// 6: RSpec.describe Formula do
// 7:   def formula(*args, **kwargs, &block)
// 8:     super do
// 9:       T.bind(self, T.class_of(Formula))
// 10:       url "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz"
// 11:       instance_eval(&block) if block
// 12:     end
// 13:   end
// 14:
// 15:   describe "#brew" do
// 16:     it "does not raise an error when the checksum matches" do
// 17:       expect do
// 18:         f = formula do
// 19:           T.bind(self, T.class_of(Formula))
// 20:           sha256 TESTBALL_SHA256
// 21:         end
// 22:
// 23:         f.brew do
// 24:           # do nothing
// 25:         end
// 26:       end.not_to raise_error
// 27:     end
// 28:
// 29:     it "raises an error when the checksum doesn't match" do
// 30:       expect do
// 31:         f = formula do
// 32:           T.bind(self, T.class_of(Formula))
// 33:           sha256 "dcbf5f44743b74add648c7e35e414076632fa3b24463d68d1f6afc5be77024f8"
// 34:         end
// 35:
// 36:         f.brew do
// 37:           # do nothing
// 38:         end
// 39:       end.to raise_error(ChecksumMismatchError)
// 40:     end
// 41:   end
// 42: end
