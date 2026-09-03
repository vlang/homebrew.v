module homebrew

import brew_runtime
import x.json2

// Translated from Homebrew/brew `formula_info.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct FormulaInfo {
pub mut:
	info              map[string]json2.Any
	native_bottle_tag string
}

pub fn new_formula_info(info map[string]json2.Any, native_bottle_tag string) &FormulaInfo {
	return &FormulaInfo{
		info: info.clone()
		native_bottle_tag: native_bottle_tag
	}
}

pub fn formula_info_from_json(contents string, native_bottle_tag string) !&FormulaInfo {
	decoded := json2.decode[json2.Any](contents)!
	if decoded !is map[string]json2.Any {
		return error('formula info must be a JSON object')
	}
	return new_formula_info(decoded as map[string]json2.Any, native_bottle_tag)
}

pub fn formula_info_lookup_output(output string, success bool,
	native_bottle_tag string) ?&FormulaInfo {
	if !success {
		return none
	}
	decoded := json2.decode[json2.Any](output) or { return none }
	if decoded !is []json2.Any {
		return none
	}
	items := decoded as []json2.Any
	if items.len == 0 || items[0] !is map[string]json2.Any {
		return none
	}
	return new_formula_info(items[0] as map[string]json2.Any, native_bottle_tag)
}

fn formula_info_nested_map(root map[string]json2.Any, keys ...string) ?map[string]json2.Any {
	mut current := root.clone()
	for key in keys {
		value := current[key] or { return none }
		if value !is map[string]json2.Any {
			return none
		}
		current = value as map[string]json2.Any
	}
	return current
}

fn formula_info_any_string(value json2.Any) string {
	return match value {
		string { value }
		i64 { value.str() }
		f64 { value.str() }
		bool { value.str() }
		else { '' }
	}
}

pub fn (formula FormulaInfo) bottle_tags() []string {
	files := formula_info_nested_map(formula.info, 'bottle', 'stable', 'files') or { return [] }
	return files.keys()
}

pub fn (formula FormulaInfo) bottle_info(tag string) ?map[string]string {
	files := formula_info_nested_map(formula.info, 'bottle', 'stable', 'files') or { return none }
	value := files[tag] or { return none }
	if value !is map[string]json2.Any {
		return none
	}
	attributes := value as map[string]json2.Any
	url := attributes['url'] or { return none }
	sha256 := attributes['sha256'] or { return none }
	return {
		'url':    formula_info_any_string(url)
		'sha256': formula_info_any_string(sha256)
	}
}

pub fn (formula FormulaInfo) any_bottle_tag() ?string {
	tags := formula.bottle_tags()
	if formula.native_bottle_tag in tags {
		return formula.native_bottle_tag
	}
	if tags.len > 0 {
		return tags[0]
	}
	return none
}

pub fn (formula FormulaInfo) bottle_info_any() ?map[string]string {
	tag := formula.any_bottle_tag() or { return none }
	return formula.bottle_info(tag)
}

pub fn (formula FormulaInfo) version(spec_type string) !Version {
	versions := formula_info_nested_map(formula.info, 'versions') or {
		return error('formula info has no versions')
	}
	value := versions[spec_type.trim_string_left(':')] or {
		return error('formula info has no ${spec_type} version')
	}
	return new_version(formula_info_any_string(value))
}

pub fn (formula FormulaInfo) revision() int {
	value := formula.info['revision'] or { return 0 }
	return match value {
		i64 { int(value) }
		f64 { int(value) }
		string { value.int() }
		else { 0 }
	}
}

pub fn (formula FormulaInfo) pkg_version(spec_type string) !PkgVersion {
	return new_pkg_version(formula.version(spec_type)!, formula.revision())
}

fn formula_info_value(formula &FormulaInfo) brew_runtime.Value {
	return brew_runtime.structured_value('FormulaInfo', json2.encode(json2.Any(formula.info)), {
		'formula_info_address': u64(voidptr(formula)).str()
	})
}

fn formula_info_from_value(value brew_runtime.Value) &FormulaInfo {
	address := value.attributes['formula_info_address'] or { panic('invalid FormulaInfo') }
	return unsafe { &FormulaInfo(voidptr(address.u64())) }
}

pub fn formula_info_boundary(formula &FormulaInfo) brew_runtime.Value {
	return formula_info_value(formula)
}

fn formula_info_map_value(values map[string]string) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
}

// Ruby attr_accessor `attr_accessor :info` at line 8.
pub fn ruby_formula_info_l8_d1_info(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'FormulaInfo is required')
	}
	formula := formula_info_from_value(args[0])
	return brew_runtime.object_value('Hash', json2.encode(json2.Any(formula.info)))
}

// Ruby attr_accessor `attr_accessor :info` at line 8.
pub fn ruby_formula_info_l8_d2_info(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'FormulaInfo and info are required')
	}
	decoded := json2.decode[json2.Any](args[1].as_string()) or {
		return brew_runtime.object_value('JSON::ParserError', err.msg())
	}
	if decoded !is map[string]json2.Any {
		return brew_runtime.object_value('TypeError', 'info must be a Hash')
	}
	mut formula := formula_info_from_value(args[0])
	formula.info = (decoded as map[string]json2.Any).clone()
	return args[1]
}

// Ruby method `initialize(info)` at line 11.
pub fn ruby_formula_info_l11_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'info is required')
	}
	formula := formula_info_from_json(args[0].as_string(), if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}) or { return brew_runtime.object_value('JSON::ParserError', err.msg()) }
	return formula_info_value(formula)
}

// Ruby method `self.lookup(name)` at line 18.
pub fn ruby_formula_info_l18_d4_self_lookup(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	success := if args.len > 2 { args[2].bool_data } else { true }
	native_tag := if args.len > 3 { args[3].as_string() } else { '' }
	formula := formula_info_lookup_output(args[1].as_string(), success, native_tag) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return formula_info_value(formula)
}

// Ruby method `bottle_tags` at line 34.
pub fn ruby_formula_info_l34_d5_bottle_tags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(if args.len > 0 {
		formula_info_from_value(args[0]).bottle_tags()
	} else {
		[]
	})
}

// Ruby method `bottle_info(my_bottle_tag = Utils::Bottles.tag)` at line 43.
pub fn ruby_formula_info_l43_d6_bottle_info(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	formula := formula_info_from_value(args[0])
	tag := if args.len > 1 { args[1].as_string() } else { formula.native_bottle_tag }
	info := formula.bottle_info(tag) or { return brew_runtime.object_value('NilClass', 'nil') }
	return formula_info_map_value(info)
}

// Ruby method `bottle_info_any` at line 54.
pub fn ruby_formula_info_l54_d7_bottle_info_any(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	info := formula_info_from_value(args[0]).bottle_info_any() or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return formula_info_map_value(info)
}

// Ruby method `any_bottle_tag` at line 59.
pub fn ruby_formula_info_l59_d8_any_bottle_tag(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	tag := formula_info_from_value(args[0]).any_bottle_tag() or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_value(tag)
}

// Ruby method `version(spec_type)` at line 66.
pub fn ruby_formula_info_l66_d9_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'FormulaInfo and spec type are required')
	}
	version := formula_info_from_value(args[0]).version(args[1].as_string()) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('Version', version.to_s())
}

// Ruby method `pkg_version(spec_type = :stable)` at line 72.
pub fn ruby_formula_info_l72_d10_pkg_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'FormulaInfo is required')
	}
	spec_type := if args.len > 1 { args[1].as_string() } else { 'stable' }
	version := formula_info_from_value(args[0]).pkg_version(spec_type) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('PkgVersion', version.to_s())
}

// Ruby method `revision` at line 77.
pub fn ruby_formula_info_l77_d11_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(if args.len > 0 {
		formula_info_from_value(args[0]).revision()
	} else {
		0
	})
}

// Ruby method `self.force_utf8!(str)` at line 82.
pub fn ruby_formula_info_l82_d12_self_force_utf8(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args[0] } else { brew_runtime.object_value('NilClass', 'nil') }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Formula information drawn from an external `brew info --json` call.
// 5: class FormulaInfo
// 6:   # The whole info structure parsed from the JSON.
// 7:   sig { returns(T::Hash[String, T.untyped]) }
// 8:   attr_accessor :info
// 9:
// 10:   sig { params(info: T::Hash[String, T.untyped]).void }
// 11:   def initialize(info)
// 12:     @info = info
// 13:   end
// 14:
// 15:   # Looks up formula on disk and reads its info.
// 16:   # Returns nil if formula is absent or if there was an error reading it.
// 17:   sig { params(name: Pathname).returns(T.nilable(FormulaInfo)) }
// 18:   def self.lookup(name)
// 19:     json = Utils.popen_read(
// 20:       *HOMEBREW_RUBY_EXEC_ARGS,
// 21:       HOMEBREW_LIBRARY_PATH/"brew.rb",
// 22:       "info",
// 23:       "--json=v1",
// 24:       name,
// 25:     )
// 26:
// 27:     return unless $CHILD_STATUS.success?
// 28:
// 29:     force_utf8!(json)
// 30:     FormulaInfo.new(JSON.parse(json)[0])
// 31:   end
// 32:
// 33:   sig { returns(T::Array[String]) }
// 34:   def bottle_tags
// 35:     return [] unless info["bottle"]["stable"]
// 36:
// 37:     info["bottle"]["stable"]["files"].keys
// 38:   end
// 39:
// 40:   sig {
// 41:     params(my_bottle_tag: T.any(Utils::Bottles::Tag, T.nilable(String))).returns(T.nilable(T::Hash[String, String]))
// 42:   }
// 43:   def bottle_info(my_bottle_tag = Utils::Bottles.tag)
// 44:     tag_s = my_bottle_tag.to_s
// 45:     return unless info["bottle"]["stable"]
// 46:
// 47:     btl_info = info["bottle"]["stable"]["files"][tag_s]
// 48:     return unless btl_info
// 49:
// 50:     { "url" => btl_info["url"], "sha256" => btl_info["sha256"] }
// 51:   end
// 52:
// 53:   sig { returns(T.nilable(T::Hash[String, String])) }
// 54:   def bottle_info_any
// 55:     bottle_info(any_bottle_tag)
// 56:   end
// 57:
// 58:   sig { returns(T.nilable(String)) }
// 59:   def any_bottle_tag
// 60:     tag = Utils::Bottles.tag.to_s
// 61:     # Prefer native bottles as a convenience for download caching
// 62:     bottle_tags.include?(tag) ? tag : bottle_tags.first
// 63:   end
// 64:
// 65:   sig { params(spec_type: Symbol).returns(Version) }
// 66:   def version(spec_type)
// 67:     version_str = info["versions"][spec_type.to_s]
// 68:     Version.new(version_str)
// 69:   end
// 70:
// 71:   sig { params(spec_type: Symbol).returns(PkgVersion) }
// 72:   def pkg_version(spec_type = :stable)
// 73:     PkgVersion.new(version(spec_type), revision)
// 74:   end
// 75:
// 76:   sig { returns(Integer) }
// 77:   def revision
// 78:     info["revision"]
// 79:   end
// 80:
// 81:   sig { params(str: String).void }
// 82:   def self.force_utf8!(str)
// 83:     str.force_encoding("UTF-8") if str.respond_to?(:force_encoding)
// 84:   end
// 85: end
