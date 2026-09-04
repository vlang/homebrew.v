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
