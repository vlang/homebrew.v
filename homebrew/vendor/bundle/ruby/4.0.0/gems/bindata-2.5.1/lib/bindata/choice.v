module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/choice.rb`.
// The original source is retained below until every stub has a typed V body.
pub type ChoiceSelectionFn = fn() ruby.Value

struct ChoiceEntry {
mut:
	key          ruby.Value
	prototype    ruby.Value
	instance     ruby.Value
	has_instance bool
}

@[heap]
pub struct ChoiceObject {
mut:
	base                   &BaseObject
	entries                []ChoiceEntry
	selection_value        ruby.Value
	selection_callback     ChoiceSelectionFn = unsafe { nil }
	has_selection_callback bool
	last_selection         ruby.Value
	has_last_selection     bool
	copy_on_change         bool
}

fn choice_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn choice_entries(value ruby.Value) []ChoiceEntry {
	mut entries := []ChoiceEntry{}
	if value.type_name == 'BinData::SanitizedChoices' {
		choices := sanitized_choices_from_value(value)
		for entry in choices.entries {
			entries << ChoiceEntry{ key: entry.key, prototype: entry.prototype, instance: choice_nil_value() }
		}
		if choices.has_default {
			entries << ChoiceEntry{
				key: ruby.object_value('Symbol', ':default')
				prototype: choices.default_prototype
				instance: choice_nil_value()
			}
		}
		return entries
	}
	if value.type_name == 'Array' {
		for index, item in value.as_array() or { panic(err) } {
			if item.type_name != 'NilClass' {
				entries << ChoiceEntry{ key: ruby.int_value(index), prototype: item, instance: choice_nil_value() }
			}
		}
		return entries
	}
	for key, item in value.map_data {
		entries << ChoiceEntry{
			key: if key == 'default' {
				ruby.object_value('Symbol', ':default')} else {
				ruby.string_value(key)}
			prototype: item
			instance: choice_nil_value()
		}
	}
	return entries
}

pub fn new_bindata_choice(choices ruby.Value, selection ruby.Value, copy_on_change bool) &ChoiceObject {
	return &ChoiceObject{
		base: new_base_object('BinData::Choice', {
			'choices':        choices
			'selection':      selection
			'copy_on_change': ruby.bool_value(copy_on_change)
		})
		entries: choice_entries(choices)
		selection_value: selection
		last_selection: choice_nil_value()
		copy_on_change: copy_on_change
	}
}

pub fn (mut object ChoiceObject) set_selection_callback(callback ChoiceSelectionFn) {
	object.selection_callback = callback
	object.has_selection_callback = true
}

pub fn (mut object ChoiceObject) set_selection(selection ruby.Value) {
	object.selection_value = selection
}

fn choice_object_value(object &ChoiceObject) ruby.Value {
	return ruby.Value{
		type_name: 'BinData::Choice'
		repr: 'BinData::Choice'
		map_data: object.base.parameters
		attributes: {
			'choice_object_address': u64(voidptr(object)).str()
		}
	}
}

pub fn choice_boundary_value(object &ChoiceObject) ruby.Value {
	return choice_object_value(object)
}

fn choice_object_from_value(value ruby.Value) &ChoiceObject {
	if address := value.attributes['choice_object_address'] {
		return unsafe { &ChoiceObject(voidptr(address.u64())) }
	}
	choices := value.map_data['choices'] or { ruby.map_value({}) }
	selection := value.map_data['selection'] or { choice_nil_value() }
	mut base := base_object_from_value(value)
	return &ChoiceObject{
		base: base
		entries: choice_entries(choices)
		selection_value: selection
		last_selection: choice_nil_value()
		copy_on_change: (value.map_data['copy_on_change'] or { ruby.bool_value(false) }).bool_data
	}
}

fn choice_selection(object &ChoiceObject) !ruby.Value {
	selection := if object.has_selection_callback {
		object.selection_callback()
	} else {
		object.selection_value
	}
	if selection.type_name == 'NilClass' {
		return error(':selection returned nil for BinData::Choice')
	}
	return selection
}

fn choice_entry_index(object &ChoiceObject, selection ruby.Value) int {
	mut default_index := -1
	for index, entry in object.entries {
		if entry.key.type_name == 'Symbol' && entry.key.as_string().trim_left(':') == 'default' {
			default_index = index
		} else if values_equal(entry.key, selection) {
			return index
		}
	}
	return default_index
}

fn choice_instantiate(prototype ruby.Value, parent ruby.Value) ruby.Value {
	if prototype.type_name == 'BinData::SanitizedPrototype' {
		mut actual := sanitized_prototype_from_value(prototype)
		return actual.instantiate(choice_nil_value(), false, parent, true)
	}
	if sanitize_is_base_instance(prototype) {
		return ruby_base_l97_d10_new(prototype, choice_nil_value(), parent)
	}
	return prototype
}

fn choice_assign_value(mut value ruby.Value, assigned ruby.Value) ruby.Value {
	if 'base_object_address' in value.attributes {
		mut base := base_object_from_value(value)
		base.snapshot_value = assigned
		base.assigned_value = assigned
		base.has_assignment = true
		base.clear = false
		return base_object_value(base)
	}
	value = assigned
	return value
}

fn choice_snapshot(value ruby.Value) ruby.Value {
	if 'base_object_address' in value.attributes {
		return base_object_from_value(value).snapshot()
	}
	return value
}

fn (mut object ChoiceObject) current_choice() !ruby.Value {
	selection := choice_selection(object)!
	index := choice_entry_index(object, selection)
	if index < 0 {
		return error("selection '${selection.repr}' does not exist in :choices for BinData::Choice")
	}
	if !object.entries[index].has_instance {
		object.entries[index].instance = choice_instantiate(object.entries[index].prototype, choice_object_value(object))
		object.entries[index].has_instance = true
	}
	if object.copy_on_change {
		if object.has_last_selection && !values_equal(selection, object.last_selection) {
			previous_index := choice_entry_index(object, object.last_selection)
			if previous_index >= 0 && object.entries[previous_index].has_instance {
				previous := choice_snapshot(object.entries[previous_index].instance)
				object.entries[index].instance = choice_assign_value(mut object.entries[index].instance, previous)
			}
		}
		object.last_selection = selection
		object.has_last_selection = true
	}
	return object.entries[index].instance
}

fn choice_delegate(mut object ChoiceObject, method string, args []ruby.Value) ruby.Value {
	mut current := object.current_choice() or { panic(err) }
	return match method.trim_left(':') {
		'clear?' {
			ruby.bool_value(if 'base_object_address' in current.attributes {
				base_object_from_value(current).is_clear()
			} else {
				false
			})
		}
		'assign' {
			if args.len == 0 { panic('Choice#assign requires value') }
			selection := choice_selection(object) or { panic(err) }
			index := choice_entry_index(object, selection)
			object.entries[index].instance = choice_assign_value(mut current, args[0])
			args[0]
		}
		'snapshot' { choice_snapshot(current) }
		'do_num_bytes' {
			ruby.int_value((current.attributes['do_num_bytes'] or { current.as_string().len.str() }).i64())
		}
		'do_read', 'do_write' { current }
		else { panic('undefined method `${method}` for current choice') }
	}
}

fn choice_keyed_array(value ruby.Value) ruby.Value {
	mut result := []ruby.Value{}
	for index, item in value.as_array() or { panic(err) } {
		if item.type_name != 'NilClass' {
			result << ruby.array_value([ruby.int_value(index), item])
		}
	}
	return ruby.array_value(result)
}

// Ruby method `initialize_shared_instance` at line 69.
pub fn ruby_choice_l69_d1_initialize_shared_instance(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Choice#initialize_shared_instance requires receiver') }
	return args[0]
}

// Ruby method `initialize_instance` at line 74.
pub fn ruby_choice_l74_d2_initialize_instance(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Choice#initialize_instance requires receiver') }
	mut object := choice_object_from_value(args[0])
	object.entries = choice_entries(object.base.parameters['choices'] or { ruby.map_value({}) })
	object.has_last_selection = false
	return choice_nil_value()
}

// Ruby method `selection` at line 80.
pub fn ruby_choice_l80_d3_selection(args ...ruby.Value) ruby.Value {
	return choice_selection(choice_object_from_value(args[0])) or { panic(err) }
}

// Ruby method `respond_to?(symbol, include_all = false) # :nodoc:` at line 89.
pub fn ruby_choice_l89_d4_respond_to(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Choice#respond_to? requires symbol') }
	mut object := choice_object_from_value(args[0])
	current := object.current_choice() or { panic(err) }
	name := args[1].as_string().trim_left(':')
	return ruby.bool_value(name in ['clear?', 'assign', 'snapshot', 'do_read', 'do_write',
		'do_num_bytes'] || name in (current.attributes['method_names'] or { '' }).split(','))
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 93.
pub fn ruby_choice_l93_d5_method_missing(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Choice#method_missing requires symbol') }
	mut object := choice_object_from_value(args[0])
	return choice_delegate(mut object, args[1].as_string(), args[2..])
}

// Ruby method `#{m}(*args)` at line 99.
pub fn ruby_choice_l99_d6_m(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Choice delegated method requires method name') }
	mut object := choice_object_from_value(args[0])
	return choice_delegate(mut object, args[1].as_string(), args[2..])
}

// Ruby method `current_choice` at line 108.
pub fn ruby_choice_l108_d7_current_choice(args ...ruby.Value) ruby.Value {
	mut object := choice_object_from_value(args[0])
	return object.current_choice() or { panic(err) }
}

// Ruby method `instantiate_choice(selection)` at line 113.
pub fn ruby_choice_l113_d8_instantiate_choice(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('instantiate_choice requires selection') }
	object := choice_object_from_value(args[0])
	index := choice_entry_index(object, args[1])
	if index < 0 { panic("selection '${args[1].repr}' does not exist in :choices for BinData::Choice") }
	return choice_instantiate(object.entries[index].prototype, args[0])
}

// Ruby method `sanitize_parameters!(obj_class, params) # :nodoc:` at line 125.
pub fn ruby_choice_l125_d9_sanitize_parameters(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ChoiceArgProcessor#sanitize_parameters! requires class and params') }
	object_class := args[args.len - 2]
	params := args.last()
	if params.type_name == 'BinData::SanitizedParameters' {
		mut parameters := sanitized_parameters_from_value(params)
		for key, value in object_class.map_data {
			parameters.values[key] = value
		}
		parameters.sanitize_choices('choices', fn (value ruby.Value) !ruby.Value {
			return value
		}) or { panic(err) }
		return sanitized_parameters_boundary_value(parameters)
	}
	mut values := params.as_map() or { panic(err) }
	for key, value in object_class.map_data {
		values[key] = value
	}
	choices := values['choices'] or { panic("parameter 'choices' must be specified") }
	values['choices'] = sanitized_choices_boundary_value(new_sanitized_choices(choices, map[string]ruby.Value{}) or { panic(err) })
	return ruby.map_value(values)
}

// Ruby method `choices_as_hash(choices)` at line 138.
pub fn ruby_choice_l138_d10_choices_as_hash(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('choices_as_hash requires choices') }
	value := args.last()
	return if value.type_name == 'Array' { choice_keyed_array(value) } else { value }
}

// Ruby method `key_array_by_index(array)` at line 146.
pub fn ruby_choice_l146_d11_key_array_by_index(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('key_array_by_index requires array') }
	return choice_keyed_array(args.last())
}

// Ruby method `ensure_valid_keys(choices)` at line 154.
pub fn ruby_choice_l154_d12_ensure_valid_keys(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ensure_valid_keys requires choices') }
	for entry in raw_choice_entries(args.last()) {
		if entry.key.type_name == 'NilClass' { panic(':choices hash may not have nil key') }
		if entry.key.type_name == 'Symbol' && entry.key.as_string().trim_left(':') != 'default' {
			panic(':choices hash may not have symbols for keys')
		}
	}
	return args.last()
}

// Ruby method `current_choice` at line 166.
pub fn ruby_choice_l166_d13_current_choice(args ...ruby.Value) ruby.Value {
	mut object := choice_object_from_value(args[0])
	return object.current_choice() or { panic(err) }
}

// Ruby method `copy_previous_value(obj)` at line 172.
pub fn ruby_choice_l172_d14_copy_previous_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('copy_previous_value requires object') }
	mut object := choice_object_from_value(args[0])
	selection := choice_selection(object) or { panic(err) }
	if object.has_last_selection && !values_equal(selection, object.last_selection) {
		previous_index := choice_entry_index(object, object.last_selection)
		if previous_index >= 0 && object.entries[previous_index].has_instance {
			mut target := args[1]
			return choice_assign_value(mut target, choice_snapshot(object.entries[previous_index].instance))
		}
	}
	object.last_selection = selection
	object.has_last_selection = true
	return args[1]
}

// Ruby method `get_previous_choice(selection)` at line 179.
pub fn ruby_choice_l179_d15_get_previous_choice(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('get_previous_choice requires selection') }
	object := choice_object_from_value(args[0])
	if object.has_last_selection && !values_equal(args[1], object.last_selection) {
		index := choice_entry_index(object, object.last_selection)
		if index >= 0 && object.entries[index].has_instance {
			return object.entries[index].instance
		}
	}
	return choice_nil_value()
}

// Ruby method `remember_current_selection(selection)` at line 185.
pub fn ruby_choice_l185_d16_remember_current_selection(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('remember_current_selection requires selection') }
	mut object := choice_object_from_value(args[0])
	object.last_selection = args[1]
	object.has_last_selection = true
	return args[1]
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
