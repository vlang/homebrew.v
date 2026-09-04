module utils

import ruby

// Translated from Homebrew/brew `utils/user.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct User {
pub:
	name string
}

pub fn current_user() ?User {
	name := ruby.current_username()
	if name == '' {
		return none
	}
	return User{
		name: name
	}
}

pub fn (user User) gui_from_who_output(output string, command_succeeded bool) bool {
	if !command_succeeded {
		return false
	}
	for line in output.split_into_lines() {
		fields := line.fields()
		if fields.len >= 2 && fields[0] == user.name && fields[1] == 'console' {
			return true
		}
	}
	return false
}

pub fn (user User) gui() bool {
	who := ruby.find_executable('who') or { return false }
	result := ruby.run_command(who, [])
	return user.gui_from_who_output(result.output, result.exit_code == 0)
}

pub fn (user User) str() string {
	return user.name
}

// Ruby method `gui?` at line 15.
pub fn ruby_user_l15_d1_gui(args ...ruby.Value) ruby.Value {
	user := if args.len > 0 {
		User{
			name: args[0].as_string()
		}
	} else {
		current_user() or { return ruby.bool_value(false) }
	}
	if args.len > 1 {
		return ruby.bool_value(user.gui_from_who_output(args[1].as_string(), if args.len > 2 { args[2].as_bool() or {
				false} } else { true }))
	}
	return ruby.bool_value(user.gui())
}

// Ruby method `self.current` at line 26.
pub fn ruby_user_l26_d2_self_current(args ...ruby.Value) ruby.Value {
	if user := current_user() {
		return ruby.object_value('User', user.name)
	}
	return ruby.object_value('NilClass', '')
}

// Ruby method `to_s = __getobj__.to_s` at line 37.
pub fn ruby_user_l37_d3_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(if args.len > 0 { args[0].as_string() } else { '' })
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "delegate"
// 5: require "etc"
// 6:
// 7: require "system_command"
// 8:
// 9: # A system user.
// 10: class User < SimpleDelegator
// 11:   include SystemCommand::Mixin
// 12:
// 13:   # Return whether the user has an active GUI session.
// 14:   sig { returns(T::Boolean) }
// 15:   def gui?
// 16:     out, _, status = system_command("who").to_a
// 17:     return false unless status.success?
// 18:
// 19:     out.lines
// 20:        .map(&:split)
// 21:        .any? { |user, type,| to_s == user && type == "console" }
// 22:   end
// 23:
// 24:   # Return the current user.
// 25:   sig { returns(T.nilable(T.attached_class)) }
// 26:   def self.current
// 27:     return @current if defined?(@current)
// 28:
// 29:     pwuid = Etc.getpwuid(Process.euid)
// 30:     return if pwuid.nil?
// 31:
// 32:     @current = T.let(new(pwuid.name), T.nilable(T.attached_class))
// 33:   end
// 34:
// 35:   # This explicit delegator exists to make to_s visible to sorbet.
// 36:   sig { returns(String) }
// 37:   def to_s = __getobj__.to_s
// 38: end
