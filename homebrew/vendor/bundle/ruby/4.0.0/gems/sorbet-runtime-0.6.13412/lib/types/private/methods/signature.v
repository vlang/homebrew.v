module methods

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/methods/signature.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct RuntimeMethodParameter {
pub:
	kind string
	name string
}

pub struct RuntimeArgumentValueType {
pub:
	name       string
	value      ruby.Value
	type_value ruby.Value
}

@[heap]
pub struct RuntimeMethodSignature {
pub:
	method                      ruby.Value
	arg_types                   []ValidationTypePair
	kwarg_types                 map[string]ruby.Value
	block_type                  ruby.Value
	block_name                  string
	rest_type                   ruby.Value
	rest_name                   string
	keyrest_type                ruby.Value
	keyrest_name                string
	bind                        ruby.Value
	effective_return_type       ruby.Value
	return_type                 ruby.Value
	mode                        string
	req_arg_count               int
	req_kwarg_names             []string
	check_level                 string
	parameters                  []RuntimeMethodParameter
	on_failure                  ruby.Value
	override_allow_incompatible string
	defined_raw                 bool
pub mut:
	method_name string
	types_built bool
}

fn signature_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn signature_parameters_from_method(method ruby.Value) []RuntimeMethodParameter {
	if raw_parameters := method.map_data['parameters'] {
		mut result := []RuntimeMethodParameter{}
		for parameter in raw_parameters.as_array() or { []ruby.Value{} } {
			result << RuntimeMethodParameter{
				kind: parameter.attribute('kind') or { 'req' }.trim_string_left(':')
				name: parameter.attribute('name') or { '' }.trim_string_left(':')
			}
		}
		return result
	}
	kinds := method.attribute('parameter_kinds') or { '' }.split(',').filter(it != '')
	names := method.attribute('parameter_names') or { '' }.split(',')
	mut result := []RuntimeMethodParameter{}
	for index, kind in kinds {
		result << RuntimeMethodParameter{
			kind: kind.trim_space().trim_string_left(':')
			name: if index < names.len && names[index].trim_space() != '' {
				names[index].trim_space().trim_string_left(':')} else {
				''}
		}
	}
	return result
}

fn signature_parameter_values(parameters []RuntimeMethodParameter) ruby.Value {
	return ruby.array_value(parameters.map(ruby.structured_value('Array', '[${it.kind}, ${it.name}]', {
		'kind': it.kind
		'name': it.name
	})))
}

fn runtime_signature_arg_map(signature &RuntimeMethodSignature) map[string]ruby.Value {
	mut result := map[string]ruby.Value{}
	for pair in signature.arg_types {
		result[pair.name] = pair.type_value
	}
	return result
}

fn runtime_signature_value(signature &RuntimeMethodSignature) ruby.Value {
	return ruby.Value{
		type_name: 'T::Private::Methods::Signature'
		repr: signature.method_name
		map_data: {
			'method':                signature.method
			'arg_types':             ruby.map_value(runtime_signature_arg_map(signature))
			'kwarg_types':           ruby.map_value(signature.kwarg_types)
			'block_type':            signature.block_type
			'rest_type':             signature.rest_type
			'keyrest_type':          signature.keyrest_type
			'bind':                  signature.bind
			'effective_return_type': signature.effective_return_type
			'return_type':           signature.return_type
			'parameters':            signature_parameter_values(signature.parameters)
			'on_failure':            signature.on_failure
			'owner':                 signature.method.map_data['owner'] or { ruby.object_value('Module', signature.method.attribute('owner') or { '<unknown>' }) }
		}
		string_array_data: signature.req_kwarg_names.clone()
		attributes: {
			'runtime_signature_address':   u64(voidptr(signature)).str()
			'method_name':                 signature.method_name
			'block_name':                  signature.block_name
			'rest_name':                   signature.rest_name
			'keyrest_name':                signature.keyrest_name
			'mode':                        signature.mode
			'req_arg_count':               signature.req_arg_count.str()
			'check_level':                 signature.check_level
			'override_allow_incompatible': signature.override_allow_incompatible
			'defined_raw':                 signature.defined_raw.str()
			'source_location':             signature.method.attribute('source_location') or { '<unknown>:0' }
		}
	}
}

fn runtime_signature_from_value(value ruby.Value) &RuntimeMethodSignature {
	address := value.attribute('runtime_signature_address') or { panic('invalid Signature receiver') }
	return unsafe { &RuntimeMethodSignature(voidptr(address.u64())) }
}

fn runtime_signature_from_args(args []ruby.Value) &RuntimeMethodSignature {
	if args.len == 0 {
		panic('Signature method requires a receiver')
	}
	return runtime_signature_from_value(args[0])
}

pub fn new_runtime_method_signature(method ruby.Value, method_name string,
	raw_arg_types map[string]ruby.Value, raw_return_type ruby.Value,
	bind ruby.Value, mode string, check_level string, on_failure ruby.Value,
	parameters []RuntimeMethodParameter, override_allow_incompatible string,
	defined_raw bool) !&RuntimeMethodSignature {
	clean_check := if check_level == '' || check_level == 'nil' {
		'always'
	} else {
		check_level.trim_string_left(':')
	}
	mut effective_parameters := parameters.clone()
	if method_name.ends_with('=') && parameters.len == 1 && parameters[0].kind == 'req' && parameters[0].name == '' && !(raw_arg_types.len == 1 && '' in raw_arg_types) {
		effective_parameters = [RuntimeMethodParameter{
			kind: 'req'
			name: method_name.trim_string_right('=')
		}]
	}
	parameter_names := effective_parameters.map(it.name)
	missing_names := parameter_names.filter(it !in raw_arg_types)
	if missing_names.len > 0 {
		return error('The declaration for `${method.as_string()}` is missing parameter(s): ${missing_names.join(', ')}')
	}
	extra_names := raw_arg_types.keys().filter(it !in parameter_names)
	if extra_names.len > 0 {
		return error('The declaration for `${method.as_string()}` has extra parameter(s): ${extra_names.join(', ')}')
	}
	if effective_parameters.len != raw_arg_types.len {
		return error('The declaration for `${method.as_string()}` has arguments with duplicate names')
	}
	mut arg_types := []ValidationTypePair{}
	mut kwarg_types := map[string]ruby.Value{}
	mut req_kwarg_names := []string{}
	mut req_arg_count := 0
	mut block_type := signature_nil()
	mut block_name := ''
	mut rest_type := signature_nil()
	mut rest_name := ''
	mut keyrest_type := signature_nil()
	mut keyrest_name := ''
	for index, parameter in effective_parameters {
		type_value := raw_arg_types[parameter.name]
		match parameter.kind {
			'req' {
				if arg_types.len > req_arg_count {
					return error('Required params after optional params are not supported in method declarations. Method: ${runtime_method_description(method, method_name, method.attribute('source_location') or { '' })}')
				}
				arg_types << ValidationTypePair{ name: parameter.name, type_value: type_value }
				req_arg_count++
			}
			'opt' {
				arg_types << ValidationTypePair{ name: parameter.name, type_value: type_value }
			}
			'key', 'keyreq' {
				kwarg_types[parameter.name] = type_value
				if parameter.kind == 'keyreq' { req_kwarg_names << parameter.name }
			}
			'block' {
				block_name = parameter.name
				block_type = type_value
			}
			'rest' {
				rest_name = parameter.name
				rest_type = type_value
			}
			'keyrest' {
				keyrest_name = parameter.name
				keyrest_type = type_value
			}
			else {
				return error('Unexpected param_kind: `${parameter.kind}`. Method: ${runtime_method_description(method, method_name, method.attribute('source_location') or { '' })}')
			}
		}
		if raw_arg_types.keys()[index] != parameter.name {
			return error('Parameter `${raw_arg_types.keys()[index]}` is declared out of order (declared as arg number ${index + 1}). Method: ${runtime_method_description(method, method_name, method.attribute('source_location') or { '' })}')
		}
	}
	effective_return := if clean_check == 'tests' && raw_return_type.type_name == 'T::Private::Types::Void' {
		ruby.object_value('T::Types::Anything', 'T.anything')
	} else {
		raw_return_type
	}
	return &RuntimeMethodSignature{
		method: method
		method_name: method_name
		arg_types: arg_types
		kwarg_types: kwarg_types
		block_type: block_type
		block_name: block_name
		rest_type: rest_type
		rest_name: rest_name
		keyrest_type: keyrest_type
		keyrest_name: keyrest_name
		bind: bind
		effective_return_type: effective_return
		return_type: raw_return_type
		mode: mode.trim_string_left(':')
		req_arg_count: req_arg_count
		req_kwarg_names: req_kwarg_names
		check_level: clean_check
		parameters: effective_parameters
		on_failure: on_failure
		override_allow_incompatible: override_allow_incompatible
		defined_raw: defined_raw
	}
}

pub fn new_untyped_runtime_method_signature(method ruby.Value, mode string,
	parameters []RuntimeMethodParameter) !&RuntimeMethodSignature {
	mut effective_parameters := parameters.clone()
	for index, parameter in effective_parameters {
		if parameter.name == '' {
			effective_parameters[index] = RuntimeMethodParameter{ ...parameter, name: 'arg${index}' }
		}
	}
	not_typed := ruby.object_value('T::Private::Types::NotTyped', 'T::Private::Types::NotTyped::INSTANCE')
	mut raw_arg_types := map[string]ruby.Value{}
	for parameter in effective_parameters {
		raw_arg_types[parameter.name] = not_typed
	}
	return new_runtime_method_signature(method, method.attribute('name') or { method.as_string() }, raw_arg_types, not_typed, signature_nil(), mode, 'never', signature_nil(), effective_parameters, 'false', false)
}

pub fn (signature &RuntimeMethodSignature) each_argument_value_type(arguments []ruby.Value) ![]RuntimeArgumentValueType {
	mut positional_length := arguments.len
	mut kwargs := map[string]ruby.Value{}
	if positional_length > signature.req_arg_count && (signature.kwarg_types.len > 0 || !validation_is_nil_type(signature.keyrest_type)) && arguments.len > 0 && arguments.last().type_name == 'Hash' {
		kwargs = arguments.last().as_map()!
		positional_length--
	}
	if validation_is_nil_type(signature.rest_type) && (positional_length < signature.req_arg_count || positional_length > signature.arg_types.len) {
		mut expected := signature.req_arg_count.str()
		if signature.arg_types.len != signature.req_arg_count {
			expected += '..${signature.arg_types.len}'
		}
		return error('wrong number of arguments (given ${positional_length}, expected ${expected})')
	}
	mut result := []RuntimeArgumentValueType{}
	mut index := 0
	for index < positional_length && index < signature.arg_types.len {
		pair := signature.arg_types[index]
		result << RuntimeArgumentValueType{ name: pair.name, value: arguments[index], type_value: pair.type_value }
		index++
	}
	if !validation_is_nil_type(signature.rest_type) {
		for index < positional_length {
			result << RuntimeArgumentValueType{ name: signature.rest_name, value: arguments[index], type_value: signature.rest_type }
			index++
		}
	}
	for name, value in kwargs {
		type_value := signature.kwarg_types[name] or { signature.keyrest_type }
		if !validation_is_nil_type(type_value) {
			result << RuntimeArgumentValueType{ name: name, value: value, type_value: type_value }
		}
	}
	return result
}

pub fn runtime_method_description(method ruby.Value, method_name string,
	source_location string) string {
	location := if source_location == '' || source_location == 'nil' {
		'<unknown location>'
	} else {
		source_location
	}
	owner := method.attribute('owner') or { method.map_data['owner'] or { ruby.object_value('Module', '<unknown>') }.as_string() }
	return '${owner}#${method_name} at ${location}'
}

fn runtime_argument_value(result RuntimeArgumentValueType) ruby.Value {
	return ruby.Value{
		type_name: 'T::Private::Methods::ArgumentValueType'
		repr: result.name
		map_data: {
			'value': result.value
			'type':  result.type_value
		}
		attributes: {
			'name': result.name
		}
	}
}

fn signature_config_from_args(args []ruby.Value) map[string]ruby.Value {
	if args.len == 1 && args[0].type_name == 'Hash' {
		return args[0].as_map() or { panic(err) }
	}
	keys := ['method', 'method_name', 'raw_arg_types', 'raw_return_type', 'bind', 'mode',
		'check_level', 'on_failure', 'parameters', 'override_allow_incompatible', 'defined_raw']
	mut result := map[string]ruby.Value{}
	for index, value in args {
		if index < keys.len {
			result[keys[index]] = value
		}
	}
	return result
}

fn runtime_signature_from_config(config map[string]ruby.Value) &RuntimeMethodSignature {
	method := config['method'] or { panic('Signature.initialize requires method') }
	raw_args := config['raw_arg_types'] or { ruby.map_value({}) }.as_map() or { panic(err) }
	parameters_value := config['parameters'] or { method.map_data['parameters'] or { signature_parameter_values(signature_parameters_from_method(method)) } }
	parameters := (parameters_value.as_array() or { []ruby.Value{} }).map(RuntimeMethodParameter{
		kind: it.attribute('kind') or { 'req' }.trim_string_left(':')
		name: it.attribute('name') or { '' }.trim_string_left(':')
	})
	return new_runtime_method_signature(method, config['method_name'] or { ruby.string_value(method.attribute('name') or { method.as_string() }) }.as_string().trim_string_left(':'), raw_args, config['raw_return_type'] or { signature_nil() }, config['bind'] or { signature_nil() }, config['mode'] or { ruby.string_value('standard') }.as_string(), config['check_level'] or { ruby.string_value('always') }.as_string(), config['on_failure'] or { signature_nil() }, parameters, config['override_allow_incompatible'] or { ruby.bool_value(false) }.as_string().trim_string_left(':'), config['defined_raw'] or { ruby.bool_value(false) }.as_bool() or { false }) or { panic(err) }
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d1_method(args ...ruby.Value) ruby.Value {
	return runtime_signature_from_args(args).method
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d2_method_name(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', ':${runtime_signature_from_args(args).method_name}')
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d3_arg_types(args ...ruby.Value) ruby.Value {
	return ruby.map_value(runtime_signature_arg_map(runtime_signature_from_args(args)))
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d4_kwarg_types(args ...ruby.Value) ruby.Value {
	return ruby.map_value(runtime_signature_from_args(args).kwarg_types)
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d5_block_type(args ...ruby.Value) ruby.Value {
	return runtime_signature_from_args(args).block_type
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d6_block_name(args ...ruby.Value) ruby.Value {
	name := runtime_signature_from_args(args).block_name
	return if name == '' {
		signature_nil()
	} else {
		ruby.object_value('Symbol', ':${name}')
	}
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d7_rest_type(args ...ruby.Value) ruby.Value {
	return runtime_signature_from_args(args).rest_type
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d8_rest_name(args ...ruby.Value) ruby.Value {
	name := runtime_signature_from_args(args).rest_name
	return if name == '' {
		signature_nil()
	} else {
		ruby.object_value('Symbol', ':${name}')
	}
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d9_keyrest_type(args ...ruby.Value) ruby.Value {
	return runtime_signature_from_args(args).keyrest_type
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d10_keyrest_name(args ...ruby.Value) ruby.Value {
	name := runtime_signature_from_args(args).keyrest_name
	return if name == '' {
		signature_nil()
	} else {
		ruby.object_value('Symbol', ':${name}')
	}
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d11_bind(args ...ruby.Value) ruby.Value {
	return runtime_signature_from_args(args).bind
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d12_effective_return_type(args ...ruby.Value) ruby.Value {
	return runtime_signature_from_args(args).effective_return_type
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d13_return_type(args ...ruby.Value) ruby.Value {
	return runtime_signature_from_args(args).return_type
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d14_mode(args ...ruby.Value) ruby.Value {
	return ruby.string_value(runtime_signature_from_args(args).mode)
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d15_req_arg_count(args ...ruby.Value) ruby.Value {
	return ruby.int_value(runtime_signature_from_args(args).req_arg_count)
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d16_req_kwarg_names(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(runtime_signature_from_args(args).req_kwarg_names)
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d17_check_level(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', ':${runtime_signature_from_args(args).check_level}')
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d18_parameters(args ...ruby.Value) ruby.Value {
	return signature_parameter_values(runtime_signature_from_args(args).parameters)
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d19_on_failure(args ...ruby.Value) ruby.Value {
	return runtime_signature_from_args(args).on_failure
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d20_override_allow_incompatible(args ...ruby.Value) ruby.Value {
	return ruby.string_value(runtime_signature_from_args(args).override_allow_incompatible)
}

// Ruby attr_reader `attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name, :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type, :return_type, :mode, :req_arg_count, :req_kwarg_names, :check_level, :parameters, :on_failure, :override_allow_incompatible, :defined_raw` at line 5.
pub fn ruby_signature_l5_d21_defined_raw(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(runtime_signature_from_args(args).defined_raw)
}

// Ruby method `self.new_untyped(method:, mode: T::Private::Methods::Modes.untyped, parameters: method.parameters)` at line 19.
pub fn ruby_signature_l19_d22_self_new_untyped(args ...ruby.Value) ruby.Value {
	config := signature_config_from_args(args)
	method := config['method'] or {
		if args.len > 0 {
			args[0]
		} else {
			panic('Signature.new_untyped requires method')
		}
	}
	mode := config['mode'] or { ruby.string_value('untyped') }.as_string()
	parameters := signature_parameters_from_method(method)
	return runtime_signature_value(new_untyped_runtime_method_signature(method, mode, parameters) or { panic(err) })
}

// Ruby method `initialize(method:, method_name:, raw_arg_types:, raw_return_type:, bind:, mode:, check_level:, on_failure:, parameters: method.parameters, override_allow_incompatible: false, defined_raw: false)` at line 45.
pub fn ruby_signature_l45_d23_initialize(args ...ruby.Value) ruby.Value {
	return runtime_signature_value(runtime_signature_from_config(signature_config_from_args(args)))
}

// Ruby attr_writer `attr_writer :method_name` at line 171.
pub fn ruby_signature_l171_d24_method_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Signature#method_name= requires a name') }
	mut signature := runtime_signature_from_args(args)
	signature.method_name = args[1].as_string().trim_string_left(':')
	return args[1]
}

// Ruby method `as_alias(alias_name)` at line 174.
pub fn ruby_signature_l174_d25_as_alias(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Signature#as_alias requires an alias name') }
	signature := runtime_signature_from_args(args)
	mut alias_signature := &RuntimeMethodSignature{
		...signature
		method_name: args[1].as_string().trim_string_left(':')
	}
	return runtime_signature_value(alias_signature)
}

// Ruby method `arg_count` at line 180.
pub fn ruby_signature_l180_d26_arg_count(args ...ruby.Value) ruby.Value {
	return ruby.int_value(runtime_signature_from_args(args).arg_types.len)
}

// Ruby method `kwarg_names` at line 184.
pub fn ruby_signature_l184_d27_kwarg_names(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(runtime_signature_from_args(args).kwarg_types.keys())
}

// Ruby method `owner` at line 188.
pub fn ruby_signature_l188_d28_owner(args ...ruby.Value) ruby.Value {
	signature := runtime_signature_from_args(args)
	return signature.method.map_data['owner'] or { ruby.object_value('Module', signature.method.attribute('owner') or { '<unknown>' }) }
}

// Ruby method `each_args_value_type(args)` at line 193.
pub fn ruby_signature_l193_d29_each_args_value_type(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Signature#each_args_value_type requires arguments') }
	values := args[1].as_array() or { panic(err) }
	return ruby.array_value(runtime_signature_from_args(args).each_argument_value_type(values) or { panic(err) }.map(runtime_argument_value(it)))
}

// Ruby it `it += 1` at line 225.
pub fn ruby_signature_l225_d30_anonymous(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.int_value(1)
	}
	return ruby.int_value((args[0].as_int() or { 0 }) + 1)
}

// Ruby it `it += 1` at line 234.
pub fn ruby_signature_l234_d31_anonymous(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.int_value(1)
	}
	return ruby.int_value((args[0].as_int() or { 0 }) + 1)
}

// Ruby method `method_desc` at line 249.
pub fn ruby_signature_l249_d32_method_desc(args ...ruby.Value) ruby.Value {
	signature := runtime_signature_from_args(args)
	return ruby.string_value(runtime_method_description(signature.method, signature.method_name, signature.method.attribute('source_location') or { '' }))
}

// Ruby method `self.method_desc(method, method_name, source_loc=method.source_location)` at line 253.
pub fn ruby_signature_l253_d33_self_method_desc(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Signature.method_desc requires method and method_name') }
	location := if args.len > 2 {
		args[2].as_string()
	} else {
		args[0].attribute('source_location') or { '' }
	}
	return ruby.string_value(runtime_method_description(args[0], args[1].as_string().trim_string_left(':'), location))
}

// Ruby method `force_type_init` at line 262.
pub fn ruby_signature_l262_d34_force_type_init(args ...ruby.Value) ruby.Value {
	mut signature := runtime_signature_from_args(args)
	signature.types_built = true
	return signature_nil()
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: class T::Private::Methods::Signature
// 5:   attr_reader :method, :method_name, :arg_types, :kwarg_types, :block_type, :block_name,
// 6:               :rest_type, :rest_name, :keyrest_type, :keyrest_name, :bind, :effective_return_type,
// 7:               :return_type, :mode, :req_arg_count, :req_kwarg_names,
// 8:               :check_level, :parameters, :on_failure, :override_allow_incompatible,
// 9:               :defined_raw
// 10:
// 11:   # T.unsafe: `UnboundMethod#parameters` lies and says `T::Array[[Symbol, Symbol]]`.
// 12:   # Sorbet can't lub tuple types, meaning that `T.any([Symbol], [Symbol,
// 13:   # Symbol])` would just be `T::Array[T.untyped]`. But Sorbet can see that
// 14:   # UNNAMED_REQUIRED_PARAMETERS, which is an array of 1-tuples, can never
// 15:   # equal an array of 2-tuples, and calls the code dead. There's no good
// 16:   # option, let's just unsafe until tuples are better and we can fix the sig.
// 17:   UNNAMED_REQUIRED_PARAMETERS = T.unsafe([[:req]].freeze)
// 18:
// 19:   def self.new_untyped(method:, mode: T::Private::Methods::Modes.untyped, parameters: method.parameters)
// 20:     # Using `NotTyped` ensures we'll get an error if we ever try validation on these.
// 21:     not_typed = T::Private::Types::NotTyped::INSTANCE
// 22:     raw_return_type = not_typed
// 23:     # Map missing parameter names to "argN" positionally
// 24:     parameters = parameters.each_with_index.map do |(param_kind, param_name), index|
// 25:       [param_kind, T.unsafe(param_name) || "arg#{index}".to_sym]
// 26:     end
// 27:     raw_arg_types = {}
// 28:     parameters.each do |_, param_name|
// 29:       raw_arg_types[param_name] = not_typed
// 30:     end
// 31:
// 32:     self.new(
// 33:       method: method,
// 34:       method_name: method.name,
// 35:       raw_arg_types: raw_arg_types,
// 36:       raw_return_type: raw_return_type,
// 37:       bind: nil,
// 38:       mode: mode,
// 39:       check_level: :never,
// 40:       parameters: parameters,
// 41:       on_failure: nil,
// 42:     )
// 43:   end
// 44:
// 45:   def initialize(method:, method_name:, raw_arg_types:, raw_return_type:, bind:, mode:, check_level:, on_failure:, parameters: method.parameters, override_allow_incompatible: false, defined_raw: false)
// 46:     check_level = check_level.nil? ? T::Private::RuntimeLevels.default_checked_level : check_level
// 47:     @method = method
// 48:     @method_name = method_name
// 49:     @block_type = nil
// 50:     @block_name = nil
// 51:     @rest_type = nil
// 52:     @rest_name = nil
// 53:     @keyrest_type = nil
// 54:     @keyrest_name = nil
// 55:     @return_type = T::Utils.coerce(raw_return_type)
// 56:     @effective_return_type = if check_level == :tests && @return_type.is_a?(T::Private::Types::Void)
// 57:       T::Types::Anything::Private::INSTANCE
// 58:     else
// 59:       @return_type
// 60:     end
// 61:     @bind = NilClass.===(bind) ? bind : T::Utils.coerce(bind)
// 62:     @mode = mode
// 63:     @check_level = check_level
// 64:     @parameters = parameters
// 65:     @on_failure = on_failure
// 66:     @override_allow_incompatible = override_allow_incompatible
// 67:     @defined_raw = defined_raw
// 68:
// 69:     # Use T.untyped in lieu of T.nilable to try to avoid unnecessary allocations.
// 70:     arg_types = nil
// 71:     kwarg_types = nil
// 72:     req_kwarg_names = nil
// 73:     if T::Private::IS_TYPECHECKING
// 74:       arg_types = T.let(nil, T.nilable(T::Array[[Symbol, T::Types::Base]]))
// 75:       kwarg_types = T.let(nil, T.nilable(T::Hash[Symbol, T::Types::Base]))
// 76:       req_kwarg_names = T.let(nil, T.nilable(T::Array[Symbol]))
// 77:     end
// 78:     req_arg_count = 0
// 79:
// 80:     # If sig params are declared but there is a single parameter with a missing name
// 81:     # **and** the method ends with a "=", assume it is a writer method generated
// 82:     # by attr_writer or attr_accessor
// 83:     # (Checks are ordered so that the common, non-writer case short-circuits without allocating.)
// 84:     writer_method = method_name.end_with?("=") && parameters == UNNAMED_REQUIRED_PARAMETERS && !(raw_arg_types.size == 1 && raw_arg_types.key?(nil))
// 85:     # For writer methods, map the single parameter to the method name without the "=" at the end
// 86:     parameters = [[:req, method_name[0...-1].to_sym]] if writer_method
// 87:     is_name_missing = parameters.any? { |_, name| !raw_arg_types.key?(name) }
// 88:     if is_name_missing
// 89:       param_names = parameters.map { |_, name| name }
// 90:       missing_names = param_names - raw_arg_types.keys
// 91:       raise "The declaration for `#{method.name}` is missing parameter(s): #{missing_names.join(', ')}"
// 92:     elsif parameters.length != raw_arg_types.size
// 93:       param_names = parameters.map { |_, name| name }
// 94:       has_extra_names = parameters.count { |_, name| raw_arg_types.key?(name) } < raw_arg_types.size
// 95:       if has_extra_names
// 96:         extra_names = raw_arg_types.keys - param_names
// 97:         raise "The declaration for `#{method.name}` has extra parameter(s): #{extra_names.join(', ')}"
// 98:       end
// 99:     end
// 100:
// 101:     if parameters.size != raw_arg_types.size
// 102:       raise "The declaration for `#{method.name}` has arguments with duplicate names"
// 103:     end
// 104:     i = 0
// 105:     raw_arg_types.each do |type_name, raw_type|
// 106:       param_kind, param_name = parameters.fetch(i)
// 107:
// 108:       if type_name != param_name
// 109:         hint = ""
// 110:         # Ruby reorders params so that required keyword arguments
// 111:         # always precede optional keyword arguments. We can't tell
// 112:         # whether the culprit is the Ruby reordering or user error, so
// 113:         # we error but include a note
// 114:         if param_kind == :keyreq && parameters.any? { |k, _| k == :key }
// 115:           hint = "\n\nNote: Any required keyword arguments must precede any optional keyword " \
// 116:                  "arguments. If your method declaration matches your `def`, try reordering any " \
// 117:                  "optional keyword parameters to the end of the method list."
// 118:         end
// 119:
// 120:         raise "Parameter `#{type_name}` is declared out of order (declared as arg number " \
// 121:               "#{i + 1}, defined in the method as arg number " \
// 122:               "#{T.must(parameters.index { |_, name| name == type_name }) + 1}).#{hint}\nMethod: #{method_desc}"
// 123:       end
// 124:
// 125:       type = T::Utils.coerce(raw_type)
// 126:
// 127:       case param_kind
// 128:       when :req
// 129:         if (arg_types ? arg_types.length : 0) > req_arg_count
// 130:           # Note that this is actually is supported by Ruby, but it would add complexity to
// 131:           # support it here, and I'm happy to discourage its use anyway.
// 132:           #
// 133:           # If you are seeing this error and surprised by it, it's possible that you have
// 134:           # overridden the method described in the error message. For example, Rails defines
// 135:           # def self.update!(id = :all, attributes)
// 136:           # on AR models. If you have also defined `self.update!` on an AR model you might
// 137:           # see this error. The simplest resolution is to rename your method.
// 138:           raise "Required params after optional params are not supported in method declarations. Method: #{method_desc}"
// 139:         end
// 140:         (arg_types ||= []) << [param_name, type]
// 141:         req_arg_count += 1
// 142:       when :opt
// 143:         (arg_types ||= []) << [param_name, type]
// 144:       when :key, :keyreq
// 145:         (kwarg_types ||= {})[param_name] = type
// 146:         if param_kind == :keyreq
// 147:           (req_kwarg_names ||= []) << param_name
// 148:         end
// 149:       when :block
// 150:         @block_name = param_name
// 151:         @block_type = type
// 152:       when :rest
// 153:         @rest_name = param_name
// 154:         @rest_type = type
// 155:       when :keyrest
// 156:         @keyrest_name = param_name
// 157:         @keyrest_type = type
// 158:       else
// 159:         raise "Unexpected param_kind: `#{param_kind}`. Method: #{method_desc}"
// 160:       end
// 161:
// 162:       i += 1
// 163:     end
// 164:
// 165:     @arg_types = arg_types || EMPTY_LIST
// 166:     @kwarg_types = kwarg_types || EMPTY_HASH
// 167:     @req_arg_count = req_arg_count
// 168:     @req_kwarg_names = req_kwarg_names || EMPTY_LIST
// 169:   end
// 170:
// 171:   attr_writer :method_name
// 172:   protected :method_name=
// 173:
// 174:   def as_alias(alias_name)
// 175:     new_sig = clone
// 176:     new_sig.method_name = alias_name
// 177:     new_sig
// 178:   end
// 179:
// 180:   def arg_count
// 181:     @arg_types.length
// 182:   end
// 183:
// 184:   def kwarg_names
// 185:     @kwarg_types.keys
// 186:   end
// 187:
// 188:   def owner
// 189:     @method.owner
// 190:   end
// 191:
// 192:   # @return [Hash] a mapping like `{arg_name: [val, type], ...}`, for only those args actually present.
// 193:   def each_args_value_type(args)
// 194:     # Manually split out args and kwargs based on ruby's behavior. Do not try to implement this by
// 195:     # getting ruby to determine the kwargs for you (e.g., by defining this method to take *args and
// 196:     # **kwargs). That won't work, because ruby's behavior for determining kwargs is dependent on the
// 197:     # the other parameters in the method definition, and our method definition here doesn't (and
// 198:     # can't) match the definition of the method we're validating. In addition, Ruby has a bug that
// 199:     # causes forwarding **kwargs to do the wrong thing: see https://bugs.ruby-lang.org/issues/10708
// 200:     # and https://bugs.ruby-lang.org/issues/11860.
// 201:     args_length = args.length
// 202:     if (args_length > @req_arg_count) && (!@kwarg_types.empty? || !@keyrest_type.nil?) && (last_arg = args[-1]).is_a?(Hash)
// 203:       kwargs = last_arg
// 204:       args_length -= 1
// 205:     else
// 206:       kwargs = EMPTY_HASH
// 207:     end
// 208:
// 209:     if @rest_type.nil? && ((args_length < @req_arg_count) || (args_length > @arg_types.length))
// 210:       expected_str = @req_arg_count.to_s
// 211:       if @arg_types.length != @req_arg_count
// 212:         expected_str += "..#{@arg_types.length}"
// 213:       end
// 214:       raise ArgumentError.new("wrong number of arguments (given #{args_length}, expected #{expected_str})")
// 215:     end
// 216:
// 217:     begin
// 218:       it = 0
// 219:
// 220:       # Process given pre-rest args. When there are no rest args,
// 221:       # this is just the given number of args.
// 222:       while it < args_length && it < @arg_types.length
// 223:         arg_type = @arg_types.fetch(it)
// 224:         yield arg_type[0], args[it], arg_type[1]
// 225:         it += 1
// 226:       end
// 227:
// 228:       if !@rest_type.nil?
// 229:         rest_count = args_length - @arg_types.length
// 230:         rest_count = 0 if rest_count.negative?
// 231:
// 232:         rest_count.times do
// 233:           yield @rest_name, args[it], @rest_type
// 234:           it += 1
// 235:         end
// 236:       end
// 237:     end
// 238:
// 239:     kwargs.each do |name, val|
// 240:       type = @kwarg_types[name]
// 241:       if !type && !@keyrest_type.nil?
// 242:         type = @keyrest_type
// 243:       end
// 244:
// 245:       yield name, val, type if type
// 246:     end
// 247:   end
// 248:
// 249:   def method_desc
// 250:     self.class.method_desc(@method, @method_name)
// 251:   end
// 252:
// 253:   def self.method_desc(method, method_name, source_loc=method.source_location)
// 254:     loc = if source_loc
// 255:       source_loc.join(':')
// 256:     else
// 257:       "<unknown location>"
// 258:     end
// 259:     "#{method.owner}##{method_name} at #{loc}"
// 260:   end
// 261:
// 262:   def force_type_init
// 263:     @arg_types.each { |_, type| type.build_type }
// 264:     @kwarg_types.each { |_, type| type.build_type }
// 265:     @block_type&.build_type
// 266:     @rest_type&.build_type
// 267:     @keyrest_type&.build_type
// 268:     @return_type.build_type
// 269:   end
// 270:
// 271:   EMPTY_LIST = [].freeze
// 272:   EMPTY_HASH = {}.freeze
// 273: end
