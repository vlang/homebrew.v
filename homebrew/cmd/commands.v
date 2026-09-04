module cmd

import homebrew.utils

// Translated from Homebrew/brew `cmd/commands.rb`.
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
