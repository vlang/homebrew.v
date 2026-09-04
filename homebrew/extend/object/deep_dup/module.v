module deep_dup

import ruby

// Translated from Homebrew/brew `extend/object/deep_dup/module.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `deep_dup` at line 12.
pub fn ruby_module_l12_d1_deep_dup(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.Value{}
	}
	return deep_dup_module(args[0], args[0].attribute('name') or { '' })
}

// deep_dup_module preserves named modules and copies anonymous modules.
pub fn deep_dup_module(value ruby.Value, name string) ruby.Value {
	if name.len > 0 {
		return value
	}
	return ruby.Value{
		...value
		string_array_data: value.string_array_data.clone()
		array_data:        value.array_data.clone()
		attributes:        value.attributes.clone()
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Module
// 5:   # Returns a copy of module or class if it's anonymous. If it's
// 6:   # named, returns +self+.
// 7:   #
// 8:   #   Object.deep_dup == Object # => true
// 9:   #   klass = Class.new
// 10:   #   klass.deep_dup == klass # => false
// 11:   sig { returns(T.self_type) }
// 12:   def deep_dup
// 13:     if name.nil?
// 14:       super
// 15:     else
// 16:       self
// 17:     end
// 18:   end
// 19: end
