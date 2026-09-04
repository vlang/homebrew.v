module artifact

import ruby
import homebrew.cask.artifact
import os
import time

// Translated from Homebrew/brew `test/cask/artifact/suite_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-suite")) }` at line 5.
pub fn ruby_suite_spec_l5_d1_cask(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 {
		args[0].as_string()
	} else {
		os.join_path(os.temp_dir(), 'brew-v-suite-spec')
	}
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: 'with-suite'
		map_data: {
			'staged_path': ruby.string_value(os.join_path(root, 'staged'))
			'appdir':      ruby.string_value(os.join_path(root, 'Applications'))
		}
	}
}

// Ruby let `let(:install_phase) do` at line 7.
pub fn ruby_suite_spec_l7_d2_install_phase(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Proc', 'install suite artifacts without sudo')
}

// Ruby let `let(:target_path) { Pathname(cask.config.appdir).join("Caffeine") }` at line 15.
pub fn ruby_suite_spec_l15_d3_target_path(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_suite_spec_l5_d1_cask() }
	appdir := (cask.map_data['appdir'] or { ruby.string_value('') }).as_string()
	return ruby.object_value('Pathname', os.join_path(appdir, 'Caffeine'))
}

// Ruby let `let(:source_path) { cask.staged_path.join("Caffeine") }` at line 16.
pub fn ruby_suite_spec_l16_d4_source_path(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_suite_spec_l5_d1_cask() }
	staged_path := (cask.map_data['staged_path'] or { ruby.string_value('') }).as_string()
	return ruby.object_value('Pathname', os.join_path(staged_path, 'Caffeine'))
}

// Ruby it `it "creates a suite containing the expected app" do` at line 22.
pub fn ruby_suite_spec_l22_d5_creates(args ...ruby.Value) ruby.Value {
	root := os.join_path(os.temp_dir(), 'brew-v-suite-create-${os.getpid()}-${time.now().unix_micro()}')
	defer { os.rmdir_all(root) or {} }
	cask := ruby_suite_spec_l5_d1_cask(ruby.string_value(root))
	source := ruby_suite_spec_l16_d4_source_path(cask).as_string()
	target := ruby_suite_spec_l15_d3_target_path(cask).as_string()
	os.mkdir_all(os.join_path(source, 'Caffeine.app')) or {
		return ruby.bool_value(false)
	}
	result := artifact.install_moved_artifact(artifact.MovedArtifact{
		source: source
		target: target
		english_name: 'App Suite'
	}, artifact.MovedInstallOptions{})
	return ruby.bool_value(result.success && os.is_dir(os.join_path(target, 'Caffeine.app')))
}

// Ruby it `it "avoids clobbering an existing suite by moving over it" do` at line 28.
pub fn ruby_suite_spec_l28_d6_avoids(args ...ruby.Value) ruby.Value {
	root := os.join_path(os.temp_dir(), 'brew-v-suite-existing-${os.getpid()}-${time.now().unix_micro()}')
	defer { os.rmdir_all(root) or {} }
	cask := ruby_suite_spec_l5_d1_cask(ruby.string_value(root))
	source := ruby_suite_spec_l16_d4_source_path(cask).as_string()
	target := ruby_suite_spec_l15_d3_target_path(cask).as_string()
	os.mkdir_all(os.join_path(source, 'Caffeine.app')) or {
		return ruby.bool_value(false)
	}
	os.mkdir_all(target) or { return ruby.bool_value(false) }
	result := artifact.install_moved_artifact(artifact.MovedArtifact{
		source: source
		target: target
		english_name: 'App Suite'
	}, artifact.MovedInstallOptions{})
	return ruby.bool_value(!result.success && result.error.contains('already a App Suite')
		&& os.is_dir(source) && os.is_dir(target) && os.real_path(source) != os.real_path(target))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Suite, :cask do
// 5:   let(:cask) { Cask::CaskLoader.load(cask_path("with-suite")) }
// 6:
// 7:   let(:install_phase) do
// 8:     lambda do
// 9:       cask.artifacts.grep(described_class).each do |artifact|
// 10:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 11:       end
// 12:     end
// 13:   end
// 14:
// 15:   let(:target_path) { Pathname(cask.config.appdir).join("Caffeine") }
// 16:   let(:source_path) { cask.staged_path.join("Caffeine") }
// 17:
// 18:   before do
// 19:     InstallHelper.install_without_artifacts(cask)
// 20:   end
// 21:
// 22:   it "creates a suite containing the expected app" do
// 23:     install_phase.call
// 24:
// 25:     expect(target_path.join("Caffeine.app")).to exist
// 26:   end
// 27:
// 28:   it "avoids clobbering an existing suite by moving over it" do
// 29:     target_path.mkpath
// 30:
// 31:     expect do
// 32:       install_phase.call
// 33:     end.to raise_error(Cask::CaskError)
// 34:
// 35:     expect(source_path).to be_a_directory
// 36:     expect(target_path).to be_a_directory
// 37:     expect(File.identical?(source_path, target_path)).to be false
// 38:   end
// 39: end
