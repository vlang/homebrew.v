module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/union.rb`.
// The original source is retained below until every stub has a typed V body.
fn union_coerce(value ruby.Value) !&BaseType {
	if type_value := base_type_from_value(value) {
		return type_value
	}
	if value.type_name in ['Class', 'Module'] {
		ancestors := value.attribute('ancestors') or { '' }
		return new_simple_base_type(value.as_string(), ancestors.split(',').filter(it.len > 0))
	}
	return error('${value.type_name} cannot be coerced to a Sorbet type')
}

fn union_contains(types []&BaseType, candidate &BaseType) bool {
	for type_value in types {
		if type_value.equals(candidate) or { false } {
			return true
		}
	}
	return false
}

pub fn new_union_type(values []ruby.Value) !&BaseType {
	mut members := []&BaseType{}
	for value in values {
		type_value := union_coerce(value)!
		if type_value.kind == .union_type {
			for nested in type_value.members {
				if !union_contains(members, nested) {
					members << nested
				}
			}
		} else if !union_contains(members, type_value) {
			members << type_value
		}
	}
	return new_union_base_type(members)
}

fn union_type_from_args(args []ruby.Value) &BaseType {
	if args.len == 0 {
		panic('Union method requires a receiver')
	}
	type_value := base_type_from_value(args[0]) or { panic(err) }
	if type_value.kind != .union_type {
		panic('invalid Union receiver')
	}
	return type_value
}

fn union_members_value(type_value &BaseType) ruby.Value {
	return ruby.array_value(type_value.members.map(base_type_boundary_value(it)))
}

fn union_is_named(type_value &BaseType, name string) bool {
	return type_value.name() or { '' } == name
}

pub fn union_type_shortcuts(types []&BaseType) string {
	if types.len == 1 {
		return types[0].name() or { '' }
	}
	if types.any(union_is_named(it, 'NilClass')) {
		remaining := types.filter(!union_is_named(it, 'NilClass'))
		return 'T.nilable(${union_type_shortcuts(remaining)})'
	}
	if types.any(union_is_named(it, 'TrueClass')) && types.any(union_is_named(it, 'FalseClass')) {
		mut remaining := [&BaseType(new_custom_base_type('T::Private::Types::StringHolder', 'T::Boolean', [], []))]
		remaining << types.filter(!union_is_named(it, 'TrueClass') && !union_is_named(it, 'FalseClass'))
		return union_type_shortcuts(remaining)
	}
	mut names := types.map(it.name() or { '' })
	names.sort()
	return 'T.any(${names.join(', ')})'
}

pub fn unwrap_nilable_union(type_value &BaseType) ?&BaseType {
	remaining := type_value.members.filter(!union_is_named(it, 'NilClass'))
	if remaining.len == type_value.members.len || remaining.len == 0 {
		return none
	}
	if remaining.len == 1 {
		return remaining[0]
	}
	return new_union_base_type(remaining)
}

pub fn union_of_type_values(type_a ruby.Value, type_b ruby.Value,
	extra []ruby.Value) !ruby.Value {
	mut values := [type_a, type_b]
	values << extra
	union_type := new_union_type(values)!
	if union_type.members.len == 1 {
		return base_type_boundary_value(union_type.members[0])
	}
	return base_type_boundary_value(union_type)
}

// Ruby method `initialize(types)` at line 9.
pub fn ruby_union_l9_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Union#initialize requires types')
	}
	return base_type_boundary_value(new_union_type(args[0].as_array() or { panic(err) }) or {
		panic(err)
	})
}

// Ruby method `types` at line 13.
pub fn ruby_union_l13_d2_types(args ...ruby.Value) ruby.Value {
	return union_members_value(union_type_from_args(args))
}

// Ruby method `build_type` at line 40.
pub fn ruby_union_l40_d3_build_type(args ...ruby.Value) ruby.Value {
	union_type_from_args(args).build_type() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `name` at line 46.
pub fn ruby_union_l46_d4_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(union_type_shortcuts(union_type_from_args(args).members))
}

// Ruby method `type_shortcuts(types)` at line 51.
pub fn ruby_union_l51_d5_type_shortcuts(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Union#type_shortcuts requires types')
	}
	values := args[1].as_array() or { panic(err) }
	mut members := []&BaseType{}
	for value in values {
		members << union_coerce(value) or { panic(err) }
	}
	return ruby.string_value(union_type_shortcuts(members))
}

// Ruby method `recursively_valid?(obj)` at line 75.
pub fn ruby_union_l75_d6_recursively_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Union#recursively_valid? requires an object')
	}
	return ruby.bool_value(union_type_from_args(args).recursively_valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `valid?(obj)` at line 101.
pub fn ruby_union_l101_d7_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Union#valid? requires an object')
	}
	return ruby.bool_value(union_type_from_args(args).valid(args[1]) or { panic(err) })
}

// Ruby method `subtype_of_single?(other)` at line 125.
pub fn ruby_union_l125_d8_subtype_of_single(args ...ruby.Value) ruby.Value {
	union_type_from_args(args)
	panic("This should never be reached if you're going through `subtype_of?` (and you should be)")
}

// Ruby method `unwrap_nilable` at line 129.
pub fn ruby_union_l129_d9_unwrap_nilable(args ...ruby.Value) ruby.Value {
	result := unwrap_nilable_union(union_type_from_args(args)) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return base_type_boundary_value(result)
}

// Ruby method `self.union_of_types(type_a, type_b, types=EMPTY_ARRAY)` at line 157.
pub fn ruby_union_l157_d10_self_union_of_types(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Union.union_of_types requires two types')
	}
	extra := if args.len > 2 {
		args[2].as_array() or { panic(err) }
	} else {
		[]ruby.Value{}
	}
	return union_of_type_values(args[0], args[1], extra) or { panic(err) }
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Takes a list of types. Validates that an object matches at least one of the types.
// 6:   class Union < Base
// 7:     # Don't use Union.new directly, use `Private::Pool.union_of_types`
// 8:     # inside sorbet-runtime and `T.any` elsewhere.
// 9:     def initialize(types)
// 10:       @inner_types = types
// 11:     end
// 12:
// 13:     def types
// 14:       @types ||= begin
// 15:         flattened = @inner_types.flat_map do |type|
// 16:           type = T::Utils.coerce(type)
// 17:           if type.is_a?(Union)
// 18:             # Simplify nested unions (mostly so `name` returns a nicer value)
// 19:             type.types
// 20:           else
// 21:             type
// 22:           end
// 23:         end.uniq
// 24:         # When every member is a plain Simple (whose valid? is exactly
// 25:         # `obj.is_a?(raw_type)`), precompute the members' raw modules so
// 26:         # valid? can skip per-member dispatch. instance_of? (the is_a? only
// 27:         # narrows for static checking) so that any Simple subclass overriding
// 28:         # valid? would be excluded. Note this snapshots the members at build
// 29:         # time.
// 30:         member_modules = []
// 31:         all_simple = flattened.all? do |type|
// 32:           type.is_a?(T::Types::Simple) && type.instance_of?(T::Types::Simple) &&
// 33:             member_modules << type.raw_type
// 34:         end
// 35:         @member_modules = all_simple ? member_modules.freeze : false
// 36:         flattened
// 37:       end
// 38:     end
// 39:
// 40:     def build_type
// 41:       types
// 42:       nil
// 43:     end
// 44:
// 45:     # overrides Base
// 46:     def name
// 47:       # Use the attr_reader here so we can override it in SimplePairUnion
// 48:       type_shortcuts(types)
// 49:     end
// 50:
// 51:     private def type_shortcuts(types)
// 52:       if types.size == 1
// 53:         # We shouldn't generally get here but it's possible if initializing the type
// 54:         # evades Sorbet's static check and we end up on the slow path, or if someone
// 55:         # is using the T:Types::Union constructor directly (the latter possibility
// 56:         # is why we don't just move the `uniq` into `Private::Pool.union_of_types`).
// 57:         return types.fetch(0).name
// 58:       end
// 59:       nilable = T::Utils.coerce(NilClass)
// 60:       trueclass = T::Utils.coerce(TrueClass)
// 61:       falseclass = T::Utils.coerce(FalseClass)
// 62:       if types.any? { |t| t == nilable }
// 63:         remaining_types = types.reject { |t| t == nilable }
// 64:         "T.nilable(#{type_shortcuts(remaining_types)})"
// 65:       elsif types.any? { |t| t == trueclass } && types.any? { |t| t == falseclass }
// 66:         remaining_types = types.reject { |t| t == trueclass || t == falseclass }
// 67:         type_shortcuts([T::Private::Types::StringHolder.new("T::Boolean")] + remaining_types)
// 68:       else
// 69:         names = types.map(&:name).compact.sort
// 70:         "T.any(#{names.join(', ')})"
// 71:       end
// 72:     end
// 73:
// 74:     # overrides Base
// 75:     def recursively_valid?(obj)
// 76:       member_modules = @member_modules
// 77:       if member_modules.nil?
// 78:         # Force the lazy types builder, which also computes @member_modules
// 79:         types
// 80:         member_modules = @member_modules
// 81:       end
// 82:       index = 0
// 83:       if member_modules
// 84:         # For an all-Simple union, recursively_valid? and valid? coincide
// 85:         # (Simple's recursively_valid? is exactly `obj.is_a?(raw_type)`).
// 86:         while index < member_modules.length
// 87:           return true if obj.is_a?(member_modules[index])
// 88:           index += 1
// 89:         end
// 90:       else
// 91:         members = types
// 92:         while index < members.length
// 93:           return true if members.fetch(index).recursively_valid?(obj)
// 94:           index += 1
// 95:         end
// 96:       end
// 97:       false
// 98:     end
// 99:
// 100:     # overrides Base
// 101:     def valid?(obj)
// 102:       member_modules = @member_modules
// 103:       if member_modules.nil?
// 104:         # Force the lazy types builder, which also computes @member_modules
// 105:         types
// 106:         member_modules = @member_modules
// 107:       end
// 108:       index = 0
// 109:       if member_modules
// 110:         while index < member_modules.length
// 111:           return true if obj.is_a?(member_modules[index])
// 112:           index += 1
// 113:         end
// 114:       else
// 115:         members = types
// 116:         while index < members.length
// 117:           return true if members.fetch(index).valid?(obj)
// 118:           index += 1
// 119:         end
// 120:       end
// 121:       false
// 122:     end
// 123:
// 124:     # overrides Base
// 125:     private def subtype_of_single?(other)
// 126:       raise "This should never be reached if you're going through `subtype_of?` (and you should be)"
// 127:     end
// 128:
// 129:     def unwrap_nilable
// 130:       non_nil_types = types.reject { |t| t == T::Utils::Nilable::NIL_TYPE }
// 131:       return nil if types.length == non_nil_types.length
// 132:       case non_nil_types.length
// 133:       when 0 then nil
// 134:       when 1 then non_nil_types.first
// 135:       else
// 136:         T::Types::Union::Private::Pool.union_of_types(non_nil_types[0], non_nil_types[1], non_nil_types[2..-1])
// 137:       end
// 138:     end
// 139:
// 140:     module Private
// 141:       module Pool
// 142:         EMPTY_ARRAY = [].freeze
// 143:         private_constant :EMPTY_ARRAY
// 144:
// 145:         # Try to use `to_nilable` on a type to get memoization, or failing that
// 146:         # try to at least use SimplePairUnion to get faster init and typechecking.
// 147:         #
// 148:         # We aren't guaranteed to detect a simple `T.nilable(<Module>)` type here
// 149:         # in cases where there are duplicate types, nested unions, etc.
// 150:         #
// 151:         # That's ok, because returning is SimplePairUnion an optimization which
// 152:         # isn't necessary for correctness.
// 153:         #
// 154:         # @param type_a [T::Types::Base]
// 155:         # @param type_b [T::Types::Base]
// 156:         # @param types [Array] optional array of additional T::Types::Base instances
// 157:         def self.union_of_types(type_a, type_b, types=EMPTY_ARRAY)
// 158:           if !types.empty?
// 159:             # Slow path
// 160:             return Union.new([type_a, type_b] + types)
// 161:           elsif !type_a.is_a?(T::Types::Simple) || !type_b.is_a?(T::Types::Simple)
// 162:             # Slow path
// 163:             return Union.new([type_a, type_b])
// 164:           end
// 165:
// 166:           begin
// 167:             # The `equal?` checks are an identity fast path: NIL_TYPE is the pooled
// 168:             # `coerce(NilClass)` instance, so it hits on every normal `T.nilable` call.
// 169:             # The `==` fallbacks preserve semantics for hand-constructed
// 170:             # `Simple.new(NilClass)` instances that bypass the pool.
// 171:             if type_b.equal?(T::Utils::Nilable::NIL_TYPE) || type_b == T::Utils::Nilable::NIL_TYPE
// 172:               type_a.to_nilable
// 173:             elsif type_a.equal?(T::Utils::Nilable::NIL_TYPE) || type_a == T::Utils::Nilable::NIL_TYPE
// 174:               type_b.to_nilable
// 175:             else
// 176:               T::Private::Types::SimplePairUnion.new(type_a, type_b)
// 177:             end
// 178:           rescue T::Private::Types::SimplePairUnion::DuplicateType
// 179:             # Slow path
// 180:             #
// 181:             # This shouldn't normally be possible due to static checks,
// 182:             # but we can get here if we're constructing a type dynamically.
// 183:             #
// 184:             # Relying on the duplicate check in the constructor has the
// 185:             # advantage that we avoid it when we hit the memoized case
// 186:             # of `to_nilable`.
// 187:             type_a
// 188:           end
// 189:         end
// 190:       end
// 191:     end
// 192:   end
// 193: end
