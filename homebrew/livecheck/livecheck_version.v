module livecheck

import strconv

// Translated from Homebrew/brew `livecheck/livecheck_version.rb`.
// The original source is retained below until every stub has a typed V body.

// LivecheckVersionPackageKind is the closed package domain accepted by
// LivecheckVersion.create in the Ruby source.
pub enum LivecheckVersionPackageKind {
	formula
	cask
	resource
}

enum LivecheckVersionTokenKind {
	null_token
	alpha
	beta
	rc
	pre
	patch
	post
	numeric
	string_token
}

struct LivecheckVersionToken {
	kind   LivecheckVersionTokenKind
	text   string
	number int
}

// LivecheckVersionComponent is the local typed equivalent of a Version held by
// LivecheckVersion. The explicit null bit preserves Version::NULL independently
// of an empty string, which Version rejects.
pub struct LivecheckVersionComponent {
pub:
	value   string
	is_null bool
}

// LivecheckVersion contains each component Version in source order.
pub struct LivecheckVersion {
pub:
	versions []LivecheckVersionComponent
}

// LivecheckVersionForeignComparisonOperand represents a non-LivecheckVersion
// object, for which Ruby's <=> returns nil.
pub struct LivecheckVersionForeignComparisonOperand {}

pub type LivecheckVersionComparisonOperand = LivecheckVersion
	| LivecheckVersionForeignComparisonOperand

// new_livecheck_version_component translates Version.new at this boundary.
pub fn new_livecheck_version_component(value string) !LivecheckVersionComponent {
	if value.trim_space() == '' {
		return error('Version must not be empty')
	}
	return LivecheckVersionComponent{
		value: value
	}
}

// null_livecheck_version_component represents Version::NULL.
pub fn null_livecheck_version_component() LivecheckVersionComponent {
	return LivecheckVersionComponent{
		is_null: true
	}
}

fn livecheck_version_token(kind LivecheckVersionTokenKind, text string) LivecheckVersionToken {
	mut number := 0
	for index, character in text {
		if character.is_digit() {
			number = strconv.atoi(text[index..]) or { 0 }
			break
		}
	}
	return LivecheckVersionToken{
		kind: kind
		text: text
		number: number
	}
}

fn livecheck_version_all_digits(value string) bool {
	for character in value {
		if !character.is_digit() {
			return false
		}
	}
	return true
}

fn livecheck_version_token_create(value string) LivecheckVersionToken {
	lower := value.to_lower()
	if lower.starts_with('alpha') && livecheck_version_all_digits(lower[5..]) {
		return livecheck_version_token(.alpha, value)
	}
	if lower.starts_with('a') && lower.len > 1 && livecheck_version_all_digits(lower[1..]) {
		return livecheck_version_token(.alpha, value)
	}
	if lower.starts_with('beta') && livecheck_version_all_digits(lower[4..]) {
		return livecheck_version_token(.beta, value)
	}
	if lower.starts_with('b') && lower.len > 1 && livecheck_version_all_digits(lower[1..]) {
		return livecheck_version_token(.beta, value)
	}
	if lower.starts_with('rc') && livecheck_version_all_digits(lower[2..]) {
		return livecheck_version_token(.rc, value)
	}
	if lower.starts_with('pre') && livecheck_version_all_digits(lower[3..]) {
		return livecheck_version_token(.pre, value)
	}
	if lower.starts_with('p') && livecheck_version_all_digits(lower[1..]) {
		return livecheck_version_token(.patch, value)
	}
	if lower.len > 5 && lower[1..].starts_with('post')
		&& livecheck_version_all_digits(lower[5..]) {
		return livecheck_version_token(.post, value)
	}
	if value != '' && livecheck_version_all_digits(value) {
		return LivecheckVersionToken{
			kind: .numeric
			number: strconv.atoi(value) or { 0 }
		}
	}
	return LivecheckVersionToken{
		kind: .string_token
		text: value
	}
}

fn livecheck_version_following_digits(value string, start int) int {
	mut count := 0
	for start + count < value.len && value[start + count].is_digit() {
		count++
	}
	return count
}

fn livecheck_version_composite_length(value string) int {
	// PostToken's pinned Ruby pattern begins with an unescaped `.`, so it
	// intentionally accepts any leading character before `post`.
	if value.len > 5 && value[1..].starts_with('post') && value[5].is_digit() {
		return 5 + livecheck_version_following_digits(value, 5)
	}
	if value.starts_with('alpha') {
		return 5 + livecheck_version_following_digits(value, 5)
	}
	if value.starts_with('a') && value.len > 1 && value[1].is_digit() {
		return 1 + livecheck_version_following_digits(value, 1)
	}
	if value.starts_with('beta') {
		return 4 + livecheck_version_following_digits(value, 4)
	}
	if value.starts_with('b') && value.len > 1 && value[1].is_digit() {
		return 1 + livecheck_version_following_digits(value, 1)
	}
	if value.starts_with('pre') {
		return 3 + livecheck_version_following_digits(value, 3)
	}
	if value.starts_with('rc') {
		return 2 + livecheck_version_following_digits(value, 2)
	}
	if value.starts_with('p') {
		return 1 + livecheck_version_following_digits(value, 1)
	}
	return 0
}

fn (component LivecheckVersionComponent) tokens() []LivecheckVersionToken {
	if component.is_null {
		return []
	}
	mut tokens := []LivecheckVersionToken{}
	mut index := 0
	for index < component.value.len {
		rest := component.value[index..]
		mut length := livecheck_version_composite_length(rest.to_lower())
		if length > 0 {
			tokens << livecheck_version_token_create(rest[..length])
			index += length
			continue
		}
		if component.value[index].is_digit() {
			length = 1
			for index + length < component.value.len
				&& component.value[index + length].is_digit() {
				length++
			}
			tokens << livecheck_version_token_create(rest[..length])
			index += length
			continue
		}
		if component.value[index].is_letter() {
			length = 1
			for index + length < component.value.len
				&& component.value[index + length].is_letter() {
				length++
			}
			tokens << livecheck_version_token_create(rest[..length])
			index += length
			continue
		}
		index++
	}
	return tokens
}

fn livecheck_version_compare_ints(left int, right int) int {
	return if left < right {
		-1
	} else if left > right { 1 } else { 0 }
}

fn livecheck_version_compare_strings(left string, right string) int {
	return if left < right {
		-1
	} else if left > right { 1 } else { 0 }
}

fn livecheck_version_compare_tokens(left LivecheckVersionToken,
	right LivecheckVersionToken) int {
	if left.kind == right.kind {
		return match left.kind {
			.null_token { 0 }
			.numeric, .alpha, .beta, .rc, .pre, .patch, .post {
				livecheck_version_compare_ints(left.number, right.number)
			}
			.string_token { livecheck_version_compare_strings(left.text, right.text) }
		}
	}
	if left.kind == .null_token {
		return match right.kind {
			.numeric {
				if right.number == 0 { 0 } else { -1 }
			}
			.alpha, .beta, .pre, .rc { 1 }
			else { -1 }
		}
	}
	if right.kind == .null_token {
		return -livecheck_version_compare_tokens(right, left)
	}
	if left.kind == .numeric {
		return 1
	}
	if right.kind == .numeric {
		return -1
	}
	match left.kind {
		.alpha {
			if right.kind in [.beta, .rc, .pre, .patch, .post] {
				return -1
			}
		}
		.beta {
			if right.kind == .alpha {
				return 1
			}
			if right.kind in [.pre, .rc, .patch, .post] {
				return -1
			}
		}
		.pre {
			if right.kind in [.alpha, .beta] {
				return 1
			}
			if right.kind in [.rc, .patch, .post] {
				return -1
			}
		}
		.rc {
			if right.kind in [.alpha, .beta, .pre] {
				return 1
			}
			if right.kind in [.patch, .post] {
				return -1
			}
		}
		.patch, .post {
			if right.kind in [.alpha, .beta, .rc, .pre] {
				return 1
			}
		}
		else {}
	}
	return livecheck_version_compare_strings(left.text, right.text)
}

fn livecheck_null_token() LivecheckVersionToken {
	return LivecheckVersionToken{
		kind: .null_token
	}
}

// compare_to preserves Version#<=>, including nil for NULL-to-NULL.
pub fn (component LivecheckVersionComponent) compare_to(other LivecheckVersionComponent) ?int {
	if other.is_null {
		if component.is_null {
			return none
		}
		return 1
	}
	if component.is_null {
		return -1
	}
	if component.value == other.value {
		return 0
	}
	left_head := component.value == 'HEAD' || component.value.starts_with('HEAD-')
	right_head := other.value == 'HEAD' || other.value.starts_with('HEAD-')
	if left_head && !right_head {
		return 1
	}
	if !left_head && right_head {
		return -1
	}
	if left_head && right_head {
		return 0
	}
	left_tokens := component.tokens()
	right_tokens := other.tokens()
	maximum := if left_tokens.len > right_tokens.len { left_tokens.len } else { right_tokens.len }
	mut left_index := 0
	mut right_index := 0
	for left_index < maximum {
		left := if left_index < left_tokens.len {
			left_tokens[left_index]
		} else {
			livecheck_null_token()
		}
		right := if right_index < right_tokens.len {
			right_tokens[right_index]
		} else {
			livecheck_null_token()
		}
		if livecheck_version_compare_tokens(left, right) == 0 {
			left_index++
			right_index++
			continue
		}
		if left.kind == .numeric && right.kind != .numeric {
			if livecheck_version_compare_tokens(left, livecheck_null_token()) > 0 {
				return 1
			}
			left_index++
		} else if left.kind != .numeric && right.kind == .numeric {
			if livecheck_version_compare_tokens(right, livecheck_null_token()) > 0 {
				return -1
			}
			right_index++
		} else {
			return livecheck_version_compare_tokens(left, right)
		}
	}
	return 0
}

// equals preserves Version::NULL's deliberate non-equality with itself.
pub fn (component LivecheckVersionComponent) equals(other LivecheckVersionComponent) bool {
	return !component.is_null && (component.compare_to(other) or { return false }) == 0
}

fn ruby_split_livecheck_versions(value string) []string {
	mut parts := value.split(',')
	for parts.len > 0 && parts.last() == '' {
		parts.delete_last()
	}
	return parts
}

// create_livecheck_version translates LivecheckVersion.create.
pub fn create_livecheck_version(package_kind LivecheckVersionPackageKind,
	version LivecheckVersionComponent) !LivecheckVersion {
	versions := match package_kind {
		.formula, .resource { [version] }
		.cask {
			mut components := []LivecheckVersionComponent{}
			for part in ruby_split_livecheck_versions(version.value) {
				components << new_livecheck_version_component(part)!
			}
			components
		}
	}
	return new_livecheck_version(versions)
}

// new_livecheck_version translates LivecheckVersion#initialize.
pub fn new_livecheck_version(versions []LivecheckVersionComponent) LivecheckVersion {
	return LivecheckVersion{
		versions: versions.clone()
	}
}

// compare_livecheck_versions translates LivecheckVersion#<=> for typed values.
pub fn compare_livecheck_versions(left LivecheckVersion, right LivecheckVersion) ?int {
	maximum := if left.versions.len > right.versions.len {
		left.versions.len
	} else {
		right.versions.len
	}
	mut left_index := 0
	mut right_index := 0
	for left_index < maximum {
		left_version := if left_index < left.versions.len {
			left.versions[left_index]
		} else {
			null_livecheck_version_component()
		}
		right_version := if right_index < right.versions.len {
			right.versions[right_index]
		} else {
			null_livecheck_version_component()
		}
		if left_version.equals(right_version) {
			left_index++
			right_index++
			continue
		}
		if !left_version.is_null && right_version.is_null {
			comparison := left_version.compare_to(null_livecheck_version_component()) or {
				return none
			}
			if comparison > 0 {
				return 1
			}
			left_index++
		} else if left_version.is_null && !right_version.is_null {
			comparison := right_version.compare_to(null_livecheck_version_component()) or {
				return none
			}
			if comparison > 0 {
				return -1
			}
			right_index++
		} else {
			return left_version.compare_to(right_version)
		}
	}
	return 0
}

// compare_livecheck_version_operand retains the nil result for foreign objects.
pub fn compare_livecheck_version_operand(left LivecheckVersion,
	other LivecheckVersionComparisonOperand) ?int {
	return match other {
		LivecheckVersion { compare_livecheck_versions(left, other) }
		LivecheckVersionForeignComparisonOperand { none }
	}
}

// Ruby method `self.create(package_or_resource, version)` at line 13.
pub fn ruby_livecheck_version_l13_d1_self_create(package_kind LivecheckVersionPackageKind,
	version LivecheckVersionComponent) !LivecheckVersion {
	return create_livecheck_version(package_kind, version)
}

// Ruby attr_reader `attr_reader :versions` at line 26.
pub fn ruby_livecheck_version_l26_d2_versions(version LivecheckVersion) []LivecheckVersionComponent {
	return version.versions.clone()
}

// Ruby method `initialize(versions)` at line 29.
pub fn ruby_livecheck_version_l29_d3_initialize(versions []LivecheckVersionComponent) LivecheckVersion {
	return new_livecheck_version(versions)
}

// Ruby method `<=>(other)` at line 34.
pub fn ruby_livecheck_version_l34_d4_anonymous(version LivecheckVersion,
	other LivecheckVersionComparisonOperand) ?int {
	return compare_livecheck_version_operand(version, other)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Livecheck
// 6:     # A formula or cask version, split into its component sub-versions.
// 7:     class LivecheckVersion
// 8:       include Comparable
// 9:
// 10:       sig {
// 11:         params(package_or_resource: T.any(Formula, Cask::Cask, Resource), version: Version).returns(LivecheckVersion)
// 12:       }
// 13:       def self.create(package_or_resource, version)
// 14:         versions = case package_or_resource
// 15:         when Formula, Resource
// 16:           [version]
// 17:         when Cask::Cask
// 18:           version.to_s.split(",").map { |s| Version.new(s) }
// 19:         else
// 20:           T.absurd(package_or_resource)
// 21:         end
// 22:         new(versions)
// 23:       end
// 24:
// 25:       sig { returns(T::Array[Version]) }
// 26:       attr_reader :versions
// 27:
// 28:       sig { params(versions: T::Array[Version]).void }
// 29:       def initialize(versions)
// 30:         @versions = versions
// 31:       end
// 32:
// 33:       sig { params(other: T.untyped).returns(T.nilable(Integer)) }
// 34:       def <=>(other)
// 35:         return unless other.is_a?(LivecheckVersion)
// 36:
// 37:         lversions = versions
// 38:         rversions = other.versions
// 39:         max = [lversions.count, rversions.count].max
// 40:         l = r = 0
// 41:
// 42:         while l < max
// 43:           a = lversions[l] || Version::NULL
// 44:           b = rversions[r] || Version::NULL
// 45:
// 46:           if a == b
// 47:             l += 1
// 48:             r += 1
// 49:             next
// 50:           elsif !a.null? && b.null?
// 51:             return 1 if a > Version::NULL
// 52:
// 53:             l += 1
// 54:           elsif a.null? && !b.null?
// 55:             return -1 if b > Version::NULL
// 56:
// 57:             r += 1
// 58:           else
// 59:             return a <=> b
// 60:           end
// 61:         end
// 62:
// 63:         0
// 64:       end
// 65:     end
// 66:   end
// 67: end
