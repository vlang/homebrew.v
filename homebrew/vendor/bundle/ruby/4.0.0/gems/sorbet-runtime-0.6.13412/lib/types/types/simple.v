module types

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/simple.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct SimpleType {
pub:
	raw_type    brew_runtime.Value
	type_name   string
	name_is_nil bool
	base_type   &BaseType
}

// SimpleNilableType is the typed adapter for the SimplePairUnion constructed by
// Simple#to_nilable. The vendored SimplePairUnion translation does not yet
// expose a typed API, and generic Union loses this optimized runtime boundary,
// so this leaf keeps the exact two raw types locally.
@[heap]
pub struct SimpleNilableType {
pub:
	non_nil_type &SimpleType
	nil_type     &SimpleType
}

struct SimpleTypePool {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	entries       map[string]brew_runtime.Value
	simple_types  map[string]&SimpleType
	base_types    map[string]&BaseType
	nilable_types map[u64]&SimpleNilableType
}

fn new_simple_type_pool() &SimpleTypePool {
	return &SimpleTypePool{}
}

const simple_type_pool = new_simple_type_pool()

pub fn new_simple_type(raw_type brew_runtime.Value) &SimpleType {
	type_name := simple_module_name(raw_type)
	base_type := new_simple_base_type(type_name, simple_module_ancestors(raw_type))
	return &SimpleType{
		raw_type: raw_type
		type_name: type_name
		name_is_nil: simple_module_name_is_nil(raw_type)
		base_type: base_type
	}
}

pub fn (simple &SimpleType) build_type() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn (simple &SimpleType) name() string {
	return simple.type_name
}

pub fn (simple &SimpleType) recursively_valid(obj brew_runtime.Value) bool {
	return simple.valid(obj)
}

pub fn (simple &SimpleType) valid(obj brew_runtime.Value) bool {
	return simple_raw_type_accepts(simple.raw_type, obj)
}

pub fn (simple &SimpleType) subtype_of_single(other &SimpleType) BaseSubtypeResult {
	return simple_module_subtype(simple.raw_type, other.raw_type)
}

pub fn (simple &SimpleType) error_message(obj brew_runtime.Value) !string {
	error_message := simple.base_type.error_message(obj)!
	actual_name := simple_object_class_name(obj)
	if simple.name() != actual_name {
		return error_message
	}
	expected_id := simple_module_object_id(simple.raw_type)
	actual_id := simple_object_class_id(obj, expected_id)
	return '${error_message}\n\nThe expected type and received object type have the same name but refer to different constants.\nExpected type is ${simple.name()} with object id ${expected_id}, but received type is ${actual_name} with object id ${actual_id}.\n\nThere might be a constant reloading problem in your application.'
}

pub fn (simple &SimpleType) to_nilable() !&SimpleNilableType {
	nil_value := simple_type_for_module(brew_runtime.structured_value('Class', 'NilClass', {
		'canonical_constant': 'true'
	}))
	nil_type := simple_type_from_value(nil_value)
	if simple.name() == nil_type.name() {
		return error('${simple.name()} == ${nil_type.name()}')
	}
	key := u64(voidptr(simple))
	mut pool := unsafe { &SimpleTypePool(simple_type_pool) }
	pool.mutex.lock()
	defer {
		pool.mutex.unlock()
	}
	if cached := pool.nilable_types[key] {
		return cached
	}
	nilable := &SimpleNilableType{
		non_nil_type: simple
		nil_type: nil_type
	}
	pool.nilable_types[key] = nilable
	return nilable
}

pub fn (nilable &SimpleNilableType) name() string {
	return 'T.nilable(${nilable.non_nil_type.name()})'
}

pub fn (nilable &SimpleNilableType) recursively_valid(obj brew_runtime.Value) bool {
	return nilable.valid(obj)
}

pub fn (nilable &SimpleNilableType) valid(obj brew_runtime.Value) bool {
	return nilable.non_nil_type.valid(obj) || nilable.nil_type.valid(obj)
}

pub fn (nilable &SimpleNilableType) types() []&SimpleType {
	return [nilable.non_nil_type, nilable.nil_type]
}

pub fn (nilable &SimpleNilableType) unwrap_nilable() &SimpleType {
	return nilable.non_nil_type
}

pub fn simple_pool_cache_frozen_objects() bool {
	// The source probe succeeds on the Ruby 4.0 runtime vendored by Homebrew.
	return true
}

pub fn simple_type_for_module(raw_type brew_runtime.Value) brew_runtime.Value {
	key := simple_module_cache_key(raw_type)
	mut pool := unsafe { &SimpleTypePool(simple_type_pool) }
	pool.mutex.lock()
	defer {
		pool.mutex.unlock()
	}
	if cached := pool.entries[key] {
		return cached
	}
	module_name := simple_module_name(raw_type)
	mut type_value := brew_runtime.Value{}
	if simple_is_special_module(raw_type, module_name) {
		type_value = new_simple_special_type_value(module_name, key, mut pool)
	} else {
		simple := new_simple_type(raw_type)
		pool.simple_types[key] = simple
		type_value = simple_type_value(simple)
	}
	// CACHE_FROZEN_OBJECTS is true for the supported Ruby runtime, so frozen
	// modules and frozen singleton type objects use the same cache path.
	if simple_pool_cache_frozen_objects() || (raw_type.attributes['frozen'] or { 'false' } != 'true' && type_value.attributes['frozen'] or { 'false' } != 'true') {
		pool.entries[key] = type_value
	}
	return type_value
}

fn simple_module_name(raw_type brew_runtime.Value) string {
	// module_name models Module.instance_method(:name), bypassing an overridden
	// #name. An empty intrinsic name falls back to the receiver's own #name.
	if intrinsic_name := raw_type.attributes['module_name'] {
		if intrinsic_name != '' {
			return intrinsic_name
		}
		if fallback_name := raw_type.attributes['name'] {
			return fallback_name
		}
		return ''
	}
	if name := raw_type.attributes['name'] {
		return name
	}
	return raw_type.as_string()
}

fn simple_module_name_is_nil(raw_type brew_runtime.Value) bool {
	if intrinsic_name := raw_type.attributes['module_name'] {
		return intrinsic_name == '' && 'name' !in raw_type.attributes
	}
	return false
}

fn simple_module_ancestors(raw_type brew_runtime.Value) []string {
	ancestors := raw_type.attributes['ancestors'] or { return [] }
	return ancestors.split(',').map(it.trim_space()).filter(it != '')
}

fn simple_module_explicit_object_id(raw_type brew_runtime.Value) ?string {
	for key in ['object_id', 'module_object_id', 'constant_id'] {
		if identity := raw_type.attributes[key] {
			return identity
		}
	}
	return none
}

fn simple_module_object_id(raw_type brew_runtime.Value) string {
	return simple_module_explicit_object_id(raw_type) or {
		u64(simple_module_cache_key(raw_type).hash()).str()
	}
}

fn simple_module_cache_key(raw_type brew_runtime.Value) string {
	if identity := simple_module_explicit_object_id(raw_type) {
		return 'object:${identity}'
	}
	return '${raw_type.type_name}:${simple_module_name(raw_type)}'
}

fn simple_object_class_name(obj brew_runtime.Value) string {
	if class_name := obj.attributes['class_name'] {
		return class_name
	}
	return match obj.type_name {
		'Bool' {
			if obj.bool_data { 'TrueClass' } else { 'FalseClass' }
		}
		else { obj.type_name }
	}
}

fn simple_object_class_id(obj brew_runtime.Value, fallback string) string {
	return simple_object_explicit_class_id(obj) or { fallback }
}

fn simple_object_explicit_class_id(obj brew_runtime.Value) ?string {
	for key in ['class_object_id', 'class_id'] {
		if identity := obj.attributes[key] {
			return identity
		}
	}
	return none
}

fn simple_raw_type_accepts(raw_type brew_runtime.Value, obj brew_runtime.Value) bool {
	expected_name := simple_module_name(raw_type)
	if simple_object_class_name(obj) == expected_name {
		if expected_id := simple_module_explicit_object_id(raw_type) {
			if actual_id := simple_object_explicit_class_id(obj) {
				return expected_id == actual_id
			}
		}
		return true
	}
	ancestors := obj.attributes['ancestors'] or { return false }
	ancestor_names := ancestors.split(',').map(it.trim_space())
	index := ancestor_names.index(expected_name)
	if index < 0 {
		return false
	}
	if expected_id := simple_module_explicit_object_id(raw_type) {
		if ancestor_ids := obj.attributes['ancestor_object_ids'] {
			ids := ancestor_ids.split(',').map(it.trim_space())
			if index < ids.len && ids[index] != '' {
				return ids[index] == expected_id
			}
		}
	}
	return true
}

fn simple_module_is_same(left brew_runtime.Value, right brew_runtime.Value) bool {
	if left_id := simple_module_explicit_object_id(left) {
		if right_id := simple_module_explicit_object_id(right) {
			return left_id == right_id
		}
	}
	return simple_module_name(left) == simple_module_name(right)
}

fn simple_module_inherits(left brew_runtime.Value, right brew_runtime.Value) bool {
	if simple_module_is_same(left, right) {
		return true
	}
	right_name := simple_module_name(right)
	ancestors := simple_module_ancestors(left)
	index := ancestors.index(right_name)
	if index < 0 {
		return false
	}
	if right_id := simple_module_explicit_object_id(right) {
		if ancestor_ids := left.attributes['ancestor_object_ids'] {
			ids := ancestor_ids.split(',').map(it.trim_space())
			if index < ids.len && ids[index] != '' {
				return ids[index] == right_id
			}
		}
	}
	return true
}

fn simple_module_subtype(left brew_runtime.Value, right brew_runtime.Value) BaseSubtypeResult {
	if simple_module_inherits(left, right) {
		return .yes
	}
	if simple_module_inherits(right, left) {
		return .no
	}
	return .unrelated
}

fn simple_other_raw_type(other brew_runtime.Value) ?brew_runtime.Value {
	if other.type_name == 'T::Types::Simple' {
		if raw_type := other.map_data['raw_type'] {
			return raw_type
		}
		if raw_name := other.attributes['raw_type'] {
			mut attributes := map[string]string{}
			if object_id := other.attributes['raw_type_object_id'] {
				if object_id != '' {
					attributes['object_id'] = object_id
				}
			}
			return brew_runtime.structured_value('Module', raw_name, attributes)
		}
	}
	if other.type_name in ['T::Types::TypedClass', 'T::Types::TypedModule'] {
		if underlying_class := other.map_data['underlying_class'] {
			return underlying_class
		}
		if underlying_name := other.attributes['underlying_class'] {
			return brew_runtime.object_value('Module', underlying_name)
		}
	}
	return none
}

fn (simple &SimpleType) subtype_of_boundary(other brew_runtime.Value) BaseSubtypeResult {
	raw_type := simple_other_raw_type(other) or { return .no }
	return simple_module_subtype(simple.raw_type, raw_type)
}

fn simple_is_special_module(raw_type brew_runtime.Value, module_name string) bool {
	if raw_type.attributes['canonical_constant'] or { 'true' } == 'false' {
		return false
	}
	if module_name in ['Array', 'Hash', 'Enumerable', 'Enumerator', 'Range'] {
		return true
	}
	if module_name == 'Set' {
		return raw_type.attributes['autoload'] or { 'false' } != 'true' && raw_type.attributes['const_defined'] or { 'true' } == 'true'
	}
	return false
}

fn new_simple_special_type_value(module_name string, key string, mut pool SimpleTypePool) brew_runtime.Value {
	type_name, display_name, frozen := match module_name {
		'Array' { 'T::Types::TypedArray::Untyped', 'T::Array[T.untyped]', 'true' }
		'Hash' { 'T::Types::TypedHash::Untyped', 'T::Hash[T.untyped, T.untyped]', 'true' }
		'Enumerable' { 'T::Types::TypedEnumerable::Untyped', 'T::Enumerable[T.untyped]', 'false' }
		'Enumerator' { 'T::Types::TypedEnumerator::Untyped', 'T::Enumerator[T.untyped]', 'false' }
		'Range' { 'T::Types::TypedRange::Untyped', 'T::Range[T.untyped]', 'false' }
		'Set' { 'T::Types::TypedSet::Untyped', 'T::Set[T.untyped]', 'false' }
		else { panic('unsupported special module ${module_name}') }
	}
	base_type := new_custom_base_type(type_name, display_name, [module_name], [])
	pool.base_types[key] = base_type
	return brew_runtime.structured_value(type_name, display_name, {
		'base_type_address': u64(voidptr(base_type)).str()
		'frozen':            frozen
		'pool_key':          key
		'underlying_class':  module_name
	})
}

fn simple_type_value(simple &SimpleType) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'T::Types::Simple'
		repr: simple.name()
		map_data: {
			'raw_type': simple.raw_type
		}
		attributes: {
			'base_type_address':   u64(voidptr(simple.base_type)).str()
			'raw_type':            simple.name()
			'raw_type_object_id':  simple_module_object_id(simple.raw_type)
			'simple_type_address': u64(voidptr(simple)).str()
		}
	}
}

fn simple_type_from_value(value brew_runtime.Value) &SimpleType {
	address := value.attributes['simple_type_address'] or { panic('invalid Simple receiver') }
	return unsafe { &SimpleType(voidptr(address.u64())) }
}

fn simple_type_from_args(args []brew_runtime.Value) &SimpleType {
	if args.len == 0 {
		panic('Simple method requires a receiver')
	}
	return simple_type_from_value(args[0])
}

fn simple_nilable_type_value(nilable &SimpleNilableType) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'T::Private::Types::SimplePairUnion'
		repr: nilable.name()
		map_data: {
			'type_a': simple_type_value(nilable.non_nil_type)
			'type_b': simple_type_value(nilable.nil_type)
		}
		attributes: {
			'raw_a':                     nilable.non_nil_type.name()
			'raw_b':                     nilable.nil_type.name()
			'simple_pair_union_address': u64(voidptr(nilable)).str()
		}
	}
}

fn simple_nilable_type_from_value(value brew_runtime.Value) &SimpleNilableType {
	address := value.attributes['simple_pair_union_address'] or {
		panic('invalid SimplePairUnion receiver')
	}
	return unsafe { &SimpleNilableType(voidptr(address.u64())) }
}

// Ruby attr_reader `attr_reader :raw_type` at line 10.
pub fn ruby_simple_l10_d1_raw_type(args ...brew_runtime.Value) brew_runtime.Value {
	return simple_type_from_args(args).raw_type
}

// Ruby method `initialize(raw_type)` at line 12.
pub fn ruby_simple_l12_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Simple#initialize requires a raw type')
	}
	return simple_type_value(new_simple_type(args[0]))
}

// Ruby method `build_type` at line 16.
pub fn ruby_simple_l16_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return simple_type_from_args(args).build_type()
}

// Ruby method `name` at line 21.
pub fn ruby_simple_l21_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	simple := simple_type_from_args(args)
	if simple.name_is_nil {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_value(simple.name())
}

// Ruby method `recursively_valid?(obj)` at line 38.
pub fn ruby_simple_l38_d5_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Simple#recursively_valid? requires an object')
	}
	return brew_runtime.bool_value(simple_type_from_args(args).recursively_valid(args[1]))
}

// Ruby method `valid?(obj)` at line 43.
pub fn ruby_simple_l43_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Simple#valid? requires an object')
	}
	return brew_runtime.bool_value(simple_type_from_args(args).valid(args[1]))
}

// Ruby method `subtype_of_single?(other)` at line 48.
pub fn ruby_simple_l48_d7_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Simple#subtype_of_single? requires another type')
	}
	return base_subtype_boundary_value(simple_type_from_args(args).subtype_of_boundary(args[1]))
}

// Ruby method `error_message(obj)` at line 63.
pub fn ruby_simple_l63_d8_error_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Simple#error_message requires an object')
	}
	return brew_runtime.string_value(simple_type_from_args(args).error_message(args[1]) or {
		panic(err)
	})
}

// Ruby method `to_nilable` at line 79.
pub fn ruby_simple_l79_d9_to_nilable(args ...brew_runtime.Value) brew_runtime.Value {
	return simple_nilable_type_value(simple_type_from_args(args).to_nilable() or { panic(err) })
}

// Ruby method `self.type_for_module(mod)` at line 97.
pub fn ruby_simple_l97_d10_self_type_for_module(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Simple::Private::Pool.type_for_module requires a module')
	}
	return simple_type_for_module(args[0])
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Validates that an object belongs to the specified class.
// 6:   class Simple < Base
// 7:     NAME_METHOD = Module.instance_method(:name)
// 8:     private_constant(:NAME_METHOD)
// 9:
// 10:     attr_reader :raw_type
// 11:
// 12:     def initialize(raw_type)
// 13:       @raw_type = raw_type
// 14:     end
// 15:
// 16:     def build_type
// 17:       nil
// 18:     end
// 19:
// 20:     # overrides Base
// 21:     def name
// 22:       # Memoize to mitigate pathological performance with anonymous modules (https://bugs.ruby-lang.org/issues/11119)
// 23:       #
// 24:       # `name` isn't normally a hot path for types, but it is used in initializing a T::Types::Union,
// 25:       # and so in `T.nilable`, and so in runtime constructions like `x = T.let(nil, T.nilable(Integer))`.
// 26:       #
// 27:       # Care more about back compat than we do about performance here.
// 28:       # Once 2.6 is well in the rear view mirror, we can replace this.
// 29:       # rubocop:disable Performance/BindCall
// 30:       @name ||= (NAME_METHOD.bind(@raw_type).call || @raw_type.name).freeze
// 31:       # rubocop:enable Performance/BindCall
// 32:     end
// 33:
// 34:     # overrides Base
// 35:     #
// 36:     # Identical to valid?; defined directly so the leaf-type hot path (every
// 37:     # element check in a typed collection walk) skips the Base delegator frame.
// 38:     def recursively_valid?(obj)
// 39:       obj.is_a?(@raw_type)
// 40:     end
// 41:
// 42:     # overrides Base
// 43:     def valid?(obj)
// 44:       obj.is_a?(@raw_type)
// 45:     end
// 46:
// 47:     # overrides Base
// 48:     private def subtype_of_single?(other)
// 49:       case other
// 50:       when Simple
// 51:         @raw_type <= other.raw_type
// 52:       when TypedClass, TypedModule
// 53:         # This case is a bit odd--we would have liked to solve this like we do
// 54:         # for `T::Array` et al., but don't for backwards compatibility.
// 55:         # See `type_for_module` below.
// 56:         @raw_type <= other.underlying_class
// 57:       else
// 58:         false
// 59:       end
// 60:     end
// 61:
// 62:     # overrides Base
// 63:     private def error_message(obj)
// 64:       error_message = super(obj)
// 65:       actual_name = obj.class.name
// 66:
// 67:       return error_message unless name == actual_name
// 68:
// 69:       <<~MSG.strip
// 70:         #{error_message}
// 71:
// 72:         The expected type and received object type have the same name but refer to different constants.
// 73:         Expected type is #{name} with object id #{@raw_type.__id__}, but received type is #{actual_name} with object id #{obj.class.__id__}.
// 74:
// 75:         There might be a constant reloading problem in your application.
// 76:       MSG
// 77:     end
// 78:
// 79:     def to_nilable
// 80:       @nilable ||= T::Private::Types::SimplePairUnion.new(
// 81:         self,
// 82:         T::Utils::Nilable::NIL_TYPE,
// 83:       )
// 84:     end
// 85:
// 86:     module Private
// 87:       module Pool
// 88:         CACHE_FROZEN_OBJECTS = begin
// 89:           ObjectSpace::WeakMap.new[1] = 1
// 90:           true # Ruby 2.7 and newer
// 91:                                rescue ArgumentError # Ruby 2.6 and older
// 92:                                  false
// 93:         end
// 94:
// 95:         @cache = ObjectSpace::WeakMap.new
// 96:
// 97:         def self.type_for_module(mod)
// 98:           cached = @cache[mod]
// 99:           return cached if cached
// 100:
// 101:           type = if mod == ::Array
// 102:             TypedArray::Untyped::Private::INSTANCE
// 103:           elsif mod == ::Hash
// 104:             TypedHash::Untyped::Private::INSTANCE
// 105:           elsif mod == ::Enumerable
// 106:             TypedEnumerable::Untyped.new
// 107:           elsif mod == ::Enumerator
// 108:             TypedEnumerator::Untyped.new
// 109:           elsif mod == ::Range
// 110:             TypedRange::Untyped.new
// 111:           elsif !Object.autoload?(:Set) && Object.const_defined?(:Set) && mod == ::Set
// 112:             TypedSet::Untyped.new
// 113:           else
// 114:             # ideally we would have a case mapping from ::Class -> T::Class and
// 115:             # ::Module -> T::Module here but for backwards compatibility we
// 116:             # don't have that, and instead have a special case in subtype_of_single?
// 117:             Simple.new(mod)
// 118:           end
// 119:
// 120:           # Unfortunately, we still need to check if the module is frozen,
// 121:           # since on 2.6 and older WeakMap adds a finalizer to the key that is added
// 122:           # to the map, so that it can clear the map entry when the key is
// 123:           # garbage collected.
// 124:           # For a frozen object, though, adding a finalizer is not a valid
// 125:           # operation, so this still raises if `mod` is frozen.
// 126:           if CACHE_FROZEN_OBJECTS || (!mod.frozen? && !type.frozen?)
// 127:             @cache[mod] = type
// 128:           end
// 129:           type
// 130:         end
// 131:       end
// 132:     end
// 133:   end
// 134: end
