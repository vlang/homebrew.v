module types

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/type_parameter.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct TypeParameter {
pub:
	parameter_name string
}

struct TypeParameterPool {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	entries map[string]ruby.Value
}

fn new_type_parameter_pool() &TypeParameterPool {
	return &TypeParameterPool{}
}

const type_parameter_pool = new_type_parameter_pool()

pub fn new_type_parameter(name ruby.Value) !&TypeParameter {
	if name.type_name != 'Symbol' {
		return error('not a symbol: ${name.as_string()}')
	}
	return &TypeParameter{
		parameter_name: name.as_string().trim_string_left(':')
	}
}

pub fn (parameter &TypeParameter) build_type() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn (_ &TypeParameter) valid(_ ruby.Value) bool {
	return true
}

pub fn (_ &TypeParameter) subtype_of_single(_ ruby.Value) bool {
	return true
}

pub fn (parameter &TypeParameter) name() string {
	return 'T.type_parameter(:${parameter.parameter_name})'
}

fn type_parameter_value(parameter &TypeParameter) ruby.Value {
	return ruby.structured_value('T::Types::TypeParameter', parameter.name(), {
		'type_parameter_address': u64(voidptr(parameter)).str()
		'name':                   parameter.parameter_name
	})
}

fn type_parameter_from_value(value ruby.Value) &TypeParameter {
	address := value.attribute('type_parameter_address') or {
		panic('invalid TypeParameter receiver')
	}
	return unsafe { &TypeParameter(voidptr(address.u64())) }
}

fn type_parameter_from_args(args []ruby.Value) &TypeParameter {
	if args.len == 0 {
		panic('TypeParameter method requires a receiver')
	}
	return type_parameter_from_value(args[0])
}

pub fn cached_type_parameter(name string) ?ruby.Value {
	mut pool := unsafe { &TypeParameterPool(type_parameter_pool) }
	pool.mutex.lock()
	defer {
		pool.mutex.unlock()
	}
	return pool.entries[name] or { return none }
}

pub fn cache_type_parameter(name string, value ruby.Value) ruby.Value {
	mut pool := unsafe { &TypeParameterPool(type_parameter_pool) }
	pool.mutex.lock()
	defer {
		pool.mutex.unlock()
	}
	pool.entries[name] = value
	return value
}

pub fn make_type_parameter(name ruby.Value) !ruby.Value {
	parameter := new_type_parameter(name)!
	if cached := cached_type_parameter(parameter.parameter_name) {
		return cached
	}
	return cache_type_parameter(parameter.parameter_name, type_parameter_value(parameter))
}

// Ruby method `self.cached_entry(name)` at line 9.
pub fn ruby_type_parameter_l9_d1_self_cached_entry(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TypeParameter.cached_entry requires a name')
	}
	name := args[0].as_string().trim_string_left(':')
	return cached_type_parameter(name) or { ruby.object_value('NilClass', 'nil') }
}

// Ruby method `self.set_entry_for(name, type)` at line 13.
pub fn ruby_type_parameter_l13_d2_self_set_entry_for(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypeParameter.set_entry_for requires a name and type')
	}
	return cache_type_parameter(args[0].as_string().trim_string_left(':'), args[1])
}

// Ruby method `initialize(name)` at line 18.
pub fn ruby_type_parameter_l18_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TypeParameter#initialize requires a name')
	}
	return type_parameter_value(new_type_parameter(args[0]) or { panic(err.msg()) })
}

// Ruby method `build_type` at line 23.
pub fn ruby_type_parameter_l23_d4_build_type(args ...ruby.Value) ruby.Value {
	return type_parameter_from_args(args).build_type()
}

// Ruby method `self.make(name)` at line 27.
pub fn ruby_type_parameter_l27_d5_self_make(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TypeParameter.make requires a name')
	}
	return make_type_parameter(args[0]) or { panic(err.msg()) }
}

// Ruby method `valid?(obj)` at line 34.
pub fn ruby_type_parameter_l34_d6_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypeParameter#valid? requires an object')
	}
	return ruby.bool_value(type_parameter_from_args(args).valid(args[1]))
}

// Ruby method `subtype_of_single?(type)` at line 38.
pub fn ruby_type_parameter_l38_d7_subtype_of_single(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypeParameter#subtype_of_single? requires a type')
	}
	return ruby.bool_value(type_parameter_from_args(args).subtype_of_single(args[1]))
}

// Ruby method `name` at line 42.
pub fn ruby_type_parameter_l42_d8_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(type_parameter_from_args(args).name())
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypeParameter < Base
// 6:     module Private
// 7:       @pool = {}
// 8:
// 9:       def self.cached_entry(name)
// 10:         @pool[name]
// 11:       end
// 12:
// 13:       def self.set_entry_for(name, type)
// 14:         @pool[name] = type
// 15:       end
// 16:     end
// 17:
// 18:     def initialize(name)
// 19:       raise ArgumentError.new("not a symbol: #{name}") unless name.is_a?(Symbol)
// 20:       @name = name
// 21:     end
// 22:
// 23:     def build_type
// 24:       nil
// 25:     end
// 26:
// 27:     def self.make(name)
// 28:       cached = Private.cached_entry(name)
// 29:       return cached if cached
// 30:
// 31:       Private.set_entry_for(name, new(name))
// 32:     end
// 33:
// 34:     def valid?(obj)
// 35:       true
// 36:     end
// 37:
// 38:     def subtype_of_single?(type)
// 39:       true
// 40:     end
// 41:
// 42:     def name
// 43:       "T.type_parameter(:#{@name})"
// 44:     end
// 45:   end
// 46: end
