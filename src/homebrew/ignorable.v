module homebrew

import brew_runtime

// Translated from Homebrew/brew `ignorable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.hook_raise(on_ignorable:, &block)` at line 20.
pub fn ruby_ignorable_l20_d1_self_hook_raise(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.hook_raise', ...args)
}

// Ruby define_method `define_method(:raise) do |*args, **kwargs|` at line 25.
pub fn ruby_ignorable_l25_d2_raise(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raise', ...args)
}

// Ruby alias_method `alias_method :fail, :raise` at line 37.
pub fn ruby_ignorable_l37_d3_fail(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fail', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Provides the ability to optionally ignore errors raised and continue execution.
// 5: module Ignorable
// 6:   # Marks exceptions which can be ignored and resumed from where they were raised.
// 7:   module ExceptionMixin; end
// 8:
// 9:   # Runs the block in a Fiber whose `raise` pauses at the raise site and passes
// 10:   # the exception to `on_ignorable`. If it returns `:ignore`, execution resumes
// 11:   # after the raise site, otherwise the exception is raised there as usual.
// 12:   sig {
// 13:     type_parameters(:U)
// 14:       .params(
// 15:         on_ignorable: T.proc.params(exception: Exception).returns(Symbol),
// 16:         block:        T.proc.returns(T.type_parameter(:U)),
// 17:       )
// 18:       .returns(T.type_parameter(:U))
// 19:   }
// 20:   def self.hook_raise(on_ignorable:, &block)
// 21:     fiber = Fiber.new(&block)
// 22:
// 23:     Object.class_eval do
// 24:       # `define_method` keeps Sorbet happy inside this `class_eval` block.
// 25:       define_method(:raise) do |*args, **kwargs|
// 26:         super(*args, **kwargs)
// 27:       # All possible exceptions must be pausable, not just `StandardError`.
// 28:       rescue Exception => e # rubocop:disable Lint/RescueException
// 29:         if e.is_a?(ScriptError) || Fiber.current != fiber
// 30:           super(e)
// 31:         else
// 32:           e.extend(ExceptionMixin)
// 33:           super(e) if Fiber.yield(e) != :ignore
// 34:         end
// 35:       end
// 36:
// 37:       alias_method :fail, :raise
// 38:     end
// 39:
// 40:     result = fiber.resume
// 41:     while fiber.alive?
// 42:       decision = begin
// 43:         on_ignorable.call(result)
// 44:       # Even `Interrupt` at the prompt must unwind the fiber, not abandon it.
// 45:       rescue Exception => e # rubocop:disable Lint/RescueException
// 46:         e
// 47:       end
// 48:
// 49:       result = case decision
// 50:       when :ignore then fiber.resume(:ignore)
// 51:       # Raise inside the fiber so its `ensure` blocks and rescues still run.
// 52:       when Exception then fiber.raise(decision)
// 53:       else fiber.resume(:raise)
// 54:       end
// 55:     end
// 56:     result
// 57:   ensure
// 58:     Object.class_eval do
// 59:       remove_method(:raise)
// 60:       remove_method(:fail)
// 61:     end
// 62:   end
// 63: end
