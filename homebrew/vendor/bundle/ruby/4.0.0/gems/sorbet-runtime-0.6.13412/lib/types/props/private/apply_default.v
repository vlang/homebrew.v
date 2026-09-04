module private

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/private/apply_default.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum ApplyDefaultKind {
	none
	abstract_default
	primitive
	complex
	empty_array
	empty_hash
	factory
}

@[heap]
pub struct ApplyDefaultDescriptor {
pub:
	kind           ApplyDefaultKind
	class_name     string
	accessor_key   string
	bound_setter   SetterDescriptor
	setter_value   ruby.Value
	stored_default ruby.Value
	factory_value  ruby.Value
}

pub type ApplyDefaultFactoryCallback = fn() !ruby.Value

fn private_deep_clone(value ruby.Value) ruby.Value {
	mut items := []ruby.Value{cap: value.array_data.len}
	for item in value.array_data {
		items << private_deep_clone(item)
	}
	mut entries := map[string]ruby.Value{}
	for key, item in value.map_data {
		entries[key] = private_deep_clone(item)
	}
	return ruby.Value{
		...value
		string_array_data: value.string_array_data.clone()
		array_data: items
		map_data: entries
		attributes: value.attributes.clone()
	}
}

fn apply_default_kind(value ruby.Value) ApplyDefaultKind {
	if value.type_name in ['Bool', 'NilClass', 'Symbol', 'Integer', 'Float', 'T::Enum'] {
		return .primitive
	}
	if value.type_name == 'String' && value.attribute('frozen') or { 'false' } == 'true' {
		return .primitive
	}
	if value.type_name == 'Array' && value.array_data.len == 0 && value.string_array_data.len == 0 {
		return .empty_array
	}
	if value.type_name == 'Hash' && value.map_data.len == 0 && value.attribute('has_default') or { 'false' } != 'true' && value.attribute('has_default_proc') or { 'false' } != 'true' {
		return .empty_hash
	}
	return .complex
}

fn permissive_default_setter(class_name string, accessor_key string) SetterDescriptor {
	untyped := ruby.object_value('T::Types::Untyped', 'T.untyped')
	return SetterDescriptor{
		class_name: class_name
		prop: accessor_key.trim_left('@')
		accessor_key: accessor_key
		type_value: untyped
		non_nil_type: untyped
		mode: .recursive_nilable
	}
}

fn apply_default_setter_from_value(value ruby.Value, class_name string,
	accessor_key string) SetterDescriptor {
	if 'setter_descriptor_address' in value.attributes {
		return *setter_descriptor_from_value(value)
	}
	return permissive_default_setter(class_name, accessor_key)
}

pub fn build_apply_default(class_name string, rules map[string]ruby.Value) !ApplyDefaultDescriptor {
	accessor_key := (private_rule(rules, 'accessor_key') or {
		return error('key not found: accessor_key')
	}).as_string()
	setter_value := private_rule(rules, '_bound_setter_proc') or {
		return error('key not found: _bound_setter_proc')
	}
	setter := apply_default_setter_from_value(setter_value, class_name, accessor_key)
	if factory := private_rule(rules, 'factory') {
		return ApplyDefaultDescriptor{
			kind: .factory
			class_name: class_name
			accessor_key: accessor_key
			bound_setter: setter
			setter_value: setter_value
			factory_value: factory
		}
	}
	if value := private_rule(rules, 'default') {
		return ApplyDefaultDescriptor{
			kind: apply_default_kind(value)
			class_name: class_name
			accessor_key: accessor_key
			bound_setter: setter
			setter_value: setter_value
			stored_default: value
		}
	}
	return ApplyDefaultDescriptor{
		kind: .none
		class_name: class_name
		accessor_key: accessor_key
		bound_setter: setter
		setter_value: setter_value
	}
}

fn evaluated_factory_value(descriptor ApplyDefaultDescriptor) ruby.Value {
	return descriptor.factory_value.map_data['result'] or { descriptor.factory_value }
}

pub fn apply_default_value(descriptor ApplyDefaultDescriptor) !ruby.Value {
	return match descriptor.kind {
		.none { private_nil_value() }
		.abstract_default { error('ApplyDefault#default is abstract') }
		.primitive { descriptor.stored_default }
		.complex { private_deep_clone(descriptor.stored_default) }
		.empty_array { ruby.array_value([]ruby.Value{}) }
		.empty_hash { ruby.map_value(map[string]ruby.Value{}) }
		.factory { evaluated_factory_value(descriptor) }
	}
}

pub fn set_apply_default(descriptor ApplyDefaultDescriptor, mut instance SetterInstance,
	error_handler SetterErrorHandler) ! {
	if descriptor.kind in [.none, .abstract_default] {
		if descriptor.kind == .abstract_default {
			return error('ApplyDefault#set_default is abstract')
		}
		return
	}
	value := apply_default_value(descriptor)!
	if descriptor.kind == .factory {
		apply_bound_setter(descriptor.bound_setter, mut instance, value, error_handler)!
	} else {
		// Fixed defaults deliberately bypass validation in the Ruby source.
		instance.values[descriptor.accessor_key] = value
	}
}

pub fn set_factory_default_with(descriptor ApplyDefaultDescriptor, mut instance SetterInstance,
	factory ApplyDefaultFactoryCallback, error_handler SetterErrorHandler) ! {
	value := factory()!
	apply_bound_setter(descriptor.bound_setter, mut instance, value, error_handler)!
}

fn apply_default_type_name(kind ApplyDefaultKind) string {
	return match kind {
		.none { 'NilClass' }
		.abstract_default { 'T::Props::Private::ApplyDefault' }
		.primitive { 'T::Props::Private::ApplyPrimitiveDefault' }
		.complex { 'T::Props::Private::ApplyComplexDefault' }
		.empty_array { 'T::Props::Private::ApplyEmptyArrayDefault' }
		.empty_hash { 'T::Props::Private::ApplyEmptyHashDefault' }
		.factory { 'T::Props::Private::ApplyDefaultFactory' }
	}
}

fn apply_default_descriptor_value(descriptor ApplyDefaultDescriptor) ruby.Value {
	if descriptor.kind == .none {
		return private_nil_value()
	}
	heap_descriptor := &ApplyDefaultDescriptor{
		...descriptor
	}
	return ruby.Value{
		type_name: apply_default_type_name(descriptor.kind)
		repr: descriptor.accessor_key
		map_data: {
			'default':           descriptor.stored_default
			'factory':           descriptor.factory_value
			'bound_setter_proc': descriptor.setter_value
		}
		attributes: {
			'apply_default_address': u64(voidptr(heap_descriptor)).str()
			'accessor_key':          descriptor.accessor_key
			'class_name':            descriptor.class_name
			'kind':                  descriptor.kind.str()
		}
	}
}

fn apply_default_descriptor_from_value(value ruby.Value) &ApplyDefaultDescriptor {
	address := value.attribute('apply_default_address') or { panic('invalid ApplyDefault receiver') }
	return unsafe { &ApplyDefaultDescriptor(voidptr(address.u64())) }
}

fn default_instance_from_value(value ruby.Value) SetterInstance {
	return SetterInstance{
		values: value.map_data.clone()
	}
}

fn default_instance_value(original ruby.Value, instance SetterInstance) ruby.Value {
	return ruby.Value{
		...original
		map_data: instance.values.clone()
	}
}

fn base_default_descriptor(accessor ruby.Value, setter ruby.Value) ApplyDefaultDescriptor {
	accessor_key := accessor.as_string()
	return ApplyDefaultDescriptor{
		kind: .abstract_default
		accessor_key: accessor_key
		bound_setter: apply_default_setter_from_value(setter, '', accessor_key)
		setter_value: setter
	}
}

// Ruby attr_reader `attr_reader :bound_setter_proc` at line 13.
pub fn ruby_apply_default_l13_d1_bound_setter_proc(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ApplyDefault#bound_setter_proc requires a receiver')
	}
	return apply_default_descriptor_from_value(args[0]).setter_value
}

// Ruby method `initialize(accessor_key, bound_setter_proc)` at line 17.
pub fn ruby_apply_default_l17_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ApplyDefault#initialize requires accessor key and bound setter')
	}
	return apply_default_descriptor_value(base_default_descriptor(args[0], args[1]))
}

// Ruby method `default; end` at line 24.
pub fn ruby_apply_default_l24_d3_default(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ApplyDefault#default requires a receiver')
	}
	return apply_default_value(*apply_default_descriptor_from_value(args[0])) or { panic(err) }
}

// Ruby method `set_default(instance); end` at line 28.
pub fn ruby_apply_default_l28_d4_set_default(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ApplyDefault#set_default requires an instance')
	}
	mut instance := default_instance_from_value(args[1])
	set_apply_default(*apply_default_descriptor_from_value(args[0]), mut instance, raising_setter_error_handler) or { panic(err) }
	return default_instance_value(args[1], instance)
}

// Ruby method `self.for(cls, rules)` at line 34.
pub fn ruby_apply_default_l34_d5_self_for(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ApplyDefault.for requires class and rules')
	}
	return apply_default_descriptor_value(build_apply_default(args[0].attribute('name') or {
		args[0].as_string()
	}, args[1].as_map() or { panic(err) }) or { panic(err) })
}

// Ruby method `initialize(default, accessor_key, bound_setter_proc)` at line 71.
pub fn ruby_apply_default_l71_d6_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('ApplyFixedDefault#initialize requires default, accessor key, and bound setter')
	}
	base := base_default_descriptor(args[1], args[2])
	descriptor := ApplyDefaultDescriptor{
		...base
		kind: .complex
		stored_default: args[0]
	}
	return apply_default_descriptor_value(descriptor)
}

// Ruby method `set_default(instance)` at line 84.
pub fn ruby_apply_default_l84_d7_set_default(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ApplyFixedDefault#set_default requires an instance')
	}
	mut instance := default_instance_from_value(args[1])
	set_apply_default(*apply_default_descriptor_from_value(args[0]), mut instance, raising_setter_error_handler) or { panic(err) }
	return default_instance_value(args[1], instance)
}

// Ruby attr_reader `attr_reader :default` at line 92.
pub fn ruby_apply_default_l92_d8_default(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ApplyPrimitiveDefault#default requires a receiver')
	}
	return apply_default_descriptor_from_value(args[0]).stored_default
}

// Ruby method `default` at line 98.
pub fn ruby_apply_default_l98_d9_default(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ApplyComplexDefault#default requires a receiver')
	}
	return private_deep_clone(apply_default_descriptor_from_value(args[0]).stored_default)
}

// Ruby method `set_default(instance)` at line 109.
pub fn ruby_apply_default_l109_d10_set_default(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ApplyEmptyArrayDefault#set_default requires an instance')
	}
	mut instance := default_instance_from_value(args[1])
	descriptor := *apply_default_descriptor_from_value(args[0])
	instance.values[descriptor.accessor_key] = ruby.array_value([]ruby.Value{})
	return default_instance_value(args[1], instance)
}

// Ruby method `default` at line 115.
pub fn ruby_apply_default_l115_d11_default(args ...ruby.Value) ruby.Value {
	return ruby.array_value([]ruby.Value{})
}

// Ruby method `set_default(instance)` at line 126.
pub fn ruby_apply_default_l126_d12_set_default(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ApplyEmptyHashDefault#set_default requires an instance')
	}
	mut instance := default_instance_from_value(args[1])
	descriptor := *apply_default_descriptor_from_value(args[0])
	instance.values[descriptor.accessor_key] = ruby.map_value(map[string]ruby.Value{})
	return default_instance_value(args[1], instance)
}

// Ruby method `default` at line 132.
pub fn ruby_apply_default_l132_d13_default(args ...ruby.Value) ruby.Value {
	return ruby.map_value(map[string]ruby.Value{})
}

// Ruby method `initialize(cls, factory, accessor_key, bound_setter_proc)` at line 149.
pub fn ruby_apply_default_l149_d14_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('ApplyDefaultFactory#initialize requires class, factory, accessor key, and bound setter')
	}
	descriptor := ApplyDefaultDescriptor{
		kind: .factory
		class_name: args[0].attribute('name') or { args[0].as_string() }
		accessor_key: args[2].as_string()
		bound_setter: apply_default_setter_from_value(args[3], args[0].as_string(), args[2].as_string())
		setter_value: args[3]
		factory_value: args[1]
	}
	return apply_default_descriptor_value(descriptor)
}

// Ruby method `set_default(instance)` at line 157.
pub fn ruby_apply_default_l157_d15_set_default(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ApplyDefaultFactory#set_default requires an instance')
	}
	mut instance := default_instance_from_value(args[1])
	set_apply_default(*apply_default_descriptor_from_value(args[0]), mut instance, raising_setter_error_handler) or { panic(err) }
	return default_instance_value(args[1], instance)
}

// Ruby method `default` at line 165.
pub fn ruby_apply_default_l165_d16_default(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ApplyDefaultFactory#default requires a receiver')
	}
	return evaluated_factory_value(*apply_default_descriptor_from_value(args[0]))
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
