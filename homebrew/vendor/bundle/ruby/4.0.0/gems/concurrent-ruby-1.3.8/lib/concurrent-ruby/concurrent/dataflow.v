module concurrent

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/dataflow.rb`.
// The original source is retained below until every stub has a typed V body.
pub type DataflowTask = fn([]ruby.Value) !ruby.Value

@[heap]
pub struct DependencyCounter {
	mutex &sync.Mutex
mut:
	count  int
	future &Future
}

@[heap]
struct DataflowContext {
	inputs []&IVar
	task   DataflowTask @[required]
	strict bool
}

pub fn new_dependency_counter(count int, future &Future) &DependencyCounter {
	return &DependencyCounter{
		mutex: sync.new_mutex()
		count: count
		future: future
	}
}

pub fn (mut counter DependencyCounter) update() {
	counter.mutex.lock()
	counter.count--
	ready := counter.count == 0
	counter.mutex.unlock()
	if ready {
		mut future := counter.future
		future.execute()
	}
}

fn dataflow_context_value(context &DataflowContext) ruby.Value {
	return ruby.structured_value('Concurrent::DataflowContext', '#<Concurrent::DataflowContext>', {
		'dataflow_context_address': u64(voidptr(context)).str()
	})
}

fn dataflow_context_from_value(value ruby.Value) &DataflowContext {
	address := (value.attribute('dataflow_context_address') or {
		panic('${value.type_name} has no translated dataflow state')
	}).u64()
	return unsafe { &DataflowContext(voidptr(address)) }
}

fn execute_dataflow_context(args []ruby.Value) !ruby.Value {
	if args.len == 0 {
		return error('dataflow context is missing')
	}
	context := dataflow_context_from_value(args[0])
	mut values := []ruby.Value{cap: context.inputs.len}
	for input_pointer in context.inputs {
		mut input := unsafe { input_pointer }
		if context.strict {
			values << input.value_or_error(none)!
		} else {
			values << input.value(none)
		}
	}
	return context.task(values)!
}

fn wait_for_dataflow_input(mut counter DependencyCounter, mut input IVar) {
	input.wait(none)
	counter.update()
}

pub fn call_dataflow(mode FutureExecutorMode, inputs []&IVar, task DataflowTask, strict bool) &Future {
	context := &DataflowContext{
		inputs: inputs.clone()
		task: task
		strict: strict
	}
	mut future := new_future_with_mode(execute_dataflow_context, [
		dataflow_context_value(context),
	], mode)
	if inputs.len == 0 {
		future.execute()
		return future
	}
	mut counter := new_dependency_counter(inputs.len, future)
	for input_pointer in inputs {
		mut input := unsafe { input_pointer }
		spawn wait_for_dataflow_input(mut counter, mut input)
	}
	return future
}

pub fn dataflow(inputs []&IVar, task DataflowTask) &Future {
	return call_dataflow(.async, inputs, task, false)
}

pub fn dataflow_with(mode FutureExecutorMode, inputs []&IVar, task DataflowTask) &Future {
	return call_dataflow(mode, inputs, task, false)
}

pub fn dataflow_bang(inputs []&IVar, task DataflowTask) &Future {
	return call_dataflow(.async, inputs, task, true)
}

pub fn dataflow_with_bang(mode FutureExecutorMode, inputs []&IVar, task DataflowTask) &Future {
	return call_dataflow(mode, inputs, task, true)
}

fn dependency_counter_boundary_value(counter &DependencyCounter) ruby.Value {
	return ruby.structured_value('Concurrent::DependencyCounter', '#<Concurrent::DependencyCounter>', {
		'dependency_counter_address': u64(voidptr(counter)).str()
	})
}

fn dependency_counter_boundary_receiver(args []ruby.Value) &DependencyCounter {
	if args.len == 0 {
		panic('DependencyCounter method requires a receiver')
	}
	address := (args[0].attribute('dependency_counter_address') or {
		panic('${args[0].type_name} has no translated DependencyCounter state')
	}).u64()
	return unsafe { &DependencyCounter(voidptr(address)) }
}

fn dataflow_boundary_task(args []ruby.Value) !ruby.Value {
	if args.len == 0 {
		return ivar_nil_value()
	}
	return args[args.len - 1]
}

fn dataflow_boundary_input(value ruby.Value) &IVar {
	if value.type_name == 'Concurrent::Future' {
		mut future := future_boundary_receiver([value])
		return future.ivar
	}
	return ivar_boundary_receiver([value])
}

fn dataflow_boundary_mode(value ruby.Value) FutureExecutorMode {
	return match value.as_string().trim_left(':') {
		'immediate' { .immediate }
		'deferred' { .deferred }
		else { .async }
	}
}

fn call_dataflow_boundary(mode FutureExecutorMode, strict bool, args []ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ArgumentError: no block given')
	}
	// A boundary Value cannot carry a V closure. The final value is the translated
	// block result; preceding values retain the exact IVar dependency contract.
	mut inputs := []&IVar{cap: args.len - 1}
	for input_value in args[..args.len - 1] {
		if input_value.type_name !in ['Concurrent::IVar', 'Concurrent::Future'] {
			panic('ArgumentError: Not all dependencies are IVars.\nDependencies: ${args[..args.len - 1]}')
		}
		inputs << dataflow_boundary_input(input_value)
	}
	result_value := args[args.len - 1]
	result_task := fn [result_value] (_ []ruby.Value) !ruby.Value {
		return result_value
	}
	return future_boundary_value(call_dataflow(mode, inputs, result_task, strict))
}

// Ruby method `initialize(count, &block)` at line 9.
pub fn ruby_dataflow_l9_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('initialize requires count and a future')
	}
	count := int(args[0].as_int() or { panic(err) })
	mut future := future_boundary_receiver([args[1]])
	return dependency_counter_boundary_value(new_dependency_counter(count, future))
}

// Ruby method `update(time, value, reason)` at line 14.
pub fn ruby_dataflow_l14_d2_update(args ...ruby.Value) ruby.Value {
	mut counter := dependency_counter_boundary_receiver(args)
	counter.update()
	return ivar_nil_value()
}

// Ruby method `dataflow(*inputs, &block)` at line 34.
pub fn ruby_dataflow_l34_d3_dataflow(args ...ruby.Value) ruby.Value {
	return call_dataflow_boundary(.async, false, args)
}

// Ruby method `dataflow_with(executor, *inputs, &block)` at line 39.
pub fn ruby_dataflow_l39_d4_dataflow_with(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		panic('ArgumentError: an executor must be provided')
	}
	return call_dataflow_boundary(dataflow_boundary_mode(args[0]), false, args[1..])
}

// Ruby method `dataflow!(*inputs, &block)` at line 44.
pub fn ruby_dataflow_l44_d5_dataflow(args ...ruby.Value) ruby.Value {
	return call_dataflow_boundary(.async, true, args)
}

// Ruby method `dataflow_with!(executor, *inputs, &block)` at line 49.
pub fn ruby_dataflow_l49_d6_dataflow_with(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		panic('ArgumentError: an executor must be provided')
	}
	return call_dataflow_boundary(dataflow_boundary_mode(args[0]), true, args[1..])
}

// Ruby method `call_dataflow(method, executor, *inputs, &block)` at line 56.
pub fn ruby_dataflow_l56_d7_call_dataflow(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name == 'NilClass' {
		panic('ArgumentError: an executor must be provided')
	}
	method := args[0].as_string().trim_left(':')
	return call_dataflow_boundary(dataflow_boundary_mode(args[1]), method == 'value!', args[2..])
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/future'
// 2: require 'concurrent/atomic/atomic_fixnum'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!visibility private
// 7:   class DependencyCounter # :nodoc:
// 8:
// 9:     def initialize(count, &block)
// 10:       @counter = AtomicFixnum.new(count)
// 11:       @block = block
// 12:     end
// 13:
// 14:     def update(time, value, reason)
// 15:       if @counter.decrement == 0
// 16:         @block.call
// 17:       end
// 18:     end
// 19:   end
// 20:
// 21:   # Dataflow allows you to create a task that will be scheduled when all of its data dependencies are available.
// 22:   # {include:file:docs-source/dataflow.md}
// 23:   #
// 24:   # @param [Future] inputs zero or more `Future` operations that this dataflow depends upon
// 25:   #
// 26:   # @yield The operation to perform once all the dependencies are met
// 27:   # @yieldparam [Future] inputs each of the `Future` inputs to the dataflow
// 28:   # @yieldreturn [Object] the result of the block operation
// 29:   #
// 30:   # @return [Object] the result of all the operations
// 31:   #
// 32:   # @raise [ArgumentError] if no block is given
// 33:   # @raise [ArgumentError] if any of the inputs are not `IVar`s
// 34:   def dataflow(*inputs, &block)
// 35:     dataflow_with(Concurrent.global_io_executor, *inputs, &block)
// 36:   end
// 37:   module_function :dataflow
// 38:
// 39:   def dataflow_with(executor, *inputs, &block)
// 40:     call_dataflow(:value, executor, *inputs, &block)
// 41:   end
// 42:   module_function :dataflow_with
// 43:
// 44:   def dataflow!(*inputs, &block)
// 45:     dataflow_with!(Concurrent.global_io_executor, *inputs, &block)
// 46:   end
// 47:   module_function :dataflow!
// 48:
// 49:   def dataflow_with!(executor, *inputs, &block)
// 50:     call_dataflow(:value!, executor, *inputs, &block)
// 51:   end
// 52:   module_function :dataflow_with!
// 53:
// 54:   private
// 55:
// 56:   def call_dataflow(method, executor, *inputs, &block)
// 57:     raise ArgumentError.new('an executor must be provided') if executor.nil?
// 58:     raise ArgumentError.new('no block given') unless block_given?
// 59:     unless inputs.all? { |input| input.is_a? IVar }
// 60:       raise ArgumentError.new("Not all dependencies are IVars.\nDependencies: #{ inputs.inspect }")
// 61:     end
// 62:
// 63:     result = Future.new(executor: executor) do
// 64:       values = inputs.map { |input| input.send(method) }
// 65:       block.call(*values)
// 66:     end
// 67:
// 68:     if inputs.empty?
// 69:       result.execute
// 70:     else
// 71:       counter = DependencyCounter.new(inputs.size) { result.execute }
// 72:
// 73:       inputs.each do |input|
// 74:         input.add_observer counter
// 75:       end
// 76:     end
// 77:
// 78:     result
// 79:   end
// 80:   module_function :call_dataflow
// 81: end
