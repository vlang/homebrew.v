module extensions

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
