module homebrew

import ruby
import x.json2

// Translated from Homebrew/brew `cask_artifact.rb`.

pub struct CaskArtifactConfig {
pub:
	raw             string
	default_values  map[string]ruby.Value
	env_values      map[string]ruby.Value
	explicit_values map[string]ruby.Value
	ignored_keys    []string
}

pub struct CaskArtifactInstallStepsContext {
pub:
	name          ruby.Value
	token         string
	version       string
	staged_path   string
	caskroom_path string
	home          string
	config        CaskArtifactConfig
}

const cask_artifact_config_keys = ['languages', 'appdir', 'appimagedir', 'keyboard_layoutdir',
	'colorpickerdir', 'prefpanedir', 'qlplugindir', 'mdimporterdir', 'dictionarydir', 'fontdir',
	'servicedir', 'input_methoddir', 'internet_plugindir', 'audio_unit_plugindir', 'vst_plugindir',
	'vst3_plugindir', 'screen_saverdir']

fn cask_artifact_json_value(value json2.Any) !ruby.Value {
	match value {
		string {
			return ruby.string_value(value)
		}
		[]json2.Any {
			mut values := []string{}
			for item in value {
				if item !is string {
					return error('Cask configuration arrays must contain strings')
				}
				values << item.str()
			}
			return ruby.string_array_value(values)
		}
		else {
			return error('Cask configuration values must be strings or arrays of strings')
		}
	}
}

fn cask_artifact_config_section(value json2.Any, mut ignored []string) !map[string]ruby.Value {
	match value {
		json2.Null {
			return map[string]ruby.Value{}
		}
		map[string]json2.Any {
			mut section := map[string]ruby.Value{}
			for name, item in value {
				if name !in cask_artifact_config_keys {
					if name !in ignored {
						ignored << name
					}
					continue
				}
				section[name] = cask_artifact_json_value(item)!
			}
			return section
		}
		else {
			return error('Cask configuration section must be a JSON object or null')
		}
	}
}

pub fn cask_artifact_config_from_json(contents string) !CaskArtifactConfig {
	decoded := json2.decode[json2.Any](contents)!
	match decoded {
		map[string]json2.Any {
			empty := json2.Any(map[string]json2.Any{})
			mut ignored := []string{}
			defaults := cask_artifact_config_section(decoded['default'] or { empty }, mut ignored)!
			environment := cask_artifact_config_section(decoded['env'] or { empty }, mut ignored)!
			explicit := cask_artifact_config_section(decoded['explicit'] or { empty }, mut ignored)!
			ignored.sort()
			return CaskArtifactConfig{
				raw: contents
				default_values: defaults
				env_values: environment
				explicit_values: explicit
				ignored_keys: ignored
			}
		}
		else {
			return error('Cask configuration must be a JSON object')
		}
	}
}

fn cask_artifact_required(values map[string]ruby.Value, key string) !ruby.Value {
	return values[key] or { error('KeyError: key not found: "${key}"') }
}

pub fn new_cask_artifact_install_steps_context(values map[string]ruby.Value) !CaskArtifactInstallStepsContext {
	name := cask_artifact_required(values, 'name')!
	token := cask_artifact_required(values, 'token')!.as_string()
	version := cask_artifact_required(values, 'version')!.as_string()
	staged_path := cask_artifact_required(values, 'staged_path')!.as_string()
	caskroom_path := cask_artifact_required(values, 'caskroom_path')!.as_string()
	home := cask_artifact_required(values, 'home')!.as_string()
	config_json := cask_artifact_required(values, 'config')!.as_string()
	return CaskArtifactInstallStepsContext{
		name: name
		token: token
		version: version
		staged_path: staged_path
		caskroom_path: caskroom_path
		home: home
		config: cask_artifact_config_from_json(config_json)!
	}
}

pub fn (context CaskArtifactInstallStepsContext) str() string {
	return context.token
}

fn cask_artifact_config_value(config CaskArtifactConfig) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Config'
		repr: config.raw
		attributes: {
			'ignored_keys': config.ignored_keys.join('|')
		}
		map_data: {
			'default':  ruby.map_value(config.default_values)
			'env':      ruby.map_value(config.env_values)
			'explicit': ruby.map_value(config.explicit_values)
		}
	}
}

fn cask_artifact_context_value(context CaskArtifactInstallStepsContext) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::InstallStepsContext'
		repr: context.token
		attributes: {
			'token':         context.token
			'version':       context.version
			'staged_path':   context.staged_path
			'caskroom_path': context.caskroom_path
			'home':          context.home
		}
		map_data: {
			'name':   context.name
			'config': cask_artifact_config_value(context.config)
		}
	}
}

fn cask_artifact_context_from_value(value ruby.Value) !CaskArtifactInstallStepsContext {
	name := value.map_data['name'] or { ruby.string_value(value.attributes['name'] or { '' }) }
	config_value := value.map_data['config'] or { ruby.string_value('{}') }
	config_json := if config_value.type_name == 'Cask::Config' {
		config_value.repr
	} else {
		config_value.as_string()
	}
	return new_cask_artifact_install_steps_context({
		'name':          name
		'token':         ruby.string_value(value.attributes['token'] or { value.as_string() })
		'version':       ruby.string_value(value.attributes['version'] or { '' })
		'staged_path':   ruby.string_value(value.attributes['staged_path'] or { '' })
		'caskroom_path': ruby.string_value(value.attributes['caskroom_path'] or { '' })
		'home':          ruby.string_value(value.attributes['home'] or { '' })
		'config':        ruby.string_value(config_json)
	})
}
