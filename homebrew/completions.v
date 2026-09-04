module homebrew

import ruby
import homebrew.utils as link_utils
import os

// Translated from Homebrew/brew `completions.rb`.
pub struct CompletionSubcommand {
pub:
	name        string
	aliases     []string
	description string
	default     bool
	options     []CompletionOption
	named_args  []CompletionNamedArgument
}

pub struct CompletionOption {
pub:
	name        string
	description string
}

pub struct CompletionNamedArgument {
pub:
	value     string
	is_symbol bool
}

pub struct CompletionCommand {
pub:
	name        string
	description string
	hidden      bool
	options     []CompletionOption
	subcommands []CompletionSubcommand
	named_args  []CompletionNamedArgument
	conflicts   map[string][]string
}

pub struct CompletionTap {
pub:
	path     string
	official bool
}

const completion_shells = ['bash', 'fish', 'zsh']
const completions_exclusion_list = ['instal', 'uninstal', 'update-report']

fn completion_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn completion_sorted_distinct(values []string) []string {
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

fn completion_taps_from_value(value ruby.Value) []CompletionTap {
	return value.array_data.map(CompletionTap{
		path: it.attributes['path'] or { it.as_string() }
		official: (it.attributes['official'] or { 'false' }) == 'true'
	})
}

pub fn completion_installed_taps(tap_directory string) []CompletionTap {
	mut taps := []CompletionTap{}
	if !os.is_dir(tap_directory) {
		return taps
	}
	mut users := os.ls(tap_directory) or { return taps }
	users.sort()
	for user in users {
		user_path := os.join_path(tap_directory, user)
		if !os.is_dir(user_path) {
			continue
		}
		mut repositories := os.ls(user_path) or { continue }
		repositories.sort()
		for repository in repositories {
			repository_path := os.join_path(user_path, repository)
			if !os.is_dir(repository_path) {
				continue
			}
			taps << CompletionTap{
				path: repository_path
				official: user.to_lower() in ['homebrew', 'linuxbrew']
			}
		}
	}
	return taps
}

pub fn completion_link(mut settings Settings, taps []CompletionTap, prefix string) ![]string {
	settings.write_bool('linkcompletions', true)!
	mut conflicts := []string{}
	for tap in taps {
		conflicts << link_utils.link_completions(tap.path, prefix, 'brew completions link')!
	}
	return completion_sorted_distinct(conflicts)
}

pub fn completion_unlink(mut settings Settings, taps []CompletionTap, prefix string) ! {
	settings.write_bool('linkcompletions', false)!
	for tap in taps {
		if !tap.official {
			link_utils.unlink_completions(tap.path, prefix)!
		}
	}
}

pub fn completion_link_enabled(mut settings Settings) bool {
	return settings.read('linkcompletions') or { '' } == 'true'
}

pub fn completion_taps_have_unlinked_files(taps []CompletionTap) bool {
	for tap in taps {
		if tap.official {
			continue
		}
		for shell in completion_shells {
			if os.exists(os.join_path(tap.path, 'completions', shell)) {
				return true
			}
		}
	}
	return false
}

pub fn completion_show_message_if_needed(mut settings Settings, taps []CompletionTap) !string {
	if settings.read('completionsmessageshown') or { '' } == 'true' || !completion_taps_have_unlinked_files(taps) {
		return ''
	}
	settings.write_bool('completionsmessageshown', true)!
	return 'Homebrew completions for external commands are unlinked by default!\n' + 'To opt-in to automatically linking external tap shell completion files, run:\n' + '  brew completions link\n' + 'Then, follow the directions at https://docs.brew.sh/Shell-Completion\n'
}

pub fn completion_command_gets_completions(options []CompletionOption,
	subcommands []CompletionSubcommand) bool {
	return options.len > 0 || subcommands.len > 0
}

pub fn completion_command_hidden_from_manpage(command_found bool, hidden bool) bool {
	return command_found && hidden
}

pub fn completion_format_description(description string, fish bool) string {
	escaped := if fish {
		description.replace("'", "\\'")
	} else {
		description.replace("'", "'\\''")
	}
	return escaped.replace('<', '').replace('>', '').replace('\n', ' ').trim_right('.')
}

pub fn completion_zsh_command_description(command string, description string) ?string {
	if description.trim_space() == '' {
		return none
	}
	return "'${command}:${completion_format_description(description, false)}'"
}

pub fn completion_subcommand_names(subcommands []CompletionSubcommand) []string {
	mut names := []string{}
	for subcommand in subcommands {
		names << subcommand.name
		names << subcommand.aliases
	}
	return names
}

pub fn completion_command_options(options []CompletionOption) map[string]string {
	mut result := map[string]string{}
	for option in options {
		if option.name.trim_space() == '' {
			continue
		}
		if option.name.starts_with('--[no-]') {
			result[option.name.replace('[no-]', '')] = option.description
			result[option.name.replace('[no-]', 'no-')] = option.description
		} else {
			result[option.name] = option.description
		}
	}
	return result
}

fn bash_named_argument_function(kind string) ?string {
	return match kind {
		'formula' { '__brew_complete_formulae' }
		'installed_formula' { '__brew_complete_installed_formulae' }
		'outdated_formula' { '__brew_complete_outdated_formulae' }
		'cask' { '__brew_complete_casks' }
		'installed_cask' { '__brew_complete_installed_casks' }
		'outdated_cask' { '__brew_complete_outdated_casks' }
		'tap', 'installed_tap' { '__brew_complete_tapped' }
		'command' { '__brew_complete_commands' }
		'diagnostic_check' {
			r'__brewcomp "${__HOMEBREW_DOCTOR_CHECKS=$(brew doctor --list-checks)}"'
		}
		'file' { '__brew_complete_files' }
		'service' { '__brew_complete_services' }
		else { none }
	}
}

fn zsh_named_argument_function(kind string) ?string {
	return match kind {
		'formula' { '__brew_formulae' }
		'installed_formula' { '__brew_installed_formulae' }
		'outdated_formula' { '__brew_outdated_formulae' }
		'cask' { '__brew_casks' }
		'installed_cask' { '__brew_installed_casks' }
		'outdated_cask' { '__brew_outdated_casks' }
		'tap' { '__brew_any_tap' }
		'installed_tap' { '__brew_installed_taps' }
		'command' { '__brew_commands' }
		'diagnostic_check' { '__brew_diagnostic_checks' }
		'file' { '__brew_formulae_or_ruby_files' }
		'service' { '__brew_services' }
		else { none }
	}
}

fn fish_named_argument_function(kind string) ?string {
	return match kind {
		'formula' { '__fish_brew_suggest_formulae_all' }
		'installed_formula' { '__fish_brew_suggest_formulae_installed' }
		'outdated_formula' { '__fish_brew_suggest_formulae_outdated' }
		'cask' { '__fish_brew_suggest_casks_all' }
		'installed_cask' { '__fish_brew_suggest_casks_installed' }
		'outdated_cask' { '__fish_brew_suggest_casks_outdated' }
		'tap', 'installed_tap' { '__fish_brew_suggest_taps_installed' }
		'command' { '__fish_brew_suggest_commands' }
		'diagnostic_check' { '__fish_brew_suggest_diagnostic_checks' }
		'service' { '__fish_brew_suggest_services' }
		else { none }
	}
}

pub fn completion_generate_bash_named_args(arguments []CompletionNamedArgument) string {
	mut functions := []string{}
	mut literals := []string{}
	for argument in arguments {
		if argument.is_symbol {
			if function := bash_named_argument_function(argument.value) {
				functions << function
			}
		} else {
			literals << argument.value
		}
	}
	mut output := ''
	for function in functions {
		output += '\n  ${function}'
	}
	if literals.len > 0 {
		output += '\n  __brewcomp "${literals.join(' ')}"'
	}
	return output
}

fn completion_options_from_command_path(path string, subcommand string) []CompletionOption {
	options := command_options_for_path(path, subcommand) or { return [] }
	return options.map(CompletionOption{
		name: it.option
		description: it.description
	})
}

fn completion_named_args_from_path(path string, subcommand string) []CompletionNamedArgument {
	arguments := named_args_type_for_path(path, subcommand) or { return [] }
	return arguments.map(CompletionNamedArgument{
		value: it
		is_symbol: true
	})
}

pub fn completion_command_from_name(name string) ?CompletionCommand {
	path := command_file_path(name) or { return none }
	metadata := command_metadata_from_path(path) or { return none }
	description := command_description_for_path(path, true) or { metadata.description }
	mut subcommands := []CompletionSubcommand{}
	for subcommand in metadata.subcommands {
		if subcommand.hidden {
			continue
		}
		subcommands << CompletionSubcommand{
			name: subcommand.name
			aliases: subcommand.aliases
			description: subcommand.description
			options: completion_options_from_command_path(path, subcommand.name)
			named_args: completion_named_args_from_path(path, subcommand.name)
		}
	}
	mut conflicts := map[string][]string{}
	for option in metadata.options {
		name_without_dashes := option.option.trim_left('-')
		conflicts[option.option] = option_conflicts_for_path(path, name_without_dashes) or { [] }
	}
	return CompletionCommand{
		name: name
		description: description
		hidden: metadata.hidden
		options: completion_options_from_command_path(path, '')
		subcommands: subcommands
		named_args: completion_named_args_from_path(path, '')
		conflicts: conflicts
	}
}

pub fn completion_commands_from_names(names []string) []CompletionCommand {
	mut result := []CompletionCommand{}
	for name in names {
		if command := completion_command_from_name(name) {
			result << command
		} else {
			result << CompletionCommand{
				name: name
			}
		}
	}
	return result
}

fn completion_subcommands_from_value(value ruby.Value) []CompletionSubcommand {
	if value.array_data.len == 0 && value.string_array_data.len > 0 {
		return value.string_array_data.map(CompletionSubcommand{
			name: it
		})
	}
	return value.array_data.map(CompletionSubcommand{
		name: it.attributes['name'] or { it.as_string() }
		aliases: (it.attributes['aliases'] or { '' }).split(',').filter(it != '')
		description: it.attributes['description'] or { '' }
		default: (it.attributes['default'] or { 'false' }) == 'true'
	})
}

fn completion_options_from_value(value ruby.Value) []CompletionOption {
	if value.map_data.len > 0 {
		mut names := value.map_data.keys()
		names.sort()
		return names.map(CompletionOption{
			name: it
			description: value.map_data[it].as_string()
		})
	}
	if value.array_data.len == 0 && value.string_array_data.len > 0 {
		return value.string_array_data.map(CompletionOption{
			name: it
		})
	}
	return value.array_data.map(CompletionOption{
		name: it.attributes['name'] or { it.as_string() }
		description: it.attributes['description'] or { '' }
	})
}

fn completion_named_args_from_value(value ruby.Value) []CompletionNamedArgument {
	raw := value.array_data.clone()
	if raw.len == 0 && value.string_array_data.len > 0 {
		return value.string_array_data.map(CompletionNamedArgument{
			value: it
			is_symbol: true
		})
	}
	return raw.map(CompletionNamedArgument{
		value: it.as_string()
		is_symbol: it.type_name == 'Symbol'
	})
}

fn completion_command_from_values(args []ruby.Value, index int) CompletionCommand {
	if args.len <= index {
		return CompletionCommand{}
	}
	value := args[index]
	name := value.attributes['name'] or { value.as_string() }
	if command := completion_command_from_name(name) {
		return command
	}
	return CompletionCommand{
		name: name
		description: value.attributes['description'] or { '' }
		hidden: (value.attributes['hidden'] or { 'false' }) == 'true'
		options: if args.len > index + 1 {
			completion_options_from_value(args[index + 1])
		} else {
			[]
		}
		subcommands: if args.len > index + 2 {
			completion_subcommands_from_value(args[index + 2])
		} else {
			[]
		}
		named_args: if args.len > index + 3 {
			completion_named_args_from_value(args[index + 3])
		} else {
			[]
		}
	}
}

fn completion_command_with_subcommands(command CompletionCommand,
	subcommands []CompletionSubcommand) CompletionCommand {
	return CompletionCommand{
		name: command.name
		description: command.description
		hidden: command.hidden
		options: command.options
		subcommands: subcommands
		named_args: command.named_args
		conflicts: command.conflicts
	}
}

fn completion_commands_from_value(value ruby.Value) []CompletionCommand {
	if value.array_data.len > 0 {
		return value.array_data.map(completion_command_from_values([it], 0))
	}
	return completion_commands_from_names(value.string_array_data)
}

fn completion_boundary_repository(args []ruby.Value, index int) string {
	if args.len > index && args[index].as_string() != '' {
		return args[index].as_string()
	}
	repository := ruby.environment_value('HOMEBREW_REPOSITORY')
	return if repository == '' { ruby.real_path('.') } else { repository }
}

fn completion_boundary_prefix(args []ruby.Value, index int, repository string) string {
	if args.len > index && args[index].as_string() != '' {
		return args[index].as_string()
	}
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	return if prefix == '' { repository } else { prefix }
}

fn completion_boundary_taps(args []ruby.Value, index int,
	repository string) []CompletionTap {
	if args.len > index {
		return completion_taps_from_value(args[index])
	}
	mut tap_directory := ruby.environment_value('HOMEBREW_TAP_DIRECTORY')
	if tap_directory == '' {
		tap_directory = os.join_path(repository, 'Library', 'Taps')
	}
	return completion_installed_taps(tap_directory)
}

fn completion_sorted_option_names(options []CompletionOption) []string {
	mut names := completion_command_options(options).keys()
	names.sort()
	return names
}

fn completion_subcommand_alias_pattern(subcommand CompletionSubcommand) string {
	mut names := [subcommand.name]
	names << subcommand.aliases
	return names.join('|')
}

pub fn completion_generate_bash_nested(command CompletionCommand) string {
	top_level_options := completion_sorted_option_names(command.options).join('\n          ')
	subcommand_names := completion_subcommand_names(command.subcommands).join(' ')
	mut subcommand_cases := []string{}
	mut option_cases := []string{}
	mut named_arg_cases := []string{}
	for subcommand in command.subcommands {
		subcommand_cases << '      ${completion_subcommand_alias_pattern(subcommand)}) subcommand="${subcommand.name}"; break ;;'
		options := completion_sorted_option_names(subcommand.options).join('\n        ')
		option_cases << '          ${subcommand.name})\n' + '            __brewcomp "\n' + '        ${options}\n' + '            "\n' + '            return\n' + '            ;;'
		named := completion_generate_bash_named_args(subcommand.named_args)
		if named != '' {
			named_arg_cases << '      ${subcommand.name})${named}\n        ;;'
		}
	}
	return '_brew_${method_name(command.name)}() {\n' + r'  local cur="${COMP_WORDS[COMP_CWORD]}"' + '\n  local subcommand=""\n  local i\n' + r'  for (( i = 2; i < COMP_CWORD; i++ ))' + '\n  do\n' + r'    case "${COMP_WORDS[i]}" in' + '\n${subcommand_cases.join('\n')}\n' + '      *) ;;\n    esac\n  done\n' + r'  case "${cur}" in' + '\n    -*)\n' + r'      case "${subcommand}" in' + '\n        "")\n' + '          __brewcomp "\n          ${top_level_options}\n          "\n          return\n          ;;\n' + '${option_cases.join('\n')}\n        *) ;;\n      esac\n      ;;\n    *) ;;\n  esac\n' + r'  case "${subcommand}" in' + '\n    "")\n      __brewcomp "${subcommand_names}"\n      ;;\n' + '${named_arg_cases.join('\n')}\n    *) ;;\n  esac\n}\n'
}

pub fn completion_generate_bash_command(command CompletionCommand) ?string {
	if !completion_command_gets_completions(command.options, command.subcommands) {
		return none
	}
	if command.subcommands.len > 0 {
		return completion_generate_bash_nested(command)
	}
	named := completion_generate_bash_named_args(command.named_args)
	options := completion_sorted_option_names(command.options).join('\n      ')
	return '_brew_${method_name(command.name)}() {\n' + r'  local cur="${COMP_WORDS[COMP_CWORD]}"' + '\n' + r'  case "${cur}" in' + '\n    -*)\n      __brewcomp "\n      ${options}\n      "\n' + '      return\n      ;;\n    *) ;;\n  esac${named}\n}\n'
}

fn completion_alias_keys() []string {
	mut aliases := internal_command_aliases.keys()
	aliases.sort()
	return aliases
}

pub fn completion_generate_bash_file(commands []CompletionCommand) string {
	mut command_names := commands.map(it.name).filter(it !in internal_command_aliases)
	command_names = completion_sorted_distinct(command_names)
	mut functions := []string{}
	mut mappings := []string{}
	mut maintainers := []string{}
	for name in command_names {
		command := commands.filter(it.name == name)[0]
		if generated := completion_generate_bash_command(command) {
			functions << generated
			mappings << '${name}) _brew_${method_name(name)} ;;'
		}
		if command.hidden {
			maintainers << name
		}
	}
	mut aliases := []string{}
	for alias_name in completion_alias_keys() {
		aliases << '${alias_name}) echo "${internal_command_aliases[alias_name]}" ;;'
	}
	alias_helpers := '__brew_list_aliases() {\n  local aliases_dir="\${HOME}/.config/brew-aliases"\n  local pattern="alias: brew ([^[:space:]]+)"\n  local alias_name line\n  local -a aliases\n  [[ ! -d \${aliases_dir} ]] && aliases_dir="\${HOME}/.brew-aliases"\n  [[ ! -d \${aliases_dir} ]] && return\n  for file in "\${aliases_dir}"/*; do\n    [[ ! -f \${file} || \${file} == *~ ]] && continue\n    alias_name="\${file##*/}"\n    {\n      read -r line\n      if read -r line && [[ \${line} =~ \${pattern} ]]; then\n        alias_name="\${BASH_REMATCH[1]}"\n      fi\n    } < "\${file}"\n    aliases+=("\${alias_name}")\n  done\n  [[ -n \${aliases[*]+"\${aliases[*]}"} ]] && echo "\${aliases[@]}"\n}\n\n'
	command_helpers := '__brew_complete_commands() {\n  local cur="\${COMP_WORDS[COMP_CWORD]}"\n  local cmds="\${__HOMEBREW_COMMANDS}"\n  local maintainer_cmds\n  local user_aliases\n  if [[ -n \${HOMEBREW_DEVELOPER:-} ]]; then\n    maintainer_cmds="${maintainers.join(' ')}"\n  fi\n  user_aliases="\$(__brew_list_aliases)"\n  while read -r line\n  do\n    [[ \$(__brew_internal_command_alias "\${line}") == "\${line}" ]] || continue\n    COMPREPLY+=("\${line}")\n  done < <(compgen -W "\${cmds} \${maintainer_cmds} \${user_aliases}" -- "\${cur}")\n}\n\n'
	return '# Bash completion script for brew(1)\n' + '# This file is automatically generated by running `brew generate-man-completions`.\n\n' + '__brewcomp() {\n  local cur="\${COMP_WORDS[COMP_CWORD]}"\n  COMPREPLY=( \$(compgen -W "\$1" -- "\${cur}") )\n}\n\n' + '__brew_internal_command_alias() {\n  case "\$1" in\n    ${aliases.join('\n    ')}\n    *) echo "\$1" ;;\n  esac\n}\n\n' + alias_helpers + command_helpers + '${functions.join('\n')}\n_brew() {\n  local cmd="\${COMP_WORDS[1]}"\n  cmd="\$(__brew_internal_command_alias "\${cmd}")"\n  case "\${cmd}" in\n    ${mappings.join('\n    ')}\n    *) __brew_complete_commands ;;\n  esac\n}\n\ncomplete -o bashdefault -o default -F _brew brew\n'
}

pub fn completion_format_zsh_argument(option string) string {
	return if option.starts_with('- ') { option } else { "'${option}'" }
}

pub fn completion_generate_zsh_option_exclusions(command CompletionCommand, option string) string {
	mut conflicts := command.conflicts[option] or { [] }
	if conflicts.len == 0 {
		conflicts = command.conflicts[option.trim_left('-')] or { [] }
	}
	if conflicts.len == 0 {
		return ''
	}
	mut exclusions := []string{}
	for conflict in conflicts {
		name := conflict.trim_left('-')
		exclusions << if name.len > 1 { '--${name}' } else { '-${name}' }
	}
	return '(${exclusions.join(' ')})'
}

pub fn completion_generate_zsh_arguments(command CompletionCommand, options []CompletionOption,
	arguments []CompletionNamedArgument) []string {
	mut remaining := completion_command_options(options)
	mut result := []string{}
	for argument in arguments {
		if argument.is_symbol {
			function := zsh_named_argument_function(argument.value) or { continue }
			result << '- ${argument.value}'
			base_type := argument.value.trim_string_left('installed_').trim_string_left('outdated_')
			option := '--${base_type}'
			if description := remaining[option] {
				if description == '' {
					result << option
				} else {
					result << '${completion_generate_zsh_option_exclusions(command, option)}${option}[${completion_format_description(description, false)}]'
				}
				remaining.delete(option)
			}
			result << '*:${argument.value}:${function}'
		} else {
			result << '- subcommand'
			result << '*:subcommand:(${argument.value})'
		}
	}
	mut option_names := remaining.keys()
	option_names.sort()
	mut option_results := []string{}
	for option in option_names {
		description := remaining[option]
		option_results << if description == '' {
			option
		} else {
			'${completion_generate_zsh_option_exclusions(command, option)}${option}[${completion_format_description(description, false)}]'
		}
	}
	option_results << result
	return option_results
}

pub fn completion_generate_zsh_nested(command CompletionCommand) string {
	mut top := completion_generate_zsh_arguments(command, command.options, []).map(completion_format_zsh_argument(it))
	top << "'1:subcommand:->subcommand'"
	top << "'*::arg:->args'"
	mut descriptions := []string{}
	mut cases := []string{}
	for subcommand in command.subcommands {
		mut names := [subcommand.name]
		names << subcommand.aliases
		for name in names {
			descriptions << if subcommand.description == '' {
				"'${name}'"
			} else {
				"'${name}:${completion_format_description(subcommand.description, false)}'"
			}
		}
		options := completion_generate_zsh_arguments(command, subcommand.options, subcommand.named_args).map(completion_format_zsh_argument(it))
		cases << '      ${names.join('|')})\n        _arguments \\\n          ${options.join(' \\\n          ')}\n        ;;'
	}
	return '# brew ${command.name}\n_brew_${method_name(command.name)}() {\n  local state\n  local -a subcommands\n' + '  subcommands=(\n    ${descriptions.join('\n    ')}\n  )\n  _arguments -C \\\n    ${top.join(' \\\n    ')}\n' + '  case "\$state" in\n    subcommand) _describe -t subcommands \'subcommand\' subcommands ;;\n' + '    args)\n      case "\$words[1]" in\n${cases.join('\n')}\n        *) ;;\n      esac\n      ;;\n  esac\n}\n'
}

pub fn completion_generate_zsh_command(command CompletionCommand) ?string {
	if !completion_command_gets_completions(command.options, command.subcommands) {
		return none
	}
	if command.subcommands.len > 0 {
		return completion_generate_zsh_nested(command)
	}
	options := completion_generate_zsh_arguments(command, command.options, command.named_args).map(completion_format_zsh_argument(it))
	return '# brew ${command.name}\n_brew_${method_name(command.name)}() {\n  _arguments \\\n    ${options.join(' \\\n    ')}\n}\n'
}

pub fn completion_generate_zsh_file(commands []CompletionCommand) string {
	mut aliases := []string{}
	for alias_name in completion_alias_keys() {
		alias_value := internal_command_aliases[alias_name]
		formatted_name := if alias_name.starts_with('-') { "'${alias_name}'" } else { alias_name }
		formatted_value := if alias_value.starts_with('-') {
			"'${alias_value}'"
		} else {
			alias_value
		}
		aliases << '${formatted_name} ${formatted_value}'
	}
	mut descriptions := []string{}
	mut maintainers := []string{}
	mut functions := []string{}
	for command in commands {
		if command.name in internal_command_aliases {
			continue
		}
		if description := completion_zsh_command_description(command.name, command.description) {
			if command.hidden {
				maintainers << description
			} else {
				descriptions << description
			}
		}
		if generated := completion_generate_zsh_command(command) {
			functions << generated
		}
	}
	user_aliases := '__brew_user_aliases() {\n  local aliases_dir="\${HOME}/.config/brew-aliases"\n  local pattern="alias: brew ([^[:space:]]+)"\n  local file line alias_name\n  local -a aliases\n  [[ ! -d \${aliases_dir} ]] && aliases_dir="\${HOME}/.brew-aliases"\n  [[ ! -d \${aliases_dir} ]] && return\n  for file in "\${aliases_dir}"/*(N); do\n    [[ ! -f \${file} || \${file} == *~ ]] && continue\n    alias_name="\${file:t}"\n    {\n      read -r line\n      if read -r line && [[ \${line} =~ \${pattern} ]]; then\n        alias_name="\${match[1]}"\n      fi\n    } < "\${file}"\n    aliases+=("\${alias_name}")\n  done\n  (( \${#aliases} )) && _describe -t user-aliases \'user aliases\' aliases\n}\n\n'
	command_selector := "__brew_commands() {\n  _alternative \\\n    'internal-commands:command:__brew_internal_commands' \\\n    'user-aliases:alias:__brew_user_aliases'\n}\n\n"
	return '#compdef brew\n#autoload\n# Brew ZSH completion function\n\n' + '__brew_list_aliases() {\n  local -a aliases\n  aliases=(\n    ${aliases.join('\n    ')}\n  )\n  echo "\${aliases}"\n}\n\n' + user_aliases + '__brew_internal_commands() {\n  local -a commands\n  commands=(\n    ${descriptions.join('\n    ')}\n  )\n' + "  [[ -n \${HOMEBREW_DEVELOPER:-} ]] && commands+=(\n    ${maintainers.join('\n    ')}\n  )\n  _describe -t internal-commands 'internal commands' commands\n}\n\n" + command_selector + '${functions.join('\n')}\n_brew() {\n  local command_or_alias="\$words[2]"\n  local command\n  local -A aliases\n  aliases=(\$(__brew_list_aliases))\n  command="\${aliases[\$command_or_alias]:-\$command_or_alias}"\n  local completion_func="_brew_\${command//-/_}"\n  _call_function ret "\${completion_func}" || __brew_internal_commands\n}\n\n_brew "\$@"\n'
}

pub fn completion_generate_fish_named_args(command CompletionCommand,
	arguments []CompletionNamedArgument, subcommand string) []string {
	mut result := []string{}
	options := completion_command_options(command.options)
	formula_and_cask := '--formula' in options && '--cask' in options
	for argument in arguments {
		if !argument.is_symbol {
			if subcommand == '' {
				result << "__fish_brew_complete_sub_cmd '${command.name}' '${argument.value}'"
			}
			continue
		}
		function := fish_named_argument_function(argument.value) or { continue }
		if subcommand != '' {
			result << "__fish_brew_complete_sub_arg '${command.name}' '${subcommand}' -a '(${function})'"
		} else if formula_and_cask && argument.value.ends_with('formula') {
			result << "__fish_brew_complete_arg '${command.name}; and not __fish_seen_argument -l cask -l casks' -a '(${function})'"
		} else if formula_and_cask && argument.value.ends_with('cask') {
			result << "__fish_brew_complete_arg '${command.name}; and not __fish_seen_argument -l formula -l formulae' -a '(${function})'"
		} else {
			result << "__fish_brew_complete_arg '${command.name}' -a '(${function})'"
		}
	}
	return result
}

fn completion_fish_option_line(_command string, condition string, option CompletionOption) string {
	mut line := '${condition} -l ${option.name.trim_left('-')}'
	if option.description != '' {
		line += " -d '${completion_format_description(option.description, true)}'"
	}
	return line
}

pub fn completion_generate_fish_nested(command CompletionCommand) string {
	description := completion_format_description(command.description, true)
	mut lines := []string{}
	if command.name !in completions_exclusion_list && command.name !in internal_command_aliases {
		lines << "__fish_brew_complete_cmd '${command.name}' '${description}'"
	}
	for subcommand in command.subcommands {
		mut names := [subcommand.name]
		names << subcommand.aliases
		for name in names {
			mut line := "__fish_brew_complete_sub_cmd '${command.name}' '${name}'"
			if subcommand.description != '' {
				line += " '${completion_format_description(subcommand.description, true)}'"
			}
			lines << line
		}
	}
	mut top_level_options := command.options.clone()
	top_level_options.sort_with_compare(fn (left &CompletionOption, right &CompletionOption) int {
		return compare_strings(left.name, right.name)
	})
	for option in top_level_options {
		lines << completion_fish_option_line(command.name, "__fish_brew_complete_arg '${command.name}; and [ (count (__fish_brew_args)) = 1 ]'", option)
	}
	for subcommand in command.subcommands {
		mut names := [subcommand.name]
		names << subcommand.aliases
		joined_names := names.join(' ')
		mut subcommand_options := subcommand.options.clone()
		subcommand_options.sort_with_compare(fn (left &CompletionOption, right &CompletionOption) int {
			return compare_strings(left.name, right.name)
		})
		for option in subcommand_options {
			lines << completion_fish_option_line(command.name, "__fish_brew_complete_sub_arg '${command.name}' '${joined_names}'", option)
		}
		lines << completion_generate_fish_named_args(command, subcommand.named_args, joined_names)
	}
	return '${lines.join('\n')}\n'
}

pub fn completion_generate_fish_command(command CompletionCommand) ?string {
	description := completion_format_description(command.description, true)
	mut lines := []string{}
	if command.name !in completions_exclusion_list && command.name !in internal_command_aliases {
		if command.hidden {
			lines << "complete -f -c brew -n 'not __fish_brew_command; and set -q HOMEBREW_DEVELOPER' -a '${command.name}' -d '${description}'"
		} else {
			lines << "__fish_brew_complete_cmd '${command.name}' '${description}'"
		}
	}
	if !completion_command_gets_completions(command.options, command.subcommands) {
		return none
	}
	if command.subcommands.len > 0 {
		return completion_generate_fish_nested(command)
	}
	mut options := command.options.clone()
	options.sort_with_compare(fn (left &CompletionOption, right &CompletionOption) int {
		return compare_strings(left.name, right.name)
	})
	for option in options {
		lines << completion_fish_option_line(command.name, "__fish_brew_complete_arg '${command.name}'", option)
	}
	lines << completion_generate_fish_named_args(command, command.named_args, '')
	return '${lines.join('\n')}\n'
}

pub fn completion_generate_fish_file(commands []CompletionCommand) string {
	mut aliases := []string{}
	for alias_name in completion_alias_keys() {
		aliases << "        case '${alias_name}'\n            echo '${internal_command_aliases[alias_name]}'"
	}
	mut functions := []string{}
	for command in commands {
		if command.name in internal_command_aliases {
			continue
		}
		if generated := completion_generate_fish_command(command) {
			functions << generated
		}
	}
	return '# Fish shell completions for Homebrew\n# This file is automatically generated by running `brew generate-man-completions`.\n\n' + 'function __fish_brew_args\n    set -l tokens (commandline -opc)\n    set -e tokens[1]\n    for t in \$tokens\n        echo \$t\n    end\nend\n\n' + "function __fish_brew_expand_alias -a cmd\n    switch \$cmd\n${aliases.join('\n')}\n        case '*'\n            echo \$cmd\n    end\nend\n\n" + 'function __fish_brew_command\n    set args (__fish_brew_args)\n    set -q args[1]; or return 1\n    set -l cmd (__fish_brew_expand_alias \$args[1])\n    if count \$argv\n        contains -- \$cmd \$argv\n    else\n        echo \$cmd\n    end\nend\n\n' + 'function __fish_brew_subcommand -a cmd\n    set args (__fish_brew_args)\n    __fish_brew_command \$cmd\n    and set -q args[2]\n    and set -l sub \$args[2]\n    or return 1\n    set -e argv[1]\n    if count \$argv\n        contains -- \$sub \$argv\n    else\n        echo \$sub\n    end\nend\n\n' + 'function __fish_brew_suggest_aliases\n    set -l aliases_dir "\$HOME/.config/brew-aliases"\n    test -d \$aliases_dir; or set aliases_dir "\$HOME/.brew-aliases"\n    test -d \$aliases_dir; or return\n    for file in \$aliases_dir/*\n        test -f \$file; and not string match -q \'*~\' -- \$file; or continue\n        set -l alias_name (string replace -r \'^.*/\' \'\' -- \$file)\n        begin\n            read -l line\n            if read -l line\n                set -l match (string match -rg \'alias: brew ([^[:space:]]+)\' -- \$line)\n                test -n "\$match"; and set alias_name \$match[1]\n            end\n        end < \$file\n        echo \$alias_name\n    end\nend\n\n' + 'function __fish_brew_suggest_commands\n    set -l commands\n    if test -f (brew --cache)/all_commands_list.txt\n        set commands (cat (brew --cache)/all_commands_list.txt)\n    else\n        set commands (cat (brew --repo)/completions/internal_commands_list.txt)\n    end\n    for command in \$commands\n        set -l expanded_command (__fish_brew_expand_alias \$command)\n        test "\$expanded_command" = "\$command"; and echo \$command\n    end\n    __fish_brew_suggest_aliases\nend\n\n' + "function __fish_brew_complete_cmd -a cmd\n    set -e argv[1]\n    complete -f -c brew -n 'not __fish_brew_command' -a \$cmd -d \$argv\nend\n\n" + 'function __fish_brew_complete_arg -a cond\n    set -e argv[1]\n    complete -f -c brew -n "__fish_brew_command \$cond" \$argv\nend\n\n' + 'function __fish_brew_complete_sub_cmd -a cmd sub\n    set -e argv[1..2]\n    __fish_brew_complete_arg "\$cmd; and [ (count (__fish_brew_args)) = 1 ]" -a \$sub -d \$argv\nend\n\n' + 'function __fish_brew_complete_sub_arg -a cmd sub\n    set -e argv[1..2]\n    complete -f -c brew -n "__fish_brew_subcommand \$cmd \$sub" \$argv\nend\n\n${functions.join('\n')}'
}

pub fn completion_update_shell_completions(repository string, commands []CompletionCommand) ![]string {
	outputs := {
		'bash/brew':      completion_generate_bash_file(commands)
		'zsh/_brew':      completion_generate_zsh_file(commands)
		'fish/brew.fish': completion_generate_fish_file(commands)
	}
	mut paths := []string{}
	for relative, contents in outputs {
		path := os.join_path(repository, 'completions', relative)
		os.mkdir_all(os.dir(path))!
		ruby.atomic_write_file(path, contents)!
		paths << path
	}
	paths.sort()
	return paths
}
