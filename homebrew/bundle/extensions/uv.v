module extensions

import ruby

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

fn uv_error(kind string, message string, attributes map[string]string) ruby.Value {
	return ruby.structured_value(kind, message, attributes)
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

pub fn uv_tool_value(tool UvTool) ruby.Value {
	return ruby.map_value({
		'name':   ruby.string_value(tool.name)
		'with':   ruby.string_array_value(tool.with)
		'source': if tool.source == '' {
			ruby.object_value('NilClass', '')
		} else {
			ruby.string_value(tool.source)
		}
	})
}

pub fn uv_tool_from_value(value ruby.Value) UvTool {
	values := value.as_map() or { return uv_normalized_options(value.as_string(), [], '') }
	if 'options' in values {
		options := values['options'].as_map() or { map[string]ruby.Value{} }
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
			values['source'].as_string()
		} else {
			''
		}
	}
}

pub fn uv_tools_value(tools []UvTool) ruby.Value {
	return ruby.array_value(tools.map(uv_tool_value(it)))
}

pub fn uv_tools_from_value(value ruby.Value) []UvTool {
	items := value.as_array() or { return [] }
	return items.map(uv_tool_from_value(it))
}

pub fn uv_state_value(state UvState) ruby.Value {
	return ruby.map_value({
		'_definition':        extension_definition_value(uv_definition())
		'executable':         if state.executable == '' {
			ruby.object_value('NilClass', '')
		} else {
			ruby.object_value('Pathname', state.executable)
		}
		'packages':           uv_tools_value(state.packages)
		'installed_packages': uv_tools_value(state.installed_packages)
		'output':             ruby.string_array_value(state.output)
		'commands':           ruby.array_value(state.commands.map(ruby.string_array_value(it)))
	})
}

pub fn uv_state_from_value(value ruby.Value) UvState {
	values := value.as_map() or { return UvState{} }
	mut commands := [][]string{}
	if 'commands' in values {
		for command in values['commands'].as_array() or { [] } {
			commands << (command.as_string_array() or { [] })
		}
	}
	return UvState{
		executable: if 'executable' in values && values['executable'].type_name != 'NilClass' {
			values['executable'].as_string()
		} else {
			''
		}
		packages: if 'packages' in values { uv_tools_from_value(values['packages']) } else { [] }
		installed_packages: if 'installed_packages' in values {
			uv_tools_from_value(values['installed_packages'])
		} else {
			[]
		}
		output: if 'output' in values { values['output'].as_string_array() or { [] } } else { [] }
		commands: commands
	}
}

pub fn uv_entry(name string, options map[string]ruby.Value) !ExtensionEntry {
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
	source_value := options['source'] or { ruby.object_value('NilClass', '') }
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
	mut normalized := map[string]ruby.Value{}
	normalized_with := uv_normalize_with(requirements)
	if normalized_with.len > 0 {
		normalized['with'] = ruby.string_array_value(normalized_with)
	}
	if source != '' {
		normalized['source'] = ruby.string_value(source)
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
