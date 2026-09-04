module cask

import ruby
import os
import x.json2

// Translated from Homebrew/brew `cask/migrator.rb`.
pub struct MigratorArtifact {
pub:
	class_name string
	arguments  []string
	target     string
	relocated  bool
	display    string
	path       string
}

pub struct MigratorCask {
pub:
	token              string
	old_tokens         []string
	installed          bool
	caskroom_path      string
	installed_caskfile string
	pin_path           string
	pinned_version     string
	artifacts          []MigratorArtifact
}

pub struct Migrator {
pub:
	old_cask MigratorCask
	new_cask MigratorCask
}

pub struct MigratorResult {
pub:
	action             string
	dry_run            bool
	migrated           bool
	shared             []MigratorArtifact
	uninstallable      []MigratorArtifact
	stdout             []string
	warnings           []string
	errors             []string
	old_pin_removed    bool
	new_pin_created    bool
	new_installed_file string
}

fn migrator_nil() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn migrator_artifact_value(artifact MigratorArtifact) ruby.Value {
	return ruby.Value{
		type_name: artifact.class_name
		repr: if artifact.display != '' { artifact.display } else { artifact.arguments.join(', ') }
		map_data: {
			'arguments': ruby.string_array_value(artifact.arguments)
			'target':    ruby.string_value(artifact.target)
			'relocated': ruby.bool_value(artifact.relocated)
			'path':      ruby.object_value('Pathname', artifact.path)
		}
		attributes: {
			'class_name': artifact.class_name
		}
	}
}

fn migrator_artifact_from_value(value ruby.Value) MigratorArtifact {
	arguments := (value.map_data['arguments'] or { ruby.string_array_value([]) }).as_string_array() or {
		[]string{}
	}
	return MigratorArtifact{
		class_name: value.attributes['class_name'] or { value.type_name }
		arguments: arguments
		target: (value.map_data['target'] or { ruby.string_value('') }).as_string()
		relocated: (value.map_data['relocated'] or { ruby.bool_value(false) }).as_bool() or {
			false
		}
		display: value.as_string()
		path: (value.map_data['path'] or { ruby.string_value('') }).as_string()
	}
}

pub fn migrator_cask_value(cask MigratorCask) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: cask.token
		map_data: {
			'token':              ruby.string_value(cask.token)
			'old_tokens':         ruby.string_array_value(cask.old_tokens)
			'installed':          ruby.bool_value(cask.installed)
			'caskroom_path':      ruby.object_value('Pathname', cask.caskroom_path)
			'installed_caskfile': if cask.installed_caskfile == '' {
				migrator_nil()
			} else {
				ruby.object_value('Pathname', cask.installed_caskfile)
			}
			'pin_path':           ruby.object_value('Pathname', cask.pin_path)
			'pinned_version':     if cask.pinned_version == '' {
				migrator_nil()
			} else {
				ruby.string_value(cask.pinned_version)
			}
			'artifacts':          ruby.array_value(cask.artifacts.map(migrator_artifact_value(it)))
		}
	}
}

pub fn migrator_cask_from_value(value ruby.Value) MigratorCask {
	artifact_values := (value.map_data['artifacts'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	return MigratorCask{
		token: (value.map_data['token'] or { ruby.string_value(value.as_string()) }).as_string()
		old_tokens: (value.map_data['old_tokens'] or { ruby.string_array_value([]) }).as_string_array() or {
			[]string{}
		}
		installed: (value.map_data['installed'] or { ruby.bool_value(false) }).as_bool() or {
			false
		}
		caskroom_path: (value.map_data['caskroom_path'] or { ruby.string_value('') }).as_string()
		installed_caskfile: (value.map_data['installed_caskfile'] or { ruby.string_value('') }).as_string()
		pin_path: (value.map_data['pin_path'] or { ruby.string_value('') }).as_string()
		pinned_version: (value.map_data['pinned_version'] or { ruby.string_value('') }).as_string()
		artifacts: artifact_values.map(migrator_artifact_from_value(it))
	}
}

pub fn migrator_value(migrator Migrator) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Migrator'
		repr: '${migrator.old_cask.token} -> ${migrator.new_cask.token}'
		map_data: {
			'old_cask': migrator_cask_value(migrator.old_cask)
			'new_cask': migrator_cask_value(migrator.new_cask)
		}
	}
}

fn migrator_from_value(value ruby.Value) Migrator {
	return Migrator{
		old_cask: migrator_cask_from_value(value.map_data['old_cask'] or { ruby.Value{} })
		new_cask: migrator_cask_from_value(value.map_data['new_cask'] or { ruby.Value{} })
	}
}

fn migrator_result_value(result MigratorResult) ruby.Value {
	return ruby.Value{
		type_name: 'Hash'
		repr: result.action
		map_data: {
			'action':             ruby.string_value(result.action)
			'dry_run':            ruby.bool_value(result.dry_run)
			'migrated':           ruby.bool_value(result.migrated)
			'shared':             ruby.array_value(result.shared.map(migrator_artifact_value(it)))
			'uninstallable':      ruby.array_value(result.uninstallable.map(migrator_artifact_value(it)))
			'stdout':             ruby.string_array_value(result.stdout)
			'warnings':           ruby.string_array_value(result.warnings)
			'errors':             ruby.string_array_value(result.errors)
			'old_pin_removed':    ruby.bool_value(result.old_pin_removed)
			'new_pin_created':    ruby.bool_value(result.new_pin_created)
			'new_installed_file': ruby.object_value('Pathname', result.new_installed_file)
		}
	}
}

pub fn new_migrator(old_cask MigratorCask, new_cask MigratorCask) !Migrator {
	if !new_cask.installed {
		return error('Cask ${new_cask.token} is not installed.')
	}
	return Migrator{
		old_cask: old_cask
		new_cask: new_cask
	}
}

fn migrator_remove_path(path string) ! {
	if path == '' || (!os.exists(path) && !os.is_link(path)) {
		return
	}
	if os.is_dir(path) && !os.is_link(path) {
		os.rmdir_all(path)!
	} else {
		os.rm(path)!
	}
}

fn migrator_copy_tree(source string, destination string) ! {
	if os.is_file(source) {
		os.mkdir_all(os.dir(destination))!
		os.cp(source, destination)!
		return
	}
	os.mkdir_all(destination)!
	for name in os.ls(source)! {
		from := os.join_path(source, name)
		to := os.join_path(destination, name)
		if os.is_dir(from) && !os.is_link(from) {
			migrator_copy_tree(from, to)!
		} else if os.is_link(from) {
			os.symlink(os.readlink(from)!, to)!
		} else {
			os.cp(from, to)!
		}
	}
}

pub fn migrator_relative_path(target string, directory string) string {
	target_parts := os.norm_path(os.abs_path(target)).trim_left(os.path_separator).split(os.path_separator)
	directory_parts := os.norm_path(os.abs_path(directory)).trim_left(os.path_separator).split(os.path_separator)
	mut common := 0
	for common < target_parts.len && common < directory_parts.len && target_parts[common] == directory_parts[common] {
		common++
	}
	mut parts := []string{}
	for _ in common .. directory_parts.len {
		parts << '..'
	}
	parts << target_parts[common..]
	return if parts.len == 0 { '.' } else { parts.join(os.path_separator) }
}

fn migrator_installed_caskfile(root string, token string) ?string {
	return caskroom_installed_caskfile(root, token, []string{})
}

// The old tokens of `new_cask` that are still installed in their own Caskroom directory.
// A symlinked directory means the cask has already been migrated.
pub fn old_tokens_needing_migration(new_cask MigratorCask, caskroom_root string,
	dry_run bool) []string {
	mut result := []string{}
	mut seen := map[string]bool{}
	for full_token in new_cask.old_tokens {
		old_token := caskroom_token_from_full_token(full_token)
		if old_token in seen {
			continue
		}
		seen[old_token] = true
		if old_token == new_cask.token {
			continue
		}
		old_path := os.join_path(caskroom_root, old_token)
		if os.is_link(old_path) || !os.is_dir(old_path) {
			continue
		}
		if migrator_installed_caskfile(caskroom_root, old_token) == none {
			if !dry_run && (os.ls(old_path) or { []string{} }).len == 0 {
				os.rmdir(old_path) or {}
			}
			continue
		}
		result << old_token
	}
	return result
}

pub fn replace_caskfile_token(path string, old_token string, new_token string) ! {
	match os.file_ext(path) {
		'.rb' {
			contents := os.read_file(path)!
			trimmed := contents.trim_left(' \t\r\n')
			prefix := 'cask "${old_token}"'
			if trimmed.starts_with(prefix) {
				leading_length := contents.len - trimmed.len
				replaced := contents[..leading_length] + 'cask "${new_token}"' + trimmed[prefix.len..]
				ruby.atomic_write_file(path, replaced)!
			}
		}
		'.json' {
			decoded := json2.decode[json2.Any](os.read_file(path)!)!
			if decoded !is map[string]json2.Any {
				return error('expected a JSON object in ${path}')
			}
			mut values := decoded.as_map()
			values['token'] = json2.Any(new_token)
			ruby.atomic_write_file(path, json2.encode(json2.Any(values)))!
		}
		else {}
	}
}

// Artifacts the new cask installs too must be left alone: uninstalling them would
// remove them from the new cask, which stays installed.
pub fn (migrator Migrator) shared_with_new_cask(artifact MigratorArtifact) bool {
	for new_artifact in migrator.new_cask.artifacts {
		if artifact.relocated {
			if new_artifact.relocated && new_artifact.target == artifact.target {
				return true
			}
		} else if new_artifact.class_name == artifact.class_name && new_artifact.arguments == artifact.arguments {
			return true
		}
	}
	return false
}

// The new cask is already installed under its own token, so the old cask is a
// separate installation that needs to be uninstalled rather than moved.
pub fn (migrator Migrator) uninstall_old_cask(old_caskfile string,
	dry_run bool) !MigratorResult {
	if old_caskfile == '' {
		return error('installed caskfile is required')
	}
	mut shared_artifacts := []MigratorArtifact{}
	mut uninstallable := []MigratorArtifact{}
	for artifact in migrator.old_cask.artifacts {
		if migrator.shared_with_new_cask(artifact) {
			shared_artifacts << artifact
		} else {
			uninstallable << artifact
		}
	}
	verb := if dry_run { 'Would migrate' } else { 'Migrating' }
	mut output := [
		'${verb} cask ${migrator.old_cask.token} to ${migrator.new_cask.token}',
	]
	if dry_run {
		output << '${migrator.new_cask.token} is already installed, so ${migrator.old_cask.token} would be uninstalled.'
		for artifact in shared_artifacts {
			output << '${artifact.display} would be kept as ${migrator.new_cask.token} installs it too.'
		}
		output << 'ln -s ${os.base(migrator.new_cask.caskroom_path)} ${migrator.old_cask.caskroom_path}'
		return MigratorResult{
			action: 'uninstall'
			dry_run: true
			shared: shared_artifacts
			uninstallable: uninstallable
			stdout: output
		}
	}
	output << '${migrator.new_cask.token} is already installed, so ${migrator.old_cask.token} will be uninstalled.'
	for artifact in shared_artifacts {
		output << 'Keeping ${artifact.display} as ${migrator.new_cask.token} installs it too.'
	}
	mut old_pin_removed := false
	if os.is_link(migrator.old_cask.pin_path) {
		os.rm(migrator.old_cask.pin_path)!
		old_pin_removed = true
	}
	output << '==> Uninstalling Cask ${migrator.old_cask.token}'
	for artifact in uninstallable {
		migrator_remove_path(artifact.path)!
	}
	migrator_remove_path(migrator.old_cask.caskroom_path)!
	os.symlink(os.base(migrator.new_cask.caskroom_path), migrator.old_cask.caskroom_path)!
	return MigratorResult{
		action: 'uninstall'
		migrated: true
		shared: shared_artifacts
		uninstallable: uninstallable
		stdout: output
		old_pin_removed: old_pin_removed
	}
}

pub fn (migrator Migrator) move_old_cask(old_caskfile string,
	dry_run bool) !MigratorResult {
	old_relative := migrator_relative_path(old_caskfile, migrator.old_cask.caskroom_path)
	new_basename := os.base(old_relative).replace_once(migrator.old_cask.token, migrator.new_cask.token)
	new_relative := os.join_path(os.dir(old_relative), new_basename)
	new_caskfile := os.join_path(migrator.new_cask.caskroom_path, new_relative)
	mut output := []string{}
	mut warnings := []string{}
	if dry_run {
		output << 'Would migrate cask ${migrator.old_cask.token} to ${migrator.new_cask.token}'
		if os.is_link(migrator.new_cask.caskroom_path) {
			output << 'rm ${migrator.new_cask.caskroom_path}'
		}
		output << 'cp -r ${migrator.old_cask.caskroom_path} ${migrator.new_cask.caskroom_path}'
		output << 'mv ${os.join_path(migrator.new_cask.caskroom_path, old_relative)} ${new_caskfile}'
		output << 'rm -r ${migrator.old_cask.caskroom_path}'
		output << 'ln -s ${os.base(migrator.new_cask.caskroom_path)} ${migrator.old_cask.caskroom_path}'
		if os.is_link(migrator.old_cask.pin_path) && migrator.old_cask.pinned_version != '' {
			target := os.join_path(migrator.new_cask.caskroom_path, migrator.old_cask.pinned_version)
			output << 'rm ${migrator.old_cask.pin_path}'
			output << 'ln -s ${migrator_relative_path(target, os.dir(migrator.new_cask.pin_path))} ${migrator.new_cask.pin_path}'
		}
		return MigratorResult{
			action: 'move'
			dry_run: true
			stdout: output
			new_installed_file: new_caskfile
		}
	}
	output << 'Migrating cask ${migrator.old_cask.token} to ${migrator.new_cask.token}'
	if os.is_link(migrator.new_cask.caskroom_path) {
		os.rm(migrator.new_cask.caskroom_path)!
	}
	migrator_copy_tree(migrator.old_cask.caskroom_path, migrator.new_cask.caskroom_path) or {
		migrator_remove_path(migrator.new_cask.caskroom_path) or {}
		return err
	}
	old_copied_caskfile := os.join_path(migrator.new_cask.caskroom_path, old_relative)
	os.mkdir_all(os.dir(new_caskfile)) or {
		migrator_remove_path(migrator.new_cask.caskroom_path) or {}
		return err
	}
	os.mv(old_copied_caskfile, new_caskfile) or {
		migrator_remove_path(migrator.new_cask.caskroom_path) or {}
		return err
	}
	replace_caskfile_token(new_caskfile, migrator.old_cask.token, migrator.new_cask.token) or {
		migrator_remove_path(migrator.new_cask.caskroom_path) or {}
		return err
	}
	migrator_remove_path(migrator.old_cask.caskroom_path)!
	os.symlink(os.base(migrator.new_cask.caskroom_path), migrator.old_cask.caskroom_path)!
	mut old_pin_removed := false
	mut new_pin_created := false
	if os.is_link(migrator.old_cask.pin_path) && migrator.old_cask.pinned_version != '' {
		target := os.join_path(migrator.new_cask.caskroom_path, migrator.old_cask.pinned_version)
		os.mkdir_all(os.dir(migrator.new_cask.pin_path)) or {
			warnings << 'Failed to migrate cask pin from ${migrator.old_cask.token} to ${migrator.new_cask.token}: ${err}'
		}
		if warnings.len == 0 {
			os.symlink(migrator_relative_path(target, os.dir(migrator.new_cask.pin_path)), migrator.new_cask.pin_path) or {
				warnings << 'Failed to migrate cask pin from ${migrator.old_cask.token} to ${migrator.new_cask.token}: ${err}'
			}
		}
		if warnings.len == 0 {
			new_pin_created = true
			os.rm(migrator.old_cask.pin_path)!
			old_pin_removed = true
		}
	}
	return MigratorResult{
		action: 'move'
		migrated: true
		stdout: output
		warnings: warnings
		old_pin_removed: old_pin_removed
		new_pin_created: new_pin_created
		new_installed_file: new_caskfile
	}
}

pub fn (migrator Migrator) migrate(dry_run bool) !MigratorResult {
	if migrator.old_cask.installed_caskfile == '' {
		return MigratorResult{
			action: 'none'
			dry_run: dry_run
		}
	}
	if os.is_dir(migrator.new_cask.caskroom_path) && !os.is_link(migrator.new_cask.caskroom_path) {
		return migrator.uninstall_old_cask(migrator.old_cask.installed_caskfile, dry_run)
	}
	return migrator.move_old_cask(migrator.old_cask.installed_caskfile, dry_run)
}

pub fn migrate_if_needed(new_cask MigratorCask, old_casks map[string]MigratorCask,
	caskroom_root string, dry_run bool) []MigratorResult {
	mut results := []MigratorResult{}
	// Ruby deliberately computes this list without forwarding `dry_run`.
	for old_token in old_tokens_needing_migration(new_cask, caskroom_root, false) {
		old_cask := old_casks[old_token] or {
			MigratorCask{
				token: old_token
				installed: true
				caskroom_path: os.join_path(caskroom_root, old_token)
				installed_caskfile: migrator_installed_caskfile(caskroom_root, old_token) or { '' }
			}
		}
		migrator := new_migrator(old_cask, new_cask) or {
			results << MigratorResult{
				action: 'error'
				errors: [err.msg()]
			}
			continue
		}
		result := migrator.migrate(dry_run) or {
			results << MigratorResult{
				action: 'error'
				errors: [err.msg()]
			}
			continue
		}
		results << result
	}
	return results
}
