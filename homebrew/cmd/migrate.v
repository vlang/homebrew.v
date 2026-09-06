module cmd

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
