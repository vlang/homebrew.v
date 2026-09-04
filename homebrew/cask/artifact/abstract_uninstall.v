module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/abstract_uninstall.rb`.
// The original source is retained below until every stub has a typed V body.
pub const abstract_uninstall_ordered_directives = ['early_script', 'launchctl', 'quit', 'signal',
	'login_item', 'kext', 'script', 'pkgutil', 'delete', 'trash', 'rmdir']

pub struct AbstractUninstallArtifact {
pub:
	cask_token string
	stanza     string = 'uninstall'
	directives map[string]ruby.Value
pub mut:
	bundle_ids_to_reopen []string
}

pub struct UninstallCommand {
pub:
	executable string
	args       []string
	input      string
	sudo       bool
}

pub type UninstallCommandRunner = fn(UninstallCommand) !bool

pub type UninstallGlobber = fn(string) ![]string

pub struct AbstractUninstallOptions {
pub:
	home                      string
	gui                       bool = true
	upgrade                   bool
	reinstall                 bool
	signal_on_upgrade         bool
	successor                 bool
	force                     bool
	launchctl_list            string
	launchctl_user_services   []string
	launchctl_system_services []string
	running_processes         map[string][]int
	quit_success              map[string]bool
	kext_loaded               map[string]bool
	kext_paths                map[string][]string
	package_matches           map[string][]string
	trash_directory           string
	undeletable               []string
	derived_login_item_paths  []string
}

pub struct ResolvedUninstallPath {
pub:
	original string
	paths    []string
}

pub struct PathResolutionResult {
pub mut:
	resolved []ResolvedUninstallPath
	warnings []string
}

pub struct AbstractUninstallResult {
pub mut:
	success              bool = true
	error                string
	output               []string
	warnings             []string
	commands             []UninstallCommand
	directive_order      []string
	removed              []string
	trashed              []string
	untrashable          []string
	packages             []string
	bundle_ids_to_reopen []string
}

fn default_uninstall_runner(command UninstallCommand) !bool {
	_ = command
	return true
}

fn default_uninstall_globber(pattern string) ![]string {
	return os.glob(pattern)
}

fn value_strings(value ruby.Value) []string {
	if value.type_name == 'Array' {
		return value.as_string_array() or { value.as_array() or { return [] }.map(it.as_string()) }
	}
	if value.type_name == 'NilClass' || value.type_name == '' {
		return []
	}
	return [value.as_string()]
}

fn value_bool(values map[string]ruby.Value, key string, fallback bool) bool {
	value := values[key] or { return fallback }
	return value.as_bool() or { fallback }
}

fn signal_pairs(value ruby.Value) [][]string {
	values := value.as_array() or { return [] }
	if values.len > 0 && values[0].type_name == 'Array' {
		return values.map(value_strings(it))
	}
	strings := value_strings(value)
	mut pairs := [][]string{}
	for index := 0; index < strings.len; index += 2 {
		end := if index + 2 < strings.len { index + 2 } else { strings.len }
		pairs << strings[index..end].clone()
	}
	return pairs
}

fn normalize_abstract_uninstall_directives(input map[string]ruby.Value) !map[string]ruby.Value {
	mut directives := input.clone()
	for key, _ in directives {
		if key !in abstract_uninstall_ordered_directives && key != 'on_upgrade' {
			return error('invalid uninstall directive `${key}`')
		}
	}
	if signal := directives['signal'] {
		directives['signal'] = ruby.array_value(signal_pairs(signal).map(ruby.string_array_value(it)))
	}
	return directives
}

pub fn new_abstract_uninstall_artifact(cask_token string, stanza string,
	directives map[string]ruby.Value) !AbstractUninstallArtifact {
	normalized := normalize_abstract_uninstall_directives(directives)!
	return AbstractUninstallArtifact{
		cask_token: cask_token
		stanza: if stanza == '' { 'uninstall' } else { stanza }
		directives: normalized
	}
}

pub fn abstract_uninstall_to_value(artifact AbstractUninstallArtifact) ruby.Value {
	return ruby.map_value({
		'cask_token':           ruby.string_value(artifact.cask_token)
		'stanza':               ruby.string_value(artifact.stanza)
		'directives':           ruby.map_value(artifact.directives)
		'bundle_ids_to_reopen': ruby.string_array_value(artifact.bundle_ids_to_reopen)
	})
}

fn abstract_uninstall_from_value(value ruby.Value) !AbstractUninstallArtifact {
	values := value.as_map()!
	directives := (values['directives'] or { ruby.map_value({}) }).as_map()!
	mut artifact := new_abstract_uninstall_artifact((values['cask_token'] or {
		ruby.string_value('test-cask')
	}).as_string(), (values['stanza'] or { ruby.string_value('uninstall') }).as_string(), directives)!
	artifact.bundle_ids_to_reopen = (values['bundle_ids_to_reopen'] or {
		ruby.string_array_value([])
	}).as_string_array() or { [] }
	return artifact
}

pub fn summarize_abstract_uninstall(artifact AbstractUninstallArtifact) string {
	mut parts := []string{}
	for key in [...abstract_uninstall_ordered_directives, 'on_upgrade'] {
		value := artifact.directives[key] or { continue }
		items := if value.type_name == 'Array' {
			value.as_array() or { []ruby.Value{} }
		} else {
			[value]
		}
		for item in items {
			parts << ':${key} => ${item.repr}'
		}
	}
	return parts.join(', ')
}

fn expand_uninstall_home(path string, home string) string {
	if path == '~' {
		return home
	}
	if path.starts_with('~/') {
		return os.join_path(home, path[2..])
	}
	return path
}

fn has_relative_path_segment(path string) bool {
	return path.split('/').any(it == '.' || it == '..')
}

pub fn resolve_uninstall_paths_with_globber(action string, paths []string,
	options AbstractUninstallOptions, globber UninstallGlobber) !PathResolutionResult {
	mut result := PathResolutionResult{}
	home := if options.home == '' { os.home_dir() } else { options.home }
	for original in paths {
		resolved := expand_uninstall_home(original, home)
		if !resolved.starts_with('/') {
			result.warnings << "Skipping ${action} for relative path '${original}'."
			continue
		}
		if has_relative_path_segment(resolved) {
			result.warnings << "Skipping ${action} for path with relative segments '${original}'."
			continue
		}
		matches := globber(resolved) or {
			return error('Unable to remove some files. Please enable Full Disk Access for your terminal under Privacy & Security > Full Disk Access.')
		}
		mut deletable := []string{}
		for target in matches {
			if target in options.undeletable || !os.is_writable(os.dir(target)) {
				result.warnings << "Skipping ${action} for undeletable path '${target}'."
				continue
			}
			deletable << target
		}
		result.resolved << ResolvedUninstallPath{
			original: original
			paths: deletable
		}
	}
	return result
}

pub fn resolve_uninstall_paths(action string, paths []string,
	options AbstractUninstallOptions) !PathResolutionResult {
	return resolve_uninstall_paths_with_globber(action, paths, options, default_uninstall_globber)
}

fn wildcard_matches(pattern string, candidate string) bool {
	if !pattern.contains('*') {
		return candidate == pattern
	}
	parts := pattern.split('*')
	mut position := 0
	if parts[0] != '' {
		if !candidate.starts_with(parts[0]) {
			return false
		}
		position = parts[0].len
	}
	for index in 1 .. parts.len {
		part := parts[index]
		if part == '' {
			continue
		}
		relative := candidate[position..].index(part) or { return false }
		position += relative + part.len
	}
	return parts.last() == '' || candidate.ends_with(parts.last())
}

pub fn find_launchctl_with_wildcard(search string, listing string) []string {
	mut services := []string{}
	for index, line in listing.split_into_lines() {
		if index == 0 {
			continue
		}
		columns := line.fields()
		if columns.len < 3 || columns[0].int() == 0 {
			continue
		}
		service := columns.last()
		if wildcard_matches(search, service) {
			services << service
		}
	}
	return services
}

pub fn running_processes_for_bundle(bundle_id string, listing string) []int {
	mut pids := []int{}
	for index, line in listing.split_into_lines() {
		if index == 0 {
			continue
		}
		columns := line.fields()
		if columns.len < 3 || columns[0].int() == 0 {
			continue
		}
		mut identifier := columns.last()
		if identifier.starts_with('application.') {
			identifier = identifier['application.'.len..]
		}
		if identifier == bundle_id {
			pids << columns[0].int()
			continue
		}
		if !identifier.starts_with('${bundle_id}.') {
			continue
		}
		suffixes := identifier[(bundle_id.len + 1)..].split('.')
		if suffixes.len <= 2 && suffixes.all(it.len > 0 && it.bytes().all(byte(it) >= `0` && byte(it) <= `9`)) {
			pids << columns[0].int()
		}
	}
	return pids
}

pub fn automation_access_instructions() string {
	return 'Enable Automation access for "Terminal → System Events" in:\n  Privacy & Security > Automation\nif you haven\'t already.'
}

fn run_uninstall_command(command UninstallCommand, runner UninstallCommandRunner,
	mut result AbstractUninstallResult) bool {
	result.commands << command
	return runner(command) or {
		result.warnings << err.msg()
		false
	}
}

fn remove_uninstall_path(path string) ! {
	if os.is_link(path) || os.is_file(path) {
		os.rm(path)!
	} else if os.is_dir(path) {
		os.rmdir_all(path)!
	}
}

fn dispatch_quit(bundle_ids []string, options AbstractUninstallOptions, runner UninstallCommandRunner,
	mut result AbstractUninstallResult) {
	for bundle_id in bundle_ids {
		pids := options.running_processes[bundle_id] or { [] }
		if pids.len == 0 {
			continue
		}
		if !options.gui {
			result.warnings << "Not logged into a GUI; skipping quitting application ID '${bundle_id}'."
			continue
		}
		command := UninstallCommand{
			executable: 'osascript'
			args: ['-l', 'JavaScript', bundle_id]
		}
		runner_success := run_uninstall_command(command, runner, mut result)
		quit_success := options.quit_success[bundle_id] or { runner_success }
		if quit_success {
			result.output << "Application '${bundle_id}' quit successfully."
			if options.upgrade {
				result.bundle_ids_to_reopen << bundle_id
			}
		} else {
			result.warnings << "Application '${bundle_id}' did not quit. ${automation_access_instructions()}"
		}
	}
}

fn service_owned(service string, services []string) bool {
	return service in services
}

fn dispatch_launchctl(services []string, options AbstractUninstallOptions,
	runner UninstallCommandRunner, mut result AbstractUninstallResult) {
	mut expanded := []string{}
	for service in services {
		if service.contains('*') {
			expanded << find_launchctl_with_wildcard(service, options.launchctl_list)
		} else {
			expanded << service
		}
	}
	for service in expanded {
		result.output << 'Removing launchctl service ${service}'
		for sudo in [false, true] {
			owned := if sudo {
				service_owned(service, options.launchctl_system_services)
			} else {
				service_owned(service, options.launchctl_user_services)
			}
			if owned {
				run_uninstall_command(UninstallCommand{
					executable: '/bin/launchctl'
					args: ['remove', service]
					sudo: sudo
				}, runner, mut result)
			}
		}
	}
}

fn dispatch_signal(value ruby.Value, options AbstractUninstallOptions,
	runner UninstallCommandRunner, mut result AbstractUninstallResult) {
	if (options.upgrade || options.reinstall) && !options.signal_on_upgrade {
		return
	}
	for pair in signal_pairs(value) {
		if pair.len != 2 {
			result.success = false
			result.error = 'Each uninstall :signal must consist of 2 elements.'
			return
		}
		signal, bundle_id := pair[0], pair[1]
		pids := options.running_processes[bundle_id] or { [] }
		if pids.len == 0 {
			continue
		}
		result.output << "Signalling '${signal}' to application ID '${bundle_id}'"
		mut arguments := ['-${signal}']
		arguments << pids.map(it.str())
		run_uninstall_command(UninstallCommand{
			executable: '/bin/kill'
			args: arguments
		}, runner, mut result)
	}
}

fn dispatch_login_items(items []string, options AbstractUninstallOptions,
	runner UninstallCommandRunner, mut result AbstractUninstallResult) {
	if options.successor {
		return
	}
	for path in options.derived_login_item_paths {
		result.output << 'Removing login item ${path}'
		run_uninstall_command(UninstallCommand{
			executable: 'osascript'
			args: ['-e', 'delete every login item whose path is "${path}"']
		}, runner, mut result)
	}
	for item in items {
		result.output << 'Removing login item ${item}'
		run_uninstall_command(UninstallCommand{
			executable: 'osascript'
			args: ['-e', 'delete every login item whose name is "${item}"']
		}, runner, mut result)
	}
}

fn dispatch_kexts(kexts []string, options AbstractUninstallOptions,
	runner UninstallCommandRunner, mut result AbstractUninstallResult) {
	for kext in kexts {
		result.output << 'Unloading kernel extension ${kext}'
		run_uninstall_command(UninstallCommand{
			executable: '/usr/sbin/kextstat'
			args: ['-l', '-b', kext]
			sudo: true
		}, runner, mut result)
		if options.kext_loaded[kext] or { false } {
			run_uninstall_command(UninstallCommand{
				executable: '/sbin/kextunload'
				args: ['-b', kext]
				sudo: true
			}, runner, mut result)
		}
		for path in options.kext_paths[kext] or { [] } {
			result.output << 'Removing kernel extension ${path}'
			run_uninstall_command(UninstallCommand{
				executable: '/bin/rm'
				args: ['-rf', path]
				sudo: true
			}, runner, mut result)
		}
	}
}

fn script_details(value ruby.Value) (string, []string, bool) {
	values := value.as_map() or { return value.as_string(), []string{}, false }
	executable := (values['executable'] or { ruby.string_value('') }).as_string()
	arguments := value_strings(values['args'] or { ruby.string_array_value([]) })
	sudo := value_bool(values, 'sudo', false)
	return executable, arguments, sudo
}

fn dispatch_script(value ruby.Value, directive_name string,
	options AbstractUninstallOptions, runner UninstallCommandRunner,
	mut result AbstractUninstallResult) {
	executable, arguments, sudo := script_details(value)
	if executable == '' {
		result.success = false
		result.error = '${directive_name} without :executable.'
		return
	}
	if executable.starts_with('/') && !os.exists(executable) {
		message := 'uninstall script ${executable} does not exist'
		if !options.force {
			result.success = false
			result.error = '${message}.'
			return
		}
		result.warnings << '${message}; skipping.'
		return
	}
	result.output << 'Running uninstall script ${executable}'
	run_uninstall_command(UninstallCommand{
		executable: executable
		args: arguments
		sudo: sudo
	}, runner, mut result)
}

fn dispatch_pkgutil(patterns []string, options AbstractUninstallOptions,
	runner UninstallCommandRunner, mut result AbstractUninstallResult) {
	for pattern in patterns {
		for package_id in options.package_matches[pattern] or { [] } {
			result.packages << package_id
			run_uninstall_command(UninstallCommand{
				executable: '/usr/sbin/pkgutil'
				args: ['--forget', package_id]
				sudo: true
			}, runner, mut result)
		}
	}
}

fn dispatch_delete(paths []string, options AbstractUninstallOptions,
	runner UninstallCommandRunner, mut result AbstractUninstallResult) {
	resolution := resolve_uninstall_paths('delete', paths, options) or {
		result.success = false
		result.error = err.msg()
		return
	}
	result.warnings << resolution.warnings
	for entry in resolution.resolved {
		if entry.paths.len == 0 {
			continue
		}
		run_uninstall_command(UninstallCommand{
			executable: '/usr/bin/xargs'
			args: ['-0', '--', '/bin/rm', '-r', '-f', '--']
			input: entry.paths.join('\0')
			sudo: true
		}, runner, mut result)
		for path in entry.paths {
			remove_uninstall_path(path) or {
				result.success = false
				result.error = err.msg()
				return
			}
			result.removed << path
		}
	}
}

fn dispatch_trash(paths []string, options AbstractUninstallOptions,
	mut result AbstractUninstallResult) {
	resolution := resolve_uninstall_paths('trash', paths, options) or {
		result.success = false
		result.error = err.msg()
		return
	}
	result.warnings << resolution.warnings
	for entry in resolution.resolved {
		for path in entry.paths {
			if options.trash_directory == '' {
				result.untrashable << path
				continue
			}
			os.mkdir_all(options.trash_directory) or {
				result.untrashable << path
				continue
			}
			mut destination := os.join_path(options.trash_directory, os.file_name(path))
			if os.exists(destination) {
				destination += '.trashed'
			}
			os.mv(path, destination) or {
				result.untrashable << path
				continue
			}
			result.trashed << destination
		}
	}
	if result.untrashable.len > 0 {
		result.warnings << 'The following files could not be trashed, please do so manually:'
	}
}

pub fn all_uninstall_paths_are_directories(directories []string) bool {
	return directories.all(os.is_dir(it))
}

pub fn recursive_uninstall_rmdir(directories []string, mut result AbstractUninstallResult) bool {
	for directory in directories {
		if !os.is_dir(directory) {
			return false
		}
		children := os.ls(directory) or { return false }
		for child in children {
			path := os.join_path(directory, child)
			if child != '.DS_Store' && !os.is_dir(path) {
				return false
			}
		}
		for child in children {
			path := os.join_path(directory, child)
			if child == '.DS_Store' {
				os.rm(path) or { return false }
				result.removed << path
			} else if !recursive_uninstall_rmdir([path], mut result) {
				return false
			}
		}
		os.rmdir(directory) or { return false }
		result.removed << directory
	}
	return true
}

fn dispatch_rmdir(paths []string, options AbstractUninstallOptions,
	mut result AbstractUninstallResult) {
	resolution := resolve_uninstall_paths('rmdir', paths, options) or {
		result.success = false
		result.error = err.msg()
		return
	}
	result.warnings << resolution.warnings
	for entry in resolution.resolved {
		if all_uninstall_paths_are_directories(entry.paths) {
			recursive_uninstall_rmdir(entry.paths, mut result)
		}
	}
}

pub fn dispatch_abstract_uninstall_directive(artifact AbstractUninstallArtifact,
	directive string, options AbstractUninstallOptions, runner UninstallCommandRunner,
	mut result AbstractUninstallResult) {
	value := artifact.directives[directive] or { return }
	result.directive_order << directive
	match directive {
		'early_script', 'script' { dispatch_script(value, directive, options, runner, mut result) }
		'launchctl' { dispatch_launchctl(value_strings(value), options, runner, mut result) }
		'quit' { dispatch_quit(value_strings(value), options, runner, mut result) }
		'signal' { dispatch_signal(value, options, runner, mut result) }
		'login_item' { dispatch_login_items(value_strings(value), options, runner, mut result) }
		'kext' { dispatch_kexts(value_strings(value), options, runner, mut result) }
		'pkgutil' { dispatch_pkgutil(value_strings(value), options, runner, mut result) }
		'delete' { dispatch_delete(value_strings(value), options, runner, mut result) }
		'trash' { dispatch_trash(value_strings(value), options, mut result) }
		'rmdir' { dispatch_rmdir(value_strings(value), options, mut result) }
		else {}
	}
}

pub fn dispatch_abstract_uninstall_with_command(mut artifact AbstractUninstallArtifact,
	options AbstractUninstallOptions, runner UninstallCommandRunner) AbstractUninstallResult {
	mut result := AbstractUninstallResult{}
	for directive in abstract_uninstall_ordered_directives {
		dispatch_abstract_uninstall_directive(artifact, directive, options, runner, mut result)
		if !result.success {
			break
		}
	}
	artifact.bundle_ids_to_reopen << result.bundle_ids_to_reopen
	return result
}

pub fn dispatch_abstract_uninstall(mut artifact AbstractUninstallArtifact,
	options AbstractUninstallOptions) AbstractUninstallResult {
	return dispatch_abstract_uninstall_with_command(mut artifact, options, default_uninstall_runner)
}

pub fn abstract_uninstall_result_to_value(result AbstractUninstallResult) ruby.Value {
	return ruby.map_value({
		'success':              ruby.bool_value(result.success)
		'error':                ruby.string_value(result.error)
		'output':               ruby.string_array_value(result.output)
		'warnings':             ruby.string_array_value(result.warnings)
		'directive_order':      ruby.string_array_value(result.directive_order)
		'removed':              ruby.string_array_value(result.removed)
		'trashed':              ruby.string_array_value(result.trashed)
		'untrashable':          ruby.string_array_value(result.untrashable)
		'packages':             ruby.string_array_value(result.packages)
		'bundle_ids_to_reopen': ruby.string_array_value(result.bundle_ids_to_reopen)
	})
}

fn adapter_artifact(args []ruby.Value) AbstractUninstallArtifact {
	if args.len > 0 {
		return abstract_uninstall_from_value(args[0]) or {
			return AbstractUninstallArtifact{
				cask_token: 'test-cask'
				directives: {}
			}
		}
	}
	return AbstractUninstallArtifact{
		cask_token: 'test-cask'
		directives: {}
	}
}

fn adapter_options(args []ruby.Value, index int) AbstractUninstallOptions {
	if args.len <= index {
		return AbstractUninstallOptions{}
	}
	values := args[index].as_map() or { return AbstractUninstallOptions{} }
	return AbstractUninstallOptions{
		home: (values['home'] or { ruby.string_value('') }).as_string()
		gui: value_bool(values, 'gui', true)
		upgrade: value_bool(values, 'upgrade', false)
		reinstall: value_bool(values, 'reinstall', false)
		signal_on_upgrade: value_bool(values, 'signal_on_upgrade', false)
		force: value_bool(values, 'force', false)
		launchctl_list: (values['launchctl_list'] or { ruby.string_value('') }).as_string()
		trash_directory: (values['trash_directory'] or { ruby.string_value('') }).as_string()
		undeletable: value_strings(values['undeletable'] or { ruby.string_array_value([]) })
	}
}

fn dispatch_adapter_directive(name string, value ruby.Value,
	options AbstractUninstallOptions) ruby.Value {
	mut artifact := new_abstract_uninstall_artifact('test-cask', 'uninstall', {
		name: value
	}) or {
		return ruby.object_value('CaskInvalidError', err.msg())
	}
	return abstract_uninstall_result_to_value(dispatch_abstract_uninstall(mut artifact, options))
}

// Ruby method `self.from_args(cask, **directives)` at line 40.
pub fn ruby_abstract_uninstall_l40_d1_self_from_args(args ...ruby.Value) ruby.Value {
	token := if args.len > 0 { args[0].as_string() } else { 'test-cask' }
	directives := if args.len > 1 {
		args[1].as_map() or { map[string]ruby.Value{} }
	} else {
		map[string]ruby.Value{}
	}
	artifact := new_abstract_uninstall_artifact(token, 'uninstall', directives) or {
		return ruby.object_value('CaskInvalidError', err.msg())
	}
	return abstract_uninstall_to_value(artifact)
}

// Ruby attr_reader `attr_reader :directives` at line 45.
pub fn ruby_abstract_uninstall_l45_d2_directives(args ...ruby.Value) ruby.Value {
	return ruby.map_value(adapter_artifact(args).directives)
}

// Ruby method `initialize(cask, **directives)` at line 48.
pub fn ruby_abstract_uninstall_l48_d3_initialize(args ...ruby.Value) ruby.Value {
	return ruby_abstract_uninstall_l40_d1_self_from_args(...args)
}

// Ruby method `to_h` at line 66.
pub fn ruby_abstract_uninstall_l66_d4_to_h(args ...ruby.Value) ruby.Value {
	return ruby.map_value(adapter_artifact(args).directives)
}

// Ruby method `summarize` at line 71.
pub fn ruby_abstract_uninstall_l71_d5_summarize(args ...ruby.Value) ruby.Value {
	return ruby.string_value(summarize_abstract_uninstall(adapter_artifact(args)))
}

// Ruby method `bundle_ids_to_reopen` at line 76.
pub fn ruby_abstract_uninstall_l76_d6_bundle_ids_to_reopen(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(adapter_artifact(args).bundle_ids_to_reopen)
}

// Ruby method `uninstall_quit(*bundle_ids, command: nil, upgrade: false, **_kwargs)` at line 89.
pub fn ruby_abstract_uninstall_l89_d7_uninstall_quit(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.string_array_value([]) }
	return dispatch_adapter_directive('quit', value, adapter_options(args, 1))
}

// Ruby method `each_resolved_path(action, paths, &_block)` at line 130.
pub fn ruby_abstract_uninstall_l130_d8_each_resolved_path(args ...ruby.Value) ruby.Value {
	action := if args.len > 0 { args[0].as_string() } else { 'delete' }
	paths := if args.len > 1 { value_strings(args[1]) } else { []string{} }
	resolution := resolve_uninstall_paths(action, paths, adapter_options(args, 2)) or {
		return ruby.object_value('CaskError', err.msg())
	}
	return ruby.map_value({
		'paths':    ruby.array_value(resolution.resolved.map(ruby.map_value({
			'original': ruby.string_value(it.original)
			'paths':    ruby.string_array_value(it.paths)
		})))
		'warnings': ruby.string_array_value(resolution.warnings)
	})
}

// Ruby method `find_launchctl_with_wildcard(search)` at line 164.
pub fn ruby_abstract_uninstall_l164_d9_find_launchctl_with_wildcard(args ...ruby.Value) ruby.Value {
	search := if args.len > 0 { args[0].as_string() } else { '*' }
	listing := if args.len > 1 { args[1].as_string() } else { 'PID Status Label' }
	return ruby.string_array_value(find_launchctl_with_wildcard(search, listing))
}

// Ruby method `dispatch_uninstall_directives(**options)` at line 177.
pub fn ruby_abstract_uninstall_l177_d10_dispatch_uninstall_directives(args ...ruby.Value) ruby.Value {
	mut artifact := adapter_artifact(args)
	return abstract_uninstall_result_to_value(dispatch_abstract_uninstall(mut artifact, adapter_options(args, 1)))
}

// Ruby method `dispatch_uninstall_directive(directive_sym, **options)` at line 184.
pub fn ruby_abstract_uninstall_l184_d11_dispatch_uninstall_directive(args ...ruby.Value) ruby.Value {
	artifact := adapter_artifact(args)
	directive := if args.len > 1 { args[1].as_string() } else { 'delete' }
	mut result := AbstractUninstallResult{}
	dispatch_abstract_uninstall_directive(artifact, directive, adapter_options(args, 2), default_uninstall_runner, mut result)
	return abstract_uninstall_result_to_value(result)
}

// Ruby method `stanza` at line 193.
pub fn ruby_abstract_uninstall_l193_d12_stanza(args ...ruby.Value) ruby.Value {
	return ruby.string_value(adapter_artifact(args).stanza)
}

// Ruby method `uninstall_early_script(directives, **options)` at line 201.
pub fn ruby_abstract_uninstall_l201_d13_uninstall_early_script(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.map_value({}) }
	return dispatch_adapter_directive('early_script', value, adapter_options(args, 1))
}

// Ruby method `uninstall_launchctl(*services, command:, **_kwargs)` at line 207.
pub fn ruby_abstract_uninstall_l207_d14_uninstall_launchctl(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.string_array_value([]) }
	return dispatch_adapter_directive('launchctl', value, adapter_options(args, 1))
}

// Ruby method `running_processes(bundle_id)` at line 271.
pub fn ruby_abstract_uninstall_l271_d15_running_processes(args ...ruby.Value) ruby.Value {
	bundle_id := if args.len > 0 { args[0].as_string() } else { '' }
	listing := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.array_value(running_processes_for_bundle(bundle_id, listing).map(ruby.int_value(it)))
}

// Ruby method `automation_access_instructions` at line 282.
pub fn ruby_abstract_uninstall_l282_d16_automation_access_instructions(args ...ruby.Value) ruby.Value {
	return ruby.string_value(automation_access_instructions())
}

// Ruby method `running?(bundle_id)` at line 291.
pub fn ruby_abstract_uninstall_l291_d17_running(args ...ruby.Value) ruby.Value {
	bundle_id := if args.len > 0 { args[0].as_string() } else { '' }
	listing := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.bool_value(running_processes_for_bundle(bundle_id, listing).len > 0)
}

// Ruby method `quit(bundle_id)` at line 314.
pub fn ruby_abstract_uninstall_l314_d18_quit(args ...ruby.Value) ruby.Value {
	bundle_id := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.map_value({
		'success': ruby.bool_value(bundle_id != '')
		'command': ruby.string_value('osascript -l JavaScript ${bundle_id}')
	})
}

// Ruby method `uninstall_signal(*signals, command: nil, **_kwargs)` at line 344.
pub fn ruby_abstract_uninstall_l344_d19_uninstall_signal(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.string_array_value([]) }
	return dispatch_adapter_directive('signal', value, adapter_options(args, 1))
}

// Ruby method `uninstall_login_item(*login_items, command: nil, successor: nil, **_kwargs)` at line 378.
pub fn ruby_abstract_uninstall_l378_d20_uninstall_login_item(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.string_array_value([]) }
	return dispatch_adapter_directive('login_item', value, adapter_options(args, 1))
}

// Ruby method `uninstall_kext(*kexts, command: nil, **_kwargs)` at line 409.
pub fn ruby_abstract_uninstall_l409_d21_uninstall_kext(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.string_array_value([]) }
	return dispatch_adapter_directive('kext', value, adapter_options(args, 1))
}

// Ruby method `uninstall_script(directives, command:, directive_name: :script, force: false, **_kwargs)` at line 455.
pub fn ruby_abstract_uninstall_l455_d22_uninstall_script(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.map_value({}) }
	return dispatch_adapter_directive('script', value, adapter_options(args, 1))
}

// Ruby method `uninstall_pkgutil(*pkgs, command:, **_kwargs)` at line 482.
pub fn ruby_abstract_uninstall_l482_d23_uninstall_pkgutil(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.string_array_value([]) }
	return dispatch_adapter_directive('pkgutil', value, adapter_options(args, 1))
}

// Ruby method `uninstall_delete(*paths, command:, **_kwargs)` at line 493.
pub fn ruby_abstract_uninstall_l493_d24_uninstall_delete(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.string_array_value([]) }
	return dispatch_adapter_directive('delete', value, adapter_options(args, 1))
}

// Ruby method `uninstall_trash(*paths, **options)` at line 509.
pub fn ruby_abstract_uninstall_l509_d25_uninstall_trash(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.string_array_value([]) }
	return dispatch_adapter_directive('trash', value, adapter_options(args, 1))
}

// Ruby method `trash_paths(*paths, command: nil, **_kwargs)` at line 522.
pub fn ruby_abstract_uninstall_l522_d26_trash_paths(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.string_array_value([]) }
	return dispatch_adapter_directive('trash', value, adapter_options(args, 1))
}

// Ruby method `all_dirs?(*directories)` at line 536.
pub fn ruby_abstract_uninstall_l536_d27_all_dirs(args ...ruby.Value) ruby.Value {
	paths := if args.len > 0 { value_strings(args[0]) } else { []string{} }
	return ruby.bool_value(all_uninstall_paths_are_directories(paths))
}

// Ruby method `recursive_rmdir(*directories, command:, **_kwargs)` at line 541.
pub fn ruby_abstract_uninstall_l541_d28_recursive_rmdir(args ...ruby.Value) ruby.Value {
	paths := if args.len > 0 { value_strings(args[0]) } else { []string{} }
	mut result := AbstractUninstallResult{}
	success := recursive_uninstall_rmdir(paths, mut result)
	result.success = success
	return abstract_uninstall_result_to_value(result)
}

// Ruby method `uninstall_rmdir(*directories, **kwargs)` at line 579.
pub fn ruby_abstract_uninstall_l579_d29_uninstall_rmdir(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0] } else { ruby.string_array_value([]) }
	return dispatch_adapter_directive('rmdir', value, adapter_options(args, 1))
}

// Ruby method `undeletable?(target)` at line 592.
pub fn ruby_abstract_uninstall_l592_d30_undeletable(args ...ruby.Value) ruby.Value {
	target := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.bool_value(target != '' && !os.is_writable(os.dir(target)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "timeout"
// 5:
// 6: require "services/system"
// 7: require "utils/user"
// 8: require "cask/artifact/abstract_artifact"
// 9: require "cask/pkg"
// 10: require "cask/utils"
// 11: require "cask/utils/trash"
// 12: require "extend/hash/keys"
// 13: require "system_command"
// 14:
// 15: module Cask
// 16:   module Artifact
// 17:     # Abstract superclass for uninstall artifacts.
// 18:     class AbstractUninstall < AbstractArtifact
// 19:       include SystemCommand::Mixin
// 20:
// 21:       ORDERED_DIRECTIVES = [
// 22:         :early_script,
// 23:         :launchctl,
// 24:         :quit,
// 25:         :signal,
// 26:         :login_item,
// 27:         :kext,
// 28:         :script,
// 29:         :pkgutil,
// 30:         :delete,
// 31:         :trash,
// 32:         :rmdir,
// 33:       ].freeze
// 34:
// 35:       METADATA_KEYS = [
// 36:         :on_upgrade,
// 37:       ].freeze
// 38:
// 39:       sig { params(cask: Cask, directives: DirectivesType).returns(AbstractUninstall) }
// 40:       def self.from_args(cask, **directives)
// 41:         new(cask, **directives)
// 42:       end
// 43:
// 44:       sig { returns(T::Hash[Symbol, DirectivesType]) }
// 45:       attr_reader :directives
// 46:
// 47:       sig { params(cask: Cask, directives: DirectivesType).void }
// 48:       def initialize(cask, **directives)
// 49:         directives.assert_valid_keys(*ORDERED_DIRECTIVES, *METADATA_KEYS)
// 50:
// 51:         super
// 52:         directives[:signal] = Array(directives[:signal]).flatten.each_slice(2).to_a
// 53:         @directives = directives
// 54:
// 55:         # This is already included when loading from the API.
// 56:         return if cask.loaded_from_api?
// 57:         return unless directives.key?(:kext)
// 58:
// 59:         cask.caveats do
// 60:           T.bind(self, ::Cask::DSL::Caveats)
// 61:           kext
// 62:         end
// 63:       end
// 64:
// 65:       sig { returns(T::Hash[Symbol, DirectivesType]) }
// 66:       def to_h
// 67:         directives.to_h
// 68:       end
// 69:
// 70:       sig { override.returns(String) }
// 71:       def summarize
// 72:         to_h.flat_map { |key, val| Array(val).map { |v| "#{key.inspect} => #{v.inspect}" } }.join(", ")
// 73:       end
// 74:
// 75:       sig { returns(T::Array[String]) }
// 76:       def bundle_ids_to_reopen
// 77:         @bundle_ids_to_reopen ||= T.let([], T.nilable(T::Array[String]))
// 78:       end
// 79:
// 80:       # :quit/:signal must come before :kext so the kext will not be in use by a running process
// 81:       sig {
// 82:         params(
// 83:           bundle_ids: String,
// 84:           command:    T.nilable(T.class_of(SystemCommand)),
// 85:           upgrade:    T::Boolean,
// 86:           _kwargs:    T.anything,
// 87:         ).void
// 88:       }
// 89:       def uninstall_quit(*bundle_ids, command: nil, upgrade: false, **_kwargs)
// 90:         bundle_ids.each do |bundle_id|
// 91:           next unless running?(bundle_id)
// 92:
// 93:           unless T.must(User.current).gui?
// 94:             opoo "Not logged into a GUI; skipping quitting application ID '#{bundle_id}'."
// 95:             next
// 96:           end
// 97:
// 98:           ohai "Quitting application '#{bundle_id}'..."
// 99:
// 100:           quit_succeeded = T.let(false, T::Boolean)
// 101:           begin
// 102:             Timeout.timeout(10) do
// 103:               Kernel.loop do
// 104:                 next unless quit(bundle_id).success?
// 105:
// 106:                 next if running?(bundle_id)
// 107:
// 108:                 puts "Application '#{bundle_id}' quit successfully."
// 109:                 quit_succeeded = true
// 110:                 break
// 111:               end
// 112:             end
// 113:           rescue Timeout::Error
// 114:             opoo "Application '#{bundle_id}' did not quit. #{automation_access_instructions}"
// 115:           end
// 116:
// 117:           bundle_ids_to_reopen << bundle_id if upgrade && quit_succeeded
// 118:         end
// 119:       end
// 120:
// 121:       # This returns T::Enumerable[[Pathname, T::Array[Pathname]]] when called without a block,
// 122:       # but sorbet doesn't support overloads.
// 123:       sig {
// 124:         params(
// 125:           action: Symbol,
// 126:           paths:  T::Array[T.any(Pathname, String)],
// 127:           _block: T.nilable(T.proc.params(path: T.any(Pathname, String), resolved_paths: T::Array[Pathname]).void),
// 128:         ).returns(T.untyped)
// 129:       }
// 130:       def each_resolved_path(action, paths, &_block)
// 131:         return enum_for(:each_resolved_path, action, paths) unless block_given?
// 132:
// 133:         paths.each do |path|
// 134:           resolved_path = Pathname.new(path.to_s.sub(%r{^~(?=(/|$))}, Dir.home))
// 135:
// 136:           if resolved_path.relative?
// 137:             opoo "Skipping #{Formatter.identifier(action)} for relative path '#{path}'."
// 138:             next
// 139:           end
// 140:
// 141:           if resolved_path.each_filename.to_a.intersect?([".", ".."])
// 142:             opoo "Skipping #{Formatter.identifier(action)} for path with relative segments '#{path}'."
// 143:             next
// 144:           end
// 145:
// 146:           begin
// 147:             resolved_paths = Pathname.glob(resolved_path).reject do |target|
// 148:               next false unless undeletable?(target)
// 149:
// 150:               opoo "Skipping #{Formatter.identifier(action)} for undeletable path '#{target}'."
// 151:               true
// 152:             end
// 153:             yield path, resolved_paths
// 154:           rescue Errno::EPERM
// 155:             raise if ::Cask::Utils.full_disk_access_enabled?
// 156:
// 157:             odie "Unable to remove some files. Please enable Full Disk Access for your terminal under " \
// 158:                  "#{::Cask::Utils.privacy_security_preference_pane("Full Disk Access")}."
// 159:           end
// 160:         end
// 161:       end
// 162:
// 163:       sig { params(search: String).returns(T::Array[String]) }
// 164:       def find_launchctl_with_wildcard(search)
// 165:         regex = Regexp.escape(search).gsub("\\*", ".*")
// 166:         system_command!("/bin/launchctl", args: ["list"])
// 167:           .stdout.lines.drop(1) # skip stdout column headers
// 168:           .filter_map do |line|
// 169:             pid, _state, id = line.chomp.split(/\s+/)
// 170:             id if pid.to_i.nonzero? && T.must(id).match?(regex)
// 171:           end
// 172:       end
// 173:
// 174:       private
// 175:
// 176:       sig { params(options: DirectivesType).void }
// 177:       def dispatch_uninstall_directives(**options)
// 178:         ORDERED_DIRECTIVES.each do |directive_sym|
// 179:           dispatch_uninstall_directive(directive_sym, **options)
// 180:         end
// 181:       end
// 182:
// 183:       sig { params(directive_sym: Symbol, options: T.anything).void }
// 184:       def dispatch_uninstall_directive(directive_sym, **options)
// 185:         return unless directives.key?(directive_sym)
// 186:
// 187:         args = directives[directive_sym]
// 188:
// 189:         send(:"uninstall_#{directive_sym}", *(args.is_a?(Hash) ? [args] : args), **options)
// 190:       end
// 191:
// 192:       sig { returns(Symbol) }
// 193:       def stanza
// 194:         self.class.dsl_key
// 195:       end
// 196:
// 197:       # Preserve prior functionality of script which runs first. Should rarely be needed.
// 198:       # :early_script should not delete files, better defer that to :script.
// 199:       # If cask writers never need :early_script it may be removed in the future.
// 200:       sig { params(directives: DirectivesType, options: T.anything).void }
// 201:       def uninstall_early_script(directives, **options)
// 202:         uninstall_script(directives, directive_name: :early_script, **options)
// 203:       end
// 204:
// 205:       # :launchctl must come before :quit/:signal for cases where app would instantly re-launch
// 206:       sig { params(services: String, command: T.class_of(SystemCommand), _kwargs: T.anything).void }
// 207:       def uninstall_launchctl(*services, command:, **_kwargs)
// 208:         booleans = [false, true]
// 209:
// 210:         all_services = []
// 211:
// 212:         # if launchctl item contains a wildcard, find matching process(es)
// 213:         services.each do |service|
// 214:           all_services << service unless service.include?("*")
// 215:           next unless service.include?("*")
// 216:
// 217:           found_services = find_launchctl_with_wildcard(service)
// 218:           next if found_services.blank?
// 219:
// 220:           found_services.each { |found_service| all_services << found_service }
// 221:         end
// 222:
// 223:         all_services.each do |service|
// 224:           ohai "Removing launchctl service #{service}"
// 225:           booleans.each do |sudo|
// 226:             _, found, = Homebrew::Services::System.launchctl_find_service(service, sudo:)
// 227:             if found
// 228:               result = command.run(
// 229:                 "/bin/launchctl",
// 230:                 args:         ["remove", service],
// 231:                 must_succeed: false,
// 232:                 sudo:,
// 233:                 sudo_as_root: sudo,
// 234:               )
// 235:               next unless result.success?
// 236:
// 237:               sleep 1
// 238:             end
// 239:             paths = [
// 240:               "/Library/LaunchAgents/#{service}.plist",
// 241:               "/Library/LaunchDaemons/#{service}.plist",
// 242:             ]
// 243:             paths.each { |elt| elt.prepend(Dir.home).freeze } unless sudo
// 244:             paths = paths.map { |elt| Pathname(elt) }.select(&:exist?)
// 245:             paths.each do |path|
// 246:               command.run("/bin/rm", args: ["-f", "--", path], must_succeed: false, sudo:, sudo_as_root: sudo)
// 247:             end
// 248:             # undocumented and untested: pass a path to uninstall :launchctl
// 249:             next unless Pathname(service).exist?
// 250:
// 251:             command.run(
// 252:               "/bin/launchctl",
// 253:               args:         ["unload", "-w", "--", service],
// 254:               must_succeed: false,
// 255:               sudo:,
// 256:               sudo_as_root: sudo,
// 257:             )
// 258:             command.run(
// 259:               "/bin/rm",
// 260:               args:         ["-f", "--", service],
// 261:               must_succeed: false,
// 262:               sudo:,
// 263:               sudo_as_root: sudo,
// 264:             )
// 265:             sleep 1
// 266:           end
// 267:         end
// 268:       end
// 269:
// 270:       sig { params(bundle_id: String).returns(T::Array[[Integer, Integer, T.nilable(String)]]) }
// 271:       def running_processes(bundle_id)
// 272:         system_command!("/bin/launchctl", args: ["list"])
// 273:           .stdout.lines.drop(1)
// 274:           .map { |line| line.chomp.split("\t") }
// 275:           .map { |pid, state, id| [pid.to_i, state.to_i, id] }
// 276:           .select do |(pid, _, id)|
// 277:             pid.nonzero? && /\A(?:application\.)?#{Regexp.escape(bundle_id)}(?:\.\d+){0,2}\Z/.match?(id)
// 278:           end
// 279:       end
// 280:
// 281:       sig { returns(String) }
// 282:       def automation_access_instructions
// 283:         <<~EOS
// 284:           Enable Automation access for "Terminal → System Events" in:
// 285:             #{::Cask::Utils.privacy_security_preference_pane("Automation")}
// 286:           if you haven't already.
// 287:         EOS
// 288:       end
// 289:
// 290:       sig { params(bundle_id: String).returns(T::Boolean) }
// 291:       def running?(bundle_id)
// 292:         script = <<~JAVASCRIPT
// 293:           'use strict';
// 294:
// 295:           ObjC.import('stdlib')
// 296:
// 297:           function run(argv) {
// 298:             try {
// 299:               var app = Application(argv[0])
// 300:               if (app.running()) {
// 301:                 $.exit(0)
// 302:               }
// 303:             } catch (err) { }
// 304:
// 305:             $.exit(1)
// 306:           }
// 307:         JAVASCRIPT
// 308:
// 309:         system_command("osascript", args:         ["-l", "JavaScript", "-e", script, bundle_id],
// 310:                                     print_stderr: true).status.success? || false
// 311:       end
// 312:
// 313:       sig { params(bundle_id: String).returns(SystemCommand::Result) }
// 314:       def quit(bundle_id)
// 315:         script = <<~JAVASCRIPT
// 316:           'use strict';
// 317:
// 318:           ObjC.import('stdlib')
// 319:
// 320:           function run(argv) {
// 321:             var app = Application(argv[0])
// 322:
// 323:             try {
// 324:               app.quit()
// 325:             } catch (err) {
// 326:               if (app.running()) {
// 327:                 $.exit(1)
// 328:               }
// 329:             }
// 330:
// 331:             $.exit(0)
// 332:           }
// 333:         JAVASCRIPT
// 334:
// 335:         system_command "osascript", args:         ["-l", "JavaScript", "-e", script, bundle_id],
// 336:                                     print_stderr: false
// 337:       end
// 338:       private :quit
// 339:
// 340:       # :signal should come after :quit so it can be used as a backup when :quit fails
// 341:       sig {
// 342:         params(signals: [String, String], command: T.nilable(T.class_of(SystemCommand)), _kwargs: T.anything).void
// 343:       }
// 344:       def uninstall_signal(*signals, command: nil, **_kwargs)
// 345:         signals.each do |pair|
// 346:           raise CaskInvalidError.new(cask, "Each #{stanza} :signal must consist of 2 elements.") if pair.size != 2
// 347:
// 348:           signal, bundle_id = pair
// 349:           ohai "Signalling '#{signal}' to application ID '#{bundle_id}'"
// 350:           pids = running_processes(bundle_id).map(&:first)
// 351:           next if pids.none?
// 352:
// 353:           # Note that unlike :quit, signals are sent from the current user (not
// 354:           # upgraded to the superuser). This is a todo item for the future, but
// 355:           # there should be some additional thought/safety checks about that, as a
// 356:           # misapplied "kill" by root could bring down the system. The fact that we
// 357:           # learned the pid from AppleScript is already some degree of protection,
// 358:           # though indirect.
// 359:           # TODO: check the user that owns the PID and don't try to kill those from other users.
// 360:           odebug "Unix ids are #{pids.inspect} for processes with bundle identifier #{bundle_id}"
// 361:           begin
// 362:             Process.kill(signal, *pids)
// 363:           rescue Errno::EPERM => e
// 364:             opoo "Failed to kill #{bundle_id} PIDs #{pids.join(", ")} with signal #{signal}: #{e}"
// 365:           end
// 366:           sleep 3
// 367:         end
// 368:       end
// 369:
// 370:       sig {
// 371:         params(
// 372:           login_items: T.any(String, T::Hash[Symbol, T.any(String, Pathname)]),
// 373:           command:     T.nilable(T.class_of(SystemCommand)),
// 374:           successor:   T.nilable(Cask),
// 375:           _kwargs:     T.anything,
// 376:         ).void
// 377:       }
// 378:       def uninstall_login_item(*login_items, command: nil, successor: nil, **_kwargs)
// 379:         return if successor
// 380:
// 381:         apps = cask.artifacts.select { |a| a.class.dsl_key == :app }
// 382:         derived_login_items = apps.map { |a| { path: a.target } }
// 383:
// 384:         [*derived_login_items, *login_items].each do |item|
// 385:           type, id = if item.respond_to?(:key) && item.key?(:path)
// 386:             ["path", item[:path]]
// 387:           else
// 388:             ["name", item]
// 389:           end
// 390:
// 391:           ohai "Removing login item #{id}"
// 392:
// 393:           result = system_command(
// 394:             "osascript",
// 395:             args: [
// 396:               "-e",
// 397:               %Q(tell application "System Events" to delete every login item whose #{type} is #{id.to_s.inspect}),
// 398:             ],
// 399:           )
// 400:
// 401:           opoo "Removal of login item #{id} failed. #{automation_access_instructions}" unless result.success?
// 402:
// 403:           sleep 1
// 404:         end
// 405:       end
// 406:
// 407:       # :kext should be unloaded before attempting to delete the relevant file
// 408:       sig { params(kexts: String, command: T.nilable(T.class_of(SystemCommand)), _kwargs: T.anything).void }
// 409:       def uninstall_kext(*kexts, command: nil, **_kwargs)
// 410:         kexts.each do |kext|
// 411:           ohai "Unloading kernel extension #{kext}"
// 412:           is_loaded = system_command!(
// 413:             "/usr/sbin/kextstat",
// 414:             args:         ["-l", "-b", kext],
// 415:             sudo:         true,
// 416:             sudo_as_root: true,
// 417:           ).stdout
// 418:           if is_loaded.length > 1
// 419:             system_command!(
// 420:               "/sbin/kextunload",
// 421:               args:         ["-b", kext],
// 422:               sudo:         true,
// 423:               sudo_as_root: true,
// 424:             )
// 425:             sleep 1
// 426:           end
// 427:           found_kexts = system_command!(
// 428:             "/usr/sbin/kextfind",
// 429:             args:         ["-b", kext],
// 430:             sudo:         true,
// 431:             sudo_as_root: true,
// 432:           ).stdout.chomp.lines
// 433:           found_kexts.each do |kext_path|
// 434:             ohai "Removing kernel extension #{kext_path}"
// 435:             system_command!(
// 436:               "/bin/rm",
// 437:               args:         ["-rf", kext_path],
// 438:               sudo:         true,
// 439:               sudo_as_root: true,
// 440:             )
// 441:           end
// 442:         end
// 443:       end
// 444:
// 445:       # :script must come before :pkgutil, :delete, or :trash so that the script file is not already deleted
// 446:       sig {
// 447:         params(
// 448:           directives:     DirectivesType,
// 449:           command:        T.class_of(SystemCommand),
// 450:           directive_name: Symbol,
// 451:           force:          T::Boolean,
// 452:           _kwargs:        T.anything,
// 453:         ).void
// 454:       }
// 455:       def uninstall_script(directives, command:, directive_name: :script, force: false, **_kwargs)
// 456:         # TODO: Create a common `Script` class to run this and Artifact::Installer.
// 457:         executable, script_arguments = self.class.read_script_arguments(directives,
// 458:                                                                         "uninstall",
// 459:                                                                         { must_succeed: true, sudo: false },
// 460:                                                                         { print_stdout: true },
// 461:                                                                         directive_name)
// 462:
// 463:         ohai "Running uninstall script #{executable}"
// 464:         raise CaskInvalidError.new(cask, "#{stanza} :#{directive_name} without :executable.") if executable.nil?
// 465:
// 466:         executable_path = staged_path_join_executable(executable)
// 467:
// 468:         if (executable_path.absolute? && !executable_path.exist?) ||
// 469:            (!executable_path.absolute? && which(executable_path.to_s).nil?)
// 470:           message = "uninstall script #{executable} does not exist"
// 471:           raise CaskError, "#{message}." unless force
// 472:
// 473:           opoo "#{message}; skipping."
// 474:           return
// 475:         end
// 476:
// 477:         command.run(executable_path, **script_arguments)
// 478:         sleep 1
// 479:       end
// 480:
// 481:       sig { params(pkgs: String, command: T.class_of(SystemCommand), _kwargs: T.anything).void }
// 482:       def uninstall_pkgutil(*pkgs, command:, **_kwargs)
// 483:         ohai "Uninstalling packages with `sudo` (which may request your password)..."
// 484:         pkgs.each do |regex|
// 485:           ::Cask::Pkg.all_matching(regex, command).each do |pkg|
// 486:             puts pkg.package_id
// 487:             pkg.uninstall
// 488:           end
// 489:         end
// 490:       end
// 491:
// 492:       sig { params(paths: T.any(Pathname, String), command: T.class_of(SystemCommand), _kwargs: T.anything).void }
// 493:       def uninstall_delete(*paths, command:, **_kwargs)
// 494:         return if paths.empty?
// 495:
// 496:         ohai "Removing files:"
// 497:         each_resolved_path(:delete, paths) do |path, resolved_paths|
// 498:           puts path
// 499:           command.run!(
// 500:             "/usr/bin/xargs",
// 501:             args:  ["-0", "--", "/bin/rm", "-r", "-f", "--"],
// 502:             input: resolved_paths.join("\0"),
// 503:             sudo:  true,
// 504:           )
// 505:         end
// 506:       end
// 507:
// 508:       sig { params(paths: T.any(Pathname, String), options: T.anything).void }
// 509:       def uninstall_trash(*paths, **options)
// 510:         return if paths.empty?
// 511:
// 512:         resolved_paths = each_resolved_path(:trash, paths).to_a
// 513:
// 514:         ohai "Trashing files:", resolved_paths.map(&:first)
// 515:         trash_paths(*resolved_paths.flat_map(&:last), **options)
// 516:       end
// 517:
// 518:       sig {
// 519:         params(paths: Pathname, command: T.nilable(T.class_of(SystemCommand)), _kwargs: T.anything)
// 520:           .returns(T.nilable([T::Array[String], T::Array[String]]))
// 521:       }
// 522:       def trash_paths(*paths, command: nil, **_kwargs)
// 523:         return if paths.empty?
// 524:
// 525:         trashed, untrashable = ::Cask::Utils::Trash.trash(*paths, command:)
// 526:
// 527:         return trashed, untrashable if untrashable.empty?
// 528:
// 529:         opoo "The following files could not be trashed, please do so manually:"
// 530:         $stderr.puts untrashable
// 531:
// 532:         [trashed, untrashable]
// 533:       end
// 534:
// 535:       sig { params(directories: Pathname).returns(T::Boolean) }
// 536:       def all_dirs?(*directories)
// 537:         directories.all?(&:directory?)
// 538:       end
// 539:
// 540:       sig { params(directories: Pathname, command: T.class_of(SystemCommand), _kwargs: T.anything).void }
// 541:       def recursive_rmdir(*directories, command:, **_kwargs)
// 542:         directories.all? do |resolved_path|
// 543:           puts resolved_path.sub(Dir.home, "~")
// 544:
// 545:           if resolved_path.readable?
// 546:             children = resolved_path.children
// 547:
// 548:             next false unless children.all? { |child| child.directory? || child.basename.to_s == ".DS_Store" }
// 549:           else
// 550:             lines = command.run!("/bin/ls", args: ["-A", "-F", "--", resolved_path], sudo: true, print_stderr: false)
// 551:                            .stdout.lines.map(&:chomp)
// 552:                            .flat_map(&:chomp)
// 553:
// 554:             # Using `-F` above outputs directories ending with `/`.
// 555:             next false unless lines.all? { |l| l.end_with?("/") || l == ".DS_Store" }
// 556:
// 557:             children = lines.map { |l| resolved_path/l.delete_suffix("/") }
// 558:           end
// 559:
// 560:           # Directory counts as empty if it only contains a `.DS_Store`.
// 561:           if children.include?(ds_store = resolved_path/".DS_Store")
// 562:             Utils.gain_permissions_remove(ds_store, command:)
// 563:             children.delete(ds_store)
// 564:           end
// 565:
// 566:           next false unless recursive_rmdir(*children, command:)
// 567:
// 568:           begin
// 569:             Utils.gain_permissions_rmdir(resolved_path, command:)
// 570:           rescue Errno::ENOTEMPTY, ErrorDuringExecution
// 571:             next false
// 572:           end
// 573:
// 574:           true
// 575:         end
// 576:       end
// 577:
// 578:       sig { params(directories: T.any(Pathname, String), kwargs: T.anything).void }
// 579:       def uninstall_rmdir(*directories, **kwargs)
// 580:         return if directories.empty?
// 581:
// 582:         ohai "Removing directories if empty:"
// 583:
// 584:         each_resolved_path(:rmdir, directories) do |_path, resolved_paths|
// 585:           next unless resolved_paths.all?(&:directory?)
// 586:
// 587:           recursive_rmdir(*resolved_paths, **kwargs)
// 588:         end
// 589:       end
// 590:
// 591:       sig { params(target: Pathname).returns(T::Boolean) }
// 592:       def undeletable?(target)
// 593:         !target.parent.writable?
// 594:       end
// 595:     end
// 596:   end
// 597: end
// 598:
// 599: require "extend/os/cask/artifact/abstract_uninstall"
