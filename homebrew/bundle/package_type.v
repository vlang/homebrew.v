module bundle

import homebrew.bundle.extensions

// Translated from Homebrew/brew `bundle/package_type.rb`.
pub struct PackageTypeContext {
pub:
	definition       extensions.ExtensionDefinition
	upgrade_formulae []string
	skipper          BundleSkipper
}

pub struct PackageTypeEntriesResult {
pub:
	entries  []BundleDslEntry
	warnings []string
}

pub struct PackageTypeCheckResult {
pub:
	errors   []string
	warnings []string
}

fn package_type_status(statuses map[string]bool, name string, no_upgrade bool) !bool {
	if status := statuses['${name}|${no_upgrade}'] {
		return status
	}
	if status := statuses[name] {
		return status
	}
	return error('NotImplementedError')
}

pub fn package_type_register(mut registry extensions.ExtensionRegistry,
	definition extensions.ExtensionDefinition) {
	registry.package_types = registry.package_types.filter(it.class_name != definition.class_name)
	registry.package_types << definition
}

pub fn package_type_registered(registry extensions.ExtensionRegistry,
	type_name string) ?extensions.ExtensionDefinition {
	requested := type_name.trim_string_left(':')
	for definition in registry.package_types {
		if definition.type_name == requested {
			return definition
		}
	}
	return none
}

pub fn package_type_dump_order(registry extensions.ExtensionRegistry) []extensions.ExtensionDefinition {
	mut core := []extensions.ExtensionDefinition{}
	for type_name in ['tap', 'brew', 'cask'] {
		if definition := package_type_registered(registry, type_name) {
			core << definition
		}
	}
	mut ordered := core.clone()
	for definition in registry.package_types {
		if !ordered.any(it.class_name == definition.class_name) {
			ordered << definition
		}
	}
	return ordered
}

pub fn package_type_failure_reason(context PackageTypeContext, name string,
	no_upgrade bool) string {
	reason := if no_upgrade && name !in context.upgrade_formulae {
		'needs to be installed.'
	} else {
		'needs to be installed or updated.'
	}
	return '${context.definition.check_label} ${name} ${reason}'
}

pub fn package_type_checkable_entries(context PackageTypeContext,
	entries []BundleDslEntry) PackageTypeEntriesResult {
	mut selected := []BundleDslEntry{}
	mut warnings := []string{}
	for entry in entries {
		if entry.entry_type != context.definition.type_name {
			continue
		}
		full_name := if 'full_name' in entry.options {
			entry.options['full_name'].as_string()
		} else {
			''
		}
		id := if 'id' in entry.options { entry.options['id'].as_string() } else { '' }
		skip_result := context.skipper.skip(BundleSkipEntry{
			type_name: entry.entry_type
			name: entry.name
			full_name: full_name
			id: id
		}, false)
		if skip_result.skipped {
			if skip_result.warning != '' {
				warnings << skip_result.warning
			}
			continue
		}
		selected << entry
	}
	return PackageTypeEntriesResult{
		entries: selected
		warnings: warnings
	}
}

pub fn package_type_format_checkable(context PackageTypeContext,
	entries []BundleDslEntry) PackageTypeEntriesResult {
	return package_type_checkable_entries(context, entries)
}

pub fn package_type_exit_early_check(context PackageTypeContext, packages []string,
	no_upgrade bool, statuses map[string]bool) !PackageTypeCheckResult {
	for package in packages {
		if package_type_status(statuses, package, no_upgrade)! {
			continue
		}
		return PackageTypeCheckResult{
			errors: [package_type_failure_reason(context, package, no_upgrade)]
		}
	}
	return PackageTypeCheckResult{}
}

pub fn package_type_full_check(context PackageTypeContext, packages []string, no_upgrade bool,
	statuses map[string]bool) !PackageTypeCheckResult {
	mut errors := []string{}
	for package in packages {
		if !package_type_status(statuses, package, no_upgrade)! {
			errors << package_type_failure_reason(context, package, no_upgrade)
		}
	}
	return PackageTypeCheckResult{
		errors: errors
	}
}

pub fn package_type_find_actionable(context PackageTypeContext, entries []BundleDslEntry,
	exit_on_first_error bool, no_upgrade bool, statuses map[string]bool) !PackageTypeCheckResult {
	formatted := package_type_format_checkable(context, entries)
	packages := formatted.entries.map(it.name)
	mut result := if exit_on_first_error {
		package_type_exit_early_check(context, packages, no_upgrade, statuses)!
	} else {
		package_type_full_check(context, packages, no_upgrade, statuses)!
	}
	result = PackageTypeCheckResult{
		...result
		warnings: formatted.warnings.clone()
	}
	return result
}
