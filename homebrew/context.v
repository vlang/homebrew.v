module homebrew

import ruby

// Translated from Homebrew/brew `context.rb`.
pub struct ExecutionContext {
pub:
	debug                          ?bool
	quiet                          ?bool
	verbose                        ?bool
	deferred_environment_expansion ?bool
}

pub fn (context ExecutionContext) debug_enabled() bool {
	return context.debug or { false }
}

pub fn (context ExecutionContext) quiet_enabled() bool {
	return context.quiet or { false }
}

pub fn (context ExecutionContext) verbose_enabled() bool {
	return context.verbose or { false }
}

pub fn (context ExecutionContext) deferred_environment_expansion_enabled() bool {
	return context.deferred_environment_expansion or { false }
}

@[heap]
pub struct ContextState {
pub mut:
	current         ExecutionContext
	has_current     bool
	thread_contexts []ExecutionContext
}

pub fn new_context_state() &ContextState {
	return &ContextState{}
}

pub fn (mut state ContextState) set_current(context ExecutionContext) {
	state.current = context
	state.has_current = true
}

pub fn (mut state ContextState) current_context() ExecutionContext {
	if state.thread_contexts.len > 0 {
		return state.thread_contexts.last()
	}
	if !state.has_current {
		state.current = ExecutionContext{}
		state.has_current = true
	}
	return state.current
}

pub fn (mut state ContextState) debug_enabled() bool {
	return state.current_context().debug_enabled()
}

pub fn (mut state ContextState) quiet_enabled() bool {
	return state.current_context().quiet_enabled()
}

pub fn (mut state ContextState) verbose_enabled() bool {
	return state.current_context().verbose_enabled()
}

pub fn (mut state ContextState) deferred_environment_expansion_enabled() bool {
	return state.current_context().deferred_environment_expansion_enabled()
}

pub fn (mut state ContextState) with_context(context ExecutionContext,
	action fn (mut ContextState) !ruby.Value) !ruby.Value {
	state.thread_contexts << context
	defer {
		state.thread_contexts.delete_last()
	}
	return action(mut state)
}

fn execution_context_value(context ExecutionContext) ruby.Value {
	return ruby.structured_value('Context::ContextStruct', '', {
		'debug':                          context.debug_enabled().str()
		'quiet':                          context.quiet_enabled().str()
		'verbose':                        context.verbose_enabled().str()
		'deferred_environment_expansion': context.deferred_environment_expansion_enabled().str()
		'debug_nil':                      (context.debug == none).str()
		'quiet_nil':                      (context.quiet == none).str()
		'verbose_nil':                    (context.verbose == none).str()
		'deferred_nil':                   (context.deferred_environment_expansion == none).str()
	})
}

fn execution_context_bool(value ruby.Value, nil_attribute string, attribute string) ?bool {
	if value.attributes[nil_attribute] == 'true' {
		return none
	}
	return value.attributes[attribute] == 'true'
}

fn execution_context_from_value(value ruby.Value) ExecutionContext {
	if value.type_name == 'Hash' {
		return ExecutionContext{
			debug: context_map_bool(value, 'debug')
			quiet: context_map_bool(value, 'quiet')
			verbose: context_map_bool(value, 'verbose')
			deferred_environment_expansion: context_map_bool(value, 'deferred_environment_expansion')
		}
	}
	return ExecutionContext{
		debug: execution_context_bool(value, 'debug_nil', 'debug')
		quiet: execution_context_bool(value, 'quiet_nil', 'quiet')
		verbose: execution_context_bool(value, 'verbose_nil', 'verbose')
		deferred_environment_expansion: execution_context_bool(value, 'deferred_nil', 'deferred_environment_expansion')
	}
}

fn context_map_bool(value ruby.Value, key string) ?bool {
	item := value.map_data[key] or { return none }
	if item.type_name == 'NilClass' {
		return none
	}
	return item.bool_data
}

fn context_state_value(state &ContextState) ruby.Value {
	return ruby.structured_value('Context::Runtime', '', {
		'context_state_address': u64(voidptr(state)).str()
	})
}

fn context_state_from_value(value ruby.Value) &ContextState {
	return unsafe { &ContextState(voidptr(value.attributes['context_state_address'].u64())) }
}

pub fn context_state_boundary(state &ContextState) ruby.Value {
	return context_state_value(state)
}

fn context_state_and_offset(args []ruby.Value) (&ContextState, int) {
	if args.len > 0 && 'context_state_address' in args[0].attributes {
		return context_state_from_value(args[0]), 1
	}
	return new_context_state(), 0
}

fn context_from_positional(args []ruby.Value, offset int) ExecutionContext {
	mut values := []?bool{}
	for index in 0 .. 4 {
		position := offset + index
		values << if position >= args.len || args[position].type_name == 'NilClass' {
			none
		} else {
			args[position].bool_data
		}
	}
	return ExecutionContext{
		debug: values[0]
		quiet: values[1]
		verbose: values[2]
		deferred_environment_expansion: values[3]
	}
}

fn context_override(value ?bool, fallback ?bool) ?bool {
	if override := value {
		return override
	}
	return fallback
}
