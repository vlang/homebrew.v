module cmd

import ruby

// Translated from Homebrew/brew `cmd/command-not-found-init.rb`.

pub struct CommandNotFoundInitOptions {
pub:
	stdout_tty      bool
	parent_shell    string
	preferred_shell string
	handler_sh      string
	handler_fish    string
}

pub struct CommandNotFoundInitResult {
pub:
	shell  string
	mode   string
	stdout string
}

pub fn command_not_found_shell(parent_shell string, preferred_shell string) string {
	return if parent_shell.len > 0 { parent_shell } else { preferred_shell }
}

pub fn command_not_found_init_output(shell string, handler_sh string, handler_fish string) !string {
	return match shell {
		'bash', 'zsh' {
			if handler_sh.ends_with('\n') { handler_sh } else { '${handler_sh}\n' }
		}
		'fish' {
			if handler_fish.ends_with('\n') { handler_fish } else { '${handler_fish}\n' }
		}
		else {
			return error('Unsupported shell type ${shell}')
		}
	}
}

pub fn command_not_found_help_output(shell string) !string {
	return match shell {
		'bash', 'zsh' {
			'# To enable command-not-found\n# Add the following lines to ~/.${shell}rc\n\nHOMEBREW_COMMAND_NOT_FOUND_HANDLER="\$(brew --repository)/Library/Homebrew/command-not-found/handler.sh"\nif [ -f "\$HOMEBREW_COMMAND_NOT_FOUND_HANDLER" ]; then\n  source "\$HOMEBREW_COMMAND_NOT_FOUND_HANDLER";\nfi\n'
		}
		'fish' {
			'# To enable command-not-found\n# Add the following line to ~/.config/fish/config.fish\n\nset HOMEBREW_COMMAND_NOT_FOUND_HANDLER (brew --repository)/Library/Homebrew/command-not-found/handler.fish\nif test -f \$HOMEBREW_COMMAND_NOT_FOUND_HANDLER\n  source \$HOMEBREW_COMMAND_NOT_FOUND_HANDLER\nend\n'
		}
		else {
			return error('Unsupported shell type ${shell}')
		}
	}
}

pub fn run_command_not_found_init(options CommandNotFoundInitOptions) !CommandNotFoundInitResult {
	shell := command_not_found_shell(options.parent_shell, options.preferred_shell)
	if options.stdout_tty {
		return CommandNotFoundInitResult{
			shell: shell
			mode: 'help'
			stdout: command_not_found_help_output(shell)!
		}
	}
	return CommandNotFoundInitResult{
		shell: shell
		mode: 'init'
		stdout: command_not_found_init_output(shell, options.handler_sh, options.handler_fish)!
	}
}

@[heap]
pub struct CommandNotFoundInitInput {
pub:
	options CommandNotFoundInitOptions
}

pub fn command_not_found_init_input_boundary(input &CommandNotFoundInitInput) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::CommandNotFoundInit::Input', '', {
		'command_not_found_init_input_address': u64(voidptr(input)).str()
	})
}

fn command_not_found_init_input_from_value(value ruby.Value) &CommandNotFoundInitInput {
	address := value.attributes['command_not_found_init_input_address'] or {
		panic('invalid CommandNotFoundInit input')
	}
	return unsafe { &CommandNotFoundInitInput(voidptr(address.u64())) }
}

fn command_not_found_init_result_value(result CommandNotFoundInitResult) ruby.Value {
	return ruby.map_value({
		'shell':  ruby.object_value('Symbol', result.shell)
		'mode':   ruby.object_value('Symbol', result.mode)
		'stdout': ruby.string_value(result.stdout)
	})
}
