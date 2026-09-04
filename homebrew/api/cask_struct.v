module api

import ruby

// Translated from Homebrew/brew `api/cask_struct.rb`.
// The original source is retained below until every stub has a typed V body.
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
			ruby.array_value([])})
		names: api_struct_string_array(cleaned['names'] or { ruby.string_array_value([]) })
		renames: cask_renames_from_value(cleaned['renames'] or { ruby.array_value([]) })
		ruby_source_checksum: api_struct_value_map(cleaned['ruby_source_checksum'] or {
			ruby.map_value({
				'sha256': api_struct_nil_value()
			})})
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

// Ruby method `self.from_hash(cask_hash, ignore_types: false)` at line 11.
pub fn ruby_cask_struct_l11_d1_self_from_hash(hash map[string]ruby.Value,
	paths ApiStructPaths, ignore_types bool) CaskStruct {
	return cask_struct_from_hash(hash, paths, ignore_types)
}

// Ruby define_method `define_method(predicate_method_name) do` at line 53.
pub fn ruby_cask_struct_l53_d2_predicate_method_name(cask CaskStruct, name string) bool {
	return cask_struct_predicate(cask, name)
}

// Ruby method `==(other)` at line 98.
pub fn ruby_cask_struct_l98_d3_anonymous(cask CaskStruct, other CaskStruct) bool {
	return cask.equals(other)
}

// Ruby method `artifacts(appdir:)` at line 108.
pub fn ruby_cask_struct_l108_d4_artifacts(cask CaskStruct, appdir string,
	paths ApiStructPaths) []CaskArtifact {
	return cask.artifacts(appdir, paths)
}

// Ruby method `caveats(appdir:)` at line 113.
pub fn ruby_cask_struct_l113_d5_caveats(cask CaskStruct, appdir string,
	paths ApiStructPaths) ?string {
	return cask.caveats(appdir, paths)
}

// Ruby method `localise(languages)` at line 118.
pub fn ruby_cask_struct_l118_d6_localise(cask CaskStruct, languages []string,
	paths ApiStructPaths) CaskStruct {
	return cask.localise(languages, paths)
}

// Ruby method `language(languages)` at line 130.
pub fn ruby_cask_struct_l130_d7_language(cask CaskStruct, languages []string) ?string {
	return cask.language(languages)
}

// Ruby method `serialize` at line 135.
pub fn ruby_cask_struct_l135_d8_serialize(cask CaskStruct) map[string]ruby.Value {
	return cask.serialize()
}

// Ruby method `self.deserialize(hash)` at line 154.
pub fn ruby_cask_struct_l154_d9_self_deserialize(hash map[string]ruby.Value,
	paths ApiStructPaths) CaskStruct {
	return cask_struct_deserialize(hash, paths)
}

// Ruby method `serialize_artifact_args(artifact)` at line 178.
pub fn ruby_cask_struct_l178_d10_serialize_artifact_args(cask CaskStruct,
	artifact CaskArtifact) []ruby.Value {
	return cask.serialize_artifact_args(artifact)
}

// Ruby method `self.deserialize_artifact_args(args)` at line 202.
pub fn ruby_cask_struct_l202_d11_self_deserialize_artifact_args(values []ruby.Value) CaskArtifact {
	return cask_struct_deserialize_artifact_args(values)
}

// Ruby method `language_variation(languages)` at line 221.
pub fn ruby_cask_struct_l221_d12_language_variation(cask CaskStruct,
	languages []string) ?CaskLanguageVariation {
	return cask.language_variation(languages)
}

// Ruby method `deep_remove_placeholders(value, appdir)` at line 253.
pub fn ruby_cask_struct_l253_d13_deep_remove_placeholders(value ruby.Value,
	appdir string, paths ApiStructPaths) ruby.Value {
	return cask_struct_deep_remove_placeholders(value, appdir, paths)
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "locale"
// 5:
// 6: module Homebrew
// 7:   module API
// 8:     # Typed representation of cask API data.
// 9:     class CaskStruct < T::Struct
// 10:       sig { params(cask_hash: T::Hash[String, T.untyped], ignore_types: T::Boolean).returns(CaskStruct) }
// 11:       def self.from_hash(cask_hash, ignore_types: false)
// 12:         return super(cask_hash) if ignore_types
// 13:
// 14:         cask_hash = ::Cask::Cask.deep_remove_placeholders(cask_hash)
// 15:         cask_hash = cask_hash.transform_keys(&:to_sym)
// 16:                              .slice(*decorator.all_props)
// 17:                              .compact_blank
// 18:         new(**cask_hash)
// 19:       end
// 20:
// 21:       PREDICATES = [
// 22:         :auto_updates,
// 23:         :caveats,
// 24:         :conflicts,
// 25:         :container,
// 26:         :depends_on,
// 27:         :deprecate,
// 28:         :desc,
// 29:         :disable,
// 30:         :homepage,
// 31:       ].freeze
// 32:
// 33:       EMPTY_BLOCK = T.let(-> {}.freeze, T.proc.void)
// 34:       EMPTY_BLOCK_PLACEHOLDER = :empty_block
// 35:
// 36:       ArtifactArgs = T.type_alias do
// 37:         [
// 38:           Symbol,
// 39:           T::Array[T.anything],
// 40:           T::Hash[Symbol, T.anything],
// 41:           T.nilable(T.proc.void),
// 42:         ]
// 43:       end
// 44:
// 45:       LanguageVariation = T.type_alias { T::Hash[Symbol, T.anything] }
// 46:
// 47:       PREDICATES.each do |predicate_name|
// 48:         present_method_name = :"#{predicate_name}_present"
// 49:         predicate_method_name = :"#{predicate_name}?"
// 50:
// 51:         const present_method_name, T::Boolean, default: false
// 52:
// 53:         define_method(predicate_method_name) do
// 54:           send(present_method_name)
// 55:         end
// 56:       end
// 57:
// 58:       DependsOnArgs = T.type_alias do
// 59:         T::Hash[
// 60:           # Keys are dependency types like :macos, :arch, :cask, :formula
// 61:           Symbol,
// 62:           # Values can be any of:
// 63:           T.any(
// 64:             # Strings like ">= :catalina" for :macos
// 65:             String,
// 66:             # Symbols like :intel or :arm64 for :arch
// 67:             Symbol,
// 68:             # Array of strings or symbols for :cask and :formula
// 69:             T::Array[T.any(String, Symbol)],
// 70:           ),
// 71:         ]
// 72:       end
// 73:
// 74:       # Changes to this struct must be mirrored in Homebrew::API::Cask.generate_cask_struct_hash
// 75:       const :auto_updates, T::Boolean, default: false
// 76:       const :caveats_rosetta, T::Boolean, default: false
// 77:       const :conflicts_with_args, T::Hash[Symbol, T::Array[String]], default: {}
// 78:       const :container_args, { nested: T.nilable(String), type: T.nilable(Symbol) },
// 79:             default: { nested: nil, type: nil }
// 80:       const :depends_on_args, DependsOnArgs, default: {}
// 81:       const :deprecate_args, T::Hash[Symbol, T.nilable(T.any(String, Symbol))], default: {}
// 82:       const :desc, T.nilable(String)
// 83:       const :disable_args, T::Hash[Symbol, T.nilable(T.any(String, Symbol))], default: {}
// 84:       const :homepage, T.nilable(String)
// 85:       const :languages, T::Array[String], default: []
// 86:       const :language_variations, T::Array[LanguageVariation], default: []
// 87:       const :names, T::Array[String], default: []
// 88:       const :renames, T::Array[[String, String]], default: []
// 89:       const :ruby_source_checksum, T::Hash[Symbol, T.nilable(String)], default: { sha256: nil }
// 90:       const :ruby_source_path, T.nilable(String)
// 91:       const :sha256, T.any(String, Symbol)
// 92:       const :tap_string, T.nilable(String)
// 93:       const :url_args, T::Array[String], default: []
// 94:       const :url_kwargs, T::Hash[Symbol, T.anything], default: {}
// 95:       const :version, T.any(String, Symbol)
// 96:
// 97:       sig { params(other: T.anything).returns(T::Boolean) }
// 98:       def ==(other)
// 99:         case other
// 100:         when CaskStruct
// 101:           serialize == other.serialize
// 102:         else
// 103:           false
// 104:         end
// 105:       end
// 106:
// 107:       sig { params(appdir: T.any(Pathname, String)).returns(T::Array[ArtifactArgs]) }
// 108:       def artifacts(appdir:)
// 109:         deep_remove_placeholders(raw_artifacts, appdir.to_s)
// 110:       end
// 111:
// 112:       sig { params(appdir: T.any(Pathname, String)).returns(T.nilable(String)) }
// 113:       def caveats(appdir:)
// 114:         deep_remove_placeholders(raw_caveats, appdir.to_s)
// 115:       end
// 116:
// 117:       sig { params(languages: T::Array[String]).returns(CaskStruct) }
// 118:       def localise(languages)
// 119:         variation = language_variation(languages)
// 120:         return self if variation.nil?
// 121:
// 122:         overrides = T.cast(variation[:overrides], T.nilable(T::Hash[String, T.anything]))
// 123:         return self if overrides.blank?
// 124:
// 125:         serialised_overrides = T.cast(::Utils.deep_stringify_symbols(overrides), T::Hash[String, T.untyped])
// 126:         self.class.deserialize(serialize.merge(serialised_overrides))
// 127:       end
// 128:
// 129:       sig { params(languages: T::Array[String]).returns(T.nilable(String)) }
// 130:       def language(languages)
// 131:         T.cast(language_variation(languages)&.[](:value), T.nilable(String))
// 132:       end
// 133:
// 134:       sig { returns(T::Hash[String, T.untyped]) }
// 135:       def serialize
// 136:         hash = self.class.decorator.all_props.filter_map do |prop|
// 137:           next if PREDICATES.any? { |predicate| prop == :"#{predicate}_present" }
// 138:
// 139:           [prop.to_s, send(prop)]
// 140:         end.to_h
// 141:
// 142:         hash["raw_artifacts"] = ::Utils.deep_compact_blank(raw_artifacts.map do |artifact|
// 143:           serialize_artifact_args(artifact)
// 144:         end, compact_zero: false, compact_false: false)
// 145:
// 146:         hash = ::Utils.deep_stringify_symbols(hash)
// 147:         raw_artifacts = hash["raw_artifacts"]
// 148:         hash = ::Utils.deep_compact_blank(hash)
// 149:         hash["raw_artifacts"] = raw_artifacts if raw_artifacts.present?
// 150:         hash
// 151:       end
// 152:
// 153:       sig { params(hash: T::Hash[String, T.untyped]).returns(CaskStruct) }
// 154:       def self.deserialize(hash)
// 155:         hash = ::Utils.deep_unstringify_symbols(hash)
// 156:
// 157:         PREDICATES.each do |name|
// 158:           source_value = case name
// 159:           when :auto_updates then hash["auto_updates"]
// 160:           when :caveats      then hash["raw_caveats"]
// 161:           when :conflicts    then hash["conflicts_with_args"]
// 162:           when :desc         then hash["desc"]
// 163:           when :homepage     then hash["homepage"]
// 164:           else                    hash["#{name}_args"]
// 165:           end
// 166:
// 167:           hash["#{name}_present"] = source_value.present?
// 168:         end
// 169:
// 170:         hash["raw_artifacts"] = if (raw_artifacts = hash["raw_artifacts"])
// 171:           raw_artifacts.map { |artifact| deserialize_artifact_args(artifact) }
// 172:         end
// 173:
// 174:         from_hash(hash)
// 175:       end
// 176:
// 177:       sig { params(artifact: ArtifactArgs).returns(T::Array[T.untyped]) }
// 178:       def serialize_artifact_args(artifact)
// 179:         key, args, kwargs, block = artifact
// 180:
// 181:         # We can't serialize Procs, so always use an empty block placeholder to be deserialized as `-> {}`.
// 182:         block = EMPTY_BLOCK_PLACEHOLDER unless block.nil?
// 183:
// 184:         [key, args, kwargs, block]
// 185:       end
// 186:
// 187:       # Format artifact args pairs into proper [key, args, kwargs, block] format since serialization removed blanks.
// 188:       sig {
// 189:         params(
// 190:           args: T.any(
// 191:             [Symbol],
// 192:             [Symbol, T::Array[T.anything]],
// 193:             [Symbol, T::Hash[Symbol, T.anything]],
// 194:             [Symbol, Symbol],
// 195:             [Symbol, T::Array[T.anything], T::Hash[Symbol, T.anything]],
// 196:             [Symbol, T::Array[T.anything], Symbol],
// 197:             [Symbol, T::Hash[Symbol, T.anything], Symbol],
// 198:             [Symbol, T::Array[T.anything], T::Hash[Symbol, T.anything], Symbol],
// 199:           ),
// 200:         ).returns(ArtifactArgs)
// 201:       }
// 202:       def self.deserialize_artifact_args(args)
// 203:         case args
// 204:         in [key]                                                        then [key, [], {}, nil]
// 205:         in [key, Array => array]                                        then [key, array, {}, nil]
// 206:         in [key, Hash => hash]                                          then [key, [], hash, nil]
// 207:         in [key, EMPTY_BLOCK_PLACEHOLDER]                               then [key, [], {}, EMPTY_BLOCK]
// 208:         in [key, Array => array, Hash => hash]                          then [key, array, hash, nil]
// 209:         in [key, Array => array, EMPTY_BLOCK_PLACEHOLDER]               then [key, array, {}, EMPTY_BLOCK]
// 210:         in [key, Hash => hash, EMPTY_BLOCK_PLACEHOLDER]                 then [key, [], hash, EMPTY_BLOCK]
// 211:         in [key, Array => array, Hash => hash, EMPTY_BLOCK_PLACEHOLDER] then [key, array, hash, EMPTY_BLOCK]
// 212:         else
// 213:           # The block argument should only ever be EMPTY_BLOCK_PLACEHOLDER or nil, so we should never reach this case.
// 214:           raise "Invalid artifact args: #{args.inspect}"
// 215:         end
// 216:       end
// 217:
// 218:       private
// 219:
// 220:       sig { params(languages: T::Array[String]).returns(T.nilable(LanguageVariation)) }
// 221:       def language_variation(languages)
// 222:         locale_groups = language_variations.map do |variation|
// 223:           T.cast(variation[:languages], T::Array[String])
// 224:         end
// 225:         languages.each do |language|
// 226:           locale = Locale.parse(language)
// 227:           group = T.cast(locale.detect(locale_groups), T.nilable(T::Array[String]))
// 228:           if group
// 229:             return language_variations.find do |variation|
// 230:               T.cast(variation[:languages], T::Array[String]) == group
// 231:             end
// 232:           end
// 233:         rescue Locale::ParserError
// 234:           next
// 235:         end
// 236:
// 237:         language_variations.find do |variation|
// 238:           T.cast(variation[:default], T.nilable(T::Boolean)) == true
// 239:         end
// 240:       end
// 241:
// 242:       const :raw_artifacts, T::Array[ArtifactArgs], default: []
// 243:       const :raw_caveats, T.nilable(String)
// 244:
// 245:       sig {
// 246:         type_parameters(:U)
// 247:           .params(
// 248:             value:  T.type_parameter(:U),
// 249:             appdir: String,
// 250:           )
// 251:           .returns(T.type_parameter(:U))
// 252:       }
// 253:       def deep_remove_placeholders(value, appdir)
// 254:         value = case value
// 255:         when Hash
// 256:           value.transform_values do |v|
// 257:             deep_remove_placeholders(v, appdir)
// 258:           end
// 259:         when Array
// 260:           value.map do |v|
// 261:             deep_remove_placeholders(v, appdir)
// 262:           end
// 263:         when String
// 264:           value.gsub(HOMEBREW_HOME_PLACEHOLDER, Dir.home)
// 265:                .gsub(HOMEBREW_PREFIX_PLACEHOLDER, HOMEBREW_PREFIX)
// 266:                .gsub(HOMEBREW_CELLAR_PLACEHOLDER, HOMEBREW_CELLAR)
// 267:                .gsub(HOMEBREW_CASK_APPDIR_PLACEHOLDER, appdir)
// 268:         else
// 269:           value
// 270:         end
// 271:
// 272:         T.cast(value, T.type_parameter(:U))
// 273:       end
// 274:     end
// 275:   end
// 276: end
