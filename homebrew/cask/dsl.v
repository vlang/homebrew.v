module cask

import ruby
import homebrew
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

fn cask_dsl_value_bool(value ruby.Value, fallback bool) bool {
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
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
