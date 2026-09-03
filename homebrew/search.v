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

pub type SearchProjector = fn([]string) []string

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
				[search_present(value)]} else {
				[SearchOptionalString{}]}
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

// Ruby method `self.query_regexp(query)` at line 39.
pub fn ruby_search_l39_d1_self_query_regexp(query string) !SearchQuery {
	if query.len >= 2 && query[0] == `/` && query[query.len - 1] == `/` {
		pattern := query[1..query.len - 1]
		// Ruby rejects a repetition operator without a preceding expression;
		// V's regex engine accepts this form, so retain Ruby's RegexpError boundary.
		if pattern.len > 0 && pattern[0] in [`*`, `+`, `?`] {
			return error('${query} is not a valid regex.')
		}
		mut expression := regex.regex_opt(pattern) or { return error('${query} is not a valid regex.') }
		_ = expression
		return SearchQuery{
			value: pattern
			is_regex: true
		}
	}
	return SearchQuery{
		value: query
	}
}

// Ruby method `self.ignore_cask?(_cask) = false` at line 50.
pub fn ruby_search_l50_d2_self_ignore_cask(_cask SearchCask) bool {
	return false
}

// Ruby method `self.search_descriptions(string_or_regex, args, search_type: nil, show_missing: false)` at line 62.
pub fn ruby_search_l62_d3_self_search_descriptions(request SearchDescriptionsRequest,
	state SearchDescriptionsState) !SearchDescriptionsResult {
	both := !request.args.formula && !request.args.cask
	eval_all := request.args.eval_all || state.tap_trust_configured
	mut stdout := ''
	mut warnings := []string{}
	mut calls := []string{}
	if request.args.formula || both {
		stdout += '${brew_utils.output_ohai('Formulae', []string{}, state.output_options)}\n'
		if eval_all {
			calls << 'descriptions:formula:cache:eval_all=true'
			stdout += search_descriptions_output(request.query, request.search_type, state.formula_cache, state.formula_cache_status, state.installed_formulae, state.installed_casks, state.resolved_formula_status, state.output_options, false)!
		} else {
			unofficial := search_unofficial_count(state.taps, true)
			if unofficial > 0 {
				warnings << search_warning('formula', unofficial)
			}
			calls << 'descriptions:formula:api:eval_all=false'
			stdout += search_descriptions_output(request.query, request.search_type, state.formula_api, state.formula_api_status, state.installed_formulae, state.installed_casks, state.resolved_formula_status, state.output_options, false)!
		}
	}
	if !request.args.cask && !both {
		return SearchDescriptionsResult{stdout, warnings, calls}
	}
	if both {
		stdout += '\n'
	}
	stdout += '${brew_utils.output_ohai('Casks', []string{}, state.output_options)}\n'
	if eval_all {
		calls << 'descriptions:cask:cache:eval_all=true'
		stdout += search_descriptions_output(request.query, request.search_type, state.cask_cache, state.cask_cache_status, state.installed_formulae, state.installed_casks, state.resolved_cask_status, state.output_options, request.show_missing)!
	} else {
		unofficial := search_unofficial_count(state.taps, false)
		if unofficial > 0 {
			warnings << search_warning('cask', unofficial)
		}
		calls << 'descriptions:cask:api:eval_all=false'
		stdout += search_descriptions_output(request.query, request.search_type, state.cask_api, state.cask_api_status, state.installed_formulae, state.installed_casks, state.resolved_cask_status, state.output_options, request.show_missing)!
	}
	return SearchDescriptionsResult{stdout, warnings, calls}
}

// Ruby method `self.search_formulae(string_or_regex)` at line 118.
pub fn ruby_search_l118_d4_self_search_formulae(query SearchQuery,
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
	found := ruby_search_l223_d7_self_search(search_string_collection(names), query, search_identity_projector)!
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
pub fn ruby_search_l160_d5_self_search_casks(query SearchQuery,
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
	found := ruby_search_l223_d7_self_search(search_string_collection(cask_tokens), query, search_identity_projector)!
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

// Ruby method `self.search_names(string_or_regex, args)` at line 207.
pub fn ruby_search_l207_d6_self_search_names(query SearchQuery, args SearchArgs,
	context SearchContext) !SearchNames {
	if !args.formula && !args.cask {
		return SearchNames{
			formulae: ruby_search_l118_d4_self_search_formulae(query, context.formulae)!
			casks: ruby_search_l160_d5_self_search_casks(query, context.casks)!
		}
	} else if args.formula {
		return SearchNames{
			formulae: ruby_search_l118_d4_self_search_formulae(query, context.formulae)!
		}
	} else if args.cask {
		return SearchNames{
			casks: ruby_search_l160_d5_self_search_casks(query, context.casks)!
		}
	}
	return SearchNames{}
}

// Ruby method `self.search(selectable, string_or_regex, &block)` at line 223.
pub fn ruby_search_l223_d7_self_search(selectable SearchCollection, query SearchQuery,
	projector SearchProjector) !SearchCollection {
	if query.is_regex {
		return ruby_search_l238_d9_self_search_regex(selectable, query.value, projector)
	}
	return ruby_search_l247_d10_self_search_string(selectable, query.value, projector)
}

// Ruby method `self.simplify_string(string)` at line 233.
pub fn ruby_search_l233_d8_self_simplify_string(value string) string {
	mut simplified := []u8{cap: value.len}
	for character in value.to_lower().bytes() {
		if (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`) || character == `@` || character == `+` {
			simplified << character
		}
	}
	return simplified.bytestr()
}

// Ruby method `self.search_regex(selectable, regex, &_block)` at line 238.
pub fn ruby_search_l238_d9_self_search_regex(selectable SearchCollection, pattern string,
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
pub fn ruby_search_l247_d10_self_search_string(selectable SearchCollection, value string,
	projector SearchProjector) SearchCollection {
	simplified := ruby_search_l233_d8_self_simplify_string(value)
	mut entries := []SearchEntry{}
	for entry in selectable.entries {
		arguments := projector(search_entry_arguments(entry, selectable.kind))
		if arguments.any(ruby_search_l233_d8_self_simplify_string(it).contains(simplified)) {
			entries << entry
		}
	}
	return SearchCollection{
		kind: selectable.kind
		entries: entries
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "description_cache_store"
// 5: require "utils/output"
// 6:
// 7: module Homebrew
// 8:   # Helper module for searching formulae or casks.
// 9:   module Search
// 10:     extend Utils::Output::Mixin
// 11:
// 12:     QUERY_REGEX = %r{^/(.*)/$}
// 13:
// 14:     SearchBlockType = T.type_alias do
// 15:       T.nilable(
// 16:         T.proc
// 17:          .params(arg0: T.any(T::Array[String], T::Array[T::Array[String]]))
// 18:          .returns(T.nilable(T.any(String, T::Array[String]))),
// 19:       )
// 20:     end
// 21:
// 22:     SearchResultType = T.type_alias do
// 23:       T.any(
// 24:         T::Array[String],
// 25:         T::Array[T::Array[String]],
// 26:         T::Hash[String, T.nilable(String)],
// 27:         T::Hash[String, T::Array[T.nilable(String)]],
// 28:       )
// 29:     end
// 30:
// 31:     SelectableType = T.type_alias do
// 32:       # These must define a `select` method that takes a block and returns an array or hash.
// 33:       # Since sorbet has minimal support for overloading sig, the return type must be casted to the actual type.
// 34:       # DescriptionCacheStore and Hash instances will return a Hash, other types will return an Array.
// 35:       T.any(DescriptionCacheStore, SearchResultType)
// 36:     end
// 37:
// 38:     sig { params(query: String).returns(T.any(Regexp, String)) }
// 39:     def self.query_regexp(query)
// 40:       if (m = query.match(QUERY_REGEX))
// 41:         Regexp.new(T.must(m[1]))
// 42:       else
// 43:         query
// 44:       end
// 45:     rescue RegexpError
// 46:       raise "#{query} is not a valid regex."
// 47:     end
// 48:
// 49:     sig { params(_cask: Cask::Cask).returns(T::Boolean) }
// 50:     def self.ignore_cask?(_cask) = false
// 51:
// 52:     T::Sig::WithoutRuntime.sig {
// 53:       params(
// 54:         string_or_regex: T.any(Regexp, String),
// 55:         # These must define `cask?`, `eval_all?`, and `formula?` methods.
// 56:         # Since only one command is typically loaded at a time, this alias is not expected to be available at runtime.
// 57:         args:            T.any(Homebrew::Cmd::Desc::Args, Homebrew::Cmd::SearchCmd::Args),
// 58:         search_type:     T.nilable(Descriptions::SearchField),
// 59:         show_missing:    T::Boolean,
// 60:       ).void
// 61:     }
// 62:     def self.search_descriptions(string_or_regex, args, search_type: nil, show_missing: false)
// 63:       require "descriptions"
// 64:
// 65:       search_type ||= Descriptions::SearchField::Description
// 66:       both = !args.formula? && !args.cask?
// 67:       eval_all = args.eval_all? || Homebrew::EnvConfig.tap_trust_configured?
// 68:
// 69:       if args.formula? || both
// 70:         ohai "Formulae"
// 71:         if eval_all
// 72:           CacheStoreDatabase.use(:descriptions) do |db|
// 73:             cache_store = DescriptionCacheStore.new(T.cast(db, CacheStoreDatabase[String, T.anything]))
// 74:             Descriptions.search(string_or_regex, search_type, cache_store, eval_all:).print
// 75:           end
// 76:         else
// 77:           unofficial = Tap.all.sum { |tap| tap.official? ? 0 : tap.formula_files.size }
// 78:           if unofficial.positive?
// 79:             opoo "Set `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` to search " \
// 80:                  "#{unofficial} additional " \
// 81:                  "#{Utils.pluralize("formula", unofficial)} in third party taps."
// 82:           end
// 83:           formulae = Homebrew::API::Internal.formula_hashes
// 84:           descriptions = formulae.transform_values { |data| data["desc"] }
// 85:           status_data = formulae.transform_values do |data|
// 86:             { deprecated: data["deprecate_present"].present?, disabled: data["disable_present"].present? }
// 87:           end
// 88:           Descriptions.search(string_or_regex, search_type, descriptions, status_data:, eval_all:).print
// 89:         end
// 90:       end
// 91:       return if !args.cask? && !both
// 92:
// 93:       puts if both
// 94:
// 95:       ohai "Casks"
// 96:       if eval_all
// 97:         CacheStoreDatabase.use(:cask_descriptions) do |db|
// 98:           cache_store = CaskDescriptionCacheStore.new(T.cast(db, CacheStoreDatabase[String, T.anything]))
// 99:           Descriptions.search(string_or_regex, search_type, cache_store, eval_all:).print(show_missing:)
// 100:         end
// 101:       else
// 102:         unofficial = Tap.all.sum { |tap| tap.official? ? 0 : tap.cask_files.size }
// 103:         if unofficial.positive?
// 104:           opoo "Set `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` to search " \
// 105:                "#{unofficial} additional " \
// 106:                "#{Utils.pluralize("cask", unofficial)} in third party taps."
// 107:         end
// 108:         casks = Homebrew::API::Internal.cask_hashes
// 109:         descriptions = casks.transform_values { |cask| [cask["names"].join(", "), cask["desc"]] }
// 110:         status_data = casks.transform_values do |cask|
// 111:           { deprecated: cask["deprecate_present"].present?, disabled: cask["disable_present"].present? }
// 112:         end
// 113:         Descriptions.search(string_or_regex, search_type, descriptions, status_data:, eval_all:).print(show_missing:)
// 114:       end
// 115:     end
// 116:
// 117:     sig { params(string_or_regex: T.any(Regexp, String)).returns(T::Array[String]) }
// 118:     def self.search_formulae(string_or_regex)
// 119:       if string_or_regex.is_a?(String) && string_or_regex.match?(HOMEBREW_TAP_FORMULA_REGEX)
// 120:         return begin
// 121:           [Formulary.factory(string_or_regex).name]
// 122:         rescue FormulaUnavailableError
// 123:           []
// 124:         end
// 125:       end
// 126:
// 127:       aliases = Formula.alias_full_names
// 128:       results = T.cast(search(Formula.full_names + aliases, string_or_regex), T::Array[String]).sort
// 129:       if string_or_regex.is_a?(String)
// 130:         results |= Formula.fuzzy_search(string_or_regex).map do |n|
// 131:           Formulary.factory(n).full_name
// 132:         end
// 133:       end
// 134:
// 135:       results.filter_map do |name|
// 136:         formula, canonical_full_name = begin
// 137:           f = Formulary.factory(name)
// 138:           [f, f.full_name]
// 139:         rescue
// 140:           [nil, name]
// 141:         end
// 142:
// 143:         # Ignore aliases from results when the full name was also found
// 144:         next if aliases.include?(name) && results.include?(canonical_full_name)
// 145:
// 146:         installed = formula&.any_version_installed? == true
// 147:         next if formula && !formula.valid_platform? && !installed
// 148:
// 149:         pretty_install_status(
// 150:           name,
// 151:           installed:,
// 152:           deprecated:       formula&.deprecated? == true,
// 153:           disabled:         formula&.disabled? == true,
// 154:           mark_uninstalled: false,
// 155:         )
// 156:       end
// 157:     end
// 158:
// 159:     sig { params(string_or_regex: T.any(Regexp, String)).returns(T::Array[String]) }
// 160:     def self.search_casks(string_or_regex)
// 161:       if string_or_regex.is_a?(String) && string_or_regex.match?(HOMEBREW_TAP_CASK_REGEX)
// 162:         return begin
// 163:           matched_cask = Cask::CaskLoader.load(string_or_regex)
// 164:           ignore_cask?(matched_cask) ? [] : [matched_cask.token]
// 165:         rescue Cask::CaskUnavailableError
// 166:           []
// 167:         end
// 168:       end
// 169:
// 170:       cask_tokens = Tap.each_with_object([]) do |tap, array|
// 171:         # We can exclude the core cask tap because `CoreCaskTap#cask_tokens` returns short names by default.
// 172:         if tap.official? && !tap.core_cask_tap?
// 173:           tap.cask_tokens.each { |token| array << token.sub(%r{^homebrew/cask.*/}, "") }
// 174:         else
// 175:           tap.cask_tokens.each { |token| array << token }
// 176:         end
// 177:       end.uniq
// 178:
// 179:       results = T.cast(search(cask_tokens, string_or_regex), T::Array[String])
// 180:       if string_or_regex.is_a?(String)
// 181:         results += DidYouMean::SpellChecker.new(dictionary: cask_tokens)
// 182:                                            .correct(string_or_regex)
// 183:       end
// 184:
// 185:       results.sort.filter_map do |name|
// 186:         cask = Cask::CaskLoader.load(name.to_s)
// 187:         next if ignore_cask?(cask)
// 188:
// 189:         pretty_install_status(
// 190:           cask.full_name,
// 191:           installed:        cask.installed?,
// 192:           deprecated:       cask.deprecated?,
// 193:           disabled:         cask.disabled?,
// 194:           mark_uninstalled: false,
// 195:         )
// 196:       end.uniq
// 197:     end
// 198:
// 199:     T::Sig::WithoutRuntime.sig {
// 200:       params(
// 201:         string_or_regex: T.any(Regexp, String),
// 202:         # These must define `cask?`, and `formula?` methods.
// 203:         # Since only one command is typically loaded at a time, this alias is not expected to be available at runtime.
// 204:         args:            T.any(Homebrew::Cmd::Desc::Args, Homebrew::Cmd::InstallCmd::Args, Homebrew::Cmd::SearchCmd::Args),
// 205:       ).returns([T::Array[String], T::Array[String]])
// 206:     }
// 207:     def self.search_names(string_or_regex, args)
// 208:       if !args.formula? && !args.cask? # both
// 209:         [search_formulae(string_or_regex), search_casks(string_or_regex)]
// 210:       elsif args.formula?
// 211:         [search_formulae(string_or_regex), []]
// 212:       elsif args.cask?
// 213:         [[], search_casks(string_or_regex)]
// 214:       else
// 215:         [[], []]
// 216:       end
// 217:     end
// 218:
// 219:     sig {
// 220:       params(selectable: SelectableType, string_or_regex: T.any(Regexp, String), block: SearchBlockType)
// 221:         .returns(SearchResultType)
// 222:     }
// 223:     def self.search(selectable, string_or_regex, &block)
// 224:       case string_or_regex
// 225:       when Regexp
// 226:         search_regex(selectable, string_or_regex, &block)
// 227:       else
// 228:         search_string(selectable, string_or_regex.to_str, &block)
// 229:       end
// 230:     end
// 231:
// 232:     sig { params(string: String).returns(String) }
// 233:     def self.simplify_string(string)
// 234:       string.downcase.gsub(/[^a-z\d@+]/i, "")
// 235:     end
// 236:
// 237:     sig { params(selectable: SelectableType, regex: Regexp, _block: SearchBlockType).returns(SearchResultType) }
// 238:     def self.search_regex(selectable, regex, &_block)
// 239:       selectable.select do |*args|
// 240:         args = yield(*args) if block_given?
// 241:         args = Array(args).flatten.compact
// 242:         args.any? { |arg| arg.match?(regex) }
// 243:       end
// 244:     end
// 245:
// 246:     sig { params(selectable: SelectableType, string: String, _block: SearchBlockType).returns(SearchResultType) }
// 247:     def self.search_string(selectable, string, &_block)
// 248:       simplified_string = simplify_string(string)
// 249:       selectable.select do |*args|
// 250:         args = yield(*args) if block_given?
// 251:         args = Array(args).flatten.compact
// 252:         args.any? { |arg| simplify_string(arg).include?(simplified_string) }
// 253:       end
// 254:     end
// 255:   end
// 256: end
// 257:
// 258: require "extend/os/search"
