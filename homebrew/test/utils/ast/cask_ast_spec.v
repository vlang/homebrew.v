module ast

import ruby
import homebrew.utils

fn cask_ast_spec_source() string {
	return 'cask "foo" do\n  version "1.0"\n  sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"\n\n  url "https://brew.sh/foo-#{version}.dmg"\n  name "Foo"\n\n  on_arm do\n    version "1.1"\n    sha256 :no_check\n  end\nend\n'
}

fn cask_ast_arch_source() string {
	return 'cask "foo" do\n  on_arm do\n    version "1.0"\n  end\n  on_intel do\n    version "1.0"\n  end\nend\n'
}

// Translated from Homebrew/brew `test/utils/ast/cask_ast_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cask_ast) do` at line 7.
pub fn ruby_cask_ast_spec_l7_d1_cask_ast(args ...ruby.Value) ruby.Value {
	return utils.ruby_ast_l568_d50_initialize(ruby.string_value(cask_ast_spec_source()))
}

// Ruby it `it "replaces the first matching stanza argument" do` at line 25.
pub fn ruby_cask_ast_spec_l25_d2_replaces(args ...ruby.Value) ruby.Value {
	mut cask := utils.CaskAst{ contents: cask_ast_spec_source() }
	utils.ast_cask_replace_first(mut cask, 'url', ruby.string_value('https://brew.sh/foo-2.0.dmg'))
	return ruby.bool_value(cask.contents.contains('url "https://brew.sh/foo-2.0.dmg"'))
}

// Ruby it `it "replaces matching stanza arguments" do` at line 33.
pub fn ruby_cask_ast_spec_l33_d3_replaces(args ...ruby.Value) ruby.Value {
	mut cask := utils.CaskAst{ contents: cask_ast_spec_source() }
	utils.ast_cask_replace_value(mut cask, 'version', ruby.string_value('1.0'), ruby.string_value('2.0'), none)
	utils.ast_cask_replace_value(mut cask, 'sha256', ruby.string_value('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), ruby.string_value('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'), none)
	utils.ast_cask_replace_value(mut cask, 'sha256', ruby.object_value('Symbol', ':no_check'), ruby.string_value('cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc'), none)
	expected := 'cask "foo" do\n  version "2.0"\n  sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"\n\n  url "https://brew.sh/foo-#{version}.dmg"\n  name "Foo"\n\n  on_arm do\n    version "1.1"\n    sha256 "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"\n  end\nend\n'
	return ruby.bool_value(cask.contents == expected)
}

// Ruby it `it "replaces matching hash argument values" do` at line 56.
pub fn ruby_cask_ast_spec_l56_d4_replaces(args ...ruby.Value) ruby.Value {
	mut cask := utils.CaskAst{ contents: 'cask "foo" do\n  version "1.0"\n  sha256 arm:   "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",\n         intel: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"\n  url "https://brew.sh/foo.dmg"\nend\n' }
	count := utils.ast_cask_replace_value(mut cask, 'sha256', ruby.string_value('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), ruby.string_value('cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc'), none)
	return ruby.bool_value(count == 1 && cask.contents.contains('arm:   "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"'))
}

// Ruby it `it "replaces matching stanza arguments only inside on_arm blocks" do` at line 80.
pub fn ruby_cask_ast_spec_l80_d5_replaces(args ...ruby.Value) ruby.Value {
	mut cask := utils.CaskAst{ contents: cask_ast_arch_source() }
	count := utils.ast_cask_replace_value(mut cask, 'version', ruby.string_value('1.0'), ruby.string_value('2.0'), 'on_arm')
	return ruby.bool_value(count == 1 && cask.contents.contains('on_arm do\n    version "2.0"') && cask.contents.contains('on_intel do\n    version "1.0"'))
}

// Ruby it `it "replaces matching stanza arguments only inside on_intel blocks" do` at line 105.
pub fn ruby_cask_ast_spec_l105_d6_replaces(args ...ruby.Value) ruby.Value {
	mut cask := utils.CaskAst{ contents: cask_ast_arch_source() }
	count := utils.ast_cask_replace_value(mut cask, 'version', ruby.string_value('1.0'), ruby.string_value('2.0'), 'on_intel')
	return ruby.bool_value(count == 1 && cask.contents.contains('on_arm do\n    version "1.0"') && cask.contents.contains('on_intel do\n    version "2.0"'))
}

// Ruby it `it "keeps replacing all matching stanza arguments without a scope" do` at line 130.
pub fn ruby_cask_ast_spec_l130_d7_keeps(args ...ruby.Value) ruby.Value {
	mut cask := utils.CaskAst{ contents: cask_ast_arch_source() }
	count := utils.ast_cask_replace_value(mut cask, 'version', ruby.string_value('1.0'), ruby.string_value('2.0'), none)
	return ruby.bool_value(count == 2 && cask.contents.count('version "2.0"') == 2)
}

// Ruby it `it "replaces matching stanza values within an on-system block" do` at line 155.
pub fn ruby_cask_ast_spec_l155_d8_replaces(args ...ruby.Value) ruby.Value {
	mut cask := utils.CaskAst{ contents: 'cask "foo" do\n  on_arm do\n    version "1.0"\n    sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"\n  end\n\n  on_intel do\n    version "1.0"\n    sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"\n  end\n\n  url "https://brew.sh/foo.dmg"\nend\n' }
	version_count := utils.ast_cask_replace_value(mut cask, 'version', ruby.string_value('1.0'), ruby.string_value('2.0'), 'on_arm')
	sha_count := utils.ast_cask_replace_value(mut cask, 'sha256', ruby.string_value('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), ruby.string_value('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'), 'on_arm')
	return ruby.bool_value(version_count == 1 && sha_count == 1 && cask.contents.contains('on_arm do\n    version "2.0"\n    sha256 "bbbb') && cask.contents.contains('on_intel do\n    version "1.0"\n    sha256 "aaaa'))
}

// Ruby it `it "detects casks with a macOS dependency" do` at line 197.
pub fn ruby_cask_ast_spec_l197_d9_detects(args ...ruby.Value) ruby.Value {
	cask := utils.CaskAst{ contents: 'cask "foo" do\n  version "1.0"\n  sha256 :no_check\n  url "https://brew.sh/foo.dmg"\n  depends_on macos: ">= :ventura"\nend\n' }
	return ruby.bool_value(utils.ast_cask_depends_on_macos(cask))
}

// Ruby it `it "returns false without a macOS dependency" do` at line 210.
pub fn ruby_cask_ast_spec_l210_d10_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!utils.ast_cask_depends_on_macos(utils.CaskAst{
		contents: cask_ast_spec_source()
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/ast"
// 5:
// 6: RSpec.describe Utils::AST::CaskAST do
// 7:   subject(:cask_ast) do
// 8:     described_class.new <<~RUBY
// 9:       cask "foo" do
// 10:         version "1.0"
// 11:         sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 12:
// 13:         url "https://brew.sh/foo-\#{version}.dmg"
// 14:         name "Foo"
// 15:
// 16:         on_arm do
// 17:           version "1.1"
// 18:           sha256 :no_check
// 19:         end
// 20:       end
// 21:     RUBY
// 22:   end
// 23:
// 24:   describe "#replace_first_stanza_value" do
// 25:     it "replaces the first matching stanza argument" do
// 26:       cask_ast.replace_first_stanza_value(:url, "https://brew.sh/foo-2.0.dmg")
// 27:
// 28:       expect(cask_ast.process).to include('url "https://brew.sh/foo-2.0.dmg"')
// 29:     end
// 30:   end
// 31:
// 32:   describe "#replace_stanza_value" do
// 33:     it "replaces matching stanza arguments" do
// 34:       cask_ast.replace_stanza_value(:version, "1.0", "2.0")
// 35:       cask_ast.replace_stanza_value(:sha256, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// 36:                                     "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
// 37:       cask_ast.replace_stanza_value(:sha256, :no_check,
// 38:                                     "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc")
// 39:
// 40:       expect(cask_ast.process).to eq <<~RUBY
// 41:         cask "foo" do
// 42:           version "2.0"
// 43:           sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 44:
// 45:           url "https://brew.sh/foo-\#{version}.dmg"
// 46:           name "Foo"
// 47:
// 48:           on_arm do
// 49:             version "1.1"
// 50:             sha256 "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
// 51:           end
// 52:         end
// 53:       RUBY
// 54:     end
// 55:
// 56:     it "replaces matching hash argument values" do
// 57:       cask_ast = described_class.new <<~RUBY
// 58:         cask "foo" do
// 59:           version "1.0"
// 60:           sha256 arm:   "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// 61:                  intel: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 62:           url "https://brew.sh/foo.dmg"
// 63:         end
// 64:       RUBY
// 65:
// 66:       expect(
// 67:         cask_ast.replace_stanza_value(:sha256, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// 68:                                       "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"),
// 69:       ).to eq(1)
// 70:       expect(cask_ast.process).to eq <<~RUBY
// 71:         cask "foo" do
// 72:           version "1.0"
// 73:           sha256 arm:   "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
// 74:                  intel: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 75:           url "https://brew.sh/foo.dmg"
// 76:         end
// 77:       RUBY
// 78:     end
// 79:
// 80:     it "replaces matching stanza arguments only inside on_arm blocks" do
// 81:       cask_ast = described_class.new <<~RUBY
// 82:         cask "foo" do
// 83:           on_arm do
// 84:             version "1.0"
// 85:           end
// 86:           on_intel do
// 87:             version "1.0"
// 88:           end
// 89:         end
// 90:       RUBY
// 91:
// 92:       expect(cask_ast.replace_stanza_value(:version, "1.0", "2.0", within: :on_arm)).to eq(1)
// 93:       expect(cask_ast.process).to eq <<~RUBY
// 94:         cask "foo" do
// 95:           on_arm do
// 96:             version "2.0"
// 97:           end
// 98:           on_intel do
// 99:             version "1.0"
// 100:           end
// 101:         end
// 102:       RUBY
// 103:     end
// 104:
// 105:     it "replaces matching stanza arguments only inside on_intel blocks" do
// 106:       cask_ast = described_class.new <<~RUBY
// 107:         cask "foo" do
// 108:           on_arm do
// 109:             version "1.0"
// 110:           end
// 111:           on_intel do
// 112:             version "1.0"
// 113:           end
// 114:         end
// 115:       RUBY
// 116:
// 117:       expect(cask_ast.replace_stanza_value(:version, "1.0", "2.0", within: :on_intel)).to eq(1)
// 118:       expect(cask_ast.process).to eq <<~RUBY
// 119:         cask "foo" do
// 120:           on_arm do
// 121:             version "1.0"
// 122:           end
// 123:           on_intel do
// 124:             version "2.0"
// 125:           end
// 126:         end
// 127:       RUBY
// 128:     end
// 129:
// 130:     it "keeps replacing all matching stanza arguments without a scope" do
// 131:       cask_ast = described_class.new <<~RUBY
// 132:         cask "foo" do
// 133:           on_arm do
// 134:             version "1.0"
// 135:           end
// 136:           on_intel do
// 137:             version "1.0"
// 138:           end
// 139:         end
// 140:       RUBY
// 141:
// 142:       expect(cask_ast.replace_stanza_value(:version, "1.0", "2.0")).to eq(2)
// 143:       expect(cask_ast.process).to eq <<~RUBY
// 144:         cask "foo" do
// 145:           on_arm do
// 146:             version "2.0"
// 147:           end
// 148:           on_intel do
// 149:             version "2.0"
// 150:           end
// 151:         end
// 152:       RUBY
// 153:     end
// 154:
// 155:     it "replaces matching stanza values within an on-system block" do
// 156:       cask_ast = described_class.new <<~RUBY
// 157:         cask "foo" do
// 158:           on_arm do
// 159:             version "1.0"
// 160:             sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 161:           end
// 162:
// 163:           on_intel do
// 164:             version "1.0"
// 165:             sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 166:           end
// 167:
// 168:           url "https://brew.sh/foo.dmg"
// 169:         end
// 170:       RUBY
// 171:
// 172:       expect(cask_ast.replace_stanza_value(:version, "1.0", "2.0", within: :on_arm)).to eq(1)
// 173:       expect(
// 174:         cask_ast.replace_stanza_value(:sha256, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// 175:                                       "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
// 176:                                       within: :on_arm),
// 177:       ).to eq(1)
// 178:       expect(cask_ast.process).to eq <<~RUBY
// 179:         cask "foo" do
// 180:           on_arm do
// 181:             version "2.0"
// 182:             sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 183:           end
// 184:
// 185:           on_intel do
// 186:             version "1.0"
// 187:             sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 188:           end
// 189:
// 190:           url "https://brew.sh/foo.dmg"
// 191:         end
// 192:       RUBY
// 193:     end
// 194:   end
// 195:
// 196:   describe "#depends_on_macos?" do
// 197:     it "detects casks with a macOS dependency" do
// 198:       cask_ast = described_class.new <<~RUBY
// 199:         cask "foo" do
// 200:           version "1.0"
// 201:           sha256 :no_check
// 202:           url "https://brew.sh/foo.dmg"
// 203:           depends_on macos: ">= :ventura"
// 204:         end
// 205:       RUBY
// 206:
// 207:       expect(cask_ast.depends_on_macos?).to be(true)
// 208:     end
// 209:
// 210:     it "returns false without a macOS dependency" do
// 211:       expect(cask_ast.depends_on_macos?).to be(false)
// 212:     end
// 213:   end
// 214: end
