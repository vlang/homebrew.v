module cask

import ruby
import homebrew
import homebrew.cask.artifact as cask_artifact
import homebrew.cask.dsl as dsl_types
import time

// Translated from Homebrew/brew `cask/dsl.rb`.
const cask_dsl_valid_no_autobump_reasons = ['incompatible_version_format', 'bumped_by_upstream',
	'extract_plist', 'latest_version', 'requires_manual_review']

const cask_dsl_ordinary_artifacts = ['installer', 'app', 'app_image', 'artifact', 'audio_unit_plugin',
	'binary', 'command_wrapper', 'colorpicker', 'dictionary', 'font', 'generated_script',
	'input_method', 'internet_plugin', 'keyboard_layout', 'manpage', 'pkg', 'prefpane', 'qlplugin',
	'mdimporter', 'screen_saver', 'service', 'stage_only', 'suite', 'vst_plugin', 'vst3_plugin',
	'zsh_completion', 'fish_completion', 'bash_completion', 'generated_completion', 'uninstall',
	'zap']

pub struct CaskLanguageBlock {
pub:
	languages  []string
	result     string
	mutations  map[string]ruby.Value
	is_default bool
}

pub struct CaskDSL {
pub mut:
	cask                            ruby.Value
	token                           string
	artifacts                       ArtifactSet
	no_autobump_message             ruby.Value
	deprecation_date                string
	deprecation_reason              ruby.Value
	deprecation_replacement_cask    string
	deprecation_replacement_formula string
	deprecate_args                  map[string]ruby.Value
	disable_date                    string
	disable_reason                  ruby.Value
	disable_replacement_cask        string
	disable_replacement_formula     string
	disable_args                    map[string]ruby.Value
	homepage_browsed                string
	on_system_block_min_os          string
	depends_on_set_in_block         bool
	deprecated                      bool
	disabled                        bool
	livecheck_defined               bool
	on_system_blocks_exist          bool
	on_os_blocks_exist              bool
	names                           []string
	description                     string
	has_description                 bool
	homepage                        string
	has_homepage                    bool
	language_blocks                 []CaskLanguageBlock
	language_eval_value             string
	language_evaluated              bool
	url_value                       CaskURL
	has_url                         bool
	container_value                 dsl_types.CaskContainer
	has_container                   bool
	renames                         []dsl_types.CaskRename
	version_value                   dsl_types.CaskVersion
	has_version                     bool
	sha256_value                    ruby.Value
	has_sha256                      bool
	arch_value                      string
	has_arch                        bool
	os_value                        string
	has_os                          bool
	depends_on_value                dsl_types.CaskDependsOn
	conflicts_with_value            dsl_types.CaskConflictsWith
	has_conflicts_with              bool
	staged_path_value               string
	caveats_value                   dsl_types.CaskCaveats
	auto_updates_value              bool
	has_auto_updates                bool
	livecheck_value                 ruby.Value
	livecheck_strategy              string
	no_autobump_defined             bool
	autobump                        bool = true
	called_in_on_system_block       bool
	called_in_on_os_block           bool
	unique_set                      map[string]bool
	unique_set_in_block             map[string]bool
}

fn cask_dsl_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn cask_dsl_error(kind string, message string) ruby.Value {
	return ruby.object_value(kind, message)
}

fn cask_dsl_value_string(value ruby.Value) string {
	return if value.type_name == 'Symbol' {
		value.as_string().trim_left(':')
	} else {
		value.as_string()
	}
}

fn cask_dsl_value_bool(value ruby.Value, fallback bool) bool {
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn cask_dsl_keywords(args []ruby.Value) map[string]ruby.Value {
	for index := args.len - 1; index >= 0; index-- {
		if args[index].type_name == 'Hash' {
			return args[index].map_data.clone()
		}
	}
	return map[string]ruby.Value{}
}

fn cask_dsl_cask_field(cask ruby.Value, key string) ruby.Value {
	if value := cask.map_data[key] {
		return value
	}
	if value := cask.attributes[key] {
		return ruby.string_value(value)
	}
	return cask_dsl_nil()
}

fn cask_dsl_cask_bool(cask ruby.Value, key string, fallback bool) bool {
	value := cask_dsl_cask_field(cask, key)
	if value.type_name == 'Bool' {
		return value.bool_data
	}
	if value.type_name in ['String', 'Symbol'] && value.as_string() != '' {
		return value.as_string().bool()
	}
	return fallback
}

fn cask_dsl_config_field(cask ruby.Value, key string) ruby.Value {
	config := cask_dsl_cask_field(cask, 'config')
	if config.type_name == 'Hash' {
		return config.map_data[key] or { cask_dsl_nil() }
	}
	return cask_dsl_nil()
}

pub fn new_cask_dsl(cask ruby.Value) CaskDSL {
	token_value := cask_dsl_cask_field(cask, 'token')
	token := if token_value.type_name == 'NilClass' {
		cask.as_string()
	} else {
		token_value.as_string()
	}
	return CaskDSL{
		cask: cask
		token: token
		artifacts: new_artifact_set([]ruby.Value{})
		depends_on_value: dsl_types.CaskDependsOn{}
		caveats_value: dsl_types.new_cask_caveats(cask)
		livecheck_value: homebrew.livecheck_dsl_value(homebrew.new_livecheck_dsl(cask))
	}
}

fn cask_language_block_value(block CaskLanguageBlock) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::DSL::LanguageBlock'
		repr: block.result
		map_data: {
			'languages': ruby.string_array_value(block.languages)
			'result':    ruby.string_value(block.result)
			'mutations': ruby.map_value(block.mutations)
			'default':   ruby.bool_value(block.is_default)
		}
	}
}

fn cask_language_block_from_value(value ruby.Value) CaskLanguageBlock {
	return CaskLanguageBlock{
		languages: (value.map_data['languages'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
		result: (value.map_data['result'] or { ruby.string_value(value.as_string()) }).as_string()
		mutations: (value.map_data['mutations'] or { ruby.map_value({}) }).map_data.clone()
		is_default: cask_dsl_value_bool(value.map_data['default'] or { ruby.bool_value(false) }, false)
	}
}

pub fn cask_dsl_value(dsl CaskDSL) ruby.Value {
	mut rename_values := []ruby.Value{}
	for rename in dsl.renames {
		rename_values << dsl_types.cask_rename_value(rename)
	}
	mut values := {
		'cask':                            dsl.cask
		'token':                           ruby.string_value(dsl.token)
		'artifacts':                       artifact_set_value(dsl.artifacts)
		'no_autobump_message':             dsl.no_autobump_message
		'deprecation_date':                if dsl.deprecation_date == '' {
			cask_dsl_nil()
		} else {
			ruby.object_value('Date', dsl.deprecation_date)
		}
		'deprecation_reason':              dsl.deprecation_reason
		'deprecation_replacement_cask':    if dsl.deprecation_replacement_cask == '' {
			cask_dsl_nil()
		} else {
			ruby.string_value(dsl.deprecation_replacement_cask)
		}
		'deprecation_replacement_formula': if dsl.deprecation_replacement_formula == '' {
			cask_dsl_nil()
		} else {
			ruby.string_value(dsl.deprecation_replacement_formula)
		}
		'deprecate_args':                  if dsl.deprecate_args.len == 0 {
			cask_dsl_nil()
		} else {
			ruby.map_value(dsl.deprecate_args)
		}
		'disable_date':                    if dsl.disable_date == '' {
			cask_dsl_nil()
		} else {
			ruby.object_value('Date', dsl.disable_date)
		}
		'disable_reason':                  dsl.disable_reason
		'disable_replacement_cask':        if dsl.disable_replacement_cask == '' {
			cask_dsl_nil()
		} else {
			ruby.string_value(dsl.disable_replacement_cask)
		}
		'disable_replacement_formula':     if dsl.disable_replacement_formula == '' {
			cask_dsl_nil()
		} else {
			ruby.string_value(dsl.disable_replacement_formula)
		}
		'disable_args':                    if dsl.disable_args.len == 0 {
			cask_dsl_nil()
		} else {
			ruby.map_value(dsl.disable_args)
		}
		'homepage_browsed':                if dsl.homepage_browsed == '' {
			cask_dsl_nil()
		} else {
			ruby.object_value('Date', dsl.homepage_browsed)
		}
		'on_system_block_min_os':          if dsl.on_system_block_min_os == '' {
			cask_dsl_nil()
		} else {
			ruby.object_value('MacOSVersion', dsl.on_system_block_min_os)
		}
		'depends_on_set_in_block':         ruby.bool_value(dsl.depends_on_set_in_block)
		'deprecated':                      ruby.bool_value(dsl.deprecated)
		'disabled':                        ruby.bool_value(dsl.disabled)
		'livecheck_defined':               ruby.bool_value(dsl.livecheck_defined)
		'on_system_blocks_exist':          ruby.bool_value(dsl.on_system_blocks_exist)
		'on_os_blocks_exist':              ruby.bool_value(dsl.on_os_blocks_exist)
		'names':                           ruby.string_array_value(dsl.names)
		'description':                     if dsl.has_description {
			ruby.string_value(dsl.description)
		} else {
			cask_dsl_nil()
		}
		'homepage':                        if dsl.has_homepage {
			ruby.string_value(dsl.homepage)
		} else {
			cask_dsl_nil()
		}
		'language_blocks':                 ruby.array_value(dsl.language_blocks.map(cask_language_block_value(it)))
		'language_eval':                   if dsl.language_evaluated {
			ruby.string_value(dsl.language_eval_value)
		} else {
			cask_dsl_nil()
		}
		'language_evaluated':              ruby.bool_value(dsl.language_evaluated)
		'url':                             if dsl.has_url {
			cask_url_value(dsl.url_value)
		} else {
			cask_dsl_nil()
		}
		'container':                       if dsl.has_container {
			dsl_types.cask_container_value(dsl.container_value)
		} else {
			cask_dsl_nil()
		}
		'renames':                         ruby.array_value(rename_values)
		'version':                         if dsl.has_version {
			dsl_types.cask_version_value(dsl.version_value)
		} else {
			cask_dsl_nil()
		}
		'sha256':                          if dsl.has_sha256 {
			dsl.sha256_value
		} else {
			cask_dsl_nil()
		}
		'arch':                            if dsl.has_arch {
			ruby.string_value(dsl.arch_value)
		} else {
			cask_dsl_nil()
		}
		'os':                              if dsl.has_os {
			ruby.string_value(dsl.os_value)
		} else {
			cask_dsl_nil()
		}
		'depends_on':                      dsl_types.cask_depends_on_value(dsl.depends_on_value)
		'conflicts_with':                  if dsl.has_conflicts_with {
			dsl_types.cask_conflicts_with_value(dsl.conflicts_with_value)
		} else {
			cask_dsl_nil()
		}
		'staged_path':                     if dsl.staged_path_value == '' {
			cask_dsl_nil()
		} else {
			ruby.object_value('Pathname', dsl.staged_path_value)
		}
		'caveats':                         dsl_types.cask_caveats_value(dsl.caveats_value)
		'caveat_texts':                    ruby.string_array_value(dsl.caveats_value.custom)
		'auto_updates':                    if dsl.has_auto_updates {
			ruby.bool_value(dsl.auto_updates_value)
		} else {
			cask_dsl_nil()
		}
		'livecheck':                       dsl.livecheck_value
		'livecheck_strategy':              ruby.string_value(dsl.livecheck_strategy)
		'no_autobump_defined':             ruby.bool_value(dsl.no_autobump_defined)
		'autobump':                        ruby.bool_value(dsl.autobump)
		'called_in_on_system_block':       ruby.bool_value(dsl.called_in_on_system_block)
		'called_in_on_os_block':           ruby.bool_value(dsl.called_in_on_os_block)
	}
	mut unique := map[string]ruby.Value{}
	for key, set in dsl.unique_set {
		unique[key] = ruby.bool_value(set)
	}
	values['unique_set'] = ruby.map_value(unique)
	mut in_block := map[string]ruby.Value{}
	for key, set in dsl.unique_set_in_block {
		in_block[key] = ruby.bool_value(set)
	}
	values['unique_set_in_block'] = ruby.map_value(in_block)
	return ruby.Value{
		type_name: 'Cask::DSL'
		repr: dsl.token
		map_data: values
	}
}

fn cask_dsl_map_bools(value ruby.Value) map[string]bool {
	mut result := map[string]bool{}
	for key, raw in value.map_data {
		result[key] = cask_dsl_value_bool(raw, false)
	}
	return result
}

pub fn cask_dsl_from_value(value ruby.Value) !CaskDSL {
	if value.type_name != 'Cask::DSL' {
		return error('expected Cask::DSL, got ${value.type_name}')
	}
	cask := value.map_data['cask'] or { ruby.object_value('Cask', value.as_string()) }
	mut dsl := new_cask_dsl(cask)
	dsl.token = (value.map_data['token'] or { ruby.string_value(value.as_string()) }).as_string()
	dsl.artifacts = artifact_set_from_value(value.map_data['artifacts'] or { artifact_set_value(new_artifact_set([]ruby.Value{})) })!
	dsl.no_autobump_message = value.map_data['no_autobump_message'] or { cask_dsl_nil() }
	dsl.deprecation_date = (value.map_data['deprecation_date'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.deprecation_reason = value.map_data['deprecation_reason'] or { cask_dsl_nil() }
	dsl.deprecation_replacement_cask = (value.map_data['deprecation_replacement_cask'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.deprecation_replacement_formula = (value.map_data['deprecation_replacement_formula'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.deprecate_args = (value.map_data['deprecate_args'] or { ruby.map_value({}) }).map_data.clone()
	dsl.disable_date = (value.map_data['disable_date'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.disable_reason = value.map_data['disable_reason'] or { cask_dsl_nil() }
	dsl.disable_replacement_cask = (value.map_data['disable_replacement_cask'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.disable_replacement_formula = (value.map_data['disable_replacement_formula'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.disable_args = (value.map_data['disable_args'] or { ruby.map_value({}) }).map_data.clone()
	dsl.homepage_browsed = (value.map_data['homepage_browsed'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.on_system_block_min_os = (value.map_data['on_system_block_min_os'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.depends_on_set_in_block = cask_dsl_value_bool(value.map_data['depends_on_set_in_block'] or { ruby.bool_value(false) }, false)
	dsl.deprecated = cask_dsl_value_bool(value.map_data['deprecated'] or { ruby.bool_value(false) }, false)
	dsl.disabled = cask_dsl_value_bool(value.map_data['disabled'] or { ruby.bool_value(false) }, false)
	dsl.livecheck_defined = cask_dsl_value_bool(value.map_data['livecheck_defined'] or { ruby.bool_value(false) }, false)
	dsl.on_system_blocks_exist = cask_dsl_value_bool(value.map_data['on_system_blocks_exist'] or { ruby.bool_value(false) }, false)
	dsl.on_os_blocks_exist = cask_dsl_value_bool(value.map_data['on_os_blocks_exist'] or { ruby.bool_value(false) }, false)
	dsl.names = (value.map_data['names'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
	if raw := value.map_data['description'] {
		if raw.type_name != 'NilClass' {
			dsl.description = raw.as_string()
			dsl.has_description = true
		}
	}
	if raw := value.map_data['homepage'] {
		if raw.type_name != 'NilClass' {
			dsl.homepage = raw.as_string()
			dsl.has_homepage = true
		}
	}
	for raw in (value.map_data['language_blocks'] or { ruby.array_value([]ruby.Value{}) }).as_array() or { []ruby.Value{} } {
		dsl.language_blocks << cask_language_block_from_value(raw)
	}
	dsl.language_evaluated = cask_dsl_value_bool(value.map_data['language_evaluated'] or { ruby.bool_value(false) }, false)
	dsl.language_eval_value = (value.map_data['language_eval'] or { ruby.string_value('') }).as_string()
	if raw := value.map_data['url'] {
		if raw.type_name != 'NilClass' {
			dsl.url_value = cask_url_from_value(raw)!
			dsl.has_url = true
		}
	}
	if raw := value.map_data['container'] {
		if raw.type_name != 'NilClass' {
			dsl.container_value = dsl_types.cask_container_from_value(raw)!
			dsl.has_container = true
		}
	}
	for raw in (value.map_data['renames'] or { ruby.array_value([]ruby.Value{}) }).as_array() or { []ruby.Value{} } {
		dsl.renames << dsl_types.cask_rename_from_value(raw)!
	}
	if raw := value.map_data['version'] {
		if raw.type_name != 'NilClass' {
			dsl.version_value = dsl_types.cask_version_from_value(raw)!
			dsl.has_version = true
		}
	}
	if raw := value.map_data['sha256'] {
		if raw.type_name != 'NilClass' {
			dsl.sha256_value = raw
			dsl.has_sha256 = true
		}
	}
	if raw := value.map_data['arch'] {
		if raw.type_name != 'NilClass' {
			dsl.arch_value = raw.as_string()
			dsl.has_arch = true
		}
	}
	if raw := value.map_data['os'] {
		if raw.type_name != 'NilClass' {
			dsl.os_value = raw.as_string()
			dsl.has_os = true
		}
	}
	dsl.depends_on_value = dsl_types.cask_depends_on_from_value(value.map_data['depends_on'] or { dsl_types.cask_depends_on_value(dsl_types.CaskDependsOn{}) })!
	if raw := value.map_data['conflicts_with'] {
		if raw.type_name != 'NilClass' {
			dsl.conflicts_with_value = dsl_types.cask_conflicts_with_from_value(raw)!
			dsl.has_conflicts_with = true
		}
	}
	dsl.staged_path_value = (value.map_data['staged_path'] or { ruby.string_value('') }).as_string()
	if caveats := value.map_data['caveats'] {
		dsl.caveats_value = dsl_types.cask_caveats_from_value(caveats)!
	} else {
		dsl.caveats_value.custom = (value.map_data['caveat_texts'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
	}
	if raw := value.map_data['auto_updates'] {
		if raw.type_name == 'Bool' {
			dsl.auto_updates_value = raw.bool_data
			dsl.has_auto_updates = true
		}
	}
	dsl.livecheck_value = value.map_data['livecheck'] or { cask_dsl_nil() }
	dsl.livecheck_strategy = (value.map_data['livecheck_strategy'] or { ruby.string_value('') }).as_string()
	dsl.no_autobump_defined = cask_dsl_value_bool(value.map_data['no_autobump_defined'] or { ruby.bool_value(false) }, false)
	dsl.autobump = cask_dsl_value_bool(value.map_data['autobump'] or { ruby.bool_value(true) }, true)
	dsl.called_in_on_system_block = cask_dsl_value_bool(value.map_data['called_in_on_system_block'] or { ruby.bool_value(false) }, false)
	dsl.called_in_on_os_block = cask_dsl_value_bool(value.map_data['called_in_on_os_block'] or { ruby.bool_value(false) }, false)
	dsl.unique_set = cask_dsl_map_bools(value.map_data['unique_set'] or { ruby.map_value({}) })
	dsl.unique_set_in_block = cask_dsl_map_bools(value.map_data['unique_set_in_block'] or { ruby.map_value({}) })
	return dsl
}

fn cask_dsl_receiver(args []ruby.Value, method string) ?CaskDSL {
	if args.len == 0 {
		_ = method
		return none
	}
	return cask_dsl_from_value(args[0]) or { return none }
}

fn (mut dsl CaskDSL) set_unique(stanza string) ! {
	allow_reassignment := cask_dsl_cask_bool(dsl.cask, 'allow_reassignment', false)
	if !allow_reassignment {
		if dsl.unique_set[stanza] && !dsl.called_in_on_system_block {
			return error("'${stanza}' stanza may only appear once.")
		}
		if dsl.unique_set_in_block[stanza] && dsl.called_in_on_system_block {
			return error("'${stanza}' stanza may only be overridden once.")
		}
	}
	if dsl.called_in_on_system_block {
		dsl.unique_set_in_block[stanza] = true
	}
	dsl.unique_set[stanza] = true
}

fn cask_dsl_system_os(dsl CaskDSL) string {
	configured := cask_dsl_cask_field(dsl.cask, 'system_os')
	if configured.type_name != 'NilClass' {
		value := configured.as_string().trim_left(':').to_lower()
		return if value in ['mac', 'macos', 'darwin'] { 'macos' } else { value }
	}
	return if ruby.kernel_info().name == 'Darwin' { 'macos' } else { 'linux' }
}

fn cask_dsl_system_arch(dsl CaskDSL) string {
	configured := cask_dsl_cask_field(dsl.cask, 'system_arch')
	if configured.type_name != 'NilClass' {
		value := configured.as_string().trim_left(':').to_lower()
		return if value in ['arm', 'arm64', 'aarch64'] { 'arm' } else { 'intel' }
	}
	machine := ruby.run_command('/usr/bin/uname', ['-m']).output.trim_space().to_lower()
	return if machine.contains('arm') || machine.contains('aarch') { 'arm' } else { 'intel' }
}

fn cask_dsl_selected(dsl CaskDSL, arm ruby.Value, intel ruby.Value) ruby.Value {
	return if cask_dsl_system_arch(dsl) == 'arm' { arm } else { intel }
}

fn cask_dsl_apply_language_block(mut dsl CaskDSL, block CaskLanguageBlock) {
	for key, value in block.mutations {
		match key {
			'sha256' {
				dsl.sha256_value = value
				dsl.has_sha256 = value.type_name != 'NilClass'
			}
			'arch' {
				dsl.arch_value = value.as_string()
				dsl.has_arch = value.type_name != 'NilClass'
			}
			'os' {
				dsl.os_value = value.as_string()
				dsl.has_os = value.type_name != 'NilClass'
			}
			'url' {
				if value.type_name == 'NilClass' {
					dsl.has_url = false
				} else {
					dsl.url_value = if value.type_name == 'Cask::URL' {
						cask_url_from_value(value) or { continue }
					} else {
						new_cask_url(value.as_string(), {}) or { continue }
					}
					dsl.has_url = true
				}
			}
			'artifacts' {
				dsl.artifacts = artifact_set_from_value(value) or { continue }
			}
			'version' {
				if value.type_name == 'NilClass' {
					dsl.has_version = false
				} else {
					dsl.version_value = dsl_types.cask_version_from_value(value) or { continue }
					dsl.has_version = true
				}
			}
			'name' {
				dsl.names = value.as_string_array() or { [value.as_string()] }
			}
			'desc' {
				dsl.description = value.as_string()
				dsl.has_description = value.type_name != 'NilClass'
			}
			'homepage' {
				dsl.homepage = value.as_string()
				dsl.has_homepage = value.type_name != 'NilClass'
			}
			'auto_updates' {
				dsl.auto_updates_value = cask_dsl_value_bool(value, false)
				dsl.has_auto_updates = value.type_name == 'Bool'
			}
			else {}
		}
	}
	dsl.language_eval_value = block.result
	dsl.language_evaluated = true
}

pub fn cask_dsl_evaluate_language(mut dsl CaskDSL) !string {
	if dsl.language_evaluated {
		return dsl.language_eval_value
	}
	if dsl.language_blocks.len == 0 {
		dsl.language_evaluated = true
		return ''
	}
	mut default_index := -1
	mut groups := [][]string{}
	for index, block in dsl.language_blocks {
		groups << block.languages
		if block.is_default {
			default_index = index
		}
	}
	if default_index < 0 {
		return error('No default language specified.')
	}
	languages := cask_dsl_config_field(dsl.cask, 'languages').as_string_array() or { []string{} }
	for language in languages {
		locale := homebrew.try_parse_locale(language) or { continue }
		selected := locale.detect(groups) or { continue }
		for block in dsl.language_blocks {
			if block.languages == selected {
				cask_dsl_apply_language_block(mut dsl, block)
				return dsl.language_eval_value
			}
		}
	}
	cask_dsl_apply_language_block(mut dsl, dsl.language_blocks[default_index])
	return dsl.language_eval_value
}

fn cask_dsl_date(value string) !string {
	time.parse_iso8601('${value}T00:00:00Z')!
	return value
}

fn cask_dsl_today(dsl CaskDSL) string {
	configured := cask_dsl_cask_field(dsl.cask, 'today')
	return if configured.type_name != 'NilClass' {
		configured.as_string()
	} else {
		ruby.today_iso()
	}
}

fn cask_dsl_argument_error(method string) ruby.Value {
	return cask_dsl_error('ArgumentError', '${method} requires a Cask::DSL receiver')
}

fn cask_dsl_receiver_or_error(args []ruby.Value, method string) !CaskDSL {
	if args.len == 0 {
		return error('${method} requires a Cask::DSL receiver')
	}
	return cask_dsl_from_value(args[0])
}

fn cask_dsl_optional_string(value string) ruby.Value {
	return if value == '' { cask_dsl_nil() } else { ruby.string_value(value) }
}

fn cask_dsl_positional(args []ruby.Value) []ruby.Value {
	mut values := []ruby.Value{}
	for index in 1 .. args.len {
		if args[index].type_name != 'Hash' {
			values << args[index]
		}
	}
	return values
}

fn (mut dsl CaskDSL) set_no_autobump_value(because ruby.Value) ! {
	reason := cask_dsl_value_string(because)
	if because.type_name == 'Symbol' && reason !in cask_dsl_valid_no_autobump_reasons {
		return error("'because' argument should use valid symbol or a string!")
	}
	if !cask_dsl_cask_bool(dsl.cask, 'allow_reassignment', false) && dsl.no_autobump_defined {
		return error("'no_autobump!' stanza may only appear once.")
	}
	dsl.no_autobump_defined = true
	dsl.no_autobump_message = because
	dsl.autobump = false
}
