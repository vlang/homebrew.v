module utils

import brew_runtime

// Translated from Homebrew/brew `utils/user.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `gui?` at line 15.
pub fn ruby_user_l15_d1_gui(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gui?', ...args)
}

// Ruby method `self.current` at line 26.
pub fn ruby_user_l26_d2_self_current(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.current', ...args)
}

// Ruby method `to_s = __getobj__.to_s` at line 37.
pub fn ruby_user_l37_d3_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
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
