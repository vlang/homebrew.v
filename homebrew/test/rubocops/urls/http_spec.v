module urls

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/urls/http_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_http_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports an offense for http:// URLs in homebrew-core" do` at line 10.
pub fn ruby_http_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "autocorrects http:// to https:// in homebrew-core" do` at line 20.
pub fn ruby_http_spec_l20_d3_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "reports no offense for http:// URLs outside homebrew-core" do` at line 37.
pub fn ruby_http_spec_l37_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offense for http:// mirror URLs (mirrors may use HTTP for bootstrapping)" do` at line 46.
pub fn ruby_http_spec_l46_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offense for deprecated formulae" do` at line 56.
pub fn ruby_http_spec_l56_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offense for disabled formulae" do` at line 66.
pub fn ruby_http_spec_l66_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offense for http:// livecheck URLs" do` at line 76.
pub fn ruby_http_spec_l76_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offense for a livecheck URL symbol" do` at line 99.
pub fn ruby_http_spec_l99_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offense when livecheck has no URL" do` at line 112.
pub fn ruby_http_spec_l112_d10_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offense when livecheck has a `url` call with no argument" do` at line 126.
pub fn ruby_http_spec_l126_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports offense for non-livecheck http:// URLs even when livecheck has http://" do` at line 140.
pub fn ruby_http_spec_l140_d12_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/urls"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::HttpUrls do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing HTTP URLs" do
// 10:     it "reports an offense for http:// URLs in homebrew-core" do
// 11:       expect_offense(<<~RUBY, "/homebrew-core/")
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url "http://example.com/foo-1.0.tar.gz"
// 15:               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/HttpUrls: Formulae in homebrew/core should not use http:// URLs
// 16:         end
// 17:       RUBY
// 18:     end
// 19:
// 20:     it "autocorrects http:// to https:// in homebrew-core" do
// 21:       expect_offense(<<~RUBY, "/homebrew-core/")
// 22:         class Foo < Formula
// 23:           desc "foo"
// 24:           url "http://example.com/foo-1.0.tar.gz"
// 25:               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/HttpUrls: Formulae in homebrew/core should not use http:// URLs
// 26:         end
// 27:       RUBY
// 28:
// 29:       expect_correction(<<~RUBY)
// 30:         class Foo < Formula
// 31:           desc "foo"
// 32:           url "https://example.com/foo-1.0.tar.gz"
// 33:         end
// 34:       RUBY
// 35:     end
// 36:
// 37:     it "reports no offense for http:// URLs outside homebrew-core" do
// 38:       expect_no_offenses(<<~RUBY, "/homebrew-mytap/")
// 39:         class Foo < Formula
// 40:           desc "foo"
// 41:           url "http://example.com/foo-1.0.tar.gz"
// 42:         end
// 43:       RUBY
// 44:     end
// 45:
// 46:     it "reports no offense for http:// mirror URLs (mirrors may use HTTP for bootstrapping)" do
// 47:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 48:         class Foo < Formula
// 49:           desc "foo"
// 50:           url "https://example.com/foo-1.0.tar.gz"
// 51:           mirror "http://mirror.example.com/foo-1.0.tar.gz"
// 52:         end
// 53:       RUBY
// 54:     end
// 55:
// 56:     it "reports no offense for deprecated formulae" do
// 57:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 58:         class Foo < Formula
// 59:           desc "foo"
// 60:           url "http://example.com/foo-1.0.tar.gz"
// 61:           deprecate! date: "2024-01-01", because: :unmaintained
// 62:         end
// 63:       RUBY
// 64:     end
// 65:
// 66:     it "reports no offense for disabled formulae" do
// 67:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 68:         class Foo < Formula
// 69:           desc "foo"
// 70:           url "http://example.com/foo-1.0.tar.gz"
// 71:           disable! date: "2024-01-01", because: :unmaintained
// 72:         end
// 73:       RUBY
// 74:     end
// 75:
// 76:     it "reports no offense for http:// livecheck URLs" do
// 77:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 78:         class Foo < Formula
// 79:           desc "foo"
// 80:           url "https://example.com/foo-1.0.tar.gz"
// 81:
// 82:           livecheck do
// 83:             url "http://example.com/releases"
// 84:             regex(/foo[._-]v?(\d+(?:.\d+)+).t/i)
// 85:           end
// 86:
// 87:           resource "foo" do
// 88:             url "https://example.com/foo-resource-1.0.tar.gz"
// 89:
// 90:             livecheck do
// 91:               url "http://example.com/resource-releases"
// 92:               regex(/foo-resource[._-]v?(\d+(?:.\d+)+).t/i)
// 93:             end
// 94:           end
// 95:         end
// 96:       RUBY
// 97:     end
// 98:
// 99:     it "reports no offense for a livecheck URL symbol" do
// 100:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 101:         class Foo < Formula
// 102:           desc "foo"
// 103:           url "https://example.com/foo-1.0.tar.gz"
// 104:
// 105:           livecheck do
// 106:             url :stable
// 107:           end
// 108:         end
// 109:       RUBY
// 110:     end
// 111:
// 112:     it "reports no offense when livecheck has no URL" do
// 113:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 114:         class Foo < Formula
// 115:           desc "foo"
// 116:           url "https://example.com/foo-1.0.tar.gz"
// 117:
// 118:           # No URL is present when `skip` is used.
// 119:           livecheck do
// 120:             skip "No version information available"
// 121:           end
// 122:         end
// 123:       RUBY
// 124:     end
// 125:
// 126:     it "reports no offense when livecheck has a `url` call with no argument" do
// 127:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 128:         class Foo < Formula
// 129:           desc "foo"
// 130:           url "https://example.com/foo-1.0.tar.gz"
// 131:
// 132:           # This shouldn't ever happen but this is simply to exercise a guard.
// 133:           livecheck do
// 134:             url
// 135:           end
// 136:         end
// 137:       RUBY
// 138:     end
// 139:
// 140:     it "reports offense for non-livecheck http:// URLs even when livecheck has http://" do
// 141:       expect_offense(<<~RUBY, "/homebrew-core/")
// 142:         class Foo < Formula
// 143:           desc "foo"
// 144:           url "http://example.com/foo-1.0.tar.gz"
// 145:               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/HttpUrls: Formulae in homebrew/core should not use http:// URLs
// 146:
// 147:           livecheck do
// 148:             url "http://example.com/releases"
// 149:             regex(/foo[._-]v?(\d+(?:.\d+)+).t/i)
// 150:           end
// 151:         end
// 152:       RUBY
// 153:     end
// 154:   end
// 155: end
