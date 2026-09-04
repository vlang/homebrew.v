module vulns

import ruby

// Translated from Homebrew/brew `vulns/semver.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct SemverIdentifier {
pub:
	value   string
	numeric bool
}

pub struct SemverVersion {
pub:
	major      string
	minor      string
	patch      string
	prerelease []SemverIdentifier
	build      []string
}

pub struct SemverRange {
pub:
	lower           ?string
	upper           ?string
	upper_inclusive bool
}

fn semver_ascii_digits(value string) bool {
	return value.len > 0 && value.bytes().all(it >= `0` && it <= `9`)
}

fn semver_identifier_char(character u8) bool {
	return (character >= `0` && character <= `9`) || (character >= `A` && character <= `Z`) || (character >= `a` && character <= `z`) || character == `-`
}

fn parse_semver_core_segment(value string) ?string {
	if !semver_ascii_digits(value) || (value.len > 1 && value[0] == `0`) {
		return none
	}
	return value
}

fn parse_semver_prerelease(value string) ?[]SemverIdentifier {
	if value == '' {
		return none
	}
	mut identifiers := []SemverIdentifier{}
	for identifier in value.split('.') {
		if identifier == '' || !identifier.bytes().all(semver_identifier_char(it)) {
			return none
		}
		numeric := semver_ascii_digits(identifier)
		if numeric && identifier.len > 1 && identifier[0] == `0` {
			return none
		}
		identifiers << SemverIdentifier{
			value: identifier
			numeric: numeric
		}
	}
	return identifiers
}

fn parse_semver_build(value string) ?[]string {
	if value == '' {
		return none
	}
	mut identifiers := []string{}
	for identifier in value.split('.') {
		if identifier == '' || !identifier.bytes().all(semver_identifier_char(it)) {
			return none
		}
		identifiers << identifier
	}
	return identifiers
}

pub fn parse_semver(version string) ?SemverVersion {
	mut normalized := version.trim_space()
	if normalized.starts_with('v') {
		normalized = normalized[1..]
	}
	if normalized.starts_with('V') {
		normalized = normalized[1..]
	}
	mut precedence := normalized
	mut build := []string{}
	if plus := normalized.index('+') {
		precedence = normalized[..plus]
		build = parse_semver_build(normalized[plus + 1..]) or { return none }
	}
	mut core_text := precedence
	mut prerelease := []SemverIdentifier{}
	if hyphen := precedence.index('-') {
		core_text = precedence[..hyphen]
		prerelease = parse_semver_prerelease(precedence[hyphen + 1..]) or { return none }
	}
	segments := core_text.split('.')
	if segments.len < 1 || segments.len > 3 {
		return none
	}
	major := parse_semver_core_segment(segments[0]) or { return none }
	minor := if segments.len > 1 {
		parse_semver_core_segment(segments[1]) or { return none }
	} else {
		'0'
	}
	patch := if segments.len > 2 {
		parse_semver_core_segment(segments[2]) or { return none }
	} else {
		'0'
	}
	return SemverVersion{
		major: major
		minor: minor
		patch: patch
		prerelease: prerelease
		build: build
	}
}

fn compare_semver_numeric(left string, right string) int {
	if left.len < right.len {
		return -1
	}
	if left.len > right.len {
		return 1
	}
	if left < right {
		return -1
	}
	if left > right {
		return 1
	}
	return 0
}

pub fn compare_semver_identifier(left SemverIdentifier, right SemverIdentifier) int {
	if left.numeric && !right.numeric {
		return -1
	}
	if !left.numeric && right.numeric {
		return 1
	}
	if left.numeric {
		return compare_semver_numeric(left.value, right.value)
	}
	if left.value < right.value {
		return -1
	}
	if left.value > right.value {
		return 1
	}
	return 0
}

pub fn compare_semver_prerelease(left []SemverIdentifier, right []SemverIdentifier) int {
	if left.len == 0 && right.len == 0 {
		return 0
	}
	if left.len == 0 {
		return 1
	}
	if right.len == 0 {
		return -1
	}
	limit := if left.len < right.len { left.len } else { right.len }
	for index in 0 .. limit {
		comparison := compare_semver_identifier(left[index], right[index])
		if comparison != 0 {
			return comparison
		}
	}
	if left.len < right.len {
		return -1
	}
	if left.len > right.len {
		return 1
	}
	return 0
}

pub fn compare_parsed_semver(left SemverVersion, right SemverVersion) int {
	for segments in [[left.major, right.major], [left.minor, right.minor], [left.patch, right.patch]] {
		comparison := compare_semver_numeric(segments[0], segments[1])
		if comparison != 0 {
			return comparison
		}
	}
	return compare_semver_prerelease(left.prerelease, right.prerelease)
}

pub fn compare_semver(left string, right string) ?int {
	left_version := parse_semver(left) or { return none }
	right_version := parse_semver(right) or { return none }
	return compare_parsed_semver(left_version, right_version)
}

pub fn (interval SemverRange) contains(version string) ?bool {
	if parse_semver(version) == none {
		return none
	}
	if lower := interval.lower {
		comparison := compare_semver(version, lower) or { return none }
		if comparison < 0 {
			return false
		}
	}
	if upper := interval.upper {
		comparison := compare_semver(version, upper) or { return none }
		if interval.upper_inclusive {
			return comparison <= 0
		}
		return comparison < 0
	}
	return true
}

pub fn semver_value(version SemverVersion) ruby.Value {
	mut representation := '${version.major}.${version.minor}.${version.patch}'
	if version.prerelease.len > 0 {
		representation += '-${version.prerelease.map(it.value).join('.')}'
	}
	if version.build.len > 0 {
		representation += '+${version.build.join('.')}'
	}
	return ruby.Value{
		type_name: 'Semver'
		repr: representation
		map_data: {
			'core':       ruby.string_array_value([version.major, version.minor,
				version.patch])
			'prerelease': ruby.string_array_value(version.prerelease.map(it.value))
			'build':      ruby.string_array_value(version.build)
		}
	}
}

pub fn semver_from_value(value ruby.Value) ?SemverVersion {
	if value.type_name != 'Semver' {
		return none
	}
	return parse_semver(value.repr)
}

fn semver_identifiers_from_value(value ruby.Value) ![]SemverIdentifier {
	items := value.as_array()!
	mut identifiers := []SemverIdentifier{cap: items.len}
	for item in items {
		if item.type_name != 'String' {
			return error('SemVer prerelease identifiers must be Strings')
		}
		text := item.as_string()
		if text == '' || !text.bytes().all(semver_identifier_char(it)) {
			return error('invalid SemVer prerelease identifier `${text}`')
		}
		identifiers << SemverIdentifier{
			value: text
			numeric: semver_ascii_digits(text)
		}
	}
	return identifiers
}

// Ruby method `self.compare(left, right)` at line 34.
pub fn ruby_semver_l34_d1_self_compare(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('NilClass', 'nil')
	}
	return if comparison := compare_semver(args[0].as_string(), args[1].as_string()) {
		ruby.int_value(comparison)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `self.parse(version)` at line 46.
pub fn ruby_semver_l46_d2_self_parse(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	return if version := parse_semver(args[0].as_string()) {
		semver_value(version)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `self.compare_prerelease(left, right)` at line 57.
pub fn ruby_semver_l57_d3_self_compare_prerelease(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('NilClass', 'nil')
	}
	left := semver_identifiers_from_value(args[0]) or { panic(err) }
	right := semver_identifiers_from_value(args[1]) or { panic(err) }
	return ruby.int_value(compare_semver_prerelease(left, right))
}

// Ruby method `self.compare_identifier(lhs, rhs)` at line 72.
pub fn ruby_semver_l72_d4_self_compare_identifier(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('NilClass', 'nil')
	}
	left := SemverIdentifier{
		value: args[0].as_string()
		numeric: semver_ascii_digits(args[0].as_string())
	}
	right := SemverIdentifier{
		value: args[1].as_string()
		numeric: semver_ascii_digits(args[1].as_string())
	}
	return ruby.int_value(compare_semver_identifier(left, right))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Vulns
// 6:     # SemVer 2.0 comparison for OSV `SEMVER` ranges (https://semver.org/#spec-item-11).
// 7:     # Kept separate from `::Version`, whose ordering differs for prerelease and
// 8:     # build metadata. Minor/patch may be omitted; other spec violations return `nil`.
// 9:     module Semver
// 10:       CORE_SEGMENT = "(0|[1-9]\\d*)"
// 11:       private_constant :CORE_SEGMENT
// 12:
// 13:       # A numeric identifier without a leading zero, or an alphanumeric
// 14:       # identifier (which may start with any digit).
// 15:       PRERELEASE_IDENTIFIER = "(?:0|[1-9]\\d*|\\d*[A-Za-z-][0-9A-Za-z-]*)"
// 16:       private_constant :PRERELEASE_IDENTIFIER
// 17:
// 18:       BUILD_IDENTIFIER = "[0-9A-Za-z-]+"
// 19:       private_constant :BUILD_IDENTIFIER
// 20:
// 21:       SEMVER_REGEX = /
// 22:         \A
// 23:         #{CORE_SEGMENT}(?:\.#{CORE_SEGMENT})?(?:\.#{CORE_SEGMENT})?
// 24:         (?:-(#{PRERELEASE_IDENTIFIER}(?:\.#{PRERELEASE_IDENTIFIER})*))?
// 25:         (?:\+#{BUILD_IDENTIFIER}(?:\.#{BUILD_IDENTIFIER})*)?
// 26:         \z
// 27:       /x
// 28:       private_constant :SEMVER_REGEX
// 29:
// 30:       NUMERIC_IDENTIFIER = /\A\d+\z/
// 31:       private_constant :NUMERIC_IDENTIFIER
// 32:
// 33:       sig { params(left: String, right: String).returns(T.nilable(Integer)) }
// 34:       def self.compare(left, right)
// 35:         a = parse(left)
// 36:         b = parse(right)
// 37:         return if a.nil? || b.nil?
// 38:
// 39:         core = a.fetch(:core) <=> b.fetch(:core)
// 40:         return core unless core.zero?
// 41:
// 42:         compare_prerelease(a.fetch(:prerelease), b.fetch(:prerelease))
// 43:       end
// 44:
// 45:       sig { params(version: String).returns(T.nilable({ core: [Integer, Integer, Integer], prerelease: T::Array[String] })) }
// 46:       private_class_method def self.parse(version)
// 47:         match = version.strip.delete_prefix("v").delete_prefix("V").match(SEMVER_REGEX)
// 48:         return if match.nil?
// 49:
// 50:         {
// 51:           core:       [match[1].to_i, match[2].to_i, match[3].to_i],
// 52:           prerelease: match[4]&.split(".") || [],
// 53:         }
// 54:       end
// 55:
// 56:       sig { params(left: T::Array[String], right: T::Array[String]).returns(Integer) }
// 57:       private_class_method def self.compare_prerelease(left, right)
// 58:         return 0 if left.empty? && right.empty?
// 59:         return 1 if left.empty?
// 60:         return -1 if right.empty?
// 61:
// 62:         left.zip(right) do |lhs, rhs|
// 63:           return 1 if rhs.nil?
// 64:
// 65:           cmp = compare_identifier(lhs, rhs)
// 66:           return cmp unless cmp.zero?
// 67:         end
// 68:         (left.length == right.length) ? 0 : -1
// 69:       end
// 70:
// 71:       sig { params(lhs: String, rhs: String).returns(Integer) }
// 72:       private_class_method def self.compare_identifier(lhs, rhs)
// 73:         lhs_numeric = lhs.match?(NUMERIC_IDENTIFIER)
// 74:         rhs_numeric = rhs.match?(NUMERIC_IDENTIFIER)
// 75:
// 76:         # spec 11.4.3: numeric identifiers sort below alphanumeric
// 77:         return -1 if lhs_numeric && !rhs_numeric
// 78:         return 1 if !lhs_numeric && rhs_numeric
// 79:
// 80:         if lhs_numeric
// 81:           lhs.to_i <=> rhs.to_i
// 82:         else
// 83:           T.must(lhs <=> rhs)
// 84:         end
// 85:       end
// 86:     end
// 87:   end
// 88: end
