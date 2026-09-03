module abstract

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/abstract/data.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct AbstractData {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	values map[string]brew_runtime.Value
}

pub fn new_abstract_data() &AbstractData {
	return &AbstractData{}
}

const abstract_data_global = new_abstract_data()

fn abstract_object_id(value brew_runtime.Value) string {
	return value.attribute('object_id') or { '${value.type_name}:${value.as_string()}' }
}

fn abstract_data_key(mod brew_runtime.Value, key string) string {
	return '${abstract_object_id(mod)}\0${key.trim_string_left(':')}'
}

pub fn (mut data AbstractData) get(mod brew_runtime.Value, key string) brew_runtime.Value {
	data.mutex.lock()
	defer {
		data.mutex.unlock()
	}
	return data.values[abstract_data_key(mod, key)] or {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

pub fn (mut data AbstractData) set(mod brew_runtime.Value, key string,
	value brew_runtime.Value) brew_runtime.Value {
	data.mutex.lock()
	data.values[abstract_data_key(mod, key)] = value
	data.mutex.unlock()
	return value
}

pub fn (mut data AbstractData) has_key(mod brew_runtime.Value, key string) bool {
	data.mutex.lock()
	defer {
		data.mutex.unlock()
	}
	return abstract_data_key(mod, key) in data.values
}

pub fn (mut data AbstractData) set_default(mod brew_runtime.Value, key string,
	default_value brew_runtime.Value) brew_runtime.Value {
	data.mutex.lock()
	defer {
		data.mutex.unlock()
	}
	storage_key := abstract_data_key(mod, key)
	if value := data.values[storage_key] {
		return value
	}
	data.values[storage_key] = default_value
	return default_value
}

pub fn global_abstract_data() &AbstractData {
	return unsafe { &AbstractData(abstract_data_global) }
}

fn data_boundary_key(args []brew_runtime.Value) string {
	if args.len < 2 {
		panic('Abstract::Data operation requires a module and key')
	}
	return args[1].as_string()
}

// Ruby method `self.get(mod, key)` at line 14.
pub fn ruby_data_l14_d1_self_get(args ...brew_runtime.Value) brew_runtime.Value {
	mut data := global_abstract_data()
	return data.get(args[0], data_boundary_key(args))
}

// Ruby method `self.set(mod, key, value)` at line 18.
pub fn ruby_data_l18_d2_self_set(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Abstract::Data.set requires a module, key, and value')
	}
	mut data := global_abstract_data()
	return data.set(args[0], data_boundary_key(args), args[2])
}

// Ruby method `self.key?(mod, key)` at line 22.
pub fn ruby_data_l22_d3_self_key(args ...brew_runtime.Value) brew_runtime.Value {
	mut data := global_abstract_data()
	return brew_runtime.bool_value(data.has_key(args[0], data_boundary_key(args)))
}

// Ruby method `self.set_default(mod, key, default)` at line 28.
pub fn ruby_data_l28_d4_self_set_default(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Abstract::Data.set_default requires a module, key, and default')
	}
	mut data := global_abstract_data()
	return data.set_default(args[0], data_boundary_key(args), args[2])
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # We need to associate data with abstract modules. We could add instance methods to them that
// 5: # access ivars, but those methods will unnecessarily pollute the module namespace, and they'd
// 6: # have access to other private state and methods that they don't actually need. We also need to
// 7: # associate data with arbitrary classes/modules that implement abstract mixins, where we don't
// 8: # control the interface at all. So, we access data via these `get` and `set` methods.
// 9: #
// 10: # Using instance_variable_get/set here is gross, but the alternative is to use a hash keyed on
// 11: # `mod`, and we can't trust that arbitrary modules can be added to those, because there are lurky
// 12: # modules that override the `hash` method with something completely broken.
// 13: module T::Private::Abstract::Data
// 14:   def self.get(mod, key)
// 15:     mod.instance_variable_get("@opus_abstract__#{key}")
// 16:   end
// 17:
// 18:   def self.set(mod, key, value)
// 19:     mod.instance_variable_set("@opus_abstract__#{key}", value)
// 20:   end
// 21:
// 22:   def self.key?(mod, key)
// 23:     mod.instance_variable_defined?("@opus_abstract__#{key}")
// 24:   end
// 25:
// 26:   # Works like `setdefault` in Python. If key has already been set, return its value. If not,
// 27:   # insert `key` with a value of `default` and return `default`.
// 28:   def self.set_default(mod, key, default)
// 29:     if self.key?(mod, key)
// 30:       self.get(mod, key)
// 31:     else
// 32:       self.set(mod, key, default)
// 33:       default
// 34:     end
// 35:   end
// 36: end
