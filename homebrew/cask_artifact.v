module homebrew

import ruby
import x.json2

// Translated from Homebrew/brew `cask_artifact.rb`.
// The original source is retained below for exact boundary auditing.

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

// Ruby attr_reader `attr_reader :name` at line 21.
pub fn ruby_cask_artifact_l21_d1_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	context := cask_artifact_context_from_value(args[0]) or {
		return ruby.object_value('KeyError', err.msg())
	}
	return context.name
}

// Ruby attr_reader `attr_reader :token` at line 24.
pub fn ruby_cask_artifact_l24_d2_token(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	context := cask_artifact_context_from_value(args[0]) or {
		return ruby.object_value('KeyError', err.msg())
	}
	return ruby.string_value(context.token)
}

// Ruby attr_reader `attr_reader :version` at line 27.
pub fn ruby_cask_artifact_l27_d3_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	context := cask_artifact_context_from_value(args[0]) or {
		return ruby.object_value('KeyError', err.msg())
	}
	return ruby.string_value(context.version)
}

// Ruby attr_reader `attr_reader :staged_path` at line 30.
pub fn ruby_cask_artifact_l30_d4_staged_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	context := cask_artifact_context_from_value(args[0]) or {
		return ruby.object_value('KeyError', err.msg())
	}
	return ruby.object_value('Pathname', context.staged_path)
}

// Ruby attr_reader `attr_reader :caskroom_path` at line 33.
pub fn ruby_cask_artifact_l33_d5_caskroom_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	context := cask_artifact_context_from_value(args[0]) or {
		return ruby.object_value('KeyError', err.msg())
	}
	return ruby.object_value('Pathname', context.caskroom_path)
}

// Ruby attr_reader `attr_reader :home` at line 36.
pub fn ruby_cask_artifact_l36_d6_home(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	context := cask_artifact_context_from_value(args[0]) or {
		return ruby.object_value('KeyError', err.msg())
	}
	return ruby.object_value('Pathname', context.home)
}

// Ruby attr_reader `attr_reader :config` at line 39.
pub fn ruby_cask_artifact_l39_d7_config(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	context := cask_artifact_context_from_value(args[0]) or {
		return ruby.object_value('KeyError', err.msg())
	}
	return cask_artifact_config_value(context.config)
}

// Ruby method `initialize(context)` at line 42.
pub fn ruby_cask_artifact_l42_d8_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return ruby.object_value('ArgumentError', 'InstallStepsContext requires a context hash')
	}
	context := new_cask_artifact_install_steps_context(args[0].map_data) or {
		return ruby.object_value('KeyError', err.msg())
	}
	return cask_artifact_context_value(context)
}

// Ruby method `to_s = token` at line 53.
pub fn ruby_cask_artifact_l53_d9_to_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	context := cask_artifact_context_from_value(args[0]) or {
		return ruby.object_value('KeyError', err.msg())
	}
	return ruby.string_value(context.str())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: raise "#{__FILE__} must not be loaded via `require`." if $PROGRAM_NAME != __FILE__
// 5:
// 6: old_trap = trap("INT") { exit! 130 }
// 7:
// 8: require_relative "global"
// 9:
// 10: require "json"
// 11: require "cask/config"
// 12: require "extend/ENV"
// 13: require "install_steps"
// 14: require "utils/fork"
// 15: require "utils/shell_completion"
// 16:
// 17: module Cask
// 18:   # Minimal cask state needed to resolve structured install-step paths and tokens.
// 19:   class InstallStepsContext
// 20:     sig { returns(T.any(String, T::Array[String])) }
// 21:     attr_reader :name
// 22:
// 23:     sig { returns(String) }
// 24:     attr_reader :token
// 25:
// 26:     sig { returns(String) }
// 27:     attr_reader :version
// 28:
// 29:     sig { returns(Pathname) }
// 30:     attr_reader :staged_path
// 31:
// 32:     sig { returns(Pathname) }
// 33:     attr_reader :caskroom_path
// 34:
// 35:     sig { returns(Pathname) }
// 36:     attr_reader :home
// 37:
// 38:     sig { returns(Config) }
// 39:     attr_reader :config
// 40:
// 41:     sig { params(context: T::Hash[String, T.untyped]).void }
// 42:     def initialize(context)
// 43:       @name = T.let(context.fetch("name"), T.any(String, T::Array[String]))
// 44:       @token = T.let(context.fetch("token"), String)
// 45:       @version = T.let(context.fetch("version"), String)
// 46:       @staged_path = T.let(Pathname(context.fetch("staged_path")), Pathname)
// 47:       @caskroom_path = T.let(Pathname(context.fetch("caskroom_path")), Pathname)
// 48:       @home = T.let(Pathname(context.fetch("home")), Pathname)
// 49:       @config = T.let(Config.from_json(context.fetch("config"), ignore_invalid_keys: true), Config)
// 50:     end
// 51:
// 52:     sig { returns(String) }
// 53:     def to_s = token
// 54:   end
// 55: end
// 56:
// 57: begin
// 58:   error_pipe = Utils.forked_child_error_pipe
// 59:
// 60:   trap("INT", old_trap)
// 61:
// 62:   # Match formula post-install isolation inside the sandboxed child. The
// 63:   # original cask context is supplied in JSON and never needs a `.rb` file.
// 64:   ENV["TMPDIR"] = HOMEBREW_TEMP.to_s
// 65:   ENV["TEMP"] = HOMEBREW_TEMP.to_s
// 66:   ENV["TMP"] = HOMEBREW_TEMP.to_s
// 67:   ENV.delete("HOMEBREW_PATH")
// 68:   ENV["PATH"] = PATH.new(ORIGINAL_PATHS).to_s
// 69:   ENV.clear_sensitive_environment!
// 70:   ENV.activate_extensions!
// 71:   Pathname.activate_extensions!
// 72:
// 73:   payload = T.cast(JSON.parse(Pathname(ARGV.fetch(0)).read), T::Hash[String, T.untyped])
// 74:   case payload.fetch("action")
// 75:   when "install_steps"
// 76:     context = Cask::InstallStepsContext.new(payload.fetch("context"))
// 77:     steps = payload.fetch("steps")
// 78:     phase = payload.fetch("phase").to_sym
// 79:     Homebrew::InstallSteps::Runner.new(context:).run(steps, phase:)
// 80:   when "generated_completions"
// 81:     errors = []
// 82:     payload.fetch("completions").each do |completion|
// 83:       commands = completion.fetch("commands")
// 84:       output_path = Pathname(completion.fetch("output_path"))
// 85:       output_path.dirname.mkpath
// 86:       output_path.write(
// 87:         Utils::ShellCompletion.generate_completion_output(
// 88:           commands, completion["shell_parameter"], completion.fetch("env")
// 89:         ),
// 90:       )
// 91:     rescue => e
// 92:       errors << "Failed to generate #{completion.fetch("shell")} completions from #{commands.fetch(0)}: #{e}"
// 93:     end
// 94:     raise errors.join("\n") unless errors.empty?
// 95:   else
// 96:     raise ArgumentError, "unknown sandboxed cask action: #{payload.fetch("action")}"
// 97:   end
// 98:
// 99: # Handle all possible exceptions.
// 100: rescue Exception => e # rubocop:disable Lint/RescueException
// 101:   Utils.report_forked_child_error(error_pipe, e)
// 102:   exit! 1
// 103: end
