module options

import brew_runtime

// Translated from Homebrew/brew `options/options.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.create(array)` at line 12.
pub fn ruby_options_l12_d1_self_create(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create', ...args)
}

// Ruby method `initialize(options = nil)` at line 17.
pub fn ruby_options_l17_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize_dup(other)` at line 23.
pub fn ruby_options_l23_d3_initialize_dup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_dup', ...args)
}

// Ruby method `freeze` at line 29.
pub fn ruby_options_l29_d4_freeze(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('freeze', ...args)
}

// Ruby method `each(&block)` at line 35.
pub fn ruby_options_l35_d5_each(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each', ...args)
}

// Ruby method `<<(other)` at line 41.
pub fn ruby_options_l41_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<<', ...args)
}

// Ruby method `+(other)` at line 47.
pub fn ruby_options_l47_d7_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('+', ...args)
}

// Ruby method `-(other)` at line 52.
pub fn ruby_options_l52_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('-', ...args)
}

// Ruby method `&(other)` at line 57.
pub fn ruby_options_l57_d9_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('&', ...args)
}

// Ruby method `|(other)` at line 62.
pub fn ruby_options_l62_d10_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('|', ...args)
}

// Ruby method `*(other)` at line 67.
pub fn ruby_options_l67_d11_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('*', ...args)
}

// Ruby method `==(other)` at line 72.
pub fn ruby_options_l72_d12_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby alias `alias eql? ==` at line 80.
pub fn ruby_options_l80_d13_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby method `empty?` at line 83.
pub fn ruby_options_l83_d14_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('empty?', ...args)
}

// Ruby method `as_flags` at line 88.
pub fn ruby_options_l88_d15_as_flags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('as_flags', ...args)
}

// Ruby method `include?(option)` at line 93.
pub fn ruby_options_l93_d16_include(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('include?', ...args)
}

// Ruby alias `alias to_ary to_a` at line 97.
pub fn ruby_options_l97_d17_to_ary(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_ary', ...args)
}

// Ruby method `to_s` at line 100.
pub fn ruby_options_l100_d18_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `inspect` at line 105.
pub fn ruby_options_l105_d19_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby method `self.dump_for_formula(formula)` at line 110.
pub fn ruby_options_l110_d20_self_dump_for_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dump_for_formula', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A collection of formula options.
// 5: class Options
// 6:   include Enumerable
// 7:   extend T::Generic
// 8:
// 9:   Elem = type_member(:out) { { fixed: Option } }
// 10:
// 11:   sig { params(array: T.nilable(T::Array[String])).returns(Options) }
// 12:   def self.create(array)
// 13:     new Array(array).map { |e| Option.new(e[/^--([^=]+=?)(.+)?$/, 1] || e) }
// 14:   end
// 15:
// 16:   sig { params(options: T.nilable(T::Enumerable[Option])).void }
// 17:   def initialize(options = nil)
// 18:     # Ensure this is synced with `initialize_dup` and `freeze` (excluding simple objects like integers and booleans)
// 19:     @options = T.let(Set.new(options), T::Set[Option])
// 20:   end
// 21:
// 22:   sig { params(other: Options).void }
// 23:   def initialize_dup(other)
// 24:     super
// 25:     @options = @options.dup
// 26:   end
// 27:
// 28:   sig { returns(T.self_type) }
// 29:   def freeze
// 30:     @options.dup
// 31:     super
// 32:   end
// 33:
// 34:   sig { override.params(block: T.proc.params(arg0: Option).returns(BasicObject)).returns(T.self_type) }
// 35:   def each(&block)
// 36:     @options.each(&block)
// 37:     self
// 38:   end
// 39:
// 40:   sig { params(other: Option).returns(T.self_type) }
// 41:   def <<(other)
// 42:     @options << other
// 43:     self
// 44:   end
// 45:
// 46:   sig { params(other: T::Enumerable[Option]).returns(T.self_type) }
// 47:   def +(other)
// 48:     self.class.new(@options + other)
// 49:   end
// 50:
// 51:   sig { params(other: T::Enumerable[Option]).returns(T.self_type) }
// 52:   def -(other)
// 53:     self.class.new(@options - other)
// 54:   end
// 55:
// 56:   sig { params(other: T::Enumerable[Option]).returns(T.self_type) }
// 57:   def &(other)
// 58:     self.class.new(@options & other)
// 59:   end
// 60:
// 61:   sig { params(other: T::Enumerable[Option]).returns(T.self_type) }
// 62:   def |(other)
// 63:     self.class.new(@options | other)
// 64:   end
// 65:
// 66:   sig { params(other: String).returns(String) }
// 67:   def *(other)
// 68:     @options.to_a * other
// 69:   end
// 70:
// 71:   sig { params(other: T.anything).returns(T::Boolean) }
// 72:   def ==(other)
// 73:     case other
// 74:     when Options
// 75:       instance_of?(other.class) && to_a == other.to_a
// 76:     else
// 77:       false
// 78:     end
// 79:   end
// 80:   alias eql? ==
// 81:
// 82:   sig { returns(T::Boolean) }
// 83:   def empty?
// 84:     @options.empty?
// 85:   end
// 86:
// 87:   sig { returns(T::Array[String]) }
// 88:   def as_flags
// 89:     map(&:flag)
// 90:   end
// 91:
// 92:   sig { params(option: T.any(Option, String)).returns(T::Boolean) }
// 93:   def include?(option)
// 94:     any? { |opt| opt == option || opt.name == option || opt.flag == option }
// 95:   end
// 96:
// 97:   alias to_ary to_a
// 98:
// 99:   sig { returns(String) }
// 100:   def to_s
// 101:     @options.join(" ")
// 102:   end
// 103:
// 104:   sig { returns(String) }
// 105:   def inspect
// 106:     "#<#{self.class.name}: #{to_a.inspect}>"
// 107:   end
// 108:
// 109:   sig { params(formula: Formula).void }
// 110:   def self.dump_for_formula(formula)
// 111:     formula.options.sort_by(&:flag).each do |opt|
// 112:       puts "#{opt.flag}\n\t#{opt.description}"
// 113:     end
// 114:     puts "--HEAD\n\tInstall HEAD version" if formula.head
// 115:   end
// 116: end
