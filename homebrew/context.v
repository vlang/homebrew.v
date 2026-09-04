module homebrew

import ruby

// Translated from Homebrew/brew `context.rb`.
// The original source is retained below until every stub has a typed V body.
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
	action fn(mut ContextState) !ruby.Value) !ruby.Value {
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

// Ruby method `initialize(debug: nil, quiet: nil, verbose: nil, deferred_environment_expansion: nil)` at line 20.
pub fn ruby_context_l20_d1_initialize(args ...ruby.Value) ruby.Value {
	context := if args.len > 0 && args[0].type_name == 'Hash' {
		execution_context_from_value(args[0])
	} else {
		context_from_positional(args, 0)
	}
	return execution_context_value(context)
}

// Ruby method `debug?` at line 28.
pub fn ruby_context_l28_d2_debug(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && execution_context_from_value(args[0]).debug_enabled())
}

// Ruby method `quiet?` at line 33.
pub fn ruby_context_l33_d3_quiet(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && execution_context_from_value(args[0]).quiet_enabled())
}

// Ruby method `verbose?` at line 38.
pub fn ruby_context_l38_d4_verbose(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && execution_context_from_value(args[0]).verbose_enabled())
}

// Ruby method `deferred_environment_expansion?` at line 43.
pub fn ruby_context_l43_d5_deferred_environment_expansion(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && execution_context_from_value(args[0]).deferred_environment_expansion_enabled())
}

// Ruby method `self.current=(context)` at line 51.
pub fn ruby_context_l51_d6_self_current(args ...ruby.Value) ruby.Value {
	mut state, offset := context_state_and_offset(args)
	if args.len <= offset {
		return ruby.object_value('ArgumentError', 'context is required')
	}
	context := execution_context_from_value(args[offset])
	state.set_current(context)
	return execution_context_value(context)
}

// Ruby method `self.current` at line 58.
pub fn ruby_context_l58_d7_self_current(args ...ruby.Value) ruby.Value {
	mut state, _ := context_state_and_offset(args)
	return execution_context_value(state.current_context())
}

// Ruby method `debug?` at line 71.
pub fn ruby_context_l71_d8_debug(args ...ruby.Value) ruby.Value {
	mut state, _ := context_state_and_offset(args)
	return ruby.bool_value(state.debug_enabled())
}

// Ruby method `quiet?` at line 76.
pub fn ruby_context_l76_d9_quiet(args ...ruby.Value) ruby.Value {
	mut state, _ := context_state_and_offset(args)
	return ruby.bool_value(state.quiet_enabled())
}

// Ruby method `verbose?` at line 81.
pub fn ruby_context_l81_d10_verbose(args ...ruby.Value) ruby.Value {
	mut state, _ := context_state_and_offset(args)
	return ruby.bool_value(state.verbose_enabled())
}

// Ruby method `deferred_environment_expansion?` at line 86.
pub fn ruby_context_l86_d11_deferred_environment_expansion(args ...ruby.Value) ruby.Value {
	mut state, _ := context_state_and_offset(args)
	return ruby.bool_value(state.deferred_environment_expansion_enabled())
}

// Ruby method `with_context(debug: debug?, quiet: quiet?, verbose: verbose?,` at line 99.
pub fn ruby_context_l99_d12_with_context(args ...ruby.Value) ruby.Value {
	mut state, offset := context_state_and_offset(args)
	old := state.current_context()
	overrides := if args.len > offset && args[offset].type_name == 'Hash' {
		execution_context_from_value(args[offset])
	} else {
		context_from_positional(args, offset)
	}
	context := ExecutionContext{
		debug: context_override(overrides.debug, old.debug)
		quiet: context_override(overrides.quiet, old.quiet)
		verbose: context_override(overrides.verbose, old.verbose)
		deferred_environment_expansion: context_override(overrides.deferred_environment_expansion, old.deferred_environment_expansion)
	}
	state.thread_contexts << context
	result_position := if args.len > offset && args[offset].type_name == 'Hash' {
		offset + 1
	} else {
		offset + 4
	}
	result := if args.len > result_position {
		args[result_position]
	} else {
		execution_context_value(state.current_context())
	}
	state.thread_contexts.delete_last()
	return result
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "monitor"
// 5:
// 6: # Module for querying the current execution context.
// 7: module Context
// 8:   extend MonitorMixin
// 9:
// 10:   # Struct describing the current execution context.
// 11:   class ContextStruct
// 12:     sig {
// 13:       params(
// 14:         debug:                          T.nilable(T::Boolean),
// 15:         quiet:                          T.nilable(T::Boolean),
// 16:         verbose:                        T.nilable(T::Boolean),
// 17:         deferred_environment_expansion: T.nilable(T::Boolean),
// 18:       ).void
// 19:     }
// 20:     def initialize(debug: nil, quiet: nil, verbose: nil, deferred_environment_expansion: nil)
// 21:       @debug = debug
// 22:       @quiet = quiet
// 23:       @verbose = verbose
// 24:       @deferred_environment_expansion = deferred_environment_expansion
// 25:     end
// 26:
// 27:     sig { returns(T::Boolean) }
// 28:     def debug?
// 29:       @debug == true
// 30:     end
// 31:
// 32:     sig { returns(T::Boolean) }
// 33:     def quiet?
// 34:       @quiet == true
// 35:     end
// 36:
// 37:     sig { returns(T::Boolean) }
// 38:     def verbose?
// 39:       @verbose == true
// 40:     end
// 41:
// 42:     sig { returns(T::Boolean) }
// 43:     def deferred_environment_expansion?
// 44:       @deferred_environment_expansion == true
// 45:     end
// 46:   end
// 47:
// 48:   @current = T.let(nil, T.nilable(ContextStruct))
// 49:
// 50:   sig { params(context: ContextStruct).void }
// 51:   def self.current=(context)
// 52:     synchronize do
// 53:       @current = context
// 54:     end
// 55:   end
// 56:
// 57:   sig { returns(ContextStruct) }
// 58:   def self.current
// 59:     current_context = T.cast(Thread.current[:context], T.nilable(ContextStruct))
// 60:     return current_context if current_context
// 61:
// 62:     synchronize do
// 63:       current = T.let(@current, T.nilable(ContextStruct))
// 64:       current ||= ContextStruct.new
// 65:       @current = current
// 66:       current
// 67:     end
// 68:   end
// 69:
// 70:   sig { returns(T::Boolean) }
// 71:   def debug?
// 72:     Context.current.debug?
// 73:   end
// 74:
// 75:   sig { returns(T::Boolean) }
// 76:   def quiet?
// 77:     Context.current.quiet?
// 78:   end
// 79:
// 80:   sig { returns(T::Boolean) }
// 81:   def verbose?
// 82:     Context.current.verbose?
// 83:   end
// 84:
// 85:   sig { returns(T::Boolean) }
// 86:   def deferred_environment_expansion?
// 87:     Context.current.deferred_environment_expansion?
// 88:   end
// 89:
// 90:   sig {
// 91:     params(
// 92:       debug:                          T.nilable(T::Boolean),
// 93:       quiet:                          T.nilable(T::Boolean),
// 94:       verbose:                        T.nilable(T::Boolean),
// 95:       deferred_environment_expansion: T.nilable(T::Boolean),
// 96:       _block:                         T.proc.void,
// 97:     ).returns(T.untyped)
// 98:   }
// 99:   def with_context(debug: debug?, quiet: quiet?, verbose: verbose?,
// 100:                    deferred_environment_expansion: deferred_environment_expansion?, &_block)
// 101:     old_context = Context.current
// 102:     Thread.current[:context] = ContextStruct.new(debug:, quiet:, verbose:, deferred_environment_expansion:)
// 103:
// 104:     begin
// 105:       yield
// 106:     ensure
// 107:       Thread.current[:context] = old_context
// 108:     end
// 109:   end
// 110: end
