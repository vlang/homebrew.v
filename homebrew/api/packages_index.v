module api

import ruby
import os
import x.json2

// Translated from Homebrew/brew `api/packages_index.rb`.

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
	value   ruby.Value
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
	data := ruby.parse_json_value(contents) or { return none }
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

pub fn packages_index_write(target string, payload string, parsed ruby.Value,
	source_stat PackageSourceStat, running_as_root_but_not_owned bool) ! {
	if running_as_root_but_not_owned {
		return
	}
	built := packages_index_build(payload, parsed) or { return }
	mut values := map[string]ruby.Value{}
	values['version'] = ruby.int_value(1)
	values['source_size'] = ruby.int_value(source_stat.size)
	values['source_mtime_ns'] = ruby.int_value(source_stat.mtime_ns)
	values['payload_bytesize'] = ruby.int_value(payload.len)
	values['top_level'] = package_locations_value(built.top_level)
	for section in ['formulae', 'casks'] {
		values[section] = package_locations_value(built.sections[section] or { map[string]PackageLocation{} })
	}
	index_path := packages_index_path_for(target)
	temporary_path := '${index_path}.tmp'
	defer { if os.exists(temporary_path) { os.rm(temporary_path) or {} } }
	os.write_file(temporary_path, json2.encode(ruby.json_any_from_value(ruby.map_value(values))))!
	os.mv(temporary_path, index_path)!
}

pub fn packages_index_build(payload string, parsed ruby.Value) ?PackagesIndexData {
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

pub fn packages_index_locate(payload string, key string, value ruby.Value,
	position int) ?PackageLocation {
	key_bytes := '${json2.encode(key)}:'
	key_position := payload.index_after(key_bytes, position) or { return none }
	value_bytes := json2.encode(ruby.json_any_from_value(value))
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
	within ?PackageLocation) !ruby.Value {
	key_bytes := '${json2.encode(name)}:'
	key_offset := location.offset - key_bytes.len
	if location.offset < 0 || location.bytesize < 0 || key_offset < 0 || location.offset + location.bytesize > index.payload.len || index.payload[key_offset..key_offset + key_bytes.len] != key_bytes || packages_outside_span(key_offset, location.offset + location.bytesize, within) {
		return error('index location for ${name} does not match the payload')
	}
	slice := index.payload[location.offset..location.offset + location.bytesize]
	return ruby.parse_json_value(slice) or { return error('index slice for ${name} does not parse') }
}

pub fn packages_outside_span(start_offset int, end_offset int, within ?PackageLocation) bool {
	span := within or { return false }
	return start_offset < span.offset || end_offset > span.offset + span.bytesize
}

fn packages_source_fingerprint(stat PackageSourceStat) PackageSourceStat {
	return stat
}

fn packages_index_value(index PackagesIndex) ruby.Value {
	return ruby.map_value({
		'payload':     ruby.string_value(index.payload)
		'source_stat': package_source_stat_value(index.source_stat)
		'top_level':   package_locations_value(index.top_level)
		'sections':    package_sections_value(index.sections)
	})
}

fn packages_index_from_args(args []ruby.Value) PackagesIndex {
	if args.len == 0 { panic('PackagesIndex receiver required') }
	value := args[0]
	return PackagesIndex{
		payload: (value.map_data['payload'] or { ruby.string_value('') }).as_string()
		source_stat: package_source_stat_from_value(value.map_data['source_stat'] or { packages_nil_value() })
		top_level: package_locations_from_value(value.map_data['top_level'] or { packages_nil_value() })
		sections: package_sections_from_value(value.map_data['sections'] or { packages_nil_value() })
	}
}

fn packages_index_data_value(data PackagesIndexData) ruby.Value {
	return ruby.map_value({
		'top_level': package_locations_value(data.top_level)
		'sections':  package_sections_value(data.sections)
	})
}

fn package_source_stat_value(stat PackageSourceStat) ruby.Value {
	return ruby.map_value({
		'size':     ruby.int_value(stat.size)
		'mtime_ns': ruby.int_value(stat.mtime_ns)
	})
}

fn package_source_stat_from_value(value ruby.Value) PackageSourceStat {
	return PackageSourceStat{
		size: (value.map_data['size'] or { ruby.int_value(0) }).int_data
		mtime_ns: (value.map_data['mtime_ns'] or { ruby.int_value(0) }).int_data
	}
}

fn package_location_value(location PackageLocation) ruby.Value {
	return ruby.array_value([
		ruby.int_value(location.offset),
		ruby.int_value(location.bytesize),
	])
}

fn package_location_from_value(value ruby.Value) PackageLocation {
	values := value.as_array() or { []ruby.Value{} }
	return PackageLocation{
		offset: if values.len > 0 { int(values[0].int_data) } else { -1 }
		bytesize: if values.len > 1 { int(values[1].int_data) } else { -1 }
	}
}

fn package_locations_value(locations map[string]PackageLocation) ruby.Value {
	mut values := map[string]ruby.Value{}
	for key, location in locations {
		values[key] = package_location_value(location)
	}
	return ruby.map_value(values)
}

fn package_locations_from_value(value ruby.Value) map[string]PackageLocation {
	return package_locations_from_value_checked(value) or { map[string]PackageLocation{} }
}

fn package_locations_from_value_checked(value ruby.Value) !map[string]PackageLocation {
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

fn package_sections_value(sections map[string]map[string]PackageLocation) ruby.Value {
	mut values := map[string]ruby.Value{}
	for key, locations in sections {
		values[key] = package_locations_value(locations)
	}
	return ruby.map_value(values)
}

fn package_sections_from_value(value ruby.Value) map[string]map[string]PackageLocation {
	mut sections := map[string]map[string]PackageLocation{}
	if value.type_name != 'Hash' {
		return sections
	}
	for key, locations in value.map_data {
		sections[key] = package_locations_from_value(locations)
	}
	return sections
}

fn packages_nil_value() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}
