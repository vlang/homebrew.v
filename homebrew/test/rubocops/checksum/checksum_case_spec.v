module checksum

import brew_runtime
import homebrew.rubocops as checksum_core

// Translated from Homebrew/brew `test/rubocops/checksum/checksum_case_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_checksum_case_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::ChecksumCase', 'FormulaAudit/ChecksumCase')
}

// Ruby it `it "reports an offense if a checksum contains uppercase letters" do` at line 10.
pub fn ruby_checksum_case_spec_l10_d2_reports() bool {
	source := 'sha256 "5cf6e1ae0A645b426c0a7cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9a"\nsha256 "5cf6e1Ae0a645b426b047aa4cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea9"'
	return checksum_core.audit_formula_checksum_case(source).len == 2
}

// Ruby it `it "reports and corrects an offense if a checksum outside a `stable` block contains uppercase letters" do` at line 29.
pub fn ruby_checksum_case_spec_l29_d3_reports() bool {
	source := 'sha256 "A4cc7cd3f7d1605ffa1ac5755cf6e1ae0a645b426b047a6a39a8b2268ddc7ea9"\nsha256 "5cf6e1ae0a645b426c0a7cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9a"'
	corrected := 'sha256 "a4cc7cd3f7d1605ffa1ac5755cf6e1ae0a645b426b047a6a39a8b2268ddc7ea9"\nsha256 "5cf6e1ae0a645b426c0a7cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9a"'
	return checksum_core.audit_formula_checksum_case(source).len == 1 && checksum_core.correct_formula_checksum_case(source) == corrected
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/checksum"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::ChecksumCase do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing spec checksums" do
// 10:     it "reports an offense if a checksum contains uppercase letters" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           url 'https://brew.sh/foo-1.0.tgz'
// 14:           stable do
// 15:             url "https://github.com/foo-lang/foo-compiler/archive/0.18.0.tar.gz"
// 16:             sha256 "5cf6e1ae0A645b426c0a7cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9a"
// 17:                              ^ FormulaAudit/ChecksumCase: `sha256` should be lowercase
// 18:
// 19:             resource "foo-package" do
// 20:               url "https://github.com/foo-lang/foo-package/archive/0.18.0.tar.gz"
// 21:               sha256 "5cf6e1Ae0a645b426b047aa4cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea9"
// 22:                             ^ FormulaAudit/ChecksumCase: `sha256` should be lowercase
// 23:             end
// 24:           end
// 25:         end
// 26:       RUBY
// 27:     end
// 28:
// 29:     it "reports and corrects an offense if a checksum outside a `stable` block contains uppercase letters" do
// 30:       expect_offense(<<~RUBY)
// 31:         class Foo < Formula
// 32:           url 'https://brew.sh/foo-1.0.tgz'
// 33:           resource "foo-outside" do
// 34:             url "https://github.com/foo-lang/foo-outside/archive/0.18.0.tar.gz"
// 35:             sha256 "A4cc7cd3f7d1605ffa1ac5755cf6e1ae0a645b426b047a6a39a8b2268ddc7ea9"
// 36:                     ^ FormulaAudit/ChecksumCase: `sha256` should be lowercase
// 37:           end
// 38:           stable do
// 39:             url "https://github.com/foo-lang/foo-compiler/archive/0.18.0.tar.gz"
// 40:             sha256 "5cf6e1ae0a645b426c0a7cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9a"
// 41:
// 42:             resource "foo-package" do
// 43:               url "https://github.com/foo-lang/foo-package/archive/0.18.0.tar.gz"
// 44:               sha256 "5cf6e1ae0a645b426b047aa4cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea9"
// 45:             end
// 46:           end
// 47:         end
// 48:       RUBY
// 49:
// 50:       expect_correction(<<~RUBY)
// 51:         class Foo < Formula
// 52:           url 'https://brew.sh/foo-1.0.tgz'
// 53:           resource "foo-outside" do
// 54:             url "https://github.com/foo-lang/foo-outside/archive/0.18.0.tar.gz"
// 55:             sha256 "a4cc7cd3f7d1605ffa1ac5755cf6e1ae0a645b426b047a6a39a8b2268ddc7ea9"
// 56:           end
// 57:           stable do
// 58:             url "https://github.com/foo-lang/foo-compiler/archive/0.18.0.tar.gz"
// 59:             sha256 "5cf6e1ae0a645b426c0a7cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9a"
// 60:
// 61:             resource "foo-package" do
// 62:               url "https://github.com/foo-lang/foo-package/archive/0.18.0.tar.gz"
// 63:               sha256 "5cf6e1ae0a645b426b047aa4cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea9"
// 64:             end
// 65:           end
// 66:         end
// 67:       RUBY
// 68:     end
// 69:   end
// 70: end
