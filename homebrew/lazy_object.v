module homebrew

import brew_runtime

// Translated from Homebrew/brew `lazy_object.rb`.
// The original source is retained below until every stub has a typed V body.
pub type LazyValueFactory = fn() !brew_runtime.Value

pub struct LazyObject {
mut:
	callable    LazyValueFactory @[required]
	getobj_set  bool
	object      brew_runtime.Value
	evaluations int
}

pub fn (object &LazyObject) evaluated() bool {
	return object.getobj_set
}

pub fn (object &LazyObject) evaluation_count() int {
	return object.evaluations
}

// Ruby method `initialize(&callable)` at line 9.
pub fn ruby_lazy_object_l9_d1_initialize(callable LazyValueFactory) LazyObject {
	return LazyObject{
		callable: callable
	}
}

// Ruby method `__getobj__(&_blk)` at line 17.
pub fn ruby_lazy_object_l17_d2_getobj(mut object LazyObject) !brew_runtime.Value {
	if object.getobj_set {
		return object.object
	}
	object.object = object.callable()!
	object.getobj_set = true
	object.evaluations++
	return object.object
}

// Ruby method `__setobj__(callable)` at line 26.
pub fn ruby_lazy_object_l26_d3_setobj(mut object LazyObject, callable LazyValueFactory) {
	object.callable = callable
	object.getobj_set = false
	object.object = brew_runtime.Value{}
}

// Ruby method `is_a?(klass)` at line 36.
pub fn ruby_lazy_object_l36_d4_is_a(mut object LazyObject, class_name string) !bool {
	value := ruby_lazy_object_l17_d2_getobj(mut object)!
	return value.type_name == class_name || class_name == 'LazyObject' || class_name == 'Delegator'
}

// Ruby method `class = __getobj__.class` at line 44.
pub fn ruby_lazy_object_l44_d5_class(mut object LazyObject) !string {
	return ruby_lazy_object_l17_d2_getobj(mut object)!.type_name
}

// Ruby method `to_s = __getobj__.to_s` at line 47.
pub fn ruby_lazy_object_l47_d6_to_s(mut object LazyObject) !string {
	return ruby_lazy_object_l17_d2_getobj(mut object)!.as_string()
}

pub fn lazy_object_not(mut object LazyObject) !bool {
	value := ruby_lazy_object_l17_d2_getobj(mut object)!
	if value.type_name == 'Bool' {
		return !value.as_bool()!
	}
	return false
}

pub fn lazy_object_equals(mut object LazyObject, other brew_runtime.Value) !bool {
	value := ruby_lazy_object_l17_d2_getobj(mut object)!
	return value.type_name == other.type_name && value.repr == other.repr
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "delegate"
// 5:
// 6: # An object which lazily evaluates its inner block only once a method is called on it.
// 7: class LazyObject < Delegator
// 8:   sig { params(callable: T.nilable(Proc)).void }
// 9:   def initialize(&callable)
// 10:     @__callable__ = T.let(nil, T.nilable(Proc))
// 11:     @getobj_set = T.let(false, T::Boolean)
// 12:     @__getobj__ = T.let(nil, T.untyped)
// 13:     super(callable)
// 14:   end
// 15:
// 16:   sig { params(_blk: T.untyped).returns(T.untyped) }
// 17:   def __getobj__(&_blk)
// 18:     return @__getobj__ if @getobj_set
// 19:
// 20:     @__getobj__ = T.must(@__callable__).call
// 21:     @getobj_set = true
// 22:     @__getobj__
// 23:   end
// 24:
// 25:   sig { params(callable: T.nilable(Proc)).void }
// 26:   def __setobj__(callable)
// 27:     @__callable__ = callable
// 28:     @getobj_set = false
// 29:     @__getobj__ = nil
// 30:   end
// 31:
// 32:   # Forward to the inner object to make lazy objects type-checkable.
// 33:   #
// 34:   # @!visibility private
// 35:   sig { params(klass: T.any(T::Module[T.anything], T::Class[T.anything])).returns(T::Boolean) }
// 36:   def is_a?(klass)
// 37:     # see https://sorbet.org/docs/faq#how-can-i-fix-type-errors-that-arise-from-super
// 38:     T.bind(self, T.untyped)
// 39:
// 40:     __getobj__.is_a?(klass) || super
// 41:   end
// 42:
// 43:   sig { returns(T::Class[T.anything]) }
// 44:   def class = __getobj__.class
// 45:
// 46:   sig { returns(String) }
// 47:   def to_s = __getobj__.to_s
// 48: end
