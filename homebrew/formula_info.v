module homebrew

import ruby
import x.json2

// Translated from Homebrew/brew `formula_info.rb`.
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

fn formula_info_value(formula &FormulaInfo) ruby.Value {
	return ruby.structured_value('FormulaInfo', json2.encode(json2.Any(formula.info)), {
		'formula_info_address': u64(voidptr(formula)).str()
	})
}

fn formula_info_from_value(value ruby.Value) &FormulaInfo {
	address := value.attributes['formula_info_address'] or { panic('invalid FormulaInfo') }
	return unsafe { &FormulaInfo(voidptr(address.u64())) }
}

pub fn formula_info_boundary(formula &FormulaInfo) ruby.Value {
	return formula_info_value(formula)
}

fn formula_info_map_value(values map[string]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}
