module api

import ruby

// Translated from Homebrew/brew `api/cask_struct.rb`.
pub const cask_struct_predicate_names = ['auto_updates', 'caveats', 'conflicts', 'container',
	'depends_on', 'deprecate', 'desc', 'disable', 'homepage']

pub struct CaskStructPredicates {
pub:
	auto_updates bool
	caveats      bool
	conflicts    bool
	container    bool
	depends_on   bool
	deprecate    bool
	desc         bool
	disable      bool
	homepage     bool
}

pub struct CaskArtifact {
pub:
	key       string
	args      []ruby.Value
	kwargs    map[string]ruby.Value
	has_block bool
}

pub struct CaskLanguageVariation {
pub:
	languages  []string
	value      string
	is_default bool
	overrides  map[string]ruby.Value
}

pub struct CaskStruct {
pub:
	auto_updates         bool
	caveats_rosetta      bool
	conflicts_with_args  map[string]ruby.Value
	container_args       map[string]ruby.Value
	depends_on_args      map[string]ruby.Value
	deprecate_args       map[string]ruby.Value
	desc                 ?string
	disable_args         map[string]ruby.Value
	homepage             ?string
	languages            []string
	language_variations  []CaskLanguageVariation
	names                []string
	renames              [][]string
	ruby_source_checksum map[string]ruby.Value
	ruby_source_path     ?string
	sha256               string
	tap_string           ?string
	url_args             []string
	url_kwargs           map[string]ruby.Value
	version              string
	raw_artifacts        []CaskArtifact
	raw_caveats          ?string
	predicates           CaskStructPredicates
}

pub fn cask_struct_predicate(cask CaskStruct, name string) bool {
	return match name.trim_right('?') {
		'auto_updates' { cask.predicates.auto_updates }
		'caveats' { cask.predicates.caveats }
		'conflicts' { cask.predicates.conflicts }
		'container' { cask.predicates.container }
		'depends_on' { cask.predicates.depends_on }
		'deprecate' { cask.predicates.deprecate }
		'desc' { cask.predicates.desc }
		'disable' { cask.predicates.disable }
		'homepage' { cask.predicates.homepage }
		else { false }
	}
}

pub fn (cask CaskStruct) predicate(name string) bool {
	return cask_struct_predicate(cask, name)
}

pub fn cask_struct_from_hash(hash map[string]ruby.Value, paths ApiStructPaths,
	ignore_types bool) CaskStruct {
	cleaned := if ignore_types {
		hash.clone()
	} else {
		api_struct_replace_map(hash, paths, paths.appdir)
	}
	return CaskStruct{
		auto_updates: api_struct_bool(cleaned['auto_updates'] or { ruby.bool_value(false) })
		caveats_rosetta: api_struct_bool(cleaned['caveats_rosetta'] or { ruby.bool_value(false) })
		conflicts_with_args: api_struct_value_map(cleaned['conflicts_with_args'] or { ruby.map_value({}) })
		container_args: api_struct_value_map(cleaned['container_args'] or { ruby.map_value({}) })
		depends_on_args: api_struct_value_map(cleaned['depends_on_args'] or { ruby.map_value({}) })
		deprecate_args: api_struct_value_map(cleaned['deprecate_args'] or { ruby.map_value({}) })
		desc: api_struct_optional_string(cleaned['desc'] or { api_struct_nil_value() })
		disable_args: api_struct_value_map(cleaned['disable_args'] or { ruby.map_value({}) })
		homepage: api_struct_optional_string(cleaned['homepage'] or { api_struct_nil_value() })
		languages: api_struct_string_array(cleaned['languages'] or { ruby.string_array_value([]) })
		language_variations: cask_language_variations_from_value(cleaned['language_variations'] or {
			ruby.array_value([])
		})
		names: api_struct_string_array(cleaned['names'] or { ruby.string_array_value([]) })
		renames: cask_renames_from_value(cleaned['renames'] or { ruby.array_value([]) })
		ruby_source_checksum: api_struct_value_map(cleaned['ruby_source_checksum'] or {
			ruby.map_value({
				'sha256': api_struct_nil_value()
			})
		})
		ruby_source_path: api_struct_optional_string(cleaned['ruby_source_path'] or { api_struct_nil_value() })
		sha256: api_struct_string(cleaned['sha256'] or { ruby.string_value('') })
		tap_string: api_struct_optional_string(cleaned['tap_string'] or { api_struct_nil_value() })
		url_args: api_struct_string_array(cleaned['url_args'] or { ruby.string_array_value([]) })
		url_kwargs: api_struct_value_map(cleaned['url_kwargs'] or { ruby.map_value({}) })
		version: api_struct_string(cleaned['version'] or { ruby.string_value('') })
		raw_artifacts: cask_artifacts_from_value(cleaned['raw_artifacts'] or { ruby.array_value([]) })
		raw_caveats: api_struct_optional_string(cleaned['raw_caveats'] or { api_struct_nil_value() })
		predicates: cask_struct_predicates_from_hash(cleaned)
	}
}

fn cask_struct_predicates_from_hash(hash map[string]ruby.Value) CaskStructPredicates {
	return CaskStructPredicates{
		auto_updates: api_struct_hash_bool(hash, 'auto_updates_present')
		caveats: api_struct_hash_bool(hash, 'caveats_present')
		conflicts: api_struct_hash_bool(hash, 'conflicts_present')
		container: api_struct_hash_bool(hash, 'container_present')
		depends_on: api_struct_hash_bool(hash, 'depends_on_present')
		deprecate: api_struct_hash_bool(hash, 'deprecate_present')
		desc: api_struct_hash_bool(hash, 'desc_present')
		disable: api_struct_hash_bool(hash, 'disable_present')
		homepage: api_struct_hash_bool(hash, 'homepage_present')
	}
}

pub fn (cask CaskStruct) equals(other CaskStruct) bool {
	return api_struct_maps_equal(cask.serialize(), other.serialize())
}

pub fn (cask CaskStruct) artifacts(appdir string, paths ApiStructPaths) []CaskArtifact {
	return cask.raw_artifacts.map(CaskArtifact{
		key: it.key
		args: it.args.map(api_struct_deep_replace(it, paths, appdir))
		kwargs: cask_replace_kwargs(it.kwargs, paths, appdir)
		has_block: it.has_block
	})
}

fn cask_replace_kwargs(kwargs map[string]ruby.Value, paths ApiStructPaths,
	appdir string) map[string]ruby.Value {
	mut replaced := map[string]ruby.Value{}
	for key, value in kwargs {
		replaced[key] = api_struct_deep_replace(value, paths, appdir)
	}
	return replaced
}

pub fn (cask CaskStruct) caveats(appdir string, paths ApiStructPaths) ?string {
	value := cask.raw_caveats or { return none }
	return api_struct_deep_replace(ruby.string_value(value), paths, appdir).as_string()
}

pub fn (cask CaskStruct) localise(languages []string, paths ApiStructPaths) CaskStruct {
	variation := cask.language_variation(languages) or { return cask }
	if variation.overrides.len == 0 {
		return cask
	}
	mut serialized := cask.serialize()
	for key, value in variation.overrides {
		serialized[key.trim_string_left(':')] = value
	}
	return cask_struct_deserialize(serialized, paths)
}

pub fn (cask CaskStruct) language(languages []string) ?string {
	variation := cask.language_variation(languages) or { return none }
	return if variation.value == '' { none } else { variation.value }
}

pub fn (cask CaskStruct) serialize() map[string]ruby.Value {
	mut hash := map[string]ruby.Value{}
	api_struct_put_nonblank(mut hash, 'auto_updates', ruby.bool_value(cask.auto_updates))
	api_struct_put_nonblank(mut hash, 'caveats_rosetta', ruby.bool_value(cask.caveats_rosetta))
	api_struct_put_nonblank(mut hash, 'conflicts_with_args', ruby.map_value(cask.conflicts_with_args))
	api_struct_put_nonblank(mut hash, 'container_args', ruby.map_value(cask.container_args))
	api_struct_put_nonblank(mut hash, 'depends_on_args', ruby.map_value(cask.depends_on_args))
	api_struct_put_nonblank(mut hash, 'deprecate_args', ruby.map_value(cask.deprecate_args))
	if desc := cask.desc {
		api_struct_put_nonblank(mut hash, 'desc', ruby.string_value(desc))
	}
	api_struct_put_nonblank(mut hash, 'disable_args', ruby.map_value(cask.disable_args))
	if homepage := cask.homepage {
		api_struct_put_nonblank(mut hash, 'homepage', ruby.string_value(homepage))
	}
	api_struct_put_nonblank(mut hash, 'languages', ruby.string_array_value(cask.languages))
	api_struct_put_nonblank(mut hash, 'language_variations', cask_language_variations_value(cask.language_variations))
	api_struct_put_nonblank(mut hash, 'names', ruby.string_array_value(cask.names))
	api_struct_put_nonblank(mut hash, 'renames', cask_renames_value(cask.renames))
	api_struct_put_nonblank(mut hash, 'ruby_source_checksum', ruby.map_value(cask.ruby_source_checksum))
	if path := cask.ruby_source_path {
		api_struct_put_nonblank(mut hash, 'ruby_source_path', ruby.string_value(path))
	}
	api_struct_put_nonblank(mut hash, 'sha256', ruby.string_value(cask.sha256))
	if tap := cask.tap_string {
		api_struct_put_nonblank(mut hash, 'tap_string', ruby.string_value(tap))
	}
	api_struct_put_nonblank(mut hash, 'url_args', ruby.string_array_value(cask.url_args))
	api_struct_put_nonblank(mut hash, 'url_kwargs', ruby.map_value(cask.url_kwargs))
	api_struct_put_nonblank(mut hash, 'version', ruby.string_value(cask.version))
	if cask.raw_artifacts.len > 0 {
		hash['raw_artifacts'] = ruby.array_value(cask.raw_artifacts.map(ruby.array_value(cask.serialize_artifact_args(it))))
	}
	if caveats := cask.raw_caveats {
		api_struct_put_nonblank(mut hash, 'raw_caveats', ruby.string_value(caveats))
	}
	return hash
}

pub fn cask_struct_deserialize(hash map[string]ruby.Value,
	paths ApiStructPaths) CaskStruct {
	mut restored := hash.clone()
	for name in cask_struct_predicate_names {
		source := match name {
			'auto_updates' { restored['auto_updates'] or { ruby.bool_value(false) } }
			'caveats' { restored['raw_caveats'] or { api_struct_nil_value() } }
			'conflicts' { restored['conflicts_with_args'] or { api_struct_nil_value() } }
			'desc' { restored['desc'] or { api_struct_nil_value() } }
			'homepage' { restored['homepage'] or { api_struct_nil_value() } }
			else { restored['${name}_args'] or { api_struct_nil_value() } }
		}
		restored['${name}_present'] = ruby.bool_value(api_struct_value_present(source))
	}
	return cask_struct_from_hash(restored, paths, false)
}

pub fn (cask CaskStruct) serialize_artifact_args(artifact CaskArtifact) []ruby.Value {
	mut values := [ruby.object_value('Symbol', ':${artifact.key}')]
	if artifact.args.len > 0 {
		values << ruby.array_value(artifact.args)
	}
	if artifact.kwargs.len > 0 {
		values << ruby.map_value(artifact.kwargs)
	}
	if artifact.has_block {
		values << ruby.object_value('Symbol', ':empty_block')
	}
	return values
}

pub fn cask_struct_deserialize_artifact_args(values []ruby.Value) CaskArtifact {
	mut artifact := CaskArtifact{
		key: api_struct_normalize_symbol(values[0] or { ruby.string_value('') }.as_string())
	}
	for value in values[1..] {
		if value.type_name == 'Array' {
			artifact = CaskArtifact{
				...artifact
				args: api_struct_value_array(value)
			}
		} else if value.type_name == 'Hash' {
			artifact = CaskArtifact{
				...artifact
				kwargs: api_struct_value_map(value)
			}
		} else if api_struct_normalize_symbol(value.as_string()) == 'empty_block' {
			artifact = CaskArtifact{
				...artifact
				has_block: true
			}
		}
	}
	return artifact
}

pub fn (cask CaskStruct) language_variation(languages []string) ?CaskLanguageVariation {
	for language in languages {
		for variation in cask.language_variations {
			if variation.languages.any(cask_locale_matches(language, it)) {
				return variation
			}
		}
	}
	for variation in cask.language_variations {
		if variation.is_default {
			return variation
		}
	}
	return none
}

fn cask_locale_matches(locale string, component string) bool {
	parts := locale.split('-')
	if component.len in [2, 3] && component.to_lower() == component {
		return parts.len > 0 && parts[0] == component
	}
	if component.len == 4 {
		return component in parts
	}
	if (component.len == 2 && component.to_upper() == component) || (component.len == 3 && component.bytes().all(it >= `0` && it <= `9`)) {
		return component in parts
	}
	return locale == component
}

pub fn cask_struct_deep_remove_placeholders(value ruby.Value, appdir string,
	paths ApiStructPaths) ruby.Value {
	return api_struct_deep_replace(value, paths, appdir)
}

fn cask_artifacts_from_value(value ruby.Value) []CaskArtifact {
	return api_struct_value_array(value).map(cask_struct_deserialize_artifact_args(api_struct_value_array(it)))
}

fn cask_language_variations_from_value(value ruby.Value) []CaskLanguageVariation {
	return api_struct_value_array(value).map(fn (item ruby.Value) CaskLanguageVariation {
		variation := api_struct_value_map(item)
		return CaskLanguageVariation{
			languages: api_struct_string_array(variation['languages'] or { ruby.string_array_value([]) })
			value: api_struct_string(variation['value'] or { ruby.string_value('') })
			is_default: api_struct_bool(variation['default'] or { ruby.bool_value(false) })
			overrides: api_struct_value_map(variation['overrides'] or { ruby.map_value({}) })
		}
	})
}

fn cask_language_variations_value(variations []CaskLanguageVariation) ruby.Value {
	return ruby.array_value(variations.map(ruby.map_value({
		'languages': ruby.string_array_value(it.languages)
		'value':     ruby.string_value(it.value)
		'default':   ruby.bool_value(it.is_default)
		'overrides': ruby.map_value(it.overrides)
	})))
}

fn cask_renames_from_value(value ruby.Value) [][]string {
	return api_struct_value_array(value).map(api_struct_string_array(it))
}

fn cask_renames_value(renames [][]string) ruby.Value {
	return ruby.array_value(renames.map(ruby.string_array_value(it)))
}
