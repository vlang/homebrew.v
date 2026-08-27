module text

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/text/java_versions_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_java_versions_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports no offenses for non-core formulae" do` at line 10.
pub fn ruby_java_versions_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 15.
pub fn ruby_java_versions_spec_l15_d3_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports no offenses when there is no OpenJDK dependency" do` at line 26.
pub fn ruby_java_versions_spec_l26_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 29.
pub fn ruby_java_versions_spec_l29_d5_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports no offenses when there are multiple OpenJDK dependencies" do` at line 40.
pub fn ruby_java_versions_spec_l40_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 46.
pub fn ruby_java_versions_spec_l46_d7_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports no offenses when Java version arguments match versioned OpenJDK dependency" do` at line 57.
pub fn ruby_java_versions_spec_l57_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 62.
pub fn ruby_java_versions_spec_l62_d9_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports no offenses when Java version arguments match unversioned OpenJDK dependency" do` at line 73.
pub fn ruby_java_versions_spec_l73_d10_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 78.
pub fn ruby_java_versions_spec_l78_d11_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports and corrects mismatched java_home version arguments for versioned OpenJDK dependency" do` at line 89.
pub fn ruby_java_versions_spec_l89_d12_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 94.
pub fn ruby_java_versions_spec_l94_d13_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 116.
pub fn ruby_java_versions_spec_l116_d14_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports and corrects mismatched java_home version arguments for unversioned OpenJDK dependency" do` at line 130.
pub fn ruby_java_versions_spec_l130_d15_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 135.
pub fn ruby_java_versions_spec_l135_d16_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 156.
pub fn ruby_java_versions_spec_l156_d17_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports and corrects mismatched write_jar_script version arguments for versioned OpenJDK dependency" do` at line 170.
pub fn ruby_java_versions_spec_l170_d18_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 175.
pub fn ruby_java_versions_spec_l175_d19_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 195.
pub fn ruby_java_versions_spec_l195_d20_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports and corrects mismatched write_jar_script version arguments for unversioned OpenJDK dependency" do` at line 208.
pub fn ruby_java_versions_spec_l208_d21_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 213.
pub fn ruby_java_versions_spec_l213_d22_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 230.
pub fn ruby_java_versions_spec_l230_d23_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::JavaVersions do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing Java versions" do
// 10:     it "reports no offenses for non-core formulae" do
// 11:       expect_no_offenses(<<~RUBY)
// 12:         class Foo < Formula
// 13:           depends_on "openjdk@25"
// 14:
// 15:           def install
// 16:             java_version = "17"
// 17:             Language::Java.java_home("21")
// 18:             Language::Java.java_home_env(java_version)
// 19:             Language::Java.overridable_java_home_env
// 20:             bin.write_jar_script libexec/"test.jar", "test"
// 21:           end
// 22:         end
// 23:       RUBY
// 24:     end
// 25:
// 26:     it "reports no offenses when there is no OpenJDK dependency" do
// 27:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 28:         class Foo < Formula
// 29:           def install
// 30:             java_version = "17"
// 31:             Language::Java.java_home("21")
// 32:             Language::Java.java_home_env(java_version)
// 33:             Language::Java.overridable_java_home_env
// 34:             bin.write_jar_script libexec/"test.jar", "test"
// 35:           end
// 36:         end
// 37:       RUBY
// 38:     end
// 39:
// 40:     it "reports no offenses when there are multiple OpenJDK dependencies" do
// 41:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 42:         class Foo < Formula
// 43:           depends_on "openjdk@21" => :build
// 44:           depends_on "openjdk@25"
// 45:
// 46:           def install
// 47:             java_version = "25"
// 48:             Language::Java.java_home("21")
// 49:             Language::Java.java_home_env(java_version)
// 50:             Language::Java.overridable_java_home_env("21")
// 51:             bin.write_jar_script libexec/"test.jar", "test", java_version: "25"
// 52:           end
// 53:         end
// 54:       RUBY
// 55:     end
// 56:
// 57:     it "reports no offenses when Java version arguments match versioned OpenJDK dependency" do
// 58:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 59:         class Foo < Formula
// 60:           depends_on "openjdk@25"
// 61:
// 62:           def install
// 63:             java_version = "25"
// 64:             Language::Java.java_home("25")
// 65:             Language::Java.java_home_env(java_version)
// 66:             Language::Java.overridable_java_home_env "25"
// 67:             bin.write_jar_script libexec/"test.jar", "test", java_version: "25"
// 68:           end
// 69:         end
// 70:       RUBY
// 71:     end
// 72:
// 73:     it "reports no offenses when Java version arguments match unversioned OpenJDK dependency" do
// 74:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 75:         class Foo < Formula
// 76:           depends_on "openjdk"
// 77:
// 78:           def install
// 79:             java_version = nil
// 80:             Language::Java.java_home
// 81:             Language::Java.java_home_env(java_version)
// 82:             Language::Java.overridable_java_home_env
// 83:             bin.write_jar_script libexec/"test.jar", "test"
// 84:           end
// 85:         end
// 86:       RUBY
// 87:     end
// 88:
// 89:     it "reports and corrects mismatched java_home version arguments for versioned OpenJDK dependency" do
// 90:       expect_offense(<<~RUBY, "/homebrew-core/")
// 91:         class Foo < Formula
// 92:           depends_on "openjdk@25"
// 93:
// 94:           def install
// 95:             java_version = "21"
// 96:                            ^^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk@25`)
// 97:             openjdk_version = nil
// 98:                               ^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk@25`)
// 99:
// 100:             Language::Java.java_home(java_version)
// 101:             Language::Java.java_home openjdk_version
// 102:             Language::Java.java_home("17")
// 103:                                      ^^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk@25`)
// 104:             Language::Java.java_home_env nil
// 105:                                          ^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk@25`)
// 106:             Language::Java.overridable_java_home_env
// 107:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk@25`)
// 108:           end
// 109:         end
// 110:       RUBY
// 111:
// 112:       expect_correction(<<~RUBY)
// 113:         class Foo < Formula
// 114:           depends_on "openjdk@25"
// 115:
// 116:           def install
// 117:             java_version = "25"
// 118:             openjdk_version = "25"
// 119:
// 120:             Language::Java.java_home(java_version)
// 121:             Language::Java.java_home openjdk_version
// 122:             Language::Java.java_home("25")
// 123:             Language::Java.java_home_env("25")
// 124:             Language::Java.overridable_java_home_env("25")
// 125:           end
// 126:         end
// 127:       RUBY
// 128:     end
// 129:
// 130:     it "reports and corrects mismatched java_home version arguments for unversioned OpenJDK dependency" do
// 131:       expect_offense(<<~RUBY, "/homebrew-core/")
// 132:         class Foo < Formula
// 133:           depends_on "openjdk"
// 134:
// 135:           def install
// 136:             java_version = "21"
// 137:                            ^^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk`)
// 138:             openjdk_version = nil
// 139:
// 140:             Language::Java.java_home(java_version)
// 141:             Language::Java.java_home openjdk_version
// 142:             Language::Java.java_home("17")
// 143:                                      ^^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk`)
// 144:             Language::Java.java_home_env(nil)
// 145:                                          ^^^ FormulaAudit/JavaVersions: Argument is unnecessary when using unversioned OpenJDK
// 146:             Language::Java.overridable_java_home_env "21"
// 147:                                                      ^^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk`)
// 148:           end
// 149:         end
// 150:       RUBY
// 151:
// 152:       expect_correction(<<~RUBY)
// 153:         class Foo < Formula
// 154:           depends_on "openjdk"
// 155:
// 156:           def install
// 157:             java_version = nil
// 158:             openjdk_version = nil
// 159:
// 160:             Language::Java.java_home(java_version)
// 161:             Language::Java.java_home openjdk_version
// 162:             Language::Java.java_home
// 163:             Language::Java.java_home_env
// 164:             Language::Java.overridable_java_home_env
// 165:           end
// 166:         end
// 167:       RUBY
// 168:     end
// 169:
// 170:     it "reports and corrects mismatched write_jar_script version arguments for versioned OpenJDK dependency" do
// 171:       expect_offense(<<~RUBY, "/homebrew-core/")
// 172:         class Foo < Formula
// 173:           depends_on "openjdk@25"
// 174:
// 175:           def install
// 176:             java_version = "21" # intentionally unused so expected to remain unmodified
// 177:             openjdk_version = nil
// 178:                               ^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk@25`)
// 179:
// 180:             bin.write_jar_script libexec/"test.jar", "test-1"
// 181:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk@25`)
// 182:             bin.write_jar_script libexec/"test.jar", "test-2", java_version: "21"
// 183:                                                                              ^^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk@25`)
// 184:             bin.write_jar_script(libexec/"test.jar", "test-3", java_version: nil)
// 185:                                                                              ^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk@25`)
// 186:             bin.write_jar_script(libexec/"test.jar", "test-4", java_version: openjdk_version)
// 187:           end
// 188:         end
// 189:       RUBY
// 190:
// 191:       expect_correction(<<~RUBY)
// 192:         class Foo < Formula
// 193:           depends_on "openjdk@25"
// 194:
// 195:           def install
// 196:             java_version = "21" # intentionally unused so expected to remain unmodified
// 197:             openjdk_version = "25"
// 198:
// 199:             bin.write_jar_script libexec/"test.jar", "test-1", java_version: "25"
// 200:             bin.write_jar_script libexec/"test.jar", "test-2", java_version: "25"
// 201:             bin.write_jar_script(libexec/"test.jar", "test-3", java_version: "25")
// 202:             bin.write_jar_script(libexec/"test.jar", "test-4", java_version: openjdk_version)
// 203:           end
// 204:         end
// 205:       RUBY
// 206:     end
// 207:
// 208:     it "reports and corrects mismatched write_jar_script version arguments for unversioned OpenJDK dependency" do
// 209:       expect_offense(<<~RUBY, "/homebrew-core/")
// 210:         class Foo < Formula
// 211:           depends_on "openjdk"
// 212:
// 213:           def install
// 214:             java_version = "21" # intentionally unused so expected to remain unmodified
// 215:             openjdk_version = "21"
// 216:                               ^^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk`)
// 217:
// 218:             bin.write_jar_script libexec/"test.jar", "test-1"
// 219:             bin.write_jar_script libexec/"test.jar", "test-2", java_version: "25"
// 220:                                                                              ^^^^ FormulaAudit/JavaVersions: Java version argument should match the specified dependency (`openjdk`)
// 221:             bin.write_jar_script(libexec/"test.jar", "test-3", java_version: openjdk_version)
// 222:           end
// 223:         end
// 224:       RUBY
// 225:
// 226:       expect_correction(<<~RUBY)
// 227:         class Foo < Formula
// 228:           depends_on "openjdk"
// 229:
// 230:           def install
// 231:             java_version = "21" # intentionally unused so expected to remain unmodified
// 232:             openjdk_version = nil
// 233:
// 234:             bin.write_jar_script libexec/"test.jar", "test-1"
// 235:             bin.write_jar_script libexec/"test.jar", "test-2"
// 236:             bin.write_jar_script(libexec/"test.jar", "test-3", java_version: openjdk_version)
// 237:           end
// 238:         end
// 239:       RUBY
// 240:     end
// 241:   end
// 242: end
