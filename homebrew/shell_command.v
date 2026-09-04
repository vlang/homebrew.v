module homebrew

// Translated from Homebrew/brew `shell_command.rb`.

// shell_command_error preserves the deliberate failure used by command classes
// that only exist so shell completions can discover them.
pub fn shell_command_error(command_name string, dev_cmd bool) IError {
	directory := if dev_cmd { 'dev-cmd' } else { 'cmd' }
	path := '${directory}/${command_name}.sh'
	return error("This command is just here for completions generation. It's actually defined in `${path}` instead.")
}
