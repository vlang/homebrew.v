module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/array_alphabetization_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports an offense when a single `zap trash` path is specified in an array" do` at line 7.
pub fn ruby_array_alphabetization_spec_l7_d1_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when the `zap` stanza paths are not in alphabetical order" do` at line 26.
pub fn ruby_array_alphabetization_spec_l26_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "sorts by element content regardless of inconsistent indentation" do` at line 66.
pub fn ruby_array_alphabetization_spec_l66_d3_sorts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sorts', ...args)
}

// Ruby it `it "autocorrects alphabetization in zap trash paths with interpolation" do` at line 93.
pub fn ruby_array_alphabetization_spec_l93_d4_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "reports an offense when a single cask is specified in an array" do` at line 118.
pub fn ruby_array_alphabetization_spec_l118_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when a single cask is specified in a multi-line array" do` at line 137.
pub fn ruby_array_alphabetization_spec_l137_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "autocorrects alphabetization in `conflicts_with` methods" do` at line 158.
pub fn ruby_array_alphabetization_spec_l158_d7_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "autocorrects alphabetization in `uninstall` methods" do` at line 183.
pub fn ruby_array_alphabetization_spec_l183_d8_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "ignores `uninstall` methods with commands" do` at line 216.
pub fn ruby_array_alphabetization_spec_l216_d9_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "moves comments when autocorrecting" do` at line 229.
pub fn ruby_array_alphabetization_spec_l229_d10_moves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('moves', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::ArrayAlphabetization, :config do
// 7:   it "reports an offense when a single `zap trash` path is specified in an array" do
// 8:     expect_offense(<<~CASK)
// 9:       cask "foo" do
// 10:         url "https://example.com/foo.zip"
// 11:
// 12:         zap trash: ["~/Library/Application Support/Foo"]
// 13:                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-element arrays by removing the []
// 14:       end
// 15:     CASK
// 16:
// 17:     expect_correction(<<~CASK)
// 18:       cask "foo" do
// 19:         url "https://example.com/foo.zip"
// 20:
// 21:         zap trash: "~/Library/Application Support/Foo"
// 22:       end
// 23:     CASK
// 24:   end
// 25:
// 26:   it "reports an offense when the `zap` stanza paths are not in alphabetical order" do
// 27:     expect_offense(<<~CASK)
// 28:       cask "foo" do
// 29:         url "https://example.com/foo.zip"
// 30:
// 31:         zap trash: [
// 32:                    ^ The array elements should be ordered alphabetically
// 33:           "/Library/Application Support/Foo",
// 34:           "/Library/Application Support/Baz",
// 35:           "~/Library/Application Support/Foo",
// 36:           "~/.dotfiles/thing",
// 37:           "~/Library/Application Support/Bar",
// 38:         ],
// 39:         rmdir: [
// 40:                ^ The array elements should be ordered alphabetically
// 41:           "/Applications/foo/nested/blah",
// 42:           "/Applications/foo/",
// 43:         ]
// 44:       end
// 45:     CASK
// 46:
// 47:     expect_correction(<<~CASK)
// 48:       cask "foo" do
// 49:         url "https://example.com/foo.zip"
// 50:
// 51:         zap trash: [
// 52:           "/Library/Application Support/Baz",
// 53:           "/Library/Application Support/Foo",
// 54:           "~/.dotfiles/thing",
// 55:           "~/Library/Application Support/Bar",
// 56:           "~/Library/Application Support/Foo",
// 57:         ],
// 58:         rmdir: [
// 59:           "/Applications/foo/",
// 60:           "/Applications/foo/nested/blah",
// 61:         ]
// 62:       end
// 63:     CASK
// 64:   end
// 65:
// 66:   it "sorts by element content regardless of inconsistent indentation" do
// 67:     expect_offense(<<~CASK)
// 68:       cask "foo" do
// 69:         url "https://example.com/foo.zip"
// 70:
// 71:         zap trash: [
// 72:                    ^ The array elements should be ordered alphabetically
// 73:              "~/Library/Caches/Foo",
// 74:              "~/Library/HTTPStorages/Foo",
// 75:           "~/Library/Application Support/Foo",
// 76:         ]
// 77:       end
// 78:     CASK
// 79:
// 80:     expect_correction(<<~CASK)
// 81:       cask "foo" do
// 82:         url "https://example.com/foo.zip"
// 83:
// 84:         zap trash: [
// 85:           "~/Library/Application Support/Foo",
// 86:              "~/Library/Caches/Foo",
// 87:              "~/Library/HTTPStorages/Foo",
// 88:         ]
// 89:       end
// 90:     CASK
// 91:   end
// 92:
// 93:   it "autocorrects alphabetization in zap trash paths with interpolation" do
// 94:     expect_offense(<<~CASK)
// 95:       cask "foo" do
// 96:         url "https://example.com/foo.zip"
// 97:
// 98:         zap trash: [
// 99:                    ^ The array elements should be ordered alphabetically
// 100:           "~/Library/Application Support/Foo",
// 101:           "~/Library/Application Support/Bar\#{version.major}",
// 102:         ]
// 103:       end
// 104:     CASK
// 105:
// 106:     expect_correction(<<~CASK)
// 107:       cask "foo" do
// 108:         url "https://example.com/foo.zip"
// 109:
// 110:         zap trash: [
// 111:           "~/Library/Application Support/Bar\#{version.major}",
// 112:           "~/Library/Application Support/Foo",
// 113:         ]
// 114:       end
// 115:     CASK
// 116:   end
// 117:
// 118:   it "reports an offense when a single cask is specified in an array" do
// 119:     expect_offense(<<~CASK)
// 120:       cask "foo" do
// 121:         url "https://example.com/foo.zip"
// 122:
// 123:         conflicts_with cask: ["bar"]
// 124:                              ^^^^^^^ Avoid single-element arrays by removing the []
// 125:       end
// 126:     CASK
// 127:
// 128:     expect_correction(<<~CASK)
// 129:       cask "foo" do
// 130:         url "https://example.com/foo.zip"
// 131:
// 132:         conflicts_with cask: "bar"
// 133:       end
// 134:     CASK
// 135:   end
// 136:
// 137:   it "reports an offense when a single cask is specified in a multi-line array" do
// 138:     expect_offense(<<~CASK)
// 139:       cask "foo" do
// 140:         url "https://example.com/foo.zip"
// 141:
// 142:         conflicts_with cask: [
// 143:                              ^ Avoid single-element arrays by removing the []
// 144:           "bar"
// 145:         ]
// 146:       end
// 147:     CASK
// 148:
// 149:     expect_correction(<<~CASK)
// 150:       cask "foo" do
// 151:         url "https://example.com/foo.zip"
// 152:
// 153:         conflicts_with cask: "bar"
// 154:       end
// 155:     CASK
// 156:   end
// 157:
// 158:   it "autocorrects alphabetization in `conflicts_with` methods" do
// 159:     expect_offense(<<~CASK)
// 160:       cask "foo" do
// 161:         url "https://example.com/foo.zip"
// 162:
// 163:         conflicts_with cask: [
// 164:                              ^ The array elements should be ordered alphabetically
// 165:           "something",
// 166:           "other",
// 167:         ]
// 168:       end
// 169:     CASK
// 170:
// 171:     expect_correction(<<~CASK)
// 172:       cask "foo" do
// 173:         url "https://example.com/foo.zip"
// 174:
// 175:         conflicts_with cask: [
// 176:           "other",
// 177:           "something",
// 178:         ]
// 179:       end
// 180:     CASK
// 181:   end
// 182:
// 183:   it "autocorrects alphabetization in `uninstall` methods" do
// 184:     expect_offense(<<~CASK)
// 185:       cask "foo" do
// 186:         url "https://example.com/foo.zip"
// 187:
// 188:         uninstall pkgutil: [
// 189:                            ^ The array elements should be ordered alphabetically
// 190:           "something",
// 191:           "other",
// 192:         ],
// 193:         script: [
// 194:           "ordered",
// 195:           "differently",
// 196:         ]
// 197:       end
// 198:     CASK
// 199:
// 200:     expect_correction(<<~CASK)
// 201:       cask "foo" do
// 202:         url "https://example.com/foo.zip"
// 203:
// 204:         uninstall pkgutil: [
// 205:           "other",
// 206:           "something",
// 207:         ],
// 208:         script: [
// 209:           "ordered",
// 210:           "differently",
// 211:         ]
// 212:       end
// 213:     CASK
// 214:   end
// 215:
// 216:   it "ignores `uninstall` methods with commands" do
// 217:     expect_no_offenses(<<~CASK)
// 218:       cask "foo" do
// 219:         url "https://example.com/foo.zip"
// 220:
// 221:         uninstall script: {
// 222:           args: ["--mode=something", "--another-mode"],
// 223:           executable: "thing",
// 224:         }
// 225:       end
// 226:     CASK
// 227:   end
// 228:
// 229:   it "moves comments when autocorrecting" do
// 230:     expect_offense(<<~CASK)
// 231:       cask "foo" do
// 232:         url "https://example.com/foo.zip"
// 233:
// 234:         zap trash: [
// 235:                    ^ The array elements should be ordered alphabetically
// 236:           # comment related to foo
// 237:           "~/Library/Application Support/Foo",
// 238:           # a really long comment related to Zoo
// 239:           # and the Zoo comment continues
// 240:           "~/Library/Application Support/Zoo",
// 241:           "~/Library/Application Support/Bar",
// 242:           "~/Library/Application Support/Baz", # in-line comment
// 243:         ]
// 244:       end
// 245:     CASK
// 246:
// 247:     expect_correction(<<~CASK)
// 248:       cask "foo" do
// 249:         url "https://example.com/foo.zip"
// 250:
// 251:         zap trash: [
// 252:           "~/Library/Application Support/Bar",
// 253:           "~/Library/Application Support/Baz", # in-line comment
// 254:           # comment related to foo
// 255:           "~/Library/Application Support/Foo",
// 256:           # a really long comment related to Zoo
// 257:           # and the Zoo comment continues
// 258:           "~/Library/Application Support/Zoo",
// 259:         ]
// 260:       end
// 261:     CASK
// 262:   end
// 263: end
