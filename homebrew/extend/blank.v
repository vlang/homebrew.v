module extend

import brew_runtime

// Translated from Homebrew/brew `extend/blank.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank?` at line 21.
pub fn ruby_blank_l21_d1_blank(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('blank?', ...args)
}

// Ruby method `present? = !blank?` at line 27.
pub fn ruby_blank_l27_d2_present(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('present?', ...args)
}

// Ruby method `presence` at line 47.
pub fn ruby_blank_l47_d3_presence(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('presence', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Object
// 5:   # An object is blank if it's false, empty, or a whitespace string.
// 6:   #
// 7:   # For example, `nil`, `''`, `'   '`, `[]`, `{}` and `false` are all blank.
// 8:   #
// 9:   # ### Example
// 10:   #
// 11:   # ```ruby
// 12:   # !address || address.empty?
// 13:   # ```
// 14:   #
// 15:   # can be simplified to
// 16:   #
// 17:   # ```ruby
// 18:   # address.blank?
// 19:   # ```
// 20:   sig { returns(T::Boolean) }
// 21:   def blank?
// 22:     respond_to?(:empty?) ? !!T.unsafe(self).empty? : false
// 23:   end
// 24:
// 25:   # An object is present if it's not blank.
// 26:   sig { returns(T::Boolean) }
// 27:   def present? = !blank?
// 28:
// 29:   # Returns the receiver if it's present, otherwise returns `nil`.
// 30:   #
// 31:   # `object.presence` is equivalent to `object.present? ? object : nil`.
// 32:   #
// 33:   # ### Example
// 34:   #
// 35:   # ```ruby
// 36:   # state   = params[:state]   if params[:state].present?
// 37:   # country = params[:country] if params[:country].present?
// 38:   # region  = state || country || 'US'
// 39:   # ```
// 40:   #
// 41:   # can be simplified to
// 42:   #
// 43:   # ```ruby
// 44:   # region = params[:state].presence || params[:country].presence || 'US'
// 45:   # ```
// 46:   sig { returns(T.nilable(T.self_type)) }
// 47:   def presence
// 48:     self if present?
// 49:   end
// 50: end
// 51: require "extend/blank/nil_class"
// 52: require "extend/blank/false_class"
// 53: require "extend/blank/true_class"
// 54: require "extend/blank/array"
// 55: require "extend/blank/hash"
// 56: require "extend/blank/symbol"
// 57: require "extend/blank/string"
// 58: require "extend/blank/numeric"
// 59: require "extend/blank/pathname"
// 60: require "extend/blank/time"
