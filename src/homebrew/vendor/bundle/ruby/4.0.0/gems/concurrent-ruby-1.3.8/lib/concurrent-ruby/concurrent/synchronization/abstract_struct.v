module synchronization

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/abstract_struct.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(*values)` at line 9.
pub fn ruby_abstract_struct_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `length` at line 19.
pub fn ruby_abstract_struct_l19_d2_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('length', ...args)
}

// Ruby alias_method `alias_method :size, :length` at line 22.
pub fn ruby_abstract_struct_l22_d3_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('size', ...args)
}

// Ruby method `members` at line 29.
pub fn ruby_abstract_struct_l29_d4_members(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('members', ...args)
}

// Ruby method `ns_values` at line 38.
pub fn ruby_abstract_struct_l38_d5_ns_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_values', ...args)
}

// Ruby method `ns_values_at(indexes)` at line 45.
pub fn ruby_abstract_struct_l45_d6_ns_values_at(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_values_at', ...args)
}

// Ruby method `ns_to_h` at line 52.
pub fn ruby_abstract_struct_l52_d7_ns_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_to_h', ...args)
}

// Ruby method `ns_get(member)` at line 59.
pub fn ruby_abstract_struct_l59_d8_ns_get(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_get', ...args)
}

// Ruby method `ns_equality(other)` at line 75.
pub fn ruby_abstract_struct_l75_d9_ns_equality(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_equality', ...args)
}

// Ruby method `ns_each` at line 82.
pub fn ruby_abstract_struct_l82_d10_ns_each(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_each', ...args)
}

// Ruby method `ns_each_pair` at line 89.
pub fn ruby_abstract_struct_l89_d11_ns_each_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_each_pair', ...args)
}

// Ruby method `ns_select` at line 98.
pub fn ruby_abstract_struct_l98_d12_ns_select(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_select', ...args)
}

// Ruby method `ns_inspect` at line 105.
pub fn ruby_abstract_struct_l105_d13_ns_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_inspect', ...args)
}

// Ruby method `ns_merge(other, &block)` at line 114.
pub fn ruby_abstract_struct_l114_d14_ns_merge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_merge', ...args)
}

// Ruby method `ns_initialize_copy` at line 119.
pub fn ruby_abstract_struct_l119_d15_ns_initialize_copy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize_copy', ...args)
}

// Ruby method `pr_underscore(clazz)` at line 130.
pub fn ruby_abstract_struct_l130_d16_pr_underscore(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pr_underscore', ...args)
}

// Ruby method `self.define_struct_class(parent, base, name, members, &block)` at line 141.
pub fn ruby_abstract_struct_l141_d17_self_define_struct_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.define_struct_class', ...args)
}

// Ruby method `ns_initialize(*values)` at line 145.
pub fn ruby_abstract_struct_l145_d18_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
}

// Ruby define_method `clazz.send(:define_method, member) do` at line 161.
pub fn ruby_abstract_struct_l161_d19_member(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('member', ...args)
}

// Ruby alias_method `clazz.singleton_class.send :alias_method, :[], :new` at line 166.
pub fn ruby_abstract_struct_l166_d20_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]', ...args)
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
