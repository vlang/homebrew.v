module homebrew

import ruby
import json2
import os

// Translated from Homebrew/brew `migrator.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `initialize(oldname, newname)` at line 19.
pub fn ruby_migrator_l19_d1_initialize(args ...ruby.Value) ruby.Value {
	oldname := if args.len > 0 { args[0].as_string() } else { '' }
	newname := if args.len > 1 { args[1].as_string() } else { '' }
	return migrator_error_value(migrator_migration_needed_message(oldname, newname))
}

// Ruby method `initialize(oldname)` at line 30.
pub fn ruby_migrator_l30_d2_initialize(args ...ruby.Value) ruby.Value {
	oldname := if args.len > 0 { args[0].as_string() } else { '' }
	cellar := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby.environment_value('HOMEBREW_CELLAR')
	}
	return migrator_error_value(migrator_no_oldpath_message(cellar, oldname))
}

// Ruby method `initialize(formula, oldname, tap)` at line 38.
pub fn ruby_migrator_l38_d3_initialize(args ...ruby.Value) ruby.Value {
	formula := if args.len > 0 {
		migrator_formula_from_value(args[0])
	} else {
		MigratorFormulaInfo{}
	}
	oldname := if args.len > 1 { args[1].as_string() } else { '' }
	tap := if args.len > 2 { args[2].as_string() } else { '' }
	return migrator_error_value(migrator_different_taps_message(formula, oldname, tap))
}

// Ruby attr_reader `attr_reader :formula` at line 55.
pub fn ruby_migrator_l55_d4_formula(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		args[0].map_data['formula'] or { migrator_nil_value() }
	} else {
		migrator_nil_value()
	}
}

// Ruby attr_reader `attr_reader :oldname` at line 59.
pub fn ruby_migrator_l59_d5_oldname(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 {
		(args[0].map_data['oldname'] or { ruby.string_value('') }).as_string()
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :old_cellar` at line 63.
pub fn ruby_migrator_l63_d6_old_cellar(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 {
		(args[0].map_data['old_cellar'] or { ruby.string_value('') }).as_string()
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :old_pin_record` at line 67.
pub fn ruby_migrator_l67_d7_old_pin_record(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 {
		(args[0].map_data['old_pin_record'] or { ruby.string_value('') }).as_string()
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :old_opt_records` at line 71.
pub fn ruby_migrator_l71_d8_old_opt_records(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		args[0].map_data['old_opt_records'] or { ruby.string_array_value([]) }
	} else {
		ruby.string_array_value([])
	}
}

// Ruby attr_reader `attr_reader :old_linked_kegs` at line 75.
pub fn ruby_migrator_l75_d9_old_linked_kegs(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		args[0].map_data['old_linked_kegs'] or { ruby.string_array_value([]) }
	} else {
		ruby.string_array_value([])
	}
}

// Ruby attr_reader `attr_reader :old_full_linked_kegs` at line 79.
pub fn ruby_migrator_l79_d10_old_full_linked_kegs(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		args[0].map_data['old_full_linked_kegs'] or { ruby.string_array_value([]) }
	} else {
		ruby.string_array_value([])
	}
}

// Ruby attr_reader `attr_reader :old_tabs` at line 83.
pub fn ruby_migrator_l83_d11_old_tabs(args ...ruby.Value) ruby.Value {
	migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	return ruby.array_value(migrator.old_tabs.map(tab_boundary_value(it)))
}

// Ruby attr_reader `attr_reader :old_tap` at line 87.
pub fn ruby_migrator_l87_d12_old_tap(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 {
		(args[0].map_data['old_tap'] or { ruby.string_value('') }).as_string()
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :old_pin_link_record` at line 91.
pub fn ruby_migrator_l91_d13_old_pin_link_record(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 {
		(args[0].map_data['old_pin_link_record'] or { ruby.string_value('') }).as_string()
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :newname` at line 95.
pub fn ruby_migrator_l95_d14_newname(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 {
		(args[0].map_data['newname'] or { ruby.string_value('') }).as_string()
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :new_cellar` at line 99.
pub fn ruby_migrator_l99_d15_new_cellar(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 {
		(args[0].map_data['new_cellar'] or { ruby.string_value('') }).as_string()
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :new_cellar_existed` at line 103.
pub fn ruby_migrator_l103_d16_new_cellar_existed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && (args[0].map_data['new_cellar_existed'] or { ruby.bool_value(false) }).bool_data)
}

// Ruby attr_reader `attr_reader :new_pin_record` at line 107.
pub fn ruby_migrator_l107_d17_new_pin_record(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 {
		(args[0].map_data['new_pin_record'] or { ruby.string_value('') }).as_string()
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :new_linked_keg_record` at line 111.
pub fn ruby_migrator_l111_d18_new_linked_keg_record(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 {
		(args[0].map_data['new_linked_keg_record'] or { ruby.string_value('') }).as_string()
	} else {
		''
	})
}

// Ruby method `self.oldnames_needing_migration(formula)` at line 114.
pub fn ruby_migrator_l114_d19_self_oldnames_needing_migration(args ...ruby.Value) ruby.Value {
	formula := if args.len > 0 {
		migrator_formula_from_value(args[0])
	} else {
		MigratorFormulaInfo{}
	}
	cellar := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby.environment_value('HOMEBREW_CELLAR')
	}
	return ruby.string_array_value(migrator_oldnames_needing_migration(formula, cellar))
}

// Ruby method `self.needs_migration?(formula)` at line 125.
pub fn ruby_migrator_l125_d20_self_needs_migration(args ...ruby.Value) ruby.Value {
	return ruby.bool_value((ruby_migrator_l114_d19_self_oldnames_needing_migration(...args).as_string_array() or { [] }).len > 0)
}

// Ruby method `self.migrate_if_needed(formula, force:, dry_run: false)` at line 130.
pub fn ruby_migrator_l130_d21_self_migrate_if_needed(args ...ruby.Value) ruby.Value {
	formula := if args.len > 0 {
		migrator_formula_from_value(args[0])
	} else {
		MigratorFormulaInfo{}
	}
	config := if args.len > 1 { migrator_config_from_value(args[1]) } else { MigratorConfig{} }
	dry_run := args.len > 2 && args[2].bool_data
	result := migrator_migrate_if_needed(formula, config, dry_run)
	return ruby.Value{
		type_name: 'Migrator::RunResult'
		repr: result.output.join('\n')
		map_data: {
			'migrated': ruby.string_array_value(result.migrated)
			'output':   ruby.string_array_value(result.output)
			'errors':   ruby.string_array_value(result.errors)
		}
	}
}

// Ruby method `initialize(formula, oldname, force: false)` at line 149.
pub fn ruby_migrator_l149_d22_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return migrator_error_value('Migrator.new requires formula, old name, and path configuration')
	}
	formula := migrator_formula_from_value(args[0])
	config := migrator_config_from_value(args[2])
	migrator := new_migrator(formula, args[1].as_string(), config) or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `fix_tabs` at line 186.
pub fn ruby_migrator_l186_d23_fix_tabs(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.fix_tabs() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `from_same_tap_user?` at line 194.
pub fn ruby_migrator_l194_d24_from_same_tap_user(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return ruby.bool_value(false) }
	return ruby.bool_value(migrator.from_same_tap_user() or { false })
}

// Ruby method `linked_old_linked_kegs` at line 221.
pub fn ruby_migrator_l221_d25_linked_old_linked_kegs(args ...ruby.Value) ruby.Value {
	migrator := migrator_receiver(args) or { return ruby.string_array_value([]) }
	return ruby.string_array_value(migrator.linked_old_linked_kegs())
}

// Ruby method `pinned?` at line 230.
pub fn ruby_migrator_l230_d26_pinned(args ...ruby.Value) ruby.Value {
	migrator := migrator_receiver(args) or { return ruby.bool_value(false) }
	return ruby.bool_value(migrator.pinned_value())
}

// Ruby method `migrate` at line 235.
pub fn ruby_migrator_l235_d27_migrate(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.migrate() or {
		migrator.backup_oldname() or {}
		return migrator_error_value(err.msg())
	}
	return migrator_value(migrator)
}

// Ruby method `remove_conflicts(directory)` at line 272.
pub fn ruby_migrator_l272_d28_remove_conflicts(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	directory := if args.len > 1 { args[1].as_string() } else { migrator.old_cellar }
	return ruby.bool_value(migrator.remove_conflicts(directory) or { return migrator_error_value(err.msg()) })
}

// Ruby method `merge_directory(directory)` at line 294.
pub fn ruby_migrator_l294_d29_merge_directory(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	directory := if args.len > 1 { args[1].as_string() } else { migrator.old_cellar }
	migrator.merge_directory(directory) or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `move_to_new_directory` at line 309.
pub fn ruby_migrator_l309_d30_move_to_new_directory(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.move_to_new_directory() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `repin` at line 326.
pub fn ruby_migrator_l326_d31_repin(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.repin() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `unlink_oldname` at line 350.
pub fn ruby_migrator_l350_d32_unlink_oldname(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.unlink_oldname() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `unlink_newname` at line 359.
pub fn ruby_migrator_l359_d33_unlink_newname(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.unlink_newname() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `link_newname` at line 368.
pub fn ruby_migrator_l368_d34_link_newname(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.link_newname() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `link_oldname_opt` at line 420.
pub fn ruby_migrator_l420_d35_link_oldname_opt(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.link_oldname_opt() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `update_tabs` at line 433.
pub fn ruby_migrator_l433_d36_update_tabs(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.update_tabs() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `unlink_oldname_opt` at line 443.
pub fn ruby_migrator_l443_d37_unlink_oldname_opt(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.unlink_oldname_opt() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `link_oldname_cellar` at line 459.
pub fn ruby_migrator_l459_d38_link_oldname_cellar(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.link_oldname_cellar() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `unlink_oldname_cellar` at line 466.
pub fn ruby_migrator_l466_d39_unlink_oldname_cellar(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.unlink_oldname_cellar() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `backup_oldname` at line 475.
pub fn ruby_migrator_l475_d40_backup_oldname(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.backup_oldname() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `backup_oldname_cellar` at line 515.
pub fn ruby_migrator_l515_d41_backup_oldname_cellar(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.backup_oldname_cellar() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `backup_old_tabs` at line 520.
pub fn ruby_migrator_l520_d42_backup_old_tabs(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.backup_old_tabs() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `lock` at line 525.
pub fn ruby_migrator_l525_d43_lock(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.lock() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Ruby method `unlock` at line 535.
pub fn ruby_migrator_l535_d44_unlock(args ...ruby.Value) ruby.Value {
	mut migrator := migrator_receiver(args) or { return migrator_error_value(err.msg()) }
	migrator.unlock() or { return migrator_error_value(err.msg()) }
	return migrator_value(migrator)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "lock_file"
// 5: require "keg"
// 6: require "tab"
// 7: require "utils"
// 8: require "utils/output"
// 9:
// 10: # Helper class for migrating a formula from an old to a new name.
// 11: class Migrator
// 12:   extend Utils::Output::Mixin
// 13:   include Context
// 14:   include Utils::Output::Mixin
// 15:
// 16:   # Error for when a migration is necessary.
// 17:   class MigrationNeededError < RuntimeError
// 18:     sig { params(oldname: String, newname: String).void }
// 19:     def initialize(oldname, newname)
// 20:       super <<~EOS
// 21:         #{oldname} was renamed to #{newname} and needs to be migrated by running:
// 22:           brew migrate #{oldname}
// 23:       EOS
// 24:     end
// 25:   end
// 26:
// 27:   # Error for when the old name's path does not exist.
// 28:   class MigratorNoOldpathError < RuntimeError
// 29:     sig { params(oldname: String).void }
// 30:     def initialize(oldname)
// 31:       super "#{HOMEBREW_CELLAR/oldname} doesn't exist."
// 32:     end
// 33:   end
// 34:
// 35:   # Error for when a formula is migrated to a different tap without explicitly using its fully-qualified name.
// 36:   class MigratorDifferentTapsError < RuntimeError
// 37:     sig { params(formula: Formula, oldname: String, tap: T.nilable(Tap)).void }
// 38:     def initialize(formula, oldname, tap)
// 39:       msg = if tap&.core_tap?
// 40:         "Please try to use #{oldname} to refer to the formula.\n"
// 41:       elsif tap
// 42:         "Please try to use fully-qualified #{tap}/#{oldname} to refer to the formula.\n"
// 43:       end
// 44:
// 45:       super <<~EOS
// 46:         #{formula.name} from #{formula.tap} is given, but old name #{oldname} was installed from #{tap || "path or url"}.
// 47:         #{msg}To force migration, run:
// 48:           brew migrate --force #{oldname}
// 49:       EOS
// 50:     end
// 51:   end
// 52:
// 53:   # Instance of renamed formula.
// 54:   sig { returns(Formula) }
// 55:   attr_reader :formula
// 56:
// 57:   # Old name of the formula.
// 58:   sig { returns(String) }
// 59:   attr_reader :oldname
// 60:
// 61:   # Path to oldname's Cellar.
// 62:   sig { returns(Pathname) }
// 63:   attr_reader :old_cellar
// 64:
// 65:   # Path to oldname pin.
// 66:   sig { returns(Pathname) }
// 67:   attr_reader :old_pin_record
// 68:
// 69:   # Path to oldname opt.
// 70:   sig { returns(T::Array[Pathname]) }
// 71:   attr_reader :old_opt_records
// 72:
// 73:   # Oldname linked kegs.
// 74:   sig { returns(T::Array[Keg]) }
// 75:   attr_reader :old_linked_kegs
// 76:
// 77:   # Oldname linked kegs that were fully linked.
// 78:   sig { returns(T::Array[Keg]) }
// 79:   attr_reader :old_full_linked_kegs
// 80:
// 81:   # Tabs from oldname kegs.
// 82:   sig { returns(T::Array[Tab]) }
// 83:   attr_reader :old_tabs
// 84:
// 85:   # Tap of the old name.
// 86:   sig { returns(T.nilable(Tap)) }
// 87:   attr_reader :old_tap
// 88:
// 89:   # Resolved path to oldname pin.
// 90:   sig { returns(T.nilable(Pathname)) }
// 91:   attr_reader :old_pin_link_record
// 92:
// 93:   # New name of the formula.
// 94:   sig { returns(String) }
// 95:   attr_reader :newname
// 96:
// 97:   # Path to newname Cellar according to new name.
// 98:   sig { returns(Pathname) }
// 99:   attr_reader :new_cellar
// 100:
// 101:   # True if new Cellar existed at initialization time.
// 102:   sig { returns(T::Boolean) }
// 103:   attr_reader :new_cellar_existed
// 104:
// 105:   # Path to newname pin.
// 106:   sig { returns(Pathname) }
// 107:   attr_reader :new_pin_record
// 108:
// 109:   # Path to newname keg that will be linked if old_linked_keg isn't nil.
// 110:   sig { returns(T.nilable(Pathname)) }
// 111:   attr_reader :new_linked_keg_record
// 112:
// 113:   sig { params(formula: Formula).returns(T::Array[String]) }
// 114:   def self.oldnames_needing_migration(formula)
// 115:     formula.oldnames.select do |oldname|
// 116:       oldname_rack = HOMEBREW_CELLAR/oldname
// 117:       next false if oldname_rack.symlink?
// 118:       next false unless oldname_rack.directory?
// 119:
// 120:       true
// 121:     end
// 122:   end
// 123:
// 124:   sig { params(formula: Formula).returns(T::Boolean) }
// 125:   def self.needs_migration?(formula)
// 126:     !oldnames_needing_migration(formula).empty?
// 127:   end
// 128:
// 129:   sig { params(formula: Formula, force: T::Boolean, dry_run: T::Boolean).void }
// 130:   def self.migrate_if_needed(formula, force:, dry_run: false)
// 131:     oldnames = Migrator.oldnames_needing_migration(formula)
// 132:
// 133:     begin
// 134:       oldnames.each do |oldname|
// 135:         if dry_run
// 136:           oh1 "Would migrate formula #{Formatter.identifier(oldname)} to #{Formatter.identifier(formula.name)}"
// 137:           next
// 138:         end
// 139:
// 140:         migrator = Migrator.new(formula, oldname, force:)
// 141:         migrator.migrate
// 142:       end
// 143:     rescue => e
// 144:       onoe e
// 145:     end
// 146:   end
// 147:
// 148:   sig { params(formula: Formula, oldname: String, force: T::Boolean).void }
// 149:   def initialize(formula, oldname, force: false)
// 150:     @oldname = oldname
// 151:     @newname = T.let(formula.name, String)
// 152:
// 153:     @formula = formula
// 154:     @old_cellar = T.let(HOMEBREW_CELLAR/oldname, Pathname)
// 155:     raise MigratorNoOldpathError, oldname unless old_cellar.exist?
// 156:
// 157:     @old_tabs = T.let(old_cellar.subdirs.map { |d| Keg.new(d).tab }, T::Array[Tab])
// 158:     first_tab = old_tabs.first
// 159:     @old_tap = T.let(first_tab&.tap, T.nilable(Tap))
// 160:
// 161:     raise MigratorDifferentTapsError.new(formula, oldname, old_tap) if !force && !from_same_tap_user?
// 162:
// 163:     @new_cellar = T.let(HOMEBREW_CELLAR/formula.name, Pathname)
// 164:     @new_cellar_existed = T.let(@new_cellar.exist?, T::Boolean)
// 165:
// 166:     @old_linked_kegs = T.let(linked_old_linked_kegs, T::Array[Keg])
// 167:     @old_full_linked_kegs = T.let([], T::Array[Keg])
// 168:     @old_opt_records = T.let([], T::Array[Pathname])
// 169:     old_linked_kegs.each do |old_linked_keg|
// 170:       @old_full_linked_kegs << old_linked_keg if old_linked_keg.linked?
// 171:       @old_opt_records << old_linked_keg.opt_record if old_linked_keg.optlinked?
// 172:     end
// 173:     @new_linked_keg_record = T.let(nil, T.nilable(Pathname))
// 174:     unless old_linked_kegs.empty?
// 175:       @new_linked_keg_record = HOMEBREW_CELLAR/"#{newname}/#{File.basename(old_linked_kegs.first.to_s)}"
// 176:     end
// 177:
// 178:     @old_pin_record = T.let(HOMEBREW_PINNED_KEGS/oldname, Pathname)
// 179:     @new_pin_record = T.let(HOMEBREW_PINNED_KEGS/newname, Pathname)
// 180:     @pinned = T.let(old_pin_record.symlink?, T::Boolean)
// 181:     @old_pin_link_record = T.let(old_pin_record.symlink? ? old_pin_record.readlink : nil, T.nilable(Pathname))
// 182:   end
// 183:
// 184:   # Fix `INSTALL_RECEIPT`s for tap-migrated formula.
// 185:   sig { void }
// 186:   def fix_tabs
// 187:     old_tabs.each do |tab|
// 188:       tab.tap = formula.tap
// 189:       tab.write
// 190:     end
// 191:   end
// 192:
// 193:   sig { returns(T::Boolean) }
// 194:   def from_same_tap_user?
// 195:     formula_tap_user = formula.tap&.user
// 196:     old_tap_user = nil
// 197:
// 198:     new_tap = if (old_tap = self.old_tap)
// 199:       old_tap_user, = old_tap.user
// 200:       if (migrate_tap = old_tap.tap_migrations[oldname])
// 201:         Utils.tap_from_full_name(migrate_tap) || (migrate_tap if migrate_tap.include?("/"))
// 202:       end
// 203:     end
// 204:
// 205:     if formula_tap_user == old_tap_user
// 206:       true
// 207:     # Homebrew didn't use to update tabs while performing tap-migrations,
// 208:     # so there can be `INSTALL_RECEIPT`s containing wrong information about tap,
// 209:     # so we check if there is an entry about oldname migrated to tap and if
// 210:     # newname's tap is the same as tap to which oldname migrated, then we
// 211:     # can perform migrations and the taps for oldname and newname are the same.
// 212:     elsif formula.tap && old_tap && formula.tap == new_tap
// 213:       fix_tabs
// 214:       true
// 215:     else
// 216:       false
// 217:     end
// 218:   end
// 219:
// 220:   sig { returns(T::Array[Keg]) }
// 221:   def linked_old_linked_kegs
// 222:     keg_dirs = []
// 223:     keg_dirs += new_cellar.subdirs if new_cellar.exist?
// 224:     keg_dirs += old_cellar.subdirs
// 225:     kegs = keg_dirs.map { |d| Keg.new(d) }
// 226:     kegs.select { |keg| keg.linked? || keg.optlinked? }
// 227:   end
// 228:
// 229:   sig { returns(T::Boolean) }
// 230:   def pinned?
// 231:     @pinned
// 232:   end
// 233:
// 234:   sig { void }
// 235:   def migrate
// 236:     oh1 "Migrating formula #{Formatter.identifier(oldname)} to #{Formatter.identifier(newname)}"
// 237:     lock
// 238:     unlink_oldname
// 239:     unlink_newname if new_cellar.exist?
// 240:     repin
// 241:     move_to_new_directory
// 242:     link_oldname_cellar
// 243:     link_oldname_opt
// 244:     link_newname unless old_linked_kegs.empty?
// 245:     update_tabs
// 246:     return unless formula.outdated?
// 247:
// 248:     opoo <<~EOS
// 249:       #{Formatter.identifier(newname)} is outdated!
// 250:       To avoid broken installations, as soon as possible please run:
// 251:         brew upgrade
// 252:       Or, if you're OK with a less reliable fix:
// 253:         brew upgrade #{newname}
// 254:     EOS
// 255:   rescue Interrupt
// 256:     ignore_interrupts { backup_oldname }
// 257:   # Any exception means the migration did not complete.
// 258:   rescue Exception => e # rubocop:disable Lint/RescueException
// 259:     onoe "The migration did not complete successfully."
// 260:     puts e
// 261:     if debug?
// 262:       require "utils/backtrace"
// 263:       puts Utils::Backtrace.clean(e)
// 264:     end
// 265:     puts "Backing up..."
// 266:     ignore_interrupts { backup_oldname }
// 267:   ensure
// 268:     unlock
// 269:   end
// 270:
// 271:   sig { params(directory: T.untyped).returns(T::Boolean) }
// 272:   def remove_conflicts(directory)
// 273:     conflicted = T.let(false, T::Boolean)
// 274:
// 275:     directory.each_child do |c|
// 276:       if c.directory? && !c.symlink?
// 277:         conflicted ||= remove_conflicts(c)
// 278:       else
// 279:         next unless (new_cellar/c.relative_path_from(old_cellar)).exist?
// 280:
// 281:         begin
// 282:           FileUtils.rm_rf c
// 283:         rescue Errno::EACCES
// 284:           conflicted = true
// 285:           onoe "#{new_cellar/c.basename} already exists."
// 286:         end
// 287:       end
// 288:     end
// 289:
// 290:     conflicted
// 291:   end
// 292:
// 293:   sig { params(directory: Pathname).void }
// 294:   def merge_directory(directory)
// 295:     directory.each_child do |c|
// 296:       new_path = new_cellar/c.relative_path_from(old_cellar)
// 297:
// 298:       if c.directory? && !c.symlink? && new_path.exist?
// 299:         merge_directory(c)
// 300:         c.unlink
// 301:       else
// 302:         FileUtils.mv(c, new_path)
// 303:       end
// 304:     end
// 305:   end
// 306:
// 307:   # Move everything from `Cellar/oldname` to `Cellar/newname`.
// 308:   sig { void }
// 309:   def move_to_new_directory
// 310:     return unless old_cellar.exist?
// 311:
// 312:     if new_cellar.exist?
// 313:       conflicted = remove_conflicts(old_cellar)
// 314:       odie "Remove #{new_cellar} and #{old_cellar} manually and run `brew reinstall #{newname}`." if conflicted
// 315:     end
// 316:
// 317:     oh1 "Moving #{Formatter.identifier(oldname)} versions to #{new_cellar}"
// 318:     if new_cellar.exist?
// 319:       merge_directory(old_cellar)
// 320:     else
// 321:       FileUtils.mv(old_cellar, new_cellar)
// 322:     end
// 323:   end
// 324:
// 325:   sig { void }
// 326:   def repin
// 327:     return unless pinned?
// 328:
// 329:     old_pin_link_record = self.old_pin_link_record
// 330:     return unless old_pin_link_record
// 331:
// 332:     # `old_pin_record` is a relative symlink and when we try to read it
// 333:     # from <dir> we actually try to find file
// 334:     # <dir>/../<...>/../Cellar/name/version.
// 335:     # To repin formula we need to update the link thus that it points to
// 336:     # the right directory.
// 337:     #
// 338:     # NOTE: `old_pin_record.realpath.sub(oldname, newname)` is unacceptable
// 339:     # here, because it resolves every symlink for `old_pin_record` and then
// 340:     # substitutes oldname with newname. It breaks things like
// 341:     # `Pathname#make_relative_symlink`, where `Pathname#relative_path_from`
// 342:     # is used to find the relative path from source to destination parent
// 343:     # and it assumes no symlinks.
// 344:     src_oldname = (old_pin_record.dirname/old_pin_link_record).expand_path
// 345:     new_pin_record.make_relative_symlink(src_oldname.sub(oldname, newname))
// 346:     old_pin_record.delete
// 347:   end
// 348:
// 349:   sig { void }
// 350:   def unlink_oldname
// 351:     oh1 "Unlinking #{Formatter.identifier(oldname)}"
// 352:     old_cellar.subdirs.each do |d|
// 353:       keg = Keg.new(d)
// 354:       keg.unlink(verbose: verbose?)
// 355:     end
// 356:   end
// 357:
// 358:   sig { void }
// 359:   def unlink_newname
// 360:     oh1 "Temporarily unlinking #{Formatter.identifier(newname)}"
// 361:     new_cellar.subdirs.each do |d|
// 362:       keg = Keg.new(d)
// 363:       keg.unlink(verbose: verbose?)
// 364:     end
// 365:   end
// 366:
// 367:   sig { returns(T.nilable(Integer)) }
// 368:   def link_newname
// 369:     new_linked_keg_record = self.new_linked_keg_record
// 370:     return unless new_linked_keg_record
// 371:
// 372:     oh1 "Relinking #{Formatter.identifier(newname)}"
// 373:     new_keg = Keg.new(new_linked_keg_record)
// 374:
// 375:     # If old_keg wasn't linked then we just optlink a keg.
// 376:     # If old keg wasn't optlinked and linked, we don't call this method at all.
// 377:     # If formula is keg-only we also optlink it.
// 378:     if formula.keg_only? || old_full_linked_kegs.empty?
// 379:       begin
// 380:         new_keg.optlink(verbose: verbose?)
// 381:       rescue Keg::LinkError => e
// 382:         onoe "Failed to create #{formula.opt_prefix}"
// 383:         raise
// 384:       end
// 385:       return
// 386:     end
// 387:
// 388:     new_keg.remove_linked_keg_record if new_keg.linked?
// 389:
// 390:     begin
// 391:       new_keg.link(overwrite: true, verbose: verbose?)
// 392:     rescue Keg::ConflictError => e
// 393:       onoe "The `brew link` step did not complete successfully."
// 394:       puts e
// 395:       puts
// 396:       puts "Possible conflicting files are:"
// 397:       new_keg.link(dry_run: true, overwrite: true, verbose: verbose?)
// 398:       raise
// 399:     rescue Keg::LinkError => e
// 400:       onoe "The `brew link` step did not complete successfully."
// 401:       puts e
// 402:       puts
// 403:       puts "You can try again using:"
// 404:       puts "  brew link #{formula.name}"
// 405:     # Any exception means the `brew link` step did not complete.
// 406:     rescue Exception => e # rubocop:disable Lint/RescueException
// 407:       onoe "An unexpected error occurred during linking"
// 408:       puts e
// 409:       if debug?
// 410:         require "utils/backtrace"
// 411:         puts Utils::Backtrace.clean(e)
// 412:       end
// 413:       ignore_interrupts { new_keg.unlink(verbose: verbose?) }
// 414:       raise
// 415:     end
// 416:   end
// 417:
// 418:   # Link keg to opt if it was linked before migrating.
// 419:   sig { void }
// 420:   def link_oldname_opt
// 421:     new_linked_keg_record = self.new_linked_keg_record
// 422:     return unless new_linked_keg_record
// 423:
// 424:     old_opt_records.each do |old_opt_record|
// 425:       old_opt_record.delete if old_opt_record.symlink?
// 426:       old_opt_record.make_relative_symlink(new_linked_keg_record)
// 427:     end
// 428:   end
// 429:
// 430:   # After migration every `INSTALL_RECEIPT.json` has the wrong path to the formula
// 431:   # so we must update `INSTALL_RECEIPT`s.
// 432:   sig { void }
// 433:   def update_tabs
// 434:     new_tabs = new_cellar.subdirs.map { |d| Keg.new(d).tab }
// 435:     new_tabs.each do |tab|
// 436:       tab.source["path"] = formula.path.to_s if tab.source["path"]
// 437:       tab.write
// 438:     end
// 439:   end
// 440:
// 441:   # Remove `opt/oldname` link if it belongs to newname.
// 442:   sig { void }
// 443:   def unlink_oldname_opt
// 444:     new_linked_keg_record = self.new_linked_keg_record
// 445:     return unless new_linked_keg_record&.exist?
// 446:
// 447:     old_opt_records.each do |old_opt_record|
// 448:       next unless old_opt_record.symlink?
// 449:       next unless old_opt_record.exist?
// 450:       next if new_linked_keg_record.realpath != old_opt_record.realpath
// 451:
// 452:       old_opt_record.unlink
// 453:       old_opt_record.parent.rmdir_if_possible
// 454:     end
// 455:   end
// 456:
// 457:   # Remove `Cellar/oldname` if it exists.
// 458:   sig { void }
// 459:   def link_oldname_cellar
// 460:     old_cellar.delete if old_cellar.symlink? || old_cellar.exist?
// 461:     old_cellar.make_relative_symlink(formula.rack)
// 462:   end
// 463:
// 464:   # Remove `Cellar/oldname` link if it belongs to newname.
// 465:   sig { void }
// 466:   def unlink_oldname_cellar
// 467:     if (old_cellar.symlink? && !old_cellar.exist?) ||
// 468:        (old_cellar.symlink? && formula.rack.exist? && formula.rack.realpath == old_cellar.realpath)
// 469:       old_cellar.unlink
// 470:     end
// 471:   end
// 472:
// 473:   # Backup everything if errors occur while migrating.
// 474:   sig { void }
// 475:   def backup_oldname
// 476:     unlink_oldname_opt
// 477:     unlink_oldname_cellar
// 478:     backup_oldname_cellar
// 479:     backup_old_tabs
// 480:
// 481:     if pinned? && !old_pin_record.symlink? && (old_pin_link = old_pin_link_record)
// 482:       src_oldname = (old_pin_record.dirname/old_pin_link).expand_path
// 483:       old_pin_record.make_relative_symlink(src_oldname)
// 484:       new_pin_record.delete
// 485:     end
// 486:
// 487:     if new_cellar.exist?
// 488:       new_cellar.subdirs.each do |d|
// 489:         newname_keg = Keg.new(d)
// 490:         newname_keg.unlink(verbose: verbose?)
// 491:         newname_keg.uninstall unless new_cellar_existed
// 492:       end
// 493:     end
// 494:
// 495:     return if old_linked_kegs.empty?
// 496:
// 497:     # The keg used to be linked and when we backup everything we restore
// 498:     # Cellar/oldname, the target also gets restored, so we are able to
// 499:     # create a keg using its old path
// 500:     old_full_linked_kegs.each do |old_linked_keg|
// 501:       old_linked_keg.link(verbose: verbose?)
// 502:     rescue Keg::LinkError
// 503:       old_linked_keg.unlink(verbose: verbose?)
// 504:       raise
// 505:     rescue Keg::AlreadyLinkedError
// 506:       old_linked_keg.unlink(verbose: verbose?)
// 507:       retry
// 508:     end
// 509:     (old_linked_kegs - old_full_linked_kegs).each do |old_linked_keg|
// 510:       old_linked_keg.optlink(verbose: verbose?)
// 511:     end
// 512:   end
// 513:
// 514:   sig { void }
// 515:   def backup_oldname_cellar
// 516:     FileUtils.mv(new_cellar, old_cellar) unless old_cellar.exist?
// 517:   end
// 518:
// 519:   sig { void }
// 520:   def backup_old_tabs
// 521:     old_tabs.each(&:write)
// 522:   end
// 523:
// 524:   sig { void }
// 525:   def lock
// 526:     newname_lock = FormulaLock.new(newname)
// 527:     oldname_lock = FormulaLock.new(oldname)
// 528:     newname_lock.lock
// 529:     oldname_lock.lock
// 530:     @newname_lock = T.let(newname_lock, T.nilable(FormulaLock))
// 531:     @oldname_lock = T.let(oldname_lock, T.nilable(FormulaLock))
// 532:   end
// 533:
// 534:   sig { void }
// 535:   def unlock
// 536:     @newname_lock&.unlock
// 537:     @oldname_lock&.unlock
// 538:   end
// 539: end
