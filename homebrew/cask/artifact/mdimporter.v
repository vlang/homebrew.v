module artifact

import brew_runtime
import os

// Translated from Homebrew/brew `cask/artifact/mdimporter.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct MdimporterArtifact {
pub:
	source string
	target string
}

pub struct MdimporterCommand {
pub:
	executable string
	args       []string
	sudo       bool
}

pub type MdimporterCommandRunner = fn(MdimporterCommand) !bool

pub struct MdimporterInstallOptions {
pub:
	adopt               bool
	auto_updates        bool
	force               bool
	verbose             bool
	predecessor_matches bool
	reinstall           bool
	target_writable     bool = true
}

pub struct MdimporterUninstallOptions {
pub:
	skip  bool
	force bool
	adopt bool
}

pub struct MdimporterOperationResult {
pub mut:
	success   bool = true
	error     string
	commands  []MdimporterCommand
	moved     bool
	adopted   bool
	restored  bool
	refreshed bool
}

fn default_mdimporter_runner(command MdimporterCommand) !bool {
	_ = command
	return true
}

fn mdimporter_path_occupied(path string) bool {
	return os.exists(path) || os.is_link(path)
}

fn remove_mdimporter_path(path string) ! {
	if os.is_link(path) || os.is_file(path) {
		os.rm(path)!
	} else if os.is_dir(path) {
		os.rmdir_all(path)!
	}
}

fn copy_mdimporter_tree(source string, target string) ! {
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
			copy_mdimporter_tree(source_entry, target_entry)!
		} else if os.is_link(source_entry) {
			os.symlink(os.readlink(source_entry)!, target_entry)!
		} else {
			os.cp(source_entry, target_entry)!
		}
	}
}

fn collect_mdimporter_tree(root string, path string, mut entries []string) {
	for name in os.ls(path) or { return } {
		entry := os.join_path(path, name)
		relative := entry.trim_string_left(root).trim_left('/')
		if os.is_dir(entry) && !os.is_link(entry) {
			entries << '${relative}/'
			collect_mdimporter_tree(root, entry, mut entries)
		} else if os.is_link(entry) {
			entries << '${relative}\0link:${os.readlink(entry) or { '' }}'
		} else {
			entries << '${relative}\0${os.read_file(entry) or { '' }}'
		}
	}
}

fn mdimporter_sources_match(source string, target string) bool {
	if os.is_file(source) && os.is_file(target) {
		return os.read_bytes(source) or { return false } == os.read_bytes(target) or { return false }
	}
	if !os.is_dir(source) || !os.is_dir(target) {
		return false
	}
	mut source_entries := []string{}
	mut target_entries := []string{}
	collect_mdimporter_tree(source, source, mut source_entries)
	collect_mdimporter_tree(target, target, mut target_entries)
	source_entries.sort()
	target_entries.sort()
	return source_entries == target_entries
}

fn mdimporter_run(command MdimporterCommand, runner MdimporterCommandRunner,
	mut result MdimporterOperationResult) bool {
	result.commands << command
	succeeded := runner(command) or {
		result.success = false
		result.error = err.msg()
		return false
	}
	if !succeeded {
		result.success = false
		result.error = 'Command failed: ${command.executable}'
	}
	return succeeded
}

pub fn reload_spotlight_with_command(artifact MdimporterArtifact,
	runner MdimporterCommandRunner, mut result MdimporterOperationResult) {
	succeeded := mdimporter_run(MdimporterCommand{
		executable: '/usr/bin/mdimport'
		args: ['-r', artifact.target]
	}, runner, mut result)
	result.refreshed = succeeded
}

pub fn install_mdimporter_with_command(artifact MdimporterArtifact,
	options MdimporterInstallOptions, runner MdimporterCommandRunner) MdimporterOperationResult {
	mut result := MdimporterOperationResult{}
	if !os.exists(artifact.source) || os.is_link(artifact.source) {
		result.success = false
		result.error = "It seems the Spotlight metadata importer source '${artifact.source}' is not there."
		return result
	}
	mut reuse_target := false
	if mdimporter_path_occupied(artifact.target) {
		if os.is_dir(artifact.target) && (os.ls(artifact.target) or { []string{} }).len == 0 && options.predecessor_matches {
			reuse_target = os.is_dir(artifact.source)
			if !reuse_target {
				remove_mdimporter_path(artifact.target) or {
					result.success = false
					result.error = err.msg()
					return result
				}
			}
		} else if options.adopt {
			if !options.auto_updates && !mdimporter_sources_match(artifact.source, artifact.target) {
				result.success = false
				result.error = 'It seems the existing Spotlight metadata importer is different from the one being installed.'
				return result
			}
			remove_mdimporter_path(artifact.source) or {
				result.success = false
				result.error = err.msg()
				return result
			}
			os.symlink(artifact.target, artifact.source) or {
				result.success = false
				result.error = err.msg()
				return result
			}
			result.adopted = true
			reload_spotlight_with_command(artifact, runner, mut result)
			return result
		} else if options.force {
			remove_mdimporter_path(artifact.target) or {
				result.success = false
				result.error = err.msg()
				return result
			}
		} else {
			result.success = false
			result.error = "It seems there is already a Spotlight metadata importer at '${artifact.target}'."
			return result
		}
	}
	os.mkdir_all(os.dir(artifact.target)) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	if reuse_target {
		for entry in os.ls(artifact.source) or {
			result.success = false
			result.error = err.msg()
			return result
		} {
			os.mv(os.join_path(artifact.source, entry), os.join_path(artifact.target, entry)) or {
				result.success = false
				result.error = err.msg()
				return result
			}
		}
		os.rmdir(artifact.source) or {
			result.success = false
			result.error = err.msg()
			return result
		}
	} else if options.target_writable {
		os.mv(artifact.source, artifact.target) or {
			result.success = false
			result.error = err.msg()
			return result
		}
	} else {
		if !mdimporter_run(MdimporterCommand{
			executable: '/bin/cp'
			args: ['-pR', artifact.source, artifact.target]
			sudo: true
		}, runner, mut result) {
			return result
		}
		copy_mdimporter_tree(artifact.source, artifact.target) or {
			result.success = false
			result.error = err.msg()
			return result
		}
		remove_mdimporter_path(artifact.source) or {
			result.success = false
			result.error = err.msg()
			return result
		}
	}
	os.symlink(artifact.target, artifact.source) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	result.moved = true
	reload_spotlight_with_command(artifact, runner, mut result)
	return result
}

pub fn install_mdimporter(artifact MdimporterArtifact,
	options MdimporterInstallOptions) MdimporterOperationResult {
	return install_mdimporter_with_command(artifact, options, default_mdimporter_runner)
}

pub fn uninstall_mdimporter_with_command(artifact MdimporterArtifact,
	options MdimporterUninstallOptions, runner MdimporterCommandRunner) MdimporterOperationResult {
	mut result := MdimporterOperationResult{}
	if os.is_link(artifact.source) && os.readlink(artifact.source) or { '' } == artifact.target {
		os.rm(artifact.source) or {
			result.success = false
			result.error = err.msg()
			return result
		}
	}
	if mdimporter_path_occupied(artifact.source) {
		if !options.force && !options.adopt {
			result.success = false
			result.error = "It seems there is already a Spotlight metadata importer at '${artifact.source}'."
			return result
		}
		remove_mdimporter_path(artifact.source) or {
			result.success = false
			result.error = err.msg()
			return result
		}
	}
	if !os.exists(artifact.target) {
		if options.skip || options.force {
			return result
		}
		result.success = false
		result.error = "It seems the Spotlight metadata importer source '${artifact.target}' is not there."
		return result
	}
	os.mkdir_all(os.dir(artifact.source)) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	if !mdimporter_run(MdimporterCommand{
		executable: '/bin/cp'
		args: ['-pR', artifact.target, artifact.source]
	}, runner, mut result) {
		return result
	}
	copy_mdimporter_tree(artifact.target, artifact.source) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	remove_mdimporter_path(artifact.target) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	result.restored = true
	return result
}

pub fn uninstall_mdimporter(artifact MdimporterArtifact,
	options MdimporterUninstallOptions) MdimporterOperationResult {
	return uninstall_mdimporter_with_command(artifact, options, default_mdimporter_runner)
}

pub fn summarize_installed_mdimporter(artifact MdimporterArtifact) string {
	if os.exists(artifact.target) {
		return artifact.target
	}
	return 'Missing Spotlight metadata importer: ${artifact.target}'
}

pub fn mdimporter_artifact_to_value(artifact MdimporterArtifact) brew_runtime.Value {
	return brew_runtime.map_value({
		'source': brew_runtime.string_value(artifact.source)
		'target': brew_runtime.string_value(artifact.target)
	})
}

fn mdimporter_artifact_from_value(value brew_runtime.Value) !MdimporterArtifact {
	values := value.as_map()!
	return MdimporterArtifact{
		source: (values['source'] or { return error('Mdimporter source is required') }).as_string()
		target: (values['target'] or { return error('Mdimporter target is required') }).as_string()
	}
}

pub fn mdimporter_operation_to_value(result MdimporterOperationResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'success':   brew_runtime.bool_value(result.success)
		'error':     brew_runtime.string_value(result.error)
		'moved':     brew_runtime.bool_value(result.moved)
		'adopted':   brew_runtime.bool_value(result.adopted)
		'restored':  brew_runtime.bool_value(result.restored)
		'refreshed': brew_runtime.bool_value(result.refreshed)
		'commands':  brew_runtime.array_value(result.commands.map(brew_runtime.map_value({
			'executable': brew_runtime.string_value(it.executable)
			'args':       brew_runtime.string_array_value(it.args)
			'sudo':       brew_runtime.bool_value(it.sudo)
		})))
	})
}

fn mdimporter_install_options_from_value(value brew_runtime.Value) MdimporterInstallOptions {
	values := value.as_map() or { return MdimporterInstallOptions{} }
	return MdimporterInstallOptions{
		adopt: value_bool(values, 'adopt', false)
		auto_updates: value_bool(values, 'auto_updates', false)
		force: value_bool(values, 'force', false)
		verbose: value_bool(values, 'verbose', false)
		predecessor_matches: value_bool(values, 'predecessor_matches', false)
		reinstall: value_bool(values, 'reinstall', false)
		target_writable: value_bool(values, 'target_writable', true)
	}
}

// Ruby method `self.english_name` at line 11.
pub fn ruby_mdimporter_l11_d1_self_english_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('Spotlight metadata importer')
}

// Ruby method `install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,` at line 27.
pub fn ruby_mdimporter_l27_d2_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'Mdimporter artifact is required')
	}
	artifact := mdimporter_artifact_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	options := if args.len > 1 {
		mdimporter_install_options_from_value(args[1])
	} else {
		MdimporterInstallOptions{}
	}
	return mdimporter_operation_to_value(install_mdimporter(artifact, options))
}

// Ruby method `reload_spotlight(command:, **_options)` at line 36.
pub fn ruby_mdimporter_l36_d3_reload_spotlight(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'Mdimporter artifact is required')
	}
	artifact := mdimporter_artifact_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	mut result := MdimporterOperationResult{}
	reload_spotlight_with_command(artifact, default_mdimporter_runner, mut result)
	return mdimporter_operation_to_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/moved"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `mdimporter` stanza.
// 9:     class Mdimporter < Moved
// 10:       sig { override.returns(String) }
// 11:       def self.english_name
// 12:         "Spotlight metadata importer"
// 13:       end
// 14:
// 15:       sig {
// 16:         override.params(
// 17:           adopt:        T::Boolean,
// 18:           auto_updates: T.nilable(T::Boolean),
// 19:           force:        T::Boolean,
// 20:           verbose:      T::Boolean,
// 21:           predecessor:  T.nilable(Cask),
// 22:           reinstall:    T::Boolean,
// 23:           command:      T.class_of(SystemCommand),
// 24:           options:      T.anything,
// 25:         ).void
// 26:       }
// 27:       def install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,
// 28:                         reinstall: false, command: SystemCommand, **options)
// 29:         super
// 30:         reload_spotlight(command:, **options)
// 31:       end
// 32:
// 33:       private
// 34:
// 35:       sig { params(command: T.class_of(SystemCommand), _options: T.anything).void }
// 36:       def reload_spotlight(command:, **_options)
// 37:         command.run!("/usr/bin/mdimport", args: ["-r", target])
// 38:       end
// 39:     end
// 40:   end
// 41: end
