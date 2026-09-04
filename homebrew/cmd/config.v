module cmd

// Translated from Homebrew/brew `cmd/config.rb`.
pub type ConfigOutputRenderer = fn () !string

pub fn config_command_output(render ConfigOutputRenderer) !string {
	return render()
}
