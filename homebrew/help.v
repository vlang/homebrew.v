module homebrew

import os
import homebrew.utils as brew_utils

// Translated from Homebrew/brew `help.rb`.
pub enum HelpCommandKind {
	internal
	internal_developer
	external_ruby_v2
	external_ruby
	external
}

pub enum HelpAction {
	print_and_exit
	resume_execution
}

pub enum HelpStream {
	none
	stdout
	stderr
}

pub struct HelpTapMetadata {
pub:
	name     string
	official bool
}

pub struct HelpCommandMetadata {
pub:
	found   bool
	name    string
	path    string
	kind    HelpCommandKind
	has_tap bool
	tap     HelpTapMetadata
}

pub struct HelpCommandLocations {
pub:
	internal_path  string
	developer_path string
	tap_directory  string
	path_value     string
}

pub struct HelpRequest {
pub:
	command        string
	empty_argv     bool
	usage_error    ?string
	remaining_args []string
}

pub struct HelpStyle {
pub:
	bold         string
	reset        string
	underline    string
	no_underline string
	width        int = 80
}

pub struct HelpParserResult {
pub:
	available bool
	output    string
}

pub struct HelpText {
pub:
	found bool
	text  string
}

pub struct HelpCommandRendering {
pub:
	output  string
	warning string
}

pub struct HelpResult {
pub:
	action  HelpAction
	stream  HelpStream
	status  int
	output  string
	command HelpCommandMetadata
	warning string
}

pub type HelpParserRenderer = fn (path string, remaining_args []string, usage_error bool) !HelpParserResult

pub struct HelpContext {
pub:
	generic_help string
	locations    HelpCommandLocations
	developer    bool
	style        HelpStyle
	trust        CommandTrustChecker @[required]
	parser       HelpParserRenderer @[required]
}

fn ensure_help_line(output string) string {
	if output.ends_with('\n') {
		return output
	}
	return '${output}\n'
}

fn path_within(path string, directory string) bool {
	if path == '' || directory == '' {
		return false
	}
	real_path := os.real_path(path)
	real_directory := os.real_path(directory).trim_string_right(os.path_separator)
	return real_path == real_directory || real_path.starts_with('${real_directory}${os.path_separator}')
}

pub fn help_tap_from_path(path string, tap_directory string) ?HelpTapMetadata {
	if !path_within(path, tap_directory) {
		return none
	}
	relative := os.real_path(path)[os.real_path(tap_directory).trim_string_right(os.path_separator).len..].trim_left(os.path_separator)
	parts := relative.split(os.path_separator)
	if parts.len < 3 || parts[0] == '' || parts[1] == '' {
		return none
	}
	tap := new_tap_reference('${parts[0]}/${parts[1]}', '') or { return none }
	return HelpTapMetadata{
		name: tap.name
		official: tap.official()
	}
}

fn help_command_metadata(name string, path string, kind HelpCommandKind,
	tap_directory string) HelpCommandMetadata {
	if tap := help_tap_from_path(path, tap_directory) {
		return HelpCommandMetadata{
			found: true
			name: name
			path: path
			kind: kind
			has_tap: true
			tap: tap
		}
	}
	return HelpCommandMetadata{
		found: true
		name: name
		path: path
		kind: kind
	}
}

fn help_permit_command(_ string, _ string) ! {}

fn require_help_command_trust(path string, command string, locations HelpCommandLocations,
	trust CommandTrustChecker) ! {
	if path_within(path, locations.tap_directory) {
		trust(path, command)!
	}
}

pub fn resolve_help_command(command string, locations HelpCommandLocations,
	trust CommandTrustChecker) !HelpCommandMetadata {
	canonical := canonical_command(command)
	if path := internal_cmd_path_in(locations.internal_path, canonical) {
		return help_command_metadata(canonical, path, .internal, locations.tap_directory)
	}
	if path := internal_cmd_path_in(locations.developer_path, canonical) {
		return help_command_metadata(canonical, path, .internal_developer, locations.tap_directory)
	}
	tap_directories := tap_cmd_directories_in(locations.tap_directory)
	if path := external_ruby_v2_cmd_path_in(command, tap_directories, locations.tap_directory, help_permit_command) {
		if path != '' {
			require_help_command_trust(path, command, locations, trust)!
			return help_command_metadata(command, path, .external_ruby_v2, locations.tap_directory)
		}
	}
	if path := external_ruby_cmd_path_in(command, locations.path_value, tap_directories, locations.tap_directory, help_permit_command) {
		if path != '' {
			require_help_command_trust(path, command, locations, trust)!
			return help_command_metadata(command, path, .external_ruby, locations.tap_directory)
		}
	}
	if path := external_cmd_path_in(command, locations.path_value, tap_directories, locations.tap_directory, help_permit_command) {
		if path != '' {
			require_help_command_trust(path, command, locations, trust)!
			return help_command_metadata(command, path, .external, locations.tap_directory)
		}
	}
	return HelpCommandMetadata{
		name: canonical
	}
}

fn command_name_from_help_path(path string) string {
	mut name := os.base(path).trim_string_right(os.file_ext(path))
	if name.starts_with('brew-') {
		name = name[5..]
	}
	return name
}

// The callback-backed parser representation keeps parser loading separate from
// help flow decisions while providing a useful source-derived default.
pub fn default_help_parser(path string, remaining_args []string,
	usage_error bool) !HelpParserResult {
	metadata := command_metadata_from_path(path)!
	if !metadata.ruby_command {
		return HelpParserResult{}
	}
	mut command := command_name_from_help_path(path)
	if metadata.subcommands.len > 0 && remaining_args.len > 0 {
		candidate := remaining_args[0]
		if usage_error || metadata.subcommands.any(it.name == candidate || candidate in it.aliases) {
			if metadata.subcommands.any(it.name == candidate || candidate in it.aliases) {
				command += ' ${candidate}'
			}
		}
	}
	mut lines := [
		'Usage: brew ${command}${if metadata.options.any(!it.hidden) { ' [options]' } else { '' }}',
	]
	if metadata.description != '' {
		lines << ''
		lines << metadata.description
	}
	for option in metadata.options {
		if !option.hidden {
			lines << '  ${option.option}\t${option.description}'
		}
	}
	return HelpParserResult{
		available: true
		output: lines.join('\n') + '\n'
	}
}

pub fn default_help_style() HelpStyle {
	return HelpStyle{
		bold: brew_utils.tty_escape('bold')
		reset: brew_utils.tty_escape('reset')
		underline: brew_utils.tty_escape('underline')
		no_underline: brew_utils.tty_escape('no_underline')
		width: 80
	}
}

pub fn command_help_lines(path string) ![]string {
	contents := os.read_file(path)!
	mut lines := []string{}
	mut start := 0
	for start < contents.len {
		newline := contents[start..].index_u8(`\n`)
		end := if newline < 0 { contents.len } else { start + newline + 1 }
		line := contents[start..end]
		if line.starts_with('#:') {
			mut help_line := line[2..]
			if help_line.starts_with('  ') {
				help_line = help_line[2..]
			}
			lines << help_line
		}
		if newline < 0 {
			break
		}
		start = end
	}
	return lines
}

fn replace_help_delimiters(input string, opening string, closing string, before string,
	after string) string {
	mut output := ''
	mut remaining := input
	for {
		start := remaining.index(opening) or {
			output += remaining
			break
		}
		end_relative := remaining[start + opening.len..].index(closing) or {
			output += remaining
			break
		}
		end := start + opening.len + end_relative
		output += remaining[..start] + before + remaining[start + opening.len..end] + after
		remaining = remaining[end + closing.len..]
	}
	return output
}

fn style_help_angles(input string, style HelpStyle) string {
	mut output := ''
	mut remaining := input
	for {
		start := remaining.index('<') or {
			output += remaining
			break
		}
		end_relative := remaining[start + 1..].index('>') or {
			output += remaining
			break
		}
		end := start + 1 + end_relative
		value := remaining[start + 1..end]
		after := if value.contains('://') { style.no_underline } else { style.reset }
		output += remaining[..start] + style.underline + value + after
		remaining = remaining[end + 1..]
	}
	return output
}

pub fn comment_help(path string, style HelpStyle) !HelpText {
	help_lines := command_help_lines(path)!
	if help_lines.len == 0 {
		return HelpText{}
	}
	width := if style.width > 0 { style.width } else { 80 }
	mut output := brew_utils.formatter_format_help_text(help_lines.join(''), width)
	output = output.replace_once('@hide_from_man_page ', '')
	if output.starts_with('* ') {
		output = '${style.bold}Usage: brew${style.reset} ' + output[2..]
	}
	output = replace_help_delimiters(output, '`', '`', style.bold, style.reset)
	output = style_help_angles(output, style)
	output = replace_help_delimiters(output, '*', '*', style.underline, style.reset)
	return HelpText{
		found: output.trim_space() != ''
		text: output
	}
}

fn help_parser_eligible(command HelpCommandMetadata) bool {
	return command.kind in [.internal, .internal_developer, .external_ruby_v2]
}

pub fn parser_help(command HelpCommandMetadata, remaining_args []string, usage_error bool,
	render HelpParserRenderer) !HelpText {
	if !help_parser_eligible(command) {
		return HelpText{}
	}
	parsed := render(command.path, remaining_args, usage_error)!
	return HelpText{
		found: parsed.available && parsed.output.trim_space() != ''
		text: parsed.output
	}
}

pub fn command_help(command HelpCommandMetadata, remaining_args []string, usage_error bool,
	context HelpContext) !HelpCommandRendering {
	mut output := parser_help(command, remaining_args, usage_error, context.parser)!
	if !output.found {
		output = comment_help(command.path, context.style)!
	}
	if output.found {
		return HelpCommandRendering{
			output: if command.has_tap && !command.tap.official {
				'From tap: ${command.tap.name}\n${output.text}'
			} else {
				output.text
			}
		}
	}
	return HelpCommandRendering{
		output: context.generic_help
		warning: if context.developer { 'No help text in: ${command.path}' } else { '' }
	}
}

pub fn help(request HelpRequest, context HelpContext) !HelpResult {
	if request.command == '' {
		return HelpResult{
			action: .print_and_exit
			stream: if request.empty_argv { .stderr } else { .stdout }
			status: if request.empty_argv { 1 } else { 0 }
			output: ensure_help_line(context.generic_help)
		}
	}
	command := resolve_help_command(request.command, context.locations, context.trust)!
	if usage_error := request.usage_error {
		mut output := context.generic_help
		mut warning := ''
		if command.found {
			rendered := command_help(command, request.remaining_args, true, context)!
			output = rendered.output
			warning = rendered.warning
		}
		return HelpResult{
			action: .print_and_exit
			stream: .stderr
			status: 1
			output: '${output.trim_right('\n')}\n\nError: ${usage_error}\n'
			command: command
			warning: warning
		}
	}
	if !command.found {
		return HelpResult{
			action: .resume_execution
			command: command
		}
	}
	if command.kind == .external && os.file_ext(command.path) != '.rb' && (command_help_lines(command.path)!).len == 0 {
		return HelpResult{
			action: .resume_execution
			command: command
		}
	}
	rendered := command_help(command, request.remaining_args, false, context)!
	return HelpResult{
		action: .print_and_exit
		stream: .stdout
		status: 0
		output: ensure_help_line(rendered.output)
		command: command
		warning: rendered.warning
	}
}
