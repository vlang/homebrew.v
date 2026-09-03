module cask

import brew_runtime
import homebrew
import homebrew.cask as uninstall_core
import os
import time

// Translated from Homebrew/brew `test/cask/uninstall_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn uninstall_spec_noop_block(mut dsl uninstall_core.CaskDSL) ! {
	_ = dsl
}

fn uninstall_spec_temp(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-cask-uninstall-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn uninstall_spec_arg_root(args []brew_runtime.Value, label string) string {
	return if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		uninstall_spec_temp(label)
	}
}

fn uninstall_spec_core(token string, root string) uninstall_core.CaskCore {
	return uninstall_core.new_cask_core(uninstall_core.CaskCoreConfig{
		token: token
		caskroom_root: os.join_path(root, 'Caskroom')
		pinned_root: os.join_path(root, 'pinned')
	}, uninstall_spec_noop_block) or { panic(err) }
}

fn uninstall_spec_cask(token string, root string, installed bool) uninstall_core.CaskUninstallCask {
	return uninstall_core.CaskUninstallCask{
		core: uninstall_spec_core(token, root)
		installed: installed
	}
}

fn uninstall_spec_dependent(token string, cask_dependencies []string) homebrew.CaskDependent {
	return homebrew.new_cask_dependent(homebrew.CaskDependentCask{
		token: token
		full_name: token
		installed: true
		cask_dependencies: cask_dependencies
	}, homebrew.CaskDependentGraph{
		installed_casks: cask_dependencies.clone()
	})
}

fn uninstall_spec_target(token string) uninstall_core.CaskUninstallCask {
	return uninstall_spec_cask(token, uninstall_spec_temp('target-${token}'), true)
}

// Ruby it `it "displays the uninstallation progress" do` at line 8.
pub fn ruby_uninstall_spec_l8_d1_displays(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'progress')
	cask := uninstall_core.CaskUninstallCask{
		...uninstall_spec_cask('local-caffeine', root, true)
		installed_versions: ['1.2.3']
		installer_messages: [
			"==> Backing up App 'Caffeine.app' to '${root}/Caffeine.app'",
			"==> Removing App '${root}/Caffeine.app'",
			'==> Purging files for version 1.2.3 of Cask local-caffeine',
		]
	}
	result := uninstall_core.uninstall_casks([cask], uninstall_core.CaskUninstallOptions{})
	return brew_runtime.bool_value(result.final_failure == none && result.stdout.contains('==> Uninstalling Cask local-caffeine') && result.stdout.contains("==> Backing up App 'Caffeine.app'") && result.stdout.contains("==> Removing App '") && result.stdout.contains('==> Purging files for version 1.2.3 of Cask local-caffeine'))
}

// Ruby it `it "shows an error when a Cask is provided that's not installed" do` at line 25.
pub fn ruby_uninstall_spec_l25_d2_shows(args ...brew_runtime.Value) brew_runtime.Value {
	result := uninstall_core.uninstall_casks([
		uninstall_spec_cask('local-caffeine', uninstall_spec_arg_root(args, 'not-installed'), false),
	], uninstall_core.CaskUninstallOptions{})
	failure := result.final_failure or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(failure.type_name == 'Cask::CaskNotInstalledError' && failure.message.contains('is not installed'))
}

// Ruby it `it "tries anyway on a non-present Cask when --force is given" do` at line 32.
pub fn ruby_uninstall_spec_l32_d3_tries(args ...brew_runtime.Value) brew_runtime.Value {
	result := uninstall_core.uninstall_casks([
		uninstall_spec_cask('local-caffeine', uninstall_spec_arg_root(args, 'force-absent'), false),
	], uninstall_core.CaskUninstallOptions{
		force: true
	})
	return brew_runtime.bool_value(result.final_failure == none && result.errors.len == 0)
}

// Ruby it `it "does not uninstall a pinned Cask" do` at line 40.
pub fn ruby_uninstall_spec_l40_d4_does(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'pinned')
	cask := uninstall_core.CaskUninstallCask{
		...uninstall_spec_cask('local-caffeine', root, true)
		pinned: true
	}
	result := uninstall_core.uninstall_casks([cask], uninstall_core.CaskUninstallOptions{})
	return brew_runtime.bool_value(result.final_failure == none && result.casks[0].pinned && result.casks[0].installed && result.uninstalled.len == 0 && result.stderr.contains('local-caffeine is pinned. You must unpin it to uninstall.'))
}

// Ruby it `it "can uninstall and unlink multiple Casks at once" do` at line 54.
pub fn ruby_uninstall_spec_l54_d5_can(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'multiple')
	caffeine_app := os.join_path(root, 'Applications', 'Caffeine.app')
	transmission_app := os.join_path(root, 'Applications', 'Transmission.app')
	os.mkdir_all(caffeine_app) or { return brew_runtime.bool_value(false) }
	os.mkdir_all(transmission_app) or { return brew_runtime.bool_value(false) }
	caffeine := uninstall_core.CaskUninstallCask{
		...uninstall_spec_cask('local-caffeine', root, true)
		artifact_paths: [caffeine_app]
	}
	transmission := uninstall_core.CaskUninstallCask{
		...uninstall_spec_cask('local-transmission-zip', root, true)
		artifact_paths: [transmission_app]
	}
	result := uninstall_core.uninstall_casks([caffeine, transmission], uninstall_core.CaskUninstallOptions{})
	defer {
		os.rmdir_all(root) or {}
	}
	return brew_runtime.bool_value(result.final_failure == none && !result.casks[0].installed && !result.casks[1].installed && !os.exists(caffeine_app) && !os.exists(transmission_app))
}

// Ruby it `it "can uninstall Casks when the uninstall script is missing, but only when using `--force`" do` at line 72.
pub fn ruby_uninstall_spec_l72_d6_can(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'missing-script')
	cask := uninstall_core.CaskUninstallCask{
		...uninstall_spec_cask('with-uninstall-script-app', root, true)
		uninstall_script: os.join_path(root, 'Applications', 'MyFancyApp.app', 'uninstall')
		uninstall_script_missing: true
	}
	failed := uninstall_core.uninstall_casks([cask], uninstall_core.CaskUninstallOptions{})
	failure := failed.final_failure or { return brew_runtime.bool_value(false) }
	forced := uninstall_core.uninstall_casks(failed.casks, uninstall_core.CaskUninstallOptions{
		force: true
	})
	return brew_runtime.bool_value(failure.type_name == 'Cask::CaskError' && failure.message.contains('uninstall script') && failed.casks[0].installed && forced.final_failure == none && !forced.casks[0].installed)
}

// Ruby it `it "continues uninstalling remaining casks when one fails" do` at line 93.
pub fn ruby_uninstall_spec_l93_d7_continues(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'continue')
	caffeine := uninstall_core.CaskUninstallCask{
		...uninstall_spec_cask('local-caffeine', root, true)
		installer_failure: uninstall_core.CaskUninstallFailure{
			type_name: 'Cask::CaskError'
			message: 'caffeine uninstall failed'
		}
	}
	transmission := uninstall_spec_cask('local-transmission-zip', root, true)
	result := uninstall_core.uninstall_casks([caffeine, transmission], uninstall_core.CaskUninstallOptions{})
	failure := result.final_failure or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(failure.type_name == 'Cask::CaskError' && failure.message.contains('caffeine uninstall failed') && result.casks[0].installed && !result.casks[1].installed)
}

// Ruby let `let(:token) { "versioned-cask" }` at line 118.
pub fn ruby_uninstall_spec_l118_d8_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('versioned-cask')
}

// Ruby let `let(:first_installed_version) { "1.2.3" }` at line 119.
pub fn ruby_uninstall_spec_l119_d9_first_installed_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('1.2.3')
}

// Ruby let `let(:last_installed_version) { "4.5.6" }` at line 120.
pub fn ruby_uninstall_spec_l120_d10_last_installed_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('4.5.6')
}

// Ruby let `let(:timestamped_versions) do` at line 121.
pub fn ruby_uninstall_spec_l121_d11_timestamped_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value([
		brew_runtime.string_array_value(['1.2.3', '123000']),
		brew_runtime.string_array_value(['4.5.6', '456000']),
	])
}

// Ruby let `let(:caskroom_path) { Cask::Caskroom.path.join(token).tap(&:mkpath) }` at line 127.
pub fn ruby_uninstall_spec_l127_d12_caskroom_path(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'versioned-path')
	path := uninstall_spec_core('versioned-cask', root).caskroom_path()
	os.mkdir_all(path) or { return brew_runtime.object_value('IOError', err.msg()) }
	return brew_runtime.object_value('Pathname', path)
}

// Ruby it `it "uninstalls one version at a time" do` at line 143.
pub fn ruby_uninstall_spec_l143_d13_uninstalls(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'versioned')
	core := uninstall_spec_core('versioned-cask', root)
	first := os.join_path(core.caskroom_path(), '1.2.3')
	last := os.join_path(core.caskroom_path(), '4.5.6')
	os.mkdir_all(first) or { return brew_runtime.bool_value(false) }
	os.mkdir_all(last) or { return brew_runtime.bool_value(false) }
	cask := uninstall_core.CaskUninstallCask{
		core: core
		installed: true
		installed_versions: ['1.2.3', '4.5.6']
	}
	one := uninstall_core.uninstall_casks([cask], uninstall_core.CaskUninstallOptions{})
	first_pass := os.exists(first) && !os.exists(last) && os.exists(core.caskroom_path())
	two := uninstall_core.uninstall_casks(one.casks, uninstall_core.CaskUninstallOptions{})
	second_pass := !os.exists(first) && !os.exists(core.caskroom_path())
	defer {
		os.rmdir_all(root) or {}
	}
	return brew_runtime.bool_value(one.final_failure == none && two.final_failure == none && first_pass && second_pass)
}

// Ruby let `let(:app) { Cask::Config.new.appdir.join("ive-been-renamed.app") }` at line 158.
pub fn ruby_uninstall_spec_l158_d14_app(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'renamed-app')
	return brew_runtime.object_value('Pathname', os.join_path(root, 'Applications', 'ive-been-renamed.app'))
}

// Ruby let `let(:caskroom_path) { Cask::Caskroom.path.join("ive-been-renamed").tap(&:mkpath) }` at line 159.
pub fn ruby_uninstall_spec_l159_d15_caskroom_path(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'renamed-caskroom')
	path := uninstall_spec_core('ive-been-renamed', root).caskroom_path()
	os.mkdir_all(path) or { return brew_runtime.object_value('IOError', err.msg()) }
	return brew_runtime.object_value('Pathname', path)
}

// Ruby let `let(:saved_caskfile) do` at line 160.
pub fn ruby_uninstall_spec_l160_d16_saved_caskfile(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'renamed-file')
	path := os.join_path(uninstall_spec_core('ive-been-renamed', root).caskroom_path(), '.metadata', 'latest', 'timestamp', 'Casks', 'ive-been-renamed.rb')
	return brew_runtime.object_value('Pathname', path)
}

// Ruby it `it "can still uninstall them" do` at line 184.
pub fn ruby_uninstall_spec_l184_d17_can(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'renamed')
	core := uninstall_spec_core('ive-been-renamed', root)
	app := os.join_path(root, 'Applications', 'ive-been-renamed.app')
	saved := os.join_path(core.caskroom_path(), '.metadata', 'latest', 'timestamp', 'Casks', 'ive-been-renamed.rb')
	os.mkdir_all(os.join_path(app, 'Contents')) or { return brew_runtime.bool_value(false) }
	os.mkdir_all(os.dir(saved)) or { return brew_runtime.bool_value(false) }
	os.write_file(saved, "cask 'ive-been-renamed' do\n  version :latest\n  app 'ive-been-renamed.app'\nend\n") or {
		return brew_runtime.bool_value(false)
	}
	result := uninstall_core.uninstall_casks([uninstall_core.CaskUninstallCask{
		core: core
		installed: true
		artifact_paths: [app]
	}], uninstall_core.CaskUninstallOptions{})
	defer {
		os.rmdir_all(root) or {}
	}
	return brew_runtime.bool_value(result.final_failure == none && !os.exists(app) && !os.exists(core.caskroom_path()))
}

// Ruby let `let(:token) { "removed-cask" }` at line 193.
pub fn ruby_uninstall_spec_l193_d18_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('removed-cask')
}

// Ruby let `let(:caskroom_path) { Cask::Caskroom.path.join(token) }` at line 194.
pub fn ruby_uninstall_spec_l194_d19_caskroom_path(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'removed-caskroom')
	return brew_runtime.object_value('Pathname', uninstall_spec_core('removed-cask', root).caskroom_path())
}

// Ruby let `let(:saved_caskfile) do` at line 195.
pub fn ruby_uninstall_spec_l195_d20_saved_caskfile(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'removed-file')
	path := os.join_path(uninstall_spec_core('removed-cask', root).caskroom_path(), '.metadata', '1.0', '20250101000000.000', 'Casks', 'removed-cask.json')
	return brew_runtime.object_value('Pathname', path)
}

// Ruby it `it "removes Homebrew's records and warns that installed files may remain" do` at line 208.
pub fn ruby_uninstall_spec_l208_d21_removes(args ...brew_runtime.Value) brew_runtime.Value {
	root := uninstall_spec_arg_root(args, 'removed')
	core := uninstall_spec_core('removed-cask', root)
	saved := os.join_path(core.caskroom_path(), '.metadata', '1.0', '20250101000000.000', 'Casks', 'removed-cask.json')
	os.mkdir_all(os.dir(saved)) or { return brew_runtime.bool_value(false) }
	os.write_file(saved, '{}') or { return brew_runtime.bool_value(false) }
	result := uninstall_core.uninstall_casks([uninstall_core.CaskUninstallCask{
		core: core
		installed: true
		incomplete_metadata: true
	}], uninstall_core.CaskUninstallOptions{})
	defer {
		os.rmdir_all(root) or {}
	}
	return brew_runtime.bool_value(result.final_failure == none && result.stderr.contains('files installed by the Cask may remain') && !os.exists(core.caskroom_path()))
}

// Ruby it `it "does not warn when uninstalling as part of an upgrade" do` at line 216.
pub fn ruby_uninstall_spec_l216_d22_does(args ...brew_runtime.Value) brew_runtime.Value {
	cask := uninstall_core.CaskUninstallCask{
		...uninstall_spec_cask('removed-cask', uninstall_spec_arg_root(args, 'upgrade'), true)
		incomplete_metadata: true
		upgrade: true
	}
	installer := uninstall_core.cask_uninstall_installer(cask, uninstall_core.CaskUninstallInstallerRequest{})
	return brew_runtime.bool_value(installer.failure == none && !installer.stderr.any(it.contains('files installed by the Cask may remain')))
}

// Ruby it `it "shows error message when trying to uninstall a cask with dependents" do` at line 225.
pub fn ruby_uninstall_spec_l225_d23_shows(args ...brew_runtime.Value) brew_runtime.Value {
	transmission := uninstall_spec_target('local-transmission-zip')
	result := uninstall_core.check_dependent_casks([transmission], [
		uninstall_spec_dependent('with-depends-on-cask', ['local-transmission-zip']),
		uninstall_spec_dependent('local-transmission-zip', []),
	], ['local-transmission-zip'])
	expected := 'Error: Refusing to uninstall local-transmission-zip\nbecause it is required by with-depends-on-cask, which is currently installed.\nYou can override this and force removal with:\n  brew uninstall --ignore-dependencies local-transmission-zip\n'
	return brew_runtime.bool_value(result.stderr == expected)
}

// Ruby it `it "shows error message when trying to uninstall a cask with multiple dependents" do` at line 243.
pub fn ruby_uninstall_spec_l243_d24_shows(args ...brew_runtime.Value) brew_runtime.Value {
	transmission := uninstall_spec_target('local-transmission-zip')
	result := uninstall_core.check_dependent_casks([transmission], [
		uninstall_spec_dependent('with-depends-on-cask', ['local-transmission-zip']),
		uninstall_spec_dependent('with-depends-on-cask-multiple', ['local-caffeine',
			'local-transmission-zip']),
		uninstall_spec_dependent('local-transmission-zip', []),
	], ['local-transmission-zip'])
	expected := 'Error: Refusing to uninstall local-transmission-zip\nbecause it is required by with-depends-on-cask and with-depends-on-cask-multiple, which are currently installed.\nYou can override this and force removal with:\n  brew uninstall --ignore-dependencies local-transmission-zip\n'
	return brew_runtime.bool_value(result.stderr == expected)
}

// Ruby it `it "shows error message when trying to uninstall multiple casks with dependents" do` at line 266.
pub fn ruby_uninstall_spec_l266_d25_shows(args ...brew_runtime.Value) brew_runtime.Value {
	transmission := uninstall_spec_target('local-transmission-zip')
	caffeine := uninstall_spec_target('local-caffeine')
	result := uninstall_core.check_dependent_casks([transmission, caffeine], [
		uninstall_spec_dependent('with-depends-on-cask', ['local-transmission-zip']),
		uninstall_spec_dependent('with-depends-on-everything', ['local-caffeine',
			'with-depends-on-cask']),
		uninstall_spec_dependent('local-caffeine', []),
		uninstall_spec_dependent('local-transmission-zip', []),
	], ['local-transmission-zip', 'local-caffeine'])
	expected := 'Error: Refusing to uninstall local-transmission-zip and local-caffeine\nbecause they are required by with-depends-on-cask and with-depends-on-everything, which are currently installed.\nYou can override this and force removal with:\n  brew uninstall --ignore-dependencies local-transmission-zip local-caffeine\n'
	return brew_runtime.bool_value(result.stderr == expected)
}

// Ruby it `it "does not output an error if no dependents found" do` at line 292.
pub fn ruby_uninstall_spec_l292_d26_does(args ...brew_runtime.Value) brew_runtime.Value {
	result := uninstall_core.check_dependent_casks([
		uninstall_spec_target('with-depends-on-cask'),
	], [
		uninstall_spec_dependent('with-depends-on-cask', ['local-transmission-zip']),
		uninstall_spec_dependent('local-transmission', []),
	], ['with-depends-on-cask'])
	return brew_runtime.bool_value(result.stderr == '')
}

// Ruby it `it "does not show an error when the dependent is also being uninstalled" do` at line 303.
pub fn ruby_uninstall_spec_l303_d27_does(args ...brew_runtime.Value) brew_runtime.Value {
	result := uninstall_core.check_dependent_casks([
		uninstall_spec_target('local-transmission-zip'),
		uninstall_spec_target('with-depends-on-cask'),
	], [
		uninstall_spec_dependent('with-depends-on-cask', ['local-transmission-zip']),
		uninstall_spec_dependent('local-transmission-zip', []),
	], ['local-transmission-zip', 'with-depends-on-cask'])
	return brew_runtime.bool_value(result.stderr == '')
}

// Ruby it `it "still shows an error when a non-uninstalled cask depends on one being uninstalled" do` at line 318.
pub fn ruby_uninstall_spec_l318_d28_still(args ...brew_runtime.Value) brew_runtime.Value {
	result := uninstall_core.check_dependent_casks([
		uninstall_spec_target('local-transmission-zip'),
		uninstall_spec_target('with-depends-on-cask'),
	], [
		uninstall_spec_dependent('with-depends-on-cask', ['local-transmission-zip']),
		uninstall_spec_dependent('with-depends-on-cask-multiple', ['local-caffeine',
			'local-transmission-zip']),
		uninstall_spec_dependent('local-transmission-zip', []),
	], ['local-transmission-zip', 'with-depends-on-cask'])
	return brew_runtime.bool_value(result.stderr.contains('Refusing to uninstall'))
}

// Ruby it `it "lists other named args when showing the error message" do` at line 338.
pub fn ruby_uninstall_spec_l338_d29_lists(args ...brew_runtime.Value) brew_runtime.Value {
	result := uninstall_core.check_dependent_casks([
		uninstall_spec_target('local-transmission-zip'),
	], [
		uninstall_spec_dependent('with-depends-on-cask', ['local-transmission-zip']),
		uninstall_spec_dependent('local-transmission-zip', []),
	], ['local-transmission-zip', 'foo', 'bar', 'baz', 'qux'])
	expected := 'Error: Refusing to uninstall local-transmission-zip\nbecause it is required by with-depends-on-cask, which is currently installed.\nYou can override this and force removal with:\n  brew uninstall --ignore-dependencies local-transmission-zip foo bar baz qux\n'
	return brew_runtime.bool_value(result.stderr == expected)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/uninstall"
// 5:
// 6: RSpec.describe Cask::Uninstall, :cask do
// 7:   describe ".uninstall_casks" do
// 8:     it "displays the uninstallation progress" do
// 9:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 10:
// 11:       Cask::Installer.new(caffeine).install
// 12:
// 13:       output = Regexp.new <<~EOS
// 14:         ==> Uninstalling Cask local-caffeine
// 15:         ==> Backing up App 'Caffeine.app' to '.*Caffeine.app'
// 16:         ==> Removing App '.*Caffeine.app'
// 17:         ==> Purging files for version 1.2.3 of Cask local-caffeine
// 18:       EOS
// 19:
// 20:       expect do
// 21:         described_class.uninstall_casks(caffeine)
// 22:       end.to output(output).to_stdout
// 23:     end
// 24:
// 25:     it "shows an error when a Cask is provided that's not installed" do
// 26:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 27:
// 28:       expect { described_class.uninstall_casks(caffeine) }
// 29:         .to raise_error(Cask::CaskNotInstalledError, /is not installed/)
// 30:     end
// 31:
// 32:     it "tries anyway on a non-present Cask when --force is given" do
// 33:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 34:
// 35:       expect do
// 36:         described_class.uninstall_casks(caffeine, force: true)
// 37:       end.not_to raise_error
// 38:     end
// 39:
// 40:     it "does not uninstall a pinned Cask" do
// 41:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 42:       InstallHelper.stub_cask_installation(caffeine)
// 43:       caffeine.pin
// 44:
// 45:       expect(Cask::Installer).not_to receive(:new)
// 46:       expect do
// 47:         described_class.uninstall_casks(caffeine)
// 48:       end.to output(/local-caffeine is pinned\. You must unpin it to uninstall\./).to_stderr
// 49:
// 50:       expect(caffeine).to be_pinned
// 51:       caffeine.unpin
// 52:     end
// 53:
// 54:     it "can uninstall and unlink multiple Casks at once" do
// 55:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 56:       transmission = Cask::CaskLoader.load(cask_path("local-transmission-zip"))
// 57:
// 58:       Cask::Installer.new(caffeine).install
// 59:       Cask::Installer.new(transmission).install
// 60:
// 61:       expect(caffeine).to be_installed
// 62:       expect(transmission).to be_installed
// 63:
// 64:       described_class.uninstall_casks(caffeine, transmission)
// 65:
// 66:       expect(caffeine).not_to be_installed
// 67:       expect(Pathname(caffeine.config.appdir).join("Transmission.app")).not_to exist
// 68:       expect(transmission).not_to be_installed
// 69:       expect(Pathname(transmission.config.appdir).join("Caffeine.app")).not_to exist
// 70:     end
// 71:
// 72:     it "can uninstall Casks when the uninstall script is missing, but only when using `--force`" do
// 73:       cask = Cask::CaskLoader.load(cask_path("with-uninstall-script-app"))
// 74:
// 75:       Cask::Installer.new(cask).install
// 76:
// 77:       expect(cask).to be_installed
// 78:
// 79:       FileUtils.rm_r(Pathname(cask.config.appdir).join("MyFancyApp.app"))
// 80:
// 81:       expect { described_class.uninstall_casks(cask) }
// 82:         .to raise_error(Cask::CaskError, /uninstall script .* does not exist/)
// 83:
// 84:       expect(cask).to be_installed
// 85:
// 86:       expect do
// 87:         described_class.uninstall_casks(cask, force: true)
// 88:       end.not_to raise_error
// 89:
// 90:       expect(cask).not_to be_installed
// 91:     end
// 92:
// 93:     it "continues uninstalling remaining casks when one fails" do
// 94:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 95:       transmission = Cask::CaskLoader.load(cask_path("local-transmission-zip"))
// 96:
// 97:       Cask::Installer.new(caffeine).install
// 98:       Cask::Installer.new(transmission).install
// 99:
// 100:       expect(caffeine).to be_installed
// 101:       expect(transmission).to be_installed
// 102:
// 103:       allow(Cask::Installer).to receive(:new).and_call_original
// 104:       allow(Cask::Installer).to receive(:new).with(caffeine, anything).and_wrap_original do |_m, *_args, **_kwargs|
// 105:         instance = instance_double(Cask::Installer)
// 106:         allow(instance).to receive(:uninstall).and_raise(Cask::CaskError.new("caffeine uninstall failed"))
// 107:         instance
// 108:       end
// 109:
// 110:       expect { described_class.uninstall_casks(caffeine, transmission) }
// 111:         .to raise_error(Cask::CaskError, /caffeine uninstall failed/)
// 112:
// 113:       expect(caffeine).to be_installed
// 114:       expect(transmission).not_to be_installed
// 115:     end
// 116:
// 117:     describe "when multiple versions of a cask are installed" do
// 118:       let(:token) { "versioned-cask" }
// 119:       let(:first_installed_version) { "1.2.3" }
// 120:       let(:last_installed_version) { "4.5.6" }
// 121:       let(:timestamped_versions) do
// 122:         [
// 123:           [first_installed_version, "123000"],
// 124:           [last_installed_version,  "456000"],
// 125:         ]
// 126:       end
// 127:       let(:caskroom_path) { Cask::Caskroom.path.join(token).tap(&:mkpath) }
// 128:
// 129:       before do
// 130:         timestamped_versions.each do |timestamped_version|
// 131:           caskroom_path.join(".metadata", *timestamped_version, "Casks").tap(&:mkpath)
// 132:                        .join("#{token}.rb").open("w") do |caskfile|
// 133:                          caskfile.puts <<~RUBY
// 134:                            cask '#{token}' do
// 135:                              version '#{timestamped_version[0]}'
// 136:                            end
// 137:                          RUBY
// 138:                        end
// 139:           caskroom_path.join(timestamped_version[0]).mkpath
// 140:         end
// 141:       end
// 142:
// 143:       it "uninstalls one version at a time" do
// 144:         described_class.uninstall_casks(Cask::Cask.new("versioned-cask"))
// 145:
// 146:         expect(caskroom_path.join(first_installed_version)).to exist
// 147:         expect(caskroom_path.join(last_installed_version)).not_to exist
// 148:         expect(caskroom_path).to exist
// 149:
// 150:         described_class.uninstall_casks(Cask::Cask.new("versioned-cask"))
// 151:
// 152:         expect(caskroom_path.join(first_installed_version)).not_to exist
// 153:         expect(caskroom_path).not_to exist
// 154:       end
// 155:     end
// 156:
// 157:     context "when Casks in Taps have been renamed or removed" do
// 158:       let(:app) { Cask::Config.new.appdir.join("ive-been-renamed.app") }
// 159:       let(:caskroom_path) { Cask::Caskroom.path.join("ive-been-renamed").tap(&:mkpath) }
// 160:       let(:saved_caskfile) do
// 161:         caskroom_path.join(".metadata", "latest", "timestamp", "Casks").join("ive-been-renamed.rb")
// 162:       end
// 163:
// 164:       before do
// 165:         app.tap(&:mkpath)
// 166:            .join("Contents")
// 167:            .tap(&:mkpath)
// 168:            .join("Info.plist")
// 169:            .tap { |file| FileUtils.touch(file) }
// 170:
// 171:         caskroom_path.mkpath
// 172:
// 173:         saved_caskfile.dirname.mkpath
// 174:
// 175:         File.write saved_caskfile, <<~RUBY
// 176:           cask 'ive-been-renamed' do
// 177:             version :latest
// 178:
// 179:             app 'ive-been-renamed.app'
// 180:           end
// 181:         RUBY
// 182:       end
// 183:
// 184:       it "can still uninstall them" do
// 185:         described_class.uninstall_casks(Cask::Cask.new("ive-been-renamed"))
// 186:
// 187:         expect(app).not_to exist
// 188:         expect(caskroom_path).not_to exist
// 189:       end
// 190:     end
// 191:
// 192:     context "when a removed Cask has incomplete installed metadata" do
// 193:       let(:token) { "removed-cask" }
// 194:       let(:caskroom_path) { Cask::Caskroom.path.join(token) }
// 195:       let(:saved_caskfile) do
// 196:         caskroom_path.join(".metadata", "1.0", "20250101000000.000", "Casks", "#{token}.json")
// 197:       end
// 198:
// 199:       before do
// 200:         saved_caskfile.dirname.mkpath
// 201:         saved_caskfile.write("{}")
// 202:         allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(false)
// 203:         allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_raise(
// 204:           ErrorDuringExecution.new(["curl"], status: 22),
// 205:         )
// 206:       end
// 207:
// 208:       it "removes Homebrew's records and warns that installed files may remain" do
// 209:         expect do
// 210:           described_class.uninstall_casks(Cask::Cask.new(token))
// 211:         end.to output(/files installed by the Cask may remain/).to_stderr
// 212:
// 213:         expect(caskroom_path).not_to exist
// 214:       end
// 215:
// 216:       it "does not warn when uninstalling as part of an upgrade" do
// 217:         expect do
// 218:           Cask::Installer.new(Cask::Cask.new(token), upgrade: true).uninstall(successor: Cask::Cask.new(token))
// 219:         end.not_to output(/files installed by the Cask may remain/).to_stderr
// 220:       end
// 221:     end
// 222:   end
// 223:
// 224:   describe ".check_dependent_casks" do
// 225:     it "shows error message when trying to uninstall a cask with dependents" do
// 226:       depends_on_cask = Cask::CaskLoader.load(cask_path("with-depends-on-cask"))
// 227:       local_transmission = Cask::CaskLoader.load(cask_path("local-transmission-zip"))
// 228:
// 229:       allow(Cask::Caskroom).to receive(:casks).and_return([depends_on_cask, local_transmission])
// 230:
// 231:       output = <<~EOS
// 232:         Error: Refusing to uninstall local-transmission-zip
// 233:         because it is required by with-depends-on-cask, which is currently installed.
// 234:         You can override this and force removal with:
// 235:           brew uninstall --ignore-dependencies local-transmission-zip
// 236:       EOS
// 237:
// 238:       expect do
// 239:         described_class.check_dependent_casks(local_transmission, named_args: ["local-transmission-zip"])
// 240:       end.to output(output).to_stderr
// 241:     end
// 242:
// 243:     it "shows error message when trying to uninstall a cask with multiple dependents" do
// 244:       depends_on_cask = Cask::CaskLoader.load(cask_path("with-depends-on-cask"))
// 245:       depends_on_cask_multiple = Cask::CaskLoader.load(cask_path("with-depends-on-cask-multiple"))
// 246:       local_transmission = Cask::CaskLoader.load(cask_path("local-transmission-zip"))
// 247:
// 248:       allow(Cask::Caskroom).to receive(:casks).and_return([
// 249:         depends_on_cask,
// 250:         depends_on_cask_multiple,
// 251:         local_transmission,
// 252:       ])
// 253:
// 254:       output = <<~EOS
// 255:         Error: Refusing to uninstall local-transmission-zip
// 256:         because it is required by with-depends-on-cask and with-depends-on-cask-multiple, which are currently installed.
// 257:         You can override this and force removal with:
// 258:           brew uninstall --ignore-dependencies local-transmission-zip
// 259:       EOS
// 260:
// 261:       expect do
// 262:         described_class.check_dependent_casks(local_transmission, named_args: ["local-transmission-zip"])
// 263:       end.to output(output).to_stderr
// 264:     end
// 265:
// 266:     it "shows error message when trying to uninstall multiple casks with dependents" do
// 267:       depends_on_cask = Cask::CaskLoader.load(cask_path("with-depends-on-cask"))
// 268:       depends_on_everything = Cask::CaskLoader.load(cask_path("with-depends-on-everything"))
// 269:       local_caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 270:       local_transmission = Cask::CaskLoader.load(cask_path("local-transmission-zip"))
// 271:       named_args = %w[local-transmission-zip local-caffeine]
// 272:
// 273:       allow(Cask::Caskroom).to receive(:casks).and_return([
// 274:         depends_on_cask,
// 275:         depends_on_everything,
// 276:         local_caffeine,
// 277:         local_transmission,
// 278:       ])
// 279:
// 280:       output = <<~EOS
// 281:         Error: Refusing to uninstall local-transmission-zip and local-caffeine
// 282:         because they are required by with-depends-on-cask and with-depends-on-everything, which are currently installed.
// 283:         You can override this and force removal with:
// 284:           brew uninstall --ignore-dependencies local-transmission-zip local-caffeine
// 285:       EOS
// 286:
// 287:       expect do
// 288:         described_class.check_dependent_casks(local_transmission, local_caffeine, named_args:)
// 289:       end.to output(output).to_stderr
// 290:     end
// 291:
// 292:     it "does not output an error if no dependents found" do
// 293:       depends_on_cask = Cask::CaskLoader.load(cask_path("with-depends-on-cask"))
// 294:       local_transmission = Cask::CaskLoader.load(cask_path("local-transmission"))
// 295:
// 296:       allow(Cask::Caskroom).to receive(:casks).and_return([depends_on_cask, local_transmission])
// 297:
// 298:       expect do
// 299:         described_class.check_dependent_casks(depends_on_cask, named_args: ["with-depends-on-cask"])
// 300:       end.not_to output.to_stderr
// 301:     end
// 302:
// 303:     it "does not show an error when the dependent is also being uninstalled" do
// 304:       depends_on_cask = Cask::CaskLoader.load(cask_path("with-depends-on-cask"))
// 305:       local_transmission = Cask::CaskLoader.load(cask_path("local-transmission-zip"))
// 306:
// 307:       allow(Cask::Caskroom).to receive(:casks).and_return([depends_on_cask, local_transmission])
// 308:
// 309:       expect do
// 310:         described_class.check_dependent_casks(
// 311:           local_transmission,
// 312:           depends_on_cask,
// 313:           named_args: ["local-transmission-zip", "with-depends-on-cask"],
// 314:         )
// 315:       end.not_to output.to_stderr
// 316:     end
// 317:
// 318:     it "still shows an error when a non-uninstalled cask depends on one being uninstalled" do
// 319:       depends_on_cask = Cask::CaskLoader.load(cask_path("with-depends-on-cask"))
// 320:       depends_on_cask_multiple = Cask::CaskLoader.load(cask_path("with-depends-on-cask-multiple"))
// 321:       local_transmission = Cask::CaskLoader.load(cask_path("local-transmission-zip"))
// 322:
// 323:       allow(Cask::Caskroom).to receive(:casks).and_return([
// 324:         depends_on_cask,
// 325:         depends_on_cask_multiple,
// 326:         local_transmission,
// 327:       ])
// 328:
// 329:       expect do
// 330:         described_class.check_dependent_casks(
// 331:           local_transmission,
// 332:           depends_on_cask,
// 333:           named_args: ["local-transmission-zip", "with-depends-on-cask"],
// 334:         )
// 335:       end.to output(/Refusing to uninstall/).to_stderr
// 336:     end
// 337:
// 338:     it "lists other named args when showing the error message" do
// 339:       depends_on_cask = Cask::CaskLoader.load(cask_path("with-depends-on-cask"))
// 340:       local_transmission = Cask::CaskLoader.load(cask_path("local-transmission-zip"))
// 341:       named_args = %w[local-transmission-zip foo bar baz qux]
// 342:
// 343:       allow(Cask::Caskroom).to receive(:casks).and_return([depends_on_cask, local_transmission])
// 344:
// 345:       output = <<~EOS
// 346:         Error: Refusing to uninstall local-transmission-zip
// 347:         because it is required by with-depends-on-cask, which is currently installed.
// 348:         You can override this and force removal with:
// 349:           brew uninstall --ignore-dependencies local-transmission-zip foo bar baz qux
// 350:       EOS
// 351:
// 352:       expect do
// 353:         described_class.check_dependent_casks(local_transmission, named_args:)
// 354:       end.to output(output).to_stderr
// 355:     end
// 356:   end
// 357: end
