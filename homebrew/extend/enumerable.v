module extend

import ruby
import homebrew.extend.blank

// Translated from Homebrew/brew `extend/enumerable.rb`.
// The original source is retained below until every stub has a typed V body.

pub fn enumerable_excludes[T](values []T, object T) bool {
	return object !in values
}

pub fn compact_blank_values(values []ruby.Value) []ruby.Value {
	return values.filter(blank.value_is_present(it))
}

// Ruby method `exclude?(object) = !include?(object)` at line 8.
pub fn ruby_enumerable_l8_d1_exclude(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Enumerable#exclude? requires a receiver and object') }
	values := args[0].as_array() or { panic(err) }
	object := args[1]
	return ruby.bool_value(!values.any(it.type_name == object.type_name
		&& it.repr == object.repr))
}

// Ruby method `compact_blank = T.unsafe(self).reject(&:blank?)` at line 32.
pub fn ruby_enumerable_l32_d2_compact_blank(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Enumerable#compact_blank requires a receiver') }
	return ruby.array_value(compact_blank_values(args[0].as_array() or { panic(err) }))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Enumerable
// 5:   # The negative of the {Enumerable#include?}. Returns `true` if the
// 6:   # collection does not include the object.
// 7:   sig { params(object: T.untyped).returns(T::Boolean) }
// 8:   def exclude?(object) = !include?(object)
// 9:
// 10:   # Returns a new +Array+ without the blank items.
// 11:   # Uses Object#blank? for determining if an item is blank.
// 12:   #
// 13:   # ### Examples
// 14:   #
// 15:   # ```
// 16:   # [1, "", nil, 2, " ", [], {}, false, true].compact_blank
// 17:   # # =>  [1, 2, true]
// 18:   # ```
// 19:   #
// 20:   # ```ruby
// 21:   # Set.new([nil, "", 1, false]).compact_blank
// 22:   # # => [1]
// 23:   # ```
// 24:   #
// 25:   # When called on a {Hash}, returns a new {Hash} without the blank values.
// 26:   #
// 27:   # ```ruby
// 28:   # { a: "", b: 1, c: nil, d: [], e: false, f: true }.compact_blank
// 29:   # # => { b: 1, f: true }
// 30:   # ```
// 31:   sig { returns(T.self_type) }
// 32:   def compact_blank = T.unsafe(self).reject(&:blank?)
// 33: end
// 34: require "extend/enumerable/hash"
