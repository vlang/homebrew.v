module vulns

import brew_runtime

// Translated from Homebrew/brew `vulns/cpan_sec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.data_url = DATA_URL` at line 21.
pub fn ruby_cpan_sec_l21_d1_self_data_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.data_url', ...args)
}

// Ruby method `self.cache_filename = "cpansa.json"` at line 24.
pub fn ruby_cpan_sec_l24_d2_self_cache_filename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cache_filename', ...args)
}

// Ruby method `initialize(data)` at line 33.
pub fn ruby_cpan_sec_l33_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby attr_reader `attr_reader :meta` at line 43.
pub fn ruby_cpan_sec_l43_d4_meta(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('meta', ...args)
}

// Ruby method `distributions` at line 46.
pub fn ruby_cpan_sec_l46_d5_distributions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('distributions', ...args)
}

// Ruby method `advisories_for(distribution)` at line 51.
pub fn ruby_cpan_sec_l51_d6_advisories_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('advisories_for', ...args)
}

// Ruby method `self.range_status(advisory, version)` at line 65.
pub fn ruby_cpan_sec_l65_d7_self_range_status(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.range_status', ...args)
}

// Ruby method `self.satisfies?(target, conjunction)` at line 88.
pub fn ruby_cpan_sec_l88_d8_self_satisfies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.satisfies?', ...args)
}

// Ruby method `self.lower_bounds(conjunction)` at line 105.
pub fn ruby_cpan_sec_l105_d9_self_lower_bounds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.lower_bounds', ...args)
}

// Ruby method `build_advisory(raw)` at line 113.
pub fn ruby_cpan_sec_l113_d10_build_advisory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_advisory', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/cached_feed"
// 5: require "vulns/vulnerability"
// 6:
// 7: module Homebrew
// 8:   module Vulns
// 9:     # Loader for the CPAN Security Advisory database.
// 10:     # Source: https://github.com/briandfoy/cpan-security-advisory
// 11:     #
// 12:     # The upstream repository ships a compiled `cpan-security-advisory.json`
// 13:     # keyed on CPAN distribution name. This class fetches and caches that file
// 14:     # and exposes advisories per distribution. Evaluating `affected_versions`
// 15:     # range strings against a formula version is left to {Vulns::Match}.
// 16:     class CPANSec < CachedFeed
// 17:       DATA_URL = "https://raw.githubusercontent.com/briandfoy/cpan-security-advisory/" \
// 18:                  "master/cpan-security-advisory.json"
// 19:
// 20:       sig { override.returns(String) }
// 21:       def self.data_url = DATA_URL
// 22:
// 23:       sig { override.returns(String) }
// 24:       def self.cache_filename = "cpansa.json"
// 25:
// 26:       Advisory = Struct.new(
// 27:         :id, :cves, :affected_versions, :fixed_versions,
// 28:         :severity, :description, :references, :reported,
// 29:         keyword_init: true
// 30:       )
// 31:
// 32:       sig { override.params(data: T.anything).void }
// 33:       def initialize(data)
// 34:         super
// 35:         raise Error, "CPANSA data is not a JSON object" unless (top = as_hash(data))
// 36:         raise Error, "CPANSA data missing 'dists' key" unless (dists = as_hash(top["dists"]))
// 37:
// 38:         @dists = T.let(dists, T::Hash[String, T.untyped])
// 39:         @meta = T.let(as_hash(top["meta"]) || {}, T::Hash[String, T.untyped])
// 40:       end
// 41:
// 42:       sig { returns(T::Hash[String, T.untyped]) }
// 43:       attr_reader :meta
// 44:
// 45:       sig { returns(T::Array[String]) }
// 46:       def distributions
// 47:         @dists.keys
// 48:       end
// 49:
// 50:       sig { params(distribution: String).returns(T::Array[Advisory]) }
// 51:       def advisories_for(distribution)
// 52:         entry = @dists[distribution]
// 53:         return [] unless entry.is_a?(Hash)
// 54:
// 55:         Array(entry["advisories"]).filter_map { |a| build_advisory(a) if a.is_a?(Hash) }
// 56:       end
// 57:
// 58:       # CPANSA constraints: each `affected_versions` array entry is a
// 59:       # comma-joined AND of `<`/`<=`/`>`/`>=`/`==`/`=`/bare-version terms; the
// 60:       # array is an OR of those. `fixed_versions` uses the same grammar.
// 61:       # Compared with {Version}; Perl's decimal-vs-dotted equivalence
// 62:       # (`1.002003` == `v1.2.3`) is not modelled since homebrew-core CPAN
// 63:       # formulae uniformly use the decimal form.
// 64:       sig { params(advisory: Advisory, version: String).returns(Vulnerability::RangeStatus) }
// 65:       def self.range_status(advisory, version)
// 66:         target = Version.new(version.sub(/\Av/i, ""))
// 67:         affected = advisory.affected_versions.empty? ||
// 68:                    advisory.affected_versions.any? { |c| satisfies?(target, c) }
// 69:         bounds = advisory.fixed_versions.flat_map { |c| lower_bounds(c) }
// 70:         if affected
// 71:           fixed_in = bounds.select { |v| target < v }.min&.to_s
// 72:           Vulnerability::RangeStatus.new(state: :affected, fixed_in:).freeze
// 73:         elsif advisory.fixed_versions.any? { |c| satisfies?(target, c) }
// 74:           fixed_in = bounds.select { |v| target >= v }.max&.to_s
// 75:           Vulnerability::RangeStatus.new(state: :fixed, fixed_in:).freeze
// 76:         else
// 77:           Vulnerability::RangeStatus.new(state: :not_applicable, fixed_in: nil).freeze
// 78:         end
// 79:       end
// 80:
// 81:       CONSTRAINT = /\A\s*(<=|>=|==|<|>|=)?\s*v?(\d[\w.]*)\s*\z/
// 82:       private_constant :CONSTRAINT
// 83:
// 84:       LOWER_BOUND_OPS = [">=", ">", "==", "=", nil].freeze
// 85:       private_constant :LOWER_BOUND_OPS
// 86:
// 87:       sig { params(target: Version, conjunction: String).returns(T::Boolean) }
// 88:       def self.satisfies?(target, conjunction)
// 89:         conjunction.split(",").all? do |term|
// 90:           match = term.match(CONSTRAINT)
// 91:           next false unless match
// 92:
// 93:           bound = Version.new(T.must(match[2]))
// 94:           case match[1]
// 95:           when "<"  then target < bound
// 96:           when "<=" then target <= bound
// 97:           when ">"  then target > bound
// 98:           when ">=" then target >= bound
// 99:           else target == bound
// 100:           end
// 101:         end
// 102:       end
// 103:
// 104:       sig { params(conjunction: String).returns(T::Array[Version]) }
// 105:       def self.lower_bounds(conjunction)
// 106:         conjunction.split(",").filter_map do |term|
// 107:           match = term.match(CONSTRAINT)
// 108:           Version.new(T.must(match[2])) if match && LOWER_BOUND_OPS.include?(match[1])
// 109:         end
// 110:       end
// 111:
// 112:       sig { params(raw: T::Hash[String, T.untyped]).returns(T.nilable(Advisory)) }
// 113:       def build_advisory(raw)
// 114:         id = raw["id"]
// 115:         return if id.nil?
// 116:
// 117:         Advisory.new(
// 118:           id:,
// 119:           cves:              Array(raw["cves"]).map(&:to_s),
// 120:           affected_versions: Array(raw["affected_versions"]).map(&:to_s),
// 121:           fixed_versions:    Array(raw["fixed_versions"]).map(&:to_s),
// 122:           severity:          raw["severity"],
// 123:           description:       raw["description"],
// 124:           references:        Array(raw["references"]).map(&:to_s),
// 125:           reported:          raw["reported"],
// 126:         ).freeze
// 127:       end
// 128:     end
// 129:   end
// 130: end
