module cask

import ruby

// Translated from Homebrew/brew `rubocops/cask/url_legacy_comma_separators.rb`.
pub const url_legacy_comma_separators_message = 'Use `version.csv.first` instead of `version.before_comma` and `version.csv.second` instead of `version.after_comma`.'

pub struct UrlLegacyCommaSeparatorOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

fn url_legacy_first_argument_end(source string, start int) int {
	if start >= source.len {
		return start
	}
	quote := source[start]
	if quote != `'` && quote != `"` {
		mut end := start
		for end < source.len && source[end] != `,` && source[end] != `\n` {
			end++
		}
		return end
	}
	mut end := start + 1
	mut escaped := false
	for end < source.len {
		if escaped {
			escaped = false
		} else if source[end] == `\\` {
			escaped = true
		} else if source[end] == quote {
			return end + 1
		}
		end++
	}
	return source.len
}

pub fn audit_url_legacy_comma_separators(source string) []UrlLegacyCommaSeparatorOffense {
	mut offenses := []UrlLegacyCommaSeparatorOffense{}
	mut line_start := 0
	for line_start < source.len {
		mut cursor := line_start
		for cursor < source.len && (source[cursor] == ` ` || source[cursor] == `\t`) {
			cursor++
		}
		if source[cursor..].starts_with('url') && cursor + 3 < source.len && (source[cursor + 3] == ` ` || source[cursor + 3] == `\t` || source[cursor + 3] == `(`) {
			cursor += 3
			if cursor < source.len && source[cursor] == `(` {
				cursor++
			}
			for cursor < source.len && (source[cursor] == ` ` || source[cursor] == `\t`) {
				cursor++
			}
			if !source[cursor..].starts_with('do') {
				argument_end := url_legacy_first_argument_end(source, cursor)
				url := source[cursor..argument_end]
				if url.contains('version.before_comma') || url.contains('version.after_comma') {
					corrected := url.replace_once('before_comma', 'csv.first').replace_once('after_comma', 'csv.second')
					offenses << UrlLegacyCommaSeparatorOffense{
						begin_pos: cursor
						end_pos: argument_end
						message: url_legacy_comma_separators_message
						replacement: corrected
					}
				}
			}
		}
		newline := source[line_start..].index_u8(`\n`)
		if newline < 0 {
			break
		}
		line_start += newline + 1
	}
	return offenses
}

pub fn correct_url_legacy_comma_separators(source string) string {
	offenses := audit_url_legacy_comma_separators(source)
	mut corrected := source
	if offenses.len == 0 {
		return corrected
	}
	for index := offenses.len - 1; index >= 0; index-- {
		offense := offenses[index]
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn url_legacy_comma_separator_value(offense UrlLegacyCommaSeparatorOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}
