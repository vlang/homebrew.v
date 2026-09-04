module cmd

import ruby

// Translated from Homebrew/brew `cmd/migrate.rb`.
pub enum MigratePackageKind {
	formula
	cask
}

pub struct MigratePackage {
pub:
	kind      MigratePackageKind
	old_name  string
	new_name  string
	installed bool
}

pub struct MigrateOptions {
pub:
	force   bool
	dry_run bool
}

pub struct MigrateResult {
pub:
	migrated []string
	output   []string
	dry_run  bool
}

pub fn run_migrate_command(packages []MigratePackage, options MigrateOptions) MigrateResult {
	mut migrated := []string{}
	mut output := []string{}
	for package in packages {
		if !package.installed || package.old_name == '' || package.new_name == '' || package.old_name == package.new_name {
			continue
		}
		kind := if package.kind == .formula { 'formula' } else { 'cask' }
		prefix := if options.dry_run { 'Would migrate' } else { 'Migrating' }
		output << '${prefix} ${kind} ${package.old_name} to ${package.new_name}'
		if !options.dry_run {
			migrated << package.new_name
		}
	}
	return MigrateResult{
		migrated: migrated
		output: output
		dry_run: options.dry_run
	}
}

pub fn migrate_package_to_value(package MigratePackage) ruby.Value {
	return ruby.structured_value('MigratePackage', package.old_name, {
		'kind':      package.kind.str()
		'old_name':  package.old_name
		'new_name':  package.new_name
		'installed': package.installed.str()
	})
}

fn migrate_package_from_value(value ruby.Value) MigratePackage {
	return MigratePackage{
		kind: if (value.attributes['kind'] or { 'formula' }) == 'cask' {
			MigratePackageKind.cask
		} else {
			MigratePackageKind.formula
		}
		old_name: value.attributes['old_name'] or { value.as_string() }
		new_name: value.attributes['new_name'] or { value.as_string() }
		installed: (value.attributes['installed'] or { 'true' }) == 'true'
	}
}

pub fn migrate_result_to_value(result MigrateResult) ruby.Value {
	return ruby.map_value({
		'migrated': ruby.string_array_value(result.migrated)
		'output':   ruby.string_array_value(result.output)
		'dry_run':  ruby.bool_value(result.dry_run)
	})
}
