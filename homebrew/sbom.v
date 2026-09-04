module homebrew

import ruby
import time
import x.json2

const sbom_filename = 'sbom.spdx.json'

fn sbom_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn sbom_bool(value ruby.Value, key string, fallback bool) bool {
	raw := value.attributes[key] or { return fallback }
	return raw == 'true' || raw == '1'
}

fn sbom_values(value ruby.Value, key string) []ruby.Value {
	nested := value.map_data[key] or { return [] }
	return nested.as_array() or { [] }
}

fn sbom_strings(value ruby.Value, key string) []string {
	raw := value.attributes[key] or { return [] }
	return if raw == '' { [] } else { raw.split('\x1f') }
}

fn sbom_present(value ruby.Value) bool {
	return value.type_name != '' && value.type_name != 'NilClass' && !(value.type_name == 'String' && value.as_string() == '')
}

fn sbom_time(epoch i64) string {
	return time.unix(epoch).format_rfc3339().replace('.000Z', 'Z')
}

fn sbom_assert(value ruby.Value) ruby.Value {
	if !sbom_present(value) {
		return ruby.string_value('NOASSERTION')
	}
	return ruby.string_value(value.as_string())
}

fn sbom_string_map(attributes map[string]string) ruby.Value {
	mut values := map[string]ruby.Value{}
	for key, value in attributes {
		values[key] = ruby.string_value(value)
	}
	return ruby.map_value(values)
}

fn sbom_value_to_any(value ruby.Value) json2.Any {
	return match value.type_name {
		'Hash' {
			mut mapped := map[string]json2.Any{}
			for key, nested in value.map_data {
				mapped[key] = sbom_value_to_any(nested)
			}
			json2.Any(mapped)
		}
		'Array' {
			json2.Any((value.as_array() or { [] }).map(sbom_value_to_any(it)))
		}
		'Bool' { json2.Any(value.bool_data) }
		'Integer' { json2.Any(value.int_data) }
		'Float' { json2.Any(value.float_data) }
		'NilClass' { json2.Any(json2.null) }
		else { json2.Any(value.as_string()) }
	}
}

fn sbom_any_to_value(value json2.Any) ruby.Value {
	return match value {
		map[string]json2.Any {
			mut mapped := map[string]ruby.Value{}
			for key, nested in value {
				mapped[key] = sbom_any_to_value(nested)
			}
			ruby.map_value(mapped)
		}
		[]json2.Any { ruby.array_value(value.map(sbom_any_to_value(it))) }
		string { ruby.string_value(value) }
		bool { ruby.bool_value(value) }
		i64 { ruby.int_value(value) }
		int { ruby.int_value(value) }
		i32 { ruby.int_value(value) }
		i16 { ruby.int_value(value) }
		i8 { ruby.int_value(value) }
		u64 { ruby.int_value(i64(value)) }
		u32 { ruby.int_value(i64(value)) }
		u16 { ruby.int_value(i64(value)) }
		u8 { ruby.int_value(i64(value)) }
		f64 { ruby.float_value(value) }
		f32 { ruby.float_value(value) }
		time.Time { ruby.string_value(value.format_rfc3339()) }
		json2.Null { sbom_nil() }
	}
}

fn sbom_json(value ruby.Value) string {
	return json2.encode(sbom_value_to_any(value))
}

fn sbom_map_string(value ruby.Value, key string) string {
	nested := value.map_data[key] or { return '' }
	return nested.as_string()
}

fn sbom_source(receiver ruby.Value) ruby.Value {
	return receiver.map_data['source'] or { ruby.map_value({}) }
}

fn sbom_source_value(source ruby.Value, key string) ruby.Value {
	return source.map_data[key] or {
		if raw := source.attributes[key] {
			return if raw == '' { sbom_nil() } else { ruby.string_value(raw) }
		}
		return sbom_nil()
	}
}

fn sbom_package_id(value ruby.Value) string {
	return sbom_map_string(value, 'SPDXID')
}

fn sbom_external_ref(locator string) ruby.Value {
	return ruby.map_value({
		'referenceCategory': ruby.string_value('PACKAGE-MANAGER')
		'referenceLocator':  ruby.string_value(locator)
		'referenceType':     ruby.string_value('purl')
	})
}

fn sbom_checksum(value string) ruby.Value {
	return ruby.map_value({
		'algorithm':     ruby.string_value('SHA256')
		'checksumValue': ruby.string_value(value)
	})
}

fn sbom_relationship(element string, relationship string, related string) ruby.Value {
	return ruby.map_value({
		'spdxElementId':      ruby.string_value(element)
		'relationshipType':   ruby.string_value(relationship)
		'relatedSpdxElement': ruby.string_value(related)
	})
}

fn sbom_percent_encode(value string) string {
	mut encoded := ''
	for character in value.bytes() {
		if (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character in [
			`-`,
			`.`,
			`_`,
			`~`,
		] {
			encoded += character.ascii_str()
		} else {
			encoded += '%${character.hex().to_upper()}'
		}
	}
	return encoded
}

fn sbom_purl(full_name string, version string) string {
	parts := full_name.split('/')
	name := if parts.len > 0 { parts.last() } else { full_name }
	namespace := if parts.len > 1 { parts[..parts.len - 1].join('/') } else { '' }
	mut result := 'pkg:brew/'
	if namespace != '' {
		result += '${namespace}/'
	}
	result += sbom_percent_encode(name)
	if version != '' {
		result += '@${sbom_percent_encode(version)}'
	}
	return result
}

fn sbom_upstream_purl(url string, version string) string {
	if url.contains('files.pythonhosted.org') {
		filename := url.all_after_last('/')
		name := filename.all_before_last('-')
		if name != '' {
			return 'pkg:pypi/${sbom_percent_encode(name)}@${sbom_percent_encode(version)}'
		}
	}
	return ''
}

fn sbom_state(name string, spdxfile string, source_modified_time i64, compiler string,
	stdlib string, runtime_dependencies []ruby.Value, license string,
	built_on ruby.Value, source ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: 'SBOM'
		repr: name
		attributes: {
			'name':                 name
			'spdxfile':             spdxfile
			'source_modified_time': source_modified_time.str()
			'compiler':             compiler
			'stdlib':               stdlib
			'license':              license
		}
		map_data: {
			'runtime_dependencies': ruby.array_value(runtime_dependencies)
			'built_on':             built_on
			'source':               source
		}
	}
}

// Translated from Homebrew/brew `sbom.rb`.

// Ruby method `self.add_bottle_package_to_supplement(supplement, bottle_package)` at line 327.
pub fn ruby_sbom_l327_d16_self_add_bottle_package_to_supplement(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[0].type_name == 'NilClass' {
		return sbom_nil()
	}
	supplement := args[0]
	bottle := args[1]
	if tags := supplement.map_data['tags'] {
		if tags.type_name == 'Hash' {
			mut updated_tags := map[string]ruby.Value{}
			for tag, tag_supplement in tags.map_data {
				if tag_supplement.type_name != 'Hash' {
					continue
				}
				updated := ruby_sbom_l327_d16_self_add_bottle_package_to_supplement(tag_supplement, bottle)
				if updated.type_name != 'NilClass' {
					updated_tags[tag] = updated
				}
			}
			if updated_tags.len > 0 {
				return ruby.map_value({
					'tags': ruby.map_value(updated_tags)
				})
			}
		}
	}
	packages_value := supplement.map_data['packages'] or { return sbom_nil() }
	if packages_value.type_name != 'Array' {
		return sbom_nil()
	}
	mut packages := packages_value.as_array() or { [] }
	packages << bottle
	describes_value := supplement.map_data['documentDescribes'] or {
		ruby.string_array_value([])
	}
	mut describes := describes_value.as_string_array() or {
		(describes_value.as_array() or { [] }).map(it.as_string())
	}
	describes << sbom_package_id(bottle)
	relationships := supplement.map_data['relationships'] or { ruby.array_value([]) }
	return ruby.map_value({
		'documentDescribes': ruby.string_array_value(describes)
		'packages':          ruby.array_value(packages)
		'relationships':     if relationships.type_name == 'Array' {
			relationships
		} else {
			ruby.array_value([])
		}
	})
}
