module homebrew

import homebrew.cli as brew_cli
import os

// Translated from Homebrew/brew `manpages.rb`.

pub struct ManpageCommand {
pub:
	path       string
	has_parser bool
	parser     brew_cli.Parser
}

pub struct ManpagesConfig {
pub:
	source_path        string
	repository         string
	target_man_path    string
	target_doc_path    string
	commands           []ManpageCommand
	developer_commands []ManpageCommand
	env_state          EnvConfigState
}

pub fn manpages_format_opt(option ?string) ?string {
	if value := option {
		return '`${value}`'
	}
	return none
}

pub fn manpages_generate_option_doc(short ?string, long ?string, description string) string {
	short_text := manpages_format_opt(short) or { '' }
	long_text := manpages_format_opt(long) or { '' }
	comma := if short_text != '' && long_text != '' { ', ' } else { '' }
	return '${short_text}${comma}${long_text}\n\n: ${description}\n'
}

pub fn manpages_format_usage_text(usage_banner string) string {
	mut result := []u8{}
	mut in_code := false
	for character in usage_banner.bytes() {
		if character == `\`` {
			in_code = !in_code
			result << character
			continue
		}
		if !in_code && character in [`[`, `]`] {
			result << `\\`
		}
		result << character
	}
	return result.bytestr()
}

pub fn manpages_format_usage_banner(usage_banner string) string {
	formatted := manpages_format_usage_text(usage_banner)
	if formatted.starts_with('#:') {
		mut rest := formatted[2..]
		for rest.starts_with(' ') {
			rest = rest[1..]
		}
		if rest.starts_with('* ') {
			return '### ${rest[2..]}'
		}
	}
	return '### ${formatted}'
}

fn manpages_same_option(left brew_cli.ProcessedOption,
	right brew_cli.ProcessedOption) bool {
	return left.short == right.short && left.long == right.long
		&& left.description == right.description
}

pub fn manpages_option_lines(options []brew_cli.ProcessedOption) []string {
	global := brew_cli.global_options()
	cask := brew_cli.global_cask_options()
	mut lines := []string{}
	for option in options {
		if option.hidden {
			continue
		}
		if option.long != '' {
			if global.any(manpages_same_option(it, option)) {
				continue
			}
			mut is_global_cask := false
			for spec in cask {
				long_name := spec.names.filter(it.starts_with('--')).last()
				if option.long in [long_name, '${long_name}=']
					&& option.description == spec.description {
					is_global_cask = true
					break
				}
			}
			if is_global_cask {
				continue
			}
		}
		lines << manpages_generate_option_doc(if option.short == '' { none } else { option.short }, if option.long == '' {
			none
		} else {
			option.long
		}, option.description)
	}
	return lines
}

fn manpages_without_root_options(options []brew_cli.ProcessedOption,
	root_options []brew_cli.ProcessedOption) []brew_cli.ProcessedOption {
	mut result := []brew_cli.ProcessedOption{}
	for option in options {
		mut is_root := false
		for root_option in root_options {
			if manpages_same_option(option, root_option) {
				is_root = true
				break
			}
		}
		if !is_root {
			result << option
		}
	}
	return result
}

pub fn manpages_parser_lines(parser brew_cli.Parser) []string {
	mut lines := []string{}
	if parser.subcommand_list().len > 0 {
		root_banner := parser.root_usage_banner_text()
		if root_banner != '' {
			lines << '${manpages_format_usage_banner(root_banner)}\n\n'
		}
		if parser.description() != '' {
			lines << '${parser.description()}\n\n'
		}
		root_options := parser.processed_options_for_root_command()
		lines << manpages_option_lines(root_options)
		for subcommand in parser.subcommand_list() {
			if subcommand.usage_banner == '' {
				continue
			}
			lines << '${manpages_format_usage_text(subcommand.usage_banner)}\n\n'
			lines << manpages_option_lines(manpages_without_root_options(parser.processed_options_for_subcommand(subcommand.name), root_options))
		}
	} else {
		if parser.usage_banner_text() != '' {
			lines << manpages_format_usage_banner(parser.usage_banner_text())
		}
		lines << manpages_option_lines(parser.processed_options())
	}
	return lines
}

fn manpages_format_comment_option(line string) string {
	parts := line.trim_space().split_any(' \t')
	if parts.len < 2 || !parts[0].starts_with('-') {
		return line
	}
	if parts[0].ends_with(',') && parts.len >= 3 && parts[1].starts_with('-') {
		description := line.all_after(parts[1]).trim_space()
		return '`${parts[0].trim_string_right(',')}`, `${parts[1]}`\n\n: ${description}\n'
	}
	description := line.all_after(parts[0]).trim_space()
	return '`${parts[0]}`\n\n: ${description}\n'
}

pub fn manpages_comment_lines(command_path string) ![]string {
	content := os.read_file(command_path)!
	comments := content.split_into_lines().filter(it.starts_with('#:'))
	if comments.len == 0 || comments[0].contains('@hide_from_man_page') {
		return []
	}
	mut lines := [manpages_format_usage_banner(comments[0]).trim_space()]
	if comments.len == 1 {
		return []
	}
	for raw in comments[1..] {
		line := if raw.len > 3 { raw[3..] } else { '' }
		if line == '' {
			lines[lines.len - 1] += '\n'
			continue
		}
		if line.contains('--debug ') || line.contains('--help ') || line.contains('--quiet ')
			|| line.contains('--verbose ') {
			continue
		}
		lines << manpages_format_comment_option(line)
	}
	lines[lines.len - 1] += '\n'
	return lines
}

fn manpages_definition_lists(value string) string {
	lines := value.split_into_lines()
	mut result := []string{}
	for index, line in lines {
		if index > 0 && result.len > 0 && result.last() == '' && line.ends_with(':')
			&& (line.starts_with('`') || line.starts_with('[') || line.starts_with('?')) {
			result << line.trim_string_right(':')
			result << ''
			result << ': '
		} else {
			result << line
		}
	}
	return result.join('\n')
}

pub fn manpages_generate_commands(commands []ManpageCommand) !string {
	mut sorted := commands.clone()
	sorted.sort_with_compare(fn (left &ManpageCommand, right &ManpageCommand) int {
		left_key := manpages_sort_key(left.path)
		right_key := manpages_sort_key(right.path)
		return if left_key < right_key {
			-1
		} else if left_key > right_key { 1 } else { 0 }
	})
	mut pages := []string{}
	for command in sorted {
		mut page := ''
		if command.has_parser {
			if command.parser.is_hidden_from_man_page() {
				continue
			}
			page = manpages_parser_lines(command.parser).join('')
		} else {
			page = (manpages_comment_lines(command.path)!).join('\n')
		}
		if page != '' {
			pages << manpages_definition_lists(page)
		}
	}
	return pages.join('\n')
}

pub fn manpages_sort_key(path string) string {
	mut name := os.base(path)
	if name.ends_with('.rb') || name.ends_with('.sh') {
		name = name[..name.len - 3]
	}
	return if name.starts_with('--') { '~~${name[2..]}' } else { name }
}

pub fn manpages_global_cask_options() string {
	mut lines := [
		'These options are applicable to the `install`, `reinstall` and `upgrade` subcommands with the `--cask` switch.\n',
	]
	for option in brew_cli.global_cask_options() {
		long_name := option.names.filter(it.starts_with('--')).last().trim_string_right('=')
		lines << manpages_generate_option_doc(none, long_name, option.description)
	}
	return lines.join('\n')
}

pub fn manpages_global_options() string {
	mut lines := ['These options are applicable across multiple subcommands.\n']
	for option in brew_cli.global_options() {
		lines << manpages_generate_option_doc(option.short, option.long, option.description)
	}
	return lines.join('\n')
}

pub fn manpages_environment_variables(state &EnvConfigState) string {
	entries := env_config_entries(state)
	mut names := entries.keys()
	names.sort()
	mut lines := []string{}
	for name in names {
		entry := entries[name]
		if env_config_hidden(entry) {
			continue
		}
		mut text := '`${name}`\n\n: ${entry.description}\n'
		if default_text := env_config_default_description(name, state) {
			text += '\n\n    *Default:* ${default_text}\n'
		}
		lines << text
	}
	return lines.join('\n')
}

fn manpages_strip_markdown_links(value string) string {
	mut result := value
	for {
		open := result.index('[') or { break }
		middle_relative := result[open..].index('](') or { break }
		middle := open + middle_relative
		close_relative := result[middle + 2..].index(')') or { break }
		close := middle + 2 + close_relative
		result = result[..open] + result[open + 1..middle] + result[close + 1..]
	}
	return result
}

fn manpages_readme_role(readme string, marker string) string {
	for line in readme.split_into_lines() {
		if line.contains(marker) {
			return manpages_strip_markdown_links(line.trim_space())
		}
	}
	return ''
}

fn manpages_render_template(template string, values map[string]string) string {
	mut result := template
	for key, value in values {
		result = result.replace('<%= ${key} %>', value)
		result = result.replace('<%= ${key}.concat("\\n") %>', '${value}\n')
	}
	for result.contains('<%') {
		start := result.index('<%') or { break }
		end_relative := result[start + 2..].index('%>') or { break }
		end := start + 2 + end_relative
		result = result[..start] + result[end + 2..]
	}
	return result
}

pub fn manpages_build(config ManpagesConfig, quiet bool) !string {
	_ = quiet
	template := os.read_file(os.join_path(config.source_path, 'brew.1.md.erb'))!
	readme := os.read_file(os.join_path(config.repository, 'README.md'))!
	return manpages_render_template(template, {
		'commands':              manpages_generate_commands(config.commands)!
		'developer_commands':    manpages_generate_commands(config.developer_commands)!
		'global_cask_options':   manpages_global_cask_options()
		'global_options':        manpages_global_options()
		'environment_variables': manpages_environment_variables(&config.env_state)
		'project_leader':        manpages_readme_role(readme, "Homebrew's [Project Leader")
		'lead_maintainers':      manpages_readme_role(readme, "Homebrew's [Lead Maintainers")
		'maintainers':           manpages_readme_role(readme, "Homebrew's other Maintainers")
	})
}

fn manpages_basic_roff(markup string) string {
	mut lines := []string{}
	for line in markup.split_into_lines() {
		if line.starts_with('## ') {
			lines << '.SH ${line[3..].to_upper()}'
		} else if line.starts_with('### ') {
			lines << '.SS ${line[4..]}'
		} else if line.starts_with('brew(1)') {
			lines << '.TH BREW 1'
		} else {
			lines << line
		}
	}
	return lines.join('\n')
}

pub fn manpages_regenerate(config ManpagesConfig, quiet bool) ! {
	markup := manpages_build(config, quiet)!
	os.mkdir_all(config.target_doc_path)!
	os.mkdir_all(config.target_man_path)!
	os.write_file(os.join_path(config.target_doc_path, 'Manpage.md'), markup)!
	os.write_file(os.join_path(config.target_man_path, 'brew.1'), manpages_basic_roff(markup))!
}
