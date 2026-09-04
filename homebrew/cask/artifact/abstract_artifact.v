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

fn abstract_artifact_nil() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn abstract_artifact_deep_dup(value ruby.Value) ruby.Value {
	mut entries := []ruby.Value{cap: value.array_data.len}
	for entry in value.array_data {
		entries << abstract_artifact_deep_dup(entry)
	}
	mut values := map[string]ruby.Value{}
	for key, entry in value.map_data {
		values[key] = abstract_artifact_deep_dup(entry)
	}
	return ruby.Value{
		type_name: value.type_name
		repr: value.repr
		bool_data: value.bool_data
		int_data: value.int_data
		float_data: value.float_data
		string_array_data: value.string_array_data.clone()
		array_data: entries
		map_data: values
		attributes: value.attributes.clone()
	}
}

fn abstract_artifact_class_name(value ruby.Value) string {
	if class_name := value.attributes['class_name'] {
		if class_name != '' {
			return class_name
		}
	}
	if value.type_name == 'Class' && value.as_string() != '' {
		return value.as_string()
	}
	if value.type_name.starts_with('Cask::Artifact::') {
		return value.type_name
	}
	if value.as_string().contains('::') {
		return value.as_string()
	}
	return abstract_artifact_default_class
}

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

pub fn new_abstract_artifact(cask ruby.Value, class_name string, summary string,
	dsl_args []ruby.Value) AbstractArtifact {
	return AbstractArtifact{
		cask: cask
		class_name: if class_name == '' { abstract_artifact_default_class } else { class_name }
		summary: summary
		dsl_args: dsl_args.map(abstract_artifact_deep_dup(it))
	}
}

pub fn abstract_artifact_value(artifact AbstractArtifact) ruby.Value {
	return ruby.Value{
		type_name: artifact.class_name
		repr: artifact.summary
		map_data: {
			'cask':     artifact.cask
			'dsl_args': ruby.array_value(artifact.dsl_args)
			'summary':  ruby.string_value(artifact.summary)
		}
		attributes: {
			'class_name': artifact.class_name
		}
	}
}

pub fn abstract_artifact_from_value(value ruby.Value) AbstractArtifact {
	dsl_args := (value.map_data['dsl_args'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	return new_abstract_artifact(value.map_data['cask'] or {
		ruby.object_value('Cask', '')
	}, abstract_artifact_class_name(value), (value.map_data['summary'] or {
		ruby.string_value(value.as_string())
	}).as_string(), dsl_args)
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

pub fn read_abstract_artifact_script_arguments(arguments ruby.Value, stanza string,
	default_arguments map[string]ruby.Value, override_arguments map[string]ruby.Value,
	key string) !AbstractArtifactScriptArguments {
	description := if key == '' { stanza } else { '${stanza} :${key}' }
	mut supplied := if arguments.type_name == 'String' {
		{
			'executable': arguments
		}
	} else if arguments.type_name == 'Hash' {
		arguments.map_data.clone()
	} else {
		return error('Unsupported arguments type ${arguments.type_name}')
	}
	mut unknown_keys := []string{}
	for supplied_key, _ in supplied {
		if supplied_key !in abstract_artifact_permitted_script_keys {
			unknown_keys << supplied_key
		}
	}
	mut warnings := []string{}
	if unknown_keys.len > 0 {
		warnings << 'Unknown arguments to ${description} -- ${abstract_artifact_symbol_array(unknown_keys)} (ignored). Running `brew update; brew cleanup` will likely fix it.'
	}
	for unknown_key in unknown_keys {
		supplied.delete(unknown_key)
	}
	mut ignored_keys := []string{}
	for supplied_key, _ in supplied {
		if supplied_key in override_arguments {
			ignored_keys << supplied_key
		}
	}
	mut errors := []string{}
	if ignored_keys.len > 0 {
		// Preserve the pinned source's interpolation of unknown_keys here.
		errors << 'Some arguments to ${description} will be ignored -- :${abstract_artifact_symbol_array(unknown_keys)} (overridden).'
	}
	mut executable := ''
	mut has_executable := false
	if value := supplied['executable'] {
		has_executable = value.type_name != 'NilClass'
		if has_executable {
			executable = value.as_string()
		}
		supplied.delete('executable')
	}
	mut merged := map[string]ruby.Value{}
	for argument_key, value in default_arguments {
		merged[argument_key] = value
	}
	for argument_key, value in supplied {
		merged[argument_key] = value
	}
	for argument_key, value in override_arguments {
		merged[argument_key] = value
	}
	return AbstractArtifactScriptArguments{
		executable: executable
		has_executable: has_executable
		arguments: merged
		warnings: warnings
		errors: errors
	}
}

fn abstract_artifact_blank(value ruby.Value) bool {
	return match value.type_name {
		'NilClass' { true }
		'Bool' { !value.bool_data }
		'String' { value.as_string().trim_space() == '' }
		'Array' { (value.as_array() or { []ruby.Value{} }).len == 0 }
		'Hash' { value.map_data.len == 0 }
		else { false }
	}
}

pub fn abstract_artifact_to_args(artifact AbstractArtifact) []ruby.Value {
	return artifact.dsl_args.filter(!abstract_artifact_blank(it)).map(abstract_artifact_deep_dup(it))
}

pub fn abstract_artifact_to_string(artifact AbstractArtifact) string {
	return '${artifact.summary} (${abstract_artifact_english_name(artifact.class_name)})'
}

pub fn abstract_artifact_config(artifact AbstractArtifact) ruby.Value {
	return artifact.cask.map_data['config'] or { ruby.object_value('Cask::Config', '') }
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

pub fn abstract_artifact_sandbox_value(sandbox AbstractArtifactSandbox) ruby.Value {
	return ruby.Value{
		type_name: 'Sandbox'
		repr: sandbox.staged_path
		map_data: {
			'staged_path':            ruby.string_value(sandbox.staged_path)
			'network_access_allowed': ruby.bool_value(sandbox.network_access_allowed)
			'install_hook_rules':     ruby.bool_value(sandbox.install_hook_rules)
			'allowed_read_paths':     ruby.string_array_value(sandbox.allowed_read_paths)
		}
	}
}

pub fn abstract_artifact_sandbox_from_value(value ruby.Value) !AbstractArtifactSandbox {
	if value.type_name != 'Sandbox' {
		return error('expected Sandbox, got ${value.type_name}')
	}
	return AbstractArtifactSandbox{
		staged_path: (value.map_data['staged_path'] or { ruby.string_value(value.as_string()) }).as_string()
		network_access_allowed: (value.map_data['network_access_allowed'] or {
			ruby.bool_value(false)
		}).as_bool() or { false }
		install_hook_rules: (value.map_data['install_hook_rules'] or {
			ruby.bool_value(false)
		}).as_bool() or { false }
		allowed_read_paths: (value.map_data['allowed_read_paths'] or {
			ruby.string_array_value([])
		}).as_string_array() or { []string{} }
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

fn abstract_artifact_sandbox_options_from_value(value ruby.Value) AbstractArtifactSandboxOptions {
	return AbstractArtifactSandboxOptions{
		temporary_root: (value.map_data['temporary_root'] or {
			ruby.string_value(os.temp_dir())
		}).as_string()
		ruby_exec_args: (value.map_data['ruby_exec_args'] or {
			ruby.string_array_value([])
		}).as_string_array() or { []string{} }
		load_path: (value.map_data['load_path'] or {
			ruby.string_array_value([])
		}).as_string_array() or { []string{} }
		library_path: (value.map_data['library_path'] or {
			ruby.string_value('')
		}).as_string()
	}
}

fn abstract_artifact_sandbox_run_value(result AbstractArtifactSandboxRunResult) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Artifact::SandboxRun'
		repr: result.invocation.command.join(' ')
		map_data: {
			'sandbox':             abstract_artifact_sandbox_value(result.sandbox)
			'temporary_path':      ruby.string_value(result.invocation.temporary_path)
			'home':                ruby.string_value(result.invocation.home)
			'payload_path':        ruby.string_value(result.invocation.payload_path)
			'payload_json':        ruby.string_value(result.invocation.payload_json)
			'command':             ruby.string_array_value(result.invocation.command)
			'preserved_brew_file': ruby.bool_value(result.invocation.preserved_brew_file)
			'temporary_removed':   ruby.bool_value(result.temporary_removed)
		}
	}
}
