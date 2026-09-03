module bottle

import brew_runtime
import homebrew.rubocops as bottle_core

// Translated from Homebrew/brew `test/rubocops/bottle/bottle_order_spec.rb`.
// The original source is retained below for line-by-line provenance.
fn bottle_order_spec_matches(body string, expected_body string) bool {
	source := bottle_spec_formula(body)
	expected := bottle_spec_formula(expected_body)
	problems := bottle_core.audit_bottle_order(source)
	return problems.len == 1 && problems[0].message == bottle_core.bottle_order_message && source[problems[0].begin_pos..problems[0].end_pos].starts_with('bottle do') && bottle_core.correct_bottle_order(source) == expected
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_bottle_order_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::BottleOrder', 'FormulaAudit/BottleOrder')
}

// Ruby it `it "reports no offenses for `bottle :unneeded`" do` at line 9.
pub fn ruby_bottle_order_spec_l9_d2_reports() bool {
	return bottle_core.audit_bottle_order(bottle_spec_formula('  bottle :unneeded')).len == 0
}

// Ruby it `it "reports no offenses for a properly ordered bottle block" do` at line 19.
pub fn ruby_bottle_order_spec_l19_d3_reports() bool {
	plain := bottle_spec_formula('  bottle do\n    rebuild 4\n    sha256 arm64_something_else: "aaaaaaaa"\n    sha256 arm64_big_sur: "aaaaaaaa"\n    sha256 big_sur: "faceb00c"\n    sha256 catalina: "deadbeef"\n  end')
	cellars := bottle_spec_formula('  bottle do\n    rebuild 4\n    sha256 cellar: :any, arm64_something_else: "aaaaaaaa"\n    sha256 cellar: :any_skip_relocation, arm64_big_sur: "aaaaaaaa"\n    sha256 cellar: "/usr/local/Cellar", big_sur: "faceb00c"\n    sha256 catalina: "deadbeef"\n  end')
	return bottle_core.audit_bottle_order(plain).len == 0 && bottle_core.audit_bottle_order(cellars).len == 0
}

// Ruby it `it "reports no offenses for a properly ordered bottle block with a single bottle" do` at line 49.
pub fn ruby_bottle_order_spec_l49_d4_reports() bool {
	plain := bottle_spec_formula('  bottle do\n    sha256 big_sur: "faceb00c"\n  end')
	cellar := bottle_spec_formula('  bottle do\n    sha256 cellar: :any, big_sur: "faceb00c"\n  end')
	return bottle_core.audit_bottle_order(plain).len == 0 && bottle_core.audit_bottle_order(cellar).len == 0
}

// Ruby it `it "reports no offenses for a properly ordered bottle block with only arm/intel bottles" do` at line 71.
pub fn ruby_bottle_order_spec_l71_d5_reports() bool {
	arm := bottle_spec_formula('  bottle do\n    rebuild 4\n    sha256 arm64_catalina: "aaaaaaaa"\n    sha256 arm64_big_sur: "aaaaaaaa"\n  end')
	intel := bottle_spec_formula('  bottle do\n    rebuild 4\n    sha256 big_sur: "faceb00c"\n    sha256 catalina: "deadbeef"\n  end')
	arm_single := bottle_spec_formula('  bottle do\n    rebuild 4\n    sha256 arm64_big_sur: "aaaaaaaa"\n  end')
	intel_single := bottle_spec_formula('  bottle do\n    rebuild 4\n    sha256 big_sur: "faceb00c"\n  end')
	return bottle_core.audit_bottle_order(arm).len == 0 && bottle_core.audit_bottle_order(intel).len == 0 && bottle_core.audit_bottle_order(arm_single).len == 0 && bottle_core.audit_bottle_order(intel_single).len == 0
}

// Ruby it `it "reports and corrects arm bottles below intel bottles" do` at line 119.
pub fn ruby_bottle_order_spec_l119_d6_reports() bool {
	return bottle_order_spec_matches('  bottle do\n    rebuild 4\n    sha256 big_sur: "faceb00c"\n    sha256 catalina: "deadbeef"\n    sha256 arm64_big_sur: "aaaaaaaa"\n  end', '  bottle do\n    rebuild 4\n    sha256 arm64_big_sur: "aaaaaaaa"\n    sha256 big_sur: "faceb00c"\n    sha256 catalina: "deadbeef"\n  end')
}

// Ruby it `it "reports and corrects multiple arm bottles below intel bottles" do` at line 148.
pub fn ruby_bottle_order_spec_l148_d7_reports() bool {
	return bottle_order_spec_matches('  bottle do\n    rebuild 4\n    sha256 big_sur: "faceb00c"\n    sha256 arm64_catalina: "aaaaaaaa"\n    sha256 catalina: "deadbeef"\n    sha256 arm64_big_sur: "aaaaaaaa"\n  end', '  bottle do\n    rebuild 4\n    sha256 arm64_catalina: "aaaaaaaa"\n    sha256 arm64_big_sur: "aaaaaaaa"\n    sha256 big_sur: "faceb00c"\n    sha256 catalina: "deadbeef"\n  end')
}

// Ruby it `it "reports and corrects arm bottles with cellars below intel bottles" do` at line 179.
pub fn ruby_bottle_order_spec_l179_d8_reports() bool {
	return bottle_order_spec_matches('  bottle do\n    rebuild 4\n    sha256 cellar: "/usr/local/Cellar",  big_sur:        "faceb00c"\n    sha256                               catalina:       "deadbeef"\n    sha256 cellar: :any,                 arm64_big_sur:  "aaaaaaaa"\n    sha256 cellar: :any_skip_relocation, arm64_catalina: "aaaaaaaa"\n  end', '  bottle do\n    rebuild 4\n    sha256 cellar: :any,                 arm64_big_sur:  "aaaaaaaa"\n    sha256 cellar: :any_skip_relocation, arm64_catalina: "aaaaaaaa"\n    sha256 cellar: "/usr/local/Cellar",  big_sur:        "faceb00c"\n    sha256                               catalina:       "deadbeef"\n  end')
}

// Ruby it `it "reports and corrects arm bottles below intel bottles with old bottle syntax" do` at line 210.
pub fn ruby_bottle_order_spec_l210_d9_reports() bool {
	return bottle_order_spec_matches('  bottle do\n    cellar :any\n    sha256 "faceb00c" => :big_sur\n    sha256 "aaaaaaaa" => :arm64_big_sur\n    sha256 "aaaaaaaa" => :arm64_catalina\n    sha256 "deadbeef" => :catalina\n  end', '  bottle do\n    cellar :any\n    sha256 "aaaaaaaa" => :arm64_big_sur\n    sha256 "aaaaaaaa" => :arm64_catalina\n    sha256 "faceb00c" => :big_sur\n    sha256 "deadbeef" => :catalina\n  end')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/bottle"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::BottleOrder do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports no offenses for `bottle :unneeded`" do
// 10:     expect_no_offenses(<<~RUBY)
// 11:       class Foo < Formula
// 12:         url "https://brew.sh/foo-1.0.tgz"
// 13:
// 14:         bottle :unneeded
// 15:       end
// 16:     RUBY
// 17:   end
// 18:
// 19:   it "reports no offenses for a properly ordered bottle block" do
// 20:     expect_no_offenses(<<~RUBY)
// 21:       class Foo < Formula
// 22:         url "https://brew.sh/foo-1.0.tgz"
// 23:
// 24:         bottle do
// 25:           rebuild 4
// 26:           sha256 arm64_something_else: "aaaaaaaa"
// 27:           sha256 arm64_big_sur: "aaaaaaaa"
// 28:           sha256 big_sur: "faceb00c"
// 29:           sha256 catalina: "deadbeef"
// 30:         end
// 31:       end
// 32:     RUBY
// 33:
// 34:     expect_no_offenses(<<~RUBY)
// 35:       class Foo < Formula
// 36:         url "https://brew.sh/foo-1.0.tgz"
// 37:
// 38:         bottle do
// 39:           rebuild 4
// 40:           sha256 cellar: :any, arm64_something_else: "aaaaaaaa"
// 41:           sha256 cellar: :any_skip_relocation, arm64_big_sur: "aaaaaaaa"
// 42:           sha256 cellar: "/usr/local/Cellar", big_sur: "faceb00c"
// 43:           sha256 catalina: "deadbeef"
// 44:         end
// 45:       end
// 46:     RUBY
// 47:   end
// 48:
// 49:   it "reports no offenses for a properly ordered bottle block with a single bottle" do
// 50:     expect_no_offenses(<<~RUBY)
// 51:       class Foo < Formula
// 52:         url "https://brew.sh/foo-1.0.tgz"
// 53:
// 54:         bottle do
// 55:           sha256 big_sur: "faceb00c"
// 56:         end
// 57:       end
// 58:     RUBY
// 59:
// 60:     expect_no_offenses(<<~RUBY)
// 61:       class Foo < Formula
// 62:         url "https://brew.sh/foo-1.0.tgz"
// 63:
// 64:         bottle do
// 65:           sha256 cellar: :any, big_sur: "faceb00c"
// 66:         end
// 67:       end
// 68:     RUBY
// 69:   end
// 70:
// 71:   it "reports no offenses for a properly ordered bottle block with only arm/intel bottles" do
// 72:     expect_no_offenses(<<~RUBY)
// 73:       class Foo < Formula
// 74:         url "https://brew.sh/foo-1.0.tgz"
// 75:
// 76:         bottle do
// 77:           rebuild 4
// 78:           sha256 arm64_catalina: "aaaaaaaa"
// 79:           sha256 arm64_big_sur: "aaaaaaaa"
// 80:         end
// 81:       end
// 82:     RUBY
// 83:
// 84:     expect_no_offenses(<<~RUBY)
// 85:       class Foo < Formula
// 86:         url "https://brew.sh/foo-1.0.tgz"
// 87:
// 88:         bottle do
// 89:           rebuild 4
// 90:           sha256 arm64_big_sur: "aaaaaaaa"
// 91:         end
// 92:       end
// 93:     RUBY
// 94:
// 95:     expect_no_offenses(<<~RUBY)
// 96:       class Foo < Formula
// 97:         url "https://brew.sh/foo-1.0.tgz"
// 98:
// 99:         bottle do
// 100:           rebuild 4
// 101:           sha256 big_sur: "faceb00c"
// 102:           sha256 catalina: "deadbeef"
// 103:         end
// 104:       end
// 105:     RUBY
// 106:
// 107:     expect_no_offenses(<<~RUBY)
// 108:       class Foo < Formula
// 109:         url "https://brew.sh/foo-1.0.tgz"
// 110:
// 111:         bottle do
// 112:           rebuild 4
// 113:           sha256 big_sur: "faceb00c"
// 114:         end
// 115:       end
// 116:     RUBY
// 117:   end
// 118:
// 119:   it "reports and corrects arm bottles below intel bottles" do
// 120:     expect_offense(<<~RUBY)
// 121:       class Foo < Formula
// 122:         url "https://brew.sh/foo-1.0.tgz"
// 123:
// 124:         bottle do
// 125:         ^^^^^^^^^ FormulaAudit/BottleOrder: ARM bottles should be listed before Intel bottles
// 126:           rebuild 4
// 127:           sha256 big_sur: "faceb00c"
// 128:           sha256 catalina: "deadbeef"
// 129:           sha256 arm64_big_sur: "aaaaaaaa"
// 130:         end
// 131:       end
// 132:     RUBY
// 133:
// 134:     expect_correction(<<~RUBY)
// 135:       class Foo < Formula
// 136:         url "https://brew.sh/foo-1.0.tgz"
// 137:
// 138:         bottle do
// 139:           rebuild 4
// 140:           sha256 arm64_big_sur: "aaaaaaaa"
// 141:           sha256 big_sur: "faceb00c"
// 142:           sha256 catalina: "deadbeef"
// 143:         end
// 144:       end
// 145:     RUBY
// 146:   end
// 147:
// 148:   it "reports and corrects multiple arm bottles below intel bottles" do
// 149:     expect_offense(<<~RUBY)
// 150:       class Foo < Formula
// 151:         url "https://brew.sh/foo-1.0.tgz"
// 152:
// 153:         bottle do
// 154:         ^^^^^^^^^ FormulaAudit/BottleOrder: ARM bottles should be listed before Intel bottles
// 155:           rebuild 4
// 156:           sha256 big_sur: "faceb00c"
// 157:           sha256 arm64_catalina: "aaaaaaaa"
// 158:           sha256 catalina: "deadbeef"
// 159:           sha256 arm64_big_sur: "aaaaaaaa"
// 160:         end
// 161:       end
// 162:     RUBY
// 163:
// 164:     expect_correction(<<~RUBY)
// 165:       class Foo < Formula
// 166:         url "https://brew.sh/foo-1.0.tgz"
// 167:
// 168:         bottle do
// 169:           rebuild 4
// 170:           sha256 arm64_catalina: "aaaaaaaa"
// 171:           sha256 arm64_big_sur: "aaaaaaaa"
// 172:           sha256 big_sur: "faceb00c"
// 173:           sha256 catalina: "deadbeef"
// 174:         end
// 175:       end
// 176:     RUBY
// 177:   end
// 178:
// 179:   it "reports and corrects arm bottles with cellars below intel bottles" do
// 180:     expect_offense(<<~RUBY)
// 181:       class Foo < Formula
// 182:         url "https://brew.sh/foo-1.0.tgz"
// 183:
// 184:         bottle do
// 185:         ^^^^^^^^^ FormulaAudit/BottleOrder: ARM bottles should be listed before Intel bottles
// 186:           rebuild 4
// 187:           sha256 cellar: "/usr/local/Cellar",  big_sur:        "faceb00c"
// 188:           sha256                               catalina:       "deadbeef"
// 189:           sha256 cellar: :any,                 arm64_big_sur:  "aaaaaaaa"
// 190:           sha256 cellar: :any_skip_relocation, arm64_catalina: "aaaaaaaa"
// 191:         end
// 192:       end
// 193:     RUBY
// 194:
// 195:     expect_correction(<<~RUBY)
// 196:       class Foo < Formula
// 197:         url "https://brew.sh/foo-1.0.tgz"
// 198:
// 199:         bottle do
// 200:           rebuild 4
// 201:           sha256 cellar: :any,                 arm64_big_sur:  "aaaaaaaa"
// 202:           sha256 cellar: :any_skip_relocation, arm64_catalina: "aaaaaaaa"
// 203:           sha256 cellar: "/usr/local/Cellar",  big_sur:        "faceb00c"
// 204:           sha256                               catalina:       "deadbeef"
// 205:         end
// 206:       end
// 207:     RUBY
// 208:   end
// 209:
// 210:   it "reports and corrects arm bottles below intel bottles with old bottle syntax" do
// 211:     expect_offense(<<~RUBY)
// 212:       class Foo < Formula
// 213:         url "https://brew.sh/foo-1.0.tgz"
// 214:
// 215:         bottle do
// 216:         ^^^^^^^^^ FormulaAudit/BottleOrder: ARM bottles should be listed before Intel bottles
// 217:           cellar :any
// 218:           sha256 "faceb00c" => :big_sur
// 219:           sha256 "aaaaaaaa" => :arm64_big_sur
// 220:           sha256 "aaaaaaaa" => :arm64_catalina
// 221:           sha256 "deadbeef" => :catalina
// 222:         end
// 223:       end
// 224:     RUBY
// 225:
// 226:     expect_correction(<<~RUBY)
// 227:       class Foo < Formula
// 228:         url "https://brew.sh/foo-1.0.tgz"
// 229:
// 230:         bottle do
// 231:           cellar :any
// 232:           sha256 "aaaaaaaa" => :arm64_big_sur
// 233:           sha256 "aaaaaaaa" => :arm64_catalina
// 234:           sha256 "faceb00c" => :big_sur
// 235:           sha256 "deadbeef" => :catalina
// 236:         end
// 237:       end
// 238:     RUBY
// 239:   end
// 240: end
