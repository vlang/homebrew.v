module rubocops

import ruby
import homebrew.rubocops as zero_zero_zero_zero_core

// Translated from Homebrew/brew `test/rubocops/zero_zero_zero_zero_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_zero_zero_zero_zero_spec_l7_d1_cop() ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::ZeroZeroZeroZero', 'ZeroZeroZeroZero')
}

// Ruby it `it "reports no offenses when 0.0.0.0 is used inside test do blocks" do` at line 9.
pub fn ruby_zero_zero_zero_zero_spec_l9_d2_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n  desc "A test formula"\n\n  test do\n    system "echo", "0.0.0.0"\n  end\nend\n'
	return zero_zero_zero_zero_core.audit_zero_zero_zero_zero(source, 'homebrew-core').len == 0
}

// Ruby it `it "reports no offenses for valid IP ranges like 10.0.0.0" do` at line 22.
pub fn ruby_zero_zero_zero_zero_spec_l22_d3_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n  desc "A test formula"\n\n  def install\n    system "echo", "10.0.0.0"\n  end\nend\n'
	return zero_zero_zero_zero_core.audit_zero_zero_zero_zero(source, 'homebrew-core').len == 0
}

// Ruby method `install` at line 28.
pub fn ruby_zero_zero_zero_zero_spec_l28_d4_install() string {
	return 'system "echo", "10.0.0.0"'
}

// Ruby it `it "reports no offenses for IP range notation like 0.0.0.0-255.255.255.255" do` at line 35.
pub fn ruby_zero_zero_zero_zero_spec_l35_d5_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n  desc "A test formula"\n\n  def install\n    system "echo", "0.0.0.0-255.255.255.255"\n  end\nend\n'
	return zero_zero_zero_zero_core.audit_zero_zero_zero_zero(source, 'homebrew-core').len == 0
}

// Ruby method `install` at line 41.
pub fn ruby_zero_zero_zero_zero_spec_l41_d6_install() string {
	return 'system "echo", "0.0.0.0-255.255.255.255"'
}

// Ruby it `it "reports no offenses for private IP ranges" do` at line 48.
pub fn ruby_zero_zero_zero_zero_spec_l48_d7_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n  desc "A test formula"\n\n  def install\n    system "echo", "192.168.1.1"\n    system "echo", "172.16.0.1"\n    system "echo", "10.0.0.1"\n  end\nend\n'
	return zero_zero_zero_zero_core.audit_zero_zero_zero_zero(source, 'homebrew-core').len == 0
}

// Ruby method `install` at line 54.
pub fn ruby_zero_zero_zero_zero_spec_l54_d8_install() []string {
	return ['system "echo", "192.168.1.1"', 'system "echo", "172.16.0.1"', 'system "echo", "10.0.0.1"']
}

// Ruby it `it "reports no offenses when outside of homebrew-core" do` at line 63.
pub fn ruby_zero_zero_zero_zero_spec_l63_d9_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n  desc "A test formula"\n\n  service do\n    run [bin/"foo", "--host", "0.0.0.0"]\n  end\nend\n'
	return zero_zero_zero_zero_core.audit_zero_zero_zero_zero(source, '').len == 0
}

// Ruby it `it "reports offenses when 0.0.0.0 is used in service blocks" do` at line 76.
pub fn ruby_zero_zero_zero_zero_spec_l76_d10_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n  desc "A test formula"\n\n  service do\n    run [bin/"foo", "--host", "0.0.0.0"]\n  end\nend\n'
	offenses := zero_zero_zero_zero_core.audit_zero_zero_zero_zero(source, 'homebrew-core')
	return offenses.len == 1 && offenses[0].content == '0.0.0.0' && offenses[0].end_pos - offenses[0].begin_pos == 9 && offenses[0].message == zero_zero_zero_zero_core.zero_zero_zero_zero_message
}

// Ruby it `it "reports offenses when 0.0.0.0 is used outside of test do blocks" do` at line 90.
pub fn ruby_zero_zero_zero_zero_spec_l90_d11_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n  desc "A test formula"\n\n  def install\n    system "echo", "0.0.0.0"\n  end\nend\n'
	offenses := zero_zero_zero_zero_core.audit_zero_zero_zero_zero(source, 'homebrew-core')
	return offenses.len == 1 && offenses[0].content == '0.0.0.0' && offenses[0].end_pos - offenses[0].begin_pos == 9
}

// Ruby method `install` at line 96.
pub fn ruby_zero_zero_zero_zero_spec_l96_d12_install() string {
	return 'system "echo", "0.0.0.0"'
}

// Ruby it `it "reports offenses for 0.0.0.0 in method definitions outside test blocks" do` at line 104.
pub fn ruby_zero_zero_zero_zero_spec_l104_d13_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n  desc "A test formula"\n\n  def configure\n    system "./configure", "--bind-address=0.0.0.0"\n  end\nend\n'
	offenses := zero_zero_zero_zero_core.audit_zero_zero_zero_zero(source, 'homebrew-core')
	return offenses.len == 1 && offenses[0].content == '--bind-address=0.0.0.0' && offenses[0].end_pos - offenses[0].begin_pos == 24
}

// Ruby method `configure` at line 110.
pub fn ruby_zero_zero_zero_zero_spec_l110_d14_configure() string {
	return 'system "./configure", "--bind-address=0.0.0.0"'
}

// Ruby it `it "reports multiple offenses when 0.0.0.0 is used in multiple places" do` at line 118.
pub fn ruby_zero_zero_zero_zero_spec_l118_d15_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n  desc "A test formula"\n\n  def install\n    system "echo", "0.0.0.0"\n  end\n\n  def post_install\n    system "echo", "0.0.0.0"\n  end\nend\n'
	offenses := zero_zero_zero_zero_core.audit_zero_zero_zero_zero(source, 'homebrew-core')
	return offenses.len == 2 && offenses.all(it.content == '0.0.0.0' && it.end_pos - it.begin_pos == 9)
}

// Ruby method `install` at line 124.
pub fn ruby_zero_zero_zero_zero_spec_l124_d16_install() string {
	return ruby_zero_zero_zero_zero_spec_l96_d12_install()
}

// Ruby method `post_install` at line 129.
pub fn ruby_zero_zero_zero_zero_spec_l129_d17_post_install() string {
	return ruby_zero_zero_zero_zero_spec_l96_d12_install()
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/zero_zero_zero_zero"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::ZeroZeroZeroZero do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports no offenses when 0.0.0.0 is used inside test do blocks" do
// 10:     expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 11:       class Foo < Formula
// 12:         url "https://brew.sh/foo-1.0.tgz"
// 13:         desc "A test formula"
// 14:
// 15:         test do
// 16:           system "echo", "0.0.0.0"
// 17:         end
// 18:       end
// 19:     RUBY
// 20:   end
// 21:
// 22:   it "reports no offenses for valid IP ranges like 10.0.0.0" do
// 23:     expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 24:       class Foo < Formula
// 25:         url "https://brew.sh/foo-1.0.tgz"
// 26:         desc "A test formula"
// 27:
// 28:         def install
// 29:           system "echo", "10.0.0.0"
// 30:         end
// 31:       end
// 32:     RUBY
// 33:   end
// 34:
// 35:   it "reports no offenses for IP range notation like 0.0.0.0-255.255.255.255" do
// 36:     expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 37:       class Foo < Formula
// 38:         url "https://brew.sh/foo-1.0.tgz"
// 39:         desc "A test formula"
// 40:
// 41:         def install
// 42:           system "echo", "0.0.0.0-255.255.255.255"
// 43:         end
// 44:       end
// 45:     RUBY
// 46:   end
// 47:
// 48:   it "reports no offenses for private IP ranges" do
// 49:     expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 50:       class Foo < Formula
// 51:         url "https://brew.sh/foo-1.0.tgz"
// 52:         desc "A test formula"
// 53:
// 54:         def install
// 55:           system "echo", "192.168.1.1"
// 56:           system "echo", "172.16.0.1"
// 57:           system "echo", "10.0.0.1"
// 58:         end
// 59:       end
// 60:     RUBY
// 61:   end
// 62:
// 63:   it "reports no offenses when outside of homebrew-core" do
// 64:     expect_no_offenses(<<~RUBY)
// 65:       class Foo < Formula
// 66:         url "https://brew.sh/foo-1.0.tgz"
// 67:         desc "A test formula"
// 68:
// 69:         service do
// 70:           run [bin/"foo", "--host", "0.0.0.0"]
// 71:         end
// 72:       end
// 73:     RUBY
// 74:   end
// 75:
// 76:   it "reports offenses when 0.0.0.0 is used in service blocks" do
// 77:     expect_offense(<<~RUBY, "/homebrew-core/")
// 78:       class Foo < Formula
// 79:         url "https://brew.sh/foo-1.0.tgz"
// 80:         desc "A test formula"
// 81:
// 82:         service do
// 83:           run [bin/"foo", "--host", "0.0.0.0"]
// 84:                                     ^^^^^^^^^ FormulaAudit/ZeroZeroZeroZero: Do not use 0.0.0.0 as it can be a security risk.
// 85:         end
// 86:       end
// 87:     RUBY
// 88:   end
// 89:
// 90:   it "reports offenses when 0.0.0.0 is used outside of test do blocks" do
// 91:     expect_offense(<<~RUBY, "/homebrew-core/")
// 92:       class Foo < Formula
// 93:         url "https://brew.sh/foo-1.0.tgz"
// 94:         desc "A test formula"
// 95:
// 96:         def install
// 97:           system "echo", "0.0.0.0"
// 98:                          ^^^^^^^^^ FormulaAudit/ZeroZeroZeroZero: Do not use 0.0.0.0 as it can be a security risk.
// 99:         end
// 100:       end
// 101:     RUBY
// 102:   end
// 103:
// 104:   it "reports offenses for 0.0.0.0 in method definitions outside test blocks" do
// 105:     expect_offense(<<~RUBY, "/homebrew-core/")
// 106:       class Foo < Formula
// 107:         url "https://brew.sh/foo-1.0.tgz"
// 108:         desc "A test formula"
// 109:
// 110:         def configure
// 111:           system "./configure", "--bind-address=0.0.0.0"
// 112:                                 ^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/ZeroZeroZeroZero: Do not use 0.0.0.0 as it can be a security risk.
// 113:         end
// 114:       end
// 115:     RUBY
// 116:   end
// 117:
// 118:   it "reports multiple offenses when 0.0.0.0 is used in multiple places" do
// 119:     expect_offense(<<~RUBY, "/homebrew-core/")
// 120:       class Foo < Formula
// 121:         url "https://brew.sh/foo-1.0.tgz"
// 122:         desc "A test formula"
// 123:
// 124:         def install
// 125:           system "echo", "0.0.0.0"
// 126:                          ^^^^^^^^^ FormulaAudit/ZeroZeroZeroZero: Do not use 0.0.0.0 as it can be a security risk.
// 127:         end
// 128:
// 129:         def post_install
// 130:           system "echo", "0.0.0.0"
// 131:                          ^^^^^^^^^ FormulaAudit/ZeroZeroZeroZero: Do not use 0.0.0.0 as it can be a security risk.
// 132:         end
// 133:       end
// 134:     RUBY
// 135:   end
// 136: end
