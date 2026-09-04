module homebrew

import ruby

// Translated from Homebrew/brew `ignorable.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum IgnorableDecision {
	ignore
	raise_exception
	handler_exception
}

pub struct IgnorableException {
pub:
	type_name       string
	message         string
	backtrace       []string
	script_error    bool
	external        bool
	handler_message string
}

pub struct IgnorableProgram {
pub:
	exception        ?IgnorableException
	decision         IgnorableDecision
	result           ruby.Value
	rescued_in_block bool
	ensure_block     bool
}

@[heap]
pub struct IgnorableState {
pub mut:
	hook_installed       bool
	ensure_ran           bool
	handler_calls        int
	exception_was_marked bool
	yielded_backtrace    []string
	propagated_backtrace []string
	steps                []string
}

pub fn new_ignorable_state() &IgnorableState {
	return &IgnorableState{}
}

pub fn (mut state IgnorableState) handle_raise(exception IgnorableException,
	decision IgnorableDecision) !bool {
	if exception.external || exception.script_error {
		state.propagated_backtrace = exception.backtrace.clone()
		return error(exception.message)
	}
	state.exception_was_marked = true
	state.handler_calls++
	state.yielded_backtrace = exception.backtrace.clone()
	match decision {
		.ignore {
			return true
		}
		.raise_exception {
			state.propagated_backtrace = exception.backtrace.clone()
			return error(exception.message)
		}
		.handler_exception {
			state.propagated_backtrace = exception.backtrace.clone()
			message := if exception.handler_message != '' {
				exception.handler_message
			} else {
				exception.message
			}
			return error(message)
		}
	}
}

pub fn (mut state IgnorableState) hook_raise(program IgnorableProgram) !ruby.Value {
	state.hook_installed = true
	state.ensure_ran = false
	defer {
		state.hook_installed = false
		if program.ensure_block {
			state.ensure_ran = true
		}
	}
	state.steps << 'before'
	if exception := program.exception {
		resumed := state.handle_raise(exception, program.decision) or {
			if program.rescued_in_block && program.decision == .raise_exception && !exception.external && !exception.script_error {
				return ruby.object_value('Symbol', 'rescued_in_block')
			}
			return err
		}
		if resumed {
			state.steps << 'after'
		}
	}
	return program.result
}

fn ignorable_state_value(state &IgnorableState) ruby.Value {
	return ruby.structured_value('Ignorable::State', '', {
		'ignorable_state_address': u64(voidptr(state)).str()
	})
}

fn ignorable_state_from_value(value ruby.Value) &IgnorableState {
	address := value.attributes['ignorable_state_address'] or { panic('invalid Ignorable state') }
	return unsafe { &IgnorableState(voidptr(address.u64())) }
}

pub fn ignorable_state_boundary(state &IgnorableState) ruby.Value {
	return ignorable_state_value(state)
}

fn ignorable_exception_from_value(value ruby.Value) IgnorableException {
	return IgnorableException{
		type_name: value.attributes['type_name'] or { value.type_name }
		message: value.attributes['message'] or { value.repr }
		backtrace: (value.attributes['backtrace'] or { '' }).split_into_lines()
		script_error: value.attributes['script_error'] == 'true'
		external: value.attributes['external'] == 'true'
		handler_message: value.attributes['handler_message'] or { '' }
	}
}

fn ignorable_decision(value string) IgnorableDecision {
	return match value.trim_string_left(':') {
		'ignore' { .ignore }
		'handler_exception' { .handler_exception }
		else { .raise_exception }
	}
}

fn ignorable_error_value(exception IgnorableException, message string) ruby.Value {
	return ruby.structured_value(exception.type_name, message, {
		'backtrace': exception.backtrace.join('\n')
	})
}

// Ruby method `self.hook_raise(on_ignorable:, &block)` at line 20.
pub fn ruby_ignorable_l20_d1_self_hook_raise(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Ignorable state is required')
	}
	mut state := ignorable_state_from_value(args[0])
	has_exception := args.len > 1 && args[1].type_name != 'NilClass'
	exception := if has_exception {
		ignorable_exception_from_value(args[1])
	} else {
		IgnorableException{}
	}
	program := IgnorableProgram{
		exception: if has_exception { exception } else { none }
		decision: if args.len > 2 {
			ignorable_decision(args[2].as_string())
		} else {
			.raise_exception
		}
		result: if args.len > 3 { args[3] } else { ruby.object_value('NilClass', 'nil') }
		rescued_in_block: args.len > 4 && args[4].bool_data
		ensure_block: args.len > 5 && args[5].bool_data
	}
	return state.hook_raise(program) or { ignorable_error_value(exception, err.msg()) }
}

// Ruby define_method `define_method(:raise) do |*args, **kwargs|` at line 25.
pub fn ruby_ignorable_l25_d2_raise(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'state and exception are required')
	}
	mut state := ignorable_state_from_value(args[0])
	exception := ignorable_exception_from_value(args[1])
	decision := if args.len > 2 {
		ignorable_decision(args[2].as_string())
	} else {
		.raise_exception
	}
	return ruby.bool_value(state.handle_raise(exception, decision) or {
		return ignorable_error_value(exception, err.msg())
	})
}

// Ruby alias_method `alias_method :fail, :raise` at line 37.
pub fn ruby_ignorable_l37_d3_fail(args ...ruby.Value) ruby.Value {
	return ruby_ignorable_l25_d2_raise(...args)
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
