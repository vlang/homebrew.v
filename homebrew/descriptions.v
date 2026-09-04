module homebrew

import ruby
import homebrew.utils as brew_utils
import regex

// Translated from Homebrew/brew `descriptions.rb`.
pub enum DescriptionSearchField {
	name
	description
	either
}

pub enum DescriptionKind {
	formula
	cask
}

pub struct DescriptionValue {
pub:
	kind        DescriptionKind
	names       string
	description ?string
}

pub struct DescriptionStatus {
pub:
	deprecated bool
	disabled   bool
}

pub struct DescriptionInstalledItem {
pub:
	name      string
	full_name string
}

// Descriptions is the typed V equivalent of the source instance. Installed
// names and fallback status metadata are supplied explicitly so searching and
// rendering stay deterministic without loading formula or cask Ruby objects.
pub struct Descriptions {
pub:
	entries              map[string]DescriptionValue
	status_data          map[string]DescriptionStatus
	installed_formulae   []DescriptionInstalledItem
	installed_casks      []DescriptionInstalledItem
	resolved_status_data map[string]DescriptionStatus
	tty                  bool
	no_emoji             bool
}

pub fn new_descriptions(entries map[string]DescriptionValue,
	status_data map[string]DescriptionStatus) Descriptions {
	return Descriptions{
		entries: entries.clone()
		status_data: status_data.clone()
	}
}

pub fn new_descriptions_with_state(entries map[string]DescriptionValue,
	status_data map[string]DescriptionStatus, installed_formulae []DescriptionInstalledItem,
	installed_casks []DescriptionInstalledItem,
	resolved_status_data map[string]DescriptionStatus, tty bool, no_emoji bool) Descriptions {
	return Descriptions{
		entries: entries.clone()
		status_data: status_data.clone()
		installed_formulae: installed_formulae.clone()
		installed_casks: installed_casks.clone()
		resolved_status_data: resolved_status_data.clone()
		tty: tty
		no_emoji: no_emoji
	}
}

pub fn description_formula(description ?string) DescriptionValue {
	return DescriptionValue{
		kind: .formula
		description: description
	}
}

pub fn description_cask(names string, description ?string) DescriptionValue {
	return DescriptionValue{
		kind: .cask
		names: names
		description: description
	}
}

pub fn description_simplify_string(value string) string {
	mut simplified := []u8{cap: value.len}
	for character in value.to_lower().bytes() {
		if (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`) || character == `@` || character == `+` {
			simplified << character
		}
	}
	return simplified.bytestr()
}

fn description_search_values(full_name string, value DescriptionValue,
	field DescriptionSearchField) []string {
	mut fields := []string{}
	if field in [.name, .either] {
		fields << full_name
	}
	if field in [.description, .either] {
		if value.kind == .cask && value.names != '' {
			fields << value.names
		}
		if description := value.description {
			fields << description
		}
	}
	return fields
}

pub fn description_search(query string, regex_query bool, field DescriptionSearchField,
	entries map[string]DescriptionValue,
	status_data map[string]DescriptionStatus) !Descriptions {
	mut results := map[string]DescriptionValue{}
	if regex_query {
		mut expression := regex.regex_opt(query) or { return error('${query} is not a valid regex.') }
		for full_name, value in entries {
			mut matched := false
			for candidate in description_search_values(full_name, value, field) {
				start, _ := expression.find(candidate)
				if start >= 0 {
					matched = true
					break
				}
			}
			if matched {
				results[full_name] = value
			}
		}
	} else {
		needle := description_simplify_string(query)
		for full_name, value in entries {
			if description_search_values(full_name, value, field).any(description_simplify_string(it).contains(needle)) {
				results[full_name] = value
			}
		}
	}
	mut matching_status := map[string]DescriptionStatus{}
	for full_name in results.keys() {
		if status := status_data[full_name] {
			matching_status[full_name] = status
		}
	}
	return new_descriptions(results, matching_status)
}

pub fn description_installed_names(items []DescriptionInstalledItem) []string {
	mut names := []string{}
	mut seen := map[string]bool{}
	for item in items {
		for name in [item.name, item.full_name] {
			if name != '' && !seen[name] {
				seen[name] = true
				names << name
			}
		}
	}
	names.sort()
	return names
}

pub fn (descriptions Descriptions) installed_formula_names() []string {
	return description_installed_names(descriptions.installed_formulae)
}

pub fn (descriptions Descriptions) installed_cask_names() []string {
	return description_installed_names(descriptions.installed_casks)
}

pub fn (descriptions Descriptions) short_names() map[string]string {
	mut names := map[string]string{}
	for full_name in descriptions.entries.keys() {
		names[full_name] = name_from_full_name(full_name)
	}
	return names
}

pub fn (descriptions Descriptions) short_name_counts() map[string]int {
	mut counts := map[string]int{}
	for short_name in descriptions.short_names().values() {
		counts[short_name]++
	}
	return counts
}

fn (descriptions Descriptions) output_options() brew_utils.OutputOptions {
	return brew_utils.OutputOptions{
		tty: brew_utils.TtyState{
			stream_is_tty: descriptions.tty
		}
		no_emoji: descriptions.no_emoji
	}
}

pub fn (descriptions Descriptions) decorate_name(full_name string, printed_name string,
	value DescriptionValue) string {
	if !descriptions.tty {
		return printed_name
	}
	options := descriptions.output_options()
	installed_names := if value.kind == .cask {
		descriptions.installed_cask_names()
	} else {
		descriptions.installed_formula_names()
	}
	mut decorated := if full_name in installed_names {
		brew_utils.pretty_installed(printed_name, options)
	} else {
		brew_utils.formatter_bold(printed_name, options.tty)
	}
	status := descriptions.status_data[full_name] or {
		descriptions.resolved_status_data[full_name] or { return decorated }
	}
	if status.deprecated {
		decorated = brew_utils.pretty_deprecated(decorated, options)
	} else if status.disabled {
		decorated = brew_utils.pretty_disabled(decorated, options)
	}
	return decorated
}

pub fn (descriptions Descriptions) print_output(show_missing bool) string {
	short_names := descriptions.short_names()
	short_name_counts := descriptions.short_name_counts()
	mut full_names := descriptions.entries.keys()
	full_names.sort()
	mut lines := []string{}
	for full_name in full_names {
		value := descriptions.entries[full_name]
		if value.kind == .formula && value.description == none {
			continue
		}
		short_name := short_names[full_name]
		printed_name := if short_name_counts[short_name] == 1 { short_name } else { full_name }
		display_name := descriptions.decorate_name(full_name, printed_name, value)
		if value.kind == .cask {
			description := value.description or {
				if !show_missing {
					continue
				}
				brew_utils.formatter_warning('[no description]', none, descriptions.output_options().tty)
			}
			lines << if value.names != '' {
				'${display_name}: (${value.names}) ${description}'
			} else {
				'${display_name}: ${description}'
			}
		} else {
			lines << '${display_name}: ${value.description or { '' }}'
		}
	}
	return if lines.len == 0 { '' } else { '${lines.join('\n')}\n' }
}

fn description_values_from_value(value ruby.Value) map[string]DescriptionValue {
	mut entries := map[string]DescriptionValue{}
	for full_name, raw in value.map_data {
		if raw.type_name == 'Array' {
			parts := raw.as_array() or { [] }
			names := if parts.len > 0 && parts[0].type_name != 'NilClass' {
				parts[0].as_string()
			} else {
				''
			}
			description := if parts.len > 1 && parts[1].type_name != 'NilClass' {
				?string(parts[1].as_string())
			} else {
				?string(none)
			}
			entries[full_name] = description_cask(names, description)
		} else if raw.type_name == 'NilClass' {
			entries[full_name] = description_formula(none)
		} else {
			entries[full_name] = description_formula(raw.as_string())
		}
	}
	return entries
}

fn description_statuses_from_value(value ruby.Value) map[string]DescriptionStatus {
	mut statuses := map[string]DescriptionStatus{}
	for full_name, raw in value.map_data {
		deprecated_value := raw.map_data['deprecated'] or { ruby.bool_value(false) }
		disabled_value := raw.map_data['disabled'] or { ruby.bool_value(false) }
		statuses[full_name] = DescriptionStatus{
			deprecated: deprecated_value.as_bool() or { deprecated_value.as_string() == 'true' }
			disabled: disabled_value.as_bool() or { disabled_value.as_string() == 'true' }
		}
	}
	return statuses
}

fn description_installed_items_from_value(value ruby.Value) []DescriptionInstalledItem {
	return value.array_data.map(DescriptionInstalledItem{
		name: it.attributes['name'] or { it.as_string() }
		full_name: it.attributes['full_name'] or { it.as_string() }
	})
}

fn description_value_to_boundary(value DescriptionValue) ruby.Value {
	if value.kind == .cask {
		mut parts := [ruby.string_value(value.names)]
		if description := value.description {
			parts << ruby.string_value(description)
		} else {
			parts << ruby.object_value('NilClass', 'nil')
		}
		return ruby.array_value(parts)
	}
	if description := value.description {
		return ruby.string_value(description)
	}
	return ruby.object_value('NilClass', 'nil')
}

fn descriptions_to_value(descriptions Descriptions) ruby.Value {
	mut entries := map[string]ruby.Value{}
	for full_name, value in descriptions.entries {
		entries[full_name] = description_value_to_boundary(value)
	}
	mut statuses := map[string]ruby.Value{}
	for full_name, status in descriptions.status_data {
		statuses[full_name] = ruby.map_value({
			'deprecated': ruby.bool_value(status.deprecated)
			'disabled':   ruby.bool_value(status.disabled)
		})
	}
	return ruby.map_value({
		'descriptions':       ruby.map_value(entries)
		'status_data':        ruby.map_value(statuses)
		'installed_formulae': ruby.array_value(descriptions.installed_formulae.map(ruby.structured_value('Formula', it.full_name, {
			'name':      it.name
			'full_name': it.full_name
		})))
		'installed_casks':    ruby.array_value(descriptions.installed_casks.map(ruby.structured_value('Cask::Cask', it.full_name, {
			'name':      it.name
			'full_name': it.full_name
		})))
		'tty':                ruby.bool_value(descriptions.tty)
		'no_emoji':           ruby.bool_value(descriptions.no_emoji)
	})
}

fn descriptions_from_value(value ruby.Value) Descriptions {
	entries_value := value.map_data['descriptions'] or { value }
	statuses_value := value.map_data['status_data'] or { ruby.map_value({}) }
	installed_formulae := value.map_data['installed_formulae'] or { ruby.array_value([]) }
	installed_casks := value.map_data['installed_casks'] or { ruby.array_value([]) }
	tty_value := value.map_data['tty'] or { ruby.bool_value(false) }
	no_emoji_value := value.map_data['no_emoji'] or { ruby.bool_value(false) }
	return new_descriptions_with_state(description_values_from_value(entries_value), description_statuses_from_value(statuses_value), description_installed_items_from_value(installed_formulae), description_installed_items_from_value(installed_casks), {}, tty_value.as_bool() or {
		false
	}, no_emoji_value.as_bool() or { false })
}

fn description_string_map_value(values map[string]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}

fn description_count_map_value(values map[string]int) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.int_value(value)
	}
	return ruby.map_value(result)
}
