module homebrew

import ruby

// Translated from Homebrew/brew `bump_version_parser.rb`.

// BumpVersionSource records whether Ruby's parser retained a Formula Version
// object or converted a String into Cask::DSL::Version.
pub enum BumpVersionSource {
	cask
	formula
}

// BumpVersion is the common, comparable representation of the two version
// classes accepted by BumpVersionParser.
pub struct BumpVersion {
pub:
	value  string
	source BumpVersionSource
	latest bool
}

// BumpVersionParser retains optional general and architecture-specific versions.
pub struct BumpVersionParser {
pub:
	general ?BumpVersion
	arm     ?BumpVersion
	intel   ?BumpVersion
}

pub fn new_cask_bump_version(value string) BumpVersion {
	return BumpVersion{
		value: value
		source: .cask
		latest: value == 'latest'
	}
}

pub fn new_formula_bump_version(version Version) BumpVersion {
	return BumpVersion{
		value: version.to_s()
		source: .formula
		latest: false
	}
}

// new_bump_version_parser implements the source's validation after blank input
// has been normalized to none.
pub fn new_bump_version_parser(general ?BumpVersion, arm ?BumpVersion, intel ?BumpVersion) !BumpVersionParser {
	if general == none && arm == none && intel == none {
		return error('Invalid usage: `--version` must not be empty.')
	}
	return BumpVersionParser{
		general: general
		arm: arm
		intel: intel
	}
}

// new_bump_version_parser_from_strings is the typed entry point used by CLI
// callers. Ruby blank strings are treated as absent keyword values.
pub fn new_bump_version_parser_from_strings(general ?string, arm ?string, intel ?string) !BumpVersionParser {
	return new_bump_version_parser(bump_version_from_optional_string(general), bump_version_from_optional_string(arm), bump_version_from_optional_string(intel))
}

pub fn (version BumpVersion) str() string {
	return version.value
}

pub fn (version BumpVersion) equals(other BumpVersion) bool {
	return version.value == other.value
}

pub fn (parser BumpVersionParser) is_blank() bool {
	return parser.general == none && parser.arm == none && parser.intel == none
}

pub fn (parser BumpVersionParser) equals(other BumpVersionParser) bool {
	return optional_bump_versions_equal(parser.general, other.general) && optional_bump_versions_equal(parser.arm, other.arm) && optional_bump_versions_equal(parser.intel, other.intel)
}

// bump_version_parser_value and bump_version_parser_from_value provide a stable
// adapter for generic translated callers while retaining optionality and source.
pub fn bump_version_parser_value(parser BumpVersionParser) ruby.Value {
	mut attributes := map[string]string{}
	for name, version in {
		'general': parser.general
		'arm':     parser.arm
		'intel':   parser.intel
	} {
		if parsed := version {
			attributes[name] = parsed.value
			attributes['${name}_source'] = parsed.source.str()
		}
	}
	return ruby.structured_value('BumpVersionParser', bump_version_parser_repr(parser), attributes)
}

pub fn bump_version_parser_from_value(value ruby.Value) !BumpVersionParser {
	if value.type_name != 'BumpVersionParser' {
		return error('expected BumpVersionParser, got ${value.type_name}')
	}
	return BumpVersionParser{
		general: bump_version_from_attribute(value, 'general')
		arm: bump_version_from_attribute(value, 'arm')
		intel: bump_version_from_attribute(value, 'intel')
	}
}

fn bump_version_from_optional_string(value ?string) ?BumpVersion {
	text := value or { return none }
	if text.trim_space().len == 0 {
		return none
	}
	return new_cask_bump_version(text)
}

fn bump_version_from_value(value ruby.Value) ?BumpVersion {
	if value.type_name in ['Nil', 'NilClass'] || value.as_string().trim_space().len == 0 {
		return none
	}
	if value.type_name == 'Version' {
		return BumpVersion{
			value: value.as_string()
			source: .formula
		}
	}
	return new_cask_bump_version(value.as_string())
}

fn bump_version_value(version BumpVersion) ruby.Value {
	type_name := if version.source == .formula { 'Version' } else { 'Cask::DSL::Version' }
	return ruby.structured_value(type_name, version.value, {
		'value':  version.value
		'source': version.source.str()
		'latest': version.latest.str()
	})
}

fn bump_version_from_attribute(value ruby.Value, name string) ?BumpVersion {
	text := value.attributes[name] or { return none }
	if text.trim_space().len == 0 {
		return none
	}
	source := if value.attributes['${name}_source'] or { '' } == 'formula' {
		BumpVersionSource.formula
	} else {
		BumpVersionSource.cask
	}
	return BumpVersion{
		value: text
		source: source
		latest: source == .cask && text == 'latest'
	}
}

fn bump_version_parser_attribute(args []ruby.Value, name string) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', '')
	}
	parser := bump_version_parser_from_value(args[0]) or {
		return ruby.object_value('NilClass', '')
	}
	mut version := ?BumpVersion(none)
	match name {
		'general' {
			version = parser.general
		}
		'arm' {
			version = parser.arm
		}
		'intel' {
			version = parser.intel
		}
		else {}
	}
	parsed := version or { return ruby.object_value('NilClass', '') }
	return bump_version_value(parsed)
}

fn optional_bump_versions_equal(left ?BumpVersion, right ?BumpVersion) bool {
	left_version := left or {
		if _ := right {
			return false
		}
		return true
	}
	right_version := right or { return false }
	return left_version.equals(right_version)
}

fn bump_version_parser_repr(parser BumpVersionParser) string {
	general := if version := parser.general { version.value } else { 'nil' }
	arm := if version := parser.arm { version.value } else { 'nil' }
	intel := if version := parser.intel { version.value } else { 'nil' }
	return 'general=${general}, arm=${arm}, intel=${intel}'
}
