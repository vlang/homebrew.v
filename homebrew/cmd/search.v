module cmd

import ruby
import net.urllib
import regex

// Translated from Homebrew/brew `cmd/search.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct SearchCommandOptions {
pub:
	formula              bool
	cask                 bool
	desc                 bool
	eval_all             bool
	pull_request         bool
	open                 bool
	closed               bool
	verbose              bool
	package_manager      string
	named                []string
	tty                  bool
	console_width        int = 80
	tap_trust_configured bool
	no_install_from_api  bool
}

pub struct SearchCommandRequest {
pub:
	options                 SearchCommandOptions
	context                 SearchCommandContext
	missing_formula_reasons map[string]string
	pull_request_output     string
}

pub struct SearchCommandContext {
pub:
	formulae             []string
	casks                []string
	description_stdout   string
	description_warnings []string
}

pub struct SearchCommandQuery {
pub:
	value    string
	is_regex bool
}

pub struct SearchPackageManagerResult {
pub:
	found bool
	url   string
}

pub struct SearchPullRequestResult {
pub:
	query  string
	only   string
	output string
}

pub struct SearchCommandResult {
pub mut:
	stdout                    string
	warnings                  []string
	browser_url               string
	description_search        bool
	description_query         string
	description_query_regex   bool
	description_show_missing  bool
	description_calls         []string
	pull_request_search       bool
	pull_request_query        string
	pull_request_state_filter string
	failed                    bool
	error                     string
}

@[heap]
pub struct SearchCommandInput {
pub:
	request SearchCommandRequest
}

pub fn search_command_input_boundary(input &SearchCommandInput) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::SearchCmd::Input', '', {
		'search_command_input_address': u64(voidptr(input)).str()
	})
}

fn search_command_input_from_value(value ruby.Value) !&SearchCommandInput {
	address := value.attributes['search_command_input_address'] or {
		return error('invalid Search command input')
	}
	return unsafe { &SearchCommandInput(voidptr(address.u64())) }
}

fn search_ruby_inspect(value string) string {
	escaped := value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
	return '"${escaped}"'
}

fn search_command_query(query string) !SearchCommandQuery {
	if query.len >= 2 && query.starts_with('/') && query.ends_with('/') {
		pattern := query[1..query.len - 1]
		if pattern.len > 0 && pattern[0] in [`*`, `+`, `?`] {
			return error('${query} is not a valid regex.')
		}
		mut expression := regex.regex_opt(pattern) or {
			return error('${query} is not a valid regex.')
		}
		_ = expression
		return SearchCommandQuery{
			value: pattern
			is_regex: true
		}
	}
	return SearchCommandQuery{
		value: query
	}
}

fn search_command_simplify(value string) string {
	mut simplified := []u8{cap: value.len}
	for character in value.to_lower().bytes() {
		if (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`)
			|| character == `@` || character == `+` {
			simplified << character
		}
	}
	return simplified.bytestr()
}

fn search_command_names(values []string, query SearchCommandQuery) ![]string {
	mut matches := []string{}
	if query.is_regex {
		mut expression := regex.regex_opt(query.value) or {
			return error('/${query.value}/ is not a valid regex.')
		}
		for value in values {
			start, _ := expression.find(value)
			if start >= 0 {
				matches << value
			}
		}
	} else {
		needle := search_command_simplify(query.value)
		for value in values {
			if search_command_simplify(value).contains(needle) {
				matches << value
			}
		}
	}
	matches.sort()
	return matches
}

fn search_description_calls(options SearchCommandOptions) []string {
	both := !options.formula && !options.cask
	eval_all := options.eval_all || options.tap_trust_configured
	backend := if eval_all { 'cache' } else { 'api' }
	mut calls := []string{}
	if options.formula || both {
		calls << 'descriptions:formula:${backend}:eval_all=${eval_all}'
	}
	if options.cask || both {
		calls << 'descriptions:cask:${backend}:eval_all=${eval_all}'
	}
	return calls
}

fn search_named_lines(values []string, tty bool, console_width int) string {
	fallback := values.join('\n') + '\n'
	if values.len == 0 || !tty {
		return fallback
	}
	width := if console_width > 0 { console_width } else { 80 }
	gap_size := 2
	lengths := values.map(it.runes().len)
	mut max_length := 0
	for length in lengths {
		if length > max_length {
			max_length = length
		}
	}
	mut columns := (width + gap_size) / (max_length + gap_size)
	if columns < 2 {
		return fallback
	}
	rows := (values.len + columns - 1) / columns
	columns = (values.len + rows - 1) / rows
	column_width := ((width + gap_size) / columns) - gap_size
	gap := ' '.repeat(gap_size)
	mut output := ''
	for row in 0 .. rows {
		mut row_items := []string{}
		mut value_index := row
		for value_index < values.len {
			mut item := values[value_index]
			if value_index + rows < values.len {
				padding := column_width - lengths[value_index]
				if padding > 0 {
					item += ' '.repeat(padding)
				}
			}
			row_items << item
			value_index += rows
		}
		output += row_items.join(gap) + '\n'
	}
	return output
}

fn search_section(title string, values []string, tty bool, console_width int) string {
	lines := search_named_lines(values, tty, console_width)
	if !tty {
		return lines
	}
	return '==> ${title}\n${lines}'
}

pub fn search_missing_formula_help(query string, found_matches bool, tty bool,
	reason ?string) string {
	if !tty || (query.len >= 2 && query.starts_with('/') && query.ends_with('/')) {
		return ''
	}
	missing_reason := reason or { return '' }
	if found_matches {
		return '\nIf you meant ${search_ruby_inspect(query)} specifically:\n${missing_reason}\n'
	}
	return '${missing_reason}\n'
}

pub fn search_regex_help(named []string, tty bool) ?string {
	if !tty {
		return none
	}
	metacharacters := ['\\', '|', '(', ')', '[', ']', '{', '}', '^', '\$', '*', '+', '?']
	for character in metacharacters {
		for argument in named {
			if argument.contains(character) && !argument.starts_with('/') {
				return 'Did you mean to perform a regular expression search?\nSurround your query with /slashes/ to search locally by regex.'
			}
		}
	}
	return none
}

pub fn search_package_manager_url(name string, query string) ?string {
	encoded := urllib.query_escape(query)
	return match name {
		'alpine' { 'https://pkgs.alpinelinux.org/packages?name=${encoded}' }
		'repology' { 'https://repology.org/projects/?search=${encoded}' }
		'macports' { 'https://ports.macports.org/search/?q=${encoded}' }
		'fink' { 'https://pdb.finkproject.org/pdb/browse.php?summary=${encoded}' }
		'opensuse' { 'https://software.opensuse.org/search?q=${encoded}' }
		'fedora' { 'https://packages.fedoraproject.org/search?query=${encoded}' }
		'archlinux' { 'https://archlinux.org/packages/?q=${encoded}' }
		'debian' {
			'https://packages.debian.org/search?keywords=${encoded}&searchon=names&suite=all&section=all'
		}
		'ubuntu' {
			'https://packages.ubuntu.com/search?keywords=${encoded}&searchon=names&suite=all&section=all'
		}
		else { none }
	}
}

pub fn search_package_manager(options SearchCommandOptions) SearchPackageManagerResult {
	url := search_package_manager_url(options.package_manager, options.named.join(' ')) or {
		return SearchPackageManagerResult{}
	}
	return SearchPackageManagerResult{
		found: true
		url: url
	}
}

pub fn search_pull_requests(query string, open bool, closed bool,
	output string) SearchPullRequestResult {
	only := if open && !closed {
		'open'
	} else if closed && !open {
		'closed'
	} else {
		''
	}
	return SearchPullRequestResult{
		query: query
		only: only
		output: output
	}
}

pub fn print_search_results(all_formulae []string, all_casks []string, query string,
	tty bool, console_width int, missing_reason ?string) SearchCommandResult {
	mut result := SearchCommandResult{}
	count := all_formulae.len + all_casks.len
	if all_formulae.len > 0 {
		result.stdout += search_section('Formulae', all_formulae, tty, console_width)
	}
	if all_formulae.len > 0 && all_casks.len > 0 {
		result.stdout += '\n'
	}
	if all_casks.len > 0 {
		result.stdout += search_section('Casks', all_casks, tty, console_width)
	}
	if query !in all_casks {
		result.stdout += search_missing_formula_help(query, count > 0, tty, missing_reason)
	}
	if count == 0 {
		result.failed = true
		result.error = 'No formulae or casks found for ${search_ruby_inspect(query)}.'
	}
	return result
}

pub fn run_search_command(request SearchCommandRequest) !SearchCommandResult {
	options := request.options
	package_manager := search_package_manager(options)
	if package_manager.found {
		return SearchCommandResult{
			browser_url: package_manager.url
		}
	}
	if options.named.len == 0 {
		return error('at least one text or regular expression argument is required')
	}
	query := options.named.join(' ')
	string_or_regex := search_command_query(query)!
	mut result := SearchCommandResult{}
	if options.desc {
		if !options.eval_all && !options.tap_trust_configured && options.no_install_from_api {
			return error('`brew search --desc` needs `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!')
		}
		result.stdout = request.context.description_stdout
		result.warnings = request.context.description_warnings.clone()
		result.description_calls = search_description_calls(options)
		result.description_search = true
		result.description_query = string_or_regex.value
		result.description_query_regex = string_or_regex.is_regex
		result.description_show_missing = true
	} else if options.pull_request {
		pull_requests := search_pull_requests(query, options.open, options.closed, request.pull_request_output)
		result.stdout = pull_requests.output
		result.pull_request_search = true
		result.pull_request_query = pull_requests.query
		result.pull_request_state_filter = pull_requests.only
	} else {
		both := !options.formula && !options.cask
		formulae := if options.formula || both {
			search_command_names(request.context.formulae, string_or_regex)!
		} else {
			[]string{}
		}
		casks := if options.cask || both {
			search_command_names(request.context.casks, string_or_regex)!
		} else {
			[]string{}
		}
		reason := if value := request.missing_formula_reasons[query] {
			?string(value)
		} else {
			?string(none)
		}
		result = print_search_results(formulae, casks, query, options.tty, options.console_width, reason)
	}
	if options.verbose {
		result.stdout += 'Use `brew desc` to list packages with a short description.\n'
	}
	if warning := search_regex_help(options.named, options.tty) {
		result.warnings << warning
	}
	return result
}

pub fn search_command_result_value(result SearchCommandResult) ruby.Value {
	return ruby.Value{
		type_name: 'SearchCommandResult'
		repr: result.stdout
		map_data: {
			'stdout':                    ruby.string_value(result.stdout)
			'warnings':                  ruby.string_array_value(result.warnings)
			'browser_url':               ruby.string_value(result.browser_url)
			'description_search':        ruby.bool_value(result.description_search)
			'description_query':         ruby.string_value(result.description_query)
			'description_query_regex':   ruby.bool_value(result.description_query_regex)
			'description_show_missing':  ruby.bool_value(result.description_show_missing)
			'description_calls':         ruby.string_array_value(result.description_calls)
			'pull_request_search':       ruby.bool_value(result.pull_request_search)
			'pull_request_query':        ruby.string_value(result.pull_request_query)
			'pull_request_state_filter': ruby.string_value(result.pull_request_state_filter)
			'failed':                    ruby.bool_value(result.failed)
			'error':                     ruby.string_value(result.error)
		}
	}
}

// Ruby method `run` at line 67.
pub fn ruby_search_l67_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Search command input is required')
	}
	input := search_command_input_from_value(args[0]) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	result := run_search_command(input.request) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return search_command_result_value(result)
}

// Ruby method `print_missing_formula_help(query, found_matches)` at line 94.
pub fn ruby_search_l94_d2_print_missing_formula_help(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'query and found_matches are required')
	}
	reason := if args.len > 2 && args[2].type_name != 'NilClass' {
		?string(args[2].as_string())
	} else {
		?string(none)
	}
	tty := if args.len > 3 { args[3].as_bool() or { false } } else { true }
	return ruby.string_value(search_missing_formula_help(args[0].as_string(), args[1].as_bool() or { false }, tty, reason))
}

// Ruby method `print_regex_help` at line 111.
pub fn ruby_search_l111_d3_print_regex_help(args ...ruby.Value) ruby.Value {
	named := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	tty := if args.len > 1 { args[1].as_bool() or { false } } else { true }
	warning := search_regex_help(named, tty) or { return ruby.object_value('NilClass', 'nil') }
	return ruby.string_value(warning)
}

// Ruby method `search_package_manager!` at line 128.
pub fn ruby_search_l128_d4_search_package_manager(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	named := if args.len > 1 { args[1].as_string_array() or { []string{} } } else { []string{} }
	result := search_package_manager(SearchCommandOptions{
		package_manager: args[0].as_string()
		named: named
	})
	return ruby.structured_value('SearchPackageManagerResult', result.url, {
		'found': result.found.str()
		'url':   result.url
	})
}

// Ruby method `search_pull_requests(query)` at line 138.
pub fn ruby_search_l138_d5_search_pull_requests(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'query is required')
	}
	open := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	closed := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	output := if args.len > 3 { args[3].as_string() } else { '' }
	result := search_pull_requests(args[0].as_string(), open, closed, output)
	return ruby.structured_value('SearchPullRequestResult', result.output, {
		'query':  result.query
		'only':   result.only
		'output': result.output
	})
}

// Ruby method `print_results(all_formulae, all_casks, query)` at line 149.
pub fn ruby_search_l149_d6_print_results(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'formulae, casks and query are required')
	}
	formulae := args[0].as_string_array() or { return ruby.object_value('ArgumentError', err.msg()) }
	casks := args[1].as_string_array() or { return ruby.object_value('ArgumentError', err.msg()) }
	tty := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	reason := if args.len > 4 && args[4].type_name != 'NilClass' {
		?string(args[4].as_string())
	} else {
		?string(none)
	}
	return search_command_result_value(print_search_results(formulae, casks, args[2].as_string(), tty, 80, reason))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "missing_formula"
// 7: require "search"
// 8:
// 9: module Homebrew
// 10:   module Cmd
// 11:     class SearchCmd < AbstractCommand
// 12:       PACKAGE_MANAGERS = T.let({
// 13:         alpine:    ->(query) { "https://pkgs.alpinelinux.org/packages?name=#{query}" },
// 14:         repology:  ->(query) { "https://repology.org/projects/?search=#{query}" },
// 15:         macports:  ->(query) { "https://ports.macports.org/search/?q=#{query}" },
// 16:         fink:      ->(query) { "https://pdb.finkproject.org/pdb/browse.php?summary=#{query}" },
// 17:         opensuse:  ->(query) { "https://software.opensuse.org/search?q=#{query}" },
// 18:         fedora:    ->(query) { "https://packages.fedoraproject.org/search?query=#{query}" },
// 19:         archlinux: ->(query) { "https://archlinux.org/packages/?q=#{query}" },
// 20:         debian:    lambda { |query|
// 21:           "https://packages.debian.org/search?keywords=#{query}&searchon=names&suite=all&section=all"
// 22:         },
// 23:         ubuntu:    lambda { |query|
// 24:           "https://packages.ubuntu.com/search?keywords=#{query}&searchon=names&suite=all&section=all"
// 25:         },
// 26:       }.freeze, T::Hash[Symbol, T.proc.params(query: String).returns(String)])
// 27:
// 28:       cmd_args do
// 29:         description <<~EOS
// 30:           Perform a substring search of cask tokens and formula names for <text>. If <text>
// 31:           is flanked by slashes, it is interpreted as a regular expression.
// 32:         EOS
// 33:         switch "--formula", "--formulae",
// 34:                description: "Search for formulae."
// 35:         switch "--cask", "--casks",
// 36:                description: "Search for casks."
// 37:         switch "--desc",
// 38:                description: "Search for formulae with a description matching <text> and casks with " \
// 39:                             "a name or description matching <text>."
// 40:         switch "--eval-all",
// 41:                description: "Evaluate all available formulae and casks, whether installed or not, to search their " \
// 42:                             "descriptions.",
// 43:                env:         :eval_all,
// 44:                odeprecated: true
// 45:         switch "--pull-request",
// 46:                description: "Search for GitHub pull requests containing <text>."
// 47:         switch "--open",
// 48:                depends_on:  "--pull-request",
// 49:                description: "Search for only open GitHub pull requests."
// 50:         switch "--closed",
// 51:                depends_on:  "--pull-request",
// 52:                description: "Search for only closed GitHub pull requests."
// 53:         package_manager_switches = PACKAGE_MANAGERS.keys.map { |name| "--#{name}" }
// 54:         package_manager_switches.each do |s|
// 55:           switch s,
// 56:                  description: "Search for <text> in the given database."
// 57:         end
// 58:
// 59:         conflicts "--desc", "--pull-request"
// 60:         conflicts "--open", "--closed"
// 61:         conflicts(*package_manager_switches)
// 62:
// 63:         named_args :text_or_regex, min: 1
// 64:       end
// 65:
// 66:       sig { override.void }
// 67:       def run
// 68:         return if search_package_manager!
// 69:
// 70:         query = args.named.join(" ")
// 71:         string_or_regex = Search.query_regexp(query)
// 72:
// 73:         if args.desc?
// 74:           if !args.eval_all? && !Homebrew::EnvConfig.tap_trust_configured? && Homebrew::EnvConfig.no_install_from_api?
// 75:             raise UsageError,
// 76:                   "`brew search --desc` needs `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 77:                   "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 78:           end
// 79:
// 80:           Search.search_descriptions(string_or_regex, args, show_missing: true)
// 81:         elsif args.pull_request?
// 82:           search_pull_requests(query)
// 83:         else
// 84:           formulae, casks = Search.search_names(string_or_regex, args)
// 85:           print_results(formulae, casks, query)
// 86:         end
// 87:
// 88:         puts "Use `brew desc` to list packages with a short description." if args.verbose?
// 89:
// 90:         print_regex_help
// 91:       end
// 92:
// 93:       sig { params(query: String, found_matches: T::Boolean).void }
// 94:       def print_missing_formula_help(query, found_matches)
// 95:         return unless $stdout.tty?
// 96:         return if query.match?(Search::QUERY_REGEX)
// 97:
// 98:         reason = MissingFormula.reason(query, silent: true)
// 99:         return if reason.nil?
// 100:
// 101:         if found_matches
// 102:           puts
// 103:           puts "If you meant #{query.inspect} specifically:"
// 104:         end
// 105:         puts reason
// 106:       end
// 107:
// 108:       private
// 109:
// 110:       sig { void }
// 111:       def print_regex_help
// 112:         return unless $stdout.tty?
// 113:
// 114:         metacharacters = %w[\\ | ( ) [ ] { } ^ $ * + ?].freeze
// 115:         return unless metacharacters.any? do |char|
// 116:           args.named.any? do |arg|
// 117:             arg.include?(char) && !arg.start_with?("/")
// 118:           end
// 119:         end
// 120:
// 121:         opoo <<~EOS
// 122:           Did you mean to perform a regular expression search?
// 123:           Surround your query with /slashes/ to search locally by regex.
// 124:         EOS
// 125:       end
// 126:
// 127:       sig { returns(T::Boolean) }
// 128:       def search_package_manager!
// 129:         package_manager = PACKAGE_MANAGERS.find { |name,| args.public_send(:"#{name}?") }
// 130:         return false if package_manager.nil?
// 131:
// 132:         _, url = package_manager
// 133:         exec_browser url.call(URI.encode_www_form_component(args.named.join(" ")))
// 134:         true
// 135:       end
// 136:
// 137:       sig { params(query: String).void }
// 138:       def search_pull_requests(query)
// 139:         only = if args.open? && !args.closed?
// 140:           "open"
// 141:         elsif args.closed? && !args.open?
// 142:           "closed"
// 143:         end
// 144:
// 145:         GitHub.print_pull_requests_matching(query, only)
// 146:       end
// 147:
// 148:       sig { params(all_formulae: T::Array[String], all_casks: T::Array[String], query: String).void }
// 149:       def print_results(all_formulae, all_casks, query)
// 150:         count = all_formulae.size + all_casks.size
// 151:
// 152:         if all_formulae.any?
// 153:           if $stdout.tty?
// 154:             ohai "Formulae", Formatter.columns(all_formulae)
// 155:           else
// 156:             puts all_formulae
// 157:           end
// 158:         end
// 159:         puts if all_formulae.any? && all_casks.any?
// 160:         if all_casks.any?
// 161:           if $stdout.tty?
// 162:             ohai "Casks", Formatter.columns(all_casks)
// 163:           else
// 164:             puts all_casks
// 165:           end
// 166:         end
// 167:
// 168:         print_missing_formula_help(query, count.positive?) if all_casks.exclude?(query)
// 169:
// 170:         odie "No formulae or casks found for #{query.inspect}." if count.zero?
// 171:       end
// 172:     end
// 173:   end
// 174: end
