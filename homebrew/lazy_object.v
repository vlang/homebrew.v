module homebrew

// Translated from Homebrew/brew `lazy_object.rb`.
// The original source is retained below until every stub has a typed V body.
pub type LazyValueFactory[T] = fn () !T

pub struct LazyObject[T] {
mut:
	callable    LazyValueFactory[T] @[required]
	getobj_set  bool
	object      T
	evaluations int
}

pub fn (object &LazyObject[T]) evaluated[T]() bool {
	return object.getobj_set
}

pub fn (object &LazyObject[T]) evaluation_count[T]() int {
	return object.evaluations
}

// Ruby method `initialize(&callable)` at line 9.
pub fn new_lazy_object[T](callable LazyValueFactory[T]) LazyObject[T] {
	return LazyObject[T]{
		callable: callable
	}
}

// Ruby method `__getobj__(&_blk)` at line 17.
pub fn (mut object LazyObject[T]) get[T]() !T {
	if object.getobj_set {
		return object.object
	}
	object.object = object.callable()!
	object.getobj_set = true
	object.evaluations++
	return object.object
}

// Ruby method `__setobj__(callable)` at line 26.
pub fn (mut object LazyObject[T]) set_factory[T](callable LazyValueFactory[T]) {
	object.callable = callable
	object.getobj_set = false
}

// Ruby method `is_a?(klass)` at line 36.
pub fn (mut object LazyObject[T]) is_a[T](predicate fn (T) bool) !bool {
	return predicate(object.get()!)
}

// Ruby method `class = __getobj__.class` at line 44.
pub fn (mut object LazyObject[T]) value_type_name[T]() !string {
	_ = object.get()!
	return $typeof(object.object).name
}

// Ruby method `to_s = __getobj__.to_s` at line 47.
pub fn (mut object LazyObject[T]) string[T]() !string {
	return '${object.get()!}'
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
