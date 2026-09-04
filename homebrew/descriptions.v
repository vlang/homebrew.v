module homebrew

import ruby
import homebrew.utils as brew_utils
import regex

// Translated from Homebrew/brew `descriptions.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.search(string_or_regex, field, cache_store, status_data: {}, eval_all: Homebrew::EnvConfig.tap_trust_configured?)` at line 33.
pub fn ruby_descriptions_l33_d1_self_search(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Descriptions.search requires a query, field, and descriptions')
	}
	field := match args[1].as_string().to_lower() {
		'name' { DescriptionSearchField.name }
		'description' { DescriptionSearchField.description }
		'either' { DescriptionSearchField.either }
		else { panic('unknown description search field `${args[1].as_string()}`') }
	}
	status_data := if args.len > 3 {
		description_statuses_from_value(args[3])
	} else {
		map[string]DescriptionStatus{}
	}
	regex_query := args[0].type_name in ['Regexp', 'Regex']
	return descriptions_to_value(description_search(args[0].as_string(), regex_query, field, description_values_from_value(args[2]), status_data) or { panic(err) })
}

// Ruby method `initialize(descriptions, status_data: {})` at line 59.
pub fn ruby_descriptions_l59_d2_initialize(args ...ruby.Value) ruby.Value {
	entries := if args.len > 0 {
		description_values_from_value(args[0])
	} else {
		map[string]DescriptionValue{}
	}
	statuses := if args.len > 1 {
		description_statuses_from_value(args[1])
	} else {
		map[string]DescriptionStatus{}
	}
	return descriptions_to_value(new_descriptions(entries, statuses))
}

// Ruby method `print(show_missing: false)` at line 67.
pub fn ruby_descriptions_l67_d3_print(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	show_missing := args.len > 1 && (args[1].as_bool() or { false })
	return ruby.string_value(descriptions_from_value(args[0]).print_output(show_missing))
}

// Ruby method `decorate_name(full_name, printed_name, description)` at line 101.
pub fn ruby_descriptions_l101_d4_decorate_name(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('decorate_name requires full name, printed name, and description')
	}
	descriptions := if args.len > 3 {
		descriptions_from_value(args[3])
	} else {
		new_descriptions({}, {})
	}
	value := if args[2].type_name == 'Array' {
		description_values_from_value(ruby.map_value({
			args[0].as_string(): args[2]
		}))[args[0].as_string()]
	} else {
		description_formula(if args[2].type_name == 'NilClass' {
			none
		} else {
			args[2].as_string()
		})
	}
	return ruby.string_value(descriptions.decorate_name(args[0].as_string(), args[1].as_string(), value))
}

// Ruby method `installed_formulae` at line 141.
pub fn ruby_descriptions_l141_d5_installed_formulae(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	return ruby.string_array_value(descriptions_from_value(args[0]).installed_formula_names())
}

// Ruby method `installed_casks` at line 149.
pub fn ruby_descriptions_l149_d6_installed_casks(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	return ruby.string_array_value(descriptions_from_value(args[0]).installed_cask_names())
}

// Ruby method `short_names` at line 157.
pub fn ruby_descriptions_l157_d7_short_names(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	return description_string_map_value(descriptions_from_value(args[0]).short_names())
}

// Ruby method `short_name_counts` at line 165.
pub fn ruby_descriptions_l165_d8_short_name_counts(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	return description_count_map_value(descriptions_from_value(args[0]).short_name_counts())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "search"
// 6: require "cask/cask_loader"
// 7:
// 8: # Helper class for printing and searching descriptions.
// 9: class Descriptions
// 10:   # Enum for specifying which fields to search.
// 11:   class SearchField < T::Enum
// 12:     enums do
// 13:       # enum values are not mutable, and calling .freeze on them breaks Sorbet
// 14:       # rubocop:disable Style/MutableConstant
// 15:       Name = new
// 16:       Description = new
// 17:       Either = new
// 18:       # rubocop:enable Style/MutableConstant
// 19:     end
// 20:   end
// 21:
// 22:   # Given a regex, find all formulae whose specified fields contain a match.
// 23:   sig {
// 24:     params(
// 25:       string_or_regex: T.any(Regexp, String),
// 26:       field:           SearchField,
// 27:       cache_store:     T.any(DescriptionCacheStore, T::Hash[String, T.nilable(String)],
// 28:                              T::Hash[String, T::Array[T.nilable(String)]]),
// 29:       status_data:     T::Hash[String, T::Hash[Symbol, T::Boolean]],
// 30:       eval_all:        T::Boolean,
// 31:     ).returns(T.attached_class)
// 32:   }
// 33:   def self.search(string_or_regex, field, cache_store, status_data: {}, eval_all: Homebrew::EnvConfig.tap_trust_configured?)
// 34:     cache_store.populate_if_empty!(eval_all:) if cache_store.is_a?(DescriptionCacheStore)
// 35:
// 36:     results = case field
// 37:     when SearchField::Name
// 38:       Homebrew::Search.search(cache_store, string_or_regex) { |name, _| name }
// 39:     when SearchField::Description
// 40:       Homebrew::Search.search(cache_store, string_or_regex) { |_, desc| desc }
// 41:     when SearchField::Either
// 42:       Homebrew::Search.search(cache_store, string_or_regex)
// 43:     else
// 44:       T.absurd(field)
// 45:     end
// 46:
// 47:     results = T.cast(results, T.any(T::Hash[String, T.nilable(String)], T::Hash[String, T::Array[T.nilable(String)]]))
// 48:
// 49:     new(results, status_data: status_data.slice(*results.keys))
// 50:   end
// 51:
// 52:   # Create an actual instance.
// 53:   sig {
// 54:     params(
// 55:       descriptions: T.any(T::Hash[String, T.nilable(String)], T::Hash[String, T::Array[T.nilable(String)]]),
// 56:       status_data:  T::Hash[String, T::Hash[Symbol, T::Boolean]],
// 57:     ).void
// 58:   }
// 59:   def initialize(descriptions, status_data: {})
// 60:     @descriptions = descriptions
// 61:     @status_data = status_data
// 62:   end
// 63:
// 64:   # Take search results -- a hash mapping formula names to descriptions -- and
// 65:   # print them.
// 66:   sig { params(show_missing: T::Boolean).void }
// 67:   def print(show_missing: false)
// 68:     @descriptions.keys.sort.each do |full_name|
// 69:       description = @descriptions[full_name]
// 70:       next if description.nil?
// 71:
// 72:       short_name = short_names[full_name]
// 73:       display_name = if short_name && short_name_counts[short_name] == 1
// 74:         short_name
// 75:       else
// 76:         full_name
// 77:       end
// 78:       display_name = decorate_name(full_name, display_name, description)
// 79:       if description.is_a?(Array)
// 80:         names = description[0]
// 81:         description = description.fetch(1, nil)
// 82:         next if description.nil? && !show_missing
// 83:
// 84:         description ||= Formatter.warning("[no description]")
// 85:         puts names.present? ? "#{display_name}: (#{names}) #{description}" : "#{display_name}: #{description}"
// 86:       else
// 87:         puts "#{display_name}: #{description}"
// 88:       end
// 89:     end
// 90:   end
// 91:
// 92:   private
// 93:
// 94:   sig {
// 95:     params(
// 96:       full_name:    String,
// 97:       printed_name: String,
// 98:       description:  T.nilable(T.any(String, T::Array[T.nilable(String)])),
// 99:     ).returns(String)
// 100:   }
// 101:   def decorate_name(full_name, printed_name, description)
// 102:     return printed_name unless $stdout.tty?
// 103:
// 104:     installed = if description.is_a?(Array)
// 105:       installed_casks.include?(full_name)
// 106:     else
// 107:       installed_formulae.include?(full_name)
// 108:     end
// 109:     printed_name = if installed
// 110:       Homebrew::Search.pretty_installed(printed_name)
// 111:     else
// 112:       "#{Tty.bold}#{printed_name}#{Tty.reset}"
// 113:     end
// 114:
// 115:     status_data = @status_data[full_name]
// 116:     if status_data&.[](:deprecated)
// 117:       Homebrew::Search.pretty_deprecated(printed_name)
// 118:     elsif status_data&.[](:disabled)
// 119:       Homebrew::Search.pretty_disabled(printed_name)
// 120:     else
// 121:       formula_or_cask = begin
// 122:         Formulary.factory(full_name)
// 123:       rescue FormulaUnavailableError
// 124:         Cask::CaskLoader.load(full_name)
// 125:       rescue Cask::CaskUnavailableError
// 126:         nil
// 127:       end
// 128:       return printed_name if formula_or_cask.nil?
// 129:
// 130:       if formula_or_cask.deprecated?
// 131:         Homebrew::Search.pretty_deprecated(printed_name)
// 132:       elsif formula_or_cask.disabled?
// 133:         Homebrew::Search.pretty_disabled(printed_name)
// 134:       else
// 135:         printed_name
// 136:       end
// 137:     end
// 138:   end
// 139:
// 140:   sig { returns(T::Set[String]) }
// 141:   def installed_formulae
// 142:     @installed_formulae ||= T.let(
// 143:       Formula.installed.flat_map { |formula| [formula.name, formula.full_name] }.to_set,
// 144:       T.nilable(T::Set[String]),
// 145:     )
// 146:   end
// 147:
// 148:   sig { returns(T::Set[String]) }
// 149:   def installed_casks
// 150:     @installed_casks ||= T.let(
// 151:       Cask::Caskroom.casks.flat_map { |cask| [cask.token, cask.full_name] }.to_set,
// 152:       T.nilable(T::Set[String]),
// 153:     )
// 154:   end
// 155:
// 156:   sig { returns(T::Hash[String, String]) }
// 157:   def short_names
// 158:     @short_names ||= T.let(
// 159:       @descriptions.keys.to_h { |k| [k, Utils.name_from_full_name(k)] },
// 160:       T.nilable(T::Hash[String, String]),
// 161:     )
// 162:   end
// 163:
// 164:   sig { returns(T::Hash[String, Integer]) }
// 165:   def short_name_counts
// 166:     @short_name_counts ||= T.let(
// 167:       short_names.values
// 168:                  .tally,
// 169:       T.nilable(T::Hash[String, Integer]),
// 170:     )
// 171:   end
// 172: end
