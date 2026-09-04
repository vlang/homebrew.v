module synchronization

import ruby
import math

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/abstract_struct.rb`.
// The original source is retained below and the dynamic Ruby class operations are
// exposed through explicit V definition and instance types.
pub type AbstractStructPredicate = fn(ruby.Value) bool

pub type AbstractStructEach = fn(ruby.Value)

pub type AbstractStructEachPair = fn(string, ruby.Value)

pub type AbstractStructMergeResolver = fn(string, ruby.Value, ruby.Value) ruby.Value

@[heap]
pub struct AbstractStructClass {
pub:
	parent  string
	base    string
	name    string
	members []string
}

@[heap]
pub struct AbstractStruct {
pub:
	definition &AbstractStructClass
mut:
	values []ruby.Value
	frozen bool
}

fn abstract_struct_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn abstract_struct_clone_value(value ruby.Value) ruby.Value {
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

fn abstract_struct_values_equal(left ruby.Value, right ruby.Value) bool {
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

fn abstract_struct_valid_constant(name string) bool {
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

pub fn define_abstract_struct_class(parent string, base string, name string, members []string) !&AbstractStructClass {
	if name.len > 0 && !abstract_struct_valid_constant(name) {
		return error('identifier ${name} needs to be constant')
	}
	return &AbstractStructClass{
		parent: parent
		base: base
		name: name
		members: members.map(it.trim_left(':'))
	}
}

pub fn (definition &AbstractStructClass) new_instance(values ...ruby.Value) !&AbstractStruct {
	if values.len > definition.members.len {
		return error('struct size differs')
	}
	mut initialized := values.clone()
	for initialized.len < definition.members.len {
		initialized << abstract_struct_nil_value()
	}
	return &AbstractStruct{
		definition: definition
		values: initialized
	}
}

pub fn (instance &AbstractStruct) length() int {
	return instance.definition.members.len
}

pub fn (instance &AbstractStruct) size() int {
	return instance.length()
}

pub fn (instance &AbstractStruct) members() []string {
	return instance.definition.members.clone()
}

pub fn (instance &AbstractStruct) values() []ruby.Value {
	return instance.values.clone()
}

pub fn (instance &AbstractStruct) values_at(indexes []int) ![]ruby.Value {
	mut selected := []ruby.Value{cap: indexes.len}
	for requested in indexes {
		index := if requested < 0 { instance.values.len + requested } else { requested }
		if index < 0 || index >= instance.values.len {
			return error('index ${requested} outside of array bounds')
		}
		selected << instance.values[index]
	}
	return selected
}

pub fn (instance &AbstractStruct) to_h() map[string]ruby.Value {
	mut result := map[string]ruby.Value{}
	for index, member in instance.definition.members {
		result[member] = instance.values[index]
	}
	return result
}

pub fn (instance &AbstractStruct) get_index(requested int) !ruby.Value {
	index := if requested < 0 { instance.values.len + requested } else { requested }
	if index < 0 || index >= instance.values.len {
		return error('offset ${requested} too large for struct(size:${instance.values.len})')
	}
	return instance.values[index]
}

pub fn (instance &AbstractStruct) get_member(member string) !ruby.Value {
	index := instance.definition.members.index(member.trim_left(':'))
	if index < 0 {
		return error("no member '${member.trim_left(':')}' in struct")
	}
	return instance.values[index]
}

pub fn (instance &AbstractStruct) equal(other &AbstractStruct) bool {
	if voidptr(instance.definition) != voidptr(other.definition) || instance.values.len != other.values.len {
		return false
	}
	for index, value in instance.values {
		if !abstract_struct_values_equal(value, other.values[index]) {
			return false
		}
	}
	return true
}

pub fn (instance &AbstractStruct) each(action AbstractStructEach) {
	for value in instance.values() {
		action(value)
	}
}

pub fn (instance &AbstractStruct) each_pair(action AbstractStructEachPair) {
	for index, value in instance.values {
		action(instance.definition.members[index], value)
	}
}

pub fn (instance &AbstractStruct) select(predicate AbstractStructPredicate) []ruby.Value {
	mut result := []ruby.Value{}
	for value in instance.values() {
		if predicate(value) {
			result << value
		}
	}
	return result
}

pub fn underscore_struct_class(class_name string) string {
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

pub fn (instance &AbstractStruct) inspect() string {
	struct_name := underscore_struct_class(instance.definition.parent)
	class_name := if instance.definition.name.len > 0 { ' ${instance.definition.name}' } else { '' }
	mut pairs := []string{cap: instance.values.len}
	for index, value in instance.values {
		pairs << '${instance.definition.members[index]}: ${value.repr}'
	}
	return '#<${struct_name}${class_name} {${pairs.join(', ')}}>'
}

pub fn (instance &AbstractStruct) merge(other map[string]ruby.Value) !&AbstractStruct {
	mut merged := instance.values()
	for member, value in other {
		index := instance.definition.members.index(member.trim_left(':'))
		if index < 0 {
			return error('unknown keywords: ${member}')
		}
		merged[index] = value
	}
	return instance.definition.new_instance(...merged)
}

pub fn (instance &AbstractStruct) merge_with(other map[string]ruby.Value, resolver AbstractStructMergeResolver) !&AbstractStruct {
	mut merged := instance.values()
	for member, value in other {
		index := instance.definition.members.index(member.trim_left(':'))
		if index < 0 {
			return error('unknown keywords: ${member}')
		}
		merged[index] = resolver(member, merged[index], value)
	}
	return instance.definition.new_instance(...merged)
}

pub fn (instance &AbstractStruct) duplicate(retain_frozen bool) &AbstractStruct {
	return &AbstractStruct{
		definition: instance.definition
		values: instance.values.map(abstract_struct_clone_value(it))
		frozen: retain_frozen && instance.frozen
	}
}

pub fn (mut instance AbstractStruct) freeze() {
	instance.frozen = true
}

pub fn (instance &AbstractStruct) is_frozen() bool {
	return instance.frozen
}

fn abstract_struct_class_boundary(definition &AbstractStructClass) ruby.Value {
	return ruby.structured_value('Class', definition.name, {
		'abstract_struct_class_address': u64(voidptr(definition)).str()
	})
}

fn abstract_struct_class_boundary_receiver(args []ruby.Value) &AbstractStructClass {
	if args.len == 0 {
		panic('AbstractStruct class method requires a receiver')
	}
	address := (args[0].attribute('abstract_struct_class_address') or { panic(err) }).u64()
	return unsafe { &AbstractStructClass(voidptr(address)) }
}

fn abstract_struct_boundary(instance &AbstractStruct) ruby.Value {
	return ruby.structured_value('Concurrent::Synchronization::AbstractStruct', instance.inspect(), {
		'abstract_struct_address': u64(voidptr(instance)).str()
	})
}

fn abstract_struct_boundary_receiver(args []ruby.Value) &AbstractStruct {
	if args.len == 0 {
		panic('AbstractStruct method requires a receiver')
	}
	address := (args[0].attribute('abstract_struct_address') or { panic(err) }).u64()
	return unsafe { &AbstractStruct(voidptr(address)) }
}

fn abstract_struct_boundary_indexes(values []ruby.Value) []int {
	return values.map(int(it.as_int() or { panic(err) }))
}

// Ruby method `initialize(*values)` at line 9.
pub fn ruby_abstract_struct_l9_d1_initialize(args ...ruby.Value) ruby.Value {
	definition := abstract_struct_class_boundary_receiver(args)
	return abstract_struct_boundary(definition.new_instance(...args[1..]) or { panic(err) })
}

// Ruby method `length` at line 19.
pub fn ruby_abstract_struct_l19_d2_length(args ...ruby.Value) ruby.Value {
	return ruby.int_value(abstract_struct_boundary_receiver(args).length())
}

// Ruby alias_method `alias_method :size, :length` at line 22.
pub fn ruby_abstract_struct_l22_d3_size(args ...ruby.Value) ruby.Value {
	return ruby_abstract_struct_l19_d2_length(...args)
}

// Ruby method `members` at line 29.
pub fn ruby_abstract_struct_l29_d4_members(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(abstract_struct_boundary_receiver(args).members())
}

// Ruby method `ns_values` at line 38.
pub fn ruby_abstract_struct_l38_d5_ns_values(args ...ruby.Value) ruby.Value {
	return ruby.array_value(abstract_struct_boundary_receiver(args).values())
}

// Ruby method `ns_values_at(indexes)` at line 45.
pub fn ruby_abstract_struct_l45_d6_ns_values_at(args ...ruby.Value) ruby.Value {
	instance := abstract_struct_boundary_receiver(args)
	return ruby.array_value(instance.values_at(abstract_struct_boundary_indexes(args[1..])) or { panic(err) })
}

// Ruby method `ns_to_h` at line 52.
pub fn ruby_abstract_struct_l52_d7_ns_to_h(args ...ruby.Value) ruby.Value {
	return ruby.map_value(abstract_struct_boundary_receiver(args).to_h())
}

// Ruby method `ns_get(member)` at line 59.
pub fn ruby_abstract_struct_l59_d8_ns_get(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('AbstractStruct#ns_get requires a member')
	}
	instance := abstract_struct_boundary_receiver(args)
	return if args[1].type_name == 'Integer' {
		instance.get_index(int(args[1].as_int() or { panic(err) })) or { panic(err) }
	} else {
		instance.get_member(args[1].as_string()) or { panic(err) }
	}
}

// Ruby method `ns_equality(other)` at line 75.
pub fn ruby_abstract_struct_l75_d9_ns_equality(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	left := abstract_struct_boundary_receiver(args)
	right := abstract_struct_boundary_receiver(args[1..])
	return ruby.bool_value(left.equal(right))
}

// Ruby method `ns_each` at line 82.
pub fn ruby_abstract_struct_l82_d10_ns_each(args ...ruby.Value) ruby.Value {
	return ruby.array_value(abstract_struct_boundary_receiver(args).values())
}

// Ruby method `ns_each_pair` at line 89.
pub fn ruby_abstract_struct_l89_d11_ns_each_pair(args ...ruby.Value) ruby.Value {
	return ruby.map_value(abstract_struct_boundary_receiver(args).to_h())
}

// Ruby method `ns_select` at line 98.
pub fn ruby_abstract_struct_l98_d12_ns_select(args ...ruby.Value) ruby.Value {
	// Generic boundaries cannot carry a Ruby block; a translated selected-value
	// array is accepted after the receiver, while typed callers use `select`.
	return if args.len > 1 {
		ruby.array_value(args[1..].clone())
	} else {
		ruby.array_value([])
	}
}

// Ruby method `ns_inspect` at line 105.
pub fn ruby_abstract_struct_l105_d13_ns_inspect(args ...ruby.Value) ruby.Value {
	return ruby.string_value(abstract_struct_boundary_receiver(args).inspect())
}

// Ruby method `ns_merge(other, &block)` at line 114.
pub fn ruby_abstract_struct_l114_d14_ns_merge(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('AbstractStruct#ns_merge requires a hash')
	}
	instance := abstract_struct_boundary_receiver(args)
	return abstract_struct_boundary(instance.merge(args[1].as_map() or { panic(err) }) or { panic(err) })
}

// Ruby method `ns_initialize_copy` at line 119.
pub fn ruby_abstract_struct_l119_d15_ns_initialize_copy(args ...ruby.Value) ruby.Value {
	return abstract_struct_boundary(abstract_struct_boundary_receiver(args).duplicate(false))
}

// Ruby method `pr_underscore(clazz)` at line 130.
pub fn ruby_abstract_struct_l130_d16_pr_underscore(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('pr_underscore requires a class')
	}
	return ruby.string_value(underscore_struct_class(args[args.len - 1].as_string()))
}

// Ruby method `self.define_struct_class(parent, base, name, members, &block)` at line 141.
pub fn ruby_abstract_struct_l141_d17_self_define_struct_class(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('define_struct_class requires parent, base, name and members')
	}
	members := args[3].as_array() or { panic(err) }
	definition := define_abstract_struct_class(args[0].as_string(), args[1].as_string(), if args[2].type_name == 'NilClass' {
		''
	} else {
		args[2].as_string()
	}, members.map(it.as_string())) or { panic(err) }
	return abstract_struct_class_boundary(definition)
}

// Ruby method `ns_initialize(*values)` at line 145.
pub fn ruby_abstract_struct_l145_d18_ns_initialize(args ...ruby.Value) ruby.Value {
	return ruby_abstract_struct_l9_d1_initialize(...args)
}

// Ruby define_method `clazz.send(:define_method, member) do` at line 161.
pub fn ruby_abstract_struct_l161_d19_member(args ...ruby.Value) ruby.Value {
	return ruby_abstract_struct_l59_d8_ns_get(...args)
}

// Ruby alias_method `clazz.singleton_class.send :alias_method, :[], :new` at line 166.
pub fn ruby_abstract_struct_l166_d20_anonymous(args ...ruby.Value) ruby.Value {
	return ruby_abstract_struct_l9_d1_initialize(...args)
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:   module Synchronization
// 3:
// 4:     # @!visibility private
// 5:     # @!macro internal_implementation_note
// 6:     module AbstractStruct
// 7:
// 8:       # @!visibility private
// 9:       def initialize(*values)
// 10:         super()
// 11:         ns_initialize(*values)
// 12:       end
// 13:
// 14:       # @!macro struct_length
// 15:       #
// 16:       #   Returns the number of struct members.
// 17:       #
// 18:       #   @return [Fixnum] the number of struct members
// 19:       def length
// 20:         self.class::MEMBERS.length
// 21:       end
// 22:       alias_method :size, :length
// 23:
// 24:       # @!macro struct_members
// 25:       #
// 26:       #   Returns the struct members as an array of symbols.
// 27:       #
// 28:       #   @return [Array] the struct members as an array of symbols
// 29:       def members
// 30:         self.class::MEMBERS.dup
// 31:       end
// 32:
// 33:       protected
// 34:
// 35:       # @!macro struct_values
// 36:       #
// 37:       # @!visibility private
// 38:       def ns_values
// 39:         @values.dup
// 40:       end
// 41:
// 42:       # @!macro struct_values_at
// 43:       #
// 44:       # @!visibility private
// 45:       def ns_values_at(indexes)
// 46:         @values.values_at(*indexes)
// 47:       end
// 48:
// 49:       # @!macro struct_to_h
// 50:       #
// 51:       # @!visibility private
// 52:       def ns_to_h
// 53:         length.times.reduce({}){|memo, i| memo[self.class::MEMBERS[i]] = @values[i]; memo}
// 54:       end
// 55:
// 56:       # @!macro struct_get
// 57:       #
// 58:       # @!visibility private
// 59:       def ns_get(member)
// 60:         if member.is_a? Integer
// 61:           if member >= @values.length
// 62:             raise IndexError.new("offset #{member} too large for struct(size:#{@values.length})")
// 63:           end
// 64:           @values[member]
// 65:         else
// 66:           send(member)
// 67:         end
// 68:       rescue NoMethodError
// 69:         raise NameError.new("no member '#{member}' in struct")
// 70:       end
// 71:
// 72:       # @!macro struct_equality
// 73:       #
// 74:       # @!visibility private
// 75:       def ns_equality(other)
// 76:         self.class == other.class && self.values == other.values
// 77:       end
// 78:
// 79:       # @!macro struct_each
// 80:       #
// 81:       # @!visibility private
// 82:       def ns_each
// 83:         values.each{|value| yield value }
// 84:       end
// 85:
// 86:       # @!macro struct_each_pair
// 87:       #
// 88:       # @!visibility private
// 89:       def ns_each_pair
// 90:         @values.length.times do |index|
// 91:           yield self.class::MEMBERS[index], @values[index]
// 92:         end
// 93:       end
// 94:
// 95:       # @!macro struct_select
// 96:       #
// 97:       # @!visibility private
// 98:       def ns_select
// 99:         values.select{|value| yield value }
// 100:       end
// 101:
// 102:       # @!macro struct_inspect
// 103:       #
// 104:       # @!visibility private
// 105:       def ns_inspect
// 106:         struct = pr_underscore(self.class.ancestors[1])
// 107:         clazz = ((self.class.to_s =~ /^#<Class:/) == 0) ? '' : " #{self.class}"
// 108:         "#<#{struct}#{clazz} #{ns_to_h}>"
// 109:       end
// 110:
// 111:       # @!macro struct_merge
// 112:       #
// 113:       # @!visibility private
// 114:       def ns_merge(other, &block)
// 115:         self.class.new(*self.to_h.merge(other, &block).values)
// 116:       end
// 117:
// 118:       # @!visibility private
// 119:       def ns_initialize_copy
// 120:         @values = @values.map do |val|
// 121:           begin
// 122:             val.clone
// 123:           rescue TypeError
// 124:             val
// 125:           end
// 126:         end
// 127:       end
// 128:
// 129:       # @!visibility private
// 130:       def pr_underscore(clazz)
// 131:         word = clazz.to_s.dup # dup string to workaround JRuby 9.2.0.0 bug https://github.com/jruby/jruby/issues/5229
// 132:         word.gsub!(/::/, '/')
// 133:         word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
// 134:         word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
// 135:         word.tr!("-", "_")
// 136:         word.downcase!
// 137:         word
// 138:       end
// 139:
// 140:       # @!visibility private
// 141:       def self.define_struct_class(parent, base, name, members, &block)
// 142:         clazz = Class.new(base || Object) do
// 143:           include parent
// 144:           self.const_set(:MEMBERS, members.collect{|member| member.to_s.to_sym}.freeze)
// 145:           def ns_initialize(*values)
// 146:             raise ArgumentError.new('struct size differs') if values.length > length
// 147:             @values = values.fill(nil, values.length..length-1)
// 148:           end
// 149:         end
// 150:         unless name.nil?
// 151:           begin
// 152:             parent.send :remove_const, name if parent.const_defined?(name, false)
// 153:             parent.const_set(name, clazz)
// 154:             clazz
// 155:           rescue NameError
// 156:             raise NameError.new("identifier #{name} needs to be constant")
// 157:           end
// 158:         end
// 159:         members.each_with_index do |member, index|
// 160:           clazz.send :remove_method, member if clazz.instance_methods(false).include? member
// 161:           clazz.send(:define_method, member) do
// 162:             @values[index]
// 163:           end
// 164:         end
// 165:         clazz.class_exec(&block) unless block.nil?
// 166:         clazz.singleton_class.send :alias_method, :[], :new
// 167:         clazz
// 168:       end
// 169:     end
// 170:   end
// 171: end
