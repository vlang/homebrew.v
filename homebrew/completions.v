module homebrew

import brew_runtime
import homebrew.utils as link_utils
import os

// Translated from Homebrew/brew `completions.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn completion_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
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

fn completion_taps_from_value(value brew_runtime.Value) []CompletionTap {
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

fn completion_subcommands_from_value(value brew_runtime.Value) []CompletionSubcommand {
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

fn completion_options_from_value(value brew_runtime.Value) []CompletionOption {
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

fn completion_named_args_from_value(value brew_runtime.Value) []CompletionNamedArgument {
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

fn completion_command_from_values(args []brew_runtime.Value, index int) CompletionCommand {
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
			completion_options_from_value(args[index + 1])} else {
			[]}
		subcommands: if args.len > index + 2 {
			completion_subcommands_from_value(args[index + 2])} else {
			[]}
		named_args: if args.len > index + 3 {
			completion_named_args_from_value(args[index + 3])} else {
			[]}
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

fn completion_commands_from_value(value brew_runtime.Value) []CompletionCommand {
	if value.array_data.len > 0 {
		return value.array_data.map(completion_command_from_values([it], 0))
	}
	return completion_commands_from_names(value.string_array_data)
}

fn completion_boundary_repository(args []brew_runtime.Value, index int) string {
	if args.len > index && args[index].as_string() != '' {
		return args[index].as_string()
	}
	repository := brew_runtime.environment_value('HOMEBREW_REPOSITORY')
	return if repository == '' { brew_runtime.real_path('.') } else { repository }
}

fn completion_boundary_prefix(args []brew_runtime.Value, index int, repository string) string {
	if args.len > index && args[index].as_string() != '' {
		return args[index].as_string()
	}
	prefix := brew_runtime.environment_value('HOMEBREW_PREFIX')
	return if prefix == '' { repository } else { prefix }
}

fn completion_boundary_taps(args []brew_runtime.Value, index int,
	repository string) []CompletionTap {
	if args.len > index {
		return completion_taps_from_value(args[index])
	}
	mut tap_directory := brew_runtime.environment_value('HOMEBREW_TAP_DIRECTORY')
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
		brew_runtime.atomic_write_file(path, contents)!
		paths << path
	}
	paths.sort()
	return paths
}

// Ruby method `self.link!` at line 78.
pub fn ruby_completions_l78_d1_self_link(args ...brew_runtime.Value) brew_runtime.Value {
	repository := completion_boundary_repository(args, 0)
	taps := completion_boundary_taps(args, 1, repository)
	prefix := completion_boundary_prefix(args, 2, repository)
	mut settings := new_settings(repository)
	completion_link(mut settings, taps, prefix) or { panic(err) }
	return completion_nil_value()
}

// Ruby method `self.unlink!` at line 86.
pub fn ruby_completions_l86_d2_self_unlink(args ...brew_runtime.Value) brew_runtime.Value {
	repository := completion_boundary_repository(args, 0)
	taps := completion_boundary_taps(args, 1, repository)
	prefix := completion_boundary_prefix(args, 2, repository)
	mut settings := new_settings(repository)
	completion_unlink(mut settings, taps, prefix) or { panic(err) }
	return completion_nil_value()
}

// Ruby method `self.link_completions?` at line 96.
pub fn ruby_completions_l96_d3_self_link_completions(args ...brew_runtime.Value) brew_runtime.Value {
	repository := completion_boundary_repository(args, 0)
	mut settings := new_settings(repository)
	return brew_runtime.bool_value(completion_link_enabled(mut settings))
}

// Ruby method `self.completions_to_link?` at line 101.
pub fn ruby_completions_l101_d4_self_completions_to_link(args ...brew_runtime.Value) brew_runtime.Value {
	repository := completion_boundary_repository(args, 1)
	taps := completion_boundary_taps(args, 0, repository)
	return brew_runtime.bool_value(completion_taps_have_unlinked_files(taps))
}

// Ruby method `self.show_completions_message_if_needed` at line 114.
pub fn ruby_completions_l114_d5_self_show_completions_message_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	repository := completion_boundary_repository(args, 0)
	taps := completion_boundary_taps(args, 1, repository)
	mut settings := new_settings(repository)
	return brew_runtime.string_value(completion_show_message_if_needed(mut settings, taps) or {
		panic(err)
	})
}

// Ruby method `self.update_shell_completions!` at line 129.
pub fn ruby_completions_l129_d6_self_update_shell_completions(args ...brew_runtime.Value) brew_runtime.Value {
	repository := completion_boundary_repository(args, 0)
	command_models := if args.len > 1 {
		completion_commands_from_value(args[1])
	} else {
		mut names := internal_commands()
		names << internal_developer_commands()
		completion_commands_from_names(names)
	}
	completion_update_shell_completions(repository, command_models) or { panic(err) }
	return completion_nil_value()
}

// Ruby method `self.command_gets_completions?(command)` at line 143.
pub fn ruby_completions_l143_d7_self_command_gets_completions(args ...brew_runtime.Value) brew_runtime.Value {
	options := if args.len > 1 {
		completion_options_from_value(args[1])
	} else {
		[]CompletionOption{}
	}
	subcommands := if args.len > 2 {
		completion_subcommands_from_value(args[2])
	} else {
		[]CompletionSubcommand{}
	}
	return brew_runtime.bool_value(completion_command_gets_completions(options, subcommands))
}

// Ruby method `self.command_hidden_from_manpage?(command)` at line 148.
pub fn ruby_completions_l148_d8_self_command_hidden_from_manpage(args ...brew_runtime.Value) brew_runtime.Value {
	found := args.len > 1 && (args[1].as_bool() or { false })
	hidden := args.len > 2 && (args[2].as_bool() or { false })
	return brew_runtime.bool_value(completion_command_hidden_from_manpage(found, hidden))
}

// Ruby method `self.zsh_command_description(command)` at line 155.
pub fn ruby_completions_l155_d9_self_zsh_command_description(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	if description := completion_zsh_command_description(args[0].as_string(), args[1].as_string()) {
		return brew_runtime.string_value(description)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.subcommand_completion_names(subcommands)` at line 163.
pub fn ruby_completions_l163_d10_self_subcommand_completion_names(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([])
	}
	return brew_runtime.string_array_value(completion_subcommand_names(completion_subcommands_from_value(args[0])))
}

// Ruby method `self.format_description(description, fish: false)` at line 168.
pub fn ruby_completions_l168_d11_self_format_description(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('format_description requires a description')
	}
	fish := args.len > 1 && (args[1].as_bool() or { false })
	return brew_runtime.string_value(completion_format_description(args[0].as_string(), fish))
}

// Ruby method `self.command_options(command, subcommand: nil)` at line 178.
pub fn ruby_completions_l178_d12_self_command_options(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.map_value(map[string]brew_runtime.Value{})
	}
	options := completion_command_options(completion_options_from_value(args[1]))
	mut values := map[string]brew_runtime.Value{}
	for name, description in options {
		values[name] = brew_runtime.string_value(description)
	}
	return brew_runtime.map_value(values)
}

// Ruby method `self.generate_bash_named_args_completion(types)` at line 196.
pub fn ruby_completions_l196_d13_self_generate_bash_named_args_completion(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value('')
	}
	arguments := args[0].array_data.map(CompletionNamedArgument{
		value: it.as_string()
		is_symbol: it.type_name == 'Symbol'
	})
	return brew_runtime.string_value(completion_generate_bash_named_args(arguments))
}

// Ruby method `self.generate_bash_nested_subcommand_completion(command, subcommands)` at line 213.
pub fn ruby_completions_l213_d14_self_generate_bash_nested_subcommand_completion(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('generate_bash_nested_subcommand_completion requires a command and subcommands')
	}
	command := completion_command_with_subcommands(completion_command_from_values([
		args[0],
	], 0), completion_subcommands_from_value(args[1]))
	return brew_runtime.string_value(completion_generate_bash_nested(command))
}

// Ruby method `self.generate_bash_subcommand_completion(command)` at line 281.
pub fn ruby_completions_l281_d15_self_generate_bash_subcommand_completion(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('generate_bash_subcommand_completion requires a command')
	}
	if generated := completion_generate_bash_command(completion_command_from_values(args, 0)) {
		return brew_runtime.string_value(generated)
	}
	return completion_nil_value()
}

// Ruby method `self.generate_bash_completion_file(commands)` at line 306.
pub fn ruby_completions_l306_d16_self_generate_bash_completion_file(args ...brew_runtime.Value) brew_runtime.Value {
	command_models := if args.len == 0 {
		[]CompletionCommand{}
	} else {
		completion_commands_from_value(args[0])
	}
	return brew_runtime.string_value(completion_generate_bash_file(command_models))
}

// Ruby method `self.format_zsh_argument(opt)` at line 328.
pub fn ruby_completions_l328_d17_self_format_zsh_argument(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('format_zsh_argument requires an option')
	}
	return brew_runtime.string_value(completion_format_zsh_argument(args[0].as_string()))
}

// Ruby method `self.generate_zsh_subcommand_completion(command)` at line 337.
pub fn ruby_completions_l337_d18_self_generate_zsh_subcommand_completion(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('generate_zsh_subcommand_completion requires a command')
	}
	if generated := completion_generate_zsh_command(completion_command_from_values(args, 0)) {
		return brew_runtime.string_value(generated)
	}
	return completion_nil_value()
}

// Ruby method `self.generate_zsh_arguments(command, options, types)` at line 362.
pub fn ruby_completions_l362_d19_self_generate_zsh_arguments(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('generate_zsh_arguments requires a command and options')
	}
	command := completion_command_from_values([args[0]], 0)
	arguments := if args.len > 2 {
		completion_named_args_from_value(args[2])
	} else {
		[]CompletionNamedArgument{}
	}
	return brew_runtime.string_array_value(completion_generate_zsh_arguments(command, completion_options_from_value(args[1]), arguments))
}

// Ruby method `self.generate_zsh_nested_subcommand_completion(command, subcommands)` at line 407.
pub fn ruby_completions_l407_d20_self_generate_zsh_nested_subcommand_completion(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('generate_zsh_nested_subcommand_completion requires a command and subcommands')
	}
	command := completion_command_with_subcommands(completion_command_from_values([
		args[0],
	], 0), completion_subcommands_from_value(args[1]))
	return brew_runtime.string_value(completion_generate_zsh_nested(command))
}

// Ruby method `self.generate_zsh_option_exclusions(command, option)` at line 470.
pub fn ruby_completions_l470_d21_self_generate_zsh_option_exclusions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('generate_zsh_option_exclusions requires a command and option')
	}
	return brew_runtime.string_value(completion_generate_zsh_option_exclusions(completion_command_from_values([
		args[0],
	], 0), args[1].as_string()))
}

// Ruby method `self.generate_zsh_completion_file(commands)` at line 478.
pub fn ruby_completions_l478_d22_self_generate_zsh_completion_file(args ...brew_runtime.Value) brew_runtime.Value {
	command_models := if args.len == 0 {
		[]CompletionCommand{}
	} else {
		completion_commands_from_value(args[0])
	}
	return brew_runtime.string_value(completion_generate_zsh_file(command_models))
}

// Ruby method `self.generate_fish_subcommand_completion(command)` at line 510.
pub fn ruby_completions_l510_d23_self_generate_fish_subcommand_completion(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('generate_fish_subcommand_completion requires a command')
	}
	if generated := completion_generate_fish_command(completion_command_from_values(args, 0)) {
		return brew_runtime.string_value(generated)
	}
	return completion_nil_value()
}

// Ruby method `self.generate_fish_named_args(command, types, subcommand: nil)` at line 570.
pub fn ruby_completions_l570_d24_self_generate_fish_named_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.string_array_value([])
	}
	command := completion_command_from_values([args[0]], 0)
	subcommand := if args.len > 2 { args[2].as_string() } else { '' }
	return brew_runtime.string_array_value(completion_generate_fish_named_args(command, completion_named_args_from_value(args[1]), subcommand))
}

// Ruby method `self.generate_fish_nested_subcommand_completion(command, subcommands)` at line 607.
pub fn ruby_completions_l607_d25_self_generate_fish_nested_subcommand_completion(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('generate_fish_nested_subcommand_completion requires a command and subcommands')
	}
	command := completion_command_with_subcommands(completion_command_from_values([
		args[0],
	], 0), completion_subcommands_from_value(args[1]))
	return brew_runtime.string_value(completion_generate_fish_nested(command))
}

// Ruby method `self.generate_fish_completion_file(commands)` at line 653.
pub fn ruby_completions_l653_d26_self_generate_fish_completion_file(args ...brew_runtime.Value) brew_runtime.Value {
	command_models := if args.len == 0 {
		[]CompletionCommand{}
	} else {
		completion_commands_from_value(args[0])
	}
	return brew_runtime.string_value(completion_generate_fish_file(command_models))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/link"
// 5: require "settings"
// 6: require "erb"
// 7: require "tap"
// 8:
// 9: module Homebrew
// 10:   # Helper functions for generating shell completions.
// 11:   module Completions
// 12:     extend Utils::Output::Mixin
// 13:
// 14:     Variables = Struct.new(
// 15:       :aliases,
// 16:       :builtin_command_descriptions,
// 17:       :completion_functions,
// 18:       :maintainer_descriptions,
// 19:       :maintainer_commands,
// 20:       :function_mappings,
// 21:     )
// 22:
// 23:     COMPLETIONS_DIR = T.let((HOMEBREW_REPOSITORY/"completions").freeze, Pathname)
// 24:     TEMPLATE_DIR = T.let((HOMEBREW_LIBRARY_PATH/"completions").freeze, Pathname)
// 25:
// 26:     SHELLS = %w[bash fish zsh].freeze
// 27:     COMPLETIONS_EXCLUSION_LIST = %w[
// 28:       instal
// 29:       uninstal
// 30:       update-report
// 31:     ].freeze
// 32:
// 33:     BASH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING = T.let({
// 34:       formula:           "__brew_complete_formulae",
// 35:       installed_formula: "__brew_complete_installed_formulae",
// 36:       outdated_formula:  "__brew_complete_outdated_formulae",
// 37:       cask:              "__brew_complete_casks",
// 38:       installed_cask:    "__brew_complete_installed_casks",
// 39:       outdated_cask:     "__brew_complete_outdated_casks",
// 40:       tap:               "__brew_complete_tapped",
// 41:       installed_tap:     "__brew_complete_tapped",
// 42:       command:           "__brew_complete_commands",
// 43:       diagnostic_check:  '__brewcomp "${__HOMEBREW_DOCTOR_CHECKS=$(brew doctor --list-checks)}"',
// 44:       file:              "__brew_complete_files",
// 45:       service:           "__brew_complete_services",
// 46:     }.freeze, T::Hash[Symbol, String])
// 47:
// 48:     ZSH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING = T.let({
// 49:       formula:           "__brew_formulae",
// 50:       installed_formula: "__brew_installed_formulae",
// 51:       outdated_formula:  "__brew_outdated_formulae",
// 52:       cask:              "__brew_casks",
// 53:       installed_cask:    "__brew_installed_casks",
// 54:       outdated_cask:     "__brew_outdated_casks",
// 55:       tap:               "__brew_any_tap",
// 56:       installed_tap:     "__brew_installed_taps",
// 57:       command:           "__brew_commands",
// 58:       diagnostic_check:  "__brew_diagnostic_checks",
// 59:       file:              "__brew_formulae_or_ruby_files",
// 60:       service:           "__brew_services",
// 61:     }.freeze, T::Hash[Symbol, String])
// 62:
// 63:     FISH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING = T.let({
// 64:       formula:           "__fish_brew_suggest_formulae_all",
// 65:       installed_formula: "__fish_brew_suggest_formulae_installed",
// 66:       outdated_formula:  "__fish_brew_suggest_formulae_outdated",
// 67:       cask:              "__fish_brew_suggest_casks_all",
// 68:       installed_cask:    "__fish_brew_suggest_casks_installed",
// 69:       outdated_cask:     "__fish_brew_suggest_casks_outdated",
// 70:       tap:               "__fish_brew_suggest_taps_installed",
// 71:       installed_tap:     "__fish_brew_suggest_taps_installed",
// 72:       command:           "__fish_brew_suggest_commands",
// 73:       diagnostic_check:  "__fish_brew_suggest_diagnostic_checks",
// 74:       service:           "__fish_brew_suggest_services",
// 75:     }.freeze, T::Hash[Symbol, String])
// 76:
// 77:     sig { void }
// 78:     def self.link!
// 79:       Settings.write :linkcompletions, true
// 80:       Tap.installed.each do |tap|
// 81:         Utils::Link.link_completions tap.path, "brew completions link"
// 82:       end
// 83:     end
// 84:
// 85:     sig { void }
// 86:     def self.unlink!
// 87:       Settings.write :linkcompletions, false
// 88:       Tap.installed.each do |tap|
// 89:         next if tap.official?
// 90:
// 91:         Utils::Link.unlink_completions tap.path
// 92:       end
// 93:     end
// 94:
// 95:     sig { returns(T::Boolean) }
// 96:     def self.link_completions?
// 97:       Settings.read(:linkcompletions) == "true"
// 98:     end
// 99:
// 100:     sig { returns(T::Boolean) }
// 101:     def self.completions_to_link?
// 102:       Tap.installed.each do |tap|
// 103:         next if tap.official?
// 104:
// 105:         SHELLS.each do |shell|
// 106:           return true if (tap.path/"completions/#{shell}").exist?
// 107:         end
// 108:       end
// 109:
// 110:       false
// 111:     end
// 112:
// 113:     sig { void }
// 114:     def self.show_completions_message_if_needed
// 115:       return if Settings.read(:completionsmessageshown) == "true"
// 116:       return unless completions_to_link?
// 117:
// 118:       ohai "Homebrew completions for external commands are unlinked by default!"
// 119:       puts <<~EOS
// 120:         To opt-in to automatically linking external tap shell completion files, run:
// 121:           brew completions link
// 122:         Then, follow the directions at #{Formatter.url("https://docs.brew.sh/Shell-Completion")}
// 123:       EOS
// 124:
// 125:       Settings.write :completionsmessageshown, true
// 126:     end
// 127:
// 128:     sig { void }
// 129:     def self.update_shell_completions!
// 130:       commands = (Commands.internal_commands_paths + Commands.internal_developer_commands_paths)
// 131:                  .map { |path| Commands.basename_without_extension(path) }
// 132:                  .uniq
// 133:                  .sort
// 134:
// 135:       puts "Writing completions to #{COMPLETIONS_DIR}"
// 136:
// 137:       (COMPLETIONS_DIR/"bash/brew").atomic_write generate_bash_completion_file(commands)
// 138:       (COMPLETIONS_DIR/"zsh/_brew").atomic_write generate_zsh_completion_file(commands)
// 139:       (COMPLETIONS_DIR/"fish/brew.fish").atomic_write generate_fish_completion_file(commands)
// 140:     end
// 141:
// 142:     sig { params(command: String).returns(T::Boolean) }
// 143:     def self.command_gets_completions?(command)
// 144:       command_options(command).any? || Commands.command_subcommands(command).any?
// 145:     end
// 146:
// 147:     sig { params(command: String).returns(T::Boolean) }
// 148:     def self.command_hidden_from_manpage?(command)
// 149:       return false unless (cmd_path = Commands.path(command))
// 150:
// 151:       Homebrew::CLI::Parser.from_cmd_path(cmd_path)&.hide_from_man_page == true
// 152:     end
// 153:
// 154:     sig { params(command: String).returns(T.nilable(String)) }
// 155:     def self.zsh_command_description(command)
// 156:       description = Commands.command_description(command, short: true)
// 157:       return if description.blank?
// 158:
// 159:       "'#{command}:#{format_description(description)}'"
// 160:     end
// 161:
// 162:     sig { params(subcommands: T::Array[Homebrew::CLI::Parser::Subcommand]).returns(T::Array[String]) }
// 163:     def self.subcommand_completion_names(subcommands)
// 164:       subcommands.flat_map { |subcommand| [subcommand.name, *subcommand.aliases] }
// 165:     end
// 166:
// 167:     sig { params(description: String, fish: T::Boolean).returns(String) }
// 168:     def self.format_description(description, fish: false)
// 169:       description = if fish
// 170:         description.gsub("'", "\\\\'")
// 171:       else
// 172:         description.gsub("'", "'\\\\''")
// 173:       end
// 174:       description.gsub(/[<>]/, "").tr("\n", " ").chomp(".")
// 175:     end
// 176:
// 177:     sig { params(command: String, subcommand: T.nilable(String)).returns(T::Hash[String, String]) }
// 178:     def self.command_options(command, subcommand: nil)
// 179:       options = {}
// 180:       Commands.command_options(command, subcommand:)&.each do |option|
// 181:         next if option.blank?
// 182:
// 183:         name = option.first
// 184:         desc = option.second
// 185:         if name.start_with? "--[no-]"
// 186:           options[name.gsub("[no-]", "")] = desc
// 187:           options[name.sub("[no-]", "no-")] = desc
// 188:         else
// 189:           options[name] = desc
// 190:         end
// 191:       end
// 192:       options
// 193:     end
// 194:
// 195:     sig { params(types: T.nilable(T::Array[T.any(Symbol, String)])).returns(String) }
// 196:     def self.generate_bash_named_args_completion(types)
// 197:       named_completion_string = ""
// 198:       return named_completion_string if types.blank?
// 199:
// 200:       named_args_strings, named_args_types = types.partition { |type| type.is_a? String }
// 201:
// 202:       T.cast(named_args_types, T::Array[Symbol]).each do |type|
// 203:         next unless BASH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING.key? type
// 204:
// 205:         named_completion_string += "\n  #{BASH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING[type]}"
// 206:       end
// 207:
// 208:       named_completion_string += "\n  __brewcomp \"#{named_args_strings.join(" ")}\"" if named_args_strings.any?
// 209:       named_completion_string
// 210:     end
// 211:
// 212:     sig { params(command: String, subcommands: T::Array[Homebrew::CLI::Parser::Subcommand]).returns(String) }
// 213:     def self.generate_bash_nested_subcommand_completion(command, subcommands)
// 214:       top_level_options = command_options(command).keys.sort.join("\n          ")
// 215:       subcommand_names = subcommand_completion_names(subcommands).join(" ")
// 216:       subcommand_cases = subcommands.map do |subcommand|
// 217:         "      #{([subcommand.name] + subcommand.aliases).join("|")}) subcommand=\"#{subcommand.name}\"; break ;;"
// 218:       end.join("\n")
// 219:       option_cases = subcommands.map do |subcommand|
// 220:         options = command_options(command, subcommand: subcommand.name).keys.sort.join("\n        ")
// 221:         <<~EOS
// 222:           #{subcommand.name})
// 223:                   __brewcomp "
// 224:                   #{options}
// 225:                   "
// 226:                   return
// 227:                   ;;
// 228:         EOS
// 229:       end.join
// 230:       named_arg_cases = subcommands.filter_map do |subcommand|
// 231:         named_completion_string = generate_bash_named_args_completion(
// 232:           Commands.named_args_type(command, subcommand: subcommand.name),
// 233:         )
// 234:         next if named_completion_string.blank?
// 235:
// 236:         <<~EOS
// 237:           #{subcommand.name})#{named_completion_string}
// 238:                   ;;
// 239:         EOS
// 240:       end.join
// 241:
// 242:       <<~COMPLETION
// 243:         _brew_#{Commands.method_name command}() {
// 244:           local cur="${COMP_WORDS[COMP_CWORD]}"
// 245:           local subcommand=""
// 246:           local i
// 247:           for (( i = 2; i < COMP_CWORD; i++ ))
// 248:           do
// 249:             case "${COMP_WORDS[i]}" in
// 250:         #{subcommand_cases}
// 251:               *) ;;
// 252:             esac
// 253:           done
// 254:           case "${cur}" in
// 255:             -*)
// 256:               case "${subcommand}" in
// 257:                 "")
// 258:                   __brewcomp "
// 259:                   #{top_level_options}
// 260:                   "
// 261:                   return
// 262:                   ;;
// 263:         #{option_cases.chomp}
// 264:                 *) ;;
// 265:               esac
// 266:               ;;
// 267:             *) ;;
// 268:           esac
// 269:           case "${subcommand}" in
// 270:             "")
// 271:               __brewcomp "#{subcommand_names}"
// 272:               ;;
// 273:         #{named_arg_cases.chomp}
// 274:             *) ;;
// 275:           esac
// 276:         }
// 277:       COMPLETION
// 278:     end
// 279:
// 280:     sig { params(command: String).returns(T.nilable(String)) }
// 281:     def self.generate_bash_subcommand_completion(command)
// 282:       return unless command_gets_completions? command
// 283:
// 284:       subcommands = Commands.command_subcommands(command)
// 285:       return generate_bash_nested_subcommand_completion(command, subcommands) if subcommands.present?
// 286:
// 287:       named_completion_string = generate_bash_named_args_completion(Commands.named_args_type(command))
// 288:
// 289:       <<~COMPLETION
// 290:         _brew_#{Commands.method_name command}() {
// 291:           local cur="${COMP_WORDS[COMP_CWORD]}"
// 292:           case "${cur}" in
// 293:             -*)
// 294:               __brewcomp "
// 295:               #{command_options(command).keys.sort.join("\n      ")}
// 296:               "
// 297:               return
// 298:               ;;
// 299:             *) ;;
// 300:           esac#{named_completion_string}
// 301:         }
// 302:       COMPLETION
// 303:     end
// 304:
// 305:     sig { params(commands: T::Array[String]).returns(String) }
// 306:     def self.generate_bash_completion_file(commands)
// 307:       commands -= Commands.internal_commands_aliases
// 308:
// 309:       variables = Variables.new(
// 310:         aliases:              Commands::HOMEBREW_INTERNAL_COMMAND_ALIASES.map do |alias_cmd, command|
// 311:           "#{alias_cmd}) echo \"#{command}\" ;;"
// 312:         end,
// 313:         completion_functions: commands.filter_map do |command|
// 314:           generate_bash_subcommand_completion command
// 315:         end,
// 316:         maintainer_commands:  commands.select { |command| command_hidden_from_manpage?(command) },
// 317:         function_mappings:    commands.filter_map do |command|
// 318:           next unless command_gets_completions? command
// 319:
// 320:           "#{command}) _brew_#{Commands.method_name command} ;;"
// 321:         end,
// 322:       )
// 323:
// 324:       ERB.new((TEMPLATE_DIR/"bash.erb").read, trim_mode: ">").result(variables.instance_eval { binding })
// 325:     end
// 326:
// 327:     sig { params(opt: String).returns(String) }
// 328:     def self.format_zsh_argument(opt)
// 329:       if opt.start_with?("- ")
// 330:         opt
// 331:       else
// 332:         "'#{opt}'"
// 333:       end
// 334:     end
// 335:
// 336:     sig { params(command: String).returns(T.nilable(String)) }
// 337:     def self.generate_zsh_subcommand_completion(command)
// 338:       return unless command_gets_completions? command
// 339:
// 340:       subcommands = Commands.command_subcommands(command)
// 341:       return generate_zsh_nested_subcommand_completion(command, subcommands) if subcommands.present?
// 342:
// 343:       options = command_options(command)
// 344:       options = generate_zsh_arguments(command, options, Commands.named_args_type(command))
// 345:
// 346:       <<~COMPLETION
// 347:         # brew #{command}
// 348:         _brew_#{Commands.method_name command}() {
// 349:           _arguments \\
// 350:             #{options.map! { |opt| format_zsh_argument(opt) }.join(" \\\n    ")}
// 351:         }
// 352:       COMPLETION
// 353:     end
// 354:
// 355:     sig {
// 356:       params(
// 357:         command: String,
// 358:         options: T::Hash[String, String],
// 359:         types:   T.nilable(T::Array[T.any(Symbol, String)]),
// 360:       ).returns(T::Array[String])
// 361:     }
// 362:     def self.generate_zsh_arguments(command, options, types)
// 363:       options = options.dup
// 364:
// 365:       args_options = []
// 366:       if types
// 367:         named_args_strings, named_args_types = types.partition { |type| type.is_a? String }
// 368:
// 369:         T.cast(named_args_types, T::Array[Symbol]).each do |type|
// 370:           next unless ZSH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING.key? type
// 371:
// 372:           args_options << "- #{type}"
// 373:           opt = "--#{type.to_s.gsub(/(installed|outdated)_/, "")}"
// 374:           if options.key?(opt)
// 375:             desc = options[opt]
// 376:
// 377:             if desc.blank?
// 378:               args_options << opt
// 379:             else
// 380:               conflicts = generate_zsh_option_exclusions(command, opt)
// 381:               args_options << "#{conflicts}#{opt}[#{format_description desc}]"
// 382:             end
// 383:
// 384:             options.delete(opt)
// 385:           end
// 386:           args_options << "*:#{type}:#{ZSH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING[type]}"
// 387:         end
// 388:
// 389:         if named_args_strings.any?
// 390:           args_options << "- subcommand"
// 391:           args_options << "*:subcommand:(#{named_args_strings.join(" ")})"
// 392:         end
// 393:       end
// 394:
// 395:       options = options.sort.map do |opt, desc|
// 396:         next opt if desc.blank?
// 397:
// 398:         conflicts = generate_zsh_option_exclusions(command, opt)
// 399:         "#{conflicts}#{opt}[#{format_description desc}]"
// 400:       end
// 401:       options += args_options
// 402:
// 403:       options
// 404:     end
// 405:
// 406:     sig { params(command: String, subcommands: T::Array[Homebrew::CLI::Parser::Subcommand]).returns(String) }
// 407:     def self.generate_zsh_nested_subcommand_completion(command, subcommands)
// 408:       top_level_arguments = generate_zsh_arguments(
// 409:         command,
// 410:         command_options(command),
// 411:         nil,
// 412:       ).map { |opt| format_zsh_argument(opt) } + [
// 413:         "'1:subcommand:->subcommand'",
// 414:         "'*::arg:->args'",
// 415:       ]
// 416:       subcommand_descriptions = subcommands.flat_map do |subcommand|
// 417:         description = subcommand.description
// 418:         ([subcommand.name] + subcommand.aliases).map do |subcommand_name|
// 419:           if description.present?
// 420:             "'#{subcommand_name}:#{format_description(description)}'"
// 421:           else
// 422:             "'#{subcommand_name}'"
// 423:           end
// 424:         end
// 425:       end.join("\n    ")
// 426:
// 427:       subcommand_cases = subcommands.map do |subcommand|
// 428:         names = ([subcommand.name] + subcommand.aliases).join("|")
// 429:         options = generate_zsh_arguments(
// 430:           command,
// 431:           command_options(command, subcommand: subcommand.name),
// 432:           Commands.named_args_type(command, subcommand: subcommand.name),
// 433:         )
// 434:         <<~EOS
// 435:           #{names})
// 436:                   _arguments \\
// 437:                     #{options.map! { |opt| format_zsh_argument(opt) }.join(" \\\n          ")}
// 438:                   ;;
// 439:         EOS
// 440:       end.join
// 441:
// 442:       <<~COMPLETION
// 443:         # brew #{command}
// 444:         _brew_#{Commands.method_name command}() {
// 445:           local state
// 446:           local -a subcommands
// 447:           subcommands=(
// 448:             #{subcommand_descriptions}
// 449:           )
// 450:
// 451:           _arguments -C \\
// 452:             #{top_level_arguments.join(" \\\n    ")}
// 453:
// 454:           case "$state" in
// 455:             subcommand)
// 456:               _describe -t subcommands 'subcommand' subcommands
// 457:               ;;
// 458:             args)
// 459:               case "$words[1]" in
// 460:         #{subcommand_cases.chomp}
// 461:                 *) ;;
// 462:               esac
// 463:               ;;
// 464:           esac
// 465:         }
// 466:       COMPLETION
// 467:     end
// 468:
// 469:     sig { params(command: String, option: String).returns(String) }
// 470:     def self.generate_zsh_option_exclusions(command, option)
// 471:       conflicts = Commands.option_conflicts(command, option.gsub(/^--?/, ""))
// 472:       return "" if conflicts.blank?
// 473:
// 474:       "(#{conflicts.map { |conflict| "-#{"-" if conflict.size > 1}#{conflict}" }.join(" ")})"
// 475:     end
// 476:
// 477:     sig { params(commands: T::Array[String]).returns(String) }
// 478:     def self.generate_zsh_completion_file(commands)
// 479:       commands -= Commands.internal_commands_aliases
// 480:
// 481:       variables = Variables.new(
// 482:         aliases:                      Commands::HOMEBREW_INTERNAL_COMMAND_ALIASES.filter_map do |alias_cmd, command|
// 483:           alias_cmd = "'#{alias_cmd}'" if alias_cmd.start_with? "-"
// 484:           command = "'#{command}'" if command.start_with? "-"
// 485:           "#{alias_cmd} #{command}"
// 486:         end,
// 487:
// 488:         builtin_command_descriptions: commands.filter_map do |command|
// 489:           next if Commands::HOMEBREW_INTERNAL_COMMAND_ALIASES.key? command
// 490:           next if command_hidden_from_manpage?(command)
// 491:
// 492:           zsh_command_description(command)
// 493:         end,
// 494:
// 495:         maintainer_descriptions:      commands.filter_map do |command|
// 496:           next unless command_hidden_from_manpage?(command)
// 497:
// 498:           zsh_command_description(command)
// 499:         end,
// 500:
// 501:         completion_functions:         commands.filter_map do |command|
// 502:           generate_zsh_subcommand_completion command
// 503:         end,
// 504:       )
// 505:
// 506:       ERB.new((TEMPLATE_DIR/"zsh.erb").read, trim_mode: ">").result(variables.instance_eval { binding })
// 507:     end
// 508:
// 509:     sig { params(command: String).returns(T.nilable(String)) }
// 510:     def self.generate_fish_subcommand_completion(command)
// 511:       command_description = format_description Commands.command_description(command, short: true).to_s, fish: true
// 512:       lines = if COMPLETIONS_EXCLUSION_LIST.include?(command) ||
// 513:                  Commands::HOMEBREW_INTERNAL_COMMAND_ALIASES.key?(command)
// 514:         []
// 515:       elsif command_hidden_from_manpage?(command)
// 516:         ["complete -f -c brew -n 'not __fish_brew_command; and set -q HOMEBREW_DEVELOPER' " \
// 517:          "-a '#{command}' -d '#{command_description}'"]
// 518:       else
// 519:         ["__fish_brew_complete_cmd '#{command}' '#{command_description}'"]
// 520:       end
// 521:       return unless command_gets_completions? command
// 522:
// 523:       subcommands = Commands.command_subcommands(command)
// 524:       return generate_fish_nested_subcommand_completion(command, subcommands) if subcommands.present?
// 525:
// 526:       options = command_options(command).sort.filter_map do |opt, desc|
// 527:         arg_line = "__fish_brew_complete_arg '#{command}' -l #{opt.sub(/^-+/, "")}"
// 528:         arg_line += " -d '#{format_description desc, fish: true}'" if desc.present?
// 529:         arg_line
// 530:       end
// 531:
// 532:       subcommands = []
// 533:       named_args = []
// 534:       if (types = Commands.named_args_type(command))
// 535:         named_args_strings, named_args_types = types.partition { |type| type.is_a? String }
// 536:
// 537:         T.cast(named_args_types, T::Array[Symbol]).each do |type|
// 538:           next unless FISH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING.key? type
// 539:
// 540:           named_arg_function = FISH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING[type]
// 541:           named_arg_prefix = "__fish_brew_complete_arg '#{command}; and not __fish_seen_argument"
// 542:
// 543:           formula_option = command_options(command).key?("--formula")
// 544:           cask_option = command_options(command).key?("--cask")
// 545:
// 546:           named_args << if formula_option && cask_option && type.to_s.end_with?("formula")
// 547:             "#{named_arg_prefix} -l cask -l casks' -a '(#{named_arg_function})'"
// 548:           elsif formula_option && cask_option && type.to_s.end_with?("cask")
// 549:             "#{named_arg_prefix} -l formula -l formulae' -a '(#{named_arg_function})'"
// 550:           else
// 551:             "__fish_brew_complete_arg '#{command}' -a '(#{named_arg_function})'"
// 552:           end
// 553:         end
// 554:
// 555:         named_args_strings.each do |subcommand|
// 556:           subcommands << "__fish_brew_complete_sub_cmd '#{command}' '#{subcommand}'"
// 557:         end
// 558:       end
// 559:
// 560:       lines += subcommands + options + named_args
// 561:       <<~COMPLETION
// 562:         #{lines.join("\n").chomp}
// 563:       COMPLETION
// 564:     end
// 565:
// 566:     sig {
// 567:       params(command: String, types: T.nilable(T::Array[T.any(Symbol, String)]),
// 568:              subcommand: T.nilable(String)).returns(T::Array[String])
// 569:     }
// 570:     def self.generate_fish_named_args(command, types, subcommand: nil)
// 571:       named_args = []
// 572:       return named_args if types.blank?
// 573:
// 574:       named_args_strings, named_args_types = types.partition { |type| type.is_a? String }
// 575:
// 576:       T.cast(named_args_types, T::Array[Symbol]).each do |type|
// 577:         next unless FISH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING.key? type
// 578:
// 579:         named_arg_function = FISH_NAMED_ARGS_COMPLETION_FUNCTION_MAPPING[type]
// 580:         if subcommand
// 581:           named_args << "__fish_brew_complete_sub_arg '#{command}' '#{subcommand}' -a '(#{named_arg_function})'"
// 582:           next
// 583:         end
// 584:
// 585:         named_arg_prefix = "__fish_brew_complete_arg '#{command}; and not __fish_seen_argument"
// 586:
// 587:         formula_option = command_options(command).key?("--formula")
// 588:         cask_option = command_options(command).key?("--cask")
// 589:
// 590:         named_args << if formula_option && cask_option && type.to_s.end_with?("formula")
// 591:           "#{named_arg_prefix} -l cask -l casks' -a '(#{named_arg_function})'"
// 592:         elsif formula_option && cask_option && type.to_s.end_with?("cask")
// 593:           "#{named_arg_prefix} -l formula -l formulae' -a '(#{named_arg_function})'"
// 594:         else
// 595:           "__fish_brew_complete_arg '#{command}' -a '(#{named_arg_function})'"
// 596:         end
// 597:       end
// 598:
// 599:       return named_args if subcommand
// 600:
// 601:       named_args_strings.map do |named_arg_string|
// 602:         "__fish_brew_complete_sub_cmd '#{command}' '#{named_arg_string}'"
// 603:       end + named_args
// 604:     end
// 605:
// 606:     sig { params(command: String, subcommands: T::Array[Homebrew::CLI::Parser::Subcommand]).returns(String) }
// 607:     def self.generate_fish_nested_subcommand_completion(command, subcommands)
// 608:       command_description = format_description Commands.command_description(command, short: true).to_s, fish: true
// 609:       lines = if COMPLETIONS_EXCLUSION_LIST.include?(command) ||
// 610:                  Commands::HOMEBREW_INTERNAL_COMMAND_ALIASES.key?(command)
// 611:         []
// 612:       else
// 613:         ["__fish_brew_complete_cmd '#{command}' '#{command_description}'"]
// 614:       end
// 615:
// 616:       subcommands.each do |subcommand|
// 617:         description = subcommand.description
// 618:         ([subcommand.name] + subcommand.aliases).each do |subcommand_name|
// 619:           line = "__fish_brew_complete_sub_cmd '#{command}' '#{subcommand_name}'"
// 620:           line += " '#{format_description(description, fish: true)}'" if description.present?
// 621:           lines << line
// 622:         end
// 623:       end
// 624:
// 625:       lines += command_options(command).sort.filter_map do |opt, desc|
// 626:         arg_line = "__fish_brew_complete_arg '#{command}; and [ (count (__fish_brew_args)) = 1 ]' " \
// 627:                    "-l #{opt.sub(/^-+/, "")}"
// 628:         arg_line += " -d '#{format_description desc, fish: true}'" if desc.present?
// 629:         arg_line
// 630:       end
// 631:
// 632:       subcommands.each do |subcommand|
// 633:         subcommand_names = ([subcommand.name] + subcommand.aliases).join(" ")
// 634:         lines += command_options(command, subcommand: subcommand.name).sort.filter_map do |opt, desc|
// 635:           arg_line = "__fish_brew_complete_sub_arg '#{command}' '#{subcommand_names}' " \
// 636:                      "-l #{opt.sub(/^-+/, "")}"
// 637:           arg_line += " -d '#{format_description desc, fish: true}'" if desc.present?
// 638:           arg_line
// 639:         end
// 640:         lines += generate_fish_named_args(
// 641:           command,
// 642:           Commands.named_args_type(command, subcommand: subcommand.name),
// 643:           subcommand: subcommand_names,
// 644:         )
// 645:       end
// 646:
// 647:       <<~COMPLETION
// 648:         #{lines.join("\n").chomp}
// 649:       COMPLETION
// 650:     end
// 651:
// 652:     sig { params(commands: T::Array[String]).returns(String) }
// 653:     def self.generate_fish_completion_file(commands)
// 654:       commands -= Commands.internal_commands_aliases
// 655:
// 656:       variables = Variables.new(
// 657:         aliases:              Commands::HOMEBREW_INTERNAL_COMMAND_ALIASES.map do |alias_cmd, command|
// 658:           "        case '#{alias_cmd}'\n            echo '#{command}'"
// 659:         end,
// 660:         completion_functions: commands.filter_map do |command|
// 661:           generate_fish_subcommand_completion command
// 662:         end,
// 663:       )
// 664:
// 665:       ERB.new((TEMPLATE_DIR/"fish.erb").read, trim_mode: ">").result(variables.instance_eval { binding })
// 666:     end
// 667:   end
// 668: end
