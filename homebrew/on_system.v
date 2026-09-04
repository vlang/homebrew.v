module homebrew

import ruby

// Translated from Homebrew/brew `on_system.rb`.
pub const on_system_arch_options = ['intel', 'arm']
pub const on_system_base_os_options = ['macos', 'linux']
pub const on_system_all_os_options = ['golden_gate', 'tahoe', 'sequoia', 'sonoma', 'ventura',
	'monterey', 'big_sur', 'catalina', 'linux']

pub struct OnSystemContext {
pub:
	current_os     string
	current_arch   string
	oldest_allowed string = 'catalina'
}

pub struct OnSystemState {
pub mut:
	on_system_blocks_exist bool
	on_os_blocks_exist     bool
	called_in_system_block bool
	called_in_os_block     bool
	minimum_os             string
}

pub struct OnSystemDefinitionSet {
pub:
	arch_methods    []string
	base_os_methods []string
	macos_methods   []string
	conditional     []string
}

pub struct OnSystemBlockResult {
pub:
	called bool
	value  string
}

pub fn on_system_all_os_arch_combinations() [][]string {
	mut result := [][]string{}
	for os_name in on_system_all_os_options {
		for arch in on_system_arch_options {
			result << [os_name, arch]
		}
	}
	return result
}

pub fn on_system_arch_condition_met(arch string, context OnSystemContext) !bool {
	if arch !in on_system_arch_options {
		return error('Invalid arch condition: :${arch}')
	}
	return arch == context.current_arch
}

pub fn on_system_os_condition_met(os_name string, or_condition ?string,
	context OnSystemContext) !bool {
	if os_name in on_system_base_os_options {
		return if os_name == 'macos' {
			context.current_os != 'linux'
		} else {
			context.current_os == 'linux'
		}
	}
	if os_name !in macos_symbol_versions() {
		return error('Invalid OS condition: :${os_name}')
	}
	if condition := or_condition {
		if condition !in ['or_newer', 'or_older'] {
			return error('Invalid OS `or_*` condition: :${condition}')
		}
	}
	if context.current_os == 'linux' {
		return false
	}
	base_os := macos_version_from_symbol(os_name)!
	current_os := if context.current_os == 'macos' {
		null_macos_version()
	} else {
		macos_version_from_symbol(context.current_os)!
	}
	if condition := or_condition {
		return if condition == 'or_newer' {
			current_os.compare(base_os) >= 0
		} else {
			current_os.compare(base_os) <= 0
		}
	}
	return current_os.compare(base_os) == 0
}

pub fn on_system_condition_from_method_name(method_name string) string {
	return method_name.trim_left('on_')
}

pub fn on_system_arch_definitions() OnSystemDefinitionSet {
	return OnSystemDefinitionSet{
		arch_methods: on_system_arch_options.map('on_${it}')
		conditional: ['on_arch_conditional']
	}
}

pub fn on_system_base_os_definitions() OnSystemDefinitionSet {
	return OnSystemDefinitionSet{
		base_os_methods: on_system_base_os_options.map('on_${it}')
		conditional: ['on_system', 'on_system_conditional']
	}
}

pub fn on_system_macos_definitions() OnSystemDefinitionSet {
	return OnSystemDefinitionSet{
		macos_methods: macos_symbol_versions().keys().map('on_${it}')
	}
}

pub fn on_system_run_arch(mut state OnSystemState, method_name string,
	context OnSystemContext, block_value string) !OnSystemBlockResult {
	state.on_system_blocks_exist = true
	condition := on_system_condition_from_method_name(method_name)
	if !on_system_arch_condition_met(condition, context)! {
		return OnSystemBlockResult{}
	}
	state.called_in_system_block = true
	result := block_value
	state.called_in_system_block = false
	return OnSystemBlockResult{ called: true, value: result }
}

pub fn on_system_arch_conditional(mut state OnSystemState, arm ?string, intel ?string,
	context OnSystemContext) !OnSystemBlockResult {
	state.on_system_blocks_exist = true
	if on_system_arch_condition_met('arm', context)! {
		value := arm or { return OnSystemBlockResult{} }
		return OnSystemBlockResult{ called: true, value: value }
	}
	if on_system_arch_condition_met('intel', context)! {
		value := intel or { return OnSystemBlockResult{} }
		return OnSystemBlockResult{ called: true, value: value }
	}
	return OnSystemBlockResult{}
}

pub fn on_system_run_base_os(mut state OnSystemState, method_name string,
	context OnSystemContext, block_value string) !OnSystemBlockResult {
	state.on_system_blocks_exist = true
	state.on_os_blocks_exist = true
	condition := on_system_condition_from_method_name(method_name)
	if !on_system_os_condition_met(condition, none, context)! {
		return OnSystemBlockResult{}
	}
	state.called_in_system_block = true
	state.called_in_os_block = true
	result := block_value
	state.called_in_system_block = false
	state.called_in_os_block = false
	return OnSystemBlockResult{ called: true, value: result }
}

pub fn on_system_run_system(mut state OnSystemState, linux string, macos string,
	context OnSystemContext, block_value string) !OnSystemBlockResult {
	state.on_system_blocks_exist = true
	state.on_os_blocks_exist = true
	if linux != 'linux' {
		return error('The first argument to `on_system` must be `:linux`')
	}
	parts := macos.split('_or_')
	version := parts[0]
	condition := if parts.len > 1 { ?string('or_${parts[1]}') } else { none }
	if !on_system_os_condition_met(version, condition, context)! && !on_system_os_condition_met('linux', none, context)! {
		return OnSystemBlockResult{}
	}
	state.called_in_system_block = true
	state.called_in_os_block = true
	result := block_value
	state.called_in_system_block = false
	state.called_in_os_block = false
	return OnSystemBlockResult{ called: true, value: result }
}

pub fn on_system_conditional(mut state OnSystemState, macos ?string, linux ?string,
	context OnSystemContext) !OnSystemBlockResult {
	state.on_system_blocks_exist = true
	if on_system_os_condition_met('macos', none, context)! {
		if value := macos {
			if value != '' {
				return OnSystemBlockResult{ called: true, value: value }
			}
		}
	} else if on_system_os_condition_met('linux', none, context)! {
		if value := linux {
			if value != '' {
				return OnSystemBlockResult{ called: true, value: value }
			}
		}
	}
	return OnSystemBlockResult{}
}

pub fn on_system_run_macos(mut state OnSystemState, method_name string,
	or_condition ?string, context OnSystemContext, block_value string) !OnSystemBlockResult {
	state.on_system_blocks_exist = true
	state.on_os_blocks_exist = true
	os_condition := on_system_condition_from_method_name(method_name)
	if !on_system_os_condition_met(os_condition, or_condition, context)! {
		return OnSystemBlockResult{}
	}
	if condition := or_condition {
		if condition == 'or_older' {
			if !state.called_in_system_block {
				state.minimum_os = context.oldest_allowed
			}
		} else {
			state.minimum_os = os_condition
		}
	} else {
		state.minimum_os = os_condition
	}
	state.called_in_system_block = true
	state.called_in_os_block = true
	result := block_value
	state.called_in_system_block = false
	state.called_in_os_block = false
	return OnSystemBlockResult{ called: true, value: result }
}

pub fn on_system_macos_and_linux_definitions() OnSystemDefinitionSet {
	arch := on_system_arch_definitions()
	base := on_system_base_os_definitions()
	macos := on_system_macos_definitions()
	mut conditional := arch.conditional.clone()
	conditional << base.conditional
	return OnSystemDefinitionSet{
		arch_methods: arch.arch_methods
		base_os_methods: base.base_os_methods
		macos_methods: macos.macos_methods
		conditional: conditional
	}
}

pub fn on_system_macos_only_definitions() OnSystemDefinitionSet {
	arch := on_system_arch_definitions()
	macos := on_system_macos_definitions()
	return OnSystemDefinitionSet{
		arch_methods: arch.arch_methods
		macos_methods: macos.macos_methods
		conditional: arch.conditional
	}
}

fn on_system_optional_value(result OnSystemBlockResult) ruby.Value {
	return if result.called {
		ruby.string_value(result.value)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

fn on_system_context_from_args(args []ruby.Value, offset int) OnSystemContext {
	return OnSystemContext{
		current_os: if args.len > offset {
			args[offset].as_string().trim_left(':')
		} else {
			'linux'
		}
		current_arch: if args.len > offset + 1 {
			args[offset + 1].as_string().trim_left(':')
		} else {
			'arm'
		}
		oldest_allowed: if args.len > offset + 2 {
			args[offset + 2].as_string().trim_left(':')
		} else {
			'catalina'
		}
	}
}

fn on_system_definition_value(definitions OnSystemDefinitionSet) ruby.Value {
	return ruby.map_value({
		'arch_methods':    ruby.string_array_value(definitions.arch_methods)
		'base_os_methods': ruby.string_array_value(definitions.base_os_methods)
		'macos_methods':   ruby.string_array_value(definitions.macos_methods)
		'conditional':     ruby.string_array_value(definitions.conditional)
	})
}
