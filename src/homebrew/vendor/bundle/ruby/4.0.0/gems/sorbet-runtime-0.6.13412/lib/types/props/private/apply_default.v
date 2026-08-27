module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/private/apply_default.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :bound_setter_proc` at line 13.
pub fn ruby_apply_default_l13_d1_bound_setter_proc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bound_setter_proc', ...args)
}

// Ruby method `initialize(accessor_key, bound_setter_proc)` at line 17.
pub fn ruby_apply_default_l17_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `default; end` at line 24.
pub fn ruby_apply_default_l24_d3_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default', ...args)
}

// Ruby method `set_default(instance); end` at line 28.
pub fn ruby_apply_default_l28_d4_set_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_default', ...args)
}

// Ruby method `self.for(cls, rules)` at line 34.
pub fn ruby_apply_default_l34_d5_self_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.for', ...args)
}

// Ruby method `initialize(default, accessor_key, bound_setter_proc)` at line 71.
pub fn ruby_apply_default_l71_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `set_default(instance)` at line 84.
pub fn ruby_apply_default_l84_d7_set_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_default', ...args)
}

// Ruby attr_reader `attr_reader :default` at line 92.
pub fn ruby_apply_default_l92_d8_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default', ...args)
}

// Ruby method `default` at line 98.
pub fn ruby_apply_default_l98_d9_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default', ...args)
}

// Ruby method `set_default(instance)` at line 109.
pub fn ruby_apply_default_l109_d10_set_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_default', ...args)
}

// Ruby method `default` at line 115.
pub fn ruby_apply_default_l115_d11_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default', ...args)
}

// Ruby method `set_default(instance)` at line 126.
pub fn ruby_apply_default_l126_d12_set_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_default', ...args)
}

// Ruby method `default` at line 132.
pub fn ruby_apply_default_l132_d13_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default', ...args)
}

// Ruby method `initialize(cls, factory, accessor_key, bound_setter_proc)` at line 149.
pub fn ruby_apply_default_l149_d14_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `set_default(instance)` at line 157.
pub fn ruby_apply_default_l157_d15_set_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_default', ...args)
}

// Ruby method `default` at line 165.
pub fn ruby_apply_default_l165_d16_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: strict
// 3:
// 4: module T::Props
// 5:   module Private
// 6:     class ApplyDefault
// 7:       extend T::Sig
// 8:       extend T::Helpers
// 9:       abstract!
// 10:
// 11:       # checked(:never) - O(object construction x prop count)
// 12:       sig { returns(SetterFactory::BoundSetterProc).checked(:never) }
// 13:       attr_reader :bound_setter_proc
// 14:
// 15:       # checked(:never) - We do this with `T.let` instead
// 16:       sig { params(accessor_key: Symbol, bound_setter_proc: SetterFactory::BoundSetterProc).void.checked(:never) }
// 17:       def initialize(accessor_key, bound_setter_proc)
// 18:         @accessor_key = T.let(accessor_key, Symbol)
// 19:         @bound_setter_proc = T.let(bound_setter_proc, SetterFactory::BoundSetterProc)
// 20:       end
// 21:
// 22:       # checked(:never) - O(object construction x prop count)
// 23:       sig { abstract.returns(T.untyped).checked(:never) }
// 24:       def default; end
// 25:
// 26:       # checked(:never) - O(object construction x prop count)
// 27:       sig { abstract.params(instance: T.all(T::Props::Optional, Object)).void.checked(:never) }
// 28:       def set_default(instance); end
// 29:
// 30:       NO_CLONE_TYPES = T.let([TrueClass, FalseClass, NilClass, Symbol, Numeric, T::Enum].freeze, T::Array[T::Module[T.anything]])
// 31:
// 32:       # checked(:never) - Rules hash is expensive to check
// 33:       sig { params(cls: T::Module[T.anything], rules: T::Hash[Symbol, T.untyped]).returns(T.nilable(ApplyDefault)).checked(:never) }
// 34:       def self.for(cls, rules)
// 35:         accessor_key = rules.fetch(:accessor_key)
// 36:         bound_setter = rules.fetch(:_bound_setter_proc)
// 37:
// 38:         if rules.key?(:factory)
// 39:           ApplyDefaultFactory.new(cls, rules.fetch(:factory), accessor_key, bound_setter)
// 40:         elsif rules.key?(:default)
// 41:           default = rules.fetch(:default)
// 42:           case default
// 43:           when *NO_CLONE_TYPES
// 44:             return ApplyPrimitiveDefault.new(default, accessor_key, bound_setter)
// 45:           when String
// 46:             if default.frozen?
// 47:               return ApplyPrimitiveDefault.new(default, accessor_key, bound_setter)
// 48:             end
// 49:           when Array
// 50:             if default.empty? && default.class == Array
// 51:               return ApplyEmptyArrayDefault.new(accessor_key, bound_setter)
// 52:             end
// 53:           when Hash
// 54:             if default.empty? && default.default.nil? && T.unsafe(default).default_proc.nil? && default.class == Hash
// 55:               return ApplyEmptyHashDefault.new(accessor_key, bound_setter)
// 56:             end
// 57:           end
// 58:
// 59:           ApplyComplexDefault.new(default, accessor_key, bound_setter)
// 60:         else
// 61:           nil
// 62:         end
// 63:       end
// 64:     end
// 65:
// 66:     class ApplyFixedDefault < ApplyDefault
// 67:       abstract!
// 68:
// 69:       # checked(:never) - We do this with `T.let` instead
// 70:       sig { params(default: BasicObject, accessor_key: Symbol, bound_setter_proc: SetterFactory::BoundSetterProc).void.checked(:never) }
// 71:       def initialize(default, accessor_key, bound_setter_proc)
// 72:         # FIXME: Ideally we'd check here that the default is actually a valid
// 73:         # value for this field, but existing code relies on the fact that we don't.
// 74:         #
// 75:         # :(
// 76:         #
// 77:         # bound_setter_proc.call(instance, default)
// 78:         @default = T.let(default, BasicObject)
// 79:         super(accessor_key, bound_setter_proc)
// 80:       end
// 81:
// 82:       # checked(:never) - O(object construction x prop count)
// 83:       sig { override.params(instance: T.all(T::Props::Optional, Object)).void.checked(:never) }
// 84:       def set_default(instance)
// 85:         instance.instance_variable_set(@accessor_key, default)
// 86:       end
// 87:     end
// 88:
// 89:     class ApplyPrimitiveDefault < ApplyFixedDefault
// 90:       # checked(:never) - O(object construction x prop count)
// 91:       sig { override.returns(T.untyped).checked(:never) }
// 92:       attr_reader :default
// 93:     end
// 94:
// 95:     class ApplyComplexDefault < ApplyFixedDefault
// 96:       # checked(:never) - O(object construction x prop count)
// 97:       sig { override.returns(T.untyped).checked(:never) }
// 98:       def default
// 99:         T::Props::Utils.deep_clone(@default)
// 100:       end
// 101:     end
// 102:
// 103:     # Special case since it's so common, and a literal `[]` is meaningfully
// 104:     # faster than falling back to ApplyComplexDefault or even calling
// 105:     # `some_empty_array.dup`
// 106:     class ApplyEmptyArrayDefault < ApplyDefault
// 107:       # checked(:never) - O(object construction x prop count)
// 108:       sig { override.params(instance: T.all(T::Props::Optional, Object)).void.checked(:never) }
// 109:       def set_default(instance)
// 110:         instance.instance_variable_set(@accessor_key, [])
// 111:       end
// 112:
// 113:       # checked(:never) - O(object construction x prop count)
// 114:       sig { override.returns(T::Array[T.untyped]).checked(:never) }
// 115:       def default
// 116:         []
// 117:       end
// 118:     end
// 119:
// 120:     # Special case since it's so common, and a literal `{}` is meaningfully
// 121:     # faster than falling back to ApplyComplexDefault or even calling
// 122:     # `some_empty_hash.dup`
// 123:     class ApplyEmptyHashDefault < ApplyDefault
// 124:       # checked(:never) - O(object construction x prop count)
// 125:       sig { override.params(instance: T.all(T::Props::Optional, Object)).void.checked(:never) }
// 126:       def set_default(instance)
// 127:         instance.instance_variable_set(@accessor_key, {})
// 128:       end
// 129:
// 130:       # checked(:never) - O(object construction x prop count)
// 131:       sig { override.returns(T::Hash[T.untyped, T.untyped]).checked(:never) }
// 132:       def default
// 133:         {}
// 134:       end
// 135:     end
// 136:
// 137:     class ApplyDefaultFactory < ApplyDefault
// 138:       # checked(:never) - We do this with `T.let` instead
// 139:       sig do
// 140:         params(
// 141:           cls: T::Module[T.anything],
// 142:           factory: T.any(Proc, Method),
// 143:           accessor_key: Symbol,
// 144:           bound_setter_proc: SetterFactory::BoundSetterProc,
// 145:         )
// 146:         .void
// 147:         .checked(:never)
// 148:       end
// 149:       def initialize(cls, factory, accessor_key, bound_setter_proc)
// 150:         @class = T.let(cls, T::Module[T.anything])
// 151:         @factory = T.let(factory, T.any(Proc, Method))
// 152:         super(accessor_key, bound_setter_proc)
// 153:       end
// 154:
// 155:       # checked(:never) - O(object construction x prop count)
// 156:       sig { override.params(instance: T.all(T::Props::Optional, Object)).void.checked(:never) }
// 157:       def set_default(instance)
// 158:         # Use the actual setter to validate the factory returns a legitimate
// 159:         # value every time
// 160:         @bound_setter_proc.call(instance, default)
// 161:       end
// 162:
// 163:       # checked(:never) - O(object construction x prop count)
// 164:       sig { override.returns(T.untyped).checked(:never) }
// 165:       def default
// 166:         @class.class_exec(&@factory)
// 167:       end
// 168:     end
// 169:   end
// 170: end
