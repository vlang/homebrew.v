module artifact

import ruby
import os
import time

// Translated from Homebrew/brew `cask/artifact/abstract_artifact.rb`.
const abstract_artifact_default_class = 'Cask::Artifact::AbstractArtifact'
const abstract_artifact_permitted_script_keys = ['args', 'input', 'executable', 'must_succeed',
	'print_stderr', 'print_stdout', 'sudo']

pub struct AbstractArtifact {
pub:
	cask       ruby.Value
	dsl_args   []ruby.Value
	class_name string
	summary    string
}

pub struct AbstractArtifactScriptArguments {
pub:
	executable     string
	has_executable bool
	arguments      map[string]ruby.Value
	warnings       []string
	errors         []string
}

pub struct AbstractArtifactSandbox {
pub:
	staged_path            string
	network_access_allowed bool
	install_hook_rules     bool
	allowed_read_paths     []string
}

pub struct AbstractArtifactSandboxOptions {
pub:
	temporary_root string
	ruby_exec_args []string
	load_path      []string
	library_path   string
}

pub struct AbstractArtifactSandboxInvocation {
pub:
	temporary_path      string
	home                string
	payload_path        string
	payload_json        string
	command             []string
	preserved_brew_file bool
}

pub struct AbstractArtifactSandboxRunResult {
pub:
	sandbox           AbstractArtifactSandbox
	invocation        AbstractArtifactSandboxInvocation
	temporary_removed bool
}

pub type AbstractArtifactSandboxRunner = fn (AbstractArtifactSandboxInvocation) !

fn abstract_artifact_unqualified_class_name(class_name string) string {
	parts := class_name.split('::')
	return if parts.len == 0 { class_name } else { parts.last() }
}

pub fn abstract_artifact_english_name(class_name string) string {
	name := abstract_artifact_unqualified_class_name(class_name)
	mut translated := []u8{cap: name.len * 2}
	for index, character in name.bytes() {
		if index > 0 && character >= `A` && character <= `Z` {
			translated << ` `
		}
		translated << character
	}
	return translated.bytestr()
}

pub fn abstract_artifact_english_article(class_name string) string {
	name := abstract_artifact_english_name(class_name).to_lower()
	return if name.len > 0 && name[0] in [`a`, `e`, `i`, `o`, `u`] { 'an' } else { 'a' }
}

pub fn abstract_artifact_dsl_key(class_name string) string {
	name := abstract_artifact_unqualified_class_name(class_name)
	mut translated := []u8{cap: name.len * 2}
	for index, character in name.bytes() {
		if index > 0 && character >= `A` && character <= `Z` {
			translated << `_`
		}
		if character >= `A` && character <= `Z` {
			translated << character + 32
		} else {
			translated << character
		}
	}
	return translated.bytestr()
}

pub fn abstract_artifact_dirmethod(class_name string) string {
	return '${abstract_artifact_dsl_key(class_name)}dir'
}

pub fn abstract_artifact_staged_path_join_executable(artifact AbstractArtifact,
	supplied_path string) !string {
	mut path := supplied_path
	if path.starts_with('~') {
		path = os.expand_tilde_to_home(path)
	}
	staged_path := (artifact.cask.map_data['staged_path'] or {
		ruby.string_value(artifact.cask.attributes['staged_path'] or { '' })
	}).as_string()
	absolute_path := if os.is_abs_path(path) { path } else { os.join_path(staged_path, path) }
	if os.exists(absolute_path) {
		if !os.is_executable(absolute_path) {
			mode := int(os.stat(absolute_path)!.get_mode().bitmask())
			os.chmod(absolute_path, mode | 0o111)!
		}
		return absolute_path
	}
	return path
}

pub fn abstract_artifact_sort_order() map[string]int {
	mut order := map[string]int{}
	groups := [
		['PreflightSteps'],
		['UninstallPreflightSteps'],
		['PreflightBlock'],
		['Uninstall'],
		['GeneratedScript'],
		['Installer'],
		['Pkg'],
		['App', 'AppImage', 'Suite', 'Artifact', 'Colorpicker', 'Prefpane', 'Qlplugin', 'Mdimporter',
			'Dictionary', 'Font', 'Service', 'InputMethod', 'InternetPlugin', 'KeyboardLayout',
			'AudioUnitPlugin', 'VstPlugin', 'Vst3Plugin', 'ScreenSaver'],
		['Binary', 'CommandWrapper'],
		['Manpage'],
		['BashCompletion', 'FishCompletion', 'ZshCompletion'],
		['GeneratedCompletion'],
		['PostflightSteps'],
		['UninstallPostflightSteps'],
		['PostflightBlock'],
		['Zap'],
	]
	for index, classes in groups {
		for class_name in classes {
			order['Cask::Artifact::${class_name}'] = index
		}
	}
	return order
}

pub fn compare_abstract_artifacts(left_class string, right_class string) ?int {
	if !left_class.starts_with('Cask::Artifact::') || !right_class.starts_with('Cask::Artifact::') {
		return none
	}
	if left_class == right_class {
		return 0
	}
	order := abstract_artifact_sort_order()
	left := order[left_class] or { return none }
	right := order[right_class] or { return none }
	return if left < right {
		-1
	} else if left > right { 1 } else { 0 }
}

fn abstract_artifact_symbol_array(keys []string) string {
	mut symbols := []string{cap: keys.len}
	for key in keys {
		symbols << ':' + key
	}
	return '[${symbols.join(', ')}]'
}

pub fn abstract_artifact_to_string(artifact AbstractArtifact) string {
	return '${artifact.summary} (${abstract_artifact_english_name(artifact.class_name)})'
}

pub fn new_abstract_artifact_sandbox(artifact AbstractArtifact, use_sandbox bool,
	network_access_allowed bool) ?AbstractArtifactSandbox {
	if !use_sandbox {
		return none
	}
	staged_path := (artifact.cask.map_data['staged_path'] or {
		ruby.string_value(artifact.cask.attributes['staged_path'] or { '' })
	}).as_string()
	return AbstractArtifactSandbox{
		staged_path: staged_path
		network_access_allowed: network_access_allowed
		install_hook_rules: true
		allowed_read_paths: [staged_path]
	}
}

fn abstract_artifact_noop_sandbox_runner(invocation AbstractArtifactSandboxInvocation) ! {
	_ = invocation
}

pub fn run_abstract_artifact_cask_sandbox(sandbox AbstractArtifactSandbox,
	payload map[string]ruby.Value, options AbstractArtifactSandboxOptions,
	runner AbstractArtifactSandboxRunner) !AbstractArtifactSandboxRunResult {
	temporary_root := if options.temporary_root == '' {
		os.temp_dir()
	} else {
		options.temporary_root
	}
	temporary_path := os.join_path(temporary_root, 'homebrew-cask-sandbox-${os.getpid()}-${time.now().unix_micro()}')
	home := os.join_path(temporary_path, 'home')
	payload_path := os.join_path(temporary_path, 'payload.json')
	os.mkdir_all(home)!
	defer {
		os.rmdir_all(temporary_path) or {}
	}
	payload_json := ruby.json_value_to_string(ruby.map_value(payload))
	os.write_file(payload_path, payload_json)!
	mut command := ['/usr/bin/env', 'HOME=${home}', 'nice']
	command << options.ruby_exec_args
	command << ['-I', options.load_path.join(os.path_delimiter.str()), '--',
		os.join_path(options.library_path, 'cask_artifact.rb'), payload_path]
	invocation := AbstractArtifactSandboxInvocation{
		temporary_path: temporary_path
		home: home
		payload_path: payload_path
		payload_json: payload_json
		command: command
		preserved_brew_file: true
	}
	runner(invocation)!
	mut updated_paths := sandbox.allowed_read_paths.clone()
	updated_paths << payload_path
	return AbstractArtifactSandboxRunResult{
		sandbox: AbstractArtifactSandbox{
			...sandbox
			allowed_read_paths: updated_paths
		}
		invocation: invocation
		temporary_removed: true
	}
}
