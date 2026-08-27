module vulns

import brew_runtime

// Translated from Homebrew/brew `vulns/semver.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.compare(left, right)` at line 34.
pub fn ruby_semver_l34_d1_self_compare(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.compare', ...args)
}

// Ruby method `self.parse(version)` at line 46.
pub fn ruby_semver_l46_d2_self_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.parse', ...args)
}

// Ruby method `self.compare_prerelease(left, right)` at line 57.
pub fn ruby_semver_l57_d3_self_compare_prerelease(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.compare_prerelease', ...args)
}

// Ruby method `self.compare_identifier(lhs, rhs)` at line 72.
pub fn ruby_semver_l72_d4_self_compare_identifier(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.compare_identifier', ...args)
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
