module elftools

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/lazy_array.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(size, &block)` at line 30.
pub fn ruby_lazy_array_l30_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `[](i)` at line 42.
pub fn ruby_lazy_array_l42_d2_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]', ...args)
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
