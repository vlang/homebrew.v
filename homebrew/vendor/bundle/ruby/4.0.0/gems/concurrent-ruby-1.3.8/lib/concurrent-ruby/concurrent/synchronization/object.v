module synchronization

import brew_runtime
import math
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/object.rb`.
// The original source is retained below until every stub has a typed V body.
pub type AtomicFieldUpdate = fn(brew_runtime.Value) !brew_runtime.Value

@[heap]
pub struct AtomicClassState {
mut:
	lock             sync.Mutex
	atomic_fields    []string
	inherited_fields []string
	safe             bool
}

@[heap]
pub struct AtomicSynchronizationObject {
mut:
	lock   sync.RwMutex
	class  &AtomicClassState
	fields map[string]brew_runtime.Value
}

fn atomic_object_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn new_atomic_class(inherited_fields []string) &AtomicClassState {
	return &AtomicClassState{
		inherited_fields: inherited_fields.clone()
	}
}

pub fn (mut class AtomicClassState) mark_safe_initialization() {
	class.lock.lock()
	class.safe = true
	class.lock.unlock()
}

pub fn (mut class AtomicClassState) safe_initialization() bool {
	class.lock.lock()
	safe := class.safe
	class.lock.unlock()
	return safe
}

pub fn (mut class AtomicClassState) add_atomic_fields(names []string) []string {
	class.lock.lock()
	mut methods := []string{}
	for name in names {
		if name.len == 0 {
			continue
		}
		if name !in class.atomic_fields {
			class.atomic_fields << name
		}
		methods << name
		methods << '${name}='
		methods << 'swap_${name}'
		methods << 'compare_and_set_${name}'
		methods << 'update_${name}'
	}
	class.safe = true
	class.lock.unlock()
	return methods
}

pub fn (mut class AtomicClassState) attributes(inherited bool) []string {
	class.lock.lock()
	mut attributes := if inherited { class.inherited_fields.clone() } else { []string{} }
	for name in class.atomic_fields {
		if name !in attributes {
			attributes << name
		}
	}
	class.lock.unlock()
	return attributes
}

pub fn new_atomic_synchronization_object(mut class AtomicClassState) &AtomicSynchronizationObject {
	mut fields := map[string]brew_runtime.Value{}
	for name in class.attributes(true) {
		fields[name] = atomic_object_nil_value()
	}
	return &AtomicSynchronizationObject{
		class: &class
		fields: fields
	}
}

fn atomic_object_values_match(actual brew_runtime.Value, expected brew_runtime.Value) bool {
	if expected.type_name == 'Integer' || expected.type_name == 'Float' {
		if actual.type_name != 'Integer' && actual.type_name != 'Float' {
			return false
		}
		actual_number := actual.as_float() or { return false }
		expected_number := expected.as_float() or { return false }
		if math.is_nan(expected_number) {
			return math.is_nan(actual_number)
		}
		return actual_number == expected_number
	}
	if expected_identity := expected.attributes['identity'] {
		return actual.attributes['identity'] == expected_identity
	}
	return actual.type_name == expected.type_name && actual.repr == expected.repr
}

fn (object &AtomicSynchronizationObject) validate_field(name string) ! {
	mut class := object.class
	if name !in class.attributes(true) {
		return error('unknown atomic attribute `${name}`')
	}
}

pub fn (mut object AtomicSynchronizationObject) get(name string) !brew_runtime.Value {
	object.validate_field(name)!
	object.lock.rlock()
	value := object.fields[name]
	object.lock.runlock()
	return value
}

pub fn (mut object AtomicSynchronizationObject) set(name string, value brew_runtime.Value) !brew_runtime.Value {
	object.validate_field(name)!
	object.lock.lock()
	object.fields[name] = value
	object.lock.unlock()
	return value
}

pub fn (mut object AtomicSynchronizationObject) swap(name string, value brew_runtime.Value) !brew_runtime.Value {
	object.validate_field(name)!
	object.lock.lock()
	previous := object.fields[name]
	object.fields[name] = value
	object.lock.unlock()
	return previous
}

pub fn (mut object AtomicSynchronizationObject) compare_and_set(name string, expected brew_runtime.Value, value brew_runtime.Value) !bool {
	object.validate_field(name)!
	object.lock.lock()
	if atomic_object_values_match(object.fields[name], expected) {
		object.fields[name] = value
		object.lock.unlock()
		return true
	}
	object.lock.unlock()
	return false
}

pub fn (mut object AtomicSynchronizationObject) update(name string, action AtomicFieldUpdate) !brew_runtime.Value {
	for {
		old := object.get(name)!
		prospect := action(old)!
		if object.compare_and_set(name, old, prospect)! {
			return prospect
		}
	}
	return error('unreachable')
}

pub fn ensure_safe_final_fields(mut class AtomicClassState, final_fields []string) !bool {
	if final_fields.any(it.len > 0 && it[0].is_capital()) && !class.safe_initialization() {
		return error('there was an instance with final field but not marked with safe_initialization!')
	}
	return true
}

fn atomic_class_value(class &AtomicClassState, methods []string) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Concurrent::Synchronization::ObjectClass'
		repr: methods.str()
		string_array_data: methods.clone()
		attributes: {
			'atomic_class_address': u64(voidptr(class)).str()
		}
	}
}

fn atomic_methods_value(class &AtomicClassState, methods []string) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Array'
		repr: methods.str()
		string_array_data: methods.clone()
		attributes: {
			'atomic_class_address': u64(voidptr(class)).str()
		}
	}
}

fn atomic_class_from_value(value brew_runtime.Value) &AtomicClassState {
	address := (value.attribute('atomic_class_address') or {
		panic('${value.type_name} has no translated atomic class state')
	}).u64()
	return unsafe { &AtomicClassState(voidptr(address)) }
}

fn atomic_object_value(object &AtomicSynchronizationObject) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::Synchronization::Object', '#<Concurrent::Synchronization::Object>', {
		'atomic_object_address': u64(voidptr(object)).str()
	})
}

fn atomic_object_from_args(args []brew_runtime.Value) &AtomicSynchronizationObject {
	if args.len == 0 {
		panic('Synchronization::Object method requires a receiver')
	}
	address := (args[0].attribute('atomic_object_address') or {
		panic('${args[0].type_name} has no translated atomic object state')
	}).u64()
	return unsafe { &AtomicSynchronizationObject(voidptr(address)) }
}

fn atomic_class_from_args_or_new(args []brew_runtime.Value) &AtomicClassState {
	if args.len > 0 && 'atomic_class_address' in args[0].attributes {
		return atomic_class_from_value(args[0])
	}
	return new_atomic_class([])
}

// Ruby method `initialize` at line 28.
pub fn ruby_object_l28_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	mut class := atomic_class_from_args_or_new(args)
	return atomic_object_value(new_atomic_synchronization_object(mut class))
}

// Ruby method `self.safe_initialization!` at line 33.
pub fn ruby_object_l33_d2_self_safe_initialization(args ...brew_runtime.Value) brew_runtime.Value {
	mut class := atomic_class_from_args_or_new(args)
	class.mark_safe_initialization()
	return atomic_class_value(class, [])
}

// Ruby method `self.safe_initialization?` at line 37.
pub fn ruby_object_l37_d3_self_safe_initialization(args ...brew_runtime.Value) brew_runtime.Value {
	mut class := atomic_class_from_args_or_new(args)
	return brew_runtime.bool_value(class.safe_initialization())
}

// Ruby method `self.ensure_safe_initialization_when_final_fields_are_present` at line 45.
pub fn ruby_object_l45_d4_self_ensure_safe_initialization_when_final_fields_are_present(args ...brew_runtime.Value) brew_runtime.Value {
	mut class := atomic_class_from_args_or_new(args)
	final_fields := if args.len > 1 {
		args[1].as_string_array() or { panic(err) }
	} else {
		[]string{}
	}
	return brew_runtime.bool_value(ensure_safe_final_fields(mut class, final_fields) or { panic(err) })
}

// Ruby method `self.new(*args, &block)` at line 47.
pub fn ruby_object_l47_d5_self_new(args ...brew_runtime.Value) brew_runtime.Value {
	mut class := atomic_class_from_args_or_new(args)
	return atomic_object_value(new_atomic_synchronization_object(mut class))
}

// Ruby method `self.attr_atomic(*names)` at line 84.
pub fn ruby_object_l84_d6_self_attr_atomic(args ...brew_runtime.Value) brew_runtime.Value {
	mut class := atomic_class_from_args_or_new(args)
	offset := if args.len > 0 && 'atomic_class_address' in args[0].attributes { 1 } else { 0 }
	methods := class.add_atomic_fields(args[offset..].map(it.as_string()))
	return atomic_methods_value(class, methods)
}

// Ruby method `#{name}` at line 93.
pub fn ruby_object_l93_d7_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('atomic getter requires receiver and name')
	}
	mut object := atomic_object_from_args(args)
	return object.get(args[1].as_string()) or { panic(err) }
}

// Ruby method `#{name}=(value)` at line 97.
pub fn ruby_object_l97_d8_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('atomic setter requires receiver, name, and value')
	}
	mut object := atomic_object_from_args(args)
	return object.set(args[1].as_string(), args[2]) or { panic(err) }
}

// Ruby method `swap_#{name}(value)` at line 101.
pub fn ruby_object_l101_d9_swap_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('atomic swap requires receiver, name, and value')
	}
	mut object := atomic_object_from_args(args)
	return object.swap(args[1].as_string(), args[2]) or { panic(err) }
}

// Ruby method `compare_and_set_#{name}(expected, value)` at line 105.
pub fn ruby_object_l105_d10_compare_and_set_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('atomic compare_and_set requires receiver, name, expected, and value')
	}
	mut object := atomic_object_from_args(args)
	return brew_runtime.bool_value(object.compare_and_set(args[1].as_string(), args[2], args[3]) or {
		panic(err)
	})
}

// Ruby method `update_#{name}(&block)` at line 109.
pub fn ruby_object_l109_d11_update_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('atomic update requires receiver, name, and translated block result')
	}
	mut object := atomic_object_from_args(args)
	return object.set(args[1].as_string(), args[2]) or { panic(err) }
}

// Ruby method `self.atomic_attributes(inherited = true)` at line 119.
pub fn ruby_object_l119_d12_self_atomic_attributes(args ...brew_runtime.Value) brew_runtime.Value {
	mut class := atomic_class_from_args_or_new(args)
	inherited := if args.len > 1 { args[1].as_bool() or { true } } else { true }
	return brew_runtime.string_array_value(class.attributes(inherited))
}

// Ruby method `self.atomic_attribute?(name)` at line 125.
pub fn ruby_object_l125_d13_self_atomic_attribute(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	mut class := atomic_class_from_args_or_new(args)
	return brew_runtime.bool_value(args[1].as_string() in class.attributes(true))
}

// Ruby method `self.define_initialize_atomic_fields` at line 131.
pub fn ruby_object_l131_d14_self_define_initialize_atomic_fields(args ...brew_runtime.Value) brew_runtime.Value {
	mut class := atomic_class_from_args_or_new(args)
	assignments := class.attributes(false).map('@Atomic${it} = Concurrent::AtomicReference.new(nil)')
	return brew_runtime.string_value(assignments.join('\n'))
}

// Ruby method `__initialize_atomic_fields__` at line 137.
pub fn ruby_object_l137_d15_initialize_atomic_fields(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		mut class := new_atomic_class([])
		return atomic_object_value(new_atomic_synchronization_object(mut class))
	}
	return args[0]
}

// Ruby method `__initialize_atomic_fields__` at line 146.
pub fn ruby_object_l146_d16_initialize_atomic_fields(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return atomic_object_nil_value()
	}
	return args[0]
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/native_extension_loader' # load native parts first
// 2:
// 3: require 'concurrent/synchronization/safe_initialization'
// 4: require 'concurrent/synchronization/volatile'
// 5: require 'concurrent/atomic/atomic_reference'
// 6:
// 7: module Concurrent
// 8:   module Synchronization
// 9:
// 10:     # Abstract object providing final, volatile, ans CAS extensions to build other concurrent abstractions.
// 11:     # - final instance variables see {Object.safe_initialization!}
// 12:     # - volatile instance variables see {Object.attr_volatile}
// 13:     # - volatile instance variables see {Object.attr_atomic}
// 14:     # @!visibility private
// 15:     class Object < AbstractObject
// 16:       include Volatile
// 17:
// 18:       # TODO make it a module if possible
// 19:
// 20:       # @!method self.attr_volatile(*names)
// 21:       #   Creates methods for reading and writing (as `attr_accessor` does) to a instance variable with
// 22:       #   volatile (Java) semantic. The instance variable should be accessed only through generated methods.
// 23:       #
// 24:       #   @param [::Array<Symbol>] names of the instance variables to be volatile
// 25:       #   @return [::Array<Symbol>] names of defined method names
// 26:
// 27:       # Has to be called by children.
// 28:       def initialize
// 29:         super
// 30:         __initialize_atomic_fields__
// 31:       end
// 32:
// 33:       def self.safe_initialization!
// 34:         extend SafeInitialization unless safe_initialization?
// 35:       end
// 36:
// 37:       def self.safe_initialization?
// 38:         self.singleton_class < SafeInitialization
// 39:       end
// 40:
// 41:       # For testing purposes, quite slow. Injects assert code to new method which will raise if class instance contains
// 42:       # any instance variables with CamelCase names and isn't {.safe_initialization?}.
// 43:       # @raise when offend found
// 44:       # @return [true]
// 45:       def self.ensure_safe_initialization_when_final_fields_are_present
// 46:         Object.class_eval do
// 47:           def self.new(*args, &block)
// 48:             object = super(*args, &block)
// 49:           ensure
// 50:             has_final_field = object.instance_variables.any? { |v| v.to_s =~ /^@[A-Z]/ }
// 51:             if has_final_field && !safe_initialization?
// 52:               raise "there was an instance of #{object.class} with final field but not marked with safe_initialization!"
// 53:             end
// 54:           end
// 55:         end
// 56:         true
// 57:       end
// 58:
// 59:       # Creates methods for reading and writing to a instance variable with
// 60:       # volatile (Java) semantic as {.attr_volatile} does.
// 61:       # The instance variable should be accessed only through generated methods.
// 62:       # This method generates following methods: `value`, `value=(new_value) #=> new_value`,
// 63:       # `swap_value(new_value) #=> old_value`,
// 64:       # `compare_and_set_value(expected, value) #=> true || false`, `update_value(&block)`.
// 65:       # @param [::Array<Symbol>] names of the instance variables to be volatile with CAS.
// 66:       # @return [::Array<Symbol>] names of defined method names.
// 67:       # @!macro attr_atomic
// 68:       #   @!method $1
// 69:       #     @return [Object] The $1.
// 70:       #   @!method $1=(new_$1)
// 71:       #     Set the $1.
// 72:       #     @return [Object] new_$1.
// 73:       #   @!method swap_$1(new_$1)
// 74:       #     Set the $1 to new_$1 and return the old $1.
// 75:       #     @return [Object] old $1
// 76:       #   @!method compare_and_set_$1(expected_$1, new_$1)
// 77:       #     Sets the $1 to new_$1 if the current $1 is expected_$1
// 78:       #     @return [true, false]
// 79:       #   @!method update_$1(&block)
// 80:       #     Updates the $1 using the block.
// 81:       #     @yield [Object] Calculate a new $1 using given (old) $1
// 82:       #     @yieldparam [Object] old $1
// 83:       #     @return [Object] new $1
// 84:       def self.attr_atomic(*names)
// 85:         @__atomic_fields__ ||= []
// 86:         @__atomic_fields__ += names
// 87:         safe_initialization!
// 88:         define_initialize_atomic_fields
// 89:
// 90:         names.each do |name|
// 91:           ivar = :"@Atomic#{name.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }}"
// 92:           class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 93:             def #{name}
// 94:               #{ivar}.get
// 95:             end
// 96:
// 97:             def #{name}=(value)
// 98:               #{ivar}.set value
// 99:             end
// 100:
// 101:             def swap_#{name}(value)
// 102:               #{ivar}.swap value
// 103:             end
// 104:
// 105:             def compare_and_set_#{name}(expected, value)
// 106:               #{ivar}.compare_and_set expected, value
// 107:             end
// 108:
// 109:             def update_#{name}(&block)
// 110:               #{ivar}.update(&block)
// 111:             end
// 112:           RUBY
// 113:         end
// 114:         names.flat_map { |n| [n, :"#{n}=", :"swap_#{n}", :"compare_and_set_#{n}", :"update_#{n}"] }
// 115:       end
// 116:
// 117:       # @param [true, false] inherited should inherited volatile with CAS fields be returned?
// 118:       # @return [::Array<Symbol>] Returns defined volatile with CAS fields on this class.
// 119:       def self.atomic_attributes(inherited = true)
// 120:         @__atomic_fields__ ||= []
// 121:         ((superclass.atomic_attributes if superclass.respond_to?(:atomic_attributes) && inherited) || []) + @__atomic_fields__
// 122:       end
// 123:
// 124:       # @return [true, false] is the attribute with name atomic?
// 125:       def self.atomic_attribute?(name)
// 126:         atomic_attributes.include? name
// 127:       end
// 128:
// 129:       private
// 130:
// 131:       def self.define_initialize_atomic_fields
// 132:         assignments = @__atomic_fields__.map do |name|
// 133:           "@Atomic#{name.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }} = Concurrent::AtomicReference.new(nil)"
// 134:         end.join("\n")
// 135:
// 136:         class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 137:           def __initialize_atomic_fields__
// 138:             super
// 139:             #{assignments}
// 140:           end
// 141:         RUBY
// 142:       end
// 143:
// 144:       private_class_method :define_initialize_atomic_fields
// 145:
// 146:       def __initialize_atomic_fields__
// 147:       end
// 148:
// 149:     end
// 150:   end
// 151: end
