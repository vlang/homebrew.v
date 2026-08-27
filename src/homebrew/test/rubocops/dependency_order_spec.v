module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/dependency_order_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_dependency_order_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports and corrects incorrectly ordered conditional dependencies" do` at line 10.
pub fn ruby_dependency_order_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects incorrectly ordered alphabetical dependencies" do` at line 31.
pub fn ruby_dependency_order_spec_l31_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects incorrectly ordered dependencies that are Requirements" do` at line 52.
pub fn ruby_dependency_order_spec_l52_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects wrong conditional order within a spec block" do` at line 73.
pub fn ruby_dependency_order_spec_l73_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses if correct order for multiple tags" do` at line 106.
pub fn ruby_dependency_order_spec_l106_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects wrong conditional order within a system block" do` at line 118.
pub fn ruby_dependency_order_spec_l118_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects incorrectly ordered conditional dependencies" do` at line 148.
pub fn ruby_dependency_order_spec_l148_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects incorrectly ordered alphabetical dependencies" do` at line 169.
pub fn ruby_dependency_order_spec_l169_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects incorrectly ordered dependencies that are Requirements" do` at line 190.
pub fn ruby_dependency_order_spec_l190_d10_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects wrong conditional order within a spec block" do` at line 211.
pub fn ruby_dependency_order_spec_l211_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses if correct order for multiple tags" do` at line 244.
pub fn ruby_dependency_order_spec_l244_d12_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects wrong conditional order within a system block" do` at line 256.
pub fn ruby_dependency_order_spec_l256_d13_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "handles dynamic strings in depends_on" do` at line 284.
pub fn ruby_dependency_order_spec_l284_d14_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "does not error on invalid depends_on" do` at line 299.
pub fn ruby_dependency_order_spec_l299_d15_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/dependency_order"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::DependencyOrder do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing `uses_from_macos`" do
// 10:     it "reports and corrects incorrectly ordered conditional dependencies" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           homepage "https://brew.sh"
// 14:           url "https://brew.sh/foo-1.0.tgz"
// 15:           uses_from_macos "apple" if build.with? "foo"
// 16:           uses_from_macos "foo" => :optional
// 17:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "foo"` (line 5) should be put before `dependency "apple"` (line 4)
// 18:         end
// 19:       RUBY
// 20:
// 21:       expect_correction(<<~RUBY)
// 22:         class Foo < Formula
// 23:           homepage "https://brew.sh"
// 24:           url "https://brew.sh/foo-1.0.tgz"
// 25:           uses_from_macos "foo" => :optional
// 26:           uses_from_macos "apple" if build.with? "foo"
// 27:         end
// 28:       RUBY
// 29:     end
// 30:
// 31:     it "reports and corrects incorrectly ordered alphabetical dependencies" do
// 32:       expect_offense(<<~RUBY)
// 33:         class Foo < Formula
// 34:           homepage "https://brew.sh"
// 35:           url "https://brew.sh/foo-1.0.tgz"
// 36:           uses_from_macos "foo"
// 37:           uses_from_macos "bar"
// 38:           ^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "bar"` (line 5) should be put before `dependency "foo"` (line 4)
// 39:         end
// 40:       RUBY
// 41:
// 42:       expect_correction(<<~RUBY)
// 43:         class Foo < Formula
// 44:           homepage "https://brew.sh"
// 45:           url "https://brew.sh/foo-1.0.tgz"
// 46:           uses_from_macos "bar"
// 47:           uses_from_macos "foo"
// 48:         end
// 49:       RUBY
// 50:     end
// 51:
// 52:     it "reports and corrects incorrectly ordered dependencies that are Requirements" do
// 53:       expect_offense(<<~RUBY)
// 54:         class Foo < Formula
// 55:           homepage "https://brew.sh"
// 56:           url "https://brew.sh/foo-1.0.tgz"
// 57:           uses_from_macos FooRequirement
// 58:           uses_from_macos "bar"
// 59:           ^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "bar"` (line 5) should be put before `dependency "FooRequirement"` (line 4)
// 60:         end
// 61:       RUBY
// 62:
// 63:       expect_correction(<<~RUBY)
// 64:         class Foo < Formula
// 65:           homepage "https://brew.sh"
// 66:           url "https://brew.sh/foo-1.0.tgz"
// 67:           uses_from_macos "bar"
// 68:           uses_from_macos FooRequirement
// 69:         end
// 70:       RUBY
// 71:     end
// 72:
// 73:     it "reports and corrects wrong conditional order within a spec block" do
// 74:       expect_offense(<<~RUBY)
// 75:         class Foo < Formula
// 76:           homepage "https://brew.sh"
// 77:           url "https://brew.sh/foo-1.0.tgz"
// 78:           head do
// 79:             uses_from_macos "apple" if build.with? "foo"
// 80:             uses_from_macos "bar"
// 81:             ^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "bar"` (line 6) should be put before `dependency "apple"` (line 5)
// 82:             uses_from_macos "foo" => :optional
// 83:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "foo"` (line 7) should be put before `dependency "apple"` (line 5)
// 84:           end
// 85:           uses_from_macos "apple" if build.with? "foo"
// 86:           uses_from_macos "foo" => :optional
// 87:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "foo"` (line 10) should be put before `dependency "apple"` (line 9)
// 88:         end
// 89:       RUBY
// 90:
// 91:       expect_correction(<<~RUBY)
// 92:         class Foo < Formula
// 93:           homepage "https://brew.sh"
// 94:           url "https://brew.sh/foo-1.0.tgz"
// 95:           head do
// 96:             uses_from_macos "bar"
// 97:             uses_from_macos "foo" => :optional
// 98:             uses_from_macos "apple" if build.with? "foo"
// 99:           end
// 100:           uses_from_macos "foo" => :optional
// 101:           uses_from_macos "apple" if build.with? "foo"
// 102:         end
// 103:       RUBY
// 104:     end
// 105:
// 106:     it "reports no offenses if correct order for multiple tags" do
// 107:       expect_no_offenses(<<~RUBY)
// 108:         class Foo < Formula
// 109:           homepage "https://brew.sh"
// 110:           url "https://brew.sh/foo-1.0.tgz"
// 111:           uses_from_macos "bar" => [:build, :test]
// 112:           uses_from_macos "foo" => :build
// 113:           uses_from_macos "apple"
// 114:         end
// 115:       RUBY
// 116:     end
// 117:
// 118:     it "reports and corrects wrong conditional order within a system block" do
// 119:       expect_offense(<<~RUBY)
// 120:         class Foo < Formula
// 121:           homepage "https://brew.sh"
// 122:           url "https://brew.sh/foo-1.0.tgz"
// 123:           on_arm do
// 124:             uses_from_macos "apple" if build.with? "foo"
// 125:             uses_from_macos "bar"
// 126:             ^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "bar"` (line 6) should be put before `dependency "apple"` (line 5)
// 127:             uses_from_macos "foo" => :optional
// 128:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "foo"` (line 7) should be put before `dependency "apple"` (line 5)
// 129:           end
// 130:         end
// 131:       RUBY
// 132:
// 133:       expect_correction(<<~RUBY)
// 134:         class Foo < Formula
// 135:           homepage "https://brew.sh"
// 136:           url "https://brew.sh/foo-1.0.tgz"
// 137:           on_arm do
// 138:             uses_from_macos "bar"
// 139:             uses_from_macos "foo" => :optional
// 140:             uses_from_macos "apple" if build.with? "foo"
// 141:           end
// 142:         end
// 143:       RUBY
// 144:     end
// 145:   end
// 146:
// 147:   context "when auditing `depends_on`" do
// 148:     it "reports and corrects incorrectly ordered conditional dependencies" do
// 149:       expect_offense(<<~RUBY)
// 150:         class Foo < Formula
// 151:           homepage "https://brew.sh"
// 152:           url "https://brew.sh/foo-1.0.tgz"
// 153:           depends_on "apple" if build.with? "foo"
// 154:           depends_on "foo" => :optional
// 155:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "foo"` (line 5) should be put before `dependency "apple"` (line 4)
// 156:         end
// 157:       RUBY
// 158:
// 159:       expect_correction(<<~RUBY)
// 160:         class Foo < Formula
// 161:           homepage "https://brew.sh"
// 162:           url "https://brew.sh/foo-1.0.tgz"
// 163:           depends_on "foo" => :optional
// 164:           depends_on "apple" if build.with? "foo"
// 165:         end
// 166:       RUBY
// 167:     end
// 168:
// 169:     it "reports and corrects incorrectly ordered alphabetical dependencies" do
// 170:       expect_offense(<<~RUBY)
// 171:         class Foo < Formula
// 172:           homepage "https://brew.sh"
// 173:           url "https://brew.sh/foo-1.0.tgz"
// 174:           depends_on "foo"
// 175:           depends_on "bar"
// 176:           ^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "bar"` (line 5) should be put before `dependency "foo"` (line 4)
// 177:         end
// 178:       RUBY
// 179:
// 180:       expect_correction(<<~RUBY)
// 181:         class Foo < Formula
// 182:           homepage "https://brew.sh"
// 183:           url "https://brew.sh/foo-1.0.tgz"
// 184:           depends_on "bar"
// 185:           depends_on "foo"
// 186:         end
// 187:       RUBY
// 188:     end
// 189:
// 190:     it "reports and corrects incorrectly ordered dependencies that are Requirements" do
// 191:       expect_offense(<<~RUBY)
// 192:         class Foo < Formula
// 193:           homepage "https://brew.sh"
// 194:           url "https://brew.sh/foo-1.0.tgz"
// 195:           depends_on FooRequirement
// 196:           depends_on "bar"
// 197:           ^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "bar"` (line 5) should be put before `dependency "FooRequirement"` (line 4)
// 198:         end
// 199:       RUBY
// 200:
// 201:       expect_correction(<<~RUBY)
// 202:         class Foo < Formula
// 203:           homepage "https://brew.sh"
// 204:           url "https://brew.sh/foo-1.0.tgz"
// 205:           depends_on "bar"
// 206:           depends_on FooRequirement
// 207:         end
// 208:       RUBY
// 209:     end
// 210:
// 211:     it "reports and corrects wrong conditional order within a spec block" do
// 212:       expect_offense(<<~RUBY)
// 213:         class Foo < Formula
// 214:           homepage "https://brew.sh"
// 215:           url "https://brew.sh/foo-1.0.tgz"
// 216:           head do
// 217:             depends_on "apple" if build.with? "foo"
// 218:             depends_on "bar"
// 219:             ^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "bar"` (line 6) should be put before `dependency "apple"` (line 5)
// 220:             depends_on "foo" => :optional
// 221:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "foo"` (line 7) should be put before `dependency "apple"` (line 5)
// 222:           end
// 223:           depends_on "apple" if build.with? "foo"
// 224:           depends_on "foo" => :optional
// 225:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "foo"` (line 10) should be put before `dependency "apple"` (line 9)
// 226:         end
// 227:       RUBY
// 228:
// 229:       expect_correction(<<~RUBY)
// 230:         class Foo < Formula
// 231:           homepage "https://brew.sh"
// 232:           url "https://brew.sh/foo-1.0.tgz"
// 233:           head do
// 234:             depends_on "bar"
// 235:             depends_on "foo" => :optional
// 236:             depends_on "apple" if build.with? "foo"
// 237:           end
// 238:           depends_on "foo" => :optional
// 239:           depends_on "apple" if build.with? "foo"
// 240:         end
// 241:       RUBY
// 242:     end
// 243:
// 244:     it "reports no offenses if correct order for multiple tags" do
// 245:       expect_no_offenses(<<~RUBY)
// 246:         class Foo < Formula
// 247:           homepage "https://brew.sh"
// 248:           url "https://brew.sh/foo-1.0.tgz"
// 249:           depends_on "bar" => [:build, :test]
// 250:           depends_on "foo" => :build
// 251:           depends_on "apple"
// 252:         end
// 253:       RUBY
// 254:     end
// 255:
// 256:     it "reports and corrects wrong conditional order within a system block" do
// 257:       expect_offense(<<~RUBY)
// 258:         class Foo < Formula
// 259:           homepage "https://brew.sh"
// 260:           url "https://brew.sh/foo-1.0.tgz"
// 261:           on_linux do
// 262:             depends_on "apple" if build.with? "foo"
// 263:             depends_on "bar"
// 264:             ^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "bar"` (line 6) should be put before `dependency "apple"` (line 5)
// 265:             depends_on "foo" => :optional
// 266:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "foo"` (line 7) should be put before `dependency "apple"` (line 5)
// 267:           end
// 268:         end
// 269:       RUBY
// 270:
// 271:       expect_correction(<<~RUBY)
// 272:         class Foo < Formula
// 273:           homepage "https://brew.sh"
// 274:           url "https://brew.sh/foo-1.0.tgz"
// 275:           on_linux do
// 276:             depends_on "bar"
// 277:             depends_on "foo" => :optional
// 278:             depends_on "apple" if build.with? "foo"
// 279:           end
// 280:         end
// 281:       RUBY
// 282:     end
// 283:
// 284:     it "handles dynamic strings in depends_on" do
// 285:       expect_offense(<<~'RUBY')
// 286:         class Foo < Formula
// 287:           homepage "https://brew.sh"
// 288:           url "https://brew.sh/foo-1.0.tgz"
// 289:
// 290:           BAR_VERSION = 1
// 291:
// 292:           depends_on "foo"
// 293:           depends_on "bar@#{BAR_VERSION}"
// 294:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/DependencyOrder: `dependency "bar@#{BAR_VERSION}"` (line 8) should be put before `dependency "foo"` (line 7)
// 295:         end
// 296:       RUBY
// 297:     end
// 298:
// 299:     it "does not error on invalid depends_on" do
// 300:       expect_no_offenses(<<~RUBY)
// 301:         class Foo < Formula
// 302:           homepage "https://brew.sh"
// 303:           url "https://brew.sh/foo-1.0.tgz"
// 304:           depends_on "apple"
// 305:           depends_on 1
// 306:           depends_on "bar"
// 307:         end
// 308:       RUBY
// 309:     end
// 310:   end
// 311: end
