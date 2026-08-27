module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/reinstall_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports unavailable names via ofail and continues reinstalling" do` at line 11.
pub fn ruby_reinstall_spec_l11_d1_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "does not reinstall a pinned Cask" do` at line 29.
pub fn ruby_reinstall_spec_l29_d2_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "asks for casks before shared prefetch when reinstalling formulae and casks" do` at line 45.
pub fn ruby_reinstall_spec_l45_d3_asks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('asks', ...args)
}

// Ruby it `it "starts formula prelude fetches before dependant checks when not asking" do` at line 88.
pub fn ruby_reinstall_spec_l88_d4_starts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('starts', ...args)
}

// Ruby it `it "reinstalls the remaining formulae after one fails" do` at line 129.
pub fn ruby_reinstall_spec_l129_d5_reinstalls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reinstalls', ...args)
}

// Ruby it `it "reinstalls a Formula", :integration_test do` at line 167.
pub fn ruby_reinstall_spec_l167_d6_reinstalls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reinstalls', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/ENV"
// 5: require "cmd/reinstall"
// 6: require "cmd/shared_examples/args_parse"
// 7:
// 8: RSpec.describe Homebrew::Cmd::Reinstall do
// 9:   it_behaves_like "parseable arguments"
// 10:
// 11:   it "reports unavailable names via ofail and continues reinstalling" do
// 12:     error = FormulaOrCaskUnavailableError.new("nonexistent")
// 13:     formula = instance_double(Formula, full_name: "testball", pinned?: false)
// 14:     allow(formula).to receive(:latest_formula).and_return(formula)
// 15:
// 16:     cmd = described_class.new(["testball", "nonexistent"])
// 17:     allow(cmd.args.named).to receive(:to_formulae_and_casks_and_unavailable)
// 18:       .with(method: :resolve)
// 19:       .and_return([formula, error])
// 20:     expect(Homebrew::Trust).to receive(:trust_fully_qualified_items!)
// 21:       .with(["testball", "nonexistent"], type: nil)
// 22:
// 23:     expect { cmd.run }
// 24:       .to output(/nonexistent/).to_stderr
// 25:
// 26:     expect(Homebrew).to have_failed
// 27:   end
// 28:
// 29:   it "does not reinstall a pinned Cask" do
// 30:     cask = Cask::Cask.new("local-caffeine")
// 31:     allow(cask).to receive_messages(pinned?: true, full_name: "local-caffeine")
// 32:
// 33:     cmd = described_class.new(["local-caffeine"])
// 34:     allow(cmd.args.named).to receive(:to_formulae_and_casks_and_unavailable)
// 35:       .with(method: :resolve)
// 36:       .and_return([cask])
// 37:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 38:     allow(Homebrew.messages).to receive(:display_messages)
// 39:
// 40:     expect(Cask::Reinstall).not_to receive(:reinstall_casks)
// 41:     expect { cmd.run }
// 42:       .to output(/local-caffeine is pinned\. You must unpin it to reinstall\./).to_stderr
// 43:   end
// 44:
// 45:   it "asks for casks before shared prefetch when reinstalling formulae and casks" do
// 46:     cmd = described_class.new(["testball", "local-caffeine"])
// 47:     formula = formula("testball") do
// 48:       T.bind(self, T.class_of(Formula))
// 49:       url "https://brew.sh/testball-0.1.tar.gz"
// 50:     end
// 51:     formula_installer = FormulaInstaller.new(formula)
// 52:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 53:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 54:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, shutdown: nil, failed_downloads: [])
// 55:     reinstall_context = Homebrew::Reinstall::InstallationContext.new(
// 56:       formula_installer:,
// 57:       formula:,
// 58:       keg:               nil,
// 59:       options:           Options.create([]),
// 60:     )
// 61:
// 62:     allow(cmd.args.named).to receive(:to_formulae_and_casks_and_unavailable)
// 63:       .with(method: :resolve)
// 64:       .and_return([formula, cask])
// 65:     allow(formula).to receive(:latest_formula).and_return(formula)
// 66:     allow(Migrator).to receive(:migrate_if_needed)
// 67:     allow(Homebrew::Install).to receive(:perform_preinstall_checks_once)
// 68:     allow(Homebrew::Reinstall).to receive(:build_install_context).and_return(reinstall_context)
// 69:     allow(Homebrew::Upgrade).to receive(:dependants).and_return(dependants)
// 70:     allow(Homebrew::Install).to receive(:ask_formulae)
// 71:     allow(Homebrew::Install).to receive(:enqueue_formulae).and_return([formula_installer])
// 72:     allow(Homebrew::Install).to receive(:enqueue_cask_installers)
// 73:     allow(Cask::Installer).to receive(:new).and_return(instance_double(Cask::Installer))
// 74:     allow(Homebrew::Reinstall).to receive(:reinstall_formula)
// 75:     allow(Homebrew::Upgrade).to receive(:upgrade_dependents)
// 76:     allow(Cask::Reinstall).to receive(:reinstall_casks)
// 77:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 78:     allow(Homebrew.messages).to receive(:display_messages)
// 79:
// 80:     expect(Homebrew::Install).to receive(:ask_casks)
// 81:       .with([cask], action: "reinstallation", skip_cask_deps: false)
// 82:       .ordered
// 83:     expect(Homebrew::DownloadQueue).to receive(:new).ordered.and_return(download_queue)
// 84:
// 85:     cmd.run
// 86:   end
// 87:
// 88:   it "starts formula prelude fetches before dependant checks when not asking" do
// 89:     cmd = described_class.new(["--yes", "testball"])
// 90:     download_queue = instance_double(Homebrew::DownloadQueue, shutdown: nil)
// 91:     formula = formula("testball") do
// 92:       T.bind(self, T.class_of(Formula))
// 93:       url "https://brew.sh/testball-0.1.tar.gz"
// 94:     end
// 95:     formula_installer = FormulaInstaller.new(formula)
// 96:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 97:     reinstall_context = Homebrew::Reinstall::InstallationContext.new(
// 98:       formula_installer:,
// 99:       formula:,
// 100:       keg:               nil,
// 101:       options:           Options.create([]),
// 102:     )
// 103:
// 104:     allow(Homebrew::Trust).to receive(:trust_fully_qualified_items!)
// 105:     allow(cmd.args.named).to receive(:to_formulae_and_casks_and_unavailable)
// 106:       .with(method: :resolve)
// 107:       .and_return([formula])
// 108:     allow(formula).to receive_messages(latest_formula: formula, pinned?: false)
// 109:     allow(Migrator).to receive(:migrate_if_needed)
// 110:     allow(Homebrew::Install).to receive(:perform_preinstall_checks_once)
// 111:     allow(Homebrew::Reinstall).to receive(:build_install_context).and_return(reinstall_context)
// 112:     allow(Homebrew::Reinstall).to receive(:reinstall_formula)
// 113:     allow(Homebrew::Upgrade).to receive(:upgrade_dependents)
// 114:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 115:     allow(Homebrew.messages).to receive(:display_messages)
// 116:     expect(Homebrew::DownloadQueue).to receive(:new).ordered.and_return(download_queue)
// 117:     expect(formula_installer).to receive(:download_queue=).with(download_queue).ordered
// 118:     expect(formula_installer).to receive(:prelude_fetch).ordered
// 119:     expect(Homebrew::Upgrade).to receive(:dependants).ordered.and_return(dependants)
// 120:     expect(Homebrew::Install).to receive(:fetch_formulae)
// 121:       .with([formula_installer], download_queue:, shutdown_download_queue: false)
// 122:       .ordered
// 123:       .and_return([formula_installer])
// 124:     expect(download_queue).to receive(:shutdown).ordered
// 125:
// 126:     cmd.run
// 127:   end
// 128:
// 129:   it "reinstalls the remaining formulae after one fails" do
// 130:     cmd = described_class.new(["--yes", "one", "two"])
// 131:     download_queue = instance_double(Homebrew::DownloadQueue, shutdown: nil, failed_downloads: [])
// 132:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 133:     contexts = %w[one two].map do |name|
// 134:       formula = formula(name) do
// 135:         T.bind(self, T.class_of(Formula))
// 136:         url "https://brew.sh/#{name}-0.1.tar.gz"
// 137:       end
// 138:       allow(formula).to receive_messages(latest_formula: formula, pinned?: false)
// 139:       Homebrew::Reinstall::InstallationContext.new(
// 140:         formula_installer: FormulaInstaller.new(formula),
// 141:         formula:,
// 142:         keg:               nil,
// 143:         options:           Options.create([]),
// 144:       )
// 145:     end
// 146:
// 147:     allow(Homebrew::Trust).to receive(:trust_fully_qualified_items!)
// 148:     allow(cmd.args.named).to receive(:to_formulae_and_casks_and_unavailable)
// 149:       .with(method: :resolve)
// 150:       .and_return(contexts.map(&:formula))
// 151:     allow(Migrator).to receive(:migrate_if_needed)
// 152:     allow(Homebrew::Install).to receive(:perform_preinstall_checks_once)
// 153:     allow(Homebrew::DownloadQueue).to receive(:new).and_return(download_queue)
// 154:     allow(Homebrew::Reinstall).to receive(:build_install_context).and_return(*contexts)
// 155:     allow(Homebrew::Install).to receive(:fetch_formulae).and_return(contexts.map(&:formula_installer))
// 156:     allow(Homebrew::Reinstall).to receive(:reinstall_formula).with(contexts.fetch(0))
// 157:                                                              .and_raise("gzip decompression failed")
// 158:     allow(Homebrew::Cleanup).to receive_messages(install_formula_clean!: nil, periodic_clean!: nil)
// 159:     allow(Homebrew::Upgrade).to receive_messages(dependants:, upgrade_dependents: [])
// 160:     allow(Homebrew.messages).to receive(:display_messages)
// 161:
// 162:     expect(Homebrew::Reinstall).to receive(:reinstall_formula).with(contexts.fetch(1))
// 163:
// 164:     expect { cmd.run }.to output(/Error: one: gzip decompression failed/).to_stderr
// 165:   end
// 166:
// 167:   it "reinstalls a Formula", :integration_test do
// 168:     formula_name = "testball_bottle"
// 169:     formula_prefix = HOMEBREW_CELLAR/formula_name/"0.1"
// 170:     formula_bin = formula_prefix/"bin"
// 171:
// 172:     setup_test_formula formula_name, tab_attributes: { installed_on_request: true }
// 173:     Keg.new(formula_prefix).link
// 174:
// 175:     expect(formula_bin).not_to exist
// 176:
// 177:     expect { brew "reinstall", formula_name }
// 178:       .to output(/Reinstalling #{formula_name}/).to_stdout
// 179:       .and output(/✔︎.*/m).to_stderr
// 180:       .and be_a_success
// 181:     expect(formula_bin).to exist
// 182:   end
// 183: end
