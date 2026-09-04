module utils

import ruby
import os
import regex

// Translated from Homebrew/brew `utils/shebang.rb`.
pub struct RewriteInfo {
pub:
	regex       string
	max_length  int
	replacement string
}

pub fn new_shebang_rewrite_info(pattern string, max_length int,
	replacement string) !RewriteInfo {
	if max_length <= 0 {
		return error('shebang maximum length must be positive')
	}
	regex.regex_opt(pattern)!
	return RewriteInfo{
		regex: pattern
		max_length: max_length
		replacement: replacement
	}
}

pub fn rewrite_info_value(info RewriteInfo) ruby.Value {
	return ruby.structured_value('Utils::Shebang::RewriteInfo', info.replacement, {
		'regex':       info.regex
		'max_length':  info.max_length.str()
		'replacement': info.replacement
	})
}

pub fn rewrite_info_from_value(value ruby.Value) !RewriteInfo {
	if value.type_name != 'Utils::Shebang::RewriteInfo' {
		return error('expected Utils::Shebang::RewriteInfo, got ${value.type_name}')
	}
	return new_shebang_rewrite_info(value.attribute('regex')!, value.attribute('max_length')!.int(), value.attribute('replacement')!)
}

fn bounded_first_line(path string, max_length int) !string {
	mut file := os.open(path)!
	bytes := file.read_bytes(max_length)
	file.close()
	probe := bytes.bytestr()
	newline := probe.index_u8(`\n`)
	if newline >= 0 {
		return probe[..newline]
	}
	return probe
}

struct ShebangProbeMatch {
	matched                bool
	matched_end            int
	separator              string
	ruby_delimiter_capture bool
}

fn shebang_probe_match(info RewriteInfo, probe string) !ShebangProbeMatch {
	ruby_delimiter := '( |\$)'
	if info.regex.ends_with(ruby_delimiter) {
		base_pattern := info.regex[..info.regex.len - ruby_delimiter.len]
		mut base_expression := regex.regex_opt(base_pattern)!
		start, end := base_expression.find(probe)
		if start != 0 || end < 0 {
			return ShebangProbeMatch{}
		}
		if end < probe.len && probe[end] != ` ` {
			return ShebangProbeMatch{}
		}
		separator := if end < probe.len { ' ' } else { '' }
		return ShebangProbeMatch{
			matched: true
			matched_end: end + separator.len
			separator: separator
			ruby_delimiter_capture: true
		}
	}
	mut expression := regex.regex_opt(info.regex)!
	start, end := expression.find(probe)
	return ShebangProbeMatch{
		matched: start >= 0
		matched_end: end
	}
}

fn ruby_capture_replacement_for_v(replacement string) string {
	// Ruby numbers its first capture as `\\1`; V's regex replacement API calls
	// that same capture `\\0`. Convert all supported single-digit references.
	mut translated := replacement
	for capture in 1 .. 10 {
		translated = translated.replace('\\${capture}', '\\${capture - 1}')
	}
	return translated
}

// rewrite_shebang reads no more than RewriteInfo.max_length bytes while deciding
// whether a file matches. A matching expression is then replaced only at its
// first occurrence, preserving capture groups such as the interpreter argument
// separator carried by the language-specific `\\1` replacements.
pub fn rewrite_shebang(info RewriteInfo, paths []string) !int {
	if info.max_length <= 0 {
		return error('shebang maximum length must be positive')
	}
	mut rewritten_count := 0
	for path in paths {
		if !os.is_file(path) {
			continue
		}
		probe := bounded_first_line(path, info.max_length)!
		probe_match := shebang_probe_match(info, probe)!
		if !probe_match.matched {
			continue
		}
		contents := os.read_file(path)!
		rewritten := if probe_match.ruby_delimiter_capture {
			replacement := info.replacement.replace('\\1', probe_match.separator)
			'#!${replacement}${contents[probe_match.matched_end..]}'
		} else {
			mut expression := regex.regex_opt(info.regex)!
			replacement := ruby_capture_replacement_for_v(info.replacement)
			// The match has already been bounded to the first line.
			expression.replace(contents, '#!${replacement}')
		}
		if rewritten == contents {
			continue
		}
		// Writing through the existing file preserves executable permission bits.
		os.write_file(path, rewritten)!
		rewritten_count++
	}
	return rewritten_count
}

fn shebang_boundary_info(args []ruby.Value) ?RewriteInfo {
	if args.len == 0 {
		return none
	}
	return rewrite_info_from_value(args[0]) or { none }
}

fn shebang_boundary_paths(args []ruby.Value) []string {
	if args.len < 2 {
		return []
	}
	mut paths := []string{}
	for argument in args[1..] {
		if argument.type_name == 'Array' {
			paths << argument.as_array() or { [] }.map(it.as_string())
		} else {
			paths << argument.as_string()
		}
	}
	return paths
}
