module types

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/enum.rb`.
// The original source is retained below until every stub has a typed V body.
const enum_unbound_suffix = " Enums are not initialized until the 'enums do' block they are defined in has finished running."

pub struct EnumDefinition {
pub:
	name       string
	serialized ?brew_runtime.Value
}

pub struct EnumLookup {
pub:
	found bool
	value &EnumValue = unsafe { nil }
}

@[heap]
pub struct EnumValue {
pub:
	class &EnumClass
mut:
	serialized_value brew_runtime.Value
	uses_default     bool
	const_name       string
	bound            bool
}

@[heap]
pub struct EnumClass {
	mutex &sync.Mutex = sync.new_mutex()
pub:
	name    string
	is_base bool
mut:
	started bool
	fully   bool
	values  []&EnumValue
	mapping map[string]&EnumValue
}

pub fn new_enum_class(name string) &EnumClass {
	return &EnumClass{
		name: name
		is_base: name == 'T::Enum'
		mapping: map[string]&EnumValue{}
	}
}

fn enum_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn enum_serialized_key(value brew_runtime.Value) string {
	return '${value.type_name}\0${value.repr}'
}

fn enum_unbound_value_message(class_name string) string {
	return 'Attempting to access Enum value on ${class_name} before it has been initialized.' + enum_unbound_suffix
}

fn enum_unbound_values_message(class_name string) string {
	return 'Attempting to access values of ${class_name} before it has been initialized.' + enum_unbound_suffix
}

fn enum_unbound_mapping_message(class_name string) string {
	return 'Attempting to access serialization map of ${class_name} before it has been initialized.' + enum_unbound_suffix
}

pub fn (mut class EnumClass) begin_initializing() ! {
	class.mutex.lock()
	defer {
		class.mutex.unlock()
	}
	if class.is_base {
		return error('enums cannot be defined for T::Enum')
	}
	if class.fully {
		return error('Enum ${class.name} was already initialized')
	}
	if class.started {
		return error('Enum ${class.name} is still initializing')
	}
	class.started = true
	class.values = []&EnumValue{}
	class.mapping = map[string]&EnumValue{}
}

pub fn (mut class EnumClass) new_value(serialized ?brew_runtime.Value) !&EnumValue {
	class.mutex.lock()
	defer {
		class.mutex.unlock()
	}
	if class.is_base {
		return error('T::Enum is abstract')
	}
	if !class.started {
		return error("Must instantiate all enum values of ${class.name} inside 'enums do'.")
	}
	if class.fully {
		return error('Cannot instantiate a new enum value of ${class.name} after it has been initialized.')
	}
	mut value := &EnumValue{
		class: class
		serialized_value: enum_nil_value()
		uses_default: true
	}
	if custom := serialized {
		value.serialized_value = custom
		value.uses_default = false
	}
	class.values << value
	return value
}

pub fn (mut value EnumValue) bind_name(name string) {
	clean_name := name.trim_string_left(':')
	value.const_name = clean_name
	if value.uses_default {
		value.serialized_value = brew_runtime.string_value(clean_name.to_lower())
	}
	value.bound = true
}

pub fn (value &EnumValue) serialize_value() !brew_runtime.Value {
	if !value.bound {
		return error(enum_unbound_value_message(value.class.name))
	}
	return value.serialized_value
}

pub fn (value &EnumValue) inspect_value() string {
	name := if value.bound { value.const_name } else { '__UNINITIALIZED__' }
	return '#<${value.class.name}::${name}>'
}

pub fn (mut class EnumClass) finish_initializing(constants map[string]&EnumValue) ! {
	class.mutex.lock()
	if !class.started || class.fully {
		class.mutex.unlock()
		return error('Enum ${class.name} is not initializing')
	}
	mut mapping := map[string]&EnumValue{}
	mut assigned := []&EnumValue{}
	for name, value in constants {
		if value.class != class {
			class.mutex.unlock()
			return error('Invalid constant ${class.name}::${name} on enum. All constants defined for an enum must be instances itself (e.g. `Foo = new`).')
		}
		mut bound_value := unsafe { &EnumValue(value) }
		bound_value.bind_name(name)
		key := enum_serialized_key(bound_value.serialized_value)
		if key in mapping {
			class.mutex.unlock()
			return error("Enum values must have unique serializations. Value '${value.serialized_value.as_string()}' is repeated on ${class.name}.")
		}
		mapping[key] = bound_value
		assigned << bound_value
	}
	mut orphaned := []string{}
	for value in class.values {
		if value !in assigned {
			orphaned << value.serialized_value.as_string()
		}
	}
	if orphaned.len > 0 {
		class.mutex.unlock()
		return error('Enum values must be assigned to constants: ${orphaned}')
	}
	class.mapping = mapping.clone()
	class.fully = true
	class.mutex.unlock()
}

pub fn define_enum(class_name string, definitions []EnumDefinition) !&EnumClass {
	mut class := new_enum_class(class_name)
	class.begin_initializing()!
	mut constants := map[string]&EnumValue{}
	for definition in definitions {
		constants[definition.name] = class.new_value(definition.serialized)!
	}
	class.finish_initializing(constants)!
	return class
}

pub fn (mut class EnumClass) all_values() ![]&EnumValue {
	class.mutex.lock()
	defer {
		class.mutex.unlock()
	}
	if !class.fully {
		return error(enum_unbound_values_message(class.name))
	}
	return class.values.clone()
}

pub fn (mut class EnumClass) try_deserialize(value brew_runtime.Value) !EnumLookup {
	class.mutex.lock()
	defer {
		class.mutex.unlock()
	}
	if !class.fully {
		return error(enum_unbound_mapping_message(class.name))
	}
	if found := class.mapping[enum_serialized_key(value)] {
		return EnumLookup{
			found: true
			value: found
		}
	}
	return EnumLookup{}
}

pub fn (mut class EnumClass) from_serialized(value brew_runtime.Value) !&EnumValue {
	result := class.try_deserialize(value)!
	if result.found {
		return result.value
	}
	return error('Enum ${class.name} key not found: ${value.as_string()}')
}

pub fn (mut class EnumClass) has_serialized(value brew_runtime.Value) !bool {
	class.mutex.lock()
	defer {
		class.mutex.unlock()
	}
	if !class.fully {
		return error(enum_unbound_mapping_message(class.name))
	}
	return enum_serialized_key(value) in class.mapping
}

fn enum_class_value(class &EnumClass) brew_runtime.Value {
	return brew_runtime.structured_value('Class', class.name, {
		'enum_class_address': u64(voidptr(class)).str()
		'name':               class.name
	})
}

fn enum_class_from_value(value brew_runtime.Value) &EnumClass {
	address := value.attribute('enum_class_address') or { panic('invalid Enum class receiver') }
	return unsafe { &EnumClass(voidptr(address.u64())) }
}

fn enum_value_value(value &EnumValue) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: value.class.name
		repr: value.inspect_value()
		map_data: {
			'serialized': value.serialized_value
		}
		attributes: {
			'enum_value_address': u64(voidptr(value)).str()
			'enum_class_address': u64(voidptr(value.class)).str()
			'class_name':         value.class.name
			'const_name':         value.const_name
			'bound':              value.bound.str()
		}
	}
}

fn enum_value_from_value(value brew_runtime.Value) &EnumValue {
	address := value.attribute('enum_value_address') or { panic('invalid Enum value receiver') }
	return unsafe { &EnumValue(voidptr(address.u64())) }
}

fn enum_values_value(values []&EnumValue) brew_runtime.Value {
	return brew_runtime.array_value(values.map(enum_value_value(it)))
}

fn enum_compare_serialized(left brew_runtime.Value, right brew_runtime.Value) ?int {
	if left.type_name in ['Integer', 'Float'] && right.type_name in ['Integer', 'Float'] {
		left_number := left.as_float() or { return none }
		right_number := right.as_float() or { return none }
		return if left_number < right_number {
			-1
		} else if left_number > right_number { 1 } else { 0 }
	}
	if left.type_name != right.type_name {
		return none
	}
	return if left.as_string() < right.as_string() {
		-1
	} else if left.as_string() > right.as_string() { 1 } else { 0 }
}

fn enum_json(value brew_runtime.Value) string {
	if value.type_name == 'String' {
		return '"${value.as_string().replace('\\', '\\\\').replace('"', '\\"')}"'
	}
	if value.type_name == 'NilClass' {
		return 'null'
	}
	return value.as_string()
}

fn enum_serialized_argument(value brew_runtime.Value) brew_runtime.Value {
	return value.map_data['value'] or { value }
}

// Ruby method `self.values` at line 57.
pub fn ruby_enum_l57_d1_self_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum.values requires a class receiver')
	}
	mut class := enum_class_from_value(args[0])
	return enum_values_value(class.all_values() or { panic(err) })
}

// Ruby method `self.each_value(&blk)` at line 67.
pub fn ruby_enum_l67_d2_self_each_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum.each_value requires a class receiver')
	}
	mut class := enum_class_from_value(args[0])
	values := class.all_values() or { panic(err) }
	if args.len > 1 && args[1].type_name != 'NilClass' {
		return enum_values_value(values)
	}
	return brew_runtime.Value{
		type_name: 'Enumerator'
		repr: '#<Enumerator: ${class.name}:each_value>'
		array_data: values.map(enum_value_value(it))
	}
}

// Ruby method `self.try_deserialize(serialized_val)` at line 80.
pub fn ruby_enum_l80_d3_self_try_deserialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Enum.try_deserialize requires a class receiver and serialized value')
	}
	mut class := enum_class_from_value(args[0])
	result := class.try_deserialize(args[1]) or { panic(err) }
	return if result.found { enum_value_value(result.value) } else { enum_nil_value() }
}

// Ruby method `self.from_serialized(serialized_val)` at line 95.
pub fn ruby_enum_l95_d4_self_from_serialized(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Enum.from_serialized requires a class receiver and serialized value')
	}
	mut class := enum_class_from_value(args[0])
	return enum_value_value(class.from_serialized(args[1]) or { panic(err) })
}

// Ruby method `self.has_serialized?(serialized_val)` at line 106.
pub fn ruby_enum_l106_d5_self_has_serialized(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Enum.has_serialized? requires a class receiver and serialized value')
	}
	mut class := enum_class_from_value(args[0])
	return brew_runtime.bool_value(class.has_serialized(args[1]) or { panic(err) })
}

// Ruby method `self.serialize(instance)` at line 115.
pub fn ruby_enum_l115_d6_self_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 || args[1].type_name == 'NilClass' {
		return enum_nil_value()
	}
	class := enum_class_from_value(args[0])
	if class.is_base {
		panic('Cannot call T::Enum.serialize directly. You must call on a specific child class.')
	}
	value := enum_value_from_value(args[1])
	if value.class != class {
		panic('Cannot call #serialize on a value that is not an instance of ${class.name}.')
	}
	return value.serialize_value() or { panic(err) }
}

// Ruby method `self.deserialize(mongo_value)` at line 132.
pub fn ruby_enum_l132_d7_self_deserialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Enum.deserialize requires a class receiver and serialized value')
	}
	class := enum_class_from_value(args[0])
	if class.is_base {
		panic('Cannot call T::Enum.deserialize directly. You must call on a specific child class.')
	}
	return ruby_enum_l95_d4_self_from_serialized(args[0], args[1])
}

// Ruby method `dup` at line 142.
pub fn ruby_enum_l142_d8_dup(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum#dup requires a receiver')
	}
	return args[0]
}

// Ruby method `clone` at line 147.
pub fn ruby_enum_l147_d9_clone(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum#clone requires a receiver')
	}
	return args[0]
}

// Ruby method `serialize` at line 167.
pub fn ruby_enum_l167_d10_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum#serialize requires a receiver')
	}
	return enum_value_from_value(args[0]).serialize_value() or { panic(err) }
}

// Ruby method `to_json(*args)` at line 177.
pub fn ruby_enum_l177_d11_to_json(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum#to_json requires a receiver')
	}
	serialized := enum_value_from_value(args[0]).serialize_value() or { panic(err) }
	return brew_runtime.string_value(enum_json(serialized))
}

// Ruby method `as_json(*args)` at line 182.
pub fn ruby_enum_l182_d12_as_json(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum#as_json requires a receiver')
	}
	serialized := enum_value_from_value(args[0]).serialize_value() or { panic(err) }
	return serialized.map_data['as_json'] or { serialized }
}

// Ruby method `to_s` at line 192.
pub fn ruby_enum_l192_d13_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_enum_l197_d14_inspect(...args)
}

// Ruby method `inspect` at line 197.
pub fn ruby_enum_l197_d14_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum#inspect requires a receiver')
	}
	return brew_runtime.string_value(enum_value_from_value(args[0]).inspect_value())
}

// Ruby method `<=>(other)` at line 202.
pub fn ruby_enum_l202_d15_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return enum_nil_value()
	}
	left := enum_value_from_value(args[0])
	if args[1].attributes['enum_class_address'] or { '' } != u64(voidptr(left.class)).str() {
		return enum_nil_value()
	}
	right := enum_value_from_value(args[1])
	comparison := enum_compare_serialized(left.serialize_value() or { panic(err) }, right.serialize_value() or {
		panic(err)
	}) or { return enum_nil_value() }
	return brew_runtime.int_value(comparison)
}

// Ruby method `to_str` at line 219.
pub fn ruby_enum_l219_d16_to_str(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum#to_str requires a receiver')
	}
	mut state := global_configuration()
	state.mutex.lock()
	legacy := state.legacy_t_enum_mode
	state.mutex.unlock()
	if !legacy {
		panic('Implicit conversion of Enum instances to strings is not allowed. Call #serialize instead.')
	}
	value := enum_value_from_value(args[0])
	return brew_runtime.string_value((value.serialize_value() or { panic(err) }).as_string())
}

// Ruby method `serialize; end` at line 244.
pub fn ruby_enum_l244_d17_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_enum_l167_d10_serialize(...args)
}

// Ruby method `==(other)` at line 249.
pub fn ruby_enum_l249_d18_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	value := enum_value_from_value(args[0])
	if args[1].type_name == 'String' {
		mut state := global_configuration()
		state.mutex.lock()
		legacy := state.legacy_t_enum_mode
		state.mutex.unlock()
		return brew_runtime.bool_value(legacy && (value.serialize_value() or { panic(err) }).as_string() == args[1].as_string())
	}
	return brew_runtime.bool_value(args[0].attributes['enum_value_address'] or { '' } == args[1].attributes['enum_value_address'] or {
		'!'
	})
}

// Ruby method `===(other)` at line 265.
pub fn ruby_enum_l265_d19_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_enum_l249_d18_anonymous(...args)
}

// Ruby method `comparison_assertion_failed(method, other)` at line 282.
pub fn ruby_enum_l282_d20_comparison_assertion_failed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('SoftAssertion', 'Enum to string comparison not allowed. Compare to the Enum instance directly instead. See go/enum-migration', {
		'method': if args.len > 1 { args[1].as_string() } else { '' }
		'other':  if args.len > 2 { args[2].as_string() } else { '' }
	})
}

// Ruby method `initialize(serialized_val=UNSET)` at line 303.
pub fn ruby_enum_l303_d21_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum#initialize requires an enum class')
	}
	mut class := enum_class_from_value(args[0])
	serialized := if args.len > 1 { ?brew_runtime.Value(args[1]) } else { none }
	return enum_value_value(class.new_value(serialized) or { panic(err) })
}

// Ruby method `assert_bound!` at line 319.
pub fn ruby_enum_l319_d22_assert_bound(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum#assert_bound! requires a receiver')
	}
	value := enum_value_from_value(args[0])
	value.serialize_value() or { panic(err) }
	return enum_nil_value()
}

// Ruby method `_bind_name(const_name)` at line 326.
pub fn ruby_enum_l326_d23_bind_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Enum#_bind_name requires a receiver and constant name')
	}
	mut value := enum_value_from_value(args[0])
	value.bind_name(args[1].as_string())
	return args[1]
}

// Ruby method `const_to_serialized_val(const_name)` at line 333.
pub fn ruby_enum_l333_d24_const_to_serialized_val(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('const_to_serialized_val requires a constant name')
	}
	return brew_runtime.string_value(args[args.len - 1].as_string().trim_string_left(':').to_lower())
}

// Ruby method `self.started_initializing?` at line 341.
pub fn ruby_enum_l341_d25_self_started_initializing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum.started_initializing? requires a class receiver')
	}
	mut class := enum_class_from_value(args[0])
	class.mutex.lock()
	started := class.started
	class.mutex.unlock()
	return brew_runtime.bool_value(started)
}

// Ruby method `self.fully_initialized?` at line 349.
pub fn ruby_enum_l349_d26_self_fully_initialized(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum.fully_initialized? requires a class receiver')
	}
	mut class := enum_class_from_value(args[0])
	class.mutex.lock()
	fully := class.fully
	class.mutex.unlock()
	return brew_runtime.bool_value(fully)
}

// Ruby method `self._register_instance(instance)` at line 358.
pub fn ruby_enum_l358_d27_self_register_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Enum._register_instance requires a class and value')
	}
	mut class := enum_class_from_value(args[0])
	value := enum_value_from_value(args[1])
	class.mutex.lock()
	if value !in class.values {
		class.values << value
	}
	class.mutex.unlock()
	return args[1]
}

// Ruby method `self.enums(&blk)` at line 366.
pub fn ruby_enum_l366_d28_self_enums(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Enum.enums requires a class receiver and constants descriptor')
	}
	mut class := enum_class_from_value(args[0])
	class.begin_initializing() or { panic(err) }
	descriptor := args[1].map_data['constants'] or { args[1] }
	mut constants := map[string]&EnumValue{}
	for name, serialized in descriptor.map_data {
		custom := if serialized.type_name == 'T::Enum::UNSET' {
			none
		} else {
			?brew_runtime.Value(serialized)
		}
		constants[name] = class.new_value(custom) or { panic(err) }
	}
	class.finish_initializing(constants) or { panic(err) }
	return enum_nil_value()
}

// Ruby method `self.inherited(child_class)` at line 407.
pub fn ruby_enum_l407_d29_self_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Enum.inherited requires parent and child classes')
	}
	parent := enum_class_from_value(args[0])
	if !parent.is_base {
		panic('Inheriting from children of T::Enum is prohibited')
	}
	return args[1]
}

// Ruby method `_dump(_level)` at line 420.
pub fn ruby_enum_l420_d30_dump(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Enum#_dump requires a receiver')
	}
	serialized := enum_value_from_value(args[0]).serialize_value() or { panic(err) }
	return brew_runtime.Value{
		type_name: 'String'
		repr: serialized.as_string()
		map_data: {
			'value': serialized
		}
		attributes: {
			'marshal': 'true'
		}
	}
}

// Ruby method `self._load(args)` at line 425.
pub fn ruby_enum_l425_d31_self_load(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Enum._load requires a class and dumped String')
	}
	return ruby_enum_l132_d7_self_deserialize(args[0], enum_serialized_argument(args[1]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: strict
// 3:
// 4: # Enumerations allow for type-safe declarations of a fixed set of values.
// 5: #
// 6: # Every value is a singleton instance of the class (i.e. `Suit::SPADE.is_a?(Suit) == true`).
// 7: #
// 8: # Each value has a corresponding serialized value. By default this is the constant's name converted
// 9: # to lowercase (e.g. `Suit::Club.serialize == 'club'`); however a custom value may be passed to the
// 10: # constructor. Enum will `freeze` the serialized value.
// 11: #
// 12: # @example Declaring an Enum:
// 13: #   class Suit < T::Enum
// 14: #     enums do
// 15: #       CLUB = new
// 16: #       SPADE = new
// 17: #       DIAMOND = new
// 18: #       HEART = new
// 19: #     end
// 20: #   end
// 21: #
// 22: # @example Custom serialization value:
// 23: #   class Status < T::Enum
// 24: #     enums do
// 25: #       READY = new('rdy')
// 26: #       ...
// 27: #     end
// 28: #   end
// 29: #
// 30: # @example Accessing values:
// 31: #   Suit::SPADE
// 32: #
// 33: # @example Converting from serialized value to enum instance:
// 34: #   Suit.deserialize('club') == Suit::CLUB
// 35: #
// 36: # @example Using enums in type signatures:
// 37: #   sig {params(suit: Suit).returns(Boolean)}
// 38: #   def is_red?(suit); ...; end
// 39: #
// 40: # WARNING: Enum instances are singletons that are shared among all their users. Their internals
// 41: # should be kept immutable to avoid unpredictable action at a distance.
// 42: class T::Enum
// 43:   extend T::Sig
// 44:   extend T::Props::CustomType
// 45:
// 46:   # TODO(jez) Might want to restrict this, or make subclasses provide this type
// 47:   SerializedVal = T.type_alias { T.untyped }
// 48:   private_constant :SerializedVal
// 49:
// 50:   ### Enum class methods ###
// 51:   # WithoutRuntime on the hot accessors below installs no method wrapper at all
// 52:   # (not even the one-time wrap a `checked(:never)` sig still pays on first
// 53:   # call). Their bodies are type-safe by construction, so the wrapper validated
// 54:   # nothing useful; Sorbet still reads these sigs statically. The
// 55:   # override/overridable annotations remain as static-only signal.
// 56:   T::Sig::WithoutRuntime.sig { returns(T::Array[T.attached_class]) }
// 57:   def self.values
// 58:     if @values.nil?
// 59:       raise(UNBOUND_VALUES_MESSAGE % self.class)
// 60:     end
// 61:     @values
// 62:   end
// 63:
// 64:   # This exists for compatibility with the interface of `Hash` & mostly to support
// 65:   # the HashEachMethods Rubocop.
// 66:   T::Sig::WithoutRuntime.sig { params(blk: T.nilable(T.proc.params(arg0: T.attached_class).void)).returns(T.any(T::Enumerator[T.attached_class], T::Array[T.attached_class])) }
// 67:   def self.each_value(&blk)
// 68:     if blk
// 69:       values.each(&blk)
// 70:     else
// 71:       values.each
// 72:     end
// 73:   end
// 74:
// 75:   # Convert from serialized value to enum instance
// 76:   #
// 77:   # Note: It would have been nice to make this method final before people started overriding it.
// 78:   # Note: Failed CriticalMethodsNoRuntimeTypingTest
// 79:   T::Sig::WithoutRuntime.sig { params(serialized_val: SerializedVal).returns(T.nilable(T.attached_class)) }
// 80:   def self.try_deserialize(serialized_val)
// 81:     if @mapping.nil?
// 82:       raise(UNBOUND_SERIALIZATION_MAP_MESSAGE % self.class)
// 83:     end
// 84:     @mapping[serialized_val]
// 85:   end
// 86:
// 87:   # Convert from serialized value to enum instance.
// 88:   #
// 89:   # Note: It would have been nice to make this method final before people started overriding it.
// 90:   # Note: Failed CriticalMethodsNoRuntimeTypingTest
// 91:   #
// 92:   # @return [self]
// 93:   # @raise [KeyError] if serialized value does not match any instance.
// 94:   T::Sig::WithoutRuntime.sig { overridable.params(serialized_val: SerializedVal).returns(T.attached_class) }
// 95:   def self.from_serialized(serialized_val)
// 96:     res = try_deserialize(serialized_val)
// 97:     if res.nil?
// 98:       raise KeyError.new("Enum #{self} key not found: #{serialized_val.inspect}")
// 99:     end
// 100:     res
// 101:   end
// 102:
// 103:   # Note: It would have been nice to make this method final before people started overriding it.
// 104:   # @return [Boolean] Does the given serialized value correspond with any of this enum's values.
// 105:   T::Sig::WithoutRuntime.sig { overridable.params(serialized_val: SerializedVal).returns(T::Boolean) }
// 106:   def self.has_serialized?(serialized_val)
// 107:     if @mapping.nil?
// 108:       raise(UNBOUND_SERIALIZATION_MAP_MESSAGE % self.class)
// 109:     end
// 110:     @mapping.include?(serialized_val)
// 111:   end
// 112:
// 113:   # Note: Failed CriticalMethodsNoRuntimeTypingTest
// 114:   T::Sig::WithoutRuntime.sig { override.params(instance: T.nilable(T::Enum)).returns(SerializedVal) }
// 115:   def self.serialize(instance)
// 116:     # This is needed otherwise if a Chalk::ODM::Document with a property of the shape
// 117:     # T::Hash[T.nilable(MyEnum), Integer] and a value that looks like {nil => 0} is
// 118:     # serialized, we throw the error on L102.
// 119:     return nil if instance.nil?
// 120:
// 121:     if self == T::Enum
// 122:       raise "Cannot call T::Enum.serialize directly. You must call on a specific child class."
// 123:     end
// 124:     if instance.class != self
// 125:       raise "Cannot call #serialize on a value that is not an instance of #{self}."
// 126:     end
// 127:     instance.serialize
// 128:   end
// 129:
// 130:   # Note: Failed CriticalMethodsNoRuntimeTypingTest
// 131:   T::Sig::WithoutRuntime.sig { override.params(mongo_value: SerializedVal).returns(T.attached_class) }
// 132:   def self.deserialize(mongo_value)
// 133:     if self == T::Enum
// 134:       raise "Cannot call T::Enum.deserialize directly. You must call on a specific child class."
// 135:     end
// 136:     self.from_serialized(mongo_value)
// 137:   end
// 138:
// 139:   ### Enum instance methods ###
// 140:
// 141:   sig { returns(T.self_type) }
// 142:   def dup
// 143:     self
// 144:   end
// 145:
// 146:   sig { returns(T.self_type).checked(:tests) }
// 147:   def clone
// 148:     self
// 149:   end
// 150:
// 151:   # Format strings (`%s` is the class) for the "accessed before initialized"
// 152:   # errors, so the various raise sites can't drift from each other.
// 153:   UNBOUND_VALUE_MESSAGE = "Attempting to access Enum value on %s before it has been initialized." \
// 154:     " Enums are not initialized until the 'enums do' block they are defined in has finished running."
// 155:   private_constant :UNBOUND_VALUE_MESSAGE
// 156:
// 157:   UNBOUND_VALUES_MESSAGE = "Attempting to access values of %s before it has been initialized." \
// 158:     " Enums are not initialized until the 'enums do' block they are defined in has finished running."
// 159:   private_constant :UNBOUND_VALUES_MESSAGE
// 160:
// 161:   UNBOUND_SERIALIZATION_MAP_MESSAGE = "Attempting to access serialization map of %s before it has been initialized." \
// 162:     " Enums are not initialized until the 'enums do' block they are defined in has finished running."
// 163:   private_constant :UNBOUND_SERIALIZATION_MAP_MESSAGE
// 164:
// 165:   # Note: Failed CriticalMethodsNoRuntimeTypingTest
// 166:   T::Sig::WithoutRuntime.sig { returns(SerializedVal) }
// 167:   def serialize
// 168:     # Same check and message as assert_bound!, open-coded to avoid the extra
// 169:     # method frame on this hot path.
// 170:     if @const_name.nil?
// 171:       raise(UNBOUND_VALUE_MESSAGE % self.class)
// 172:     end
// 173:     @serialized_val
// 174:   end
// 175:
// 176:   sig { params(args: T.untyped).returns(T.untyped) }
// 177:   def to_json(*args)
// 178:     serialize.to_json(*args)
// 179:   end
// 180:
// 181:   sig { params(args: T.untyped).returns(T.untyped) }
// 182:   def as_json(*args)
// 183:     serialized_val = serialize
// 184:     return serialized_val unless serialized_val.respond_to?(:as_json)
// 185:     serialized_val.as_json(*args)
// 186:   end
// 187:
// 188:   # `to_s` keeps delegating to `inspect` rather than `alias_method :to_s,
// 189:   # :inspect` so a subclass that overrides `inspect` still has its `to_s`
// 190:   # reflect the override.
// 191:   T::Sig::WithoutRuntime.sig { returns(String) }
// 192:   def to_s
// 193:     inspect
// 194:   end
// 195:
// 196:   T::Sig::WithoutRuntime.sig { returns(String) }
// 197:   def inspect
// 198:     "#<#{self.class.name}::#{@const_name || '__UNINITIALIZED__'}>"
// 199:   end
// 200:
// 201:   T::Sig::WithoutRuntime.sig { params(other: BasicObject).returns(T.nilable(Integer)) }
// 202:   def <=>(other)
// 203:     case other
// 204:     when self.class
// 205:       self.serialize <=> other.serialize
// 206:     else
// 207:       nil
// 208:     end
// 209:   end
// 210:
// 211:   # NB: Do not call this method. This exists to allow for a safe migration path in places where enum
// 212:   # values are compared directly against string values.
// 213:   #
// 214:   # Ruby's string has a weird quirk where `'my_string' == obj` calls obj.==('my_string') if obj
// 215:   # responds to the `to_str` method. It does not actually call `to_str` however.
// 216:   #
// 217:   # See https://ruby-doc.org/core-2.4.0/String.html#method-i-3D-3D
// 218:   T::Sig::WithoutRuntime.sig { returns(String) }
// 219:   def to_str
// 220:     msg = 'Implicit conversion of Enum instances to strings is not allowed. Call #serialize instead.'
// 221:     if T::Configuration.legacy_t_enum_migration_mode?
// 222:       T::Configuration.soft_assert_handler(
// 223:         msg,
// 224:         storytime: {
// 225:           class: self.class.name,
// 226:           caller_location: Kernel.caller_locations(1..1)&.[](0)&.then { "#{_1.path}:#{_1.lineno}" },
// 227:         },
// 228:       )
// 229:       serialize.to_s
// 230:     else
// 231:       Kernel.raise NoMethodError.new(msg)
// 232:     end
// 233:   end
// 234:
// 235:   module LegacyMigrationMode
// 236:     include Kernel
// 237:     extend T::Helpers
// 238:     abstract!
// 239:
// 240:     if T.unsafe(false)
// 241:       # Declare to the type system that the `serialize` method for sure exists
// 242:       # on whatever we mix this into.
// 243:       T::Sig::WithoutRuntime.sig { abstract.returns(T.untyped) }
// 244:       def serialize; end
// 245:     end
// 246:
// 247:     # WithoutRuntime so that comparison_assertion_failed can assume a constant stack depth
// 248:     T::Sig::WithoutRuntime.sig { params(other: BasicObject).returns(T::Boolean) }
// 249:     def ==(other)
// 250:       case other
// 251:       when String
// 252:         if T::Configuration.legacy_t_enum_migration_mode?
// 253:           comparison_assertion_failed(:==, other)
// 254:           self.serialize == other
// 255:         else
// 256:           false
// 257:         end
// 258:       else
// 259:         super(other)
// 260:       end
// 261:     end
// 262:
// 263:     # WithoutRuntime so that comparison_assertion_failed can assume a constant stack depth
// 264:     T::Sig::WithoutRuntime.sig { params(other: BasicObject).returns(T::Boolean) }
// 265:     def ===(other)
// 266:       case other
// 267:       when String
// 268:         if T::Configuration.legacy_t_enum_migration_mode?
// 269:           comparison_assertion_failed(:===, other)
// 270:           self.serialize == other
// 271:         else
// 272:           false
// 273:         end
// 274:       else
// 275:         super(other)
// 276:       end
// 277:     end
// 278:
// 279:     # WithoutRuntime so that caller_locations can assume a constant stack depth
// 280:     # (Otherwise, the first call would be the method with the wrapping, which would have a different stack depth.)
// 281:     T::Sig::WithoutRuntime.sig { params(method: Symbol, other: T.untyped).void }
// 282:     private def comparison_assertion_failed(method, other)
// 283:       T::Configuration.soft_assert_handler(
// 284:         'Enum to string comparison not allowed. Compare to the Enum instance directly instead. See go/enum-migration',
// 285:         storytime: {
// 286:           class: self.class.name,
// 287:           self: self.inspect,
// 288:           other: other,
// 289:           other_class: other.class.name,
// 290:           method: method,
// 291:           caller_location: Kernel.caller_locations(2..2)&.[](0)&.then { "#{_1.path}:#{_1.lineno}" },
// 292:         }
// 293:       )
// 294:     end
// 295:   end
// 296:
// 297:   ### Private implementation ###
// 298:
// 299:   UNSET = T.let(Module.new.freeze, T::Module[T.anything])
// 300:   private_constant :UNSET
// 301:
// 302:   sig { params(serialized_val: SerializedVal).void }
// 303:   def initialize(serialized_val=UNSET)
// 304:     raise 'T::Enum is abstract' if self.class == T::Enum
// 305:     if !self.class.started_initializing?
// 306:       raise "Must instantiate all enum values of #{self.class} inside 'enums do'."
// 307:     end
// 308:     if self.class.fully_initialized?
// 309:       raise "Cannot instantiate a new enum value of #{self.class} after it has been initialized."
// 310:     end
// 311:
// 312:     serialized_val = serialized_val.frozen? ? serialized_val : serialized_val.dup.freeze
// 313:     @serialized_val = T.let(serialized_val, T.nilable(SerializedVal))
// 314:     @const_name = T.let(nil, T.nilable(Symbol))
// 315:     self.class._register_instance(self)
// 316:   end
// 317:
// 318:   T::Sig::WithoutRuntime.sig { returns(NilClass) }
// 319:   private def assert_bound!
// 320:     if @const_name.nil?
// 321:       raise(UNBOUND_VALUE_MESSAGE % self.class)
// 322:     end
// 323:   end
// 324:
// 325:   sig { params(const_name: Symbol).void }
// 326:   def _bind_name(const_name)
// 327:     @const_name = const_name
// 328:     @serialized_val = const_to_serialized_val(const_name) if @serialized_val.equal?(UNSET)
// 329:     freeze
// 330:   end
// 331:
// 332:   sig { params(const_name: Symbol).returns(String) }
// 333:   private def const_to_serialized_val(const_name)
// 334:     # Historical note: We convert to lowercase names because the majority of existing calls to
// 335:     # `make_accessible` were arrays of lowercase strings. Doing this conversion allowed for the
// 336:     # least amount of repetition in migrated declarations.
// 337:     -const_name.to_s.downcase.freeze
// 338:   end
// 339:
// 340:   sig { returns(T::Boolean) }
// 341:   def self.started_initializing?
// 342:     unless defined?(@started_initializing)
// 343:       @started_initializing = T.let(false, T.nilable(T::Boolean))
// 344:     end
// 345:     T.must(@started_initializing)
// 346:   end
// 347:
// 348:   sig { returns(T::Boolean) }
// 349:   def self.fully_initialized?
// 350:     unless defined?(@fully_initialized)
// 351:       @fully_initialized = T.let(false, T.nilable(T::Boolean))
// 352:     end
// 353:     T.must(@fully_initialized)
// 354:   end
// 355:
// 356:   # Maintains the order in which values are defined
// 357:   sig { params(instance: T.untyped).void }
// 358:   def self._register_instance(instance)
// 359:     @values ||= []
// 360:     @values << T.cast(instance, T.attached_class)
// 361:   end
// 362:
// 363:   # Entrypoint for allowing people to register new enum values.
// 364:   # All enum values must be defined within this block.
// 365:   sig { params(blk: T.proc.void).void }
// 366:   def self.enums(&blk)
// 367:     raise "enums cannot be defined for T::Enum" if self == T::Enum
// 368:     raise "Enum #{self} was already initialized" if fully_initialized?
// 369:     raise "Enum #{self} is still initializing" if started_initializing?
// 370:
// 371:     @started_initializing = true
// 372:
// 373:     @values = T.let(nil, T.nilable(T::Array[T.attached_class]))
// 374:
// 375:     yield
// 376:
// 377:     @mapping = T.let(nil, T.nilable(T::Hash[SerializedVal, T.attached_class]))
// 378:     @mapping = {}
// 379:
// 380:     # Freeze the Enum class and bind the constant names into each of the instances.
// 381:     self.constants(false).each do |const_name|
// 382:       instance = self.const_get(const_name, false)
// 383:       if !instance.is_a?(self)
// 384:         raise "Invalid constant #{self}::#{const_name} on enum. " \
// 385:           "All constants defined for an enum must be instances itself (e.g. `Foo = new`)."
// 386:       end
// 387:
// 388:       instance._bind_name(const_name)
// 389:       serialized = instance.serialize
// 390:       if @mapping.include?(serialized)
// 391:         raise "Enum values must have unique serializations. Value '#{serialized}' is repeated on #{self}."
// 392:       end
// 393:       @mapping[serialized] = instance
// 394:     end
// 395:     @values.freeze
// 396:     @mapping.freeze
// 397:
// 398:     orphaned_instances = T.must(@values) - @mapping.values
// 399:     if !orphaned_instances.empty?
// 400:       raise "Enum values must be assigned to constants: #{orphaned_instances.map { |v| v.instance_variable_get('@serialized_val') }}"
// 401:     end
// 402:
// 403:     @fully_initialized = true
// 404:   end
// 405:
// 406:   sig { params(child_class: T::Class[T.anything]).void }
// 407:   def self.inherited(child_class)
// 408:     super
// 409:
// 410:     raise "Inheriting from children of T::Enum is prohibited" if self != T::Enum
// 411:
// 412:     # "oj" gem JSON support
// 413:     if Object.const_defined?(:Oj)
// 414:       Object.const_get(:Oj).register_odd(child_class, child_class, :try_deserialize, :serialize)
// 415:     end
// 416:   end
// 417:
// 418:   # Marshal support
// 419:   sig { params(_level: Integer).returns(String) }
// 420:   def _dump(_level)
// 421:     Marshal.dump(serialize)
// 422:   end
// 423:
// 424:   sig { params(args: String).returns(T.attached_class) }
// 425:   def self._load(args)
// 426:     deserialize(Marshal.load(args)) # rubocop:disable Security/MarshalLoad
// 427:   end
// 428: end
