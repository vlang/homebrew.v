module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/choice.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize_shared_instance` at line 69.
pub fn ruby_choice_l69_d1_initialize_shared_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_shared_instance', ...args)
}

// Ruby method `initialize_instance` at line 74.
pub fn ruby_choice_l74_d2_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_instance', ...args)
}

// Ruby method `selection` at line 80.
pub fn ruby_choice_l80_d3_selection(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('selection', ...args)
}

// Ruby method `respond_to?(symbol, include_all = false) # :nodoc:` at line 89.
pub fn ruby_choice_l89_d4_respond_to(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('respond_to?', ...args)
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 93.
pub fn ruby_choice_l93_d5_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby method `#{m}(*args)` at line 99.
pub fn ruby_choice_l99_d6_m(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{m}', ...args)
}

// Ruby method `current_choice` at line 108.
pub fn ruby_choice_l108_d7_current_choice(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current_choice', ...args)
}

// Ruby method `instantiate_choice(selection)` at line 113.
pub fn ruby_choice_l113_d8_instantiate_choice(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('instantiate_choice', ...args)
}

// Ruby method `sanitize_parameters!(obj_class, params) # :nodoc:` at line 125.
pub fn ruby_choice_l125_d9_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sanitize_parameters!', ...args)
}

// Ruby method `choices_as_hash(choices)` at line 138.
pub fn ruby_choice_l138_d10_choices_as_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('choices_as_hash', ...args)
}

// Ruby method `key_array_by_index(array)` at line 146.
pub fn ruby_choice_l146_d11_key_array_by_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('key_array_by_index', ...args)
}

// Ruby method `ensure_valid_keys(choices)` at line 154.
pub fn ruby_choice_l154_d12_ensure_valid_keys(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ensure_valid_keys', ...args)
}

// Ruby method `current_choice` at line 166.
pub fn ruby_choice_l166_d13_current_choice(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current_choice', ...args)
}

// Ruby method `copy_previous_value(obj)` at line 172.
pub fn ruby_choice_l172_d14_copy_previous_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('copy_previous_value', ...args)
}

// Ruby method `get_previous_choice(selection)` at line 179.
pub fn ruby_choice_l179_d15_get_previous_choice(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_previous_choice', ...args)
}

// Ruby method `remember_current_selection(selection)` at line 185.
pub fn ruby_choice_l185_d16_remember_current_selection(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remember_current_selection', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base'
// 2: require 'bindata/dsl'
// 3:
// 4: module BinData
// 5:   # A Choice is a collection of data objects of which only one is active
// 6:   # at any particular time.  Method calls will be delegated to the active
// 7:   # choice.
// 8:   #
// 9:   #   require 'bindata'
// 10:   #
// 11:   #   type1 = [:string, {value: "Type1"}]
// 12:   #   type2 = [:string, {value: "Type2"}]
// 13:   #
// 14:   #   choices = {5 => type1, 17 => type2}
// 15:   #   a = BinData::Choice.new(choices: choices, selection: 5)
// 16:   #   a # => "Type1"
// 17:   #
// 18:   #   choices = [ type1, type2 ]
// 19:   #   a = BinData::Choice.new(choices: choices, selection: 1)
// 20:   #   a # => "Type2"
// 21:   #
// 22:   #   choices = [ nil, nil, nil, type1, nil, type2 ]
// 23:   #   a = BinData::Choice.new(choices: choices, selection: 3)
// 24:   #   a # => "Type1"
// 25:   #
// 26:   #
// 27:   #   Chooser = Struct.new(:choice)
// 28:   #   mychoice = Chooser.new
// 29:   #   mychoice.choice = 'big'
// 30:   #
// 31:   #   choices = {'big' => :uint16be, 'little' => :uint16le}
// 32:   #   a = BinData::Choice.new(choices: choices, copy_on_change: true,
// 33:   #                           selection: -> { mychoice.choice })
// 34:   #   a.assign(256)
// 35:   #   a.to_binary_s #=> "\001\000"
// 36:   #
// 37:   #   mychoice.choice = 'little'
// 38:   #   a.to_binary_s #=> "\000\001"
// 39:   #
// 40:   # == Parameters
// 41:   #
// 42:   # Parameters may be provided at initialisation to control the behaviour of
// 43:   # an object.  These params are:
// 44:   #
// 45:   # <tt>:choices</tt>::        Either an array or a hash specifying the possible
// 46:   #                            data objects.  The format of the
// 47:   #                            array/hash.values is a list of symbols
// 48:   #                            representing the data object type.  If a choice
// 49:   #                            is to have params passed to it, then it should
// 50:   #                            be provided as [type_symbol, hash_params].  An
// 51:   #                            implementation constraint is that the hash may
// 52:   #                            not contain symbols as keys, with the exception
// 53:   #                            of :default.  :default is to be used when then
// 54:   #                            :selection does not exist in the :choices hash.
// 55:   # <tt>:selection</tt>::      An index/key into the :choices array/hash which
// 56:   #                            specifies the currently active choice.
// 57:   # <tt>:copy_on_change</tt>:: If set to true, copy the value of the previous
// 58:   #                            selection to the current selection whenever the
// 59:   #                            selection changes.  Default is false.
// 60:   class Choice < BinData::Base
// 61:     extend DSLMixin
// 62:
// 63:     dsl_parser    :choice
// 64:     arg_processor :choice
// 65:
// 66:     mandatory_parameters :choices, :selection
// 67:     optional_parameter   :copy_on_change
// 68:
// 69:     def initialize_shared_instance
// 70:       extend CopyOnChangePlugin if eval_parameter(:copy_on_change) == true
// 71:       super
// 72:     end
// 73:
// 74:     def initialize_instance
// 75:       @choices = {}
// 76:       @last_selection = nil
// 77:     end
// 78:
// 79:     # Returns the current selection.
// 80:     def selection
// 81:       selection = eval_parameter(:selection)
// 82:       if selection.nil?
// 83:         raise IndexError, ":selection returned nil for #{debug_name}"
// 84:       end
// 85:
// 86:       selection
// 87:     end
// 88:
// 89:     def respond_to?(symbol, include_all = false) # :nodoc:
// 90:       current_choice.respond_to?(symbol, include_all) || super
// 91:     end
// 92:
// 93:     def method_missing(symbol, *args, &block) # :nodoc:
// 94:       current_choice.__send__(symbol, *args, &block)
// 95:     end
// 96:
// 97:     %w[clear? assign snapshot do_read do_write do_num_bytes].each do |m|
// 98:       module_eval <<-END
// 99:         def #{m}(*args)
// 100:           current_choice.#{m}(*args)
// 101:         end
// 102:       END
// 103:     end
// 104:
// 105:     #---------------
// 106:     private
// 107:
// 108:     def current_choice
// 109:       current_selection = selection
// 110:       @choices[current_selection] ||= instantiate_choice(current_selection)
// 111:     end
// 112:
// 113:     def instantiate_choice(selection)
// 114:       prototype = get_parameter(:choices)[selection]
// 115:       if prototype.nil?
// 116:         msg = "selection '#{selection}' does not exist in :choices for #{debug_name}"
// 117:         raise IndexError, msg
// 118:       end
// 119:
// 120:       prototype.instantiate(nil, self)
// 121:     end
// 122:   end
// 123:
// 124:   class ChoiceArgProcessor < BaseArgProcessor
// 125:     def sanitize_parameters!(obj_class, params) # :nodoc:
// 126:       params.merge!(obj_class.dsl_params)
// 127:
// 128:       params.sanitize_choices(:choices) do |choices|
// 129:         hash_choices = choices_as_hash(choices)
// 130:         ensure_valid_keys(hash_choices)
// 131:         hash_choices
// 132:       end
// 133:     end
// 134:
// 135:     #-------------
// 136:     private
// 137:
// 138:     def choices_as_hash(choices)
// 139:       if choices.respond_to?(:to_ary)
// 140:         key_array_by_index(choices.to_ary)
// 141:       else
// 142:         choices
// 143:       end
// 144:     end
// 145:
// 146:     def key_array_by_index(array)
// 147:       result = {}
// 148:       array.each_with_index do |el, i|
// 149:         result[i] = el unless el.nil?
// 150:       end
// 151:       result
// 152:     end
// 153:
// 154:     def ensure_valid_keys(choices)
// 155:       if choices.key?(nil)
// 156:         raise ArgumentError, ":choices hash may not have nil key"
// 157:       end
// 158:       if choices.keys.detect { |key| key.is_a?(Symbol) && key != :default }
// 159:         raise ArgumentError, ":choices hash may not have symbols for keys"
// 160:       end
// 161:     end
// 162:   end
// 163:
// 164:   # Logic for the :copy_on_change parameter
// 165:   module CopyOnChangePlugin
// 166:     def current_choice
// 167:       obj = super
// 168:       copy_previous_value(obj)
// 169:       obj
// 170:     end
// 171:
// 172:     def copy_previous_value(obj)
// 173:       current_selection = selection
// 174:       prev = get_previous_choice(current_selection)
// 175:       obj.assign(prev) unless prev.nil?
// 176:       remember_current_selection(current_selection)
// 177:     end
// 178:
// 179:     def get_previous_choice(selection)
// 180:       if @last_selection && selection != @last_selection
// 181:         @choices[@last_selection]
// 182:       end
// 183:     end
// 184:
// 185:     def remember_current_selection(selection)
// 186:       @last_selection = selection
// 187:     end
// 188:   end
// 189: end
