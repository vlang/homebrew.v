module cmd

import ruby
import homebrew.utils

// Translated from Homebrew/brew `cmd/commands.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CommandsCommandConfig {
pub:
	quiet           bool
	include_aliases bool
	internal        []string
	developer       []string
	external        []string
	aliases         []string
	console_width   int = 80
	stream_is_tty   bool
}

struct CommandsCommandSection {
	title    string
	commands []string
}

fn commands_unique_sorted(values []string) []string {
	mut sorted := values.clone()
	sorted.sort()
	mut unique := []string{cap: sorted.len}
	for value in sorted {
		if unique.len == 0 || unique.last() != value {
			unique << value
		}
	}
	return unique
}

pub fn commands_command_output(config CommandsCommandConfig) string {
	if config.quiet {
		mut commands := config.internal.clone()
		commands << config.developer
		commands << config.external
		if config.include_aliases {
			commands << config.aliases
		}
		return utils.formatter_columns(commands_unique_sorted(commands), config.console_width, config.stream_is_tty, 2, 0)
	}

	mut sections := []string{}
	for section in [
		CommandsCommandSection{ title: 'Built-in commands', commands: config.internal },
		CommandsCommandSection{ title: 'Built-in developer commands', commands: config.developer },
		CommandsCommandSection{ title: 'External commands', commands: config.external },
	] {
		commands := commands_unique_sorted(section.commands)
		if commands.len == 0 {
			continue
		}
		columns := utils.formatter_columns(commands, config.console_width, config.stream_is_tty, 2, 0).trim_right('\n')
		sections << '==> ${section.title}\n${columns}'
	}
	if sections.len == 0 {
		return ''
	}
	return sections.join('\n\n') + '\n'
}

// Ruby method `run` at line 23.
pub fn ruby_commands_l23_d1_run(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 { args[0].map_data } else { map[string]ruby.Value{} }
	quiet := (options['quiet'] or { ruby.bool_value(false) }).as_bool() or { false }
	include_aliases := (options['include_aliases'] or { ruby.bool_value(false) }).as_bool() or {
		false
	}
	internal := if value := options['internal'] {
		value.as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	developer := if value := options['developer'] {
		value.as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	external := if value := options['external'] {
		value.as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	aliases := if value := options['aliases'] {
		value.as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	return ruby.string_value(commands_command_output(CommandsCommandConfig{
		quiet: quiet
		include_aliases: include_aliases
		internal: internal
		developer: developer
		external: external
		aliases: aliases
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class CommandsCmd < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Show lists of built-in and external commands.
// 12:         EOS
// 13:         switch "-q", "--quiet",
// 14:                description: "List only the names of commands without category headers."
// 15:         switch "--include-aliases",
// 16:                depends_on:  "--quiet",
// 17:                description: "Include aliases of internal commands."
// 18:
// 19:         named_args :none
// 20:       end
// 21:
// 22:       sig { override.void }
// 23:       def run
// 24:         if args.quiet?
// 25:           puts Formatter.columns(Commands.commands(aliases: args.include_aliases?))
// 26:           return
// 27:         end
// 28:
// 29:         prepend_separator = T.let(false, T::Boolean)
// 30:
// 31:         {
// 32:           "Built-in commands"           => Commands.internal_commands,
// 33:           "Built-in developer commands" => Commands.internal_developer_commands,
// 34:           "External commands"           => Commands.external_commands,
// 35:         }.each do |title, commands|
// 36:           next if commands.blank?
// 37:
// 38:           puts if prepend_separator
// 39:           ohai title, Formatter.columns(commands)
// 40:
// 41:           prepend_separator ||= true
// 42:         end
// 43:       end
// 44:     end
// 45:   end
// 46: end
