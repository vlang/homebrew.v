module cask

import ruby
import os
import x.json2

// Translated from Homebrew/brew `cask/migrator.rb`.
// The original source is retained below to keep the translation auditable.
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

// Ruby attr_reader `attr_reader :old_cask, :new_cask` at line 13.
pub fn ruby_migrator_l13_d1_old_cask(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return migrator_nil()
	}
	return migrator_cask_value(migrator_from_value(args[0]).old_cask)
}

// Ruby attr_reader `attr_reader :old_cask, :new_cask` at line 13.
pub fn ruby_migrator_l13_d2_new_cask(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return migrator_nil()
	}
	return migrator_cask_value(migrator_from_value(args[0]).new_cask)
}

// Ruby method `initialize(old_cask, new_cask)` at line 16.
pub fn ruby_migrator_l16_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'Migrator#initialize requires two casks')
	}
	migrator := new_migrator(migrator_cask_from_value(args[0]), migrator_cask_from_value(args[1])) or {
		return ruby.object_value('Cask::CaskNotInstalledError', err.msg())
	}
	return migrator_value(migrator)
}

// Ruby method `self.old_tokens_needing_migration(new_cask, dry_run: false)` at line 26.
pub fn ruby_migrator_l26_d4_self_old_tokens_needing_migration(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.string_array_value([])
	}
	dry_run := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	return ruby.string_array_value(old_tokens_needing_migration(migrator_cask_from_value(args[0]), args[1].as_string(), dry_run))
}

// Ruby method `self.migrate_if_needed(new_cask, dry_run: false)` at line 46.
pub fn ruby_migrator_l46_d5_self_migrate_if_needed(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([])
	}
	new_cask := migrator_cask_from_value(args[0])
	root := args[1].as_string()
	dry_run := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	results := migrate_if_needed(new_cask, map[string]MigratorCask{}, root, dry_run)
	return ruby.array_value(results.map(migrator_result_value(it)))
}

// Ruby method `migrate(dry_run: false)` at line 55.
pub fn ruby_migrator_l55_d6_migrate(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return migrator_nil()
	}
	dry_run := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	result := migrator_from_value(args[0]).migrate(dry_run) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return migrator_result_value(result)
}

// Ruby method `self.replace_caskfile_token(path, old_token, new_token)` at line 68.
pub fn ruby_migrator_l68_d7_self_replace_caskfile_token(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'replace_caskfile_token requires path and tokens')
	}
	replace_caskfile_token(args[0].as_string(), args[1].as_string(), args[2].as_string()) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return migrator_nil()
}

// Ruby method `uninstall_old_cask(old_caskfile, dry_run:)` at line 84.
pub fn ruby_migrator_l84_d8_uninstall_old_cask(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'uninstall_old_cask requires a caskfile')
	}
	dry_run := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	result := migrator_from_value(args[0]).uninstall_old_cask(args[1].as_string(), dry_run) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return migrator_result_value(result)
}

// Ruby method `shared_with_new_cask?(artifact)` at line 124.
pub fn ruby_migrator_l124_d9_shared_with_new_cask(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(migrator_from_value(args[0]).shared_with_new_cask(migrator_artifact_from_value(args[1])))
}

// Ruby method `move_old_cask(old_caskfile, dry_run:)` at line 136.
pub fn ruby_migrator_l136_d10_move_old_cask(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'move_old_cask requires a caskfile')
	}
	dry_run := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	result := migrator_from_value(args[0]).move_old_cask(args[1].as_string(), dry_run) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return migrator_result_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/inreplace"
// 5: require "utils/output"
// 6:
// 7: module Cask
// 8:   class Migrator
// 9:     extend ::Utils::Output::Mixin
// 10:     include ::Utils::Output::Mixin
// 11:
// 12:     sig { returns(Cask) }
// 13:     attr_reader :old_cask, :new_cask
// 14:
// 15:     sig { params(old_cask: Cask, new_cask: Cask).void }
// 16:     def initialize(old_cask, new_cask)
// 17:       raise CaskNotInstalledError, new_cask unless new_cask.installed?
// 18:
// 19:       @old_cask = old_cask
// 20:       @new_cask = new_cask
// 21:     end
// 22:
// 23:     # The old tokens of `new_cask` that are still installed in their own Caskroom directory.
// 24:     # A symlinked directory means the cask has already been migrated.
// 25:     sig { params(new_cask: Cask, dry_run: T::Boolean).returns(T::Array[String]) }
// 26:     def self.old_tokens_needing_migration(new_cask, dry_run: false)
// 27:       new_cask.old_tokens
// 28:               .map { |old_token| Caskroom.token_from_full_token(old_token) }
// 29:               .uniq
// 30:               .select do |old_token|
// 31:         next false if old_token == new_cask.token
// 32:
// 33:         old_caskroom_path = Caskroom.path/old_token
// 34:         next false if old_caskroom_path.symlink? || !old_caskroom_path.directory?
// 35:
// 36:         if Caskroom.cask_installed_caskfile(old_token).nil?
// 37:           old_caskroom_path.rmdir_if_possible unless dry_run
// 38:           next false
// 39:         end
// 40:
// 41:         true
// 42:       end
// 43:     end
// 44:
// 45:     sig { params(new_cask: Cask, dry_run: T::Boolean).void }
// 46:     def self.migrate_if_needed(new_cask, dry_run: false)
// 47:       old_tokens_needing_migration(new_cask).each do |old_token|
// 48:         new(Cask.new(old_token), new_cask).migrate(dry_run:)
// 49:       rescue => e
// 50:         onoe e
// 51:       end
// 52:     end
// 53:
// 54:     sig { params(dry_run: T::Boolean).void }
// 55:     def migrate(dry_run: false)
// 56:       old_caskfile = old_cask.installed_caskfile
// 57:       return if old_caskfile.nil?
// 58:
// 59:       new_caskroom_path = new_cask.caskroom_path
// 60:       if new_caskroom_path.directory? && !new_caskroom_path.symlink?
// 61:         uninstall_old_cask(old_caskfile, dry_run:)
// 62:       else
// 63:         move_old_cask(old_caskfile, dry_run:)
// 64:       end
// 65:     end
// 66:
// 67:     sig { params(path: Pathname, old_token: String, new_token: String).void }
// 68:     def self.replace_caskfile_token(path, old_token, new_token)
// 69:       case path.extname
// 70:       when ".rb"
// 71:         ::Utils::Inreplace.inreplace path, /\A\s*cask\s+"#{Regexp.escape(old_token)}"/, "cask #{new_token.inspect}"
// 72:       when ".json"
// 73:         json = JSON.parse(path.read)
// 74:         json["token"] = new_token
// 75:         path.atomic_write json.to_json
// 76:       end
// 77:     end
// 78:
// 79:     private
// 80:
// 81:     # The new cask is already installed under its own token, so the old cask is a
// 82:     # separate installation that needs to be uninstalled rather than moved.
// 83:     sig { params(old_caskfile: Pathname, dry_run: T::Boolean).void }
// 84:     def uninstall_old_cask(old_caskfile, dry_run:)
// 85:       old_token = old_cask.token
// 86:       new_token = new_cask.token
// 87:
// 88:       old_caskroom_path = old_cask.caskroom_path
// 89:       new_caskroom_path = new_cask.caskroom_path
// 90:
// 91:       # Load the old cask from its own installed caskfile so that its artifacts (rather
// 92:       # than the artifacts of the cask it was renamed to) are the ones uninstalled.
// 93:       installed_old_cask = CaskLoader.load_from_installed_caskfile(old_caskfile)
// 94:       uninstallable, shared = installed_old_cask.artifacts.partition do |artifact|
// 95:         !shared_with_new_cask?(artifact)
// 96:       end
// 97:
// 98:       if dry_run
// 99:         oh1 "Would migrate cask #{Formatter.identifier(old_token)} to #{Formatter.identifier(new_token)}"
// 100:
// 101:         puts "#{new_token} is already installed, so #{old_token} would be uninstalled."
// 102:         shared.each { |artifact| puts "#{artifact} would be kept as #{new_token} installs it too." }
// 103:         puts "ln -s #{new_caskroom_path.basename} #{old_caskroom_path}"
// 104:         return
// 105:       end
// 106:
// 107:       oh1 "Migrating cask #{Formatter.identifier(old_token)} to #{Formatter.identifier(new_token)}"
// 108:       puts "#{new_token} is already installed, so #{old_token} will be uninstalled."
// 109:       shared.each { |artifact| puts "Keeping #{artifact} as #{new_token} installs it too." }
// 110:
// 111:       require "cask/installer"
// 112:
// 113:       installed_old_cask.unpin if installed_old_cask.pinned?
// 114:       Installer.new(installed_old_cask, force: true, verbose: Context.current.verbose?,
// 115:                     default_uninstall_artifacts: ArtifactSet.new(uninstallable)).uninstall
// 116:
// 117:       FileUtils.rm_rf old_caskroom_path
// 118:       FileUtils.ln_s new_caskroom_path.basename, old_caskroom_path
// 119:     end
// 120:
// 121:     # Artifacts the new cask installs too must be left alone: uninstalling them would
// 122:     # remove them from the new cask, which stays installed.
// 123:     sig { params(artifact: Artifact::AbstractArtifact).returns(T::Boolean) }
// 124:     def shared_with_new_cask?(artifact)
// 125:       new_cask.artifacts.any? do |new_artifact|
// 126:         if artifact.is_a?(Artifact::Relocated)
// 127:           # Compare the paths these end up at, which is all that matters on disk.
// 128:           new_artifact.is_a?(Artifact::Relocated) && new_artifact.target == artifact.target
// 129:         else
// 130:           new_artifact.instance_of?(artifact.class) && new_artifact.to_args == artifact.to_args
// 131:         end
// 132:       end
// 133:     end
// 134:
// 135:     sig { params(old_caskfile: Pathname, dry_run: T::Boolean).void }
// 136:     def move_old_cask(old_caskfile, dry_run:)
// 137:       old_token = old_cask.token
// 138:       new_token = new_cask.token
// 139:
// 140:       old_caskroom_path = old_cask.caskroom_path
// 141:       new_caskroom_path = new_cask.caskroom_path
// 142:
// 143:       old_installed_caskfile = old_caskfile.relative_path_from(old_caskroom_path)
// 144:       new_installed_caskfile = old_installed_caskfile.dirname/old_installed_caskfile.basename.sub(
// 145:         old_token,
// 146:         new_token,
// 147:       )
// 148:
// 149:       if dry_run
// 150:         oh1 "Would migrate cask #{Formatter.identifier(old_token)} to #{Formatter.identifier(new_token)}"
// 151:
// 152:         puts "rm #{new_caskroom_path}" if new_caskroom_path.symlink?
// 153:         puts "cp -r #{old_caskroom_path} #{new_caskroom_path}"
// 154:         puts "mv #{new_caskroom_path}/#{old_installed_caskfile} #{new_caskroom_path}/#{new_installed_caskfile}"
// 155:         puts "rm -r #{old_caskroom_path}"
// 156:         puts "ln -s #{new_caskroom_path.basename} #{old_caskroom_path}"
// 157:         if (old_pin_path = old_cask.pin_path).symlink? && (pinned_version = old_cask.pinned_version)
// 158:           new_pin_path = new_cask.pin_path
// 159:           puts "rm #{old_pin_path}"
// 160:           puts "ln -s #{(new_caskroom_path/pinned_version).relative_path_from(new_pin_path.dirname)} #{new_pin_path}"
// 161:         end
// 162:       else
// 163:         oh1 "Migrating cask #{Formatter.identifier(old_token)} to #{Formatter.identifier(new_token)}"
// 164:
// 165:         # An earlier rename migration era could leave the new token as an alias symlink
// 166:         # pointing at the old directory; remove it so the copy below cannot recurse
// 167:         # into its own source.
// 168:         FileUtils.rm new_caskroom_path if new_caskroom_path.symlink?
// 169:
// 170:         begin
// 171:           FileUtils.cp_r old_caskroom_path, new_caskroom_path
// 172:           FileUtils.mv new_caskroom_path/old_installed_caskfile, new_caskroom_path/new_installed_caskfile
// 173:           self.class.replace_caskfile_token(new_caskroom_path/new_installed_caskfile, old_token, new_token)
// 174:         rescue => e
// 175:           FileUtils.rm_rf new_caskroom_path
// 176:           raise e
// 177:         end
// 178:
// 179:         FileUtils.rm_r old_caskroom_path
// 180:         FileUtils.ln_s new_caskroom_path.basename, old_caskroom_path
// 181:         if old_cask.pin_path.symlink? && (pinned_version = old_cask.pinned_version)
// 182:           begin
// 183:             new_cask.pin_path.make_relative_symlink(new_caskroom_path/pinned_version)
// 184:             old_cask.unpin
// 185:           rescue => e
// 186:             opoo "Failed to migrate cask pin from #{old_token} to #{new_token}: #{e}"
// 187:           end
// 188:         end
// 189:       end
// 190:     end
// 191:   end
// 192: end
