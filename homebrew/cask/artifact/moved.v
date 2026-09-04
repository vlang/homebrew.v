module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/moved.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ArtifactCommand {
pub:
	executable   string
	args         []string
	sudo         bool
	sudo_as_root bool
}

pub type ArtifactCommandRunner = fn(ArtifactCommand) !bool

pub struct MovedArtifact {
pub:
	source           string
	target           string
	english_name     string = 'Artifact'
	printable_target string
}

pub struct MovedInstallOptions {
pub:
	adopt                  bool
	auto_updates           bool
	force                  bool
	verbose                bool
	predecessor_matches    bool
	successor_matches      bool
	reinstall              bool
	target_parent_writable bool = true
	target_app_management  bool
}

pub struct MovedUninstallOptions {
pub:
	skip                   bool
	force                  bool
	adopt                  bool
	successor_matches      bool
	source_parent_writable bool = true
	target_app_management  bool
}

pub struct MovedOperationResult {
pub mut:
	success          bool = true
	error            string
	output           []string
	warnings         []string
	commands         []ArtifactCommand
	moved            bool
	adopted          bool
	reused           bool
	restored         bool
	removed          []string
	altname_metadata string
}

fn default_artifact_command_runner(command ArtifactCommand) !bool {
	_ = command
	return true
}

fn moved_path_occupied(path string) bool {
	return os.exists(path) || os.is_link(path)
}

fn moved_remove_path(path string) ! {
	if os.is_link(path) || os.is_file(path) {
		os.rm(path)!
	} else if os.is_dir(path) {
		os.rmdir_all(path)!
	}
}

fn moved_copy_tree(source string, target string) ! {
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
			moved_copy_tree(source_entry, target_entry)!
		} else if os.is_link(source_entry) {
			os.symlink(os.readlink(source_entry)!, target_entry)!
		} else {
			os.cp(source_entry, target_entry)!
		}
	}
}

fn moved_collect_tree(root string, path string, mut entries []string) {
	for name in os.ls(path) or { return } {
		entry := os.join_path(path, name)
		relative := entry.trim_string_left(root).trim_left('/')
		if os.is_dir(entry) && !os.is_link(entry) {
			entries << '${relative}/'
			moved_collect_tree(root, entry, mut entries)
		} else if os.is_link(entry) {
			entries << '${relative}\0link:${os.readlink(entry) or { '' }}'
		} else {
			entries << '${relative}\0${os.read_file(entry) or { '' }}'
		}
	}
}

fn moved_sources_match(source string, target string) bool {
	if os.is_file(source) && os.is_file(target) {
		return os.read_bytes(source) or { return false } == os.read_bytes(target) or { return false }
	}
	if !os.is_dir(source) || !os.is_dir(target) {
		return false
	}
	mut source_entries := []string{}
	mut target_entries := []string{}
	moved_collect_tree(source, source, mut source_entries)
	moved_collect_tree(target, target, mut target_entries)
	source_entries.sort()
	target_entries.sort()
	return source_entries == target_entries
}

fn moved_run(command ArtifactCommand, runner ArtifactCommandRunner,
	mut result MovedOperationResult) bool {
	result.commands << command
	return runner(command) or {
		result.warnings << err.msg()
		false
	}
}

fn moved_link_resolves_to(source string, target string) bool {
	if !os.is_link(source) {
		return false
	}
	link := os.readlink(source) or { return false }
	resolved := if link.starts_with('/') { link } else { os.join_path(os.dir(source), link) }
	return os.real_path(resolved) == os.real_path(target)
}

fn moved_delete_target(artifact MovedArtifact, target string, successor_matches bool,
	target_app_management bool, mut result MovedOperationResult) ! {
	if !moved_path_occupied(target) {
		return
	}
	if os.is_dir(target) && successor_matches && target_app_management {
		for child in os.ls(target)! {
			child_path := os.join_path(target, child)
			moved_remove_path(child_path)!
			result.removed << child_path
		}
		return
	}
	moved_remove_path(target)!
	result.removed << target
	_ = artifact
}

pub fn moved_english_description(english_name string) string {
	return '${english_name}s'
}

pub fn moved_backup_copy_args(target string, source string) []string {
	return ['-pR', target, source]
}

pub fn moved_artifact_matches(candidate ?MovedArtifact, artifact MovedArtifact) bool {
	other := candidate or { return false }
	return other.target == artifact.target && other.english_name == artifact.english_name
}

pub fn moved_target_undeletable(target string) bool {
	return target != '' && !os.is_writable(os.dir(target))
}

pub fn post_move_artifact(artifact MovedArtifact, mut result MovedOperationResult) ! {
	if moved_path_occupied(artifact.source) {
		moved_remove_path(artifact.source)!
	}
	os.mkdir_all(os.dir(artifact.source))!
	os.symlink(artifact.target, artifact.source)!
	result.altname_metadata = os.file_name(artifact.source)
}

pub fn move_artifact_with_command(artifact MovedArtifact, options MovedInstallOptions,
	runner ArtifactCommandRunner) MovedOperationResult {
	mut result := MovedOperationResult{}
	if !os.exists(artifact.source) || os.is_link(artifact.source) {
		result.success = false
		result.error = "It seems the ${artifact.english_name} source '${artifact.source}' is not there."
		return result
	}
	mut reuse_target := false
	if moved_path_occupied(artifact.target) {
		if os.is_dir(artifact.target) && (os.ls(artifact.target) or { []string{} }).len == 0 && options.predecessor_matches {
			reuse_target = os.is_dir(artifact.source)
			if !reuse_target {
				moved_delete_target(artifact, artifact.target, options.successor_matches, options.target_app_management, mut result) or {
					result.success = false
					result.error = err.msg()
					return result
				}
			}
		} else if options.adopt {
			result.output << "Adopting existing ${artifact.english_name} at '${artifact.target}'"
			if !options.auto_updates && !moved_sources_match(artifact.source, artifact.target) {
				result.success = false
				result.error = 'It seems the existing ${artifact.english_name} is different from the one being installed.'
				return result
			}
			moved_remove_path(artifact.source) or {
				result.success = false
				result.error = err.msg()
				return result
			}
			post_move_artifact(artifact, mut result) or {
				result.success = false
				result.error = err.msg()
				return result
			}
			result.adopted = true
			return result
		} else if options.force {
			result.warnings << "It seems there is already a ${artifact.english_name} at '${artifact.target}'; overwriting."
			moved_delete_target(artifact, artifact.target, options.successor_matches, options.target_app_management, mut result) or {
				result.success = false
				result.error = err.msg()
				return result
			}
		} else {
			result.success = false
			result.error = "It seems there is already a ${artifact.english_name} at '${artifact.target}'."
			return result
		}
	}
	result.output << "Moving ${artifact.english_name} '${os.file_name(artifact.source)}' to '${artifact.target}'"
	os.mkdir_all(os.dir(artifact.target)) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	if reuse_target {
		for child in os.ls(artifact.source) or {
			result.success = false
			result.error = err.msg()
			return result
		} {
			os.mv(os.join_path(artifact.source, child), os.join_path(artifact.target, child)) or {
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
		result.reused = true
	} else if options.target_parent_writable {
		os.mv(artifact.source, artifact.target) or {
			result.success = false
			result.error = err.msg()
			return result
		}
	} else {
		if !moved_run(ArtifactCommand{
			executable: '/bin/cp'
			args: moved_backup_copy_args(artifact.source, artifact.target)
			sudo: true
		}, runner, mut result) {
			result.success = false
			result.error = 'Failed to copy ${artifact.source} to ${artifact.target}.'
			return result
		}
		moved_copy_tree(artifact.source, artifact.target) or {
			result.success = false
			result.error = err.msg()
			return result
		}
		moved_remove_path(artifact.source) or {
			result.success = false
			result.error = err.msg()
			return result
		}
	}
	post_move_artifact(artifact, mut result) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	result.moved = true
	return result
}

pub fn install_moved_artifact(artifact MovedArtifact,
	options MovedInstallOptions) MovedOperationResult {
	return move_artifact_with_command(artifact, options, default_artifact_command_runner)
}

pub fn move_back_artifact_with_command(artifact MovedArtifact,
	options MovedUninstallOptions, runner ArtifactCommandRunner) MovedOperationResult {
	mut result := MovedOperationResult{}
	if moved_link_resolves_to(artifact.source, artifact.target) {
		os.rm(artifact.source) or {
			result.success = false
			result.error = err.msg()
			return result
		}
	}
	if moved_path_occupied(artifact.source) {
		if !options.force && !options.adopt {
			result.success = false
			result.error = "It seems there is already a ${artifact.english_name} at '${artifact.source}'."
			return result
		}
		result.warnings << "It seems there is already a ${artifact.english_name} at '${artifact.source}'; overwriting."
		moved_remove_path(artifact.source) or {
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
		result.error = "It seems the ${artifact.english_name} source '${artifact.target}' is not there."
		return result
	}
	result.output << "Backing up ${artifact.english_name} '${os.file_name(artifact.target)}' to '${artifact.source}'"
	os.mkdir_all(os.dir(artifact.source)) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	mut copied := false
	mut sudo_attempts := if options.source_parent_writable {
		[false, true]
	} else {
		[
			true,
		]
	}
	for sudo in sudo_attempts {
		if moved_run(ArtifactCommand{
			executable: '/bin/cp'
			args: moved_backup_copy_args(artifact.target, artifact.source)
			sudo: sudo
		}, runner, mut result) {
			copied = true
			break
		}
	}
	if !copied {
		result.success = false
		result.error = 'Failed to back up ${artifact.target} to ${artifact.source}.'
		return result
	}
	moved_copy_tree(artifact.target, artifact.source) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	moved_delete_target(artifact, artifact.target, options.successor_matches, options.target_app_management, mut result) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	result.restored = true
	return result
}

pub fn uninstall_moved_artifact(artifact MovedArtifact,
	options MovedUninstallOptions) MovedOperationResult {
	return move_back_artifact_with_command(artifact, options, default_artifact_command_runner)
}

fn moved_path_size(path string) i64 {
	if os.is_file(path) {
		return os.file_size(path)
	}
	mut size := i64(0)
	for child in os.ls(path) or { return size } {
		size += moved_path_size(os.join_path(path, child))
	}
	return size
}

pub fn summarize_installed_moved(artifact MovedArtifact) string {
	printable := if artifact.printable_target == '' {
		artifact.target
	} else {
		artifact.printable_target
	}
	if os.exists(artifact.target) {
		return '${printable} (${moved_path_size(artifact.target)}B)'
	}
	return 'Missing ${artifact.english_name}: ${printable}'
}

pub fn moved_artifact_to_value(artifact MovedArtifact) ruby.Value {
	return ruby.map_value({
		'source':           ruby.string_value(artifact.source)
		'target':           ruby.string_value(artifact.target)
		'english_name':     ruby.string_value(artifact.english_name)
		'printable_target': ruby.string_value(artifact.printable_target)
	})
}

fn moved_artifact_from_value(value ruby.Value) !MovedArtifact {
	values := value.as_map()!
	return MovedArtifact{
		source: (values['source'] or { return error('Moved source is required') }).as_string()
		target: (values['target'] or { return error('Moved target is required') }).as_string()
		english_name: (values['english_name'] or { ruby.string_value('Artifact') }).as_string()
		printable_target: (values['printable_target'] or { ruby.string_value('') }).as_string()
	}
}

pub fn moved_operation_to_value(result MovedOperationResult) ruby.Value {
	return ruby.map_value({
		'success':          ruby.bool_value(result.success)
		'error':            ruby.string_value(result.error)
		'output':           ruby.string_array_value(result.output)
		'warnings':         ruby.string_array_value(result.warnings)
		'moved':            ruby.bool_value(result.moved)
		'adopted':          ruby.bool_value(result.adopted)
		'reused':           ruby.bool_value(result.reused)
		'restored':         ruby.bool_value(result.restored)
		'removed':          ruby.string_array_value(result.removed)
		'altname_metadata': ruby.string_value(result.altname_metadata)
		'commands':         ruby.array_value(result.commands.map(ruby.map_value({
			'executable':   ruby.string_value(it.executable)
			'args':         ruby.string_array_value(it.args)
			'sudo':         ruby.bool_value(it.sudo)
			'sudo_as_root': ruby.bool_value(it.sudo_as_root)
		})))
	})
}

fn moved_install_options_from_value(value ruby.Value) MovedInstallOptions {
	values := value.as_map() or { return MovedInstallOptions{} }
	return MovedInstallOptions{
		adopt: value_bool(values, 'adopt', false)
		auto_updates: value_bool(values, 'auto_updates', false)
		force: value_bool(values, 'force', false)
		verbose: value_bool(values, 'verbose', false)
		predecessor_matches: value_bool(values, 'predecessor_matches', false)
		successor_matches: value_bool(values, 'successor_matches', false)
		reinstall: value_bool(values, 'reinstall', false)
		target_parent_writable: value_bool(values, 'target_parent_writable', true)
		target_app_management: value_bool(values, 'target_app_management', false)
	}
}

fn moved_uninstall_options_from_value(value ruby.Value) MovedUninstallOptions {
	values := value.as_map() or { return MovedUninstallOptions{} }
	return MovedUninstallOptions{
		skip: value_bool(values, 'skip', false)
		force: value_bool(values, 'force', false)
		adopt: value_bool(values, 'adopt', false)
		successor_matches: value_bool(values, 'successor_matches', false)
		source_parent_writable: value_bool(values, 'source_parent_writable', true)
		target_app_management: value_bool(values, 'target_app_management', false)
	}
}

fn moved_adapter_artifact(args []ruby.Value) !MovedArtifact {
	if args.len == 0 {
		return error('Moved artifact is required')
	}
	return moved_artifact_from_value(args[0])
}

// Ruby method `self.english_description` at line 12.
pub fn ruby_moved_l12_d1_self_english_description(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'Artifact' }
	return ruby.string_value(moved_english_description(name))
}

// Ruby method `install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,` at line 28.
pub fn ruby_moved_l28_d2_install_phase(args ...ruby.Value) ruby.Value {
	artifact := moved_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	options := if args.len > 1 {
		moved_install_options_from_value(args[1])
	} else {
		MovedInstallOptions{}
	}
	return moved_operation_to_value(install_moved_artifact(artifact, options))
}

// Ruby method `uninstall_phase(skip: false, force: false, adopt: false, verbose: false, successor: nil, upgrade: false,` at line 45.
pub fn ruby_moved_l45_d3_uninstall_phase(args ...ruby.Value) ruby.Value {
	artifact := moved_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	options := if args.len > 1 {
		moved_uninstall_options_from_value(args[1])
	} else {
		MovedUninstallOptions{}
	}
	return moved_operation_to_value(uninstall_moved_artifact(artifact, options))
}

// Ruby method `summarize_installed` at line 51.
pub fn ruby_moved_l51_d4_summarize_installed(args ...ruby.Value) ruby.Value {
	artifact := moved_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return ruby.string_value(summarize_installed_moved(artifact))
}

// Ruby method `backup_copy_args(target, source)` at line 60.
pub fn ruby_moved_l60_d5_backup_copy_args(args ...ruby.Value) ruby.Value {
	target := if args.len > 0 { args[0].as_string() } else { '' }
	source := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.string_array_value(moved_backup_copy_args(target, source))
}

// Ruby method `move(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil, successor: nil,` at line 78.
pub fn ruby_moved_l78_d6_move(args ...ruby.Value) ruby.Value {
	return ruby_moved_l28_d2_install_phase(...args)
}

// Ruby method `post_move(command)` at line 176.
pub fn ruby_moved_l176_d7_post_move(args ...ruby.Value) ruby.Value {
	artifact := moved_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	mut result := MovedOperationResult{}
	post_move_artifact(artifact, mut result) or {
		return ruby.object_value('CaskError', err.msg())
	}
	return moved_operation_to_value(result)
}

// Ruby method `matching_artifact?(cask)` at line 183.
pub fn ruby_moved_l183_d8_matching_artifact(args ...ruby.Value) ruby.Value {
	artifact := moved_adapter_artifact(args) or { return ruby.bool_value(false) }
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	candidate := moved_artifact_from_value(args[1]) or { return ruby.bool_value(false) }
	return ruby.bool_value(moved_artifact_matches(candidate, artifact))
}

// Ruby method `move_back(skip: false, force: false, adopt: false, command: SystemCommand, successor: nil)` at line 200.
pub fn ruby_moved_l200_d9_move_back(args ...ruby.Value) ruby.Value {
	return ruby_moved_l45_d3_uninstall_phase(...args)
}

// Ruby method `delete(target, force: false, successor: nil, command: SystemCommand)` at line 244.
pub fn ruby_moved_l244_d10_delete(args ...ruby.Value) ruby.Value {
	artifact := moved_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	target := if args.len > 1 { args[1].as_string() } else { artifact.target }
	options := if args.len > 2 {
		moved_uninstall_options_from_value(args[2])
	} else {
		MovedUninstallOptions{}
	}
	mut result := MovedOperationResult{}
	if moved_target_undeletable(target) {
		return ruby.object_value('CaskError', 'Cannot remove undeletable ${artifact.english_name}.')
	}
	moved_delete_target(artifact, target, options.successor_matches, options.target_app_management, mut result) or { return ruby.object_value('CaskError', err.msg()) }
	return moved_operation_to_value(result)
}

// Ruby method `undeletable?(target)` at line 264.
pub fn ruby_moved_l264_d11_undeletable(args ...ruby.Value) ruby.Value {
	target := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.bool_value(moved_target_undeletable(target))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/relocated"
// 5: require "cask/quarantine"
// 6:
// 7: module Cask
// 8:   module Artifact
// 9:     # Superclass for all artifacts that are installed by moving them to the target location.
// 10:     class Moved < Relocated
// 11:       sig { returns(String) }
// 12:       def self.english_description
// 13:         "#{english_name}s"
// 14:       end
// 15:
// 16:       sig {
// 17:         overridable.params(
// 18:           adopt:        T::Boolean,
// 19:           auto_updates: T.nilable(T::Boolean),
// 20:           force:        T::Boolean,
// 21:           verbose:      T::Boolean,
// 22:           predecessor:  T.nilable(Cask),
// 23:           successor:    T.nilable(Cask),
// 24:           reinstall:    T::Boolean,
// 25:           command:      T.class_of(SystemCommand),
// 26:         ).void
// 27:       }
// 28:       def install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,
// 29:                         successor: nil, reinstall: false, command: SystemCommand)
// 30:         move(adopt:, auto_updates:, force:, verbose:, predecessor:, successor:, reinstall:, command:)
// 31:       end
// 32:
// 33:       sig {
// 34:         overridable.params(
// 35:           skip:      T::Boolean,
// 36:           force:     T::Boolean,
// 37:           adopt:     T::Boolean,
// 38:           verbose:   T::Boolean,
// 39:           successor: T.nilable(Cask),
// 40:           upgrade:   T::Boolean,
// 41:           reinstall: T::Boolean,
// 42:           command:   T.class_of(SystemCommand),
// 43:         ).void
// 44:       }
// 45:       def uninstall_phase(skip: false, force: false, adopt: false, verbose: false, successor: nil, upgrade: false,
// 46:                           reinstall: false, command: SystemCommand)
// 47:         move_back(skip:, force:, adopt:, successor:, command:)
// 48:       end
// 49:
// 50:       sig { returns(String) }
// 51:       def summarize_installed
// 52:         if target.exist?
// 53:           "#{printable_target} (#{target.abv})"
// 54:         else
// 55:           Formatter.error(printable_target, label: "Missing #{self.class.english_name}")
// 56:         end
// 57:       end
// 58:
// 59:       sig { overridable.params(target: Pathname, source: Pathname).returns(T::Array[T.any(String, Pathname)]) }
// 60:       def backup_copy_args(target, source)
// 61:         ["-pR", target, source]
// 62:       end
// 63:
// 64:       private
// 65:
// 66:       sig {
// 67:         params(
// 68:           adopt:        T::Boolean,
// 69:           auto_updates: T.nilable(T::Boolean),
// 70:           force:        T::Boolean,
// 71:           verbose:      T::Boolean,
// 72:           predecessor:  T.nilable(Cask),
// 73:           successor:    T.nilable(Cask),
// 74:           reinstall:    T::Boolean,
// 75:           command:      T.class_of(SystemCommand),
// 76:         ).returns(T.nilable(SystemCommand::Result))
// 77:       }
// 78:       def move(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil, successor: nil,
// 79:                reinstall: false, command: SystemCommand)
// 80:         unless source.exist?
// 81:           raise CaskError, "It seems the #{self.class.english_name} source '#{source}' is not there."
// 82:         end
// 83:
// 84:         if Utils.path_occupied?(target)
// 85:           if target.directory? && target.children.empty? && matching_artifact?(predecessor)
// 86:             # An upgrade removed the directory contents but left the directory itself (see below).
// 87:             unless source.directory?
// 88:               if target.parent.writable? && !force
// 89:                 target.rmdir
// 90:               else
// 91:                 Utils.gain_permissions_remove(target, command:)
// 92:               end
// 93:             end
// 94:           else
// 95:             if adopt
// 96:               ohai "Adopting existing #{self.class.english_name} at '#{target}'"
// 97:
// 98:               unless auto_updates
// 99:                 source_plist = Pathname("#{source}/Contents/Info.plist")
// 100:                 target_plist = Pathname("#{target}/Contents/Info.plist")
// 101:                 same = if source_plist.size? &&
// 102:                           (source_bundle_version = Homebrew::BundleVersion.from_info_plist(source_plist)) &&
// 103:                           target_plist.size? &&
// 104:                           (target_bundle_version = Homebrew::BundleVersion.from_info_plist(target_plist))
// 105:                   if source_bundle_version.short_version == target_bundle_version.short_version
// 106:                     if source_bundle_version.version == target_bundle_version.version
// 107:                       true
// 108:                     else
// 109:                       onoe "The bundle version of #{source} is #{source_bundle_version.version} but " \
// 110:                            "is #{target_bundle_version.version} for #{target}!"
// 111:                       false
// 112:                     end
// 113:                   else
// 114:                     onoe "The bundle short version of #{source} is #{source_bundle_version.short_version} but " \
// 115:                          "is #{target_bundle_version.short_version} for #{target}!"
// 116:                     false
// 117:                   end
// 118:                 else
// 119:                   command.run(
// 120:                     "/usr/bin/diff",
// 121:                     args:         ["--recursive", "--brief", source, target],
// 122:                     verbose:,
// 123:                     print_stdout: verbose,
// 124:                   ).success?
// 125:                 end
// 126:
// 127:                 unless same
// 128:                   raise CaskError,
// 129:                         "It seems the existing #{self.class.english_name} is different from " \
// 130:                         "the one being installed."
// 131:                 end
// 132:               end
// 133:
// 134:               # Remove the source as we don't need to move it to the target location
// 135:               FileUtils.rm_r(source)
// 136:
// 137:               return post_move(command)
// 138:             end
// 139:
// 140:             message = "It seems there is already #{self.class.english_article} " \
// 141:                       "#{self.class.english_name} at '#{target}'"
// 142:             raise CaskError, "#{message}." if !force && !adopt
// 143:
// 144:             opoo "#{message}; overwriting."
// 145:             delete(target, force:, successor:, command:)
// 146:           end
// 147:         end
// 148:
// 149:         ohai "Moving #{self.class.english_name} '#{source.basename}' to '#{target}'"
// 150:
// 151:         Utils.gain_permissions_mkpath(target.dirname, command:) unless target.dirname.exist?
// 152:
// 153:         if target.directory? && Quarantine.app_management_permissions_granted?(app: target, command:)
// 154:           if target.writable?
// 155:             source.children.each { |child| FileUtils.move(child, target/child.basename) }
// 156:           else
// 157:             command.run!("/bin/cp", args: ["-pR", *source.children, target],
// 158:                                     sudo: true)
// 159:           end
// 160:           Quarantine.copy_xattrs(source, target, command:)
// 161:           FileUtils.rm_r(source)
// 162:         elsif target.dirname.writable?
// 163:           FileUtils.move(source, target)
// 164:         else
// 165:           # default sudo user isn't necessarily able to write to Homebrew's locations
// 166:           # e.g. with runas_default set in the sudoers (5) file.
// 167:           command.run!("/bin/cp", args: ["-pR", source, target], sudo: true)
// 168:           FileUtils.rm_r(source)
// 169:         end
// 170:
// 171:         post_move(command)
// 172:       end
// 173:
// 174:       # Performs any actions necessary after the source has been moved to the target location.
// 175:       sig { params(command: T.class_of(SystemCommand)).returns(T.nilable(SystemCommand::Result)) }
// 176:       def post_move(command)
// 177:         FileUtils.ln_sf target, source
// 178:
// 179:         add_altname_metadata(target, source.basename, command:)
// 180:       end
// 181:
// 182:       sig { params(cask: T.nilable(Cask)).returns(T::Boolean) }
// 183:       def matching_artifact?(cask)
// 184:         return false unless cask
// 185:
// 186:         cask.artifacts.any? do |a|
// 187:           a.instance_of?(self.class) && instance_of?(a.class) && a.target == target
// 188:         end
// 189:       end
// 190:
// 191:       sig {
// 192:         params(
// 193:           skip:      T::Boolean,
// 194:           force:     T::Boolean,
// 195:           adopt:     T::Boolean,
// 196:           command:   T.class_of(SystemCommand),
// 197:           successor: T.nilable(Cask),
// 198:         ).void
// 199:       }
// 200:       def move_back(skip: false, force: false, adopt: false, command: SystemCommand, successor: nil)
// 201:         FileUtils.rm source if source.symlink? && source.dirname.join(source.readlink) == target
// 202:
// 203:         if Utils.path_occupied?(source)
// 204:           message = "It seems there is already #{self.class.english_article} " \
// 205:                     "#{self.class.english_name} at '#{source}'"
// 206:           raise CaskError, "#{message}." if !force && !adopt
// 207:
// 208:           opoo "#{message}; overwriting."
// 209:           delete(source, force:, successor:, command:)
// 210:         end
// 211:
// 212:         unless target.exist?
// 213:           return if skip || force
// 214:
// 215:           raise CaskError, "It seems the #{self.class.english_name} source '#{target}' is not there."
// 216:         end
// 217:
// 218:         ohai "Backing up #{self.class.english_name} '#{target.basename}' to '#{source}'"
// 219:         source.dirname.mkpath
// 220:
// 221:         # We need to preserve extended attributes between copies.
// 222:         # This may fail and need sudo if the source has files with restricted permissions.
// 223:         [!source.parent.writable?, true].uniq.each do |sudo|
// 224:           result = command.run(
// 225:             "/bin/cp",
// 226:             args:         backup_copy_args(target, source),
// 227:             must_succeed: sudo,
// 228:             sudo:,
// 229:           )
// 230:           break if result.success?
// 231:         end
// 232:
// 233:         delete(target, force:, successor:, command:)
// 234:       end
// 235:
// 236:       sig {
// 237:         params(
// 238:           target:    Pathname,
// 239:           force:     T::Boolean,
// 240:           successor: T.nilable(Cask),
// 241:           command:   T.class_of(SystemCommand),
// 242:         ).void
// 243:       }
// 244:       def delete(target, force: false, successor: nil, command: SystemCommand)
// 245:         ohai "Removing #{self.class.english_name} '#{target}'"
// 246:         raise CaskError, "Cannot remove undeletable #{self.class.english_name}." if undeletable?(target)
// 247:
// 248:         return unless Utils.path_occupied?(target)
// 249:
// 250:         if target.directory? && matching_artifact?(successor) && Quarantine.app_management_permissions_granted?(
// 251:           app: target, command:,
// 252:         )
// 253:           # If an app folder is deleted, macOS considers the app uninstalled and removes some data.
// 254:           # Remove only the contents to handle this case.
// 255:           target.children.each do |child|
// 256:             Utils.gain_permissions_remove(child, command:)
// 257:           end
// 258:         else
// 259:           Utils.gain_permissions_remove(target, command:)
// 260:         end
// 261:       end
// 262:
// 263:       sig { params(target: Pathname).returns(T::Boolean) }
// 264:       def undeletable?(target)
// 265:         !target.parent.writable?
// 266:       end
// 267:     end
// 268:   end
// 269: end
// 270:
// 271: require "extend/os/cask/artifact/moved"
