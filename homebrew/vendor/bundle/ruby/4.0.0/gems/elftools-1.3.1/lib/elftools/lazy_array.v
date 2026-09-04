module elftools

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/lazy_array.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct LazyArray[T] {
	loader fn(int) T = unsafe { nil }
pub:
	size int
mut:
	values []T
	loaded []bool
}

pub fn new_lazy_array[T](size int, loader fn(int) T) !&LazyArray[T] {
	if size < 0 {
		return error('negative array size')
	}
	return &LazyArray[T]{
		size: size
		loader: loader
		values: []T{len: size}
		loaded: []bool{len: size}
	}
}

pub fn (array &LazyArray[T]) len() int {
	return array.size
}

pub fn (mut array LazyArray[T]) get(index int) ?T {
	if index < 0 || index >= array.size {
		return none
	}
	if !array.loaded[index] {
		array.values[index] = array.loader(index)
		array.loaded[index] = true
	}
	return array.values[index]
}

pub fn (mut array LazyArray[T]) to_array() []T {
	mut result := []T{cap: array.size}
	for index in 0 .. array.size {
		result << array.get(index) or { panic('in-bounds lazy array element is missing') }
	}
	return result
}

pub fn lazy_array_map[T, U](mut array LazyArray[T], transform fn(T) U) []U {
	mut result := []U{cap: array.size}
	for value in array.to_array() {
		result << transform(value)
	}
	return result
}

pub fn (mut array LazyArray[T]) last() ?T {
	if array.size == 0 {
		return none
	}
	return array.get(array.size - 1)
}

pub fn (mut array LazyArray[T]) contains(value T) bool {
	for current in array.to_array() {
		if current == value {
			return true
		}
	}
	return false
}

pub fn (mut array LazyArray[T]) inspect() string {
	return array.to_array().str()
}

pub fn (array &LazyArray[T]) responds_to_array_method(name string) bool {
	return name in ['[]', 'size', 'length', 'to_a', 'map', 'last', 'include?', 'inspect']
}

fn lazy_array_boundary(size int, values []ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: 'ELFTools::LazyArray'
		repr: values.map(it.repr).str()
		int_data: i64(size)
		array_data: values.clone()
		attributes: {
			'size': size.str()
		}
	}
}

// Ruby method `initialize(size, &block)` at line 30.
pub fn ruby_lazy_array_l30_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('LazyArray#initialize requires a size')
	}
	size := int(args[0].as_int() or { panic(err) })
	if size < 0 {
		panic('negative array size')
	}
	mut values := []ruby.Value{len: size, init: ruby.object_value('NilClass', 'nil')}
	// A `ruby.Value` cannot carry a V closure. At this generic boundary,
	// an optional Array argument represents the block's indexed results; native
	// callers use `new_lazy_array` above and retain true on-demand evaluation.
	if args.len > 1 && args[1].type_name == 'Array' {
		provided := args[1].as_array() or { panic(err) }
		limit := if provided.len < size { provided.len } else { size }
		for index in 0 .. limit {
			values[index] = provided[index]
		}
	}
	return lazy_array_boundary(size, values)
}

// Ruby method `[](i)` at line 42.
pub fn ruby_lazy_array_l42_d2_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('LazyArray#[] requires a receiver and index')
	}
	size := (args[0].attribute('size') or { args[0].array_data.len.str() }).int()
	index := int(args[1].as_int() or { panic(err) })
	if index < 0 || index >= size || index >= args[0].array_data.len {
		return ruby.object_value('NilClass', 'nil')
	}
	return args[0].array_data[index]
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'delegate'
// 4:
// 5: module ELFTools
// 6:   # A helper class for {ELFTools} easy to implement
// 7:   # 'lazy loading' objects.
// 8:   # Mainly used when loading sections, segments, and
// 9:   # symbols.
// 10:   class LazyArray < SimpleDelegator
// 11:     # Instantiate a {LazyArray} object.
// 12:     # @param [Integer] size
// 13:     #   The size of array.
// 14:     # @yieldparam [Integer] i
// 15:     #   Needs the +i+-th element.
// 16:     # @yieldreturn [Object]
// 17:     #   Value of the +i+-th element.
// 18:     # @example
// 19:     #   arr = LazyArray.new(10) { |i| p "calc #{i}"; i * i }
// 20:     #   p arr[2]
// 21:     #   # "calc 2"
// 22:     #   # 4
// 23:     #
// 24:     #   p arr[3]
// 25:     #   # "calc 3"
// 26:     #   # 9
// 27:     #
// 28:     #   p arr[3]
// 29:     #   # 9
// 30:     def initialize(size, &block)
// 31:       super(Array.new(size))
// 32:       @block = block
// 33:     end
// 34:
// 35:     # To access elements like a normal array.
// 36:     #
// 37:     # Elements are lazy loaded at the first time
// 38:     # access it.
// 39:     # @return [Object]
// 40:     #   The element, returned type is the
// 41:     #   return type of block given in {#initialize}.
// 42:     def [](i)
// 43:       # XXX: support negative index?
// 44:       return nil unless i.between?(0, __getobj__.size - 1)
// 45:
// 46:       __getobj__[i] ||= @block.call(i)
// 47:     end
// 48:   end
// 49: end
