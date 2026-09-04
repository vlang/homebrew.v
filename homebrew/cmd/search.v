module cmd

import ruby
import net.urllib
import regex

// Translated from Homebrew/brew `cmd/search.rb`.

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
