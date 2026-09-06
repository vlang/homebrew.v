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

fn context_override(value ?bool, fallback ?bool) ?bool {
	if override := value {
		return override
	}
	return fallback
}
