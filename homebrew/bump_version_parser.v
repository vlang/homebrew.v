module homebrew

import brew_runtime

// Translated from Homebrew/brew `bump_version_parser.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :arm, :general, :intel` at line 10.
pub fn ruby_bump_version_parser_l10_d1_arm(args ...brew_runtime.Value) brew_runtime.Value {
	return bump_version_parser_attribute(args, 'arm')
}

// Ruby attr_reader `attr_reader :arm, :general, :intel` at line 10.
pub fn ruby_bump_version_parser_l10_d2_general(args ...brew_runtime.Value) brew_runtime.Value {
	return bump_version_parser_attribute(args, 'general')
}

// Ruby attr_reader `attr_reader :arm, :general, :intel` at line 10.
pub fn ruby_bump_version_parser_l10_d3_intel(args ...brew_runtime.Value) brew_runtime.Value {
	return bump_version_parser_attribute(args, 'intel')
}

// Ruby method `initialize(general: nil, arm: nil, intel: nil)` at line 17.
pub fn ruby_bump_version_parser_l17_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	mut general := ?BumpVersion(none)
	mut arm := ?BumpVersion(none)
	mut intel := ?BumpVersion(none)
	if args.len == 1 && args[0].type_name == 'Hash' {
		values := args[0].map_data.clone()
		general = bump_version_from_value(values['general'] or {
			brew_runtime.object_value('NilClass', '')
		})
		arm = bump_version_from_value(values['arm'] or {
			brew_runtime.object_value('NilClass', '')
		})
		intel = bump_version_from_value(values['intel'] or {
			brew_runtime.object_value('NilClass', '')
		})
	} else {
		if args.len > 0 {
			general = bump_version_from_value(args[0])
		}
		if args.len > 1 {
			arm = bump_version_from_value(args[1])
		}
		if args.len > 2 {
			intel = bump_version_from_value(args[2])
		}
	}
	parser := new_bump_version_parser(general, arm, intel) or {
		return brew_runtime.structured_value('UsageError', err.msg(), {
			'message': err.msg()
		})
	}
	return bump_version_parser_value(parser)
}

// Ruby method `parse_version(version)` at line 30.
pub fn ruby_bump_version_parser_l30_d5_parse_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', '')
	}
	version := bump_version_from_value(args[args.len - 1]) or {
		return brew_runtime.object_value('NilClass', '')
	}
	return bump_version_value(version)
}

// Ruby method `parse_cask_version(version)` at line 43.
pub fn ruby_bump_version_parser_l43_d6_parse_cask_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', '')
	}
	return bump_version_value(new_cask_bump_version(args[args.len - 1].as_string()))
}

// Ruby method `blank?` at line 52.
pub fn ruby_bump_version_parser_l52_d7_blank(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(true)
	}
	parser := bump_version_parser_from_value(args[0]) or {
		return brew_runtime.bool_value(true)
	}
	return brew_runtime.bool_value(parser.is_blank())
}

// Ruby method `==(other)` at line 57.
pub fn ruby_bump_version_parser_l57_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	parser := bump_version_parser_from_value(args[0]) or {
		return brew_runtime.bool_value(false)
	}
	other := bump_version_parser_from_value(args[1]) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(parser.equals(other))
}

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
pub fn bump_version_parser_value(parser BumpVersionParser) brew_runtime.Value {
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
	return brew_runtime.structured_value('BumpVersionParser', bump_version_parser_repr(parser), attributes)
}

pub fn bump_version_parser_from_value(value brew_runtime.Value) !BumpVersionParser {
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

fn bump_version_from_value(value brew_runtime.Value) ?BumpVersion {
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

fn bump_version_value(version BumpVersion) brew_runtime.Value {
	type_name := if version.source == .formula { 'Version' } else { 'Cask::DSL::Version' }
	return brew_runtime.structured_value(type_name, version.value, {
		'value':  version.value
		'source': version.source.str()
		'latest': version.latest.str()
	})
}

fn bump_version_from_attribute(value brew_runtime.Value, name string) ?BumpVersion {
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

fn bump_version_parser_attribute(args []brew_runtime.Value, name string) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', '')
	}
	parser := bump_version_parser_from_value(args[0]) or {
		return brew_runtime.object_value('NilClass', '')
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
	parsed := version or { return brew_runtime.object_value('NilClass', '') }
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   # Class handling architecture-specific version information.
// 6:   class BumpVersionParser
// 7:     VERSION_SYMBOLS = [:general, :arm, :intel].freeze
// 8:
// 9:     sig { returns(T.nilable(T.any(Version, Cask::DSL::Version))) }
// 10:     attr_reader :arm, :general, :intel
// 11:
// 12:     sig {
// 13:       params(general: T.nilable(T.any(Version, String)),
// 14:              arm:     T.nilable(T.any(Version, String)),
// 15:              intel:   T.nilable(T.any(Version, String))).void
// 16:     }
// 17:     def initialize(general: nil, arm: nil, intel: nil)
// 18:       @general = T.let(parse_version(general), T.nilable(T.any(Version, Cask::DSL::Version))) if general.present?
// 19:       @arm = T.let(parse_version(arm), T.nilable(T.any(Version, Cask::DSL::Version))) if arm.present?
// 20:       @intel = T.let(parse_version(intel), T.nilable(T.any(Version, Cask::DSL::Version))) if intel.present?
// 21:
// 22:       return if @general.present?
// 23:       raise UsageError, "`--version` must not be empty." if arm.blank? && intel.blank?
// 24:     end
// 25:
// 26:     sig {
// 27:       params(version: T.any(Version, String))
// 28:         .returns(T.nilable(T.any(Version, Cask::DSL::Version)))
// 29:     }
// 30:     def parse_version(version)
// 31:       if version.is_a?(Version)
// 32:         version
// 33:       elsif version.is_a?(String)
// 34:         parse_cask_version(version)
// 35:       else
// 36:         # simplecov:disable
// 37:         T.absurd(version)
// 38:         # simplecov:enable
// 39:       end
// 40:     end
// 41:
// 42:     sig { params(version: String).returns(T.nilable(Cask::DSL::Version)) }
// 43:     def parse_cask_version(version)
// 44:       if version == "latest"
// 45:         Cask::DSL::Version.new(:latest)
// 46:       else
// 47:         Cask::DSL::Version.new(version)
// 48:       end
// 49:     end
// 50:
// 51:     sig { returns(T::Boolean) }
// 52:     def blank?
// 53:       @general.blank? && @arm.blank? && @intel.blank?
// 54:     end
// 55:
// 56:     sig { params(other: T.anything).returns(T::Boolean) }
// 57:     def ==(other)
// 58:       case other
// 59:       when BumpVersionParser
// 60:         (general == other.general) && (arm == other.arm) && (intel == other.intel)
// 61:       else
// 62:         false
// 63:       end
// 64:     end
// 65:   end
// 66: end
