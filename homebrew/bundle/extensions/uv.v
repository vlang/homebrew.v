module extensions

import brew_runtime

pub struct UvTool {
pub:
	name   string
	with   []string
	source string
}

pub struct UvState {
pub mut:
	executable         string
	packages           []UvTool
	installed_packages []UvTool
	output             []string
	commands           [][]string
}

fn uv_error(kind string, message string, attributes map[string]string) brew_runtime.Value {
	return brew_runtime.structured_value(kind, message, attributes)
}

pub fn uv_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Uv'
		type_name: 'uv'
		banner_name: 'uv tools'
		check_label: 'uv Tool'
		cleanup_heading: 'uv tools'
	}
}

pub fn uv_normalize_with(requirements []string) []string {
	mut normalized := []string{}
	for requirement in requirements {
		value := requirement.trim_space()
		if value != '' && value !in normalized {
			normalized << value
		}
	}
	normalized.sort()
	return normalized
}

pub fn uv_normalize_source(source string) string {
	return source.trim_space()
}

pub fn uv_local_source(source string) bool {
	mut value := source
	if value.starts_with('git+') {
		value = value[4..]
	}
	return value.starts_with('file://') || value.starts_with('/') || value.starts_with('./') || value.starts_with('../')
}

pub fn uv_parse_source(required_raw string) string {
	source := uv_normalize_source(required_raw)
	if source == '' || uv_local_source(source) {
		return ''
	}
	if source.starts_with('git+') || source.starts_with('http://') || source.starts_with('https://') || source.ends_with('.git') {
		return source
	}
	return ''
}

fn uv_unique_sorted_csv(value string) []string {
	mut entries := []string{}
	for item in value.split(',') {
		trimmed := item.trim_space()
		if trimmed != '' && trimmed !in entries {
			entries << trimmed
		}
	}
	entries.sort()
	return entries
}

pub fn uv_name_with_extras(name string, extras_raw string) string {
	if extras_raw.trim_space() == '' {
		return name
	}
	extras := uv_unique_sorted_csv(extras_raw)
	if extras.len == 0 {
		return name
	}
	return '${name}[${extras.join(',')}]'
}

pub fn uv_continuation_constraint(requirement string) bool {
	trimmed := requirement.trim_space()
	for operator in ['<=', '>=', '!=', '==', '~=', '<', '>'] {
		if trimmed.starts_with(operator) && trimmed.len > operator.len && trimmed[operator.len..].trim_space() != '' {
			return true
		}
	}
	return false
}

pub fn uv_normalize_constraint(requirement string) string {
	trimmed := requirement.trim_space()
	for operator in ['<=', '>=', '!=', '==', '~=', '<', '>'] {
		if trimmed.starts_with(operator) {
			return '${operator}${trimmed[operator.len..].trim_space()}'
		}
	}
	return trimmed
}

pub fn uv_parse_with_requirements(with_raw string) []string {
	if with_raw.trim_space() == '' {
		return []
	}
	mut entries := []string{}
	for token in with_raw.split(', ') {
		requirement := token.trim_space()
		if requirement == '' {
			continue
		}
		if uv_continuation_constraint(requirement) && entries.len > 0 {
			last := entries.pop()
			entries << '${last}, ${uv_normalize_constraint(requirement)}'
		} else {
			entries << requirement
		}
	}
	return uv_normalize_with(entries)
}

pub fn uv_normalize_name(name string) string {
	trimmed := name.trim_space()
	open := trimmed.index('[') or { return trimmed }
	if open == 0 || !trimmed.ends_with(']') || trimmed[..open].contains(']') {
		return trimmed
	}
	extras_raw := trimmed[open + 1..trimmed.len - 1]
	if extras_raw.contains('[') || extras_raw.contains(']') {
		return trimmed
	}
	base := trimmed[..open].trim_space()
	extras := uv_unique_sorted_csv(extras_raw)
	if extras.len == 0 {
		return base
	}
	return '${base}[${extras.join(',')}]'
}

pub fn uv_normalized_options(name string, requirements []string, source string) UvTool {
	return UvTool{
		name: uv_normalize_name(name)
		with: uv_normalize_with(requirements)
		source: uv_normalize_source(source)
	}
}

pub fn uv_tool_value(tool UvTool) brew_runtime.Value {
	return brew_runtime.map_value({
		'name':   brew_runtime.string_value(tool.name)
		'with':   brew_runtime.string_array_value(tool.with)
		'source': if tool.source == '' {
			brew_runtime.object_value('NilClass', '')
		} else {
			brew_runtime.string_value(tool.source)
		}
	})
}

pub fn uv_tool_from_value(value brew_runtime.Value) UvTool {
	values := value.as_map() or { return uv_normalized_options(value.as_string(), [], '') }
	if 'options' in values {
		options := values['options'].as_map() or { map[string]brew_runtime.Value{} }
		return uv_normalized_options(if 'name' in values { values['name'].as_string() } else { '' }, if 'with' in options {
			options['with'].as_string_array() or { [] }
		} else {
			[]
		}, if 'source' in options && options['source'].type_name != 'NilClass' {
			options['source'].as_string()
		} else {
			''
		})
	}
	return UvTool{
		name: if 'name' in values { values['name'].as_string() } else { '' }
		with: if 'with' in values { values['with'].as_string_array() or { [] } } else { [] }
		source: if 'source' in values && values['source'].type_name != 'NilClass' {
			values['source'].as_string()} else {
			''}
	}
}

pub fn uv_tools_value(tools []UvTool) brew_runtime.Value {
	return brew_runtime.array_value(tools.map(uv_tool_value(it)))
}

pub fn uv_tools_from_value(value brew_runtime.Value) []UvTool {
	items := value.as_array() or { return [] }
	return items.map(uv_tool_from_value(it))
}

pub fn uv_state_value(state UvState) brew_runtime.Value {
	return brew_runtime.map_value({
		'_definition':        extension_definition_value(uv_definition())
		'executable':         if state.executable == '' {
			brew_runtime.object_value('NilClass', '')
		} else {
			brew_runtime.object_value('Pathname', state.executable)
		}
		'packages':           uv_tools_value(state.packages)
		'installed_packages': uv_tools_value(state.installed_packages)
		'output':             brew_runtime.string_array_value(state.output)
		'commands':           brew_runtime.array_value(state.commands.map(brew_runtime.string_array_value(it)))
	})
}

pub fn uv_state_from_value(value brew_runtime.Value) UvState {
	values := value.as_map() or { return UvState{} }
	mut commands := [][]string{}
	if 'commands' in values {
		for command in values['commands'].as_array() or { [] } {
			commands << (command.as_string_array() or { [] })
		}
	}
	return UvState{
		executable: if 'executable' in values && values['executable'].type_name != 'NilClass' {
			values['executable'].as_string()} else {
			''}
		packages: if 'packages' in values { uv_tools_from_value(values['packages']) } else { [] }
		installed_packages: if 'installed_packages' in values {
			uv_tools_from_value(values['installed_packages'])} else {
			[]}
		output: if 'output' in values { values['output'].as_string_array() or { [] } } else { [] }
		commands: commands
	}
}

pub fn uv_entry(name string, options map[string]brew_runtime.Value) !ExtensionEntry {
	mut unknown_options := []string{}
	for key in options.keys() {
		if key !in ['with', 'source'] {
			unknown_options << ':${key}'
		}
	}
	if unknown_options.len > 0 {
		return error('unknown options([${unknown_options.join(', ')}]) for uv')
	}
	mut requirements := []string{}
	if 'with' in options && options['with'].type_name != 'NilClass' {
		requirements = options['with'].as_string_array() or {
			return error('options[:with](${options['with'].repr}) should be an Array of String objects')
		}
	}
	source_value := options['source'] or { brew_runtime.object_value('NilClass', '') }
	if source_value.type_name !in ['String', 'NilClass'] {
		return error('options[:source](${source_value.repr}) should be a String object')
	}
	source := if source_value.type_name == 'String' {
		uv_normalize_source(source_value.as_string())
	} else {
		''
	}
	if source != '' && uv_local_source(source) {
		return error('options[:source](${source_value.repr}) is local to this machine so cannot be used in a Brewfile')
	}
	mut normalized := map[string]brew_runtime.Value{}
	normalized_with := uv_normalize_with(requirements)
	if normalized_with.len > 0 {
		normalized['with'] = brew_runtime.string_array_value(normalized_with)
	}
	if source != '' {
		normalized['source'] = brew_runtime.string_value(source)
	}
	return ExtensionEntry{
		entry_type: 'uv'
		name: name
		options: normalized
	}
}

fn uv_metadata(line string, key string) string {
	start := line.index('[${key}:') or { return '' }
	content_start := start + key.len + 2
	relative_end := line[content_start..].index(']') or { return '' }
	return line[content_start..content_start + relative_end].trim_space()
}

pub fn uv_parse_tool_list(output string) []UvTool {
	mut tools := []UvTool{}
	for line in output.split_into_lines() {
		if line == '' || line[0].is_space() {
			continue
		}
		fields := line.fields()
		if fields.len < 2 || fields[0] == '' || !fields[1].starts_with('v') || fields[1].len == 1 {
			continue
		}
		tools << UvTool{
			name: uv_name_with_extras(fields[0], uv_metadata(line, 'extras'))
			with: uv_parse_with_requirements(uv_metadata(line, 'with'))
			source: uv_parse_source(uv_metadata(line, 'required'))
		}
	}
	tools.sort_with_compare(fn (a &UvTool, b &UvTool) int {
		return a.name.compare(b.name)
	})
	return tools
}

pub fn uv_dump_entry(tool UvTool) string {
	mut line := extension_dump_entry(uv_definition(), ExtensionPackage{
		name: tool.name
		with: tool.with
	})
	if tool.source != '' {
		line += ', source: ${extension_quote(tool.source)}'
	}
	return line
}

pub fn uv_install_args(name string, requirements []string, source string) []string {
	mut args := ['tool', 'install',
		if source.trim_space() != '' { source.trim_space() } else { name }]
	for requirement in uv_normalize_with(requirements) {
		args << '--with'
		args << requirement
	}
	return args
}

pub fn uv_package_installed(installed []UvTool, name string, requirements []string,
	source string) bool {
	return uv_normalized_options(name, requirements, source) in installed
}

pub fn uv_cleanup_items(entries []ExtensionEntry, executable string, tools []UvTool) []string {
	if executable == '' {
		return []
	}
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == 'uv' {
			kept << entry.name
		}
	}
	if kept.len == 0 {
		return []
	}
	return tools.filter(it.name !in kept).map(it.name)
}

// Translated from Homebrew/brew `bundle/extensions/uv.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `type = :uv` at line 25.
pub fn ruby_uv_l25_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Symbol', 'uv')
}

// Ruby method `check_label = "uv Tool"` at line 28.
pub fn ruby_uv_l28_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('uv Tool')
}

// Ruby method `banner_name = "uv tools"` at line 31.
pub fn ruby_uv_l31_d3_banner_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('uv tools')
}

// Ruby method `entry(name, options = {})` at line 34.
pub fn ruby_uv_l34_d4_entry(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return uv_error('ArgumentError', 'name is required', {})
	}
	options := if args.len > 1 {
		args[1].as_map() or { return uv_error('ArgumentError', err.msg(), {}) }
	} else {
		map[string]brew_runtime.Value{}
	}
	entry := uv_entry(args[0].as_string(), options) or { return uv_error('RuntimeError', err.msg(), {}) }
	return extension_entry_value(entry)
}

// Ruby method `reset!` at line 62.
pub fn ruby_uv_l62_d5_reset(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 { uv_state_from_value(args[0]) } else { UvState{} }
	state.packages = []
	state.installed_packages = []
	return uv_state_value(state)
}

// Ruby method `cleanup_heading` at line 68.
pub fn ruby_uv_l68_d6_cleanup_heading(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('uv tools')
}

// Ruby method `packages` at line 73.
pub fn ruby_uv_l73_d7_packages(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { uv_state_from_value(args[0]) } else { UvState{} }
	if state.packages.len > 0 {
		return uv_tools_value(state.packages)
	}
	if state.executable == '' {
		return uv_tools_value([])
	}
	output := if args.len > 1 { args[1].as_string() } else { '' }
	return uv_tools_value(uv_parse_tool_list(output))
}

// Ruby method `dump_name(package)` at line 87.
pub fn ruby_uv_l87_d8_dump_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return uv_error('ArgumentError', 'package is required', {})
	}
	return brew_runtime.string_value(uv_tool_from_value(args[0]).name)
}

// Ruby method `dump_with(package)` at line 92.
pub fn ruby_uv_l92_d9_dump_with(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return uv_error('ArgumentError', 'package is required', {})
	}
	return brew_runtime.string_array_value(uv_tool_from_value(args[0]).with)
}

// Ruby method `dump_source(package)` at line 97.
pub fn ruby_uv_l97_d10_dump_source(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return uv_error('ArgumentError', 'package is required', {})
	}
	source := uv_tool_from_value(args[0]).source
	if source == '' {
		return brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.string_value(source)
}

// Ruby method `install_package!(name, with: nil, source: nil, verbose: false)` at line 109.
pub fn ruby_uv_l109_d11_install_package(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { uv_state_from_value(args[0]) } else { UvState{} }
	if state.executable == '' {
		return uv_error('RuntimeError', 'uv is not installed', {})
	}
	name := if args.len > 1 { args[1].as_string() } else { '' }
	requirements := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	source := if args.len > 3 && args[3].type_name != 'NilClass' { args[3].as_string() } else { '' }
	result := if args.len > 5 { args[5].as_bool() or { false } } else { false }
	return brew_runtime.map_value({
		'result':  brew_runtime.bool_value(result)
		'command': brew_runtime.string_array_value(([state.executable] as []string).clone())
		'args':    brew_runtime.string_array_value(uv_install_args(name, requirements, source))
	})
}

// Ruby method `installed_packages` at line 122.
pub fn ruby_uv_l122_d12_installed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { uv_state_from_value(args[0]) } else { UvState{} }
	if state.installed_packages.len > 0 {
		return uv_tools_value(state.installed_packages)
	}
	return uv_tools_value(state.packages.clone())
}

// Ruby method `parse_tool_list(output)` at line 130.
pub fn ruby_uv_l130_d13_parse_tool_list(args ...brew_runtime.Value) brew_runtime.Value {
	return uv_tools_value(uv_parse_tool_list(if args.len > 0 { args[0].as_string() } else { '' }))
}

// Ruby method `parse_source(required_raw)` at line 157.
pub fn ruby_uv_l157_d14_parse_source(args ...brew_runtime.Value) brew_runtime.Value {
	source := uv_parse_source(if args.len > 0 && args[0].type_name != 'NilClass' {
		args[0].as_string()
	} else {
		''
	})
	if source == '' {
		return brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.string_value(source)
}

// Ruby method `name_with_extras(name, extras_raw)` at line 168.
pub fn ruby_uv_l168_d15_name_with_extras(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	extras := if args.len > 1 && args[1].type_name != 'NilClass' { args[1].as_string() } else { '' }
	return brew_runtime.string_value(uv_name_with_extras(name, extras))
}

// Ruby method `parse_with_requirements(with_raw)` at line 179.
pub fn ruby_uv_l179_d16_parse_with_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	with_raw := if args.len > 0 && args[0].type_name != 'NilClass' {
		args[0].as_string()
	} else {
		''
	}
	return brew_runtime.string_array_value(uv_parse_with_requirements(with_raw))
}

// Ruby method `continuation_constraint?(requirement)` at line 200.
pub fn ruby_uv_l200_d17_continuation_constraint(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(uv_continuation_constraint(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `normalize_constraint(requirement)` at line 206.
pub fn ruby_uv_l206_d18_normalize_constraint(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(uv_normalize_constraint(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `normalize_with(with)` at line 212.
pub fn ruby_uv_l212_d19_normalize_with(args ...brew_runtime.Value) brew_runtime.Value {
	requirements := if args.len > 0 { args[0].as_string_array() or { [] } } else { [] }
	return brew_runtime.string_array_value(uv_normalize_with(requirements))
}

// Ruby method `normalize_source(source)` at line 218.
pub fn ruby_uv_l218_d20_normalize_source(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.string_value(uv_normalize_source(args[0].as_string()))
}

// Ruby method `normalize_name(name)` at line 224.
pub fn ruby_uv_l224_d21_normalize_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(uv_normalize_name(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `package_record(name, with: nil, source: nil)` at line 248.
pub fn ruby_uv_l248_d22_package_record(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	requirements := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	source := if args.len > 2 && args[2].type_name != 'NilClass' { args[2].as_string() } else { '' }
	return uv_tool_value(uv_normalized_options(name, requirements, source))
}

// Ruby method `normalized_options(name, with:, source: nil)` at line 253.
pub fn ruby_uv_l253_d23_normalized_options(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	requirements := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	source := if args.len > 2 && args[2].type_name != 'NilClass' { args[2].as_string() } else { '' }
	return uv_tool_value(uv_normalized_options(name, requirements, source))
}

// Ruby method `package_name(package)` at line 263.
pub fn ruby_uv_l263_d24_package_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return uv_error('ArgumentError', 'package is required', {})
	}
	return brew_runtime.string_value(uv_tool_from_value(args[0]).name)
}

// Ruby method `package_with(package)` at line 269.
pub fn ruby_uv_l269_d25_package_with(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return uv_error('ArgumentError', 'package is required', {})
	}
	return brew_runtime.string_array_value(uv_tool_from_value(args[0]).with)
}

// Ruby method `package_source(package)` at line 279.
pub fn ruby_uv_l279_d26_package_source(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return uv_error('ArgumentError', 'package is required', {})
	}
	source := uv_tool_from_value(args[0]).source
	if source == '' {
		return brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.string_value(source)
}

// Ruby method `dump_entry(package)` at line 287.
pub fn ruby_uv_l287_d27_dump_entry(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return uv_error('ArgumentError', 'package is required', {})
	}
	return brew_runtime.string_value(uv_dump_entry(uv_tool_from_value(args[0])))
}

// Ruby method `preinstall!(name, with: nil, source: nil, no_upgrade: false, verbose: false, **_options)` at line 305.
pub fn ruby_uv_l305_d28_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { uv_state_from_value(args[0]) } else { UvState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	requirements := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	source := if args.len > 3 && args[3].type_name != 'NilClass' { args[3].as_string() } else { '' }
	verbose := if args.len > 4 { args[4].as_bool() or { false } } else { false }
	if state.executable == '' {
		return uv_error('RuntimeError', 'Unable to install ${name} uv tool. uv installation failed.', {
			'command': 'brew install --formula uv'
		})
	}
	if uv_package_installed(state.installed_packages, name, requirements, source) {
		if verbose {
			return brew_runtime.map_value({
				'result': brew_runtime.bool_value(false)
				'output': brew_runtime.string_value('Skipping install of ${name} uv tool. It is already installed.')
			})
		}
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(true)
}

// Ruby method `install!(name, with: nil, source: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,` at line 330.
pub fn ruby_uv_l330_d29_install(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 { uv_state_from_value(args[0]) } else { UvState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	requirements := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	source := if args.len > 3 && args[3].type_name != 'NilClass' { args[3].as_string() } else { '' }
	preinstall := if args.len > 4 { args[4].as_bool() or { true } } else { true }
	verbose := if args.len > 5 { args[5].as_bool() or { false } } else { false }
	result := if args.len > 6 { args[6].as_bool() or { false } } else { false }
	if !preinstall {
		return brew_runtime.bool_value(true)
	}
	if verbose {
		state.output << 'Installing ${name} uv tool. It is not currently installed.'
	}
	command := ([state.executable] as []string).clone()
	mut full_command := command.clone()
	full_command << uv_install_args(name, requirements, source)
	state.commands << full_command
	if !result {
		return brew_runtime.map_value({
			'result': brew_runtime.bool_value(false)
			'state':  uv_state_value(state)
		})
	}
	tool := uv_normalized_options(name, requirements, source)
	if tool !in state.installed_packages {
		state.installed_packages << tool
	}
	if tool !in state.packages {
		state.packages << tool
	}
	return brew_runtime.map_value({
		'result': brew_runtime.bool_value(true)
		'state':  uv_state_value(state)
	})
}

// Ruby method `package_installed?(name, with: nil, source: nil)` at line 353.
pub fn ruby_uv_l353_d30_package_installed(args ...brew_runtime.Value) brew_runtime.Value {
	installed := if args.len > 0 { uv_tools_from_value(args[0]) } else { [] }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	requirements := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	source := if args.len > 3 && args[3].type_name != 'NilClass' { args[3].as_string() } else { '' }
	return brew_runtime.bool_value(uv_package_installed(installed, name, requirements, source))
}

// Ruby method `uninstall_package!(name, executable: Pathname.new(""))` at line 358.
pub fn ruby_uv_l358_d31_uninstall_package(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	executable := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.string_array_value([executable, 'tool', 'uninstall', name])
}

// Ruby method `format_checkable(entries)` at line 364.
pub fn ruby_uv_l364_d32_format_checkable(args ...brew_runtime.Value) brew_runtime.Value {
	entries_value := if args.len > 0 { args[0].as_array() or { [] } } else { [] }
	mut tools := []UvTool{}
	for entry_value in entries_value {
		entry := extension_entry_from_value(entry_value)
		if entry.entry_type == 'uv' {
			tools << uv_tool_from_value(entry_value)
		}
	}
	return uv_tools_value(tools)
}

// Ruby method `installed_and_up_to_date?(package, no_upgrade: false)` at line 371.
pub fn ruby_uv_l371_d33_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	installed := uv_tools_from_value(args[0])
	package := uv_tool_from_value(args[1])
	return brew_runtime.bool_value(uv_package_installed(installed, package.name, package.with, package.source))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     class Uv < Extension
// 9:       WithOptions = T.type_alias { T::Hash[Symbol, T.any(String, T::Array[String])] }
// 10:       Tool = T.type_alias { { name: String, with: T::Array[String], source: T.nilable(String) } }
// 11:       Checkable = T.type_alias { { name: String, options: WithOptions } }
// 12:       ToolEntry = T.type_alias { T.any(Tool, Checkable) }
// 13:
// 14:       SOURCE_REQUIREMENT_REGEX = %r{\A(?:git\+|https?://)|\.git\z}
// 15:       # `uv tool list` reports a tool installed from a directory as an absolute
// 16:       # `file://` URL, and a hand-written Brewfile can name a path directly.
// 17:       # `uv tool install` also takes either spelling behind a `git+` prefix.
// 18:       # None of them resolves on another machine, so none is accepted, and a
// 19:       # tool installed from one is dumped without a `source:` rather than with
// 20:       # one that would then fail to parse.
// 21:       LOCAL_SOURCE_REGEX = %r{\A(?:git\+)?(?:file://|\.{0,2}/)}
// 22:
// 23:       class << self
// 24:         sig { override.returns(Symbol) }
// 25:         def type = :uv
// 26:
// 27:         sig { override.returns(String) }
// 28:         def check_label = "uv Tool"
// 29:
// 30:         sig { override.returns(String) }
// 31:         def banner_name = "uv tools"
// 32:
// 33:         sig { override.params(name: String, options: Homebrew::Bundle::EntryInputOptions).returns(Dsl::Entry) }
// 34:         def entry(name, options = {})
// 35:           unknown_options = options.keys - [:with, :source]
// 36:           raise "unknown options(#{unknown_options.inspect}) for uv" if unknown_options.present?
// 37:
// 38:           with = options[:with]
// 39:           if !with.nil? && (!with.is_a?(Array) || with.any? { |requirement| !requirement.is_a?(String) })
// 40:             raise "options[:with](#{with.inspect}) should be an Array of String objects"
// 41:           end
// 42:
// 43:           source = options.fetch(:source, nil)
// 44:           if !source.nil? && !source.is_a?(String)
// 45:             raise "options[:source](#{source.inspect}) should be a String object"
// 46:           end
// 47:
// 48:           normalized_options = {}
// 49:           normalized_with = normalize_with(with || [])
// 50:           normalized_options[:with] = normalized_with if normalized_with.present?
// 51:           normalized_source = normalize_source(source)
// 52:           if normalized_source&.match?(LOCAL_SOURCE_REGEX)
// 53:             raise "options[:source](#{source.inspect}) is local to this machine so cannot be used in a Brewfile"
// 54:           end
// 55:
// 56:           normalized_options[:source] = normalized_source if normalized_source.present?
// 57:
// 58:           Dsl::Entry.new(:uv, name, normalized_options)
// 59:         end
// 60:
// 61:         sig { override.void }
// 62:         def reset!
// 63:           @packages = T.let(nil, T.nilable(T::Array[Tool]))
// 64:           @installed_packages = T.let(nil, T.nilable(T::Array[Tool]))
// 65:         end
// 66:
// 67:         sig { override.returns(T.nilable(String)) }
// 68:         def cleanup_heading
// 69:           banner_name
// 70:         end
// 71:
// 72:         sig { override.returns(T::Array[Tool]) }
// 73:         def packages
// 74:           packages = @packages
// 75:           return packages if packages
// 76:
// 77:           @packages = if (uv = package_manager_executable)
// 78:             output = `#{uv} tool list --show-with --show-extras --show-version-specifiers 2>/dev/null`
// 79:             parse_tool_list(output)
// 80:           end
// 81:           return [] if @packages.nil?
// 82:
// 83:           @packages
// 84:         end
// 85:
// 86:         sig { override.params(package: Object).returns(String) }
// 87:         def dump_name(package)
// 88:           package_name(T.cast(package, ToolEntry))
// 89:         end
// 90:
// 91:         sig { override.params(package: Object).returns(T.nilable(T::Array[String])) }
// 92:         def dump_with(package)
// 93:           package_with(T.cast(package, ToolEntry))
// 94:         end
// 95:
// 96:         sig { params(package: Object).returns(T.nilable(String)) }
// 97:         def dump_source(package)
// 98:           package_source(T.cast(package, ToolEntry))
// 99:         end
// 100:
// 101:         sig {
// 102:           override.params(
// 103:             name:    String,
// 104:             with:    T.nilable(T::Array[String]),
// 105:             source:  T.nilable(String),
// 106:             verbose: T::Boolean,
// 107:           ).returns(T::Boolean)
// 108:         }
// 109:         def install_package!(name, with: nil, source: nil, verbose: false)
// 110:           uv = package_manager_executable!
// 111:
// 112:           args = ["tool", "install", source.presence || name]
// 113:           normalize_with(with || []).each do |requirement|
// 114:             args << "--with"
// 115:             args << requirement
// 116:           end
// 117:
// 118:           Bundle.system(uv.to_s, *args, verbose:)
// 119:         end
// 120:
// 121:         sig { override.returns(T::Array[Tool]) }
// 122:         def installed_packages
// 123:           installed_packages = @installed_packages
// 124:           return installed_packages if installed_packages
// 125:
// 126:           @installed_packages = packages.dup
// 127:         end
// 128:
// 129:         sig { params(output: String).returns(T::Array[Tool]) }
// 130:         def parse_tool_list(output)
// 131:           entries = T.let([], T::Array[Tool])
// 132:
// 133:           output.each_line do |line|
// 134:             match = line.match(/\A(\S+)\s+v\S+/)
// 135:             next unless match
// 136:
// 137:             name = match[1]
// 138:             next if name.nil?
// 139:
// 140:             extras_raw = line[/\[extras:\s*([^\]]+)\]/, 1]
// 141:             name = name_with_extras(name, extras_raw)
// 142:             with_raw = line[/\[with:\s*([^\]]+)\]/, 1]
// 143:             required_raw = line[/\[required:\s*([^\]]+)\]/, 1]
// 144:
// 145:             entries << {
// 146:               name:   name,
// 147:               with:   parse_with_requirements(with_raw),
// 148:               source: parse_source(required_raw),
// 149:             }
// 150:           end
// 151:
// 152:           entries.sort_by { |entry| entry[:name].to_s }
// 153:         end
// 154:         private :parse_tool_list
// 155:
// 156:         sig { params(required_raw: T.nilable(String)).returns(T.nilable(String)) }
// 157:         def parse_source(required_raw)
// 158:           source = normalize_source(required_raw)
// 159:           return if source.nil?
// 160:           return if source.match?(LOCAL_SOURCE_REGEX)
// 161:           return source if source.match?(SOURCE_REQUIREMENT_REGEX)
// 162:
// 163:           nil
// 164:         end
// 165:         private :parse_source
// 166:
// 167:         sig { params(name: String, extras_raw: T.nilable(String)).returns(String) }
// 168:         def name_with_extras(name, extras_raw)
// 169:           return name if extras_raw.blank?
// 170:
// 171:           extras = extras_raw.split(",").map(&:strip).reject(&:empty?).uniq.sort
// 172:           return name if extras.empty?
// 173:
// 174:           "#{name}[#{extras.join(",")}]"
// 175:         end
// 176:         private :name_with_extras
// 177:
// 178:         sig { params(with_raw: T.nilable(String)).returns(T::Array[String]) }
// 179:         def parse_with_requirements(with_raw)
// 180:           return [] if with_raw.blank?
// 181:
// 182:           entries = T.let([], T::Array[String])
// 183:           with_raw.split(", ").each do |token|
// 184:             requirement = token.strip
// 185:             next if requirement.empty?
// 186:
// 187:             if continuation_constraint?(requirement) && entries.any?
// 188:               last_requirement = entries.pop
// 189:               entries << "#{last_requirement}, #{normalize_constraint(requirement)}" if last_requirement
// 190:             else
// 191:               entries << requirement
// 192:             end
// 193:           end
// 194:
// 195:           entries.uniq.sort
// 196:         end
// 197:         private :parse_with_requirements
// 198:
// 199:         sig { params(requirement: String).returns(T::Boolean) }
// 200:         def continuation_constraint?(requirement)
// 201:           requirement.match?(/\A(?:<=|>=|!=|==|~=|<|>)\s*\S/)
// 202:         end
// 203:         private :continuation_constraint?
// 204:
// 205:         sig { params(requirement: String).returns(String) }
// 206:         def normalize_constraint(requirement)
// 207:           requirement.strip.sub(/\A(<=|>=|!=|==|~=|<|>)\s+/, "\\1")
// 208:         end
// 209:         private :normalize_constraint
// 210:
// 211:         sig { params(with: T::Array[String]).returns(T::Array[String]) }
// 212:         def normalize_with(with)
// 213:           with.map(&:strip).reject(&:empty?).uniq.sort
// 214:         end
// 215:         private :normalize_with
// 216:
// 217:         sig { params(source: T.nilable(String)).returns(T.nilable(String)) }
// 218:         def normalize_source(source)
// 219:           source.presence&.strip
// 220:         end
// 221:         private :normalize_source
// 222:
// 223:         sig { params(name: String).returns(String) }
// 224:         def normalize_name(name)
// 225:           match = name.strip.match(/\A(?<base>[^\[\]]+)(?:\[(?<extras>[^\]]+)\])?\z/)
// 226:           return name.strip unless match
// 227:
// 228:           base = match[:base]
// 229:           return name.strip if base.nil?
// 230:
// 231:           extras_raw = match[:extras]
// 232:           return base.strip if extras_raw.blank?
// 233:
// 234:           extras = extras_raw.split(",").map(&:strip).reject(&:empty?).uniq.sort
// 235:           return base.strip if extras.empty?
// 236:
// 237:           "#{base.strip}[#{extras.join(",")}]"
// 238:         end
// 239:         private :normalize_name
// 240:
// 241:         sig {
// 242:           override.params(
// 243:             name:   String,
// 244:             with:   T.nilable(T::Array[String]),
// 245:             source: T.nilable(String),
// 246:           ).returns(Object)
// 247:         }
// 248:         def package_record(name, with: nil, source: nil)
// 249:           normalized_options(name, with: with || [], source:)
// 250:         end
// 251:
// 252:         sig { params(name: String, with: T::Array[String], source: T.nilable(String)).returns(Tool) }
// 253:         def normalized_options(name, with:, source: nil)
// 254:           {
// 255:             name:   normalize_name(name),
// 256:             with:   normalize_with(with),
// 257:             source: normalize_source(source),
// 258:           }
// 259:         end
// 260:         private :normalized_options
// 261:
// 262:         sig { params(package: ToolEntry).returns(String) }
// 263:         def package_name(package)
// 264:           package[:name]
// 265:         end
// 266:         private :package_name
// 267:
// 268:         sig { params(package: ToolEntry).returns(T.nilable(T::Array[String])) }
// 269:         def package_with(package)
// 270:           if package.key?(:with)
// 271:             package[:with]
// 272:           else
// 273:             package[:options].fetch(:with, [])
// 274:           end
// 275:         end
// 276:         private :package_with
// 277:
// 278:         sig { params(package: ToolEntry).returns(T.nilable(String)) }
// 279:         def package_source(package)
// 280:           return package[:source] if package.key?(:source)
// 281:
// 282:           T.cast(package[:options].fetch(:source, nil), T.nilable(String))
// 283:         end
// 284:         private :package_source
// 285:
// 286:         sig { override.params(package: Object).returns(String) }
// 287:         def dump_entry(package)
// 288:           line = super
// 289:           source = dump_source(package)
// 290:           line = "#{line}, source: #{quote(source)}" if source.present?
// 291:
// 292:           line
// 293:         end
// 294:
// 295:         sig {
// 296:           override.params(
// 297:             name:       String,
// 298:             with:       T.nilable(T::Array[String]),
// 299:             source:     T.nilable(String),
// 300:             no_upgrade: T::Boolean,
// 301:             verbose:    T::Boolean,
// 302:             _options:   Homebrew::Bundle::EntryOption,
// 303:           ).returns(T::Boolean)
// 304:         }
// 305:         def preinstall!(name, with: nil, source: nil, no_upgrade: false, verbose: false, **_options)
// 306:           _ = no_upgrade
// 307:
// 308:           ensure_package_manager_installed!(name, verbose:)
// 309:
// 310:           if package_installed?(name, with:, source:)
// 311:             puts "Skipping install of #{name} #{package_description}. It is already installed." if verbose
// 312:             return false
// 313:           end
// 314:
// 315:           true
// 316:         end
// 317:
// 318:         sig {
// 319:           override.params(
// 320:             name:       String,
// 321:             with:       T.nilable(T::Array[String]),
// 322:             source:     T.nilable(String),
// 323:             preinstall: T::Boolean,
// 324:             no_upgrade: T::Boolean,
// 325:             verbose:    T::Boolean,
// 326:             force:      T::Boolean,
// 327:             _options:   Homebrew::Bundle::EntryOption,
// 328:           ).returns(T::Boolean)
// 329:         }
// 330:         def install!(name, with: nil, source: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,
// 331:                      **_options)
// 332:           _ = no_upgrade
// 333:           _ = force
// 334:
// 335:           return true unless preinstall
// 336:
// 337:           puts "Installing #{name} #{package_description}. It is not currently installed." if verbose
// 338:           return false unless install_package!(name, with:, source:, verbose:)
// 339:
// 340:           package = normalized_options(name, with: with || [], source:)
// 341:           installed_packages << package unless installed_packages.include?(package)
// 342:           packages << package unless packages.include?(package)
// 343:           true
// 344:         end
// 345:
// 346:         sig {
// 347:           override.params(
// 348:             name:   String,
// 349:             with:   T.nilable(T::Array[String]),
// 350:             source: T.nilable(String),
// 351:           ).returns(T::Boolean)
// 352:         }
// 353:         def package_installed?(name, with: nil, source: nil)
// 354:           installed_packages.include?(package_record(name, with:, source:))
// 355:         end
// 356:
// 357:         sig { override.params(name: String, executable: Pathname).void }
// 358:         def uninstall_package!(name, executable: Pathname.new(""))
// 359:           Bundle.system(executable.to_s, "tool", "uninstall", name, verbose: false)
// 360:         end
// 361:       end
// 362:
// 363:       sig { override.params(entries: T::Array[Dsl::Entry]).returns(T::Array[Object]) }
// 364:       def format_checkable(entries)
// 365:         checkable_entries(entries).map do |entry|
// 366:           { name: entry.name, options: entry.options }
// 367:         end
// 368:       end
// 369:
// 370:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 371:       def installed_and_up_to_date?(package, no_upgrade: false)
// 372:         self.class.package_installed?(
// 373:           self.class.dump_name(package),
// 374:           with:   self.class.dump_with(package),
// 375:           source: self.class.dump_source(package),
// 376:         )
// 377:       end
// 378:     end
// 379:   end
// 380: end
