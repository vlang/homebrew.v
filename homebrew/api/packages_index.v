module api

import brew_runtime
import os
import x.json2

// Translated from Homebrew/brew `api/packages_index.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.path_for(target)` at line 31.
pub fn ruby_packages_index_l31_d1_self_path_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('PackagesIndex.path_for requires a target') }
	return brew_runtime.string_value(packages_index_path_for(args[0].as_string()))
}

// Ruby method `self.source_fingerprint(stat)` at line 36.
pub fn ruby_packages_index_l36_d2_self_source_fingerprint(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('PackagesIndex.source_fingerprint requires a stat') }
	stat := package_source_stat_from_value(args[0])
	return package_source_stat_value(stat)
}

// Ruby method `self.load(target, payload:, source_stat:)` at line 44.
pub fn ruby_packages_index_l44_d3_self_load(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('PackagesIndex.load requires target and payload') }
	stat := if args.len > 2 {
		package_source_stat_from_value(args[2])
	} else {
		packages_source_stat(args[0].as_string()) or { return packages_nil_value() }
	}
	index := packages_index_load(args[0].as_string(), args[1].as_string(), stat) or {
		return packages_nil_value()
	}
	return packages_index_value(index)
}

// Ruby method `self.top_level_spans_tile_payload?(payload, top_level)` at line 70.
pub fn ruby_packages_index_l70_d4_self_top_level_spans_tile_payload(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('top_level_spans_tile_payload? requires payload and spans') }
	return brew_runtime.bool_value(packages_top_level_spans_tile_payload(args[0].as_string(), package_locations_from_value(args[1])))
}

// Ruby method `self.write!(target, payload:, parsed:, source_stat:)` at line 100.
pub fn ruby_packages_index_l100_d5_self_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('PackagesIndex.write! requires target, payload and parsed data') }
	stat := if args.len > 3 {
		package_source_stat_from_value(args[3])
	} else {
		packages_source_stat(args[0].as_string()) or { return packages_nil_value() }
	}
	packages_index_write(args[0].as_string(), args[1].as_string(), args[2], stat, false) or {}
	return packages_nil_value()
}

// Ruby method `self.build(payload:, parsed:)` at line 132.
pub fn ruby_packages_index_l132_d6_self_build(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('PackagesIndex.build requires payload and parsed data') }
	if built := packages_index_build(args[0].as_string(), args[1]) {
		return packages_index_data_value(built)
	}
	return packages_nil_value()
}

// Ruby method `self.locate(payload, key, value, position)` at line 181.
pub fn ruby_packages_index_l181_d7_self_locate(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 { panic('PackagesIndex.locate requires payload, key, value and position') }
	if location := packages_index_locate(args[0].as_string(), args[1].as_string(), args[2], int(args[3].int_data)) {
		return package_location_value(location)
	}
	return packages_nil_value()
}

// Ruby attr_reader `attr_reader :payload` at line 194.
pub fn ruby_packages_index_l194_d8_payload(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(packages_index_from_args(args).payload)
}

// Ruby attr_reader `attr_reader :source_stat` at line 197.
pub fn ruby_packages_index_l197_d9_source_stat(args ...brew_runtime.Value) brew_runtime.Value {
	return package_source_stat_value(packages_index_from_args(args).source_stat)
}

// Ruby method `initialize(payload:, source_stat:, top_level:, sections:)` at line 203.
pub fn ruby_packages_index_l203_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('PackagesIndex.initialize requires payload, source_stat, top_level and sections')
	}
	index := PackagesIndex{
		payload: args[0].as_string()
		source_stat: package_source_stat_from_value(args[1])
		top_level: package_locations_from_value(args[2])
		sections: package_sections_from_value(args[3])
	}
	return packages_index_value(index)
}

// Ruby method `formula_hash(name)` at line 211.
pub fn ruby_packages_index_l211_d11_formula_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('PackagesIndex.formula_hash requires receiver and name') }
	result := packages_index_formula_hash(packages_index_from_args(args), args[1].as_string()) or {
		return brew_runtime.object_value('PackagesIndex::Invalid', err.msg())
	}
	return if result.present { result.value } else { packages_nil_value() }
}

// Ruby method `cask_hash(name)` at line 216.
pub fn ruby_packages_index_l216_d12_cask_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('PackagesIndex.cask_hash requires receiver and name') }
	result := packages_index_cask_hash(packages_index_from_args(args), args[1].as_string()) or {
		return brew_runtime.object_value('PackagesIndex::Invalid', err.msg())
	}
	return if result.present { result.value } else { packages_nil_value() }
}

// Ruby method `formula_names` at line 221.
pub fn ruby_packages_index_l221_d13_formula_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(packages_index_formula_names(packages_index_from_args(args)))
}

// Ruby method `cask_names` at line 226.
pub fn ruby_packages_index_l226_d14_cask_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(packages_index_cask_names(packages_index_from_args(args)))
}

// Ruby method `formula_name?(name)` at line 231.
pub fn ruby_packages_index_l231_d15_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('PackagesIndex.formula_name? requires receiver and name') }
	return brew_runtime.bool_value(packages_index_formula_name(packages_index_from_args(args), args[1].as_string()))
}

// Ruby method `cask_name?(name)` at line 236.
pub fn ruby_packages_index_l236_d16_cask_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('PackagesIndex.cask_name? requires receiver and name') }
	return brew_runtime.bool_value(packages_index_cask_name(packages_index_from_args(args), args[1].as_string()))
}

// Ruby method `top_level_value(key)` at line 241.
pub fn ruby_packages_index_l241_d17_top_level_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('PackagesIndex.top_level_value requires receiver and key') }
	result := packages_index_top_level_value(packages_index_from_args(args), args[1].as_string()) or {
		return brew_runtime.object_value('PackagesIndex::Invalid', err.msg())
	}
	return if result.present { result.value } else { packages_nil_value() }
}

// Ruby method `entry_value(section, name)` at line 253.
pub fn ruby_packages_index_l253_d18_entry_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('PackagesIndex.entry_value requires receiver, section and name') }
	result := packages_index_entry_value(packages_index_from_args(args), args[1].as_string(), args[2].as_string()) or { return brew_runtime.object_value('PackagesIndex::Invalid', err.msg()) }
	return if result.present { result.value } else { packages_nil_value() }
}

// Ruby method `slice_value(name, location, within: nil)` at line 270.
pub fn ruby_packages_index_l270_d19_slice_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('PackagesIndex.slice_value requires receiver, name and location') }
	within := if args.len > 3 && args[3].type_name != 'NilClass' {
		package_location_from_value(args[3])
	} else {
		none
	}
	return packages_index_slice_value(packages_index_from_args(args), args[1].as_string(), package_location_from_value(args[2]), within) or {
		return brew_runtime.object_value('PackagesIndex::Invalid', err.msg())
	}
}

// Ruby method `outside_span?(start_offset, end_offset, within)` at line 289.
pub fn ruby_packages_index_l289_d20_outside_span(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 { panic('PackagesIndex.outside_span? requires receiver, start, end and span') }
	within := if args[3].type_name == 'NilClass' {
		none
	} else {
		package_location_from_value(args[3])
	}
	return brew_runtime.bool_value(packages_outside_span(int(args[1].int_data), int(args[2].int_data), within))
}

pub struct PackageSourceStat {
pub:
	size     i64
	mtime_ns i64
}

pub struct PackageLocation {
pub:
	offset   int
	bytesize int
}

pub struct PackagesIndexData {
pub:
	top_level map[string]PackageLocation
	sections  map[string]map[string]PackageLocation
}

pub struct PackagesIndex {
pub:
	payload     string
	source_stat PackageSourceStat
	top_level   map[string]PackageLocation
	sections    map[string]map[string]PackageLocation
}

pub struct PackageValueResult {
pub:
	present bool
	value   brew_runtime.Value
}

struct PackageSpan {
	key      string
	location PackageLocation
}

pub fn packages_index_path_for(target string) string {
	return '${target}.payload.index'
}

pub fn packages_source_stat(path string) !PackageSourceStat {
	stat := os.stat(path)!
	return PackageSourceStat{ size: stat.size, mtime_ns: stat.mtime * 1_000_000_000 }
}

pub fn packages_index_load(target string, payload string, source_stat PackageSourceStat) ?PackagesIndex {
	contents := os.read_file(packages_index_path_for(target)) or { return none }
	data := brew_runtime.parse_json_value(contents) or { return none }
	if data.type_name != 'Hash' {
		return none
	}
	if (data.map_data['version'] or { packages_nil_value() }).int_data != 1 {
		return none
	}
	fingerprint := packages_source_fingerprint(source_stat)
	if (data.map_data['source_size'] or { packages_nil_value() }).int_data != fingerprint.size || (data.map_data['source_mtime_ns'] or { packages_nil_value() }).int_data != fingerprint.mtime_ns {
		return none
	}
	if (data.map_data['payload_bytesize'] or { packages_nil_value() }).int_data != payload.len {
		return none
	}
	top_value := data.map_data['top_level'] or { return none }
	if top_value.type_name != 'Hash' {
		return none
	}
	formula_value := data.map_data['formulae'] or { return none }
	cask_value := data.map_data['casks'] or { return none }
	if formula_value.type_name != 'Hash' || cask_value.type_name != 'Hash' {
		return none
	}
	top_level := package_locations_from_value_checked(top_value) or { return none }
	if !packages_top_level_spans_tile_payload(payload, top_level) {
		return none
	}
	return PackagesIndex{
		payload: payload
		source_stat: source_stat
		top_level: top_level
		sections: {
			'formulae': package_locations_from_value_checked(formula_value) or { return none }
			'casks':    package_locations_from_value_checked(cask_value) or { return none }
		}
	}
}

pub fn packages_top_level_spans_tile_payload(payload string, top_level map[string]PackageLocation) bool {
	if payload.len == 0 || payload[0] != `{` {
		return false
	}
	mut spans := top_level.keys().map(PackageSpan{ key: it, location: top_level[it] })
	spans.sort_with_compare(fn (left &PackageSpan, right &PackageSpan) int {
		return left.location.offset - right.location.offset
	})
	mut position := 1
	for index, span in spans {
		if span.location.bytesize < 0 {
			return false
		}
		mut key_bytes := '${json2.encode(span.key)}:'
		if index > 0 {
			key_bytes = ',${key_bytes}'
		}
		if position + key_bytes.len > payload.len || payload[position..position + key_bytes.len] != key_bytes {
			return false
		}
		if position + key_bytes.len != span.location.offset {
			return false
		}
		position = span.location.offset + span.location.bytesize
	}
	return position + 1 == payload.len && position >= 0 && position < payload.len && payload[position] == `}`
}

pub fn packages_index_write(target string, payload string, parsed brew_runtime.Value,
	source_stat PackageSourceStat, running_as_root_but_not_owned bool) ! {
	if running_as_root_but_not_owned {
		return
	}
	built := packages_index_build(payload, parsed) or { return }
	mut values := map[string]brew_runtime.Value{}
	values['version'] = brew_runtime.int_value(1)
	values['source_size'] = brew_runtime.int_value(source_stat.size)
	values['source_mtime_ns'] = brew_runtime.int_value(source_stat.mtime_ns)
	values['payload_bytesize'] = brew_runtime.int_value(payload.len)
	values['top_level'] = package_locations_value(built.top_level)
	for section in ['formulae', 'casks'] {
		values[section] = package_locations_value(built.sections[section] or { map[string]PackageLocation{} })
	}
	index_path := packages_index_path_for(target)
	temporary_path := '${index_path}.tmp'
	defer { if os.exists(temporary_path) { os.rm(temporary_path) or {} } }
	os.write_file(temporary_path, json2.encode(brew_runtime.json_any_from_value(brew_runtime.map_value(values))))!
	os.mv(temporary_path, index_path)!
}

pub fn packages_index_build(payload string, parsed brew_runtime.Value) ?PackagesIndexData {
	if parsed.type_name != 'Hash' {
		return none
	}
	mut top_level := map[string]PackageLocation{}
	mut sections := {
		'formulae': map[string]PackageLocation{}
		'casks':    map[string]PackageLocation{}
	}
	mut retries := 0
	mut position := 0
	for key, value in parsed.map_data {
		location := packages_index_locate(payload, key, value, position) or { return none }
		top_level[key] = location
		if key in ['formulae', 'casks'] && value.type_name == 'Hash' {
			mut entry_position := location.offset
			for name, entry in value.map_data {
				mut found := PackageLocation{}
				mut present := false
				for {
					if entry_location := packages_index_locate(payload, name, entry, entry_position) {
						found = entry_location
						present = true
						break
					}
					retries++
					if retries > 100 {
						return none
					}
					next_position := payload.index_after('${json2.encode(name)}:', entry_position) or { return none }
					entry_position = next_position + 1
				}
				if !present {
					return none
				}
				sections[key][name] = found
				entry_position = found.offset + found.bytesize
			}
		}
		position = location.offset + location.bytesize
	}
	return PackagesIndexData{ top_level: top_level, sections: sections }
}

pub fn packages_index_locate(payload string, key string, value brew_runtime.Value,
	position int) ?PackageLocation {
	key_bytes := '${json2.encode(key)}:'
	key_position := payload.index_after(key_bytes, position) or { return none }
	value_bytes := json2.encode(brew_runtime.json_any_from_value(value))
	value_start := key_position + key_bytes.len
	if value_start < 0 || value_start + value_bytes.len > payload.len || payload[value_start..value_start + value_bytes.len] != value_bytes {
		return none
	}
	return PackageLocation{ offset: value_start, bytesize: value_bytes.len }
}

pub fn packages_index_formula_hash(index PackagesIndex, name string) !PackageValueResult {
	return packages_index_entry_value(index, 'formulae', name)
}

pub fn packages_index_cask_hash(index PackagesIndex, name string) !PackageValueResult {
	return packages_index_entry_value(index, 'casks', name)
}

pub fn packages_index_formula_names(index PackagesIndex) []string {
	return (index.sections['formulae'] or { map[string]PackageLocation{} }).keys()
}

pub fn packages_index_cask_names(index PackagesIndex) []string {
	return (index.sections['casks'] or { map[string]PackageLocation{} }).keys()
}

pub fn packages_index_formula_name(index PackagesIndex, name string) bool {
	return name in (index.sections['formulae'] or { map[string]PackageLocation{} })
}

pub fn packages_index_cask_name(index PackagesIndex, name string) bool {
	return name in (index.sections['casks'] or { map[string]PackageLocation{} })
}

pub fn packages_index_top_level_value(index PackagesIndex, key string) !PackageValueResult {
	if key in ['formulae', 'casks'] {
		return PackageValueResult{}
	}
	location := index.top_level[key] or { return PackageValueResult{} }
	return PackageValueResult{ present: true, value: packages_index_slice_value(index, key, location, none)! }
}

pub fn packages_index_entry_value(index PackagesIndex, section string,
	name string) !PackageValueResult {
	locations := (index.sections[section] or { map[string]PackageLocation{} }).clone()
	location := locations[name] or { return PackageValueResult{} }
	section_location := index.top_level[section] or {
		return error('no ${section} span for the ${name} index entry')
	}
	value := packages_index_slice_value(index, name, location, section_location)!
	if value.type_name != 'Hash' {
		return error('${section} index entry for ${name} is not a hash')
	}
	return PackageValueResult{ present: true, value: value }
}

pub fn packages_index_slice_value(index PackagesIndex, name string, location PackageLocation,
	within ?PackageLocation) !brew_runtime.Value {
	key_bytes := '${json2.encode(name)}:'
	key_offset := location.offset - key_bytes.len
	if location.offset < 0 || location.bytesize < 0 || key_offset < 0 || location.offset + location.bytesize > index.payload.len || index.payload[key_offset..key_offset + key_bytes.len] != key_bytes || packages_outside_span(key_offset, location.offset + location.bytesize, within) {
		return error('index location for ${name} does not match the payload')
	}
	slice := index.payload[location.offset..location.offset + location.bytesize]
	return brew_runtime.parse_json_value(slice) or { return error('index slice for ${name} does not parse') }
}

pub fn packages_outside_span(start_offset int, end_offset int, within ?PackageLocation) bool {
	span := within or { return false }
	return start_offset < span.offset || end_offset > span.offset + span.bytesize
}

fn packages_source_fingerprint(stat PackageSourceStat) PackageSourceStat {
	return stat
}

fn packages_index_value(index PackagesIndex) brew_runtime.Value {
	return brew_runtime.map_value({
		'payload':     brew_runtime.string_value(index.payload)
		'source_stat': package_source_stat_value(index.source_stat)
		'top_level':   package_locations_value(index.top_level)
		'sections':    package_sections_value(index.sections)
	})
}

fn packages_index_from_args(args []brew_runtime.Value) PackagesIndex {
	if args.len == 0 { panic('PackagesIndex receiver required') }
	value := args[0]
	return PackagesIndex{
		payload: (value.map_data['payload'] or { brew_runtime.string_value('') }).as_string()
		source_stat: package_source_stat_from_value(value.map_data['source_stat'] or { packages_nil_value() })
		top_level: package_locations_from_value(value.map_data['top_level'] or { packages_nil_value() })
		sections: package_sections_from_value(value.map_data['sections'] or { packages_nil_value() })
	}
}

fn packages_index_data_value(data PackagesIndexData) brew_runtime.Value {
	return brew_runtime.map_value({
		'top_level': package_locations_value(data.top_level)
		'sections':  package_sections_value(data.sections)
	})
}

fn package_source_stat_value(stat PackageSourceStat) brew_runtime.Value {
	return brew_runtime.map_value({
		'size':     brew_runtime.int_value(stat.size)
		'mtime_ns': brew_runtime.int_value(stat.mtime_ns)
	})
}

fn package_source_stat_from_value(value brew_runtime.Value) PackageSourceStat {
	return PackageSourceStat{
		size: (value.map_data['size'] or { brew_runtime.int_value(0) }).int_data
		mtime_ns: (value.map_data['mtime_ns'] or { brew_runtime.int_value(0) }).int_data
	}
}

fn package_location_value(location PackageLocation) brew_runtime.Value {
	return brew_runtime.array_value([
		brew_runtime.int_value(location.offset),
		brew_runtime.int_value(location.bytesize),
	])
}

fn package_location_from_value(value brew_runtime.Value) PackageLocation {
	values := value.as_array() or { []brew_runtime.Value{} }
	return PackageLocation{
		offset: if values.len > 0 { int(values[0].int_data) } else { -1 }
		bytesize: if values.len > 1 { int(values[1].int_data) } else { -1 }
	}
}

fn package_locations_value(locations map[string]PackageLocation) brew_runtime.Value {
	mut values := map[string]brew_runtime.Value{}
	for key, location in locations {
		values[key] = package_location_value(location)
	}
	return brew_runtime.map_value(values)
}

fn package_locations_from_value(value brew_runtime.Value) map[string]PackageLocation {
	return package_locations_from_value_checked(value) or { map[string]PackageLocation{} }
}

fn package_locations_from_value_checked(value brew_runtime.Value) !map[string]PackageLocation {
	if value.type_name != 'Hash' {
		return error('locations are not a hash')
	}
	mut locations := map[string]PackageLocation{}
	for key, entry in value.map_data {
		values := entry.as_array() or { return error('location is not an array') }
		if values.len != 2 || values[0].type_name != 'Integer' || values[1].type_name != 'Integer' || values[1].int_data < 0 {
			return error('invalid location')
		}
		locations[key] = PackageLocation{ offset: int(values[0].int_data), bytesize: int(values[1].int_data) }
	}
	return locations
}

fn package_sections_value(sections map[string]map[string]PackageLocation) brew_runtime.Value {
	mut values := map[string]brew_runtime.Value{}
	for key, locations in sections {
		values[key] = package_locations_value(locations)
	}
	return brew_runtime.map_value(values)
}

fn package_sections_from_value(value brew_runtime.Value) map[string]map[string]PackageLocation {
	mut sections := map[string]map[string]PackageLocation{}
	if value.type_name != 'Hash' {
		return sections
	}
	for key, locations in value.map_data {
		sections[key] = package_locations_from_value(locations)
	}
	return sections
}

fn packages_nil_value() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module API
// 6:     # Byte-offset index into a signature-verified internal packages JWS
// 7:     # payload, so commands can parse only the entries they need instead of
// 8:     # the whole multi-megabyte document.
// 9:     #
// 10:     # The index is derived, unverified cache data guarded in layers: the
// 11:     # payload bytes it points into are signature-verified on every run,
// 12:     # loading requires the recorded top-level spans to tile that payload
// 13:     # exactly (so the formulae and casks section spans are provably the
// 14:     # real top-level values) and every lookup revalidates that its offsets
// 15:     # sit at the expected `"<name>":` key inside the requested section's
// 16:     # span and that the slice parses. A forged or stale index therefore
// 17:     # cannot inject unverified content or remap a name to another entry,
// 18:     # even a matching key in the other section; it fails validation and
// 19:     # callers fall back to a full parse when {Invalid} is raised.
// 20:     class PackagesIndex
// 21:       FORMAT_VERSION = 1
// 22:       SECTION_KEYS = %w[formulae casks].freeze
// 23:       # Bounds index building when payload bytes stop round-tripping through
// 24:       # `JSON.generate`; giving up just means no index is written.
// 25:       MAX_FALSE_MATCH_RETRIES = 100
// 26:
// 27:       # Raised when index contents do not match the verified payload.
// 28:       class Invalid < RuntimeError; end
// 29:
// 30:       sig { params(target: Pathname).returns(Pathname) }
// 31:       def self.path_for(target)
// 32:         Pathname("#{target}.payload.index")
// 33:       end
// 34:
// 35:       sig { params(stat: File::Stat).returns(T::Hash[String, Integer]) }
// 36:       def self.source_fingerprint(stat)
// 37:         {
// 38:           "source_size"     => stat.size,
// 39:           "source_mtime_ns" => (stat.mtime.to_r * 1_000_000_000).to_i,
// 40:         }
// 41:       end
// 42:
// 43:       sig { params(target: Pathname, payload: String, source_stat: File::Stat).returns(T.nilable(PackagesIndex)) }
// 44:       def self.load(target, payload:, source_stat:)
// 45:         data = JSON.parse(path_for(target).read(encoding: Encoding::UTF_8))
// 46:         return unless data.is_a?(Hash)
// 47:         return if data["version"] != FORMAT_VERSION
// 48:         return if source_fingerprint(source_stat).any? { |key, value| data[key] != value }
// 49:         return if data["payload_bytesize"] != payload.bytesize
// 50:
// 51:         top_level = data["top_level"]
// 52:         sections = data.slice(*SECTION_KEYS)
// 53:         return unless top_level.is_a?(Hash)
// 54:         return unless sections.values.all?(Hash)
// 55:         return unless top_level_spans_tile_payload?(payload, top_level)
// 56:
// 57:         new(payload:, source_stat:, top_level:, sections:)
// 58:       rescue SystemCallError, JSON::ParserError
// 59:         nil
// 60:       end
// 61:
// 62:       # The recorded top-level spans must reconstruct the payload's
// 63:       # top-level object exactly: starting at the opening brace, each span
// 64:       # is immediately preceded by its own comma-separated JSON key and the
// 65:       # last ends at the closing brace. This proves every span, including
// 66:       # the section spans entry lookups are bounded by, is the real
// 67:       # top-level value for its key rather than an arbitrary or inflated
// 68:       # byte range.
// 69:       sig { params(payload: String, top_level: T::Hash[String, T.untyped]).returns(T::Boolean) }
// 70:       private_class_method def self.top_level_spans_tile_payload?(payload, top_level)
// 71:         return false if payload.byteslice(0, 1) != "{"
// 72:
// 73:         spans = top_level.map do |key, location|
// 74:           offset, bytesize = location
// 75:           return false if !offset.is_a?(Integer) || !bytesize.is_a?(Integer) || bytesize.negative?
// 76:
// 77:           [key.to_s, offset, bytesize]
// 78:         end
// 79:         spans.sort_by! { |_, offset, _| offset }
// 80:
// 81:         position = 1
// 82:         spans.each_with_index do |(key, offset, bytesize), index|
// 83:           key_bytes = "#{key.to_json}:"
// 84:           key_bytes = ",#{key_bytes}" if index.positive?
// 85:           return false if payload.byteslice(position, key_bytes.bytesize) != key_bytes
// 86:           return false if position + key_bytes.bytesize != offset
// 87:
// 88:           position = offset + bytesize
// 89:         end
// 90:
// 91:         position + 1 == payload.bytesize && payload.byteslice(position, 1) == "}"
// 92:       end
// 93:
// 94:       # Builds and persists an index for a freshly verified and parsed
// 95:       # payload. Failing to build or write one only costs the fast path.
// 96:       sig {
// 97:         params(target: Pathname, payload: String, parsed: T::Hash[String, T.untyped],
// 98:                source_stat: File::Stat).void
// 99:       }
// 100:       def self.write!(target, payload:, parsed:, source_stat:)
// 101:         # Never write to a user-owned cache as root, matching `skip_download?`.
// 102:         return if Homebrew.running_as_root_but_not_owned_by_root?
// 103:         return if (data = build(payload:, parsed:)).nil?
// 104:
// 105:         data = {
// 106:           "version"          => FORMAT_VERSION,
// 107:           **source_fingerprint(source_stat),
// 108:           "payload_bytesize" => payload.bytesize,
// 109:           **data,
// 110:         }
// 111:         index_path = path_for(target)
// 112:         temporary_path = Pathname("#{index_path}.tmp")
// 113:         begin
// 114:           temporary_path.write(JSON.generate(data))
// 115:           File.rename(temporary_path, index_path)
// 116:         ensure
// 117:           temporary_path.unlink if temporary_path.exist?
// 118:         end
// 119:       rescue SystemCallError
// 120:         nil
// 121:       end
// 122:
// 123:       # Locates every top-level value and every formula and cask entry in the
// 124:       # payload bytes. Offsets are found by searching for each JSON key in
// 125:       # document order and validating that the following bytes byte-match the
// 126:       # entry's `JSON.generate` round trip, so every recorded offset provably
// 127:       # reproduces the canonical parse.
// 128:       sig {
// 129:         params(payload: String, parsed: T::Hash[String, T.untyped])
// 130:           .returns(T.nilable(T::Hash[String, T::Hash[String, [Integer, Integer]]]))
// 131:       }
// 132:       def self.build(payload:, parsed:)
// 133:         data = T.let({ "top_level" => {} }, T::Hash[String, T::Hash[String, [Integer, Integer]]])
// 134:         SECTION_KEYS.each { |section| data[section] = {} }
// 135:         retries = 0
// 136:         position = 0
// 137:
// 138:         parsed.each do |key, value|
// 139:           location = locate(payload, key, value, position)
// 140:           return nil if location.nil?
// 141:
// 142:           value_start, value_bytesize = location
// 143:           T.must(data["top_level"])[key] = [value_start, value_bytesize]
// 144:
// 145:           if SECTION_KEYS.include?(key) && value.is_a?(Hash)
// 146:             entry_position = value_start
// 147:             value.each do |name, entry|
// 148:               entry_location = T.let(nil, T.nilable([Integer, Integer]))
// 149:               loop do
// 150:                 entry_location = locate(payload, name, entry, entry_position)
// 151:                 break unless entry_location.nil?
// 152:
// 153:                 retries += 1
// 154:                 return nil if retries > MAX_FALSE_MATCH_RETRIES
// 155:
// 156:                 next_position = payload.byteindex("#{name.to_json}:", entry_position)
// 157:                 return nil if next_position.nil?
// 158:
// 159:                 entry_position = next_position + 1
// 160:               end
// 161:
// 162:               entry_start, entry_bytesize = entry_location
// 163:               T.must(data[key])[name] = [entry_start, entry_bytesize]
// 164:               entry_position = entry_start + entry_bytesize
// 165:             end
// 166:           end
// 167:
// 168:           position = value_start + value_bytesize
// 169:         end
// 170:
// 171:         data
// 172:       end
// 173:
// 174:       # Finds `"<key>":<value>` at or after `position`, returning the value's
// 175:       # byte offset and length only when the payload bytes match the value's
// 176:       # canonical serialisation exactly.
// 177:       sig {
// 178:         params(payload: String, key: String, value: T.untyped, position: Integer)
// 179:           .returns(T.nilable([Integer, Integer]))
// 180:       }
// 181:       private_class_method def self.locate(payload, key, value, position)
// 182:         key_bytes = "#{key.to_json}:"
// 183:         key_position = payload.byteindex(key_bytes, position)
// 184:         return if key_position.nil?
// 185:
// 186:         value_bytes = JSON.generate(value)
// 187:         value_start = key_position + key_bytes.bytesize
// 188:         return if payload.byteslice(value_start, value_bytes.bytesize) != value_bytes
// 189:
// 190:         [value_start, value_bytes.bytesize]
// 191:       end
// 192:
// 193:       sig { returns(String) }
// 194:       attr_reader :payload
// 195:
// 196:       sig { returns(File::Stat) }
// 197:       attr_reader :source_stat
// 198:
// 199:       sig {
// 200:         params(payload: String, source_stat: File::Stat, top_level: T::Hash[String, T.untyped],
// 201:                sections: T::Hash[String, T::Hash[String, T.untyped]]).void
// 202:       }
// 203:       def initialize(payload:, source_stat:, top_level:, sections:)
// 204:         @payload = payload
// 205:         @source_stat = source_stat
// 206:         @top_level = top_level
// 207:         @sections = sections
// 208:       end
// 209:
// 210:       sig { params(name: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 211:       def formula_hash(name)
// 212:         entry_value("formulae", name)
// 213:       end
// 214:
// 215:       sig { params(name: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 216:       def cask_hash(name)
// 217:         entry_value("casks", name)
// 218:       end
// 219:
// 220:       sig { returns(T::Array[String]) }
// 221:       def formula_names
// 222:         @sections.fetch("formulae", {}).keys
// 223:       end
// 224:
// 225:       sig { returns(T::Array[String]) }
// 226:       def cask_names
// 227:         @sections.fetch("casks", {}).keys
// 228:       end
// 229:
// 230:       sig { params(name: String).returns(T::Boolean) }
// 231:       def formula_name?(name)
// 232:         @sections.fetch("formulae", {}).key?(name)
// 233:       end
// 234:
// 235:       sig { params(name: String).returns(T::Boolean) }
// 236:       def cask_name?(name)
// 237:         @sections.fetch("casks", {}).key?(name)
// 238:       end
// 239:
// 240:       sig { params(key: String).returns(T.untyped) }
// 241:       def top_level_value(key)
// 242:         return if SECTION_KEYS.include?(key)
// 243:
// 244:         location = @top_level[key]
// 245:         return if location.nil?
// 246:
// 247:         slice_value(key, location)
// 248:       end
// 249:
// 250:       private
// 251:
// 252:       sig { params(section: String, name: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 253:       def entry_value(section, name)
// 254:         location = @sections.fetch(section, {})[name]
// 255:         return if location.nil?
// 256:
// 257:         section_location = @top_level[section]
// 258:         raise Invalid, "no #{section} span for the #{name} index entry" unless section_location.is_a?(Array)
// 259:
// 260:         value = slice_value(name, location, within: section_location)
// 261:         raise Invalid, "#{section} index entry for #{name} is not a hash" unless value.is_a?(Hash)
// 262:
// 263:         value
// 264:       end
// 265:
// 266:       # Revalidates a recorded location against the verified payload bytes:
// 267:       # it must be preceded by the expected JSON key, sit inside the given
// 268:       # load-validated span and parse cleanly.
// 269:       sig { params(name: String, location: T.untyped, within: T.untyped).returns(T.untyped) }
// 270:       def slice_value(name, location, within: nil)
// 271:         offset, bytesize = location
// 272:         key_bytes = "#{name.to_json}:"
// 273:         key_offset = offset - key_bytes.bytesize if offset.is_a?(Integer)
// 274:         if !offset.is_a?(Integer) || !bytesize.is_a?(Integer) ||
// 275:            key_offset.nil? || key_offset.negative? || (offset + bytesize) > payload.bytesize ||
// 276:            payload.byteslice(key_offset, key_bytes.bytesize) != key_bytes ||
// 277:            outside_span?(key_offset, offset + bytesize, within)
// 278:           raise Invalid, "index location for #{name} does not match the payload"
// 279:         end
// 280:
// 281:         begin
// 282:           JSON.parse(T.must(payload.byteslice(offset, bytesize)), freeze: true)
// 283:         rescue JSON::ParserError
// 284:           raise Invalid, "index slice for #{name} does not parse"
// 285:         end
// 286:       end
// 287:
// 288:       sig { params(start_offset: Integer, end_offset: Integer, within: T.untyped).returns(T::Boolean) }
// 289:       def outside_span?(start_offset, end_offset, within)
// 290:         return false if within.nil?
// 291:
// 292:         within_offset, within_bytesize = within
// 293:         return true if !within_offset.is_a?(Integer) || !within_bytesize.is_a?(Integer)
// 294:
// 295:         start_offset < within_offset || end_offset > within_offset + within_bytesize
// 296:       end
// 297:     end
// 298:   end
// 299: end
