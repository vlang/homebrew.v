module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/abstract_uninstall.rb`.
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

pub type UninstallCommandRunner = fn (UninstallCommand) !bool

pub type UninstallGlobber = fn (string) ![]string

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
			input: entry.paths.join('\x00')
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
