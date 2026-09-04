module homebrew

import homebrew.utils as brew_utils
import regex

// Translated from Homebrew/brew `search.rb`.
pub struct SearchQuery {
pub:
	value    string
	is_regex bool
}

pub enum SearchCollectionKind {
	strings
	rows
	string_map
	row_map
}

pub struct SearchOptionalString {
pub:
	present bool
	value   string
}

pub struct SearchEntry {
pub:
	key    string
	values []SearchOptionalString
}

pub struct SearchCollection {
pub:
	kind    SearchCollectionKind
	entries []SearchEntry
}

pub type SearchProjector = fn ([]string) []string

pub struct SearchArgs {
pub:
	formula  bool
	cask     bool
	eval_all bool
}

pub struct SearchFormula {
pub:
	name           string
	full_name      string
	installed      bool
	valid_platform bool = true
	deprecated     bool
	disabled       bool
}

pub enum SearchLoadErrorKind {
	unavailable
	other
}

pub struct SearchLoadError {
pub:
	kind    SearchLoadErrorKind
	message string
}

pub struct SearchFormulaState {
pub:
	full_names     []string
	aliases        []string
	fuzzy_results  map[string][]string
	formulae       map[string]SearchFormula
	errors         map[string]SearchLoadError
	output_options brew_utils.OutputOptions
}

pub struct SearchCask {
pub:
	token          string
	full_name      string
	installed      bool
	deprecated     bool
	disabled       bool
	supports_linux bool = true
}

pub struct SearchTap {
pub:
	official      bool
	core_cask_tap bool
	formula_files []string
	cask_files    []string
	cask_tokens   []string
}

pub struct SearchCaskState {
pub:
	taps           []SearchTap
	corrections    map[string][]string
	casks          map[string]SearchCask
	errors         map[string]SearchLoadError
	host_linux     bool
	output_options brew_utils.OutputOptions
}

pub struct SearchDescriptionsState {
pub:
	taps                    []SearchTap
	tap_trust_configured    bool
	formula_api             map[string]DescriptionValue
	formula_api_status      map[string]DescriptionStatus
	cask_api                map[string]DescriptionValue
	cask_api_status         map[string]DescriptionStatus
	formula_cache           map[string]DescriptionValue
	formula_cache_status    map[string]DescriptionStatus
	cask_cache              map[string]DescriptionValue
	cask_cache_status       map[string]DescriptionStatus
	installed_formulae      []DescriptionInstalledItem
	installed_casks         []DescriptionInstalledItem
	resolved_formula_status map[string]DescriptionStatus
	resolved_cask_status    map[string]DescriptionStatus
	output_options          brew_utils.OutputOptions
}

pub struct SearchContext {
pub:
	formulae     SearchFormulaState
	casks        SearchCaskState
	descriptions SearchDescriptionsState
}

pub struct SearchNames {
pub:
	formulae []string
	casks    []string
}

pub struct SearchDescriptionsRequest {
pub:
	query        SearchQuery
	args         SearchArgs
	search_type  DescriptionSearchField = .description
	show_missing bool
}

pub struct SearchDescriptionsResult {
pub:
	stdout   string
	warnings []string
	calls    []string
}

fn search_present(value string) SearchOptionalString {
	return SearchOptionalString{
		present: true
		value: value
	}
}

pub fn search_string_collection(values []string) SearchCollection {
	return SearchCollection{
		kind: .strings
		entries: values.map(SearchEntry{
			values: [search_present(it)]
		})
	}
}

pub fn search_row_collection(values [][]string) SearchCollection {
	return SearchCollection{
		kind: .rows
		entries: values.map(SearchEntry{
			values: it.map(search_present(it))
		})
	}
}

pub fn search_string_map_collection(values map[string]?string) SearchCollection {
	mut keys := values.keys()
	keys.sort()
	return SearchCollection{
		kind: .string_map
		entries: keys.map(SearchEntry{
			key: it
			values: if value := values[it] {
				[search_present(value)]
			} else {
				[SearchOptionalString{}]
			}
		})
	}
}

pub fn search_collection_strings(collection SearchCollection) []string {
	mut values := []string{}
	for entry in collection.entries {
		if entry.values.len > 0 && entry.values[0].present {
			values << entry.values[0].value
		}
	}
	return values
}

pub fn search_identity_projector(values []string) []string {
	return values.clone()
}

fn search_entry_arguments(entry SearchEntry, kind SearchCollectionKind) []string {
	mut values := []string{}
	if kind in [.string_map, .row_map] {
		values << entry.key
	}
	for value in entry.values {
		if value.present {
			values << value.value
		}
	}
	return values
}

fn search_qualified_name(value string) bool {
	parts := value.split('/')
	if parts.len != 3 || parts.any(it == '') {
		return false
	}
	for character in parts[2].bytes() {
		if !((character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character == `_` || character == `+` || character == `-` || character == `.` || character == `@`) {
			return false
		}
	}
	return true
}

fn search_unique(values []string) []string {
	mut unique := []string{}
	mut seen := map[string]bool{}
	for value in values {
		if !seen[value] {
			seen[value] = true
			unique << value
		}
	}
	return unique
}

fn search_unofficial_count(taps []SearchTap, formula bool) int {
	mut count := 0
	for tap in taps {
		if tap.official {
			continue
		}
		count += if formula { tap.formula_files.len } else { tap.cask_files.len }
	}
	return count
}

fn search_warning(kind string, count int) string {
	plural := pluralize(kind, i64(count), 's', '', false)
	return 'Set `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` to search ${count} additional ${plural} in third party taps.'
}

fn search_descriptions_output(query SearchQuery, field DescriptionSearchField,
	entries map[string]DescriptionValue, statuses map[string]DescriptionStatus,
	installed_formulae []DescriptionInstalledItem, installed_casks []DescriptionInstalledItem,
	resolved_statuses map[string]DescriptionStatus, options brew_utils.OutputOptions,
	show_missing bool) !string {
	filtered := description_search(query.value, query.is_regex, field, entries, statuses)!
	decorated := new_descriptions_with_state(filtered.entries, filtered.status_data, installed_formulae, installed_casks, resolved_statuses, options.tty.stream_is_tty, options.no_emoji)
	return decorated.print_output(show_missing)
}

// Ruby method `self.search_formulae(string_or_regex)` at line 118.
pub fn search_search_formulae(query SearchQuery,
	state SearchFormulaState) ![]string {
	if !query.is_regex && search_qualified_name(query.value) {
		formula := state.formulae[query.value] or {
			failure := state.errors[query.value] or { return []string{} }
			if failure.kind == .unavailable {
				return []string{}
			}
			return error(failure.message)
		}
		return [formula.name]
	}
	mut names := state.full_names.clone()
	names << state.aliases
	found := search_search(search_string_collection(names), query, search_identity_projector)!
	mut results := search_collection_strings(found)
	results.sort()
	if !query.is_regex {
		for fuzzy_name in state.fuzzy_results[query.value] {
			formula := state.formulae[fuzzy_name] or {
				failure := state.errors[fuzzy_name] or {
					return error('Formula ${fuzzy_name} is unavailable')
				}
				return error(failure.message)
			}
			if formula.full_name !in results {
				results << formula.full_name
			}
		}
	}
	mut output := []string{}
	for name in results {
		formula := state.formulae[name] or {
			output << brew_utils.pretty_install_status(name, brew_utils.InstallStatusOptions{
				mark_uninstalled: false
			}, state.output_options)
			continue
		}
		canonical_full_name := formula.full_name
		if name in state.aliases && canonical_full_name in results {
			continue
		}
		if !formula.valid_platform && !formula.installed {
			continue
		}
		output << brew_utils.pretty_install_status(name, brew_utils.InstallStatusOptions{
			installed: formula.installed
			deprecated: formula.deprecated
			disabled: formula.disabled
			mark_uninstalled: false
		}, state.output_options)
	}
	return output
}

// Ruby method `self.search_casks(string_or_regex)` at line 160.
pub fn search_search_casks(query SearchQuery,
	state SearchCaskState) ![]string {
	if !query.is_regex && search_qualified_name(query.value) {
		cask := state.casks[query.value] or {
			failure := state.errors[query.value] or { return []string{} }
			if failure.kind == .unavailable {
				return []string{}
			}
			return error(failure.message)
		}
		if state.host_linux && !cask.supports_linux {
			return []string{}
		}
		return [cask.token]
	}
	mut cask_tokens := []string{}
	for tap in state.taps {
		for token in tap.cask_tokens {
			if tap.official && !tap.core_cask_tap && token.starts_with('homebrew/cask') && token.count('/') >= 2 {
				cask_tokens << token.all_after_last('/')
			} else {
				cask_tokens << token
			}
		}
	}
	cask_tokens = search_unique(cask_tokens)
	found := search_search(search_string_collection(cask_tokens), query, search_identity_projector)!
	mut results := search_collection_strings(found)
	if !query.is_regex {
		results << state.corrections[query.value]
	}
	results.sort()
	mut output := []string{}
	for name in results {
		cask := state.casks[name] or {
			failure := state.errors[name] or { return error('Cask ${name} is unavailable') }
			return error(failure.message)
		}
		if state.host_linux && !cask.supports_linux {
			continue
		}
		output << brew_utils.pretty_install_status(cask.full_name, brew_utils.InstallStatusOptions{
			installed: cask.installed
			deprecated: cask.deprecated
			disabled: cask.disabled
			mark_uninstalled: false
		}, state.output_options)
	}
	return search_unique(output)
}

// Ruby method `self.search(selectable, string_or_regex, &block)` at line 223.
pub fn search_search(selectable SearchCollection, query SearchQuery,
	projector SearchProjector) !SearchCollection {
	if query.is_regex {
		return search_search_regex(selectable, query.value, projector)
	}
	return search_search_string(selectable, query.value, projector)
}

// Ruby method `self.simplify_string(string)` at line 233.
pub fn search_simplify_string(value string) string {
	mut simplified := []u8{cap: value.len}
	for character in value.to_lower().bytes() {
		if (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`) || character == `@` || character == `+` {
			simplified << character
		}
	}
	return simplified.bytestr()
}

// Ruby method `self.search_regex(selectable, regex, &_block)` at line 238.
pub fn search_search_regex(selectable SearchCollection, pattern string,
	projector SearchProjector) !SearchCollection {
	mut expression := regex.regex_opt(pattern) or { return error('/${pattern}/ is not a valid regex.') }
	mut entries := []SearchEntry{}
	for entry in selectable.entries {
		arguments := projector(search_entry_arguments(entry, selectable.kind))
		mut matched := false
		for argument in arguments {
			start, _ := expression.find(argument)
			if start >= 0 {
				matched = true
				break
			}
		}
		if matched {
			entries << entry
		}
	}
	return SearchCollection{
		kind: selectable.kind
		entries: entries
	}
}

// Ruby method `self.search_string(selectable, string, &_block)` at line 247.
pub fn search_search_string(selectable SearchCollection, value string,
	projector SearchProjector) SearchCollection {
	simplified := search_simplify_string(value)
	mut entries := []SearchEntry{}
	for entry in selectable.entries {
		arguments := projector(search_entry_arguments(entry, selectable.kind))
		if arguments.any(search_simplify_string(it).contains(simplified)) {
			entries << entry
		}
	}
	return SearchCollection{
		kind: selectable.kind
		entries: entries
	}
}
