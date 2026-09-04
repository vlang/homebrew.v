module util

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/util/data_structures.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum SynchronizationEngine {
	cruby
	truffleruby
}

pub struct SynchronizedClassPlan {
pub:
	class_name string
	engine     SynchronizationEngine
	methods    []string
}

pub type SynchronizedAction = fn() !ruby.Value

@[heap]
pub struct SynchronizedObject {
pub:
	plan SynchronizedClassPlan
mut:
	monitor sync.Mutex
}

pub fn make_synchronized_plan(class_name string, methods []string, engine SynchronizationEngine) SynchronizedClassPlan {
	return SynchronizedClassPlan{
		class_name: class_name
		engine: engine
		methods: methods.clone()
	}
}

pub fn new_synchronized_object(plan SynchronizedClassPlan) &SynchronizedObject {
	return &SynchronizedObject{
		plan: plan
	}
}

pub fn (object &SynchronizedObject) copy() &SynchronizedObject {
	return new_synchronized_object(object.plan)
}

pub fn (mut object SynchronizedObject) synchronized(action SynchronizedAction) !ruby.Value {
	object.monitor.lock()
	defer {
		object.monitor.unlock()
	}
	return action()
}

fn synchronized_class_plan_value(plan SynchronizedClassPlan) ruby.Value {
	return ruby.structured_value('Concurrent::ThreadSafe::Util::SynchronizedClassPlan', plan.class_name, {
		'class_name': plan.class_name
		'engine':     plan.engine.str()
		'methods':    plan.methods.join(',')
	})
}

fn synchronized_class_plan_from_value(value ruby.Value, default_engine SynchronizationEngine) SynchronizedClassPlan {
	class_name := value.attribute('class_name') or { value.as_string() }
	methods := (value.attribute('methods') or { '' }).split(',').filter(it.len > 0)
	engine_name := value.attribute('engine') or { default_engine.str() }
	return make_synchronized_plan(class_name, methods, if engine_name == SynchronizationEngine.truffleruby.str() {
		.truffleruby
	} else {
		.cruby
	})
}

fn synchronized_object_value(object &SynchronizedObject) ruby.Value {
	return ruby.structured_value('Concurrent::ThreadSafe::Util::SynchronizedObject', '#<${object.plan.class_name}>', {
		'synchronized_object_address': u64(voidptr(object)).str()
		'class_name':                  object.plan.class_name
		'engine':                      object.plan.engine.str()
		'methods':                     object.plan.methods.join(',')
	})
}

fn synchronized_object_from_value(value ruby.Value) &SynchronizedObject {
	address := (value.attribute('synchronized_object_address') or {
		panic('${value.type_name} has no translated synchronized state')
	}).u64()
	return unsafe { &SynchronizedObject(voidptr(address)) }
}

// Ruby method `self.synchronized(object, &block)` at line 7.
pub fn ruby_data_structures_l7_d1_self_synchronized(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TruffleRuby.synchronized requires an object and translated block result')
	}
	mut object := synchronized_object_from_value(args[0])
	mut result := args[1]
	return object.synchronized(fn [mut result] () !ruby.Value {
		return result
	}) or { panic(err) }
}

// Ruby method `self.make_synchronized_on_cruby(klass)` at line 16.
pub fn ruby_data_structures_l16_d2_self_make_synchronized_on_cruby(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('make_synchronized_on_cruby requires a class')
	}
	return synchronized_class_plan_value(synchronized_class_plan_from_value(args[0], .cruby))
}

// Ruby method `initialize(*args, &block)` at line 18.
pub fn ruby_data_structures_l18_d3_initialize(args ...ruby.Value) ruby.Value {
	plan := if args.len > 0 && args[0].type_name == 'Concurrent::ThreadSafe::Util::SynchronizedClassPlan' {
		synchronized_class_plan_from_value(args[0], .cruby)
	} else {
		make_synchronized_plan('Object', [], .cruby)
	}
	return synchronized_object_value(new_synchronized_object(plan))
}

// Ruby method `initialize_copy(other)` at line 23.
pub fn ruby_data_structures_l23_d4_initialize_copy(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('initialize_copy requires another synchronized object')
	}
	return synchronized_object_value(synchronized_object_from_value(args[0]).copy())
}

// Ruby method `#{method}(*args)` at line 32.
pub fn ruby_data_structures_l32_d5_method(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('synchronized generated method requires receiver and translated super result')
	}
	mut object := synchronized_object_from_value(args[0])
	mut result := args[args.len - 1]
	return object.synchronized(fn [mut result] () !ruby.Value {
		return result
	}) or { panic(err) }
}

// Ruby method `self.make_synchronized_on_truffleruby(klass)` at line 41.
pub fn ruby_data_structures_l41_d6_self_make_synchronized_on_truffleruby(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('make_synchronized_on_truffleruby requires a class')
	}
	plan := synchronized_class_plan_from_value(args[0], .truffleruby)
	return synchronized_class_plan_value(SynchronizedClassPlan{
		...plan
		engine: .truffleruby
	})
}

// Ruby method `#{method}(*args, &block)` at line 44.
pub fn ruby_data_structures_l44_d7_method(args ...ruby.Value) ruby.Value {
	return ruby_data_structures_l32_d5_method(...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/thread_safe/util'
// 2: require 'concurrent/utility/engine'
// 3:
// 4: # Shim for TruffleRuby.synchronized
// 5: if Concurrent.on_truffleruby? && !TruffleRuby.respond_to?(:synchronized)
// 6:   module TruffleRuby
// 7:     def self.synchronized(object, &block)
// 8:       Truffle::System.synchronized(object, &block)
// 9:     end
// 10:   end
// 11: end
// 12:
// 13: module Concurrent
// 14:   module ThreadSafe
// 15:     module Util
// 16:       def self.make_synchronized_on_cruby(klass)
// 17:         klass.class_eval do
// 18:           def initialize(*args, &block)
// 19:             @_monitor = Monitor.new
// 20:             super
// 21:           end
// 22:
// 23:           def initialize_copy(other)
// 24:             # make sure a copy is not sharing a monitor with the original object!
// 25:             @_monitor = Monitor.new
// 26:             super
// 27:           end
// 28:         end
// 29:
// 30:         klass.superclass.instance_methods(false).each do |method|
// 31:           klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 32:             def #{method}(*args)
// 33:               monitor = @_monitor
// 34:               monitor or raise("BUG: Internal monitor was not properly initialized. Please report this to the concurrent-ruby developers.")
// 35:               monitor.synchronize { super }
// 36:             end
// 37:           RUBY
// 38:         end
// 39:       end
// 40:
// 41:       def self.make_synchronized_on_truffleruby(klass)
// 42:         klass.superclass.instance_methods(false).each do |method|
// 43:           klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 44:             def #{method}(*args, &block)
// 45:               TruffleRuby.synchronized(self) { super(*args, &block) }
// 46:             end
// 47:           RUBY
// 48:         end
// 49:       end
// 50:     end
// 51:   end
// 52: end
