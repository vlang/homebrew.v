module api

import brew_runtime

// Translated from Homebrew/brew `api/formula_struct.rb`.
// The original source is retained below until every stub has a typed V body.
pub const formula_struct_predicate_names = ['bottle', 'deprecate', 'disable', 'head', 'keg_only',
	'no_autobump', 'pour_bottle', 'service', 'service_run', 'service_name', 'stable']

pub struct ApiStructPaths {
pub:
	prefix string = '/opt/homebrew'
	cellar string = '/opt/homebrew/Cellar'
	home   string
	appdir string = '/Applications'
}

pub struct ApiStructArgPair {
pub:
	first  brew_runtime.Value
	second brew_runtime.Value
}

pub struct FormulaBottleChecksum {
pub:
	cellar   string
	tag      string
	checksum string
}

pub struct FormulaBottleSerialization {
pub:
	bottle_tag      ?string
	bottle_cellar   ?string
	bottle_checksum string
}

pub struct FormulaStructPredicates {
pub:
	bottle       bool
	deprecate    bool
	disable      bool
	head         bool
	keg_only     bool
	no_autobump  bool
	pour_bottle  bool
	service      bool
	service_run  bool
	service_name bool
	stable       bool
}

pub struct FormulaStruct {
pub:
	aliases                []string
	bottle_checksums       []FormulaBottleChecksum
	bottle_rebuild         int
	caveats                ?string
	conflicts              []ApiStructArgPair
	deprecate_args         map[string]brew_runtime.Value
	desc                   string
	disable_args           map[string]brew_runtime.Value
	executables            []string
	head_dependencies      []brew_runtime.Value
	head_url_args          ApiStructArgPair
	head_uses_from_macos   []ApiStructArgPair
	homepage               string
	keg_only_args          []brew_runtime.Value
	license                string
	link_overwrite_paths   []string
	no_autobump_args       map[string]brew_runtime.Value
	oldnames               []string
	post_install_defined   bool
	post_install_steps     []brew_runtime.Value
	pour_bottle_args       map[string]brew_runtime.Value
	revision               int
	ruby_source_checksum   string
	service_args           []ApiStructArgPair
	service_name_args      map[string]brew_runtime.Value
	service_run_args       []brew_runtime.Value
	service_run_kwargs     map[string]brew_runtime.Value
	stable_dependencies    []brew_runtime.Value
	stable_patches         []brew_runtime.Value
	stable_checksum        ?string
	stable_url_args        ApiStructArgPair
	stable_uses_from_macos []ApiStructArgPair
	stable_version         string
	version_scheme         int
	versioned_formulae     []string
	predicates             FormulaStructPredicates
}

pub fn formula_struct_predicate(formula FormulaStruct, name string) bool {
	return match name.trim_right('?') {
		'bottle' { formula.predicates.bottle }
		'deprecate' { formula.predicates.deprecate }
		'disable' { formula.predicates.disable }
		'head' { formula.predicates.head }
		'keg_only' { formula.predicates.keg_only }
		'no_autobump' { formula.predicates.no_autobump }
		'pour_bottle' { formula.predicates.pour_bottle }
		'service' { formula.predicates.service }
		'service_run' { formula.predicates.service_run }
		'service_name' { formula.predicates.service_name }
		'stable' { formula.predicates.stable }
		else { false }
	}
}

pub fn (formula FormulaStruct) predicate(name string) bool {
	return formula_struct_predicate(formula, name)
}

pub fn api_struct_value_equal(left brew_runtime.Value, right brew_runtime.Value) bool {
	return api_struct_values_equal(left, right)
}

pub fn formula_struct_from_hash(hash map[string]brew_runtime.Value,
	paths ApiStructPaths) FormulaStruct {
	cleaned := api_struct_replace_map(hash, paths, paths.appdir)
	return FormulaStruct{
		aliases: api_struct_string_array(cleaned['aliases'] or { brew_runtime.string_array_value([]) })
		bottle_checksums: formula_bottle_checksums_from_value(cleaned['bottle_checksums'] or {
			brew_runtime.array_value([])})
		bottle_rebuild: api_struct_int(cleaned['bottle_rebuild'] or { brew_runtime.int_value(0) })
		caveats: api_struct_optional_string(cleaned['caveats'] or { api_struct_nil_value() })
		conflicts: api_struct_arg_pairs(cleaned['conflicts'] or { brew_runtime.array_value([]) })
		deprecate_args: api_struct_value_map(cleaned['deprecate_args'] or { brew_runtime.map_value({}) })
		desc: api_struct_string(cleaned['desc'] or { brew_runtime.string_value('') })
		disable_args: api_struct_value_map(cleaned['disable_args'] or { brew_runtime.map_value({}) })
		executables: api_struct_string_array(cleaned['executables'] or { brew_runtime.string_array_value([]) })
		head_dependencies: api_struct_value_array(cleaned['head_dependencies'] or { brew_runtime.array_value([]) })
		head_url_args: api_struct_arg_pair(cleaned['head_url_args'] or { brew_runtime.array_value([]) }, brew_runtime.map_value({}))
		head_uses_from_macos: api_struct_arg_pairs(cleaned['head_uses_from_macos'] or {
			brew_runtime.array_value([])})
		homepage: api_struct_string(cleaned['homepage'] or { brew_runtime.string_value('') })
		keg_only_args: api_struct_value_array(cleaned['keg_only_args'] or { brew_runtime.array_value([]) })
		license: api_struct_string(cleaned['license'] or { brew_runtime.string_value('') })
		link_overwrite_paths: api_struct_string_array(cleaned['link_overwrite_paths'] or {
			brew_runtime.string_array_value([])})
		no_autobump_args: api_struct_value_map(cleaned['no_autobump_args'] or { brew_runtime.map_value({}) })
		oldnames: api_struct_string_array(cleaned['oldnames'] or { brew_runtime.string_array_value([]) })
		post_install_defined: api_struct_bool(cleaned['post_install_defined'] or {
			brew_runtime.bool_value(false)})
		post_install_steps: api_struct_value_array(cleaned['post_install_steps'] or {
			brew_runtime.array_value([])})
		pour_bottle_args: api_struct_value_map(cleaned['pour_bottle_args'] or { brew_runtime.map_value({}) })
		revision: api_struct_int(cleaned['revision'] or { brew_runtime.int_value(0) })
		ruby_source_checksum: api_struct_string(cleaned['ruby_source_checksum'] or {
			brew_runtime.string_value('')})
		service_args: api_struct_arg_pairs(cleaned['service_args'] or { brew_runtime.array_value([]) })
		service_name_args: api_struct_value_map(cleaned['service_name_args'] or { brew_runtime.map_value({}) })
		service_run_args: api_struct_value_array(cleaned['service_run_args'] or {
			brew_runtime.array_value([])})
		service_run_kwargs: api_struct_value_map(cleaned['service_run_kwargs'] or {
			brew_runtime.map_value({})})
		stable_dependencies: api_struct_value_array(cleaned['stable_dependencies'] or {
			brew_runtime.array_value([])})
		stable_patches: api_struct_value_array(cleaned['stable_patches'] or { brew_runtime.array_value([]) })
		stable_checksum: api_struct_optional_string(cleaned['stable_checksum'] or { api_struct_nil_value() })
		stable_url_args: api_struct_arg_pair(cleaned['stable_url_args'] or { brew_runtime.array_value([]) }, brew_runtime.map_value({}))
		stable_uses_from_macos: api_struct_arg_pairs(cleaned['stable_uses_from_macos'] or {
			brew_runtime.array_value([])})
		stable_version: api_struct_string(cleaned['stable_version'] or { brew_runtime.string_value('') })
		version_scheme: api_struct_int(cleaned['version_scheme'] or { brew_runtime.int_value(0) })
		versioned_formulae: api_struct_string_array(cleaned['versioned_formulae'] or {
			brew_runtime.string_array_value([])})
		predicates: formula_struct_predicates_from_hash(cleaned)
	}
}

fn formula_struct_predicates_from_hash(hash map[string]brew_runtime.Value) FormulaStructPredicates {
	return FormulaStructPredicates{
		bottle: api_struct_hash_bool(hash, 'bottle_present')
		deprecate: api_struct_hash_bool(hash, 'deprecate_present')
		disable: api_struct_hash_bool(hash, 'disable_present')
		head: api_struct_hash_bool(hash, 'head_present')
		keg_only: api_struct_hash_bool(hash, 'keg_only_present')
		no_autobump: api_struct_hash_bool(hash, 'no_autobump_present')
		pour_bottle: api_struct_hash_bool(hash, 'pour_bottle_present')
		service: api_struct_hash_bool(hash, 'service_present')
		service_run: api_struct_hash_bool(hash, 'service_run_present')
		service_name: api_struct_hash_bool(hash, 'service_name_present')
		stable: api_struct_hash_bool(hash, 'stable_present')
	}
}

pub fn (formula FormulaStruct) equals(other FormulaStruct, bottle_tag string) bool {
	return api_struct_maps_equal(formula.serialize(bottle_tag), other.serialize(bottle_tag))
}

pub fn (formula FormulaStruct) serialize_bottle(bottle_tag string) ?FormulaBottleSerialization {
	selected := formula_bottle_for_tag(formula.bottle_checksums, bottle_tag) or { return none }
	normalized_request := api_struct_normalize_symbol(bottle_tag)
	return FormulaBottleSerialization{
		bottle_tag: if selected.tag == normalized_request { none } else { selected.tag }
		bottle_cellar: if selected.cellar == 'any_skip_relocation' { none } else { selected.cellar }
		bottle_checksum: selected.checksum
	}
}

fn formula_bottle_for_tag(checksums []FormulaBottleChecksum,
	requested_tag string) ?FormulaBottleChecksum {
	requested := api_struct_normalize_symbol(requested_tag)
	for checksum in checksums {
		if checksum.tag == requested {
			return checksum
		}
	}
	for checksum in checksums {
		if checksum.tag == 'all' {
			return checksum
		}
	}
	requested_rank := formula_macos_tag_rank(requested)
	if requested_rank == 0 || requested.contains('linux') {
		return none
	}
	requested_arch := formula_bottle_arch(requested)
	mut found := false
	mut best := FormulaBottleChecksum{}
	mut best_rank := 0
	for checksum in checksums {
		rank := formula_macos_tag_rank(checksum.tag)
		if rank > 0 && rank <= requested_rank && formula_bottle_arch(checksum.tag) == requested_arch && (!found || rank > best_rank) {
			found = true
			best = checksum
			best_rank = rank
		}
	}
	return if found { best } else { none }
}

fn formula_bottle_arch(tag string) string {
	if tag.starts_with('arm64_') {
		return 'arm64'
	}
	if tag.starts_with('x86_64_') {
		return 'x86_64'
	}
	return 'intel'
}

fn formula_macos_tag_rank(tag string) int {
	name := tag.trim_string_left('arm64_').trim_string_left('x86_64_')
	return match name {
		'tahoe' { 26 }
		'sequoia' { 15 }
		'sonoma' { 14 }
		'ventura' { 13 }
		'monterey' { 12 }
		'big_sur' { 11 }
		'catalina' { 10 }
		else { 0 }
	}
}

pub fn (formula FormulaStruct) serialize(bottle_tag string) map[string]brew_runtime.Value {
	mut hash := map[string]brew_runtime.Value{}
	api_struct_put_nonblank(mut hash, 'aliases', brew_runtime.string_array_value(formula.aliases))
	api_struct_put_nonblank(mut hash, 'bottle_rebuild', brew_runtime.int_value(formula.bottle_rebuild))
	if caveats := formula.caveats {
		api_struct_put_nonblank(mut hash, 'caveats', brew_runtime.string_value(caveats))
	}
	api_struct_put_nonblank(mut hash, 'conflicts', api_struct_arg_pairs_value(formula.conflicts))
	api_struct_put_nonblank(mut hash, 'deprecate_args', brew_runtime.map_value(formula.deprecate_args))
	api_struct_put_nonblank(mut hash, 'desc', brew_runtime.string_value(formula.desc))
	api_struct_put_nonblank(mut hash, 'disable_args', brew_runtime.map_value(formula.disable_args))
	api_struct_put_nonblank(mut hash, 'executables', brew_runtime.string_array_value(formula.executables))
	api_struct_put_nonblank(mut hash, 'head_dependencies', brew_runtime.array_value(formula.head_dependencies))
	if formula.predicates.head || !api_struct_arg_pair_blank(formula.head_url_args) {
		api_struct_put_nonblank(mut hash, 'head_url_args', api_struct_arg_pair_value(formula.head_url_args))
	}
	api_struct_put_nonblank(mut hash, 'head_uses_from_macos', api_struct_arg_pairs_value(formula.head_uses_from_macos))
	api_struct_put_nonblank(mut hash, 'homepage', brew_runtime.string_value(formula.homepage))
	api_struct_put_nonblank(mut hash, 'keg_only_args', brew_runtime.array_value(formula.keg_only_args))
	api_struct_put_nonblank(mut hash, 'license', brew_runtime.string_value(formula.license))
	api_struct_put_nonblank(mut hash, 'link_overwrite_paths', brew_runtime.string_array_value(formula.link_overwrite_paths))
	api_struct_put_nonblank(mut hash, 'no_autobump_args', brew_runtime.map_value(formula.no_autobump_args))
	api_struct_put_nonblank(mut hash, 'oldnames', brew_runtime.string_array_value(formula.oldnames))
	api_struct_put_nonblank(mut hash, 'post_install_defined', brew_runtime.bool_value(formula.post_install_defined))
	api_struct_put_nonblank(mut hash, 'post_install_steps', brew_runtime.array_value(formula.post_install_steps))
	api_struct_put_nonblank(mut hash, 'pour_bottle_args', brew_runtime.map_value(formula.pour_bottle_args))
	api_struct_put_nonblank(mut hash, 'revision', brew_runtime.int_value(formula.revision))
	api_struct_put_nonblank(mut hash, 'ruby_source_checksum', brew_runtime.string_value(formula.ruby_source_checksum))
	api_struct_put_nonblank(mut hash, 'service_args', api_struct_arg_pairs_value(formula.service_args))
	api_struct_put_nonblank(mut hash, 'service_name_args', brew_runtime.map_value(formula.service_name_args))
	api_struct_put_nonblank(mut hash, 'service_run_args', brew_runtime.array_value(formula.service_run_args))
	api_struct_put_nonblank(mut hash, 'service_run_kwargs', brew_runtime.map_value(formula.service_run_kwargs))
	api_struct_put_nonblank(mut hash, 'stable_dependencies', brew_runtime.array_value(formula.stable_dependencies))
	api_struct_put_nonblank(mut hash, 'stable_patches', brew_runtime.array_value(formula.stable_patches))
	if checksum := formula.stable_checksum {
		api_struct_put_nonblank(mut hash, 'stable_checksum', brew_runtime.string_value(checksum))
	}
	if formula.predicates.stable || !api_struct_arg_pair_blank(formula.stable_url_args) {
		api_struct_put_nonblank(mut hash, 'stable_url_args', api_struct_arg_pair_value(formula.stable_url_args))
	}
	api_struct_put_nonblank(mut hash, 'stable_uses_from_macos', api_struct_arg_pairs_value(formula.stable_uses_from_macos))
	api_struct_put_nonblank(mut hash, 'stable_version', brew_runtime.string_value(formula.stable_version))
	api_struct_put_nonblank(mut hash, 'version_scheme', brew_runtime.int_value(formula.version_scheme))
	api_struct_put_nonblank(mut hash, 'versioned_formulae', brew_runtime.string_array_value(formula.versioned_formulae))
	if bottle := formula.serialize_bottle(bottle_tag) {
		hash['bottle_checksum'] = brew_runtime.string_value(bottle.bottle_checksum)
		if tag := bottle.bottle_tag {
			hash['bottle_tag'] = brew_runtime.string_value(':${tag}')
		}
		if cellar := bottle.bottle_cellar {
			hash['bottle_cellar'] = brew_runtime.string_value(if cellar.starts_with('/') {
				cellar
			} else {
				':${cellar}'
			})
		}
	}
	return hash
}

pub fn formula_struct_deserialize(hash map[string]brew_runtime.Value, bottle_tag string,
	paths ApiStructPaths) FormulaStruct {
	mut restored := hash.clone()
	for name in formula_struct_predicate_names {
		restored['${name}_present'] = brew_runtime.bool_value(api_struct_value_present(restored['${name}_args'] or {
			api_struct_nil_value()
		}))
	}
	if checksum := restored['bottle_checksum'] {
		tag := api_struct_normalize_symbol(api_struct_string(restored['bottle_tag'] or {
			brew_runtime.string_value(bottle_tag)
		}))
		cellar := api_struct_normalize_symbol(api_struct_string(restored['bottle_cellar'] or {
			brew_runtime.string_value('any_skip_relocation')
		}))
		restored['bottle_present'] = brew_runtime.bool_value(true)
		restored['bottle_checksums'] = brew_runtime.array_value([brew_runtime.map_value({
			'cellar': brew_runtime.string_value(cellar)
			tag:      brew_runtime.string_value(checksum.as_string())
		})])
	} else {
		restored['bottle_present'] = brew_runtime.bool_value(false)
	}
	for spec in ['head', 'stable'] {
		if value := restored['${spec}_url_args'] {
			restored['${spec}_present'] = brew_runtime.bool_value(true)
			restored['${spec}_url_args'] = api_struct_arg_pair_value(api_struct_arg_pair(value, brew_runtime.map_value({})))
		} else {
			restored['${spec}_present'] = brew_runtime.bool_value(false)
		}
		if uses := restored['${spec}_uses_from_macos'] {
			restored['${spec}_uses_from_macos'] = api_struct_arg_pairs_value(api_struct_arg_pairs(uses))
		}
	}
	if conflicts := restored['conflicts'] {
		restored['conflicts'] = api_struct_arg_pairs_value(api_struct_arg_pairs(conflicts))
	}
	return formula_struct_from_hash(restored, paths)
}

pub fn formula_struct_format_arg_pair(values []brew_runtime.Value,
	last brew_runtime.Value) ApiStructArgPair {
	return ApiStructArgPair{
		first: values[0] or { api_struct_nil_value() }
		second: values[1] or { last }
	}
}

// Ruby method `self.from_hash(formula_hash)` at line 12.
pub fn ruby_formula_struct_l12_d1_self_from_hash(hash map[string]brew_runtime.Value,
	paths ApiStructPaths) FormulaStruct {
	return formula_struct_from_hash(hash, paths)
}

// Ruby define_method `define_method(predicate_method_name) do` at line 83.
pub fn ruby_formula_struct_l83_d2_predicate_method_name(formula FormulaStruct, name string) bool {
	return formula_struct_predicate(formula, name)
}

// Ruby method `==(other)` at line 126.
pub fn ruby_formula_struct_l126_d3_anonymous(formula FormulaStruct, other FormulaStruct,
	bottle_tag string) bool {
	return formula.equals(other, bottle_tag)
}

// Ruby method `serialize_bottle(bottle_tag: ::Utils::Bottles.tag)` at line 136.
pub fn ruby_formula_struct_l136_d4_serialize_bottle(formula FormulaStruct,
	bottle_tag string) ?FormulaBottleSerialization {
	return formula.serialize_bottle(bottle_tag)
}

// Ruby method `serialize(bottle_tag: ::Utils::Bottles.tag)` at line 163.
pub fn ruby_formula_struct_l163_d5_serialize(formula FormulaStruct,
	bottle_tag string) map[string]brew_runtime.Value {
	return formula.serialize(bottle_tag)
}

// Ruby method `self.deserialize(hash, bottle_tag: ::Utils::Bottles.tag)` at line 187.
pub fn ruby_formula_struct_l187_d6_self_deserialize(hash map[string]brew_runtime.Value,
	bottle_tag string, paths ApiStructPaths) FormulaStruct {
	return formula_struct_deserialize(hash, bottle_tag, paths)
}

// Ruby method `self.format_arg_pair(args, last:)` at line 241.
pub fn ruby_formula_struct_l241_d7_self_format_arg_pair(values []brew_runtime.Value,
	last brew_runtime.Value) ApiStructArgPair {
	return formula_struct_format_arg_pair(values, last)
}

fn formula_bottle_checksums_from_value(value brew_runtime.Value) []FormulaBottleChecksum {
	mut checksums := []FormulaBottleChecksum{}
	for item in api_struct_value_array(value) {
		info := api_struct_value_map(item)
		cellar := api_struct_normalize_symbol(api_struct_string(info['cellar'] or {
			brew_runtime.string_value('any')
		}))
		for tag, checksum in info {
			if tag != 'cellar' {
				checksums << FormulaBottleChecksum{
					cellar: cellar
					tag: api_struct_normalize_symbol(tag)
					checksum: checksum.as_string()
				}
				break
			}
		}
	}
	return checksums
}

fn api_struct_arg_pair(value brew_runtime.Value, last brew_runtime.Value) ApiStructArgPair {
	return formula_struct_format_arg_pair(api_struct_value_array(value), last)
}

fn api_struct_arg_pairs(value brew_runtime.Value) []ApiStructArgPair {
	return api_struct_value_array(value).map(api_struct_arg_pair(it, brew_runtime.map_value({})))
}

fn api_struct_arg_pair_value(pair ApiStructArgPair) brew_runtime.Value {
	mut values := [pair.first]
	if api_struct_value_present(pair.second) {
		values << pair.second
	}
	return brew_runtime.array_value(values)
}

fn api_struct_arg_pairs_value(pairs []ApiStructArgPair) brew_runtime.Value {
	return brew_runtime.array_value(pairs.map(api_struct_arg_pair_value(it)))
}

fn api_struct_arg_pair_blank(pair ApiStructArgPair) bool {
	return !api_struct_value_present(pair.first) && !api_struct_value_present(pair.second)
}

fn api_struct_normalize_symbol(value string) string {
	return value.trim_space().trim_string_left(':')
}

fn api_struct_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

fn api_struct_string(value brew_runtime.Value) string {
	return value.as_string()
}

fn api_struct_optional_string(value brew_runtime.Value) ?string {
	return if value.type_name == 'NilClass' || value.as_string() == '' {
		none
	} else {
		value.as_string()
	}
}

fn api_struct_bool(value brew_runtime.Value) bool {
	return value.as_bool() or { value.as_string().to_lower() in ['true', '1', 'yes'] }
}

fn api_struct_int(value brew_runtime.Value) int {
	return int(value.as_int() or { value.as_string().int() })
}

fn api_struct_hash_bool(hash map[string]brew_runtime.Value, name string) bool {
	return api_struct_bool(hash[name] or { brew_runtime.bool_value(false) })
}

fn api_struct_string_array(value brew_runtime.Value) []string {
	if value.string_array_data.len > 0 {
		return value.string_array_data.clone()
	}
	return value.array_data.map(it.as_string())
}

fn api_struct_value_array(value brew_runtime.Value) []brew_runtime.Value {
	return value.as_array() or { []brew_runtime.Value{} }
}

fn api_struct_value_map(value brew_runtime.Value) map[string]brew_runtime.Value {
	return value.as_map() or { map[string]brew_runtime.Value{} }
}

fn api_struct_value_present(value brew_runtime.Value) bool {
	return match value.type_name {
		'NilClass' { false }
		'String' { value.as_string() != '' }
		'Array' { value.array_data.len > 0 || value.string_array_data.len > 0 }
		'Hash' { value.map_data.len > 0 }
		'Bool' { value.bool_data }
		else { true }
	}
}

fn api_struct_put_nonblank(mut hash map[string]brew_runtime.Value, name string,
	value brew_runtime.Value) {
	if api_struct_value_present(value) {
		hash[name] = value
	}
}

fn api_struct_replace_map(hash map[string]brew_runtime.Value, paths ApiStructPaths,
	appdir string) map[string]brew_runtime.Value {
	mut replaced := map[string]brew_runtime.Value{}
	for key, value in hash {
		replaced[key.trim_string_left(':')] = api_struct_deep_replace(value, paths, appdir)
	}
	return replaced
}

fn api_struct_deep_replace(value brew_runtime.Value, paths ApiStructPaths,
	appdir string) brew_runtime.Value {
	if value.type_name == 'String' {
		return brew_runtime.string_value(value.as_string().replace(r'$HOMEBREW_PREFIX', paths.prefix).replace(r'$HOMEBREW_CELLAR', paths.cellar).replace(r'$APPDIR', appdir).replace(r'/$HOME', paths.home))
	}
	if value.type_name == 'Array' {
		return brew_runtime.array_value(api_struct_value_array(value).map(api_struct_deep_replace(it, paths, appdir)))
	}
	if value.type_name == 'Hash' {
		mut mapped := map[string]brew_runtime.Value{}
		for key, item in value.map_data {
			mapped[key] = api_struct_deep_replace(item, paths, appdir)
		}
		return brew_runtime.map_value(mapped)
	}
	return value
}

fn api_struct_values_equal(left brew_runtime.Value, right brew_runtime.Value) bool {
	if left.type_name != right.type_name || left.repr != right.repr || left.bool_data != right.bool_data || left.int_data != right.int_data || left.float_data != right.float_data || left.string_array_data != right.string_array_data || left.attributes != right.attributes || left.array_data.len != right.array_data.len || left.map_data.len != right.map_data.len {
		return false
	}
	for index, item in left.array_data {
		if !api_struct_values_equal(item, right.array_data[index]) {
			return false
		}
	}
	return api_struct_maps_equal(left.map_data, right.map_data)
}

fn api_struct_maps_equal(left map[string]brew_runtime.Value,
	right map[string]brew_runtime.Value) bool {
	if left.len != right.len {
		return false
	}
	for key, value in left {
		other := right[key] or { return false }
		if !api_struct_values_equal(value, other) {
			return false
		}
	}
	return true
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "service"
// 5: require "utils/spdx"
// 6: require "install_steps"
// 7:
// 8: module Homebrew
// 9:   module API
// 10:     class FormulaStruct < T::Struct
// 11:       sig { params(formula_hash: T::Hash[String, T.untyped]).returns(FormulaStruct) }
// 12:       def self.from_hash(formula_hash)
// 13:         formula_hash = ::Formula.deep_remove_placeholders(formula_hash)
// 14:         formula_hash = formula_hash.transform_keys(&:to_sym)
// 15:                                    .slice(*decorator.all_props)
// 16:                                    .compact_blank
// 17:         new(**formula_hash)
// 18:       end
// 19:
// 20:       PREDICATES = [
// 21:         :bottle,
// 22:         :deprecate,
// 23:         :disable,
// 24:         :head,
// 25:         :keg_only,
// 26:         :no_autobump,
// 27:         :pour_bottle,
// 28:         :service,
// 29:         :service_run,
// 30:         :service_name,
// 31:         :stable,
// 32:       ].freeze
// 33:
// 34:       SKIP_SERIALIZATION = [
// 35:         # Bottle checksums have special serialization done by the serialize_bottle method
// 36:         :bottle_checksums,
// 37:       ].freeze
// 38:
// 39:       SPECS = [:head, :stable].freeze
// 40:
// 41:       # :any_skip_relocation is the most common in homebrew/core
// 42:       DEFAULT_CELLAR = :any_skip_relocation
// 43:
// 44:       DependsOnArgs = T.type_alias do
// 45:         T.any(
// 46:           # Dependencies
// 47:           T.any(
// 48:             # Formula name: "foo"
// 49:             String,
// 50:             # Formula name and dependency type: { "foo" => :build }
// 51:             T::Hash[String, Symbol],
// 52:           ),
// 53:           # Requirements
// 54:           T.any(
// 55:             # Requirement name: :macos
// 56:             Symbol,
// 57:             # Requirement name and other info: { macos: :build }
// 58:             T::Hash[Symbol, T::Array[T.anything]],
// 59:           ),
// 60:         )
// 61:       end
// 62:
// 63:       UsesFromMacOSArgs = T.type_alias do
// 64:         [
// 65:           T.any(
// 66:             # Formula name: "foo"
// 67:             String,
// 68:             # Formula name and dependency type: { "foo" => :build }
// 69:             # Formula name, dependency type, and version bounds: { "foo" => :build, since: :catalina }
// 70:             T::Hash[T.any(String, Symbol), T.any(Symbol, T::Array[Symbol])],
// 71:           ),
// 72:           # If the first argument is only a name, this argument contains the version bounds: { since: :catalina }
// 73:           T::Hash[Symbol, Symbol],
// 74:         ]
// 75:       end
// 76:
// 77:       PREDICATES.each do |predicate_name|
// 78:         present_method_name = :"#{predicate_name}_present"
// 79:         predicate_method_name = :"#{predicate_name}?"
// 80:
// 81:         const present_method_name, T::Boolean, default: false
// 82:
// 83:         define_method(predicate_method_name) do
// 84:           send(present_method_name)
// 85:         end
// 86:       end
// 87:
// 88:       # Changes to this struct must be mirrored in Homebrew::API::Formula.generate_formula_struct_hash
// 89:       const :aliases, T::Array[String], default: []
// 90:       const :bottle_checksums, T::Array[T::Hash[Symbol, T.any(String, Symbol)]], default: []
// 91:       const :bottle_rebuild, Integer, default: 0
// 92:       const :caveats, T.nilable(String)
// 93:       const :conflicts, T::Array[[String, T::Hash[Symbol, String]]], default: []
// 94:       const :deprecate_args, T::Hash[Symbol, T.nilable(T.any(String, Symbol))], default: {}
// 95:       const :desc, String
// 96:       const :disable_args, T::Hash[Symbol, T.nilable(T.any(String, Symbol))], default: {}
// 97:       const :executables, T::Array[String], default: []
// 98:       const :head_dependencies, T::Array[DependsOnArgs], default: []
// 99:       const :head_url_args, [String, T::Hash[Symbol, T.anything]], default: ["", {}]
// 100:       const :head_uses_from_macos, T::Array[UsesFromMacOSArgs], default: []
// 101:       const :homepage, String
// 102:       const :keg_only_args, T::Array[T.any(String, Symbol)], default: []
// 103:       const :license, SPDX::LicenseExpression
// 104:       const :link_overwrite_paths, T::Array[String], default: []
// 105:       const :no_autobump_args, T::Hash[Symbol, T.any(String, Symbol)], default: {}
// 106:       const :oldnames, T::Array[String], default: []
// 107:       const :post_install_defined, T::Boolean, default: false
// 108:       const :post_install_steps, Homebrew::InstallSteps::Steps, default: []
// 109:       const :pour_bottle_args, T::Hash[Symbol, Symbol], default: {}
// 110:       const :revision, Integer, default: 0
// 111:       const :ruby_source_checksum, String
// 112:       const :service_args, T::Array[[Symbol, BasicObject]], default: []
// 113:       const :service_name_args, T::Hash[Symbol, String], default: {}
// 114:       const :service_run_args, T::Array[Homebrew::Service::RunParam], default: []
// 115:       const :service_run_kwargs, T::Hash[Symbol, Homebrew::Service::RunParam], default: {}
// 116:       const :stable_dependencies, T::Array[DependsOnArgs], default: []
// 117:       const :stable_patches, T::Array[T::Hash[T.any(String, Symbol), T.untyped]], default: []
// 118:       const :stable_checksum, T.nilable(String)
// 119:       const :stable_url_args, [String, T::Hash[Symbol, T.anything]], default: ["", {}]
// 120:       const :stable_uses_from_macos, T::Array[UsesFromMacOSArgs], default: []
// 121:       const :stable_version, String
// 122:       const :version_scheme, Integer, default: 0
// 123:       const :versioned_formulae, T::Array[String], default: []
// 124:
// 125:       sig { params(other: T.anything).returns(T::Boolean) }
// 126:       def ==(other)
// 127:         case other
// 128:         when FormulaStruct
// 129:           serialize == other.serialize
// 130:         else
// 131:           false
// 132:         end
// 133:       end
// 134:
// 135:       sig { params(bottle_tag: ::Utils::Bottles::Tag).returns(T.nilable(T::Hash[String, T.untyped])) }
// 136:       def serialize_bottle(bottle_tag: ::Utils::Bottles.tag)
// 137:         bottle_collector = ::Utils::Bottles::Collector.new
// 138:         bottle_checksums.each do |bottle_info|
// 139:           bottle_info = bottle_info.dup
// 140:           cellar = bottle_info.delete(:cellar) || :any
// 141:           tag = T.must(bottle_info.keys.first)
// 142:           checksum = T.cast(bottle_info.values.first, String)
// 143:
// 144:           bottle_collector.add(
// 145:             ::Utils::Bottles::Tag.from_symbol(tag),
// 146:             checksum: Checksum.new(checksum),
// 147:             cellar:,
// 148:           )
// 149:         end
// 150:         return unless (bottle_spec = bottle_collector.specification_for(bottle_tag))
// 151:
// 152:         tag = (bottle_spec.tag if bottle_spec.tag != bottle_tag)
// 153:         cellar = (bottle_spec.cellar if bottle_spec.cellar != DEFAULT_CELLAR)
// 154:
// 155:         {
// 156:           "bottle_tag"      => tag&.to_sym,
// 157:           "bottle_cellar"   => cellar,
// 158:           "bottle_checksum" => bottle_spec.checksum.to_s,
// 159:         }
// 160:       end
// 161:
// 162:       sig { params(bottle_tag: ::Utils::Bottles::Tag).returns(T::Hash[String, T.untyped]) }
// 163:       def serialize(bottle_tag: ::Utils::Bottles.tag)
// 164:         hash = self.class.decorator.all_props.filter_map do |prop|
// 165:           next if PREDICATES.any? { |predicate| prop == :"#{predicate}_present" }
// 166:           next if SKIP_SERIALIZATION.include?(prop)
// 167:
// 168:           [prop.to_s, send(prop)]
// 169:         end.to_h
// 170:
// 171:         if (bottle_hash = serialize_bottle(bottle_tag:))
// 172:           hash = hash.merge(bottle_hash)
// 173:         end
// 174:
// 175:         hash = ::Utils.deep_stringify_symbols(hash)
// 176:
// 177:         service_args = hash["service_args"]
// 178:         hash = ::Utils.deep_compact_blank(hash)
// 179:
// 180:         # service_args may have falsey values that we don't want to remove, like `keep_alive successful_exit: false`
// 181:         hash["service_args"] = service_args if service_args&.any?
// 182:
// 183:         hash
// 184:       end
// 185:
// 186:       sig { params(hash: T::Hash[String, T.untyped], bottle_tag: ::Utils::Bottles::Tag).returns(FormulaStruct) }
// 187:       def self.deserialize(hash, bottle_tag: ::Utils::Bottles.tag)
// 188:         hash = ::Utils.deep_unstringify_symbols(hash)
// 189:
// 190:         # Items that don't follow the `hash["foo_present"] = hash["foo_args"].present?` pattern are overridden below
// 191:         PREDICATES.each do |name|
// 192:           hash["#{name}_present"] = hash["#{name}_args"].present?
// 193:         end
// 194:
// 195:         if (bottle_checksum = hash["bottle_checksum"])
// 196:           tag = hash.fetch("bottle_tag", bottle_tag.to_sym)
// 197:           cellar = hash.fetch("bottle_cellar", DEFAULT_CELLAR)
// 198:
// 199:           hash["bottle_present"] = true
// 200:           hash["bottle_checksums"] = [{ cellar: cellar, tag => bottle_checksum }]
// 201:         else
// 202:           hash["bottle_present"] = false
// 203:         end
// 204:
// 205:         # *_url_args need to be in [String, Hash] format, but the hash may have been dropped if empty
// 206:         SPECS.each do |key|
// 207:           if (url_args = hash["#{key}_url_args"])
// 208:             hash["#{key}_present"] = true
// 209:             hash["#{key}_url_args"] = format_arg_pair(url_args, last: {})
// 210:           else
// 211:             hash["#{key}_present"] = false
// 212:           end
// 213:
// 214:           next unless (uses_from_macos = hash["#{key}_uses_from_macos"])
// 215:
// 216:           hash["#{key}_uses_from_macos"] = uses_from_macos.map do |args|
// 217:             format_arg_pair(args, last: {})
// 218:           end
// 219:         end
// 220:
// 221:         hash["conflicts"] = if (conflicts = hash["conflicts"])
// 222:           conflicts.map { |conflict| format_arg_pair(conflict, last: {}) }
// 223:         end
// 224:
// 225:         from_hash(hash)
// 226:       end
// 227:
// 228:       # Format argument pairs into proper [first, last] format if serialization has removed some elements.
// 229:       # Pass a default value for last to be used when only one element is present.
// 230:       #
// 231:       #  format_arg_pair(["foo"], last: {})                       # => ["foo", {}]
// 232:       #  format_arg_pair([{ "foo" => :build }], last: {})         # => [{ "foo" => :build }, {}]
// 233:       #  format_arg_pair(["foo", { since: :catalina }], last: {}) # => ["foo", { since: :catalina }]
// 234:       sig {
// 235:         type_parameters(:U, :V)
// 236:           .params(
// 237:             args: T.any([T.type_parameter(:U)], [T.type_parameter(:U), T.type_parameter(:V)]),
// 238:             last: T.type_parameter(:V),
// 239:           ).returns([T.type_parameter(:U), T.type_parameter(:V)])
// 240:       }
// 241:       def self.format_arg_pair(args, last:)
// 242:         args = case args
// 243:         in [elem]
// 244:           [elem, last]
// 245:         in [elem1, elem2]
// 246:           [elem1, elem2]
// 247:         end
// 248:
// 249:         # The case above is exhaustive so args will never be nil, but sorbet cannot infer that.
// 250:         T.must(args)
// 251:       end
// 252:     end
// 253:   end
// 254: end
