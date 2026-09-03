module version

import os
import regex

// Translated from Homebrew/brew `version/parser.rb`.
// The original source is retained below until every stub has a typed V body.

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
		kind:    kind
	}
}

// new_regex_parser_with_transform preserves the optional Ruby block behavior.
pub fn new_regex_parser_with_transform(pattern string, kind ParserKind, transform VersionTransform) !RegexParser {
	regex.regex_opt(v_regex_pattern(pattern))!
	return RegexParser{
		pattern:   pattern
		kind:      kind
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
		'.tbz', '.tbz2', '.txz', '.zip', '.gz', '.bz2', '.xz', '.lz', '.lzma', '.zst', '.rpm',
		'.deb', '.jar', '.war', '.phar'] {
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

// Ruby method `parse(spec); end` at line 11.
pub fn ruby_parser_l11_d1_parse(parser RegexParser, spec string) ?string {
	return parser.parse(spec)
}

// Ruby method `initialize(regex, &block)` at line 20.
pub fn ruby_parser_l20_d2_initialize(pattern string, kind ParserKind) !RegexParser {
	return new_regex_parser(pattern, kind)
}

// Ruby method `parse(spec)` at line 27.
pub fn ruby_parser_l27_d3_parse(parser RegexParser, spec string) ?string {
	return parser.parse(spec)
}

// Ruby method `self.process_spec(spec)` at line 39.
pub fn ruby_parser_l39_d4_self_process_spec(spec string) !string {
	return error('Version::RegexParser.process_spec must be implemented for ${spec}')
}

// Ruby method `self.process_spec(spec)` at line 46.
pub fn ruby_parser_l46_d5_self_process_spec(spec string) string {
	return url_process_spec(spec)
}

// Ruby method `self.process_spec(spec)` at line 56.
pub fn ruby_parser_l56_d6_self_process_spec(spec string) string {
	return stem_process_spec(spec)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Version
// 5:   class Parser
// 6:     extend T::Helpers
// 7:
// 8:     abstract!
// 9:
// 10:     sig { abstract.params(spec: Pathname).returns(T.nilable(String)) }
// 11:     def parse(spec); end
// 12:   end
// 13:
// 14:   class RegexParser < Parser
// 15:     extend T::Helpers
// 16:
// 17:     abstract!
// 18:
// 19:     sig { params(regex: Regexp, block: T.nilable(T.proc.params(arg0: String).returns(String))).void }
// 20:     def initialize(regex, &block)
// 21:       super()
// 22:       @regex = regex
// 23:       @block = block
// 24:     end
// 25:
// 26:     sig { override.params(spec: Pathname).returns(T.nilable(String)) }
// 27:     def parse(spec)
// 28:       match = @regex.match(self.class.process_spec(spec))
// 29:       return if match.blank?
// 30:
// 31:       version = match.captures.first
// 32:       return if version.blank?
// 33:       return @block.call(version) if @block.present?
// 34:
// 35:       version
// 36:     end
// 37:
// 38:     sig { params(spec: Pathname).returns(String) }
// 39:     def self.process_spec(spec)
// 40:       raise NotImplementedError, "#{name}.process_spec must be implemented for #{spec}"
// 41:     end
// 42:   end
// 43:
// 44:   class UrlParser < RegexParser
// 45:     sig { override.params(spec: Pathname).returns(String) }
// 46:     def self.process_spec(spec)
// 47:       spec.to_s
// 48:     end
// 49:   end
// 50:
// 51:   class StemParser < RegexParser
// 52:     SOURCEFORGE_DOWNLOAD_REGEX = %r{(?:sourceforge\.net|sf\.net)/.*/download$}
// 53:     NO_FILE_EXTENSION_REGEX = /\.[^a-zA-Z]+$/
// 54:
// 55:     sig { override.params(spec: Pathname).returns(String) }
// 56:     def self.process_spec(spec)
// 57:       spec_s = spec.to_s
// 58:       return spec.dirname.stem if spec_s.match?(SOURCEFORGE_DOWNLOAD_REGEX)
// 59:       return spec.basename.to_s if spec_s.match?(NO_FILE_EXTENSION_REGEX)
// 60:
// 61:       spec.stem
// 62:     end
// 63:   end
// 64: end
