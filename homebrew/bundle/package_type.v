module bundle

import ruby
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

fn package_type_nil() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn package_type_error(type_name string, message string) ruby.Value {
	return ruby.structured_value(type_name, message, {
		'message': message
	})
}

pub fn package_type_context_value(context PackageTypeContext) ruby.Value {
	mut skipped := map[string]ruby.Value{}
	for entry_type, names in context.skipper.skipped_entries {
		skipped[entry_type] = ruby.string_array_value(names)
	}
	return ruby.map_value({
		'definition':       extensions.extension_definition_value(context.definition)
		'upgrade_formulae': ruby.string_array_value(context.upgrade_formulae)
		'failed_taps':      ruby.string_array_value(context.skipper.failed_taps)
		'skipped_entries':  ruby.map_value(skipped)
	})
}

pub fn package_type_context_from_value(value ruby.Value) PackageTypeContext {
	fields := value.as_map() or { map[string]ruby.Value{} }
	mut skipped := map[string][]string{}
	for entry_type, names in (fields['skipped_entries'] or { ruby.map_value({}) }).as_map() or {
		map[string]ruby.Value{}
	} {
		skipped[entry_type] = names.as_string_array() or { [] }
	}
	return PackageTypeContext{
		definition: extensions.extension_definition_from_value(fields['definition'] or { value })
		upgrade_formulae: (fields['upgrade_formulae'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		skipper: BundleSkipper{
			failed_taps: (fields['failed_taps'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
			skipped_entries: skipped
			initialized: true
		}
	}
}

fn package_type_entry_from_value(value ruby.Value) BundleDslEntry {
	if value.attributes.len > 0 {
		return BundleDslEntry{
			entry_type: value.attributes['type'] or { '' }
			name: value.attributes['name'] or { value.repr }
			options: value.map_data.clone()
		}
	}
	fields := value.as_map() or { map[string]ruby.Value{} }
	return BundleDslEntry{
		entry_type: (fields['type'] or { ruby.string_value('') }).as_string()
		name: (fields['name'] or { ruby.string_value(value.repr) }).as_string()
		options: (fields['options'] or { ruby.map_value({}) }).as_map() or { map[string]ruby.Value{} }
	}
}

fn package_type_entries_from_value(value ruby.Value) []BundleDslEntry {
	return value.as_array() or { [] }.map(package_type_entry_from_value(it))
}

fn package_type_entries_value(result PackageTypeEntriesResult) ruby.Value {
	return ruby.Value{
		type_name: 'Array'
		array_data: result.entries.map(bundle_dsl_entry_value(it))
		map_data: {
			'warnings': ruby.string_array_value(result.warnings)
		}
	}
}

fn package_type_check_value(result PackageTypeCheckResult) ruby.Value {
	return ruby.Value{
		type_name: 'Array'
		array_data: result.errors.map(ruby.string_value(it))
		map_data: {
			'warnings': ruby.string_array_value(result.warnings)
		}
	}
}

fn package_type_statuses_from_value(value ruby.Value) map[string]bool {
	fields := value.as_map() or { map[string]ruby.Value{} }
	mut statuses := map[string]bool{}
	for name, status in fields {
		statuses[name] = status.as_bool() or { false }
	}
	return statuses
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
