module cask

import homebrew.rubocops.cask as stanza_grouping_core

// Translated from Homebrew/brew `test/rubocops/cask/stanza_grouping_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn stanza_grouping_caveats_example(caveats string) bool {
	source := "cask 'foo' do\n  version :latest\n  sha256 :no_check\n  url 'https://foo.brew.sh/foo.zip'\n  name 'Foo'\n  app 'Foo.app'\n  ${caveats}\nend"
	expected := "cask 'foo' do\n  version :latest\n  sha256 :no_check\n\n  url 'https://foo.brew.sh/foo.zip'\n  name 'Foo'\n\n  app 'Foo.app'\n\n  ${caveats}\nend"
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 3 && offenses.all(it.message == stanza_grouping_core.stanza_grouping_missing_line_message) && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "accepts a sole stanza" do` at line 7.
pub fn ruby_stanza_grouping_spec_l7_d1_accepts() bool {
	source := "cask 'foo' do\n  version :latest\nend"
	return stanza_grouping_core.audit_stanza_grouping(source).len == 0
}

// Ruby it `it "accepts correctly grouped stanzas" do` at line 15.
pub fn ruby_stanza_grouping_spec_l15_d2_accepts() bool {
	source := "cask 'foo' do\n  version :latest\n  sha256 :no_check\nend"
	return stanza_grouping_core.audit_stanza_grouping(source).len == 0
}

// Ruby it `it "groups completion generation with artifacts" do` at line 24.
pub fn ruby_stanza_grouping_spec_l24_d3_groups() bool {
	source := "cask 'foo' do\n  binary 'foo'\n  generate_completions_from_executable 'foo', 'completions'\n\n  zap trash: '~/.foo'\nend"
	return stanza_grouping_core.audit_stanza_grouping(source).len == 0
}

// Ruby it `it "requires a group boundary after completion generation" do` at line 35.
pub fn ruby_stanza_grouping_spec_l35_d4_requires() bool {
	source := "cask 'foo' do\n  binary 'foo'\n  generate_completions_from_executable 'foo', 'completions'\n  zap trash: '~/.foo'\nend"
	expected := "cask 'foo' do\n  binary 'foo'\n  generate_completions_from_executable 'foo', 'completions'\n\n  zap trash: '~/.foo'\nend"
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 1 && offenses[0].message == stanza_grouping_core.stanza_grouping_missing_line_message && source[offenses[0].begin_pos..offenses[0].end_pos] == "  zap trash: '~/.foo'" && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "accepts correctly grouped stanzas and variable assignments" do` at line 55.
pub fn ruby_stanza_grouping_spec_l55_d5_accepts() bool {
	source := 'cask \'foo\' do\n  arch arm: "arm64", intel: "x86_64"\n  folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"\n  os macos: ">= :big_sur"\n\n  version :latest\n  sha256 :no_check\nend'
	return stanza_grouping_core.audit_stanza_grouping(source).len == 0
}

// Ruby it `it "reports an offense when a stanza is grouped incorrectly" do` at line 68.
pub fn ruby_stanza_grouping_spec_l68_d6_reports() bool {
	source := "cask 'foo' do\n  version :latest\n\n  sha256 :no_check\nend"
	expected := "cask 'foo' do\n  version :latest\n  sha256 :no_check\nend"
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 1 && offenses[0].kind == 'remove' && offenses[0].message == stanza_grouping_core.stanza_grouping_extra_line_message && source[offenses[0].begin_pos..offenses[0].end_pos] == '\n' && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "reports an offense for an incorrectly grouped `arch` stanza" do` at line 86.
pub fn ruby_stanza_grouping_spec_l86_d7_reports() bool {
	source := 'cask \'foo\' do\n  arch arm: "arm64", intel: "x86_64"\n  version :latest\n  sha256 :no_check\nend'
	expected := 'cask \'foo\' do\n  arch arm: "arm64", intel: "x86_64"\n\n  version :latest\n  sha256 :no_check\nend'
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 1 && source[offenses[0].begin_pos..offenses[0].end_pos] == '  version :latest' && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "reports an offense for an incorrectly grouped variable assignment" do` at line 106.
pub fn ruby_stanza_grouping_spec_l106_d8_reports() bool {
	source := 'cask \'foo\' do\n  arch arm: "arm64", intel: "x86_64"\n  folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"\n  version :latest\n  sha256 :no_check\nend'
	expected := 'cask \'foo\' do\n  arch arm: "arm64", intel: "x86_64"\n  folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"\n\n  version :latest\n  sha256 :no_check\nend'
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 1 && source[offenses[0].begin_pos..offenses[0].end_pos] == '  version :latest' && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "reports an offense for multiple incorrectly grouped stanzas" do` at line 128.
pub fn ruby_stanza_grouping_spec_l128_d9_reports() bool {
	source := "cask 'foo' do\n  version :latest\n  sha256 :no_check\n  url 'https://foo.brew.sh/foo.zip'\n\n  name 'Foo'\n\n  homepage 'https://foo.brew.sh'\n\n  app 'Foo.app'\n  uninstall :quit => 'com.example.foo',\n            :kext => 'com.example.foo.kextextension'\nend"
	expected := "cask 'foo' do\n  version :latest\n  sha256 :no_check\n\n  url 'https://foo.brew.sh/foo.zip'\n  name 'Foo'\n  homepage 'https://foo.brew.sh'\n\n  app 'Foo.app'\n\n  uninstall :quit => 'com.example.foo',\n            :kext => 'com.example.foo.kextextension'\nend"
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 4 && offenses.map(it.kind) == ['insert', 'remove', 'remove', 'insert'] && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "reports an offense for multiple incorrectly grouped stanzas and variable assignments" do` at line 166.
pub fn ruby_stanza_grouping_spec_l166_d10_reports() bool {
	source := 'cask \'foo\' do\n  arch arm: "arm64", intel: "x86_64"\n  folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"\n\n  platform = on_arch_conditional arm: "darwin-arm64", intel: "darwin"\n  version :latest\n  sha256 :no_check\n\n  url \'https://foo.brew.sh/foo.zip\'\n\n  name \'Foo\'\n\n  homepage \'https://foo.brew.sh\'\n\n  app \'Foo.app\'\n  uninstall :quit => \'com.example.foo\',\n            :kext => \'com.example.foo.kextextension\'\nend'
	expected := 'cask \'foo\' do\n  arch arm: "arm64", intel: "x86_64"\n  folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"\n  platform = on_arch_conditional arm: "darwin-arm64", intel: "darwin"\n\n  version :latest\n  sha256 :no_check\n\n  url \'https://foo.brew.sh/foo.zip\'\n  name \'Foo\'\n  homepage \'https://foo.brew.sh\'\n\n  app \'Foo.app\'\n\n  uninstall :quit => \'com.example.foo\',\n            :kext => \'com.example.foo.kextextension\'\nend'
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 5 && offenses.map(it.kind) == ['remove', 'insert', 'remove', 'remove',
		'insert'] && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "reports an offense for an incorrectly grouped `caveats` stanza" do` at line 215.
pub fn ruby_stanza_grouping_spec_l215_d11_reports() bool {
	return stanza_grouping_caveats_example(ruby_stanza_grouping_spec_l252_d12_caveats()) && stanza_grouping_caveats_example(ruby_stanza_grouping_spec_l263_d13_caveats()) && stanza_grouping_caveats_example(ruby_stanza_grouping_spec_l278_d14_caveats())
}

// Ruby let `let(:caveats) do` at line 252.
pub fn ruby_stanza_grouping_spec_l252_d12_caveats() string {
	return "caveats 'This is a one-line caveat.'"
}

// Ruby let `let(:caveats) do` at line 263.
pub fn ruby_stanza_grouping_spec_l263_d13_caveats() string {
	return "caveats <<~EOS\n    This is a multiline caveat.\n\n    Let's hope it doesn't cause any problems!\n  EOS"
}

// Ruby let `let(:caveats) do` at line 278.
pub fn ruby_stanza_grouping_spec_l278_d14_caveats() string {
	return 'caveats do\n    puts \'This is a multiline caveat.\'\n\n    puts "Let\'s hope it doesn\'t cause any problems!"\n  end'
}

// Ruby it `it "reports an offense for an incorrectly grouped `postflight` stanza" do` at line 292.
pub fn ruby_stanza_grouping_spec_l292_d15_reports() bool {
	source := "cask 'foo' do\n  version :latest\n  sha256 :no_check\n  url 'https://foo.brew.sh/foo.zip'\n  name 'Foo'\n  app 'Foo.app'\n  postflight do\n    puts 'We have liftoff!'\n  end\nend"
	expected := "cask 'foo' do\n  version :latest\n  sha256 :no_check\n\n  url 'https://foo.brew.sh/foo.zip'\n  name 'Foo'\n\n  app 'Foo.app'\n\n  postflight do\n    puts 'We have liftoff!'\n  end\nend"
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 3 && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "reports an offense for incorrectly grouped comments" do` at line 326.
pub fn ruby_stanza_grouping_spec_l326_d16_reports() bool {
	source := "cask 'foo' do\n  version :latest\n  sha256 :no_check\n  # comment with an empty line between\n\n  # comment directly above\n  postflight do\n    puts 'We have liftoff!'\n  end\n  url 'https://foo.brew.sh/foo.zip'\n  name 'Foo'\n  app 'Foo.app'\nend"
	expected := "cask 'foo' do\n  version :latest\n  sha256 :no_check\n\n  # comment with an empty line between\n\n  # comment directly above\n  postflight do\n    puts 'We have liftoff!'\n  end\n\n  url 'https://foo.brew.sh/foo.zip'\n  name 'Foo'\n\n  app 'Foo.app'\nend"
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 3 && source[offenses[0].begin_pos..offenses[0].end_pos] == '  # comment with an empty line between' && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "reports an offense for incorrectly grouped comments and variable assignments" do` at line 366.
pub fn ruby_stanza_grouping_spec_l366_d17_reports() bool {
	source := 'cask \'foo\' do\n  arch arm: "arm64", intel: "x86_64"\n  folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"\n  # comment with an empty line between\n  version :latest\n  sha256 :no_check\n\n  # comment directly above\n  postflight do\n    puts \'We have liftoff!\'\n  end\n  url \'https://foo.brew.sh/foo.zip\'\n  name \'Foo\'\n  app \'Foo.app\'\nend'
	expected := 'cask \'foo\' do\n  arch arm: "arm64", intel: "x86_64"\n  folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"\n\n  # comment with an empty line between\n  version :latest\n  sha256 :no_check\n\n  # comment directly above\n  postflight do\n    puts \'We have liftoff!\'\n  end\n\n  url \'https://foo.brew.sh/foo.zip\'\n  name \'Foo\'\n\n  app \'Foo.app\'\nend'
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 3 && source[offenses[0].begin_pos..offenses[0].end_pos] == '  # comment with an empty line between' && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "reports an offense for incorrectly grouped stanzas in `on_*` blocks" do` at line 410.
pub fn ruby_stanza_grouping_spec_l410_d18_reports() bool {
	source := 'cask \'foo\' do\n  on_arm do\n    version "1.0.2"\n\n    sha256 :no_check\n  end\n  on_intel do\n    version "0.9.8"\n    sha256 :no_check\n    url "https://foo.brew.sh/foo-intel.zip"\n  end\nend'
	expected := 'cask \'foo\' do\n  on_arm do\n    version "1.0.2"\n    sha256 :no_check\n  end\n  on_intel do\n    version "0.9.8"\n    sha256 :no_check\n\n    url "https://foo.brew.sh/foo-intel.zip"\n  end\nend'
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 2 && offenses.map(it.kind) == ['remove', 'insert'] && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Ruby it `it "reports an offense for incorrectly grouped stanzas with comments in `on_*` blocks" do` at line 444.
pub fn ruby_stanza_grouping_spec_l444_d19_reports() bool {
	source := 'cask \'foo\' do\n  on_arm do\n    version "1.0.2"\n\n    sha256 :no_check # comment on same line\n  end\n  on_intel do\n    version "0.9.8"\n    sha256 :no_check\n  end\nend'
	expected := 'cask \'foo\' do\n  on_arm do\n    version "1.0.2"\n    sha256 :no_check # comment on same line\n  end\n  on_intel do\n    version "0.9.8"\n    sha256 :no_check\n  end\nend'
	offenses := stanza_grouping_core.audit_stanza_grouping(source)
	return offenses.len == 1 && offenses[0].kind == 'remove' && stanza_grouping_core.correct_stanza_grouping(source) == expected
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::StanzaGrouping, :config do
// 7:   it "accepts a sole stanza" do
// 8:     expect_no_offenses <<~CASK
// 9:       cask 'foo' do
// 10:         version :latest
// 11:       end
// 12:     CASK
// 13:   end
// 14:
// 15:   it "accepts correctly grouped stanzas" do
// 16:     expect_no_offenses <<~CASK
// 17:       cask 'foo' do
// 18:         version :latest
// 19:         sha256 :no_check
// 20:       end
// 21:     CASK
// 22:   end
// 23:
// 24:   it "groups completion generation with artifacts" do
// 25:     expect_no_offenses <<~CASK
// 26:       cask 'foo' do
// 27:         binary 'foo'
// 28:         generate_completions_from_executable 'foo', 'completions'
// 29:
// 30:         zap trash: '~/.foo'
// 31:       end
// 32:     CASK
// 33:   end
// 34:
// 35:   it "requires a group boundary after completion generation" do
// 36:     expect_offense <<~CASK
// 37:       cask 'foo' do
// 38:         binary 'foo'
// 39:         generate_completions_from_executable 'foo', 'completions'
// 40:         zap trash: '~/.foo'
// 41:       ^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 42:       end
// 43:     CASK
// 44:
// 45:     expect_correction <<~CASK
// 46:       cask 'foo' do
// 47:         binary 'foo'
// 48:         generate_completions_from_executable 'foo', 'completions'
// 49:
// 50:         zap trash: '~/.foo'
// 51:       end
// 52:     CASK
// 53:   end
// 54:
// 55:   it "accepts correctly grouped stanzas and variable assignments" do
// 56:     expect_no_offenses <<~CASK
// 57:       cask 'foo' do
// 58:         arch arm: "arm64", intel: "x86_64"
// 59:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 60:         os macos: ">= :big_sur"
// 61:
// 62:         version :latest
// 63:         sha256 :no_check
// 64:       end
// 65:     CASK
// 66:   end
// 67:
// 68:   it "reports an offense when a stanza is grouped incorrectly" do
// 69:     expect_offense <<~CASK
// 70:       cask 'foo' do
// 71:         version :latest
// 72:
// 73:       ^{} stanzas within the same group should have no lines between them
// 74:         sha256 :no_check
// 75:       end
// 76:     CASK
// 77:
// 78:     expect_correction <<~CASK
// 79:       cask 'foo' do
// 80:         version :latest
// 81:         sha256 :no_check
// 82:       end
// 83:     CASK
// 84:   end
// 85:
// 86:   it "reports an offense for an incorrectly grouped `arch` stanza" do
// 87:     expect_offense <<~CASK
// 88:       cask 'foo' do
// 89:         arch arm: "arm64", intel: "x86_64"
// 90:         version :latest
// 91:       ^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 92:         sha256 :no_check
// 93:       end
// 94:     CASK
// 95:
// 96:     expect_correction <<~CASK
// 97:       cask 'foo' do
// 98:         arch arm: "arm64", intel: "x86_64"
// 99:
// 100:         version :latest
// 101:         sha256 :no_check
// 102:       end
// 103:     CASK
// 104:   end
// 105:
// 106:   it "reports an offense for an incorrectly grouped variable assignment" do
// 107:     expect_offense <<~CASK
// 108:       cask 'foo' do
// 109:         arch arm: "arm64", intel: "x86_64"
// 110:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 111:         version :latest
// 112:       ^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 113:         sha256 :no_check
// 114:       end
// 115:     CASK
// 116:
// 117:     expect_correction <<~CASK
// 118:       cask 'foo' do
// 119:         arch arm: "arm64", intel: "x86_64"
// 120:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 121:
// 122:         version :latest
// 123:         sha256 :no_check
// 124:       end
// 125:     CASK
// 126:   end
// 127:
// 128:   it "reports an offense for multiple incorrectly grouped stanzas" do
// 129:     expect_offense <<~CASK
// 130:       cask 'foo' do
// 131:         version :latest
// 132:         sha256 :no_check
// 133:         url 'https://foo.brew.sh/foo.zip'
// 134:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 135:
// 136:       ^{} stanzas within the same group should have no lines between them
// 137:         name 'Foo'
// 138:
// 139:       ^{} stanzas within the same group should have no lines between them
// 140:         homepage 'https://foo.brew.sh'
// 141:
// 142:         app 'Foo.app'
// 143:         uninstall :quit => 'com.example.foo',
// 144:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 145:                   :kext => 'com.example.foo.kextextension'
// 146:       end
// 147:     CASK
// 148:
// 149:     expect_correction <<~CASK
// 150:       cask 'foo' do
// 151:         version :latest
// 152:         sha256 :no_check
// 153:
// 154:         url 'https://foo.brew.sh/foo.zip'
// 155:         name 'Foo'
// 156:         homepage 'https://foo.brew.sh'
// 157:
// 158:         app 'Foo.app'
// 159:
// 160:         uninstall :quit => 'com.example.foo',
// 161:                   :kext => 'com.example.foo.kextextension'
// 162:       end
// 163:     CASK
// 164:   end
// 165:
// 166:   it "reports an offense for multiple incorrectly grouped stanzas and variable assignments" do
// 167:     expect_offense <<~CASK
// 168:       cask 'foo' do
// 169:         arch arm: "arm64", intel: "x86_64"
// 170:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 171:
// 172:       ^{} stanzas within the same group should have no lines between them
// 173:         platform = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 174:         version :latest
// 175:       ^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 176:         sha256 :no_check
// 177:
// 178:         url 'https://foo.brew.sh/foo.zip'
// 179:
// 180:       ^{} stanzas within the same group should have no lines between them
// 181:         name 'Foo'
// 182:
// 183:       ^{} stanzas within the same group should have no lines between them
// 184:         homepage 'https://foo.brew.sh'
// 185:
// 186:         app 'Foo.app'
// 187:         uninstall :quit => 'com.example.foo',
// 188:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 189:                   :kext => 'com.example.foo.kextextension'
// 190:       end
// 191:     CASK
// 192:
// 193:     expect_correction <<~CASK
// 194:       cask 'foo' do
// 195:         arch arm: "arm64", intel: "x86_64"
// 196:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 197:         platform = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 198:
// 199:         version :latest
// 200:         sha256 :no_check
// 201:
// 202:         url 'https://foo.brew.sh/foo.zip'
// 203:         name 'Foo'
// 204:         homepage 'https://foo.brew.sh'
// 205:
// 206:         app 'Foo.app'
// 207:
// 208:         uninstall :quit => 'com.example.foo',
// 209:                   :kext => 'com.example.foo.kextextension'
// 210:       end
// 211:     CASK
// 212:   end
// 213:
// 214:   shared_examples "caveats" do
// 215:     it "reports an offense for an incorrectly grouped `caveats` stanza" do
// 216:       # Indent all except the first line.
// 217:       interpolated_caveats = caveats.strip
// 218:
// 219:       expect_offense <<~CASK
// 220:         cask 'foo' do
// 221:           version :latest
// 222:           sha256 :no_check
// 223:           url 'https://foo.brew.sh/foo.zip'
// 224:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 225:           name 'Foo'
// 226:           app 'Foo.app'
// 227:         ^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 228:           #{interpolated_caveats}
// 229:         end
// 230:       CASK
// 231:
// 232:       # Remove offense annotations.
// 233:       corrected_caveats = interpolated_caveats.gsub(/\n\s*\^+\s+.*$/, "")
// 234:
// 235:       expect_correction <<~CASK
// 236:         cask 'foo' do
// 237:           version :latest
// 238:           sha256 :no_check
// 239:
// 240:           url 'https://foo.brew.sh/foo.zip'
// 241:           name 'Foo'
// 242:
// 243:           app 'Foo.app'
// 244:
// 245:           #{corrected_caveats}
// 246:         end
// 247:       CASK
// 248:     end
// 249:   end
// 250:
// 251:   context "when `caveats` is a one-line string" do
// 252:     let(:caveats) do
// 253:       <<~CAVEATS
// 254:           caveats 'This is a one-line caveat.'
// 255:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 256:       CAVEATS
// 257:     end
// 258:
// 259:     include_examples "caveats"
// 260:   end
// 261:
// 262:   context "when `caveats` is a heredoc" do
// 263:     let(:caveats) do
// 264:       <<~CAVEATS
// 265:           caveats <<~EOS
// 266:         ^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 267:             This is a multiline caveat.
// 268:
// 269:             Let's hope it doesn't cause any problems!
// 270:           EOS
// 271:       CAVEATS
// 272:     end
// 273:
// 274:     include_examples "caveats"
// 275:   end
// 276:
// 277:   context "when `caveats` is a block" do
// 278:     let(:caveats) do
// 279:       <<~CAVEATS
// 280:           caveats do
// 281:         ^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 282:             puts 'This is a multiline caveat.'
// 283:
// 284:             puts "Let's hope it doesn't cause any problems!"
// 285:           end
// 286:       CAVEATS
// 287:     end
// 288:
// 289:     include_examples "caveats"
// 290:   end
// 291:
// 292:   it "reports an offense for an incorrectly grouped `postflight` stanza" do
// 293:     expect_offense <<~CASK
// 294:       cask 'foo' do
// 295:         version :latest
// 296:         sha256 :no_check
// 297:         url 'https://foo.brew.sh/foo.zip'
// 298:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 299:         name 'Foo'
// 300:         app 'Foo.app'
// 301:       ^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 302:         postflight do
// 303:       ^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 304:           puts 'We have liftoff!'
// 305:         end
// 306:       end
// 307:     CASK
// 308:
// 309:     expect_correction <<~CASK
// 310:       cask 'foo' do
// 311:         version :latest
// 312:         sha256 :no_check
// 313:
// 314:         url 'https://foo.brew.sh/foo.zip'
// 315:         name 'Foo'
// 316:
// 317:         app 'Foo.app'
// 318:
// 319:         postflight do
// 320:           puts 'We have liftoff!'
// 321:         end
// 322:       end
// 323:     CASK
// 324:   end
// 325:
// 326:   it "reports an offense for incorrectly grouped comments" do
// 327:     expect_offense <<~CASK
// 328:       cask 'foo' do
// 329:         version :latest
// 330:         sha256 :no_check
// 331:         # comment with an empty line between
// 332:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 333:
// 334:         # comment directly above
// 335:         postflight do
// 336:           puts 'We have liftoff!'
// 337:         end
// 338:         url 'https://foo.brew.sh/foo.zip'
// 339:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 340:         name 'Foo'
// 341:         app 'Foo.app'
// 342:       ^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 343:       end
// 344:     CASK
// 345:
// 346:     expect_correction <<~CASK
// 347:       cask 'foo' do
// 348:         version :latest
// 349:         sha256 :no_check
// 350:
// 351:         # comment with an empty line between
// 352:
// 353:         # comment directly above
// 354:         postflight do
// 355:           puts 'We have liftoff!'
// 356:         end
// 357:
// 358:         url 'https://foo.brew.sh/foo.zip'
// 359:         name 'Foo'
// 360:
// 361:         app 'Foo.app'
// 362:       end
// 363:     CASK
// 364:   end
// 365:
// 366:   it "reports an offense for incorrectly grouped comments and variable assignments" do
// 367:     expect_offense <<~CASK
// 368:       cask 'foo' do
// 369:         arch arm: "arm64", intel: "x86_64"
// 370:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 371:         # comment with an empty line between
// 372:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 373:         version :latest
// 374:         sha256 :no_check
// 375:
// 376:         # comment directly above
// 377:         postflight do
// 378:           puts 'We have liftoff!'
// 379:         end
// 380:         url 'https://foo.brew.sh/foo.zip'
// 381:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 382:         name 'Foo'
// 383:         app 'Foo.app'
// 384:       ^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 385:       end
// 386:     CASK
// 387:
// 388:     expect_correction <<~CASK
// 389:       cask 'foo' do
// 390:         arch arm: "arm64", intel: "x86_64"
// 391:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 392:
// 393:         # comment with an empty line between
// 394:         version :latest
// 395:         sha256 :no_check
// 396:
// 397:         # comment directly above
// 398:         postflight do
// 399:           puts 'We have liftoff!'
// 400:         end
// 401:
// 402:         url 'https://foo.brew.sh/foo.zip'
// 403:         name 'Foo'
// 404:
// 405:         app 'Foo.app'
// 406:       end
// 407:     CASK
// 408:   end
// 409:
// 410:   it "reports an offense for incorrectly grouped stanzas in `on_*` blocks" do
// 411:     expect_offense <<~CASK
// 412:       cask 'foo' do
// 413:         on_arm do
// 414:           version "1.0.2"
// 415:
// 416:       ^{} stanzas within the same group should have no lines between them
// 417:           sha256 :no_check
// 418:         end
// 419:         on_intel do
// 420:           version "0.9.8"
// 421:           sha256 :no_check
// 422:           url "https://foo.brew.sh/foo-intel.zip"
// 423:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stanza groups should be separated by a single empty line
// 424:         end
// 425:       end
// 426:     CASK
// 427:
// 428:     expect_correction <<~CASK
// 429:       cask 'foo' do
// 430:         on_arm do
// 431:           version "1.0.2"
// 432:           sha256 :no_check
// 433:         end
// 434:         on_intel do
// 435:           version "0.9.8"
// 436:           sha256 :no_check
// 437:
// 438:           url "https://foo.brew.sh/foo-intel.zip"
// 439:         end
// 440:       end
// 441:     CASK
// 442:   end
// 443:
// 444:   it "reports an offense for incorrectly grouped stanzas with comments in `on_*` blocks" do
// 445:     expect_offense <<~CASK
// 446:       cask 'foo' do
// 447:         on_arm do
// 448:           version "1.0.2"
// 449:
// 450:       ^{} stanzas within the same group should have no lines between them
// 451:           sha256 :no_check # comment on same line
// 452:         end
// 453:         on_intel do
// 454:           version "0.9.8"
// 455:           sha256 :no_check
// 456:         end
// 457:       end
// 458:     CASK
// 459:
// 460:     expect_correction <<~CASK
// 461:       cask 'foo' do
// 462:         on_arm do
// 463:           version "1.0.2"
// 464:           sha256 :no_check # comment on same line
// 465:         end
// 466:         on_intel do
// 467:           version "0.9.8"
// 468:           sha256 :no_check
// 469:         end
// 470:       end
// 471:     CASK
// 472:   end
// 473: end
