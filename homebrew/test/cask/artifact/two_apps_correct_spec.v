module artifact

import ruby
import homebrew.cask.artifact as production_artifact
import os
import time

// Translated from Homebrew/brew `test/cask/artifact/two_apps_correct_spec.rb`.
// The original source is retained below until every stub has a typed V body.

struct TwoAppsCorrectFixture {
	root          string
	staged_path   string
	appdir        string
	source_subdir string
}

struct TwoAppsInstallResult {
	success bool
	error   string
	stdout  string
}

fn two_apps_correct_root(args []ruby.Value, label string) string {
	if args.len > 0 && args[0].as_string() != '' {
		return args[0].as_string()
	}
	return os.join_path(os.temp_dir(), 'brew-v-two-apps-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn two_apps_correct_fixture(root string, in_subdirectory bool) !TwoAppsCorrectFixture {
	staged_path := os.join_path(root, 'staged')
	appdir := os.join_path(root, 'Applications')
	source_subdir := if in_subdirectory { 'Caffeines' } else { '' }
	os.mkdir_all(appdir)!
	for name in ['Caffeine Mini.app', 'Caffeine Pro.app'] {
		source := if source_subdir == '' {
			os.join_path(staged_path, name)
		} else {
			os.join_path(staged_path, source_subdir, name)
		}
		os.mkdir_all(os.join_path(source, 'Contents'))!
		os.write_file(os.join_path(source, 'Contents', 'fixture.txt'), name)!
	}
	return TwoAppsCorrectFixture{
		root: root
		staged_path: staged_path
		appdir: appdir
		source_subdir: source_subdir
	}
}

fn two_apps_correct_source(fixture TwoAppsCorrectFixture, name string) string {
	if fixture.source_subdir == '' {
		return os.join_path(fixture.staged_path, name)
	}
	return os.join_path(fixture.staged_path, fixture.source_subdir, name)
}

fn two_apps_correct_target(fixture TwoAppsCorrectFixture, name string) string {
	return os.join_path(fixture.appdir, name)
}

fn two_apps_correct_artifact(fixture TwoAppsCorrectFixture, name string) production_artifact.AppArtifact {
	return production_artifact.AppArtifact{
		source: two_apps_correct_source(fixture, name)
		target: two_apps_correct_target(fixture, name)
	}
}

fn two_apps_correct_install(fixture TwoAppsCorrectFixture) TwoAppsInstallResult {
	// Homebrew installs the artifacts whose targets are available before reporting
	// a collision, so one bad app does not prevent its sibling from being moved.
	mut available := []string{}
	mut occupied := []string{}
	for name in ['Caffeine Mini.app', 'Caffeine Pro.app'] {
		if os.exists(two_apps_correct_target(fixture, name))
			|| os.is_link(two_apps_correct_target(fixture, name)) {
			occupied << name
		} else {
			available << name
		}
	}
	mut output := ''
	for name in available {
		result := production_artifact.install_app(two_apps_correct_artifact(fixture, name), production_artifact.AppInstallOptions{})
		output += result.stdout
		if !result.success {
			return TwoAppsInstallResult{
				error: result.error
				stdout: output
			}
		}
	}
	for name in occupied {
		result := production_artifact.install_app(two_apps_correct_artifact(fixture, name), production_artifact.AppInstallOptions{})
		output += result.stdout
		if !result.success {
			return TwoAppsInstallResult{
				error: result.error
				stdout: output
			}
		}
	}
	return TwoAppsInstallResult{
		success: true
		stdout: output
	}
}

fn two_apps_fixture_value(fixture TwoAppsCorrectFixture) ruby.Value {
	return ruby.structured_value('Cask', fixture.root, {
		'staged_path':   fixture.staged_path
		'appdir':        fixture.appdir
		'source_subdir': fixture.source_subdir
	})
}

fn two_apps_result_value(result TwoAppsInstallResult) ruby.Value {
	return ruby.structured_value('InstallPhaseResult', result.error, {
		'success': result.success.str()
		'error':   result.error
		'stdout':  result.stdout
	})
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-two-apps-correct")) }` at line 6.
pub fn ruby_two_apps_correct_spec_l6_d1_cask(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'cask')
	fixture := two_apps_correct_fixture(root, false) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return two_apps_fixture_value(fixture)
}

// Ruby let `let(:install_phase) do` at line 8.
pub fn ruby_two_apps_correct_spec_l8_d2_install_phase(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'install')
	fixture := two_apps_correct_fixture(root, false) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return two_apps_result_value(two_apps_correct_install(fixture))
}

// Ruby let `let(:source_path_mini) { cask.staged_path.join("Caffeine Mini.app") }` at line 14.
pub fn ruby_two_apps_correct_spec_l14_d3_source_path_mini(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'source-mini')
	return ruby.string_value(os.join_path(root, 'staged', 'Caffeine Mini.app'))
}

// Ruby let `let(:target_path_mini) { Pathname(cask.config.appdir).join("Caffeine Mini.app") }` at line 15.
pub fn ruby_two_apps_correct_spec_l15_d4_target_path_mini(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'target-mini')
	return ruby.string_value(os.join_path(root, 'Applications', 'Caffeine Mini.app'))
}

// Ruby let `let(:source_path_pro) { cask.staged_path.join("Caffeine Pro.app") }` at line 17.
pub fn ruby_two_apps_correct_spec_l17_d5_source_path_pro(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'source-pro')
	return ruby.string_value(os.join_path(root, 'staged', 'Caffeine Pro.app'))
}

// Ruby let `let(:target_path_pro) { Pathname(cask.config.appdir).join("Caffeine Pro.app") }` at line 18.
pub fn ruby_two_apps_correct_spec_l18_d6_target_path_pro(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'target-pro')
	return ruby.string_value(os.join_path(root, 'Applications', 'Caffeine Pro.app'))
}

// Ruby it `it "installs both apps using the proper target directory" do` at line 24.
pub fn ruby_two_apps_correct_spec_l24_d7_installs(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'both')
	fixture := two_apps_correct_fixture(root, false) or { return ruby.bool_value(false) }
	result := two_apps_correct_install(fixture)
	return ruby.bool_value(result.success
		&& os.is_dir(two_apps_correct_target(fixture, 'Caffeine Mini.app'))
		&& os.is_link(two_apps_correct_source(fixture, 'Caffeine Mini.app'))
		&& os.is_dir(two_apps_correct_target(fixture, 'Caffeine Pro.app'))
		&& os.is_link(two_apps_correct_source(fixture, 'Caffeine Pro.app')))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-two-apps-subdir")) }` at line 35.
pub fn ruby_two_apps_correct_spec_l35_d8_cask(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'subdir-cask')
	fixture := two_apps_correct_fixture(root, true) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return two_apps_fixture_value(fixture)
}

// Ruby let `let(:source_path_mini) { cask.staged_path.join("Caffeines", "Caffeine Mini.app") }` at line 37.
pub fn ruby_two_apps_correct_spec_l37_d9_source_path_mini(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'subdir-source-mini')
	return ruby.string_value(os.join_path(root, 'staged', 'Caffeines', 'Caffeine Mini.app'))
}

// Ruby let `let(:source_path_pro) { cask.staged_path.join("Caffeines", "Caffeine Pro.app") }` at line 38.
pub fn ruby_two_apps_correct_spec_l38_d10_source_path_pro(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'subdir-source-pro')
	return ruby.string_value(os.join_path(root, 'staged', 'Caffeines', 'Caffeine Pro.app'))
}

// Ruby it `it "installs both apps using the proper target directory" do` at line 40.
pub fn ruby_two_apps_correct_spec_l40_d11_installs(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'subdir-both')
	fixture := two_apps_correct_fixture(root, true) or { return ruby.bool_value(false) }
	result := two_apps_correct_install(fixture)
	return ruby.bool_value(result.success
		&& os.is_dir(two_apps_correct_target(fixture, 'Caffeine Mini.app'))
		&& os.is_link(two_apps_correct_source(fixture, 'Caffeine Mini.app'))
		&& os.is_dir(two_apps_correct_target(fixture, 'Caffeine Pro.app'))
		&& os.is_link(two_apps_correct_source(fixture, 'Caffeine Pro.app')))
}

// Ruby it `it "only uses apps when they are specified" do` at line 51.
pub fn ruby_two_apps_correct_spec_l51_d12_only(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'specified-only')
	fixture := two_apps_correct_fixture(root, false) or { return ruby.bool_value(false) }
	deluxe := two_apps_correct_source(fixture, 'Caffeine Deluxe.app')
	os.mkdir_all(os.join_path(deluxe, 'Contents')) or { return ruby.bool_value(false) }
	os.write_file(os.join_path(deluxe, 'Contents', 'fixture.txt'), 'deluxe') or {
		return ruby.bool_value(false)
	}
	result := two_apps_correct_install(fixture)
	return ruby.bool_value(result.success
		&& os.is_dir(two_apps_correct_target(fixture, 'Caffeine Mini.app'))
		&& os.is_link(two_apps_correct_source(fixture, 'Caffeine Mini.app'))
		&& !os.exists(two_apps_correct_target(fixture, 'Caffeine Deluxe.app')) && os.is_dir(deluxe))
}

// Ruby it `it "when the first app of two already exists" do` at line 64.
pub fn ruby_two_apps_correct_spec_l64_d13_when(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'first-exists')
	fixture := two_apps_correct_fixture(root, false) or { return ruby.bool_value(false) }
	mini_source := two_apps_correct_source(fixture, 'Caffeine Mini.app')
	mini_target := two_apps_correct_target(fixture, 'Caffeine Mini.app')
	pro_target := two_apps_correct_target(fixture, 'Caffeine Pro.app')
	os.mkdir_all(mini_target) or { return ruby.bool_value(false) }
	result := two_apps_correct_install(fixture)
	return ruby.bool_value(!result.success
		&& result.error == "It seems there is already an App at '${mini_target}'."
		&& result.stdout == "==> Moving App 'Caffeine Pro.app' to '${pro_target}'\n"
		&& os.is_dir(mini_source) && os.is_dir(mini_target) && !os.is_link(mini_source))
}

// Ruby it `it "when the second app of two already exists" do` at line 78.
pub fn ruby_two_apps_correct_spec_l78_d14_when(args ...ruby.Value) ruby.Value {
	root := two_apps_correct_root(args, 'second-exists')
	fixture := two_apps_correct_fixture(root, false) or { return ruby.bool_value(false) }
	pro_source := two_apps_correct_source(fixture, 'Caffeine Pro.app')
	mini_target := two_apps_correct_target(fixture, 'Caffeine Mini.app')
	pro_target := two_apps_correct_target(fixture, 'Caffeine Pro.app')
	os.mkdir_all(pro_target) or { return ruby.bool_value(false) }
	result := two_apps_correct_install(fixture)
	return ruby.bool_value(!result.success
		&& result.error == "It seems there is already an App at '${pro_target}'."
		&& result.stdout == "==> Moving App 'Caffeine Mini.app' to '${mini_target}'\n"
		&& os.is_dir(pro_source) && os.is_dir(pro_target) && !os.is_link(pro_source))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::App, :cask do
// 5:   describe "multiple apps" do
// 6:     let(:cask) { Cask::CaskLoader.load(cask_path("with-two-apps-correct")) }
// 7:
// 8:     let(:install_phase) do
// 9:       cask.artifacts.grep(described_class).each do |artifact|
// 10:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 11:       end
// 12:     end
// 13:
// 14:     let(:source_path_mini) { cask.staged_path.join("Caffeine Mini.app") }
// 15:     let(:target_path_mini) { Pathname(cask.config.appdir).join("Caffeine Mini.app") }
// 16:
// 17:     let(:source_path_pro) { cask.staged_path.join("Caffeine Pro.app") }
// 18:     let(:target_path_pro) { Pathname(cask.config.appdir).join("Caffeine Pro.app") }
// 19:
// 20:     before do
// 21:       InstallHelper.install_without_artifacts(cask)
// 22:     end
// 23:
// 24:     it "installs both apps using the proper target directory" do
// 25:       install_phase
// 26:
// 27:       expect(target_path_mini).to be_a_directory
// 28:       expect(source_path_mini).to be_a_symlink
// 29:
// 30:       expect(target_path_pro).to be_a_directory
// 31:       expect(source_path_pro).to be_a_symlink
// 32:     end
// 33:
// 34:     describe "when apps are in a subdirectory" do
// 35:       let(:cask) { Cask::CaskLoader.load(cask_path("with-two-apps-subdir")) }
// 36:
// 37:       let(:source_path_mini) { cask.staged_path.join("Caffeines", "Caffeine Mini.app") }
// 38:       let(:source_path_pro) { cask.staged_path.join("Caffeines", "Caffeine Pro.app") }
// 39:
// 40:       it "installs both apps using the proper target directory" do
// 41:         install_phase
// 42:
// 43:         expect(target_path_mini).to be_a_directory
// 44:         expect(source_path_mini).to be_a_symlink
// 45:
// 46:         expect(target_path_pro).to be_a_directory
// 47:         expect(source_path_pro).to be_a_symlink
// 48:       end
// 49:     end
// 50:
// 51:     it "only uses apps when they are specified" do
// 52:       FileUtils.cp_r source_path_mini, source_path_mini.sub("Caffeine Mini.app", "Caffeine Deluxe.app")
// 53:
// 54:       install_phase
// 55:
// 56:       expect(target_path_mini).to be_a_directory
// 57:       expect(source_path_mini).to be_a_symlink
// 58:
// 59:       expect(Pathname(cask.config.appdir).join("Caffeine Deluxe.app")).not_to exist
// 60:       expect(cask.staged_path.join("Caffeine Deluxe.app")).to exist
// 61:     end
// 62:
// 63:     describe "avoids clobbering an existing app" do
// 64:       it "when the first app of two already exists" do
// 65:         target_path_mini.mkpath
// 66:
// 67:         expect do
// 68:           expect { install_phase }.to output(<<~EOS).to_stdout
// 69:             ==> Moving App 'Caffeine Pro.app' to '#{target_path_pro}'
// 70:           EOS
// 71:         end.to raise_error(Cask::CaskError, "It seems there is already an App at '#{target_path_mini}'.")
// 72:
// 73:         expect(source_path_mini).to be_a_directory
// 74:         expect(target_path_mini).to be_a_directory
// 75:         expect(File.identical?(source_path_mini, target_path_mini)).to be false
// 76:       end
// 77:
// 78:       it "when the second app of two already exists" do
// 79:         target_path_pro.mkpath
// 80:
// 81:         expect do
// 82:           expect { install_phase }.to output(<<~EOS).to_stdout
// 83:             ==> Moving App 'Caffeine Mini.app' to '#{target_path_mini}'
// 84:           EOS
// 85:         end.to raise_error(Cask::CaskError, "It seems there is already an App at '#{target_path_pro}'.")
// 86:
// 87:         expect(source_path_pro).to be_a_directory
// 88:         expect(target_path_pro).to be_a_directory
// 89:         expect(File.identical?(source_path_pro, target_path_pro)).to be false
// 90:       end
// 91:     end
// 92:   end
// 93: end
