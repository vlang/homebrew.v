module cmd

// Translated from Homebrew/brew `cmd/help.rb`.
pub type HelpOutputRenderer = fn () !string

pub fn help_command_output(render HelpOutputRenderer) !string {
	return render()
}
