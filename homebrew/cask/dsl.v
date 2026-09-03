module cask

import brew_runtime
import homebrew
import homebrew.cask.artifact as cask_artifact
import homebrew.cask.dsl as dsl_types
import time

// Translated from Homebrew/brew `cask/dsl.rb`.
// The original source is retained below until every stub has a typed V body.
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
	mutations  map[string]brew_runtime.Value
	is_default bool
}

pub struct CaskDSL {
pub mut:
	cask                            brew_runtime.Value
	token                           string
	artifacts                       ArtifactSet
	no_autobump_message             brew_runtime.Value
	deprecation_date                string
	deprecation_reason              brew_runtime.Value
	deprecation_replacement_cask    string
	deprecation_replacement_formula string
	deprecate_args                  map[string]brew_runtime.Value
	disable_date                    string
	disable_reason                  brew_runtime.Value
	disable_replacement_cask        string
	disable_replacement_formula     string
	disable_args                    map[string]brew_runtime.Value
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
	sha256_value                    brew_runtime.Value
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
	livecheck_value                 brew_runtime.Value
	livecheck_strategy              string
	no_autobump_defined             bool
	autobump                        bool = true
	called_in_on_system_block       bool
	called_in_on_os_block           bool
	unique_set                      map[string]bool
	unique_set_in_block             map[string]bool
}

fn cask_dsl_nil() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn cask_dsl_error(kind string, message string) brew_runtime.Value {
	return brew_runtime.object_value(kind, message)
}

fn cask_dsl_value_string(value brew_runtime.Value) string {
	return if value.type_name == 'Symbol' {
		value.as_string().trim_left(':')
	} else {
		value.as_string()
	}
}

fn cask_dsl_value_bool(value brew_runtime.Value, fallback bool) bool {
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn cask_dsl_keywords(args []brew_runtime.Value) map[string]brew_runtime.Value {
	for index := args.len - 1; index >= 0; index-- {
		if args[index].type_name == 'Hash' {
			return args[index].map_data.clone()
		}
	}
	return map[string]brew_runtime.Value{}
}

fn cask_dsl_cask_field(cask brew_runtime.Value, key string) brew_runtime.Value {
	if value := cask.map_data[key] {
		return value
	}
	if value := cask.attributes[key] {
		return brew_runtime.string_value(value)
	}
	return cask_dsl_nil()
}

fn cask_dsl_cask_bool(cask brew_runtime.Value, key string, fallback bool) bool {
	value := cask_dsl_cask_field(cask, key)
	if value.type_name == 'Bool' {
		return value.bool_data
	}
	if value.type_name in ['String', 'Symbol'] && value.as_string() != '' {
		return value.as_string().bool()
	}
	return fallback
}

fn cask_dsl_config_field(cask brew_runtime.Value, key string) brew_runtime.Value {
	config := cask_dsl_cask_field(cask, 'config')
	if config.type_name == 'Hash' {
		return config.map_data[key] or { cask_dsl_nil() }
	}
	return cask_dsl_nil()
}

pub fn new_cask_dsl(cask brew_runtime.Value) CaskDSL {
	token_value := cask_dsl_cask_field(cask, 'token')
	token := if token_value.type_name == 'NilClass' {
		cask.as_string()
	} else {
		token_value.as_string()
	}
	return CaskDSL{
		cask: cask
		token: token
		artifacts: new_artifact_set([]brew_runtime.Value{})
		depends_on_value: dsl_types.CaskDependsOn{}
		caveats_value: dsl_types.new_cask_caveats(cask)
		livecheck_value: homebrew.livecheck_dsl_value(homebrew.new_livecheck_dsl(cask))
	}
}

fn cask_language_block_value(block CaskLanguageBlock) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Cask::DSL::LanguageBlock'
		repr: block.result
		map_data: {
			'languages': brew_runtime.string_array_value(block.languages)
			'result':    brew_runtime.string_value(block.result)
			'mutations': brew_runtime.map_value(block.mutations)
			'default':   brew_runtime.bool_value(block.is_default)
		}
	}
}

fn cask_language_block_from_value(value brew_runtime.Value) CaskLanguageBlock {
	return CaskLanguageBlock{
		languages: (value.map_data['languages'] or { brew_runtime.string_array_value([]) }).as_string_array() or { []string{} }
		result: (value.map_data['result'] or { brew_runtime.string_value(value.as_string()) }).as_string()
		mutations: (value.map_data['mutations'] or { brew_runtime.map_value({}) }).map_data.clone()
		is_default: cask_dsl_value_bool(value.map_data['default'] or { brew_runtime.bool_value(false) }, false)
	}
}

pub fn cask_dsl_value(dsl CaskDSL) brew_runtime.Value {
	mut rename_values := []brew_runtime.Value{}
	for rename in dsl.renames {
		rename_values << dsl_types.cask_rename_value(rename)
	}
	mut values := {
		'cask':                            dsl.cask
		'token':                           brew_runtime.string_value(dsl.token)
		'artifacts':                       artifact_set_value(dsl.artifacts)
		'no_autobump_message':             dsl.no_autobump_message
		'deprecation_date':                if dsl.deprecation_date == '' {
			cask_dsl_nil()
		} else {
			brew_runtime.object_value('Date', dsl.deprecation_date)
		}
		'deprecation_reason':              dsl.deprecation_reason
		'deprecation_replacement_cask':    if dsl.deprecation_replacement_cask == '' {
			cask_dsl_nil()
		} else {
			brew_runtime.string_value(dsl.deprecation_replacement_cask)
		}
		'deprecation_replacement_formula': if dsl.deprecation_replacement_formula == '' {
			cask_dsl_nil()
		} else {
			brew_runtime.string_value(dsl.deprecation_replacement_formula)
		}
		'deprecate_args':                  if dsl.deprecate_args.len == 0 {
			cask_dsl_nil()
		} else {
			brew_runtime.map_value(dsl.deprecate_args)
		}
		'disable_date':                    if dsl.disable_date == '' {
			cask_dsl_nil()
		} else {
			brew_runtime.object_value('Date', dsl.disable_date)
		}
		'disable_reason':                  dsl.disable_reason
		'disable_replacement_cask':        if dsl.disable_replacement_cask == '' {
			cask_dsl_nil()
		} else {
			brew_runtime.string_value(dsl.disable_replacement_cask)
		}
		'disable_replacement_formula':     if dsl.disable_replacement_formula == '' {
			cask_dsl_nil()
		} else {
			brew_runtime.string_value(dsl.disable_replacement_formula)
		}
		'disable_args':                    if dsl.disable_args.len == 0 {
			cask_dsl_nil()
		} else {
			brew_runtime.map_value(dsl.disable_args)
		}
		'homepage_browsed':                if dsl.homepage_browsed == '' {
			cask_dsl_nil()
		} else {
			brew_runtime.object_value('Date', dsl.homepage_browsed)
		}
		'on_system_block_min_os':          if dsl.on_system_block_min_os == '' {
			cask_dsl_nil()
		} else {
			brew_runtime.object_value('MacOSVersion', dsl.on_system_block_min_os)
		}
		'depends_on_set_in_block':         brew_runtime.bool_value(dsl.depends_on_set_in_block)
		'deprecated':                      brew_runtime.bool_value(dsl.deprecated)
		'disabled':                        brew_runtime.bool_value(dsl.disabled)
		'livecheck_defined':               brew_runtime.bool_value(dsl.livecheck_defined)
		'on_system_blocks_exist':          brew_runtime.bool_value(dsl.on_system_blocks_exist)
		'on_os_blocks_exist':              brew_runtime.bool_value(dsl.on_os_blocks_exist)
		'names':                           brew_runtime.string_array_value(dsl.names)
		'description':                     if dsl.has_description {
			brew_runtime.string_value(dsl.description)
		} else {
			cask_dsl_nil()
		}
		'homepage':                        if dsl.has_homepage {
			brew_runtime.string_value(dsl.homepage)
		} else {
			cask_dsl_nil()
		}
		'language_blocks':                 brew_runtime.array_value(dsl.language_blocks.map(cask_language_block_value(it)))
		'language_eval':                   if dsl.language_evaluated {
			brew_runtime.string_value(dsl.language_eval_value)
		} else {
			cask_dsl_nil()
		}
		'language_evaluated':              brew_runtime.bool_value(dsl.language_evaluated)
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
		'renames':                         brew_runtime.array_value(rename_values)
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
			brew_runtime.string_value(dsl.arch_value)
		} else {
			cask_dsl_nil()
		}
		'os':                              if dsl.has_os {
			brew_runtime.string_value(dsl.os_value)
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
			brew_runtime.object_value('Pathname', dsl.staged_path_value)
		}
		'caveats':                         dsl_types.cask_caveats_value(dsl.caveats_value)
		'caveat_texts':                    brew_runtime.string_array_value(dsl.caveats_value.custom)
		'auto_updates':                    if dsl.has_auto_updates {
			brew_runtime.bool_value(dsl.auto_updates_value)
		} else {
			cask_dsl_nil()
		}
		'livecheck':                       dsl.livecheck_value
		'livecheck_strategy':              brew_runtime.string_value(dsl.livecheck_strategy)
		'no_autobump_defined':             brew_runtime.bool_value(dsl.no_autobump_defined)
		'autobump':                        brew_runtime.bool_value(dsl.autobump)
		'called_in_on_system_block':       brew_runtime.bool_value(dsl.called_in_on_system_block)
		'called_in_on_os_block':           brew_runtime.bool_value(dsl.called_in_on_os_block)
	}
	mut unique := map[string]brew_runtime.Value{}
	for key, set in dsl.unique_set {
		unique[key] = brew_runtime.bool_value(set)
	}
	values['unique_set'] = brew_runtime.map_value(unique)
	mut in_block := map[string]brew_runtime.Value{}
	for key, set in dsl.unique_set_in_block {
		in_block[key] = brew_runtime.bool_value(set)
	}
	values['unique_set_in_block'] = brew_runtime.map_value(in_block)
	return brew_runtime.Value{
		type_name: 'Cask::DSL'
		repr: dsl.token
		map_data: values
	}
}

fn cask_dsl_map_bools(value brew_runtime.Value) map[string]bool {
	mut result := map[string]bool{}
	for key, raw in value.map_data {
		result[key] = cask_dsl_value_bool(raw, false)
	}
	return result
}

pub fn cask_dsl_from_value(value brew_runtime.Value) !CaskDSL {
	if value.type_name != 'Cask::DSL' {
		return error('expected Cask::DSL, got ${value.type_name}')
	}
	cask := value.map_data['cask'] or { brew_runtime.object_value('Cask', value.as_string()) }
	mut dsl := new_cask_dsl(cask)
	dsl.token = (value.map_data['token'] or { brew_runtime.string_value(value.as_string()) }).as_string()
	dsl.artifacts = artifact_set_from_value(value.map_data['artifacts'] or { artifact_set_value(new_artifact_set([]brew_runtime.Value{})) })!
	dsl.no_autobump_message = value.map_data['no_autobump_message'] or { cask_dsl_nil() }
	dsl.deprecation_date = (value.map_data['deprecation_date'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.deprecation_reason = value.map_data['deprecation_reason'] or { cask_dsl_nil() }
	dsl.deprecation_replacement_cask = (value.map_data['deprecation_replacement_cask'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.deprecation_replacement_formula = (value.map_data['deprecation_replacement_formula'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.deprecate_args = (value.map_data['deprecate_args'] or { brew_runtime.map_value({}) }).map_data.clone()
	dsl.disable_date = (value.map_data['disable_date'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.disable_reason = value.map_data['disable_reason'] or { cask_dsl_nil() }
	dsl.disable_replacement_cask = (value.map_data['disable_replacement_cask'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.disable_replacement_formula = (value.map_data['disable_replacement_formula'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.disable_args = (value.map_data['disable_args'] or { brew_runtime.map_value({}) }).map_data.clone()
	dsl.homepage_browsed = (value.map_data['homepage_browsed'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.on_system_block_min_os = (value.map_data['on_system_block_min_os'] or { cask_dsl_nil() }).as_string().replace('nil', '')
	dsl.depends_on_set_in_block = cask_dsl_value_bool(value.map_data['depends_on_set_in_block'] or { brew_runtime.bool_value(false) }, false)
	dsl.deprecated = cask_dsl_value_bool(value.map_data['deprecated'] or { brew_runtime.bool_value(false) }, false)
	dsl.disabled = cask_dsl_value_bool(value.map_data['disabled'] or { brew_runtime.bool_value(false) }, false)
	dsl.livecheck_defined = cask_dsl_value_bool(value.map_data['livecheck_defined'] or { brew_runtime.bool_value(false) }, false)
	dsl.on_system_blocks_exist = cask_dsl_value_bool(value.map_data['on_system_blocks_exist'] or { brew_runtime.bool_value(false) }, false)
	dsl.on_os_blocks_exist = cask_dsl_value_bool(value.map_data['on_os_blocks_exist'] or { brew_runtime.bool_value(false) }, false)
	dsl.names = (value.map_data['names'] or { brew_runtime.string_array_value([]) }).as_string_array() or { []string{} }
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
	for raw in (value.map_data['language_blocks'] or { brew_runtime.array_value([]brew_runtime.Value{}) }).as_array() or { []brew_runtime.Value{} } {
		dsl.language_blocks << cask_language_block_from_value(raw)
	}
	dsl.language_evaluated = cask_dsl_value_bool(value.map_data['language_evaluated'] or { brew_runtime.bool_value(false) }, false)
	dsl.language_eval_value = (value.map_data['language_eval'] or { brew_runtime.string_value('') }).as_string()
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
	for raw in (value.map_data['renames'] or { brew_runtime.array_value([]brew_runtime.Value{}) }).as_array() or { []brew_runtime.Value{} } {
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
	dsl.staged_path_value = (value.map_data['staged_path'] or { brew_runtime.string_value('') }).as_string()
	if caveats := value.map_data['caveats'] {
		dsl.caveats_value = dsl_types.cask_caveats_from_value(caveats)!
	} else {
		dsl.caveats_value.custom = (value.map_data['caveat_texts'] or { brew_runtime.string_array_value([]) }).as_string_array() or { []string{} }
	}
	if raw := value.map_data['auto_updates'] {
		if raw.type_name == 'Bool' {
			dsl.auto_updates_value = raw.bool_data
			dsl.has_auto_updates = true
		}
	}
	dsl.livecheck_value = value.map_data['livecheck'] or { cask_dsl_nil() }
	dsl.livecheck_strategy = (value.map_data['livecheck_strategy'] or { brew_runtime.string_value('') }).as_string()
	dsl.no_autobump_defined = cask_dsl_value_bool(value.map_data['no_autobump_defined'] or { brew_runtime.bool_value(false) }, false)
	dsl.autobump = cask_dsl_value_bool(value.map_data['autobump'] or { brew_runtime.bool_value(true) }, true)
	dsl.called_in_on_system_block = cask_dsl_value_bool(value.map_data['called_in_on_system_block'] or { brew_runtime.bool_value(false) }, false)
	dsl.called_in_on_os_block = cask_dsl_value_bool(value.map_data['called_in_on_os_block'] or { brew_runtime.bool_value(false) }, false)
	dsl.unique_set = cask_dsl_map_bools(value.map_data['unique_set'] or { brew_runtime.map_value({}) })
	dsl.unique_set_in_block = cask_dsl_map_bools(value.map_data['unique_set_in_block'] or { brew_runtime.map_value({}) })
	return dsl
}

fn cask_dsl_receiver(args []brew_runtime.Value, method string) ?CaskDSL {
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
	return if brew_runtime.kernel_info().name == 'Darwin' { 'macos' } else { 'linux' }
}

fn cask_dsl_system_arch(dsl CaskDSL) string {
	configured := cask_dsl_cask_field(dsl.cask, 'system_arch')
	if configured.type_name != 'NilClass' {
		value := configured.as_string().trim_left(':').to_lower()
		return if value in ['arm', 'arm64', 'aarch64'] { 'arm' } else { 'intel' }
	}
	machine := brew_runtime.run_command('/usr/bin/uname', ['-m']).output.trim_space().to_lower()
	return if machine.contains('arm') || machine.contains('aarch') { 'arm' } else { 'intel' }
}

fn cask_dsl_selected(dsl CaskDSL, arm brew_runtime.Value, intel brew_runtime.Value) brew_runtime.Value {
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
		brew_runtime.today_iso()
	}
}

fn cask_dsl_argument_error(method string) brew_runtime.Value {
	return cask_dsl_error('ArgumentError', '${method} requires a Cask::DSL receiver')
}

fn cask_dsl_receiver_or_error(args []brew_runtime.Value, method string) !CaskDSL {
	if args.len == 0 {
		return error('${method} requires a Cask::DSL receiver')
	}
	return cask_dsl_from_value(args[0])
}

fn cask_dsl_optional_string(value string) brew_runtime.Value {
	return if value == '' { cask_dsl_nil() } else { brew_runtime.string_value(value) }
}

fn cask_dsl_positional(args []brew_runtime.Value) []brew_runtime.Value {
	mut values := []brew_runtime.Value{}
	for index in 1 .. args.len {
		if args[index].type_name != 'Hash' {
			values << args[index]
		}
	}
	return values
}

fn (mut dsl CaskDSL) set_no_autobump_value(because brew_runtime.Value) ! {
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

// Ruby attr_reader `attr_reader :cask` at line 142.
pub fn ruby_dsl_l142_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'cask') or { return cask_dsl_argument_error('cask') }
	return dsl.cask
}

// Ruby attr_reader `attr_reader :token` at line 145.
pub fn ruby_dsl_l145_d2_token(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'token') or { return cask_dsl_argument_error('token') }
	return brew_runtime.string_value(dsl.token)
}

// Ruby attr_reader `attr_reader :no_autobump_message` at line 148.
pub fn ruby_dsl_l148_d3_no_autobump_message(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'no_autobump_message') or { return cask_dsl_argument_error('no_autobump_message') }
	return dsl.no_autobump_message
}

// Ruby attr_reader `attr_reader :artifacts` at line 151.
pub fn ruby_dsl_l151_d4_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'artifacts') or { return cask_dsl_argument_error('artifacts') }
	return artifact_set_value(dsl.artifacts)
}

// Ruby attr_reader `attr_reader :deprecation_date` at line 154.
pub fn ruby_dsl_l154_d5_deprecation_date(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'deprecation_date') or { return cask_dsl_argument_error('deprecation_date') }
	return if dsl.deprecation_date == '' {
		cask_dsl_nil()
	} else {
		brew_runtime.object_value('Date', dsl.deprecation_date)
	}
}

// Ruby attr_reader `attr_reader :deprecation_reason` at line 157.
pub fn ruby_dsl_l157_d6_deprecation_reason(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'deprecation_reason') or { return cask_dsl_argument_error('deprecation_reason') }
	return dsl.deprecation_reason
}

// Ruby attr_reader `attr_reader :deprecation_replacement_cask` at line 160.
pub fn ruby_dsl_l160_d7_deprecation_replacement_cask(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'deprecation_replacement_cask') or { return cask_dsl_argument_error('deprecation_replacement_cask') }
	return cask_dsl_optional_string(dsl.deprecation_replacement_cask)
}

// Ruby attr_reader `attr_reader :deprecation_replacement_formula` at line 163.
pub fn ruby_dsl_l163_d8_deprecation_replacement_formula(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'deprecation_replacement_formula') or { return cask_dsl_argument_error('deprecation_replacement_formula') }
	return cask_dsl_optional_string(dsl.deprecation_replacement_formula)
}

// Ruby attr_reader `attr_reader :deprecate_args` at line 166.
pub fn ruby_dsl_l166_d9_deprecate_args(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'deprecate_args') or { return cask_dsl_argument_error('deprecate_args') }
	return if dsl.deprecate_args.len == 0 {
		cask_dsl_nil()
	} else {
		brew_runtime.map_value(dsl.deprecate_args)
	}
}

// Ruby attr_reader `attr_reader :disable_date` at line 169.
pub fn ruby_dsl_l169_d10_disable_date(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'disable_date') or { return cask_dsl_argument_error('disable_date') }
	return if dsl.disable_date == '' {
		cask_dsl_nil()
	} else {
		brew_runtime.object_value('Date', dsl.disable_date)
	}
}

// Ruby attr_reader `attr_reader :disable_reason` at line 172.
pub fn ruby_dsl_l172_d11_disable_reason(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'disable_reason') or { return cask_dsl_argument_error('disable_reason') }
	return dsl.disable_reason
}

// Ruby attr_reader `attr_reader :disable_replacement_cask` at line 175.
pub fn ruby_dsl_l175_d12_disable_replacement_cask(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'disable_replacement_cask') or { return cask_dsl_argument_error('disable_replacement_cask') }
	return cask_dsl_optional_string(dsl.disable_replacement_cask)
}

// Ruby attr_reader `attr_reader :disable_replacement_formula` at line 178.
pub fn ruby_dsl_l178_d13_disable_replacement_formula(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'disable_replacement_formula') or { return cask_dsl_argument_error('disable_replacement_formula') }
	return cask_dsl_optional_string(dsl.disable_replacement_formula)
}

// Ruby attr_reader `attr_reader :homepage_browsed` at line 181.
pub fn ruby_dsl_l181_d14_homepage_browsed(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'homepage_browsed') or { return cask_dsl_argument_error('homepage_browsed') }
	return if dsl.homepage_browsed == '' {
		cask_dsl_nil()
	} else {
		brew_runtime.object_value('Date', dsl.homepage_browsed)
	}
}

// Ruby attr_reader `attr_reader :disable_args` at line 184.
pub fn ruby_dsl_l184_d15_disable_args(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'disable_args') or { return cask_dsl_argument_error('disable_args') }
	return if dsl.disable_args.len == 0 {
		cask_dsl_nil()
	} else {
		brew_runtime.map_value(dsl.disable_args)
	}
}

// Ruby attr_reader `attr_reader :on_system_block_min_os` at line 187.
pub fn ruby_dsl_l187_d16_on_system_block_min_os(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'on_system_block_min_os') or { return cask_dsl_argument_error('on_system_block_min_os') }
	return if dsl.on_system_block_min_os == '' {
		cask_dsl_nil()
	} else {
		brew_runtime.object_value('MacOSVersion', dsl.on_system_block_min_os)
	}
}

// Ruby method `initialize(cask)` at line 190.
pub fn ruby_dsl_l190_d17_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return cask_dsl_error('ArgumentError', 'Cask::DSL#initialize requires a cask')
	}
	return cask_dsl_value(new_cask_dsl(args[0]))
}

// Ruby method `depends_on_set_in_block? = @depends_on_set_in_block` at line 249.
pub fn ruby_dsl_l249_d18_depends_on_set_in_block(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'depends_on_set_in_block?') or { return cask_dsl_argument_error('depends_on_set_in_block?') }
	return brew_runtime.bool_value(dsl.depends_on_set_in_block)
}

// Ruby method `deprecated? = @deprecated` at line 252.
pub fn ruby_dsl_l252_d19_deprecated(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'deprecated?') or { return cask_dsl_argument_error('deprecated?') }
	return brew_runtime.bool_value(dsl.deprecated)
}

// Ruby method `disabled? = @disabled` at line 255.
pub fn ruby_dsl_l255_d20_disabled(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'disabled?') or { return cask_dsl_argument_error('disabled?') }
	return brew_runtime.bool_value(dsl.disabled)
}

// Ruby method `livecheck_defined? = @livecheck_defined` at line 258.
pub fn ruby_dsl_l258_d21_livecheck_defined(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'livecheck_defined?') or { return cask_dsl_argument_error('livecheck_defined?') }
	return brew_runtime.bool_value(dsl.livecheck_defined)
}

// Ruby method `on_system_blocks_exist? = @on_system_blocks_exist` at line 261.
pub fn ruby_dsl_l261_d22_on_system_blocks_exist(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'on_system_blocks_exist?') or { return cask_dsl_argument_error('on_system_blocks_exist?') }
	return brew_runtime.bool_value(dsl.on_system_blocks_exist)
}

// Ruby method `on_os_blocks_exist? = @on_os_blocks_exist` at line 264.
pub fn ruby_dsl_l264_d23_on_os_blocks_exist(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'on_os_blocks_exist?') or { return cask_dsl_argument_error('on_os_blocks_exist?') }
	return brew_runtime.bool_value(dsl.on_os_blocks_exist)
}

// Ruby method `name(*args)` at line 278.
pub fn ruby_dsl_l278_d24_name(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'name') or { return cask_dsl_argument_error('name') }
	positionals := cask_dsl_positional(args)
	if positionals.len == 0 {
		return brew_runtime.string_array_value(dsl.names)
	}
	for raw in positionals {
		if raw.type_name == 'Array' {
			dsl.names << raw.as_string_array() or { raw.as_array() or { []brew_runtime.Value{} }.map(it.as_string()) }
		} else {
			dsl.names << raw.as_string()
		}
	}
	return cask_dsl_value(dsl)
}

// Ruby method `desc(description = nil)` at line 294.
pub fn ruby_dsl_l294_d25_desc(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'desc') or { return cask_dsl_argument_error('desc') }
	positionals := cask_dsl_positional(args)
	if positionals.len == 0 || positionals[0].type_name == 'NilClass' {
		return if dsl.has_description {
			brew_runtime.string_value(dsl.description)
		} else {
			cask_dsl_nil()
		}
	}
	dsl.set_unique('desc') or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	dsl.description = positionals[0].as_string()
	dsl.has_description = true
	return cask_dsl_value(dsl)
}

// Ruby method `set_unique_stanza(stanza, should_return, &_block)` at line 307.
pub fn ruby_dsl_l307_d26_set_unique_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'set_unique_stanza') or { return cask_dsl_argument_error('set_unique_stanza') }
	if args.len < 3 {
		return cask_dsl_error('ArgumentError', 'set_unique_stanza requires stanza and should_return')
	}
	stanza := cask_dsl_value_string(args[1])
	should_return := cask_dsl_value_bool(args[2], false)
	if should_return {
		return cask_dsl_cask_field(cask_dsl_value(dsl), stanza)
	}
	if args.len < 4 {
		return cask_dsl_error('ArgumentError', 'set_unique_stanza requires a block result')
	}
	dsl.set_unique(stanza) or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	value := args[3]
	match stanza {
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
			dsl.has_auto_updates = value.type_name != 'NilClass'
		}
		else {}
	}
	return cask_dsl_value(dsl)
}

// Ruby method `homepage(homepage = nil, browsed: nil)` at line 341.
pub fn ruby_dsl_l341_d27_homepage(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'homepage') or { return cask_dsl_argument_error('homepage') }
	positionals := cask_dsl_positional(args)
	keywords := cask_dsl_keywords(args)
	if positionals.len == 0 || positionals[0].type_name == 'NilClass' {
		if browsed := keywords['browsed'] {
			if browsed.type_name != 'NilClass' {
				return cask_dsl_error('CaskInvalidError', '`browsed` requires a homepage URL')
			}
		}
		return if dsl.has_homepage {
			brew_runtime.string_value(dsl.homepage)
		} else {
			cask_dsl_nil()
		}
	}
	dsl.set_unique('homepage') or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	if browsed := keywords['browsed'] {
		if browsed.type_name != 'NilClass' {
			dsl.homepage_browsed = cask_dsl_date(browsed.as_string()) or {
				return cask_dsl_error('CaskInvalidError', err.msg())
			}
		}
	}
	dsl.homepage = positionals[0].as_string()
	dsl.has_homepage = true
	return cask_dsl_value(dsl)
}

// Ruby method `language(*args, default: false, &block)` at line 360.
pub fn ruby_dsl_l360_d28_language(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'language') or { return cask_dsl_argument_error('language') }
	if args.len == 1 {
		result := cask_dsl_evaluate_language(mut dsl) or {
			return cask_dsl_error('CaskInvalidError', err.msg())
		}
		return brew_runtime.string_value(result)
	}
	keywords := cask_dsl_keywords(args)
	is_default := cask_dsl_value_bool(keywords['default'] or { brew_runtime.bool_value(false) }, false)
	mut languages := []string{}
	mut block_value := cask_dsl_nil()
	for index in 1 .. args.len {
		raw := args[index]
		if raw.type_name == 'Hash' {
			continue
		}
		if raw.type_name == 'Cask::DSL::LanguageBlock' || raw.type_name == 'Proc' {
			block_value = raw
		} else if raw.type_name == 'Array' {
			languages << raw.as_string_array() or { []string{} }
		} else {
			languages << raw.as_string()
		}
	}
	if languages.len == 0 {
		result := cask_dsl_evaluate_language(mut dsl) or {
			return cask_dsl_error('CaskInvalidError', err.msg())
		}
		return brew_runtime.string_value(result)
	}
	if block_value.type_name == 'NilClass' {
		return cask_dsl_error('CaskInvalidError', 'No block given to language stanza.')
	}
	if is_default && !cask_dsl_cask_bool(dsl.cask, 'allow_reassignment', false) {
		for existing in dsl.language_blocks {
			if existing.is_default {
				return cask_dsl_error('CaskInvalidError', 'Only one default language may be defined.')
			}
		}
	}
	mut block := cask_language_block_from_value(block_value)
	block = CaskLanguageBlock{
		...block
		languages: languages
		is_default: is_default
	}
	dsl.language_blocks << block
	return cask_dsl_value(dsl)
}

// Ruby method `language_eval` at line 380.
pub fn ruby_dsl_l380_d29_language_eval(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'language_eval') or { return cask_dsl_argument_error('language_eval') }
	result := cask_dsl_evaluate_language(mut dsl) or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	return if result == '' && dsl.language_blocks.len == 0 {
		cask_dsl_nil()
	} else {
		brew_runtime.string_value(result)
	}
}

// Ruby method `languages` at line 407.
pub fn ruby_dsl_l407_d30_languages(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'languages') or { return cask_dsl_argument_error('languages') }
	mut result := []string{}
	for block in dsl.language_blocks {
		result << block.languages
	}
	return brew_runtime.string_array_value(result)
}

// Ruby method `language_groups` at line 412.
pub fn ruby_dsl_l412_d31_language_groups(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'language_groups') or { return cask_dsl_argument_error('language_groups') }
	return brew_runtime.array_value(dsl.language_blocks.map(brew_runtime.string_array_value(it.languages)))
}

// Ruby method `default_language_group` at line 417.
pub fn ruby_dsl_l417_d32_default_language_group(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'default_language_group') or { return cask_dsl_argument_error('default_language_group') }
	for block in dsl.language_blocks {
		if block.is_default {
			return brew_runtime.string_array_value(block.languages)
		}
	}
	return cask_dsl_nil()
}

// Ruby method `url(uri = nil, **options)` at line 434.
pub fn ruby_dsl_l434_d33_url(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'url') or { return cask_dsl_argument_error('url') }
	positionals := cask_dsl_positional(args)
	if positionals.len == 0 || positionals[0].type_name == 'NilClass' {
		return if dsl.has_url { cask_url_value(dsl.url_value) } else { cask_dsl_nil() }
	}
	dsl.set_unique('url') or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	dsl.url_value = new_cask_url(positionals[0].as_string(), cask_dsl_keywords(args)) or {
		return cask_dsl_error('CaskInvalidError', err.msg())
	}
	dsl.has_url = true
	return cask_dsl_value(dsl)
}

// Ruby method `container(nested: nil, type: nil)` at line 464.
pub fn ruby_dsl_l464_d34_container(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'container') or { return cask_dsl_argument_error('container') }
	keywords := cask_dsl_keywords(args)
	nested_raw := keywords['nested'] or { cask_dsl_nil() }
	type_raw := keywords['type'] or { cask_dsl_nil() }
	if nested_raw.type_name == 'NilClass' && type_raw.type_name == 'NilClass' {
		return if dsl.has_container {
			dsl_types.cask_container_value(dsl.container_value)
		} else {
			cask_dsl_nil()
		}
	}
	dsl.set_unique('container') or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	nested := if nested_raw.type_name == 'NilClass' { none } else { nested_raw.as_string() }
	kind := if type_raw.type_name == 'NilClass' { none } else { cask_dsl_value_string(type_raw) }
	dsl.container_value = dsl_types.new_cask_container(nested, kind) or {
		return cask_dsl_error('CaskInvalidError', err.msg())
	}
	dsl.has_container = true
	return cask_dsl_value(dsl)
}

// Ruby method `rename(from = T.unsafe(nil), to = T.unsafe(nil))` at line 486.
pub fn ruby_dsl_l486_d35_rename(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'rename') or { return cask_dsl_argument_error('rename') }
	positionals := cask_dsl_positional(args)
	if positionals.len == 0 || positionals[0].type_name == 'NilClass' {
		return brew_runtime.array_value(dsl.renames.map(dsl_types.cask_rename_value(it)))
	}
	if positionals.len < 2 {
		return cask_dsl_error('ArgumentError', 'rename requires from and to')
	}
	dsl.renames << dsl_types.new_cask_rename(positionals[0].as_string(), positionals[1].as_string())
	return cask_dsl_value(dsl)
}

// Ruby method `version(arg = nil)` at line 503.
pub fn ruby_dsl_l503_d36_version(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'version') or { return cask_dsl_argument_error('version') }
	positionals := cask_dsl_positional(args)
	if positionals.len == 0 || positionals[0].type_name == 'NilClass' {
		return if dsl.has_version {
			dsl_types.cask_version_value(dsl.version_value)
		} else {
			cask_dsl_nil()
		}
	}
	raw := positionals[0]
	if raw.type_name != 'String' && !(raw.type_name == 'Symbol' && cask_dsl_value_string(raw) == 'latest') {
		return cask_dsl_error('CaskInvalidError', "invalid 'version' value: ${raw.repr}")
	}
	dsl.set_unique('version') or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	if raw.type_name == 'Symbol' && cask_dsl_value_string(raw) == 'latest' && !dsl.no_autobump_defined {
		dsl.set_no_autobump_value(brew_runtime.Value{ type_name: 'Symbol', repr: 'latest_version' }) or {
			return cask_dsl_error('CaskInvalidError', err.msg())
		}
	}
	dsl.version_value = dsl_types.new_cask_version(raw) or {
		return cask_dsl_error('CaskInvalidError', err.msg())
	}
	dsl.has_version = true
	return cask_dsl_value(dsl)
}

// Ruby method `sha256(arg = nil, arm: nil, intel: nil, x86_64: nil, x86_64_linux: nil, arm64_linux: nil)` at line 545.
pub fn ruby_dsl_l545_d37_sha256(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'sha256') or { return cask_dsl_argument_error('sha256') }
	positionals := cask_dsl_positional(args)
	keywords := cask_dsl_keywords(args)
	arg := if positionals.len > 0 { positionals[0] } else { cask_dsl_nil() }
	arm := keywords['arm'] or { cask_dsl_nil() }
	intel := keywords['intel'] or { cask_dsl_nil() }
	mut x86 := keywords['x86_64'] or { cask_dsl_nil() }
	x86_linux := keywords['x86_64_linux'] or { cask_dsl_nil() }
	arm_linux := keywords['arm64_linux'] or { cask_dsl_nil() }
	should_return := arg.type_name == 'NilClass' && arm.type_name == 'NilClass' && (intel.type_name == 'NilClass' || x86.type_name == 'NilClass') && x86_linux.type_name == 'NilClass' && arm_linux.type_name == 'NilClass'
	if should_return {
		return if dsl.has_sha256 { dsl.sha256_value } else { cask_dsl_nil() }
	}
	if intel.type_name != 'NilClass' && x86.type_name == 'NilClass' {
		x86 = intel
	}
	dsl.set_unique('sha256') or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	if arm.type_name != 'NilClass' || x86.type_name != 'NilClass' || x86_linux.type_name != 'NilClass' || arm_linux.type_name != 'NilClass' {
		dsl.on_system_blocks_exist = true
	}
	mut selected := arg
	if selected.type_name == 'NilClass' {
		selected = if cask_dsl_system_os(dsl) == 'macos' {
			cask_dsl_selected(dsl, arm, x86)
		} else {
			cask_dsl_selected(dsl, arm_linux, x86_linux)
		}
	}
	if selected.type_name == 'Symbol' && cask_dsl_value_string(selected) == 'no_check' {
		dsl.sha256_value = brew_runtime.Value{ type_name: 'Symbol', repr: 'no_check' }
	} else if selected.type_name == 'String' {
		dsl.sha256_value = brew_runtime.object_value('Checksum', selected.as_string())
	} else if selected.type_name == 'NilClass' {
		dsl.sha256_value = cask_dsl_nil()
	} else {
		return cask_dsl_error('CaskInvalidError', "invalid 'sha256' value: ${selected.repr}")
	}
	dsl.has_sha256 = selected.type_name != 'NilClass'
	return cask_dsl_value(dsl)
}

// Ruby method `arch(arm: nil, intel: nil)` at line 581.
pub fn ruby_dsl_l581_d38_arch(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'arch') or { return cask_dsl_argument_error('arch') }
	keywords := cask_dsl_keywords(args)
	arm := keywords['arm'] or { cask_dsl_nil() }
	intel := keywords['intel'] or { cask_dsl_nil() }
	if arm.type_name == 'NilClass' && intel.type_name == 'NilClass' {
		return if dsl.has_arch { brew_runtime.string_value(dsl.arch_value) } else { cask_dsl_nil() }
	}
	dsl.set_unique('arch') or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	dsl.on_system_blocks_exist = true
	selected := cask_dsl_selected(dsl, arm, intel)
	dsl.arch_value = selected.as_string()
	dsl.has_arch = selected.type_name != 'NilClass'
	return cask_dsl_value(dsl)
}

// Ruby method `os(macos: nil, linux: nil)` at line 606.
pub fn ruby_dsl_l606_d39_os(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'os') or { return cask_dsl_argument_error('os') }
	keywords := cask_dsl_keywords(args)
	macos := keywords['macos'] or { cask_dsl_nil() }
	linux := keywords['linux'] or { cask_dsl_nil() }
	if macos.type_name == 'NilClass' && linux.type_name == 'NilClass' {
		return if dsl.has_os { brew_runtime.string_value(dsl.os_value) } else { cask_dsl_nil() }
	}
	dsl.set_unique('os') or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	dsl.on_system_blocks_exist = true
	selected := if cask_dsl_system_os(dsl) == 'macos' { macos } else { linux }
	dsl.os_value = selected.as_string()
	dsl.has_os = selected.type_name != 'NilClass'
	return cask_dsl_value(dsl)
}

// Ruby method `depends_on(arg = nil, **kwargs)` at line 623.
pub fn ruby_dsl_l623_d40_depends_on(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'depends_on') or { return cask_dsl_argument_error('depends_on') }
	mut kwargs := cask_dsl_keywords(args)
	positionals := cask_dsl_positional(args)
	if dsl.called_in_on_system_block {
		dsl.depends_on_set_in_block = true
	}
	if positionals.len > 0 && positionals[0].type_name != 'NilClass' {
		name := cask_dsl_value_string(positionals[0])
		if name == 'macos' {
			if 'macos' in kwargs || 'maximum_macos' in kwargs {
				return cask_dsl_error('CaskInvalidError', '`depends_on :macos` cannot be combined with another macOS `depends_on`')
			}
			kwargs['macos'] = brew_runtime.Value{ type_name: 'Symbol', repr: 'any' }
		} else if name == 'linux' {
			kwargs['linux'] = brew_runtime.Value{ type_name: 'Symbol', repr: 'any' }
		} else {
			return cask_dsl_error('CaskInvalidError', "invalid 'depends_on' value: ${positionals[0].repr}")
		}
	}
	if kwargs.len == 0 {
		return dsl_types.cask_depends_on_value(dsl.depends_on_value)
	}
	dsl.depends_on_value.load(kwargs, dsl.called_in_on_system_block, dsl.called_in_on_os_block) or {
		return cask_dsl_error('CaskInvalidError', err.msg())
	}
	return cask_dsl_value(dsl)
}

// Ruby method `conflicts_with(**kwargs)` at line 655.
pub fn ruby_dsl_l655_d41_conflicts_with(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'conflicts_with') or { return cask_dsl_argument_error('conflicts_with') }
	kwargs := cask_dsl_keywords(args)
	if kwargs.len == 0 {
		return if dsl.has_conflicts_with {
			dsl_types.cask_conflicts_with_value(dsl.conflicts_with_value)
		} else {
			cask_dsl_nil()
		}
	}
	new_conflicts := dsl_types.new_cask_conflicts_with(kwargs) or {
		return cask_dsl_error('CaskInvalidError', err.msg())
	}
	if dsl.has_conflicts_with {
		dsl.conflicts_with_value.merge(new_conflicts)
	} else {
		dsl.conflicts_with_value = new_conflicts
		dsl.has_conflicts_with = true
	}
	return cask_dsl_value(dsl)
}

// Ruby method `caskroom_path` at line 667.
pub fn ruby_dsl_l667_d42_caskroom_path(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'caskroom_path') or { return cask_dsl_argument_error('caskroom_path') }
	path := cask_dsl_cask_field(dsl.cask, 'caskroom_path')
	return if path.type_name == 'NilClass' {
		brew_runtime.object_value('Pathname', '/opt/homebrew/Caskroom/${dsl.token}')
	} else {
		brew_runtime.object_value('Pathname', path.as_string())
	}
}

// Ruby method `staged_path` at line 675.
pub fn ruby_dsl_l675_d43_staged_path(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'staged_path') or { return cask_dsl_argument_error('staged_path') }
	if dsl.staged_path_value == '' {
		base := ruby_dsl_l667_d42_caskroom_path(cask_dsl_value(dsl)).as_string().trim_right('/')
		version := if dsl.has_version {
			dsl.version_value.raw_version.as_string()
		} else {
			'unknown'
		}
		dsl.staged_path_value = '${base}/${version}'
	}
	return brew_runtime.object_value('Pathname', dsl.staged_path_value)
}

// Ruby method `caveats(*strings, &block)` at line 691.
pub fn ruby_dsl_l691_d44_caveats(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'caveats') or { return cask_dsl_argument_error('caveats') }
	positionals := cask_dsl_positional(args)
	if positionals.len == 0 {
		return dsl_types.ruby_caveats_l51_d5_to_s(dsl_types.cask_caveats_value(dsl.caveats_value))
	}
	for value in positionals {
		dsl.caveats_value = dsl_types.cask_caveats_from_value(dsl_types.ruby_caveats_l80_d9_eval_caveats(dsl_types.cask_caveats_value(dsl.caveats_value), value)) or {
			return cask_dsl_error('CaskInvalidError', err.msg())
		}
	}
	return cask_dsl_value(dsl)
}

// Ruby method `caveats_object = @caveats` at line 705.
pub fn ruby_dsl_l705_d45_caveats_object(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'caveats_object') or { return cask_dsl_argument_error('caveats_object') }
	return dsl_types.cask_caveats_value(dsl.caveats_value)
}

// Ruby method `auto_updates(auto_updates = nil)` at line 711.
pub fn ruby_dsl_l711_d46_auto_updates(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'auto_updates') or { return cask_dsl_argument_error('auto_updates') }
	positionals := cask_dsl_positional(args)
	if positionals.len == 0 || positionals[0].type_name == 'NilClass' {
		return if dsl.has_auto_updates {
			brew_runtime.bool_value(dsl.auto_updates_value)
		} else {
			cask_dsl_nil()
		}
	}
	dsl.set_unique('auto_updates') or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	if positionals[0].type_name != 'Bool' {
		return cask_dsl_error('CaskInvalidError', "invalid 'auto_updates' value: ${positionals[0].repr}")
	}
	dsl.auto_updates_value = positionals[0].bool_data
	dsl.has_auto_updates = true
	return cask_dsl_value(dsl)
}

// Ruby method `livecheck(&block)` at line 719.
pub fn ruby_dsl_l719_d47_livecheck(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'livecheck') or { return cask_dsl_argument_error('livecheck') }
	positionals := cask_dsl_positional(args)
	if positionals.len == 0 {
		return dsl.livecheck_value
	}
	if !cask_dsl_cask_bool(dsl.cask, 'allow_reassignment', false) && dsl.livecheck_defined {
		return cask_dsl_error('CaskInvalidError', "'livecheck' stanza may only appear once.")
	}
	dsl.livecheck_defined = true
	dsl.livecheck_value = positionals[0]
	dsl.livecheck_strategy = (positionals[0].map_data['strategy'] or { brew_runtime.string_value('') }).as_string().trim_left(':')
	if dsl.livecheck_strategy == 'extract_plist' && !dsl.no_autobump_defined {
		dsl.set_no_autobump_value(brew_runtime.Value{ type_name: 'Symbol', repr: 'extract_plist' }) or {
			return cask_dsl_error('CaskInvalidError', err.msg())
		}
	}
	return cask_dsl_value(dsl)
}

// Ruby method `no_autobump!(because:)` at line 736.
pub fn ruby_dsl_l736_d48_no_autobump(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'no_autobump!') or { return cask_dsl_argument_error('no_autobump!') }
	tap := cask_dsl_cask_field(dsl.cask, 'tap')
	if tap.type_name != 'NilClass' && !cask_dsl_value_bool(tap.map_data['official'] or { brew_runtime.bool_value(false) }, false) {
		return cask_dsl_error('CaskInvalidError', "'no_autobump!' can only be used in official Homebrew taps.")
	}
	because := cask_dsl_keywords(args)['because'] or {
		return cask_dsl_error('ArgumentError', "missing keyword: 'because'")
	}
	dsl.set_no_autobump_value(because) or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	return cask_dsl_value(dsl)
}

// Ruby method `autobump?` at line 747.
pub fn ruby_dsl_l747_d49_autobump(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'autobump?') or { return cask_dsl_argument_error('autobump?') }
	return brew_runtime.bool_value(dsl.autobump)
}

// Ruby method `deprecate!(date:, because:, replacement: nil, replacement_formula: nil, replacement_cask: nil)` at line 765.
pub fn ruby_dsl_l765_d50_deprecate(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'deprecate!') or { return cask_dsl_argument_error('deprecate!') }
	kwargs := cask_dsl_keywords(args)
	date := kwargs['date'] or { return cask_dsl_error('ArgumentError', "missing keyword: 'date'") }
	because := kwargs['because'] or { return cask_dsl_error('ArgumentError', "missing keyword: 'because'") }
	replacement := kwargs['replacement'] or { cask_dsl_nil() }
	replacement_formula := kwargs['replacement_formula'] or { cask_dsl_nil() }
	replacement_cask := kwargs['replacement_cask'] or { cask_dsl_nil() }
	mut present := 0
	for raw in [replacement, replacement_formula, replacement_cask] {
		if raw.type_name != 'NilClass' && raw.as_string() != '' { present++ }
	}
	if present > 1 {
		return cask_dsl_error('ArgumentError', 'more than one of replacement, replacement_formula and/or replacement_cask specified!')
	}
	dsl.deprecate_args = {
		'date':                date
		'because':             because
		'replacement_formula': replacement_formula
		'replacement_cask':    replacement_cask
	}
	dsl.deprecation_date = cask_dsl_date(date.as_string()) or { return cask_dsl_error('ArgumentError', err.msg()) }
	if dsl.deprecation_date <= cask_dsl_today(dsl) {
		dsl.deprecation_reason = because
		dsl.deprecation_replacement_formula = if replacement_formula.type_name != 'NilClass' && replacement_formula.as_string() != '' {
			replacement_formula.as_string()
		} else {
			replacement.as_string().replace('nil', '')
		}
		dsl.deprecation_replacement_cask = if replacement_cask.type_name != 'NilClass' && replacement_cask.as_string() != '' {
			replacement_cask.as_string()
		} else {
			replacement.as_string().replace('nil', '')
		}
		dsl.deprecated = true
	}
	return cask_dsl_value(dsl)
}

// Ruby method `disable!(date:, because:, replacement: nil, replacement_formula: nil, replacement_cask: nil)` at line 802.
pub fn ruby_dsl_l802_d51_disable(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'disable!') or { return cask_dsl_argument_error('disable!') }
	kwargs := cask_dsl_keywords(args)
	date := kwargs['date'] or { return cask_dsl_error('ArgumentError', "missing keyword: 'date'") }
	mut because := kwargs['because'] or { return cask_dsl_error('ArgumentError', "missing keyword: 'because'") }
	if because.type_name == 'Symbol' && cask_dsl_value_string(because) == 'unsigned' {
		because = brew_runtime.Value{ type_name: 'Symbol', repr: 'fails_gatekeeper_check' }
	}
	replacement := kwargs['replacement'] or { cask_dsl_nil() }
	replacement_formula := kwargs['replacement_formula'] or { cask_dsl_nil() }
	replacement_cask := kwargs['replacement_cask'] or { cask_dsl_nil() }
	mut present := 0
	for raw in [replacement, replacement_formula, replacement_cask] {
		if raw.type_name != 'NilClass' && raw.as_string() != '' { present++ }
	}
	if present > 1 {
		return cask_dsl_error('ArgumentError', 'more than one of replacement, replacement_formula and/or replacement_cask specified!')
	}
	dsl.disable_args = {
		'date':                date
		'because':             because
		'replacement_formula': replacement_formula
		'replacement_cask':    replacement_cask
	}
	dsl.disable_date = cask_dsl_date(date.as_string()) or { return cask_dsl_error('ArgumentError', err.msg()) }
	if dsl.disable_date > cask_dsl_today(dsl) {
		dsl.deprecation_reason = because
		dsl.deprecation_replacement_formula = if replacement_formula.type_name != 'NilClass' && replacement_formula.as_string() != '' {
			replacement_formula.as_string()
		} else {
			replacement.as_string().replace('nil', '')
		}
		dsl.deprecation_replacement_cask = if replacement_cask.type_name != 'NilClass' && replacement_cask.as_string() != '' {
			replacement_cask.as_string()
		} else {
			replacement.as_string().replace('nil', '')
		}
		dsl.deprecated = true
	} else {
		dsl.disable_reason = because
		dsl.disable_replacement_formula = if replacement_formula.type_name != 'NilClass' && replacement_formula.as_string() != '' {
			replacement_formula.as_string()
		} else {
			replacement.as_string().replace('nil', '')
		}
		dsl.disable_replacement_cask = if replacement_cask.type_name != 'NilClass' && replacement_cask.as_string() != '' {
			replacement_cask.as_string()
		} else {
			replacement.as_string().replace('nil', '')
		}
		dsl.disabled = true
	}
	return cask_dsl_value(dsl)
}

// Ruby define_method `define_method(klass.dsl_key) do |*args, **kwargs|` at line 836.
pub fn ruby_dsl_l836_d52_klass_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'artifact') or { return cask_dsl_argument_error('artifact') }
	if args.len < 2 {
		return cask_dsl_error('ArgumentError', 'artifact stanza requires its DSL key')
	}
	key := cask_dsl_value_string(args[1])
	if key !in cask_dsl_ordinary_artifacts {
		return cask_dsl_error('CaskInvalidError', "invalid '${key}' stanza")
	}
	kwargs := cask_dsl_keywords(args)
	mut artifact_args := []brew_runtime.Value{}
	for index in 2 .. args.len {
		if args[index].type_name != 'Hash' { artifact_args << args[index] }
	}
	if key == 'stage_only' {
		if artifact_args.len != 1 || (artifact_args[0].type_name != 'Bool' && artifact_args[0].as_string() != 'true') || (artifact_args[0].type_name == 'Bool' && !artifact_args[0].bool_data) || kwargs.len > 0 {
			return cask_dsl_error('CaskInvalidError', "'stage_only' takes only a single argument: true")
		}
		for artifact in dsl.artifacts.items {
			if (artifact.attributes['dsl_key'] or { '' }) != 'stage_only' {
				return cask_dsl_error('CaskInvalidError', "'stage_only' must be the only activatable artifact.")
			}
		}
	} else {
		for artifact in dsl.artifacts.items {
			if (artifact.attributes['dsl_key'] or { '' }) == 'stage_only' {
				return cask_dsl_error('CaskInvalidError', "'stage_only' must be the only activatable artifact.")
			}
		}
	}
	mut attributes := {
		'dsl_key':    key
		'cask_token': dsl.token
	}
	if artifact_args.len > 0 {
		attributes['source'] = artifact_args[0].as_string()
	}
	for name, value in kwargs {
		attributes[name] = value.as_string()
	}
	class_name := key.split('_').map(it.title()).join('')
	mut artifact := brew_runtime.structured_value('Cask::Artifact::${class_name}', artifact_args.map(it.as_string()).join(', '), attributes)
	if key == 'pkg' {
		if artifact_args.len == 0 {
			return cask_dsl_error('CaskInvalidError', "invalid 'pkg' stanza: missing path")
		}
		artifact = cask_artifact.pkg_artifact_value(cask_artifact.new_pkg_artifact(dsl.cask, artifact_args[0].as_string(), kwargs) or {
			return cask_dsl_error('CaskInvalidError', "invalid 'pkg' stanza: ${err.msg()}")
		})
	} else if key == 'installer' {
		artifact = cask_artifact.installer_artifact_value(cask_artifact.new_installer_artifact(dsl.cask, kwargs) or { return cask_dsl_error('CaskInvalidError', err.msg()) })
	} else if key == 'app' && artifact_args.len > 0 {
		app_value := cask_artifact.app_artifact_value(cask_artifact.AppArtifact{
			source: artifact_args[0].as_string()
			target: (kwargs['target'] or { brew_runtime.string_value('') }).as_string()
		})
		artifact = brew_runtime.Value{
			...app_value
			attributes: {
				'dsl_key': 'app'
				'source':  app_value.attributes['source'] or { '' }
				'target':  app_value.attributes['target'] or { '' }
			}
		}
	}
	mut items := dsl.artifacts.items.clone()
	items << artifact
	dsl.artifacts = new_artifact_set(items)
	return cask_dsl_value(dsl)
}

// Ruby define_method `define_method(dsl_key) do |&block|` at line 853.
pub fn ruby_dsl_l853_d53_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'artifact block') or { return cask_dsl_argument_error('artifact block') }
	if args.len < 3 {
		return cask_dsl_error('ArgumentError', 'artifact block requires a DSL key and block')
	}
	key := cask_dsl_value_string(args[1])
	artifact := brew_runtime.Value{
		type_name: 'Cask::Artifact::${key.split('_').map(it.title()).join('')}'
		repr: key
		map_data: {
			key: args[2]
		}
		attributes: {
			'dsl_key':    key
			'cask_token': dsl.token
		}
	}
	mut items := dsl.artifacts.items.clone()
	items << artifact
	dsl.artifacts = new_artifact_set(items)
	return cask_dsl_value(dsl)
}

// Ruby define_method `define_method(klass.dsl_key) do |steps = nil, **kwargs, &block|` at line 862.
pub fn ruby_dsl_l862_d54_klass_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'install step artifact') or { return cask_dsl_argument_error('install step artifact') }
	if args.len < 2 {
		return cask_dsl_error('ArgumentError', 'install step artifact requires its DSL key')
	}
	key := cask_dsl_value_string(args[1])
	steps := if args.len > 2 { args[2] } else { brew_runtime.array_value([]brew_runtime.Value{}) }
	artifact := brew_runtime.Value{
		type_name: 'Cask::Artifact::${key.split('_').map(it.title()).join('')}'
		repr: steps.repr
		map_data: {
			'steps': steps
		}
		attributes: {
			'dsl_key':    key
			'cask_token': dsl.token
		}
	}
	mut items := dsl.artifacts.items.clone()
	items << artifact
	dsl.artifacts = new_artifact_set(items)
	return cask_dsl_value(dsl)
}

// Ruby method `method_missing(method, *_args)` at line 875.
pub fn ruby_dsl_l875_d55_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'method_missing') or { return cask_dsl_argument_error('method_missing') }
	method := if args.len > 1 { cask_dsl_value_string(args[1]) } else { '' }
	return cask_dsl_error('NoMethodError', "undefined method '${method}' for Cask '${dsl.token}'")
}

// Ruby method `respond_to_missing?(_method_name, _include_private = false)` at line 880.
pub fn ruby_dsl_l880_d56_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return cask_dsl_argument_error('respond_to_missing?')
	}
	return brew_runtime.bool_value(false)
}

// Ruby method `os_version` at line 885.
pub fn ruby_dsl_l885_d57_os_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return cask_dsl_argument_error('os_version')
	}
	return cask_dsl_nil()
}

// Ruby method `appdir` at line 893.
pub fn ruby_dsl_l893_d58_appdir(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'appdir') or { return cask_dsl_argument_error('appdir') }
	if cask_dsl_cask_bool(dsl.cask, 'generating_hash', false) {
		return brew_runtime.string_value('\$APPDIR')
	}
	configured := cask_dsl_config_field(dsl.cask, 'appdir')
	return brew_runtime.object_value('Pathname', if configured.type_name == 'NilClass' {
		'/Applications'
	} else {
		configured.as_string().trim_right('/')
	})
}

// Ruby method `no_autobump_defined?` at line 902.
pub fn ruby_dsl_l902_d59_no_autobump_defined(args ...brew_runtime.Value) brew_runtime.Value {
	dsl := cask_dsl_receiver(args, 'no_autobump_defined?') or { return cask_dsl_argument_error('no_autobump_defined?') }
	return brew_runtime.bool_value(dsl.no_autobump_defined)
}

// Ruby method `set_no_autobump(because:)` at line 907.
pub fn ruby_dsl_l907_d60_set_no_autobump(args ...brew_runtime.Value) brew_runtime.Value {
	mut dsl := cask_dsl_receiver(args, 'set_no_autobump') or { return cask_dsl_argument_error('set_no_autobump') }
	because := cask_dsl_keywords(args)['because'] or {
		if args.len > 1 {
			args[1]
		} else {
			return cask_dsl_error('ArgumentError', "missing keyword: 'because'")
		}
	}
	dsl.set_no_autobump_value(because) or { return cask_dsl_error('CaskInvalidError', err.msg()) }
	return cask_dsl_value(dsl)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "autobump_constants"
// 5: require "locale"
// 6: require "livecheck"
// 7: require "utils/output"
// 8: require "utils/path"
// 9:
// 10: require "cask/artifact"
// 11: require "cask/artifact_set"
// 12:
// 13: require "cask/caskroom"
// 14: require "cask/exceptions"
// 15:
// 16: require "cask/dsl/base"
// 17: require "cask/dsl/caveats"
// 18: require "cask/dsl/conflicts_with"
// 19: require "cask/dsl/container"
// 20: require "cask/dsl/depends_on"
// 21: require "cask/dsl/postflight"
// 22: require "cask/dsl/preflight"
// 23: require "cask/dsl/rename"
// 24: require "cask/dsl/uninstall_postflight"
// 25: require "cask/dsl/uninstall_preflight"
// 26: require "cask/dsl/version"
// 27:
// 28: require "cask/url"
// 29: require "cask/utils"
// 30:
// 31: require "on_system"
// 32:
// 33: module Cask
// 34:   # Class representing the domain-specific language used for casks.
// 35:   class DSL
// 36:     include ::Utils::Output::Mixin
// 37:     include ::Utils::Path
// 38:
// 39:     ORDINARY_ARTIFACT_CLASSES = [
// 40:       Artifact::Installer,
// 41:       Artifact::App,
// 42:       Artifact::AppImage,
// 43:       Artifact::Artifact,
// 44:       Artifact::AudioUnitPlugin,
// 45:       Artifact::Binary,
// 46:       Artifact::CommandWrapper,
// 47:       Artifact::Colorpicker,
// 48:       Artifact::Dictionary,
// 49:       Artifact::Font,
// 50:       Artifact::GeneratedScript,
// 51:       Artifact::InputMethod,
// 52:       Artifact::InternetPlugin,
// 53:       Artifact::KeyboardLayout,
// 54:       Artifact::Manpage,
// 55:       Artifact::Pkg,
// 56:       Artifact::Prefpane,
// 57:       Artifact::Qlplugin,
// 58:       Artifact::Mdimporter,
// 59:       Artifact::ScreenSaver,
// 60:       Artifact::Service,
// 61:       Artifact::StageOnly,
// 62:       Artifact::Suite,
// 63:       Artifact::VstPlugin,
// 64:       Artifact::Vst3Plugin,
// 65:       Artifact::ZshCompletion,
// 66:       Artifact::FishCompletion,
// 67:       Artifact::BashCompletion,
// 68:       Artifact::GeneratedCompletion,
// 69:       Artifact::Uninstall,
// 70:       Artifact::Zap,
// 71:     ].freeze
// 72:
// 73:     ACTIVATABLE_ARTIFACT_CLASSES = T.let(
// 74:       (ORDINARY_ARTIFACT_CLASSES - [Artifact::StageOnly]).freeze,
// 75:       T::Array[T.class_of(Artifact::AbstractArtifact)],
// 76:     )
// 77:
// 78:     ARTIFACT_BLOCK_CLASSES = [
// 79:       Artifact::PreflightBlock,
// 80:       Artifact::PostflightBlock,
// 81:     ].freeze
// 82:
// 83:     INSTALL_STEP_ARTIFACT_CLASSES = [
// 84:       Artifact::PreflightSteps,
// 85:       Artifact::PostflightSteps,
// 86:       Artifact::UninstallPreflightSteps,
// 87:       Artifact::UninstallPostflightSteps,
// 88:     ].freeze
// 89:
// 90:     DSL_METHODS = T.let(Set.new([
// 91:       :arch,
// 92:       :artifacts,
// 93:       :auto_updates,
// 94:       :caveats,
// 95:       :conflicts_with,
// 96:       :container,
// 97:       :desc,
// 98:       :depends_on,
// 99:       :homepage,
// 100:       :homepage_browsed,
// 101:       :language,
// 102:       :name,
// 103:       :os,
// 104:       :rename,
// 105:       :sha256,
// 106:       :staged_path,
// 107:       :url,
// 108:       :version,
// 109:       :appdir,
// 110:       :deprecate!,
// 111:       :deprecated?,
// 112:       :deprecation_date,
// 113:       :deprecation_reason,
// 114:       :deprecation_replacement_cask,
// 115:       :deprecation_replacement_formula,
// 116:       :deprecate_args,
// 117:       :disable!,
// 118:       :disabled?,
// 119:       :disable_date,
// 120:       :disable_reason,
// 121:       :disable_replacement_cask,
// 122:       :disable_replacement_formula,
// 123:       :disable_args,
// 124:       :livecheck,
// 125:       :livecheck_defined?,
// 126:       :no_autobump!,
// 127:       :autobump?,
// 128:       :no_autobump_message,
// 129:       :on_system_blocks_exist?,
// 130:       :on_os_blocks_exist?,
// 131:       :on_system_block_min_os,
// 132:       :depends_on_set_in_block?,
// 133:       *ORDINARY_ARTIFACT_CLASSES.map(&:dsl_key),
// 134:       *ACTIVATABLE_ARTIFACT_CLASSES.map(&:dsl_key),
// 135:       *ARTIFACT_BLOCK_CLASSES.flat_map { |klass| [klass.dsl_key, klass.uninstall_dsl_key] },
// 136:       *INSTALL_STEP_ARTIFACT_CLASSES.map(&:dsl_key),
// 137:     ]).freeze, T::Set[Symbol])
// 138:
// 139:     include OnSystem::MacOSAndLinux
// 140:
// 141:     sig { returns(Cask) }
// 142:     attr_reader :cask
// 143:
// 144:     sig { returns(String) }
// 145:     attr_reader :token
// 146:
// 147:     sig { returns(T.nilable(T.any(String, Symbol))) }
// 148:     attr_reader :no_autobump_message
// 149:
// 150:     sig { returns(ArtifactSet) }
// 151:     attr_reader :artifacts
// 152:
// 153:     sig { returns(T.nilable(Date)) }
// 154:     attr_reader :deprecation_date
// 155:
// 156:     sig { returns(T.nilable(T.any(String, Symbol))) }
// 157:     attr_reader :deprecation_reason
// 158:
// 159:     sig { returns(T.nilable(String)) }
// 160:     attr_reader :deprecation_replacement_cask
// 161:
// 162:     sig { returns(T.nilable(String)) }
// 163:     attr_reader :deprecation_replacement_formula
// 164:
// 165:     sig { returns(T.nilable(T::Hash[Symbol, T.nilable(T.any(String, Symbol))])) }
// 166:     attr_reader :deprecate_args
// 167:
// 168:     sig { returns(T.nilable(Date)) }
// 169:     attr_reader :disable_date
// 170:
// 171:     sig { returns(T.nilable(T.any(String, Symbol))) }
// 172:     attr_reader :disable_reason
// 173:
// 174:     sig { returns(T.nilable(String)) }
// 175:     attr_reader :disable_replacement_cask
// 176:
// 177:     sig { returns(T.nilable(String)) }
// 178:     attr_reader :disable_replacement_formula
// 179:
// 180:     sig { returns(T.nilable(Date)) }
// 181:     attr_reader :homepage_browsed
// 182:
// 183:     sig { returns(T.nilable(T::Hash[Symbol, T.nilable(T.any(String, Symbol))])) }
// 184:     attr_reader :disable_args
// 185:
// 186:     sig { returns(T.nilable(MacOSVersion)) }
// 187:     attr_reader :on_system_block_min_os
// 188:
// 189:     sig { params(cask: Cask).void }
// 190:     def initialize(cask)
// 191:       # NOTE: `:"@#{stanza}"` variables set by `set_unique_stanza` must be
// 192:       # initialized to `nil`.
// 193:       @arch = T.let(nil, T.nilable(String))
// 194:       @arch_set_in_block = T.let(false, T::Boolean)
// 195:       @artifacts = T.let(ArtifactSet.new, ArtifactSet)
// 196:       @auto_updates = T.let(nil, T.nilable(T::Boolean))
// 197:       @auto_updates_set_in_block = T.let(false, T::Boolean)
// 198:       @autobump = T.let(true, T::Boolean)
// 199:       @called_in_on_system_block = T.let(false, T::Boolean)
// 200:       @called_in_on_os_block = T.let(false, T::Boolean)
// 201:       @cask = cask
// 202:       @caveats = T.let(DSL::Caveats.new(cask), DSL::Caveats)
// 203:       @conflicts_with = T.let(nil, T.nilable(DSL::ConflictsWith))
// 204:       @container = T.let(nil, T.nilable(DSL::Container))
// 205:       @container_set_in_block = T.let(false, T::Boolean)
// 206:       @depends_on = T.let(DSL::DependsOn.new, DSL::DependsOn)
// 207:       @depends_on_set_in_block = T.let(false, T::Boolean)
// 208:       @deprecated = T.let(false, T::Boolean)
// 209:       @deprecation_date = T.let(nil, T.nilable(Date))
// 210:       @deprecation_reason = T.let(nil, T.nilable(T.any(String, Symbol)))
// 211:       @deprecation_replacement_cask = T.let(nil, T.nilable(String))
// 212:       @deprecation_replacement_formula = T.let(nil, T.nilable(String))
// 213:       @deprecate_args = T.let(nil, T.nilable(T::Hash[Symbol, T.nilable(T.any(String, Symbol))]))
// 214:       @desc = T.let(nil, T.nilable(String))
// 215:       @desc_set_in_block = T.let(false, T::Boolean)
// 216:       @disable_date = T.let(nil, T.nilable(Date))
// 217:       @disable_reason = T.let(nil, T.nilable(T.any(String, Symbol)))
// 218:       @disable_replacement_cask = T.let(nil, T.nilable(String))
// 219:       @disable_replacement_formula = T.let(nil, T.nilable(String))
// 220:       @disable_args = T.let(nil, T.nilable(T::Hash[Symbol, T.nilable(T.any(String, Symbol))]))
// 221:       @disabled = T.let(false, T::Boolean)
// 222:       @homepage = T.let(nil, T.nilable(String))
// 223:       @homepage_browsed = T.let(nil, T.nilable(Date))
// 224:       @homepage_set_in_block = T.let(false, T::Boolean)
// 225:       @language_blocks = T.let({}, T::Hash[T::Array[String], Proc])
// 226:       @language_eval = T.let(nil, T.nilable(String))
// 227:       @livecheck = T.let(Livecheck.new(cask), Livecheck)
// 228:       @livecheck_defined = T.let(false, T::Boolean)
// 229:       @name = T.let([], T::Array[String])
// 230:       @no_autobump_defined = T.let(false, T::Boolean)
// 231:       @no_autobump_message = T.let(nil, T.nilable(T.any(String, Symbol)))
// 232:       @on_system_blocks_exist = T.let(false, T::Boolean)
// 233:       @on_os_blocks_exist = T.let(false, T::Boolean)
// 234:       @on_system_block_min_os = T.let(nil, T.nilable(MacOSVersion))
// 235:       @os = T.let(nil, T.nilable(String))
// 236:       @os_set_in_block = T.let(false, T::Boolean)
// 237:       @rename = T.let([], T::Array[DSL::Rename])
// 238:       @sha256 = T.let(nil, T.nilable(T.any(Checksum, Symbol)))
// 239:       @sha256_set_in_block = T.let(false, T::Boolean)
// 240:       @staged_path = T.let(nil, T.nilable(Pathname))
// 241:       @token = T.let(cask.token, String)
// 242:       @url = T.let(nil, T.nilable(URL))
// 243:       @url_set_in_block = T.let(false, T::Boolean)
// 244:       @version = T.let(nil, T.nilable(DSL::Version))
// 245:       @version_set_in_block = T.let(false, T::Boolean)
// 246:     end
// 247:
// 248:     sig { returns(T::Boolean) }
// 249:     def depends_on_set_in_block? = @depends_on_set_in_block
// 250:
// 251:     sig { returns(T::Boolean) }
// 252:     def deprecated? = @deprecated
// 253:
// 254:     sig { returns(T::Boolean) }
// 255:     def disabled? = @disabled
// 256:
// 257:     sig { returns(T::Boolean) }
// 258:     def livecheck_defined? = @livecheck_defined
// 259:
// 260:     sig { returns(T::Boolean) }
// 261:     def on_system_blocks_exist? = @on_system_blocks_exist
// 262:
// 263:     sig { returns(T::Boolean) }
// 264:     def on_os_blocks_exist? = @on_os_blocks_exist
// 265:
// 266:     # Specifies the cask's name.
// 267:     #
// 268:     # NOTE: Multiple names can be specified.
// 269:     #
// 270:     # ### Example
// 271:     #
// 272:     # ```ruby
// 273:     # name "Visual Studio Code"
// 274:     # ```
// 275:     #
// 276:     # @api public
// 277:     sig { params(args: T.any(String, T::Array[String])).returns(T::Array[String]) }
// 278:     def name(*args)
// 279:       return @name if args.empty?
// 280:
// 281:       @name.concat(args.flatten)
// 282:     end
// 283:
// 284:     # Describes the cask.
// 285:     #
// 286:     # ### Example
// 287:     #
// 288:     # ```ruby
// 289:     # desc "Open-source code editor"
// 290:     # ```
// 291:     #
// 292:     # @api public
// 293:     sig { params(description: T.nilable(String)).returns(T.nilable(String)) }
// 294:     def desc(description = nil)
// 295:       set_unique_stanza(:desc, description.nil?) { description }
// 296:     end
// 297:
// 298:     # NOTE: Using `WithoutRuntime` to avoid Sorbet wrapping this method,
// 299:     # which would interfere with `caller_locations` in methods like `url`.
// 300:     T::Sig::WithoutRuntime.sig {
// 301:       type_parameters(:U).params(
// 302:         stanza:        Symbol,
// 303:         should_return: T::Boolean,
// 304:         _block:        T.proc.returns(T.all(BasicObject, T.type_parameter(:U))),
// 305:       ).returns(T.type_parameter(:U))
// 306:     }
// 307:     def set_unique_stanza(stanza, should_return, &_block)
// 308:       return instance_variable_get(:"@#{stanza}") if should_return
// 309:
// 310:       unless @cask.allow_reassignment
// 311:         if !instance_variable_get(:"@#{stanza}").nil? && !@called_in_on_system_block
// 312:           raise CaskInvalidError.new(cask, "'#{stanza}' stanza may only appear once.")
// 313:         end
// 314:
// 315:         if instance_variable_get(:"@#{stanza}_set_in_block") && @called_in_on_system_block
// 316:           raise CaskInvalidError.new(cask, "'#{stanza}' stanza may only be overridden once.")
// 317:         end
// 318:       end
// 319:
// 320:       instance_variable_set(:"@#{stanza}_set_in_block", true) if @called_in_on_system_block
// 321:       instance_variable_set(:"@#{stanza}", yield)
// 322:     rescue CaskInvalidError
// 323:       raise
// 324:     rescue => e
// 325:       raise CaskInvalidError.new(cask, "'#{stanza}' stanza failed with: #{e}")
// 326:     end
// 327:
// 328:     # Sets the cask's homepage.
// 329:     #
// 330:     # ### Example
// 331:     #
// 332:     # ```ruby
// 333:     # homepage "https://code.visualstudio.com/", browsed: "2026-07-26"
// 334:     # ```
// 335:     #
// 336:     # `browsed` is the date when a human last checked the homepage in a browser.
// 337:     # Automated homepage availability audits are skipped for one year.
// 338:     #
// 339:     # @api public
// 340:     sig { params(homepage: T.nilable(String), browsed: T.nilable(String)).returns(T.nilable(String)) }
// 341:     def homepage(homepage = nil, browsed: nil)
// 342:       raise CaskInvalidError.new(cask, "`browsed` requires a homepage URL") if homepage.nil? && browsed
// 343:
// 344:       set_unique_stanza(:homepage, homepage.nil?) do
// 345:         @homepage_browsed = Date.parse(browsed) if browsed
// 346:         homepage
// 347:       end
// 348:     end
// 349:
// 350:     # Specifies language-specific values for the cask.
// 351:     #
// 352:     # @api public
// 353:     sig {
// 354:       params(
// 355:         args:    String,
// 356:         default: T::Boolean,
// 357:         block:   T.nilable(T.proc.returns(String)),
// 358:       ).returns(T.nilable(String))
// 359:     }
// 360:     def language(*args, default: false, &block)
// 361:       if args.empty?
// 362:         language_eval
// 363:       elsif block
// 364:         @language_blocks[args] = block
// 365:
// 366:         return unless default
// 367:
// 368:         if !@cask.allow_reassignment && @language_blocks.default.present?
// 369:           raise CaskInvalidError.new(cask, "Only one default language may be defined.")
// 370:         end
// 371:
// 372:         @language_blocks.default = block
// 373:         nil
// 374:       else
// 375:         raise CaskInvalidError.new(cask, "No block given to language stanza.")
// 376:       end
// 377:     end
// 378:
// 379:     sig { returns(T.nilable(String)) }
// 380:     def language_eval
// 381:       return @language_eval unless @language_eval.nil?
// 382:
// 383:       return @language_eval = nil if @language_blocks.empty?
// 384:
// 385:       if (language_blocks_default = @language_blocks.default).nil?
// 386:         raise CaskInvalidError.new(cask, "No default language specified.")
// 387:       end
// 388:
// 389:       locales = cask.config.languages
// 390:                     .filter_map do |language|
// 391:                       Locale.parse(language)
// 392:                     rescue Locale::ParserError
// 393:                       nil
// 394:                     end
// 395:
// 396:       locales.each do |locale|
// 397:         key = T.cast(locale.detect(@language_blocks.keys), T.nilable(T::Array[String]))
// 398:         next if key.nil? || (language_block = @language_blocks[key]).nil?
// 399:
// 400:         return @language_eval = language_block.call
// 401:       end
// 402:
// 403:       @language_eval = language_blocks_default.call
// 404:     end
// 405:
// 406:     sig { returns(T::Array[String]) }
// 407:     def languages
// 408:       @language_blocks.keys.flatten
// 409:     end
// 410:
// 411:     sig { returns(T::Array[T::Array[String]]) }
// 412:     def language_groups
// 413:       @language_blocks.keys
// 414:     end
// 415:
// 416:     sig { returns(T.nilable(T::Array[String])) }
// 417:     def default_language_group
// 418:       default_language_block = @language_blocks.default
// 419:       return if default_language_block.nil?
// 420:
// 421:       @language_blocks.key(default_language_block)
// 422:     end
// 423:
// 424:     # Sets the cask's download URL.
// 425:     #
// 426:     # ### Example
// 427:     #
// 428:     # ```ruby
// 429:     # url "https://update.code.visualstudio.com/#{version}/#{arch}/stable"
// 430:     # ```
// 431:     #
// 432:     # @api public
// 433:     T::Sig::WithoutRuntime.sig { params(uri: T.nilable(T.any(URI::Generic, String)), options: T.untyped).returns(T.nilable(URL)) }
// 434:     def url(uri = nil, **options)
// 435:       caller_location = caller_locations.fetch(0)
// 436:       return @url unless uri
// 437:
// 438:       # Keep accepting `verified` as a no-op for compatibility with existing casks.
// 439:       # odeprecated "the `verified` parameter in the `url` stanza" if options[:verified]
// 440:
// 441:       set_unique_stanza(:url, false) do
// 442:         URL.new(uri, **options, caller_location:)
// 443:       end
// 444:     end
// 445:
// 446:     # Sets the cask's container type or nested container path.
// 447:     #
// 448:     # ### Examples
// 449:     #
// 450:     # The container is a nested disk image:
// 451:     #
// 452:     # ```ruby
// 453:     # container nested: "orca-#{version}.dmg"
// 454:     # ```
// 455:     #
// 456:     # The container should not be unarchived:
// 457:     #
// 458:     # ```ruby
// 459:     # container type: :naked
// 460:     # ```
// 461:     #
// 462:     # @api public
// 463:     sig { params(nested: T.nilable(String), type: T.nilable(Symbol)).returns(T.nilable(DSL::Container)) }
// 464:     def container(nested: nil, type: nil)
// 465:       set_unique_stanza(:container, nested.nil? && type.nil?) do
// 466:         DSL::Container.new(nested:, type:)
// 467:       end
// 468:     end
// 469:
// 470:     # Renames files after extraction.
// 471:     #
// 472:     # This is useful when the downloaded file has unpredictable names
// 473:     # that need to be normalized for proper artifact installation.
// 474:     #
// 475:     # ### Example
// 476:     #
// 477:     # ```ruby
// 478:     # rename "RØDECaster App*.pkg", "RØDECaster App.pkg"
// 479:     # ```
// 480:     #
// 481:     # @api public
// 482:     sig {
// 483:       params(from: String,
// 484:              to:   String).returns(T::Array[DSL::Rename])
// 485:     }
// 486:     def rename(from = T.unsafe(nil), to = T.unsafe(nil))
// 487:       return @rename if from.nil?
// 488:
// 489:       @rename << DSL::Rename.new(from, to)
// 490:     end
// 491:
// 492:     # Sets the cask's version.
// 493:     #
// 494:     # ### Example
// 495:     #
// 496:     # ```ruby
// 497:     # version "1.88.1"
// 498:     # ```
// 499:     #
// 500:     # @see DSL::Version
// 501:     # @api public
// 502:     sig { params(arg: T.nilable(T.any(String, Symbol))).returns(T.nilable(DSL::Version)) }
// 503:     def version(arg = nil)
// 504:       set_unique_stanza(:version, arg.nil?) do
// 505:         if !arg.is_a?(String) && arg != :latest
// 506:           raise CaskInvalidError.new(cask, "invalid 'version' value: #{arg.inspect}")
// 507:         end
// 508:
// 509:         set_no_autobump(because: :latest_version) if arg == :latest && !no_autobump_defined?
// 510:
// 511:         DSL::Version.new(arg)
// 512:       end
// 513:     end
// 514:
// 515:     # Sets the cask's download checksum.
// 516:     #
// 517:     # ### Example
// 518:     #
// 519:     # For universal or single-architecture downloads:
// 520:     #
// 521:     # ```ruby
// 522:     # sha256 "7bdb497080ffafdfd8cc94d8c62b004af1be9599e865e5555e456e2681e150ca"
// 523:     # ```
// 524:     #
// 525:     # For architecture- or OS-dependent downloads:
// 526:     #
// 527:     # ```ruby
// 528:     # sha256 arm:          "7bdb497080ffafdfd8cc94d8c62b004af1be9599e865e5555e456e2681e150ca",
// 529:     #        intel:        "b3c1c2442480a0219b9e05cf91d03385858c20f04b764ec08a3fa83d1b27e7b2",
// 530:     #        arm64_linux:  "bd766af7e692afceb727a6f88e24e6e68d9882aeb3e8348412f6c03d96537c75",
// 531:     #        x86_64_linux: "1a2aee7f1ddc999993d4d7d42a150c5e602bc17281678050b8ed79a0500cc90f"
// 532:     # ```
// 533:     #
// 534:     # @api public
// 535:     sig {
// 536:       params(
// 537:         arg:          T.nilable(T.any(String, Symbol)),
// 538:         arm:          T.nilable(String),
// 539:         intel:        T.nilable(String),
// 540:         x86_64:       T.nilable(String),
// 541:         x86_64_linux: T.nilable(String),
// 542:         arm64_linux:  T.nilable(String),
// 543:       ).returns(T.nilable(T.any(Symbol, Checksum)))
// 544:     }
// 545:     def sha256(arg = nil, arm: nil, intel: nil, x86_64: nil, x86_64_linux: nil, arm64_linux: nil)
// 546:       should_return = arg.nil? && arm.nil? && (intel.nil? || x86_64.nil?) && x86_64_linux.nil? && arm64_linux.nil?
// 547:
// 548:       x86_64 ||= intel if intel.present? && x86_64.nil?
// 549:       set_unique_stanza(:sha256, should_return) do
// 550:         if arm.present? || x86_64.present? || x86_64_linux.present? || arm64_linux.present?
// 551:           @on_system_blocks_exist = true
// 552:         end
// 553:
// 554:         val = arg || on_system_conditional(
// 555:           macos: on_arch_conditional(arm:, intel: x86_64),
// 556:           linux: on_arch_conditional(arm: arm64_linux, intel: x86_64_linux),
// 557:         )
// 558:         case val
// 559:         when :no_check
// 560:           :no_check
// 561:         when String
// 562:           Checksum.new(val)
// 563:         when nil
// 564:           nil
// 565:         else
// 566:           raise CaskInvalidError.new(cask, "invalid 'sha256' value: #{val.inspect}")
// 567:         end
// 568:       end
// 569:     end
// 570:
// 571:     # Sets the cask's architecture strings.
// 572:     #
// 573:     # ### Example
// 574:     #
// 575:     # ```ruby
// 576:     # arch arm: "darwin-arm64", intel: "darwin"
// 577:     # ```
// 578:     #
// 579:     # @api public
// 580:     sig { params(arm: T.nilable(String), intel: T.nilable(String)).returns(T.nilable(String)) }
// 581:     def arch(arm: nil, intel: nil)
// 582:       should_return = arm.nil? && intel.nil?
// 583:
// 584:       set_unique_stanza(:arch, should_return) do
// 585:         @on_system_blocks_exist = true
// 586:
// 587:         on_arch_conditional(arm:, intel:)
// 588:       end
// 589:     end
// 590:
// 591:     # Sets the cask's os strings.
// 592:     #
// 593:     # ### Example
// 594:     #
// 595:     # ```ruby
// 596:     # os macos: "darwin", linux: "tux"
// 597:     # ```
// 598:     #
// 599:     # @api public
// 600:     sig {
// 601:       params(
// 602:         macos: T.nilable(String),
// 603:         linux: T.nilable(String),
// 604:       ).returns(T.nilable(String))
// 605:     }
// 606:     def os(macos: nil, linux: nil)
// 607:       should_return = macos.nil? && linux.nil?
// 608:
// 609:       set_unique_stanza(:os, should_return) do
// 610:         @on_system_blocks_exist = true
// 611:         @on_os_blocks_exist = true
// 612:
// 613:         on_system_conditional(macos:, linux:)
// 614:       end
// 615:     end
// 616:
// 617:     # Declare dependencies and requirements for a cask.
// 618:     #
// 619:     # NOTE: Multiple dependencies can be specified.
// 620:     #
// 621:     # @api public
// 622:     sig { params(arg: T.nilable(Symbol), kwargs: T.untyped).returns(DSL::DependsOn) }
// 623:     def depends_on(arg = nil, **kwargs)
// 624:       @depends_on_set_in_block = true if @called_in_on_system_block
// 625:       if arg == :macos
// 626:         if kwargs.key?(:macos) || kwargs.key?(:maximum_macos)
// 627:           raise CaskInvalidError.new(cask, "`depends_on :macos` cannot be combined with another macOS `depends_on`")
// 628:         end
// 629:
// 630:         kwargs[:macos] = :any
// 631:       elsif arg == :linux
// 632:         kwargs[:linux] = :any
// 633:       elsif arg
// 634:         raise CaskInvalidError.new(cask, "invalid 'depends_on' value: #{arg.inspect}")
// 635:       end
// 636:       return @depends_on if kwargs.empty?
// 637:
// 638:       begin
// 639:         # Only OS blocks scope a dependency to one OS: `on_arm`/`on_intel`
// 640:         # blocks are evaluated on every OS, so a macOS dependency inside one
// 641:         # applies everywhere and marks the cask macOS-only.
// 642:         @depends_on.load(kwargs, set_in_block: @called_in_on_system_block, os_scoped: @called_in_on_os_block)
// 643:       rescue RuntimeError => e
// 644:         raise CaskInvalidError.new(cask, e)
// 645:       end
// 646:       @depends_on
// 647:     end
// 648:
// 649:     # Declare conflicts that keep a cask from installing or working correctly.
// 650:     #
// 651:     # NOTE: Multiple `conflicts_with` stanzas can be specified; they are merged.
// 652:     #
// 653:     # @api public
// 654:     sig { params(kwargs: T.anything).returns(T.nilable(DSL::ConflictsWith)) }
// 655:     def conflicts_with(**kwargs)
// 656:       return @conflicts_with if kwargs.empty?
// 657:
// 658:       new_conflicts = DSL::ConflictsWith.new(**kwargs)
// 659:       @conflicts_with = @conflicts_with&.merge!(new_conflicts) || new_conflicts
// 660:     rescue CaskInvalidError
// 661:       raise
// 662:     rescue => e
// 663:       raise CaskInvalidError.new(cask, "'conflicts_with' stanza failed with: #{e}")
// 664:     end
// 665:
// 666:     sig { returns(Pathname) }
// 667:     def caskroom_path
// 668:       cask.caskroom_path
// 669:     end
// 670:
// 671:     # The staged location for this cask, including version number.
// 672:     #
// 673:     # @api public
// 674:     sig { returns(Pathname) }
// 675:     def staged_path
// 676:       return @staged_path if @staged_path
// 677:
// 678:       cask_version = version || :unknown
// 679:       @staged_path = caskroom_path.join(cask_version.to_s)
// 680:     end
// 681:
// 682:     # Provide the user with cask-specific information at install time.
// 683:     #
// 684:     # @api public
// 685:     sig {
// 686:       params(
// 687:         strings: String,
// 688:         block:   T.nilable(T.proc.returns(T.nilable(T.any(Symbol, String)))),
// 689:       ).returns(T.any(String, DSL::Caveats))
// 690:     }
// 691:     def caveats(*strings, &block)
// 692:       if block
// 693:         @caveats.eval_caveats(&block)
// 694:       elsif strings.any?
// 695:         strings.each do |string|
// 696:           @caveats.eval_caveats { string }
// 697:         end
// 698:       else
// 699:         return @caveats.to_s
// 700:       end
// 701:       @caveats
// 702:     end
// 703:
// 704:     sig { returns(DSL::Caveats) }
// 705:     def caveats_object = @caveats
// 706:
// 707:     # Asserts that the cask artifacts auto-update.
// 708:     #
// 709:     # @api public
// 710:     sig { params(auto_updates: T.nilable(T::Boolean)).returns(T.nilable(T::Boolean)) }
// 711:     def auto_updates(auto_updates = nil)
// 712:       set_unique_stanza(:auto_updates, auto_updates.nil?) { auto_updates }
// 713:     end
// 714:
// 715:     # Automatically fetch the latest version of a cask from changelogs.
// 716:     #
// 717:     # @api public
// 718:     sig { params(block: T.nilable(T.proc.bind(Livecheck).void)).returns(Livecheck) }
// 719:     def livecheck(&block)
// 720:       return @livecheck unless block
// 721:
// 722:       if !@cask.allow_reassignment && @livecheck_defined
// 723:         raise CaskInvalidError.new(cask, "'livecheck' stanza may only appear once.")
// 724:       end
// 725:
// 726:       @livecheck_defined = true
// 727:       @livecheck.instance_eval(&block)
// 728:       set_no_autobump(because: :extract_plist) if @livecheck.strategy == :extract_plist && !no_autobump_defined?
// 729:       @livecheck
// 730:     end
// 731:
// 732:     # Excludes the cask from autobump list.
// 733:     #
// 734:     # @api public
// 735:     sig { params(because: T.any(String, Symbol)).void }
// 736:     def no_autobump!(because:)
// 737:       tap = @cask.tap
// 738:       if tap && !tap.official?
// 739:         raise CaskInvalidError.new(cask, "'no_autobump!' can only be used in official Homebrew taps.")
// 740:       end
// 741:
// 742:       set_no_autobump(because:)
// 743:     end
// 744:
// 745:     # Is the cask in autobump list?
// 746:     sig { returns(T::Boolean) }
// 747:     def autobump?
// 748:       @autobump == true
// 749:     end
// 750:
// 751:     # Declare that a cask is no longer functional or supported.
// 752:     #
// 753:     # NOTE: A warning will be shown when trying to install this cask.
// 754:     #
// 755:     # @api public
// 756:     sig {
// 757:       params(
// 758:         date:                String,
// 759:         because:             T.any(String, Symbol),
// 760:         replacement:         T.nilable(String),
// 761:         replacement_formula: T.nilable(String),
// 762:         replacement_cask:    T.nilable(String),
// 763:       ).void
// 764:     }
// 765:     def deprecate!(date:, because:, replacement: nil, replacement_formula: nil, replacement_cask: nil)
// 766:       if [replacement, replacement_formula, replacement_cask].filter_map(&:presence).length > 1
// 767:         raise ArgumentError, "more than one of replacement, replacement_formula and/or replacement_cask specified!"
// 768:       end
// 769:
// 770:       if replacement
// 771:         odeprecated(
// 772:           "deprecate!(:replacement)",
// 773:           "deprecate!(:replacement_formula) or deprecate!(:replacement_cask)",
// 774:         )
// 775:       end
// 776:
// 777:       @deprecate_args = { date:, because:, replacement_formula:, replacement_cask: }
// 778:
// 779:       @deprecation_date = Date.parse(date)
// 780:       return if @deprecation_date > Date.today
// 781:
// 782:       @deprecation_reason = because
// 783:       @deprecation_replacement_formula = replacement_formula.presence || replacement
// 784:       @deprecation_replacement_cask = replacement_cask.presence || replacement
// 785:       @deprecated = true
// 786:     end
// 787:
// 788:     # Declare that a cask is no longer functional or supported.
// 789:     #
// 790:     # NOTE: An error will be thrown when trying to install this cask.
// 791:     #
// 792:     # @api public
// 793:     sig {
// 794:       params(
// 795:         date:                String,
// 796:         because:             T.any(String, Symbol),
// 797:         replacement:         T.nilable(String),
// 798:         replacement_formula: T.nilable(String),
// 799:         replacement_cask:    T.nilable(String),
// 800:       ).void
// 801:     }
// 802:     def disable!(date:, because:, replacement: nil, replacement_formula: nil, replacement_cask: nil)
// 803:       if [replacement, replacement_formula, replacement_cask].filter_map(&:presence).length > 1
// 804:         raise ArgumentError, "more than one of replacement, replacement_formula and/or replacement_cask specified!"
// 805:       end
// 806:
// 807:       # odeprecate: remove this remapping when the :unsigned reason is removed
// 808:       because = :fails_gatekeeper_check if because == :unsigned
// 809:
// 810:       if replacement
// 811:         odeprecated(
// 812:           "disable!(:replacement)",
// 813:           "disable!(:replacement_formula) or disable!(:replacement_cask)",
// 814:         )
// 815:       end
// 816:
// 817:       @disable_args = { date:, because:, replacement_formula:, replacement_cask: }
// 818:
// 819:       @disable_date = Date.parse(date)
// 820:
// 821:       if @disable_date > Date.today
// 822:         @deprecation_reason = because
// 823:         @deprecation_replacement_formula = replacement_formula.presence || replacement
// 824:         @deprecation_replacement_cask = replacement_cask.presence || replacement
// 825:         @deprecated = true
// 826:         return
// 827:       end
// 828:
// 829:       @disable_reason = because
// 830:       @disable_replacement_formula = replacement_formula.presence || replacement
// 831:       @disable_replacement_cask = replacement_cask.presence || replacement
// 832:       @disabled = true
// 833:     end
// 834:
// 835:     ORDINARY_ARTIFACT_CLASSES.each do |klass|
// 836:       define_method(klass.dsl_key) do |*args, **kwargs|
// 837:         T.bind(self, DSL)
// 838:         if [*artifacts.map(&:class), klass].include?(Artifact::StageOnly) &&
// 839:            artifacts.map(&:class).intersect?(ACTIVATABLE_ARTIFACT_CLASSES)
// 840:           raise CaskInvalidError.new(cask, "'stage_only' must be the only activatable artifact.")
// 841:         end
// 842:
// 843:         artifacts.add(klass.from_args(cask, *args, **kwargs))
// 844:       rescue CaskInvalidError
// 845:         raise
// 846:       rescue => e
// 847:         raise CaskInvalidError.new(cask, "invalid '#{klass.dsl_key}' stanza: #{e}")
// 848:       end
// 849:     end
// 850:
// 851:     ARTIFACT_BLOCK_CLASSES.each do |klass|
// 852:       [klass.dsl_key, klass.uninstall_dsl_key].each do |dsl_key|
// 853:         define_method(dsl_key) do |&block|
// 854:           T.bind(self, DSL)
// 855:           # odeprecated "`#{dsl_key}`", "`#{dsl_key}_steps`"
// 856:           artifacts.add(klass.new(cask, dsl_key => block))
// 857:         end
// 858:       end
// 859:     end
// 860:
// 861:     INSTALL_STEP_ARTIFACT_CLASSES.each do |klass|
// 862:       define_method(klass.dsl_key) do |steps = nil, **kwargs, &block|
// 863:         T.bind(self, DSL)
// 864:         steps = if block
// 865:           Homebrew::InstallSteps::DSL.build(default_base: :staged_path, default_source_base: :staged_path,
// 866:                                             default_target_base: :staged_path, &block)
// 867:         else
// 868:           Homebrew::InstallSteps::DSL.normalise_steps([kwargs[:steps] || steps].flatten.compact)
// 869:         end
// 870:         artifacts.add(klass.new(cask, steps))
// 871:       end
// 872:     end
// 873:
// 874:     sig { override.params(method: Symbol, _args: T.anything).returns(T.noreturn) }
// 875:     def method_missing(method, *_args)
// 876:       raise NoMethodError, "undefined method '#{method}' for Cask '#{token}'"
// 877:     end
// 878:
// 879:     sig { override.params(_method_name: T.any(String, Symbol), _include_private: T::Boolean).returns(T::Boolean) }
// 880:     def respond_to_missing?(_method_name, _include_private = false)
// 881:       false
// 882:     end
// 883:
// 884:     sig { returns(T.nilable(MacOSVersion)) }
// 885:     def os_version
// 886:       nil
// 887:     end
// 888:
// 889:     # The directory `app`s are installed into.
// 890:     #
// 891:     # @api public
// 892:     sig { returns(T.any(Pathname, String)) }
// 893:     def appdir
// 894:       return HOMEBREW_CASK_APPDIR_PLACEHOLDER if Cask.generating_hash?
// 895:
// 896:       cask.config.appdir
// 897:     end
// 898:
// 899:     private
// 900:
// 901:     sig { returns(T::Boolean) }
// 902:     def no_autobump_defined?
// 903:       @no_autobump_defined
// 904:     end
// 905:
// 906:     sig { params(because: T.any(String, Symbol)).void }
// 907:     def set_no_autobump(because:)
// 908:       if because.is_a?(Symbol) && !NO_AUTOBUMP_REASONS_LIST.key?(because)
// 909:         raise ArgumentError, "'because' argument should use valid symbol or a string!"
// 910:       end
// 911:
// 912:       if !@cask.allow_reassignment && no_autobump_defined?
// 913:         raise CaskInvalidError.new(cask, "'no_autobump!' stanza may only appear once.")
// 914:       end
// 915:
// 916:       odisabled "no_autobump! because: :requires_manual_review" if because == :requires_manual_review
// 917:
// 918:       @no_autobump_defined = true
// 919:       @no_autobump_message = because
// 920:       @autobump = false
// 921:     end
// 922:   end
// 923: end
