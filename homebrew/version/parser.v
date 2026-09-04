module version

import os
import regex

// Translated from Homebrew/brew `version/parser.rb`.

// ParserKind is the V equivalent of the Ruby UrlParser and StemParser subclasses.
pub enum ParserKind {
	url
	stem
}

// VersionTransform is the typed equivalent of the optional Ruby parser block.
pub type VersionTransform = fn (string) string

// RegexParser extracts the first capture from a processed URL or path.
pub struct RegexParser {
pub:
	pattern   string
	kind      ParserKind
	transform VersionTransform = identity_version_transform
}

fn identity_version_transform(value string) string {
	return value
}

// new_regex_parser translates RegexParser#initialize and validates the expression eagerly.
pub fn new_regex_parser(pattern string, kind ParserKind) !RegexParser {
	regex.regex_opt(v_regex_pattern(pattern))!
	return RegexParser{
		pattern: pattern
		kind: kind
	}
}

// new_regex_parser_with_transform preserves the optional Ruby block behavior.
pub fn new_regex_parser_with_transform(pattern string, kind ParserKind, transform VersionTransform) !RegexParser {
	regex.regex_opt(v_regex_pattern(pattern))!
	return RegexParser{
		pattern: pattern
		kind: kind
		transform: transform
	}
}

// parse performs RegexParser#parse and returns none for a blank match or capture.
pub fn (parser RegexParser) parse(spec string) ?string {
	processed := match parser.kind {
		.url { url_process_spec(spec) }
		.stem { stem_process_spec(spec) }
	}
	mut expression := regex.regex_opt(v_regex_pattern(parser.pattern)) or { return none }
	start, _ := expression.find(processed)
	if start < 0 {
		return none
	}
	version := expression.get_group_by_id(processed, 0)
	if version.trim_space() == '' {
		return none
	}
	return parser.transform(version)
}

// V's regex engine requires a leading hyphen in a character class; Ruby accepts it last.
fn v_regex_pattern(pattern string) string {
	return pattern.replace('[._-]', '[-._]').replace('[_-]', '[-_]')
}

// url_process_spec translates UrlParser.process_spec.
pub fn url_process_spec(spec string) string {
	return spec
}

// stem_process_spec translates StemParser.process_spec, including Homebrew archive stems.
pub fn stem_process_spec(spec string) string {
	if (spec.contains('sourceforge.net/') || spec.contains('sf.net/'))
		&& spec.ends_with('/download') {
		return archive_stem(os.file_name(os.dir(spec)))
	}
	basename := os.file_name(spec)
	if has_numeric_suffix_without_extension(basename) {
		return basename
	}
	return archive_stem(basename)
}

fn has_numeric_suffix_without_extension(value string) bool {
	dot := value.last_index('.') or { return false }
	if dot == value.len - 1 {
		return true
	}
	for character in value[dot + 1..] {
		if character.is_letter() {
			return false
		}
	}
	return true
}

fn archive_stem(value string) string {
	for suffix in ['.tar.gz', '.tar.bz2', '.tar.xz', '.tar.lz', '.tar.lzma', '.tar.zst', '.tgz',
		'.tbz', '.tbz2', '.txz', '.zip', '.gz', '.bz2', '.xz', '.lz', '.lzma', '.zst', '.rpm', '.deb',
		'.jar', '.war', '.phar'] {
		if value.to_lower().ends_with(suffix) {
			return value[..value.len - suffix.len]
		}
	}
	dot := value.last_index('.') or { return value }
	for character in value[dot + 1..] {
		if !character.is_letter() {
			return value
		}
	}
	return value[..dot]
}
