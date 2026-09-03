module cask

import homebrew.rubocops.cask as url_core

// Translated from Homebrew/brew `test/rubocops/cask/url_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const url_spec_homebrew_path = '/homebrew-cask/Casks/f/foo.rb'
const url_spec_tap_path = '/homebrew-tap/Casks/f/foo.rb'

fn url_spec_source(body string) string {
	return 'cask "foo" do\n${body}\nend'
}

// Ruby it `it "allows regular `url` blocks in homebrew-cask" do` at line 7.
pub fn ruby_url_spec_l7_d1_allows() bool {
	source := url_spec_source('  url "https://example.com/download/foo-v1.2.0.dmg"')
	return url_core.audit_cask_url(source, url_spec_homebrew_path).len == 0
}

// Ruby it `it "does not allow `url do` blocks in homebrew-cask" do` at line 15.
pub fn ruby_url_spec_l15_d2_does() bool {
	source := url_spec_source('  url "https://example.com/download/foo-v1.2.0.dmg" do |url|\n    url\n  end')
	offenses := url_core.audit_cask_url(source, url_spec_homebrew_path)
	return offenses.len == 1 && offenses[0].kind == 'url_block' && offenses[0].message == url_core.cask_url_block_message && source[offenses[0].begin_pos..offenses[0].end_pos] == 'url "https://example.com/download/foo-v1.2.0.dmg" do |url|\n    url\n  end'
}

// Ruby it `it "allows regular `url` blocks in a non-homebrew-cask tap" do` at line 26.
pub fn ruby_url_spec_l26_d3_allows() bool {
	source := url_spec_source('  url "https://example.com/download/foo-v1.2.0.dmg"')
	return url_core.audit_cask_url(source, url_spec_tap_path).len == 0
}

// Ruby it `it "allows `url do` blocks in a non-homebrew-cask tap" do` at line 34.
pub fn ruby_url_spec_l34_d4_allows() bool {
	source := url_spec_source('  url "https://example.com/download/foo-v1.2.0.dmg" do |url|\n    url\n  end')
	return url_core.audit_cask_url(source, url_spec_tap_path).len == 0
}

// Ruby it `it "reports an offense for a keyword parameter on the same line as the URL" do` at line 44.
pub fn ruby_url_spec_l44_d5_reports() bool {
	source := url_spec_source('  url "https://example.com/download/foo-v1.2.0.dmg", header: "Accept: application/octet-stream"')
	expected := url_spec_source('  url "https://example.com/download/foo-v1.2.0.dmg",\n    header: "Accept: application/octet-stream"')
	offenses := url_core.audit_cask_url(source, '')
	return offenses.len == 1 && offenses[0].kind == 'keyword_line' && offenses[0].message == url_core.cask_url_keyword_message && url_core.correct_cask_url(source, '') == expected
}

// Ruby it `it "reports an offense for a `url` stanza with only keyword arguments" do` at line 60.
pub fn ruby_url_spec_l60_d6_reports() bool {
	source := url_spec_source('  url header: "Accept"')
	offenses := url_core.audit_cask_url(source, '')
	return offenses.len == 1 && offenses[0].kind == 'missing_argument' && offenses[0].message == url_core.cask_url_argument_message
}

// Ruby it `it "accepts a method call URL with a keyword parameter on a new indented line" do` at line 69.
pub fn ruby_url_spec_l69_d7_accepts() bool {
	source := url_spec_source('  version "1.2.0"\n  url Utils.download_url(version),\n    header: "Accept: application/octet-stream"')
	return url_core.audit_cask_url(source, '').len == 0
}

// Ruby it `it "reports an offense for a method call URL with a keyword parameter on the same line" do` at line 79.
pub fn ruby_url_spec_l79_d8_reports() bool {
	source := url_spec_source('  version "1.2.0"\n  url Utils.download_url(version), header: "Accept: application/octet-stream"')
	expected := url_spec_source('  version "1.2.0"\n  url Utils.download_url(version),\n    header: "Accept: application/octet-stream"')
	offenses := url_core.audit_cask_url(source, '')
	return offenses.len == 1 && offenses[0].kind == 'keyword_line' && url_core.correct_cask_url(source, '') == expected
}

// Ruby it `it "reports an offense for an http:// URL in homebrew-cask" do` at line 97.
pub fn ruby_url_spec_l97_d9_reports() bool {
	source := url_spec_source('  url "http://example.com/download/foo-v1.2.0.dmg"')
	offenses := url_core.audit_cask_url(source, url_spec_homebrew_path)
	return offenses.len == 1 && offenses[0].kind == 'http' && offenses[0].message == url_core.cask_url_http_message
}

// Ruby it `it "autocorrects http:// to https:// in homebrew-cask" do` at line 106.
pub fn ruby_url_spec_l106_d10_autocorrects() bool {
	source := url_spec_source('  url "http://example.com/download/foo-v1.2.0.dmg"')
	expected := url_spec_source('  url "https://example.com/download/foo-v1.2.0.dmg"')
	return url_core.correct_cask_url(source, url_spec_homebrew_path) == expected
}

// Ruby it `it "reports no offense for http:// URL outside homebrew-cask" do` at line 121.
pub fn ruby_url_spec_l121_d11_reports() bool {
	source := url_spec_source('  url "http://example.com/download/foo-v1.2.0.dmg"')
	return url_core.audit_cask_url(source, '/homebrew-mytap/Casks/f/foo.rb').len == 0
}

// Ruby it `it "reports an offense for a non-string-literal URL in homebrew-cask" do` at line 129.
pub fn ruby_url_spec_l129_d12_reports() bool {
	source := url_spec_source('  version "1.2.3"\n  url Utils.download_url(version)')
	offenses := url_core.audit_cask_url(source, url_spec_homebrew_path)
	return offenses.len == 1 && offenses[0].kind == 'string_literal' && offenses[0].message == url_core.cask_url_literal_message && source[offenses[0].begin_pos..offenses[0].end_pos] == 'Utils.download_url(version)'
}

// Ruby it `it "accepts an interpolated string URL in homebrew-cask" do` at line 139.
pub fn ruby_url_spec_l139_d13_accepts() bool {
	source := url_spec_source('  version "1.2.3"\n  url "https://example.com/download/foo-v#{version}.dmg"')
	return url_core.audit_cask_url(source, url_spec_homebrew_path).len == 0
}

// Ruby it `it "accepts a non-string-literal URL outside homebrew-cask" do` at line 148.
pub fn ruby_url_spec_l148_d14_accepts() bool {
	source := url_spec_source('  version "1.2.3"\n  url Utils.download_url(version)')
	return url_core.audit_cask_url(source, url_spec_tap_path).len == 0
}

// Ruby it `it "reports no offense for an https:// URL" do` at line 157.
pub fn ruby_url_spec_l157_d15_reports() bool {
	source := url_spec_source('  url "https://example.com/download/foo-v1.2.0.dmg"')
	return url_core.audit_cask_url(source, '').len == 0
}

// Ruby it `it "reports no offense for deprecated casks" do` at line 165.
pub fn ruby_url_spec_l165_d16_reports() bool {
	source := url_spec_source('  url "http://example.com/download/foo-v1.2.0.dmg"\n  deprecate! date: "2024-01-01", because: :unmaintained')
	return url_core.audit_cask_url(source, url_spec_homebrew_path).len == 0
}

// Ruby it `it "reports no offense for disabled casks" do` at line 174.
pub fn ruby_url_spec_l174_d17_reports() bool {
	source := url_spec_source('  url "http://example.com/download/foo-v1.2.0.dmg"\n  disable! date: "2024-01-01", because: :unmaintained')
	return url_core.audit_cask_url(source, url_spec_homebrew_path).len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::Url, :config do
// 7:   it "allows regular `url` blocks in homebrew-cask" do
// 8:     expect_no_offenses <<~CASK, "/homebrew-cask/Casks/f/foo.rb"
// 9:       cask "foo" do
// 10:         url "https://example.com/download/foo-v1.2.0.dmg"
// 11:       end
// 12:     CASK
// 13:   end
// 14:
// 15:   it "does not allow `url do` blocks in homebrew-cask" do
// 16:     expect_offense <<~CASK, "/homebrew-cask/Casks/f/foo.rb"
// 17:       cask "foo" do
// 18:         url "https://example.com/download/foo-v1.2.0.dmg" do |url|
// 19:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `url "..." do` blocks in Homebrew/homebrew-cask.
// 20:           url
// 21:         end
// 22:       end
// 23:     CASK
// 24:   end
// 25:
// 26:   it "allows regular `url` blocks in a non-homebrew-cask tap" do
// 27:     expect_no_offenses <<~CASK, "/homebrew-tap/Casks/f/foo.rb"
// 28:       cask "foo" do
// 29:         url "https://example.com/download/foo-v1.2.0.dmg"
// 30:       end
// 31:     CASK
// 32:   end
// 33:
// 34:   it "allows `url do` blocks in a non-homebrew-cask tap" do
// 35:     expect_no_offenses <<~CASK, "/homebrew-tap/Casks/f/foo.rb"
// 36:       cask "foo" do
// 37:         url "https://example.com/download/foo-v1.2.0.dmg" do |url|
// 38:           url
// 39:         end
// 40:       end
// 41:     CASK
// 42:   end
// 43:
// 44:   it "reports an offense for a keyword parameter on the same line as the URL" do
// 45:     expect_offense <<~CASK
// 46:       cask "foo" do
// 47:         url "https://example.com/download/foo-v1.2.0.dmg", header: "Accept: application/octet-stream"
// 48:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Keyword URL parameter should be on a new indented line.
// 49:       end
// 50:     CASK
// 51:
// 52:     expect_correction <<~CASK
// 53:       cask "foo" do
// 54:         url "https://example.com/download/foo-v1.2.0.dmg",
// 55:             header: "Accept: application/octet-stream"
// 56:       end
// 57:     CASK
// 58:   end
// 59:
// 60:   it "reports an offense for a `url` stanza with only keyword arguments" do
// 61:     expect_offense <<~CASK
// 62:       cask "foo" do
// 63:         url header: "Accept"
// 64:         ^^^^^^^^^^^^^^^^^^^^ The `url` stanza requires a URL argument.
// 65:       end
// 66:     CASK
// 67:   end
// 68:
// 69:   it "accepts a method call URL with a keyword parameter on a new indented line" do
// 70:     expect_no_offenses <<~CASK
// 71:       cask "foo" do
// 72:         version "1.2.0"
// 73:         url Utils.download_url(version),
// 74:             header: "Accept: application/octet-stream"
// 75:       end
// 76:     CASK
// 77:   end
// 78:
// 79:   it "reports an offense for a method call URL with a keyword parameter on the same line" do
// 80:     expect_offense <<~CASK
// 81:       cask "foo" do
// 82:         version "1.2.0"
// 83:         url Utils.download_url(version), header: "Accept: application/octet-stream"
// 84:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Keyword URL parameter should be on a new indented line.
// 85:       end
// 86:     CASK
// 87:
// 88:     expect_correction <<~CASK
// 89:       cask "foo" do
// 90:         version "1.2.0"
// 91:         url Utils.download_url(version),
// 92:             header: "Accept: application/octet-stream"
// 93:       end
// 94:     CASK
// 95:   end
// 96:
// 97:   it "reports an offense for an http:// URL in homebrew-cask" do
// 98:     expect_offense <<~CASK, "/homebrew-cask/Casks/f/foo.rb"
// 99:       cask "foo" do
// 100:         url "http://example.com/download/foo-v1.2.0.dmg"
// 101:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Casks in homebrew/cask should not use http:// URLs
// 102:       end
// 103:     CASK
// 104:   end
// 105:
// 106:   it "autocorrects http:// to https:// in homebrew-cask" do
// 107:     expect_offense <<~CASK, "/homebrew-cask/Casks/f/foo.rb"
// 108:       cask "foo" do
// 109:         url "http://example.com/download/foo-v1.2.0.dmg"
// 110:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Casks in homebrew/cask should not use http:// URLs
// 111:       end
// 112:     CASK
// 113:
// 114:     expect_correction <<~CASK
// 115:       cask "foo" do
// 116:         url "https://example.com/download/foo-v1.2.0.dmg"
// 117:       end
// 118:     CASK
// 119:   end
// 120:
// 121:   it "reports no offense for http:// URL outside homebrew-cask" do
// 122:     expect_no_offenses <<~CASK, "/homebrew-mytap/Casks/f/foo.rb"
// 123:       cask "foo" do
// 124:         url "http://example.com/download/foo-v1.2.0.dmg"
// 125:       end
// 126:     CASK
// 127:   end
// 128:
// 129:   it "reports an offense for a non-string-literal URL in homebrew-cask" do
// 130:     expect_offense <<~CASK, "/homebrew-cask/Casks/f/foo.rb"
// 131:       cask "foo" do
// 132:         version "1.2.3"
// 133:         url Utils.download_url(version)
// 134:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Casks in homebrew/cask should use string literal URLs.
// 135:       end
// 136:     CASK
// 137:   end
// 138:
// 139:   it "accepts an interpolated string URL in homebrew-cask" do
// 140:     expect_no_offenses <<~CASK, "/homebrew-cask/Casks/f/foo.rb"
// 141:       cask "foo" do
// 142:         version "1.2.3"
// 143:         url "https://example.com/download/foo-v\#{version}.dmg"
// 144:       end
// 145:     CASK
// 146:   end
// 147:
// 148:   it "accepts a non-string-literal URL outside homebrew-cask" do
// 149:     expect_no_offenses <<~CASK, "/homebrew-tap/Casks/f/foo.rb"
// 150:       cask "foo" do
// 151:         version "1.2.3"
// 152:         url Utils.download_url(version)
// 153:       end
// 154:     CASK
// 155:   end
// 156:
// 157:   it "reports no offense for an https:// URL" do
// 158:     expect_no_offenses <<~CASK
// 159:       cask "foo" do
// 160:         url "https://example.com/download/foo-v1.2.0.dmg"
// 161:       end
// 162:     CASK
// 163:   end
// 164:
// 165:   it "reports no offense for deprecated casks" do
// 166:     expect_no_offenses <<~CASK, "/homebrew-cask/Casks/f/foo.rb"
// 167:       cask "foo" do
// 168:         url "http://example.com/download/foo-v1.2.0.dmg"
// 169:         deprecate! date: "2024-01-01", because: :unmaintained
// 170:       end
// 171:     CASK
// 172:   end
// 173:
// 174:   it "reports no offense for disabled casks" do
// 175:     expect_no_offenses <<~CASK, "/homebrew-cask/Casks/f/foo.rb"
// 176:       cask "foo" do
// 177:         url "http://example.com/download/foo-v1.2.0.dmg"
// 178:         disable! date: "2024-01-01", because: :unmaintained
// 179:       end
// 180:     CASK
// 181:   end
// 182: end
