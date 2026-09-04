module cask

import ruby
import x.json2

// Translated from Homebrew/brew `cask/config.rb`.
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
		return ruby.environment_value('HOME')
	}
	if path.starts_with('~/') {
		return ruby.join_path(ruby.environment_value('HOME'), path[2..])
	}
	if path.starts_with('/') {
		return path
	}
	return ruby.join_path(ruby.current_directory(), path)
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
			cask_config_option_words(ruby.environment_value('HOMEBREW_CASK_OPTS'))
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
	return ruby.join_path(cask_config_prefix(), 'bin')
}

pub fn (config CaskConfig) manpagedir() string {
	return ruby.join_path(cask_config_prefix(), 'share/man')
}

pub fn (config CaskConfig) bash_completion() string {
	return ruby.join_path(cask_config_prefix(), 'etc/bash_completion.d')
}

pub fn (config CaskConfig) zsh_completion() string {
	return ruby.join_path(cask_config_prefix(), 'share/zsh/site-functions')
}

pub fn (config CaskConfig) fish_completion() string {
	return ruby.join_path(cask_config_prefix(), 'share/fish/vendor_completions.d')
}

fn cask_config_prefix() string {
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
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

fn cask_config_boundary(config CaskConfig) ruby.Value {
	return ruby.structured_value('Cask::Config', config.json(), {
		'json': config.json()
	})
}

fn cask_config_from_boundary(value ruby.Value) CaskConfig {
	contents := value.attribute('json') or { value.as_string() }
	return cask_config_from_json(contents, false) or { panic(err) }
}

fn cask_config_map_boundary(values CaskConfigMap) ruby.Value {
	mut mapped := map[string]ruby.Value{}
	for name, value in values {
		mapped[name] = if value.kind == .languages {
			ruby.string_array_value(value.values)
		} else {
			ruby.object_value('Pathname', value.path)
		}
	}
	return ruby.map_value(mapped)
}

fn cask_config_map_from_boundary(value ruby.Value) CaskConfigMap {
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
