module props

import brew_runtime

pub struct SerializableObject {
pub:
	class_name string
pub mut:
	values                 map[string]brew_runtime.Value
	extra_props            map[string]brew_runtime.Value
	missing_required_props []string
}

const serializable_rule_keys = ['dont_store', 'name', 'raise_on_nil_write']

pub fn new_serializable_object(class_name string) SerializableObject {
	return SerializableObject{
		class_name: class_name
		values: map[string]brew_runtime.Value{}
		extra_props: map[string]brew_runtime.Value{}
	}
}

pub fn serializable_valid_rule_key(super_valid bool, key string) bool {
	return super_valid || key.trim_left(':') in serializable_rule_keys
}

fn serializable_prop_name(definition DecoratorProp) string {
	return (definition.rules['serialized_form'] or {
		definition.rules['name'] or { brew_runtime.string_value(definition.name) }
	}).as_string()
}

pub fn serializable_forms(decorator PropsDecorator) map[string]string {
	mut forms := map[string]string{}
	for name, definition in decorator.props {
		forms[serializable_prop_name(definition)] = name
	}
	return forms
}

pub fn serializable_required_props(decorator PropsDecorator) []string {
	mut result := []string{}
	for name, definition in decorator.props {
		if required_prop(definition.rules) {
			result << name
		}
	}
	result.sort()
	return result
}

pub fn serialize_props(object SerializableObject, decorator PropsDecorator,
	strict bool) !map[string]brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for name, definition in decorator.props {
		if decorator_rule_bool(definition.rules, 'dont_store') {
			continue
		}
		accessor := (definition.rules['accessor_key'] or {
			brew_runtime.object_value('Symbol', '@${name}')
		}).as_string().trim_left('@')
		value := object.values[accessor] or { object.values[name] or { props_nil_value() } }
		if value.type_name == 'NilClass' {
			if strict && required_prop(definition.rules) && name !in object.missing_required_props {
				return error('${object.class_name}.${name} not set for non-optional prop')
			}
			continue
		}
		result[serializable_prop_name(definition)] = deep_clone(value)
	}
	for key, value in object.extra_props {
		result[key] = deep_clone(value)
	}
	return result
}

pub fn deserialize_props(mut object SerializableObject, decorator PropsDecorator,
	hash map[string]brew_runtime.Value, strict bool) !int {
	forms := serializable_forms(decorator)
	mut matched := 0
	for serialized_form, prop in forms {
		definition := decorator.props[prop]
		if decorator_rule_bool(definition.rules, 'dont_store') {
			continue
		}
		if serialized_form in hash {
			value := hash[serialized_form]
			if value.type_name == 'NilClass' && decorator_rule_bool(definition.rules, 'raise_on_nil_write') {
				if prop !in object.missing_required_props { object.missing_required_props << prop }
			}
			if value.type_name == 'NilClass' && !decorator_prop_nilable(definition.rules['type_object'] or {
				props_nil_value()}, definition.rules) {
				if default_value := definition.rules['default'] {
					object.values[prop] = deep_clone(default_value)
				} else if factory := definition.rules['factory'] {
					object.values[prop] = factory.map_data['result'] or { deep_clone(factory) }
				} else {
					return error('Tried to deserialize a required prop from a nil value: prop=${serialized_form} klass=${object.class_name}')
				}
			} else {
				object.values[prop] = deep_clone(value)
			}
			matched++
		}
	}
	mut extra := map[string]brew_runtime.Value{}
	for key, value in hash {
		if key !in forms {
			extra[key] = deep_clone(value)
		}
	}
	if extra.len > 0 {
		if strict {
			mut keys := extra.keys()
			keys.sort()
			return error('Unknown properties for ${object.class_name}: ${keys}')
		}
		object.extra_props = extra.clone()
	}
	return matched
}

pub fn stringify_serializable_keys(value brew_runtime.Value) brew_runtime.Value {
	if value.type_name == 'Hash' {
		mut result := map[string]brew_runtime.Value{}
		for key, child in value.map_data {
			result[key.trim_left(':')] = stringify_serializable_keys(child)
		}
		return brew_runtime.map_value(result)
	}
	if value.type_name == 'Array' {
		return brew_runtime.array_value(value.array_data.map(stringify_serializable_keys(it)))
	}
	return value
}

pub fn serializable_with(object SerializableObject, decorator PropsDecorator,
	changed map[string]brew_runtime.Value) !SerializableObject {
	mut serialized := serialize_props(object, decorator, true)!
	converted := stringify_serializable_keys(brew_runtime.map_value(changed)).map_data
	for key, value in converted {
		serialized[key] = value
	}
	mut result := new_serializable_object(object.class_name)
	deserialize_props(mut result, decorator, serialized, false)!
	if object.extra_props != result.extra_props {
		mut difference := map[string]brew_runtime.Value{}
		for key, value in result.extra_props {
			if key !in object.extra_props || object.extra_props[key].repr != value.repr {
				difference[key] = value
			}
		}
		return error('Unexpected arguments: input(${changed}), unexpected(${difference})')
	}
	return result
}

pub fn serializable_add_prop_definition(mut decorator PropsDecorator, prop string,
	input_rules map[string]brew_runtime.Value) ! {
	mut rules := input_rules.clone()
	serialized_form := (rules['name'] or { brew_runtime.string_value(prop) }).as_string()
	validate_decorator_prop_name(serialized_form)!
	rules['serialized_form'] = brew_runtime.string_value(serialized_form)
	decorator_add_prop_definition(mut decorator, prop, rules)!
}

pub fn generate_props_serialize_source(decorator PropsDecorator) string {
	mut clauses := []string{}
	for name, definition in decorator.props {
		if decorator_rule_bool(definition.rules, 'dont_store') {
			continue
		}
		key := (definition.rules['accessor_key'] or { brew_runtime.object_value('Symbol', '@${name}') }).as_string()
		form := serializable_prop_name(definition)
		required := if required_prop(definition.rules) {
			'required_prop_missing_from_serialize(:${name}) if strict'
		} else {
			''
		}
		clauses << '  if ${key}.nil?\n    ${required}\n  else\n    h["${form}"] = ${key}\n  end'
	}
	return 'def __t_props_generated_serialize(strict)\n  h = {}\n${clauses.join('\n\n')}\n  h\nend\n'
}

pub fn generate_props_deserialize_source(decorator PropsDecorator) string {
	mut clauses := []string{}
	for name, definition in decorator.props {
		if decorator_rule_bool(definition.rules, 'dont_store') {
			continue
		}
		key := (definition.rules['accessor_key'] or { brew_runtime.object_value('Symbol', '@${name}') }).as_string()
		form := serializable_prop_name(definition)
		clauses << '  val = hash["${form}"]\n  ${key} = if val.nil?\n    found -= 1 unless hash.key?("${form}".freeze)\n    nil\n  else\n    val\n  end'
	}
	return 'def __t_props_generated_deserialize(hash)\n  found = ${clauses.len}\n${clauses.join('\n\n')}\n  found\nend\n'
}

pub fn generated_source_context(class_name string, generated_method string, message string,
	source string, line_num int) ?string {
	lines := source.split('\n')
	if line_num <= 0 || line_num > lines.len {
		return none
	}
	mut previous_blank := 0
	for i in 0 .. line_num {
		if lines[i].len == 0 {
			previous_blank = i
		}
	}
	mut next_blank := lines.len
	for i in line_num .. lines.len {
		if lines[i].len == 0 {
			next_blank = i
			break
		}
	}
	context := lines[previous_blank + 1..next_blank].map('  ${it}').join('\n')
	return 'Error in ${class_name}#${generated_method}: ${message}\nat line ${line_num - previous_blank - 1} in:\n${context}\n'
}

pub fn serializable_pretty_extra(object SerializableObject, single_line bool) string {
	if !single_line || object.extra_props.len == 0 {
		return ''
	}
	mut keys := object.extra_props.keys()
	keys.sort()
	mut pairs := []string{}
	for key in keys {
		pairs << '${key}=${object.extra_props[key].repr}'
	}
	return '@_extra_props=<${pairs.join(' ')}>'
}

fn serializable_object_value(object SerializableObject) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: object.class_name
		repr: '<${object.class_name}>'
		map_data: {
			'_values':                                  brew_runtime.map_value(object.values)
			'_extra_props':                             brew_runtime.map_value(object.extra_props)
			'_required_props_missing_from_deserialize': brew_runtime.string_array_value(object.missing_required_props)
		}
		attributes: {
			'class_name': object.class_name
		}
	}
}

fn serializable_object_from_value(value brew_runtime.Value) SerializableObject {
	values := value.map_data['_values'] or { brew_runtime.map_value(value.map_data) }
	extra := value.map_data['_extra_props'] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }
	missing := value.map_data['_required_props_missing_from_deserialize'] or { brew_runtime.string_array_value([]string{}) }
	return SerializableObject{
		class_name: value.attribute('class_name') or { value.type_name }
		values: values.map_data.clone()
		extra_props: extra.map_data.clone()
		missing_required_props: missing.string_array_data.clone()
	}
}

fn serializable_decorator_arg(args []brew_runtime.Value, index int) PropsDecorator {
	if index < args.len {
		return decorator_from_value(args[index])
	}
	return new_props_decorator('Object', []string{})
}

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/serializable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `serialize(strict=true)` at line 18.
pub fn ruby_serializable_l18_d1_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('serialize requires object and decorator') }
	strict := if args.len > 2 { args[2].as_bool() or { panic(err) } } else { true }
	return brew_runtime.map_value(serialize_props(serializable_object_from_value(args[0]), decorator_from_value(args[1]), strict) or { panic(err) })
}

// Ruby method `__t_props_generated_serialize(strict)` at line 42.
pub fn ruby_serializable_l42_d2_t_props_generated_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value(map[string]brew_runtime.Value{})
	}
	if args.len < 2 {
		return brew_runtime.map_value(map[string]brew_runtime.Value{})
	}
	strict := if args.len > 2 { args[2].as_bool() or { panic(err) } } else { true }
	return brew_runtime.map_value(serialize_props(serializable_object_from_value(args[0]), decorator_from_value(args[1]), strict) or { panic(err) })
}

// Ruby method `deserialize(hash, strict=false)` at line 59.
pub fn ruby_serializable_l59_d3_deserialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('deserialize requires object, decorator, and hash') }
	mut object := serializable_object_from_value(args[0])
	strict := if args.len > 3 { args[3].as_bool() or { panic(err) } } else { false }
	deserialize_props(mut object, decorator_from_value(args[1]), args[2].as_map() or { panic(err) }, strict) or { panic(err) }
	return serializable_object_value(object)
}

// Ruby method `__t_props_generated_deserialize(hash)` at line 95.
pub fn ruby_serializable_l95_d4_t_props_generated_deserialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.int_value(0)
	}
	mut object := serializable_object_from_value(args[0])
	return brew_runtime.int_value(deserialize_props(mut object, decorator_from_value(args[1]), args[2].as_map() or { panic(err) }, false) or { panic(err) })
}

// Ruby method `with(changed_props)` at line 103.
pub fn ruby_serializable_l103_d5_with(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('with requires object, decorator, and changes') }
	return serializable_object_value(serializable_with(serializable_object_from_value(args[0]), decorator_from_value(args[1]), args[2].as_map() or { panic(err) }) or { panic(err) })
}

// Ruby method `recursive_stringify_keys(obj)` at line 107.
pub fn ruby_serializable_l107_d6_recursive_stringify_keys(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('recursive_stringify_keys requires object') }
	return stringify_serializable_keys(args[args.len - 1])
}

// Ruby method `with_existing_hash(changed_props, existing_hash:)` at line 121.
pub fn ruby_serializable_l121_d7_with_existing_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('with_existing_hash requires object, decorator, changes, and existing hash')
	}
	mut object := serializable_object_from_value(args[0])
	deserialize_props(mut object, decorator_from_value(args[1]), args[3].as_map() or { panic(err) }, false) or { panic(err) }
	return serializable_object_value(serializable_with(object, decorator_from_value(args[1]), args[2].as_map() or { panic(err) }) or { panic(err) })
}

// Ruby method `required_prop_missing_from_serialize(prop)` at line 139.
pub fn ruby_serializable_l139_d8_required_prop_missing_from_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('required_prop_missing_from_serialize requires object and prop') }
	object := serializable_object_from_value(args[0])
	prop := decorator_rule_name(args[1])
	if prop in object.missing_required_props {
		return props_nil_value()
	}
	panic('${object.class_name}.${prop} not set for non-optional prop')
}

// Ruby method `required_prop_missing_from_deserialize(prop)` at line 154.
pub fn ruby_serializable_l154_d9_required_prop_missing_from_deserialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('required_prop_missing_from_deserialize requires object and prop') }
	mut object := serializable_object_from_value(args[0])
	prop := decorator_rule_name(args[1])
	if prop !in object.missing_required_props { object.missing_required_props << prop }
	return serializable_object_value(object)
}

// Ruby method `valid_rule_key?(key)` at line 179.
pub fn ruby_serializable_l179_d10_valid_rule_key(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('valid_rule_key? requires key') }
	super_valid := if args.len > 1 {
		args[args.len - 2].type_name == 'Bool' && args[args.len - 2].bool_data
	} else {
		false
	}
	return brew_runtime.bool_value(serializable_valid_rule_key(super_valid, decorator_rule_name(args[args.len - 1])))
}

// Ruby method `required_props` at line 183.
pub fn ruby_serializable_l183_d11_required_props(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('required_props requires decorator') }
	return brew_runtime.string_array_value(serializable_required_props(decorator_from_value(args[0])))
}

// Ruby method `prop_dont_store?(prop)` at line 187.
pub fn ruby_serializable_l187_d12_prop_dont_store(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('prop_dont_store? requires decorator and prop') }
	rules := decorator_prop_rules(decorator_from_value(args[0]), decorator_rule_name(args[1])) or { panic(err) }
	return brew_runtime.bool_value(decorator_rule_bool(rules, 'dont_store'))
}

// Ruby method `prop_by_serialized_forms` at line 190.
pub fn ruby_serializable_l190_d13_prop_by_serialized_forms(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('prop_by_serialized_forms requires decorator') }
	mut result := map[string]brew_runtime.Value{}
	for form, prop in serializable_forms(decorator_from_value(args[0])) {
		result[form] = brew_runtime.object_value('Symbol', ':${prop}')
	}
	return brew_runtime.map_value(result)
}

// Ruby method `from_hash(hash, strict=false)` at line 194.
pub fn ruby_serializable_l194_d14_from_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('from_hash requires decorator and hash') }
	decorator := decorator_from_value(args[0])
	mut object := new_serializable_object(decorator.class_name)
	strict := if args.len > 2 { args[2].as_bool() or { panic(err) } } else { false }
	deserialize_props(mut object, decorator, args[1].as_map() or { panic(err) }, strict) or { panic(err) }
	return serializable_object_value(object)
}

// Ruby method `prop_serialized_form(prop)` at line 203.
pub fn ruby_serializable_l203_d15_prop_serialized_form(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('prop_serialized_form requires decorator and prop') }
	definition := decorator_from_value(args[0]).props[decorator_rule_name(args[1])] or { panic('No such prop') }
	return brew_runtime.string_value(serializable_prop_name(definition))
}

// Ruby method `serialized_form_prop(serialized_form)` at line 207.
pub fn ruby_serializable_l207_d16_serialized_form_prop(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('serialized_form_prop requires decorator and form') }
	prop := serializable_forms(decorator_from_value(args[0]))[args[1].as_string()] or { panic('No such serialized form') }
	return brew_runtime.object_value('Symbol', ':${prop}')
}

// Ruby method `add_prop_definition(prop, rules)` at line 211.
pub fn ruby_serializable_l211_d17_add_prop_definition(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('add_prop_definition requires decorator, prop, and rules') }
	mut decorator := decorator_from_value(args[0])
	serializable_add_prop_definition(mut decorator, decorator_rule_name(args[1]), args[2].as_map() or { panic(err) }) or { panic(err) }
	return decorator_value(decorator)
}

// Ruby method `generate_serialize_source` at line 221.
pub fn ruby_serializable_l221_d18_generate_serialize_source(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('generate_serialize_source requires decorator') }
	return brew_runtime.string_value(generate_props_serialize_source(decorator_from_value(args[0])))
}

// Ruby method `generate_deserialize_source` at line 225.
pub fn ruby_serializable_l225_d19_generate_deserialize_source(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('generate_deserialize_source requires decorator') }
	return brew_runtime.string_value(generate_props_deserialize_source(decorator_from_value(args[0])))
}

// Ruby method `message_with_generated_source_context(error, generated_method, generate_source_method)` at line 232.
pub fn ruby_serializable_l232_d20_message_with_generated_source_context(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 5 {
		return props_nil_value()
	}
	line := args[4].as_int() or { return props_nil_value() }
	context := generated_source_context(decorator_from_value(args[0]).class_name, args[2].as_string().trim_left(':'), args[1].as_string(), args[3].as_string(), int(line)) or { return props_nil_value() }
	return brew_runtime.string_value(context)
}

// Ruby method `raise_nil_deserialize_error(hkey)` at line 271.
pub fn ruby_serializable_l271_d21_raise_nil_deserialize_error(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('raise_nil_deserialize_error requires decorator and key') }
	panic('Tried to deserialize a required prop from a nil value. You should provide a default: or factory: for this prop. prop=${args[1].as_string()} klass=${decorator_from_value(args[0]).class_name}')
}

// Ruby method `prop_validate_definition!(name, cls, rules, type)` at line 277.
pub fn ruby_serializable_l277_d22_prop_validate_definition(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 { panic('prop_validate_definition! requires decorator, name, class, and rules') }
	rules := args[3].as_map() or { panic(err) }
	if rule_name := rules['name'] {
		if rule_name.type_name != 'String' { panic('Invalid name') }
		validate_decorator_prop_name(rule_name.as_string()) or { panic(err) }
	}
	if value := rules['raise_on_nil_write'] {
		if value.type_name != 'Bool' || !value.bool_data { panic('raise_on_nil_write must be true') }
	}
	return props_nil_value()
}

// Ruby method `get_id(instance)` at line 295.
pub fn ruby_serializable_l295_d23_get_id(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('get_id requires decorator and instance') }
	forms := serializable_forms(decorator_from_value(args[0]))
	prop := forms['_id'] or { return props_nil_value() }
	return serializable_object_from_value(args[1]).values[prop] or { props_nil_value() }
}

// Ruby method `extra_props(instance)` at line 307.
pub fn ruby_serializable_l307_d24_extra_props(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('extra_props requires instance') }
	return brew_runtime.map_value(serializable_object_from_value(args[args.len - 1]).extra_props)
}

// Ruby method `pretty_print_extra(instance, pp)` at line 312.
pub fn ruby_serializable_l312_d25_pretty_print_extra(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('pretty_print_extra requires instance') }
	single := if args.len > 1 {
		args[args.len - 1].attribute('single_line') or { 'false' } == 'true'
	} else {
		true
	}
	return brew_runtime.string_value(serializable_pretty_extra(serializable_object_from_value(args[args.len - if args.len > 1 {
		2
	} else {
		1
	}]), single))
}

// Ruby method `prop_by_serialized_forms` at line 335.
pub fn ruby_serializable_l335_d26_prop_by_serialized_forms(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_serializable_l190_d13_prop_by_serialized_forms(...args)
}

// Ruby method `from_hash(hash, strict=false)` at line 342.
pub fn ruby_serializable_l342_d27_from_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_serializable_l194_d14_from_hash(...args)
}

// Ruby method `from_hash!(hash)` at line 348.
pub fn ruby_serializable_l348_d28_from_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('from_hash! requires decorator and hash') }
	return ruby_serializable_l194_d14_from_hash(args[0], args[1], brew_runtime.bool_value(true))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props::Serializable
// 5:   include T::Props::Plugin
// 6:   # Required because we have special handling for `optional: false`
// 7:   include T::Props::Optional
// 8:   # Required because we have special handling for extra_props
// 9:   include T::Props::PrettyPrintable
// 10:
// 11:   # Serializes this object to a hash, suitable for conversion to
// 12:   # JSON/BSON.
// 13:   #
// 14:   # @param strict [T::Boolean] (true) If false, do not raise an
// 15:   #   exception if this object has mandatory props with missing
// 16:   #   values.
// 17:   # @return [Hash] A serialization of this object.
// 18:   def serialize(strict=true)
// 19:     begin
// 20:       h = __t_props_generated_serialize(strict)
// 21:     rescue => e
// 22:       msg = self.class.decorator.message_with_generated_source_context(
// 23:         e,
// 24:         :__t_props_generated_serialize,
// 25:         :generate_serialize_source
// 26:       )
// 27:       if msg
// 28:         begin
// 29:           raise e.class.new(msg)
// 30:         rescue ArgumentError
// 31:           raise TypeError.new(msg)
// 32:         end
// 33:       else
// 34:         raise
// 35:       end
// 36:     end
// 37:
// 38:     h.merge!(@_extra_props) if defined?(@_extra_props)
// 39:     h
// 40:   end
// 41:
// 42:   private def __t_props_generated_serialize(strict)
// 43:     # No-op; will be overridden if there are any props.
// 44:     #
// 45:     # To see the definition for class `Foo`, run `Foo.decorator.send(:generate_serialize_source)`
// 46:     {}
// 47:   end
// 48:
// 49:   # Populates the property values on this object with the values
// 50:   # from a hash. In general, prefer to use {.from_hash} to construct
// 51:   # a new instance, instead of loading into an existing instance.
// 52:   #
// 53:   # @param hash [Hash<String, Object>] The hash to take property
// 54:   #  values from.
// 55:   # @param strict [T::Boolean] (false) If true, raise an exception if
// 56:   #  the hash contains keys that do not correspond to any known
// 57:   #  props on this instance.
// 58:   # @return [void]
// 59:   def deserialize(hash, strict=false)
// 60:     begin
// 61:       hash_keys_matching_props = __t_props_generated_deserialize(hash)
// 62:     rescue => e
// 63:       msg = self.class.decorator.message_with_generated_source_context(
// 64:         e,
// 65:         :__t_props_generated_deserialize,
// 66:         :generate_deserialize_source
// 67:       )
// 68:       if msg
// 69:         begin
// 70:           raise e.class.new(msg)
// 71:         rescue ArgumentError
// 72:           raise TypeError.new(msg)
// 73:         end
// 74:       else
// 75:         raise
// 76:       end
// 77:     end
// 78:
// 79:     if hash.size > hash_keys_matching_props
// 80:       serialized_forms = self.class.decorator.prop_by_serialized_forms
// 81:       extra = hash.reject { |k, _| serialized_forms.key?(k) }
// 82:
// 83:       # `extra` could still be empty here if the input matches a `dont_store` prop;
// 84:       # historically, we just ignore those
// 85:       if !extra.empty?
// 86:         if strict
// 87:           raise "Unknown properties for #{self.class.name}: #{extra.keys.inspect}"
// 88:         else
// 89:           @_extra_props = extra
// 90:         end
// 91:       end
// 92:     end
// 93:   end
// 94:
// 95:   private def __t_props_generated_deserialize(hash)
// 96:     # No-op; will be overridden if there are any props.
// 97:     #
// 98:     # To see the definition for class `Foo`, run `Foo.decorator.send(:generate_deserialize_source)`
// 99:     0
// 100:   end
// 101:
// 102:   # with() will clone the old object to the new object and merge the specified props to the new object.
// 103:   def with(changed_props)
// 104:     with_existing_hash(changed_props, existing_hash: self.serialize)
// 105:   end
// 106:
// 107:   private def recursive_stringify_keys(obj)
// 108:     if obj.is_a?(Hash)
// 109:       new_obj = obj.class.new
// 110:       obj.each do |k, v|
// 111:         new_obj[k.to_s] = recursive_stringify_keys(v)
// 112:       end
// 113:     elsif obj.is_a?(Array)
// 114:       new_obj = obj.map { |v| recursive_stringify_keys(v) }
// 115:     else
// 116:       new_obj = obj
// 117:     end
// 118:     new_obj
// 119:   end
// 120:
// 121:   private def with_existing_hash(changed_props, existing_hash:)
// 122:     serialized = existing_hash
// 123:     new_val = self.class.from_hash(serialized.merge(recursive_stringify_keys(changed_props)))
// 124:     old_extra = self.instance_variable_get(:@_extra_props)
// 125:     new_extra = new_val.instance_variable_get(:@_extra_props)
// 126:     if old_extra != new_extra
// 127:       difference =
// 128:         if old_extra
// 129:           new_extra.reject { |k, v| old_extra[k] == v }
// 130:         else
// 131:           new_extra
// 132:         end
// 133:       raise ArgumentError.new("Unexpected arguments: input(#{changed_props}), unexpected(#{difference})")
// 134:     end
// 135:     new_val
// 136:   end
// 137:
// 138:   # Asserts if this property is missing during strict serialize
// 139:   private def required_prop_missing_from_serialize(prop)
// 140:     if @_required_props_missing_from_deserialize&.include?(prop)
// 141:       # If the prop was already missing during deserialization, that means the application
// 142:       # code already had to deal with a nil value, which means we wouldn't be accomplishing
// 143:       # much by raising here (other than causing an unnecessary breakage).
// 144:       T::Configuration.log_info_handler(
// 145:         "chalk-odm: missing required property in serialize",
// 146:         prop: prop, class: self.class.name, id: self.class.decorator.get_id(self)
// 147:       )
// 148:     else
// 149:       raise TypeError.new("#{self.class.name}.#{prop} not set for non-optional prop")
// 150:     end
// 151:   end
// 152:
// 153:   # Marks this property as missing during deserialize
// 154:   private def required_prop_missing_from_deserialize(prop)
// 155:     @_required_props_missing_from_deserialize ||= Set[]
// 156:     @_required_props_missing_from_deserialize << prop
// 157:     nil
// 158:   end
// 159: end
// 160:
// 161: ##############################################
// 162:
// 163: # NB: This must stay in the same file where T::Props::Serializable is defined due to
// 164: # T::Props::Decorator#apply_plugin; see https://git.corp.stripe.com/stripe-internal/pay-server/blob/fc7f15593b49875f2d0499ffecfd19798bac05b3/chalk/odm/lib/chalk-odm/document_decorator.rb#L716-L717
// 165: module T::Props::Serializable::DecoratorMethods
// 166:   include T::Props::HasLazilySpecializedMethods::DecoratorMethods
// 167:
// 168:   # Heads up!
// 169:   #
// 170:   # There are already too many ad-hoc options on the prop DSL.
// 171:   #
// 172:   # We have already done a lot of work to remove unnecessary and confusing
// 173:   # options. If you're considering adding a new rule key, please come chat with
// 174:   # the Sorbet team first, as we'd really like to learn more about how to best
// 175:   # solve the problem you're encountering.
// 176:   VALID_RULE_KEYS = {dont_store: true, name: true, raise_on_nil_write: true}.freeze
// 177:   private_constant :VALID_RULE_KEYS
// 178:
// 179:   def valid_rule_key?(key)
// 180:     super || VALID_RULE_KEYS[key]
// 181:   end
// 182:
// 183:   def required_props
// 184:     @class.props.select { |_, v| T::Props::Utils.required_prop?(v) }.keys
// 185:   end
// 186:
// 187:   def prop_dont_store?(prop)
// 188:     prop_rules(prop)[:dont_store]
// 189:   end
// 190:   def prop_by_serialized_forms
// 191:     @class.prop_by_serialized_forms
// 192:   end
// 193:
// 194:   def from_hash(hash, strict=false)
// 195:     raise ArgumentError.new("#{hash.inspect} provided to from_hash") if !(hash && hash.is_a?(Hash))
// 196:
// 197:     i = @class.allocate
// 198:     i.deserialize(hash, strict)
// 199:
// 200:     i
// 201:   end
// 202:
// 203:   def prop_serialized_form(prop)
// 204:     prop_rules(prop)[:serialized_form]
// 205:   end
// 206:
// 207:   def serialized_form_prop(serialized_form)
// 208:     prop_by_serialized_forms[serialized_form.to_s] || raise("No such serialized form: #{serialized_form.inspect}")
// 209:   end
// 210:
// 211:   def add_prop_definition(prop, rules)
// 212:     serialized_form = rules.fetch(:name, prop.to_s)
// 213:     rules[:serialized_form] = serialized_form
// 214:     res = super
// 215:     prop_by_serialized_forms[serialized_form] = prop
// 216:     enqueue_lazy_method_definition!(:__t_props_generated_serialize) { generate_serialize_source }
// 217:     enqueue_lazy_method_definition!(:__t_props_generated_deserialize) { generate_deserialize_source }
// 218:     res
// 219:   end
// 220:
// 221:   private def generate_serialize_source
// 222:     T::Props::Private::SerializerGenerator.generate(props)
// 223:   end
// 224:
// 225:   private def generate_deserialize_source
// 226:     T::Props::Private::DeserializerGenerator.generate(
// 227:       props,
// 228:       props_with_defaults || {},
// 229:     )
// 230:   end
// 231:
// 232:   def message_with_generated_source_context(error, generated_method, generate_source_method)
// 233:     generated_method = generated_method.to_s
// 234:     if error.backtrace_locations
// 235:       line_loc = error.backtrace_locations.find { |l| l.base_label == generated_method }
// 236:       return unless line_loc
// 237:
// 238:       line_num = line_loc.lineno
// 239:     else
// 240:       label = if RUBY_VERSION >= "3.4"
// 241:         # in 'ClassName#__t_props_generated_serialize'"
// 242:         "##{generated_method}'"
// 243:       else
// 244:         # in `__t_props_generated_serialize'"
// 245:         "in `#{generated_method}'"
// 246:       end
// 247:       line_label = error.backtrace.find { |l| l.end_with?(label) }
// 248:       return unless line_label
// 249:
// 250:       line_num = if line_label.start_with?("(eval)")
// 251:         # (eval):13:in ...
// 252:         line_label.split(':')[1]&.to_i
// 253:       else
// 254:         # (eval at /Users/jez/stripe/sorbet/gems/sorbet-runtime/lib/types/props/has_lazily_specialized_methods.rb:65):13:in ...
// 255:         line_label.split(':')[2]&.to_i
// 256:       end
// 257:     end
// 258:     return unless line_num
// 259:
// 260:     source_lines = self.send(generate_source_method).split("\n")
// 261:     previous_blank = source_lines[0...line_num].rindex(&:empty?) || 0
// 262:     next_blank = line_num + (source_lines[line_num..-1]&.find_index(&:empty?) || 0)
// 263:     context = "  #{source_lines[(previous_blank + 1)...next_blank].join("\n  ")}"
// 264:     <<~MSG
// 265:       Error in #{decorated_class.name}##{generated_method}: #{error.message}
// 266:       at line #{line_num - previous_blank - 1} in:
// 267:       #{context}
// 268:     MSG
// 269:   end
// 270:
// 271:   def raise_nil_deserialize_error(hkey)
// 272:     raise "Tried to deserialize a required prop from a nil value. " \
// 273:       "You should provide a `default: or factory:` for this prop. " \
// 274:       "prop=#{hkey} klass=#{decorated_class.name}"
// 275:   end
// 276:
// 277:   def prop_validate_definition!(name, cls, rules, type)
// 278:     result = super
// 279:
// 280:     if (rules_name = rules[:name])
// 281:       unless rules_name.is_a?(String)
// 282:         raise ArgumentError.new("Invalid name in prop #{@class.name}.#{name}: #{rules_name.inspect}")
// 283:       end
// 284:
// 285:       validate_prop_name(rules_name)
// 286:     end
// 287:
// 288:     if !rules[:raise_on_nil_write].nil? && rules[:raise_on_nil_write] != true
// 289:       raise ArgumentError.new("The value of `raise_on_nil_write` if specified must be `true` (given: #{rules[:raise_on_nil_write]}).")
// 290:     end
// 291:
// 292:     result
// 293:   end
// 294:
// 295:   def get_id(instance)
// 296:     prop = prop_by_serialized_forms['_id']
// 297:     if prop
// 298:       get(instance, prop)
// 299:     else
// 300:       nil
// 301:     end
// 302:   end
// 303:
// 304:   EMPTY_EXTRA_PROPS = {}.freeze
// 305:   private_constant :EMPTY_EXTRA_PROPS
// 306:
// 307:   def extra_props(instance)
// 308:     instance.instance_variable_get(:@_extra_props) || EMPTY_EXTRA_PROPS
// 309:   end
// 310:
// 311:   # adds to the default result of T::Props::PrettyPrintable
// 312:   def pretty_print_extra(instance, pp)
// 313:     # This is to maintain backwards compatibility with Stripe's codebase, where only the single line (through `inspect`)
// 314:     # version is expected to add anything extra
// 315:     return if !pp.is_a?(PP::SingleLine)
// 316:     if (extra_props = extra_props(instance)) && !extra_props.empty?
// 317:       pp.breakable
// 318:       pp.text("@_extra_props=")
// 319:       pp.group(1, "<", ">") do
// 320:         extra_props.each_with_index do |(prop, value), i|
// 321:           pp.breakable unless i.zero?
// 322:           pp.text("#{prop}=")
// 323:           value.pretty_print(pp)
// 324:         end
// 325:       end
// 326:     end
// 327:   end
// 328: end
// 329:
// 330: ##############################################
// 331:
// 332: # NB: This must stay in the same file where T::Props::Serializable is defined due to
// 333: # T::Props::Decorator#apply_plugin; see https://git.corp.stripe.com/stripe-internal/pay-server/blob/fc7f15593b49875f2d0499ffecfd19798bac05b3/chalk/odm/lib/chalk-odm/document_decorator.rb#L716-L717
// 334: module T::Props::Serializable::ClassMethods
// 335:   def prop_by_serialized_forms
// 336:     @prop_by_serialized_forms ||= {}
// 337:   end
// 338:
// 339:   # Allocate a new instance and call {#deserialize} to load a new
// 340:   # object from a hash.
// 341:   # @return [Serializable]
// 342:   def from_hash(hash, strict=false)
// 343:     self.decorator.from_hash(hash, strict)
// 344:   end
// 345:
// 346:   # Equivalent to {.from_hash} with `strict` set to true.
// 347:   # @return [Serializable]
// 348:   def from_hash!(hash)
// 349:     self.decorator.from_hash(hash, true)
// 350:   end
// 351: end
