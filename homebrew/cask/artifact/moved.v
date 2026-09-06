module artifact

import os

// Translated from Homebrew/brew `cask/artifact/moved.rb`.
pub struct ArtifactCommand {
pub:
	executable   string
	args         []string
	sudo         bool
	sudo_as_root bool
}

pub type ArtifactCommandRunner = fn (ArtifactCommand) !bool

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
			entries << '${relative}\x00link:${os.readlink(entry) or { '' }}'
		} else {
			entries << '${relative}\x00${os.read_file(entry) or { '' }}'
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
