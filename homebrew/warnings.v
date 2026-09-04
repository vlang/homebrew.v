module homebrew

// Translated from Homebrew/brew `warnings.rb`.

const parser_syntax_warning_patterns = [
	'parser/current is loading parser/ruby',
	'-compliant syntax, but you are running ',
	'https://github.com/whitequark/parser#compatibility-with-ruby-mri',
]

// WarningFilter is the explicit V equivalent of Ruby's thread-local ignored
// warning list. Passing it into a block keeps nested scopes isolated and makes
// restoration automatic when that block returns an error.
pub struct WarningFilter {
pub:
	patterns []string
}

pub fn expand_warning_patterns(patterns []string) []string {
	mut expanded := []string{}
	for pattern in patterns {
		if pattern == 'parser_syntax' {
			expanded << parser_syntax_warning_patterns
		} else {
			expanded << pattern
		}
	}
	return expanded
}

pub fn (filter WarningFilter) ignored(message string) bool {
	return filter.patterns.any(message.contains(it))
}

// emit translates Warning.warn's filter: ignored text produces no output and
// other warnings are forwarded unchanged.
pub fn (filter WarningFilter) emit(message string) string {
	return if filter.ignored(message) { '' } else { message }
}

pub fn with_ignored_warnings[T](filter WarningFilter, patterns []string,
	block fn (WarningFilter) !T) !T {
	mut nested_patterns := filter.patterns.clone()
	nested_patterns << expand_warning_patterns(patterns)
	nested := WarningFilter{
		patterns: nested_patterns
	}
	return block(nested)
}
