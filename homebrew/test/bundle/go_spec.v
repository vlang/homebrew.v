module bundle

import brew_runtime

// Translated from Homebrew/brew `test/bundle/go_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:dumper) { described_class }` at line 10.
pub fn ruby_go_spec_l10_d1_dumper(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dumper', ...args)
}

// Ruby specify `specify do` at line 18.
pub fn ruby_go_spec_l18_d2_do(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do', ...args)
}

// Ruby it `it "returns package list" do` at line 30.
pub fn ruby_go_spec_l30_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "dumps package list" do` at line 42.
pub fn ruby_go_spec_l42_d4_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dumps', ...args)
}

// Ruby it `it "tries to install go" do` at line 56.
pub fn ruby_go_spec_l56_d5_tries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tries', ...args)
}

// Ruby it `it "preserves upgrade_formulae while bootstrapping Go" do` at line 63.
pub fn ruby_go_spec_l63_d6_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "skips" do` at line 85.
pub fn ruby_go_spec_l85_d7_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "installs package" do` at line 96.
pub fn ruby_go_spec_l96_d8_installs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installs', ...args)
}

// Ruby it `it "updates dump output after install in the same process" do` at line 104.
pub fn ruby_go_spec_l104_d9_updates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('updates', ...args)
}

// Ruby it `it "returns packages not in Brewfile entries" do` at line 128.
pub fn ruby_go_spec_l128_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns frozen empty array when go is not installed" do` at line 134.
pub fn ruby_go_spec_l134_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions/go"
// 7:
// 8: RSpec.describe Homebrew::Bundle::Go do
// 9:   describe "dumping" do
// 10:     subject(:dumper) { described_class }
// 11:
// 12:     context "when go is not installed" do
// 13:       before do
// 14:         described_class.reset!
// 15:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 16:       end
// 17:
// 18:       specify do
// 19:         expect(dumper.packages).to be_empty
// 20:         expect(dumper.dump).to eql("")
// 21:       end
// 22:     end
// 23:
// 24:     context "when go is installed" do
// 25:       before do
// 26:         described_class.reset!
// 27:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("go"))
// 28:       end
// 29:
// 30:       it "returns package list" do
// 31:         allow(described_class).to receive(:`).with("go env GOBIN").and_return("")
// 32:         allow(described_class).to receive(:`).with("go env GOPATH").and_return("/Users/test/go")
// 33:         allow(File).to receive(:directory?).with("/Users/test/go/bin").and_return(true)
// 34:         allow(Dir).to receive(:glob).with("/Users/test/go/bin/*").and_return(["/Users/test/go/bin/crush"])
// 35:         allow(File).to receive(:executable?).with("/Users/test/go/bin/crush").and_return(true)
// 36:         allow(File).to receive(:directory?).with("/Users/test/go/bin/crush").and_return(false)
// 37:         allow(described_class).to receive(:`).with("go version -m \"/Users/test/go/bin/crush\" 2>/dev/null")
// 38:                                              .and_return("\tpath\tgithub.com/charmbracelet/crush\n")
// 39:         expect(dumper.packages).to eql(["github.com/charmbracelet/crush"])
// 40:       end
// 41:
// 42:       it "dumps package list" do
// 43:         allow(dumper).to receive(:packages).and_return(["github.com/charmbracelet/crush"])
// 44:         expect(dumper.dump).to eql('go "github.com/charmbracelet/crush"')
// 45:       end
// 46:     end
// 47:   end
// 48:
// 49:   describe "installing" do
// 50:     context "when Go is not installed" do
// 51:       before do
// 52:         described_class.reset!
// 53:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 54:       end
// 55:
// 56:       it "tries to install go" do
// 57:         expect(Homebrew::Bundle).to \
// 58:           receive(:system).with(HOMEBREW_BREW_FILE, "install", "--formula", "go", verbose: false)
// 59:                           .and_return(true)
// 60:         expect { described_class.preinstall!("github.com/charmbracelet/crush") }.to raise_error(RuntimeError)
// 61:       end
// 62:
// 63:       it "preserves upgrade_formulae while bootstrapping Go" do
// 64:         Homebrew::Bundle.upgrade_formulae = "foo,bar"
// 65:
// 66:         expect(Homebrew::Bundle).to \
// 67:           receive(:system).with(HOMEBREW_BREW_FILE, "install", "--formula", "go", verbose: false)
// 68:                           .and_return(true)
// 69:         expect { described_class.preinstall!("github.com/charmbracelet/crush") }.to raise_error(RuntimeError)
// 70:         expect(Homebrew::Bundle.upgrade_formulae).to eql(["foo", "bar"])
// 71:       end
// 72:     end
// 73:
// 74:     context "when Go is installed" do
// 75:       before do
// 76:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("go"))
// 77:       end
// 78:
// 79:       context "when package is installed" do
// 80:         before do
// 81:           allow(described_class).to receive(:installed_packages)
// 82:             .and_return(["github.com/charmbracelet/crush"])
// 83:         end
// 84:
// 85:         it "skips" do
// 86:           expect(Homebrew::Bundle).not_to receive(:system)
// 87:           expect(described_class.preinstall!("github.com/charmbracelet/crush")).to be(false)
// 88:         end
// 89:       end
// 90:
// 91:       context "when package is not installed" do
// 92:         before do
// 93:           allow(described_class).to receive_messages(packages: [], installed_packages: [])
// 94:         end
// 95:
// 96:         it "installs package" do
// 97:           expect(Homebrew::Bundle).to \
// 98:             receive(:system).with("go", "install", "github.com/charmbracelet/crush@latest", verbose: false)
// 99:                             .and_return(true)
// 100:           expect(described_class.preinstall!("github.com/charmbracelet/crush")).to be(true)
// 101:           expect(described_class.install!("github.com/charmbracelet/crush")).to be(true)
// 102:         end
// 103:
// 104:         it "updates dump output after install in the same process" do
// 105:           expect(Homebrew::Bundle).to \
// 106:             receive(:system).with("go", "install", "github.com/charmbracelet/crush@latest", verbose: false)
// 107:                             .and_return(true)
// 108:
// 109:           described_class.install!("github.com/charmbracelet/crush")
// 110:
// 111:           expect(described_class.dump).to eql('go "github.com/charmbracelet/crush"')
// 112:         end
// 113:       end
// 114:     end
// 115:   end
// 116:
// 117:   describe "cleanup" do
// 118:     before do
// 119:       described_class.reset!
// 120:       pkgs = %w[github.com/charmbracelet/crush github.com/golangci/golangci-lint/v2/cmd/golangci-lint]
// 121:       allow(described_class).to receive_messages(
// 122:         package_manager_executable: Pathname.new("go"),
// 123:         packages:                   pkgs,
// 124:         installed_packages:         pkgs,
// 125:       )
// 126:     end
// 127:
// 128:     it "returns packages not in Brewfile entries" do
// 129:       entries = [Homebrew::Bundle::Dsl::Entry.new(:go, "github.com/charmbracelet/crush")]
// 130:       expect(described_class.cleanup_items(entries))
// 131:         .to eql(%w[github.com/golangci/golangci-lint/v2/cmd/golangci-lint])
// 132:     end
// 133:
// 134:     it "returns frozen empty array when go is not installed" do
// 135:       allow(described_class).to receive(:package_manager_installed?).and_return(false)
// 136:       entries = [Homebrew::Bundle::Dsl::Entry.new(:go, "github.com/charmbracelet/crush")]
// 137:       expect(described_class.cleanup_items(entries)).to eql([])
// 138:     end
// 139:   end
// 140: end
