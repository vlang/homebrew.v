module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/base.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.method_added(method_name)` at line 6.
pub fn ruby_base_l6_d1_self_method_added(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.method_added', ...args)
}

// Ruby method `recursively_valid?(obj)` at line 20.
pub fn ruby_base_l20_d2_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursively_valid?', ...args)
}

// Ruby define_method `define_method(:valid?) do |_obj|` at line 24.
pub fn ruby_base_l24_d3_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(type)` at line 32.
pub fn ruby_base_l32_d4_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Ruby define_method `define_method(:build_type) do` at line 38.
pub fn ruby_base_l38_d5_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby define_method `define_method(:name) do` at line 43.
pub fn ruby_base_l43_d6_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `subtype_of?(t2)` at line 52.
pub fn ruby_base_l52_d7_subtype_of(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of?', ...args)
}

// Ruby method `to_s` at line 132.
pub fn ruby_base_l132_d8_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `describe_obj(obj)` at line 136.
pub fn ruby_base_l136_d9_describe_obj(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('describe_obj', ...args)
}

// Ruby method `error_message_for_obj(obj)` at line 158.
pub fn ruby_base_l158_d10_error_message_for_obj(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error_message_for_obj', ...args)
}

// Ruby method `error_message_for_obj_recursive(obj)` at line 166.
pub fn ruby_base_l166_d11_error_message_for_obj_recursive(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error_message_for_obj_recursive', ...args)
}

// Ruby method `error_message(obj)` at line 174.
pub fn ruby_base_l174_d12_error_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error_message', ...args)
}

// Ruby method `validate!(obj)` at line 178.
pub fn ruby_base_l178_d13_validate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validate!', ...args)
}

// Ruby method `hash` at line 185.
pub fn ruby_base_l185_d14_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hash', ...args)
}

// Ruby method `==(other)` at line 191.
pub fn ruby_base_l191_d15_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby alias_method `alias_method :eql?, :==` at line 203.
pub fn ruby_base_l203_d16_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class Base
// 6:     def self.method_added(method_name)
// 7:       super(method_name)
// 8:       # What is now `subtype_of_single?` used to be named `subtype_of?`. Make sure people don't
// 9:       # override the wrong thing.
// 10:       #
// 11:       # NB: Outside of T::Types, we would enforce this by using `sig` and not declaring the method
// 12:       # as overridable, but doing so here would result in a dependency cycle.
// 13:       if method_name == :subtype_of? && self != T::Types::Base
// 14:         raise "`subtype_of?` should not be overridden. You probably want to override " \
// 15:               "`subtype_of_single?` instead."
// 16:       end
// 17:     end
// 18:
// 19:     # this will be redefined in certain subclasses
// 20:     def recursively_valid?(obj)
// 21:       valid?(obj)
// 22:     end
// 23:
// 24:     define_method(:valid?) do |_obj|
// 25:       raise NotImplementedError
// 26:     end
// 27:
// 28:     # @return [T::Boolean] This method must be implemented to return whether the subclass is a subtype
// 29:     # of `type`. This should only be called by `subtype_of?`, which guarantees that `type` will be
// 30:     # a "single" type, by which we mean it won't be a Union or an Intersection (c.f.
// 31:     # `isSubTypeSingle` in sorbet).
// 32:     private def subtype_of_single?(type)
// 33:       raise NotImplementedError
// 34:     end
// 35:
// 36:     # Force any lazy initialization that this type might need to do
// 37:     # It's unusual to call this directly; you probably want to call it indirectly via `T::Utils.run_all_sig_blocks`.
// 38:     define_method(:build_type) do
// 39:       raise NotImplementedError
// 40:     end
// 41:
// 42:     # Equality is based on name, so be sure the name reflects all relevant state when implementing.
// 43:     define_method(:name) do
// 44:       raise NotImplementedError
// 45:     end
// 46:
// 47:     # Mirrors ruby_typer::core::Types::isSubType
// 48:     # See https://git.corp.stripe.com/stripe-internal/ruby-typer/blob/9fc8ed998c04ac0b96592ae6bb3493b8a925c5c1/core/types/subtyping.cc#L912-L950
// 49:     #
// 50:     # This method cannot be overridden (see `method_added` above).
// 51:     # Subclasses only need to implement `subtype_of_single?`).
// 52:     def subtype_of?(t2)
// 53:       t1 = self
// 54:
// 55:       # Fast path over the isSubType mirror below: the dominant pair during
// 56:       # override validation is two plain Simples, which match none of the
// 57:       # branches in the walk. instance_of? (never
// 58:       # is_a?) so that any hypothetical Simple subclass takes the full walk,
// 59:       # and the raw subtype_of_single? result is returned unmodified
// 60:       # (Module#<= yields nil for unrelated modules, which callers observe).
// 61:       if t1.instance_of?(T::Types::Simple) && t2.instance_of?(T::Types::Simple)
// 62:         return subtype_of_single?(t2)
// 63:       end
// 64:
// 65:       if t2.is_a?(T::Private::Types::TypeAlias)
// 66:         t2 = t2.aliased_type
// 67:       end
// 68:
// 69:       if t2.is_a?(T::Types::Anything)
// 70:         return true
// 71:       end
// 72:
// 73:       if t1.is_a?(T::Private::Types::TypeAlias)
// 74:         return t1.aliased_type.subtype_of?(t2)
// 75:       end
// 76:
// 77:       if t1.is_a?(T::Types::TypeVariable) || t2.is_a?(T::Types::TypeVariable)
// 78:         # Generics are erased at runtime. Let's treat them like `T.untyped` for
// 79:         # the purpose of things like override checking.
// 80:         return true
// 81:       end
// 82:
// 83:       # pairs to cover: 1  (_, _)
// 84:       #                 2  (_, And)
// 85:       #                 3  (_, Or)
// 86:       #                 4  (And, _)
// 87:       #                 5  (And, And)
// 88:       #                 6  (And, Or)
// 89:       #                 7  (Or, _)
// 90:       #                 8  (Or, And)
// 91:       #                 9  (Or, Or)
// 92:
// 93:       # Note: order of cases here matters!
// 94:       if t1.is_a?(T::Types::Union) # 7, 8, 9
// 95:         # this will be incorrect if/when we have Type members
// 96:         return t1.types.all? { |t1_member| t1_member.subtype_of?(t2) }
// 97:       end
// 98:
// 99:       if t2.is_a?(T::Types::Intersection) # 2, 5
// 100:         # this will be incorrect if/when we have Type members
// 101:         return t2.types.all? { |t2_member| t1.subtype_of?(t2_member) }
// 102:       end
// 103:
// 104:       if t2.is_a?(T::Types::Union)
// 105:         if t1.is_a?(T::Types::Intersection) # 6
// 106:           # dropping either of parts eagerly make subtype test be too strict.
// 107:           # we have to try both cases, when we normally try only one
// 108:           return t2.types.any? { |t2_member| t1.subtype_of?(t2_member) } ||
// 109:               t1.types.any? { |t1_member| t1_member.subtype_of?(t2) }
// 110:         end
// 111:         return t2.types.any? { |t2_member| t1.subtype_of?(t2_member) } # 3
// 112:       end
// 113:
// 114:       if t1.is_a?(T::Types::Intersection) # 4
// 115:         # this will be incorrect if/when we have Type members
// 116:         return t1.types.any? { |t1_member| t1_member.subtype_of?(t2) }
// 117:       end
// 118:
// 119:       # 1; Start with some special cases
// 120:       if t1.is_a?(T::Private::Types::Void)
// 121:         return t2.is_a?(T::Private::Types::Void)
// 122:       end
// 123:
// 124:       if t1.is_a?(T::Types::Untyped) || t2.is_a?(T::Types::Untyped)
// 125:         return true
// 126:       end
// 127:
// 128:       # Rest of (1)
// 129:       subtype_of_single?(t2)
// 130:     end
// 131:
// 132:     def to_s
// 133:       name
// 134:     end
// 135:
// 136:     def describe_obj(obj)
// 137:       # Would be redundant to print class and value in these common cases.
// 138:       case obj
// 139:       when nil, true, false
// 140:         return "type #{obj.class}"
// 141:       end
// 142:
// 143:       # In rare cases, obj.inspect may fail, or be undefined, so rescue.
// 144:       begin
// 145:         # Default inspect behavior of, eg; `#<Object:0x0...>` is ugly; just print the hash instead, which is more concise/readable.
// 146:         if obj.method(:inspect).owner == Kernel
// 147:           "type #{obj.class} with hash #{obj.hash}"
// 148:         elsif T::Configuration.include_value_in_type_errors?
// 149:           "type #{obj.class} with value #{T::Utils.string_truncate_middle(obj.inspect, 30, 30)}"
// 150:         else
// 151:           "type #{obj.class}"
// 152:         end
// 153:       rescue StandardError, SystemStackError
// 154:         "type #{obj.class} with unprintable value"
// 155:       end
// 156:     end
// 157:
// 158:     def error_message_for_obj(obj)
// 159:       if valid?(obj)
// 160:         nil
// 161:       else
// 162:         error_message(obj)
// 163:       end
// 164:     end
// 165:
// 166:     def error_message_for_obj_recursive(obj)
// 167:       if recursively_valid?(obj)
// 168:         nil
// 169:       else
// 170:         error_message(obj)
// 171:       end
// 172:     end
// 173:
// 174:     private def error_message(obj)
// 175:       "Expected type #{self.name}, got #{describe_obj(obj)}"
// 176:     end
// 177:
// 178:     def validate!(obj)
// 179:       err = error_message_for_obj(obj)
// 180:       raise TypeError.new(err) if err
// 181:     end
// 182:
// 183:     ### Equality methods (necessary for deduping types with `uniq`)
// 184:
// 185:     def hash
// 186:       name.hash
// 187:     end
// 188:
// 189:     # Type equivalence, defined by serializing the type to a string (with
// 190:     # `#name`) and comparing the resulting strings for equality.
// 191:     def ==(other)
// 192:       case other
// 193:       when T::Types::Base
// 194:         # Performance fast path: pooled and memoized type instances (e.g. the
// 195:         # results of repeated T.nilable(X) calls) are the same object, so they
// 196:         # can compare equal without computing and comparing their names.
// 197:         other.equal?(self) || other.name == self.name
// 198:       else
// 199:         false
// 200:       end
// 201:     end
// 202:
// 203:     alias_method :eql?, :==
// 204:   end
// 205: end
