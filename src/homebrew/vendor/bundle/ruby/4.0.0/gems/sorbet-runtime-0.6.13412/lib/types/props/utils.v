module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/utils.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.deep_clone_object(what, freeze: false)` at line 7.
pub fn ruby_utils_l7_d1_self_deep_clone_object(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.deep_clone_object', ...args)
}

// Ruby method `self.deep_clone(what)` at line 15.
pub fn ruby_utils_l15_d2_self_deep_clone(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.deep_clone', ...args)
}

// Ruby method `self.deep_clone_freeze(what)` at line 39.
pub fn ruby_utils_l39_d3_self_deep_clone_freeze(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.deep_clone_freeze', ...args)
}

// Ruby method `self.need_nil_read_check?(prop_rules)` at line 64.
pub fn ruby_utils_l64_d4_self_need_nil_read_check(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.need_nil_read_check?', ...args)
}

// Ruby method `self.need_nil_write_check?(prop_rules)` at line 70.
pub fn ruby_utils_l70_d5_self_need_nil_write_check(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.need_nil_write_check?', ...args)
}

// Ruby method `self.required_prop?(prop_rules)` at line 74.
pub fn ruby_utils_l74_d6_self_required_prop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.required_prop?', ...args)
}

// Ruby method `self.optional_prop?(prop_rules)` at line 79.
pub fn ruby_utils_l79_d7_self_optional_prop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.optional_prop?', ...args)
}

// Ruby method `self.merge_serialized_optional_rule(prop_rules)` at line 84.
pub fn ruby_utils_l84_d8_self_merge_serialized_optional_rule(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.merge_serialized_optional_rule', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Props::Utils
// 5:   # Deep copy an object. The object must consist of Ruby primitive
// 6:   # types and Hashes and Arrays.
// 7:   def self.deep_clone_object(what, freeze: false)
// 8:     freeze ? deep_clone_freeze(what) : deep_clone(what)
// 9:   end
// 10:
// 11:   # deep_clone_object with freeze: false. Kept kwarg-free, with String (the
// 12:   # most common serialized scalar) tested first: this is what generated
// 13:   # serializers/deserializers emit for dynamic fallbacks, so it runs per
// 14:   # element of every untyped container prop.
// 15:   def self.deep_clone(what)
// 16:     case what
// 17:     when String
// 18:       what.clone
// 19:     when true, false, Symbol, NilClass, Numeric
// 20:       what
// 21:     when Array
// 22:       what.map { |v| deep_clone(v) }
// 23:     when Hash
// 24:       h = what.class.new
// 25:       what.each_pair do |k, v|
// 26:         h[k] = deep_clone(v)
// 27:       end
// 28:       h
// 29:     when Regexp
// 30:       what.dup
// 31:     when T::Enum
// 32:       what
// 33:     else
// 34:       what.clone
// 35:     end
// 36:   end
// 37:
// 38:   # deep_clone_object with freeze: true.
// 39:   def self.deep_clone_freeze(what)
// 40:     result = case what
// 41:     when true, false, Symbol, NilClass, Numeric
// 42:       what
// 43:     when Array
// 44:       what.map { |v| deep_clone_freeze(v) }
// 45:     when Hash
// 46:       h = what.class.new
// 47:       what.each_pair do |k, v|
// 48:         k.freeze
// 49:         h[k] = deep_clone_freeze(v)
// 50:       end
// 51:       h
// 52:     when Regexp
// 53:       what.dup
// 54:     when T::Enum
// 55:       what
// 56:     else
// 57:       what.clone
// 58:     end
// 59:     result.freeze
// 60:   end
// 61:
// 62:   # The prop_rules indicate whether we should check for reading a nil value for the prop/field.
// 63:   # This is mostly for the compatibility check that we allow existing documents carry some nil prop/field.
// 64:   def self.need_nil_read_check?(prop_rules)
// 65:     # . :on_load allows nil read, but we need to check for the read for future writes
// 66:     prop_rules[:optional] == :on_load || prop_rules[:raise_on_nil_write]
// 67:   end
// 68:
// 69:   # The prop_rules indicate whether we should check for writing a nil value for the prop/field.
// 70:   def self.need_nil_write_check?(prop_rules)
// 71:     need_nil_read_check?(prop_rules) || T::Props::Utils.required_prop?(prop_rules)
// 72:   end
// 73:
// 74:   def self.required_prop?(prop_rules)
// 75:     # Clients should never reference :_tnilable as the implementation can change.
// 76:     !prop_rules[:_tnilable]
// 77:   end
// 78:
// 79:   def self.optional_prop?(prop_rules)
// 80:     # Clients should never reference :_tnilable as the implementation can change.
// 81:     !!prop_rules[:_tnilable]
// 82:   end
// 83:
// 84:   def self.merge_serialized_optional_rule(prop_rules)
// 85:     {'_tnilable' => true}.merge(prop_rules.merge('_tnilable' => true))
// 86:   end
// 87: end
