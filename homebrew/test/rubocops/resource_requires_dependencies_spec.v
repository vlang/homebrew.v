module rubocops

import brew_runtime
import homebrew.rubocops as resource_dependencies_core

// Translated from Homebrew/brew `test/rubocops/resource_requires_dependencies_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_resource_requires_dependencies_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::ResourceRequiresDependencies', 'FormulaAudit/ResourceRequiresDependencies')
}

fn resource_requires_dependencies_spec_single_problem(source string, resource string, dependency_kind string, required_dependencies []string) bool {
	problems := resource_dependencies_core.audit_resource_requires_dependencies(source)
	if problems.len != 1 {
		return false
	}
	problem := problems[0]
	return problem.resource == resource && problem.dependency_kind == dependency_kind && problem.required_dependencies == required_dependencies
}

// Ruby it `it "does not report offenses" do` at line 10.
pub fn ruby_resource_requires_dependencies_spec_l10_d2_does() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n  homepage "https://brew.sh"\n  uses_from_macos "libxml2"\nend'
	return resource_dependencies_core.audit_resource_requires_dependencies(source).len == 0
}

// Ruby it `it "does not report offenses" do` at line 23.
pub fn ruby_resource_requires_dependencies_spec_l23_d3_does() bool {
	source := 'class Foo < Formula\n  uses_from_macos "libxml2"\n  resource "not-bcrypt" do\n    url "blah"\n  end\nend'
	return resource_dependencies_core.audit_resource_requires_dependencies(source).len == 0
}

// Ruby it `it "does not report offenses if the dependencies are present" do` at line 41.
pub fn ruby_resource_requires_dependencies_spec_l41_d4_does() bool {
	source := 'class Foo < Formula\n  depends_on "pkgconf" => :build\n  depends_on "rust" => :build\n  resource "bcrypt" do\n    url "blah"\n  end\nend'
	return resource_dependencies_core.audit_resource_requires_dependencies(source).len == 0
}

// Ruby it `it "reports offenses if missing a dependency" do` at line 58.
pub fn ruby_resource_requires_dependencies_spec_l58_d5_reports() bool {
	source := 'class Foo < Formula\n  depends_on "pkgconf" => :build\n  resource "bcrypt" do\n    url "blah"\n  end\nend'
	return resource_requires_dependencies_spec_single_problem(source, 'bcrypt', 'depends_on', [
		'pkgconf',
		'rust',
	])
}

// Ruby it `it "does not report offenses" do` at line 77.
pub fn ruby_resource_requires_dependencies_spec_l77_d6_does() bool {
	source := 'class Foo < Formula\n  uses_from_macos "libxml2"\n  resource "not-lxml" do\n    url "blah"\n  end\nend'
	return resource_dependencies_core.audit_resource_requires_dependencies(source).len == 0
}

// Ruby it `it "does not report offenses if the dependencies are present" do` at line 95.
pub fn ruby_resource_requires_dependencies_spec_l95_d7_does() bool {
	source := 'class Foo < Formula\n  uses_from_macos "libxml2"\n  uses_from_macos "libxslt"\n  resource "lxml" do\n    url "blah"\n  end\nend'
	return resource_dependencies_core.audit_resource_requires_dependencies(source).len == 0
}

// Ruby it `it "reports offenses if missing a dependency" do` at line 112.
pub fn ruby_resource_requires_dependencies_spec_l112_d8_reports() bool {
	source := 'class Foo < Formula\n  uses_from_macos "libsomethingelse"\n  uses_from_macos "not_libxml2"\n  resource "lxml" do\n    url "blah"\n  end\nend'
	return resource_requires_dependencies_spec_single_problem(source, 'lxml', 'uses_from_macos', [
		'libxml2',
		'libxslt',
	])
}

// Ruby it `it "does not report offenses" do` at line 132.
pub fn ruby_resource_requires_dependencies_spec_l132_d9_does() bool {
	source := 'class Foo < Formula\n  uses_from_macos "libxml2"\n  resource "not-pynacl" do\n    url "blah"\n  end\nend'
	return resource_dependencies_core.audit_resource_requires_dependencies(source).len == 0
}

// Ruby it `it "does not report offenses if the dependencies are present" do` at line 150.
pub fn ruby_resource_requires_dependencies_spec_l150_d10_does() bool {
	source := 'class Foo < Formula\n  depends_on "libsodium"\n  resource "pynacl" do\n    url "blah"\n  end\nend'
	return resource_dependencies_core.audit_resource_requires_dependencies(source).len == 0
}

// Ruby it `it "reports offenses if missing a dependency" do` at line 166.
pub fn ruby_resource_requires_dependencies_spec_l166_d11_reports() bool {
	source := 'class Foo < Formula\n  depends_on "not_libsodium"\n  resource "pynacl" do\n    url "blah"\n  end\nend'
	return resource_requires_dependencies_spec_single_problem(source, 'pynacl', 'depends_on', [
		'libsodium',
	])
}

// Ruby it `it "does not report offenses" do` at line 185.
pub fn ruby_resource_requires_dependencies_spec_l185_d12_does() bool {
	source := 'class Foo < Formula\n  uses_from_macos "libxml2"\n  resource "not-pyyaml" do\n    url "blah"\n  end\nend'
	return resource_dependencies_core.audit_resource_requires_dependencies(source).len == 0
}

// Ruby it `it "does not report offenses if the dependencies are present" do` at line 203.
pub fn ruby_resource_requires_dependencies_spec_l203_d13_does() bool {
	source := 'class Foo < Formula\n  depends_on "libyaml"\n  resource "pyyaml" do\n    url "blah"\n  end\nend'
	return resource_dependencies_core.audit_resource_requires_dependencies(source).len == 0
}

// Ruby it `it "reports offenses if missing a dependency" do` at line 219.
pub fn ruby_resource_requires_dependencies_spec_l219_d14_reports() bool {
	source := 'class Foo < Formula\n  depends_on "not_libyaml"\n  resource "pyyaml" do\n    url "blah"\n  end\nend'
	return resource_requires_dependencies_spec_single_problem(source, 'pyyaml', 'depends_on', [
		'libyaml',
	])
}

// Ruby it `it "reports offenses for each resource that is missing a dependency" do` at line 238.
pub fn ruby_resource_requires_dependencies_spec_l238_d15_reports() bool {
	source := 'class Foo < Formula\n  uses_from_macos "one"\n  uses_from_macos "two"\n  depends_on "three"\n  resource "lxml" do\n  end\n  resource "pynacl" do\n  end\n  resource "pyyaml" do\n  end\nend'
	problems := resource_dependencies_core.audit_resource_requires_dependencies(source)
	return problems.map(it.resource) == ['lxml', 'pynacl', 'pyyaml'] && problems.map(it.dependency_kind) == [
		'uses_from_macos',
		'depends_on',
		'depends_on',
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/resource_requires_dependencies"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::ResourceRequiresDependencies do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when a formula does not have any resources" do
// 10:     it "does not report offenses" do
// 11:       expect_no_offenses(<<~RUBY)
// 12:         class Foo < Formula
// 13:           url "https://brew.sh/foo-1.0.tgz"
// 14:           homepage "https://brew.sh"
// 15:
// 16:           uses_from_macos "libxml2"
// 17:         end
// 18:       RUBY
// 19:     end
// 20:   end
// 21:
// 22:   context "when a formula does not have the bcrypt resource" do
// 23:     it "does not report offenses" do
// 24:       expect_no_offenses(<<~RUBY)
// 25:         class Foo < Formula
// 26:           url "https://brew.sh/foo-1.0.tgz"
// 27:           homepage "https://brew.sh"
// 28:
// 29:           uses_from_macos "libxml2"
// 30:
// 31:           resource "not-bcrypt" do
// 32:             url "blah"
// 33:             sha256 "blah"
// 34:           end
// 35:         end
// 36:       RUBY
// 37:     end
// 38:   end
// 39:
// 40:   context "when a formula has the bcrypt resource" do
// 41:     it "does not report offenses if the dependencies are present" do
// 42:       expect_no_offenses(<<~RUBY)
// 43:         class Foo < Formula
// 44:           url "https://brew.sh/foo-1.0.tgz"
// 45:           homepage "https://brew.sh"
// 46:
// 47:           depends_on "pkgconf" => :build
// 48:           depends_on "rust" => :build
// 49:
// 50:           resource "bcrypt" do
// 51:             url "blah"
// 52:             sha256 "blah"
// 53:           end
// 54:         end
// 55:       RUBY
// 56:     end
// 57:
// 58:     it "reports offenses if missing a dependency" do
// 59:       expect_offense(<<~RUBY)
// 60:         class Foo < Formula
// 61:           url "https://brew.sh/foo-1.0.tgz"
// 62:           homepage "https://brew.sh"
// 63:
// 64:           depends_on "pkgconf" => :build
// 65:
// 66:           resource "bcrypt" do
// 67:           ^^^^^^^^^^^^^^^^^ FormulaAudit/ResourceRequiresDependencies: Add `depends_on` lines above for `"pkgconf"` and `"rust"`.
// 68:             url "blah"
// 69:             sha256 "blah"
// 70:           end
// 71:         end
// 72:       RUBY
// 73:     end
// 74:   end
// 75:
// 76:   context "when a formula does not have the lxml resource" do
// 77:     it "does not report offenses" do
// 78:       expect_no_offenses(<<~RUBY)
// 79:         class Foo < Formula
// 80:           url "https://brew.sh/foo-1.0.tgz"
// 81:           homepage "https://brew.sh"
// 82:
// 83:           uses_from_macos "libxml2"
// 84:
// 85:           resource "not-lxml" do
// 86:             url "blah"
// 87:             sha256 "blah"
// 88:           end
// 89:         end
// 90:       RUBY
// 91:     end
// 92:   end
// 93:
// 94:   context "when a formula has the lxml resource" do
// 95:     it "does not report offenses if the dependencies are present" do
// 96:       expect_no_offenses(<<~RUBY)
// 97:         class Foo < Formula
// 98:           url "https://brew.sh/foo-1.0.tgz"
// 99:           homepage "https://brew.sh"
// 100:
// 101:           uses_from_macos "libxml2"
// 102:           uses_from_macos "libxslt"
// 103:
// 104:           resource "lxml" do
// 105:             url "blah"
// 106:             sha256 "blah"
// 107:           end
// 108:         end
// 109:       RUBY
// 110:     end
// 111:
// 112:     it "reports offenses if missing a dependency" do
// 113:       expect_offense(<<~RUBY)
// 114:         class Foo < Formula
// 115:           url "https://brew.sh/foo-1.0.tgz"
// 116:           homepage "https://brew.sh"
// 117:
// 118:           uses_from_macos "libsomethingelse"
// 119:           uses_from_macos "not_libxml2"
// 120:
// 121:           resource "lxml" do
// 122:           ^^^^^^^^^^^^^^^ FormulaAudit/ResourceRequiresDependencies: Add `uses_from_macos` lines above for `"libxml2"` and `"libxslt"`.
// 123:             url "blah"
// 124:             sha256 "blah"
// 125:           end
// 126:         end
// 127:       RUBY
// 128:     end
// 129:   end
// 130:
// 131:   context "when a formula does not have the pynacl resource" do
// 132:     it "does not report offenses" do
// 133:       expect_no_offenses(<<~RUBY)
// 134:         class Foo < Formula
// 135:           url "https://brew.sh/foo-1.0.tgz"
// 136:           homepage "https://brew.sh"
// 137:
// 138:           uses_from_macos "libxml2"
// 139:
// 140:           resource "not-pynacl" do
// 141:             url "blah"
// 142:             sha256 "blah"
// 143:           end
// 144:         end
// 145:       RUBY
// 146:     end
// 147:   end
// 148:
// 149:   context "when a formula has the pynacl resource" do
// 150:     it "does not report offenses if the dependencies are present" do
// 151:       expect_no_offenses(<<~RUBY)
// 152:         class Foo < Formula
// 153:           url "https://brew.sh/foo-1.0.tgz"
// 154:           homepage "https://brew.sh"
// 155:
// 156:           depends_on "libsodium"
// 157:
// 158:           resource "pynacl" do
// 159:             url "blah"
// 160:             sha256 "blah"
// 161:           end
// 162:         end
// 163:       RUBY
// 164:     end
// 165:
// 166:     it "reports offenses if missing a dependency" do
// 167:       expect_offense(<<~RUBY)
// 168:         class Foo < Formula
// 169:           url "https://brew.sh/foo-1.0.tgz"
// 170:           homepage "https://brew.sh"
// 171:
// 172:           depends_on "not_libsodium"
// 173:
// 174:           resource "pynacl" do
// 175:           ^^^^^^^^^^^^^^^^^ FormulaAudit/ResourceRequiresDependencies: Add `depends_on` lines above for `"libsodium"`.
// 176:             url "blah"
// 177:             sha256 "blah"
// 178:           end
// 179:         end
// 180:       RUBY
// 181:     end
// 182:   end
// 183:
// 184:   context "when a formula does not have the pyyaml resource" do
// 185:     it "does not report offenses" do
// 186:       expect_no_offenses(<<~RUBY)
// 187:         class Foo < Formula
// 188:           url "https://brew.sh/foo-1.0.tgz"
// 189:           homepage "https://brew.sh"
// 190:
// 191:           uses_from_macos "libxml2"
// 192:
// 193:           resource "not-pyyaml" do
// 194:             url "blah"
// 195:             sha256 "blah"
// 196:           end
// 197:         end
// 198:       RUBY
// 199:     end
// 200:   end
// 201:
// 202:   context "when a formula has the pyyaml resource" do
// 203:     it "does not report offenses if the dependencies are present" do
// 204:       expect_no_offenses(<<~RUBY)
// 205:         class Foo < Formula
// 206:           url "https://brew.sh/foo-1.0.tgz"
// 207:           homepage "https://brew.sh"
// 208:
// 209:           depends_on "libyaml"
// 210:
// 211:           resource "pyyaml" do
// 212:             url "blah"
// 213:             sha256 "blah"
// 214:           end
// 215:         end
// 216:       RUBY
// 217:     end
// 218:
// 219:     it "reports offenses if missing a dependency" do
// 220:       expect_offense(<<~RUBY)
// 221:         class Foo < Formula
// 222:           url "https://brew.sh/foo-1.0.tgz"
// 223:           homepage "https://brew.sh"
// 224:
// 225:           depends_on "not_libyaml"
// 226:
// 227:           resource "pyyaml" do
// 228:           ^^^^^^^^^^^^^^^^^ FormulaAudit/ResourceRequiresDependencies: Add `depends_on` lines above for `"libyaml"`.
// 229:             url "blah"
// 230:             sha256 "blah"
// 231:           end
// 232:         end
// 233:       RUBY
// 234:     end
// 235:   end
// 236:
// 237:   context "when a formula has multiple resources" do
// 238:     it "reports offenses for each resource that is missing a dependency" do
// 239:       expect_offense(<<~RUBY)
// 240:         class Foo < Formula
// 241:           url "https://brew.sh/foo-1.0.tgz"
// 242:           homepage "https://brew.sh"
// 243:
// 244:           uses_from_macos "one"
// 245:           uses_from_macos "two"
// 246:           depends_on "three"
// 247:
// 248:           resource "lxml" do
// 249:           ^^^^^^^^^^^^^^^ FormulaAudit/ResourceRequiresDependencies: Add `uses_from_macos` lines above for `"libxml2"` and `"libxslt"`.
// 250:             url "blah"
// 251:             sha256 "blah"
// 252:           end
// 253:
// 254:           resource "pynacl" do
// 255:           ^^^^^^^^^^^^^^^^^ FormulaAudit/ResourceRequiresDependencies: Add `depends_on` lines above for `"libsodium"`.
// 256:             url "blah"
// 257:             sha256 "blah"
// 258:           end
// 259:
// 260:           resource "pyyaml" do
// 261:           ^^^^^^^^^^^^^^^^^ FormulaAudit/ResourceRequiresDependencies: Add `depends_on` lines above for `"libyaml"`.
// 262:             url "blah"
// 263:             sha256 "blah"
// 264:           end
// 265:         end
// 266:       RUBY
// 267:     end
// 268:   end
// 269: end
