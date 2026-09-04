module cmd

import ruby

// Translated from Homebrew/brew `cmd/migrate.rb`.
// The original source is retained below until every stub has a typed V body.
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
			MigratePackageKind.cask} else {
			MigratePackageKind.formula}
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

// Ruby method `run` at line 32.
pub fn ruby_migrate_l32_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'at least one installed formula or cask is required')
	}
	values := args[0].as_map() or { return ruby.object_value('ArgumentError', err.msg()) }
	package_values := if value := values['packages'] {
		value.as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	if package_values.len == 0 {
		return ruby.object_value('ArgumentError', 'at least one installed formula or cask is required')
	}
	options := MigrateOptions{
		force: if value := values['force'] { value.as_bool() or { false } } else { false }
		dry_run: if value := values['dry_run'] { value.as_bool() or { false } } else { false }
	}
	return migrate_result_to_value(run_migrate_command(package_values.map(migrate_package_from_value(it)), options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "migrator"
// 6: require "cask/migrator"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Migrate < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Migrate renamed packages to new names, where <formula> are old names of
// 14:           packages.
// 15:         EOS
// 16:         switch "-f", "--force",
// 17:                description: "Treat installed <formula> and provided <formula> as if they are from " \
// 18:                             "the same taps and migrate them anyway."
// 19:         switch "-n", "--dry-run",
// 20:                description: "Show what would be migrated, but do not actually migrate anything."
// 21:         switch "--formula", "--formulae",
// 22:                description: "Only migrate formulae."
// 23:         switch "--cask", "--casks",
// 24:                description: "Only migrate casks."
// 25:
// 26:         conflicts "--formula", "--cask"
// 27:
// 28:         named_args [:installed_formula, :installed_cask], min: 1
// 29:       end
// 30:
// 31:       sig { override.void }
// 32:       def run
// 33:         args.named.to_formulae_and_casks(warn: false).each do |formula_or_cask|
// 34:           case formula_or_cask
// 35:           when Formula
// 36:             Migrator.migrate_if_needed(formula_or_cask, force: args.force?, dry_run: args.dry_run?)
// 37:           when Cask::Cask
// 38:             Cask::Migrator.migrate_if_needed(formula_or_cask, dry_run: args.dry_run?)
// 39:           end
// 40:         end
// 41:       end
// 42:     end
// 43:   end
// 44: end
