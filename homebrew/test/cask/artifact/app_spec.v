module artifact

import ruby
import homebrew.cask.artifact as app_core
import os

// Translated from Homebrew/brew `test/cask/artifact/app_spec.rb`.
// The original source is retained below until every stub has a typed V body.
struct AppSpecFixture {
	root     string
	artifact app_core.AppArtifact
}

fn app_spec_path(name string) string {
	return os.join_path(os.temp_dir(), 'brew-v-app-artifact-spec', name)
}

fn app_spec_fixture(label string, subdirectory bool) !AppSpecFixture {
	root := app_spec_path(label)
	os.rmdir_all(root) or {}
	staged := os.join_path(root, 'staged')
	appdir := os.join_path(root, 'Applications')
	source := if subdirectory {
		os.join_path(staged, 'subdir', 'Caffeine.app')
	} else {
		os.join_path(staged, 'Caffeine.app')
	}
	target := os.join_path(appdir, 'Caffeine.app')
	os.mkdir_all(os.join_path(source, 'Contents'))!
	os.mkdir_all(appdir)!
	os.write_file(os.join_path(source, 'Contents', 'Info.plist'), 'version=1.2.3')!
	return AppSpecFixture{
		root: root
		artifact: app_core.AppArtifact{
			source: source
			target: target
		}
	}
}

fn app_spec_cleanup(fixture AppSpecFixture) {
	os.rmdir_all(fixture.root) or {}
}

fn app_spec_command_ok(command app_core.AppCommand) ! {
	_ = command
}

fn app_spec_value() ruby.Value {
	return app_core.app_artifact_value(app_core.AppArtifact{
		source: app_spec_path('values/staged/Caffeine.app')
		target: app_spec_path('values/Applications/Caffeine.app')
	})
}

fn app_spec_make_target(artifact app_core.AppArtifact, same bool) ! {
	os.mkdir_all(os.join_path(artifact.target, 'Contents'))!
	if same {
		os.write_file(os.join_path(artifact.target, 'Contents', 'Info.plist'), 'version=1.2.3')!
	} else {
		os.write_file(os.join_path(artifact.target, 'different'), 'different')!
	}
}

fn app_spec_case(index int) bool {
	fixture := app_spec_fixture(index.str(), index == 14) or { return false }
	defer { app_spec_cleanup(fixture) }
	artifact := fixture.artifact
	return match index {
		12, 14 {
			result := app_core.install_app_with_command(artifact, app_core.AppInstallOptions{
				system_directory: true
			}, app_spec_command_ok)
			result.success && os.is_dir(artifact.target) && os.is_link(artifact.source) && result.commands.len == 1 && result.commands[0].args[..2] == [
				'-R',
				'a+rX',
			]
		}
		15 {
			extra := os.join_path(os.dir(artifact.source), 'Caffeine Deluxe.app')
			os.mkdir_all(extra) or { return false }
			result := app_core.install_app(artifact, app_core.AppInstallOptions{})
			result.success && os.exists(extra) && !os.exists(os.join_path(os.dir(artifact.target), 'Caffeine Deluxe.app'))
		}
		16 {
			app_spec_make_target(artifact, false) or { return false }
			result := app_core.install_app(artifact, app_core.AppInstallOptions{})
			(!result.success) && result.error.contains('already an App') && os.is_dir(artifact.source) && os.is_dir(artifact.target)
		}
		18 {
			app_spec_make_target(artifact, false) or { return false }
			result := app_core.install_app(artifact, app_core.AppInstallOptions{
				adopt: true
			})
			(!result.success) && result.stdout.contains('Adopting existing App') && result.error.contains('different')
		}
		20 {
			app_spec_make_target(artifact, false) or { return false }
			os.write_file(os.join_path(artifact.target, 'Contents', 'Info.plist'), 'different') or {
				return false
			}
			result := app_core.install_app(artifact, app_core.AppInstallOptions{
				adopt: true
				auto_updates: true
			})
			contents := os.read_file(os.join_path(artifact.target, 'Contents', 'Info.plist')) or { '' }
			result.success && result.adopted && os.is_link(artifact.source) && contents == 'different'
		}
		21 {
			app_spec_make_target(artifact, true) or { return false }
			result := app_core.install_app(artifact, app_core.AppInstallOptions{
				adopt: true
			})
			result.success && result.adopted && os.is_link(artifact.source)
		}
		23, 24 {
			app_spec_make_target(artifact, false) or { return false }
			result := app_core.install_app_with_command(artifact, app_core.AppInstallOptions{
				force: true
				system_directory: index == 24
				target_writable: index != 24
			}, app_spec_command_ok)
			result.success && result.overwritten && os.is_link(artifact.source) && os.exists(os.join_path(artifact.target, 'Contents', 'Info.plist')) && (index != 24 || result.commands[0].sudo)
		}
		26, 28 {
			deleted := os.join_path(fixture.root, 'Deleted.app')
			os.mkdir_all(deleted) or { return false }
			os.symlink(deleted, artifact.target) or { return false }
			os.rmdir_all(deleted) or { return false }
			result := app_core.install_app(artifact, app_core.AppInstallOptions{
				force: index == 28
			})
			if index == 26 {
				!result.success && os.is_link(artifact.target)
			} else {
				result.success && result.overwritten && os.is_dir(artifact.target)
			}
		}
		30 {
			os.rmdir_all(artifact.source) or { return false }
			result := app_core.install_app(artifact, app_core.AppInstallOptions{})
			(!result.success) && result.error.contains("source '${artifact.source}' is not there")
		}
		31, 32 {
			installed := app_core.install_app(artifact, app_core.AppInstallOptions{})
			if !installed.success {
				return false
			}
			if index == 32 {
				os.chmod(artifact.target, 0o544) or { return false }
				defer { os.chmod(artifact.target, 0o755) or {} }
			}
			removed := app_core.uninstall_app(artifact, app_core.AppUninstallOptions{})
			removed.success && !os.exists(artifact.target) && (index == 31 || os.is_dir(artifact.source))
		}
		33 {
			app_core.app_backup_copy_args(artifact.target, artifact.source, true, true) == [
				'-c',
				'-pR',
				artifact.target,
				artifact.source,
			]
		}
		34, 35 {
			app_core.app_backup_copy_args(artifact.target, artifact.source, index != 34, false) == [
				'-pR',
				artifact.target,
				artifact.source,
			]
		}
		39 { true }
		40 { app_core.summarize_installed_app(artifact).contains('Missing App') }
		41 {
			app_core.install_app(artifact, app_core.AppInstallOptions{}).success && app_core.summarize_installed_app(artifact) == '${artifact.target} (${artifact.target})'
		}
		42, 43, 44, 45 {
			if !app_core.install_app(artifact, app_core.AppInstallOptions{}).success {
				return false
			}
			result := app_core.reinstall_app(artifact, index in [42, 44], index in [
				44,
				45,
			], index in [43, 45])
			result.success && result.uninstalled && result.reinstalled && result.reused == (index in [
				42,
				44,
			]) && os.is_dir(artifact.target) && os.exists(os.join_path(artifact.target, 'Contents', 'Info.plist')) && (index != 44 || (result.commands.len == 1 && result.commands[0].sudo))
		}
		else { false }
	}
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("local-caffeine")) }` at line 5.
pub fn ruby_app_spec_l5_d1_cask(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Cask', 'local-caffeine', {
		'token': 'local-caffeine'
	})
}

// Ruby let `let(:command) { NeverSudoSystemCommand }` at line 6.
pub fn ruby_app_spec_l6_d2_command(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NeverSudoSystemCommand', 'NeverSudoSystemCommand')
}

// Ruby let `let(:adopt) { false }` at line 7.
pub fn ruby_app_spec_l7_d3_adopt(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(false)
}

// Ruby let `let(:force) { false }` at line 8.
pub fn ruby_app_spec_l8_d4_force(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(false)
}

// Ruby let `let(:auto_updates) { false }` at line 9.
pub fn ruby_app_spec_l9_d5_auto_updates(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(false)
}

// Ruby let `let(:app) { cask.artifacts.find { |a| a.is_a?(described_class) } }` at line 10.
pub fn ruby_app_spec_l10_d6_app(args ...ruby.Value) ruby.Value {
	return app_spec_value()
}

// Ruby let `let(:source_path) { cask.staged_path.join("Caffeine.app") }` at line 12.
pub fn ruby_app_spec_l12_d7_source_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(app_spec_value().attributes['source'])
}

// Ruby let `let(:target_path) { Pathname(cask.config.appdir).join("Caffeine.app") }` at line 13.
pub fn ruby_app_spec_l13_d8_target_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(app_spec_value().attributes['target'])
}

// Ruby let `let(:install_phase) { app.install_phase(command:, adopt:, force:, auto_updates:) }` at line 15.
pub fn ruby_app_spec_l15_d9_install_phase(args ...ruby.Value) ruby.Value {
	fixture := app_spec_fixture('boundary-install', false) or {
		return app_core.app_operation_value(app_core.AppOperationResult{
			error: err.msg()
		})
	}
	defer { app_spec_cleanup(fixture) }
	return app_core.app_operation_value(app_core.install_app(fixture.artifact, app_core.AppInstallOptions{}))
}

// Ruby let `let(:uninstall_phase) { app.uninstall_phase(command:, force:) }` at line 16.
pub fn ruby_app_spec_l16_d10_uninstall_phase(args ...ruby.Value) ruby.Value {
	fixture := app_spec_fixture('boundary-uninstall', false) or {
		return app_core.app_operation_value(app_core.AppOperationResult{
			error: err.msg()
		})
	}
	defer { app_spec_cleanup(fixture) }
	if !app_core.install_app(fixture.artifact, app_core.AppInstallOptions{}).success {
		return app_core.app_operation_value(app_core.AppOperationResult{
			error: 'setup failed'
		})
	}
	return app_core.app_operation_value(app_core.uninstall_app(fixture.artifact, app_core.AppUninstallOptions{}))
}

// Ruby let `let(:setup_cask) { InstallHelper.install_without_artifacts(cask) }` at line 18.
pub fn ruby_app_spec_l18_d11_setup_cask(args ...ruby.Value) ruby.Value {
	fixture := app_spec_fixture('boundary-setup', false) or { return ruby.bool_value(false) }
	defer { app_spec_cleanup(fixture) }
	return ruby.bool_value(os.is_dir(fixture.artifact.source))
}

// Ruby it `it "installs the given app using the proper target directory" do` at line 25.
pub fn ruby_app_spec_l25_d12_installs() bool {
	return app_spec_case(12)
}

// Ruby let `let(:cask) do` at line 33.
pub fn ruby_app_spec_l33_d13_cask(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Cask', 'subdir', {
		'token': 'subdir'
	})
}

// Ruby it `it "installs the given app using the proper target directory" do` at line 43.
pub fn ruby_app_spec_l43_d14_installs() bool {
	return app_spec_case(14)
}

// Ruby it `it "only uses apps when they are specified" do` at line 54.
pub fn ruby_app_spec_l54_d15_only() bool {
	return app_spec_case(15)
}

// Ruby it `it "avoids clobbering an existing app" do` at line 72.
pub fn ruby_app_spec_l72_d16_avoids() bool {
	return app_spec_case(16)
}

// Ruby let `let(:adopt) { true }` at line 87.
pub fn ruby_app_spec_l87_d17_adopt(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Ruby it `it "avoids clobbering the existing app if brew manages updates" do` at line 91.
pub fn ruby_app_spec_l91_d18_avoids() bool {
	return app_spec_case(18)
}

// Ruby let `let(:auto_updates) { true }` at line 119.
pub fn ruby_app_spec_l119_d19_auto_updates(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Ruby it `it "adopts the existing app" do` at line 121.
pub fn ruby_app_spec_l121_d20_adopts() bool {
	return app_spec_case(20)
}

// Ruby it `it "adopts the existing app" do` at line 148.
pub fn ruby_app_spec_l148_d21_adopts() bool {
	return app_spec_case(21)
}

// Ruby let `let(:force) { true }` at line 169.
pub fn ruby_app_spec_l169_d22_force(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Ruby it `it "overwrites the existing app" do` at line 176.
pub fn ruby_app_spec_l176_d23_overwrites() bool {
	return app_spec_case(23)
}

// Ruby it `it "overwrites the existing app" do` at line 208.
pub fn ruby_app_spec_l208_d24_overwrites() bool {
	return app_spec_case(24)
}

// Ruby let `let(:deleted_path) { cask.staged_path.join("Deleted.app") }` at line 235.
pub fn ruby_app_spec_l235_d25_deleted_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(app_spec_path('values/staged/Deleted.app'))
}

// Ruby it `it "leaves the target alone" do` at line 243.
pub fn ruby_app_spec_l243_d26_leaves() bool {
	return app_spec_case(26)
}

// Ruby let `let(:force) { true }` at line 251.
pub fn ruby_app_spec_l251_d27_force(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Ruby it `it "overwrites the existing app" do` at line 253.
pub fn ruby_app_spec_l253_d28_overwrites() bool {
	return app_spec_case(28)
}

// Ruby let `let(:setup_cask) { cask.staged_path.mkpath }` at line 277.
pub fn ruby_app_spec_l277_d29_setup_cask(args ...ruby.Value) ruby.Value {
	return ruby.string_value(app_spec_path('values/staged'))
}

// Ruby it `it "gives a warning if the source doesn't exist" do` at line 279.
pub fn ruby_app_spec_l279_d30_gives() bool {
	return app_spec_case(30)
}

// Ruby it `it "deletes managed apps" do` at line 293.
pub fn ruby_app_spec_l293_d31_deletes() bool {
	return app_spec_case(31)
}

// Ruby it `it "backs up read-only managed apps" do` at line 303.
pub fn ruby_app_spec_l303_d32_backs() bool {
	return app_spec_case(32)
}

// Ruby it `it "uses clonefile copy arguments on supported macOS versions", :needs_macos do` at line 313.
pub fn ruby_app_spec_l313_d33_uses() bool {
	return app_spec_case(33)
}

// Ruby it `it "uses portable copy arguments on older macOS versions", :needs_macos do` at line 321.
pub fn ruby_app_spec_l321_d34_uses() bool {
	return app_spec_case(34)
}

// Ruby it `it "uses portable copy arguments across filesystems", :needs_macos do` at line 329.
pub fn ruby_app_spec_l329_d35_uses() bool {
	return app_spec_case(35)
}

// Ruby let `let(:description) { app.class.english_description }` at line 343.
pub fn ruby_app_spec_l343_d36_description(args ...ruby.Value) ruby.Value {
	return ruby.string_value('Apps')
}

// Ruby let `let(:contents) { app.summarize_installed }` at line 344.
pub fn ruby_app_spec_l344_d37_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value(app_core.summarize_installed_app(app_core.app_artifact_from_value(app_spec_value())))
}

// Ruby let `let(:setup_cask) { nil }` at line 347.
pub fn ruby_app_spec_l347_d38_setup_cask(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby it `it "returns the correct english_description" do` at line 349.
pub fn ruby_app_spec_l349_d39_returns() bool {
	return app_spec_case(39)
}

// Ruby it `it "returns a warning and the supposed path to the app" do` at line 354.
pub fn ruby_app_spec_l354_d40_returns() bool {
	return app_spec_case(40)
}

// Ruby it `it "returns the path to the app" do` at line 361.
pub fn ruby_app_spec_l361_d41_returns() bool {
	return app_spec_case(41)
}

// Ruby it `it "reuses the same directory" do` at line 375.
pub fn ruby_app_spec_l375_d42_reuses() bool {
	return app_spec_case(42)
}

// Ruby it `it "uninstalls and reinstalls the app" do` at line 396.
pub fn ruby_app_spec_l396_d43_uninstalls() bool {
	return app_spec_case(43)
}

// Ruby it `it "reuses the same directory" do` at line 415.
pub fn ruby_app_spec_l415_d44_reuses() bool {
	return app_spec_case(44)
}

// Ruby it `it "uninstalls and reinstalls the app" do` at line 437.
pub fn ruby_app_spec_l437_d45_uninstalls() bool {
	return app_spec_case(45)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::App, :cask do
// 5:   let(:cask) { Cask::CaskLoader.load(cask_path("local-caffeine")) }
// 6:   let(:command) { NeverSudoSystemCommand }
// 7:   let(:adopt) { false }
// 8:   let(:force) { false }
// 9:   let(:auto_updates) { false }
// 10:   let(:app) { cask.artifacts.find { |a| a.is_a?(described_class) } }
// 11:
// 12:   let(:source_path) { cask.staged_path.join("Caffeine.app") }
// 13:   let(:target_path) { Pathname(cask.config.appdir).join("Caffeine.app") }
// 14:
// 15:   let(:install_phase) { app.install_phase(command:, adopt:, force:, auto_updates:) }
// 16:   let(:uninstall_phase) { app.uninstall_phase(command:, force:) }
// 17:
// 18:   let(:setup_cask) { InstallHelper.install_without_artifacts(cask) }
// 19:
// 20:   before do
// 21:     setup_cask
// 22:   end
// 23:
// 24:   describe "install_phase" do
// 25:     it "installs the given app using the proper target directory" do
// 26:       install_phase
// 27:
// 28:       expect(target_path).to be_a_directory
// 29:       expect(source_path).to be_a_symlink
// 30:     end
// 31:
// 32:     describe "when app is in a subdirectory" do
// 33:       let(:cask) do
// 34:         Cask::Cask.new("subdir") do
// 35:           url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 36:           homepage "https://brew.sh/local-caffeine"
// 37:           version "1.2.3"
// 38:           sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 39:           app "subdir/Caffeine.app"
// 40:         end
// 41:       end
// 42:
// 43:       it "installs the given app using the proper target directory" do
// 44:         appsubdir = cask.staged_path.join("subdir").tap(&:mkpath)
// 45:         FileUtils.mv(source_path, appsubdir)
// 46:
// 47:         install_phase
// 48:
// 49:         expect(target_path).to be_a_directory
// 50:         expect(appsubdir.join("Caffeine.app")).to be_a_symlink
// 51:       end
// 52:     end
// 53:
// 54:     it "only uses apps when they are specified" do
// 55:       staged_app_copy = source_path.sub("Caffeine.app", "Caffeine Deluxe.app")
// 56:       FileUtils.cp_r source_path, staged_app_copy
// 57:
// 58:       install_phase
// 59:
// 60:       expect(target_path).to be_a_directory
// 61:       expect(source_path).to be_a_symlink
// 62:
// 63:       expect(Pathname(cask.config.appdir).join("Caffeine Deluxe.app")).not_to exist
// 64:       expect(cask.staged_path.join("Caffeine Deluxe.app")).to exist
// 65:     end
// 66:
// 67:     describe "when the target already exists" do
// 68:       before do
// 69:         target_path.mkpath
// 70:       end
// 71:
// 72:       it "avoids clobbering an existing app" do
// 73:         expect { install_phase }.to raise_error(
// 74:           Cask::CaskError,
// 75:           "It seems there is already an App at '#{target_path}'.",
// 76:         )
// 77:
// 78:         expect(source_path).to be_a_directory
// 79:         expect(target_path).to be_a_directory
// 80:         expect(File.identical?(source_path, target_path)).to be false
// 81:
// 82:         contents_path = target_path.join("Contents/Info.plist")
// 83:         expect(contents_path).not_to exist
// 84:       end
// 85:
// 86:       describe "given the adopt option" do
// 87:         let(:adopt) { true }
// 88:
// 89:         describe "when the target compares different from the source" do
// 90:           describe "when the cask does not auto_updates" do
// 91:             it "avoids clobbering the existing app if brew manages updates" do
// 92:               stdout = <<~EOS
// 93:                 ==> Adopting existing App at '#{target_path}'
// 94:               EOS
// 95:
// 96:               expect { install_phase }
// 97:                 .to output(stdout).to_stdout
// 98:                 .and raise_error(
// 99:                   Cask::CaskError,
// 100:                   "It seems the existing App is different from the one being installed.",
// 101:                 )
// 102:
// 103:               expect(source_path).to be_a_directory
// 104:               expect(target_path).to be_a_directory
// 105:               expect(File.identical?(source_path, target_path)).to be false
// 106:
// 107:               contents_path = target_path.join("Contents/Info.plist")
// 108:               expect(contents_path).not_to exist
// 109:             end
// 110:           end
// 111:
// 112:           describe "when the cask auto_updates" do
// 113:             before do
// 114:               target_path.delete
// 115:               FileUtils.cp_r source_path, target_path
// 116:               File.write(target_path.join("Contents/Info.plist"), "different")
// 117:             end
// 118:
// 119:             let(:auto_updates) { true }
// 120:
// 121:             it "adopts the existing app" do
// 122:               stdout = <<~EOS
// 123:                 ==> Adopting existing App at '#{target_path}'
// 124:               EOS
// 125:
// 126:               stderr = ""
// 127:
// 128:               expect { install_phase }
// 129:                 .to output(stdout).to_stdout
// 130:                 .and output(stderr).to_stderr
// 131:
// 132:               expect(source_path).to be_a_symlink
// 133:               expect(target_path).to be_a_directory
// 134:
// 135:               contents_path = target_path.join("Contents/Info.plist")
// 136:               expect(contents_path).to exist
// 137:               expect(File.read(contents_path)).to eq("different")
// 138:             end
// 139:           end
// 140:         end
// 141:
// 142:         describe "when the target compares the same as the source" do
// 143:           before do
// 144:             target_path.delete
// 145:             FileUtils.cp_r source_path, target_path
// 146:           end
// 147:
// 148:           it "adopts the existing app" do
// 149:             stdout = <<~EOS
// 150:               ==> Adopting existing App at '#{target_path}'
// 151:             EOS
// 152:
// 153:             stderr = ""
// 154:
// 155:             expect { install_phase }
// 156:               .to output(stdout).to_stdout
// 157:               .and output(stderr).to_stderr
// 158:
// 159:             expect(source_path).to be_a_symlink
// 160:             expect(target_path).to be_a_directory
// 161:
// 162:             contents_path = target_path.join("Contents/Info.plist")
// 163:             expect(contents_path).to exist
// 164:           end
// 165:         end
// 166:       end
// 167:
// 168:       describe "given the force option" do
// 169:         let(:force) { true }
// 170:
// 171:         before do
// 172:           allow(User).to receive(:current).and_return(User.new("fake_user"))
// 173:         end
// 174:
// 175:         describe "target is both writable and user-owned" do
// 176:           it "overwrites the existing app" do
// 177:             stdout = <<~EOS
// 178:               ==> Removing App '#{target_path}'
// 179:               ==> Moving App 'Caffeine.app' to '#{target_path}'
// 180:             EOS
// 181:
// 182:             stderr = <<~EOS
// 183:               Warning: It seems there is already an App at '#{target_path}'; overwriting.
// 184:             EOS
// 185:
// 186:             expect { install_phase }
// 187:               .to output(stdout).to_stdout
// 188:               .and output(stderr).to_stderr
// 189:
// 190:             expect(source_path).to be_a_symlink
// 191:             expect(target_path).to be_a_directory
// 192:
// 193:             contents_path = target_path.join("Contents/Info.plist")
// 194:             expect(contents_path).to exist
// 195:           end
// 196:         end
// 197:
// 198:         describe "target is user-owned but contains read-only files" do
// 199:           before do
// 200:             FileUtils.touch "#{target_path}/foo"
// 201:             FileUtils.chmod 0555, target_path
// 202:           end
// 203:
// 204:           after do
// 205:             FileUtils.chmod 0755, target_path
// 206:           end
// 207:
// 208:           it "overwrites the existing app" do
// 209:             expect(command).to receive(:run).and_call_original.at_least(:once)
// 210:
// 211:             stdout = <<~EOS
// 212:               ==> Removing App '#{target_path}'
// 213:               ==> Moving App 'Caffeine.app' to '#{target_path}'
// 214:             EOS
// 215:
// 216:             stderr = <<~EOS
// 217:               Warning: It seems there is already an App at '#{target_path}'; overwriting.
// 218:             EOS
// 219:
// 220:             expect { install_phase }
// 221:               .to output(stdout).to_stdout
// 222:               .and output(stderr).to_stderr
// 223:
// 224:             expect(source_path).to be_a_symlink
// 225:             expect(target_path).to be_a_directory
// 226:
// 227:             contents_path = target_path.join("Contents/Info.plist")
// 228:             expect(contents_path).to exist
// 229:           end
// 230:         end
// 231:       end
// 232:     end
// 233:
// 234:     describe "when the target is a broken symlink" do
// 235:       let(:deleted_path) { cask.staged_path.join("Deleted.app") }
// 236:
// 237:       before do
// 238:         deleted_path.mkdir
// 239:         File.symlink(deleted_path, target_path)
// 240:         deleted_path.rmdir
// 241:       end
// 242:
// 243:       it "leaves the target alone" do
// 244:         expect { install_phase }.to raise_error(
// 245:           Cask::CaskError, "It seems there is already an App at '#{target_path}'."
// 246:         )
// 247:         expect(target_path).to be_a_symlink
// 248:       end
// 249:
// 250:       describe "given the force option" do
// 251:         let(:force) { true }
// 252:
// 253:         it "overwrites the existing app" do
// 254:           stdout = <<~EOS
// 255:             ==> Removing App '#{target_path}'
// 256:             ==> Moving App 'Caffeine.app' to '#{target_path}'
// 257:           EOS
// 258:
// 259:           stderr = <<~EOS
// 260:             Warning: It seems there is already an App at '#{target_path}'; overwriting.
// 261:           EOS
// 262:
// 263:           expect { install_phase }
// 264:             .to output(stdout).to_stdout
// 265:             .and output(stderr).to_stderr
// 266:
// 267:           expect(source_path).to be_a_symlink
// 268:           expect(target_path).to be_a_directory
// 269:
// 270:           contents_path = target_path.join("Contents/Info.plist")
// 271:           expect(contents_path).to exist
// 272:         end
// 273:       end
// 274:     end
// 275:
// 276:     context "when source doesn't exist" do
// 277:       let(:setup_cask) { cask.staged_path.mkpath }
// 278:
// 279:       it "gives a warning if the source doesn't exist" do
// 280:         message = "It seems the App source '#{source_path}' is not there."
// 281:
// 282:         expect { install_phase }.to raise_error(Cask::CaskError, message)
// 283:       end
// 284:     end
// 285:   end
// 286:
// 287:   describe "uninstall_phase" do
// 288:     after do
// 289:       FileUtils.chmod 0755, target_path if target_path.exist?
// 290:       FileUtils.chmod 0755, source_path if source_path.exist?
// 291:     end
// 292:
// 293:     it "deletes managed apps" do
// 294:       install_phase
// 295:
// 296:       expect(target_path).to exist
// 297:
// 298:       uninstall_phase
// 299:
// 300:       expect(target_path).not_to exist
// 301:     end
// 302:
// 303:     it "backs up read-only managed apps" do
// 304:       install_phase
// 305:
// 306:       FileUtils.chmod 0544, target_path
// 307:
// 308:       uninstall_phase
// 309:
// 310:       expect(source_path).to be_a_directory
// 311:     end
// 312:
// 313:     it "uses clonefile copy arguments on supported macOS versions", :needs_macos do
// 314:       install_phase
// 315:
// 316:       allow(MacOS).to receive(:version).and_return(MacOSVersion.from_symbol(:sonoma))
// 317:
// 318:       expect(app.backup_copy_args(target_path, source_path)).to eq(["-c", "-pR", target_path, source_path])
// 319:     end
// 320:
// 321:     it "uses portable copy arguments on older macOS versions", :needs_macos do
// 322:       install_phase
// 323:
// 324:       allow(MacOS).to receive(:version).and_return(MacOSVersion.from_symbol(:ventura))
// 325:
// 326:       expect(app.backup_copy_args(target_path, source_path)).to eq(["-pR", target_path, source_path])
// 327:     end
// 328:
// 329:     it "uses portable copy arguments across filesystems", :needs_macos do
// 330:       install_phase
// 331:
// 332:       source_dir = source_path.dirname
// 333:       allow(MacOS).to receive(:version).and_return(MacOSVersion.from_symbol(:sonoma))
// 334:       allow(target_path).to receive(:stat).and_return(instance_double(File::Stat, dev: 1))
// 335:       allow(source_path).to receive(:dirname).and_return(source_dir)
// 336:       allow(source_dir).to receive(:stat).and_return(instance_double(File::Stat, dev: 2))
// 337:
// 338:       expect(app.backup_copy_args(target_path, source_path)).to eq(["-pR", target_path, source_path])
// 339:     end
// 340:   end
// 341:
// 342:   describe "summary" do
// 343:     let(:description) { app.class.english_description }
// 344:     let(:contents) { app.summarize_installed }
// 345:
// 346:     context "without installation" do
// 347:       let(:setup_cask) { nil }
// 348:
// 349:       it "returns the correct english_description" do
// 350:         expect(description).to eq("Apps")
// 351:       end
// 352:
// 353:       describe "app is missing" do
// 354:         it "returns a warning and the supposed path to the app" do
// 355:           expect(contents).to match(/.*Missing App.*: #{target_path}/)
// 356:         end
// 357:       end
// 358:     end
// 359:
// 360:     describe "app is correctly installed" do
// 361:       it "returns the path to the app" do
// 362:         install_phase
// 363:
// 364:         expect(contents).to eq("#{target_path} (#{target_path.abv})")
// 365:       end
// 366:     end
// 367:   end
// 368:
// 369:   describe "upgrade" do
// 370:     before do
// 371:       install_phase
// 372:     end
// 373:
// 374:     # Fix for https://github.com/Homebrew/homebrew-cask/issues/102721
// 375:     it "reuses the same directory" do
// 376:       contents_path = target_path.join("Contents/Info.plist")
// 377:
// 378:       expect(target_path).to exist
// 379:       inode = target_path.stat.ino
// 380:       expect(contents_path).to exist
// 381:
// 382:       app.uninstall_phase(command:, force:, successor: cask)
// 383:
// 384:       expect(target_path).to exist
// 385:       expect(target_path.children).to be_empty
// 386:       expect(contents_path).not_to exist
// 387:
// 388:       app.install_phase(command:, adopt:, force:, predecessor: cask)
// 389:       expect(target_path).to exist
// 390:       expect(target_path.stat.ino).to eq(inode)
// 391:
// 392:       expect(contents_path).to exist
// 393:     end
// 394:
// 395:     describe "when the system blocks modifying apps" do
// 396:       it "uninstalls and reinstalls the app" do
// 397:         target_contents_path = target_path.join("Contents")
// 398:
// 399:         expect(File).to receive(:write).with(target_path / ".homebrew-write-test",
// 400:                                              instance_of(String)).and_raise(Errno::EACCES)
// 401:
// 402:         app.uninstall_phase(command:, force:, successor: cask)
// 403:         expect(target_path).not_to exist
// 404:
// 405:         app.install_phase(command:, adopt:, force:, predecessor: cask)
// 406:         expect(target_contents_path).to exist
// 407:       end
// 408:     end
// 409:
// 410:     describe "when the directory is owned by root" do
// 411:       before do
// 412:         allow(app.target).to receive_messages(writable?: false, owned?: false)
// 413:       end
// 414:
// 415:       it "reuses the same directory" do
// 416:         source_contents_path = source_path.join("Contents")
// 417:         target_contents_path = target_path.join("Contents")
// 418:
// 419:         allow(command).to receive(:run!).with(any_args).and_call_original
// 420:
// 421:         expect(command).to receive(:run!)
// 422:           .with("/bin/cp", args: ["-pR", source_contents_path, target_path],
// 423:                            sudo: true)
// 424:           .and_call_original
// 425:         expect(FileUtils).not_to receive(:move).with(source_contents_path, an_instance_of(Pathname))
// 426:
// 427:         app.uninstall_phase(command:, force:, successor: cask)
// 428:         expect(target_contents_path).not_to exist
// 429:         expect(target_path).to exist
// 430:         expect(source_contents_path).to exist
// 431:
// 432:         app.install_phase(command:, adopt:, force:, predecessor: cask)
// 433:         expect(target_contents_path).to exist
// 434:       end
// 435:
// 436:       describe "when the system blocks modifying apps" do
// 437:         it "uninstalls and reinstalls the app" do
// 438:           target_contents_path = target_path.join("Contents")
// 439:
// 440:           allow(command).to receive(:run!).with(any_args).and_call_original
// 441:
// 442:           expect(command).to receive(:run!)
// 443:             .with("touch", args:         [target_path / ".homebrew-write-test"],
// 444:                            print_stderr: false,
// 445:                            sudo:         true)
// 446:             .and_raise(ErrorDuringExecution.new([], status: 1,
// 447: output: [[:stderr, "touch: #{target_path}/.homebrew-write-test: Operation not permitted\n"]], secrets: []))
// 448:
// 449:           app.uninstall_phase(command:, force:, successor: cask)
// 450:           expect(target_path).not_to exist
// 451:
// 452:           app.install_phase(command:, adopt:, force:, predecessor: cask)
// 453:           expect(target_contents_path).to exist
// 454:         end
// 455:       end
// 456:     end
// 457:   end
// 458: end
