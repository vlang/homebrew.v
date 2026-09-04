module object

import ruby

// Translated from Homebrew/brew `extend/object/duplicable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `duplicable? = true` at line 30.
pub fn ruby_duplicable_l30_d1_duplicable(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// is_duplicable reports the default Object#duplicable? result. Callers carrying
// reflection objects use one of the non-duplicable type names below.
pub fn is_duplicable(value ruby.Value) bool {
	return value.type_name !in ['Method', 'UnboundMethod', 'Singleton']
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Most objects are cloneable, but not all. For example you can't dup methods:
// 5: #
// 6: # ```ruby
// 7: # method(:puts).dup # => TypeError: allocator undefined for Method
// 8: # ```
// 9: #
// 10: # Classes may signal their instances are not duplicable removing +dup+/+clone+
// 11: # or raising exceptions from them. So, to dup an arbitrary object you normally
// 12: # use an optimistic approach and are ready to catch an exception, say:
// 13: #
// 14: # ```ruby
// 15: # arbitrary_object.dup rescue object
// 16: # ```
// 17: #
// 18: # Rails dups objects in a few critical spots where they are not that arbitrary.
// 19: # That `rescue` is very expensive (like 40 times slower than a predicate) and it
// 20: # is often triggered.
// 21: #
// 22: # That's why we hardcode the following cases and check duplicable? instead of
// 23: # using that rescue idiom.
// 24: class Object
// 25:   # Can you safely dup this object?
// 26:   #
// 27:   # False for method objects;
// 28:   # true otherwise.
// 29:   sig { returns(T::Boolean) }
// 30:   def duplicable? = true
// 31: end
// 32: require "extend/object/duplicable/method"
// 33: require "extend/object/duplicable/unbound_method"
// 34:
// 35: require "singleton"
// 36: require "extend/object/duplicable/singleton"
