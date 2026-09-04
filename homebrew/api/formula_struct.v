module api

import ruby

// Translated from Homebrew/brew `api/formula_struct.rb`.
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
	first  ruby.Value
	second ruby.Value
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
	deprecate_args         map[string]ruby.Value
	desc                   string
	disable_args           map[string]ruby.Value
	executables            []string
	head_dependencies      []ruby.Value
	head_url_args          ApiStructArgPair
	head_uses_from_macos   []ApiStructArgPair
	homepage               string
	keg_only_args          []ruby.Value
	license                string
	link_overwrite_paths   []string
	no_autobump_args       map[string]ruby.Value
	oldnames               []string
	post_install_defined   bool
	post_install_steps     []ruby.Value
	pour_bottle_args       map[string]ruby.Value
	revision               int
	ruby_source_checksum   string
	service_args           []ApiStructArgPair
	service_name_args      map[string]ruby.Value
	service_run_args       []ruby.Value
	service_run_kwargs     map[string]ruby.Value
	stable_dependencies    []ruby.Value
	stable_patches         []ruby.Value
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

pub fn api_struct_value_equal(left ruby.Value, right ruby.Value) bool {
	return api_struct_values_equal(left, right)
}

pub fn formula_struct_from_hash(hash map[string]ruby.Value,
	paths ApiStructPaths) FormulaStruct {
	cleaned := api_struct_replace_map(hash, paths, paths.appdir)
	return FormulaStruct{
		aliases: api_struct_string_array(cleaned['aliases'] or { ruby.string_array_value([]) })
		bottle_checksums: formula_bottle_checksums_from_value(cleaned['bottle_checksums'] or {
			ruby.array_value([])
		})
		bottle_rebuild: api_struct_int(cleaned['bottle_rebuild'] or { ruby.int_value(0) })
		caveats: api_struct_optional_string(cleaned['caveats'] or { api_struct_nil_value() })
		conflicts: api_struct_arg_pairs(cleaned['conflicts'] or { ruby.array_value([]) })
		deprecate_args: api_struct_value_map(cleaned['deprecate_args'] or { ruby.map_value({}) })
		desc: api_struct_string(cleaned['desc'] or { ruby.string_value('') })
		disable_args: api_struct_value_map(cleaned['disable_args'] or { ruby.map_value({}) })
		executables: api_struct_string_array(cleaned['executables'] or { ruby.string_array_value([]) })
		head_dependencies: api_struct_value_array(cleaned['head_dependencies'] or { ruby.array_value([]) })
		head_url_args: api_struct_arg_pair(cleaned['head_url_args'] or { ruby.array_value([]) }, ruby.map_value({}))
		head_uses_from_macos: api_struct_arg_pairs(cleaned['head_uses_from_macos'] or {
			ruby.array_value([])
		})
		homepage: api_struct_string(cleaned['homepage'] or { ruby.string_value('') })
		keg_only_args: api_struct_value_array(cleaned['keg_only_args'] or { ruby.array_value([]) })
		license: api_struct_string(cleaned['license'] or { ruby.string_value('') })
		link_overwrite_paths: api_struct_string_array(cleaned['link_overwrite_paths'] or {
			ruby.string_array_value([])
		})
		no_autobump_args: api_struct_value_map(cleaned['no_autobump_args'] or { ruby.map_value({}) })
		oldnames: api_struct_string_array(cleaned['oldnames'] or { ruby.string_array_value([]) })
		post_install_defined: api_struct_bool(cleaned['post_install_defined'] or {
			ruby.bool_value(false)
		})
		post_install_steps: api_struct_value_array(cleaned['post_install_steps'] or {
			ruby.array_value([])
		})
		pour_bottle_args: api_struct_value_map(cleaned['pour_bottle_args'] or { ruby.map_value({}) })
		revision: api_struct_int(cleaned['revision'] or { ruby.int_value(0) })
		ruby_source_checksum: api_struct_string(cleaned['ruby_source_checksum'] or {
			ruby.string_value('')
		})
		service_args: api_struct_arg_pairs(cleaned['service_args'] or { ruby.array_value([]) })
		service_name_args: api_struct_value_map(cleaned['service_name_args'] or { ruby.map_value({}) })
		service_run_args: api_struct_value_array(cleaned['service_run_args'] or {
			ruby.array_value([])
		})
		service_run_kwargs: api_struct_value_map(cleaned['service_run_kwargs'] or {
			ruby.map_value({})
		})
		stable_dependencies: api_struct_value_array(cleaned['stable_dependencies'] or {
			ruby.array_value([])
		})
		stable_patches: api_struct_value_array(cleaned['stable_patches'] or { ruby.array_value([]) })
		stable_checksum: api_struct_optional_string(cleaned['stable_checksum'] or { api_struct_nil_value() })
		stable_url_args: api_struct_arg_pair(cleaned['stable_url_args'] or { ruby.array_value([]) }, ruby.map_value({}))
		stable_uses_from_macos: api_struct_arg_pairs(cleaned['stable_uses_from_macos'] or {
			ruby.array_value([])
		})
		stable_version: api_struct_string(cleaned['stable_version'] or { ruby.string_value('') })
		version_scheme: api_struct_int(cleaned['version_scheme'] or { ruby.int_value(0) })
		versioned_formulae: api_struct_string_array(cleaned['versioned_formulae'] or {
			ruby.string_array_value([])
		})
		predicates: formula_struct_predicates_from_hash(cleaned)
	}
}

fn formula_struct_predicates_from_hash(hash map[string]ruby.Value) FormulaStructPredicates {
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

pub fn (formula FormulaStruct) serialize(bottle_tag string) map[string]ruby.Value {
	mut hash := map[string]ruby.Value{}
	api_struct_put_nonblank(mut hash, 'aliases', ruby.string_array_value(formula.aliases))
	api_struct_put_nonblank(mut hash, 'bottle_rebuild', ruby.int_value(formula.bottle_rebuild))
	if caveats := formula.caveats {
		api_struct_put_nonblank(mut hash, 'caveats', ruby.string_value(caveats))
	}
	api_struct_put_nonblank(mut hash, 'conflicts', api_struct_arg_pairs_value(formula.conflicts))
	api_struct_put_nonblank(mut hash, 'deprecate_args', ruby.map_value(formula.deprecate_args))
	api_struct_put_nonblank(mut hash, 'desc', ruby.string_value(formula.desc))
	api_struct_put_nonblank(mut hash, 'disable_args', ruby.map_value(formula.disable_args))
	api_struct_put_nonblank(mut hash, 'executables', ruby.string_array_value(formula.executables))
	api_struct_put_nonblank(mut hash, 'head_dependencies', ruby.array_value(formula.head_dependencies))
	if formula.predicates.head || !api_struct_arg_pair_blank(formula.head_url_args) {
		api_struct_put_nonblank(mut hash, 'head_url_args', api_struct_arg_pair_value(formula.head_url_args))
	}
	api_struct_put_nonblank(mut hash, 'head_uses_from_macos', api_struct_arg_pairs_value(formula.head_uses_from_macos))
	api_struct_put_nonblank(mut hash, 'homepage', ruby.string_value(formula.homepage))
	api_struct_put_nonblank(mut hash, 'keg_only_args', ruby.array_value(formula.keg_only_args))
	api_struct_put_nonblank(mut hash, 'license', ruby.string_value(formula.license))
	api_struct_put_nonblank(mut hash, 'link_overwrite_paths', ruby.string_array_value(formula.link_overwrite_paths))
	api_struct_put_nonblank(mut hash, 'no_autobump_args', ruby.map_value(formula.no_autobump_args))
	api_struct_put_nonblank(mut hash, 'oldnames', ruby.string_array_value(formula.oldnames))
	api_struct_put_nonblank(mut hash, 'post_install_defined', ruby.bool_value(formula.post_install_defined))
	api_struct_put_nonblank(mut hash, 'post_install_steps', ruby.array_value(formula.post_install_steps))
	api_struct_put_nonblank(mut hash, 'pour_bottle_args', ruby.map_value(formula.pour_bottle_args))
	api_struct_put_nonblank(mut hash, 'revision', ruby.int_value(formula.revision))
	api_struct_put_nonblank(mut hash, 'ruby_source_checksum', ruby.string_value(formula.ruby_source_checksum))
	api_struct_put_nonblank(mut hash, 'service_args', api_struct_arg_pairs_value(formula.service_args))
	api_struct_put_nonblank(mut hash, 'service_name_args', ruby.map_value(formula.service_name_args))
	api_struct_put_nonblank(mut hash, 'service_run_args', ruby.array_value(formula.service_run_args))
	api_struct_put_nonblank(mut hash, 'service_run_kwargs', ruby.map_value(formula.service_run_kwargs))
	api_struct_put_nonblank(mut hash, 'stable_dependencies', ruby.array_value(formula.stable_dependencies))
	api_struct_put_nonblank(mut hash, 'stable_patches', ruby.array_value(formula.stable_patches))
	if checksum := formula.stable_checksum {
		api_struct_put_nonblank(mut hash, 'stable_checksum', ruby.string_value(checksum))
	}
	if formula.predicates.stable || !api_struct_arg_pair_blank(formula.stable_url_args) {
		api_struct_put_nonblank(mut hash, 'stable_url_args', api_struct_arg_pair_value(formula.stable_url_args))
	}
	api_struct_put_nonblank(mut hash, 'stable_uses_from_macos', api_struct_arg_pairs_value(formula.stable_uses_from_macos))
	api_struct_put_nonblank(mut hash, 'stable_version', ruby.string_value(formula.stable_version))
	api_struct_put_nonblank(mut hash, 'version_scheme', ruby.int_value(formula.version_scheme))
	api_struct_put_nonblank(mut hash, 'versioned_formulae', ruby.string_array_value(formula.versioned_formulae))
	if bottle := formula.serialize_bottle(bottle_tag) {
		hash['bottle_checksum'] = ruby.string_value(bottle.bottle_checksum)
		if tag := bottle.bottle_tag {
			hash['bottle_tag'] = ruby.string_value(':${tag}')
		}
		if cellar := bottle.bottle_cellar {
			hash['bottle_cellar'] = ruby.string_value(if cellar.starts_with('/') {
				cellar
			} else {
				':${cellar}'
			})
		}
	}
	return hash
}

pub fn formula_struct_deserialize(hash map[string]ruby.Value, bottle_tag string,
	paths ApiStructPaths) FormulaStruct {
	mut restored := hash.clone()
	for name in formula_struct_predicate_names {
		restored['${name}_present'] = ruby.bool_value(api_struct_value_present(restored['${name}_args'] or {
			api_struct_nil_value()
		}))
	}
	if checksum := restored['bottle_checksum'] {
		tag := api_struct_normalize_symbol(api_struct_string(restored['bottle_tag'] or {
			ruby.string_value(bottle_tag)
		}))
		cellar := api_struct_normalize_symbol(api_struct_string(restored['bottle_cellar'] or {
			ruby.string_value('any_skip_relocation')
		}))
		restored['bottle_present'] = ruby.bool_value(true)
		restored['bottle_checksums'] = ruby.array_value([ruby.map_value({
			'cellar': ruby.string_value(cellar)
			tag:      ruby.string_value(checksum.as_string())
		})])
	} else {
		restored['bottle_present'] = ruby.bool_value(false)
	}
	for spec in ['head', 'stable'] {
		if value := restored['${spec}_url_args'] {
			restored['${spec}_present'] = ruby.bool_value(true)
			restored['${spec}_url_args'] = api_struct_arg_pair_value(api_struct_arg_pair(value, ruby.map_value({})))
		} else {
			restored['${spec}_present'] = ruby.bool_value(false)
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

pub fn formula_struct_format_arg_pair(values []ruby.Value,
	last ruby.Value) ApiStructArgPair {
	return ApiStructArgPair{
		first: values[0] or { api_struct_nil_value() }
		second: values[1] or { last }
	}
}

fn formula_bottle_checksums_from_value(value ruby.Value) []FormulaBottleChecksum {
	mut checksums := []FormulaBottleChecksum{}
	for item in api_struct_value_array(value) {
		info := api_struct_value_map(item)
		cellar := api_struct_normalize_symbol(api_struct_string(info['cellar'] or {
			ruby.string_value('any')
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

fn api_struct_arg_pair(value ruby.Value, last ruby.Value) ApiStructArgPair {
	return formula_struct_format_arg_pair(api_struct_value_array(value), last)
}

fn api_struct_arg_pairs(value ruby.Value) []ApiStructArgPair {
	return api_struct_value_array(value).map(api_struct_arg_pair(it, ruby.map_value({})))
}

fn api_struct_arg_pair_value(pair ApiStructArgPair) ruby.Value {
	mut values := [pair.first]
	if api_struct_value_present(pair.second) {
		values << pair.second
	}
	return ruby.array_value(values)
}

fn api_struct_arg_pairs_value(pairs []ApiStructArgPair) ruby.Value {
	return ruby.array_value(pairs.map(api_struct_arg_pair_value(it)))
}

fn api_struct_arg_pair_blank(pair ApiStructArgPair) bool {
	return !api_struct_value_present(pair.first) && !api_struct_value_present(pair.second)
}

fn api_struct_normalize_symbol(value string) string {
	return value.trim_space().trim_string_left(':')
}

fn api_struct_nil_value() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn api_struct_string(value ruby.Value) string {
	return value.as_string()
}

fn api_struct_optional_string(value ruby.Value) ?string {
	return if value.type_name == 'NilClass' || value.as_string() == '' {
		none
	} else {
		value.as_string()
	}
}

fn api_struct_bool(value ruby.Value) bool {
	return value.as_bool() or { value.as_string().to_lower() in ['true', '1', 'yes'] }
}

fn api_struct_int(value ruby.Value) int {
	return int(value.as_int() or { value.as_string().int() })
}

fn api_struct_hash_bool(hash map[string]ruby.Value, name string) bool {
	return api_struct_bool(hash[name] or { ruby.bool_value(false) })
}

fn api_struct_string_array(value ruby.Value) []string {
	if value.string_array_data.len > 0 {
		return value.string_array_data.clone()
	}
	return value.array_data.map(it.as_string())
}

fn api_struct_value_array(value ruby.Value) []ruby.Value {
	return value.as_array() or { []ruby.Value{} }
}

fn api_struct_value_map(value ruby.Value) map[string]ruby.Value {
	return value.as_map() or { map[string]ruby.Value{} }
}

fn api_struct_value_present(value ruby.Value) bool {
	return match value.type_name {
		'NilClass' { false }
		'String' { value.as_string() != '' }
		'Array' { value.array_data.len > 0 || value.string_array_data.len > 0 }
		'Hash' { value.map_data.len > 0 }
		'Bool' { value.bool_data }
		else { true }
	}
}

fn api_struct_put_nonblank(mut hash map[string]ruby.Value, name string,
	value ruby.Value) {
	if api_struct_value_present(value) {
		hash[name] = value
	}
}

fn api_struct_replace_map(hash map[string]ruby.Value, paths ApiStructPaths,
	appdir string) map[string]ruby.Value {
	mut replaced := map[string]ruby.Value{}
	for key, value in hash {
		replaced[key.trim_string_left(':')] = api_struct_deep_replace(value, paths, appdir)
	}
	return replaced
}

fn api_struct_deep_replace(value ruby.Value, paths ApiStructPaths,
	appdir string) ruby.Value {
	if value.type_name == 'String' {
		return ruby.string_value(value.as_string().replace(r'$HOMEBREW_PREFIX', paths.prefix).replace(r'$HOMEBREW_CELLAR', paths.cellar).replace(r'$APPDIR', appdir).replace(r'/$HOME', paths.home))
	}
	if value.type_name == 'Array' {
		return ruby.array_value(api_struct_value_array(value).map(api_struct_deep_replace(it, paths, appdir)))
	}
	if value.type_name == 'Hash' {
		mut mapped := map[string]ruby.Value{}
		for key, item in value.map_data {
			mapped[key] = api_struct_deep_replace(item, paths, appdir)
		}
		return ruby.map_value(mapped)
	}
	return value
}

fn api_struct_values_equal(left ruby.Value, right ruby.Value) bool {
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

fn api_struct_maps_equal(left map[string]ruby.Value,
	right map[string]ruby.Value) bool {
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
