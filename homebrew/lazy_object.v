module homebrew

// Translated from Homebrew/brew `lazy_object.rb`.
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
