module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/no_overrides_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "accepts when there are no `on_*` blocks" do` at line 7.
pub fn ruby_no_overrides_spec_l7_d1_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts when there are no top-level standalone stanzas" do` at line 18.
pub fn ruby_no_overrides_spec_l18_d2_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts `depends_on macos:` in `on_macos` blocks" do` at line 28.
pub fn ruby_no_overrides_spec_l28_d3_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts non-overridable stanzas in `on_*` blocks" do` at line 38.
pub fn ruby_no_overrides_spec_l38_d4_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts `arch` and `version` interpolations in strings in `on_*` blocks" do` at line 54.
pub fn ruby_no_overrides_spec_l54_d5_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts `version` interpolations with method calls in strings in `on_*` blocks" do` at line 69.
pub fn ruby_no_overrides_spec_l69_d6_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts `arch` interpolations in regexes in `on_*` blocks" do` at line 81.
pub fn ruby_no_overrides_spec_l81_d7_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "ignores contents of single-line `livecheck` blocks in `on_*` blocks" do` at line 100.
pub fn ruby_no_overrides_spec_l100_d8_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "ignores contents of multi-line `livecheck` blocks in `on_*` blocks" do` at line 119.
pub fn ruby_no_overrides_spec_l119_d9_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "accepts `on_*` blocks that don't override upper-level stanzas" do` at line 139.
pub fn ruby_no_overrides_spec_l139_d10_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts `conflicts_with` in both top-level and `on_*` blocks" do` at line 156.
pub fn ruby_no_overrides_spec_l156_d11_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "reports an offense when `on_*` blocks override a single upper-level stanza" do` at line 169.
pub fn ruby_no_overrides_spec_l169_d12_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when `on_*` blocks override multiple upper-level stanzas" do` at line 184.
pub fn ruby_no_overrides_spec_l184_d13_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "accepts when there is a top-level `depends_on macos:` stanza" do` at line 201.
pub fn ruby_no_overrides_spec_l201_d14_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "reports an offense when `on_*` blocks contain the samne `depends_on macos:` stanza" do` at line 214.
pub fn ruby_no_overrides_spec_l214_d15_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "accepts when multiple `on_*` blocks contain different `depends_on macos:` stanzas" do` at line 240.
pub fn ruby_no_overrides_spec_l240_d16_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::NoOverrides, :config do
// 7:   it "accepts when there are no `on_*` blocks" do
// 8:     expect_no_offenses <<~CASK
// 9:       cask 'foo' do
// 10:         version '1.2.3'
// 11:         url 'https://brew.sh/foo.pkg'
// 12:
// 13:         name 'Foo'
// 14:       end
// 15:     CASK
// 16:   end
// 17:
// 18:   it "accepts when there are no top-level standalone stanzas" do
// 19:     expect_no_offenses <<~CASK
// 20:       cask 'foo' do
// 21:         on_sequoia :or_later do
// 22:           version :latest
// 23:         end
// 24:       end
// 25:     CASK
// 26:   end
// 27:
// 28:   it "accepts `depends_on macos:` in `on_macos` blocks" do
// 29:     expect_no_offenses <<~CASK
// 30:       cask 'foo' do
// 31:         on_macos do
// 32:           depends_on macos: :catalina
// 33:         end
// 34:       end
// 35:     CASK
// 36:   end
// 37:
// 38:   it "accepts non-overridable stanzas in `on_*` blocks" do
// 39:     expect_no_offenses <<~CASK
// 40:       cask 'foo' do
// 41:         version '1.2.3'
// 42:
// 43:         on_arm do
// 44:           binary "foo-\#{version}-arm64"
// 45:         end
// 46:
// 47:         app "foo-\#{version}.app"
// 48:
// 49:         binary "foo-\#{version}"
// 50:       end
// 51:     CASK
// 52:   end
// 53:
// 54:   it "accepts `arch` and `version` interpolations in strings in `on_*` blocks" do
// 55:     expect_no_offenses <<~CASK
// 56:       cask 'foo' do
// 57:         arch arm: "arm64", intel: "x86"
// 58:         version '1.2.3'
// 59:
// 60:         on_sequoia :or_later do
// 61:           sha256 "aaa"
// 62:
// 63:           url "https://brew.sh/foo-\#{version}-\#{arch}.pkg"
// 64:         end
// 65:       end
// 66:     CASK
// 67:   end
// 68:
// 69:   it "accepts `version` interpolations with method calls in strings in `on_*` blocks" do
// 70:     expect_no_offenses <<~CASK
// 71:       cask 'foo' do
// 72:         version '0.99,123.3'
// 73:
// 74:         on_sequoia :or_later do
// 75:           url "https://brew.sh/foo-\#{version.csv.first}-\#{version.csv.second}.pkg"
// 76:         end
// 77:       end
// 78:     CASK
// 79:   end
// 80:
// 81:   it "accepts `arch` interpolations in regexes in `on_*` blocks" do
// 82:     expect_no_offenses <<~CASK
// 83:       cask 'foo' do
// 84:         arch arm: "arm64", intel: "x86"
// 85:
// 86:         version '0.99,123.3'
// 87:
// 88:         on_sequoia :or_later do
// 89:           url "https://brew.sh/foo-\#{arch}-\#{version.csv.first}-\#{version.csv.last}.pkg"
// 90:
// 91:           livecheck do
// 92:             url "https://brew.sh/foo/releases.html"
// 93:             regex(/href=.*?foo[._-]v?(\d+(?:.\d+)+)-\#{arch}.pkg/i)
// 94:           end
// 95:         end
// 96:       end
// 97:     CASK
// 98:   end
// 99:
// 100:   it "ignores contents of single-line `livecheck` blocks in `on_*` blocks" do
// 101:     expect_no_offenses <<~CASK
// 102:       cask 'foo' do
// 103:         on_intel do
// 104:           livecheck do
// 105:             url 'https://brew.sh/foo' # Livecheck should be allowed since it's a different "kind" of URL.
// 106:           end
// 107:           version '1.2.3'
// 108:         end
// 109:         on_arm do
// 110:           version '2.3.4'
// 111:         end
// 112:
// 113:         url 'https://brew.sh/foo.pkg'
// 114:         sha256 "bbb"
// 115:       end
// 116:     CASK
// 117:   end
// 118:
// 119:   it "ignores contents of multi-line `livecheck` blocks in `on_*` blocks" do
// 120:     expect_no_offenses <<~CASK
// 121:       cask 'foo' do
// 122:         on_intel do
// 123:           livecheck do
// 124:             url 'https://brew.sh/foo' # Livecheck should be allowed since it's a different "kind" of URL.
// 125:             strategy :sparkle
// 126:           end
// 127:           version '1.2.3'
// 128:         end
// 129:         on_arm do
// 130:           version '2.3.4'
// 131:         end
// 132:
// 133:         url 'https://brew.sh/foo.pkg'
// 134:         sha256 "bbb"
// 135:       end
// 136:     CASK
// 137:   end
// 138:
// 139:   it "accepts `on_*` blocks that don't override upper-level stanzas" do
// 140:     expect_no_offenses <<~CASK
// 141:       cask "foo" do
// 142:         version "1.2.3"
// 143:
// 144:         on_big_sur :or_older do
// 145:           sha256 "bbb"
// 146:           url "https://brew.sh/legacy/foo-2.3.4.dmg"
// 147:         end
// 148:         on_monterey :or_newer do
// 149:           sha256 "aaa"
// 150:           url "https://brew.sh/foo-2.3.4.dmg"
// 151:         end
// 152:       end
// 153:     CASK
// 154:   end
// 155:
// 156:   it "accepts `conflicts_with` in both top-level and `on_*` blocks" do
// 157:     expect_no_offenses <<~CASK
// 158:       cask "foo" do
// 159:         version "1.2.3"
// 160:         conflicts_with cask: "foo-beta"
// 161:
// 162:         on_sequoia :or_older do
// 163:           conflicts_with cask: "foo-legacy"
// 164:         end
// 165:       end
// 166:     CASK
// 167:   end
// 168:
// 169:   it "reports an offense when `on_*` blocks override a single upper-level stanza" do
// 170:     expect_offense <<~CASK
// 171:       cask 'foo' do
// 172:         version '2.3.4'
// 173:         ^^^^^^^^^^^^^^^ Do not use a top-level `version` stanza as the default. Add it to an `on_{system}` block instead. Use `:or_older` or `:or_newer` to specify a range of macOS versions.
// 174:
// 175:         on_sequoia :or_older do
// 176:           version '1.2.3'
// 177:         end
// 178:
// 179:         url 'https://brew.sh/foo-2.3.4.dmg'
// 180:       end
// 181:     CASK
// 182:   end
// 183:
// 184:   it "reports an offense when `on_*` blocks override multiple upper-level stanzas" do
// 185:     expect_offense <<~CASK
// 186:       cask "foo" do
// 187:         version "1.2.3"
// 188:         sha256 "aaa"
// 189:         ^^^^^^^^^^^^ Do not use a top-level `sha256` stanza as the default. Add it to an `on_{system}` block instead. Use `:or_older` or `:or_newer` to specify a range of macOS versions.
// 190:         url "https://brew.sh/foo-2.3.4.dmg"
// 191:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use a top-level `url` stanza as the default. Add it to an `on_{system}` block instead. Use `:or_older` or `:or_newer` to specify a range of macOS versions.
// 192:
// 193:         on_big_sur :or_older do
// 194:           sha256 "bbb"
// 195:           url "https://brew.sh/legacy/foo-2.3.4.dmg"
// 196:         end
// 197:       end
// 198:     CASK
// 199:   end
// 200:
// 201:   it "accepts when there is a top-level `depends_on macos:` stanza" do
// 202:     expect_no_offenses <<~CASK
// 203:       cask 'foo' do
// 204:         version '1.2.3'
// 205:         url 'https://brew.sh/foo.pkg'
// 206:
// 207:         depends_on macos: ">= :sequoia"
// 208:
// 209:         name 'Foo'
// 210:       end
// 211:     CASK
// 212:   end
// 213:
// 214:   it "reports an offense when `on_*` blocks contain the samne `depends_on macos:` stanza" do
// 215:     expect_offense <<~CASK
// 216:       cask 'foo' do
// 217:         version '1.2.3'
// 218:
// 219:         on_sequoia :or_newer do
// 220:           sha256 "aaa"
// 221:           url "https://brew.sh/foo-mac.dmg"
// 222:
// 223:           depends_on macos: ">= :sequoia"
// 224:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use a `depends_on macos:` stanza inside an `on_{system}` block. Add it once to specify the oldest macOS supported by any version in the cask.
// 225:         end
// 226:
// 227:         on_arm do
// 228:           sha256 "bbb"
// 229:           url "https://brew.sh/foo-arm.dmg"
// 230:
// 231:           depends_on macos: ">= :sequoia"
// 232:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use a `depends_on macos:` stanza inside an `on_{system}` block. Add it once to specify the oldest macOS supported by any version in the cask.
// 233:         end
// 234:
// 235:         name 'Foo'
// 236:       end
// 237:     CASK
// 238:   end
// 239:
// 240:   it "accepts when multiple `on_*` blocks contain different `depends_on macos:` stanzas" do
// 241:     expect_no_offenses <<~CASK
// 242:       cask "foo" do
// 243:         version "1.2.3"
// 244:
// 245:         on_arm do
// 246:           depends_on macos: ">= :monterey"
// 247:         end
// 248:         on_intel do
// 249:           depends_on macos: ">= :ventura"
// 250:         end
// 251:
// 252:         sha256 "aaa"
// 253:         url "https://brew.sh/foo-mac.dmg"
// 254:         name 'Foo'
// 255:       end
// 256:     CASK
// 257:   end
// 258: end
