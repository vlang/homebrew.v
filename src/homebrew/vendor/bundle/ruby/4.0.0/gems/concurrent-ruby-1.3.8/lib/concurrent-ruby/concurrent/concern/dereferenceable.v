module concern

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/concern/dereferenceable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `value` at line 21.
pub fn ruby_dereferenceable_l21_d1_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby alias_method `alias_method :deref, :value` at line 24.
pub fn ruby_dereferenceable_l24_d2_deref(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deref', ...args)
}

// Ruby method `value=(value)` at line 31.
pub fn ruby_dereferenceable_l31_d3_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value=', ...args)
}

// Ruby method `set_deref_options(opts = {})` at line 48.
pub fn ruby_dereferenceable_l48_d4_set_deref_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_deref_options', ...args)
}

// Ruby method `ns_set_deref_options(opts)` at line 54.
pub fn ruby_dereferenceable_l54_d5_ns_set_deref_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_set_deref_options', ...args)
}

// Ruby method `apply_deref_options(value)` at line 63.
pub fn ruby_dereferenceable_l63_d6_apply_deref_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('apply_deref_options', ...args)
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:   module Concern
// 3:
// 4:     # Object references in Ruby are mutable. This can lead to serious problems when
// 5:     # the `#value` of a concurrent object is a mutable reference. Which is always the
// 6:     # case unless the value is a `Fixnum`, `Symbol`, or similar "primitive" data type.
// 7:     # Most classes in this library that expose a `#value` getter method do so using the
// 8:     # `Dereferenceable` mixin module.
// 9:     #
// 10:     # @!macro copy_options
// 11:     module Dereferenceable
// 12:       # NOTE: This module is going away in 2.0. In the mean time we need it to
// 13:       # play nicely with the synchronization layer. This means that the
// 14:       # including class SHOULD be synchronized and it MUST implement a
// 15:       # `#synchronize` method. Not doing so will lead to runtime errors.
// 16:
// 17:       # Return the value this object represents after applying the options specified
// 18:       # by the `#set_deref_options` method.
// 19:       #
// 20:       # @return [Object] the current value of the object
// 21:       def value
// 22:         synchronize { apply_deref_options(@value) }
// 23:       end
// 24:       alias_method :deref, :value
// 25:
// 26:       protected
// 27:
// 28:       # Set the internal value of this object
// 29:       #
// 30:       # @param [Object] value the new value
// 31:       def value=(value)
// 32:         synchronize{ @value = value }
// 33:       end
// 34:
// 35:       # @!macro dereferenceable_set_deref_options
// 36:       #   Set the options which define the operations #value performs before
// 37:       #   returning data to the caller (dereferencing).
// 38:       #
// 39:       #   @note Most classes that include this module will call `#set_deref_options`
// 40:       #     from within the constructor, thus allowing these options to be set at
// 41:       #     object creation.
// 42:       #
// 43:       #   @param [Hash] opts the options defining dereference behavior.
// 44:       #   @option opts [String] :dup_on_deref (false) call `#dup` before returning the data
// 45:       #   @option opts [String] :freeze_on_deref (false) call `#freeze` before returning the data
// 46:       #   @option opts [String] :copy_on_deref (nil) call the given `Proc` passing
// 47:       #     the internal value and returning the value returned from the proc
// 48:       def set_deref_options(opts = {})
// 49:         synchronize{ ns_set_deref_options(opts) }
// 50:       end
// 51:
// 52:       # @!macro dereferenceable_set_deref_options
// 53:       # @!visibility private
// 54:       def ns_set_deref_options(opts)
// 55:         @dup_on_deref = opts[:dup_on_deref] || opts[:dup]
// 56:         @freeze_on_deref = opts[:freeze_on_deref] || opts[:freeze]
// 57:         @copy_on_deref = opts[:copy_on_deref] || opts[:copy]
// 58:         @do_nothing_on_deref = !(@dup_on_deref || @freeze_on_deref || @copy_on_deref)
// 59:         nil
// 60:       end
// 61:
// 62:       # @!visibility private
// 63:       def apply_deref_options(value)
// 64:         return nil if value.nil?
// 65:         return value if @do_nothing_on_deref
// 66:         value = @copy_on_deref.call(value) if @copy_on_deref
// 67:         value = value.dup if @dup_on_deref
// 68:         value = value.freeze if @freeze_on_deref
// 69:         value
// 70:       end
// 71:     end
// 72:   end
// 73: end
