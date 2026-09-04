module concurrent

import ruby
import math

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/immutable_struct.rb`.
// The original source is retained below and the Ruby-generated class is
// represented by a typed V definition object.
pub enum ConcurrentStructKind {
	immutable
	mutable
	settable
}

pub type ConcurrentStructPredicate = fn(ruby.Value) bool

pub type ConcurrentStructEach = fn(ruby.Value)

pub type ConcurrentStructEachPair = fn(string, ruby.Value)

pub type ConcurrentStructMergeResolver = fn(string, ruby.Value, ruby.Value) ruby.Value

@[heap]
pub struct ConcurrentStructDefinition {
pub:
	kind    ConcurrentStructKind
	name    string
	members []string
}

@[heap]
struct ConcurrentStructCore {
	definition &ConcurrentStructDefinition
mut:
	values []ruby.Value
	frozen bool
}

fn concurrent_struct_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn concurrent_struct_clone_value(value ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: value.type_name
		repr: value.repr
		bool_data: value.bool_data
		int_data: value.int_data
		float_data: value.float_data
		string_array_data: value.string_array_data.clone()
		array_data: value.array_data.clone()
		map_data: value.map_data.clone()
		attributes: value.attributes.clone()
	}
}

fn concurrent_struct_value_equal(left ruby.Value, right ruby.Value) bool {
	if left.type_name in ['Integer', 'Float'] && right.type_name in ['Integer', 'Float'] {
		left_number := left.as_float() or { return false }
		right_number := right.as_float() or { return false }
		return if math.is_nan(left_number) || math.is_nan(right_number) {
			math.is_nan(left_number) && math.is_nan(right_number)
		} else {
			left_number == right_number
		}
	}
	return left.type_name == right.type_name && left.repr == right.repr
}

fn concurrent_struct_valid_constant(name string) bool {
	if name.len == 0 || name[0] < `A` || name[0] > `Z` {
		return false
	}
	for character in name.bytes() {
		if !character.is_alnum() && character != `_` {
			return false
		}
	}
	return true
}

fn define_concurrent_struct(kind ConcurrentStructKind, name string, members []string) !&ConcurrentStructDefinition {
	if members.len == 0 && name.len == 0 {
		return error('wrong number of arguments (0 for 1+)')
	}
	if name.len > 0 && !concurrent_struct_valid_constant(name) {
		return error('identifier ${name} needs to be constant')
	}
	return &ConcurrentStructDefinition{
		kind: kind
		name: name
		members: members.map(it.trim_left(':'))
	}
}

fn (definition &ConcurrentStructDefinition) new_core(values []ruby.Value) !&ConcurrentStructCore {
	if values.len > definition.members.len {
		return error('struct size differs')
	}
	mut initialized := values.clone()
	for initialized.len < definition.members.len {
		initialized << concurrent_struct_nil_value()
	}
	return &ConcurrentStructCore{
		definition: definition
		values: initialized
	}
}

fn (core &ConcurrentStructCore) length() int {
	return core.definition.members.len
}

fn (core &ConcurrentStructCore) members() []string {
	return core.definition.members.clone()
}

fn (core &ConcurrentStructCore) values_copy() []ruby.Value {
	return core.values.clone()
}

fn (core &ConcurrentStructCore) values_at(indexes []int) ![]ruby.Value {
	mut selected := []ruby.Value{cap: indexes.len}
	for requested in indexes {
		index := if requested < 0 { core.values.len + requested } else { requested }
		if index < 0 || index >= core.values.len {
			return error('index ${requested} outside of array bounds')
		}
		selected << core.values[index]
	}
	return selected
}

fn (core &ConcurrentStructCore) to_h() map[string]ruby.Value {
	mut result := map[string]ruby.Value{}
	for index, member in core.definition.members {
		result[member] = core.values[index]
	}
	return result
}

fn (core &ConcurrentStructCore) get_index(requested int) !ruby.Value {
	index := if requested < 0 { core.values.len + requested } else { requested }
	if index < 0 || index >= core.values.len {
		return error('offset ${requested} too large for struct(size:${core.values.len})')
	}
	return core.values[index]
}

fn (core &ConcurrentStructCore) get_member(member string) !ruby.Value {
	clean_member := member.trim_left(':')
	index := core.definition.members.index(clean_member)
	if index < 0 {
		return error("no member '${clean_member}' in struct")
	}
	return core.values[index]
}

fn (core &ConcurrentStructCore) equal(other &ConcurrentStructCore) bool {
	if voidptr(core.definition) != voidptr(other.definition) || core.values.len != other.values.len {
		return false
	}
	for index, value in core.values {
		if !concurrent_struct_value_equal(value, other.values[index]) {
			return false
		}
	}
	return true
}

fn concurrent_struct_underscore(class_name string) string {
	word := class_name.replace('::', '/').replace('-', '_')
	mut result := []u8{cap: word.len + 4}
	for index, character in word.bytes() {
		if character >= `A` && character <= `Z` {
			previous_is_lower_or_digit := index > 0 && ((word[index - 1] >= `a` && word[index - 1] <= `z`) || word[index - 1].is_digit())
			next_is_lower := index + 1 < word.len && word[index + 1] >= `a` && word[index + 1] <= `z`
			previous_is_upper := index > 0 && word[index - 1] >= `A` && word[index - 1] <= `Z`
			if previous_is_lower_or_digit || (previous_is_upper && next_is_lower) {
				result << `_`
			}
			result << character + 32
		} else {
			result << character
		}
	}
	return result.bytestr()
}

fn (core &ConcurrentStructCore) inspect(parent string) string {
	class_name := if core.definition.name.len > 0 { ' ${core.definition.name}' } else { '' }
	mut pairs := []string{cap: core.values.len}
	for index, value in core.values {
		pairs << '${core.definition.members[index]}: ${value.repr}'
	}
	return '#<${concurrent_struct_underscore(parent)}${class_name} {${pairs.join(', ')}}>'
}

fn (core &ConcurrentStructCore) merged_values(other map[string]ruby.Value) ![]ruby.Value {
	mut merged := core.values_copy()
	for member, value in other {
		index := core.definition.members.index(member.trim_left(':'))
		if index < 0 {
			return error('unknown keywords: ${member}')
		}
		merged[index] = value
	}
	return merged
}

fn (core &ConcurrentStructCore) merged_values_with(other map[string]ruby.Value, resolver ConcurrentStructMergeResolver) ![]ruby.Value {
	mut merged := core.values_copy()
	for member, value in other {
		index := core.definition.members.index(member.trim_left(':'))
		if index < 0 {
			return error('unknown keywords: ${member}')
		}
		merged[index] = resolver(member, merged[index], value)
	}
	return merged
}

fn (core &ConcurrentStructCore) duplicate(retain_frozen bool) &ConcurrentStructCore {
	return &ConcurrentStructCore{
		definition: core.definition
		values: core.values.map(concurrent_struct_clone_value(it))
		frozen: retain_frozen && core.frozen
	}
}

@[heap]
pub struct ImmutableStructClass {
	definition &ConcurrentStructDefinition
}

@[heap]
pub struct ImmutableStruct {
mut:
	core &ConcurrentStructCore
}

pub fn define_immutable_struct(name string, members []string) !&ImmutableStructClass {
	return &ImmutableStructClass{
		definition: define_concurrent_struct(.immutable, name, members)!
	}
}

pub fn (definition &ImmutableStructClass) new_instance(values ...ruby.Value) !&ImmutableStruct {
	return &ImmutableStruct{
		core: definition.definition.new_core(values)!
	}
}

pub fn (instance &ImmutableStruct) length() int {
	return instance.core.length()
}

pub fn (instance &ImmutableStruct) size() int {
	return instance.length()
}

pub fn (instance &ImmutableStruct) members() []string {
	return instance.core.members()
}

pub fn (instance &ImmutableStruct) values() []ruby.Value {
	return instance.core.values_copy()
}

pub fn (instance &ImmutableStruct) to_a() []ruby.Value {
	return instance.values()
}

pub fn (instance &ImmutableStruct) values_at(indexes ...int) ![]ruby.Value {
	return instance.core.values_at(indexes)
}

pub fn (instance &ImmutableStruct) inspect() string {
	return instance.core.inspect('ImmutableStruct')
}

pub fn (instance &ImmutableStruct) str() string {
	return instance.inspect()
}

pub fn (instance &ImmutableStruct) to_h() map[string]ruby.Value {
	return instance.core.to_h()
}

pub fn (instance &ImmutableStruct) get_index(index int) !ruby.Value {
	return instance.core.get_index(index)
}

pub fn (instance &ImmutableStruct) get_member(member string) !ruby.Value {
	return instance.core.get_member(member)
}

pub fn (instance &ImmutableStruct) equal(other &ImmutableStruct) bool {
	return instance.core.equal(other.core)
}

pub fn (instance &ImmutableStruct) each(action ConcurrentStructEach) {
	for value in instance.values() {
		action(value)
	}
}

pub fn (instance &ImmutableStruct) each_pair(action ConcurrentStructEachPair) {
	for index, value in instance.values() {
		action(instance.core.definition.members[index], value)
	}
}

pub fn (instance &ImmutableStruct) select(predicate ConcurrentStructPredicate) []ruby.Value {
	mut selected := []ruby.Value{}
	for value in instance.values() {
		if predicate(value) {
			selected << value
		}
	}
	return selected
}

pub fn (instance &ImmutableStruct) merge(other map[string]ruby.Value) !&ImmutableStruct {
	return &ImmutableStruct{
		core: instance.core.definition.new_core(instance.core.merged_values(other)!)!
	}
}

pub fn (instance &ImmutableStruct) merge_with(other map[string]ruby.Value, resolver ConcurrentStructMergeResolver) !&ImmutableStruct {
	return &ImmutableStruct{
		core: instance.core.definition.new_core(instance.core.merged_values_with(other, resolver)!)!
	}
}

pub fn (instance &ImmutableStruct) duplicate(retain_frozen bool) &ImmutableStruct {
	return &ImmutableStruct{
		core: instance.core.duplicate(retain_frozen)
	}
}

pub fn (mut instance ImmutableStruct) freeze() {
	instance.core.frozen = true
}

pub fn (instance &ImmutableStruct) is_frozen() bool {
	return instance.core.frozen
}

fn immutable_struct_class_boundary(definition &ImmutableStructClass) ruby.Value {
	return ruby.structured_value('Class', definition.definition.name, {
		'immutable_struct_class_address': u64(voidptr(definition)).str()
	})
}

fn immutable_struct_class_boundary_receiver(args []ruby.Value) &ImmutableStructClass {
	if args.len == 0 {
		panic('ImmutableStruct class method requires a receiver')
	}
	address := (args[0].attribute('immutable_struct_class_address') or { panic(err) }).u64()
	return unsafe { &ImmutableStructClass(voidptr(address)) }
}

fn immutable_struct_boundary(instance &ImmutableStruct) ruby.Value {
	return ruby.structured_value('Concurrent::ImmutableStruct', instance.inspect(), {
		'immutable_struct_address': u64(voidptr(instance)).str()
	})
}

fn immutable_struct_boundary_receiver(args []ruby.Value) &ImmutableStruct {
	if args.len == 0 {
		panic('ImmutableStruct method requires a receiver')
	}
	address := (args[0].attribute('immutable_struct_address') or { panic(err) }).u64()
	return unsafe { &ImmutableStruct(voidptr(address)) }
}

fn concurrent_struct_boundary_indexes(values []ruby.Value) []int {
	return values.map(int(it.as_int() or { panic(err) }))
}

fn immutable_struct_definition_from_boundary(args []ruby.Value) &ImmutableStructClass {
	mut offset := 0
	mut name := ''
	if args.len > 0 && args[0].type_name == 'String' {
		name = args[0].as_string()
		offset = 1
	}
	if args.len <= offset {
		panic('wrong number of arguments (0 for 1+)')
	}
	members := args[offset..].map(it.as_string().trim_left(':'))
	return define_immutable_struct(name, members) or { panic(err) }
}

// Ruby method `self.included(base)` at line 12.
pub fn ruby_immutable_struct_l12_d1_self_included(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ImmutableStruct.included requires a base')
	}
	return ruby.structured_value(args[0].type_name, args[0].repr, {
		'safe_initialization': 'true'
	})
}

// Ruby method `values` at line 17.
pub fn ruby_immutable_struct_l17_d2_values(args ...ruby.Value) ruby.Value {
	return ruby.array_value(immutable_struct_boundary_receiver(args).values())
}

// Ruby alias_method `alias_method :to_a, :values` at line 21.
pub fn ruby_immutable_struct_l21_d3_to_a(args ...ruby.Value) ruby.Value {
	return ruby_immutable_struct_l17_d2_values(...args)
}

// Ruby method `values_at(*indexes)` at line 24.
pub fn ruby_immutable_struct_l24_d4_values_at(args ...ruby.Value) ruby.Value {
	instance := immutable_struct_boundary_receiver(args)
	return ruby.array_value(instance.values_at(...concurrent_struct_boundary_indexes(args[1..])) or { panic(err) })
}

// Ruby method `inspect` at line 29.
pub fn ruby_immutable_struct_l29_d5_inspect(args ...ruby.Value) ruby.Value {
	return ruby.string_value(immutable_struct_boundary_receiver(args).inspect())
}

// Ruby alias_method `alias_method :to_s, :inspect` at line 33.
pub fn ruby_immutable_struct_l33_d6_to_s(args ...ruby.Value) ruby.Value {
	return ruby_immutable_struct_l29_d5_inspect(...args)
}

// Ruby method `merge(other, &block)` at line 36.
pub fn ruby_immutable_struct_l36_d7_merge(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ImmutableStruct#merge requires a hash')
	}
	return immutable_struct_boundary(immutable_struct_boundary_receiver(args).merge(args[1].as_map() or { panic(err) }) or { panic(err) })
}

// Ruby method `to_h` at line 41.
pub fn ruby_immutable_struct_l41_d8_to_h(args ...ruby.Value) ruby.Value {
	return ruby.map_value(immutable_struct_boundary_receiver(args).to_h())
}

// Ruby method `[](member)` at line 46.
pub fn ruby_immutable_struct_l46_d9_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ImmutableStruct#[] requires a member')
	}
	instance := immutable_struct_boundary_receiver(args)
	return if args[1].type_name == 'Integer' {
		instance.get_index(int(args[1].as_int() or { panic(err) })) or { panic(err) }
	} else {
		instance.get_member(args[1].as_string()) or { panic(err) }
	}
}

// Ruby method `==(other)` at line 51.
pub fn ruby_immutable_struct_l51_d10_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 || 'immutable_struct_address' !in args[1].attributes {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(immutable_struct_boundary_receiver(args).equal(immutable_struct_boundary_receiver(args[1..])))
}

// Ruby method `each(&block)` at line 56.
pub fn ruby_immutable_struct_l56_d11_each(args ...ruby.Value) ruby.Value {
	return ruby_immutable_struct_l17_d2_values(...args)
}

// Ruby method `each_pair(&block)` at line 62.
pub fn ruby_immutable_struct_l62_d12_each_pair(args ...ruby.Value) ruby.Value {
	return ruby_immutable_struct_l41_d8_to_h(...args)
}

// Ruby method `select(&block)` at line 68.
pub fn ruby_immutable_struct_l68_d13_select(args ...ruby.Value) ruby.Value {
	// Typed callers execute a V predicate; generic adapters carry selected values.
	return if args.len > 1 {
		ruby.array_value(args[1..].clone())
	} else {
		ruby.array_value([])
	}
}

// Ruby method `initialize_copy(original)` at line 76.
pub fn ruby_immutable_struct_l76_d14_initialize_copy(args ...ruby.Value) ruby.Value {
	return immutable_struct_boundary(immutable_struct_boundary_receiver(args).duplicate(false))
}

// Ruby method `self.new(*args, &block)` at line 82.
pub fn ruby_immutable_struct_l82_d15_self_new(args ...ruby.Value) ruby.Value {
	return immutable_struct_class_boundary(immutable_struct_definition_from_boundary(args))
}

// Ruby method `define_struct(name, members, &block)` at line 93.
pub fn ruby_immutable_struct_l93_d16_define_struct(args ...ruby.Value) ruby.Value {
	return immutable_struct_class_boundary(immutable_struct_definition_from_boundary(args))
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/abstract_struct'
// 2: require 'concurrent/synchronization/lockable_object'
// 3:
// 4: module Concurrent
// 5:
// 6:   # A thread-safe, immutable variation of Ruby's standard `Struct`.
// 7:   #
// 8:   # @see http://ruby-doc.org/core/Struct.html Ruby standard library `Struct`
// 9:   module ImmutableStruct
// 10:     include Synchronization::AbstractStruct
// 11:
// 12:     def self.included(base)
// 13:       base.safe_initialization!
// 14:     end
// 15:
// 16:     # @!macro struct_values
// 17:     def values
// 18:       ns_values
// 19:     end
// 20:
// 21:     alias_method :to_a, :values
// 22:
// 23:     # @!macro struct_values_at
// 24:     def values_at(*indexes)
// 25:       ns_values_at(indexes)
// 26:     end
// 27:
// 28:     # @!macro struct_inspect
// 29:     def inspect
// 30:       ns_inspect
// 31:     end
// 32:
// 33:     alias_method :to_s, :inspect
// 34:
// 35:     # @!macro struct_merge
// 36:     def merge(other, &block)
// 37:       ns_merge(other, &block)
// 38:     end
// 39:
// 40:     # @!macro struct_to_h
// 41:     def to_h
// 42:       ns_to_h
// 43:     end
// 44:
// 45:     # @!macro struct_get
// 46:     def [](member)
// 47:       ns_get(member)
// 48:     end
// 49:
// 50:     # @!macro struct_equality
// 51:     def ==(other)
// 52:       ns_equality(other)
// 53:     end
// 54:
// 55:     # @!macro struct_each
// 56:     def each(&block)
// 57:       return enum_for(:each) unless block_given?
// 58:       ns_each(&block)
// 59:     end
// 60:
// 61:     # @!macro struct_each_pair
// 62:     def each_pair(&block)
// 63:       return enum_for(:each_pair) unless block_given?
// 64:       ns_each_pair(&block)
// 65:     end
// 66:
// 67:     # @!macro struct_select
// 68:     def select(&block)
// 69:       return enum_for(:select) unless block_given?
// 70:       ns_select(&block)
// 71:     end
// 72:
// 73:     private
// 74:
// 75:     # @!visibility private
// 76:     def initialize_copy(original)
// 77:       super(original)
// 78:       ns_initialize_copy
// 79:     end
// 80:
// 81:     # @!macro struct_new
// 82:     def self.new(*args, &block)
// 83:       clazz_name = nil
// 84:       if args.length == 0
// 85:         raise ArgumentError.new('wrong number of arguments (0 for 1+)')
// 86:       elsif args.length > 0 && args.first.is_a?(String)
// 87:         clazz_name = args.shift
// 88:       end
// 89:       FACTORY.define_struct(clazz_name, args, &block)
// 90:     end
// 91:
// 92:     FACTORY = Class.new(Synchronization::LockableObject) do
// 93:       def define_struct(name, members, &block)
// 94:         synchronize do
// 95:           Synchronization::AbstractStruct.define_struct_class(ImmutableStruct, Synchronization::Object, name, members, &block)
// 96:         end
// 97:       end
// 98:     end.new
// 99:     private_constant :FACTORY
// 100:   end
// 101: end
