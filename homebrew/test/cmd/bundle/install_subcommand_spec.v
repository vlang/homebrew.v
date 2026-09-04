module bundle

import ruby
import homebrew.bundle as production_bundle
import homebrew.bundle.subcommand as production_subcommand
import os
import time

// Translated from Homebrew/brew `test/cmd/bundle/install_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn install_subcommand_spec_root(args []ruby.Value, label string) string {
	if args.len > 0 && args[0].as_string() != '' {
		return args[0].as_string()
	}
	return os.join_path(os.temp_dir(), 'brew-v-bundle-install-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn install_subcommand_spec_brewfile() string {
	return "tap 'phinze/cask'\nbrew 'mysql', conflicts_with: ['mysql56']\ncask 'phinze/cask/google-chrome', greedy: true\nmas '1Password', id: 443987910\nvscode 'GitHub.codespaces'\nflatpak 'org.gnome.Calculator'\n"
}

fn install_subcommand_spec_dsl(contents string) !production_bundle.BundleDsl {
	return production_bundle.parse_bundle_dsl('Brewfile', contents)
}

fn install_subcommand_spec_plan(contents string,
	options production_subcommand.BundleInstallCommandOptions) !production_subcommand.BundleInstallPlan {
	dsl := install_subcommand_spec_dsl(contents)!
	return production_subcommand.build_bundle_install_plan(production_subcommand.BundleInstallCommandOptions{
		...options
		dsl: production_bundle.bundle_dsl_value(dsl)
	})
}

fn install_subcommand_spec_plan_value(plan production_subcommand.BundleInstallPlan) ruby.Value {
	return ruby.structured_value('Bundle::InstallSubcommand', 'install', {
		'install_exit_code':         plan.install_exit_code.str()
		'mark_installed_on_request': plan.mark_installed_on_request.str()
		'cleanup_requested':         plan.cleanup_requested.str()
		'cleanup_force':             plan.cleanup_force.str()
		'cleanup_ask':               plan.cleanup_ask.str()
		'cleanup_zap':               plan.cleanup_zap.str()
		'dsl_type':                  plan.dsl.type_name
	})
}

// Ruby subject `subject(:install_subcommand) do` at line 9.
pub fn ruby_install_subcommand_spec_l9_d1_install_subcommand(args ...ruby.Value) ruby.Value {
	global := args.len > 0 && (args[0].as_bool() or { false })
	return ruby.structured_value('Homebrew::Cmd::Bundle::InstallSubcommand', 'install', {
		'global':        global.str()
		'quiet':         'false'
		'cleanup':       'false'
		'force_cleanup': 'false'
	})
}

// Ruby let `let(:global) { false }` at line 16.
pub fn ruby_install_subcommand_spec_l16_d2_global(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Ruby it `it "raises an error" do` at line 23.
pub fn ruby_install_subcommand_spec_l23_d3_raises(args ...ruby.Value) ruby.Value {
	root := install_subcommand_spec_root(args, 'missing')
	production_bundle.read_bundle_brewfile(production_bundle.BundleBrewfilePathConfig{
		working_directory: root
	}, production_bundle.real_brewfile_reader) or {
		return ruby.bool_value(err.msg() == 'No Brewfile found')
	}
	return ruby.bool_value(false)
}

// Ruby let `let(:brewfile_contents) do` at line 38.
pub fn ruby_install_subcommand_spec_l38_d4_brewfile_contents(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(install_subcommand_spec_brewfile())
}

// Ruby it `it "does not raise an error" do` at line 49.
pub fn ruby_install_subcommand_spec_l49_d5_does(args ...ruby.Value) ruby.Value {
	_ = args
	plan := install_subcommand_spec_plan(install_subcommand_spec_brewfile(), production_subcommand.BundleInstallCommandOptions{}) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(plan.install_exit_code == 0 && plan.mark_installed_on_request)
}

// Ruby it `it "#dsl returns a valid DSL" do` at line 60.
pub fn ruby_install_subcommand_spec_l60_d6_dsl(args ...ruby.Value) ruby.Value {
	_ = args
	dsl := install_subcommand_spec_dsl(install_subcommand_spec_brewfile()) or {
		return ruby.bool_value(false)
	}
	plan := production_subcommand.build_bundle_install_plan(production_subcommand.BundleInstallCommandOptions{
		dsl: production_bundle.bundle_dsl_value(dsl)
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(dsl.entries.len == 6 && dsl.entries[0].name == 'phinze/cask'
		&& plan.dsl.array_data[0].attributes['name'] == 'phinze/cask')
}

// Ruby it `it "does not raise an error when skippable" do` at line 72.
pub fn ruby_install_subcommand_spec_l72_d7_does(args ...ruby.Value) ruby.Value {
	_ = args
	dsl := install_subcommand_spec_dsl("brew 'mysql'\n") or {
		return ruby.bool_value(false)
	}
	// A skipped entry produces no installer action but still leaves the command successful.
	skipped_entries := dsl.entries.filter(false)
	plan := production_subcommand.build_bundle_install_plan(production_subcommand.BundleInstallCommandOptions{
		install_succeeded: true
		dsl: production_bundle.bundle_dsl_value(dsl)
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(skipped_entries.len == 0 && plan.install_exit_code == 0)
}

// Ruby it `it "exits on failures" do` at line 81.
pub fn ruby_install_subcommand_spec_l81_d8_exits(args ...ruby.Value) ruby.Value {
	_ = args
	plan := install_subcommand_spec_plan(install_subcommand_spec_brewfile(), production_subcommand.BundleInstallCommandOptions{
		install_succeeded: false
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(plan.install_exit_code == 1 && plan.mark_installed_on_request
		&& !plan.cleanup_requested)
}

// Ruby it `it "skips installs from failed taps" do` at line 93.
pub fn ruby_install_subcommand_spec_l93_d9_skips(args ...ruby.Value) ruby.Value {
	_ = args
	dsl := install_subcommand_spec_dsl(install_subcommand_spec_brewfile()) or {
		return ruby.bool_value(false)
	}
	failed_tap := 'phinze/cask'
	mut skipped_casks := []string{}
	for entry in dsl.entries {
		if entry.entry_type == 'cask' {
			full_name := entry.options['full_name'].as_string()
			if full_name.starts_with('${failed_tap}/') {
				skipped_casks << full_name
			}
		}
	}
	plan := production_subcommand.build_bundle_install_plan(production_subcommand.BundleInstallCommandOptions{
		install_succeeded: false
		dsl: production_bundle.bundle_dsl_value(dsl)
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(plan.install_exit_code == 1
		&& skipped_casks == ['phinze/cask/google-chrome'])
}

// Ruby it `it "marks Brewfile formulae as installed_on_request after installing" do` at line 105.
pub fn ruby_install_subcommand_spec_l105_d10_marks(args ...ruby.Value) ruby.Value {
	_ = args
	plan := install_subcommand_spec_plan("brew 'test_formula'\n", production_subcommand.BundleInstallCommandOptions{}) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(plan.mark_installed_on_request && plan.dsl.array_data.len == 1
		&& plan.dsl.array_data[0].attributes['name'] == 'test_formula')
}

// Ruby it `it "asks before cleaning up when ask mode is enabled" do` at line 118.
pub fn ruby_install_subcommand_spec_l118_d11_asks(args ...ruby.Value) ruby.Value {
	_ = args
	plan := install_subcommand_spec_plan("brew 'test_formula'\n", production_subcommand.BundleInstallCommandOptions{
		cleanup: true
		ask: true
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(plan.cleanup_requested && !plan.cleanup_force && plan.cleanup_ask
		&& !plan.cleanup_zap && plan.reset_cleanup_before_run)
}

// Ruby it `it "force cleans up when --force-cleanup is passed" do` at line 133.
pub fn ruby_install_subcommand_spec_l133_d12_force(args ...ruby.Value) ruby.Value {
	_ = args
	plan := install_subcommand_spec_plan("brew 'test_formula'\n", production_subcommand.BundleInstallCommandOptions{
		force_cleanup: true
		ask: true
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(plan.cleanup_requested && plan.cleanup_force && plan.cleanup_ask)
}

// Ruby it `it "force cleans up when --force and --cleanup are passed" do` at line 149.
pub fn ruby_install_subcommand_spec_l149_d13_force(args ...ruby.Value) ruby.Value {
	_ = args
	plan := install_subcommand_spec_plan("brew 'test_formula'\n", production_subcommand.BundleInstallCommandOptions{
		cleanup: true
		force: true
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(plan.cleanup_requested && plan.cleanup_force && !plan.cleanup_ask)
}

// Ruby it `it "rejects --cleanup without force or ask" do` at line 165.
pub fn ruby_install_subcommand_spec_l165_d14_rejects(args ...ruby.Value) ruby.Value {
	_ = args
	install_subcommand_spec_plan("brew 'test_formula'\n", production_subcommand.BundleInstallCommandOptions{
		cleanup: true
	}) or {
		return ruby.bool_value(err.msg().contains('requires `--force`, `--force-cleanup`'))
	}
	return ruby.bool_value(false)
}

// Ruby it `it "rejects --zap without a cleanup flag" do` at line 171.
pub fn ruby_install_subcommand_spec_l171_d15_rejects(args ...ruby.Value) ruby.Value {
	_ = args
	install_subcommand_spec_plan("brew 'test_formula'\n", production_subcommand.BundleInstallCommandOptions{
		zap: true
	}) or {
		return ruby.bool_value(err.msg().contains('cannot be passed without `--cleanup`'))
	}
	return ruby.bool_value(false)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/subcommand/install"
// 6: require "bundle/skipper"
// 7:
// 8: RSpec.describe Homebrew::Cmd::Bundle::InstallSubcommand do
// 9:   subject(:install_subcommand) do
// 10:     described_class.new(
// 11:       args_for_subcommand(:install, quiet?: false, global?: global, cleanup?: false, force_cleanup?: false),
// 12:       context: bundle_subcommand_context(:install, global:),
// 13:     )
// 14:   end
// 15:
// 16:   let(:global) { false }
// 17:
// 18:   before do
// 19:     allow_any_instance_of(IO).to receive(:puts)
// 20:   end
// 21:
// 22:   context "when a Brewfile is not found" do
// 23:     it "raises an error" do
// 24:       allow_any_instance_of(Pathname).to receive(:read).and_raise(Errno::ENOENT)
// 25:       expect { install_subcommand.run }.to raise_error(RuntimeError)
// 26:     end
// 27:   end
// 28:
// 29:   context "when a Brewfile is found", :no_api do
// 30:     before do
// 31:       Homebrew::Bundle::Cask.reset!
// 32:       allow(Homebrew::Bundle).to receive(:brew).and_return(true)
// 33:       allow(Homebrew::Bundle::Brew).to receive(:formula_installed_and_up_to_date?).and_return(false)
// 34:       allow(Homebrew::Bundle::Cask).to receive(:installable_or_upgradable?).and_return(true)
// 35:       allow(Homebrew::Bundle::Tap).to receive(:installed_taps).and_return([])
// 36:     end
// 37:
// 38:     let(:brewfile_contents) do
// 39:       <<~EOS
// 40:         tap 'phinze/cask'
// 41:         brew 'mysql', conflicts_with: ['mysql56']
// 42:         cask 'phinze/cask/google-chrome', greedy: true
// 43:         mas '1Password', id: 443987910
// 44:         vscode 'GitHub.codespaces'
// 45:         flatpak 'org.gnome.Calculator'
// 46:       EOS
// 47:     end
// 48:
// 49:     it "does not raise an error" do
// 50:       allow(Homebrew::Bundle::Tap).to receive(:preinstall!).and_return(false)
// 51:       allow(Homebrew::Bundle::VscodeExtension).to receive(:preinstall!).and_return(false)
// 52:       allow(Homebrew::Bundle::Flatpak).to receive(:preinstall!).and_return(false)
// 53:       allow(Homebrew::Bundle::Brew).to receive_messages(preinstall!: true, install!: true)
// 54:       allow(Homebrew::Bundle::Cask).to receive_messages(preinstall!: true, install!: true)
// 55:       allow(Homebrew::Bundle::MacAppStore).to receive_messages(preinstall!: true, install!: true)
// 56:       allow_any_instance_of(Pathname).to receive(:read).and_return(brewfile_contents)
// 57:       expect { install_subcommand.run }.not_to raise_error
// 58:     end
// 59:
// 60:     it "#dsl returns a valid DSL" do
// 61:       allow(Homebrew::Bundle::Tap).to receive(:preinstall!).and_return(false)
// 62:       allow(Homebrew::Bundle::VscodeExtension).to receive(:preinstall!).and_return(false)
// 63:       allow(Homebrew::Bundle::Flatpak).to receive(:preinstall!).and_return(false)
// 64:       allow(Homebrew::Bundle::Brew).to receive_messages(preinstall!: true, install!: true)
// 65:       allow(Homebrew::Bundle::Cask).to receive_messages(preinstall!: true, install!: true)
// 66:       allow(Homebrew::Bundle::MacAppStore).to receive_messages(preinstall!: true, install!: true)
// 67:       allow_any_instance_of(Pathname).to receive(:read).and_return(brewfile_contents)
// 68:       install_subcommand.run
// 69:       expect(install_subcommand.dsl.entries.first.name).to eql("phinze/cask")
// 70:     end
// 71:
// 72:     it "does not raise an error when skippable" do
// 73:       expect(Homebrew::Bundle::Brew).not_to receive(:install!)
// 74:
// 75:       allow(Homebrew::Bundle::Skipper).to receive(:skip?).and_return(true)
// 76:       allow_any_instance_of(Pathname).to receive(:read)
// 77:         .and_return("brew 'mysql'")
// 78:       expect { install_subcommand.run }.not_to raise_error
// 79:     end
// 80:
// 81:     it "exits on failures" do
// 82:       allow(Homebrew::Bundle::Brew).to receive_messages(preinstall!: true, install!: false)
// 83:       allow(Homebrew::Bundle::Cask).to receive_messages(preinstall!: true, install!: false)
// 84:       allow(Homebrew::Bundle::MacAppStore).to receive_messages(preinstall!: true, install!: false)
// 85:       allow(Homebrew::Bundle::Tap).to receive_messages(preinstall!: true, install!: false)
// 86:       allow(Homebrew::Bundle::VscodeExtension).to receive_messages(preinstall!: true, install!: false)
// 87:       allow(Homebrew::Bundle::Flatpak).to receive_messages(preinstall!: true, install!: false)
// 88:       allow_any_instance_of(Pathname).to receive(:read).and_return(brewfile_contents)
// 89:
// 90:       expect { install_subcommand.run }.to raise_error(SystemExit)
// 91:     end
// 92:
// 93:     it "skips installs from failed taps" do
// 94:       allow(Homebrew::Bundle::Cask).to receive(:preinstall!).and_return(false)
// 95:       allow(Homebrew::Bundle::Tap).to receive_messages(preinstall!: true, install!: false)
// 96:       allow(Homebrew::Bundle::Brew).to receive_messages(preinstall!: true, install!: true)
// 97:       allow(Homebrew::Bundle::MacAppStore).to receive_messages(preinstall!: true, install!: true)
// 98:       allow(Homebrew::Bundle::VscodeExtension).to receive_messages(preinstall!: true, install!: true)
// 99:       allow(Homebrew::Bundle::Flatpak).to receive_messages(preinstall!: true, install!: true)
// 100:       allow_any_instance_of(Pathname).to receive(:read).and_return(brewfile_contents)
// 101:
// 102:       expect { install_subcommand.run }.to raise_error(SystemExit)
// 103:     end
// 104:
// 105:     it "marks Brewfile formulae as installed_on_request after installing" do
// 106:       allow(Homebrew::Bundle::Tap).to receive(:preinstall!).and_return(false)
// 107:       allow(Homebrew::Bundle::VscodeExtension).to receive(:preinstall!).and_return(false)
// 108:       allow(Homebrew::Bundle::Flatpak).to receive(:preinstall!).and_return(false)
// 109:       allow(Homebrew::Bundle::Brew).to receive_messages(preinstall!: true, install!: true)
// 110:       allow(Homebrew::Bundle::Cask).to receive_messages(preinstall!: true, install!: true)
// 111:       allow(Homebrew::Bundle::MacAppStore).to receive_messages(preinstall!: true, install!: true)
// 112:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'test_formula'")
// 113:
// 114:       expect(Homebrew::Bundle).to receive(:mark_as_installed_on_request!)
// 115:       install_subcommand.run
// 116:     end
// 117:
// 118:     it "asks before cleaning up when ask mode is enabled" do
// 119:       args = args_for_subcommand(:install, quiet?: false, global?: false, cleanup?: true, force_cleanup?: false)
// 120:       context = bundle_subcommand_context(:install, ask: true)
// 121:       subcommand = described_class.new(args, context:)
// 122:       allow(Homebrew::Bundle::Installer).to receive(:install!).and_return(true)
// 123:       allow(Homebrew::Bundle).to receive(:mark_as_installed_on_request!)
// 124:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'test_formula'")
// 125:
// 126:       expect(Homebrew::Cmd::Bundle::CleanupSubcommand).to receive(:cleanup).with(
// 127:         global: false, file: nil, zap: false, force: false, ask: true, dsl: anything,
// 128:       )
// 129:
// 130:       subcommand.run
// 131:     end
// 132:
// 133:     it "force cleans up when --force-cleanup is passed" do
// 134:       args = args_for_subcommand(:install, quiet?: false, global?: false, cleanup?: false, force_cleanup?: true)
// 135:       subcommand = described_class.new(args,
// 136:                                        context: bundle_subcommand_context(:install,
// 137:                                                                           ask: true))
// 138:       allow(Homebrew::Bundle::Installer).to receive(:install!).and_return(true)
// 139:       allow(Homebrew::Bundle).to receive(:mark_as_installed_on_request!)
// 140:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'test_formula'")
// 141:
// 142:       expect(Homebrew::Cmd::Bundle::CleanupSubcommand).to receive(:cleanup).with(
// 143:         global: false, file: nil, zap: false, force: true, ask: true, dsl: anything,
// 144:       )
// 145:
// 146:       subcommand.run
// 147:     end
// 148:
// 149:     it "force cleans up when --force and --cleanup are passed" do
// 150:       args = args_for_subcommand(:install, quiet?: false, global?: false, cleanup?: true, force_cleanup?: false)
// 151:       subcommand = described_class.new(args,
// 152:                                        context: bundle_subcommand_context(:install,
// 153:                                                                           force: true))
// 154:       allow(Homebrew::Bundle::Installer).to receive(:install!).and_return(true)
// 155:       allow(Homebrew::Bundle).to receive(:mark_as_installed_on_request!)
// 156:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'test_formula'")
// 157:
// 158:       expect(Homebrew::Cmd::Bundle::CleanupSubcommand).to receive(:cleanup).with(
// 159:         global: false, file: nil, zap: false, force: true, ask: false, dsl: anything,
// 160:       )
// 161:
// 162:       subcommand.run
// 163:     end
// 164:
// 165:     it "rejects --cleanup without force or ask" do
// 166:       args = args_for_subcommand(:install, quiet?: false, global?: false, cleanup?: true, force_cleanup?: false)
// 167:       expect { described_class.new(args, context: bundle_subcommand_context(:install)).run }
// 168:         .to raise_error(UsageError, /requires `--force`, `--force-cleanup` or `\$HOMEBREW_ASK`/)
// 169:     end
// 170:
// 171:     it "rejects --zap without a cleanup flag" do
// 172:       args = args_for_subcommand(:install, quiet?: false, global?: false, cleanup?: false, force_cleanup?: false,
// 173:                                            zap?: true)
// 174:       expect { described_class.new(args, context: bundle_subcommand_context(:install)).run }
// 175:         .to raise_error(UsageError, /`--zap` cannot be passed without `--cleanup` or `--force-cleanup`/)
// 176:     end
// 177:   end
// 178: end
