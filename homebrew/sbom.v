module homebrew

import ruby
import os
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
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.create(formula, tab)` at line 33.
pub fn ruby_sbom_l33_d1_self_create(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'formula and tab are required')
	}
	formula := args[0]
	tab := args[1]
	active := if sbom_bool(formula, 'stable', true) {
		formula.map_data['stable'] or { formula }
	} else {
		formula.map_data['head'] or { formula }
	}
	source := ruby.Value{
		type_name: 'SBOM::Source'
		attributes: {
			'path':         formula.attributes['specified_path'] or { '' }
			'tap_name':     formula.attributes['tap_name'] or { '' }
			'tap_git_head': if sbom_bool(formula, 'tap_installed', false) {
				formula.attributes['tap_git_head'] or { '' }} else {
				''}
			'spec':         formula.attributes['active_spec_sym'] or { 'stable' }
			'version':      active.attributes['version'] or { formula.attributes['version'] or { '' } }
			'url':          active.attributes['url'] or { formula.attributes['url'] or { '' } }
			'checksum':     active.attributes['checksum'] or { formula.attributes['checksum'] or { '' } }
		}
		map_data: {
			'patches': active.map_data['patches'] or {
				formula.map_data['patches'] or {
					ruby.array_value([])}}
			'bottle':  formula.map_data['bottle'] or { ruby.map_value({}) }
		}
	}
	deps := ruby_sbom_l72_d3_self_runtime_deps_hash(tab.map_data['runtime_dependencies'] or {
		ruby.array_value([])
	}).as_array() or { [] }
	prefix := formula.attributes['prefix'] or { '' }
	return sbom_state(formula.attributes['name'] or { formula.repr }, os.join_path(prefix, sbom_filename), (tab.attributes['source_modified_time'] or { '0' }).i64(), tab.attributes['compiler'] or { '' }, tab.attributes['stdlib'] or { '' }, deps, formula.attributes['license'] or { '' }, tab.map_data['built_on'] or {
		sbom_string_map({})
	}, source)
}

// Ruby method `self.spdxfile(formula)` at line 67.
pub fn ruby_sbom_l67_d2_self_spdxfile(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('Pathname', sbom_filename)
	}
	return ruby.object_value('Pathname', os.join_path(args[0].attributes['prefix'] or {
		''
	}, sbom_filename))
}

// Ruby method `self.runtime_deps_hash(deps)` at line 72.
pub fn ruby_sbom_l72_d3_self_runtime_deps_hash(args ...ruby.Value) ruby.Value {
	deps := if args.len > 0 { args[0].as_array() or { [] } } else { []ruby.Value{} }
	mut result := []ruby.Value{}
	for dependency in deps {
		formula := dependency.map_data['formula'] or { dependency }
		full_name := dependency.attributes['full_name'] or {
			formula.attributes['full_name'] or {
				formula.repr
			}
		}
		result << ruby.Value{
			type_name: 'Hash'
			map_data: {
				'full_name':           ruby.string_value(full_name)
				'pkg_version':         ruby.string_value(dependency.attributes['pkg_version'] or {
					dependency.attributes['version'] or { '' }})
				'name':                ruby.string_value(formula.attributes['name'] or {
					formula.repr})
				'license':             ruby.string_value(formula.attributes['license'] or { '' })
				'bottle':              formula.map_data['bottle'] or { ruby.map_value({}) }
				'formula_pkg_version': ruby.string_value(formula.attributes['pkg_version'] or {
					formula.attributes['version'] or { '' }})
			}
		}
	}
	return ruby.array_value(result)
}

// Ruby method `self.exist?(formula)` at line 88.
pub fn ruby_sbom_l88_d4_self_exist(args ...ruby.Value) ruby.Value {
	path := ruby_sbom_l67_d2_self_spdxfile(...args).as_string()
	return ruby.bool_value(os.exists(path))
}

// Ruby method `self.github_packages_sbom_supplement_annotation(supplement, formula_full_name:, formula_name:, version:,` at line 104.
pub fn ruby_sbom_l104_d5_self_github_packages_sbom_supplement_annotation(args ...ruby.Value) ruby.Value {
	if args.len < 8 || args[0].type_name == 'NilClass' {
		return sbom_nil()
	}
	bottle := ruby_sbom_l133_d6_self_bottle_package(args[1], args[2], args[3], args[4], args[5], args[6], args[7])
	result := ruby_sbom_l327_d16_self_add_bottle_package_to_supplement(args[0], bottle)
	if result.type_name == 'NilClass' {
		return result
	}
	return ruby.string_value(sbom_json(result))
}

// Ruby method `self.bottle_package(formula_full_name, formula_name, version, tar_gz_sha256, root_url:, license:, created_date:)` at line 133.
pub fn ruby_sbom_l133_d6_self_bottle_package(args ...ruby.Value) ruby.Value {
	if args.len < 7 {
		return ruby.map_value({})
	}
	full_name := args[0].as_string()
	name := args[1].as_string()
	version := args[2].as_string()
	sha256 := args[3].as_string()
	root_url := args[4].as_string().trim_string_right('/')
	license := args[5].as_string()
	created := args[6].as_string()
	image_name := name.replace('@', '/').replace('+', 'x')
	return ruby.map_value({
		'SPDXID':           ruby.string_value('SPDXRef-Bottle-${name}')
		'name':             ruby.string_value(name)
		'versionInfo':      ruby.string_value(version)
		'filesAnalyzed':    ruby.bool_value(false)
		'licenseDeclared':  ruby.string_value('NOASSERTION')
		'builtDate':        ruby.string_value(created)
		'licenseConcluded': ruby.string_value(if license == '' {
			'NOASSERTION'
		} else {
			license
		})
		'downloadLocation': ruby.string_value('${root_url}/${image_name}/blobs/sha256:${sha256}')
		'copyrightText':    ruby.string_value('NOASSERTION')
		'externalRefs':     ruby.array_value([
			sbom_external_ref(sbom_purl(full_name, version)),
		])
		'checksums':        ruby.array_value([sbom_checksum(sha256)])
	})
}

// Ruby method `self.brew_purl(full_name, version)` at line 163.
pub fn ruby_sbom_l163_d7_self_brew_purl(args ...ruby.Value) ruby.Value {
	full_name := if args.len > 0 { args[0].as_string() } else { '' }
	version := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].as_string()
	} else {
		''
	}
	return ruby.string_value(sbom_purl(full_name, version))
}

// Ruby method `self.update_pour_metadata(spdxfile, homebrew_version:, time:, supplement: nil)` at line 181.
pub fn ruby_sbom_l181_d8_self_update_pour_metadata(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return sbom_nil()
	}
	path := args[0].as_string()
	if !os.exists(path) {
		return sbom_nil()
	}
	contents := os.read_file(path) or { return sbom_nil() }
	decoded := json2.decode[json2.Any](contents) or { return sbom_nil() }
	mut spdx := sbom_any_to_value(decoded)
	if spdx.type_name != 'Hash' {
		return sbom_nil()
	}
	mut creation := spdx.map_data['creationInfo'] or { return sbom_nil() }
	if creation.type_name != 'Hash' {
		return sbom_nil()
	}
	mut creation_map := creation.map_data.clone()
	creation_map['created'] = ruby.string_value(sbom_time(args[2].int_data))
	creation_map['creators'] = ruby.string_array_value([
		'Tool: https://github.com/Homebrew/brew@${args[1].as_string()}',
	])
	creation = ruby.map_value(creation_map)
	mut spdx_map := spdx.map_data.clone()
	spdx_map['creationInfo'] = creation
	spdx = ruby.map_value(spdx_map)
	if args.len > 3 && args[3].type_name != 'NilClass' {
		spdx = ruby_sbom_l310_d15_self_merge_spdx_supplement(spdx, args[3])
	}
	os.write_file(path, sbom_json(spdx)) or { return ruby.object_value('IOError', err.msg()) }
	return spdx
}

// Ruby method `self.schema` at line 199.
pub fn ruby_sbom_l199_d9_self_schema(args ...ruby.Value) ruby.Value {
	path := os.join_path(os.dir(@FILE), 'data', 'schemas', 'sbom.json')
	contents := os.read_file(path) or { return ruby.object_value('SchemaError', err.msg()) }
	decoded := json2.decode[json2.Any](contents) or { return ruby.object_value('SchemaError', err.msg()) }
	return sbom_any_to_value(decoded)
}

// Ruby method `schema_validation_errors(data = nil, bottling: false)` at line 204.
pub fn ruby_sbom_l204_d10_schema_validation_errors(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value(['SBOM receiver is required'])
	}
	receiver := args[0]
	if !sbom_bool(receiver, 'json_schemer_available', true) {
		if sbom_bool(receiver, 'enforce_sbom', false) {
			return ruby.object_value('RuntimeError', 'Need json_schemer to validate SBOM, run `brew install-bundler-gems --add-groups=bottle`!')
		}
		return ruby.string_array_value([])
	}
	bottling := args.len > 2 && args[2].bool_data
	data := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1]
	} else {
		ruby_sbom_l246_d13_to_spdx_sbom(receiver, ruby.bool_value(bottling))
	}
	if injected := data.map_data['schema_validation_errors'] {
		return ruby.string_array_value(injected.as_string_array() or { [] })
	}
	mut errors := []string{}
	for key in ['SPDXID', 'spdxVersion', 'name', 'creationInfo', 'dataLicense', 'documentNamespace',
		'documentDescribes', 'files', 'packages', 'relationships'] {
		if key !in data.map_data {
			errors << "required property '${key}' is missing"
		}
	}
	return ruby.string_array_value(errors)
}

// Ruby method `valid?(data = nil, bottling: false)` at line 217.
pub fn ruby_sbom_l217_d11_valid(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	errors := ruby_sbom_l204_d10_schema_validation_errors(...args)
	if errors.type_name != 'Array' {
		return errors
	}
	values := errors.as_string_array() or { [] }
	if values.len == 0 {
		return ruby.bool_value(true)
	}
	if sbom_bool(args[0], 'enforce_sbom', false) {
		return ruby.object_value('RuntimeError', 'Failed to validate SBOM against JSON schema!')
	}
	return ruby.Value{
		type_name: 'Bool'
		repr: 'false'
		bool_data: false
		attributes: {
			'stderr': 'Warning: SBOM validation errors:\n${values.join('\n')}\n'
		}
	}
}

// Ruby method `write(validate: true, bottling: false)` at line 230.
pub fn ruby_sbom_l230_d12_write(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'SBOM receiver is required')
	}
	receiver := args[0]
	validate := args.len < 2 || args[1].bool_data
	bottling := args.len > 2 && args[2].bool_data
	spdx := ruby_sbom_l246_d13_to_spdx_sbom(receiver, ruby.bool_value(bottling))
	if validate {
		valid := ruby_sbom_l217_d11_valid(receiver, spdx, ruby.bool_value(bottling))
		if valid.type_name == 'RuntimeError' {
			return valid
		}
		if valid.type_name != 'Bool' || !valid.bool_data {
			return ruby.Value{
				type_name: 'SBOMWriteResult'
				bool_data: false
				attributes: {
					'stderr': 'Warning: SBOM is not valid, not writing to disk!\n'
				}
			}
		}
	}
	path := receiver.attributes['spdxfile'] or { '' }
	if path == '' {
		return ruby.object_value('IOError', 'SPDX file path is empty')
	}
	file_existed := os.exists(path)
	os.mkdir_all(os.dir(path)) or { return ruby.object_value('IOError', err.msg()) }
	os.write_file(path, sbom_json(spdx)) or { return ruby.object_value('IOError', err.msg()) }
	return ruby.Value{
		type_name: 'SBOMWriteResult'
		bool_data: true
		attributes: {
			'path':                path
			'formula_cache_clear': (!file_existed).str()
		}
		map_data: {
			'sbom': spdx
		}
	}
}

// Ruby method `to_spdx_sbom(bottling: false)` at line 246.
pub fn ruby_sbom_l246_d13_to_spdx_sbom(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	receiver := args[0]
	bottling := args.len > 1 && args[1].bool_data
	runtime := ruby_sbom_l612_d29_full_spdx_runtime_dependencies(receiver, ruby.bool_value(bottling)).as_array() or { [] }
	compiler := if bottling {
		ruby.map_value({})
	} else {
		ruby_sbom_l398_d25_compiler_packages(receiver)
	}
	packages := ruby_sbom_l494_d27_generate_packages_json(receiver, ruby.array_value(runtime), compiler, ruby.bool_value(bottling)).as_array() or { [] }
	files := ruby_sbom_l591_d28_generate_files_json(receiver).as_array() or { [] }
	relations := ruby_sbom_l439_d26_generate_relations_json(receiver, ruby.array_value(runtime), compiler, ruby.bool_value(bottling)).as_array() or { [] }
	name := receiver.attributes['name'] or { receiver.repr }
	version := ruby_sbom_l707_d37_spec_version(receiver).as_string()
	return ruby.map_value({
		'SPDXID':            ruby.string_value('SPDXRef-DOCUMENT')
		'spdxVersion':       ruby.string_value('SPDX-2.3')
		'name':              ruby.string_value('SBOM-SPDX-${name}-${version}')
		'creationInfo':      ruby.map_value({
			'created':  ruby.string_value(ruby_sbom_l712_d38_source_modified_time(receiver).as_string())
			'creators': ruby.string_array_value([
				'Tool: https://github.com/Homebrew/brew',
			])
		})
		'dataLicense':       ruby.string_value('CC0-1.0')
		'documentNamespace': ruby.string_value('https://formulae.brew.sh/spdx/${name}-${version}.json')
		'documentDescribes': ruby.string_array_value(packages.map(sbom_package_id(it)))
		'files':             ruby.array_value(files)
		'packages':          ruby.array_value(packages)
		'relationships':     ruby.array_value(relations)
	})
}

// Ruby method `to_spdx_supplement` at line 271.
pub fn ruby_sbom_l271_d14_to_spdx_supplement(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	receiver := args[0]
	runtime := ruby_sbom_l612_d29_full_spdx_runtime_dependencies(receiver, ruby.bool_value(false)).as_array() or { [] }
	compiler := ruby_sbom_l398_d25_compiler_packages(receiver)
	mut packages := runtime.clone()
	for _, package in compiler.map_data {
		packages << package
	}
	mut relations := []ruby.Value{}
	for dependency in runtime {
		relations << sbom_relationship(sbom_package_id(dependency), 'RUNTIME_DEPENDENCY_OF', ruby_sbom_l686_d33_bottle_spdx_id(receiver).as_string())
	}
	if compiler_package := compiler.map_data['SPDXRef-Compiler'] {
		if sbom_present(compiler_package) {
			relations << sbom_relationship('SPDXRef-Compiler', 'BUILD_TOOL_OF', 'SPDXRef-Archive-${receiver.attributes['name'] or { receiver.repr }}-src')
		}
	}
	if stdlib_package := compiler.map_data['SPDXRef-Stdlib'] {
		if sbom_present(stdlib_package) {
			relations << sbom_relationship('SPDXRef-Stdlib', 'DEPENDENCY_OF', ruby_sbom_l686_d33_bottle_spdx_id(receiver).as_string())
		}
	}
	return ruby.map_value({
		'documentDescribes': ruby.string_array_value(packages.map(sbom_package_id(it)))
		'packages':          ruby.array_value(packages)
		'relationships':     ruby.array_value(relations)
	})
}

// Ruby method `self.merge_spdx_supplement(spdx, supplement)` at line 310.
pub fn ruby_sbom_l310_d15_self_merge_spdx_supplement(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[0].type_name != 'Hash' || args[1].type_name != 'Hash' {
		return if args.len > 0 { args[0] } else { sbom_nil() }
	}
	mut mapped := args[0].map_data.clone()
	for key in ['documentDescribes', 'packages', 'relationships'] {
		left := mapped[key] or { continue }
		right := args[1].map_data[key] or { continue }
		if left.type_name != 'Array' || right.type_name != 'Array' {
			continue
		}
		mut combined := left.as_array() or { [] }
		combined << right.as_array() or { [] }
		mapped[key] = ruby.array_value(combined)
	}
	return ruby.map_value(mapped)
}

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

// Ruby attr_reader `attr_reader :name` at line 354.
pub fn ruby_sbom_l354_d17_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 {
		args[0].attributes['name'] or {
			args[0].repr
		}
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :stdlib` at line 357.
pub fn ruby_sbom_l357_d18_stdlib(args ...ruby.Value) ruby.Value {
	if args.len == 0 || (args[0].attributes['stdlib'] or { '' }) == '' {
		return sbom_nil()
	}
	return ruby.string_value(args[0].attributes['stdlib'])
}

// Ruby attr_reader `attr_reader :source` at line 360.
pub fn ruby_sbom_l360_d19_source(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { sbom_source(args[0]) } else { ruby.map_value({}) }
}

// Ruby attr_reader `attr_reader :built_on` at line 363.
pub fn ruby_sbom_l363_d20_built_on(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		args[0].map_data['built_on'] or { ruby.map_value({}) }
	} else {
		ruby.map_value({})
	}
}

// Ruby attr_reader `attr_reader :license` at line 366.
pub fn ruby_sbom_l366_d21_license(args ...ruby.Value) ruby.Value {
	if args.len == 0 || (args[0].attributes['license'] or { '' }) == '' {
		return sbom_nil()
	}
	return ruby.string_value(args[0].attributes['license'])
}

// Ruby attr_accessor `attr_accessor :spdxfile` at line 369.
pub fn ruby_sbom_l369_d22_spdxfile(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', if args.len > 0 {
		args[0].attributes['spdxfile'] or {
			''
		}
	} else {
		''
	})
}

// Ruby attr_accessor `attr_accessor :spdxfile` at line 369.
pub fn ruby_sbom_l369_d23_spdxfile(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return if args.len > 0 { args[0] } else { sbom_nil() }
	}
	mut attributes := args[0].attributes.clone()
	attributes['spdxfile'] = args[1].as_string()
	return ruby.Value{
		...args[0]
		attributes: attributes
	}
}

// Ruby method `initialize(name:, spdxfile:, source_modified_time:, compiler:, stdlib:, runtime_dependencies:,` at line 384.
pub fn ruby_sbom_l384_d24_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 9 {
		return ruby.object_value('ArgumentError', 'nine SBOM initializer values are required')
	}
	return sbom_state(args[0].as_string(), args[1].as_string(), args[2].int_data, args[3].as_string(), if args[4].type_name == 'NilClass' {
		''
	} else {
		args[4].as_string()
	}, args[5].as_array() or { [] }, if args[6].type_name == 'NilClass' {
		''
	} else {
		args[6].as_string()
	}, args[7], args[8])
}

// Ruby method `compiler_packages` at line 398.
pub fn ruby_sbom_l398_d25_compiler_packages(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	receiver := args[0]
	compiler := ruby_sbom_l691_d34_compiler(receiver).as_string()
	built_on := ruby_sbom_l363_d20_built_on(receiver)
	xcode := built_on.map_data['xcode'] or { sbom_nil() }
	mut packages := {
		'SPDXRef-Compiler': ruby.map_value({
			'SPDXID':           ruby.string_value('SPDXRef-Compiler')
			'name':             ruby.string_value(compiler)
			'versionInfo':      sbom_assert(xcode)
			'filesAnalyzed':    ruby.bool_value(false)
			'licenseDeclared':  ruby.string_value('NOASSERTION')
			'licenseConcluded': ruby.string_value('NOASSERTION')
			'copyrightText':    ruby.string_value('NOASSERTION')
			'downloadLocation': ruby.string_value('NOASSERTION')
			'checksums':        ruby.array_value([])
			'externalRefs':     ruby.array_value([])
		})
	}
	stdlib := receiver.attributes['stdlib'] or { '' }
	if stdlib != '' {
		packages['SPDXRef-Stdlib'] = ruby.map_value({
			'SPDXID':           ruby.string_value('SPDXRef-Stdlib')
			'name':             ruby.string_value(stdlib)
			'versionInfo':      ruby.string_value(stdlib)
			'filesAnalyzed':    ruby.bool_value(false)
			'licenseDeclared':  ruby.string_value('NOASSERTION')
			'licenseConcluded': ruby.string_value('NOASSERTION')
			'copyrightText':    ruby.string_value('NOASSERTION')
			'downloadLocation': ruby.string_value('NOASSERTION')
			'checksums':        ruby.array_value([])
			'externalRefs':     ruby.array_value([])
		})
	}
	return ruby.map_value(packages)
}

// Ruby method `generate_relations_json(runtime_dependency_declaration, compiler_declaration, bottling:)` at line 439.
pub fn ruby_sbom_l439_d26_generate_relations_json(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		return ruby.array_value([])
	}
	receiver := args[0]
	runtime := args[1].as_array() or { [] }
	compiler := args[2]
	bottling := args[3].bool_data
	mut relationships := runtime.map(sbom_relationship(sbom_package_id(it), 'RUNTIME_DEPENDENCY_OF', ruby_sbom_l677_d32_described_package_spdx_id(receiver, ruby.bool_value(bottling)).as_string()))
	name := receiver.attributes['name'] or { receiver.repr }
	for index, patch in sbom_values(sbom_source(receiver), 'patches') {
		if patch.type_name == 'ExternalPatch' || patch.attributes['kind'] == 'external' {
			relationships << sbom_relationship('SPDXRef-Patch-${name}-${index}', 'PATCH_APPLIED', 'SPDXRef-Archive-${name}-src')
		}
	}
	if sbom_present(sbom_source_value(sbom_source(receiver), 'checksum')) {
		relationships << sbom_relationship('SPDXRef-File-${name}', 'PACKAGE_OF', 'SPDXRef-Archive-${name}-src')
	}
	if !bottling {
		relationships << sbom_relationship('SPDXRef-Compiler', 'BUILD_TOOL_OF', 'SPDXRef-Archive-${name}-src')
		if stdlib := compiler.map_data['SPDXRef-Stdlib'] {
			if sbom_present(stdlib) {
				relationships << sbom_relationship('SPDXRef-Stdlib', 'DEPENDENCY_OF', ruby_sbom_l677_d32_described_package_spdx_id(receiver, ruby.bool_value(false)).as_string())
			}
		}
	}
	return ruby.array_value(relationships)
}

// Ruby method `generate_packages_json(runtime_dependency_declaration, compiler_declaration, bottling:)` at line 494.
pub fn ruby_sbom_l494_d27_generate_packages_json(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		return ruby.array_value([])
	}
	receiver := args[0]
	runtime := args[1].as_array() or { [] }
	compiler := args[2]
	bottling := args[3].bool_data
	name := receiver.attributes['name'] or { receiver.repr }
	source := sbom_source(receiver)
	version := ruby_sbom_l707_d37_spec_version(receiver).as_string()
	url := sbom_source_value(source, 'url').as_string()
	checksum := sbom_source_value(source, 'checksum').as_string()
	license := receiver.attributes['license'] or { '' }
	full_name := [source.attributes['tap_name'] or { '' }, name].filter(it != '').join('/')
	mut external_refs := [sbom_external_ref(sbom_purl(full_name, version))]
	upstream := sbom_upstream_purl(url, version)
	if upstream != '' {
		external_refs << sbom_external_ref(upstream)
	}
	mut packages := [ruby.map_value({
		'SPDXID':           ruby.string_value('SPDXRef-Archive-${name}-src')
		'name':             ruby.string_value(name)
		'versionInfo':      ruby.string_value(version)
		'filesAnalyzed':    ruby.bool_value(false)
		'licenseDeclared':  ruby.string_value('NOASSERTION')
		'builtDate':        ruby.string_value(ruby_sbom_l712_d38_source_modified_time(receiver).as_string())
		'licenseConcluded': ruby.string_value(if license == '' {
			'NOASSERTION'
		} else {
			license
		})
		'downloadLocation': if url == '' {
			ruby.string_value('NOASSERTION')
		} else {
			ruby.string_value(url)
		}
		'copyrightText':    ruby.string_value('NOASSERTION')
		'externalRefs':     ruby.array_value(external_refs)
		'checksums':        ruby.array_value([sbom_checksum(checksum)])
	})]
	for index, patch in sbom_values(source, 'patches') {
		if patch.type_name != 'ExternalPatch' && patch.attributes['kind'] != 'external' {
			continue
		}
		patch_checksum := patch.attributes['checksum'] or { '' }
		packages << ruby.map_value({
			'SPDXID':           ruby.string_value('SPDXRef-Patch-${name}-${index}')
			'name':             ruby.string_value('${name} patch ${index}')
			'filesAnalyzed':    ruby.bool_value(false)
			'licenseDeclared':  ruby.string_value('NOASSERTION')
			'licenseConcluded': ruby.string_value('NOASSERTION')
			'downloadLocation': sbom_assert(ruby.string_value(patch.attributes['url'] or {
				''
			}))
			'copyrightText':    ruby.string_value('NOASSERTION')
			'checksums':        if patch_checksum == '' {
				ruby.array_value([])
			} else {
				ruby.array_value([sbom_checksum(patch_checksum)])
			}
			'externalRefs':     ruby.array_value([])
		})
	}
	packages << runtime
	for _, package in compiler.map_data {
		packages << package
	}
	if ruby_sbom_l672_d31_bottle_package(receiver, ruby.bool_value(bottling)).bool_data {
		info := ruby_sbom_l659_d30_get_bottle_info(receiver, source.map_data['bottle'] or {
			ruby.map_value({})
		})
		if info.type_name == 'Hash' && version != '' {
			packages << ruby.map_value({
				'SPDXID':           ruby.string_value('SPDXRef-Bottle-${name}')
				'name':             ruby.string_value(name)
				'versionInfo':      ruby.string_value(version)
				'filesAnalyzed':    ruby.bool_value(false)
				'licenseDeclared':  ruby.string_value('NOASSERTION')
				'builtDate':        ruby.string_value(ruby_sbom_l712_d38_source_modified_time(receiver).as_string())
				'licenseConcluded': ruby.string_value(if license == '' {
					'NOASSERTION'
				} else {
					license
				})
				'downloadLocation': ruby.string_value(sbom_map_string(info, 'url'))
				'copyrightText':    ruby.string_value('NOASSERTION')
				'externalRefs':     ruby.array_value([
					sbom_external_ref(sbom_purl(full_name, version)),
				])
				'checksums':        ruby.array_value([
					sbom_checksum(sbom_map_string(info, 'sha256')),
				])
			})
		}
	}
	return ruby.array_value(packages)
}

// Ruby method `generate_files_json` at line 591.
pub fn ruby_sbom_l591_d28_generate_files_json(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	receiver := args[0]
	source := sbom_source(receiver)
	checksum := sbom_source_value(source, 'checksum').as_string()
	if checksum == '' {
		return ruby.array_value([])
	}
	name := receiver.attributes['name'] or { receiver.repr }
	url := sbom_source_value(source, 'url').as_string()
	filename := if url.all_after_last('/') != '' {
		url.all_after_last('/')
	} else {
		'${name}-${ruby_sbom_l707_d37_spec_version(receiver).as_string()}'
	}
	return ruby.array_value([ruby.map_value({
		'SPDXID':    ruby.string_value('SPDXRef-File-${name}')
		'fileName':  ruby.string_value(filename)
		'checksums': ruby.array_value([sbom_checksum(checksum)])
	})])
}

// Ruby method `full_spdx_runtime_dependencies(bottling:)` at line 612.
pub fn ruby_sbom_l612_d29_full_spdx_runtime_dependencies(args ...ruby.Value) ruby.Value {
	if args.len == 0 || (args.len > 1 && args[1].bool_data) {
		return ruby.array_value([])
	}
	mut packages := []ruby.Value{}
	for dependency in sbom_values(args[0], 'runtime_dependencies') {
		if dependency.type_name != 'Hash' || dependency.map_data.len == 0 {
			continue
		}
		bottle := dependency.map_data['bottle'] or { continue }
		info := ruby_sbom_l659_d30_get_bottle_info(args[0], bottle)
		if info.type_name != 'Hash' || info.map_data.len == 0 {
			continue
		}
		name := sbom_map_string(dependency, 'name')
		pkg_version := sbom_map_string(dependency, 'pkg_version')
		formula_version := sbom_map_string(dependency, 'formula_pkg_version')
		url := if pkg_version == formula_version { sbom_map_string(info, 'url') } else { '' }
		license := sbom_map_string(dependency, 'license')
		packages << ruby.map_value({
			'SPDXID':           ruby.string_value('SPDXRef-Package-SPDXRef-${name.replace('/', '-')}-${pkg_version}')
			'name':             ruby.string_value(name)
			'versionInfo':      ruby.string_value(pkg_version)
			'filesAnalyzed':    ruby.bool_value(false)
			'licenseDeclared':  ruby.string_value('NOASSERTION')
			'licenseConcluded': ruby.string_value(if license == '' {
				'NOASSERTION'
			} else {
				license
			})
			'downloadLocation': ruby.string_value(if url == '' {
				'NOASSERTION'
			} else {
				url
			})
			'copyrightText':    ruby.string_value('NOASSERTION')
			'checksums':        ruby.array_value([sbom_checksum(if sbom_map_string(info, 'sha256') == '' {
				'NOASSERTION'
			} else {
				sbom_map_string(info, 'sha256')
			})])
			'externalRefs':     ruby.array_value([
				sbom_external_ref(sbom_purl(sbom_map_string(dependency, 'full_name'), pkg_version)),
			])
		})
	}
	return ruby.array_value(packages)
}

// Ruby method `get_bottle_info(base)` at line 659.
pub fn ruby_sbom_l659_d30_get_bottle_info(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'Hash' || args[1].map_data.len == 0 {
		return sbom_nil()
	}
	files := args[1].map_data['files'] or { return sbom_nil() }
	if files.type_name != 'Hash' {
		return sbom_nil()
	}
	tag := args[0].attributes['bottle_tag'] or { 'all' }
	info := files.map_data[tag] or { files.map_data['all'] or { return sbom_nil() } }
	if info.type_name != 'Hash' {
		return sbom_nil()
	}
	mut mapped := map[string]ruby.Value{}
	for key, value in info.map_data {
		mapped[key] = ruby.string_value(value.as_string())
	}
	for key, value in info.attributes {
		mapped[key] = ruby.string_value(value)
	}
	return ruby.map_value(mapped)
}

// Ruby method `bottle_package?(bottling:)` at line 672.
pub fn ruby_sbom_l672_d31_bottle_package(args ...ruby.Value) ruby.Value {
	if args.len == 0 || (args.len > 1 && args[1].bool_data) {
		return ruby.bool_value(false)
	}
	receiver := args[0]
	info := ruby_sbom_l659_d30_get_bottle_info(receiver, sbom_source(receiver).map_data['bottle'] or {
		ruby.map_value({})
	})
	return ruby.bool_value(info.type_name == 'Hash' && info.map_data.len > 0 && ruby_sbom_l702_d36_spec_symbol(receiver).as_string() == 'stable' && ruby_sbom_l707_d37_spec_version(receiver).as_string() != '')
}

// Ruby method `described_package_spdx_id(bottling:)` at line 677.
pub fn ruby_sbom_l677_d32_described_package_spdx_id(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	bottling := args.len > 1 && args[1].bool_data
	if ruby_sbom_l672_d31_bottle_package(args[0], ruby.bool_value(bottling)).bool_data {
		return ruby_sbom_l686_d33_bottle_spdx_id(args[0])
	}
	return ruby.string_value('SPDXRef-Archive-${args[0].attributes['name'] or {
		args[0].repr
	}}-src')
}

// Ruby method `bottle_spdx_id` at line 686.
pub fn ruby_sbom_l686_d33_bottle_spdx_id(args ...ruby.Value) ruby.Value {
	return ruby.string_value('SPDXRef-Bottle-${if args.len > 0 {
		args[0].attributes['name'] or { args[0].repr }
	} else {
		''
	}}')
}

// Ruby method `compiler` at line 691.
pub fn ruby_sbom_l691_d34_compiler(args ...ruby.Value) ruby.Value {
	if args.len > 0 && (args[0].attributes['compiler'] or { '' }) != '' {
		return ruby.string_value(args[0].attributes['compiler'])
	}
	default_compiler := if args.len > 0 {
		args[0].attributes['default_compiler'] or {
			'clang'
		}
	} else {
		'clang'
	}
	return ruby.string_value(default_compiler)
}

// Ruby method `tap` at line 696.
pub fn ruby_sbom_l696_d35_tap(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return sbom_nil()
	}
	name := sbom_source(args[0]).attributes['tap_name'] or { '' }
	return if name == '' {
		sbom_nil()
	} else {
		ruby.structured_value('Tap', name, {
			'name': name
		})
	}
}

// Ruby method `spec_symbol` at line 702.
pub fn ruby_sbom_l702_d36_spec_symbol(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', if args.len > 0 {
		sbom_source(args[0]).attributes['spec'] or { 'stable' }
	} else {
		'stable'
	})
}

// Ruby method `spec_version` at line 707.
pub fn ruby_sbom_l707_d37_spec_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return sbom_nil()
	}
	return sbom_source_value(sbom_source(args[0]), 'version')
}

// Ruby method `source_modified_time` at line 712.
pub fn ruby_sbom_l712_d38_source_modified_time(args ...ruby.Value) ruby.Value {
	epoch := if args.len > 0 {
		(args[0].attributes['source_modified_time'] or { '0' }).i64()
	} else {
		i64(0)
	}
	return ruby.object_value('Time', sbom_time(epoch))
}

// Ruby method `assert_value(val)` at line 717.
pub fn ruby_sbom_l717_d39_assert_value(args ...ruby.Value) ruby.Value {
	return sbom_assert(if args.len > 1 {
		args[1]
	} else if args.len > 0 {
		args[0]
	} else {
		sbom_nil()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "development_tools"
// 6: require "utils/curl"
// 7: require "utils/output"
// 8: require "vulns/identify"
// 9:
// 10: # Rather than calling `new` directly, use one of the class methods like {SBOM.create}.
// 11: class SBOM
// 12:   include Utils::Output::Mixin
// 13:
// 14:   FILENAME = "sbom.spdx.json"
// 15:   SCHEMA_FILE = T.let((HOMEBREW_LIBRARY_PATH/"data/schemas/sbom.json").freeze, Pathname)
// 16:   SPDXHash = T.type_alias { T::Hash[String, Object] }
// 17:   SPDXSymbolHash = T.type_alias { T::Hash[Symbol, Object] }
// 18:
// 19:   class Source < T::Struct
// 20:     const :path, String
// 21:     const :tap_name, T.nilable(String)
// 22:     const :tap_git_head, T.nilable(String)
// 23:     const :spec, Symbol
// 24:     const :patches, T::Array[T.any(EmbeddedPatch, ExternalPatch)]
// 25:     const :bottle, T::Hash[String, Object]
// 26:     const :version, T.nilable(Version)
// 27:     const :url, T.nilable(String)
// 28:     const :checksum, T.nilable(Checksum)
// 29:   end
// 30:
// 31:   # Instantiates a {SBOM} for a new installation of a formula.
// 32:   sig { params(formula: Formula, tab: Tab).returns(T.attached_class) }
// 33:   def self.create(formula, tab)
// 34:     active_spec = if formula.stable?
// 35:       T.must(formula.stable)
// 36:     else
// 37:       T.must(formula.head)
// 38:     end
// 39:     active_spec_sym = formula.active_spec_sym
// 40:
// 41:     new(
// 42:       name:                 formula.name,
// 43:       spdxfile:             SBOM.spdxfile(formula),
// 44:       source_modified_time: tab.source_modified_time.to_i,
// 45:       compiler:             tab.compiler,
// 46:       stdlib:               tab.stdlib,
// 47:       runtime_dependencies: SBOM.runtime_deps_hash(T.cast(Array(tab.runtime_dependencies),
// 48:                                                           T::Array[T::Hash[String, Object]])),
// 49:       license:              SPDX.license_expression_to_string(formula.license),
// 50:       built_on:             DevelopmentTools.build_system_info,
// 51:       source:               Source.new(
// 52:         path:         formula.specified_path.to_s,
// 53:         tap_name:     formula.tap&.name,
// 54:         # We can only get `tap_git_head` if the tap is installed locally
// 55:         tap_git_head: (formula.tap!.git_head if formula.tap&.installed?),
// 56:         spec:         active_spec_sym,
// 57:         patches:      active_spec.patches,
// 58:         bottle:       formula.bottle_hash,
// 59:         version:      active_spec.version,
// 60:         url:          active_spec.url,
// 61:         checksum:     active_spec.checksum,
// 62:       ),
// 63:     )
// 64:   end
// 65:
// 66:   sig { params(formula: Formula).returns(Pathname) }
// 67:   def self.spdxfile(formula)
// 68:     formula.prefix/FILENAME
// 69:   end
// 70:
// 71:   sig { params(deps: T::Array[T::Hash[String, Object]]).returns(T::Array[T::Hash[String, Object]]) }
// 72:   def self.runtime_deps_hash(deps)
// 73:     deps.map do |dep|
// 74:       full_name = dep.fetch("full_name").to_s
// 75:       dep_formula = Formula[full_name]
// 76:       {
// 77:         "full_name"           => full_name,
// 78:         "pkg_version"         => dep.fetch("pkg_version"),
// 79:         "name"                => dep_formula.name,
// 80:         "license"             => SPDX.license_expression_to_string(dep_formula.license),
// 81:         "bottle"              => dep_formula.bottle_hash,
// 82:         "formula_pkg_version" => dep_formula.pkg_version.to_s,
// 83:       }
// 84:     end
// 85:   end
// 86:
// 87:   sig { params(formula: Formula).returns(T::Boolean) }
// 88:   def self.exist?(formula)
// 89:     spdxfile(formula).exist?
// 90:   end
// 91:
// 92:   sig {
// 93:     params(
// 94:       supplement:        T.nilable(SPDXHash),
// 95:       formula_full_name: String,
// 96:       formula_name:      String,
// 97:       version:           Version,
// 98:       tar_gz_sha256:     String,
// 99:       root_url:          String,
// 100:       license:           String,
// 101:       created_date:      String,
// 102:     ).returns(T.nilable(String))
// 103:   }
// 104:   def self.github_packages_sbom_supplement_annotation(supplement, formula_full_name:, formula_name:, version:,
// 105:                                                       tar_gz_sha256:, root_url:, license:, created_date:)
// 106:     require "github_packages"
// 107:
// 108:     add_bottle_package_to_supplement(
// 109:       supplement,
// 110:       bottle_package(
// 111:         formula_full_name,
// 112:         formula_name,
// 113:         version,
// 114:         tar_gz_sha256,
// 115:         root_url:,
// 116:         license:,
// 117:         created_date:,
// 118:       ),
// 119:     )&.to_json
// 120:   end
// 121:
// 122:   sig {
// 123:     params(
// 124:       formula_full_name: String,
// 125:       formula_name:      String,
// 126:       version:           Version,
// 127:       tar_gz_sha256:     String,
// 128:       root_url:          String,
// 129:       license:           String,
// 130:       created_date:      String,
// 131:     ).returns(SPDXHash)
// 132:   }
// 133:   def self.bottle_package(formula_full_name, formula_name, version, tar_gz_sha256, root_url:, license:, created_date:)
// 134:     {
// 135:       "SPDXID"           => "SPDXRef-Bottle-#{formula_name}",
// 136:       "name"             => formula_name,
// 137:       "versionInfo"      => version.to_s,
// 138:       "filesAnalyzed"    => false,
// 139:       "licenseDeclared"  => "NOASSERTION",
// 140:       "builtDate"        => created_date,
// 141:       "licenseConcluded" => license.presence || "NOASSERTION",
// 142:       "downloadLocation" => "#{root_url}/#{GitHubPackages.image_formula_name(formula_name)}/" \
// 143:                             "blobs/sha256:#{tar_gz_sha256}",
// 144:       "copyrightText"    => "NOASSERTION",
// 145:       "externalRefs"     => [
// 146:         {
// 147:           "referenceCategory" => "PACKAGE-MANAGER",
// 148:           "referenceLocator"  => brew_purl(formula_full_name, version),
// 149:           "referenceType"     => "purl",
// 150:         },
// 151:       ],
// 152:       "checksums"        => [
// 153:         {
// 154:           "algorithm"     => "SHA256",
// 155:           "checksumValue" => tar_gz_sha256,
// 156:         },
// 157:       ],
// 158:     }
// 159:   end
// 160:   private_class_method :bottle_package
// 161:
// 162:   sig { params(full_name: String, version: T.nilable(T.any(String, Version))).returns(String) }
// 163:   def self.brew_purl(full_name, version)
// 164:     namespace, _, name = full_name.rpartition("/")
// 165:     Homebrew::Vulns::Purl.new(
// 166:       type:      "brew",
// 167:       namespace: namespace.presence,
// 168:       name:,
// 169:       version:   version&.to_s,
// 170:     ).to_s
// 171:   end
// 172:
// 173:   sig {
// 174:     params(
// 175:       spdxfile:         Pathname,
// 176:       homebrew_version: String,
// 177:       time:             Integer,
// 178:       supplement:       T.nilable(SPDXHash),
// 179:     ).void
// 180:   }
// 181:   def self.update_pour_metadata(spdxfile, homebrew_version:, time:, supplement: nil)
// 182:     return unless spdxfile.exist?
// 183:
// 184:     spdx = JSON.parse(spdxfile.read)
// 185:     return unless spdx.is_a?(Hash)
// 186:
// 187:     creation_info = spdx["creationInfo"]
// 188:     return unless creation_info.is_a?(Hash)
// 189:
// 190:     creation_info["created"] = Time.at(time).utc.iso8601
// 191:     creation_info["creators"] = ["Tool: https://github.com/Homebrew/brew@#{homebrew_version}"]
// 192:     merge_spdx_supplement(spdx, supplement) if supplement
// 193:     spdxfile.atomic_write(JSON.pretty_generate(spdx))
// 194:   rescue JSON::ParserError
// 195:     nil
// 196:   end
// 197:
// 198:   sig { returns(T::Hash[String, T.anything]) }
// 199:   def self.schema
// 200:     @schema ||= T.let(JSON.parse(SCHEMA_FILE.read, freeze: true), T.nilable(T::Hash[String, Object]))
// 201:   end
// 202:
// 203:   sig { params(data: T.nilable(T::Hash[Symbol, T.anything]), bottling: T::Boolean).returns(T::Array[String]) }
// 204:   def schema_validation_errors(data = nil, bottling: false)
// 205:     unless Homebrew.require? "json_schemer"
// 206:       error_message = "Need json_schemer to validate SBOM, run `brew install-bundler-gems --add-groups=bottle`!"
// 207:       odie error_message if ENV["HOMEBREW_ENFORCE_SBOM"]
// 208:       return []
// 209:     end
// 210:
// 211:     schemer = JSONSchemer.schema(SBOM.schema)
// 212:
// 213:     schemer.validate(data || to_spdx_sbom(bottling:)).map { |error| error["error"] }
// 214:   end
// 215:
// 216:   sig { params(data: T.nilable(T::Hash[Symbol, T.anything]), bottling: T::Boolean).returns(T::Boolean) }
// 217:   def valid?(data = nil, bottling: false)
// 218:     validation_errors = schema_validation_errors(data, bottling:)
// 219:     return true if validation_errors.empty?
// 220:
// 221:     opoo "SBOM validation errors:"
// 222:     validation_errors.each { |error| $stderr.puts error }
// 223:
// 224:     odie "Failed to validate SBOM against JSON schema!" if ENV["HOMEBREW_ENFORCE_SBOM"]
// 225:
// 226:     false
// 227:   end
// 228:
// 229:   sig { params(validate: T::Boolean, bottling: T::Boolean).void }
// 230:   def write(validate: true, bottling: false)
// 231:     # If this is a new installation, the cache of installed formulae
// 232:     # will no longer be valid.
// 233:     Formula.clear_cache unless spdxfile.exist?
// 234:
// 235:     spdx_sbom = to_spdx_sbom(bottling:)
// 236:
// 237:     if validate && !valid?(spdx_sbom, bottling:)
// 238:       opoo "SBOM is not valid, not writing to disk!"
// 239:       return
// 240:     end
// 241:
// 242:     spdxfile.atomic_write(JSON.pretty_generate(spdx_sbom))
// 243:   end
// 244:
// 245:   sig { params(bottling: T::Boolean).returns(T::Hash[Symbol, T.anything]) }
// 246:   def to_spdx_sbom(bottling: false)
// 247:     runtime_full = full_spdx_runtime_dependencies(bottling:)
// 248:     compiler_info = compiler_packages
// 249:     compiler_info = {} if bottling
// 250:
// 251:     packages = generate_packages_json(runtime_full, compiler_info, bottling:)
// 252:     files = generate_files_json
// 253:     {
// 254:       SPDXID:            "SPDXRef-DOCUMENT",
// 255:       spdxVersion:       "SPDX-2.3",
// 256:       name:              "SBOM-SPDX-#{name}-#{spec_version}",
// 257:       creationInfo:      {
// 258:         created:  source_modified_time.iso8601,
// 259:         creators: ["Tool: https://github.com/Homebrew/brew"],
// 260:       },
// 261:       dataLicense:       "CC0-1.0",
// 262:       documentNamespace: "https://formulae.brew.sh/spdx/#{name}-#{spec_version}.json",
// 263:       documentDescribes: packages.map { |dependency| dependency[:SPDXID] },
// 264:       files:,
// 265:       packages:,
// 266:       relationships:     generate_relations_json(runtime_full, compiler_info, bottling:),
// 267:     }
// 268:   end
// 269:
// 270:   sig { returns(SPDXHash) }
// 271:   def to_spdx_supplement
// 272:     runtime_full = full_spdx_runtime_dependencies(bottling: false)
// 273:     compiler_info = compiler_packages
// 274:     packages = runtime_full + compiler_info.values
// 275:     relationships = T.let([], T::Array[SPDXSymbolHash])
// 276:     runtime_full.each do |dependency|
// 277:       relationships << {
// 278:         spdxElementId:      dependency[:SPDXID],
// 279:         relationshipType:   "RUNTIME_DEPENDENCY_OF",
// 280:         relatedSpdxElement: bottle_spdx_id,
// 281:       }
// 282:     end
// 283:
// 284:     if compiler_info["SPDXRef-Compiler"].present?
// 285:       relationships << {
// 286:         spdxElementId:      "SPDXRef-Compiler",
// 287:         relationshipType:   "BUILD_TOOL_OF",
// 288:         relatedSpdxElement: "SPDXRef-Archive-#{name}-src",
// 289:       }
// 290:     end
// 291:
// 292:     if compiler_info["SPDXRef-Stdlib"].present?
// 293:       relationships << {
// 294:         spdxElementId:      "SPDXRef-Stdlib",
// 295:         relationshipType:   "DEPENDENCY_OF",
// 296:         relatedSpdxElement: bottle_spdx_id,
// 297:       }
// 298:     end
// 299:
// 300:     {
// 301:       "documentDescribes" => packages.map { |package| package[:SPDXID] },
// 302:       "packages"          => packages,
// 303:       "relationships"     => relationships,
// 304:     }
// 305:   end
// 306:
// 307:   private
// 308:
// 309:   sig { params(spdx: SPDXHash, supplement: SPDXHash).void }
// 310:   def self.merge_spdx_supplement(spdx, supplement)
// 311:     ["documentDescribes", "packages", "relationships"].each do |key|
// 312:       spdx_value = spdx[key]
// 313:       supplement_value = supplement[key]
// 314:       next if !spdx_value.is_a?(Array) || !supplement_value.is_a?(Array)
// 315:
// 316:       spdx_value.concat(supplement_value)
// 317:     end
// 318:   end
// 319:   private_class_method :merge_spdx_supplement
// 320:
// 321:   sig {
// 322:     params(
// 323:       supplement:     T.nilable(SPDXHash),
// 324:       bottle_package: SPDXHash,
// 325:     ).returns(T.nilable(SPDXHash))
// 326:   }
// 327:   def self.add_bottle_package_to_supplement(supplement, bottle_package)
// 328:     return if supplement.nil?
// 329:
// 330:     if (tags = supplement["tags"]).is_a?(Hash)
// 331:       tag_supplements = tags.filter_map do |tag, tag_supplement|
// 332:         next if !tag.is_a?(String) || !tag_supplement.is_a?(Hash)
// 333:
// 334:         [tag, add_bottle_package_to_supplement(tag_supplement, bottle_package)]
// 335:       end.to_h.compact
// 336:       return { "tags" => tag_supplements } if tag_supplements.present?
// 337:     end
// 338:
// 339:     packages = supplement["packages"]
// 340:     return unless packages.is_a?(Array)
// 341:
// 342:     document_describes = supplement["documentDescribes"]
// 343:     relationships = supplement["relationships"]
// 344:     document_describes += [bottle_package.fetch("SPDXID")] if document_describes.is_a?(Array)
// 345:     {
// 346:       "documentDescribes" => document_describes.is_a?(Array) ? document_describes : [],
// 347:       "packages"          => packages + [bottle_package],
// 348:       "relationships"     => relationships.is_a?(Array) ? relationships : [],
// 349:     }
// 350:   end
// 351:   private_class_method :add_bottle_package_to_supplement
// 352:
// 353:   sig { returns(String) }
// 354:   attr_reader :name
// 355:
// 356:   sig { returns(T.nilable(T.any(String, Symbol))) }
// 357:   attr_reader :stdlib
// 358:
// 359:   sig { returns(Source) }
// 360:   attr_reader :source
// 361:
// 362:   sig { returns(T::Hash[String, T.nilable(String)]) }
// 363:   attr_reader :built_on
// 364:
// 365:   sig { returns(T.nilable(String)) }
// 366:   attr_reader :license
// 367:
// 368:   sig { returns(Pathname) }
// 369:   attr_accessor :spdxfile
// 370:
// 371:   sig {
// 372:     params(
// 373:       name:                 String,
// 374:       spdxfile:             Pathname,
// 375:       source_modified_time: Integer,
// 376:       compiler:             T.any(String, Symbol),
// 377:       stdlib:               T.nilable(T.any(String, Symbol)),
// 378:       runtime_dependencies: T::Array[T::Hash[String, Object]],
// 379:       license:              T.nilable(String),
// 380:       built_on:             T::Hash[String, T.nilable(String)],
// 381:       source:               Source,
// 382:     ).void
// 383:   }
// 384:   def initialize(name:, spdxfile:, source_modified_time:, compiler:, stdlib:, runtime_dependencies:,
// 385:                  license:, built_on:, source:)
// 386:     @name = name
// 387:     @spdxfile = spdxfile
// 388:     @source_modified_time = source_modified_time
// 389:     @compiler = compiler
// 390:     @stdlib = stdlib
// 391:     @runtime_dependencies = runtime_dependencies
// 392:     @license = license
// 393:     @built_on = built_on
// 394:     @source = source
// 395:   end
// 396:
// 397:   sig { returns(T::Hash[String, SPDXSymbolHash]) }
// 398:   def compiler_packages
// 399:     packages = {
// 400:       "SPDXRef-Compiler" => {
// 401:         SPDXID:           "SPDXRef-Compiler",
// 402:         name:             compiler.to_s,
// 403:         versionInfo:      assert_value(built_on["xcode"]),
// 404:         filesAnalyzed:    false,
// 405:         licenseDeclared:  assert_value(nil),
// 406:         licenseConcluded: assert_value(nil),
// 407:         copyrightText:    assert_value(nil),
// 408:         downloadLocation: assert_value(nil),
// 409:         checksums:        [],
// 410:         externalRefs:     [],
// 411:       },
// 412:     }
// 413:
// 414:     if stdlib.present?
// 415:       packages["SPDXRef-Stdlib"] = {
// 416:         SPDXID:           "SPDXRef-Stdlib",
// 417:         name:             stdlib.to_s,
// 418:         versionInfo:      stdlib.to_s,
// 419:         filesAnalyzed:    false,
// 420:         licenseDeclared:  assert_value(nil),
// 421:         licenseConcluded: assert_value(nil),
// 422:         copyrightText:    assert_value(nil),
// 423:         downloadLocation: assert_value(nil),
// 424:         checksums:        [],
// 425:         externalRefs:     [],
// 426:       }
// 427:     end
// 428:
// 429:     packages
// 430:   end
// 431:
// 432:   sig {
// 433:     params(
// 434:       runtime_dependency_declaration: T::Array[SPDXSymbolHash],
// 435:       compiler_declaration:           T::Hash[String, Object],
// 436:       bottling:                       T::Boolean,
// 437:     ).returns(T::Array[SPDXSymbolHash])
// 438:   }
// 439:   def generate_relations_json(runtime_dependency_declaration, compiler_declaration, bottling:)
// 440:     runtime = runtime_dependency_declaration.map do |dependency|
// 441:       {
// 442:         spdxElementId:      dependency[:SPDXID],
// 443:         relationshipType:   "RUNTIME_DEPENDENCY_OF",
// 444:         relatedSpdxElement: described_package_spdx_id(bottling:),
// 445:       }
// 446:     end
// 447:
// 448:     patches = source.patches.each_with_index.filter_map do |patch, index|
// 449:       next unless patch.is_a?(ExternalPatch)
// 450:
// 451:       {
// 452:         spdxElementId:      "SPDXRef-Patch-#{name}-#{index}",
// 453:         relationshipType:   "PATCH_APPLIED",
// 454:         relatedSpdxElement: "SPDXRef-Archive-#{name}-src",
// 455:       }
// 456:     end
// 457:
// 458:     base = T.let([], T::Array[SPDXSymbolHash])
// 459:
// 460:     if source.checksum.present?
// 461:       base << {
// 462:         spdxElementId:      "SPDXRef-File-#{name}",
// 463:         relationshipType:   "PACKAGE_OF",
// 464:         relatedSpdxElement: "SPDXRef-Archive-#{name}-src",
// 465:       }
// 466:     end
// 467:
// 468:     unless bottling
// 469:       base << {
// 470:         spdxElementId:      "SPDXRef-Compiler",
// 471:         relationshipType:   "BUILD_TOOL_OF",
// 472:         relatedSpdxElement: "SPDXRef-Archive-#{name}-src",
// 473:       }
// 474:
// 475:       if compiler_declaration["SPDXRef-Stdlib"].present?
// 476:         base << {
// 477:           spdxElementId:      "SPDXRef-Stdlib",
// 478:           relationshipType:   "DEPENDENCY_OF",
// 479:           relatedSpdxElement: described_package_spdx_id(bottling:),
// 480:         }
// 481:       end
// 482:     end
// 483:
// 484:     runtime + patches + base
// 485:   end
// 486:
// 487:   sig {
// 488:     params(
// 489:       runtime_dependency_declaration: T::Array[SPDXSymbolHash],
// 490:       compiler_declaration:           T::Hash[String, SPDXSymbolHash],
// 491:       bottling:                       T::Boolean,
// 492:     ).returns(T::Array[SPDXSymbolHash])
// 493:   }
// 494:   def generate_packages_json(runtime_dependency_declaration, compiler_declaration, bottling:)
// 495:     bottle = []
// 496:     if bottle_package?(bottling:) &&
// 497:        (bottle_info = get_bottle_info(source.bottle)) &&
// 498:        (stable_version = source.version)
// 499:       bottle << {
// 500:         SPDXID:           "SPDXRef-Bottle-#{name}",
// 501:         name:             name.to_s,
// 502:         versionInfo:      stable_version.to_s,
// 503:         filesAnalyzed:    false,
// 504:         licenseDeclared:  assert_value(nil),
// 505:         builtDate:        source_modified_time.iso8601,
// 506:         licenseConcluded: assert_value(license),
// 507:         downloadLocation: bottle_info.fetch("url"),
// 508:         copyrightText:    assert_value(nil),
// 509:         externalRefs:     [
// 510:           {
// 511:             referenceCategory: "PACKAGE-MANAGER",
// 512:             referenceLocator:  SBOM.brew_purl([source.tap_name, name].compact.join("/"), stable_version),
// 513:             referenceType:     "purl",
// 514:           },
// 515:         ],
// 516:         checksums:        [
// 517:           {
// 518:             algorithm:     "SHA256",
// 519:             checksumValue: bottle_info.fetch("sha256"),
// 520:           },
// 521:         ],
// 522:       }
// 523:     end
// 524:
// 525:     patches = source.patches.each_with_index.filter_map do |patch, index|
// 526:       next unless patch.is_a?(ExternalPatch)
// 527:
// 528:       package = {
// 529:         SPDXID:           "SPDXRef-Patch-#{name}-#{index}",
// 530:         name:             "#{name} patch #{index}",
// 531:         filesAnalyzed:    false,
// 532:         licenseDeclared:  assert_value(nil),
// 533:         licenseConcluded: assert_value(nil),
// 534:         downloadLocation: assert_value(patch.url),
// 535:         copyrightText:    assert_value(nil),
// 536:         checksums:        [],
// 537:         externalRefs:     [],
// 538:       }
// 539:       if (checksum = patch.resource.checksum)
// 540:         package[:checksums] = [
// 541:           {
// 542:             algorithm:     "SHA256",
// 543:             checksumValue: checksum.hexdigest,
// 544:           },
// 545:         ]
// 546:       end
// 547:       package
// 548:     end
// 549:
// 550:     source_purl = SBOM.brew_purl([source.tap_name, name].compact.join("/"), spec_version)
// 551:
// 552:     external_refs = T.let([
// 553:       {
// 554:         referenceCategory: "PACKAGE-MANAGER",
// 555:         referenceLocator:  source_purl,
// 556:         referenceType:     "purl",
// 557:       },
// 558:     ], T::Array[SPDXSymbolHash])
// 559:
// 560:     if (registry_pkg = Homebrew::Vulns::Identify.registry_package(source.url))
// 561:       external_refs << {
// 562:         referenceCategory: "PACKAGE-MANAGER",
// 563:         referenceLocator:  registry_pkg.purl,
// 564:         referenceType:     "purl",
// 565:       }
// 566:     end
// 567:
// 568:     [
// 569:       {
// 570:         SPDXID:           "SPDXRef-Archive-#{name}-src",
// 571:         name:             name.to_s,
// 572:         versionInfo:      spec_version.to_s,
// 573:         filesAnalyzed:    false,
// 574:         licenseDeclared:  assert_value(nil),
// 575:         builtDate:        source_modified_time.iso8601,
// 576:         licenseConcluded: assert_value(license),
// 577:         downloadLocation: source.url,
// 578:         copyrightText:    assert_value(nil),
// 579:         externalRefs:     external_refs,
// 580:         checksums:        [
// 581:           {
// 582:             algorithm:     "SHA256",
// 583:             checksumValue: source.checksum.to_s,
// 584:           },
// 585:         ],
// 586:       },
// 587:     ] + patches + runtime_dependency_declaration + compiler_declaration.values + bottle
// 588:   end
// 589:
// 590:   sig { returns(T::Array[SPDXSymbolHash]) }
// 591:   def generate_files_json
// 592:     checksum = source.checksum
// 593:     return [] unless checksum
// 594:
// 595:     [
// 596:       {
// 597:         SPDXID:    "SPDXRef-File-#{name}",
// 598:         fileName:  source.url.to_s.split("/").last.presence || "#{name}-#{spec_version}",
// 599:         checksums: [
// 600:           {
// 601:             algorithm:     "SHA256",
// 602:             checksumValue: checksum.hexdigest,
// 603:           },
// 604:         ],
// 605:       },
// 606:     ]
// 607:   end
// 608:
// 609:   sig {
// 610:     params(bottling: T::Boolean).returns(T::Array[SPDXSymbolHash])
// 611:   }
// 612:   def full_spdx_runtime_dependencies(bottling:)
// 613:     return [] if bottling || @runtime_dependencies.blank?
// 614:
// 615:     @runtime_dependencies.compact.filter_map do |dependency|
// 616:       next unless dependency.present?
// 617:
// 618:       dependency_bottle = dependency["bottle"]
// 619:       next unless dependency_bottle.is_a?(Hash)
// 620:
// 621:       bottle_info = get_bottle_info(dependency_bottle)
// 622:       next unless bottle_info.present?
// 623:
// 624:       dependency_name = dependency.fetch("name").to_s
// 625:       dependency_pkg_version = dependency.fetch("pkg_version").to_s
// 626:       dependency_formula_pkg_version = dependency.fetch("formula_pkg_version").to_s
// 627:
// 628:       # Only set bottle URL if the dependency is the same version as the formula/bottle.
// 629:       bottle_url = bottle_info["url"] if dependency_pkg_version == dependency_formula_pkg_version
// 630:
// 631:       dependency_json = {
// 632:         SPDXID:           "SPDXRef-Package-SPDXRef-#{dependency_name.tr("/", "-")}-#{dependency_pkg_version}",
// 633:         name:             dependency_name,
// 634:         versionInfo:      dependency_pkg_version,
// 635:         filesAnalyzed:    false,
// 636:         licenseDeclared:  assert_value(nil),
// 637:         licenseConcluded: assert_value(dependency["license"]),
// 638:         downloadLocation: assert_value(bottle_url),
// 639:         copyrightText:    assert_value(nil),
// 640:         checksums:        [
// 641:           {
// 642:             algorithm:     "SHA256",
// 643:             checksumValue: assert_value(bottle_info["sha256"]),
// 644:           },
// 645:         ],
// 646:         externalRefs:     [
// 647:           {
// 648:             referenceCategory: "PACKAGE-MANAGER",
// 649:             referenceLocator:  SBOM.brew_purl(dependency.fetch("full_name").to_s, dependency_pkg_version),
// 650:             referenceType:     "purl",
// 651:           },
// 652:         ],
// 653:       }
// 654:       dependency_json
// 655:     end
// 656:   end
// 657:
// 658:   sig { params(base: T.nilable(T::Hash[String, Object])).returns(T.nilable(T::Hash[String, String])) }
// 659:   def get_bottle_info(base)
// 660:     return unless base.present?
// 661:
// 662:     files = base["files"]
// 663:     return unless files.is_a?(Hash)
// 664:
// 665:     bottle_info = files[Utils::Bottles.tag.to_sym] || files[:all]
// 666:     return unless bottle_info.is_a?(Hash)
// 667:
// 668:     bottle_info.to_h { |key, value| [key.to_s, value.to_s] }
// 669:   end
// 670:
// 671:   sig { params(bottling: T::Boolean).returns(T::Boolean) }
// 672:   def bottle_package?(bottling:)
// 673:     !bottling && get_bottle_info(source.bottle).present? && spec_symbol == :stable && source.version.present?
// 674:   end
// 675:
// 676:   sig { params(bottling: T::Boolean).returns(String) }
// 677:   def described_package_spdx_id(bottling:)
// 678:     if bottle_package?(bottling:)
// 679:       bottle_spdx_id
// 680:     else
// 681:       "SPDXRef-Archive-#{name}-src"
// 682:     end
// 683:   end
// 684:
// 685:   sig { returns(String) }
// 686:   def bottle_spdx_id
// 687:     "SPDXRef-Bottle-#{name}"
// 688:   end
// 689:
// 690:   sig { returns(Symbol) }
// 691:   def compiler
// 692:     @compiler.presence&.to_sym || DevelopmentTools.default_compiler
// 693:   end
// 694:
// 695:   sig { returns(T.nilable(Tap)) }
// 696:   def tap
// 697:     tap_name = source.tap_name
// 698:     Tap.fetch(tap_name) if tap_name
// 699:   end
// 700:
// 701:   sig { returns(Symbol) }
// 702:   def spec_symbol
// 703:     source.spec
// 704:   end
// 705:
// 706:   sig { returns(T.nilable(Version)) }
// 707:   def spec_version
// 708:     source.version
// 709:   end
// 710:
// 711:   sig { returns(Time) }
// 712:   def source_modified_time
// 713:     Time.at(@source_modified_time).utc
// 714:   end
// 715:
// 716:   sig { params(val: Object).returns(String) }
// 717:   def assert_value(val)
// 718:     return :NOASSERTION.to_s unless val.present?
// 719:
// 720:     val.to_s
// 721:   end
// 722: end
