module homebrew

import ruby
import homebrew.cli as brew_cli
import os

// Translated from Homebrew/brew `commands.rb`.
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
