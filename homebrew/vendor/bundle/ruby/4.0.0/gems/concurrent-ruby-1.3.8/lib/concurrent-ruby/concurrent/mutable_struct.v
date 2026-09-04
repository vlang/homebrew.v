module concurrent

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/mutable_struct.rb`.
// The original source is retained below and the Ruby-generated class is
// represented by a typed V definition object.
@[heap]
pub struct MutableStructClass {
	definition &ConcurrentStructDefinition
}

@[heap]
pub struct MutableStruct {
mut:
	core &ConcurrentStructCore
	lock sync.RwMutex
}

pub fn define_mutable_struct(name string, members []string) !&MutableStructClass {
	return &MutableStructClass{
		definition: define_concurrent_struct(.mutable, name, members)!
	}
}

pub fn (definition &MutableStructClass) new_instance(values ...ruby.Value) !&MutableStruct {
	return &MutableStruct{
		core: definition.definition.new_core(values)!
	}
}

pub fn (instance &MutableStruct) length() int {
	return instance.core.length()
}

pub fn (instance &MutableStruct) size() int {
	return instance.length()
}

pub fn (instance &MutableStruct) members() []string {
	return instance.core.members()
}

pub fn (mut instance MutableStruct) values() []ruby.Value {
	instance.lock.rlock()
	defer {
		instance.lock.runlock()
	}
	return instance.core.values_copy()
}

pub fn (mut instance MutableStruct) to_a() []ruby.Value {
	return instance.values()
}

pub fn (mut instance MutableStruct) values_at(indexes ...int) ![]ruby.Value {
	instance.lock.rlock()
	defer {
		instance.lock.runlock()
	}
	return instance.core.values_at(indexes)
}

pub fn (mut instance MutableStruct) inspect() string {
	instance.lock.rlock()
	defer {
		instance.lock.runlock()
	}
	return instance.core.inspect('MutableStruct')
}

pub fn (mut instance MutableStruct) str() string {
	return instance.inspect()
}

pub fn (mut instance MutableStruct) to_h() map[string]ruby.Value {
	instance.lock.rlock()
	defer {
		instance.lock.runlock()
	}
	return instance.core.to_h()
}

pub fn (mut instance MutableStruct) get_index(index int) !ruby.Value {
	instance.lock.rlock()
	defer {
		instance.lock.runlock()
	}
	return instance.core.get_index(index)
}

pub fn (mut instance MutableStruct) get_member(member string) !ruby.Value {
	instance.lock.rlock()
	defer {
		instance.lock.runlock()
	}
	return instance.core.get_member(member)
}

pub fn (mut instance MutableStruct) set_index(index int, value ruby.Value) !ruby.Value {
	instance.lock.lock()
	defer {
		instance.lock.unlock()
	}
	if instance.core.frozen {
		return error("can't modify frozen MutableStruct")
	}
	normalized := if index < 0 { instance.core.values.len + index } else { index }
	if normalized < 0 || normalized >= instance.core.values.len {
		return error('offset ${index} too large for struct(size:${instance.core.values.len})')
	}
	instance.core.values[normalized] = value
	return value
}

pub fn (mut instance MutableStruct) set_member(member string, value ruby.Value) !ruby.Value {
	instance.lock.lock()
	defer {
		instance.lock.unlock()
	}
	if instance.core.frozen {
		return error("can't modify frozen MutableStruct")
	}
	clean_member := member.trim_left(':')
	index := instance.core.definition.members.index(clean_member)
	if index < 0 {
		return error("no member '${clean_member}' in struct")
	}
	instance.core.values[index] = value
	return value
}

pub fn (mut instance MutableStruct) equal(mut other MutableStruct) bool {
	left_values := instance.values()
	right_values := other.values()
	if voidptr(instance.core.definition) != voidptr(other.core.definition) || left_values.len != right_values.len {
		return false
	}
	for index, value in left_values {
		if !concurrent_struct_value_equal(value, right_values[index]) {
			return false
		}
	}
	return true
}

pub fn (mut instance MutableStruct) each(action ConcurrentStructEach) {
	for value in instance.values() {
		action(value)
	}
}

pub fn (mut instance MutableStruct) each_pair(action ConcurrentStructEachPair) {
	for index, value in instance.values() {
		action(instance.core.definition.members[index], value)
	}
}

pub fn (mut instance MutableStruct) select(predicate ConcurrentStructPredicate) []ruby.Value {
	mut selected := []ruby.Value{}
	for value in instance.values() {
		if predicate(value) {
			selected << value
		}
	}
	return selected
}

pub fn (mut instance MutableStruct) merge(other map[string]ruby.Value) !&MutableStruct {
	instance.lock.rlock()
	defer {
		instance.lock.runlock()
	}
	return &MutableStruct{
		core: instance.core.definition.new_core(instance.core.merged_values(other)!)!
	}
}

pub fn (mut instance MutableStruct) merge_with(other map[string]ruby.Value, resolver ConcurrentStructMergeResolver) !&MutableStruct {
	instance.lock.rlock()
	defer {
		instance.lock.runlock()
	}
	return &MutableStruct{
		core: instance.core.definition.new_core(instance.core.merged_values_with(other, resolver)!)!
	}
}

pub fn (mut instance MutableStruct) duplicate(retain_frozen bool) &MutableStruct {
	instance.lock.rlock()
	defer {
		instance.lock.runlock()
	}
	return &MutableStruct{
		core: instance.core.duplicate(retain_frozen)
	}
}

pub fn (mut instance MutableStruct) freeze() {
	instance.lock.lock()
	instance.core.frozen = true
	instance.lock.unlock()
}

pub fn (mut instance MutableStruct) is_frozen() bool {
	instance.lock.rlock()
	defer {
		instance.lock.runlock()
	}
	return instance.core.frozen
}

fn mutable_struct_class_boundary(definition &MutableStructClass) ruby.Value {
	return ruby.structured_value('Class', definition.definition.name, {
		'mutable_struct_class_address': u64(voidptr(definition)).str()
	})
}

fn mutable_struct_boundary(mut instance MutableStruct) ruby.Value {
	return ruby.structured_value('Concurrent::MutableStruct', instance.inspect(), {
		'mutable_struct_address': u64(voidptr(instance)).str()
	})
}

fn mutable_struct_boundary_receiver(args []ruby.Value) &MutableStruct {
	if args.len == 0 {
		panic('MutableStruct method requires a receiver')
	}
	address := (args[0].attribute('mutable_struct_address') or { panic(err) }).u64()
	return unsafe { &MutableStruct(voidptr(address)) }
}

fn mutable_struct_definition_from_boundary(args []ruby.Value) &MutableStructClass {
	mut offset := 0
	mut name := ''
	if args.len > 0 && args[0].type_name == 'String' {
		name = args[0].as_string()
		offset = 1
	}
	if args.len <= offset {
		panic('wrong number of arguments (0 for 1+)')
	}
	return define_mutable_struct(name, args[offset..].map(it.as_string().trim_left(':'))) or { panic(err) }
}

// Ruby method `values` at line 51.
pub fn ruby_mutable_struct_l51_d1_values(args ...ruby.Value) ruby.Value {
	mut instance := mutable_struct_boundary_receiver(args)
	return ruby.array_value(instance.values())
}

// Ruby alias_method `alias_method :to_a, :values` at line 54.
pub fn ruby_mutable_struct_l54_d2_to_a(args ...ruby.Value) ruby.Value {
	return ruby_mutable_struct_l51_d1_values(...args)
}

// Ruby method `values_at(*indexes)` at line 63.
pub fn ruby_mutable_struct_l63_d3_values_at(args ...ruby.Value) ruby.Value {
	mut instance := mutable_struct_boundary_receiver(args)
	return ruby.array_value(instance.values_at(...concurrent_struct_boundary_indexes(args[1..])) or { panic(err) })
}

// Ruby method `inspect` at line 72.
pub fn ruby_mutable_struct_l72_d4_inspect(args ...ruby.Value) ruby.Value {
	mut instance := mutable_struct_boundary_receiver(args)
	return ruby.string_value(instance.inspect())
}

// Ruby alias_method `alias_method :to_s, :inspect` at line 75.
pub fn ruby_mutable_struct_l75_d5_to_s(args ...ruby.Value) ruby.Value {
	return ruby_mutable_struct_l72_d4_inspect(...args)
}

// Ruby method `merge(other, &block)` at line 94.
pub fn ruby_mutable_struct_l94_d6_merge(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MutableStruct#merge requires a hash')
	}
	mut instance := mutable_struct_boundary_receiver(args)
	mut merged := instance.merge(args[1].as_map() or { panic(err) }) or { panic(err) }
	return mutable_struct_boundary(mut merged)
}

// Ruby method `to_h` at line 103.
pub fn ruby_mutable_struct_l103_d7_to_h(args ...ruby.Value) ruby.Value {
	mut instance := mutable_struct_boundary_receiver(args)
	return ruby.map_value(instance.to_h())
}

// Ruby method `[](member)` at line 118.
pub fn ruby_mutable_struct_l118_d8_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MutableStruct#[] requires a member')
	}
	mut instance := mutable_struct_boundary_receiver(args)
	return if args[1].type_name == 'Integer' {
		instance.get_index(int(args[1].as_int() or { panic(err) })) or { panic(err) }
	} else {
		instance.get_member(args[1].as_string()) or { panic(err) }
	}
}

// Ruby method `==(other)` at line 128.
pub fn ruby_mutable_struct_l128_d9_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 || 'mutable_struct_address' !in args[1].attributes {
		return ruby.bool_value(false)
	}
	mut left := mutable_struct_boundary_receiver(args)
	mut right := mutable_struct_boundary_receiver(args[1..])
	return ruby.bool_value(left.equal(mut right))
}

// Ruby method `each(&block)` at line 139.
pub fn ruby_mutable_struct_l139_d10_each(args ...ruby.Value) ruby.Value {
	return ruby_mutable_struct_l51_d1_values(...args)
}

// Ruby method `each_pair(&block)` at line 152.
pub fn ruby_mutable_struct_l152_d11_each_pair(args ...ruby.Value) ruby.Value {
	return ruby_mutable_struct_l103_d7_to_h(...args)
}

// Ruby method `select(&block)` at line 167.
pub fn ruby_mutable_struct_l167_d12_select(args ...ruby.Value) ruby.Value {
	return if args.len > 1 {
		ruby.array_value(args[1..].clone())
	} else {
		ruby.array_value([])
	}
}

// Ruby method `[]=(member, value)` at line 185.
pub fn ruby_mutable_struct_l185_d13_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('MutableStruct#[]= requires a member and value')
	}
	mut instance := mutable_struct_boundary_receiver(args)
	return if args[1].type_name == 'Integer' {
		instance.set_index(int(args[1].as_int() or { panic(err) }), args[2]) or { panic(err) }
	} else {
		instance.set_member(args[1].as_string(), args[2]) or { panic(err) }
	}
}

// Ruby method `initialize_copy(original)` at line 202.
pub fn ruby_mutable_struct_l202_d14_initialize_copy(args ...ruby.Value) ruby.Value {
	mut instance := mutable_struct_boundary_receiver(args)
	mut duplicate := instance.duplicate(false)
	return mutable_struct_boundary(mut duplicate)
}

// Ruby method `self.new(*args, &block)` at line 210.
pub fn ruby_mutable_struct_l210_d15_self_new(args ...ruby.Value) ruby.Value {
	return mutable_struct_class_boundary(mutable_struct_definition_from_boundary(args))
}

// Ruby method `define_struct(name, members, &block)` at line 221.
pub fn ruby_mutable_struct_l221_d16_define_struct(args ...ruby.Value) ruby.Value {
	return mutable_struct_class_boundary(mutable_struct_definition_from_boundary(args))
}

// Ruby define_method `clazz.send(:define_method, member) do` at line 226.
pub fn ruby_mutable_struct_l226_d17_member(args ...ruby.Value) ruby.Value {
	return ruby_mutable_struct_l118_d8_anonymous(...args)
}

// Ruby define_method `clazz.send(:define_method, "#{member}=") do |value|` at line 229.
pub fn ruby_mutable_struct_l229_d18_member(args ...ruby.Value) ruby.Value {
	return ruby_mutable_struct_l185_d13_anonymous(...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/abstract_struct'
// 2: require 'concurrent/synchronization/lockable_object'
// 3:
// 4: module Concurrent
// 5:
// 6:   # An thread-safe variation of Ruby's standard `Struct`. Values can be set at
// 7:   # construction or safely changed at any time during the object's lifecycle.
// 8:   #
// 9:   # @see http://ruby-doc.org/core/Struct.html Ruby standard library `Struct`
// 10:   module MutableStruct
// 11:     include Synchronization::AbstractStruct
// 12:
// 13:     # @!macro struct_new
// 14:     #
// 15:     #   Factory for creating new struct classes.
// 16:     #
// 17:     #   ```
// 18:     #   new([class_name] [, member_name]+>) -> StructClass click to toggle source
// 19:     #   new([class_name] [, member_name]+>) {|StructClass| block } -> StructClass
// 20:     #   new(value, ...) -> obj
// 21:     #   StructClass[value, ...] -> obj
// 22:     #   ```
// 23:     #
// 24:     #   The first two forms are used to create a new struct subclass `class_name`
// 25:     #   that can contain a value for each   member_name . This subclass can be
// 26:     #   used to create instances of the structure like any other  Class .
// 27:     #
// 28:     #   If the `class_name` is omitted an anonymous struct class will be created.
// 29:     #   Otherwise, the name of this struct will appear as a constant in the struct class,
// 30:     #   so it must be unique for all structs under this base class and must start with a
// 31:     #   capital letter. Assigning a struct class to a constant also gives the class
// 32:     #   the name of the constant.
// 33:     #
// 34:     #   If a block is given it will be evaluated in the context of `StructClass`, passing
// 35:     #   the created class as a parameter. This is the recommended way to customize a struct.
// 36:     #   Subclassing an anonymous struct creates an extra anonymous class that will never be used.
// 37:     #
// 38:     #   The last two forms create a new instance of a struct subclass. The number of value
// 39:     #   parameters must be less than or equal to the number of attributes defined for the
// 40:     #   struct. Unset parameters default to nil. Passing more parameters than number of attributes
// 41:     #   will raise an `ArgumentError`.
// 42:     #
// 43:     #   @see http://ruby-doc.org/core/Struct.html#method-c-new Ruby standard library `Struct#new`
// 44:
// 45:     # @!macro struct_values
// 46:     #
// 47:     #   Returns the values for this struct as an Array.
// 48:     #
// 49:     #   @return [Array] the values for this struct
// 50:     #
// 51:     def values
// 52:       synchronize { ns_values }
// 53:     end
// 54:     alias_method :to_a, :values
// 55:
// 56:     # @!macro struct_values_at
// 57:     #
// 58:     #   Returns the struct member values for each selector as an Array.
// 59:     #
// 60:     #   A selector may be either an Integer offset or a Range of offsets (as in `Array#values_at`).
// 61:     #
// 62:     #   @param [Fixnum, Range] indexes the index(es) from which to obatin the values (in order)
// 63:     def values_at(*indexes)
// 64:       synchronize { ns_values_at(indexes) }
// 65:     end
// 66:
// 67:     # @!macro struct_inspect
// 68:     #
// 69:     #   Describe the contents of this struct in a string.
// 70:     #
// 71:     #   @return [String] the contents of this struct in a string
// 72:     def inspect
// 73:       synchronize { ns_inspect }
// 74:     end
// 75:     alias_method :to_s, :inspect
// 76:
// 77:     # @!macro struct_merge
// 78:     #
// 79:     #   Returns a new struct containing the contents of `other` and the contents
// 80:     #   of `self`. If no block is specified, the value for entries with duplicate
// 81:     #   keys will be that of `other`. Otherwise the value for each duplicate key
// 82:     #   is determined by calling the block with the key, its value in `self` and
// 83:     #   its value in `other`.
// 84:     #
// 85:     #   @param [Hash] other the hash from which to set the new values
// 86:     #   @yield an options block for resolving duplicate keys
// 87:     #   @yieldparam [String, Symbol] member the name of the member which is duplicated
// 88:     #   @yieldparam [Object] selfvalue the value of the member in `self`
// 89:     #   @yieldparam [Object] othervalue the value of the member in `other`
// 90:     #
// 91:     #   @return [Synchronization::AbstractStruct] a new struct with the new values
// 92:     #
// 93:     #   @raise [ArgumentError] of given a member that is not defined in the struct
// 94:     def merge(other, &block)
// 95:       synchronize { ns_merge(other, &block) }
// 96:     end
// 97:
// 98:     # @!macro struct_to_h
// 99:     #
// 100:     #   Returns a hash containing the names and values for the struct’s members.
// 101:     #
// 102:     #   @return [Hash] the names and values for the struct’s members
// 103:     def to_h
// 104:       synchronize { ns_to_h }
// 105:     end
// 106:
// 107:     # @!macro struct_get
// 108:     #
// 109:     #   Attribute Reference
// 110:     #
// 111:     #   @param [Symbol, String, Integer] member the string or symbol name of the member
// 112:     #     for which to obtain the value or the member's index
// 113:     #
// 114:     #   @return [Object] the value of the given struct member or the member at the given index.
// 115:     #
// 116:     #   @raise [NameError] if the member does not exist
// 117:     #   @raise [IndexError] if the index is out of range.
// 118:     def [](member)
// 119:       synchronize { ns_get(member) }
// 120:     end
// 121:
// 122:     # @!macro struct_equality
// 123:     #
// 124:     #   Equality
// 125:     #
// 126:     #   @return [Boolean] true if other has the same struct subclass and has
// 127:     #     equal member values (according to `Object#==`)
// 128:     def ==(other)
// 129:       synchronize { ns_equality(other) }
// 130:     end
// 131:
// 132:     # @!macro struct_each
// 133:     #
// 134:     #   Yields the value of each struct member in order. If no block is given
// 135:     #   an enumerator is returned.
// 136:     #
// 137:     #   @yield the operation to be performed on each struct member
// 138:     #   @yieldparam [Object] value each struct value (in order)
// 139:     def each(&block)
// 140:       return enum_for(:each) unless block_given?
// 141:       synchronize { ns_each(&block) }
// 142:     end
// 143:
// 144:     # @!macro struct_each_pair
// 145:     #
// 146:     #   Yields the name and value of each struct member in order. If no block is
// 147:     #   given an enumerator is returned.
// 148:     #
// 149:     #   @yield the operation to be performed on each struct member/value pair
// 150:     #   @yieldparam [Object] member each struct member (in order)
// 151:     #   @yieldparam [Object] value each struct value (in order)
// 152:     def each_pair(&block)
// 153:       return enum_for(:each_pair) unless block_given?
// 154:       synchronize { ns_each_pair(&block) }
// 155:     end
// 156:
// 157:     # @!macro struct_select
// 158:     #
// 159:     #   Yields each member value from the struct to the block and returns an Array
// 160:     #   containing the member values from the struct for which the given block
// 161:     #   returns a true value (equivalent to `Enumerable#select`).
// 162:     #
// 163:     #   @yield the operation to be performed on each struct member
// 164:     #   @yieldparam [Object] value each struct value (in order)
// 165:     #
// 166:     #   @return [Array] an array containing each value for which the block returns true
// 167:     def select(&block)
// 168:       return enum_for(:select) unless block_given?
// 169:       synchronize { ns_select(&block) }
// 170:     end
// 171:
// 172:     # @!macro struct_set
// 173:     #
// 174:     #   Attribute Assignment
// 175:     #
// 176:     #   Sets the value of the given struct member or the member at the given index.
// 177:     #
// 178:     #   @param [Symbol, String, Integer] member the string or symbol name of the member
// 179:     #     for which to obtain the value or the member's index
// 180:     #
// 181:     #   @return [Object] the value of the given struct member or the member at the given index.
// 182:     #
// 183:     #   @raise [NameError] if the name does not exist
// 184:     #   @raise [IndexError] if the index is out of range.
// 185:     def []=(member, value)
// 186:       if member.is_a? Integer
// 187:         length = synchronize { @values.length }
// 188:         if member >= length
// 189:           raise IndexError.new("offset #{member} too large for struct(size:#{length})")
// 190:         end
// 191:         synchronize { @values[member] = value }
// 192:       else
// 193:         send("#{member}=", value)
// 194:       end
// 195:     rescue NoMethodError
// 196:       raise NameError.new("no member '#{member}' in struct")
// 197:     end
// 198:
// 199:     private
// 200:
// 201:     # @!visibility private
// 202:     def initialize_copy(original)
// 203:       synchronize do
// 204:         super(original)
// 205:         ns_initialize_copy
// 206:       end
// 207:     end
// 208:
// 209:     # @!macro struct_new
// 210:     def self.new(*args, &block)
// 211:       clazz_name = nil
// 212:       if args.length == 0
// 213:         raise ArgumentError.new('wrong number of arguments (0 for 1+)')
// 214:       elsif args.length > 0 && args.first.is_a?(String)
// 215:         clazz_name = args.shift
// 216:       end
// 217:       FACTORY.define_struct(clazz_name, args, &block)
// 218:     end
// 219:
// 220:     FACTORY = Class.new(Synchronization::LockableObject) do
// 221:       def define_struct(name, members, &block)
// 222:         synchronize do
// 223:           clazz = Synchronization::AbstractStruct.define_struct_class(MutableStruct, Synchronization::LockableObject, name, members, &block)
// 224:           members.each_with_index do |member, index|
// 225:             clazz.send :remove_method, member
// 226:             clazz.send(:define_method, member) do
// 227:               synchronize { @values[index] }
// 228:             end
// 229:             clazz.send(:define_method, "#{member}=") do |value|
// 230:               synchronize { @values[index] = value }
// 231:             end
// 232:           end
// 233:           clazz
// 234:         end
// 235:       end
// 236:     end.new
// 237:     private_constant :FACTORY
// 238:   end
// 239: end
