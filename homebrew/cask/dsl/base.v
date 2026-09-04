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

fn base_cask_value(cask &BaseCask) ruby.Value {
	return ruby.structured_value('Cask::Cask', cask.representation, {
		'base_cask_address': u64(voidptr(cask)).str()
	})
}

fn base_cask_from_value(value ruby.Value) &BaseCask {
	address := value.attributes['base_cask_address'] or { panic('invalid Base cask') }
	return unsafe { &BaseCask(voidptr(address.u64())) }
}

pub fn base_cask_boundary(cask &BaseCask) ruby.Value {
	return base_cask_value(cask)
}

fn base_command_value(command &BaseCommand) ruby.Value {
	return ruby.structured_value('SystemCommand', '', {
		'base_command_address': u64(voidptr(command)).str()
	})
}

fn base_command_from_value(value ruby.Value) &BaseCommand {
	address := value.attributes['base_command_address'] or { panic('invalid Base command') }
	return unsafe { &BaseCommand(voidptr(address.u64())) }
}

pub fn base_command_boundary(command &BaseCommand) ruby.Value {
	return base_command_value(command)
}

fn base_value(base &Base) ruby.Value {
	return ruby.structured_value('Cask::DSL::Base', '', {
		'base_address': u64(voidptr(base)).str()
	})
}

fn base_from_value(value ruby.Value) &Base {
	address := value.attributes['base_address'] or { panic('invalid Cask::DSL::Base') }
	return unsafe { &Base(voidptr(address.u64())) }
}

pub fn base_boundary(base &Base) ruby.Value {
	return base_value(base)
}
