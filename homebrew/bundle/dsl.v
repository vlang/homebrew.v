module bundle

import ruby

// Translated from Homebrew/brew `bundle/dsl.rb`.
pub struct BundleDslEntry {
pub:
	entry_type string
	name       string
	options    map[string]ruby.Value
}

pub struct BundleDsl {
pub:
	path           string
	input          string
	entries        []BundleDslEntry
	cask_arguments map[string]ruby.Value
}

const bundle_dsl_extensions = ['mas', 'vscode', 'winget', 'go', 'cargo', 'uv', 'flatpak', 'npm',
	'krew']

pub fn bundle_dsl_entry(entry_type string, name string, options map[string]ruby.Value) BundleDslEntry {
	return BundleDslEntry{
		entry_type: entry_type
		name: name
		options: options.clone()
	}
}

pub fn parse_bundle_dsl(path string, input string) !BundleDsl {
	mut entries := []BundleDslEntry{}
	mut cask_arguments := map[string]ruby.Value{}
	for source_line in input.split_into_lines() {
		mut line := strip_dsl_comment(source_line).trim_space()
		if line == '' || line.starts_with('#') {
			continue
		}
		if line.contains(' unless system ') {
			line = line.all_before(' unless system ').trim_space()
		}
		method_end := line.index_any(' \t')
		if method_end < 0 {
			return error('Invalid Brewfile: unknown command `${line}`')
		}
		method_name := line[..method_end]
		raw_arguments := line[method_end..].trim_space()
		parts := split_dsl_top_level(raw_arguments, `,`)
		if method_name == 'cask_args' {
			if parts.len != 1 {
				return error('Invalid Brewfile: wrong number of arguments for cask_args')
			}
			arguments := parse_dsl_options(parts[0]) or {
				return error('Invalid Brewfile: cask arguments must be a Hash')
			}
			for key, value in arguments {
				cask_arguments[key] = value
			}
			continue
		}
		if method_name !in ['brew', 'cask', 'tap'] && method_name !in bundle_dsl_extensions {
			return error('Invalid Brewfile: unknown command `${method_name}`')
		}
		if parts.len == 0 {
			return error('Invalid Brewfile: wrong number of arguments for ${method_name}')
		}
		name_value := parse_dsl_value(parts[0]) or {
			return error('Invalid Brewfile: ${method_name} name must be a String')
		}
		if name_value.type_name != 'String' {
			return error('Invalid Brewfile: ${method_name} name must be a String')
		}
		mut options := map[string]ruby.Value{}
		mut clone_target := ruby.object_value('NilClass', '')
		mut option_start := 1
		if method_name == 'tap' && parts.len > 1 && (parts[1].trim_space().starts_with('{') || !dsl_part_looks_like_options(parts[1])) {
			clone_target = parse_dsl_value(parts[1]) or {
				return error('Invalid Brewfile: tap clone target must be a String')
			}
			if clone_target.type_name !in ['String', 'NilClass'] {
				return error('Invalid Brewfile: tap clone target must be a String')
			}
			option_start = 2
		}
		for index := option_start; index < parts.len; index++ {
			parsed_options := parse_dsl_options(parts[index]) or {
				return error('Invalid Brewfile: options(${parts[index]}) should be a Hash object')
			}
			for key, value in parsed_options {
				options[key] = value
			}
		}
		match method_name {
			'brew' {
				entries << bundle_dsl_entry('brew', sanitize_brew_name(name_value.repr), options)
			}
			'cask' {
				full_name := name_value.repr
				options['full_name'] = ruby.string_value(full_name)
				mut merged_args := cask_arguments.clone()
				if 'args' in options {
					local_args := options['args'].as_map() or {
						return error('Invalid Brewfile: cask options[:args] must be a Hash')
					}
					for key, value in local_args {
						merged_args[key] = value
					}
				}
				options['args'] = ruby.map_value(merged_args)
				entries << bundle_dsl_entry('cask', sanitize_cask_name(full_name), options)
			}
			'tap' {
				options['clone_target'] = clone_target
				entries << bundle_dsl_entry('tap', sanitize_tap_name(name_value.repr), options)
			}
			else {
				entries << extension_dsl_entry(method_name, name_value.repr, options)!
			}
		}
	}
	return BundleDsl{
		path: path
		input: input
		entries: entries
		cask_arguments: cask_arguments
	}
}

pub fn sanitize_brew_name(raw_name string) string {
	name := raw_name.to_lower()
	parts := name.split('/')
	if parts.len == 3 && parts[0] == 'homebrew' && parts[1] == 'homebrew' {
		return parts[2]
	}
	if parts.len == 3 {
		repository := parts[1].trim_string_left('homebrew-')
		return '${parts[0]}/${repository}/${parts[2]}'
	}
	return name
}

pub fn sanitize_tap_name(raw_name string) string {
	name := raw_name.to_lower()
	parts := name.split('/')
	if parts.len == 2 {
		return '${parts[0]}/${parts[1].trim_string_left('homebrew-')}'
	}
	return name
}

pub fn sanitize_cask_name(raw_name string) string {
	parts := raw_name.split('/')
	return parts[parts.len - 1].to_lower()
}

pub fn bundle_dsl_responds_to(method_name string) bool {
	return method_name in bundle_dsl_extensions
}

fn extension_dsl_entry(method_name string, name string, raw_options map[string]ruby.Value) !BundleDslEntry {
	mut options := raw_options.clone()
	allowed := match method_name {
		'mas' { ['id'] }
		'winget' { ['id', 'source'] }
		'uv' { ['with', 'source'] }
		'cargo' { ['source'] }
		'flatpak' { ['remote', 'url'] }
		else { []string{} }
	}
	mut unknown := []string{}
	for key, _ in options {
		if key !in allowed {
			unknown << key
		}
	}
	if unknown.len > 0 {
		return error('Invalid Brewfile: unknown options(${unknown}) for ${method_name}')
	}
	if method_name == 'mas' {
		if 'id' !in options || options['id'].type_name != 'Integer' {
			return error('Invalid Brewfile: options[:id] should be an Integer object')
		}
	}
	if method_name in ['uv', 'cargo'] && 'source' in options && options['source'].type_name != 'String' {
		return error('Invalid Brewfile: options[:source] should be a String object')
	}
	if method_name == 'uv' && 'with' in options {
		value := options['with']
		if value.type_name != 'Array' {
			return error('Invalid Brewfile: options[:with] should be an Array of String objects')
		}
		with_values := value.as_array() or {
			return error('Invalid Brewfile: options[:with] should be an Array of String objects')
		}
		if with_values.any(it.type_name != 'String') {
			return error('Invalid Brewfile: options[:with] should be an Array of String objects')
		}
	}
	if method_name == 'winget' {
		if 'id' in options && options['id'].type_name != 'String' {
			return error('Invalid Brewfile: options[:id] should be a String object')
		}
		if 'source' in options && options['source'].type_name != 'String' {
			return error('Invalid Brewfile: options[:source] should be a String object')
		}
		source := if 'source' in options { options['source'].repr } else { 'winget' }
		if source !in ['winget', 'msstore'] {
			return error('Invalid Brewfile: options[:source] should be one of [winget, msstore]')
		}
		if 'id' !in options {
			options['id'] = ruby.string_value(name)
		}
		options['source'] = ruby.string_value(source)
	}
	if method_name == 'flatpak' {
		for key in ['remote', 'url'] {
			if key in options && options[key].type_name != 'String' {
				return error('Invalid Brewfile: options[:${key}] should be a String object')
			}
		}
		remote := if 'remote' in options { options['remote'].repr } else { 'flathub' }
		if 'url' in options && (remote.starts_with('http://') || remote.starts_with('https://')) {
			return error('Invalid Brewfile: url: cannot be used when remote: is already a URL')
		}
		options['remote'] = ruby.string_value(remote)
	}
	return bundle_dsl_entry(method_name, name, options)
}

fn strip_dsl_comment(line string) string {
	mut quote := u8(0)
	for index, character in line.bytes() {
		if character == `'` || character == `"` {
			if quote == character {
				quote = 0
			} else if quote == 0 {
				quote = character
			}
		} else if character == `#` && quote == 0 {
			return line[..index]
		}
	}
	return line
}

fn split_dsl_top_level(text string, separator u8) []string {
	mut parts := []string{}
	mut quote := u8(0)
	mut depth := 0
	mut start := 0
	for index, character in text.bytes() {
		if character == `'` || character == `"` {
			if quote == character {
				quote = 0
			} else if quote == 0 {
				quote = character
			}
			continue
		}
		if quote != 0 {
			continue
		}
		if character == `[` || character == `{` || character == `(` {
			depth++
		} else if character == `]` || character == `}` || character == `)` {
			depth--
		} else if character == separator && depth == 0 {
			parts << text[start..index].trim_space()
			start = index + 1
		}
	}
	if text[start..].trim_space() != '' {
		parts << text[start..].trim_space()
	}
	return parts
}

fn dsl_part_looks_like_options(part string) bool {
	trimmed := part.trim_space()
	return trimmed.starts_with('{') || dsl_top_level_colon(trimmed) >= 0
}

fn dsl_top_level_colon(text string) int {
	mut quote := u8(0)
	mut depth := 0
	for index, character in text.bytes() {
		if character == `'` || character == `"` {
			if quote == character {
				quote = 0
			} else if quote == 0 {
				quote = character
			}
			continue
		}
		if quote != 0 {
			continue
		}
		if character == `[` || character == `{` {
			depth++
		} else if character == `]` || character == `}` {
			depth--
		} else if character == `:` && depth == 0 {
			return index
		}
	}
	return -1
}

fn parse_dsl_options(raw string) !map[string]ruby.Value {
	mut text := raw.trim_space()
	if text.starts_with('{') && text.ends_with('}') {
		text = text[1..text.len - 1].trim_space()
	}
	if text == '' {
		return map[string]ruby.Value{}
	}
	mut result := map[string]ruby.Value{}
	for pair in split_dsl_top_level(text, `,`) {
		colon := dsl_top_level_colon(pair)
		if colon < 1 {
			return error('expected Hash')
		}
		key := pair[..colon].trim_space().trim_left(':').trim('"\'')
		result[key] = parse_dsl_value(pair[colon + 1..])!
	}
	return result
}

fn parse_dsl_value(raw string) !ruby.Value {
	text := raw.trim_space()
	if text.len >= 2 && ((text[0] == `'` && text[text.len - 1] == `'`) || (text[0] == `"` && text[text.len - 1] == `"`)) {
		return ruby.string_value(text[1..text.len - 1])
	}
	if text.starts_with(':') && text.len > 1 {
		return ruby.object_value('Symbol', text[1..])
	}
	if text == 'true' || text == 'false' {
		return ruby.bool_value(text == 'true')
	}
	if text == 'nil' {
		return ruby.object_value('NilClass', '')
	}
	if text.starts_with('[') && text.ends_with(']') {
		mut values := []ruby.Value{}
		for item in split_dsl_top_level(text[1..text.len - 1], `,`) {
			values << parse_dsl_value(item)!
		}
		return ruby.array_value(values)
	}
	if text.starts_with('{') && text.ends_with('}') {
		return ruby.map_value(parse_dsl_options(text)!)
	}
	if text != '' && text.bytes().all(it >= `0` && it <= `9`) {
		return ruby.int_value(text.i64())
	}
	return error('unsupported value `${text}`')
}

pub fn bundle_dsl_entry_value(entry BundleDslEntry) ruby.Value {
	return ruby.Value{
		type_name: 'Homebrew::Bundle::Dsl::Entry'
		repr: entry.name
		map_data: entry.options.clone()
		attributes: {
			'type': entry.entry_type
			'name': entry.name
		}
	}
}

pub fn bundle_dsl_value(dsl BundleDsl) ruby.Value {
	return ruby.Value{
		type_name: 'Homebrew::Bundle::Dsl'
		repr: dsl.path
		array_data: dsl.entries.map(bundle_dsl_entry_value(it))
		map_data: dsl.cask_arguments.clone()
		attributes: {
			'path':  dsl.path
			'input': dsl.input
		}
	}
}
