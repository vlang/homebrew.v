module utils

import brew_runtime
import os
import regex

// Translated from Homebrew/brew `utils/shebang.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn rewrite_info_value(info RewriteInfo) brew_runtime.Value {
	return brew_runtime.structured_value('Utils::Shebang::RewriteInfo', info.replacement, {
		'regex':       info.regex
		'max_length':  info.max_length.str()
		'replacement': info.replacement
	})
}

pub fn rewrite_info_from_value(value brew_runtime.Value) !RewriteInfo {
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

fn shebang_boundary_info(args []brew_runtime.Value) ?RewriteInfo {
	if args.len == 0 {
		return none
	}
	return rewrite_info_from_value(args[0]) or { none }
}

fn shebang_boundary_paths(args []brew_runtime.Value) []string {
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

// Ruby attr_reader `attr_reader :regex` at line 16.
pub fn ruby_shebang_l16_d1_regex(args ...brew_runtime.Value) brew_runtime.Value {
	info := shebang_boundary_info(args) or { return brew_runtime.string_value('') }
	return brew_runtime.string_value(info.regex)
}

// Ruby attr_reader `attr_reader :max_length` at line 19.
pub fn ruby_shebang_l19_d2_max_length(args ...brew_runtime.Value) brew_runtime.Value {
	info := shebang_boundary_info(args) or { return brew_runtime.int_value(0) }
	return brew_runtime.int_value(info.max_length)
}

// Ruby attr_reader `attr_reader :replacement` at line 22.
pub fn ruby_shebang_l22_d3_replacement(args ...brew_runtime.Value) brew_runtime.Value {
	info := shebang_boundary_info(args) or { return brew_runtime.string_value('') }
	return brew_runtime.string_value(info.replacement)
}

// Ruby method `initialize(regex, max_length, replacement)` at line 25.
pub fn ruby_shebang_l25_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'expected regex, max_length, and replacement')
	}
	max_length := int(args[1].as_int() or { 0 })
	info := new_shebang_rewrite_info(args[0].as_string(), max_length, args[2].as_string()) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return rewrite_info_value(info)
}

// Ruby method `rewrite_shebang(rewrite_info, *paths)` at line 42.
pub fn ruby_shebang_l42_d5_rewrite_shebang(args ...brew_runtime.Value) brew_runtime.Value {
	info := shebang_boundary_info(args) or {
		return brew_runtime.object_value('ArgumentError', 'expected rewrite information')
	}
	rewrite_shebang(info, shebang_boundary_paths(args)) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # Helper functions for manipulating shebang lines.
// 6:   module Shebang
// 7:     extend T::Helpers
// 8:
// 9:     requires_ancestor { Kernel }
// 10:
// 11:     module_function
// 12:
// 13:     # Specification on how to rewrite a given shebang.
// 14:     class RewriteInfo
// 15:       sig { returns(Regexp) }
// 16:       attr_reader :regex
// 17:
// 18:       sig { returns(Integer) }
// 19:       attr_reader :max_length
// 20:
// 21:       sig { returns(T.any(String, Pathname)) }
// 22:       attr_reader :replacement
// 23:
// 24:       sig { params(regex: Regexp, max_length: Integer, replacement: T.any(String, Pathname)).void }
// 25:       def initialize(regex, max_length, replacement)
// 26:         @regex = regex
// 27:         @max_length = max_length
// 28:         @replacement = replacement
// 29:       end
// 30:     end
// 31:
// 32:     # Rewrite shebang for the given `paths` using the given `rewrite_info`.
// 33:     #
// 34:     # ### Example
// 35:     #
// 36:     # ```ruby
// 37:     # rewrite_shebang detected_python_shebang, bin/"script.py"
// 38:     # ```
// 39:     #
// 40:     # @api public
// 41:     sig { params(rewrite_info: RewriteInfo, paths: T.any(String, Pathname)).void }
// 42:     def rewrite_shebang(rewrite_info, *paths)
// 43:       paths.each do |f|
// 44:         f = Pathname(f)
// 45:         next unless f.file?
// 46:         next unless rewrite_info.regex.match?(f.read(rewrite_info.max_length))
// 47:
// 48:         Utils::Inreplace.inreplace f.to_s, rewrite_info.regex, "#!#{rewrite_info.replacement}"
// 49:       end
// 50:     end
// 51:   end
// 52: end
