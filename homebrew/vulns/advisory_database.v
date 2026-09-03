module vulns

import homebrew
import x.json2

// Translated from Homebrew/brew `vulns/advisory_database.rb`.
// The original source is retained below until every stub has a typed V body.
pub const advisory_database_data_url = 'https://raw.githubusercontent.com/Homebrew/advisory-database/main/data/advisories.json'
pub const advisory_database_cache_filename = 'advisories.json'

pub struct AdvisoryEvent {
pub:
	introduced    ?string
	fixed         ?string
	last_affected ?string
	limit         ?string
}

pub struct AdvisoryRange {
pub:
	range_type string
	events     []AdvisoryEvent
}

pub struct AdvisoryPackage {
pub:
	ecosystem string
	name      string
}

pub struct AdvisoryAffected {
pub:
	package  AdvisoryPackage
	ranges   []AdvisoryRange
	versions []string
	fix      ?string
	severity ?string
}

pub struct AdvisorySeverityEntry {
pub:
	severity_type string
	score         string
}

pub struct AdvisoryRecord {
	raw map[string]json2.Any
pub:
	id               string
	upstream         []string
	aliases          []string
	summary          ?string
	severity         ?CvssSeverity
	affected         []AdvisoryAffected
	severity_entries []AdvisorySeverityEntry
}

pub struct AdvisoryEntry {
pub:
	id       string
	upstream []string
	summary  ?string
	severity ?string
	fix      ?string
	fixed_in ?string
}

pub struct AdvisoryStatus {
pub:
	open        []AdvisoryEntry
	patched     []AdvisoryEntry
	fixed_count int
}

pub struct AdvisoryDatabase {
	advisories  map[string][]AdvisoryRecord
	meta_values map[string]json2.Any
}

pub enum AdvisoryRangeState {
	affected
	fixed
	not_applicable
}

pub struct AdvisoryRangeStatus {
pub:
	state    AdvisoryRangeState
	fixed_in ?string
}

struct AdvisoryInterval {
	lower           ?string
	upper           ?string
	upper_inclusive bool
}

pub type AdvisoryReadFile = fn(string) !string

pub type AdvisoryWriteFile = fn(string, string) !

pub type AdvisoryRenameFile = fn(string, string) !

pub type AdvisoryMakeDirectory = fn(string) !

pub type AdvisoryPathExists = fn(string) bool

pub type AdvisoryModifiedTime = fn(string) !i64

pub type AdvisoryFetch = fn(string) !string

pub type AdvisoryClock = fn() i64

pub type AdvisoryWarning = fn(string)

pub struct AdvisoryDatabaseIo {
pub:
	read_file      AdvisoryReadFile @[required]
	write_file     AdvisoryWriteFile @[required]
	rename_file    AdvisoryRenameFile @[required]
	make_directory AdvisoryMakeDirectory @[required]
	path_exists    AdvisoryPathExists @[required]
	modified_time  AdvisoryModifiedTime @[required]
	fetch          AdvisoryFetch @[required]
	now            AdvisoryClock @[required]
	warn           AdvisoryWarning @[required]
}

fn advisory_optional_string(values map[string]json2.Any, key string) ?string {
	value := values[key] or { return none }
	if value is string {
		return value
	}
	return none
}

fn advisory_string_array(value json2.Any) []string {
	if value is []json2.Any {
		mut result := []string{}
		for item in value {
			if item is string {
				result << item
			}
		}
		return result
	}
	if value is string {
		return [value]
	}
	return []string{}
}

fn advisory_any_array(value json2.Any) []json2.Any {
	if value is []json2.Any {
		return value
	}
	if value is json2.Null {
		return []json2.Any{}
	}
	return [value]
}

fn parse_advisory_event(value json2.Any) ?AdvisoryEvent {
	if value !is map[string]json2.Any {
		return none
	}
	values := value.as_map()
	return AdvisoryEvent{
		introduced: advisory_optional_string(values, 'introduced')
		fixed: advisory_optional_string(values, 'fixed')
		last_affected: advisory_optional_string(values, 'last_affected')
		limit: advisory_optional_string(values, 'limit')
	}
}

fn parse_advisory_range(value json2.Any) ?AdvisoryRange {
	if value !is map[string]json2.Any {
		return none
	}
	values := value.as_map()
	range_type_value := advisory_optional_string(values, 'type') or { '' }
	mut events := []AdvisoryEvent{}
	if raw_events := values['events'] {
		for raw_event in advisory_any_array(raw_events) {
			if event := parse_advisory_event(raw_event) {
				events << event
			}
		}
	}
	return AdvisoryRange{
		range_type: range_type_value
		events: events
	}
}

fn parse_advisory_affected(value json2.Any) ?AdvisoryAffected {
	if value !is map[string]json2.Any {
		return none
	}
	values := value.as_map()
	raw_package := values['package'] or { return none }
	if raw_package !is map[string]json2.Any {
		return none
	}
	package_values := raw_package.as_map()
	ecosystem := advisory_optional_string(package_values, 'ecosystem') or { '' }
	name := advisory_optional_string(package_values, 'name') or { '' }
	mut ranges := []AdvisoryRange{}
	if raw_ranges := values['ranges'] {
		for raw_range in advisory_any_array(raw_ranges) {
			if advisory_range := parse_advisory_range(raw_range) {
				ranges << advisory_range
			}
		}
	}
	versions := if raw_versions := values['versions'] {
		advisory_string_array(raw_versions)
	} else {
		[]string{}
	}
	mut fix := ?string(none)
	mut severity := ?string(none)
	if ecosystem_specific := values['ecosystem_specific'] {
		if ecosystem_specific is map[string]json2.Any {
			fix = advisory_optional_string(ecosystem_specific, 'fix')
			severity = advisory_optional_string(ecosystem_specific, 'severity')
		}
	}
	if severity == none {
		if database_specific := values['database_specific'] {
			if database_specific is map[string]json2.Any {
				severity = advisory_optional_string(database_specific, 'severity')
			}
		}
	}
	return AdvisoryAffected{
		package: AdvisoryPackage{
			ecosystem: ecosystem
			name: name
		}
		ranges: ranges
		versions: versions
		fix: fix
		severity: severity
	}
}

fn parse_advisory_severity_entry(value json2.Any) ?AdvisorySeverityEntry {
	if value !is map[string]json2.Any {
		return none
	}
	values := value.as_map()
	severity_type := advisory_optional_string(values, 'type') or { return none }
	score := advisory_optional_string(values, 'score') or { return none }
	return AdvisorySeverityEntry{
		severity_type: severity_type
		score: score
	}
}

fn normalize_advisory_severity(value string) ?CvssSeverity {
	return match value.to_lower() {
		'critical' { CvssSeverity.critical }
		'high' { CvssSeverity.high }
		'medium', 'moderate' { CvssSeverity.medium }
		'low' { CvssSeverity.low }
		else { none }
	}
}

fn advisory_record_severity(entries []AdvisorySeverityEntry,
	affected []AdvisoryAffected) ?CvssSeverity {
	for wanted_type in ['CVSS_V4', 'CVSS_V3', 'CVSS_V2'] {
		for entry in entries {
			if entry.severity_type == wanted_type {
				if severity := cvss_severity(entry.score) {
					return severity
				}
			}
		}
	}
	for item in affected {
		if raw_severity := item.severity {
			if severity := normalize_advisory_severity(raw_severity) {
				return severity
			}
		}
	}
	return none
}

pub fn parse_advisory_record(value json2.Any) !AdvisoryRecord {
	if value !is map[string]json2.Any {
		return error('advisory record is not a JSON object')
	}
	values := value.as_map()
	id := advisory_optional_string(values, 'id') or {
		return error("advisory record has no string 'id'")
	}
	mut affected := []AdvisoryAffected{}
	if raw_affected := values['affected'] {
		for raw_item in advisory_any_array(raw_affected) {
			if item := parse_advisory_affected(raw_item) {
				affected << item
			}
		}
	}
	mut severity_entries := []AdvisorySeverityEntry{}
	if raw_severity := values['severity'] {
		for raw_entry in advisory_any_array(raw_severity) {
			if entry := parse_advisory_severity_entry(raw_entry) {
				severity_entries << entry
			}
		}
	}
	upstream := if raw_upstream := values['upstream'] {
		advisory_string_array(raw_upstream)
	} else {
		[]string{}
	}
	aliases := if raw_aliases := values['aliases'] {
		advisory_string_array(raw_aliases)
	} else {
		[]string{}
	}
	return AdvisoryRecord{
		raw: values.clone()
		id: id
		upstream: upstream
		aliases: aliases
		summary: advisory_optional_string(values, 'summary')
		severity: advisory_record_severity(severity_entries, affected)
		affected: affected
		severity_entries: severity_entries
	}
}

pub fn new_advisory_database(data json2.Any) !AdvisoryDatabase {
	if data !is map[string]json2.Any {
		return error('advisory index is not a JSON object')
	}
	top := data.as_map()
	if 'advisories' !in top {
		return error("advisory index has no 'advisories' key")
	}
	raw_advisories := top['advisories'] or { json2.Any(json2.null) }
	if raw_advisories !is map[string]json2.Any {
		return error("advisory index 'advisories' is not a JSON object")
	}
	advisory_values := raw_advisories.as_map()
	mut advisories := map[string][]AdvisoryRecord{}
	for formula_name, raw_records in advisory_values {
		mut records := []AdvisoryRecord{}
		for raw_record in advisory_any_array(raw_records) {
			if raw_record is map[string]json2.Any {
				records << parse_advisory_record(raw_record)!
			}
		}
		advisories[formula_name] = records
	}
	mut meta := map[string]json2.Any{}
	if raw_meta := top['meta'] {
		if raw_meta is map[string]json2.Any {
			meta = raw_meta.clone()
		}
	}
	return AdvisoryDatabase{
		advisories: advisories
		meta_values: meta
	}
}

pub fn parse_advisory_database(contents string) !AdvisoryDatabase {
	data := json2.decode[json2.Any](contents) or {
		return error('Failed to parse ${advisory_database_cache_filename}: ${err.msg()}')
	}
	return new_advisory_database(data)
}

pub fn advisory_database_from_file(path string, read_file AdvisoryReadFile) !AdvisoryDatabase {
	contents := read_file(path)!
	data := json2.decode[json2.Any](contents) or {
		return error('Failed to parse ${advisory_database_cache_filename} at ${path}: ${err.msg()}')
	}
	return new_advisory_database(data)
}

fn advisory_cache_path(cache_directory string) string {
	separator := if cache_directory.ends_with('/') || cache_directory == '' { '' } else { '/' }
	return '${cache_directory}${separator}${advisory_database_cache_filename}'
}

pub fn refresh_advisory_database(cache_file string, io AdvisoryDatabaseIo) !AdvisoryDatabase {
	contents := io.fetch(advisory_database_data_url)!
	loaded := parse_advisory_database(contents)!
	slash := cache_file.last_index('/') or { -1 }
	parent := if slash >= 0 { cache_file[..slash] } else { '' }
	if parent != '' {
		io.make_directory(parent)!
	}
	temporary_file := '${cache_file}.download-${io.now()}'
	io.write_file(temporary_file, contents)!
	io.rename_file(temporary_file, cache_file)!
	return loaded
}

pub fn load_advisory_database(cache_directory string, max_age i64,
	io AdvisoryDatabaseIo) !AdvisoryDatabase {
	cache_file := advisory_cache_path(cache_directory)
	exists := io.path_exists(cache_file)
	if exists {
		modified := io.modified_time(cache_file)!
		if io.now() - modified <= max_age {
			return advisory_database_from_file(cache_file, io.read_file)
		}
	}
	return refresh_advisory_database(cache_file, io) or {
		if !exists {
			return err
		}
		modified := io.modified_time(cache_file) or { 0 }
		message := err.msg().split_into_lines()[0]
		io.warn('Failed to refresh ${advisory_database_cache_filename} (${message}); using cached copy from ${modified}.')
		return advisory_database_from_file(cache_file, io.read_file)
	}
}

pub fn (database AdvisoryDatabase) meta() map[string]json2.Any {
	return database.meta_values.clone()
}

pub fn (database AdvisoryDatabase) formulae() []string {
	mut result := database.advisories.keys()
	result.sort()
	return result
}

pub fn (database AdvisoryDatabase) records_for(formula_name string) []AdvisoryRecord {
	return (database.advisories[formula_name] or { []AdvisoryRecord{} }).clone()
}

pub fn (record AdvisoryRecord) to_json_value() json2.Any {
	return json2.Any(record.raw.clone())
}

fn normalize_advisory_version(version string) string {
	if version.len > 0 && version[0] in [`v`, `V`] {
		return version[1..]
	}
	return version
}

fn compare_advisory_versions(range_type string, left string, right string) ?int {
	if range_type == 'SEMVER' {
		return compare_semver(left, right)
	}
	left_version := homebrew.new_version(left) or { return none }
	right_version := homebrew.new_version(right) or { return none }
	return left_version.compare_to(right_version)
}

fn advisory_intervals(events []AdvisoryEvent) []AdvisoryInterval {
	mut result := []AdvisoryInterval{}
	mut lower := ?string(none)
	for event in events {
		if introduced := event.introduced {
			if previous := lower {
				result << AdvisoryInterval{
					lower: previous
				}
			}
			normalized := normalize_advisory_version(introduced)
			lower = if normalized == '0' { none } else { normalized }
		} else if fixed := event.fixed {
			normalized := normalize_advisory_version(fixed)
			result << AdvisoryInterval{
				lower: lower
				upper: normalized
			}
			lower = none
		} else if last := event.last_affected {
			normalized := normalize_advisory_version(last)
			result << AdvisoryInterval{
				lower: lower
				upper: normalized
				upper_inclusive: true
			}
			lower = none
		} else if limit := event.limit {
			normalized := normalize_advisory_version(limit)
			result << AdvisoryInterval{
				lower: lower
				upper: if normalized == '*' { none } else { normalized }
			}
			lower = none
		}
	}
	if lower != none || result.len == 0 {
		result << AdvisoryInterval{
			lower: lower
		}
	}
	return result
}

fn advisory_in_interval(target string, interval AdvisoryInterval,
	range_type string) ?bool {
	if lower := interval.lower {
		comparison := compare_advisory_versions(range_type, target, lower) or { return none }
		if comparison < 0 {
			return false
		}
	}
	if upper := interval.upper {
		comparison := compare_advisory_versions(range_type, target, upper) or { return none }
		return if interval.upper_inclusive { comparison <= 0 } else { comparison < 0 }
	}
	return true
}

pub fn (record AdvisoryRecord) range_status(ecosystem string, name string,
	version string) ?AdvisoryRangeStatus {
	target := normalize_advisory_version(version)
	mut matched_entry := false
	mut checked := false
	mut past_fixes := []string{}
	for affected in record.affected {
		if affected.package.ecosystem != ecosystem || affected.package.name != name {
			continue
		}
		matched_entry = true
		for advisory_range in affected.ranges {
			if advisory_range.range_type == 'GIT' {
				continue
			}
			for interval in advisory_intervals(advisory_range.events) {
				inside := advisory_in_interval(target, interval, advisory_range.range_type) or {
					continue
				}
				checked = true
				if inside {
					return AdvisoryRangeStatus{
						state: .affected
						fixed_in: if interval.upper_inclusive { none } else { interval.upper }
					}
				}
				if upper := interval.upper {
					comparison := compare_advisory_versions(advisory_range.range_type, target, upper) or { continue }
					if (interval.upper_inclusive && comparison > 0) || (!interval.upper_inclusive && comparison >= 0) {
						past_fixes << upper
					}
				}
			}
		}
		if affected.versions.len > 0 {
			checked = true
			if affected.versions.any(normalize_advisory_version(it) == target) {
				return AdvisoryRangeStatus{
					state: .affected
				}
			}
		}
	}
	if !matched_entry || !checked {
		return none
	}
	if past_fixes.len == 0 {
		return AdvisoryRangeStatus{
			state: .not_applicable
		}
	}
	mut latest := past_fixes[0]
	for candidate in past_fixes[1..] {
		comparison := compare_advisory_versions('ECOSYSTEM', candidate, latest) or { continue }
		if comparison > 0 {
			latest = candidate
		}
	}
	return AdvisoryRangeStatus{
		state: .fixed
		fixed_in: latest
	}
}

pub fn (entry AdvisoryEntry) to_api_hash() map[string]json2.Any {
	mut result := {
		'id': json2.Any(entry.id)
	}
	if entry.upstream.len > 0 {
		result['upstream'] = json2.Any(entry.upstream.map(json2.Any(it)))
	}
	if value := entry.summary {
		result['summary'] = json2.Any(value)
	}
	if value := entry.severity {
		result['severity'] = json2.Any(value)
	}
	if value := entry.fix {
		result['fix'] = json2.Any(value)
	}
	if value := entry.fixed_in {
		result['fixed_in'] = json2.Any(value)
	}
	return result
}

pub fn (database AdvisoryDatabase) status_for(formula_name string,
	pkg_version string) ?AdvisoryStatus {
	records := database.records_for(formula_name)
	if records.len == 0 {
		return none
	}
	mut open := []AdvisoryEntry{}
	mut patched := []AdvisoryEntry{}
	mut fixed_count := 0
	for record in records {
		mut fix := ?string(none)
		if record.affected.len > 0 {
			fix = record.affected[0].fix
		}
		status := record.range_status('Homebrew', formula_name, pkg_version)
		entry := AdvisoryEntry{
			id: record.id
			upstream: if record.upstream.len > 0 {
				record.upstream.clone()} else {
				record.aliases.clone()}
			summary: record.summary
			severity: if value := record.severity { value.symbol() } else { none }
			fix: fix
			fixed_in: if value := status { value.fixed_in } else { none }
		}
		if value := status {
			match value.state {
				.affected { open << entry }
				.fixed {
					if fix_value := fix {
						if fix_value == 'patch' {
							patched << entry
						} else {
							fixed_count++
						}
					} else {
						fixed_count++
					}
				}
				.not_applicable {}
			}
		} else {
			open << entry
		}
	}
	open.sort(a.id < b.id)
	patched.sort(a.id < b.id)
	return AdvisoryStatus{
		open: open
		patched: patched
		fixed_count: fixed_count
	}
}

pub fn (database AdvisoryDatabase) status_for_pkg_version(formula_name string,
	pkg_version homebrew.PkgVersion) ?AdvisoryStatus {
	return database.status_for(formula_name, pkg_version.to_s())
}

// Ruby method `self.data_url = DATA_URL` at line 21.
pub fn ruby_advisory_database_l21_d1_self_data_url() string {
	return advisory_database_data_url
}

// Ruby method `self.cache_filename = "advisories.json"` at line 24.
pub fn ruby_advisory_database_l24_d2_self_cache_filename() string {
	return advisory_database_cache_filename
}

// Ruby method `initialize(data)` at line 27.
pub fn ruby_advisory_database_l27_d3_initialize(data json2.Any) !AdvisoryDatabase {
	return new_advisory_database(data)
}

// Ruby attr_reader `attr_reader :meta` at line 40.
pub fn ruby_advisory_database_l40_d4_meta(database AdvisoryDatabase) map[string]json2.Any {
	return database.meta()
}

// Ruby method `formulae` at line 43.
pub fn ruby_advisory_database_l43_d5_formulae(database AdvisoryDatabase) []string {
	return database.formulae()
}

// Ruby method `records_for(formula_name)` at line 50.
pub fn ruby_advisory_database_l50_d6_records_for(database AdvisoryDatabase,
	formula_name string) []AdvisoryRecord {
	return database.records_for(formula_name)
}

// Ruby method `to_api_hash` at line 58.
pub fn ruby_advisory_database_l58_d7_to_api_hash(entry AdvisoryEntry) map[string]json2.Any {
	return entry.to_api_hash()
}

// Ruby method `status_for(formula_name, pkg_version)` at line 75.
pub fn ruby_advisory_database_l75_d8_status_for(database AdvisoryDatabase, formula_name string,
	pkg_version string) ?AdvisoryStatus {
	return database.status_for(formula_name, pkg_version)
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
