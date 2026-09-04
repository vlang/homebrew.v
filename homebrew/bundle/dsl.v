module bundle

import ruby

// Translated from Homebrew/brew `bundle/dsl.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby attr_reader `attr_reader :type` at line 16.
pub fn ruby_dsl_l16_d1_type(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.string_value(args[0].attributes['type'] or { '' })
	} else {
		ruby.object_value('NilClass', '')
	}
}

// Ruby attr_reader `attr_reader :name` at line 19.
pub fn ruby_dsl_l19_d2_name(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.string_value(args[0].repr)
	} else {
		ruby.object_value('NilClass', '')
	}
}

// Ruby attr_reader `attr_reader :options` at line 22.
pub fn ruby_dsl_l22_d3_options(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.map_value(args[0].map_data)
	} else {
		ruby.map_value({})
	}
}

// Ruby method `initialize(type, name, options = {})` at line 25.
pub fn ruby_dsl_l25_d4_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'type and name are required')
	}
	options := if args.len > 2 {
		args[2].as_map() or { return ruby.object_value('ArgumentError', err.msg()) }
	} else {
		map[string]ruby.Value{}
	}
	return bundle_dsl_entry_value(bundle_dsl_entry(args[0].repr, args[1].repr, options))
}

// Ruby method `to_s` at line 32.
pub fn ruby_dsl_l32_d5_to_s(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.string_value(args[0].repr)
	} else {
		ruby.string_value('')
	}
}

// Ruby attr_reader `attr_reader :entries` at line 38.
pub fn ruby_dsl_l38_d6_entries(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.array_value(args[0].array_data)
	} else {
		ruby.array_value([])
	}
}

// Ruby attr_reader `attr_reader :cask_arguments` at line 41.
pub fn ruby_dsl_l41_d7_cask_arguments(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.map_value(args[0].map_data)
	} else {
		ruby.map_value({})
	}
}

// Ruby attr_reader `attr_reader :input` at line 44.
pub fn ruby_dsl_l44_d8_input(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.string_value(args[0].attributes['input'] or { '' })
	} else {
		ruby.string_value('')
	}
}

// Ruby method `initialize(path)` at line 47.
pub fn ruby_dsl_l47_d9_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'path is required')
	}
	input := args[0].repr
	path := args[0].attributes['path'] or { '<StringIO>' }
	dsl := parse_bundle_dsl(path, input) or { return ruby.object_value('RuntimeError', err.msg()) }
	return bundle_dsl_value(dsl)
}

// Ruby method `process` at line 66.
pub fn ruby_dsl_l66_d10_process(args ...ruby.Value) ruby.Value {
	return ruby_dsl_l47_d9_initialize(...args)
}

// Ruby method `cask_args(args)` at line 71.
pub fn ruby_dsl_l71_d11_cask_args(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return ruby.object_value('ArgumentError', 'cask arguments must be a Hash')
	}
	return ruby.map_value(args[0].map_data)
}

// Ruby method `brew(name, options = {})` at line 76.
pub fn ruby_dsl_l76_d12_brew(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'String' {
		return ruby.object_value('ArgumentError', 'brew name must be a String')
	}
	options := if args.len > 1 {
		args[1].as_map() or { return ruby.object_value('ArgumentError', 'brew options must be a Hash') }
	} else {
		map[string]ruby.Value{}
	}
	return bundle_dsl_entry_value(bundle_dsl_entry('brew', sanitize_brew_name(args[0].repr), options))
}

// Ruby method `cask(name, options = {})` at line 84.
pub fn ruby_dsl_l84_d13_cask(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'String' {
		return ruby.object_value('ArgumentError', 'cask name must be a String')
	}
	mut options := if args.len > 1 {
		args[1].as_map() or { return ruby.object_value('ArgumentError', 'cask options must be a Hash') }
	} else {
		map[string]ruby.Value{}
	}
	options['full_name'] = ruby.string_value(args[0].repr)
	if 'args' !in options {
		options['args'] = ruby.map_value({})
	}
	return bundle_dsl_entry_value(bundle_dsl_entry('cask', sanitize_cask_name(args[0].repr), options))
}

// Ruby method `tap(name, clone_target = nil, options = {}, **keyword_options)` at line 100.
pub fn ruby_dsl_l100_d14_tap(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'String' {
		return ruby.object_value('ArgumentError', 'tap name must be a String')
	}
	mut options := map[string]ruby.Value{}
	mut clone_target := ruby.object_value('NilClass', '')
	if args.len > 1 {
		if args[1].type_name == 'Hash' {
			options = args[1].map_data.clone()
		} else if args[1].type_name == 'String' {
			clone_target = args[1]
		} else {
			return ruby.object_value('ArgumentError', 'tap clone target must be a String')
		}
	}
	if args.len > 2 {
		for key, value in args[2].as_map() or { return ruby.object_value('ArgumentError', err.msg()) } {
			options[key] = value
		}
	}
	options['clone_target'] = clone_target
	return bundle_dsl_entry_value(bundle_dsl_entry('tap', sanitize_tap_name(args[0].repr), options))
}

// Ruby method `validate_type!(value, type, description)` at line 110.
pub fn ruby_dsl_l110_d15_validate_type(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'value and type are required')
	}
	if args[0].type_name != args[1].repr {
		description := if args.len > 2 { args[2].repr } else { 'value' }
		return ruby.object_value('TypeError', '${description} must be a ${args[1].repr}')
	}
	return ruby.object_value('NilClass', '')
}

// Ruby method `self.sanitize_brew_name(name)` at line 120.
pub fn ruby_dsl_l120_d16_self_sanitize_brew_name(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.string_value(sanitize_brew_name(args[0].repr))
	} else {
		ruby.string_value('')
	}
}

// Ruby method `self.sanitize_tap_name(name)` at line 140.
pub fn ruby_dsl_l140_d17_self_sanitize_tap_name(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.string_value(sanitize_tap_name(args[0].repr))
	} else {
		ruby.string_value('')
	}
}

// Ruby method `self.sanitize_cask_name(name)` at line 150.
pub fn ruby_dsl_l150_d18_self_sanitize_cask_name(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.string_value(sanitize_cask_name(args[0].repr))
	} else {
		ruby.string_value('')
	}
}

// Ruby method `method_missing(method_name, *args, **options, &block)` at line 159.
pub fn ruby_dsl_l159_d19_method_missing(args ...ruby.Value) ruby.Value {
	if args.len < 2 || !bundle_dsl_responds_to(args[0].repr) {
		return ruby.object_value('NoMethodError', 'unknown Bundle DSL method')
	}
	options := if args.len > 2 {
		args[2].as_map() or { return ruby.object_value('ArgumentError', err.msg()) }
	} else {
		map[string]ruby.Value{}
	}
	entry := extension_dsl_entry(args[0].repr, args[1].repr, options) or { return ruby.object_value('RuntimeError', err.msg()) }
	return bundle_dsl_entry_value(entry)
}

// Ruby method `respond_to_missing?(method_name, include_private = false)` at line 186.
pub fn ruby_dsl_l186_d20_respond_to_missing(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && bundle_dsl_responds_to(args[0].repr))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Bundle
// 6:     EntryOptionScalar = T.type_alias { T.nilable(T.any(String, Integer, Symbol, TrueClass, FalseClass)) }
// 7:     NestedEntryOptionValue = T.type_alias { T.any(EntryOptionScalar, T::Array[String]) }
// 8:     NestedEntryOptions = T.type_alias { T::Hash[Symbol, NestedEntryOptionValue] }
// 9:     EntryOption = T.type_alias { T.any(EntryOptionScalar, T::Array[String], NestedEntryOptions) }
// 10:     EntryOptions = T.type_alias { T::Hash[Symbol, EntryOption] }
// 11:     EntryInputOptions = T.type_alias { T::Hash[Symbol, Object] }
// 12:
// 13:     class Dsl
// 14:       class Entry
// 15:         sig { returns(Symbol) }
// 16:         attr_reader :type
// 17:
// 18:         sig { returns(String) }
// 19:         attr_reader :name
// 20:
// 21:         sig { returns(Homebrew::Bundle::EntryOptions) }
// 22:         attr_reader :options
// 23:
// 24:         sig { params(type: Symbol, name: String, options: Homebrew::Bundle::EntryOptions).void }
// 25:         def initialize(type, name, options = {})
// 26:           @type = type
// 27:           @name = name
// 28:           @options = options
// 29:         end
// 30:
// 31:         sig { returns(String) }
// 32:         def to_s
// 33:           name
// 34:         end
// 35:       end
// 36:
// 37:       sig { returns(T::Array[Entry]) }
// 38:       attr_reader :entries
// 39:
// 40:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 41:       attr_reader :cask_arguments
// 42:
// 43:       sig { returns(String) }
// 44:       attr_reader :input
// 45:
// 46:       sig { params(path: T.any(Pathname, StringIO)).void }
// 47:       def initialize(path)
// 48:         @path = path
// 49:         path_read = path.read
// 50:         raise "path_read is nil" unless path_read
// 51:
// 52:         @input = T.let(path_read, String)
// 53:         @entries = T.let([], T::Array[Entry])
// 54:         @cask_arguments = T.let({}, T::Hash[Symbol, T.untyped])
// 55:
// 56:         begin
// 57:           process
// 58:         # Want to catch all exceptions for e.g. syntax errors.
// 59:         rescue Exception => e # rubocop:disable Lint/RescueException
// 60:           error_msg = "Invalid Brewfile: #{e.message}"
// 61:           raise RuntimeError, error_msg, e.backtrace
// 62:         end
// 63:       end
// 64:
// 65:       sig { void }
// 66:       def process
// 67:         instance_eval(@input, @path.to_s)
// 68:       end
// 69:
// 70:       sig { params(args: T::Hash[Symbol, T.untyped]).void }
// 71:       def cask_args(args)
// 72:         @cask_arguments.merge!(args)
// 73:       end
// 74:
// 75:       sig { params(name: String, options: Homebrew::Bundle::EntryOptions).void }
// 76:       def brew(name, options = {})
// 77:         validate_type!(options, Hash, "brew options")
// 78:
// 79:         name = Homebrew::Bundle::Dsl.sanitize_brew_name(name)
// 80:         @entries << Entry.new(:brew, name, options)
// 81:       end
// 82:
// 83:       sig { params(name: String, options: Homebrew::Bundle::EntryOptions).void }
// 84:       def cask(name, options = {})
// 85:         options[:full_name] = name
// 86:         name = Homebrew::Bundle::Dsl.sanitize_cask_name(name)
// 87:         options[:args] =
// 88:           @cask_arguments.merge T.cast(options.fetch(:args, {}), T::Hash[Symbol, NestedEntryOptionValue])
// 89:         @entries << Entry.new(:cask, name, options)
// 90:       end
// 91:
// 92:       sig {
// 93:         params(
// 94:           name:            String,
// 95:           clone_target:    T.nilable(String),
// 96:           options:         Homebrew::Bundle::EntryOptions,
// 97:           keyword_options: Homebrew::Bundle::EntryOption,
// 98:         ).void
// 99:       }
// 100:       def tap(name, clone_target = nil, options = {}, **keyword_options)
// 101:         validate_type!(clone_target, String, "tap clone target") if clone_target
// 102:
// 103:         options.merge!(keyword_options)
// 104:         options[:clone_target] = clone_target
// 105:         name = Homebrew::Bundle::Dsl.sanitize_tap_name(name)
// 106:         @entries << Entry.new(:tap, name, options)
// 107:       end
// 108:
// 109:       sig { params(value: Object, type: T.any(T.class_of(Hash), T.class_of(String)), description: String).void }
// 110:       def validate_type!(value, type, description)
// 111:         raise "#{description} must be a #{type}" unless value.is_a?(type)
// 112:       end
// 113:       private :validate_type!
// 114:
// 115:       HOMEBREW_TAP_ARGS_REGEX = %r{^([\w-]+)/(homebrew-)?([\w-]+)$}
// 116:       HOMEBREW_CORE_FORMULA_REGEX = %r{^homebrew/homebrew/([\w+-.@]+)$}i
// 117:       HOMEBREW_TAP_FORMULA_REGEX = %r{^([\w-]+)/([\w-]+)/([\w+-.@]+)$}
// 118:
// 119:       sig { params(name: String).returns(String) }
// 120:       def self.sanitize_brew_name(name)
// 121:         name = name.downcase
// 122:         if name =~ HOMEBREW_CORE_FORMULA_REGEX
// 123:           sanitized_name = Regexp.last_match(1)
// 124:           raise "sanitized_name is nil" unless sanitized_name
// 125:
// 126:           sanitized_name
// 127:         elsif name =~ HOMEBREW_TAP_FORMULA_REGEX
// 128:           user = Regexp.last_match(1)
// 129:           repo = Regexp.last_match(2)
// 130:           name = Regexp.last_match(3)
// 131:           raise "repo is nil" unless repo
// 132:
// 133:           "#{user}/#{repo.sub("homebrew-", "")}/#{name}"
// 134:         else
// 135:           name
// 136:         end
// 137:       end
// 138:
// 139:       sig { params(name: String).returns(String) }
// 140:       def self.sanitize_tap_name(name)
// 141:         name = name.downcase
// 142:         if name =~ HOMEBREW_TAP_ARGS_REGEX
// 143:           "#{Regexp.last_match(1)}/#{Regexp.last_match(3)}"
// 144:         else
// 145:           name
// 146:         end
// 147:       end
// 148:
// 149:       sig { params(name: String).returns(String) }
// 150:       def self.sanitize_cask_name(name)
// 151:         require "utils"
// 152:         Utils.name_from_full_name(name).downcase
// 153:       end
// 154:
// 155:       sig {
// 156:         override.params(method_name: Symbol, args: T.untyped, options: T.untyped,
// 157:                         block: T.nilable(T.proc.void)).returns(T.untyped)
// 158:       }
// 159:       def method_missing(method_name, *args, **options, &block)
// 160:         require "bundle/extensions"
// 161:         extension = Homebrew::Bundle.extension(method_name)
// 162:         return super if extension.nil?
// 163:         raise ArgumentError, "blocks are not supported for #{method_name}" if block
// 164:
// 165:         # Extension DSL entries follow the existing Brewfile calling convention:
// 166:         # a required name plus an optional options hash, passed positionally,
// 167:         # with keywords, or both.
// 168:         unless (1..2).cover?(args.length)
// 169:           raise ArgumentError,
// 170:                 "wrong number of arguments (given #{args.length}, expected 1..2)"
// 171:         end
// 172:
// 173:         positional_options = {}
// 174:         if args.length == 2
// 175:           positional_options = args[1]
// 176:           unless positional_options.is_a? Hash
// 177:             raise ArgumentError,
// 178:                   "options(#{positional_options.inspect}) should be a Hash object"
// 179:           end
// 180:         end
// 181:
// 182:         @entries << extension.entry(args.first, positional_options.merge(options))
// 183:       end
// 184:
// 185:       sig { override.params(method_name: T.any(String, Symbol), include_private: T::Boolean).returns(T::Boolean) }
// 186:       def respond_to_missing?(method_name, include_private = false)
// 187:         require "bundle/extensions"
// 188:         !Homebrew::Bundle.extension(method_name).nil? || super
// 189:       end
// 190:     end
// 191:   end
// 192: end
