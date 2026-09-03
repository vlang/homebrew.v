module artifact

import brew_runtime
import homebrew.cask.artifact as cask_artifact
import os
import time

// Translated from Homebrew/brew `test/cask/artifact/generic_artifact_spec.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct GenericArtifactSpecCask {
pub:
	token       string
	staged_path string
	appdir      string
	source      string
	target      string
}

fn generic_artifact_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-generic-artifact-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

pub fn load_generic_artifact_spec_cask(token string, root string) !GenericArtifactSpecCask {
	staged_path := os.join_path(root, 'staged')
	appdir := os.join_path(root, 'Applications')
	configured_target := match token {
		'with-generic-artifact' { os.join_path(appdir, 'Caffeine.app') }
		'generic-artifact-relative-target' { 'Caffeine.app' }
		'generic-artifact-user-relative-target' { '~/Desktop/Caffeine.app' }
		'invalid-generic-artifact-no-target' {
			cask_artifact.new_generic_artifact(token, 'Caffeine.app', map[string]string{})!
			return error('expected missing Generic Artifact target to fail')
		}
		else {
			return error("Cask '${token}' is unavailable")
		}
	}
	generic_artifact := cask_artifact.new_generic_artifact(token, 'Caffeine.app', {
		'target': configured_target
	})!
	return GenericArtifactSpecCask{
		token: token
		staged_path: staged_path
		appdir: appdir
		source: os.join_path(staged_path, generic_artifact.source)
		target: cask_artifact.resolve_artifact_target(generic_artifact.target, none)
	}
}

pub fn prepare_generic_artifact_spec_cask(cask GenericArtifactSpecCask) ! {
	os.mkdir_all(os.join_path(cask.source, 'Contents'))!
	os.mkdir_all(cask.appdir)!
	os.write_file(os.join_path(cask.source, 'Contents', 'Info.plist'), 'version=1.2.3')!
}

pub fn generic_artifact_spec_install_phase(cask GenericArtifactSpecCask) cask_artifact.MovedOperationResult {
	return cask_artifact.install_moved_artifact(cask_artifact.MovedArtifact{
		source: cask.source
		target: cask.target
		english_name: 'Generic Artifact'
	}, cask_artifact.MovedInstallOptions{
		force: false
	})
}

fn generic_artifact_spec_cask_value(cask GenericArtifactSpecCask) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Cask::Cask'
		repr: cask.token
		map_data: {
			'token':       brew_runtime.string_value(cask.token)
			'staged_path': brew_runtime.string_value(cask.staged_path)
			'appdir':      brew_runtime.string_value(cask.appdir)
			'source':      brew_runtime.string_value(cask.source)
			'target':      brew_runtime.string_value(cask.target)
		}
	}
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-generic-artifact")) }` at line 5.
pub fn ruby_generic_artifact_spec_l5_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	root := if args.len > 0 {
		args[0].as_string()
	} else {
		os.join_path(os.temp_dir(), 'brew-v-generic-artifact-spec')
	}
	cask := load_generic_artifact_spec_cask('with-generic-artifact', root) or {
		return brew_runtime.object_value('CaskInvalidError', err.msg())
	}
	return generic_artifact_spec_cask_value(cask)
}

// Ruby let `let(:install_phase) do` at line 7.
pub fn ruby_generic_artifact_spec_l7_d2_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Proc', 'install Generic Artifact without sudo or force')
}

// Ruby let `let(:source_path) { cask.staged_path.join("Caffeine.app") }` at line 15.
pub fn ruby_generic_artifact_spec_l15_d3_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	cask := if args.len > 0 { args[0] } else { ruby_generic_artifact_spec_l5_d1_cask() }
	staged_path := (cask.map_data['staged_path'] or { brew_runtime.string_value('') }).as_string()
	return brew_runtime.object_value('Pathname', os.join_path(staged_path, 'Caffeine.app'))
}

// Ruby let `let(:target_path) { Pathname(cask.config.appdir).join("Caffeine.app") }` at line 16.
pub fn ruby_generic_artifact_spec_l16_d4_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	cask := if args.len > 0 { args[0] } else { ruby_generic_artifact_spec_l5_d1_cask() }
	appdir := (cask.map_data['appdir'] or { brew_runtime.string_value('') }).as_string()
	return brew_runtime.object_value('Pathname', os.join_path(appdir, 'Caffeine.app'))
}

// Ruby it `it "fails to load", :no_api do` at line 23.
pub fn ruby_generic_artifact_spec_l23_d5_fails(args ...brew_runtime.Value) brew_runtime.Value {
	root := generic_artifact_spec_root('missing-target')
	_ := load_generic_artifact_spec_cask('invalid-generic-artifact-no-target', root) or {
		return brew_runtime.bool_value(err.msg().contains('Generic Artifact')
			&& err.msg().contains('requires a target'))
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "does not fail to load" do` at line 31.
pub fn ruby_generic_artifact_spec_l31_d6_does(args ...brew_runtime.Value) brew_runtime.Value {
	cask := load_generic_artifact_spec_cask('generic-artifact-relative-target', generic_artifact_spec_root('relative')) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(cask.target == 'Caffeine.app')
}

// Ruby it `it "does not fail to load" do` at line 39.
pub fn ruby_generic_artifact_spec_l39_d7_does(args ...brew_runtime.Value) brew_runtime.Value {
	cask := load_generic_artifact_spec_cask('generic-artifact-user-relative-target', generic_artifact_spec_root('user-relative')) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(cask.target == os.join_path(os.home_dir(), 'Desktop', 'Caffeine.app'))
}

// Ruby it `it "moves the artifact to the proper directory" do` at line 46.
pub fn ruby_generic_artifact_spec_l46_d8_moves(args ...brew_runtime.Value) brew_runtime.Value {
	root := generic_artifact_spec_root('moves')
	defer { os.rmdir_all(root) or {} }
	cask := load_generic_artifact_spec_cask('with-generic-artifact', root) or {
		return brew_runtime.bool_value(false)
	}
	prepare_generic_artifact_spec_cask(cask) or { return brew_runtime.bool_value(false) }
	result := generic_artifact_spec_install_phase(cask)
	return brew_runtime.bool_value(result.success && os.is_dir(cask.target) && os.is_link(cask.source))
}

// Ruby it `it "avoids clobbering an existing artifact" do` at line 53.
pub fn ruby_generic_artifact_spec_l53_d9_avoids(args ...brew_runtime.Value) brew_runtime.Value {
	root := generic_artifact_spec_root('avoids')
	defer { os.rmdir_all(root) or {} }
	cask := load_generic_artifact_spec_cask('with-generic-artifact', root) or {
		return brew_runtime.bool_value(false)
	}
	prepare_generic_artifact_spec_cask(cask) or { return brew_runtime.bool_value(false) }
	os.mkdir_all(cask.target) or { return brew_runtime.bool_value(false) }
	result := generic_artifact_spec_install_phase(cask)
	return brew_runtime.bool_value(!result.success && result.error.contains('already a Generic Artifact')
		&& os.is_dir(cask.source) && os.is_dir(cask.target)
		&& os.real_path(cask.source) != os.real_path(cask.target))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Artifact, :cask do
// 5:   let(:cask) { Cask::CaskLoader.load(cask_path("with-generic-artifact")) }
// 6:
// 7:   let(:install_phase) do
// 8:     lambda do
// 9:       cask.artifacts.grep(described_class).each do |artifact|
// 10:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 11:       end
// 12:     end
// 13:   end
// 14:
// 15:   let(:source_path) { cask.staged_path.join("Caffeine.app") }
// 16:   let(:target_path) { Pathname(cask.config.appdir).join("Caffeine.app") }
// 17:
// 18:   before do
// 19:     InstallHelper.install_without_artifacts(cask)
// 20:   end
// 21:
// 22:   context "without target" do
// 23:     it "fails to load", :no_api do
// 24:       expect do
// 25:         Cask::CaskLoader.load("invalid-generic-artifact-no-target")
// 26:       end.to raise_error(Cask::CaskInvalidError, /Generic Artifact.*requires.*target/)
// 27:     end
// 28:   end
// 29:
// 30:   context "with relative target" do
// 31:     it "does not fail to load" do
// 32:       expect do
// 33:         Cask::CaskLoader.load("generic-artifact-relative-target")
// 34:       end.not_to raise_error
// 35:     end
// 36:   end
// 37:
// 38:   context "with user-relative target" do
// 39:     it "does not fail to load" do
// 40:       expect do
// 41:         Cask::CaskLoader.load("generic-artifact-user-relative-target")
// 42:       end.not_to raise_error
// 43:     end
// 44:   end
// 45:
// 46:   it "moves the artifact to the proper directory" do
// 47:     install_phase.call
// 48:
// 49:     expect(target_path).to be_a_directory
// 50:     expect(source_path).to be_a_symlink
// 51:   end
// 52:
// 53:   it "avoids clobbering an existing artifact" do
// 54:     target_path.mkpath
// 55:
// 56:     expect do
// 57:       install_phase.call
// 58:     end.to raise_error(Cask::CaskError)
// 59:
// 60:     expect(source_path).to be_a_directory
// 61:     expect(target_path).to be_a_directory
// 62:     expect(File.identical?(source_path, target_path)).to be false
// 63:   end
// 64: end
