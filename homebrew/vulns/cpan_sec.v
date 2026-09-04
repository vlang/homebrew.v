module vulns

import ruby
import homebrew
import x.json2

// Translated from Homebrew/brew `vulns/cpan_sec.rb`.
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

pub type CpanSecReadFile = fn (string) !string

pub type CpanSecWriteFile = fn (string, string) !

pub type CpanSecRenameFile = fn (string, string) !

pub type CpanSecRemoveFile = fn (string) !

pub type CpanSecMakeDirectory = fn (string) !

pub type CpanSecPathExists = fn (string) bool

pub type CpanSecModifiedTime = fn (string) !i64

pub type CpanSecFetch = fn (string) !string

pub type CpanSecClock = fn () i64

pub type CpanSecWarning = fn (string)

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
			cpan_sec_string_array(value)
		} else {
			[]string{}
		}
		fixed_versions: if value := raw['fixed_versions'] {
			cpan_sec_string_array(value)
		} else {
			[]string{}
		}
		severity: cpan_sec_optional_string(raw, 'severity')
		description: cpan_sec_optional_string(raw, 'description')
		references: if value := raw['references'] {
			cpan_sec_string_array(value)
		} else {
			[]string{}
		}
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
				ruby.string_value(value)
			} else {
				ruby.object_value('NilClass', 'nil')
			}
			'description':       if value := advisory.description {
				ruby.string_value(value)
			} else {
				ruby.object_value('NilClass', 'nil')
			}
			'references':        ruby.string_array_value(advisory.references)
			'reported':          if value := advisory.reported {
				ruby.string_value(value)
			} else {
				ruby.object_value('NilClass', 'nil')
			}
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
