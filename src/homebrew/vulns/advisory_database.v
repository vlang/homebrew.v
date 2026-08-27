module vulns

import brew_runtime

// Translated from Homebrew/brew `vulns/advisory_database.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.data_url = DATA_URL` at line 21.
pub fn ruby_advisory_database_l21_d1_self_data_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.data_url', ...args)
}

// Ruby method `self.cache_filename = "advisories.json"` at line 24.
pub fn ruby_advisory_database_l24_d2_self_cache_filename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cache_filename', ...args)
}

// Ruby method `initialize(data)` at line 27.
pub fn ruby_advisory_database_l27_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby attr_reader `attr_reader :meta` at line 40.
pub fn ruby_advisory_database_l40_d4_meta(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('meta', ...args)
}

// Ruby method `formulae` at line 43.
pub fn ruby_advisory_database_l43_d5_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae', ...args)
}

// Ruby method `records_for(formula_name)` at line 50.
pub fn ruby_advisory_database_l50_d6_records_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('records_for', ...args)
}

// Ruby method `to_api_hash` at line 58.
pub fn ruby_advisory_database_l58_d7_to_api_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_api_hash', ...args)
}

// Ruby method `status_for(formula_name, pkg_version)` at line 75.
pub fn ruby_advisory_database_l75_d8_status_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('status_for', ...args)
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
// 9:     # Reader for the concatenated `BREW-*` OSV corpus published by
// 10:     # Homebrew/advisory-database at `data/advisories.json` (built by that
// 11:     # repository's `AdvisoryIndex` via `rake advisories:concat`).
// 12:     #
// 13:     # Consumed by `brew generate-formula-api` to attach a `vulnerabilities`
// 14:     # field to each formula's API JSON, and by `brew vulns` (Phase 4) as the
// 15:     # local `ecosystem: Homebrew` range source until osv.dev ingests the feed.
// 16:     class AdvisoryDatabase < CachedFeed
// 17:       DATA_URL = "https://raw.githubusercontent.com/Homebrew/advisory-database/" \
// 18:                  "main/data/advisories.json"
// 19:
// 20:       sig { override.returns(String) }
// 21:       def self.data_url = DATA_URL
// 22:
// 23:       sig { override.returns(String) }
// 24:       def self.cache_filename = "advisories.json"
// 25:
// 26:       sig { override.params(data: T.anything).void }
// 27:       def initialize(data)
// 28:         super
// 29:         raise Error, "advisory index is not a JSON object" unless (top = as_hash(data))
// 30:         raise Error, "advisory index has no 'advisories' key" unless top.key?("advisories")
// 31:         unless (advisories = as_hash(top["advisories"]))
// 32:           raise Error, "advisory index 'advisories' is not a JSON object"
// 33:         end
// 34:
// 35:         @advisories = T.let(advisories, T::Hash[String, T.untyped])
// 36:         @meta = T.let(as_hash(top["meta"]) || {}, T::Hash[String, T.untyped])
// 37:       end
// 38:
// 39:       sig { returns(T::Hash[String, T.untyped]) }
// 40:       attr_reader :meta
// 41:
// 42:       sig { returns(T::Array[String]) }
// 43:       def formulae
// 44:         @advisories.keys
// 45:       end
// 46:
// 47:       # {Vulnerability} wrappers for every `BREW-*` record whose
// 48:       # `affected[0].package.name` is `formula_name`.
// 49:       sig { params(formula_name: String).returns(T::Array[Vulnerability]) }
// 50:       def records_for(formula_name)
// 51:         Array(@advisories[formula_name]).filter_map do |record|
// 52:           Vulnerability.new(record) if record.is_a?(Hash)
// 53:         end
// 54:       end
// 55:
// 56:       Entry = Struct.new(:id, :upstream, :summary, :severity, :fix, :fixed_in, keyword_init: true) do
// 57:         sig { returns(T::Hash[String, T.untyped]) }
// 58:         def to_api_hash
// 59:           to_h.transform_keys(&:to_s).compact
// 60:         end
// 61:       end
// 62:
// 63:       # Evaluate every record for `formula_name` against `pkg_version` and
// 64:       # return the `{open:, patched:}` shape used by the formula API JSON and
// 65:       # `brew info`. `open` are records whose `ECOSYSTEM` range still contains
// 66:       # `pkg_version`; `patched` are records where `ecosystem_specific.fix` is
// 67:       # `"patch"` (Homebrew ships a `resolves`-annotated patch); `fixed_count`
// 68:       # counts bump-fixed records that no longer apply. Returns `nil` when the
// 69:       # corpus has no records for the formula so callers can distinguish
// 70:       # "checked, clean" from "not covered".
// 71:       sig {
// 72:         params(formula_name: String, pkg_version: T.any(String, PkgVersion))
// 73:           .returns(T.nilable(T::Hash[String, T.untyped]))
// 74:       }
// 75:       def status_for(formula_name, pkg_version)
// 76:         records = records_for(formula_name)
// 77:         return if records.empty?
// 78:
// 79:         version = pkg_version.to_s
// 80:         open = T.let([], T::Array[Entry])
// 81:         patched = T.let([], T::Array[Entry])
// 82:         fixed_count = 0
// 83:
// 84:         records.each do |vuln|
// 85:           eco = vuln.affected.first&.dig("ecosystem_specific") || {}
// 86:           status = vuln.range_status("Homebrew", formula_name, version)
// 87:           entry = Entry.new(
// 88:             id:       vuln.id,
// 89:             upstream: vuln.upstream.presence || vuln.aliases.presence,
// 90:             summary:  vuln.summary,
// 91:             severity: vuln.severity&.to_s,
// 92:             fix:      eco["fix"],
// 93:             fixed_in: status&.fixed_in,
// 94:           ).freeze
// 95:           case status&.state
// 96:           when nil, :affected then open << entry
// 97:           when :fixed
// 98:             if eco["fix"] == "patch"
// 99:               patched << entry
// 100:             else
// 101:               fixed_count += 1
// 102:             end
// 103:           when :not_applicable then next
// 104:           end
// 105:         end
// 106:
// 107:         {
// 108:           "open"        => open.sort_by(&:id).map(&:to_api_hash),
// 109:           "patched"     => patched.sort_by(&:id).map(&:to_api_hash),
// 110:           "fixed_count" => fixed_count,
// 111:         }
// 112:       end
// 113:     end
// 114:   end
// 115: end
