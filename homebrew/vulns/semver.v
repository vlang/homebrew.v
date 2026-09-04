module vulns

import ruby

// Translated from Homebrew/brew `vulns/semver.rb`.
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
			'core':       ruby.string_array_value([version.major, version.minor, version.patch])
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
