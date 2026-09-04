module homebrew

import ruby
import homebrew.cli as brew_cli
import os

// Translated from Homebrew/brew `commands.rb`.
// The original source is retained below until every stub has a typed V body.
const internal_command_aliases = {
	'ls':           'list'
	'homepage':     'home'
	'-S':           'search'
	'up':           'update'
	'ln':           'link'
	'instal':       'install'
	'uninstal':     'uninstall'
	'post_install': 'postinstall'
	'rm':           'uninstall'
	'remove':       'uninstall'
	'abv':          'info'
	'dr':           'doctor'
	'--repo':       '--repository'
	'environment':  '--env'
	'--config':     'config'
	'-v':           '--version'
	'lc':           'livecheck'
	'tc':           'typecheck'
	'x':            'exec'
}

const command_completion_exclusions = ['instal', 'uninstal', 'update-report']

pub struct CommandOption {
pub:
	option      string
	description string
	hidden      bool
	deprecated  bool
	subcommands []string
}

pub struct CommandSubcommand {
pub:
	name        string
	aliases     []string
	description string
	hidden      bool
}

pub struct CommandMetadata {
pub mut:
	description  string
	options      []CommandOption
	subcommands  []CommandSubcommand
	named_args   []string
	conflicts    [][]string
	ruby_command bool
	hidden       bool
}

pub type CommandTrustChecker = fn (path string, command string) !

fn permit_command(_ string, _ string) ! {}

fn nil_value() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn sorted_distinct(values []string) []string {
	mut result := []string{}
	mut seen := map[string]bool{}
	for value in values {
		if value != '' && !seen[value] {
			seen[value] = true
			result << value
		}
	}
	result.sort()
	return result
}

fn string_list_value(values []string) ruby.Value {
	return ruby.string_array_value(values)
}

fn option_list_value(options []CommandOption) ruby.Value {
	return ruby.array_value(options.map(ruby.array_value([
		ruby.string_value(it.option),
		ruby.string_value(it.description),
	])))
}

fn path_is_within(path string, directory string) bool {
	if path == '' || directory == '' {
		return false
	}
	real_path := os.real_path(path)
	real_directory := os.real_path(directory).trim_string_right(os.path_separator)
	return real_path == real_directory || real_path.starts_with('${real_directory}${os.path_separator}')
}

pub fn canonical_command(command string) string {
	return internal_command_aliases[command] or { command }
}

pub fn internal_commands_aliases() []string {
	mut aliases := internal_command_aliases.keys()
	aliases.sort()
	return aliases
}

pub fn method_name(command string) string {
	return command.replace('-', '_').to_lower()
}

pub fn basename_without_extension(path string) string {
	base := path.all_after_last('/')
	if base.contains('.') {
		return base.all_before_last('.')
	}
	return base
}

pub fn args_method_name(command_path string) string {
	return '${method_name(basename_without_extension(command_path))}_args'
}

pub fn command_path() string {
	return '${@DIR}/cmd'
}

pub fn developer_command_path() string {
	return '${@DIR}/dev-cmd'
}

pub fn internal_cmd_path_in(path string, command string) ?string {
	for extension in ['.v', '.sh'] {
		candidate := ruby.join_path(path, '${command}${extension}')
		if ruby.is_file(candidate) {
			return candidate
		}
	}
	return none
}

pub fn internal_cmd_path(command string) ?string {
	return internal_cmd_path_in(command_path(), command)
}

pub fn internal_dev_cmd_path(command string) ?string {
	return internal_cmd_path_in(developer_command_path(), command)
}

pub fn valid_internal_cmd(command string) bool {
	internal_cmd_path(command) or { return false }
	return true
}

pub fn valid_internal_dev_cmd(command string) bool {
	internal_dev_cmd_path(command) or { return false }
	return true
}

pub fn valid_ruby_cmd(command string) bool {
	path := command_file_path(command) or { return false }
	return path.ends_with('.rb') || path.ends_with('.v')
}

pub fn find_commands(path string) []string {
	mut found := []string{}
	entries := ruby.list_dir(path) or { return found }
	for entry in entries {
		candidate := ruby.join_path(path, entry)
		if ruby.is_file(candidate) {
			found << candidate
		}
	}
	found.sort()
	return found
}

pub fn find_internal_commands(path string) ![]string {
	return find_internal_commands_in(path, [command_path(), developer_command_path()])
}

pub fn find_internal_commands_in(path string, official_paths []string) ![]string {
	real_path := ruby.real_path(path)
	if !official_paths.any(ruby.real_path(it) == real_path) {
		return error('${path} is not an official command path')
	}
	mut names := []string{}
	mut seen := map[string]bool{}
	for candidate in find_commands(path) {
		name := basename_without_extension(candidate)
		metadata := command_metadata_from_path(candidate) or { CommandMetadata{} }
		if !seen[name] && !metadata.hidden {
			seen[name] = true
			names << name
		}
	}
	names.sort()
	return names
}

pub fn internal_commands() []string {
	return find_internal_commands(command_path()) or { [] }
}

pub fn internal_developer_commands() []string {
	return find_internal_commands(developer_command_path()) or { [] }
}

pub fn tap_cmd_directories_in(tap_directory string) []string {
	mut directories := []string{}
	if !os.is_dir(tap_directory) {
		return directories
	}
	users := os.ls(tap_directory) or { return directories }
	for user in users {
		user_path := os.join_path(tap_directory, user)
		if !os.is_dir(user_path) {
			continue
		}
		repositories := os.ls(user_path) or { continue }
		for repository in repositories {
			candidate := os.join_path(user_path, repository, 'cmd')
			if os.is_dir(candidate) {
				directories << candidate
			}
		}
	}
	directories.sort()
	return directories
}

pub fn tap_cmd_directories() []string {
	mut directory := ruby.environment_value('HOMEBREW_TAP_DIRECTORY')
	if directory == '' {
		repository := ruby.environment_value('HOMEBREW_REPOSITORY')
		if repository != '' {
			directory = os.join_path(repository, 'Library', 'Taps')
		}
	}
	return tap_cmd_directories_in(directory)
}

fn command_search_directories(path_value string, extra []string) []string {
	mut directories := path_value.split(os.path_delimiter)
	directories << extra
	return sorted_distinct(directories)
}

pub fn find_executable_in_directories(name string, directories []string) ?string {
	for directory in directories {
		candidate := os.join_path(if directory == '' { os.getwd() } else { directory }, name)
		if os.is_file(candidate) && os.is_executable(candidate) {
			return candidate
		}
	}
	return none
}

pub fn require_trusted_command_with(path string, command string, tap_directory string,
	checker CommandTrustChecker) ! {
	if path != '' && path_is_within(path, tap_directory) {
		checker(path, command)!
	}
}

pub fn external_ruby_v2_cmd_path_in(command string, directories []string, tap_directory string,
	checker CommandTrustChecker) !string {
	path := find_executable_in_directories('${command}.rb', directories) or { return '' }
	require_trusted_command_with(path, command, tap_directory, checker)!
	return path
}

pub fn external_ruby_cmd_path_in(command string, path_value string, tap_directories []string,
	tap_directory string, checker CommandTrustChecker) !string {
	path := find_executable_in_directories('brew-${command}.rb', command_search_directories(path_value, tap_directories)) or { return '' }
	require_trusted_command_with(path, command, tap_directory, checker)!
	return path
}

pub fn external_cmd_path_in(command string, path_value string, tap_directories []string,
	tap_directory string, checker CommandTrustChecker) !string {
	path := find_executable_in_directories('brew-${command}', command_search_directories(path_value, tap_directories)) or { return '' }
	require_trusted_command_with(path, command, tap_directory, checker)!
	return path
}

pub fn external_cmd_path(command string) ?string {
	directories := tap_cmd_directories()
	tap_directory := ruby.environment_value('HOMEBREW_TAP_DIRECTORY')
	if ruby_path := external_ruby_cmd_path_in(command, ruby.environment_value('PATH'), directories, tap_directory, permit_command) {
		if ruby_path != '' {
			return ruby_path
		}
	}
	if path := external_cmd_path_in(command, ruby.environment_value('PATH'), directories, tap_directory, permit_command) {
		if path != '' {
			return path
		}
	}
	return none
}

pub fn resolve_command_path(command string, internal_path string, developer_path string,
	tap_directories []string, path_value string, tap_directory string, checker CommandTrustChecker) !string {
	canonical := canonical_command(command)
	if path := internal_cmd_path_in(internal_path, canonical) {
		return path
	}
	if path := internal_cmd_path_in(developer_path, canonical) {
		return path
	}
	if path := external_ruby_v2_cmd_path_in(command, tap_directories, tap_directory, checker) {
		if path != '' {
			return path
		}
	}
	if path := external_ruby_cmd_path_in(command, path_value, tap_directories, tap_directory, checker) {
		if path != '' {
			return path
		}
	}
	return external_cmd_path_in(command, path_value, tap_directories, tap_directory, checker)
}

pub fn command_file_path(command string) ?string {
	path := resolve_command_path(command, command_path(), developer_command_path(), tap_cmd_directories(), ruby.environment_value('PATH'), ruby.environment_value('HOMEBREW_TAP_DIRECTORY'), permit_command) or { return none }
	return if path == '' { none } else { path }
}

pub fn external_commands_in(directories []string) []string {
	mut result := []string{}
	for directory in directories {
		for path in find_commands(directory) {
			if !os.is_executable(path) {
				continue
			}
			mut name := basename_without_extension(path)
			if name.starts_with('brew-') {
				name = name[5..].trim_space()
			}
			result << name
		}
	}
	return sorted_distinct(result)
}

pub fn external_commands() []string {
	return external_commands_in(tap_cmd_directories())
}

pub fn commands(include_external bool, include_aliases bool) []string {
	mut result := internal_commands()
	result << internal_developer_commands()
	if include_external {
		result << external_commands()
	}
	if include_aliases {
		result << internal_commands_aliases()
	}
	return sorted_distinct(result)
}

fn edit_distance(left string, right string) int {
	mut previous := []int{len: right.len + 1, init: index}
	for left_index, left_byte in left.bytes() {
		mut current := []int{len: right.len + 1}
		current[0] = left_index + 1
		for right_index, right_byte in right.bytes() {
			insert_cost := current[right_index] + 1
			delete_cost := previous[right_index + 1] + 1
			replace_cost := previous[right_index] + if left_byte == right_byte { 0 } else { 1 }
			current[right_index + 1] = int_min(insert_cost, int_min(delete_cost, replace_cost))
		}
		previous = current.clone()
	}
	return previous[right.len]
}

pub fn suggestion_message_from_commands(command string, internal_candidates []string,
	all_candidates []string) string {
	mut suggestions := []string{}
	for candidate in internal_candidates {
		distance := edit_distance(command, candidate)
		threshold := int_max(1, int_min(3, command.len / 3))
		if distance <= threshold {
			suggestions << candidate
		}
	}
	if suggestions.len == 0 {
		for candidate in all_candidates {
			distance := edit_distance(command, candidate)
			threshold := int_max(1, int_min(3, command.len / 3))
			if distance <= threshold {
				suggestions << candidate
			}
		}
	}
	if suggestions.len == 0 {
		return ''
	}
	suggestions = sorted_distinct(suggestions)
	suggestions.sort_with_compare(fn (a &string, b &string) int {
		return a.len - b.len
	})
	if suggestions.len == 1 {
		return '\nDid you mean ${suggestions[0]}?'
	}
	return '\nDid you mean ${suggestions[..suggestions.len - 1].join(', ')} or ${suggestions.last()}?'
}

pub fn suggestion_message(command string) string {
	return suggestion_message_from_commands(command, commands(false, true), commands(true, true))
}

fn translated_source_line(line string) string {
	mut value := line.trim_space()
	if value.starts_with('//') {
		value = value[2..].trim_space()
		colon := value.index(':') or { return value }
		prefix := value[..colon]
		if prefix != '' && prefix.bytes().all(it >= `0` && it <= `9`) {
			value = value[colon + 1..].trim_space()
		}
	}
	return value
}

fn first_quoted_after(line string, start int) string {
	if start < 0 || start >= line.len {
		return ''
	}
	remaining := line[start..]
	mut best := -1
	mut quote := u8(0)
	for candidate in [`"`, `'`] {
		index := remaining.index_u8(candidate)
		if index >= 0 && (best == -1 || index < best) {
			best = index
			quote = candidate
		}
	}
	if best == -1 {
		return ''
	}
	tail := remaining[best + 1..]
	end := tail.index_u8(quote)
	if end < 0 {
		return ''
	}
	return tail[..end]
}

fn quoted_values(line string) []string {
	mut values := []string{}
	mut index := 0
	for index < line.len {
		mut found := -1
		mut quote := u8(0)
		for candidate in [`"`, `'`] {
			relative := line[index..].index_u8(candidate)
			if relative >= 0 {
				absolute := index + relative
				if found == -1 || absolute < found {
					found = absolute
					quote = candidate
				}
			}
		}
		if found == -1 {
			break
		}
		end_relative := line[found + 1..].index_u8(quote)
		if end_relative < 0 {
			break
		}
		end := found + 1 + end_relative
		values << line[found + 1..end]
		index = end + 1
	}
	return values
}

fn symbol_values(line string) []string {
	mut values := []string{}
	for piece in line.split(':')[1..] {
		mut value := piece.all_before(',').all_before(')').trim_space().trim('[]{}')
		if value.contains(' ') {
			value = value.all_before(' ')
		}
		if value != '' && value.bytes().all(it.is_alnum() || it == `_`) {
			values << value
		}
	}
	return values
}

fn shell_option(line string) ?CommandOption {
	content := line.trim_string_left('#:').trim_space()
	mut option_start := -1
	for index, byte in content.bytes() {
		if byte == `-` && (index == 0 || content[index - 1].is_space()) {
			option_start = index
		}
	}
	if option_start == -1 {
		return none
	}
	rest := content[option_start..]
	mut pieces := rest.fields()
	if pieces.len < 2 {
		return none
	}
	mut option := pieces[0].trim_string_right(',')
	mut description_start := option.len
	if pieces.len > 2 && pieces[1].starts_with('-') {
		option = pieces[1].trim_string_right(',')
		description_start = rest.index(pieces[1]) or { 0 } + pieces[1].len
	}
	return CommandOption{
		option: option
		description: rest[description_start..].trim_space()
	}
}

fn command_option_description(source_lines []string, option_index int) string {
	mut description := ''
	mut started := false
	for offset in 0 .. 5 {
		index := option_index + offset
		if index >= source_lines.len {
			break
		}
		line := translated_source_line(source_lines[index])
		description_position := line.index('description:') or { -1 }
		if !started {
			if description_position < 0 {
				if offset == 0 {
					continue
				}
				if line.starts_with('switch ') || line.starts_with('flag ') || line.starts_with('comma_array ') || line.starts_with('[:switch,') || line.starts_with('[:flag,') || line.starts_with('[:comma_array,') {
					break
				}
				continue
			}
			started = true
		}
		part := first_quoted_after(line, if description_position < 0 {
			0
		} else {
			description_position
		})
		if part != '' {
			description += part
		}
		if started && !line.trim_space().ends_with('\\') {
			break
		}
	}
	return description
}

fn command_option_deprecated(source_lines []string, option_index int) bool {
	for offset in 0 .. 8 {
		index := option_index + offset
		if index >= source_lines.len {
			break
		}
		line := translated_source_line(source_lines[index])
		if offset > 0 && (line.starts_with('switch ') || line.starts_with('flag ') || line.starts_with('comma_array ') || line.starts_with('[:switch,') || line.starts_with('[:flag,') || line.starts_with('[:comma_array,') || line.starts_with('named_args ')) {
			break
		}
		if line.contains('odeprecated: true') {
			return true
		}
	}
	return false
}

pub fn command_metadata_from_text(contents string) CommandMetadata {
	mut metadata := CommandMetadata{}
	mut shell_lines := []string{}
	source_lines := contents.split_into_lines()
	for index, raw_line in source_lines {
		line := translated_source_line(raw_line)
		if line.contains('hide_from_man_page') && (line.contains('true') || line.contains('!')) {
			metadata.hidden = true
		}
		if line.starts_with('#:') {
			shell_lines << line
			continue
		}
		if line.starts_with('description <<~') && index + 1 < source_lines.len {
			candidate := translated_source_line(source_lines[index + 1]).trim_space()
			if candidate != '' {
				metadata.description = candidate
			}
		} else if line.starts_with('desc ') || line.starts_with('description ') {
			description := first_quoted_after(line, 0)
			if description != '' {
				metadata.description = description
			}
		}
		if line.starts_with('switch ') || line.starts_with('flag ') || line.starts_with('comma_array ') || line.starts_with('[:switch,') || line.starts_with('[:flag,') || line.starts_with('[:comma_array,') {
			values := quoted_values(line)
			dashed := values.filter(it.starts_with('-'))
			mut option := if dashed.len == 0 { '' } else { dashed[0] }
			for value in dashed {
				if value.starts_with('--') {
					option = value
					break
				}
			}
			option = option.trim_string_right('=')
			if option != '' {
				metadata.options << CommandOption{
					option: option
					description: command_option_description(source_lines, index)
					hidden: line.contains('hidden: true')
					deprecated: command_option_deprecated(source_lines, index)
				}
			}
		}
		if line.starts_with('subcommand ') {
			values := quoted_values(line)
			if values.len > 0 {
				description_position := line.index('description:') or { -1 }
				metadata.subcommands << CommandSubcommand{
					name: values[0]
					description: first_quoted_after(line, description_position)
					hidden: line.contains('hidden: true')
				}
			}
		}
		if line.starts_with('named_args ') && !line.starts_with('named_args =') {
			metadata.named_args = symbol_values(line)
			if metadata.named_args.len == 0 {
				metadata.named_args = quoted_values(line)
			}
		}
		if line.starts_with('conflicts ') {
			mut conflict := quoted_values(line).map(it.trim_left('-').replace('_', '-'))
			conflict << symbol_values(line).map(it.replace('_', '-'))
			if conflict.len > 1 {
				metadata.conflicts << sorted_distinct(conflict)
			}
		}
	}
	if shell_lines.len > 2 {
		for line in shell_lines[2..] {
			if option := shell_option(line) {
				metadata.options << option
			} else if metadata.description == '' {
				candidate := line.trim_string_left('#:').trim_space()
				if candidate != '' && candidate[0].is_letter() {
					metadata.description = candidate
				}
			}
		}
	}
	metadata.ruby_command = shell_lines.len == 0
		&& (contents.contains('AbstractCommand') || contents.contains('_args')
			|| metadata.options.len > 0 || metadata.description != '')
	return metadata
}

pub fn command_metadata_from_path(path string) !CommandMetadata {
	return command_metadata_from_text(os.read_file(path)!)
}

pub fn command_options_for_path(path string, subcommand string) ![]CommandOption {
	metadata := command_metadata_from_path(path)!
	if basename_without_extension(path) == 'help' {
		return []
	}
	mut by_name := map[string]CommandOption{}
	if metadata.ruby_command {
		for option in brew_cli.global_options() {
			name := if option.long != '' { option.long } else { option.short }
			if name != '' {
				by_name[name] = CommandOption{
					option: name
					description: option.description
				}
			}
		}
	}
	for option in metadata.options {
		if option.hidden || option.deprecated {
			continue
		}
		if subcommand == '' && option.subcommands.len > 0 {
			continue
		}
		if subcommand != '' && option.subcommands.len > 0 && subcommand !in option.subcommands {
			continue
		}
		by_name[option.option] = option
	}
	return by_name.values()
}

pub fn command_description_for_path(path string, short bool) !string {
	description := command_metadata_from_path(path)!.description
	if !short {
		return description
	}
	for index, byte in description.bytes() {
		if byte == `.` && (index == description.len - 1 || description[index + 1].is_space()) {
			return description[..index]
		}
	}
	return description
}

pub fn command_subcommands_for_path(path string) ![]CommandSubcommand {
	return command_metadata_from_path(path)!.subcommands.filter(!it.hidden)
}

pub fn named_args_type_for_path(path string, _ string) ![]string {
	return command_metadata_from_path(path)!.named_args
}

pub fn option_conflicts_for_path(path string, option string) ![]string {
	metadata := command_metadata_from_path(path)!
	mut normalized := option.trim_left('-').replace('_', '-')
	mut hidden := metadata.options.filter(it.hidden).map(it.option.trim_left('-').replace('_', '-'))
	mut result := []string{}
	for group in metadata.conflicts {
		if normalized in group {
			for candidate in group {
				if candidate != normalized && candidate !in hidden {
					result << candidate
				}
			}
		}
	}
	return sorted_distinct(result)
}

pub fn rebuild_internal_commands_completion_list_at(repository string, internal_path string,
	developer_path string) ![]string {
	mut result := find_internal_commands_in(internal_path, [internal_path, developer_path])!
	result << find_internal_commands_in(developer_path, [internal_path, developer_path])!
	result = sorted_distinct(result).filter(it !in command_completion_exclusions)
	destination := os.join_path(repository, 'completions', 'internal_commands_list.txt')
	os.mkdir_all(os.dir(destination))!
	ruby.atomic_write_file(destination, '${result.join('\n')}\n')!
	return result
}

pub fn rebuild_commands_completion_list_at(cache string, internal []string, developer []string,
	external []string) ![]string {
	mut all := internal.clone()
	all << developer
	all << external
	all = sorted_distinct(all).filter(it !in command_completion_exclusions)
	external_commands_sorted := sorted_distinct(external)
	os.mkdir_all(cache)!
	ruby.atomic_write_file(os.join_path(cache, 'all_commands_list.txt'), '${all.join('\n')}\n')!
	ruby.atomic_write_file(os.join_path(cache, 'external_commands_list.txt'), '${external_commands_sorted.join('\n')}\n')!
	return all
}

// Ruby method `self.valid_internal_cmd?(cmd)` at line 42.
pub fn ruby_commands_l42_d1_self_valid_internal_cmd(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(valid_internal_cmd(args[0].as_string()))
}

// Ruby method `self.valid_internal_dev_cmd?(cmd)` at line 47.
pub fn ruby_commands_l47_d2_self_valid_internal_dev_cmd(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(valid_internal_dev_cmd(args[0].as_string()))
}

// Ruby method `self.valid_ruby_cmd?(cmd)` at line 52.
pub fn ruby_commands_l52_d3_self_valid_ruby_cmd(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && valid_ruby_cmd(args[0].as_string()))
}

// Ruby method `self.method_name(cmd)` at line 58.
pub fn ruby_commands_l58_d4_self_method_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(method_name(args[0].as_string()))
}

// Ruby method `self.args_method_name(cmd_path)` at line 66.
pub fn ruby_commands_l66_d5_self_args_method_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(args_method_name(args[0].as_string()))
}

// Ruby method `self.internal_cmd_path(cmd)` at line 73.
pub fn ruby_commands_l73_d6_self_internal_cmd_path(args ...ruby.Value) ruby.Value {
	path := internal_cmd_path(args[0].as_string()) or {
		return ruby.object_value('NilClass', '')
	}
	return ruby.string_value(path)
}

// Ruby method `self.internal_dev_cmd_path(cmd)` at line 81.
pub fn ruby_commands_l81_d7_self_internal_dev_cmd_path(args ...ruby.Value) ruby.Value {
	path := internal_dev_cmd_path(args[0].as_string()) or {
		return ruby.object_value('NilClass', '')
	}
	return ruby.string_value(path)
}

// Ruby method `self.external_ruby_v2_cmd_path(cmd)` at line 90.
pub fn ruby_commands_l90_d8_self_external_ruby_v2_cmd_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return nil_value()
	}
	path := external_ruby_v2_cmd_path_in(args[0].as_string(), tap_cmd_directories(), ruby.environment_value('HOMEBREW_TAP_DIRECTORY'), permit_command) or { return nil_value() }
	return if path == '' { nil_value() } else { ruby.string_value(path) }
}

// Ruby method `self.external_ruby_cmd_path(cmd)` at line 98.
pub fn ruby_commands_l98_d9_self_external_ruby_cmd_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return nil_value()
	}
	path := external_ruby_cmd_path_in(args[0].as_string(), ruby.environment_value('PATH'), tap_cmd_directories(), ruby.environment_value('HOMEBREW_TAP_DIRECTORY'), permit_command) or { return nil_value() }
	return if path == '' { nil_value() } else { ruby.string_value(path) }
}

// Ruby method `self.external_cmd_path(cmd)` at line 105.
pub fn ruby_commands_l105_d10_self_external_cmd_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return nil_value()
	}
	path := external_cmd_path(args[0].as_string()) or { return nil_value() }
	return ruby.string_value(path)
}

// Ruby method `self.require_trusted_command!(path, cmd)` at line 112.
pub fn ruby_commands_l112_d11_self_require_trusted_command(args ...ruby.Value) ruby.Value {
	if args.len > 1 {
		require_trusted_command_with(args[0].as_string(), args[1].as_string(), ruby.environment_value('HOMEBREW_TAP_DIRECTORY'), permit_command) or {
			return ruby.bool_value(false)
		}
	}
	return nil_value()
}

// Ruby method `self.path(cmd)` at line 121.
pub fn ruby_commands_l121_d12_self_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return nil_value()
	}
	path := command_file_path(args[0].as_string()) or { return nil_value() }
	return ruby.string_value(path)
}

// Ruby method `self.commands(external: true, aliases: false)` at line 132.
pub fn ruby_commands_l132_d13_self_commands(args ...ruby.Value) ruby.Value {
	include_external := if args.len > 0 { args[0].as_bool() or { true } } else { true }
	include_aliases := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	return string_list_value(commands(include_external, include_aliases))
}

// Ruby method `self.suggestion_message(cmd)` at line 141.
pub fn ruby_commands_l141_d14_self_suggestion_message(args ...ruby.Value) ruby.Value {
	return ruby.string_value(suggestion_message(args[0].as_string()))
}

// Ruby method `self.tap_cmd_directories` at line 153.
pub fn ruby_commands_l153_d15_self_tap_cmd_directories(args ...ruby.Value) ruby.Value {
	return string_list_value(tap_cmd_directories())
}

// Ruby method `self.internal_commands_paths` at line 158.
pub fn ruby_commands_l158_d16_self_internal_commands_paths(args ...ruby.Value) ruby.Value {
	return string_list_value(find_commands(command_path()))
}

// Ruby method `self.internal_developer_commands_paths` at line 163.
pub fn ruby_commands_l163_d17_self_internal_developer_commands_paths(args ...ruby.Value) ruby.Value {
	return string_list_value(find_commands(developer_command_path()))
}

// Ruby method `self.internal_commands` at line 168.
pub fn ruby_commands_l168_d18_self_internal_commands(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Array[String]', internal_commands().join(','))
}

// Ruby method `self.internal_developer_commands` at line 173.
pub fn ruby_commands_l173_d19_self_internal_developer_commands(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Array[String]', internal_developer_commands().join(','))
}

// Ruby method `self.internal_commands_aliases` at line 178.
pub fn ruby_commands_l178_d20_self_internal_commands_aliases(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Array[String]', internal_commands_aliases().join(','))
}

// Ruby method `self.find_internal_commands(path)` at line 183.
pub fn ruby_commands_l183_d21_self_find_internal_commands(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return string_list_value([])
	}
	return string_list_value(find_internal_commands(args[0].as_string()) or { [] })
}

// Ruby method `self.external_commands` at line 194.
pub fn ruby_commands_l194_d22_self_external_commands(args ...ruby.Value) ruby.Value {
	return string_list_value(external_commands())
}

// Ruby method `self.basename_without_extension(path)` at line 209.
pub fn ruby_commands_l209_d23_self_basename_without_extension(args ...ruby.Value) ruby.Value {
	return ruby.string_value(basename_without_extension(args[0].as_string()))
}

// Ruby method `self.find_commands(path)` at line 214.
pub fn ruby_commands_l214_d24_self_find_commands(args ...ruby.Value) ruby.Value {
	return if args.len == 0 {
		string_list_value([])
	} else {
		string_list_value(find_commands(args[0].as_string()))
	}
}

// Ruby method `self.rebuild_internal_commands_completion_list` at line 221.
pub fn ruby_commands_l221_d25_self_rebuild_internal_commands_completion_list(args ...ruby.Value) ruby.Value {
	repository := ruby.environment_value('HOMEBREW_REPOSITORY')
	if repository == '' {
		return ruby.bool_value(false)
	}
	rebuild_internal_commands_completion_list_at(repository, command_path(), developer_command_path()) or {
		return ruby.bool_value(false)
	}
	return nil_value()
}

// Ruby method `self.rebuild_commands_completion_list` at line 235.
pub fn ruby_commands_l235_d26_self_rebuild_commands_completion_list(args ...ruby.Value) ruby.Value {
	cache := ruby.environment_value('HOMEBREW_CACHE')
	if cache == '' {
		return ruby.bool_value(false)
	}
	rebuild_commands_completion_list_at(cache, internal_commands(), internal_developer_commands(), external_commands()) or { return ruby.bool_value(false) }
	return nil_value()
}

// Ruby method `self.command_options(command, subcommand: nil)` at line 252.
pub fn ruby_commands_l252_d27_self_command_options(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].as_string() == 'help' {
		return nil_value()
	}
	path := command_file_path(args[0].as_string()) or { return nil_value() }
	subcommand := if args.len > 1 { args[1].as_string() } else { '' }
	return option_list_value(command_options_for_path(path, subcommand) or { return nil_value() })
}

// Ruby method `self.command_description(command, short: false)` at line 287.
pub fn ruby_commands_l287_d28_self_command_description(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return nil_value()
	}
	path := command_file_path(args[0].as_string()) or { return nil_value() }
	short := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	description := command_description_for_path(path, short) or { return nil_value() }
	return if description == '' { nil_value() } else { ruby.string_value(description) }
}

// Ruby method `self.command_subcommands(command)` at line 317.
pub fn ruby_commands_l317_d29_self_command_subcommands(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	path := command_file_path(args[0].as_string()) or { return ruby.array_value([]) }
	subcommands := command_subcommands_for_path(path) or { return ruby.array_value([]) }
	return ruby.array_value(subcommands.map(ruby.structured_value('Subcommand', it.name, {
		'name':        it.name
		'description': it.description
	})))
}

// Ruby method `self.named_args_type(command, subcommand: nil)` at line 331.
pub fn ruby_commands_l331_d30_self_named_args_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return nil_value()
	}
	path := command_file_path(args[0].as_string()) or { return nil_value() }
	subcommand := if args.len > 1 { args[1].as_string() } else { '' }
	return string_list_value(named_args_type_for_path(path, subcommand) or { return nil_value() })
}

// Ruby method `self.option_conflicts(command, option)` at line 348.
pub fn ruby_commands_l348_d31_self_option_conflicts(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return nil_value()
	}
	path := command_file_path(args[0].as_string()) or { return nil_value() }
	return string_list_value(option_conflicts_for_path(path, args[1].as_string()) or {
		return nil_value()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "homebrew"
// 5: require "cli/parser"
// 6: require "extend/ENV/sensitive"
// 7:
// 8: # Helper functions for commands.
// 9: module Commands
// 10:   HOMEBREW_CMD_PATH = T.let((HOMEBREW_LIBRARY_PATH/"cmd").freeze, Pathname)
// 11:   HOMEBREW_DEV_CMD_PATH = T.let((HOMEBREW_LIBRARY_PATH/"dev-cmd").freeze, Pathname)
// 12:   # If you are going to change anything in below hash,
// 13:   # be sure to also update appropriate case statement in brew.sh
// 14:   HOMEBREW_INTERNAL_COMMAND_ALIASES = T.let({
// 15:     "ls"           => "list",
// 16:     "homepage"     => "home",
// 17:     "-S"           => "search",
// 18:     "up"           => "update",
// 19:     "ln"           => "link",
// 20:     "instal"       => "install", # gem does the same
// 21:     "uninstal"     => "uninstall",
// 22:     "post_install" => "postinstall",
// 23:     "rm"           => "uninstall",
// 24:     "remove"       => "uninstall",
// 25:     "abv"          => "info",
// 26:     "dr"           => "doctor",
// 27:     "--repo"       => "--repository",
// 28:     "environment"  => "--env",
// 29:     "--config"     => "config",
// 30:     "-v"           => "--version",
// 31:     "lc"           => "livecheck",
// 32:     "tc"           => "typecheck",
// 33:     "x"            => "exec",
// 34:   }.freeze, T::Hash[String, String])
// 35:   # This pattern is used to split descriptions at full stops. We only consider a
// 36:   # dot as a full stop if it is either followed by a whitespace or at the end of
// 37:   # the description. In this way we can prevent cutting off a sentence in the
// 38:   # middle due to dots in URLs or paths.
// 39:   DESCRIPTION_SPLITTING_PATTERN = /\.(?>\s|$)/
// 40:
// 41:   sig { params(cmd: String).returns(T::Boolean) }
// 42:   def self.valid_internal_cmd?(cmd)
// 43:     Homebrew.require?(HOMEBREW_CMD_PATH/cmd)
// 44:   end
// 45:
// 46:   sig { params(cmd: String).returns(T::Boolean) }
// 47:   def self.valid_internal_dev_cmd?(cmd)
// 48:     Homebrew.require?(HOMEBREW_DEV_CMD_PATH/cmd)
// 49:   end
// 50:
// 51:   sig { params(cmd: String).returns(T::Boolean) }
// 52:   def self.valid_ruby_cmd?(cmd)
// 53:     (valid_internal_cmd?(cmd) || valid_internal_dev_cmd?(cmd) || external_ruby_v2_cmd_path(cmd).present?) &&
// 54:       (Homebrew::AbstractCommand.command(cmd)&.ruby_cmd? == true)
// 55:   end
// 56:
// 57:   sig { params(cmd: String).returns(Symbol) }
// 58:   def self.method_name(cmd)
// 59:     cmd.to_s
// 60:        .tr("-", "_")
// 61:        .downcase
// 62:        .to_sym
// 63:   end
// 64:
// 65:   sig { params(cmd_path: Pathname).returns(Symbol) }
// 66:   def self.args_method_name(cmd_path)
// 67:     cmd_path_basename = basename_without_extension(cmd_path)
// 68:     cmd_method_prefix = method_name(cmd_path_basename)
// 69:     :"#{cmd_method_prefix}_args"
// 70:   end
// 71:
// 72:   sig { params(cmd: String).returns(T.nilable(Pathname)) }
// 73:   def self.internal_cmd_path(cmd)
// 74:     [
// 75:       HOMEBREW_CMD_PATH/"#{cmd}.rb",
// 76:       HOMEBREW_CMD_PATH/"#{cmd}.sh",
// 77:     ].find(&:exist?)
// 78:   end
// 79:
// 80:   sig { params(cmd: String).returns(T.nilable(Pathname)) }
// 81:   def self.internal_dev_cmd_path(cmd)
// 82:     [
// 83:       HOMEBREW_DEV_CMD_PATH/"#{cmd}.rb",
// 84:       HOMEBREW_DEV_CMD_PATH/"#{cmd}.sh",
// 85:     ].find(&:exist?)
// 86:   end
// 87:
// 88:   # Ruby commands which can be `require`d without being run.
// 89:   sig { params(cmd: String).returns(T.nilable(Pathname)) }
// 90:   def self.external_ruby_v2_cmd_path(cmd)
// 91:     path = which("#{cmd}.rb", tap_cmd_directories)
// 92:     require_trusted_command!(path, cmd)
// 93:     path if ENV.clear_sensitive_environment! { Homebrew.require?(path) }
// 94:   end
// 95:
// 96:   # Ruby commands which are run by being `require`d.
// 97:   sig { params(cmd: String).returns(T.nilable(Pathname)) }
// 98:   def self.external_ruby_cmd_path(cmd)
// 99:     path = which("brew-#{cmd}.rb", PATH.new(ENV.fetch("PATH")).append(tap_cmd_directories))
// 100:     require_trusted_command!(path, cmd)
// 101:     path
// 102:   end
// 103:
// 104:   sig { params(cmd: String).returns(T.nilable(Pathname)) }
// 105:   def self.external_cmd_path(cmd)
// 106:     path = which("brew-#{cmd}", PATH.new(ENV.fetch("PATH")).append(tap_cmd_directories))
// 107:     require_trusted_command!(path, cmd)
// 108:     path
// 109:   end
// 110:
// 111:   sig { params(path: T.nilable(Pathname), cmd: String).void }
// 112:   def self.require_trusted_command!(path, cmd)
// 113:     return unless path
// 114:     return if path.expand_path.ascend.none?(HOMEBREW_TAP_DIRECTORY)
// 115:
// 116:     require "trust"
// 117:     Homebrew::Trust.require_trusted_command!(path, cmd)
// 118:   end
// 119:
// 120:   sig { params(cmd: String).returns(T.nilable(Pathname)) }
// 121:   def self.path(cmd)
// 122:     internal_cmd = HOMEBREW_INTERNAL_COMMAND_ALIASES.fetch(cmd, cmd)
// 123:     path ||= internal_cmd_path(internal_cmd)
// 124:     path ||= internal_dev_cmd_path(internal_cmd)
// 125:     path ||= external_ruby_v2_cmd_path(cmd)
// 126:     path ||= external_ruby_cmd_path(cmd)
// 127:     path ||= external_cmd_path(cmd)
// 128:     path
// 129:   end
// 130:
// 131:   sig { params(external: T::Boolean, aliases: T::Boolean).returns(T::Array[String]) }
// 132:   def self.commands(external: true, aliases: false)
// 133:     cmds = internal_commands
// 134:     cmds += internal_developer_commands
// 135:     cmds += external_commands if external
// 136:     cmds += internal_commands_aliases if aliases
// 137:     cmds.sort
// 138:   end
// 139:
// 140:   sig { params(cmd: String).returns(String) }
// 141:   def self.suggestion_message(cmd)
// 142:     require "did_you_mean"
// 143:
// 144:     suggestions = DidYouMean::SpellChecker.new(dictionary: commands(external: false, aliases: true)).correct(cmd)
// 145:     suggestions = DidYouMean::SpellChecker.new(dictionary: commands(aliases: true)).correct(cmd) if suggestions.empty?
// 146:     return "" if suggestions.empty?
// 147:
// 148:     "\nDid you mean #{suggestions.to_sentence(two_words_connector: " or ", last_word_connector: " or ")}?"
// 149:   end
// 150:
// 151:   # An array of all tap cmd directory {Pathname}s.
// 152:   sig { returns(T::Array[Pathname]) }
// 153:   def self.tap_cmd_directories
// 154:     Pathname.glob HOMEBREW_TAP_DIRECTORY/"*/*/cmd"
// 155:   end
// 156:
// 157:   sig { returns(T::Array[Pathname]) }
// 158:   def self.internal_commands_paths
// 159:     find_commands HOMEBREW_CMD_PATH
// 160:   end
// 161:
// 162:   sig { returns(T::Array[Pathname]) }
// 163:   def self.internal_developer_commands_paths
// 164:     find_commands HOMEBREW_DEV_CMD_PATH
// 165:   end
// 166:
// 167:   sig { returns(T::Array[String]) }
// 168:   def self.internal_commands
// 169:     find_internal_commands(HOMEBREW_CMD_PATH).map(&:to_s)
// 170:   end
// 171:
// 172:   sig { returns(T::Array[String]) }
// 173:   def self.internal_developer_commands
// 174:     find_internal_commands(HOMEBREW_DEV_CMD_PATH).map(&:to_s)
// 175:   end
// 176:
// 177:   sig { returns(T::Array[String]) }
// 178:   def self.internal_commands_aliases
// 179:     HOMEBREW_INTERNAL_COMMAND_ALIASES.keys
// 180:   end
// 181:
// 182:   sig { params(path: Pathname).returns(T::Array[String]) }
// 183:   def self.find_internal_commands(path)
// 184:     raise ArgumentError, "#{path} is not an official command path" \
// 185:       unless [HOMEBREW_CMD_PATH, HOMEBREW_DEV_CMD_PATH].include?(path)
// 186:
// 187:     find_commands(path).map(&:basename)
// 188:                        .map { |basename| basename_without_extension(basename) }
// 189:                        .uniq
// 190:                        .reject { |name| Homebrew::CLI::Parser.from_cmd_path(path/"#{name}.rb")&.hide_from_man_page }
// 191:   end
// 192:
// 193:   sig { returns(T::Array[String]) }
// 194:   def self.external_commands
// 195:     tap_cmd_directories.flat_map do |path|
// 196:       commands = find_commands(path).select(&:executable?)
// 197:       if path.expand_path.ascend.any?(HOMEBREW_TAP_DIRECTORY)
// 198:         require "trust"
// 199:         commands = Homebrew::Trust.trusted_command_files(commands)
// 200:       end
// 201:       commands
// 202:         .map { |basename| basename_without_extension(basename) }
// 203:         .map { |p| p.to_s.delete_prefix("brew-").strip }
// 204:     end.map(&:to_s)
// 205:        .sort
// 206:   end
// 207:
// 208:   sig { params(path: Pathname).returns(String) }
// 209:   def self.basename_without_extension(path)
// 210:     path.basename(path.extname).to_s
// 211:   end
// 212:
// 213:   sig { params(path: Pathname).returns(T::Array[Pathname]) }
// 214:   def self.find_commands(path)
// 215:     Pathname.glob("#{path}/*")
// 216:             .select(&:file?)
// 217:             .sort
// 218:   end
// 219:
// 220:   sig { void }
// 221:   def self.rebuild_internal_commands_completion_list
// 222:     require "completions"
// 223:
// 224:     cmds = internal_commands + internal_developer_commands
// 225:     cmds.reject! do |cmd|
// 226:       Homebrew::Completions::COMPLETIONS_EXCLUSION_LIST.include?(cmd) ||
// 227:         Homebrew::Completions.command_hidden_from_manpage?(cmd)
// 228:     end
// 229:
// 230:     file = HOMEBREW_REPOSITORY/"completions/internal_commands_list.txt"
// 231:     file.atomic_write("#{cmds.sort.join("\n")}\n")
// 232:   end
// 233:
// 234:   sig { void }
// 235:   def self.rebuild_commands_completion_list
// 236:     require "completions"
// 237:
// 238:     # Ensure that the cache exists so we can build the commands list
// 239:     HOMEBREW_CACHE.mkpath
// 240:
// 241:     # Don't reject `command_hidden_from_manpage?` commands here: internal ones
// 242:     # are already excluded and checking externals loads every tap command file.
// 243:     cmds = commands - Homebrew::Completions::COMPLETIONS_EXCLUSION_LIST
// 244:
// 245:     all_commands_file = HOMEBREW_CACHE/"all_commands_list.txt"
// 246:     external_commands_file = HOMEBREW_CACHE/"external_commands_list.txt"
// 247:     all_commands_file.atomic_write("#{cmds.sort.join("\n")}\n")
// 248:     external_commands_file.atomic_write("#{external_commands.sort.join("\n")}\n")
// 249:   end
// 250:
// 251:   sig { params(command: String, subcommand: T.nilable(String)).returns(T.nilable(T::Array[[String, String]])) }
// 252:   def self.command_options(command, subcommand: nil)
// 253:     return if command == "help"
// 254:
// 255:     path = self.path(command)
// 256:     return unless path
// 257:
// 258:     if (cmd_parser = Homebrew::CLI::Parser.from_cmd_path(path))
// 259:       processed_options = if subcommand.nil? && cmd_parser.subcommands.present?
// 260:         cmd_parser.processed_options_for_root_command
// 261:       else
// 262:         cmd_parser.processed_options_for_subcommand(subcommand)
// 263:       end
// 264:       processed_options.filter_map do |short, long, desc, hidden|
// 265:         next if hidden
// 266:
// 267:         option = long || short
// 268:         next if option.nil?
// 269:
// 270:         [option, desc]
// 271:       end
// 272:     else
// 273:       options = []
// 274:       comment_lines = path.read.lines.grep(/^#:/)
// 275:       return options if comment_lines.empty?
// 276:
// 277:       # skip the comment's initial usage summary lines
// 278:       comment_lines.slice(2..-1)&.each do |line|
// 279:         match_data = / (?<option>-[-\w]+) +(?<desc>.*)$/.match(line)
// 280:         options << [match_data[:option], match_data[:desc]] if match_data
// 281:       end
// 282:       options
// 283:     end
// 284:   end
// 285:
// 286:   sig { params(command: String, short: T::Boolean).returns(T.nilable(String)) }
// 287:   def self.command_description(command, short: false)
// 288:     path = self.path(command)
// 289:     return unless path
// 290:
// 291:     if (cmd_parser = Homebrew::CLI::Parser.from_cmd_path(path))
// 292:       if short
// 293:         cmd_parser.description&.split(DESCRIPTION_SPLITTING_PATTERN)&.first
// 294:       else
// 295:         cmd_parser.description
// 296:       end
// 297:     else
// 298:       comment_lines = path.read.lines.grep(/^#:/)
// 299:
// 300:       # skip the comment's initial usage summary lines
// 301:       comment_lines.slice(2..-1)&.each do |line|
// 302:         match_data = /^#:  (?<desc>\w.*+)$/.match(line)
// 303:         next unless match_data
// 304:
// 305:         desc = match_data[:desc]
// 306:         next if desc.nil?
// 307:
// 308:         return desc.split(DESCRIPTION_SPLITTING_PATTERN).first if short
// 309:
// 310:         return desc
// 311:       end
// 312:       nil
// 313:     end
// 314:   end
// 315:
// 316:   sig { params(command: String).returns(T::Array[Homebrew::CLI::Parser::Subcommand]) }
// 317:   def self.command_subcommands(command)
// 318:     path = self.path(command)
// 319:     return [] unless path
// 320:
// 321:     cmd_parser = Homebrew::CLI::Parser.from_cmd_path(path)
// 322:     return [] if cmd_parser.blank?
// 323:
// 324:     cmd_parser.subcommands
// 325:   end
// 326:
// 327:   sig {
// 328:     params(command: String, subcommand: T.nilable(String))
// 329:       .returns(T.nilable(T.any(T::Array[Symbol], T::Array[String])))
// 330:   }
// 331:   def self.named_args_type(command, subcommand: nil)
// 332:     path = self.path(command)
// 333:     return unless path
// 334:
// 335:     cmd_parser = Homebrew::CLI::Parser.from_cmd_path(path)
// 336:     return if cmd_parser.blank?
// 337:
// 338:     args_type = if subcommand
// 339:       cmd_parser.named_args_type_for_subcommand(subcommand)
// 340:     else
// 341:       cmd_parser.named_args_type
// 342:     end
// 343:     Array(args_type)
// 344:   end
// 345:
// 346:   # Returns the conflicts of a given `option` for `command`.
// 347:   sig { params(command: String, option: String).returns(T.nilable(T::Array[String])) }
// 348:   def self.option_conflicts(command, option)
// 349:     path = self.path(command)
// 350:     return unless path
// 351:
// 352:     cmd_parser = Homebrew::CLI::Parser.from_cmd_path(path)
// 353:     return if cmd_parser.blank?
// 354:
// 355:     hidden_options = cmd_parser.processed_options.filter_map do |short, long, _desc, hidden|
// 356:       next unless hidden
// 357:
// 358:       option_name = long || short
// 359:       next unless option_name
// 360:
// 361:       Homebrew::CLI::Parser.option_to_name(option_name).tr("_", "-")
// 362:     end
// 363:
// 364:     cmd_parser.conflicts.map do |set|
// 365:       set = set.map { |s| s.tr "_", "-" } - hidden_options
// 366:       set - [option] if set.include? option
// 367:     end.flatten.compact
// 368:   end
// 369: end
