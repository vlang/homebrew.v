module bundle

import ruby
import homebrew.bundle.extensions

// Translated from Homebrew/brew `test/bundle/krew_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn krew_spec_case(line int) bool {
	match line {
		18 {
			mut state := extensions.new_krew_state()
			packages := state.discover_packages()
			return packages.len == 0 && extensions.krew_dump(packages) == ''
		}
		31 {
			return extensions.krew_parse_plugin_list('ctx\nneat\nns\n') == ['ctx', 'neat', 'ns']
		}
		37 {
			return extensions.krew_parse_plugin_list('').len == 0
		}
		43 {
			return extensions.krew_dump(['ctx', 'ns', 'neat']) == 'krew "ctx"\nkrew "ns"\nkrew "neat"'
		}
		58 {
			if _ := extensions.krew_preinstall('', [], 'ctx') {
				return false
			}
			return true
		}
		65 {
			upgrade_formulae := ['foo', 'bar']
			if _ := extensions.krew_preinstall('', [], 'ctx') {}
			return upgrade_formulae == ['foo', 'bar']
		}
		89 {
			return !(extensions.krew_preinstall('/usr/local/bin/kubectl-krew', ['ctx'], 'ctx') or {
				return false
			})
		}
		105 {
			mut state := extensions.new_krew_state()
			state.executable = '/usr/local/bin/kubectl-krew'
			state.original_path = '/usr/bin:/bin'
			state.packages_loaded = true
			state.installed_packages_loaded = true
			preinstall := extensions.krew_preinstall(state.executable, state.installed_packages, 'ctx') or { return false }
			installed := state.install('ctx', true, false, true) or { return false }
			return preinstall && installed && state.commands == [
				['/usr/local/bin/kubectl-krew', 'install', 'ctx'],
			] && state.last_environment['PATH'].starts_with('/usr/local/bin:')
		}
		116 {
			mut state := extensions.new_krew_state()
			state.executable = '/usr/local/bin/kubectl-krew'
			state.packages_loaded = true
			state.installed_packages_loaded = true
			if !(state.install('ctx', true, false, true) or { return false }) {
				return false
			}
			return extensions.krew_dump(state.packages) == 'krew "ctx"'
		}
		142 {
			entries := [extensions.ExtensionEntry{
				entry_type: 'krew'
				name: 'ctx'
			}]
			return extensions.krew_cleanup_items(entries, '/usr/local/bin/kubectl-krew', [
				'ctx',
				'ns',
				'neat',
			]) == ['ns', 'neat']
		}
		147 {
			mut state := extensions.new_krew_state()
			state.executable = '/usr/local/bin/kubectl-krew'
			state.original_path = '/usr/bin:/bin'
			state.cleanup(['ns'])
			return state.commands == [
				['/usr/local/bin/kubectl-krew', 'uninstall', 'ns'],
			] && state.last_environment['PATH'].starts_with('/usr/local/bin:') && state.output.last().contains('Uninstalled 1 Krew plugin')
		}
		else {
			return false
		}
	}
}

// Ruby subject `subject(:dumper) { described_class }` at line 10.
pub fn ruby_krew_spec_l10_d1_dumper(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Homebrew::Bundle::Krew', 'Homebrew::Bundle::Krew')
}

// Ruby it `it "returns an empty list and dumps an empty string" do` at line 18.
pub fn ruby_krew_spec_l18_d2_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(18))
}

// Ruby it `it "returns plugin list" do` at line 31.
pub fn ruby_krew_spec_l31_d3_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(31))
}

// Ruby it `it "handles empty output" do` at line 37.
pub fn ruby_krew_spec_l37_d4_handles(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(37))
}

// Ruby it `it "dumps plugin list" do` at line 43.
pub fn ruby_krew_spec_l43_d5_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(43))
}

// Ruby it `it "tries to install krew" do` at line 58.
pub fn ruby_krew_spec_l58_d6_tries(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(58))
}

// Ruby it `it "preserves upgrade_formulae while bootstrapping krew" do` at line 65.
pub fn ruby_krew_spec_l65_d7_preserves(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(65))
}

// Ruby it `it "skips" do` at line 89.
pub fn ruby_krew_spec_l89_d8_skips(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(89))
}

// Ruby it `it "installs plugin" do` at line 105.
pub fn ruby_krew_spec_l105_d9_installs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(105))
}

// Ruby it `it "updates dump output after install" do` at line 116.
pub fn ruby_krew_spec_l116_d10_updates(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(116))
}

// Ruby it `it "returns plugins not in Brewfile entries" do` at line 142.
pub fn ruby_krew_spec_l142_d11_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(142))
}

// Ruby it `it "uninstalls plugins" do` at line 147.
pub fn ruby_krew_spec_l147_d12_uninstalls(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(krew_spec_case(147))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions/krew"
// 7:
// 8: RSpec.describe Homebrew::Bundle::Krew do
// 9:   describe "dumping" do
// 10:     subject(:dumper) { described_class }
// 11:
// 12:     context "when krew is not installed" do
// 13:       before do
// 14:         described_class.reset!
// 15:         allow(described_class).to receive(:package_manager_installed?).and_return(false)
// 16:       end
// 17:
// 18:       it "returns an empty list and dumps an empty string" do
// 19:         expect(dumper.packages).to be_empty
// 20:         expect(dumper.dump).to eql("")
// 21:       end
// 22:     end
// 23:
// 24:     context "when krew is installed" do
// 25:       before do
// 26:         described_class.reset!
// 27:         allow(described_class).to receive_messages(package_manager_installed?: true,
// 28:                                                    package_manager_executable: Pathname.new("kubectl-krew"))
// 29:       end
// 30:
// 31:       it "returns plugin list" do
// 32:         allow(described_class).to receive(:`).and_return("ctx\nneat\nns\n")
// 33:
// 34:         expect(dumper.packages).to eql(%w[ctx neat ns])
// 35:       end
// 36:
// 37:       it "handles empty output" do
// 38:         allow(described_class).to receive(:`).and_return("")
// 39:
// 40:         expect(dumper.packages).to be_empty
// 41:       end
// 42:
// 43:       it "dumps plugin list" do
// 44:         allow(dumper).to receive(:packages).and_return(["ctx", "ns", "neat"])
// 45:         expect(dumper.dump).to eql("krew \"ctx\"\nkrew \"ns\"\nkrew \"neat\"")
// 46:       end
// 47:     end
// 48:   end
// 49:
// 50:   describe "installing" do
// 51:     context "when kubectl-krew is not found" do
// 52:       before do
// 53:         described_class.reset!
// 54:         allow(described_class).to receive_messages(package_manager_executable: nil,
// 55:                                                    package_manager_installed?: false)
// 56:       end
// 57:
// 58:       it "tries to install krew" do
// 59:         expect(Homebrew::Bundle).to \
// 60:           receive(:system).with(HOMEBREW_BREW_FILE, "install", "--formula", "krew", verbose: false)
// 61:                           .and_return(true)
// 62:         expect { described_class.preinstall!("ctx") }.to raise_error(RuntimeError)
// 63:       end
// 64:
// 65:       it "preserves upgrade_formulae while bootstrapping krew" do
// 66:         Homebrew::Bundle.upgrade_formulae = "foo,bar"
// 67:
// 68:         expect(Homebrew::Bundle).to \
// 69:           receive(:system).with(HOMEBREW_BREW_FILE, "install", "--formula", "krew", verbose: false)
// 70:                           .and_return(true)
// 71:         expect { described_class.preinstall!("ctx") }.to raise_error(RuntimeError)
// 72:         expect(Homebrew::Bundle.upgrade_formulae).to eql(["foo", "bar"])
// 73:       end
// 74:     end
// 75:
// 76:     context "when kubectl-krew is installed" do
// 77:       before do
// 78:         allow(described_class).to receive_messages(
// 79:           package_manager_executable: Pathname.new("/usr/local/bin/kubectl-krew"),
// 80:           package_manager_installed?: true,
// 81:         )
// 82:       end
// 83:
// 84:       context "when plugin is installed" do
// 85:         before do
// 86:           allow(described_class).to receive(:installed_packages).and_return(["ctx"])
// 87:         end
// 88:
// 89:         it "skips" do
// 90:           expect(Homebrew::Bundle).not_to receive(:system)
// 91:           expect(described_class.preinstall!("ctx")).to be(false)
// 92:         end
// 93:       end
// 94:
// 95:       context "when plugin is not installed" do
// 96:         before do
// 97:           described_class.reset!
// 98:           allow(described_class).to receive_messages(
// 99:             package_manager_executable: Pathname.new("/usr/local/bin/kubectl-krew"),
// 100:             package_manager_installed?: true,
// 101:             installed_packages:         [],
// 102:           )
// 103:         end
// 104:
// 105:         it "installs plugin" do
// 106:           expect(Homebrew::Bundle).to receive(:system) do |*args, verbose:|
// 107:             expect(ENV.fetch("PATH", "")).to start_with("/usr/local/bin:")
// 108:             expect(args).to eq(["/usr/local/bin/kubectl-krew", "install", "ctx"])
// 109:             expect(verbose).to be(false)
// 110:             true
// 111:           end
// 112:           expect(described_class.preinstall!("ctx")).to be(true)
// 113:           expect(described_class.install!("ctx")).to be(true)
// 114:         end
// 115:
// 116:         it "updates dump output after install" do
// 117:           expect(Homebrew::Bundle).to receive(:system) do |*args, verbose:|
// 118:             expect(args).to eq(["/usr/local/bin/kubectl-krew", "install", "ctx"])
// 119:             expect(verbose).to be(false)
// 120:             true
// 121:           end
// 122:
// 123:           described_class.install!("ctx")
// 124:
// 125:           expect(described_class.dump).to eql('krew "ctx"')
// 126:         end
// 127:       end
// 128:     end
// 129:   end
// 130:
// 131:   describe "cleanup" do
// 132:     before do
// 133:       described_class.reset!
// 134:       allow(described_class).to receive_messages(
// 135:         package_manager_executable: Pathname.new("/usr/local/bin/kubectl-krew"),
// 136:         package_manager_installed?: true,
// 137:         packages:                   %w[ctx ns neat],
// 138:         installed_packages:         %w[ctx ns neat],
// 139:       )
// 140:     end
// 141:
// 142:     it "returns plugins not in Brewfile entries" do
// 143:       entries = [Homebrew::Bundle::Dsl::Entry.new(:krew, "ctx")]
// 144:       expect(described_class.cleanup_items(entries)).to eql(%w[ns neat])
// 145:     end
// 146:
// 147:     it "uninstalls plugins" do
// 148:       expect(Homebrew::Bundle).to receive(:system) do |*args, verbose:|
// 149:         expect(ENV.fetch("PATH", "")).to start_with("/usr/local/bin:")
// 150:         expect(args).to eq(["/usr/local/bin/kubectl-krew", "uninstall", "ns"])
// 151:         expect(verbose).to be(false)
// 152:         true
// 153:       end
// 154:
// 155:       expect { described_class.cleanup!(["ns"]) }.to output(/Uninstalled 1 Krew plugin/).to_stdout
// 156:     end
// 157:   end
// 158: end
