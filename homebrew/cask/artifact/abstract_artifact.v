module artifact

import brew_runtime
import os
import time

// Translated from Homebrew/brew `cask/artifact/abstract_artifact.rb`.
// The original source is retained below until every stub has a typed V body.
const abstract_artifact_default_class = 'Cask::Artifact::AbstractArtifact'
const abstract_artifact_permitted_script_keys = ['args', 'input', 'executable', 'must_succeed',
	'print_stderr', 'print_stdout', 'sudo']

pub struct AbstractArtifact {
pub:
	cask       brew_runtime.Value
	dsl_args   []brew_runtime.Value
	class_name string
	summary    string
}

pub struct AbstractArtifactScriptArguments {
pub:
	executable     string
	has_executable bool
	arguments      map[string]brew_runtime.Value
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

pub type AbstractArtifactSandboxRunner = fn(AbstractArtifactSandboxInvocation) !

fn abstract_artifact_nil() brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn abstract_artifact_deep_dup(value brew_runtime.Value) brew_runtime.Value {
	mut entries := []brew_runtime.Value{cap: value.array_data.len}
	for entry in value.array_data {
		entries << abstract_artifact_deep_dup(entry)
	}
	mut values := map[string]brew_runtime.Value{}
	for key, entry in value.map_data {
		values[key] = abstract_artifact_deep_dup(entry)
	}
	return brew_runtime.Value{
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

fn abstract_artifact_class_name(value brew_runtime.Value) string {
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

pub fn new_abstract_artifact(cask brew_runtime.Value, class_name string, summary string,
	dsl_args []brew_runtime.Value) AbstractArtifact {
	return AbstractArtifact{
		cask: cask
		class_name: if class_name == '' { abstract_artifact_default_class } else { class_name }
		summary: summary
		dsl_args: dsl_args.map(abstract_artifact_deep_dup(it))
	}
}

pub fn abstract_artifact_value(artifact AbstractArtifact) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: artifact.class_name
		repr: artifact.summary
		map_data: {
			'cask':     artifact.cask
			'dsl_args': brew_runtime.array_value(artifact.dsl_args)
			'summary':  brew_runtime.string_value(artifact.summary)
		}
		attributes: {
			'class_name': artifact.class_name
		}
	}
}

pub fn abstract_artifact_from_value(value brew_runtime.Value) AbstractArtifact {
	dsl_args := (value.map_data['dsl_args'] or { brew_runtime.array_value([]) }).as_array() or {
		[]brew_runtime.Value{}
	}
	return new_abstract_artifact(value.map_data['cask'] or {
		brew_runtime.object_value('Cask', '')
	}, abstract_artifact_class_name(value), (value.map_data['summary'] or {
		brew_runtime.string_value(value.as_string())
	}).as_string(), dsl_args)
}

pub fn abstract_artifact_staged_path_join_executable(artifact AbstractArtifact,
	supplied_path string) !string {
	mut path := supplied_path
	if path.starts_with('~') {
		path = os.expand_tilde_to_home(path)
	}
	staged_path := (artifact.cask.map_data['staged_path'] or {
		brew_runtime.string_value(artifact.cask.attributes['staged_path'] or { '' })
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

pub fn read_abstract_artifact_script_arguments(arguments brew_runtime.Value, stanza string,
	default_arguments map[string]brew_runtime.Value, override_arguments map[string]brew_runtime.Value,
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
	mut merged := map[string]brew_runtime.Value{}
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

fn abstract_artifact_blank(value brew_runtime.Value) bool {
	return match value.type_name {
		'NilClass' { true }
		'Bool' { !value.bool_data }
		'String' { value.as_string().trim_space() == '' }
		'Array' { (value.as_array() or { []brew_runtime.Value{} }).len == 0 }
		'Hash' { value.map_data.len == 0 }
		else { false }
	}
}

pub fn abstract_artifact_to_args(artifact AbstractArtifact) []brew_runtime.Value {
	return artifact.dsl_args.filter(!abstract_artifact_blank(it)).map(abstract_artifact_deep_dup(it))
}

pub fn abstract_artifact_to_string(artifact AbstractArtifact) string {
	return '${artifact.summary} (${abstract_artifact_english_name(artifact.class_name)})'
}

pub fn abstract_artifact_config(artifact AbstractArtifact) brew_runtime.Value {
	return artifact.cask.map_data['config'] or { brew_runtime.object_value('Cask::Config', '') }
}

pub fn new_abstract_artifact_sandbox(artifact AbstractArtifact, use_sandbox bool,
	network_access_allowed bool) ?AbstractArtifactSandbox {
	if !use_sandbox {
		return none
	}
	staged_path := (artifact.cask.map_data['staged_path'] or {
		brew_runtime.string_value(artifact.cask.attributes['staged_path'] or { '' })
	}).as_string()
	return AbstractArtifactSandbox{
		staged_path: staged_path
		network_access_allowed: network_access_allowed
		install_hook_rules: true
		allowed_read_paths: [staged_path]
	}
}

pub fn abstract_artifact_sandbox_value(sandbox AbstractArtifactSandbox) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Sandbox'
		repr: sandbox.staged_path
		map_data: {
			'staged_path':            brew_runtime.string_value(sandbox.staged_path)
			'network_access_allowed': brew_runtime.bool_value(sandbox.network_access_allowed)
			'install_hook_rules':     brew_runtime.bool_value(sandbox.install_hook_rules)
			'allowed_read_paths':     brew_runtime.string_array_value(sandbox.allowed_read_paths)
		}
	}
}

pub fn abstract_artifact_sandbox_from_value(value brew_runtime.Value) !AbstractArtifactSandbox {
	if value.type_name != 'Sandbox' {
		return error('expected Sandbox, got ${value.type_name}')
	}
	return AbstractArtifactSandbox{
		staged_path: (value.map_data['staged_path'] or { brew_runtime.string_value(value.as_string()) }).as_string()
		network_access_allowed: (value.map_data['network_access_allowed'] or {
			brew_runtime.bool_value(false)
		}).as_bool() or { false }
		install_hook_rules: (value.map_data['install_hook_rules'] or {
			brew_runtime.bool_value(false)
		}).as_bool() or { false }
		allowed_read_paths: (value.map_data['allowed_read_paths'] or {
			brew_runtime.string_array_value([])
		}).as_string_array() or { []string{} }
	}
}

fn abstract_artifact_noop_sandbox_runner(invocation AbstractArtifactSandboxInvocation) ! {
	_ = invocation
}

pub fn run_abstract_artifact_cask_sandbox(sandbox AbstractArtifactSandbox,
	payload map[string]brew_runtime.Value, options AbstractArtifactSandboxOptions,
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
	payload_json := brew_runtime.json_value_to_string(brew_runtime.map_value(payload))
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

fn abstract_artifact_sandbox_options_from_value(value brew_runtime.Value) AbstractArtifactSandboxOptions {
	return AbstractArtifactSandboxOptions{
		temporary_root: (value.map_data['temporary_root'] or {
			brew_runtime.string_value(os.temp_dir())
		}).as_string()
		ruby_exec_args: (value.map_data['ruby_exec_args'] or {
			brew_runtime.string_array_value([])
		}).as_string_array() or { []string{} }
		load_path: (value.map_data['load_path'] or {
			brew_runtime.string_array_value([])
		}).as_string_array() or { []string{} }
		library_path: (value.map_data['library_path'] or {
			brew_runtime.string_value('')
		}).as_string()
	}
}

fn abstract_artifact_sandbox_run_value(result AbstractArtifactSandboxRunResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Cask::Artifact::SandboxRun'
		repr: result.invocation.command.join(' ')
		map_data: {
			'sandbox':             abstract_artifact_sandbox_value(result.sandbox)
			'temporary_path':      brew_runtime.string_value(result.invocation.temporary_path)
			'home':                brew_runtime.string_value(result.invocation.home)
			'payload_path':        brew_runtime.string_value(result.invocation.payload_path)
			'payload_json':        brew_runtime.string_value(result.invocation.payload_json)
			'command':             brew_runtime.string_array_value(result.invocation.command)
			'preserved_brew_file': brew_runtime.bool_value(result.invocation.preserved_brew_file)
			'temporary_removed':   brew_runtime.bool_value(result.temporary_removed)
		}
	}
}

// Ruby method `self.english_name` at line 28.
pub fn ruby_abstract_artifact_l28_d1_self_english_name(args ...brew_runtime.Value) brew_runtime.Value {
	class_name := if args.len > 0 {
		abstract_artifact_class_name(args[0])
	} else {
		abstract_artifact_default_class
	}
	return brew_runtime.string_value(abstract_artifact_english_name(class_name))
}

// Ruby method `self.english_article` at line 33.
pub fn ruby_abstract_artifact_l33_d2_self_english_article(args ...brew_runtime.Value) brew_runtime.Value {
	class_name := if args.len > 0 {
		abstract_artifact_class_name(args[0])
	} else {
		abstract_artifact_default_class
	}
	return brew_runtime.string_value(abstract_artifact_english_article(class_name))
}

// Ruby method `self.dsl_key` at line 38.
pub fn ruby_abstract_artifact_l38_d3_self_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	class_name := if args.len > 0 {
		abstract_artifact_class_name(args[0])
	} else {
		abstract_artifact_default_class
	}
	return brew_runtime.object_value('Symbol', abstract_artifact_dsl_key(class_name))
}

// Ruby method `self.dirmethod` at line 44.
pub fn ruby_abstract_artifact_l44_d4_self_dirmethod(args ...brew_runtime.Value) brew_runtime.Value {
	class_name := if args.len > 0 {
		abstract_artifact_class_name(args[0])
	} else {
		abstract_artifact_default_class
	}
	return brew_runtime.object_value('Symbol', abstract_artifact_dirmethod(class_name))
}

// Ruby method `summarize; end` at line 49.
pub fn ruby_abstract_artifact_l49_d5_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return abstract_artifact_nil()
}

// Ruby method `staged_path_join_executable(path)` at line 52.
pub fn ruby_abstract_artifact_l52_d6_staged_path_join_executable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'staged_path_join_executable requires a receiver and path')
	}
	path := abstract_artifact_staged_path_join_executable(abstract_artifact_from_value(args[0]), args[1].as_string()) or { return brew_runtime.object_value('SystemCallError', err.msg()) }
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `sort_order` at line 72.
pub fn ruby_abstract_artifact_l72_d7_sort_order(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut order := map[string]brew_runtime.Value{}
	for class_name, index in abstract_artifact_sort_order() {
		order[class_name] = brew_runtime.int_value(index)
	}
	return brew_runtime.map_value(order)
}

// Ruby method `<=>(other)` at line 129.
pub fn ruby_abstract_artifact_l129_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return abstract_artifact_nil()
	}
	comparison := compare_abstract_artifacts(abstract_artifact_class_name(args[0]), abstract_artifact_class_name(args[1])) or { return abstract_artifact_nil() }
	return brew_runtime.int_value(comparison)
}

// Ruby method `self.read_script_arguments(arguments, stanza, default_arguments = {}, override_arguments = {}, key = nil)` at line 149.
pub fn ruby_abstract_artifact_l149_d9_self_read_script_arguments(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'read_script_arguments requires arguments and stanza')
	}
	defaults := if args.len > 2 && args[2].type_name == 'Hash' {
		args[2].map_data
	} else {
		map[string]brew_runtime.Value{}
	}
	overrides := if args.len > 3 && args[3].type_name == 'Hash' {
		args[3].map_data
	} else {
		map[string]brew_runtime.Value{}
	}
	key := if args.len > 4 && args[4].type_name != 'NilClass' { args[4].as_string() } else { '' }
	result := read_abstract_artifact_script_arguments(args[0], args[1].as_string(), defaults, overrides, key) or { return brew_runtime.object_value('FatalError', err.msg()) }
	executable := if result.has_executable {
		brew_runtime.string_value(result.executable)
	} else {
		abstract_artifact_nil()
	}
	return brew_runtime.array_value([executable, brew_runtime.map_value(result.arguments)])
}

// Ruby attr_reader `attr_reader :cask` at line 187.
pub fn ruby_abstract_artifact_l187_d10_cask(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'cask requires a receiver')
	}
	return abstract_artifact_from_value(args[0]).cask
}

// Ruby method `initialize(cask, *dsl_args)` at line 190.
pub fn ruby_abstract_artifact_l190_d11_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'initialize requires a cask')
	}
	class_name := args[0].attributes['artifact_class'] or { abstract_artifact_default_class }
	return abstract_artifact_value(new_abstract_artifact(args[0], class_name, '', args[1..]))
}

// Ruby method `config` at line 201.
pub fn ruby_abstract_artifact_l201_d12_config(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'config requires a receiver')
	}
	return abstract_artifact_config(abstract_artifact_from_value(args[0]))
}

// Ruby method `cask_sandbox(network_access_allowed: false)` at line 206.
pub fn ruby_abstract_artifact_l206_d13_cask_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'cask_sandbox requires a receiver')
	}
	network_access_allowed := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	use_sandbox := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	sandbox := new_abstract_artifact_sandbox(abstract_artifact_from_value(args[0]), use_sandbox, network_access_allowed) or { return abstract_artifact_nil() }
	return abstract_artifact_sandbox_value(sandbox)
}

// Ruby method `run_cask_sandbox(sandbox, payload)` at line 221.
pub fn ruby_abstract_artifact_l221_d14_run_cask_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'run_cask_sandbox requires a receiver, sandbox, and payload')
	}
	sandbox := abstract_artifact_sandbox_from_value(args[1]) or {
		return brew_runtime.object_value('TypeError', err.msg())
	}
	if args[2].type_name != 'Hash' {
		return brew_runtime.object_value('TypeError', 'payload must be a Hash')
	}
	options := if args.len > 3 && args[3].type_name == 'Hash' {
		abstract_artifact_sandbox_options_from_value(args[3])
	} else {
		AbstractArtifactSandboxOptions{}
	}
	result := run_abstract_artifact_cask_sandbox(sandbox, args[2].map_data, options, abstract_artifact_noop_sandbox_runner) or {
		return brew_runtime.object_value('SystemCallError', err.msg())
	}
	return abstract_artifact_sandbox_run_value(result)
}

// Ruby method `to_s` at line 252.
pub fn ruby_abstract_artifact_l252_d15_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'to_s requires a receiver')
	}
	return brew_runtime.string_value(abstract_artifact_to_string(abstract_artifact_from_value(args[0])))
}

// Ruby method `to_args` at line 257.
pub fn ruby_abstract_artifact_l257_d16_to_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'to_args requires a receiver')
	}
	return brew_runtime.array_value(abstract_artifact_to_args(abstract_artifact_from_value(args[0])))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/object/deep_dup"
// 5: require "env_config"
// 6: require "json"
// 7: require "sandbox"
// 8: require "tmpdir"
// 9: require "utils/output"
// 10:
// 11: module Cask
// 12:   # Module containing all cask artifact classes.
// 13:   module Artifact
// 14:     # Abstract superclass for all artifacts.
// 15:     class AbstractArtifact
// 16:       extend T::Helpers
// 17:       extend ::Utils::Output::Mixin
// 18:
// 19:       abstract!
// 20:
// 21:       include Comparable
// 22:       include ::Utils::Output::Mixin
// 23:
// 24:       # T.anything or the union of all possible argument types would be better choice, but it's convenient to be
// 25:       # able to invoke `.inspect`, `.to_s`, etc. without the overhead of type guards.
// 26:       DirectivesType = T.type_alias { Object }
// 27:       sig { overridable.returns(String) }
// 28:       def self.english_name
// 29:         @english_name ||= T.let(T.must(name).sub(/^.*:/, "").gsub(/(.)([A-Z])/, '\1 \2'), T.nilable(String))
// 30:       end
// 31:
// 32:       sig { returns(String) }
// 33:       def self.english_article
// 34:         @english_article ||= T.let(/^[aeiou]/i.match?(english_name) ? "an" : "a", T.nilable(String))
// 35:       end
// 36:
// 37:       sig { overridable.returns(Symbol) }
// 38:       def self.dsl_key
// 39:         @dsl_key ||= T.let(T.must(name).sub(/^.*:/, "").gsub(/(.)([A-Z])/, '\1_\2').downcase.to_sym,
// 40:                            T.nilable(Symbol))
// 41:       end
// 42:
// 43:       sig { overridable.returns(Symbol) }
// 44:       def self.dirmethod
// 45:         @dirmethod ||= T.let(:"#{dsl_key}dir", T.nilable(Symbol))
// 46:       end
// 47:
// 48:       sig { abstract.returns(String) }
// 49:       def summarize; end
// 50:
// 51:       sig { params(path: T.any(String, Pathname)).returns(Pathname) }
// 52:       def staged_path_join_executable(path)
// 53:         path = Pathname(path)
// 54:         path = path.expand_path if path.to_s.start_with?("~")
// 55:
// 56:         absolute_path = if path.absolute?
// 57:           path
// 58:         else
// 59:           cask.staged_path.join(path)
// 60:         end
// 61:
// 62:         FileUtils.chmod "+x", absolute_path if absolute_path.exist? && !absolute_path.executable?
// 63:
// 64:         if absolute_path.exist?
// 65:           absolute_path
// 66:         else
// 67:           path
// 68:         end
// 69:       end
// 70:
// 71:       sig { returns(T::Hash[T.class_of(AbstractArtifact), Integer]) }
// 72:       def sort_order
// 73:         @sort_order ||= T.let(
// 74:           [
// 75:             PreflightSteps,
// 76:             UninstallPreflightSteps,
// 77:             PreflightBlock,
// 78:             # The `uninstall` stanza should be run first, as it may
// 79:             # depend on other artifacts still being installed.
// 80:             Uninstall,
// 81:             GeneratedScript,
// 82:             Installer,
// 83:             # `pkg` should be run before `binary`, so
// 84:             # targets are created prior to linking.
// 85:             # `pkg` should be run before `app`, since an `app` could
// 86:             # contain a nested installer (e.g. `wireshark`).
// 87:             Pkg,
// 88:             [
// 89:               App,
// 90:               AppImage,
// 91:               Suite,
// 92:               Artifact,
// 93:               Colorpicker,
// 94:               Prefpane,
// 95:               Qlplugin,
// 96:               Mdimporter,
// 97:               Dictionary,
// 98:               Font,
// 99:               Service,
// 100:               InputMethod,
// 101:               InternetPlugin,
// 102:               KeyboardLayout,
// 103:               AudioUnitPlugin,
// 104:               VstPlugin,
// 105:               Vst3Plugin,
// 106:               ScreenSaver,
// 107:             ],
// 108:             [
// 109:               Binary,
// 110:               CommandWrapper,
// 111:             ],
// 112:             Manpage,
// 113:             [
// 114:               BashCompletion,
// 115:               FishCompletion,
// 116:               ZshCompletion,
// 117:             ],
// 118:             GeneratedCompletion,
// 119:             PostflightSteps,
// 120:             UninstallPostflightSteps,
// 121:             PostflightBlock,
// 122:             Zap,
// 123:           ].each_with_index.flat_map { |classes, i| Array(classes).map { |c| [c, i] } }.to_h,
// 124:           T.nilable(T::Hash[T.class_of(AbstractArtifact), Integer]),
// 125:         )
// 126:       end
// 127:
// 128:       sig { override.params(other: BasicObject).returns(T.nilable(Integer)) }
// 129:       def <=>(other)
// 130:         case other
// 131:         when AbstractArtifact
// 132:           return 0 if instance_of?(other.class)
// 133:
// 134:           (sort_order[self.class] <=> sort_order[other.class]).to_i
// 135:         end
// 136:       end
// 137:
// 138:       # TODO: this sort of logic would make more sense in dsl.rb, or a
// 139:       #       constructor called from dsl.rb, so long as that isn't slow.
// 140:       sig {
// 141:         params(
// 142:           arguments:          DirectivesType,
// 143:           stanza:             T.any(String, Symbol),
// 144:           default_arguments:  T::Hash[Symbol, T.anything],
// 145:           override_arguments: T::Hash[Symbol, T.anything],
// 146:           key:                T.nilable(Symbol),
// 147:         ).returns([T.nilable(String), T::Hash[Symbol, T.untyped]])
// 148:       }
// 149:       def self.read_script_arguments(arguments, stanza, default_arguments = {}, override_arguments = {}, key = nil)
// 150:         # TODO: when stanza names are harmonized with class names,
// 151:         #       stanza may not be needed as an explicit argument
// 152:         description = key ? "#{stanza} #{key.inspect}" : stanza.to_s
// 153:
// 154:         arguments = case arguments
// 155:         when String then { executable: arguments } # backward-compatible string value
// 156:         when Hash then arguments.dup # Avoid mutating the original argument
// 157:         else odie "Unsupported arguments type #{arguments.class}"
// 158:         end
// 159:
// 160:         # key sanity
// 161:         permitted_keys = [:args, :input, :executable, :must_succeed, :sudo, :print_stdout, :print_stderr]
// 162:         unknown_keys = arguments.keys - permitted_keys
// 163:         unless unknown_keys.empty?
// 164:           opoo "Unknown arguments to #{description} -- " \
// 165:                "#{unknown_keys.inspect} (ignored). Running " \
// 166:                "`brew update; brew cleanup` will likely fix it."
// 167:         end
// 168:         arguments.select! { |k| permitted_keys.include?(k) }
// 169:
// 170:         # key warnings
// 171:         override_keys = override_arguments.keys
// 172:         ignored_keys = arguments.keys & override_keys
// 173:         unless ignored_keys.empty?
// 174:           onoe "Some arguments to #{description} will be ignored -- :#{unknown_keys.inspect} (overridden)."
// 175:         end
// 176:
// 177:         # extract executable
// 178:         executable = arguments.key?(:executable) ? arguments.delete(:executable) : nil
// 179:
// 180:         arguments = default_arguments.merge arguments
// 181:         arguments.merge! override_arguments
// 182:
// 183:         [executable, arguments]
// 184:       end
// 185:
// 186:       sig { returns(Cask) }
// 187:       attr_reader :cask
// 188:
// 189:       sig { params(cask: Cask, dsl_args: T.anything).void }
// 190:       def initialize(cask, *dsl_args)
// 191:         @cask = cask
// 192:         @dirmethod = T.let(nil, T.nilable(Symbol))
// 193:         @dsl_args = T.let(dsl_args.deep_dup, T::Array[T.anything])
// 194:         @dsl_key = T.let(nil, T.nilable(Symbol))
// 195:         @english_article = T.let(nil, T.nilable(String))
// 196:         @english_name = T.let(nil, T.nilable(String))
// 197:         @sort_order = T.let(nil, T.nilable(T::Hash[T.class_of(AbstractArtifact), Integer]))
// 198:       end
// 199:
// 200:       sig { returns(Config) }
// 201:       def config
// 202:         cask.config
// 203:       end
// 204:
// 205:       sig { params(network_access_allowed: T::Boolean).returns(T.nilable(Sandbox)) }
// 206:       def cask_sandbox(network_access_allowed: false)
// 207:         return unless Sandbox.use_for?("running cask artifact operations")
// 208:
// 209:         Sandbox.new.tap do |sandbox|
// 210:           sandbox.allow_read(path: cask.staged_path, type: :subpath)
// 211:           sandbox.add_install_hook_rules(network_access_allowed:)
// 212:         end
// 213:       end
// 214:
// 215:       sig {
// 216:         params(
// 217:           sandbox: Sandbox,
// 218:           payload: T::Hash[String, T.untyped],
// 219:         ).void
// 220:       }
// 221:       def run_cask_sandbox(sandbox, payload)
// 222:         # Formulae sandbox the complete `postinstall.rb` process. Do the same
// 223:         # for cask operations so Ruby file changes and every command share one
// 224:         # profile, instead of forwarding command input and output through files.
// 225:         Dir.mktmpdir("homebrew-cask-sandbox", HOMEBREW_TEMP) do |temporary_directory|
// 226:           temporary_path = Pathname(temporary_directory)
// 227:           home = temporary_path/"home"
// 228:           payload_path = temporary_path/"payload.json"
// 229:           home.mkpath
// 230:           payload_path.write(JSON.generate(payload))
// 231:           sandbox.allow_read(path: payload_path)
// 232:
// 233:           # The payload carries only structured data, not a cask `.rb` file.
// 234:           # Set HOME before starting this child so its boot process and any
// 235:           # commands it runs cannot discover the user's real home directory.
// 236:           Sandbox.with_preserved_brew_file do
// 237:             sandbox.run(
// 238:               "/usr/bin/env",
// 239:               "HOME=#{home}",
// 240:               "nice",
// 241:               *HOMEBREW_RUBY_EXEC_ARGS,
// 242:               "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 243:               "--",
// 244:               HOMEBREW_LIBRARY_PATH/"cask_artifact.rb",
// 245:               payload_path
// 246:             )
// 247:           end
// 248:         end
// 249:       end
// 250:
// 251:       sig { returns(String) }
// 252:       def to_s
// 253:         "#{summarize} (#{self.class.english_name})"
// 254:       end
// 255:
// 256:       sig { returns(T::Array[T.anything]) }
// 257:       def to_args
// 258:         @dsl_args.compact_blank
// 259:       end
// 260:     end
// 261:   end
// 262: end
