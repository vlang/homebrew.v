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

pub fn (context CaskArtifactInstallStepsContext) str() string {
	return context.token
}
