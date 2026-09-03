module rubocops

import homebrew.rubocops as no_base64_core

// Translated from Homebrew/brew `test/rubocops/no_base64_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers an offense and removes `require \"base64\"`" do` at line 7.
pub fn ruby_no_base64_spec_l7_d1_registers() bool {
	source := 'require "base64"\nrequire "json"\n'
	offenses := no_base64_core.audit_no_base64(source)
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == 16 && offenses[0].message == no_base64_core.no_base64_message && no_base64_core.correct_no_base64(source) == 'require "json"\n'
}

// Ruby it `it "registers an offense and removes `Kernel.require \"base64\"`" do` at line 19.
pub fn ruby_no_base64_spec_l19_d2_registers() bool {
	source := 'Kernel.require "base64"\nrequire "json"\n'
	offenses := no_base64_core.audit_no_base64(source)
	return offenses.len == 1 && source[offenses[0].begin_pos..offenses[0].end_pos] == 'Kernel.require "base64"' && no_base64_core.correct_no_base64(source) == 'require "json"\n'
}

// Ruby it `it "registers an offense and corrects `Base64.decode64`" do` at line 31.
pub fn ruby_no_base64_spec_l31_d3_registers() bool {
	source := 'Base64.decode64(foo)'
	offenses := no_base64_core.audit_no_base64(source)
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == source.len && no_base64_core.correct_no_base64(source) == 'foo.unpack1("m")'
}

// Ruby it `it "registers an offense and corrects `Base64.strict_decode64`" do` at line 42.
pub fn ruby_no_base64_spec_l42_d4_registers() bool {
	source := 'Base64.strict_decode64("aGVsbG8=")'
	offenses := no_base64_core.audit_no_base64(source)
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == source.len && no_base64_core.correct_no_base64(source) == '"aGVsbG8=".unpack1("m0")'
}

// Ruby it `it "registers an offense and corrects `Base64.encode64`" do` at line 53.
pub fn ruby_no_base64_spec_l53_d5_registers() bool {
	source := 'Base64.encode64(file.read)'
	offenses := no_base64_core.audit_no_base64(source)
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == source.len && no_base64_core.correct_no_base64(source) == '[file.read].pack("m")'
}

// Ruby it `it "registers an offense and corrects `Base64.strict_encode64`" do` at line 64.
pub fn ruby_no_base64_spec_l64_d6_registers() bool {
	source := 'Base64.strict_encode64("hello" * count)'
	offenses := no_base64_core.audit_no_base64(source)
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == source.len && no_base64_core.correct_no_base64(source) == '["hello" * count].pack("m0")'
}

// Ruby it `it "registers an offense and corrects `::Base64` calls" do` at line 75.
pub fn ruby_no_base64_spec_l75_d7_registers() bool {
	source := '::Base64.decode64(foo)'
	offenses := no_base64_core.audit_no_base64(source)
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == source.len && no_base64_core.correct_no_base64(source) == 'foo.unpack1("m")'
}

// Ruby it `it "registers an offense without correction for other `Base64` methods" do` at line 86.
pub fn ruby_no_base64_spec_l86_d8_registers() bool {
	source := 'Base64.urlsafe_decode64(foo)'
	offenses := no_base64_core.audit_no_base64(source)
	return offenses.len == 1 && !offenses[0].correctable && no_base64_core.correct_no_base64(source) == source
}

// Ruby it `it "registers an offense without correction for a decode of a compound expression" do` at line 95.
pub fn ruby_no_base64_spec_l95_d9_registers() bool {
	source := 'Base64.decode64(foo + bar)'
	offenses := no_base64_core.audit_no_base64(source)
	return offenses.len == 1 && !offenses[0].correctable && no_base64_core.correct_no_base64(source) == source
}

// Ruby it `it "registers an offense without correction for a bare `Base64` reference" do` at line 104.
pub fn ruby_no_base64_spec_l104_d10_registers() bool {
	source := 'encoder = Base64'
	offenses := no_base64_core.audit_no_base64(source)
	return offenses.len == 1 && source[offenses[0].begin_pos..offenses[0].end_pos] == 'Base64' && !offenses[0].correctable && no_base64_core.correct_no_base64(source) == source
}

// Ruby it `it "does not register an offense for a formula class named `Base64`" do` at line 113.
pub fn ruby_no_base64_spec_l113_d11_does() bool {
	source := 'class Base64 < Formula\n  desc "Encode and decode base64 files"\nend\n'
	return no_base64_core.audit_no_base64(source).len == 0
}

// Ruby it `it "does not register an offense for namespaced `Base64` constants" do` at line 121.
pub fn ruby_no_base64_spec_l121_d12_does() bool {
	return no_base64_core.audit_no_base64('Foo::Base64.decode64(foo)').len == 0
}

// Ruby it `it "does not register an offense for other requires" do` at line 127.
pub fn ruby_no_base64_spec_l127_d13_does() bool {
	return no_base64_core.audit_no_base64('require "json"').len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/no_base64"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::NoBase64, :config do
// 7:   it "registers an offense and removes `require \"base64\"`" do
// 8:     expect_offense(<<~RUBY)
// 9:       require "base64"
// 10:       ^^^^^^^^^^^^^^^^ Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.
// 11:       require "json"
// 12:     RUBY
// 13:
// 14:     expect_correction(<<~RUBY)
// 15:       require "json"
// 16:     RUBY
// 17:   end
// 18:
// 19:   it "registers an offense and removes `Kernel.require \"base64\"`" do
// 20:     expect_offense(<<~RUBY)
// 21:       Kernel.require "base64"
// 22:       ^^^^^^^^^^^^^^^^^^^^^^^ Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.
// 23:       require "json"
// 24:     RUBY
// 25:
// 26:     expect_correction(<<~RUBY)
// 27:       require "json"
// 28:     RUBY
// 29:   end
// 30:
// 31:   it "registers an offense and corrects `Base64.decode64`" do
// 32:     expect_offense(<<~RUBY)
// 33:       Base64.decode64(foo)
// 34:       ^^^^^^^^^^^^^^^^^^^^ Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.
// 35:     RUBY
// 36:
// 37:     expect_correction(<<~RUBY)
// 38:       foo.unpack1("m")
// 39:     RUBY
// 40:   end
// 41:
// 42:   it "registers an offense and corrects `Base64.strict_decode64`" do
// 43:     expect_offense(<<~RUBY)
// 44:       Base64.strict_decode64("aGVsbG8=")
// 45:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.
// 46:     RUBY
// 47:
// 48:     expect_correction(<<~RUBY)
// 49:       "aGVsbG8=".unpack1("m0")
// 50:     RUBY
// 51:   end
// 52:
// 53:   it "registers an offense and corrects `Base64.encode64`" do
// 54:     expect_offense(<<~RUBY)
// 55:       Base64.encode64(file.read)
// 56:       ^^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.
// 57:     RUBY
// 58:
// 59:     expect_correction(<<~RUBY)
// 60:       [file.read].pack("m")
// 61:     RUBY
// 62:   end
// 63:
// 64:   it "registers an offense and corrects `Base64.strict_encode64`" do
// 65:     expect_offense(<<~RUBY)
// 66:       Base64.strict_encode64("hello" * count)
// 67:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.
// 68:     RUBY
// 69:
// 70:     expect_correction(<<~RUBY)
// 71:       ["hello" * count].pack("m0")
// 72:     RUBY
// 73:   end
// 74:
// 75:   it "registers an offense and corrects `::Base64` calls" do
// 76:     expect_offense(<<~RUBY)
// 77:       ::Base64.decode64(foo)
// 78:       ^^^^^^^^^^^^^^^^^^^^^^ Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.
// 79:     RUBY
// 80:
// 81:     expect_correction(<<~RUBY)
// 82:       foo.unpack1("m")
// 83:     RUBY
// 84:   end
// 85:
// 86:   it "registers an offense without correction for other `Base64` methods" do
// 87:     expect_offense(<<~RUBY)
// 88:       Base64.urlsafe_decode64(foo)
// 89:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.
// 90:     RUBY
// 91:
// 92:     expect_no_corrections
// 93:   end
// 94:
// 95:   it "registers an offense without correction for a decode of a compound expression" do
// 96:     expect_offense(<<~RUBY)
// 97:       Base64.decode64(foo + bar)
// 98:       ^^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.
// 99:     RUBY
// 100:
// 101:     expect_no_corrections
// 102:   end
// 103:
// 104:   it "registers an offense without correction for a bare `Base64` reference" do
// 105:     expect_offense(<<~RUBY)
// 106:       encoder = Base64
// 107:                 ^^^^^^ Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.
// 108:     RUBY
// 109:
// 110:     expect_no_corrections
// 111:   end
// 112:
// 113:   it "does not register an offense for a formula class named `Base64`" do
// 114:     expect_no_offenses(<<~RUBY)
// 115:       class Base64 < Formula
// 116:         desc "Encode and decode base64 files"
// 117:       end
// 118:     RUBY
// 119:   end
// 120:
// 121:   it "does not register an offense for namespaced `Base64` constants" do
// 122:     expect_no_offenses(<<~RUBY)
// 123:       Foo::Base64.decode64(foo)
// 124:     RUBY
// 125:   end
// 126:
// 127:   it "does not register an offense for other requires" do
// 128:     expect_no_offenses(<<~RUBY)
// 129:       require "json"
// 130:     RUBY
// 131:   end
// 132: end
