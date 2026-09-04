module homebrew

import ruby
import json2
import os

// Translated from Homebrew/brew `migrator.rb`.
pub struct MigratorFormulaInfo {
pub:
	name           string
	tap            string
	path           string
	rack           string
	oldnames       []string
	keg_only       bool
	outdated       bool
	tap_migrations map[string]string
}

pub struct MigratorConfig {
pub:
	cellar      string
	prefix      string
	pinned_kegs string
	linked_kegs string
	locks_dir   string
	force       bool
}

pub struct Migrator {
pub:
	formula            MigratorFormulaInfo
	oldname            string
	newname            string
	old_cellar         string
	new_cellar         string
	new_cellar_existed bool
	old_pin_record     string
	new_pin_record     string
	old_tap            string
	cellar             string
	prefix             string
	pinned_kegs        string
	linked_kegs        string
	locks_dir          string
pub mut:
	old_pin_link_record   string
	old_opt_records       []string
	old_linked_kegs       []string
	old_full_linked_kegs  []string
	old_tabs              []Tab
	new_linked_keg_record string
	pinned                bool
	newname_lock          LockFile
	oldname_lock          LockFile
	output                []string
}

pub struct MigratorRunResult {
pub mut:
	migrated []string
	output   []string
	errors   []string
}

fn migrator_nil_value() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

pub fn migrator_migration_needed_message(oldname string, newname string) string {
	return '${oldname} was renamed to ${newname} and needs to be migrated by running:\n  brew migrate ${oldname}\n'
}

pub fn migrator_no_oldpath_message(cellar string, oldname string) string {
	return "${os.join_path(cellar, oldname)} doesn't exist."
}

pub fn migrator_different_taps_message(formula MigratorFormulaInfo, oldname string,
	old_tap string) string {
	mut instruction := ''
	if old_tap == 'homebrew/core' {
		instruction = 'Please try to use ${oldname} to refer to the formula.\n'
	} else if old_tap != '' {
		instruction = 'Please try to use fully-qualified ${old_tap}/${oldname} to refer to the formula.\n'
	}
	installed_from := if old_tap == '' { 'path or url' } else { old_tap }
	return '${formula.name} from ${formula.tap} is given, but old name ${oldname} was installed from ${installed_from}.\n${instruction}To force migration, run:\n  brew migrate --force ${oldname}\n'
}

fn migrator_subdirs(path string) []string {
	mut result := []string{}
	for entry in os.ls(path) or { return result } {
		child := os.join_path(path, entry)
		if os.is_dir(child) && !os.is_link(child) {
			result << child
		}
	}
	result.sort()
	return result
}

fn migrator_relative_path(target string, directory string) string {
	target_parts := os.real_path(target).trim_right('/').trim_left('/').split('/')
	directory_parts := os.real_path(directory).trim_right('/').trim_left('/').split('/')
	mut common := 0
	for common < target_parts.len && common < directory_parts.len && target_parts[common] == directory_parts[common] {
		common++
	}
	mut parts := []string{}
	for _ in common .. directory_parts.len {
		parts << '..'
	}
	parts << target_parts[common..]
	return if parts.len == 0 { '.' } else { parts.join('/') }
}

fn migrator_make_relative_symlink(link string, target string) ! {
	if os.is_link(link) || os.exists(link) {
		if os.is_dir(link) && !os.is_link(link) {
			os.rmdir_all(link)!
		} else {
			os.rm(link)!
		}
	}
	os.mkdir_all(os.dir(link))!
	os.symlink(migrator_relative_path(target, os.dir(link)), link)!
}

fn migrator_same_path(left string, right string) bool {
	return os.real_path(left).trim_right('/') == os.real_path(right).trim_right('/')
}

fn migrator_tap_user(tap string) string {
	return tap.all_before('/')
}

pub fn migrator_oldnames_needing_migration(formula MigratorFormulaInfo, cellar string) []string {
	mut result := []string{}
	for oldname in formula.oldnames {
		rack := os.join_path(cellar, oldname)
		if !os.is_link(rack) && os.is_dir(rack) {
			result << oldname
		}
	}
	return result
}

pub fn migrator_needs_migration(formula MigratorFormulaInfo, cellar string) bool {
	return migrator_oldnames_needing_migration(formula, cellar).len > 0
}

pub fn new_migrator(formula MigratorFormulaInfo, oldname string, config MigratorConfig) !Migrator {
	old_cellar := os.join_path(config.cellar, oldname)
	if !os.exists(old_cellar) {
		return error(migrator_no_oldpath_message(config.cellar, oldname))
	}
	mut old_tabs := []Tab{}
	for keg_path in migrator_subdirs(old_cellar) {
		if tab := tab_for_keg(keg_path) {
			old_tabs << tab
		}
	}
	old_tap := if old_tabs.len > 0 { old_tabs[0].tap_name() } else { '' }
	mut migrator := Migrator{
		formula: formula
		oldname: oldname
		newname: formula.name
		old_cellar: old_cellar
		new_cellar: os.join_path(config.cellar, formula.name)
		new_cellar_existed: os.exists(os.join_path(config.cellar, formula.name))
		old_pin_record: os.join_path(config.pinned_kegs, oldname)
		new_pin_record: os.join_path(config.pinned_kegs, formula.name)
		old_tabs: old_tabs
		old_tap: old_tap
		cellar: config.cellar
		prefix: config.prefix
		pinned_kegs: config.pinned_kegs
		linked_kegs: config.linked_kegs
		locks_dir: config.locks_dir
		newname_lock: new_lock_file('formula', os.join_path(config.cellar, formula.name), config.locks_dir)
		oldname_lock: new_lock_file('formula', old_cellar, config.locks_dir)
	}
	if !config.force && !migrator.from_same_tap_user()! {
		return error(migrator_different_taps_message(formula, oldname, old_tap))
	}
	for rack in [migrator.new_cellar, migrator.old_cellar] {
		for keg_path in migrator_subdirs(rack) {
			keg := new_keg_with_paths(keg_path, config.cellar, config.prefix) or { continue }
			if keg.linked() || keg.optlinked() {
				migrator.old_linked_kegs << keg_path
				if keg.linked() {
					migrator.old_full_linked_kegs << keg_path
				}
				if keg.optlinked() {
					migrator.old_opt_records << keg.opt_record
				}
			}
		}
	}
	if migrator.old_linked_kegs.len > 0 {
		migrator.new_linked_keg_record = os.join_path(migrator.new_cellar, os.base(migrator.old_linked_kegs[0]))
	}
	migrator.pinned = os.is_link(migrator.old_pin_record)
	if migrator.pinned {
		migrator.old_pin_link_record = os.readlink(migrator.old_pin_record) or { '' }
	}
	return migrator
}

pub fn (mut migrator Migrator) fix_tabs() ! {
	for mut tab in migrator.old_tabs {
		tab.set_tap(migrator.formula.tap)
		tab.write()!
	}
}

pub fn (mut migrator Migrator) from_same_tap_user() !bool {
	formula_user := migrator_tap_user(migrator.formula.tap)
	old_user := migrator_tap_user(migrator.old_tap)
	if formula_user == old_user {
		return true
	}
	if migrator.formula.tap != '' && migrator.old_tap != '' {
		migration := migrator.formula.tap_migrations[migrator.oldname] or { '' }
		if migration == migrator.formula.tap {
			migrator.fix_tabs()!
			return true
		}
	}
	return false
}

pub fn (migrator Migrator) linked_old_linked_kegs() []string {
	return migrator.old_linked_kegs.clone()
}

pub fn (migrator Migrator) pinned_value() bool {
	return migrator.pinned
}

pub fn (mut migrator Migrator) remove_conflicts(directory string) !bool {
	mut conflicted := false
	for entry in os.ls(directory)! {
		child := os.join_path(directory, entry)
		if os.is_dir(child) && !os.is_link(child) {
			if migrator.remove_conflicts(child)! {
				conflicted = true
			}
			continue
		}
		relative := child.trim_string_left(migrator.old_cellar).trim_left('/')
		new_path := os.join_path(migrator.new_cellar, relative)
		if os.exists(new_path) || os.is_link(new_path) {
			if os.is_dir(child) && !os.is_link(child) {
				os.rmdir_all(child) or { conflicted = true }
			} else {
				os.rm(child) or { conflicted = true }
			}
		}
	}
	return conflicted
}

pub fn (mut migrator Migrator) merge_directory(directory string) ! {
	for entry in os.ls(directory)! {
		child := os.join_path(directory, entry)
		relative := child.trim_string_left(migrator.old_cellar).trim_left('/')
		new_path := os.join_path(migrator.new_cellar, relative)
		if os.is_dir(child) && !os.is_link(child) && os.exists(new_path) {
			migrator.merge_directory(child)!
			os.rmdir(child) or {}
		} else {
			os.mkdir_all(os.dir(new_path))!
			os.mv(child, new_path)!
		}
	}
}

pub fn (mut migrator Migrator) move_to_new_directory() ! {
	if !os.exists(migrator.old_cellar) {
		return
	}
	if os.exists(migrator.new_cellar) && migrator.remove_conflicts(migrator.old_cellar)! {
		return error('Remove ${migrator.new_cellar} and ${migrator.old_cellar} manually and run `brew reinstall ${migrator.newname}`.')
	}
	migrator.output << 'Moving ${migrator.oldname} versions to ${migrator.new_cellar}'
	if os.exists(migrator.new_cellar) {
		migrator.merge_directory(migrator.old_cellar)!
		os.rmdir(migrator.old_cellar) or {}
	} else {
		os.mv(migrator.old_cellar, migrator.new_cellar)!
	}
}

pub fn (mut migrator Migrator) repin() ! {
	if !migrator.pinned || migrator.old_pin_link_record == '' {
		return
	}
	old_target := os.real_path(os.join_path(os.dir(migrator.old_pin_record), migrator.old_pin_link_record))
	new_target := old_target.replace('/${migrator.oldname}/', '/${migrator.newname}/')
	migrator_make_relative_symlink(migrator.new_pin_record, new_target)!
	os.rm(migrator.old_pin_record)!
	migrator.pinned = false
}

pub fn (mut migrator Migrator) unlink_oldname() ! {
	migrator.output << 'Unlinking ${migrator.oldname}'
	for path in migrator_subdirs(migrator.old_cellar) {
		keg := new_keg_with_paths(path, migrator.cellar, migrator.prefix)!
		keg.unlink(false)!
	}
}

pub fn (mut migrator Migrator) unlink_newname() ! {
	migrator.output << 'Temporarily unlinking ${migrator.newname}'
	for path in migrator_subdirs(migrator.new_cellar) {
		keg := new_keg_with_paths(path, migrator.cellar, migrator.prefix)!
		keg.unlink(false)!
	}
}

pub fn (mut migrator Migrator) link_newname() ! {
	if migrator.new_linked_keg_record == '' || !os.is_dir(migrator.new_linked_keg_record) {
		return
	}
	migrator.output << 'Relinking ${migrator.newname}'
	keg := new_keg_with_paths(migrator.new_linked_keg_record, migrator.cellar, migrator.prefix)!
	if migrator.formula.keg_only || migrator.old_full_linked_kegs.len == 0 {
		keg.optlink(false, true)!
		return
	}
	keg.link(false, true)!
}

pub fn (mut migrator Migrator) link_oldname_opt() ! {
	if migrator.new_linked_keg_record == '' {
		return
	}
	for record in migrator.old_opt_records {
		migrator_make_relative_symlink(record, migrator.new_linked_keg_record)!
	}
}

pub fn (mut migrator Migrator) update_tabs() ! {
	for path in migrator_subdirs(migrator.new_cellar) {
		mut tab := tab_for_keg(path) or { continue }
		if 'path' in tab.source {
			tab.source['path'] = json2.Any(migrator.formula.path)
		}
		tab.write()!
	}
}

pub fn (mut migrator Migrator) unlink_oldname_opt() ! {
	if migrator.new_linked_keg_record == '' || !os.exists(migrator.new_linked_keg_record) {
		return
	}
	for record in migrator.old_opt_records {
		if os.is_link(record) && os.exists(record) && migrator_same_path(record, migrator.new_linked_keg_record) {
			os.rm(record)!
			if entries := os.ls(os.dir(record)) {
				if entries.len == 0 {
					os.rmdir(os.dir(record)) or {}
				}
			}
		}
	}
}

pub fn (mut migrator Migrator) link_oldname_cellar() ! {
	if os.is_link(migrator.old_cellar) {
		os.rm(migrator.old_cellar)!
	} else if os.exists(migrator.old_cellar) {
		os.rmdir_all(migrator.old_cellar)!
	}
	migrator_make_relative_symlink(migrator.old_cellar, migrator.formula.rack)!
}

pub fn (mut migrator Migrator) unlink_oldname_cellar() ! {
	if !os.is_link(migrator.old_cellar) {
		return
	}
	if !os.exists(migrator.old_cellar) || (os.exists(migrator.formula.rack) && migrator_same_path(migrator.old_cellar, migrator.formula.rack)) {
		os.rm(migrator.old_cellar)!
	}
}

pub fn (mut migrator Migrator) backup_oldname_cellar() ! {
	if !os.exists(migrator.old_cellar) && os.exists(migrator.new_cellar) {
		os.mv(migrator.new_cellar, migrator.old_cellar)!
	}
}

pub fn (mut migrator Migrator) backup_old_tabs() ! {
	for tab in migrator.old_tabs {
		tab.write()!
	}
}

pub fn (mut migrator Migrator) backup_oldname() ! {
	migrator.unlink_oldname_opt()!
	migrator.unlink_oldname_cellar()!
	migrator.backup_oldname_cellar()!
	migrator.backup_old_tabs()!
	if migrator.old_pin_link_record != '' && !os.is_link(migrator.old_pin_record) {
		old_target := os.real_path(os.join_path(os.dir(migrator.old_pin_record), migrator.old_pin_link_record))
		migrator_make_relative_symlink(migrator.old_pin_record, old_target)!
		if os.is_link(migrator.new_pin_record) || os.exists(migrator.new_pin_record) {
			os.rm(migrator.new_pin_record)!
		}
		migrator.pinned = true
	}
	if os.exists(migrator.new_cellar) {
		for path in migrator_subdirs(migrator.new_cellar) {
			keg := new_keg_with_paths(path, migrator.cellar, migrator.prefix)!
			keg.unlink(false) or {}
			if !migrator.new_cellar_existed {
				keg.uninstall() or {}
			}
		}
	}
	for path in migrator.old_full_linked_kegs {
		if os.is_dir(path) {
			keg := new_keg_with_paths(path, migrator.cellar, migrator.prefix)!
			if !keg.linked() {
				keg.link(false, true)!
			}
		}
	}
	for path in migrator.old_linked_kegs {
		if path !in migrator.old_full_linked_kegs && os.is_dir(path) {
			keg := new_keg_with_paths(path, migrator.cellar, migrator.prefix)!
			keg.optlink(false, true)!
		}
	}
}

pub fn (mut migrator Migrator) lock() ! {
	migrator.newname_lock.lock()!
	migrator.oldname_lock.lock()!
}

pub fn (mut migrator Migrator) unlock() ! {
	migrator.newname_lock.unlock(false)!
	migrator.oldname_lock.unlock(false)!
}

pub fn (mut migrator Migrator) migrate() ! {
	migrator.output << 'Migrating formula ${migrator.oldname} to ${migrator.newname}'
	migrator.lock()!
	defer {
		migrator.unlock() or {}
	}
	migrator.unlink_oldname()!
	if os.exists(migrator.new_cellar) {
		migrator.unlink_newname()!
	}
	migrator.repin()!
	migrator.move_to_new_directory()!
	migrator.link_oldname_cellar()!
	migrator.link_oldname_opt()!
	if migrator.old_linked_kegs.len > 0 {
		migrator.link_newname()!
	}
	migrator.update_tabs()!
	if migrator.formula.outdated {
		migrator.output << "${migrator.newname} is outdated!\nTo avoid broken installations, as soon as possible please run:\n  brew upgrade\nOr, if you're OK with a less reliable fix:\n  brew upgrade ${migrator.newname}"
	}
}

pub fn migrator_migrate_if_needed(formula MigratorFormulaInfo, config MigratorConfig,
	dry_run bool) MigratorRunResult {
	mut result := MigratorRunResult{}
	for oldname in migrator_oldnames_needing_migration(formula, config.cellar) {
		if dry_run {
			result.output << 'Would migrate formula ${oldname} to ${formula.name}'
			continue
		}
		mut migrator := new_migrator(formula, oldname, config) or {
			result.errors << err.msg()
			continue
		}
		migrator.migrate() or {
			result.errors << err.msg()
			continue
		}
		result.migrated << oldname
		result.output << migrator.output
	}
	return result
}

fn migrator_formula_from_value(value ruby.Value) MigratorFormulaInfo {
	return MigratorFormulaInfo{
		name: (value.map_data['name'] or { ruby.string_value(value.as_string()) }).as_string()
		tap: (value.map_data['tap'] or { ruby.string_value('') }).as_string()
		path: (value.map_data['path'] or { ruby.string_value('') }).as_string()
		rack: (value.map_data['rack'] or { ruby.string_value('') }).as_string()
		oldnames: (value.map_data['oldnames'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		keg_only: (value.map_data['keg_only'] or { ruby.bool_value(false) }).bool_data
		outdated: (value.map_data['outdated'] or { ruby.bool_value(false) }).bool_data
	}
}

fn migrator_config_from_value(value ruby.Value) MigratorConfig {
	return MigratorConfig{
		cellar: (value.map_data['cellar'] or { ruby.string_value('') }).as_string()
		prefix: (value.map_data['prefix'] or { ruby.string_value('') }).as_string()
		pinned_kegs: (value.map_data['pinned_kegs'] or { ruby.string_value('') }).as_string()
		linked_kegs: (value.map_data['linked_kegs'] or { ruby.string_value('') }).as_string()
		locks_dir: (value.map_data['locks_dir'] or { ruby.string_value('') }).as_string()
		force: (value.map_data['force'] or { ruby.bool_value(false) }).bool_data
	}
}

pub fn migrator_value(migrator Migrator) ruby.Value {
	return ruby.Value{
		type_name: 'Migrator'
		repr: '${migrator.oldname}->${migrator.newname}'
		map_data: {
			'formula':               ruby.Value{
				type_name: 'Formula'
				repr: migrator.formula.name
				map_data: {
					'name':     ruby.string_value(migrator.formula.name)
					'tap':      ruby.string_value(migrator.formula.tap)
					'path':     ruby.string_value(migrator.formula.path)
					'rack':     ruby.string_value(migrator.formula.rack)
					'oldnames': ruby.string_array_value(migrator.formula.oldnames)
					'keg_only': ruby.bool_value(migrator.formula.keg_only)
					'outdated': ruby.bool_value(migrator.formula.outdated)
				}
			}
			'oldname':               ruby.string_value(migrator.oldname)
			'newname':               ruby.string_value(migrator.newname)
			'old_cellar':            ruby.string_value(migrator.old_cellar)
			'new_cellar':            ruby.string_value(migrator.new_cellar)
			'old_pin_record':        ruby.string_value(migrator.old_pin_record)
			'new_pin_record':        ruby.string_value(migrator.new_pin_record)
			'old_pin_link_record':   ruby.string_value(migrator.old_pin_link_record)
			'old_opt_records':       ruby.string_array_value(migrator.old_opt_records)
			'old_linked_kegs':       ruby.string_array_value(migrator.old_linked_kegs)
			'old_full_linked_kegs':  ruby.string_array_value(migrator.old_full_linked_kegs)
			'old_tap':               ruby.string_value(migrator.old_tap)
			'new_linked_keg_record': ruby.string_value(migrator.new_linked_keg_record)
			'new_cellar_existed':    ruby.bool_value(migrator.new_cellar_existed)
			'pinned':                ruby.bool_value(migrator.pinned)
			'cellar':                ruby.string_value(migrator.cellar)
			'prefix':                ruby.string_value(migrator.prefix)
			'pinned_kegs':           ruby.string_value(migrator.pinned_kegs)
			'linked_kegs':           ruby.string_value(migrator.linked_kegs)
			'locks_dir':             ruby.string_value(migrator.locks_dir)
			'output':                ruby.string_array_value(migrator.output)
		}
	}
}

fn migrator_from_value(value ruby.Value) !Migrator {
	formula_value := value.map_data['formula'] or { return error('Migrator value has no formula') }
	formula := migrator_formula_from_value(formula_value)
	return Migrator{
		formula: formula
		oldname: (value.map_data['oldname'] or { ruby.string_value('') }).as_string()
		newname: (value.map_data['newname'] or { ruby.string_value(formula.name) }).as_string()
		old_cellar: (value.map_data['old_cellar'] or { ruby.string_value('') }).as_string()
		new_cellar: (value.map_data['new_cellar'] or { ruby.string_value('') }).as_string()
		old_pin_record: (value.map_data['old_pin_record'] or { ruby.string_value('') }).as_string()
		new_pin_record: (value.map_data['new_pin_record'] or { ruby.string_value('') }).as_string()
		old_pin_link_record: (value.map_data['old_pin_link_record'] or { ruby.string_value('') }).as_string()
		old_opt_records: (value.map_data['old_opt_records'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		old_linked_kegs: (value.map_data['old_linked_kegs'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		old_full_linked_kegs: (value.map_data['old_full_linked_kegs'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		old_tap: (value.map_data['old_tap'] or { ruby.string_value('') }).as_string()
		new_linked_keg_record: (value.map_data['new_linked_keg_record'] or { ruby.string_value('') }).as_string()
		new_cellar_existed: (value.map_data['new_cellar_existed'] or { ruby.bool_value(false) }).bool_data
		pinned: (value.map_data['pinned'] or { ruby.bool_value(false) }).bool_data
		cellar: (value.map_data['cellar'] or { ruby.string_value('') }).as_string()
		prefix: (value.map_data['prefix'] or { ruby.string_value('') }).as_string()
		pinned_kegs: (value.map_data['pinned_kegs'] or { ruby.string_value('') }).as_string()
		linked_kegs: (value.map_data['linked_kegs'] or { ruby.string_value('') }).as_string()
		locks_dir: (value.map_data['locks_dir'] or { ruby.string_value('') }).as_string()
		output: (value.map_data['output'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		newname_lock: new_lock_file('formula', (value.map_data['new_cellar'] or { ruby.string_value('') }).as_string(), (value.map_data['locks_dir'] or { ruby.string_value('') }).as_string())
		oldname_lock: new_lock_file('formula', (value.map_data['old_cellar'] or { ruby.string_value('') }).as_string(), (value.map_data['locks_dir'] or { ruby.string_value('') }).as_string())
	}
}

fn migrator_receiver(args []ruby.Value) !Migrator {
	if args.len == 0 {
		return error('Migrator receiver is required')
	}
	return migrator_from_value(args[0])
}

fn migrator_error_value(message string) ruby.Value {
	return ruby.Value{ type_name: 'Error', repr: message }
}
