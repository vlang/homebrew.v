module artifact

import brew_runtime
import homebrew.cask.artifact as cask_artifact
import os
import time

// Translated from Homebrew/brew `test/cask/artifact/bashcompletion_spec.rb`.
// The original source is retained below for exact translation auditing.

pub struct BashCompletionSpecCask {
pub:
	token                     string
	staged_path               string
	bash_completion_directory string
	completion_source         string
}

fn bash_completion_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-bash-completion-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

pub fn load_bash_completion_spec_cask(token string, root string) !BashCompletionSpecCask {
	completion_source := match token {
		'basic-cask' { '' }
		'with-shellcompletion' { 'test.bash' }
		'with-shellcompletion-long' { 'test.bash-completion' }
		else {
			return error("Cask '${token}' is unavailable")
		}
	}
	return BashCompletionSpecCask{
		token: token
		staged_path: os.join_path(root, 'staged')
		bash_completion_directory: os.join_path(root, 'prefix', 'etc', 'bash_completion.d')
		completion_source: completion_source
	}
}

pub fn bash_completion_spec_source_path(cask BashCompletionSpecCask) string {
	return os.join_path(cask.staged_path, cask.completion_source)
}

pub fn bash_completion_spec_target_path(cask BashCompletionSpecCask) string {
	return cask_artifact.resolve_bash_completion_target(cask.completion_source, cask.bash_completion_directory)
}

pub fn bash_completion_spec_install_phase(cask BashCompletionSpecCask) cask_artifact.SymlinkedOperationResult {
	if cask.completion_source == '' {
		return cask_artifact.SymlinkedOperationResult{}
	}
	return cask_artifact.install_symlinked_artifact(cask_artifact.SymlinkedArtifact{
		source: bash_completion_spec_source_path(cask)
		target: bash_completion_spec_target_path(cask)
		english_name: 'Bash Completion'
	}, cask_artifact.SymlinkedInstallOptions{
		force: false
	})
}

pub fn bash_completion_spec_links(token string) bool {
	root := bash_completion_spec_root(token)
	defer { os.rmdir_all(root) or {} }
	cask := load_bash_completion_spec_cask(token, root) or { return false }
	source := bash_completion_spec_source_path(cask)
	target := bash_completion_spec_target_path(cask)
	os.mkdir_all(os.dir(source)) or { return false }
	os.write_file(source, '') or { return false }
	result := bash_completion_spec_install_phase(cask)
	return result.success && result.linked && os.is_link(target) && os.exists(target)
		&& os.real_path(target) == os.real_path(source)
}

fn bash_completion_spec_cask_value(cask BashCompletionSpecCask) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Cask::Cask'
		repr: cask.token
		map_data: {
			'token':                     brew_runtime.string_value(cask.token)
			'staged_path':               brew_runtime.string_value(cask.staged_path)
			'bash_completion_directory': brew_runtime.string_value(cask.bash_completion_directory)
			'completion_source':         brew_runtime.string_value(cask.completion_source)
		}
	}
}

fn bash_completion_spec_cask_from_value(value brew_runtime.Value) !BashCompletionSpecCask {
	if value.type_name != 'Cask::Cask' {
		return error('expected Cask::Cask, got ${value.type_name}')
	}
	return BashCompletionSpecCask{
		token: (value.map_data['token'] or { return error('cask token is required') }).as_string()
		staged_path: (value.map_data['staged_path'] or {
			return error('cask staged path is required')
		}).as_string()
		bash_completion_directory: (value.map_data['bash_completion_directory'] or {
			return error('bash completion directory is required')
		}).as_string()
		completion_source: (value.map_data['completion_source'] or {
			return error('completion source is required')
		}).as_string()
	}
}

// Ruby let `let(:cask_token) { "basic-cask" }` at line 5.
pub fn ruby_bashcompletion_spec_l5_d1_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('basic-cask')
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_token) }` at line 6.
pub fn ruby_bashcompletion_spec_l6_d2_cask(args ...brew_runtime.Value) brew_runtime.Value {
	token := if args.len > 0 { args[0].as_string() } else { 'basic-cask' }
	root := if args.len > 1 { args[1].as_string() } else { bash_completion_spec_root('cask') }
	cask := load_bash_completion_spec_cask(token, root) or {
		return brew_runtime.object_value('CaskUnavailableError', err.msg())
	}
	return bash_completion_spec_cask_value(cask)
}

// Ruby let `let(:install_phase) do` at line 9.
pub fn ruby_bashcompletion_spec_l9_d3_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('Proc', 'install BashCompletion artifacts without sudo or force')
	}
	cask := bash_completion_spec_cask_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return cask_artifact.symlinked_operation_to_value(bash_completion_spec_install_phase(cask))
}

// Ruby let `let(:source_path) { cask.staged_path.join("test.bash") }` at line 17.
pub fn ruby_bashcompletion_spec_l17_d4_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	cask_value := if args.len > 0 { args[0] } else { ruby_bashcompletion_spec_l6_d2_cask() }
	cask := bash_completion_spec_cask_from_value(cask_value) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('Pathname', os.join_path(cask.staged_path, 'test.bash'))
}

// Ruby let `let(:target_path) { cask.config.bash_completion.join("test") }` at line 18.
pub fn ruby_bashcompletion_spec_l18_d5_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	cask_value := if args.len > 0 { args[0] } else { ruby_bashcompletion_spec_l6_d2_cask() }
	cask := bash_completion_spec_cask_from_value(cask_value) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('Pathname', os.join_path(cask.bash_completion_directory, 'test'))
}

// Ruby let `let(:full_source_path) { cask.staged_path.join("test.bash-completion") }` at line 19.
pub fn ruby_bashcompletion_spec_l19_d6_full_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	cask_value := if args.len > 0 {
		args[0]
	} else {
		ruby_bashcompletion_spec_l6_d2_cask(brew_runtime.string_value('with-shellcompletion-long'))
	}
	cask := bash_completion_spec_cask_from_value(cask_value) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('Pathname', os.join_path(cask.staged_path, 'test.bash-completion'))
}

// Ruby let `let(:full_target_path) { cask.config.bash_completion.join("test") }` at line 20.
pub fn ruby_bashcompletion_spec_l20_d7_full_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	cask_value := if args.len > 0 {
		args[0]
	} else {
		ruby_bashcompletion_spec_l6_d2_cask(brew_runtime.string_value('with-shellcompletion-long'))
	}
	cask := bash_completion_spec_cask_from_value(cask_value) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('Pathname', os.join_path(cask.bash_completion_directory, 'test'))
}

// Ruby let `let(:cask_token) { "with-shellcompletion" }` at line 23.
pub fn ruby_bashcompletion_spec_l23_d8_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('with-shellcompletion')
}

// Ruby it `it "links the completion to the proper directory" do` at line 25.
pub fn ruby_bashcompletion_spec_l25_d9_links(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(bash_completion_spec_links('with-shellcompletion'))
}

// Ruby let `let(:cask_token) { "with-shellcompletion-long" }` at line 36.
pub fn ruby_bashcompletion_spec_l36_d10_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('with-shellcompletion-long')
}

// Ruby it `it "links the completion to the proper directory" do` at line 38.
pub fn ruby_bashcompletion_spec_l38_d11_links(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(bash_completion_spec_links('with-shellcompletion-long'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::BashCompletion, :cask do
// 5:   let(:cask_token) { "basic-cask" }
// 6:   let(:cask) { Cask::CaskLoader.load(cask_token) }
// 7:
// 8:   context "with install" do
// 9:     let(:install_phase) do
// 10:       lambda do
// 11:         cask.artifacts.grep(described_class).each do |artifact|
// 12:           artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 13:         end
// 14:       end
// 15:     end
// 16:
// 17:     let(:source_path) { cask.staged_path.join("test.bash") }
// 18:     let(:target_path) { cask.config.bash_completion.join("test") }
// 19:     let(:full_source_path) { cask.staged_path.join("test.bash-completion") }
// 20:     let(:full_target_path) { cask.config.bash_completion.join("test") }
// 21:
// 22:     context "with completion" do
// 23:       let(:cask_token) { "with-shellcompletion" }
// 24:
// 25:       it "links the completion to the proper directory" do
// 26:         source_path.dirname.mkpath
// 27:         source_path.write ""
// 28:
// 29:         install_phase.call
// 30:
// 31:         expect(File).to be_identical target_path, source_path
// 32:       end
// 33:     end
// 34:
// 35:     context "with long completion" do
// 36:       let(:cask_token) { "with-shellcompletion-long" }
// 37:
// 38:       it "links the completion to the proper directory" do
// 39:         full_source_path.dirname.mkpath
// 40:         full_source_path.write ""
// 41:
// 42:         install_phase.call
// 43:
// 44:         expect(File).to be_identical full_target_path, full_source_path
// 45:       end
// 46:     end
// 47:   end
// 48: end
