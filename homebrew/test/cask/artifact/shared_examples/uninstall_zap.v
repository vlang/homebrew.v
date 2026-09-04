module shared_examples

import ruby
import homebrew.cask.artifact as core
import os

// Translated from Homebrew/brew `test/cask/artifact/shared_examples/uninstall_zap.rb`.
// The original source is retained below until every stub has a typed V body.
const shared_bundle_id = 'my.fancy.package.app'
const shared_service_id = 'my.fancy.package.service'

fn shared_success_runner(command core.UninstallCommand) !bool {
	_ = command
	return true
}

fn shared_failure_runner(command core.UninstallCommand) !bool {
	_ = command
	return false
}

fn shared_artifact(directive string, value ruby.Value) core.AbstractUninstallArtifact {
	return core.new_abstract_uninstall_artifact('with-uninstall-${directive}', 'uninstall', {
		directive: value
	}) or { core.AbstractUninstallArtifact{} }
}

fn shared_launchctl_listing() string {
	return 'PID     Status  Label\n1111    0       my.fancy.package.service.12345\n-       0       com.apple.SafariHistoryServiceAgent\n-       0       com.apple.progressd\n555     0       my.fancy.package.service.test'
}

fn shared_directive_result(directive string, value ruby.Value,
	options core.AbstractUninstallOptions, runner core.UninstallCommandRunner) core.AbstractUninstallResult {
	mut artifact := shared_artifact(directive, value)
	return core.dispatch_abstract_uninstall_with_command(mut artifact, options, runner)
}

fn shared_command(result core.AbstractUninstallResult, executable string, sudo bool) bool {
	return result.commands.any(it.executable == executable && it.sudo == sudo)
}

fn uninstall_zap_filesystem_case() bool {
	root := os.join_path(os.temp_dir(), 'brew-v-abstract-uninstall-${os.getpid()}')
	if os.exists(root) {
		os.rmdir_all(root) or { return false }
	}
	os.mkdir_all(root) or { return false }
	delete_path := os.join_path(root, 'absolute_path')
	trash_path := os.join_path(root, 'path_with_tilde')
	trash_dir := os.join_path(root, 'Trash')
	os.write_file(delete_path, 'delete') or { return false }
	os.write_file(trash_path, 'trash') or { return false }
	delete_result := shared_directive_result('delete', ruby.string_array_value([
		delete_path,
	]), core.AbstractUninstallOptions{
		home: root
	}, shared_success_runner)
	trash_result := shared_directive_result('trash', ruby.string_array_value([
		trash_path,
	]), core.AbstractUninstallOptions{
		home: root
		trash_directory: trash_dir
	}, shared_success_runner)
	success := delete_result.success && delete_path in delete_result.removed && !os.exists(delete_path) && trash_result.success && trash_result.trashed.len == 1 && !os.exists(trash_path)
	os.rmdir_all(root) or {}
	return success
}

fn uninstall_zap_script_case() bool {
	root := os.join_path(os.temp_dir(), 'brew-v-abstract-script-${os.getpid()}')
	os.mkdir_all(root) or { return false }
	script := os.join_path(root, 'FancyUninstaller.tool')
	os.write_file(script, '#!/bin/sh\n') or { return false }
	value := ruby.map_value({
		'executable': ruby.string_value(script)
		'args':       ruby.string_array_value(['--please'])
		'sudo':       ruby.bool_value(false)
	})
	script_result := shared_directive_result('script', value, core.AbstractUninstallOptions{}, shared_success_runner)
	early_result := shared_directive_result('early_script', value, core.AbstractUninstallOptions{}, shared_success_runner)
	os.rmdir_all(root) or {}
	return script_result.success && early_result.success && script_result.commands.len == 1 && script_result.commands[0].args == [
		'--please',
	]
}

pub fn uninstall_zap_shared_example_case(index int) bool {
	match index {
		9 {
			result := shared_directive_result('launchctl', ruby.string_array_value([
				shared_service_id,
			]), core.AbstractUninstallOptions{
				launchctl_user_services: [shared_service_id]
			}, shared_success_runner)
			return result.success && shared_command(result, '/bin/launchctl', false)
		}
		10 {
			result := shared_directive_result('launchctl', ruby.string_array_value([
				shared_service_id,
			]), core.AbstractUninstallOptions{
				launchctl_system_services: [shared_service_id]
			}, shared_success_runner)
			return result.success && shared_command(result, '/bin/launchctl', true)
		}
		11 {
			result := shared_directive_result('launchctl', ruby.string_array_value([
				shared_service_id,
			]), core.AbstractUninstallOptions{
				launchctl_system_services: [shared_service_id]
			}, shared_failure_runner)
			return result.success && result.commands.len == 1
		}
		16 {
			result := shared_directive_result('launchctl', ruby.string_array_value([
				'my.fancy.package.service.*',
			]), core.AbstractUninstallOptions{
				launchctl_list: shared_launchctl_listing()
				launchctl_system_services: ['my.fancy.package.service.12345']
			}, shared_success_runner)
			return result.commands.any(it.args == ['remove', 'my.fancy.package.service.12345'])
		}
		17 {
			return core.find_launchctl_with_wildcard('my.fancy.package.service.*', shared_launchctl_listing()) == [
				'my.fancy.package.service.12345',
				'my.fancy.package.service.test',
			]
		}
		21 {
			result := shared_directive_result('pkgutil', ruby.string_array_value([
				'my.fancy.package.*',
			]), core.AbstractUninstallOptions{
				package_matches: {
					'my.fancy.package.*': ['my.fancy.package.main', 'my.fancy.package.agent']
				}
			}, shared_success_runner)
			return result.packages == ['my.fancy.package.main', 'my.fancy.package.agent']
		}
		24 {
			kext := 'my.fancy.package.kernelextension'
			result := shared_directive_result('kext', ruby.string_array_value([
				kext,
			]), core.AbstractUninstallOptions{
				kext_loaded: {
					kext: true
				}
				kext_paths: {
					kext: ['/Library/Extensions/FancyPackage.kext']
				}
			}, shared_success_runner)
			return result.commands.map(it.executable) == ['/usr/sbin/kextstat', '/sbin/kextunload',
				'/bin/rm']
		}
		27 {
			result := shared_directive_result('quit', ruby.string_array_value([
				shared_bundle_id,
			]), core.AbstractUninstallOptions{
				gui: false
				running_processes: {
					shared_bundle_id: [12345]
				}
			}, shared_success_runner)
			return result.commands.len == 0 && result.warnings[0].contains('Not logged into a GUI')
		}
		28 {
			result := shared_directive_result('quit', ruby.string_array_value([
				shared_bundle_id,
			]), core.AbstractUninstallOptions{
				running_processes: {
					shared_bundle_id: [12345]
				}
				quit_success: {
					shared_bundle_id: true
				}
			}, shared_success_runner)
			return result.commands.len == 1 && result.output.last().contains('quit successfully')
		}
		29 {
			result := shared_directive_result('quit', ruby.string_array_value([
				shared_bundle_id,
			]), core.AbstractUninstallOptions{
				running_processes: {
					shared_bundle_id: [12345]
				}
				quit_success: {
					shared_bundle_id: false
				}
			}, shared_failure_runner)
			return result.warnings.any(it.contains('did not quit'))
		}
		34 {
			value := ruby.string_array_value(['TERM', shared_bundle_id, 'KILL',
				shared_bundle_id])
			result := shared_directive_result('signal', value, core.AbstractUninstallOptions{
				running_processes: {
					shared_bundle_id: [12345, 67890]
				}
			}, shared_success_runner)
			return result.commands.len == 2 && result.commands[0].args[0] == '-TERM' && result.commands[1].args[0] == '-KILL'
		}
		35 {
			value := ruby.string_array_value(['TERM', shared_bundle_id])
			upgrade := shared_directive_result('signal', value, core.AbstractUninstallOptions{
				upgrade: true
				running_processes: {
					shared_bundle_id: [12345]
				}
			}, shared_success_runner)
			reinstall := shared_directive_result('signal', value, core.AbstractUninstallOptions{
				reinstall: true
				running_processes: {
					shared_bundle_id: [12345]
				}
			}, shared_success_runner)
			return upgrade.commands.len == 0 && reinstall.commands.len == 0
		}
		44 {
			return uninstall_zap_filesystem_case()
		}
		49 {
			return uninstall_zap_script_case()
		}
		51 {
			result := shared_directive_result('login_item', ruby.string_array_value([
				'Fancy',
			]), core.AbstractUninstallOptions{}, shared_success_runner)
			return result.commands.len == 1 && result.commands[0].executable == 'osascript' && result.commands[0].args.last().contains('name is "Fancy"')
		}
		else {
			return false
		}
	}
}

// Ruby subject `subject { artifact }` at line 8.
pub fn ruby_uninstall_zap_l8_d1_subject_dynamic(args ...ruby.Value) ruby.Value {
	_ = args
	return core.abstract_uninstall_to_value(shared_artifact('delete', ruby.string_array_value([
		'/tmp/absolute_path',
	])))
}

// Ruby let `let(:artifact_dsl_key) { described_class.dsl_key }` at line 10.
pub fn ruby_uninstall_zap_l10_d2_artifact_dsl_key(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('uninstall')
}

// Ruby let `let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }` at line 11.
pub fn ruby_uninstall_zap_l11_d3_artifact(args ...ruby.Value) ruby.Value {
	return ruby_uninstall_zap_l8_d1_subject_dynamic(...args)
}

// Ruby let `let(:fake_system_command) { class_double(SystemCommand) }` at line 12.
pub fn ruby_uninstall_zap_l12_d4_fake_system_command(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('UninstallCommandRunner', 'InjectedUninstallCommand')
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-launchctl")) }` at line 19.
pub fn ruby_uninstall_zap_l19_d5_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-launchctl')
}

// Ruby let `let(:launchctl_list_cmd) { %w[/bin/launchctl list my.fancy.package.service] }` at line 20.
pub fn ruby_uninstall_zap_l20_d6_launchctl_list_cmd(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['/bin/launchctl', 'list', shared_service_id])
}

// Ruby let `let(:launchctl_remove_cmd) { %w[/bin/launchctl remove my.fancy.package.service] }` at line 21.
pub fn ruby_uninstall_zap_l21_d7_launchctl_remove_cmd(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['/bin/launchctl', 'remove', shared_service_id])
}

// Ruby let `let(:service_info) do` at line 22.
pub fn ruby_uninstall_zap_l22_d8_service_info(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('{ "Label" = "${shared_service_id}"; "OnDemand" = true; };')
}

// Ruby it `it "works when job is owned by user" do` at line 37.
pub fn ruby_uninstall_zap_l37_d9_works(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(9))
}

// Ruby it `it "works when job is owned by system" do` at line 53.
pub fn ruby_uninstall_zap_l53_d10_works(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(10))
}

// Ruby it `it "does not fail when sudo removal fails" do` at line 69.
pub fn ruby_uninstall_zap_l69_d11_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(11))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-launchctl-wildcard")) }` at line 89.
pub fn ruby_uninstall_zap_l89_d12_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-launchctl-wildcard')
}

// Ruby let `let(:launchctl_regex) { "my.fancy.package.service.*" }` at line 90.
pub fn ruby_uninstall_zap_l90_d13_launchctl_regex(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('my.fancy.package.service.*')
}

// Ruby let `let(:service_info) do` at line 91.
pub fn ruby_uninstall_zap_l91_d14_service_info(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('{ "Label" = "my.fancy.package.service.12345"; };')
}

// Ruby let `let(:launchctl_list) do` at line 105.
pub fn ruby_uninstall_zap_l105_d15_launchctl_list(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(shared_launchctl_listing())
}

// Ruby it `it "searches installed launchctl items" do` at line 121.
pub fn ruby_uninstall_zap_l121_d16_searches(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(16))
}

// Ruby it `it "returns the matching launchctl services" do` at line 138.
pub fn ruby_uninstall_zap_l138_d17_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(17))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-pkgutil")) }` at line 149.
pub fn ruby_uninstall_zap_l149_d18_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-pkgutil')
}

// Ruby let `let(:main_pkg_id) { "my.fancy.package.main" }` at line 151.
pub fn ruby_uninstall_zap_l151_d19_main_pkg_id(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('my.fancy.package.main')
}

// Ruby let `let(:agent_pkg_id) { "my.fancy.package.agent" }` at line 152.
pub fn ruby_uninstall_zap_l152_d20_agent_pkg_id(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('my.fancy.package.agent')
}

// Ruby it `it "is supported" do` at line 154.
pub fn ruby_uninstall_zap_l154_d21_is(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(21))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-kext")) }` at line 173.
pub fn ruby_uninstall_zap_l173_d22_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-kext')
}

// Ruby let `let(:kext_id) { "my.fancy.package.kernelextension" }` at line 174.
pub fn ruby_uninstall_zap_l174_d23_kext_id(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('my.fancy.package.kernelextension')
}

// Ruby it `it "is supported" do` at line 176.
pub fn ruby_uninstall_zap_l176_d24_is(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(24))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-quit")) }` at line 197.
pub fn ruby_uninstall_zap_l197_d25_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-quit')
}

// Ruby let `let(:bundle_id) { "my.fancy.package.app" }` at line 198.
pub fn ruby_uninstall_zap_l198_d26_bundle_id(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(shared_bundle_id)
}

// Ruby it `it "is skipped when the user is not a GUI user" do` at line 200.
pub fn ruby_uninstall_zap_l200_d27_is(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(27))
}

// Ruby it `it "quits a running application" do` at line 209.
pub fn ruby_uninstall_zap_l209_d28_quits(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(28))
}

// Ruby it `it "tries to quit the application" do` at line 222.
pub fn ruby_uninstall_zap_l222_d29_tries(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(29))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-signal")) }` at line 238.
pub fn ruby_uninstall_zap_l238_d30_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-signal')
}

// Ruby let `let(:bundle_id) { "my.fancy.package.app" }` at line 239.
pub fn ruby_uninstall_zap_l239_d31_bundle_id(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(shared_bundle_id)
}

// Ruby let `let(:signals) { %w[TERM KILL] }` at line 240.
pub fn ruby_uninstall_zap_l240_d32_signals(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['TERM', 'KILL'])
}

// Ruby let `let(:unix_pids) { [12_345, 67_890] }` at line 241.
pub fn ruby_uninstall_zap_l241_d33_unix_pids(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.array_value([ruby.int_value(12345), ruby.int_value(67890)])
}

// Ruby it `it "is supported" do` at line 243.
pub fn ruby_uninstall_zap_l243_d34_is(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(34))
}

// Ruby it `it "does not send signal when upgrading or reinstalling" do` at line 255.
pub fn ruby_uninstall_zap_l255_d35_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(35))
}

// Ruby let `let(:dir) { TEST_TMPDIR }` at line 274.
pub fn ruby_uninstall_zap_l274_d36_dir(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(os.temp_dir())
}

// Ruby let `let(:absolute_path) { Pathname.new("#{dir}/absolute_path") }` at line 275.
pub fn ruby_uninstall_zap_l275_d37_absolute_path(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(os.join_path(os.temp_dir(), 'absolute_path'))
}

// Ruby let `let(:path_with_tilde) { Pathname.new("#{dir}/path_with_tilde") }` at line 276.
pub fn ruby_uninstall_zap_l276_d38_path_with_tilde(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('~/path_with_tilde')
}

// Ruby let `let(:glob_path) { Pathname.new("#{dir}/glob_path") }` at line 277.
pub fn ruby_uninstall_zap_l277_d39_glob_path(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(os.join_path(os.temp_dir(), 'glob_path*'))
}

// Ruby let `let(:glob_path_alt) { Pathname.new("#{dir}/glob_path_alt") }` at line 278.
pub fn ruby_uninstall_zap_l278_d40_glob_path_alt(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(os.join_path(os.temp_dir(), 'glob_path_alt'))
}

// Ruby let `let(:paths) { [absolute_path, path_with_tilde, glob_path, glob_path_alt] }` at line 279.
pub fn ruby_uninstall_zap_l279_d41_paths(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value([
		os.join_path(os.temp_dir(), 'absolute_path'),
		'~/path_with_tilde',
		os.join_path(os.temp_dir(), 'glob_path*'),
		os.join_path(os.temp_dir(), 'glob_path_alt'),
	])
}

// Ruby let `let(:fake_system_command) { NeverSudoSystemCommand }` at line 280.
pub fn ruby_uninstall_zap_l280_d42_fake_system_command(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('UninstallCommandRunner', 'NeverSudoSystemCommand')
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-#{directive}")) }` at line 281.
pub fn ruby_uninstall_zap_l281_d43_cask(args ...ruby.Value) ruby.Value {
	directive := if args.len > 0 { args[0].as_string() } else { 'delete' }
	return ruby.string_value('with-uninstall-${directive}')
}

// Ruby it `it "is supported" do` at line 302.
pub fn ruby_uninstall_zap_l302_d44_is(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(44))
}

// Ruby let `let(:fake_system_command) { NeverSudoSystemCommand }` at line 316.
pub fn ruby_uninstall_zap_l316_d45_fake_system_command(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('UninstallCommandRunner', 'NeverSudoSystemCommand')
}

// Ruby let `let(:token) { "with-#{artifact_dsl_key}-#{script_type}".tr("_", "-") }` at line 317.
pub fn ruby_uninstall_zap_l317_d46_token(args ...ruby.Value) ruby.Value {
	script_type := if args.len > 0 { args[0].as_string() } else { 'script' }
	return ruby.string_value('with-uninstall-${script_type}'.replace('_', '-'))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path(token.to_s)) }` at line 318.
pub fn ruby_uninstall_zap_l318_d47_cask(args ...ruby.Value) ruby.Value {
	return ruby_uninstall_zap_l317_d46_token(...args)
}

// Ruby let `let(:script_pathname) { cask.staged_path.join("MyFancyPkg", "FancyUninstaller.tool") }` at line 319.
pub fn ruby_uninstall_zap_l319_d48_script_pathname(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('/tmp/staged/MyFancyPkg/FancyUninstaller.tool')
}

// Ruby it `it "is supported" do` at line 321.
pub fn ruby_uninstall_zap_l321_d49_is(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(49))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-login-item")) }` at line 340.
pub fn ruby_uninstall_zap_l340_d50_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-login-item')
}

// Ruby it `it "is supported" do` at line 342.
pub fn ruby_uninstall_zap_l342_d51_is(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_zap_shared_example_case(51))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "benchmark"
// 5: require "services/system"
// 6:
// 7: RSpec.shared_examples "#uninstall_phase or #zap_phase" do
// 8:   subject { artifact }
// 9:
// 10:   let(:artifact_dsl_key) { described_class.dsl_key }
// 11:   let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }
// 12:   let(:fake_system_command) { class_double(SystemCommand) }
// 13:
// 14:   before do
// 15:     allow(fake_system_command).to receive(:is_a?) { |val| SystemCommand.is_a?(val) }
// 16:   end
// 17:
// 18:   context "when using :launchctl" do
// 19:     let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-launchctl")) }
// 20:     let(:launchctl_list_cmd) { %w[/bin/launchctl list my.fancy.package.service] }
// 21:     let(:launchctl_remove_cmd) { %w[/bin/launchctl remove my.fancy.package.service] }
// 22:     let(:service_info) do
// 23:       <<~EOS
// 24:         {
// 25:                 "LimitLoadToSessionType" = "Aqua";
// 26:                 "Label" = "my.fancy.package.service";
// 27:                 "TimeOut" = 30;
// 28:                 "OnDemand" = true;
// 29:                 "LastExitStatus" = 0;
// 30:                 "ProgramArguments" = (
// 31:                         "argument";
// 32:                 );
// 33:         };
// 34:       EOS
// 35:     end
// 36:
// 37:     it "works when job is owned by user" do
// 38:       allow(Homebrew::Services::System).to receive(:launchctl_find_service)
// 39:         .with("my.fancy.package.service", sudo: false)
// 40:         .and_return([service_info, true, :launchctl_print])
// 41:       allow(Homebrew::Services::System).to receive(:launchctl_find_service)
// 42:         .with("my.fancy.package.service", sudo: true)
// 43:         .and_return(["", false, :launchctl_list])
// 44:
// 45:       expect(fake_system_command).to receive(:run)
// 46:         .with("/bin/launchctl", args: ["remove", "my.fancy.package.service"],
// 47:         must_succeed: false, sudo: false, sudo_as_root: false)
// 48:         .and_return(instance_double(SystemCommand::Result, success?: true))
// 49:
// 50:       subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 51:     end
// 52:
// 53:     it "works when job is owned by system" do
// 54:       allow(Homebrew::Services::System).to receive(:launchctl_find_service)
// 55:         .with("my.fancy.package.service", sudo: false)
// 56:         .and_return(["", false, :launchctl_list])
// 57:       allow(Homebrew::Services::System).to receive(:launchctl_find_service)
// 58:         .with("my.fancy.package.service", sudo: true)
// 59:         .and_return([service_info, true, :launchctl_print])
// 60:
// 61:       expect(fake_system_command).to receive(:run)
// 62:         .with("/bin/launchctl", args: ["remove", "my.fancy.package.service"],
// 63:         must_succeed: false, sudo: true, sudo_as_root: true)
// 64:         .and_return(instance_double(SystemCommand::Result, success?: true))
// 65:
// 66:       subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 67:     end
// 68:
// 69:     it "does not fail when sudo removal fails" do
// 70:       allow(Homebrew::Services::System).to receive(:launchctl_find_service)
// 71:         .with("my.fancy.package.service", sudo: false)
// 72:         .and_return(["", false, :launchctl_list])
// 73:       allow(Homebrew::Services::System).to receive(:launchctl_find_service)
// 74:         .with("my.fancy.package.service", sudo: true)
// 75:         .and_return([service_info, true, :launchctl_print])
// 76:
// 77:       expect(fake_system_command).to receive(:run)
// 78:         .with("/bin/launchctl", args: ["remove", "my.fancy.package.service"],
// 79:         must_succeed: false, sudo: true, sudo_as_root: true)
// 80:         .and_return(instance_double(SystemCommand::Result, success?: false))
// 81:
// 82:       expect do
// 83:         subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 84:       end.not_to raise_error
// 85:     end
// 86:   end
// 87:
// 88:   context "when using :launchctl with regex wildcard" do
// 89:     let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-launchctl-wildcard")) }
// 90:     let(:launchctl_regex) { "my.fancy.package.service.*" }
// 91:     let(:service_info) do
// 92:       <<~EOS
// 93:         {
// 94:                 "LimitLoadToSessionType" = "Aqua";
// 95:                 "Label" = "my.fancy.package.service.12345";
// 96:                 "TimeOut" = 30;
// 97:                 "OnDemand" = true;
// 98:                 "LastExitStatus" = 0;
// 99:                 "ProgramArguments" = (
// 100:                         "argument";
// 101:                 );
// 102:         };
// 103:       EOS
// 104:     end
// 105:     let(:launchctl_list) do
// 106:       <<~EOS
// 107:         PID     Status  Label
// 108:         1111    0       my.fancy.package.service.12345
// 109:         -       0       com.apple.SafariHistoryServiceAgent
// 110:         -       0       com.apple.progressd
// 111:         555     0       my.fancy.package.service.test
// 112:       EOS
// 113:     end
// 114:
// 115:     before do
// 116:       allow(fake_system_command).to receive(:run)
// 117:         .with("/bin/launchctl", hash_including(args: ["print", anything]))
// 118:         .and_return(instance_double(SystemCommand::Result, success?: false))
// 119:     end
// 120:
// 121:     it "searches installed launchctl items" do
// 122:       expect(subject).to receive(:find_launchctl_with_wildcard)
// 123:         .with(launchctl_regex)
// 124:         .and_return(["my.fancy.package.service.12345"])
// 125:
// 126:       allow(Homebrew::Services::System).to receive(:launchctl_find_service) do |_label, sudo:|
// 127:         sudo ? [service_info, true, :launchctl_print] : ["", false, :launchctl_list]
// 128:       end
// 129:
// 130:       expect(fake_system_command).to receive(:run)
// 131:         .with("/bin/launchctl", args: ["remove", "my.fancy.package.service.12345"],
// 132:         must_succeed: false, sudo: true, sudo_as_root: true)
// 133:         .and_return(instance_double(SystemCommand::Result, success?: true))
// 134:
// 135:       subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 136:     end
// 137:
// 138:     it "returns the matching launchctl services" do
// 139:       expect(subject).to receive(:system_command!)
// 140:         .with("/bin/launchctl", args: ["list"])
// 141:         .and_return(instance_double(SystemCommand::Result, stdout: launchctl_list))
// 142:
// 143:       expect(subject.find_launchctl_with_wildcard("my.fancy.package.service.*"))
// 144:         .to eq(["my.fancy.package.service.12345", "my.fancy.package.service.test"])
// 145:     end
// 146:   end
// 147:
// 148:   context "when using :pkgutil" do
// 149:     let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-pkgutil")) }
// 150:
// 151:     let(:main_pkg_id) { "my.fancy.package.main" }
// 152:     let(:agent_pkg_id) { "my.fancy.package.agent" }
// 153:
// 154:     it "is supported" do
// 155:       main_pkg = Cask::Pkg.new(main_pkg_id, fake_system_command)
// 156:       agent_pkg = Cask::Pkg.new(agent_pkg_id, fake_system_command)
// 157:
// 158:       expect(Cask::Pkg).to receive(:all_matching).and_return(
// 159:         [
// 160:           main_pkg,
// 161:           agent_pkg,
// 162:         ],
// 163:       )
// 164:
// 165:       expect(main_pkg).to receive(:uninstall)
// 166:       expect(agent_pkg).to receive(:uninstall)
// 167:
// 168:       subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 169:     end
// 170:   end
// 171:
// 172:   context "when using :kext" do
// 173:     let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-kext")) }
// 174:     let(:kext_id) { "my.fancy.package.kernelextension" }
// 175:
// 176:     it "is supported" do
// 177:       allow(subject).to receive(:system_command!)
// 178:         .with("/usr/sbin/kextstat", args: ["-l", "-b", kext_id], sudo: true, sudo_as_root: true)
// 179:         .and_return(instance_double(SystemCommand::Result, stdout: "loaded"))
// 180:
// 181:       expect(subject).to receive(:system_command!)
// 182:         .with("/sbin/kextunload", args: ["-b", kext_id], sudo: true, sudo_as_root: true)
// 183:         .and_return(instance_double(SystemCommand::Result))
// 184:
// 185:       expect(subject).to receive(:system_command!)
// 186:         .with("/usr/sbin/kextfind", args: ["-b", kext_id], sudo: true, sudo_as_root: true)
// 187:         .and_return(instance_double(SystemCommand::Result, stdout: "/Library/Extensions/FancyPackage.kext\n"))
// 188:
// 189:       expect(subject).to receive(:system_command!)
// 190:         .with("/bin/rm", args: ["-rf", "/Library/Extensions/FancyPackage.kext"], sudo: true, sudo_as_root: true)
// 191:
// 192:       subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 193:     end
// 194:   end
// 195:
// 196:   context "when using :quit" do
// 197:     let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-quit")) }
// 198:     let(:bundle_id) { "my.fancy.package.app" }
// 199:
// 200:     it "is skipped when the user is not a GUI user" do
// 201:       allow(User.current).to receive(:gui?).and_return false
// 202:       allow(subject).to receive(:running?).with(bundle_id).and_return(true)
// 203:
// 204:       expect do
// 205:         subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 206:       end.to output(/Not logged into a GUI; skipping quitting application ID 'my.fancy.package.app'\./).to_stderr
// 207:     end
// 208:
// 209:     it "quits a running application" do
// 210:       allow(User.current).to receive(:gui?).and_return true
// 211:
// 212:       expect(subject).to receive(:running?).with(bundle_id).ordered.and_return(true)
// 213:       expect(subject).to receive(:quit).with(bundle_id)
// 214:                                        .and_return(instance_double(SystemCommand::Result, success?: true))
// 215:       expect(subject).to receive(:running?).with(bundle_id).ordered.and_return(false)
// 216:
// 217:       expect do
// 218:         subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 219:       end.to output(/Application 'my.fancy.package.app' quit successfully\./).to_stdout
// 220:     end
// 221:
// 222:     it "tries to quit the application" do
// 223:       allow(User.current).to receive(:gui?).and_return true
// 224:
// 225:       allow(subject).to receive(:running?).with(bundle_id).and_return(true)
// 226:       allow(subject).to receive(:quit).with(bundle_id)
// 227:                                       .and_return(instance_double(SystemCommand::Result, success?: false))
// 228:
// 229:       allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
// 230:
// 231:       expect do
// 232:         subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 233:       end.to output(/Application 'my.fancy.package.app' did not quit\./).to_stderr
// 234:     end
// 235:   end
// 236:
// 237:   context "when using :signal" do
// 238:     let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-signal")) }
// 239:     let(:bundle_id) { "my.fancy.package.app" }
// 240:     let(:signals) { %w[TERM KILL] }
// 241:     let(:unix_pids) { [12_345, 67_890] }
// 242:
// 243:     it "is supported" do
// 244:       allow(subject).to receive(:running_processes).with(bundle_id)
// 245:                                                    .and_return(unix_pids.map { |pid| [pid, 0, bundle_id] })
// 246:       allow(subject).to receive(:sleep).with(3)
// 247:
// 248:       signals.each do |signal|
// 249:         expect(Process).to receive(:kill).with(signal, *unix_pids).and_return(1)
// 250:       end
// 251:
// 252:       subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 253:     end
// 254:
// 255:     it "does not send signal when upgrading or reinstalling" do
// 256:       next if artifact_dsl_key == :zap
// 257:
// 258:       allow(subject).to receive(:running_processes).with(bundle_id)
// 259:                                                    .and_return(unix_pids.map { |pid| [pid, 0, bundle_id] })
// 260:
// 261:       signals.each do |_signal|
// 262:         expect(Process).not_to receive(:kill)
// 263:       end
// 264:
// 265:       subject.public_send(:"#{artifact_dsl_key}_phase", upgrade: true, command: fake_system_command)
// 266:       subject.public_send(:"#{artifact_dsl_key}_phase", reinstall: true, command: fake_system_command)
// 267:     end
// 268:   end
// 269:
// 270:   [:delete, :trash].each do |directive|
// 271:     next if directive == :trash && ENV["HOMEBREW_TESTS_COVERAGE"].nil?
// 272:
// 273:     context "when using :#{directive}" do
// 274:       let(:dir) { TEST_TMPDIR }
// 275:       let(:absolute_path) { Pathname.new("#{dir}/absolute_path") }
// 276:       let(:path_with_tilde) { Pathname.new("#{dir}/path_with_tilde") }
// 277:       let(:glob_path) { Pathname.new("#{dir}/glob_path") }
// 278:       let(:glob_path_alt) { Pathname.new("#{dir}/glob_path_alt") }
// 279:       let(:paths) { [absolute_path, path_with_tilde, glob_path, glob_path_alt] }
// 280:       let(:fake_system_command) { NeverSudoSystemCommand }
// 281:       let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-#{directive}")) }
// 282:
// 283:       around do |example|
// 284:         ENV["HOME"] = dir
// 285:
// 286:         FileUtils.touch paths
// 287:
// 288:         example.run
// 289:       ensure
// 290:         FileUtils.rm_f paths
// 291:       end
// 292:
// 293:       before do
// 294:         allow_any_instance_of(Cask::Artifact::AbstractUninstall).to receive(:trash_paths)
// 295:           .and_wrap_original do |method, *args, **kwargs|
// 296:             method.call(*args, **kwargs).tap do |trashed, _|
// 297:               FileUtils.rm_r trashed
// 298:             end
// 299:           end
// 300:       end
// 301:
// 302:       it "is supported" do
// 303:         expect(paths).to all(exist)
// 304:
// 305:         subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 306:
// 307:         paths.each do |path|
// 308:           expect(path).not_to exist
// 309:         end
// 310:       end
// 311:     end
// 312:   end
// 313:
// 314:   test_each([:script, :early_script]) do |script_type|
// 315:     context "when using #{script_type.inspect}" do
// 316:       let(:fake_system_command) { NeverSudoSystemCommand }
// 317:       let(:token) { "with-#{artifact_dsl_key}-#{script_type}".tr("_", "-") }
// 318:       let(:cask) { Cask::CaskLoader.load(cask_path(token.to_s)) }
// 319:       let(:script_pathname) { cask.staged_path.join("MyFancyPkg", "FancyUninstaller.tool") }
// 320:
// 321:       it "is supported" do
// 322:         allow(fake_system_command).to receive(:run).with(any_args).and_call_original
// 323:
// 324:         expect(fake_system_command).to receive(:run)
// 325:           .with(
// 326:             cask.staged_path.join("MyFancyPkg", "FancyUninstaller.tool"),
// 327:             args:         ["--please"],
// 328:             must_succeed: true,
// 329:             print_stdout: true,
// 330:             sudo:         false,
// 331:           )
// 332:
// 333:         InstallHelper.install_without_artifacts(cask)
// 334:         subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 335:       end
// 336:     end
// 337:   end
// 338:
// 339:   context "when using :login_item" do
// 340:     let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-login-item")) }
// 341:
// 342:     it "is supported" do
// 343:       expect(subject).to receive(:system_command)
// 344:         .with(
// 345:           "osascript",
// 346:           args: ["-e", 'tell application "System Events" to delete every login item whose name is "Fancy"'],
// 347:         )
// 348:         .and_return(instance_double(SystemCommand::Result, success?: true))
// 349:
// 350:       subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 351:     end
// 352:   end
// 353: end
