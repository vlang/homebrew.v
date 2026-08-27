module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/trace.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `trace_reading(io = STDERR)` at line 6.
pub fn ruby_trace_l6_d1_trace_reading(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trace_reading', ...args)
}

// Ruby method `initialize(io)` at line 24.
pub fn ruby_trace_l24_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `trace(msg)` at line 28.
pub fn ruby_trace_l28_d3_trace(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trace', ...args)
}

// Ruby method `trace_obj(obj_name, val)` at line 32.
pub fn ruby_trace_l32_d4_trace_obj(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trace_obj', ...args)
}

// Ruby method `trace_message # :nodoc:` at line 41.
pub fn ruby_trace_l41_d5_trace_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trace_message', ...args)
}

// Ruby method `turn_on_tracing` at line 48.
pub fn ruby_trace_l48_d6_turn_on_tracing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('turn_on_tracing', ...args)
}

// Ruby alias_method `alias_method :do_read_without_hook, :do_read` at line 50.
pub fn ruby_trace_l50_d7_do_read_without_hook(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read_without_hook', ...args)
}

// Ruby alias_method `alias_method :do_read, :do_read_with_hook` at line 51.
pub fn ruby_trace_l51_d8_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read', ...args)
}

// Ruby method `turn_off_tracing` at line 55.
pub fn ruby_trace_l55_d9_turn_off_tracing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('turn_off_tracing', ...args)
}

// Ruby alias_method `alias_method :do_read, :do_read_without_hook` at line 57.
pub fn ruby_trace_l57_d10_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read', ...args)
}

// Ruby method `do_read_with_hook(io)` at line 66.
pub fn ruby_trace_l66_d11_do_read_with_hook(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read_with_hook', ...args)
}

// Ruby method `do_read_with_hook(io)` at line 79.
pub fn ruby_trace_l79_d12_do_read_with_hook(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read_with_hook', ...args)
}

// Original Ruby source (line-for-line):
// 1: module BinData
// 2:
// 3:   # Turn on trace information when reading a BinData object.
// 4:   # If +block+ is given then the tracing only occurs for that block.
// 5:   # This is useful for debugging a BinData declaration.
// 6:   def trace_reading(io = STDERR)
// 7:     @tracer = Tracer.new(io)
// 8:     [BasePrimitive, Choice].each(&:turn_on_tracing)
// 9:
// 10:     if block_given?
// 11:       begin
// 12:         yield
// 13:       ensure
// 14:         [BasePrimitive, Choice].each(&:turn_off_tracing)
// 15:         @tracer = nil
// 16:       end
// 17:     end
// 18:   end
// 19:
// 20:   # reference to the current tracer
// 21:   @tracer ||= nil
// 22:
// 23:   class Tracer # :nodoc:
// 24:     def initialize(io)
// 25:       @trace_io = io
// 26:     end
// 27:
// 28:     def trace(msg)
// 29:       @trace_io.puts(msg)
// 30:     end
// 31:
// 32:     def trace_obj(obj_name, val)
// 33:       if val.length > 30
// 34:         val = val.slice(0..30) + "..."
// 35:       end
// 36:
// 37:       trace "#{obj_name} => #{val}"
// 38:     end
// 39:   end
// 40:
// 41:   def trace_message # :nodoc:
// 42:     yield @tracer
// 43:   end
// 44:
// 45:   module_function :trace_reading, :trace_message
// 46:
// 47:   module TraceHook
// 48:     def turn_on_tracing
// 49:       if !method_defined? :do_read_without_hook
// 50:         alias_method :do_read_without_hook, :do_read
// 51:         alias_method :do_read, :do_read_with_hook
// 52:       end
// 53:     end
// 54:
// 55:     def turn_off_tracing
// 56:       if method_defined? :do_read_without_hook
// 57:         alias_method :do_read, :do_read_without_hook
// 58:         remove_method :do_read_without_hook
// 59:       end
// 60:     end
// 61:   end
// 62:
// 63:   class BasePrimitive < BinData::Base
// 64:     extend TraceHook
// 65:
// 66:     def do_read_with_hook(io)
// 67:       do_read_without_hook(io)
// 68:
// 69:       BinData.trace_message do |tracer|
// 70:         value_string = _value.inspect
// 71:         tracer.trace_obj(debug_name, value_string)
// 72:       end
// 73:     end
// 74:   end
// 75:
// 76:   class Choice < BinData::Base
// 77:     extend TraceHook
// 78:
// 79:     def do_read_with_hook(io)
// 80:       BinData.trace_message do |tracer|
// 81:         selection_string = eval_parameter(:selection).inspect
// 82:         tracer.trace_obj("#{debug_name}-selection-", selection_string)
// 83:       end
// 84:
// 85:       do_read_without_hook(io)
// 86:     end
// 87:   end
// 88: end
