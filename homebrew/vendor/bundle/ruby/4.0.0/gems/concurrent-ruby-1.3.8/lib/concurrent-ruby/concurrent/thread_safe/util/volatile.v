module util

import ruby
import math
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/util/volatile.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct VolatileClassPlan {
pub:
	attributes []string
}

@[heap]
pub struct VolatileObject {
pub:
	plan VolatileClassPlan
mut:
	lock   sync.RwMutex
	values map[string]ruby.Value
}

fn volatile_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn volatile_attributes(names []string) VolatileClassPlan {
	mut attributes := []string{}
	for name in names {
		if name.len > 0 && name !in attributes {
			attributes << name
		}
	}
	return VolatileClassPlan{
		attributes: attributes
	}
}

pub fn new_volatile_object(plan VolatileClassPlan) &VolatileObject {
	mut values := map[string]ruby.Value{}
	for name in plan.attributes {
		values[name] = volatile_nil_value()
	}
	return &VolatileObject{
		plan: plan
		values: values
	}
}

pub fn (mut object VolatileObject) copy() &VolatileObject {
	object.lock.rlock()
	values := object.values.clone()
	object.lock.runlock()
	return &VolatileObject{
		plan: object.plan
		values: values
	}
}

fn (object &VolatileObject) validate_attribute(name string) ! {
	if name !in object.plan.attributes {
		return error('unknown volatile attribute `${name}`')
	}
}

pub fn (mut object VolatileObject) get(name string) !ruby.Value {
	object.validate_attribute(name)!
	object.lock.rlock()
	value := object.values[name]
	object.lock.runlock()
	return value
}

pub fn (mut object VolatileObject) set(name string, value ruby.Value) !ruby.Value {
	object.validate_attribute(name)!
	object.lock.lock()
	object.values[name] = value
	object.lock.unlock()
	return value
}

fn volatile_values_match(actual ruby.Value, expected ruby.Value) bool {
	if expected.type_name == 'Integer' || expected.type_name == 'Float' {
		if actual.type_name != 'Integer' && actual.type_name != 'Float' {
			return false
		}
		actual_numeric := actual.as_float() or { return false }
		expected_numeric := expected.as_float() or { return false }
		if math.is_nan(expected_numeric) {
			return math.is_nan(actual_numeric)
		}
		return actual_numeric == expected_numeric
	}
	if expected_identity := expected.attributes['identity'] {
		return actual.attributes['identity'] == expected_identity
	}
	return actual.type_name == expected.type_name && actual.repr == expected.repr
}

pub fn (mut object VolatileObject) compare_and_set(name string, expected ruby.Value, prospect ruby.Value) !bool {
	object.validate_attribute(name)!
	object.lock.lock()
	if volatile_values_match(object.values[name], expected) {
		object.values[name] = prospect
		object.lock.unlock()
		return true
	}
	object.lock.unlock()
	return false
}

fn volatile_plan_value(plan VolatileClassPlan) ruby.Value {
	return ruby.structured_value('Concurrent::ThreadSafe::Util::VolatileClassPlan', plan.attributes.str(), {
		'attributes': plan.attributes.join(',')
	})
}

fn volatile_plan_from_value(value ruby.Value) VolatileClassPlan {
	return volatile_attributes((value.attribute('attributes') or { '' }).split(',').filter(it.len > 0))
}

fn volatile_object_value(object &VolatileObject) ruby.Value {
	return ruby.structured_value('Concurrent::ThreadSafe::Util::VolatileObject', '#<VolatileObject>', {
		'volatile_object_address': u64(voidptr(object)).str()
		'attributes':              object.plan.attributes.join(',')
	})
}

fn volatile_object_from_value(value ruby.Value) &VolatileObject {
	address := (value.attribute('volatile_object_address') or {
		panic('${value.type_name} has no translated volatile state')
	}).u64()
	return unsafe { &VolatileObject(voidptr(address)) }
}

// Ruby method `attr_volatile(*attr_names)` at line 33.
pub fn ruby_volatile_l33_d1_attr_volatile(args ...ruby.Value) ruby.Value {
	return volatile_plan_value(volatile_attributes(args.map(it.as_string())))
}

// Ruby method `initialize(*)` at line 41.
pub fn ruby_volatile_l41_d2_initialize(args ...ruby.Value) ruby.Value {
	plan := if args.len > 0 && args[0].type_name == 'Concurrent::ThreadSafe::Util::VolatileClassPlan' {
		volatile_plan_from_value(args[0])
	} else {
		volatile_attributes([])
	}
	return volatile_object_value(new_volatile_object(plan))
}

// Ruby method `initialize_copy(other)` at line 46.
pub fn ruby_volatile_l46_d3_initialize_copy(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Volatile#initialize_copy requires another object')
	}
	mut object := volatile_object_from_value(args[0])
	return volatile_object_value(object.copy())
}

// Ruby method `#{attr_name}` at line 54.
pub fn ruby_volatile_l54_d4_attr_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('volatile getter requires receiver and attribute name')
	}
	mut object := volatile_object_from_value(args[0])
	return object.get(args[1].as_string()) or { panic(err) }
}

// Ruby method `#{attr_name}=(value)` at line 58.
pub fn ruby_volatile_l58_d5_attr_name(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('volatile setter requires receiver, attribute name, and value')
	}
	mut object := volatile_object_from_value(args[0])
	return object.set(args[1].as_string(), args[2]) or { panic(err) }
}

// Ruby method `compare_and_set_#{attr_name}(old_value, new_value)` at line 62.
pub fn ruby_volatile_l62_d6_compare_and_set_attr_name(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('volatile compare_and_set requires receiver, attribute name, old value, and new value')
	}
	mut object := volatile_object_from_value(args[0])
	return ruby.bool_value(object.compare_and_set(args[1].as_string(), args[2], args[3]) or {
		panic(err)
	})
}

// Ruby alias_method `alias_method :"cas_#{attr_name}", :"compare_and_set_#{attr_name}"` at line 67.
pub fn ruby_volatile_l67_d7_cas_attr_name(args ...ruby.Value) ruby.Value {
	return ruby_volatile_l62_d6_compare_and_set_attr_name(...args)
}

// Ruby alias_method `alias_method :"lazy_set_#{attr_name}", :"#{attr_name}="` at line 68.
pub fn ruby_volatile_l68_d8_lazy_set_attr_name(args ...ruby.Value) ruby.Value {
	return ruby_volatile_l58_d5_attr_name(...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/thread_safe/util'
// 2:
// 3: module Concurrent
// 4:
// 5:   # @!visibility private
// 6:   module ThreadSafe
// 7:
// 8:     # @!visibility private
// 9:     module Util
// 10:
// 11:       # @!visibility private
// 12:       module Volatile
// 13:
// 14:         # Provides +volatile+ (in the JVM's sense) attribute accessors implemented
// 15:         # atop of +Concurrent::AtomicReference+.
// 16:         #
// 17:         # Usage:
// 18:         #   class Foo
// 19:         #     extend Concurrent::ThreadSafe::Util::Volatile
// 20:         #     attr_volatile :foo, :bar
// 21:         #
// 22:         #     def initialize(bar)
// 23:         #       super() # must super() into parent initializers before using the volatile attribute accessors
// 24:         #       self.bar = bar
// 25:         #     end
// 26:         #
// 27:         #     def hello
// 28:         #       my_foo = foo # volatile read
// 29:         #       self.foo = 1 # volatile write
// 30:         #       cas_foo(1, 2) # => true | a strong CAS
// 31:         #     end
// 32:         #   end
// 33:         def attr_volatile(*attr_names)
// 34:           return if attr_names.empty?
// 35:           include(Module.new do
// 36:             atomic_ref_setup = attr_names.map {|attr_name| "@__#{attr_name} = Concurrent::AtomicReference.new"}
// 37:             initialize_copy_setup = attr_names.zip(atomic_ref_setup).map do |attr_name, ref_setup|
// 38:               "#{ref_setup}(other.instance_variable_get(:@__#{attr_name}).get)"
// 39:             end
// 40:             class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
// 41:             def initialize(*)
// 42:               super
// 43:             #{atomic_ref_setup.join('; ')}
// 44:             end
// 45:
// 46:             def initialize_copy(other)
// 47:               super
// 48:             #{initialize_copy_setup.join('; ')}
// 49:             end
// 50:             RUBY_EVAL
// 51:
// 52:             attr_names.each do |attr_name|
// 53:               class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
// 54:               def #{attr_name}
// 55:                 @__#{attr_name}.get
// 56:               end
// 57:
// 58:               def #{attr_name}=(value)
// 59:                 @__#{attr_name}.set(value)
// 60:               end
// 61:
// 62:               def compare_and_set_#{attr_name}(old_value, new_value)
// 63:                 @__#{attr_name}.compare_and_set(old_value, new_value)
// 64:               end
// 65:               RUBY_EVAL
// 66:
// 67:               alias_method :"cas_#{attr_name}", :"compare_and_set_#{attr_name}"
// 68:               alias_method :"lazy_set_#{attr_name}", :"#{attr_name}="
// 69:             end
// 70:           end)
// 71:         end
// 72:       end
// 73:     end
// 74:   end
// 75: end
