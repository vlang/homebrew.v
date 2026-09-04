module cmd

// Translated from Homebrew/brew `cmd/command.rb`.
pub type CommandPathResolver = fn (string) ?string

pub fn command_paths(commands []string, resolver CommandPathResolver) ![]string {
	mut paths := []string{cap: commands.len}
	for command in commands {
		path := resolver(command) or { return error('Unknown command: brew ${command}') }
		paths << path
	}
	return paths
}
