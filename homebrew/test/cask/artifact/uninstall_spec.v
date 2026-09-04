module artifact

import ruby
import homebrew.cask.artifact as core
import os

// Translated from Homebrew/brew `test/cask/artifact/uninstall_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const uninstall_spec_bundle_id = 'my.fancy.package.app'

fn uninstall_spec_runner(command core.UninstallCommand) !bool {
	_ = command
	return true
}

fn uninstall_spec_failed_runner(command core.UninstallCommand) !bool {
	_ = command
	return false
}

fn uninstall_spec_artifact(kind string) core.AbstractUninstallArtifact {
	mut directives := map[string]ruby.Value{}
	match kind {
		'quit' {
			directives['quit'] = ruby.string_array_value([
				uninstall_spec_bundle_id,
			])
		}
		'signal' {
			directives['signal'] = ruby.string_array_value(['TERM', uninstall_spec_bundle_id])
		}
		'signal_on_upgrade' {
			directives['signal'] = ruby.string_array_value(['TERM', uninstall_spec_bundle_id])
			directives['on_upgrade'] = ruby.string_value('signal')
		}
		'both_on_upgrade' {
			directives['quit'] = ruby.string_array_value([
				uninstall_spec_bundle_id,
			])
			directives['signal'] = ruby.string_array_value(['TERM', uninstall_spec_bundle_id])
			directives['on_upgrade'] = ruby.string_value('signal')
		}
		'quit_only' {
			directives['quit'] = ruby.string_array_value([
				uninstall_spec_bundle_id,
			])
			directives['signal'] = ruby.string_array_value(['TERM', uninstall_spec_bundle_id])
		}
		else {}
	}
	return core.new_abstract_uninstall_artifact('with-uninstall-${kind}', 'uninstall', directives) or {
		core.AbstractUninstallArtifact{}
	}
}

fn uninstall_spec_phase(kind string, upgrade bool, reinstall bool, quit bool,
	quit_success bool, runner core.UninstallCommandRunner) core.AbstractUninstallResult {
	mut artifact := uninstall_spec_artifact(kind)
	return core.uninstall_phase_with_command(mut artifact, core.UninstallPhaseOptions{
		upgrade: upgrade
		reinstall: reinstall
		quit: quit
		operation: core.AbstractUninstallOptions{
			running_processes: {
				uninstall_spec_bundle_id: [12345, 67890]
			}
			quit_success: {
				uninstall_spec_bundle_id: quit_success
			}
		}
	}, runner)
}

pub fn uninstall_spec_case(index int) bool {
	match index {
		4 {
			return 'quit' in uninstall_spec_phase('quit', true, false, true, true, uninstall_spec_runner).directive_order
		}
		5 {
			return 'quit' !in uninstall_spec_phase('quit', true, false, false, true, uninstall_spec_runner).directive_order
		}
		6 {
			return 'quit' in uninstall_spec_phase('quit', false, true, true, true, uninstall_spec_runner).directive_order
		}
		9 {
			return 'signal' !in uninstall_spec_phase('signal', true, false, true, true, uninstall_spec_runner).directive_order
		}
		10 {
			return 'signal' !in uninstall_spec_phase('signal', false, true, true, true, uninstall_spec_runner).directive_order
		}
		13 {
			result := uninstall_spec_phase('signal_on_upgrade', true, false, true, true, uninstall_spec_runner)
			return 'signal' in result.directive_order && result.commands.any(it.executable == '/bin/kill')
		}
		14 {
			result := uninstall_spec_phase('signal_on_upgrade', false, true, true, true, uninstall_spec_runner)
			return 'signal' in result.directive_order && result.commands.any(it.executable == '/bin/kill')
		}
		17 {
			result := uninstall_spec_phase('both_on_upgrade', true, false, true, true, uninstall_spec_runner)
			return 'quit' in result.directive_order && 'signal' in result.directive_order
		}
		20 {
			result := uninstall_spec_phase('quit_only', true, false, true, true, uninstall_spec_runner)
			return 'quit' in result.directive_order && 'signal' !in result.directive_order
		}
		25 {
			mut artifact := uninstall_spec_artifact('quit')
			result := core.uninstall_phase_with_command(mut artifact, core.UninstallPhaseOptions{
				upgrade: true
				operation: core.AbstractUninstallOptions{
					running_processes: {
						uninstall_spec_bundle_id: [12345]
					}
					quit_success: {
						uninstall_spec_bundle_id: true
					}
				}
			}, uninstall_spec_runner)
			return result.bundle_ids_to_reopen == [uninstall_spec_bundle_id] && artifact.bundle_ids_to_reopen == [
				uninstall_spec_bundle_id,
			]
		}
		26 {
			return uninstall_spec_phase('quit', false, false, true, true, uninstall_spec_runner).bundle_ids_to_reopen.len == 0
		}
		27 {
			result := uninstall_spec_phase('quit', true, false, true, false, uninstall_spec_failed_runner)
			return result.bundle_ids_to_reopen.len == 0 && result.warnings.any(it.contains('did not quit'))
		}
		34 {
			root := os.join_path(os.temp_dir(), 'brew-v-uninstall-post-${os.getpid()}')
			if os.exists(root) {
				os.rmdir_all(root) or { return false }
			}
			nested := os.join_path(root, 'nested', 'empty_directory_path')
			os.mkdir_all(nested) or { return false }
			os.write_file(os.join_path(root, '.DS_Store'), '') or { return false }
			artifact := core.new_abstract_uninstall_artifact('with-uninstall-rmdir', 'uninstall', {
				'rmdir': ruby.string_array_value([root])
			}) or { return false }
			result := core.post_uninstall_phase_with_command(artifact, core.AbstractUninstallOptions{}, uninstall_spec_runner)
			removed := !os.exists(root)
			if os.exists(root) {
				os.rmdir_all(root) or {}
			}
			return result.success && removed && 'rmdir' in result.directive_order
		}
		else {
			return false
		}
	}
}

fn uninstall_spec_artifact_value(kind string) ruby.Value {
	return core.abstract_uninstall_to_value(uninstall_spec_artifact(kind))
}

// Ruby let `let(:fake_system_command) { NeverSudoSystemCommand }` at line 8.
pub fn ruby_uninstall_spec_l8_d1_fake_system_command(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('UninstallCommandRunner', 'NeverSudoSystemCommand')
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-quit")) }` at line 14.
pub fn ruby_uninstall_spec_l14_d2_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-quit')
}

// Ruby let `let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }` at line 15.
pub fn ruby_uninstall_spec_l15_d3_artifact(args ...ruby.Value) ruby.Value {
	_ = args
	return uninstall_spec_artifact_value('quit')
}

// Ruby it `it "invokes :quit during upgrade" do` at line 17.
pub fn ruby_uninstall_spec_l17_d4_invokes(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(4))
}

// Ruby it `it "skips :quit during upgrade when quit is false" do` at line 28.
pub fn ruby_uninstall_spec_l28_d5_skips(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(5))
}

// Ruby it `it "invokes :quit during reinstall" do` at line 39.
pub fn ruby_uninstall_spec_l39_d6_invokes(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(6))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-signal")) }` at line 52.
pub fn ruby_uninstall_spec_l52_d7_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-signal')
}

// Ruby let `let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }` at line 53.
pub fn ruby_uninstall_spec_l53_d8_artifact(args ...ruby.Value) ruby.Value {
	_ = args
	return uninstall_spec_artifact_value('signal')
}

// Ruby it `it "skips :signal by default during upgrade" do` at line 55.
pub fn ruby_uninstall_spec_l55_d9_skips(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(9))
}

// Ruby it `it "skips :signal by default during reinstall" do` at line 66.
pub fn ruby_uninstall_spec_l66_d10_skips(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(10))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-signal-on-upgrade")) }` at line 79.
pub fn ruby_uninstall_spec_l79_d11_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-signal-on-upgrade')
}

// Ruby let `let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }` at line 80.
pub fn ruby_uninstall_spec_l80_d12_artifact(args ...ruby.Value) ruby.Value {
	_ = args
	return uninstall_spec_artifact_value('signal_on_upgrade')
}

// Ruby it `it "invokes :signal during upgrade" do` at line 82.
pub fn ruby_uninstall_spec_l82_d13_invokes(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(13))
}

// Ruby it `it "invokes :signal during reinstall" do` at line 93.
pub fn ruby_uninstall_spec_l93_d14_invokes(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(14))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-both-on-upgrade")) }` at line 107.
pub fn ruby_uninstall_spec_l107_d15_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-both-on-upgrade')
}

// Ruby let `let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }` at line 108.
pub fn ruby_uninstall_spec_l108_d16_artifact(args ...ruby.Value) ruby.Value {
	_ = args
	return uninstall_spec_artifact_value('both_on_upgrade')
}

// Ruby it `it "invokes both quit and signal during upgrade when on_upgrade: :signal" do` at line 110.
pub fn ruby_uninstall_spec_l110_d17_invokes(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(17))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-quit-only-on-upgrade")) }` at line 122.
pub fn ruby_uninstall_spec_l122_d18_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-quit-only-on-upgrade')
}

// Ruby let `let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }` at line 123.
pub fn ruby_uninstall_spec_l123_d19_artifact(args ...ruby.Value) ruby.Value {
	_ = args
	return uninstall_spec_artifact_value('quit_only')
}

// Ruby it `it "invokes quit but not signal during upgrade without on_upgrade: :signal" do` at line 125.
pub fn ruby_uninstall_spec_l125_d20_invokes(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(20))
}

// Ruby subject `subject(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }` at line 139.
pub fn ruby_uninstall_spec_l139_d21_artifact(args ...ruby.Value) ruby.Value {
	_ = args
	return uninstall_spec_artifact_value('quit')
}

// Ruby let `let(:fake_system_command) { NeverSudoSystemCommand }` at line 141.
pub fn ruby_uninstall_spec_l141_d22_fake_system_command(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('UninstallCommandRunner', 'NeverSudoSystemCommand')
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-quit")) }` at line 142.
pub fn ruby_uninstall_spec_l142_d23_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-quit')
}

// Ruby let `let(:bundle_id) { "my.fancy.package.app" }` at line 143.
pub fn ruby_uninstall_spec_l143_d24_bundle_id(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(uninstall_spec_bundle_id)
}

// Ruby it `it "tracks a successfully quit app during upgrade" do` at line 147.
pub fn ruby_uninstall_spec_l147_d25_tracks(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(25))
}

// Ruby it `it "does not track during regular uninstall" do` at line 157.
pub fn ruby_uninstall_spec_l157_d26_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(26))
}

// Ruby it `it "does not track when quit times out" do` at line 167.
pub fn ruby_uninstall_spec_l167_d27_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(27))
}

// Ruby subject `subject(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }` at line 182.
pub fn ruby_uninstall_spec_l182_d28_artifact(args ...ruby.Value) ruby.Value {
	_ = args
	return core.abstract_uninstall_to_value(core.new_abstract_uninstall_artifact('with-uninstall-rmdir', 'uninstall', {
		'rmdir': ruby.string_array_value(['/tmp/empty_directory_path'])
	}) or { core.AbstractUninstallArtifact{} })
}

// Ruby let `let(:fake_system_command) { NeverSudoSystemCommand }` at line 185.
pub fn ruby_uninstall_spec_l185_d29_fake_system_command(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('UninstallCommandRunner', 'NeverSudoSystemCommand')
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-rmdir")) }` at line 186.
pub fn ruby_uninstall_spec_l186_d30_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('with-uninstall-rmdir')
}

// Ruby let `let(:empty_directory) { Pathname.new("#{TEST_TMPDIR}/empty_directory_path") }` at line 187.
pub fn ruby_uninstall_spec_l187_d31_empty_directory(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(os.join_path(os.temp_dir(), 'empty_directory_path'))
}

// Ruby let `let(:empty_directory_tree) { empty_directory.join("nested", "empty_directory_path") }` at line 188.
pub fn ruby_uninstall_spec_l188_d32_empty_directory_tree(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(os.join_path(os.temp_dir(), 'empty_directory_path', 'nested', 'empty_directory_path'))
}

// Ruby let `let(:ds_store) { empty_directory.join(".DS_Store") }` at line 189.
pub fn ruby_uninstall_spec_l189_d33_ds_store(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(os.join_path(os.temp_dir(), 'empty_directory_path', '.DS_Store'))
}

// Ruby it `it "is supported" do` at line 200.
pub fn ruby_uninstall_spec_l200_d34_is(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(uninstall_spec_case(34))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples/uninstall_zap"
// 5:
// 6: RSpec.describe Cask::Artifact::Uninstall, :cask do
// 7:   describe "#uninstall_phase" do
// 8:     let(:fake_system_command) { NeverSudoSystemCommand }
// 9:
// 10:     include_examples "#uninstall_phase or #zap_phase"
// 11:
// 12:     describe "upgrade/reinstall uninstall directives" do
// 13:       context "with-uninstall-quit" do
// 14:         let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-quit")) }
// 15:         let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }
// 16:
// 17:         it "invokes :quit during upgrade" do
// 18:           called_directives = T.let([], T::Array[Symbol])
// 19:           allow(artifact).to receive(:dispatch_uninstall_directive) do |directive, **options|
// 20:             called_directives << directive if options[:command] == fake_system_command
// 21:           end
// 22:
// 23:           artifact.uninstall_phase(upgrade: true, command: fake_system_command)
// 24:
// 25:           expect(called_directives).to include(:quit)
// 26:         end
// 27:
// 28:         it "skips :quit during upgrade when quit is false" do
// 29:           called_directives = T.let([], T::Array[Symbol])
// 30:           allow(artifact).to receive(:dispatch_uninstall_directive) do |directive, **options|
// 31:             called_directives << directive if options[:command] == fake_system_command
// 32:           end
// 33:
// 34:           artifact.uninstall_phase(upgrade: true, quit: false, command: fake_system_command)
// 35:
// 36:           expect(called_directives).not_to include(:quit)
// 37:         end
// 38:
// 39:         it "invokes :quit during reinstall" do
// 40:           called_directives = T.let([], T::Array[Symbol])
// 41:           allow(artifact).to receive(:dispatch_uninstall_directive) do |directive, **options|
// 42:             called_directives << directive if options[:command] == fake_system_command
// 43:           end
// 44:
// 45:           artifact.uninstall_phase(reinstall: true, command: fake_system_command)
// 46:
// 47:           expect(called_directives).to include(:quit)
// 48:         end
// 49:       end
// 50:
// 51:       context "with-uninstall-signal" do
// 52:         let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-signal")) }
// 53:         let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }
// 54:
// 55:         it "skips :signal by default during upgrade" do
// 56:           called_directives = T.let([], T::Array[Symbol])
// 57:           allow(artifact).to receive(:dispatch_uninstall_directive) do |directive, **options|
// 58:             called_directives << directive if options[:command] == fake_system_command
// 59:           end
// 60:
// 61:           artifact.uninstall_phase(upgrade: true, command: fake_system_command)
// 62:
// 63:           expect(called_directives).not_to include(:signal)
// 64:         end
// 65:
// 66:         it "skips :signal by default during reinstall" do
// 67:           called_directives = T.let([], T::Array[Symbol])
// 68:           allow(artifact).to receive(:dispatch_uninstall_directive) do |directive, **options|
// 69:             called_directives << directive if options[:command] == fake_system_command
// 70:           end
// 71:
// 72:           artifact.uninstall_phase(reinstall: true, command: fake_system_command)
// 73:
// 74:           expect(called_directives).not_to include(:signal)
// 75:         end
// 76:       end
// 77:
// 78:       context "with-uninstall-signal-on-upgrade" do
// 79:         let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-signal-on-upgrade")) }
// 80:         let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }
// 81:
// 82:         it "invokes :signal during upgrade" do
// 83:           called_directives = T.let([], T::Array[Symbol])
// 84:           allow(artifact).to receive(:dispatch_uninstall_directive) do |directive, **options|
// 85:             called_directives << directive if options[:command] == fake_system_command
// 86:           end
// 87:
// 88:           artifact.uninstall_phase(upgrade: true, command: fake_system_command)
// 89:
// 90:           expect(called_directives).to include(:signal)
// 91:         end
// 92:
// 93:         it "invokes :signal during reinstall" do
// 94:           called_directives = T.let([], T::Array[Symbol])
// 95:           allow(artifact).to receive(:dispatch_uninstall_directive) do |directive, **options|
// 96:             called_directives << directive if options[:command] == fake_system_command
// 97:           end
// 98:
// 99:           artifact.uninstall_phase(reinstall: true, command: fake_system_command)
// 100:
// 101:           expect(called_directives).to include(:signal)
// 102:         end
// 103:       end
// 104:     end
// 105:
// 106:     context "with-uninstall-both-on-upgrade" do
// 107:       let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-both-on-upgrade")) }
// 108:       let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }
// 109:
// 110:       it "invokes both quit and signal during upgrade when on_upgrade: :signal" do
// 111:         called_directives = T.let([], T::Array[Symbol])
// 112:         allow(artifact).to receive(:dispatch_uninstall_directive) do |directive, **options|
// 113:           called_directives << directive if options[:command] == fake_system_command
// 114:         end
// 115:
// 116:         artifact.uninstall_phase(upgrade: true, command: fake_system_command)
// 117:         expect(called_directives).to include(:quit, :signal)
// 118:       end
// 119:     end
// 120:
// 121:     context "with-uninstall-quit-only-on-upgrade" do
// 122:       let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-quit-only-on-upgrade")) }
// 123:       let(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }
// 124:
// 125:       it "invokes quit but not signal during upgrade without on_upgrade: :signal" do
// 126:         called_directives = T.let([], T::Array[Symbol])
// 127:         allow(artifact).to receive(:dispatch_uninstall_directive) do |directive, **options|
// 128:           called_directives << directive if options[:command] == fake_system_command
// 129:         end
// 130:
// 131:         artifact.uninstall_phase(upgrade: true, command: fake_system_command)
// 132:         expect(called_directives).to include(:quit)
// 133:         expect(called_directives).not_to include(:signal)
// 134:       end
// 135:     end
// 136:   end
// 137:
// 138:   describe "#bundle_ids_to_reopen" do
// 139:     subject(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }
// 140:
// 141:     let(:fake_system_command) { NeverSudoSystemCommand }
// 142:     let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-quit")) }
// 143:     let(:bundle_id) { "my.fancy.package.app" }
// 144:
// 145:     before { allow(User.current).to receive(:gui?).and_return true }
// 146:
// 147:     it "tracks a successfully quit app during upgrade" do
// 148:       allow(artifact).to receive(:running?).with(bundle_id).and_return(true, false)
// 149:       allow(artifact).to receive(:quit).with(bundle_id)
// 150:                                        .and_return(instance_double(SystemCommand::Result, success?: true))
// 151:
// 152:       artifact.uninstall_quit(bundle_id, upgrade: true, command: fake_system_command)
// 153:
// 154:       expect(artifact.bundle_ids_to_reopen).to eq [bundle_id]
// 155:     end
// 156:
// 157:     it "does not track during regular uninstall" do
// 158:       allow(artifact).to receive(:running?).with(bundle_id).and_return(true, false)
// 159:       allow(artifact).to receive(:quit).with(bundle_id)
// 160:                                        .and_return(instance_double(SystemCommand::Result, success?: true))
// 161:
// 162:       artifact.uninstall_quit(bundle_id, upgrade: false, command: fake_system_command)
// 163:
// 164:       expect(artifact.bundle_ids_to_reopen).to be_empty
// 165:     end
// 166:
// 167:     it "does not track when quit times out" do
// 168:       allow(artifact).to receive(:running?).with(bundle_id).and_return(true)
// 169:       allow(artifact).to receive(:quit).with(bundle_id)
// 170:                                        .and_return(instance_double(SystemCommand::Result, success?: false))
// 171:       allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
// 172:
// 173:       expect do
// 174:         artifact.uninstall_quit(bundle_id, upgrade: true, command: fake_system_command)
// 175:       end.to output(/did not quit/).to_stderr
// 176:
// 177:       expect(artifact.bundle_ids_to_reopen).to be_empty
// 178:     end
// 179:   end
// 180:
// 181:   describe "#post_uninstall_phase" do
// 182:     subject(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }
// 183:
// 184:     context "when using :rmdir" do
// 185:       let(:fake_system_command) { NeverSudoSystemCommand }
// 186:       let(:cask) { Cask::CaskLoader.load(cask_path("with-uninstall-rmdir")) }
// 187:       let(:empty_directory) { Pathname.new("#{TEST_TMPDIR}/empty_directory_path") }
// 188:       let(:empty_directory_tree) { empty_directory.join("nested", "empty_directory_path") }
// 189:       let(:ds_store) { empty_directory.join(".DS_Store") }
// 190:
// 191:       before do
// 192:         empty_directory_tree.mkpath
// 193:         FileUtils.touch ds_store
// 194:       end
// 195:
// 196:       after do
// 197:         FileUtils.rm_rf empty_directory
// 198:       end
// 199:
// 200:       it "is supported" do
// 201:         expect(empty_directory_tree).to exist
// 202:         expect(ds_store).to exist
// 203:
// 204:         artifact.post_uninstall_phase(command: fake_system_command)
// 205:
// 206:         expect(ds_store).not_to exist
// 207:         expect(empty_directory).not_to exist
// 208:       end
// 209:     end
// 210:   end
// 211: end
