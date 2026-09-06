module dsl

import ruby

// Translated from Homebrew/brew `cask/dsl/base.rb`.
@[heap]
pub struct BaseCask {
pub:
	token          string
	version        string
	caskroom_path  string
	staged_path    string
	appdir         string
	language       string
	arch           string
	representation string
}

pub struct BaseCommandInvocation {
pub:
	executable string
	options    map[string]ruby.Value
}

@[heap]
pub struct BaseCommand {
pub:
	result ruby.Value
pub mut:
	invocations []BaseCommandInvocation
}

@[heap]
pub struct Base {
pub:
	cask    &BaseCask
	command &BaseCommand
}

pub fn new_base(cask &BaseCask, command &BaseCommand) &Base {
	return &Base{
		cask: cask
		command: command
	}
}

pub fn (base &Base) system_command(executable string,
	options map[string]ruby.Value) ruby.Value {
	mut command := base.command
	command.invocations << BaseCommandInvocation{
		executable: executable
		options: options.clone()
	}
	return command.result
}

pub fn (base &Base) method_missing(method string) ! {
	representation := if base.cask.representation != '' {
		base.cask.representation
	} else {
		base.cask.token
	}
	return error("undefined method '${method.trim_string_left(':')}' for Cask '${representation}'")
}

fn base_value(base &Base) ruby.Value {
	return ruby.structured_value('Cask::DSL::Base', '', {
		'base_address': u64(voidptr(base)).str()
	})
}
