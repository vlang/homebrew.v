module options

// Translated from Homebrew/brew `options/options.rb`.
// The original source is retained below.

// Options is an insertion-ordered set of formula options. Ruby's Set preserves
// the first equal object added, so equality and duplicate detection use only an
// option's name while retaining the first option's description.
pub struct Options {
mut:
	items  []FormulaOption
	frozen bool
}

// new_options translates Options.new(options = nil).
pub fn new_options(initial ...FormulaOption) Options {
	mut options := Options{}
	for option in initial {
		options.add(option)
	}
	return options
}

// create translates Options.create(array), including Homebrew's extraction of
// the option name from flags such as --feature and --prefix=/path.
pub fn create(arguments []string) Options {
	mut options := Options{}
	for argument in arguments {
		options.add(new_option(option_name_from_argument(argument)))
	}
	return options
}

fn option_name_from_argument(argument string) string {
	if !argument.starts_with('--') || argument.len <= 2 {
		return argument
	}
	name_and_value := argument[2..]
	if name_and_value.starts_with('=') {
		return argument
	}
	if equals_index := name_and_value.index('=') {
		return name_and_value[..equals_index + 1]
	}
	return name_and_value
}

// duplicate translates initialize_dup by copying the backing collection and
// returning an unfrozen Options value.
pub fn (options Options) duplicate() Options {
	return Options{
		items: options.items.clone()
	}
}

// freeze translates Options#freeze. Ruby freezes the Options wrapper but not its
// backing Set, so << remains usable after this call; the flag records the wrapper
// state without changing that source behavior.
pub fn (mut options Options) freeze() {
	options.frozen = true
}

pub fn (options Options) is_frozen() bool {
	return options.frozen
}

// each translates Options#each.
pub fn (options Options) each(block fn (FormulaOption)) {
	for option in options.items {
		block(option)
	}
}

// add translates Options#<<.
pub fn (mut options Options) add(other FormulaOption) {
	if !options.contains_option(other) {
		options.items << other
	}
}

// plus translates Options#+.
pub fn (options Options) plus(other Options) Options {
	mut result := options.duplicate()
	for option in other.items {
		result.add(option)
	}
	return result
}

// minus translates Options#-.
pub fn (options Options) minus(other Options) Options {
	mut result := Options{}
	for option in options.items {
		if !other.contains_option(option) {
			result.add(option)
		}
	}
	return result
}

// intersection translates Options#&.
pub fn (options Options) intersection(other Options) Options {
	mut result := Options{}
	for option in options.items {
		if other.contains_option(option) {
			result.add(option)
		}
	}
	return result
}

// union translates Options#|.
pub fn (options Options) union(other Options) Options {
	return options.plus(other)
}

// join translates Options#* with a String argument.
pub fn (options Options) join(separator string) string {
	return options.as_flags().join(separator)
}

// equal translates Options#== and Options#eql?. Like the Ruby implementation,
// it compares the insertion-ordered arrays rather than Set equality.
pub fn (options Options) equal(other Options) bool {
	if options.items.len != other.items.len {
		return false
	}
	for index, option in options.items {
		if !option.equal(other.items[index]) {
			return false
		}
	}
	return true
}

pub fn (options Options) empty() bool {
	return options.items.len == 0
}

pub fn (options Options) len() int {
	return options.items.len
}

// as_flags translates Options#as_flags.
pub fn (options Options) as_flags() []string {
	return options.items.map(it.flag)
}

// contains translates the String branch of Options#include?.
pub fn (options Options) contains(value string) bool {
	return options.items.any(it.name == value || it.flag == value)
}

// contains_option translates the FormulaOption branch of Options#include?.
pub fn (options Options) contains_option(value FormulaOption) bool {
	return options.items.any(it.equal(value))
}

// to_array translates Enumerable#to_a and the to_ary alias.
pub fn (options Options) to_array() []FormulaOption {
	return options.items.clone()
}

// str translates Options#to_s.
pub fn (options Options) str() string {
	return options.as_flags().join(' ')
}

// inspect translates Options#inspect.
pub fn (options Options) inspect() string {
	return '#<Options: [${options.items.map(it.inspect()).join(', ')}]>'
}

// FormulaOptionProvider is the typed V counterpart of the Formula properties
// consumed by Options.dump_for_formula.
pub interface FormulaOptionProvider {
	formula_options() Options
	formula_has_head() bool
}

// format_for_formula contains the output behavior of Options.dump_for_formula.
pub fn format_for_formula(options Options, has_head bool) string {
	mut sorted_options := options.to_array()
	sorted_options.sort(a.flag < b.flag)
	mut lines := []string{}
	for option in sorted_options {
		lines << option.flag
		lines << '\t${option.description}'
	}
	if has_head {
		lines << '--HEAD'
		lines << '\tInstall HEAD version'
	}
	if lines.len == 0 {
		return ''
	}
	return lines.join('\n') + '\n'
}

// dump_for_formula translates Options.dump_for_formula(formula).
pub fn dump_for_formula(formula FormulaOptionProvider) {
	print(format_for_formula(formula.formula_options(), formula.formula_has_head()))
}

// Ruby method `self.create(array)` at line 12.
pub fn ruby_options_l12_d1_self_create(arguments []string) Options {
	return create(arguments)
}

// Ruby method `initialize(options = nil)` at line 17.
pub fn ruby_options_l17_d2_initialize(initial ...FormulaOption) Options {
	return new_options(...initial)
}

// Ruby method `initialize_dup(other)` at line 23.
pub fn ruby_options_l23_d3_initialize_dup(other Options) Options {
	return other.duplicate()
}

// Ruby method `freeze` at line 29.
pub fn ruby_options_l29_d4_freeze(mut options Options) Options {
	options.freeze()
	return options
}

// Ruby method `each(&block)` at line 35.
pub fn ruby_options_l35_d5_each(options Options, block fn (FormulaOption)) Options {
	options.each(block)
	return options
}

// Ruby method `<<(other)` at line 41.
pub fn ruby_options_l41_d6_anonymous(mut options Options, other FormulaOption) Options {
	options.add(other)
	return options
}

// Ruby method `+(other)` at line 47.
pub fn ruby_options_l47_d7_anonymous(options Options, other Options) Options {
	return options.plus(other)
}

// Ruby method `-(other)` at line 52.
pub fn ruby_options_l52_d8_anonymous(options Options, other Options) Options {
	return options.minus(other)
}

// Ruby method `&(other)` at line 57.
pub fn ruby_options_l57_d9_anonymous(options Options, other Options) Options {
	return options.intersection(other)
}

// Ruby method `|(other)` at line 62.
pub fn ruby_options_l62_d10_anonymous(options Options, other Options) Options {
	return options.union(other)
}

// Ruby method `*(other)` at line 67.
pub fn ruby_options_l67_d11_anonymous(options Options, separator string) string {
	return options.join(separator)
}

// Ruby method `==(other)` at line 72.
pub fn ruby_options_l72_d12_anonymous(options Options, other Options) bool {
	return options.equal(other)
}

// Ruby alias `alias eql? ==` at line 80.
pub fn ruby_options_l80_d13_eql(options Options, other Options) bool {
	return options.equal(other)
}

// Ruby method `empty?` at line 83.
pub fn ruby_options_l83_d14_empty(options Options) bool {
	return options.empty()
}

// Ruby method `as_flags` at line 88.
pub fn ruby_options_l88_d15_as_flags(options Options) []string {
	return options.as_flags()
}

// Ruby method `include?(option)` at line 93.
pub fn ruby_options_l93_d16_include(options Options, option string) bool {
	return options.contains(option)
}

// Ruby alias `alias to_ary to_a` at line 97.
pub fn ruby_options_l97_d17_to_ary(options Options) []FormulaOption {
	return options.to_array()
}

// Ruby method `to_s` at line 100.
pub fn ruby_options_l100_d18_to_s(options Options) string {
	return options.str()
}

// Ruby method `inspect` at line 105.
pub fn ruby_options_l105_d19_inspect(options Options) string {
	return options.inspect()
}

// Ruby method `self.dump_for_formula(formula)` at line 110.
pub fn ruby_options_l110_d20_self_dump_for_formula(formula FormulaOptionProvider) {
	dump_for_formula(formula)
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
