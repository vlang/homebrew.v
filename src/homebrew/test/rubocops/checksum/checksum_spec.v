module checksum

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/checksum/checksum_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_checksum_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports an offense if a checksum is empty" do` at line 10.
pub fn ruby_checksum_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if a checksum is not 64 characters" do` at line 29.
pub fn ruby_checksum_spec_l29_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if a checksum contains invalid characters" do` at line 48.
pub fn ruby_checksum_spec_l48_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if a checksum is not 64 characters in a bottle block without cellar" do` at line 67.
pub fn ruby_checksum_spec_l67_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if a checksum is not 64 characters in a bottle block" do` at line 80.
pub fn ruby_checksum_spec_l80_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/checksum"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Checksum do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing spec checksums" do
// 10:     it "reports an offense if a checksum is empty" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           url 'https://brew.sh/foo-1.0.tgz'
// 14:           stable do
// 15:             url "https://github.com/foo-lang/foo-compiler/archive/0.18.0.tar.gz"
// 16:             sha256 ""
// 17:                    ^^ FormulaAudit/Checksum: `sha256` is empty
// 18:
// 19:             resource "foo-package" do
// 20:               url "https://github.com/foo-lang/foo-package/archive/0.18.0.tar.gz"
// 21:               sha256 ""
// 22:                      ^^ FormulaAudit/Checksum: `sha256` is empty
// 23:             end
// 24:           end
// 25:         end
// 26:       RUBY
// 27:     end
// 28:
// 29:     it "reports an offense if a checksum is not 64 characters" do
// 30:       expect_offense(<<~RUBY)
// 31:         class Foo < Formula
// 32:           url 'https://brew.sh/foo-1.0.tgz'
// 33:           stable do
// 34:             url "https://github.com/foo-lang/foo-compiler/archive/0.18.0.tar.gz"
// 35:             sha256 "5cf6e1ae0a645b426c0474cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9ad"
// 36:                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Checksum: `sha256` should be 64 characters
// 37:
// 38:             resource "foo-package" do
// 39:               url "https://github.com/foo-lang/foo-package/archive/0.18.0.tar.gz"
// 40:               sha256 "5cf6e1ae0a645b426c047aaa4cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9"
// 41:                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Checksum: `sha256` should be 64 characters
// 42:             end
// 43:           end
// 44:         end
// 45:       RUBY
// 46:     end
// 47:
// 48:     it "reports an offense if a checksum contains invalid characters" do
// 49:       expect_offense(<<~RUBY)
// 50:         class Foo < Formula
// 51:           url 'https://brew.sh/foo-1.0.tgz'
// 52:           stable do
// 53:             url "https://github.com/foo-lang/foo-compiler/archive/0.18.0.tar.gz"
// 54:             sha256 "5cf6e1ae0a645b426c0k7cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9a"
// 55:                                        ^ FormulaAudit/Checksum: `sha256` contains invalid characters
// 56:
// 57:             resource "foo-package" do
// 58:               url "https://github.com/foo-lang/foo-package/archive/0.18.0.tar.gz"
// 59:               sha256 "5cf6e1ae0a645b426x047aa4cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea9"
// 60:                                        ^ FormulaAudit/Checksum: `sha256` contains invalid characters
// 61:             end
// 62:           end
// 63:         end
// 64:       RUBY
// 65:     end
// 66:
// 67:     it "reports an offense if a checksum is not 64 characters in a bottle block without cellar" do
// 68:       expect_offense(<<~RUBY)
// 69:         class Foo < Formula
// 70:           url 'https://brew.sh/foo-1.0.tgz'
// 71:
// 72:           bottle do
// 73:             sha256 catalina: "5cf6e1ae0a645b426c0474cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9ad"
// 74:                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Checksum: `sha256` should be 64 characters
// 75:           end
// 76:         end
// 77:       RUBY
// 78:     end
// 79:
// 80:     it "reports an offense if a checksum is not 64 characters in a bottle block" do
// 81:       expect_offense(<<~RUBY)
// 82:         class Foo < Formula
// 83:           url 'https://brew.sh/foo-1.0.tgz'
// 84:
// 85:           bottle do
// 86:             sha256 cellar: :any, catalina: "5cf6e1ae0a645b426c0474cc7cd3f7d1605ffa1ac5756a39a8b2268ddc7ea0e9ad"
// 87:                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Checksum: `sha256` should be 64 characters
// 88:           end
// 89:         end
// 90:       RUBY
// 91:     end
// 92:   end
// 93: end
