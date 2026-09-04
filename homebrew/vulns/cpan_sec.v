module vulns

import ruby
import homebrew
import x.json2

// Translated from Homebrew/brew `vulns/cpan_sec.rb`.
// The original source is retained below until every stub has a typed V body.
pub const cpan_sec_data_url = 'https://raw.githubusercontent.com/briandfoy/cpan-security-advisory/master/cpan-security-advisory.json'
pub const cpan_sec_cache_filename = 'cpansa.json'

pub enum CpanSecConstraintOperator {
	less
	less_equal
	greater
	greater_equal
	equal
}

pub struct CpanSecConstraint {
pub:
	operator CpanSecConstraintOperator
	version  string
}

pub struct CpanSecAdvisory {
pub:
	id                string
	cves              []string
	affected_versions []string
	fixed_versions    []string
	severity          ?string
	description       ?string
	references        []string
	reported          ?string
}

pub enum CpanSecRangeState {
	affected
	fixed
	not_applicable
}

pub struct CpanSecRangeStatus {
pub:
	state    CpanSecRangeState
	fixed_in ?string
}

pub fn (status CpanSecRangeStatus) affected() bool {
	return status.state == .affected
}

pub fn (status CpanSecRangeStatus) fixed() bool {
	return status.state == .fixed
}

pub struct CpanSecDatabase {
	distribution_advisories map[string][]CpanSecAdvisory
	meta_values             map[string]json2.Any
}

pub struct CpanSecQuery {
pub:
	distribution string
	version      string
}

pub struct CpanSecFinding {
pub:
	distribution string
	advisory     CpanSecAdvisory
	status       CpanSecRangeStatus
}

pub type CpanSecReadFile = fn(string) !string

pub type CpanSecWriteFile = fn(string, string) !

pub type CpanSecRenameFile = fn(string, string) !

pub type CpanSecRemoveFile = fn(string) !

pub type CpanSecMakeDirectory = fn(string) !

pub type CpanSecPathExists = fn(string) bool

pub type CpanSecModifiedTime = fn(string) !i64

pub type CpanSecFetch = fn(string) !string

pub type CpanSecClock = fn() i64

pub type CpanSecWarning = fn(string)

pub struct CpanSecIo {
pub:
	read_file      CpanSecReadFile @[required]
	write_file     CpanSecWriteFile @[required]
	rename_file    CpanSecRenameFile @[required]
	remove_file    CpanSecRemoveFile @[required]
	make_directory CpanSecMakeDirectory @[required]
	path_exists    CpanSecPathExists @[required]
	modified_time  CpanSecModifiedTime @[required]
	fetch          CpanSecFetch @[required]
	now            CpanSecClock @[required]
	warn           CpanSecWarning @[required]
}

fn cpan_sec_optional_string(values map[string]json2.Any, key string) ?string {
	value := values[key] or { return none }
	if value is string {
		return value
	}
	return none
}

fn cpan_sec_any_array(value json2.Any) []json2.Any {
	if value is []json2.Any {
		return value
	}
	if value is json2.Null {
		return []json2.Any{}
	}
	return [value]
}

fn cpan_sec_string_array(value json2.Any) []string {
	mut result := []string{}
	for item in cpan_sec_any_array(value) {
		result << item.str()
	}
	return result
}

pub fn build_cpan_sec_advisory(raw map[string]json2.Any) ?CpanSecAdvisory {
	id_value := raw['id'] or { return none }
	if id_value is json2.Null {
		return none
	}
	id := id_value.str()
	return CpanSecAdvisory{
		id: id
		cves: if value := raw['cves'] { cpan_sec_string_array(value) } else { []string{} }
		affected_versions: if value := raw['affected_versions'] {
			cpan_sec_string_array(value)} else {
			[]string{}}
		fixed_versions: if value := raw['fixed_versions'] {
			cpan_sec_string_array(value)} else {
			[]string{}}
		severity: cpan_sec_optional_string(raw, 'severity')
		description: cpan_sec_optional_string(raw, 'description')
		references: if value := raw['references'] {
			cpan_sec_string_array(value)} else {
			[]string{}}
		reported: cpan_sec_optional_string(raw, 'reported')
	}
}

pub fn new_cpan_sec_database(data json2.Any) !CpanSecDatabase {
	if data !is map[string]json2.Any {
		return error('CPANSA data is not a JSON object')
	}
	top := data.as_map()
	raw_dists := top['dists'] or { return error("CPANSA data missing 'dists' key") }
	if raw_dists !is map[string]json2.Any {
		return error("CPANSA data missing 'dists' key")
	}
	dists := raw_dists.as_map()
	mut advisories := map[string][]CpanSecAdvisory{}
	for distribution, raw_entry in dists {
		if raw_entry !is map[string]json2.Any {
			advisories[distribution] = []CpanSecAdvisory{}
			continue
		}
		entry := raw_entry.as_map()
		mut records := []CpanSecAdvisory{}
		if raw_records := entry['advisories'] {
			for raw_record in cpan_sec_any_array(raw_records) {
				if raw_record is map[string]json2.Any {
					if advisory := build_cpan_sec_advisory(raw_record) {
						records << advisory
					}
				}
			}
		}
		advisories[distribution] = records
	}
	mut meta := map[string]json2.Any{}
	if raw_meta := top['meta'] {
		if raw_meta is map[string]json2.Any {
			meta = raw_meta.clone()
		}
	}
	return CpanSecDatabase{
		distribution_advisories: advisories
		meta_values: meta
	}
}

pub fn parse_cpan_sec_database(contents string) !CpanSecDatabase {
	data := json2.decode[json2.Any](contents) or {
		return error('Failed to parse ${cpan_sec_cache_filename}: ${err.msg()}')
	}
	return new_cpan_sec_database(data)
}

pub fn cpan_sec_from_file(path string, read_file CpanSecReadFile) !CpanSecDatabase {
	contents := read_file(path)!
	data := json2.decode[json2.Any](contents) or {
		return error('Failed to parse ${cpan_sec_cache_filename} at ${path}: ${err.msg()}')
	}
	return new_cpan_sec_database(data)
}

fn cpan_sec_cache_path(cache_directory string) string {
	separator := if cache_directory == '' || cache_directory.ends_with('/') { '' } else { '/' }
	return '${cache_directory}${separator}${cpan_sec_cache_filename}'
}

pub fn refresh_cpan_sec(cache_file string, io CpanSecIo) !CpanSecDatabase {
	contents := io.fetch(cpan_sec_data_url)!
	slash := cache_file.last_index('/') or { -1 }
	parent := if slash >= 0 { cache_file[..slash] } else { '' }
	if parent != '' {
		io.make_directory(parent)!
	}
	temporary_file := '${cache_file}.download-${io.now()}'
	io.write_file(temporary_file, contents)!
	loaded := parse_cpan_sec_database(contents) or {
		io.remove_file(temporary_file) or {}
		return err
	}
	io.rename_file(temporary_file, cache_file) or {
		io.remove_file(temporary_file) or {}
		return err
	}
	return loaded
}

pub fn load_cpan_sec(cache_directory string, max_age i64, io CpanSecIo) !CpanSecDatabase {
	cache_file := cpan_sec_cache_path(cache_directory)
	exists := io.path_exists(cache_file)
	if exists {
		modified := io.modified_time(cache_file)!
		if io.now() - modified <= max_age {
			return cpan_sec_from_file(cache_file, io.read_file)
		}
	}
	return refresh_cpan_sec(cache_file, io) or {
		if !exists {
			return err
		}
		modified := io.modified_time(cache_file) or { 0 }
		message := err.msg().split_into_lines()[0]
		io.warn('Failed to refresh ${cpan_sec_cache_filename} (${message}); using cached copy from ${modified}.')
		return cpan_sec_from_file(cache_file, io.read_file)
	}
}

pub fn (database CpanSecDatabase) meta() map[string]json2.Any {
	return database.meta_values.clone()
}

pub fn (database CpanSecDatabase) distributions() []string {
	return database.distribution_advisories.keys()
}

pub fn normalize_cpan_distribution(distribution string) string {
	return distribution.trim_space().replace('::', '-')
}

pub fn (database CpanSecDatabase) advisories_for(distribution string) []CpanSecAdvisory {
	return (database.distribution_advisories[distribution] or { []CpanSecAdvisory{} }).clone()
}

fn cpan_sec_constraint_char(character u8) bool {
	return (character >= `A` && character <= `Z`) || (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`) || character in [
		`_`,
		`.`,
	]
}

pub fn parse_cpan_sec_constraint(term string) ?CpanSecConstraint {
	mut rest := term.trim_space()
	mut operator := CpanSecConstraintOperator.equal
	for candidate in ['<=', '>=', '==', '<', '>', '='] {
		if rest.starts_with(candidate) {
			operator = match candidate {
				'<' { CpanSecConstraintOperator.less }
				'<=' { CpanSecConstraintOperator.less_equal }
				'>' { CpanSecConstraintOperator.greater }
				'>=' { CpanSecConstraintOperator.greater_equal }
				else { CpanSecConstraintOperator.equal }
			}
			rest = rest[candidate.len..].trim_space()
			break
		}
	}
	if rest.starts_with('v') {
		rest = rest[1..]
	}
	if rest == '' || rest[0] < `0` || rest[0] > `9` || !rest.bytes().all(cpan_sec_constraint_char(it)) {
		return none
	}
	if _ := homebrew.new_version(rest) {
		return CpanSecConstraint{
			operator: operator
			version: rest
		}
	}
	return none
}

fn cpan_sec_compare(target homebrew.Version, bound string) ?int {
	bound_version := homebrew.new_version(bound) or { return none }
	return target.compare_to(bound_version)
}

pub fn cpan_sec_satisfies_version(target homebrew.Version, conjunction string) bool {
	for raw_term in conjunction.split(',') {
		constraint := parse_cpan_sec_constraint(raw_term) or { return false }
		comparison := cpan_sec_compare(target, constraint.version) or { return false }
		matches := match constraint.operator {
			.less { comparison < 0 }
			.less_equal { comparison <= 0 }
			.greater { comparison > 0 }
			.greater_equal { comparison >= 0 }
			.equal { comparison == 0 }
		}
		if !matches {
			return false
		}
	}
	return true
}

pub fn cpan_sec_satisfies(target string, conjunction string) bool {
	normalized := if target.len > 0 && target[0] in [`v`, `V`] { target[1..] } else { target }
	version := homebrew.new_version(normalized) or { return false }
	return cpan_sec_satisfies_version(version, conjunction)
}

pub fn cpan_sec_lower_bounds(conjunction string) []string {
	mut result := []string{}
	for raw_term in conjunction.split(',') {
		constraint := parse_cpan_sec_constraint(raw_term) or { continue }
		if constraint.operator in [.greater_equal, .greater, .equal] {
			result << constraint.version
		}
	}
	return result
}

fn cpan_sec_min_above(target homebrew.Version, bounds []string) ?string {
	mut found := false
	mut selected := ''
	for bound in bounds {
		version := homebrew.new_version(bound) or { continue }
		if target.compare_to(version) >= 0 {
			continue
		}
		if !found {
			selected = bound
			found = true
			continue
		}
		current := homebrew.new_version(selected) or { continue }
		if version.compare_to(current) < 0 {
			selected = bound
		}
	}
	if found {
		return selected
	}
	return none
}

fn cpan_sec_max_at_or_below(target homebrew.Version, bounds []string) ?string {
	mut found := false
	mut selected := ''
	for bound in bounds {
		version := homebrew.new_version(bound) or { continue }
		if target.compare_to(version) < 0 {
			continue
		}
		if !found {
			selected = bound
			found = true
			continue
		}
		current := homebrew.new_version(selected) or { continue }
		if version.compare_to(current) > 0 {
			selected = bound
		}
	}
	if found {
		return selected
	}
	return none
}

pub fn cpan_sec_range_status(advisory CpanSecAdvisory, version string) !CpanSecRangeStatus {
	normalized := if version.len > 0 && version[0] in [`v`, `V`] { version[1..] } else { version }
	target := homebrew.new_version(normalized)!
	affected := advisory.affected_versions.len == 0 || advisory.affected_versions.any(cpan_sec_satisfies_version(target, it))
	mut bounds := []string{}
	for conjunction in advisory.fixed_versions {
		bounds << cpan_sec_lower_bounds(conjunction)
	}
	if affected {
		return CpanSecRangeStatus{
			state: .affected
			fixed_in: cpan_sec_min_above(target, bounds)
		}
	}
	if advisory.fixed_versions.any(cpan_sec_satisfies_version(target, it)) {
		return CpanSecRangeStatus{
			state: .fixed
			fixed_in: cpan_sec_max_at_or_below(target, bounds)
		}
	}
	return CpanSecRangeStatus{
		state: .not_applicable
	}
}

pub fn (database CpanSecDatabase) query(query CpanSecQuery) ![]CpanSecFinding {
	distribution := normalize_cpan_distribution(query.distribution)
	mut findings := []CpanSecFinding{}
	for advisory in database.advisories_for(distribution) {
		status := cpan_sec_range_status(advisory, query.version)!
		if status.state == .affected {
			findings << CpanSecFinding{
				distribution: distribution
				advisory: advisory
				status: status
			}
		}
	}
	return findings
}

fn cpan_sec_advisory_json(advisory CpanSecAdvisory) map[string]json2.Any {
	mut result := {
		'id':                json2.Any(advisory.id)
		'cves':              json2.Any(advisory.cves.map(json2.Any(it)))
		'affected_versions': json2.Any(advisory.affected_versions.map(json2.Any(it)))
		'fixed_versions':    json2.Any(advisory.fixed_versions.map(json2.Any(it)))
		'references':        json2.Any(advisory.references.map(json2.Any(it)))
	}
	if value := advisory.severity {
		result['severity'] = json2.Any(value)
	}
	if value := advisory.description {
		result['description'] = json2.Any(value)
	}
	if value := advisory.reported {
		result['reported'] = json2.Any(value)
	}
	return result
}

pub fn cpan_sec_advisory_value(advisory CpanSecAdvisory) ruby.Value {
	return ruby.Value{
		type_name: 'CPANSec::Advisory'
		repr: json2.encode(cpan_sec_advisory_json(advisory))
		map_data: {
			'id':                ruby.string_value(advisory.id)
			'cves':              ruby.string_array_value(advisory.cves)
			'affected_versions': ruby.string_array_value(advisory.affected_versions)
			'fixed_versions':    ruby.string_array_value(advisory.fixed_versions)
			'severity':          if value := advisory.severity {
				ruby.string_value(value)} else {
				ruby.object_value('NilClass', 'nil')}
			'description':       if value := advisory.description {
				ruby.string_value(value)} else {
				ruby.object_value('NilClass', 'nil')}
			'references':        ruby.string_array_value(advisory.references)
			'reported':          if value := advisory.reported {
				ruby.string_value(value)} else {
				ruby.object_value('NilClass', 'nil')}
		}
	}
}

pub fn cpan_sec_advisory_from_value(value ruby.Value) !CpanSecAdvisory {
	if value.type_name != 'CPANSec::Advisory' {
		return error('expected CPANSec::Advisory, got ${value.type_name}')
	}
	decoded := json2.decode[json2.Any](value.repr)!
	if decoded !is map[string]json2.Any {
		return error('CPANSec advisory value is not a JSON object')
	}
	return build_cpan_sec_advisory(decoded.as_map()) or { error('CPANSA advisory has no id') }
}

fn cpan_sec_database_json(database CpanSecDatabase) map[string]json2.Any {
	mut dists := map[string]json2.Any{}
	for distribution in database.distributions() {
		dists[distribution] = json2.Any({
			'advisories': json2.Any(database.advisories_for(distribution).map(json2.Any(cpan_sec_advisory_json(it))))
		})
	}
	return {
		'dists': json2.Any(dists)
		'meta':  json2.Any(database.meta())
	}
}

pub fn cpan_sec_database_value(database CpanSecDatabase) ruby.Value {
	return ruby.Value{
		type_name: 'CPANSec'
		repr: json2.encode(cpan_sec_database_json(database))
		attributes: {
			'distributions': database.distributions().join(',')
		}
	}
}

pub fn cpan_sec_database_from_value(value ruby.Value) !CpanSecDatabase {
	if value.type_name != 'CPANSec' {
		return error('expected CPANSec, got ${value.type_name}')
	}
	return parse_cpan_sec_database(value.repr)
}

pub fn cpan_sec_range_status_value(status CpanSecRangeStatus) ruby.Value {
	return ruby.Value{
		type_name: 'Vulnerability::RangeStatus'
		repr: status.state.str()
		attributes: {
			'state':    status.state.str()
			'fixed_in': status.fixed_in or { '' }
		}
	}
}

fn cpan_sec_json_from_boundary(value ruby.Value) json2.Any {
	return match value.type_name {
		'NilClass' { json2.Any(json2.null) }
		'String' { json2.Any(value.as_string()) }
		'Bool' { json2.Any(value.bool_data) }
		'Integer' { json2.Any(value.int_data) }
		'Float' { json2.Any(value.float_data) }
		'Array' {
			if value.array_data.len > 0 {
				json2.Any(value.array_data.map(cpan_sec_json_from_boundary(it)))
			} else {
				json2.Any(value.string_array_data.map(json2.Any(it)))
			}
		}
		'Hash' {
			mut result := map[string]json2.Any{}
			for key, item in value.map_data {
				result[key] = cpan_sec_json_from_boundary(item)
			}
			json2.Any(result)
		}
		else { json2.Any(value.as_string()) }
	}
}

// Ruby method `self.data_url = DATA_URL` at line 21.
pub fn ruby_cpan_sec_l21_d1_self_data_url(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cpan_sec_data_url)
}

// Ruby method `self.cache_filename = "cpansa.json"` at line 24.
pub fn ruby_cpan_sec_l24_d2_self_cache_filename(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cpan_sec_cache_filename)
}

// Ruby method `initialize(data)` at line 33.
pub fn ruby_cpan_sec_l33_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CPANSec initialize requires data')
	}
	data := cpan_sec_json_from_boundary(args[0])
	return cpan_sec_database_value(new_cpan_sec_database(data) or { panic(err) })
}

// Ruby attr_reader `attr_reader :meta` at line 43.
pub fn ruby_cpan_sec_l43_d4_meta(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('missing CPANSec receiver')
	}
	database := cpan_sec_database_from_value(args[0]) or { panic(err) }
	mut values := map[string]ruby.Value{}
	for key, value in database.meta() {
		values[key] = match value {
			string { ruby.string_value(value) }
			int { ruby.int_value(value) }
			i64 { ruby.int_value(value) }
			f64 {
				integer := i64(value)
				if value == f64(integer) {
					ruby.int_value(integer)
				} else {
					ruby.float_value(value)
				}
			}
			bool { ruby.bool_value(value) }
			else { ruby.object_value('NilClass', 'nil') }
		}
	}
	return ruby.map_value(values)
}

// Ruby method `distributions` at line 46.
pub fn ruby_cpan_sec_l46_d5_distributions(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('missing CPANSec receiver')
	}
	database := cpan_sec_database_from_value(args[0]) or { panic(err) }
	return ruby.string_array_value(database.distributions())
}

// Ruby method `advisories_for(distribution)` at line 51.
pub fn ruby_cpan_sec_l51_d6_advisories_for(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([]ruby.Value{})
	}
	database := cpan_sec_database_from_value(args[0]) or { panic(err) }
	return ruby.array_value(database.advisories_for(args[1].as_string()).map(cpan_sec_advisory_value(it)))
}

// Ruby method `self.range_status(advisory, version)` at line 65.
pub fn ruby_cpan_sec_l65_d7_self_range_status(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('CPANSec.range_status requires advisory and version')
	}
	advisory := cpan_sec_advisory_from_value(args[0]) or { panic(err) }
	return cpan_sec_range_status_value(cpan_sec_range_status(advisory, args[1].as_string()) or {
		panic(err)
	})
}

// Ruby method `self.satisfies?(target, conjunction)` at line 88.
pub fn ruby_cpan_sec_l88_d8_self_satisfies(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(cpan_sec_satisfies(args[0].as_string(), args[1].as_string()))
}

// Ruby method `self.lower_bounds(conjunction)` at line 105.
pub fn ruby_cpan_sec_l105_d9_self_lower_bounds(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([]string{})
	}
	return ruby.string_array_value(cpan_sec_lower_bounds(args[0].as_string()))
}

// Ruby method `build_advisory(raw)` at line 113.
pub fn ruby_cpan_sec_l113_d10_build_advisory(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return ruby.object_value('NilClass', 'nil')
	}
	raw_value := cpan_sec_json_from_boundary(args[0])
	if raw_value !is map[string]json2.Any {
		return ruby.object_value('NilClass', 'nil')
	}
	advisory := build_cpan_sec_advisory(raw_value.as_map()) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return cpan_sec_advisory_value(advisory)
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
