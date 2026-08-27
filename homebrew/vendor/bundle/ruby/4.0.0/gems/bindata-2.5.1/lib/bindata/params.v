module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/params.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `mandatory_parameters(*args)` at line 6.
pub fn ruby_params_l6_d1_mandatory_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mandatory_parameters', ...args)
}

// Ruby method `optional_parameters(*args)` at line 11.
pub fn ruby_params_l11_d2_optional_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('optional_parameters', ...args)
}

// Ruby method `default_parameters(*args)` at line 16.
pub fn ruby_params_l16_d3_default_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default_parameters', ...args)
}

// Ruby method `mutually_exclusive_parameters(*args)` at line 22.
pub fn ruby_params_l22_d4_mutually_exclusive_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mutually_exclusive_parameters', ...args)
}

// Ruby alias `alias mandatory_parameter mandatory_parameters` at line 26.
pub fn ruby_params_l26_d5_mandatory_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mandatory_parameter', ...args)
}

// Ruby alias `alias optional_parameter  optional_parameters` at line 27.
pub fn ruby_params_l27_d6_optional_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('optional_parameter', ...args)
}

// Ruby alias `alias default_parameter   default_parameters` at line 28.
pub fn ruby_params_l28_d7_default_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default_parameter', ...args)
}

// Ruby method `accepted_parameters # :nodoc:` at line 30.
pub fn ruby_params_l30_d8_accepted_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepted_parameters', ...args)
}

// Ruby method `initialize(ancestor_parameters = nil)` at line 42.
pub fn ruby_params_l42_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `mandatory(*args)` at line 56.
pub fn ruby_params_l56_d10_mandatory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mandatory', ...args)
}

// Ruby method `optional(*args)` at line 64.
pub fn ruby_params_l64_d11_optional(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('optional', ...args)
}

// Ruby method `default(args = nil)` at line 72.
pub fn ruby_params_l72_d12_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default', ...args)
}

// Ruby method `mutually_exclusive(*args)` at line 82.
pub fn ruby_params_l82_d13_mutually_exclusive(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mutually_exclusive', ...args)
}

// Ruby method `all` at line 94.
pub fn ruby_params_l94_d14_all(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('all', ...args)
}

// Ruby method `to_syms(args)` at line 101.
pub fn ruby_params_l101_d15_to_syms(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_syms', ...args)
}

// Ruby method `ensure_valid_names(names)` at line 107.
pub fn ruby_params_l107_d16_ensure_valid_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ensure_valid_names', ...args)
}

// Ruby method `invalid_parameter_names` at line 118.
pub fn ruby_params_l118_d17_invalid_parameter_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('invalid_parameter_names', ...args)
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
