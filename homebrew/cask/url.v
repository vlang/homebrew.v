module cask

import ruby
import net.urllib
import os
import regex

// Translated from Homebrew/brew `cask/url.rb`.
pub struct CaskURL {
pub:
	uri            string
	options        map[string]ruby.Value
	caller_path    string
	caller_line    int
	raw_line_value string
	has_raw_line   bool
}

fn cask_url_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn cask_url_header(value ruby.Value) ruby.Value {
	if value.type_name == 'NilClass' {
		return value
	}
	if value.type_name == 'Array' {
		return value
	}
	return ruby.string_array_value([value.as_string()])
}

pub fn new_cask_url(uri string, supplied map[string]ruby.Value) !CaskURL {
	urllib.parse(uri)!
	mut options := map[string]ruby.Value{}
	for key in ['verified', 'using', 'tag', 'branch', 'revisions', 'revision', 'trust_cert', 'cookies',
		'referer', 'header', 'user_agent', 'data', 'only_path'] {
		if raw := supplied[key] {
			if raw.type_name != 'NilClass' {
				options[key] = if key == 'header' { cask_url_header(raw) } else { raw }
			}
		}
	}
	if 'user_agent' !in options {
		options['user_agent'] = ruby.Value{ type_name: 'Symbol', repr: 'default' }
	}
	caller := supplied['caller_location'] or { ruby.Value{} }
	line_text := caller.attributes['lineno'] or {
		if raw := caller.map_data['lineno'] { raw.as_string() } else { '0' }
	}
	raw_line := supplied['raw_url_line'] or { ruby.Value{} }
	return CaskURL{
		uri: uri
		options: options
		caller_path: caller.attributes['path'] or {
			if raw := caller.map_data['path'] {
				raw.as_string()
			} else {
				''
			}
		}
		caller_line: line_text.int()
		raw_line_value: raw_line.as_string()
		has_raw_line: raw_line.type_name != '' && raw_line.type_name != 'NilClass'
	}
}

pub fn cask_url_value(url CaskURL) ruby.Value {
	mut values := url.options.clone()
	values['uri'] = ruby.string_value(url.uri)
	values['caller_path'] = ruby.string_value(url.caller_path)
	values['caller_line'] = ruby.int_value(url.caller_line)
	if url.has_raw_line {
		values['raw_url_line'] = ruby.string_value(url.raw_line_value)
	}
	return ruby.Value{
		type_name: 'Cask::URL'
		repr: url.uri
		map_data: values
		attributes: {
			'uri': url.uri
		}
	}
}

pub fn cask_url_from_value(value ruby.Value) !CaskURL {
	if value.type_name != 'Cask::URL' {
		return error('expected Cask::URL, got ${value.type_name}')
	}
	mut supplied := value.map_data.clone()
	if raw_path := supplied['caller_path'] {
		supplied['caller_location'] = ruby.structured_value('Thread::Backtrace::Location', raw_path.as_string(), {
			'path':   raw_path.as_string()
			'lineno': (supplied['caller_line'] or { ruby.int_value(0) }).as_string()
		})
	}
	return new_cask_url((supplied['uri'] or { ruby.string_value(value.as_string()) }).as_string(), supplied)
}

pub fn (url CaskURL) parsed() !urllib.URL {
	return urllib.parse(url.uri)
}

pub fn (url CaskURL) raw_url_line() ?string {
	if url.has_raw_line {
		return url.raw_line_value
	}
	if url.caller_path == '' || url.caller_line < 1 {
		return none
	}
	lines := os.read_lines(url.caller_path) or { return none }
	if url.caller_line > lines.len {
		return none
	}
	return '${lines[url.caller_line - 1]}\n'
}

pub fn (url CaskURL) unversioned(ignore_major_version bool) bool {
	line := url.raw_url_line() or { return false }
	url_start := line.index('url') or { return false }
	first_quote_offset := line[url_start + 3..].index('"') or { return false }
	first_quote := url_start + 3 + first_quote_offset
	second_quote_offset := line[first_quote + 1..].index('"') or { return false }
	second_quote := first_quote + 1 + second_quote_offset
	mut interpolated := line[first_quote + 1..second_quote]
	mut arch_expression := regex.regex_opt('#\\{\\s*arch\\s*\\}') or { return false }
	interpolated = arch_expression.replace(interpolated, '')
	if ignore_major_version {
		mut major_expression := regex.regex_opt('#\\{\\s*version\\s*\\.\\s*major\\s*\\}') or {
			return false
		}
		interpolated = major_expression.replace(interpolated, '')
	}
	return !interpolated.contains(r'#{')
}

fn cask_url_receiver(args []ruby.Value) ?CaskURL {
	if args.len == 0 {
		return none
	}
	return cask_url_from_value(args[0]) or { return none }
}

fn cask_url_option(args []ruby.Value, key string) ruby.Value {
	url := cask_url_receiver(args) or { return cask_url_nil() }
	return url.options[key] or { cask_url_nil() }
}
