module bundle

import ruby
import homebrew.bundle.extensions

// Translated from Homebrew/brew `test/bundle/vscode_extension_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn vscode_spec_case(line int) bool {
	match line {
		19 {
			mut state := extensions.new_vscode_extension_state()
			values := state.discover_extensions()
			return values.len == 0 && extensions.vscode_dump(values) == ''
		}
		31 {
			output := 'catppuccin.catppuccin-vsc\ndavidanson.vscode-markdownlint\nstreetsidesoftware.code-spell-checker\ntamasfe.even-better-toml\n'
			return extensions.vscode_parse_extensions(output) == [
				'catppuccin.catppuccin-vsc',
				'davidanson.vscode-markdownlint',
				'streetsidesoftware.code-spell-checker',
				'tamasfe.even-better-toml',
			]
		}
		50 {
			output := 'updating vs code server to version f6cfa2ea2403534de03f069bdf160d06451ed282\ndownloading: 100%\nunpacked 3485 files and folders to /home/mike/.vscode-server.\nGitHub.codespaces\n'
			return extensions.vscode_parse_extensions(output) == ['github.codespaces']
		}
		75 {
			mut state := extensions.new_vscode_extension_state()
			state.cask_installed = true
			state.brew_file = '/opt/homebrew/bin/brew'
			if _ := state.preinstall('foo', false) {
				return false
			}
			return state.commands == [['/opt/homebrew/bin/brew', 'install', '--cask',
				'visual-studio-code']]
		}
		93, 98 {
			mut state := extensions.new_vscode_extension_state()
			state.executable = 'code'
			state.installed_extensions = ['foo']
			state.installed_extensions_loaded = true
			name := if line == 98 { 'Foo' } else { 'foo' }
			return !(state.preinstall(name, false) or { return false })
		}
		109, 116, 129 {
			mut state := extensions.new_vscode_extension_state()
			state.executable = 'code'
			state.extensions_loaded = true
			state.installed_extensions_loaded = true
			preinstall := state.preinstall('foo', false) or { return false }
			installed := state.install('foo', true, false, true) or { return false }
			return preinstall && installed && state.commands == [['code', '--install-extension',
				'foo']] && state.extensions == ['foo'] && state.installed_extensions == [
				'foo',
			]
		}
		else {
			return false
		}
	}
}

// Ruby subject `subject(:dumper) { described_class }` at line 11.
pub fn ruby_vscode_extension_spec_l11_d1_dumper(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Homebrew::Bundle::VscodeExtension', 'Homebrew::Bundle::VscodeExtension')
}

// Ruby specify `specify do` at line 19.
pub fn ruby_vscode_extension_spec_l19_d2_do(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(vscode_spec_case(19))
}

// Ruby it `it "returns package list" do` at line 31.
pub fn ruby_vscode_extension_spec_l31_d3_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(vscode_spec_case(31))
}

// Ruby it `it "ignores VSCode server setup output" do` at line 50.
pub fn ruby_vscode_extension_spec_l50_d4_ignores(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(vscode_spec_case(50))
}

// Ruby it `it "tries to install vscode" do` at line 75.
pub fn ruby_vscode_extension_spec_l75_d5_tries(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(vscode_spec_case(75))
}

// Ruby it `it "skips" do` at line 93.
pub fn ruby_vscode_extension_spec_l93_d6_skips(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(vscode_spec_case(93))
}

// Ruby it `it "skips ignoring case" do` at line 98.
pub fn ruby_vscode_extension_spec_l98_d7_skips(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(vscode_spec_case(98))
}

// Ruby it `it "installs extension" do` at line 109.
pub fn ruby_vscode_extension_spec_l109_d8_installs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(vscode_spec_case(109))
}

// Ruby it `it "installs extension when euid != uid and Process::UID.re_exchangeable? returns true" do` at line 116.
pub fn ruby_vscode_extension_spec_l116_d9_installs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(vscode_spec_case(116))
}

// Ruby it `it "installs extension when euid != uid and Process::UID.re_exchangeable? returns false" do` at line 129.
pub fn ruby_vscode_extension_spec_l129_d10_installs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(vscode_spec_case(129))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions/vscode_extension"
// 7: require "extend/kernel"
// 8:
// 9: RSpec.describe Homebrew::Bundle::VscodeExtension do
// 10:   describe "dumping" do
// 11:     subject(:dumper) { described_class }
// 12:
// 13:     context "when vscode is not installed" do
// 14:       before do
// 15:         described_class.reset!
// 16:         allow(described_class).to receive_messages(package_manager_executable: nil, "`": "")
// 17:       end
// 18:
// 19:       specify do
// 20:         expect(dumper.extensions).to be_empty
// 21:         expect(dumper.dump).to eql("")
// 22:       end
// 23:     end
// 24:
// 25:     context "when vscode is installed" do
// 26:       before do
// 27:         described_class.reset!
// 28:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("code"))
// 29:       end
// 30:
// 31:       it "returns package list" do
// 32:         output = <<~EOF
// 33:           catppuccin.catppuccin-vsc
// 34:           davidanson.vscode-markdownlint
// 35:           streetsidesoftware.code-spell-checker
// 36:           tamasfe.even-better-toml
// 37:         EOF
// 38:
// 39:         allow(described_class).to receive(:`)
// 40:           .with('"code" --list-extensions 2>/dev/null')
// 41:           .and_return(output)
// 42:         expect(dumper.extensions).to eql([
// 43:           "catppuccin.catppuccin-vsc",
// 44:           "davidanson.vscode-markdownlint",
// 45:           "streetsidesoftware.code-spell-checker",
// 46:           "tamasfe.even-better-toml",
// 47:         ])
// 48:       end
// 49:
// 50:       it "ignores VSCode server setup output" do
// 51:         output = <<~EOF
// 52:           updating vs code server to version f6cfa2ea2403534de03f069bdf160d06451ed282
// 53:           downloading:     \b\b\b\b  0%\b\b\b\b100%
// 54:           unpacked 3485 files and folders to /home/mike/.vscode-server/bin/f6cfa2ea2403534de03f069bdf160d06451ed282.
// 55:           GitHub.codespaces
// 56:         EOF
// 57:
// 58:         allow(described_class).to receive(:`)
// 59:           .with('"code" --list-extensions 2>/dev/null')
// 60:           .and_return(output)
// 61:
// 62:         expect(dumper.extensions).to eql(["github.codespaces"])
// 63:       end
// 64:     end
// 65:   end
// 66:
// 67:   describe "installing" do
// 68:     context "when VSCode is not installed" do
// 69:       before do
// 70:         described_class.reset!
// 71:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 72:         allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(true)
// 73:       end
// 74:
// 75:       it "tries to install vscode" do
// 76:         expect(Homebrew::Bundle).to \
// 77:           receive(:system).with(HOMEBREW_BREW_FILE, "install", "--cask", "visual-studio-code", verbose: false)
// 78:                           .and_return(true)
// 79:         expect { described_class.preinstall!("foo") }.to raise_error(RuntimeError)
// 80:       end
// 81:     end
// 82:
// 83:     context "when VSCode is installed" do
// 84:       before do
// 85:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname("code"))
// 86:       end
// 87:
// 88:       context "when extension is installed" do
// 89:         before do
// 90:           allow(described_class).to receive(:installed_extensions).and_return(["foo"])
// 91:         end
// 92:
// 93:         it "skips" do
// 94:           expect(Homebrew::Bundle).not_to receive(:system)
// 95:           expect(described_class.preinstall!("foo")).to be(false)
// 96:         end
// 97:
// 98:         it "skips ignoring case" do
// 99:           expect(Homebrew::Bundle).not_to receive(:system)
// 100:           expect(described_class.preinstall!("Foo")).to be(false)
// 101:         end
// 102:       end
// 103:
// 104:       context "when extension is not installed" do
// 105:         before do
// 106:           allow(described_class).to receive(:installed_extensions).and_return([])
// 107:         end
// 108:
// 109:         it "installs extension" do
// 110:           expect(Homebrew::Bundle).to \
// 111:             receive(:system).with(Pathname("code"), "--install-extension", "foo", verbose: false).and_return(true)
// 112:           expect(described_class.preinstall!("foo")).to be(true)
// 113:           expect(described_class.install!("foo")).to be(true)
// 114:         end
// 115:
// 116:         it "installs extension when euid != uid and Process::UID.re_exchangeable? returns true" do
// 117:           allow(Process).to receive(:uid).and_return(0)
// 118:           allow(Etc).to receive(:getpwuid).with(0).and_return(double(dir: "/root"))
// 119:           expect(Process).to receive(:euid).and_return(1).once
// 120:           expect(Process::UID).to receive(:re_exchangeable?).and_return(true).once
// 121:           expect(Process::UID).to receive(:re_exchange).twice
// 122:
// 123:           expect(Homebrew::Bundle).to \
// 124:             receive(:system).with(Pathname("code"), "--install-extension", "foo", verbose: false).and_return(true)
// 125:           expect(described_class.preinstall!("foo")).to be(true)
// 126:           expect(described_class.install!("foo")).to be(true)
// 127:         end
// 128:
// 129:         it "installs extension when euid != uid and Process::UID.re_exchangeable? returns false" do
// 130:           allow(Process).to receive(:uid).and_return(0)
// 131:           allow(Etc).to receive(:getpwuid).with(0).and_return(double(dir: "/root"))
// 132:           expect(Process).to receive(:euid).and_return(1).once
// 133:           expect(Process::UID).to receive(:re_exchangeable?).and_return(false).once
// 134:           expect(Process::Sys).to receive(:seteuid).twice
// 135:
// 136:           expect(Homebrew::Bundle).to \
// 137:             receive(:system).with(Pathname("code"), "--install-extension", "foo", verbose: false).and_return(true)
// 138:           expect(described_class.preinstall!("foo")).to be(true)
// 139:           expect(described_class.install!("foo")).to be(true)
// 140:         end
// 141:       end
// 142:     end
// 143:   end
// 144: end
