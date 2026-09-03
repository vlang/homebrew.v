module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/trace.rb`.
// The original source is retained below until every stub has a typed V body.

pub type TraceBlockFn = fn (mut TraceSession) brew_runtime.Value

pub type TraceMessageFn = fn (&Tracer) brew_runtime.Value

pub type TraceReadFn = fn (mut IORead) brew_runtime.Value

@[heap]
pub struct TraceOutput {
mut:
	data string
}

@[heap]
pub struct Tracer {
mut:
	output &TraceOutput
}

@[heap]
pub struct TraceSession {
mut:
	tracer            &Tracer
	primitive_tracing bool
	choice_tracing    bool
	active            bool
}

@[heap]
pub struct TraceBlock {
mut:
	callback TraceBlockFn @[required]
}

@[heap]
pub struct TraceMessageBlock {
mut:
	callback TraceMessageFn @[required]
}

@[heap]
pub struct TraceReadable {
mut:
	debug_name string
	selection  brew_runtime.Value
	value      brew_runtime.Value
	read       TraceReadFn @[required]
}

enum TraceHookKind {
	primitive
	choice
}

@[heap]
pub struct TraceHookState {
mut:
	kind    TraceHookKind
	target  brew_runtime.Value
	session &TraceSession
	active  bool
}

fn trace_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn new_trace_output() &TraceOutput {
	return &TraceOutput{}
}

pub fn (output &TraceOutput) value() string {
	return output.data
}

fn trace_output_value(output &TraceOutput) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'StringIO'
		repr: output.data
		int_data: i64(u64(voidptr(output)))
		attributes: {
			'trace_output_address': u64(voidptr(output)).str()
		}
	}
}

fn trace_output_from_value(value brew_runtime.Value) &TraceOutput {
	if address := value.attributes['trace_output_address'] {
		return unsafe { &TraceOutput(voidptr(address.u64())) }
	}
	return new_trace_output()
}

pub fn new_tracer(output &TraceOutput) &Tracer {
	return &Tracer{
		output: output
	}
}

pub fn tracer_boundary_value(tracer &Tracer) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::Tracer'
		repr: 'BinData::Tracer'
		int_data: i64(u64(voidptr(tracer)))
		attributes: {
			'tracer_address': u64(voidptr(tracer)).str()
		}
	}
}

fn tracer_from_value(value brew_runtime.Value) &Tracer {
	address := value.attributes['tracer_address'] or { panic('expected BinData::Tracer receiver') }
	return unsafe { &Tracer(voidptr(address.u64())) }
}

pub fn new_trace_session(output &TraceOutput) &TraceSession {
	return &TraceSession{
		tracer: new_tracer(output)
	}
}

pub fn trace_session_boundary_value(session &TraceSession) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::TraceSession'
		repr: 'BinData::TraceSession'
		int_data: i64(u64(voidptr(session)))
		attributes: {
			'trace_session_address': u64(voidptr(session)).str()
		}
	}
}

fn trace_session_from_value(value brew_runtime.Value) &TraceSession {
	address := value.attributes['trace_session_address'] or { panic('expected BinData::TraceSession') }
	return unsafe { &TraceSession(voidptr(address.u64())) }
}

pub fn trace_block_value(callback TraceBlockFn) brew_runtime.Value {
	block := &TraceBlock{
		callback: callback
	}
	return brew_runtime.Value{
		type_name: 'Proc'
		repr: 'trace block'
		int_data: i64(u64(voidptr(block)))
		attributes: {
			'trace_block_address': u64(voidptr(block)).str()
		}
	}
}

fn trace_block_from_value(value brew_runtime.Value) ?&TraceBlock {
	address := value.attributes['trace_block_address'] or { return none }
	return unsafe { &TraceBlock(voidptr(address.u64())) }
}

pub fn trace_message_block_value(callback TraceMessageFn) brew_runtime.Value {
	block := &TraceMessageBlock{
		callback: callback
	}
	return brew_runtime.Value{
		type_name: 'Proc'
		repr: 'trace message block'
		int_data: i64(u64(voidptr(block)))
		attributes: {
			'trace_message_block_address': u64(voidptr(block)).str()
		}
	}
}

fn trace_message_block_from_value(value brew_runtime.Value) ?&TraceMessageBlock {
	address := value.attributes['trace_message_block_address'] or { return none }
	return unsafe { &TraceMessageBlock(voidptr(address.u64())) }
}

pub fn new_trace_readable(debug_name string, selection brew_runtime.Value, callback TraceReadFn) &TraceReadable {
	return &TraceReadable{
		debug_name: debug_name
		selection: selection
		value: trace_nil_value()
		read: callback
	}
}

pub fn trace_readable_boundary_value(readable &TraceReadable) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::TraceReadable'
		repr: readable.value.repr
		int_data: i64(u64(voidptr(readable)))
		attributes: {
			'trace_readable_address': u64(voidptr(readable)).str()
			'debug_name': readable.debug_name
		}
	}
}

fn trace_readable_from_value(value brew_runtime.Value) ?&TraceReadable {
	address := value.attributes['trace_readable_address'] or { return none }
	return unsafe { &TraceReadable(voidptr(address.u64())) }
}

pub fn new_trace_hook(kind string, target brew_runtime.Value, session &TraceSession) &TraceHookState {
	return &TraceHookState{
		kind: if kind.trim_left(':') == 'choice' { .choice } else { .primitive }
		target: target
		session: session
	}
}

pub fn trace_hook_boundary_value(hook &TraceHookState) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::TraceHook'
		repr: hook.kind.str()
		int_data: i64(u64(voidptr(hook)))
		attributes: {
			'trace_hook_address': u64(voidptr(hook)).str()
			'kind': hook.kind.str()
			'active': hook.active.str()
		}
	}
}

fn trace_hook_from_value(value brew_runtime.Value) ?&TraceHookState {
	address := value.attributes['trace_hook_address'] or { return none }
	return unsafe { &TraceHookState(voidptr(address.u64())) }
}

fn (mut tracer Tracer) trace(message string) {
	tracer.output.data += message + '\n'
}

fn (mut tracer Tracer) trace_object(name string, initial_value string) {
	mut value := initial_value
	if value.len > 30 {
		value = value[..31] + '...'
	}
	tracer.trace('${name} => ${value}')
}

fn trace_inspect(value brew_runtime.Value) string {
	if value.type_name == 'String' {
		return '"${value.as_string()}"'
	}
	if value.type_name == 'NilClass' {
		return 'nil'
	}
	return value.repr
}

fn trace_target_debug_name(value brew_runtime.Value) string {
	if readable := trace_readable_from_value(value) {
		return readable.debug_name
	}
	if _ := value.attributes['base_object_address'] {
		return ruby_base_l206_d25_debug_name(value).as_string()
	}
	return value.attributes['debug_name'] or { 'obj' }
}

fn trace_target_value(value brew_runtime.Value) brew_runtime.Value {
	if readable := trace_readable_from_value(value) {
		return readable.value
	}
	if _ := value.attributes['primitive_object_address'] {
		return primitive_effective_value(primitive_object_from_value(value))
	}
	if _ := value.attributes['base_object_address'] {
		return base_object_from_value(value).snapshot_value
	}
	return value
}

fn trace_target_selection(value brew_runtime.Value) brew_runtime.Value {
	if readable := trace_readable_from_value(value) {
		return readable.selection
	}
	if _ := value.attributes['base_object_address'] {
		return base_object_from_value(value).parameters['selection'] or { trace_nil_value() }
	}
	return value.map_data['selection'] or { trace_nil_value() }
}

fn trace_raw_read(target brew_runtime.Value, io brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(io)
	if address := target.attributes['trace_readable_address'] {
		mut readable := unsafe { &TraceReadable(voidptr(address.u64())) }
		readable.value = readable.read(mut reader)
		return readable.value
	}
	if _ := target.attributes['primitive_object_address'] {
		return ruby_primitive_l115_d9_read_and_return_value(target, io)
	}
	if _ := target.attributes['array_object_address'] {
		mut object := array_object_from_value(target)
		match object.read_mode {
			.initial_length { return ruby_array_l312_d40_do_read(target, io) }
			.read_until { return ruby_array_l285_d38_do_read(target, io) }
			.read_until_eof { return ruby_array_l297_d39_do_read(target, io) }
		}
	}
	if _ := target.attributes['struct_object_address'] {
		return ruby_struct_l139_d10_do_read(target, io)
	}
	panic('${target.type_name} has no translated do_read target')
}

fn trace_hook_call_args(args []brew_runtime.Value) (&TraceHookState, brew_runtime.Value) {
	if args.len == 0 {
		panic('trace hook requires a receiver')
	}
	if 'trace_hook_address' in args[0].attributes {
		if args.len < 2 {
			panic('trace hook requires IO')
		}
		hook := trace_hook_from_value(args[0]) or { panic('expected TraceHook') }
		return hook, args[1]
	}
	if args.len < 3 {
		panic('trace hook requires session, target and IO')
	}
	session := trace_session_from_value(args[0])
	hook := new_trace_hook(if args[0].attributes['kind'] == 'choice' { 'choice' } else { 'primitive' }, args[1], session)
	return hook, args[2]
}

fn trace_with_primitive_hook(hook &TraceHookState, io brew_runtime.Value) brew_runtime.Value {
	result := trace_raw_read(hook.target, io)
	mut tracer := hook.session.tracer
	tracer.trace_object(trace_target_debug_name(hook.target), trace_inspect(trace_target_value(hook.target)))
	return result
}

fn trace_with_choice_hook(hook &TraceHookState, io brew_runtime.Value) brew_runtime.Value {
	mut tracer := hook.session.tracer
	tracer.trace_object('${trace_target_debug_name(hook.target)}-selection-', trace_inspect(trace_target_selection(hook.target)))
	return trace_raw_read(hook.target, io)
}

// Ruby method `trace_reading(io = STDERR)` at line 6.
pub fn ruby_trace_l6_d1_trace_reading(args ...brew_runtime.Value) brew_runtime.Value {
	mut session := if args.len > 0 && args[0].type_name == 'BinData::TraceSession' {
		trace_session_from_value(args[0])
	} else {
		output := if args.len > 0 { trace_output_from_value(args[0]) } else { new_trace_output() }
		new_trace_session(output)
	}
	session.primitive_tracing = true
	session.choice_tracing = true
	session.active = true
	block_value := if args.len > 0 && args.last().type_name == 'Proc' { args.last() } else { trace_nil_value() }
	if block := trace_block_from_value(block_value) {
		defer {
			session.primitive_tracing = false
			session.choice_tracing = false
			session.active = false
		}
		return block.callback(mut session)
	}
	return trace_session_boundary_value(session)
}

// Ruby method `initialize(io)` at line 24.
pub fn ruby_trace_l24_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Tracer#initialize requires IO')
	}
	return tracer_boundary_value(new_tracer(trace_output_from_value(args[args.len - 1])))
}

// Ruby method `trace(msg)` at line 28.
pub fn ruby_trace_l28_d3_trace(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Tracer#trace requires a receiver and message')
	}
	mut tracer := tracer_from_value(args[0])
	tracer.trace(args[1].as_string())
	return trace_nil_value()
}

// Ruby method `trace_obj(obj_name, val)` at line 32.
pub fn ruby_trace_l32_d4_trace_obj(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Tracer#trace_obj requires a receiver, object name and value')
	}
	mut tracer := tracer_from_value(args[0])
	tracer.trace_object(args[1].as_string(), args[2].as_string())
	return trace_nil_value()
}

// Ruby method `trace_message # :nodoc:` at line 41.
pub fn ruby_trace_l41_d5_trace_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('trace_message requires a trace session')
	}
	session := trace_session_from_value(args[0])
	if args.len > 1 {
		if block := trace_message_block_from_value(args[1]) {
			return block.callback(session.tracer)
		}
	}
	return tracer_boundary_value(session.tracer)
}

// Ruby method `turn_on_tracing` at line 48.
pub fn ruby_trace_l48_d6_turn_on_tracing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TraceHook#turn_on_tracing requires a receiver')
	}
	if 'trace_hook_address' in args[0].attributes {
		address := args[0].attributes['trace_hook_address'] or { panic('expected TraceHook') }
		mut mutable := unsafe { &TraceHookState(voidptr(address.u64())) }
		if !mutable.active {
			mutable.active = true
		}
		return trace_hook_boundary_value(mutable)
	}
	mut session := trace_session_from_value(args[0])
	session.primitive_tracing = true
	session.choice_tracing = true
	session.active = true
	return trace_session_boundary_value(session)
}

// Ruby alias_method `alias_method :do_read_without_hook, :do_read` at line 50.
pub fn ruby_trace_l50_d7_do_read_without_hook(args ...brew_runtime.Value) brew_runtime.Value {
	hook, io := trace_hook_call_args(args)
	return trace_raw_read(hook.target, io)
}

// Ruby alias_method `alias_method :do_read, :do_read_with_hook` at line 51.
pub fn ruby_trace_l51_d8_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	hook, io := trace_hook_call_args(args)
	if !hook.active {
		return trace_raw_read(hook.target, io)
	}
	return match hook.kind {
		.primitive { trace_with_primitive_hook(hook, io) }
		.choice { trace_with_choice_hook(hook, io) }
	}
}

// Ruby method `turn_off_tracing` at line 55.
pub fn ruby_trace_l55_d9_turn_off_tracing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TraceHook#turn_off_tracing requires a receiver')
	}
	if 'trace_hook_address' in args[0].attributes {
		address := args[0].attributes['trace_hook_address'] or { panic('expected TraceHook') }
		mut mutable := unsafe { &TraceHookState(voidptr(address.u64())) }
		if mutable.active {
			mutable.active = false
		}
		return trace_hook_boundary_value(mutable)
	}
	mut session := trace_session_from_value(args[0])
	session.primitive_tracing = false
	session.choice_tracing = false
	session.active = false
	return trace_session_boundary_value(session)
}

// Ruby alias_method `alias_method :do_read, :do_read_without_hook` at line 57.
pub fn ruby_trace_l57_d10_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	hook, io := trace_hook_call_args(args)
	return trace_raw_read(hook.target, io)
}

// Ruby method `do_read_with_hook(io)` at line 66.
pub fn ruby_trace_l66_d11_do_read_with_hook(args ...brew_runtime.Value) brew_runtime.Value {
	hook, io := trace_hook_call_args(args)
	return trace_with_primitive_hook(hook, io)
}

// Ruby method `do_read_with_hook(io)` at line 79.
pub fn ruby_trace_l79_d12_do_read_with_hook(args ...brew_runtime.Value) brew_runtime.Value {
	hook, io := trace_hook_call_args(args)
	return trace_with_choice_hook(hook, io)
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
