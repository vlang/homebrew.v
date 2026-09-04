module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/app.rb`.
pub struct AppArtifact {
pub:
	source string
	target string
}

pub struct AppCommand {
pub:
	executable string
	args       []string
	sudo       bool
}

pub type AppCommandRunner = fn (AppCommand) !

pub struct AppInstallOptions {
pub:
	adopt               bool
	auto_updates        bool
	force               bool
	predecessor_matches bool
	reinstall           bool
	system_directory    bool
	target_writable     bool = true
}

pub struct AppUninstallOptions {
pub:
	force                bool
	skip                 bool
	successor_matches    bool
	preserve_directory   bool
	root_owned           bool
	modification_blocked bool
}

pub struct AppOperationResult {
pub:
	success     bool
	error       string
	stdout      string
	stderr      string
	commands    []AppCommand
	adopted     bool
	overwritten bool
	reused      bool
	backed_up   bool
}

pub struct AppReinstallResult {
pub:
	success     bool
	reused      bool
	uninstalled bool
	reinstalled bool
	commands    []AppCommand
}

fn app_default_command_runner(command AppCommand) ! {
	_ = command
}

fn app_path_occupied(path string) bool {
	return os.exists(path) || os.is_link(path)
}

fn app_target_in_system_directory(target string) bool {
	normalized := target.trim_string_right('/')
	for directory in ['/Applications', '/Library', '/System'] {
		if normalized == directory || normalized.starts_with('${directory}/') {
			return true
		}
	}
	return false
}

fn app_remove_path(path string) ! {
	if os.is_link(path) || os.is_file(path) {
		os.rm(path)!
	} else if os.is_dir(path) {
		os.rmdir_all(path)!
	}
}

fn app_copy_tree(source string, target string) ! {
	if os.is_file(source) {
		os.mkdir_all(os.dir(target))!
		os.cp(source, target)!
		return
	}
	os.mkdir_all(target)!
	for entry in os.ls(source)! {
		source_entry := os.join_path(source, entry)
		target_entry := os.join_path(target, entry)
		if os.is_dir(source_entry) && !os.is_link(source_entry) {
			app_copy_tree(source_entry, target_entry)!
		} else if os.is_link(source_entry) {
			link_target := os.readlink(source_entry)!
			os.symlink(link_target, target_entry)!
		} else {
			os.cp(source_entry, target_entry)!
		}
	}
}

fn app_collect_entries(root string, path string, mut entries []string) {
	for name in os.ls(path) or { return } {
		entry := os.join_path(path, name)
		relative := entry.trim_string_left(root).trim_left('/')
		if os.is_dir(entry) && !os.is_link(entry) {
			entries << '${relative}/'
			app_collect_entries(root, entry, mut entries)
		} else if os.is_link(entry) {
			entries << '${relative}\x00link:${os.readlink(entry) or { '' }}'
		} else {
			contents := os.read_file(entry) or { '' }
			entries << '${relative}\x00${contents}'
		}
	}
}

fn app_directory_entries(path string) []string {
	mut entries := []string{}
	if !os.is_dir(path) {
		return entries
	}
	app_collect_entries(path, path, mut entries)
	entries.sort()
	return entries
}

fn app_sources_match(source string, target string) bool {
	return os.is_dir(source) && os.is_dir(target) && app_directory_entries(source) == app_directory_entries(target)
}

fn app_link_source(artifact AppArtifact) ! {
	if app_path_occupied(artifact.source) {
		app_remove_path(artifact.source)!
	}
	os.mkdir_all(os.dir(artifact.source))!
	os.symlink(artifact.target, artifact.source)!
}

fn app_move_into_target(artifact AppArtifact, reuse bool) ! {
	os.mkdir_all(os.dir(artifact.target))!
	if reuse {
		for entry in os.ls(artifact.source)! {
			os.mv(os.join_path(artifact.source, entry), os.join_path(artifact.target, entry))!
		}
		os.rmdir(artifact.source)!
	} else {
		os.mv(artifact.source, artifact.target)!
	}
	app_link_source(artifact)!
}

pub fn install_app_with_command(artifact AppArtifact, options AppInstallOptions,
	runner AppCommandRunner) AppOperationResult {
	if !os.exists(artifact.source) || os.is_link(artifact.source) {
		return AppOperationResult{
			error: "It seems the App source '${artifact.source}' is not there."
		}
	}
	mut output := ''
	mut warning := ''
	mut adopted := false
	mut overwritten := false
	mut reused := false
	if app_path_occupied(artifact.target) {
		if os.is_dir(artifact.target) && (os.ls(artifact.target) or { []string{} }).len == 0 && options.predecessor_matches {
			reused = true
		} else if options.adopt {
			output += "==> Adopting existing App at '${artifact.target}'\n"
			if !options.auto_updates && !app_sources_match(artifact.source, artifact.target) {
				return AppOperationResult{
					error: 'It seems the existing App is different from the one being installed.'
					stdout: output
				}
			}
			app_remove_path(artifact.source) or {
				return AppOperationResult{
					error: err.msg()
					stdout: output
				}
			}
			app_link_source(artifact) or {
				return AppOperationResult{
					error: err.msg()
					stdout: output
				}
			}
			adopted = true
		} else if options.force {
			warning = "Warning: It seems there is already an App at '${artifact.target}'; overwriting.\n"
			output += "==> Removing App '${artifact.target}'\n"
			app_remove_path(artifact.target) or {
				return AppOperationResult{
					error: err.msg()
					stdout: output
					stderr: warning
				}
			}
			overwritten = true
		} else {
			return AppOperationResult{
				error: "It seems there is already an App at '${artifact.target}'."
			}
		}
	}
	if !adopted {
		output += "==> Moving App '${os.file_name(artifact.source)}' to '${artifact.target}'\n"
		app_move_into_target(artifact, reused) or {
			return AppOperationResult{
				error: err.msg()
				stdout: output
				stderr: warning
			}
		}
	}
	mut commands := []AppCommand{}
	if options.system_directory || app_target_in_system_directory(artifact.target) {
		command := AppCommand{
			executable: 'chmod'
			args: ['-R', 'a+rX', artifact.target]
			sudo: !options.target_writable
		}
		commands << command
		runner(command) or {
			return AppOperationResult{
				error: err.msg()
				stdout: output
				stderr: warning
				commands: commands
				adopted: adopted
				overwritten: overwritten
				reused: reused
			}
		}
	}
	return AppOperationResult{
		success: true
		stdout: output
		stderr: warning
		commands: commands
		adopted: adopted
		overwritten: overwritten
		reused: reused
	}
}

pub fn install_app(artifact AppArtifact, options AppInstallOptions) AppOperationResult {
	return install_app_with_command(artifact, options, app_default_command_runner)
}

pub fn app_backup_copy_args(target string, source string, clone_supported bool,
	same_filesystem bool) []string {
	mut args := []string{}
	if clone_supported && same_filesystem {
		args << '-c'
	}
	args << '-pR'
	args << target
	args << source
	return args
}

pub fn uninstall_app(artifact AppArtifact, options AppUninstallOptions) AppOperationResult {
	if os.is_link(artifact.source) {
		os.rm(artifact.source) or {
			return AppOperationResult{
				error: err.msg()
			}
		}
	}
	if !os.exists(artifact.target) {
		if options.skip || options.force {
			return AppOperationResult{
				success: true
			}
		}
		return AppOperationResult{
			error: "It seems the App source '${artifact.target}' is not there."
		}
	}
	mut commands := []AppCommand{}
	if options.root_owned {
		commands << AppCommand{
			executable: '/bin/cp'
			args: app_backup_copy_args(artifact.target, artifact.source, false, true)
			sudo: true
		}
	}
	app_copy_tree(artifact.target, artifact.source) or {
		return AppOperationResult{
			error: err.msg()
			commands: commands
		}
	}
	if options.successor_matches && options.preserve_directory && !options.modification_blocked {
		entries := os.ls(artifact.target) or {
			return AppOperationResult{
				error: err.msg()
				commands: commands
			}
		}
		for entry in entries {
			app_remove_path(os.join_path(artifact.target, entry)) or {
				return AppOperationResult{
					error: err.msg()
					commands: commands
				}
			}
		}
	} else {
		app_remove_path(artifact.target) or {
			return AppOperationResult{
				error: err.msg()
				commands: commands
			}
		}
	}
	return AppOperationResult{
		success: true
		stdout: "==> Backing up App '${os.file_name(artifact.target)}' to '${artifact.source}'\n==> Removing App '${artifact.target}'\n"
		commands: commands
		backed_up: true
		reused: options.successor_matches && options.preserve_directory && !options.modification_blocked
	}
}

fn app_abbreviated_path(path string) string {
	home := os.home_dir().trim_string_right('/')
	if path == home {
		return '~'
	}
	if path.starts_with('${home}/') {
		return '~/${path[home.len + 1..]}'
	}
	return path
}

pub fn summarize_installed_app(artifact AppArtifact) string {
	if os.exists(artifact.target) {
		return '${artifact.target} (${app_abbreviated_path(artifact.target)})'
	}
	return 'Error: Missing App: ${artifact.target}'
}

pub fn reinstall_app(artifact AppArtifact, preserve_directory bool, root_owned bool,
	modification_blocked bool) AppReinstallResult {
	uninstall_result := uninstall_app(artifact, AppUninstallOptions{
		force: true
		successor_matches: true
		preserve_directory: preserve_directory
		root_owned: root_owned
		modification_blocked: modification_blocked
	})
	if !uninstall_result.success {
		return AppReinstallResult{}
	}
	install_result := install_app(artifact, AppInstallOptions{
		predecessor_matches: true
	})
	return AppReinstallResult{
		success: install_result.success
		reused: install_result.reused
		uninstalled: uninstall_result.success
		reinstalled: install_result.success
		commands: uninstall_result.commands
	}
}

pub fn app_artifact_value(artifact AppArtifact) ruby.Value {
	return ruby.structured_value('Cask::Artifact::App', artifact.source, {
		'source': artifact.source
		'target': artifact.target
	})
}

pub fn app_artifact_from_value(value ruby.Value) AppArtifact {
	return AppArtifact{
		source: value.attributes['source'] or { value.as_string() }
		target: value.attributes['target'] or { '' }
	}
}

pub fn app_operation_value(result AppOperationResult) ruby.Value {
	return ruby.map_value({
		'success':     ruby.bool_value(result.success)
		'error':       ruby.string_value(result.error)
		'stdout':      ruby.string_value(result.stdout)
		'stderr':      ruby.string_value(result.stderr)
		'adopted':     ruby.bool_value(result.adopted)
		'overwritten': ruby.bool_value(result.overwritten)
		'reused':      ruby.bool_value(result.reused)
		'commands':    ruby.string_array_value(result.commands.map('${it.executable} ${it.args.join(' ')} sudo=${it.sudo}'))
	})
}
