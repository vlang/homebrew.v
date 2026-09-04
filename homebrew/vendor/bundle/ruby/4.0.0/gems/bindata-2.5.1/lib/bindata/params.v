module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/params.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct AcceptedParameters {
mut:
	mandatory_names          []string
	optional_names           []string
	default_values           map[string]ruby.Value
	default_names            []string
	mutually_exclusive_pairs [][]string
}

pub fn new_accepted_parameters() &AcceptedParameters {
	return &AcceptedParameters{
		default_values: map[string]ruby.Value{}
	}
}

pub fn inherit_accepted_parameters(ancestor &AcceptedParameters) &AcceptedParameters {
	return &AcceptedParameters{
		mandatory_names: ancestor.mandatory_names.clone()
		optional_names: ancestor.optional_names.clone()
		default_values: ancestor.default_values.clone()
		default_names: ancestor.default_names.clone()
		mutually_exclusive_pairs: ancestor.mutually_exclusive_pairs.map(it.clone())
	}
}

fn unique_parameter_names(names []string) []string {
	mut result := []string{cap: names.len}
	for name in names {
		if name !in result {
			result << name
		}
	}
	return result
}

pub fn invalid_accepted_parameter_names() []string {
	// LazyEvaluator.instance_methods(true) on Homebrew's portable Ruby 4.0,
	// excluding the explicitly allowed `name` and `type` methods.
	return ['!', '!=', '!~', '<=>', '==', '===', '__id__', '__send__', 'class', 'clone',
		'define_singleton_method', 'display', 'dup', 'enum_for', 'eql?', 'equal?', 'extend', 'freeze',
		'frozen?', 'hash', 'index', 'inspect', 'instance_eval', 'instance_exec', 'instance_of?',
		'instance_variable_defined?', 'instance_variable_get', 'instance_variable_set',
		'instance_variables', 'is_a?', 'itself', 'kind_of?', 'lazy_eval', 'method', 'method_missing',
		'methods', 'nil?', 'object_id', 'parent', 'private_methods', 'protected_methods',
		'public_method', 'public_methods', 'public_send', 'remove_instance_variable', 'respond_to?',
		'send', 'singleton_class', 'singleton_method', 'singleton_methods', 'tap', 'then', 'to_enum',
		'to_s', 'yield_self']
}

pub fn validate_accepted_parameter_names(names []string) ! {
	invalid_names := invalid_accepted_parameter_names()
	for name in names {
		if name in invalid_names {
			return error("Rename parameter '${name}' as it shadows an existing method.")
		}
	}
}

pub fn accepted_parameter_symbols(names []string) ![]string {
	mut symbols := []string{cap: names.len}
	for name in names {
		symbols << name.trim_left(':')
	}
	validate_accepted_parameter_names(symbols)!
	return symbols
}

pub fn (mut parameters AcceptedParameters) add_mandatory(names []string) ![]string {
	if names.len > 0 {
		parameters.mandatory_names << accepted_parameter_symbols(names)!
		parameters.mandatory_names = unique_parameter_names(parameters.mandatory_names)
	}
	return parameters.mandatory_names.clone()
}

pub fn (mut parameters AcceptedParameters) add_optional(names []string) ![]string {
	if names.len > 0 {
		parameters.optional_names << accepted_parameter_symbols(names)!
		parameters.optional_names = unique_parameter_names(parameters.optional_names)
	}
	return parameters.optional_names.clone()
}

pub fn (mut parameters AcceptedParameters) add_defaults(values map[string]ruby.Value) !map[string]ruby.Value {
	validate_accepted_parameter_names(values.keys().map(it.trim_left(':')))!
	for original_name, value in values {
		name := original_name.trim_left(':')
		if name !in parameters.default_values {
			parameters.default_names << name
		}
		parameters.default_values[name] = value
	}
	return parameters.default_values.clone()
}

pub fn (mut parameters AcceptedParameters) add_mutually_exclusive(names []string) ![][]string {
	symbols := accepted_parameter_symbols(names)!
	for left_index in 0 .. symbols.len {
		for right_index in left_index + 1 .. symbols.len {
			pair := [symbols[left_index], symbols[right_index]]
			if pair !in parameters.mutually_exclusive_pairs {
				parameters.mutually_exclusive_pairs << pair
			}
		}
	}
	return parameters.mutually_exclusive_pairs.map(it.clone())
}

pub fn (parameters &AcceptedParameters) mandatory() []string {
	return parameters.mandatory_names.clone()
}

pub fn (parameters &AcceptedParameters) optional() []string {
	return parameters.optional_names.clone()
}

pub fn (parameters &AcceptedParameters) defaults() map[string]ruby.Value {
	return parameters.default_values.clone()
}

pub fn (parameters &AcceptedParameters) mutually_exclusive() [][]string {
	return parameters.mutually_exclusive_pairs.map(it.clone())
}

pub fn (parameters &AcceptedParameters) all() []string {
	mut names := parameters.mandatory_names.clone()
	names << parameters.optional_names
	names << parameters.default_names
	return unique_parameter_names(names)
}

fn accepted_parameters_value(parameters &AcceptedParameters) ruby.Value {
	pairs := parameters.mutually_exclusive_pairs.map(ruby.string_array_value(it))
	return ruby.Value{
		type_name: 'BinData::AcceptedParameters'
		repr: parameters.all().str()
		int_data: i64(u64(voidptr(parameters)))
		attributes: {
			'accepted_parameters_address': u64(voidptr(parameters)).str()
		}
		map_data: {
			'mandatory':          ruby.string_array_value(parameters.mandatory_names)
			'optional':           ruby.string_array_value(parameters.optional_names)
			'default':            ruby.map_value(parameters.default_values)
			'default_names':      ruby.string_array_value(parameters.default_names)
			'mutually_exclusive': ruby.array_value(pairs)
		}
	}
}

fn accepted_parameters_from_value(value ruby.Value) &AcceptedParameters {
	if address := value.attributes['accepted_parameters_address'] {
		actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
		return unsafe { &AcceptedParameters(voidptr(actual)) }
	}
	if value.type_name != 'BinData::AcceptedParameters' {
		return new_accepted_parameters()
	}
	data := value.map_data.clone()
	mandatory := data['mandatory'] or { ruby.string_array_value([]) }
	optional := data['optional'] or { ruby.string_array_value([]) }
	defaults := data['default'] or { ruby.map_value({}) }
	default_names := data['default_names'] or { ruby.string_array_value([]) }
	pairs := data['mutually_exclusive'] or { ruby.array_value([]) }
	return &AcceptedParameters{
		mandatory_names: mandatory.as_string_array() or { panic(err) }
		optional_names: optional.as_string_array() or { panic(err) }
		default_values: defaults.as_map() or { panic(err) }
		default_names: default_names.as_string_array() or { panic(err) }
		mutually_exclusive_pairs: pairs.as_array() or { panic(err) }.map(it.as_string_array() or {
			panic(err)})
	}
}

pub fn new_accepted_parameters_plugin_receiver(type_name string) ruby.Value {
	parameters := new_accepted_parameters()
	return ruby.Value{
		type_name: type_name
		repr: type_name
		int_data: i64(u64(voidptr(parameters)))
		attributes: {
			'accepted_parameters_address': u64(voidptr(parameters)).str()
		}
	}
}

pub fn inherit_accepted_parameters_plugin_receiver(type_name string, ancestor ruby.Value) ruby.Value {
	parameters := inherit_accepted_parameters(accepted_parameters_for_plugin(ancestor))
	return ruby.Value{
		type_name: type_name
		repr: type_name
		int_data: i64(u64(voidptr(parameters)))
		attributes: {
			'accepted_parameters_address': u64(voidptr(parameters)).str()
		}
	}
}

fn nil_parameter_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn parameter_name_from_value(value ruby.Value) string {
	if value.type_name !in ['String', 'Symbol'] {
		panic("undefined method `to_sym' for ${value.type_name}")
	}
	return value.as_string().trim_left(':')
}

fn parameter_names_from_values(values []ruby.Value) []string {
	return values.map(parameter_name_from_value(it))
}

fn accepted_parameters_for_plugin(receiver ruby.Value) &AcceptedParameters {
	if _ := receiver.attributes['accepted_parameters_address'] {
		return accepted_parameters_from_value(receiver)
	}
	if receiver.type_name == 'BinData::AcceptedParameters' {
		return accepted_parameters_from_value(receiver)
	}
	if stored := receiver.map_data['accepted_parameters'] {
		return accepted_parameters_from_value(stored)
	}
	if ancestor := receiver.map_data['ancestor_accepted_parameters'] {
		return inherit_accepted_parameters(accepted_parameters_from_value(ancestor))
	}
	return new_accepted_parameters()
}

fn parameter_pairs_value(pairs [][]string) ruby.Value {
	return ruby.array_value(pairs.map(ruby.string_array_value(it)))
}

// Ruby method `mandatory_parameters(*args)` at line 6.
pub fn ruby_params_l6_d1_mandatory_parameters(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('mandatory_parameters requires a receiver')
	}
	mut parameters := accepted_parameters_for_plugin(args[0])
	return ruby.string_array_value(parameters.add_mandatory(parameter_names_from_values(args[1..])) or {
		panic(err)
	})
}

// Ruby method `optional_parameters(*args)` at line 11.
pub fn ruby_params_l11_d2_optional_parameters(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('optional_parameters requires a receiver')
	}
	mut parameters := accepted_parameters_for_plugin(args[0])
	return ruby.string_array_value(parameters.add_optional(parameter_names_from_values(args[1..])) or {
		panic(err)
	})
}

// Ruby method `default_parameters(*args)` at line 16.
pub fn ruby_params_l16_d3_default_parameters(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('default_parameters requires a receiver')
	}
	if args.len > 2 {
		panic('wrong number of arguments for default_parameters')
	}
	mut parameters := accepted_parameters_for_plugin(args[0])
	values := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].as_map() or { panic(err) }
	} else {
		map[string]ruby.Value{}
	}
	return ruby.map_value(parameters.add_defaults(values) or { panic(err) })
}

// Ruby method `mutually_exclusive_parameters(*args)` at line 22.
pub fn ruby_params_l22_d4_mutually_exclusive_parameters(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('mutually_exclusive_parameters requires a receiver')
	}
	mut parameters := accepted_parameters_for_plugin(args[0])
	return parameter_pairs_value(parameters.add_mutually_exclusive(parameter_names_from_values(args[1..])) or {
		panic(err)
	})
}

// Ruby alias `alias mandatory_parameter mandatory_parameters` at line 26.
pub fn ruby_params_l26_d5_mandatory_parameter(args ...ruby.Value) ruby.Value {
	return ruby_params_l6_d1_mandatory_parameters(...args)
}

// Ruby alias `alias optional_parameter  optional_parameters` at line 27.
pub fn ruby_params_l27_d6_optional_parameter(args ...ruby.Value) ruby.Value {
	return ruby_params_l11_d2_optional_parameters(...args)
}

// Ruby alias `alias default_parameter   default_parameters` at line 28.
pub fn ruby_params_l28_d7_default_parameter(args ...ruby.Value) ruby.Value {
	return ruby_params_l16_d3_default_parameters(...args)
}

// Ruby method `accepted_parameters # :nodoc:` at line 30.
pub fn ruby_params_l30_d8_accepted_parameters(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return accepted_parameters_value(new_accepted_parameters())
	}
	return accepted_parameters_value(accepted_parameters_for_plugin(args[0]))
}

// Ruby method `initialize(ancestor_parameters = nil)` at line 42.
pub fn ruby_params_l42_d9_initialize(args ...ruby.Value) ruby.Value {
	if args.len > 1 {
		panic('wrong number of arguments for AcceptedParameters#initialize')
	}
	if args.len > 0 && args[0].type_name != 'NilClass' {
		return accepted_parameters_value(inherit_accepted_parameters(accepted_parameters_from_value(args[0])))
	}
	return accepted_parameters_value(new_accepted_parameters())
}

// Ruby method `mandatory(*args)` at line 56.
pub fn ruby_params_l56_d10_mandatory(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('AcceptedParameters#mandatory requires a receiver')
	}
	mut parameters := accepted_parameters_from_value(args[0])
	return ruby.string_array_value(parameters.add_mandatory(parameter_names_from_values(args[1..])) or {
		panic(err)
	})
}

// Ruby method `optional(*args)` at line 64.
pub fn ruby_params_l64_d11_optional(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('AcceptedParameters#optional requires a receiver')
	}
	mut parameters := accepted_parameters_from_value(args[0])
	return ruby.string_array_value(parameters.add_optional(parameter_names_from_values(args[1..])) or {
		panic(err)
	})
}

// Ruby method `default(args = nil)` at line 72.
pub fn ruby_params_l72_d12_default(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('AcceptedParameters#default requires a receiver')
	}
	if args.len > 2 {
		panic('wrong number of arguments for AcceptedParameters#default')
	}
	mut parameters := accepted_parameters_from_value(args[0])
	if args.len > 1 && args[1].type_name != 'NilClass' {
		return ruby.map_value(parameters.add_defaults(args[1].as_map() or { panic(err) }) or {
			panic(err)
		})
	}
	return ruby.map_value(parameters.defaults())
}

// Ruby method `mutually_exclusive(*args)` at line 82.
pub fn ruby_params_l82_d13_mutually_exclusive(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('AcceptedParameters#mutually_exclusive requires a receiver')
	}
	mut parameters := accepted_parameters_from_value(args[0])
	return parameter_pairs_value(parameters.add_mutually_exclusive(parameter_names_from_values(args[1..])) or {
		panic(err)
	})
}

// Ruby method `all` at line 94.
pub fn ruby_params_l94_d14_all(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('AcceptedParameters#all requires a receiver')
	}
	return ruby.string_array_value(accepted_parameters_from_value(args[0]).all())
}

// Ruby method `to_syms(args)` at line 101.
pub fn ruby_params_l101_d15_to_syms(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('AcceptedParameters#to_syms requires a receiver and array')
	}
	values := args[1].as_array() or { panic(err) }
	return ruby.string_array_value(accepted_parameter_symbols(parameter_names_from_values(values)) or {
		panic(err)
	})
}

// Ruby method `ensure_valid_names(names)` at line 107.
pub fn ruby_params_l107_d16_ensure_valid_names(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('AcceptedParameters#ensure_valid_names requires a receiver and names')
	}
	names := args[1].as_array() or { panic(err) }
	converted := parameter_names_from_values(names)
	validate_accepted_parameter_names(converted) or { panic(err) }
	return ruby.string_array_value(converted)
}

// Ruby method `invalid_parameter_names` at line 118.
pub fn ruby_params_l118_d17_invalid_parameter_names(args ...ruby.Value) ruby.Value {
	mut invalid := map[string]ruby.Value{}
	for name in invalid_accepted_parameter_names() {
		invalid[name] = ruby.bool_value(true)
	}
	return ruby.map_value(invalid)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/lazy'
// 2:
// 3: module BinData
// 4:   module AcceptedParametersPlugin
// 5:     # Mandatory parameters must be present when instantiating a data object.
// 6:     def mandatory_parameters(*args)
// 7:       accepted_parameters.mandatory(*args)
// 8:     end
// 9:
// 10:     # Optional parameters may be present when instantiating a data object.
// 11:     def optional_parameters(*args)
// 12:       accepted_parameters.optional(*args)
// 13:     end
// 14:
// 15:     # Default parameters can be overridden when instantiating a data object.
// 16:     def default_parameters(*args)
// 17:       accepted_parameters.default(*args)
// 18:     end
// 19:
// 20:     # Mutually exclusive parameters may not all be present when
// 21:     # instantiating a data object.
// 22:     def mutually_exclusive_parameters(*args)
// 23:       accepted_parameters.mutually_exclusive(*args)
// 24:     end
// 25:
// 26:     alias mandatory_parameter mandatory_parameters
// 27:     alias optional_parameter  optional_parameters
// 28:     alias default_parameter   default_parameters
// 29:
// 30:     def accepted_parameters # :nodoc:
// 31:       @accepted_parameters ||= begin
// 32:         ancestor_params = superclass.respond_to?(:accepted_parameters) ?
// 33:                             superclass.accepted_parameters : nil
// 34:         AcceptedParameters.new(ancestor_params)
// 35:       end
// 36:     end
// 37:
// 38:     # BinData objects accept parameters when initializing.  AcceptedParameters
// 39:     # allow a BinData class to declaratively identify accepted parameters as
// 40:     # mandatory, optional, default or mutually exclusive.
// 41:     class AcceptedParameters
// 42:       def initialize(ancestor_parameters = nil)
// 43:         if ancestor_parameters
// 44:           @mandatory = ancestor_parameters.mandatory.dup
// 45:           @optional  = ancestor_parameters.optional.dup
// 46:           @default   = ancestor_parameters.default.dup
// 47:           @mutually_exclusive = ancestor_parameters.mutually_exclusive.dup
// 48:         else
// 49:           @mandatory = []
// 50:           @optional  = []
// 51:           @default   = Hash.new
// 52:           @mutually_exclusive = []
// 53:         end
// 54:       end
// 55:
// 56:       def mandatory(*args)
// 57:         unless args.empty?
// 58:           @mandatory.concat(to_syms(args))
// 59:           @mandatory.uniq!
// 60:         end
// 61:         @mandatory
// 62:       end
// 63:
// 64:       def optional(*args)
// 65:         unless args.empty?
// 66:           @optional.concat(to_syms(args))
// 67:           @optional.uniq!
// 68:         end
// 69:         @optional
// 70:       end
// 71:
// 72:       def default(args = nil)
// 73:         if args
// 74:           to_syms(args.keys)  # call for side effect of validating names
// 75:           args.each_pair do |param, value|
// 76:             @default[param.to_sym] = value
// 77:           end
// 78:         end
// 79:         @default
// 80:       end
// 81:
// 82:       def mutually_exclusive(*args)
// 83:         arg1 = args.shift
// 84:         until args.empty?
// 85:           args.each do |arg2|
// 86:             @mutually_exclusive.push([arg1.to_sym, arg2.to_sym])
// 87:             @mutually_exclusive.uniq!
// 88:           end
// 89:           arg1 = args.shift
// 90:         end
// 91:         @mutually_exclusive
// 92:       end
// 93:
// 94:       def all
// 95:         (@mandatory + @optional + @default.keys).uniq
// 96:       end
// 97:
// 98:       #---------------
// 99:       private
// 100:
// 101:       def to_syms(args)
// 102:         syms = args.collect(&:to_sym)
// 103:         ensure_valid_names(syms)
// 104:         syms
// 105:       end
// 106:
// 107:       def ensure_valid_names(names)
// 108:         invalid_names = self.class.invalid_parameter_names
// 109:         names.each do |name|
// 110:           if invalid_names.include?(name)
// 111:             raise NameError.new("Rename parameter '#{name}' " \
// 112:                                 "as it shadows an existing method.", name)
// 113:           end
// 114:         end
// 115:       end
// 116:
// 117:       class << self
// 118:         def invalid_parameter_names
// 119:           @invalid_parameter_names ||= begin
// 120:             all_names = LazyEvaluator.instance_methods(true)
// 121:             allowed_names = [:name, :type]
// 122:             invalid_names = (all_names - allowed_names).uniq
// 123:
// 124:             Hash[*invalid_names.collect { |key| [key.to_sym, true] }.flatten]
// 125:           end
// 126:         end
// 127:       end
// 128:     end
// 129:   end
// 130: end
