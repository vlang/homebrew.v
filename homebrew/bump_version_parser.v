module homebrew

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

fn bump_version_from_optional_string(value ?string) ?BumpVersion {
	text := value or { return none }
	if text.trim_space().len == 0 {
		return none
	}
	return new_cask_bump_version(text)
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
