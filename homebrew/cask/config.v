module cask

import brew_runtime
import x.json2

// Translated from Homebrew/brew `cask/config.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum CaskConfigValueKind {
	path
	languages
}

pub struct CaskConfigValue {
pub:
	kind   CaskConfigValueKind
	path   string
	values []string
}

pub type CaskConfigMap = map[string]CaskConfigValue

pub struct CaskConfigOptions {
pub:
	default_values      CaskConfigMap
	env_values          CaskConfigMap
	explicit_values     CaskConfigMap
	env_supplied        bool
	ignore_invalid_keys bool
	cask_options        []string
}

pub struct CaskConfig {
pub mut:
	default_values  CaskConfigMap
	env_values      CaskConfigMap
	explicit_values CaskConfigMap
pub:
	ignored_keys []string
}

const cask_default_directories = {
	'appdir':               '/Applications'
	'appimagedir':          '~/Applications'
	'keyboard_layoutdir':   '/Library/Keyboard Layouts'
	'colorpickerdir':       '~/Library/ColorPickers'
	'prefpanedir':          '~/Library/PreferencePanes'
	'qlplugindir':          '~/Library/QuickLook'
	'mdimporterdir':        '~/Library/Spotlight'
	'dictionarydir':        '~/Library/Dictionaries'
	'fontdir':              '~/Library/Fonts'
	'servicedir':           '~/Library/Services'
	'input_methoddir':      '~/Library/Input Methods'
	'internet_plugindir':   '~/Library/Internet Plug-Ins'
	'audio_unit_plugindir': '~/Library/Audio/Plug-Ins/Components'
	'vst_plugindir':        '~/Library/Audio/Plug-Ins/VST'
	'vst3_plugindir':       '~/Library/Audio/Plug-Ins/VST3'
	'screen_saverdir':      '~/Library/Screen Savers'
}

fn cask_config_path(value string) CaskConfigValue {
	return CaskConfigValue{
		kind: .path
		path: value
	}
}

fn cask_config_languages(values []string) CaskConfigValue {
	return CaskConfigValue{
		kind: .languages
		values: values.clone()
	}
}

pub fn cask_config_defaults() CaskConfigMap {
	mut values := CaskConfigMap{}
	values['languages'] = cask_config_languages([])
	for name, path in cask_default_directories {
		values[name] = cask_config_path(path)
	}
	return values
}

fn cask_config_expand_path(path string) string {
	if path == '~' {
		return brew_runtime.environment_value('HOME')
	}
	if path.starts_with('~/') {
		return brew_runtime.join_path(brew_runtime.environment_value('HOME'), path[2..])
	}
	if path.starts_with('/') {
		return path
	}
	return brew_runtime.join_path(brew_runtime.current_directory(), path)
}

pub fn canonicalize_cask_config(values CaskConfigMap) !CaskConfigMap {
	mut canonical := CaskConfigMap{}
	for name, value in values {
		if name in cask_default_directories {
			if value.kind == .languages {
				return error('Invalid path for default dir ${name}: ${value.values}')
			}
			canonical[name] = cask_config_path(cask_config_expand_path(value.path))
		} else {
			canonical[name] = value
		}
	}
	return canonical
}

pub fn reject_legacy_cask_config_keys(values CaskConfigMap) CaskConfigMap {
	valid := cask_config_defaults()
	mut filtered := CaskConfigMap{}
	for name, value in values {
		underscored := name.replace('-', '_')
		if name.contains('-') && underscored in valid {
			continue
		}
		filtered[name] = value
	}
	return filtered
}

fn cask_config_environment(options []string) CaskConfigMap {
	mut values := CaskConfigMap{}
	for argument in options {
		if !argument.contains('=') {
			continue
		}
		parts := argument.split_nth('=', 2)
		name := parts[0].trim_string_left('--').replace('-', '_')
		if name == 'language' {
			values['languages'] = cask_config_languages(parts[1].split(','))
		} else {
			values[name] = cask_config_path(parts[1])
		}
	}
	return values
}

fn cask_config_option_words(value string) []string {
	// EnvConfig.cask_opts supplies a Shellwords-split array in Ruby. Values in
	// persisted config are already parsed; this adapter preserves its ordinary
	// space-separated command-line representation.
	return value.fields()
}

pub fn new_cask_config(options CaskConfigOptions) !CaskConfig {
	mut defaults := cask_config_defaults()
	for name, value in options.default_values {
		defaults[name] = value
	}
	mut environment := if options.env_supplied {
		options.env_values.clone()
	} else {
		cask_config_environment(if options.cask_options.len > 0 {
			options.cask_options
		} else {
			cask_config_option_words(brew_runtime.environment_value('HOMEBREW_CASK_OPTS'))
		})
	}
	mut explicit := options.explicit_values.clone()
	valid := cask_config_defaults()
	mut unknown := []string{}
	for name in environment.keys() {
		if name !in valid {
			unknown << name
		}
	}
	for name in explicit.keys() {
		if name !in valid && name !in unknown {
			unknown << name
		}
	}
	unknown.sort()
	if unknown.len > 0 {
		if !options.ignore_invalid_keys {
			return error('Unknown key: :${unknown[0]}')
		}
		eprintln('Warning: Ignoring unknown cask configuration keys: [${unknown.map(':\${it}').join(', ')}]')
		for name in unknown {
			environment.delete(name)
			explicit.delete(name)
		}
	}
	return CaskConfig{
		default_values: canonicalize_cask_config(defaults)!
		env_values: canonicalize_cask_config(environment)!
		explicit_values: canonicalize_cask_config(explicit)!
		ignored_keys: unknown
	}
}

fn cask_config_value_from_json(value json2.Any) !CaskConfigValue {
	if value is []json2.Any {
		return cask_config_languages(value.map(it.str()))
	}
	if value is string {
		return cask_config_path(value)
	}
	return error('Cask configuration values must be strings or arrays of strings')
}

fn cask_config_section(value json2.Any) !CaskConfigMap {
	match value {
		json2.Null {
			return CaskConfigMap{}
		}
		map[string]json2.Any {
			mut section := CaskConfigMap{}
			for name, item in value {
				section[name] = cask_config_value_from_json(item)!
			}
			return reject_legacy_cask_config_keys(section)
		}
		else {
			return error('Cask configuration section must be a JSON object or null')
		}
	}
}

pub fn cask_config_from_json(contents string, ignore_invalid_keys bool) !CaskConfig {
	decoded := json2.decode[json2.Any](contents)!
	match decoded {
		map[string]json2.Any {
			empty := json2.Any(map[string]json2.Any{})
			default_values := cask_config_section(decoded['default'] or { empty })!
			env_values := cask_config_section(decoded['env'] or { empty })!
			explicit_values := cask_config_section(decoded['explicit'] or { empty })!
			return new_cask_config(CaskConfigOptions{
				default_values: default_values
				env_values: env_values
				explicit_values: explicit_values
				env_supplied: true
				ignore_invalid_keys: ignore_invalid_keys
			})
		}
		else {
			return error('Cask configuration must be a JSON object')
		}
	}
}

fn cask_config_value_json(value CaskConfigValue) json2.Any {
	return if value.kind == .languages {
		json2.Any(value.values.map(json2.Any(it)))
	} else {
		json2.Any(value.path)
	}
}

fn cask_config_map_json(values CaskConfigMap) map[string]json2.Any {
	mut encoded := map[string]json2.Any{}
	for name, value in values {
		encoded[name] = cask_config_value_json(value)
	}
	return encoded
}

pub fn (config CaskConfig) json() string {
	return json2.encode(json2.Any({
		'default':  json2.Any(cask_config_map_json(config.default_values))
		'env':      json2.Any(cask_config_map_json(config.env_values))
		'explicit': json2.Any(cask_config_map_json(config.explicit_values))
	}))
}

pub fn (config CaskConfig) directory(name string) !string {
	if name !in cask_default_directories {
		return error('Unknown cask directory: ${name}')
	}
	if value := config.explicit_values[name] {
		return value.path
	}
	if value := config.env_values[name] {
		return value.path
	}
	return config.default_values[name].path
}

pub fn (mut config CaskConfig) set_directory(name string, path string) ! {
	if name !in cask_default_directories {
		return error('Unknown cask directory: ${name}')
	}
	config.explicit_values[name] = cask_config_path(cask_config_expand_path(path))
}

fn cask_config_valid_locale(value string) bool {
	if value == '' || value.starts_with('-') || value.ends_with('-') {
		return false
	}
	parts := value.split('-')
	if parts.len == 0 || parts.len > 3 {
		return false
	}
	mut position := 0
	if position < parts.len {
		part := parts[position]
		if part.len in [2, 3] && part.bytes().all(it >= `a` && it <= `z`) {
			position++
		}
	}
	if position < parts.len {
		part := parts[position]
		if part.len == 4 && part[0].is_capital() && part[1..].bytes().all(it >= `a` && it <= `z`) {
			position++
		}
	}
	if position < parts.len {
		part := parts[position]
		if (part.len == 2 && part.bytes().all(it >= `A` && it <= `Z`)) || (part.len == 3 && part.bytes().all(it.is_digit())) {
			position++
		}
	}
	return position == parts.len
}

pub fn (config CaskConfig) languages() []string {
	mut languages := []string{}
	for values in [config.explicit_values, config.env_values, config.default_values] {
		if configured := values['languages'] {
			for language in configured.values {
				if language !in languages && cask_config_valid_locale(language) {
					languages << language
				}
			}
		}
	}
	return languages
}

pub fn (mut config CaskConfig) set_languages(languages []string) {
	config.explicit_values['languages'] = cask_config_languages(languages)
}

pub fn (config CaskConfig) binarydir() string {
	return brew_runtime.join_path(cask_config_prefix(), 'bin')
}

pub fn (config CaskConfig) manpagedir() string {
	return brew_runtime.join_path(cask_config_prefix(), 'share/man')
}

pub fn (config CaskConfig) bash_completion() string {
	return brew_runtime.join_path(cask_config_prefix(), 'etc/bash_completion.d')
}

pub fn (config CaskConfig) zsh_completion() string {
	return brew_runtime.join_path(cask_config_prefix(), 'share/zsh/site-functions')
}

pub fn (config CaskConfig) fish_completion() string {
	return brew_runtime.join_path(cask_config_prefix(), 'share/fish/vendor_completions.d')
}

fn cask_config_prefix() string {
	prefix := brew_runtime.environment_value('HOMEBREW_PREFIX')
	return if prefix == '' { '/opt/homebrew' } else { prefix }
}

pub fn (config CaskConfig) merge(other CaskConfig) !CaskConfig {
	mut explicit := other.explicit_values.clone()
	for name, value in config.explicit_values {
		explicit[name] = value
	}
	return new_cask_config(CaskConfigOptions{
		explicit_values: explicit
		env_supplied: true
	})
}

fn cask_config_boundary(config CaskConfig) brew_runtime.Value {
	return brew_runtime.structured_value('Cask::Config', config.json(), {
		'json': config.json()
	})
}

fn cask_config_from_boundary(value brew_runtime.Value) CaskConfig {
	contents := value.attribute('json') or { value.as_string() }
	return cask_config_from_json(contents, false) or { panic(err) }
}

fn cask_config_map_boundary(values CaskConfigMap) brew_runtime.Value {
	mut mapped := map[string]brew_runtime.Value{}
	for name, value in values {
		mapped[name] = if value.kind == .languages {
			brew_runtime.string_array_value(value.values)
		} else {
			brew_runtime.object_value('Pathname', value.path)
		}
	}
	return brew_runtime.map_value(mapped)
}

fn cask_config_map_from_boundary(value brew_runtime.Value) CaskConfigMap {
	values := value.as_map() or { return CaskConfigMap{} }
	mut mapped := CaskConfigMap{}
	for name, item in values {
		mapped[name] = if item.type_name == 'Array' {
			cask_config_languages(item.as_string_array() or { [] })
		} else {
			cask_config_path(item.as_string())
		}
	}
	return mapped
}

// Ruby method `self.defaults` at line 43.
pub fn ruby_config_l43_d1_self_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_config_map_boundary(canonicalize_cask_config(cask_config_defaults()) or {
		panic(err)
	})
}

// Ruby method `self.from_args(args)` at line 50.
pub fn ruby_config_l50_d2_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	mut explicit := CaskConfigMap{}
	if args.len > 0 {
		for name, value in args[0].attributes {
			if name == 'language' || name == 'languages' {
				explicit['languages'] = cask_config_languages(if value == '' {
					[]
				} else {
					value.split(',')
				})
			} else if name in cask_default_directories && value != '' {
				explicit[name] = cask_config_path(value)
			}
		}
	}
	return cask_config_boundary(new_cask_config(CaskConfigOptions{
		explicit_values: explicit
	}) or { panic(err) })
}

// Ruby method `self.from_json(json, ignore_invalid_keys: false)` at line 76.
pub fn ruby_config_l76_d3_self_from_json(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Config.from_json requires JSON') }
	ignore := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	return cask_config_boundary(cask_config_from_json(args[0].as_string(), ignore) or { panic(err) })
}

// Ruby method `self.reject_legacy_keys(config)` at line 90.
pub fn ruby_config_l90_d4_self_reject_legacy_keys(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return cask_config_map_boundary(reject_legacy_cask_config_keys(cask_config_map_from_boundary(args[0])))
}

// Ruby method `self.canonicalize(config)` at line 99.
pub fn ruby_config_l99_d5_self_canonicalize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return cask_config_map_boundary(CaskConfigMap{})
	}
	return cask_config_map_boundary(canonicalize_cask_config(cask_config_map_from_boundary(args[0])) or {
		panic(err)
	})
}

// Ruby attr_accessor `attr_accessor :explicit` at line 115.
pub fn ruby_config_l115_d6_explicit(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Config#explicit requires a receiver') }
	return cask_config_map_boundary(cask_config_from_boundary(args[0]).explicit_values)
}

// Ruby attr_accessor `attr_accessor :explicit` at line 115.
pub fn ruby_config_l115_d7_explicit(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Config#explicit= requires a value') }
	mut config := cask_config_from_boundary(args[0])
	config.explicit_values = canonicalize_cask_config(cask_config_map_from_boundary(args[1])) or {
		panic(err)
	}
	return cask_config_boundary(config)
}

// Ruby method `initialize(default: nil, env: nil, explicit: {}, ignore_invalid_keys: false)` at line 125.
pub fn ruby_config_l125_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	defaults := if args.len > 0 && args[0].type_name != 'NilClass' {
		cask_config_map_from_boundary(args[0])
	} else {
		CaskConfigMap{}
	}
	environment := if args.len > 1 && args[1].type_name != 'NilClass' {
		cask_config_map_from_boundary(args[1])
	} else {
		CaskConfigMap{}
	}
	explicit := if args.len > 2 { cask_config_map_from_boundary(args[2]) } else { CaskConfigMap{} }
	ignore := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	return cask_config_boundary(new_cask_config(CaskConfigOptions{
		default_values: defaults
		env_values: environment
		explicit_values: explicit
		env_supplied: args.len > 1 && args[1].type_name != 'NilClass'
		ignore_invalid_keys: ignore
	}) or { panic(err) })
}

// Ruby method `default` at line 161.
pub fn ruby_config_l161_d9_default(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Config#default requires a receiver') }
	return cask_config_map_boundary(cask_config_from_boundary(args[0]).default_values)
}

// Ruby method `env` at line 166.
pub fn ruby_config_l166_d10_env(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Config#env requires a receiver') }
	return cask_config_map_boundary(cask_config_from_boundary(args[0]).env_values)
}

// Ruby method `binarydir` at line 186.
pub fn ruby_config_l186_d11_binarydir(args ...brew_runtime.Value) brew_runtime.Value {
	config := if args.len > 0 {
		cask_config_from_boundary(args[0])
	} else {
		new_cask_config(CaskConfigOptions{}) or {
			panic(err)
		}
	}
	return brew_runtime.object_value('Pathname', config.binarydir())
}

// Ruby method `manpagedir` at line 191.
pub fn ruby_config_l191_d12_manpagedir(args ...brew_runtime.Value) brew_runtime.Value {
	config := if args.len > 0 {
		cask_config_from_boundary(args[0])
	} else {
		new_cask_config(CaskConfigOptions{}) or {
			panic(err)
		}
	}
	return brew_runtime.object_value('Pathname', config.manpagedir())
}

// Ruby method `bash_completion` at line 196.
pub fn ruby_config_l196_d13_bash_completion(args ...brew_runtime.Value) brew_runtime.Value {
	config := if args.len > 0 {
		cask_config_from_boundary(args[0])
	} else {
		new_cask_config(CaskConfigOptions{}) or {
			panic(err)
		}
	}
	return brew_runtime.object_value('Pathname', config.bash_completion())
}

// Ruby method `zsh_completion` at line 201.
pub fn ruby_config_l201_d14_zsh_completion(args ...brew_runtime.Value) brew_runtime.Value {
	config := if args.len > 0 {
		cask_config_from_boundary(args[0])
	} else {
		new_cask_config(CaskConfigOptions{}) or {
			panic(err)
		}
	}
	return brew_runtime.object_value('Pathname', config.zsh_completion())
}

// Ruby method `fish_completion` at line 206.
pub fn ruby_config_l206_d15_fish_completion(args ...brew_runtime.Value) brew_runtime.Value {
	config := if args.len > 0 {
		cask_config_from_boundary(args[0])
	} else {
		new_cask_config(CaskConfigOptions{}) or {
			panic(err)
		}
	}
	return brew_runtime.object_value('Pathname', config.fish_completion())
}

// Ruby method `languages` at line 211.
pub fn ruby_config_l211_d16_languages(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Config#languages requires a receiver') }
	return brew_runtime.string_array_value(cask_config_from_boundary(args[0]).languages())
}

// Ruby method `languages=(languages)` at line 226.
pub fn ruby_config_l226_d17_languages(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Config#languages= requires languages') }
	mut config := cask_config_from_boundary(args[0])
	config.set_languages(args[1].as_string_array() or { panic(err) })
	return cask_config_boundary(config)
}

// Ruby define_method `define_method(dir) do` at line 231.
pub fn ruby_config_l231_d18_dir(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('generated Config directory reader requires receiver and directory name')
	}
	return brew_runtime.object_value('Pathname', cask_config_from_boundary(args[0]).directory(args[1].as_string()) or {
		panic(err)
	})
}

// Ruby define_method `define_method(:"#{dir}=") do |path|` at line 236.
pub fn ruby_config_l236_d19_dir(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('generated Config directory writer requires receiver, directory name and path')
	}
	mut config := cask_config_from_boundary(args[0])
	config.set_directory(args[1].as_string(), args[2].as_string()) or { panic(err) }
	return cask_config_boundary(config)
}

// Ruby method `merge(other)` at line 243.
pub fn ruby_config_l243_d20_merge(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Config#merge requires a receiver and other Config') }
	return cask_config_boundary(cask_config_from_boundary(args[0]).merge(cask_config_from_boundary(args[1])) or {
		panic(err)
	})
}

// Ruby method `to_json(*options)` at line 248.
pub fn ruby_config_l248_d21_to_json(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Config#to_json requires a receiver') }
	return brew_runtime.string_value(cask_config_from_boundary(args[0]).json())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5:
// 6: require "lazy_object"
// 7: require "locale"
// 8: require "extend/hash/keys"
// 9: require "utils/output"
// 10:
// 11: module Cask
// 12:   # Configuration for installing casks.
// 13:   #
// 14:   # @api internal
// 15:   class Config
// 16:     include ::Utils::Output::Mixin
// 17:
// 18:     ConfigHash = T.type_alias { T::Hash[Symbol, T.any(LazyObject, String, Pathname, T::Array[String])] }
// 19:     DEFAULT_DIRS = T.let(
// 20:       {
// 21:         appdir:               "/Applications",
// 22:         appimagedir:          "~/Applications",
// 23:         keyboard_layoutdir:   "/Library/Keyboard Layouts",
// 24:         colorpickerdir:       "~/Library/ColorPickers",
// 25:         prefpanedir:          "~/Library/PreferencePanes",
// 26:         qlplugindir:          "~/Library/QuickLook",
// 27:         mdimporterdir:        "~/Library/Spotlight",
// 28:         dictionarydir:        "~/Library/Dictionaries",
// 29:         fontdir:              "~/Library/Fonts",
// 30:         servicedir:           "~/Library/Services",
// 31:         input_methoddir:      "~/Library/Input Methods",
// 32:         internet_plugindir:   "~/Library/Internet Plug-Ins",
// 33:         audio_unit_plugindir: "~/Library/Audio/Plug-Ins/Components",
// 34:         vst_plugindir:        "~/Library/Audio/Plug-Ins/VST",
// 35:         vst3_plugindir:       "~/Library/Audio/Plug-Ins/VST3",
// 36:         screen_saverdir:      "~/Library/Screen Savers",
// 37:       }.freeze,
// 38:       T::Hash[Symbol, String],
// 39:     )
// 40:
// 41:     # runtime recursive evaluation forces the LazyObject to be evaluated
// 42:     T::Sig::WithoutRuntime.sig { returns(ConfigHash) }
// 43:     def self.defaults
// 44:       {
// 45:         languages: T.let([], T::Array[String]),
// 46:       }.merge(DEFAULT_DIRS).freeze
// 47:     end
// 48:
// 49:     sig { params(args: Homebrew::CLI::Args).returns(T.attached_class) }
// 50:     def self.from_args(args)
// 51:       # FIXME: T.unsafe is a workaround for methods that are only defined when `cask_options`
// 52:       # is invoked on the parser. (These could be captured by a DSL compiler instead.)
// 53:       args = T.unsafe(args)
// 54:       new(explicit: {
// 55:         appdir:               args.appdir,
// 56:         appimagedir:          args.appimagedir,
// 57:         keyboard_layoutdir:   args.keyboard_layoutdir,
// 58:         colorpickerdir:       args.colorpickerdir,
// 59:         prefpanedir:          args.prefpanedir,
// 60:         qlplugindir:          args.qlplugindir,
// 61:         mdimporterdir:        args.mdimporterdir,
// 62:         dictionarydir:        args.dictionarydir,
// 63:         fontdir:              args.fontdir,
// 64:         servicedir:           args.servicedir,
// 65:         input_methoddir:      args.input_methoddir,
// 66:         internet_plugindir:   args.internet_plugindir,
// 67:         audio_unit_plugindir: args.audio_unit_plugindir,
// 68:         vst_plugindir:        args.vst_plugindir,
// 69:         vst3_plugindir:       args.vst3_plugindir,
// 70:         screen_saverdir:      args.screen_saverdir,
// 71:         languages:            args.language,
// 72:       }.compact)
// 73:     end
// 74:
// 75:     sig { params(json: String, ignore_invalid_keys: T::Boolean).returns(T.attached_class) }
// 76:     def self.from_json(json, ignore_invalid_keys: false)
// 77:       config = JSON.parse(json, symbolize_names: true)
// 78:
// 79:       new(
// 80:         default:             reject_legacy_keys(config.fetch(:default,  {})),
// 81:         env:                 reject_legacy_keys(config.fetch(:env,      {})),
// 82:         explicit:            reject_legacy_keys(config.fetch(:explicit, {})) || {},
// 83:         ignore_invalid_keys:,
// 84:       )
// 85:     end
// 86:
// 87:     # Saved configs can contain hyphenated option names that were never honored when read back,
// 88:     # so drop them instead of warning about them or retroactively making them take effect.
// 89:     sig { params(config: T.nilable(ConfigHash)).returns(T.nilable(ConfigHash)) }
// 90:     def self.reject_legacy_keys(config)
// 91:       return if config.nil?
// 92:
// 93:       valid_keys = defaults
// 94:       config.reject { |key, _| key.to_s.include?("-") && valid_keys.key?(key.to_s.tr("-", "_").to_sym) }
// 95:     end
// 96:
// 97:     # runtime recursive evaluation forces the LazyObject to be evaluated
// 98:     T::Sig::WithoutRuntime.sig { params(config: ConfigHash).returns(ConfigHash) }
// 99:     def self.canonicalize(config)
// 100:       config.to_h do |k, v|
// 101:         if DEFAULT_DIRS.key?(k)
// 102:           raise TypeError, "Invalid path for default dir #{k}: #{v.inspect}" if v.is_a?(Array)
// 103:
// 104:           [k, Pathname(v.to_s).expand_path]
// 105:         else
// 106:           [k, v]
// 107:         end
// 108:       end
// 109:     end
// 110:
// 111:     # Get the explicit configuration.
// 112:     #
// 113:     # @api internal
// 114:     sig { returns(ConfigHash) }
// 115:     attr_accessor :explicit
// 116:
// 117:     sig {
// 118:       params(
// 119:         default:             T.nilable(ConfigHash),
// 120:         env:                 T.nilable(ConfigHash),
// 121:         explicit:            ConfigHash,
// 122:         ignore_invalid_keys: T::Boolean,
// 123:       ).void
// 124:     }
// 125:     def initialize(default: nil, env: nil, explicit: {}, ignore_invalid_keys: false)
// 126:       # Define all instance variables in a consistent order so every instance
// 127:       # shares one object shape, avoiding Ruby's shape-variation warning.
// 128:       @default = T.let(
// 129:         default ? self.class.canonicalize(self.class.defaults.merge(default)) : nil,
// 130:         T.nilable(ConfigHash),
// 131:       )
// 132:       @env = T.let(
// 133:         env ? self.class.canonicalize(env) : nil,
// 134:         T.nilable(ConfigHash),
// 135:       )
// 136:       @explicit = T.let(
// 137:         self.class.canonicalize(explicit),
// 138:         ConfigHash,
// 139:       )
// 140:       @binarydir = T.let(nil, T.nilable(Pathname))
// 141:       @manpagedir = T.let(nil, T.nilable(Pathname))
// 142:       @bash_completion = T.let(nil, T.nilable(Pathname))
// 143:       @zsh_completion = T.let(nil, T.nilable(Pathname))
// 144:       @fish_completion = T.let(nil, T.nilable(Pathname))
// 145:
// 146:       if ignore_invalid_keys &&
// 147:          (unknown_keys = ((Array(@env&.keys) + @explicit.keys).uniq - self.class.defaults.keys).presence)
// 148:         opoo "Ignoring unknown cask configuration keys: #{unknown_keys.inspect}"
// 149:
// 150:         @env&.delete_if { |key, _| unknown_keys.include?(key) }
// 151:         @explicit.delete_if { |key, _| unknown_keys.include?(key) }
// 152:         return
// 153:       end
// 154:
// 155:       @env&.assert_valid_keys(*self.class.defaults.keys)
// 156:       @explicit.assert_valid_keys(*self.class.defaults.keys)
// 157:     end
// 158:
// 159:     # runtime recursive evaluation forces the LazyObject to be evaluated
// 160:     T::Sig::WithoutRuntime.sig { returns(ConfigHash) }
// 161:     def default
// 162:       @default ||= self.class.canonicalize(self.class.defaults)
// 163:     end
// 164:
// 165:     sig { returns(ConfigHash) }
// 166:     def env
// 167:       @env ||= self.class.canonicalize(
// 168:         Homebrew::EnvConfig.cask_opts
// 169:           .select { |arg| arg.include?("=") }
// 170:           .map { |arg| T.cast(arg.split("=", 2), [String, String]) }
// 171:           .to_h do |(flag, value)|
// 172:             # command-line flags are hyphenated (e.g. --input-methoddir) but config keys use underscores
// 173:             key = flag.sub(/^--/, "").tr("-", "_")
// 174:             # converts --language flag to :languages config key
// 175:             if key == "language"
// 176:               key = "languages"
// 177:               value = value.split(",")
// 178:             end
// 179:
// 180:             [key.to_sym, value]
// 181:           end,
// 182:       )
// 183:     end
// 184:
// 185:     sig { returns(Pathname) }
// 186:     def binarydir
// 187:       @binarydir ||= HOMEBREW_PREFIX/"bin"
// 188:     end
// 189:
// 190:     sig { returns(Pathname) }
// 191:     def manpagedir
// 192:       @manpagedir ||= HOMEBREW_PREFIX/"share/man"
// 193:     end
// 194:
// 195:     sig { returns(Pathname) }
// 196:     def bash_completion
// 197:       @bash_completion ||= HOMEBREW_PREFIX/"etc/bash_completion.d"
// 198:     end
// 199:
// 200:     sig { returns(Pathname) }
// 201:     def zsh_completion
// 202:       @zsh_completion ||= HOMEBREW_PREFIX/"share/zsh/site-functions"
// 203:     end
// 204:
// 205:     sig { returns(Pathname) }
// 206:     def fish_completion
// 207:       @fish_completion ||= HOMEBREW_PREFIX/"share/fish/vendor_completions.d"
// 208:     end
// 209:
// 210:     sig { returns(T::Array[String]) }
// 211:     def languages
// 212:       [
// 213:         *explicit.fetch(:languages, []),
// 214:         *env.fetch(:languages, []),
// 215:         *default.fetch(:languages, []),
// 216:       ].uniq.select do |lang|
// 217:         # Ensure all languages are valid.
// 218:         Locale.parse(lang)
// 219:         true
// 220:       rescue Locale::ParserError
// 221:         false
// 222:       end
// 223:     end
// 224:
// 225:     sig { params(languages: T::Array[String]).void }
// 226:     def languages=(languages)
// 227:       explicit[:languages] = languages
// 228:     end
// 229:
// 230:     DEFAULT_DIRS.each_key do |dir|
// 231:       define_method(dir) do
// 232:         T.bind(self, Config)
// 233:         explicit.fetch(dir, env.fetch(dir, default.fetch(dir)))
// 234:       end
// 235:
// 236:       define_method(:"#{dir}=") do |path|
// 237:         T.bind(self, Config)
// 238:         explicit[dir] = Pathname(path).expand_path
// 239:       end
// 240:     end
// 241:
// 242:     sig { params(other: Config).returns(T.self_type) }
// 243:     def merge(other)
// 244:       self.class.new(explicit: other.explicit.merge(explicit))
// 245:     end
// 246:
// 247:     sig { params(options: T.untyped).returns(String) }
// 248:     def to_json(*options)
// 249:       {
// 250:         default:,
// 251:         env:,
// 252:         explicit:,
// 253:       }.to_json(*options)
// 254:     end
// 255:   end
// 256: end
// 257:
// 258: require "extend/os/cask/config"
