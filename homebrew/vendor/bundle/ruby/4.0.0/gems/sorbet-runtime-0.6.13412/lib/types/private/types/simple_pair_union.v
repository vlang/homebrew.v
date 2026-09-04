module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/types/simple_pair_union.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct SimplePairUnion {
pub:
	type_a ruby.Value
	type_b ruby.Value
	raw_a  ruby.Value
	raw_b  ruby.Value
}

fn pair_simple_name(type_value ruby.Value) string {
	return type_value.attribute('raw_type') or { type_value.as_string() }
}

fn pair_simple_raw(type_value ruby.Value) ruby.Value {
	return type_value.map_data['raw_type'] or {
		ruby.object_value('Class', pair_simple_name(type_value))
	}
}

pub fn new_simple_pair_union(type_a ruby.Value, type_b ruby.Value) !&SimplePairUnion {
	if pair_simple_name(type_a) == pair_simple_name(type_b) {
		return error('${pair_simple_name(type_a)} == ${pair_simple_name(type_b)}')
	}
	return &SimplePairUnion{
		type_a: type_a
		type_b: type_b
		raw_a: pair_simple_raw(type_a)
		raw_b: pair_simple_raw(type_b)
	}
}

pub fn (pair &SimplePairUnion) recursively_valid(value ruby.Value) bool {
	return pair.valid(value)
}

pub fn (pair &SimplePairUnion) valid(value ruby.Value) bool {
	return pair_raw_accepts(pair.raw_a, value) || pair_raw_accepts(pair.raw_b, value)
}

fn pair_raw_accepts(raw_type ruby.Value, value ruby.Value) bool {
	expected := raw_type.as_string()
	if value.type_name == expected {
		return true
	}
	ancestors := value.attribute('ancestors') or { return false }
	return ancestors.split(',').map(it.trim_space()).any(it == expected)
}

pub fn (pair &SimplePairUnion) types() []ruby.Value {
	// Reconstructing through the pool preserves the source's weakly pooled type identity.
	return [pair.type_a, pair.type_b]
}

pub fn (pair &SimplePairUnion) unwrap_nilable() ?ruby.Value {
	types := pair.types()
	if pair.raw_a.as_string() == 'NilClass' {
		return types[1]
	}
	if pair.raw_b.as_string() == 'NilClass' {
		return types[0]
	}
	return none
}

fn simple_pair_union_value(pair &SimplePairUnion) ruby.Value {
	mut names := [pair_simple_name(pair.type_a), pair_simple_name(pair.type_b)]
	names.sort()
	representation := if pair.raw_a.as_string() == 'NilClass' {
		'T.nilable(${pair_simple_name(pair.type_b)})'
	} else if pair.raw_b.as_string() == 'NilClass' {
		'T.nilable(${pair_simple_name(pair.type_a)})'
	} else {
		'T.any(${names.join(', ')})'
	}
	return ruby.Value{
		type_name: 'T::Private::Types::SimplePairUnion'
		repr: representation
		array_data: pair.types()
		attributes: {
			'simple_pair_union_address': u64(voidptr(pair)).str()
		}
	}
}

fn simple_pair_union_from_args(args []ruby.Value) &SimplePairUnion {
	if args.len == 0 {
		panic('SimplePairUnion method requires a receiver')
	}
	address := args[0].attribute('simple_pair_union_address') or {
		panic('invalid SimplePairUnion receiver')
	}
	return unsafe { &SimplePairUnion(voidptr(address.u64())) }
}

// Ruby method `initialize(type_a, type_b)` at line 12.
pub fn ruby_simple_pair_union_l12_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('SimplePairUnion#initialize requires two types')
	}
	return simple_pair_union_value(new_simple_pair_union(args[0], args[1]) or { panic(err) })
}

// Ruby method `recursively_valid?(obj)` at line 22.
pub fn ruby_simple_pair_union_l22_d2_recursively_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('SimplePairUnion#recursively_valid? requires an object')
	}
	return ruby.bool_value(simple_pair_union_from_args(args).recursively_valid(args[1]))
}

// Ruby method `valid?(obj)` at line 27.
pub fn ruby_simple_pair_union_l27_d3_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('SimplePairUnion#valid? requires an object')
	}
	return ruby.bool_value(simple_pair_union_from_args(args).valid(args[1]))
}

// Ruby method `types` at line 32.
pub fn ruby_simple_pair_union_l32_d4_types(args ...ruby.Value) ruby.Value {
	return ruby.array_value(simple_pair_union_from_args(args).types())
}

// Ruby method `unwrap_nilable` at line 44.
pub fn ruby_simple_pair_union_l44_d5_unwrap_nilable(args ...ruby.Value) ruby.Value {
	result := simple_pair_union_from_args(args).unwrap_nilable() or {
		return ruby.object_value('NilClass', 'nil')
	}
	return result
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Specialization of Union for the common case of the union of two simple types.
// 5: #
// 6: # This covers e.g. T.nilable(SomeModule), T.any(Integer, Float), and T::Boolean.
// 7: class T::Private::Types::SimplePairUnion < T::Types::Union
// 8:   class DuplicateType < RuntimeError; end
// 9:
// 10:   # @param type_a [T::Types::Simple]
// 11:   # @param type_b [T::Types::Simple]
// 12:   def initialize(type_a, type_b)
// 13:     if type_a == type_b
// 14:       raise DuplicateType.new("#{type_a} == #{type_b}")
// 15:     end
// 16:
// 17:     @raw_a = type_a.raw_type
// 18:     @raw_b = type_b.raw_type
// 19:   end
// 20:
// 21:   # @override Union
// 22:   def recursively_valid?(obj)
// 23:     obj.is_a?(@raw_a) || obj.is_a?(@raw_b)
// 24:   end
// 25:
// 26:   # @override Union
// 27:   def valid?(obj)
// 28:     obj.is_a?(@raw_a) || obj.is_a?(@raw_b)
// 29:   end
// 30:
// 31:   # @override Union
// 32:   def types
// 33:     # We reconstruct the simple types rather than just storing them because
// 34:     # (1) this is normally not a hot path and (2) we want to keep the instance
// 35:     # variable count <= 3 so that we can fit in a 40 byte heap entry along
// 36:     # with object headers.
// 37:     @types ||= [
// 38:       T::Types::Simple::Private::Pool.type_for_module(@raw_a),
// 39:       T::Types::Simple::Private::Pool.type_for_module(@raw_b),
// 40:     ]
// 41:   end
// 42:
// 43:   # overrides Union
// 44:   def unwrap_nilable
// 45:     a_nil = @raw_a.equal?(NilClass)
// 46:     b_nil = @raw_b.equal?(NilClass)
// 47:     if a_nil
// 48:       return types[1]
// 49:     end
// 50:     if b_nil
// 51:       return types[0]
// 52:     end
// 53:     nil
// 54:   end
// 55: end
