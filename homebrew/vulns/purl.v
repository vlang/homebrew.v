module vulns

import ruby

// Translated from Homebrew/brew `vulns/purl.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct PackageUrlConfig {
pub:
	package_type string
	name         string
	namespace    ?string
	version      ?string
	qualifiers   map[string]string
	subpath      ?string
}

pub struct PackageUrl {
	package_type_value string
	name_value         string
	namespace_segments []string
	version_value      ?string
	qualifier_values   map[string]string
	subpath_segments   []string
}

pub fn (purl PackageUrl) package_type() string {
	return purl.package_type_value
}

pub fn (purl PackageUrl) name() string {
	return purl.name_value
}

pub fn (purl PackageUrl) namespace() ?string {
	if purl.namespace_segments.len == 0 {
		return none
	}
	return purl.namespace_segments.join('/')
}

pub fn (purl PackageUrl) version() ?string {
	return purl.version_value
}

pub fn (purl PackageUrl) qualifiers() map[string]string {
	return purl.qualifier_values.clone()
}

pub fn (purl PackageUrl) subpath() ?string {
	if purl.subpath_segments.len == 0 {
		return none
	}
	return purl.subpath_segments.join('/')
}

pub fn normalize_purl_components(package_type string, namespace ?string,
	name string) (?string, string) {
	mut normalized_namespace := namespace
	mut normalized_name := name
	match package_type {
		'pypi' {
			normalized_name = name.to_lower().replace('_', '-')
		}
		'hex' {
			normalized_namespace = if value := namespace { value.to_lower() } else { none }
			normalized_name = name.to_lower()
		}
		'cpan' {
			normalized_namespace = if value := namespace { value.to_upper() } else { none }
		}
		else {}
	}
	return normalized_namespace, normalized_name
}

fn valid_purl_type(package_type string) bool {
	if package_type.len == 0 || !((package_type[0] >= `a` && package_type[0] <= `z`) || (package_type[0] >= `0` && package_type[0] <= `9`)) {
		return false
	}
	return package_type.bytes().all((it >= `a` && it <= `z`) || (it >= `0` && it <= `9`) || it in [
		`-`,
		`.`,
		`+`,
	])
}

fn normalize_purl_path_segments(value ?string, field string) ![]string {
	if raw := value {
		if raw == '' {
			return []string{}
		}
		mut segments := []string{}
		for segment in raw.split('/') {
			if segment == '' {
				continue
			}
			if field == 'subpath' && segment in ['.', '..'] {
				return error('PURL subpath cannot contain `${segment}`')
			}
			segments << segment
		}
		return segments
	}
	return []string{}
}

fn normalize_purl_qualifiers(values map[string]string) !map[string]string {
	mut normalized := map[string]string{}
	for key, value in values {
		lower_key := key.to_lower()
		if lower_key == '' || !(lower_key[0] >= `a` && lower_key[0] <= `z`) || !lower_key.bytes().all((it >= `a` && it <= `z`) || (it >= `0` && it <= `9`) || it in [
			`-`,
			`.`,
			`_`,
		]) {
			return error('invalid PURL qualifier key `${key}`')
		}
		if value == '' {
			return error('PURL qualifier `${key}` must not be empty')
		}
		if lower_key in normalized {
			return error('duplicate PURL qualifier `${lower_key}`')
		}
		normalized[lower_key] = value
	}
	return normalized
}

fn new_package_url_from_segments(package_type string, namespace_segments []string, name string,
	version ?string, qualifiers map[string]string, subpath_segments []string) !PackageUrl {
	if package_type == '' {
		return error('PURL type is required')
	}
	if name == '' {
		return error('PURL name is required')
	}
	normalized_type := package_type.to_lower()
	if !valid_purl_type(normalized_type) {
		return error('invalid PURL type `${package_type}`')
	}
	_, normalized_name := normalize_purl_components(normalized_type, none, name)
	normalized_namespace_segments := match normalized_type {
		'hex' { namespace_segments.map(it.to_lower()) }
		'cpan' { namespace_segments.map(it.to_upper()) }
		else { namespace_segments.clone() }
	}
	mut normalized_version := ?string(none)
	if value := version {
		if value != '' {
			normalized_version = value
		}
	}
	return PackageUrl{
		package_type_value: normalized_type
		name_value: normalized_name
		namespace_segments: normalized_namespace_segments.clone()
		version_value: normalized_version
		qualifier_values: normalize_purl_qualifiers(qualifiers)!
		subpath_segments: subpath_segments.clone()
	}
}

pub fn new_package_url(config PackageUrlConfig) !PackageUrl {
	namespace_segments := normalize_purl_path_segments(config.namespace, 'namespace')!
	subpath_segments := normalize_purl_path_segments(config.subpath, 'subpath')!
	return new_package_url_from_segments(config.package_type, namespace_segments, config.name, config.version, config.qualifiers, subpath_segments)
}

fn purl_unreserved(character u8) bool {
	return (character >= `A` && character <= `Z`) || (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`) || character in [
		`-`,
		`.`,
		`_`,
		`~`,
		`:`,
	]
}

fn purl_hex_digit(value u8) u8 {
	return if value < 10 { `0` + value } else { `A` + value - 10 }
}

pub fn encode_purl_component(component string) string {
	mut encoded := []u8{cap: component.len}
	for character in component.bytes() {
		if purl_unreserved(character) {
			encoded << character
		} else {
			encoded << `%`
			encoded << purl_hex_digit(character >> 4)
			encoded << purl_hex_digit(character & 0x0f)
		}
	}
	return encoded.bytestr()
}

fn purl_hex_value(character u8) ?u8 {
	if character >= `0` && character <= `9` {
		return u8(character - `0`)
	}
	if character >= `A` && character <= `F` {
		return u8(character - `A` + 10)
	}
	if character >= `a` && character <= `f` {
		return u8(character - `a` + 10)
	}
	return none
}

fn decode_purl_component(component string) !string {
	mut decoded := []u8{cap: component.len}
	mut index := 0
	for index < component.len {
		if component[index] != `%` {
			decoded << component[index]
			index++
			continue
		}
		if index + 2 >= component.len {
			return error('incomplete percent escape in PURL component')
		}
		high := purl_hex_value(component[index + 1]) or {
			return error('invalid percent escape in PURL component')
		}
		low := purl_hex_value(component[index + 2]) or {
			return error('invalid percent escape in PURL component')
		}
		decoded << (high << 4 | low)
		index += 3
	}
	return decoded.bytestr()
}

pub fn (purl PackageUrl) str() string {
	mut result := 'pkg:${purl.package_type_value}/'
	if purl.namespace_segments.len > 0 {
		result += '${purl.namespace_segments.map(encode_purl_component(it)).join('/')}/'
	}
	result += encode_purl_component(purl.name_value)
	if version := purl.version_value {
		result += '@${encode_purl_component(version)}'
	}
	if purl.qualifier_values.len > 0 {
		mut keys := purl.qualifier_values.keys()
		keys.sort()
		result += '?' + keys.map('${encode_purl_component(it)}=${encode_purl_component(purl.qualifier_values[it])}').join('&')
	}
	if purl.subpath_segments.len > 0 {
		result += '#${purl.subpath_segments.map(encode_purl_component(it)).join('/')}'
	}
	return result
}

pub fn parse_package_url(value string) !PackageUrl {
	if !value.starts_with('pkg:') {
		return error('PURL must start with `pkg:`')
	}
	mut main := value[4..]
	mut raw_subpath := ''
	if fragment := main.index('#') {
		raw_subpath = main[fragment + 1..]
		main = main[..fragment]
		if raw_subpath == '' {
			return error('PURL subpath must not be empty')
		}
	}
	mut raw_qualifiers := ''
	if query := main.index('?') {
		raw_qualifiers = main[query + 1..]
		main = main[..query]
		if raw_qualifiers == '' {
			return error('PURL qualifiers must not be empty')
		}
	}
	type_end := main.index('/') or { return error('PURL is missing its name') }
	package_type := main[..type_end]
	mut path := main[type_end + 1..]
	mut version := ?string(none)
	if at := path.last_index('@') {
		if at + 1 >= path.len {
			return error('PURL version must not be empty')
		}
		version = decode_purl_component(path[at + 1..])!
		path = path[..at]
	}
	path_parts := path.split('/')
	if path_parts.len == 0 || path_parts.last() == '' {
		return error('PURL name is required')
	}
	name := decode_purl_component(path_parts.last())!
	mut namespace_segments := []string{}
	if path_parts.len > 1 {
		for raw_segment in path_parts[..path_parts.len - 1] {
			if raw_segment == '' {
				continue
			}
			namespace_segments << decode_purl_component(raw_segment)!
		}
	}
	mut qualifiers := map[string]string{}
	if raw_qualifiers != '' {
		for pair in raw_qualifiers.split('&') {
			equals := pair.index('=') or { return error('PURL qualifier is missing `=`') }
			key := decode_purl_component(pair[..equals])!
			qualifier_value := decode_purl_component(pair[equals + 1..])!
			if key.to_lower() in qualifiers {
				return error('duplicate PURL qualifier `${key}`')
			}
			qualifiers[key.to_lower()] = qualifier_value
		}
	}
	mut subpath_segments := []string{}
	if raw_subpath != '' {
		for raw_segment in raw_subpath.split('/') {
			if raw_segment == '' {
				continue
			}
			segment := decode_purl_component(raw_segment)!
			if segment in ['.', '..'] {
				return error('PURL subpath cannot contain `${segment}`')
			}
			subpath_segments << segment
		}
		if subpath_segments.len == 0 {
			return error('PURL subpath must contain a segment')
		}
	}
	return new_package_url_from_segments(package_type, namespace_segments, name, version, qualifiers, subpath_segments)
}

pub fn (purl PackageUrl) equals(other PackageUrl) bool {
	return purl.str() == other.str()
}

pub fn (purl PackageUrl) hash() i64 {
	mut hash := u64(14_695_981_039_346_656_037)
	for character in purl.str().bytes() {
		hash ^= u64(character)
		hash *= u64(1_099_511_628_211)
	}
	return i64(hash)
}

pub fn purl_value(purl PackageUrl) ruby.Value {
	mut qualifier_values := map[string]ruby.Value{}
	for key, value in purl.qualifiers() {
		qualifier_values[key] = ruby.string_value(value)
	}
	return ruby.Value{
		type_name: 'Purl'
		repr: purl.str()
		map_data: qualifier_values
		attributes: {
			'type':      purl.package_type()
			'name':      purl.name()
			'namespace': purl.namespace() or { '' }
			'version':   purl.version() or { '' }
			'subpath':   purl.subpath() or { '' }
		}
	}
}

pub fn purl_from_value(value ruby.Value) !PackageUrl {
	if value.type_name != 'Purl' {
		return error('expected Purl, got ${value.type_name}')
	}
	return parse_package_url(value.repr)
}

struct PurlOptionalString {
	value ?string
}

fn purl_optional_string(value ruby.Value) !PurlOptionalString {
	if value.type_name == 'NilClass' {
		return PurlOptionalString{}
	}
	if value.type_name != 'String' {
		return error('expected String or nil, got ${value.type_name}')
	}
	return PurlOptionalString{
		value: value.as_string()
	}
}

fn purl_config_from_args(args []ruby.Value) !PackageUrlConfig {
	if args.len == 1 && args[0].type_name == 'Hash' {
		values := args[0].map_data.clone()
		package_type := values['type'] or { values['package_type'] or { return error('type is required') } }
		name := values['name'] or { return error('name is required') }
		mut qualifiers := map[string]string{}
		if raw_qualifiers := values['qualifiers'] {
			if raw_qualifiers.type_name != 'Hash' {
				return error('qualifiers must be a Hash')
			}
			for key, value in raw_qualifiers.map_data {
				qualifiers[key] = value.as_string()
			}
		}
		return PackageUrlConfig{
			package_type: package_type.as_string()
			name: name.as_string()
			namespace: purl_optional_string(values['namespace'] or {
				ruby.object_value('NilClass', 'nil')})!.value
			version: purl_optional_string(values['version'] or {
				ruby.object_value('NilClass', 'nil')})!.value
			qualifiers: qualifiers
			subpath: purl_optional_string(values['subpath'] or {
				ruby.object_value('NilClass', 'nil')})!.value
		}
	}
	if args.len < 2 {
		return error('PURL initialize requires type and name')
	}
	return PackageUrlConfig{
		package_type: args[0].as_string()
		name: args[1].as_string()
		namespace: if args.len > 2 { purl_optional_string(args[2])!.value } else { none }
		version: if args.len > 3 { purl_optional_string(args[3])!.value } else { none }
	}
}

fn purl_boundary_receiver(args []ruby.Value) !PackageUrl {
	if args.len == 0 {
		return error('missing Purl receiver')
	}
	return purl_from_value(args[0])
}

// Ruby attr_reader `attr_reader :type, :name` at line 14.
pub fn ruby_purl_l14_d1_type(args ...ruby.Value) ruby.Value {
	purl := purl_boundary_receiver(args) or { panic(err) }
	return ruby.string_value(purl.package_type())
}

// Ruby attr_reader `attr_reader :type, :name` at line 14.
pub fn ruby_purl_l14_d2_name(args ...ruby.Value) ruby.Value {
	purl := purl_boundary_receiver(args) or { panic(err) }
	return ruby.string_value(purl.name())
}

// Ruby attr_reader `attr_reader :namespace, :version` at line 17.
pub fn ruby_purl_l17_d3_namespace(args ...ruby.Value) ruby.Value {
	purl := purl_boundary_receiver(args) or { panic(err) }
	return if namespace := purl.namespace() {
		ruby.string_value(namespace)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby attr_reader `attr_reader :namespace, :version` at line 17.
pub fn ruby_purl_l17_d4_version(args ...ruby.Value) ruby.Value {
	purl := purl_boundary_receiver(args) or { panic(err) }
	return if version := purl.version() {
		ruby.string_value(version)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `initialize(type:, name:, namespace: nil, version: nil)` at line 22.
pub fn ruby_purl_l22_d5_initialize(args ...ruby.Value) ruby.Value {
	config := purl_config_from_args(args) or { panic(err) }
	return purl_value(new_package_url(config) or { panic(err) })
}

// Ruby method `to_s` at line 36.
pub fn ruby_purl_l36_d6_to_s(args ...ruby.Value) ruby.Value {
	purl := purl_boundary_receiver(args) or { panic(err) }
	return ruby.string_value(purl.str())
}

// Ruby method `==(other)` at line 48.
pub fn ruby_purl_l48_d7_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'Purl' {
		return ruby.bool_value(false)
	}
	left := purl_from_value(args[0]) or { return ruby.bool_value(false) }
	right := purl_from_value(args[1]) or { return ruby.bool_value(false) }
	return ruby.bool_value(left.equals(right))
}

// Ruby alias `alias eql? ==` at line 56.
pub fn ruby_purl_l56_d8_eql(args ...ruby.Value) ruby.Value {
	return ruby_purl_l48_d7_anonymous(...args)
}

// Ruby method `hash` at line 59.
pub fn ruby_purl_l59_d9_hash(args ...ruby.Value) ruby.Value {
	purl := purl_boundary_receiver(args) or { panic(err) }
	return ruby.int_value(purl.hash())
}

// Ruby method `self.encode(component)` at line 67.
pub fn ruby_purl_l67_d10_self_encode(args ...ruby.Value) ruby.Value {
	return ruby.string_value(encode_purl_component(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `self.normalize(type, namespace, name)` at line 76.
pub fn ruby_purl_l76_d11_self_normalize(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('NilClass', 'nil')
	}
	namespace := purl_optional_string(args[1]) or { panic(err) }
	normalized_namespace, normalized_name := normalize_purl_components(args[0].as_string().to_lower(), namespace.value, args[2].as_string())
	return ruby.array_value([
		if value := normalized_namespace {
			ruby.string_value(value)
		} else {
			ruby.object_value('NilClass', 'nil')
		},
		ruby.string_value(normalized_name),
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Vulns
// 6:     # A package URL per https://github.com/package-url/purl-spec.
// 7:     #
// 8:     # Minimal builder for the registry types Homebrew derives from formula
// 9:     # source URLs. Applies the spec's per-type name normalisation and RFC 3986
// 10:     # percent-encoding when serialised. Parsing, qualifiers and subpath are
// 11:     # intentionally omitted.
// 12:     class Purl
// 13:       sig { returns(String) }
// 14:       attr_reader :type, :name
// 15:
// 16:       sig { returns(T.nilable(String)) }
// 17:       attr_reader :namespace, :version
// 18:
// 19:       sig {
// 20:         params(type: String, name: String, namespace: T.nilable(String), version: T.nilable(String)).void
// 21:       }
// 22:       def initialize(type:, name:, namespace: nil, version: nil)
// 23:         raise ArgumentError, "type is required" if type.empty?
// 24:         raise ArgumentError, "name is required" if name.empty?
// 25:
// 26:         @type = T.let(type.downcase.freeze, String)
// 27:         namespace = nil if namespace && namespace.empty?
// 28:         namespace, name = self.class.normalize(@type, namespace, name)
// 29:         @namespace = T.let(namespace && -namespace, T.nilable(String))
// 30:         @name = T.let(-name, String)
// 31:         version = nil if version && version.empty?
// 32:         @version = T.let(version && -version, T.nilable(String))
// 33:       end
// 34:
// 35:       sig { returns(String) }
// 36:       def to_s
// 37:         purl = "pkg:#{@type}/"
// 38:         if @namespace
// 39:           purl << @namespace.split("/").reject(&:empty?).map { |s| self.class.encode(s) }.join("/")
// 40:           purl << "/"
// 41:         end
// 42:         purl << self.class.encode(@name)
// 43:         purl << "@#{self.class.encode(@version)}" if @version
// 44:         purl.freeze
// 45:       end
// 46:
// 47:       sig { params(other: T.anything).returns(T::Boolean) }
// 48:       def ==(other)
// 49:         case other
// 50:         when Purl
// 51:           type == other.type && namespace == other.namespace &&
// 52:             name == other.name && version == other.version
// 53:         else false
// 54:         end
// 55:       end
// 56:       alias eql? ==
// 57:
// 58:       sig { returns(Integer) }
// 59:       def hash
// 60:         [type, namespace, name, version].hash
// 61:       end
// 62:
// 63:       # Percent-encode a single purl component. The spec permits the RFC 3986
// 64:       # unreserved set plus `:` unencoded; `+` for space is forbidden so
// 65:       # `URI.encode_www_form_component` is unsuitable.
// 66:       sig { params(component: String).returns(String) }
// 67:       def self.encode(component)
// 68:         component.b.gsub(/[^A-Za-z0-9\-._~:]/n) { |c| format("%%%02X", c.ord) }
// 69:       end
// 70:
// 71:       # Per-type normalisation from purl-spec PURL-TYPES.rst for the types we emit.
// 72:       sig {
// 73:         params(type: String, namespace: T.nilable(String), name: String)
// 74:           .returns([T.nilable(String), String])
// 75:       }
// 76:       def self.normalize(type, namespace, name)
// 77:         case type
// 78:         when "pypi"
// 79:           [namespace, name.downcase.tr("_", "-")]
// 80:         when "hex"
// 81:           [namespace&.downcase, name.downcase]
// 82:         when "cpan"
// 83:           [namespace&.upcase, name]
// 84:         else
// 85:           [namespace, name]
// 86:         end
// 87:       end
// 88:     end
// 89:   end
// 90: end
