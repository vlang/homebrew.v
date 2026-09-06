module homebrew

import ruby

// Translated from Homebrew/brew `ignorable.rb`.
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

fn ignorable_decision(value string) IgnorableDecision {
	return match value.trim_string_left(':') {
		'ignore' { .ignore }
		'handler_exception' { .handler_exception }
		else { .raise_exception }
	}
}
