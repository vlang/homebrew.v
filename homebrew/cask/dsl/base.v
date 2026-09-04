module dsl

import ruby

// Translated from Homebrew/brew `cask/dsl/base.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby attr_reader `attr_reader :cask` at line 14.
pub fn ruby_base_l14_d1_cask(args ...ruby.Value) ruby.Value {
	return base_cask_value(base_from_value(args[0]).cask)
}

// Ruby attr_reader `attr_reader :command` at line 17.
pub fn ruby_base_l17_d2_command(args ...ruby.Value) ruby.Value {
	return base_command_value(base_from_value(args[0]).command)
}

// Ruby method `initialize(cask, command = SystemCommand)` at line 20.
pub fn ruby_base_l20_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'cask and command are required')
	}
	return base_value(new_base(base_cask_from_value(args[0]), base_command_from_value(args[1])))
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d4_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value(base_from_value(args[0]).cask.token)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d5_version(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Cask::DSL::Version', base_from_value(args[0]).cask.version)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d6_caskroom_path(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', base_from_value(args[0]).cask.caskroom_path)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d7_staged_path(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', base_from_value(args[0]).cask.staged_path)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d8_appdir(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', base_from_value(args[0]).cask.appdir)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d9_language(args ...ruby.Value) ruby.Value {
	return ruby.string_value(base_from_value(args[0]).cask.language)
}

// Ruby def_delegators `def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch` at line 25.
pub fn ruby_base_l25_d10_arch(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', base_from_value(args[0]).cask.arch)
}

// Ruby method `system_command(executable, **options)` at line 28.
pub fn ruby_base_l28_d11_system_command(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'executable is required')
	}
	options := if args.len > 2 {
		args[2].as_map() or { map[string]ruby.Value{} }
	} else {
		map[string]ruby.Value{}
	}
	return base_from_value(args[0]).system_command(args[1].as_string(), options)
}

// Ruby method `method_missing(method, *_args)` at line 33.
pub fn ruby_base_l33_d12_method_missing(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'method is required')
	}
	base_from_value(args[0]).method_missing(args[1].as_string()) or {
		return ruby.object_value('NoMethodError', err.msg())
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `respond_to_missing?(_method, _include_private = false)` at line 38.
pub fn ruby_base_l38_d13_respond_to_missing(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5:
// 6: module Cask
// 7:   class DSL
// 8:     # Superclass for all stanzas which take a block.
// 9:     class Base
// 10:       extend Forwardable
// 11:       include ::Utils::Path
// 12:
// 13:       sig { returns(Cask) }
// 14:       attr_reader :cask
// 15:
// 16:       sig { returns(T.class_of(SystemCommand)) }
// 17:       attr_reader :command
// 18:
// 19:       sig { params(cask: Cask, command: T.class_of(SystemCommand)).void }
// 20:       def initialize(cask, command = SystemCommand)
// 21:         @cask = cask
// 22:         @command = command
// 23:       end
// 24:
// 25:       def_delegators :@cask, :token, :version, :caskroom_path, :staged_path, :appdir, :language, :arch
// 26:
// 27:       sig { params(executable: String, options: T.untyped).returns(T.nilable(SystemCommand::Result)) }
// 28:       def system_command(executable, **options)
// 29:         @command.run!(executable, **options)
// 30:       end
// 31:
// 32:       sig { params(method: Symbol, _args: T.untyped).returns(T.noreturn) }
// 33:       def method_missing(method, *_args)
// 34:         raise NoMethodError, "undefined method '#{method}' for Cask '#{@cask}'"
// 35:       end
// 36:
// 37:       sig { params(_method: Symbol, _include_private: T::Boolean).returns(T::Boolean) }
// 38:       def respond_to_missing?(_method, _include_private = false)
// 39:         false
// 40:       end
// 41:     end
// 42:   end
// 43: end
