module methods

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/methods/call_validation_2_7.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ValidatorSpecialization {
pub:
	module_name     string
	method_name     string
	visibility      string
	kind            string
	arg_count       int
	required_count  int
	validate_return bool
	returns_void    bool
	validate_block  bool
	raw_fast_types  bool
	kwargs_only     bool
	original_method brew_runtime.Value
	signature       brew_runtime.Value
}

fn specialized_effective_return_type(signature brew_runtime.Value) brew_runtime.Value {
	return signature.map_data['effective_return_type'] or {
		signature.map_data['return_type'] or { brew_runtime.object_value('NilClass', 'nil') }
	}
}

fn specialized_signature_arg_count(signature brew_runtime.Value) int {
	return call_signature_arg_types(signature).len
}

pub fn build_validator_specialization(kind string, fixed_arg_count int,
	required_count int, args []brew_runtime.Value) ValidatorSpecialization {
	if args.len < 3 {
		panic('specialized CallValidation creation requires module, original method, and signature')
	}
	signature := args[2]
	return_type := specialized_effective_return_type(signature)
	arg_count := if fixed_arg_count >= 0 {
		fixed_arg_count
	} else {
		specialized_signature_arg_count(signature)
	}
	resolved_required_count := if required_count == -2 {
		signature.attribute('req_arg_count') or { arg_count.str() }.int()
	} else if required_count >= 0 {
		required_count
	} else {
		arg_count
	}
	visibility := if args.len > 3 {
		args[3].as_string().trim_string_left(':')
	} else {
		args[1].attribute('visibility') or { 'public' }
	}
	validate_return := !kind.contains('skip_return') && !kind.contains('procedure')
	returns_void := kind.contains('procedure') || return_type.type_name == 'T::Private::Types::Void'
	if validate_return && returns_void && (kind == 'method_fast' || kind == 'method_medium') {
		panic('Should have used create_validator_procedure_${if kind.ends_with('fast') {
			'fast'
		} else {
			'medium'
		}}')
	}
	return ValidatorSpecialization{
		module_name: args[0].as_string()
		method_name: signature.attribute('method_name') or { signature.as_string() }
		visibility: visibility
		kind: kind
		arg_count: arg_count
		required_count: resolved_required_count
		validate_return: validate_return
		returns_void: returns_void
		validate_block: kind == 'with_block'
		raw_fast_types: kind.contains('fast')
		kwargs_only: kind == 'kwargs'
		original_method: args[1]
		signature: signature
	}
}

fn validator_specialization_value(specialization ValidatorSpecialization) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'T::Private::Methods::CallValidation::ValidatorSpecialization'
		repr: specialization.method_name
		map_data: {
			'original_method': specialization.original_method
			'signature':       specialization.signature
		}
		attributes: {
			'module':          specialization.module_name
			'method_name':     specialization.method_name
			'visibility':      specialization.visibility
			'kind':            specialization.kind
			'arg_count':       specialization.arg_count.str()
			'required_count':  specialization.required_count.str()
			'validate_return': specialization.validate_return.str()
			'returns_void':    specialization.returns_void.str()
			'validate_block':  specialization.validate_block.str()
			'raw_fast_types':  specialization.raw_fast_types.str()
			'kwargs_only':     specialization.kwargs_only.str()
		}
	}
}

pub fn validator_specialization_from_value(value brew_runtime.Value) ValidatorSpecialization {
	return ValidatorSpecialization{
		module_name: value.attribute('module') or { '' }
		method_name: value.attribute('method_name') or { value.as_string() }
		visibility: value.attribute('visibility') or { 'public' }
		kind: value.attribute('kind') or { '' }
		arg_count: value.attribute('arg_count') or { '0' }.int()
		required_count: value.attribute('required_count') or { '0' }.int()
		validate_return: value.attribute('validate_return') or { 'false' } == 'true'
		returns_void: value.attribute('returns_void') or { 'false' } == 'true'
		validate_block: value.attribute('validate_block') or { 'false' } == 'true'
		raw_fast_types: value.attribute('raw_fast_types') or { 'false' } == 'true'
		kwargs_only: value.attribute('kwargs_only') or { 'false' } == 'true'
		original_method: value.map_data['original_method'] or { brew_runtime.object_value('NilClass', 'nil') }
		signature: value.map_data['signature'] or { brew_runtime.object_value('NilClass', 'nil') }
	}
}

pub fn execute_validator_specialization(specialization ValidatorSpecialization,
	instance brew_runtime.Value, positional []brew_runtime.Value,
	kwargs map[string]brew_runtime.Value, block_value brew_runtime.Value,
	return_value brew_runtime.Value) !brew_runtime.Value {
	if specialization.kwargs_only {
		kwarg_types := specialization.signature.map_data['kwarg_types'] or { brew_runtime.map_value({}) }.as_map()!
		for name, value in kwargs {
			if type_value := kwarg_types[name] {
				message := call_error_message(type_value, value)
				if message != '' {
					return error("Parameter '${name}': ${message}")
				}
			}
		}
	} else {
		if positional.len < specialization.required_count || positional.len > specialization.arg_count {
			expected := if specialization.required_count == specialization.arg_count {
				specialization.arg_count.str()
			} else {
				'${specialization.required_count}..${specialization.arg_count}'
			}
			return error('wrong number of arguments (given ${positional.len}, expected ${expected})')
		}
		arg_types := call_signature_arg_types(specialization.signature)
		for index, value in positional {
			if index >= arg_types.len {
				break
			}
			message := call_error_message(arg_types[index].type_value, value)
			if message != '' {
				return error("Parameter '${arg_types[index].name}': ${message}")
			}
		}
	}
	if specialization.validate_block {
		block_type := specialization.signature.map_data['block_type'] or { brew_runtime.object_value('NilClass', 'nil') }
		if block_value.type_name == 'NilClass' || !call_value_valid(block_type, block_value) {
			return error("Block parameter '${specialization.signature.attribute('block_name') or { '' }}': ${call_error_message(block_type, block_value)}")
		}
	}
	if specialization.returns_void {
		return brew_runtime.object_value('T::Private::Types::Void::VOID', 'VOID')
	}
	if specialization.validate_return {
		return_type := specialized_effective_return_type(specialization.signature)
		message := call_error_message(return_type, return_value)
		if message != '' {
			return error('Return value: ${message}')
		}
	}
	return return_value
}

fn validator_specialization_boundary(kind string, fixed_arg_count int, required_count int,
	args []brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_value(build_validator_specialization(kind, fixed_arg_count, required_count, args))
}

// Ruby method `self.create_validator_method_fast(mod, original_method, method_sig, original_visibility)` at line 9.
pub fn ruby_call_validation_2_7_l9_d1_self_create_validator_method_fast(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_fast', -1, -1, args)
}

// Ruby method `self.create_validator_method_fast0(mod, original_method, method_sig, original_visibility, return_type)` at line 41.
pub fn ruby_call_validation_2_7_l41_d2_self_create_validator_method_fast0(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_fast', 0, 0, args)
}

// Ruby method `self.create_validator_method_fast1(mod, original_method, method_sig, original_visibility, return_type, arg0_type)` at line 78.
pub fn ruby_call_validation_2_7_l78_d3_self_create_validator_method_fast1(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_fast', 1, 1, args)
}

// Ruby method `self.create_validator_method_fast2(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type)` at line 127.
pub fn ruby_call_validation_2_7_l127_d4_self_create_validator_method_fast2(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_fast', 2, 2, args)
}

// Ruby method `self.create_validator_method_fast3(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type)` at line 188.
pub fn ruby_call_validation_2_7_l188_d5_self_create_validator_method_fast3(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_fast', 3, 3, args)
}

// Ruby method `self.create_validator_method_fast4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)` at line 261.
pub fn ruby_call_validation_2_7_l261_d6_self_create_validator_method_fast4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_fast', 4, 4, args)
}

// Ruby method `self.create_validator_method_skip_return_fast(mod, original_method, method_sig, original_visibility)` at line 346.
pub fn ruby_call_validation_2_7_l346_d7_self_create_validator_method_skip_return_fast(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_fast', -1, -1, args)
}

// Ruby method `self.create_validator_method_skip_return_fast0(mod, original_method, method_sig, original_visibility)` at line 375.
pub fn ruby_call_validation_2_7_l375_d8_self_create_validator_method_skip_return_fast0(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_fast', 0, 0, args)
}

// Ruby method `self.create_validator_method_skip_return_fast1(mod, original_method, method_sig, original_visibility, arg0_type)` at line 397.
pub fn ruby_call_validation_2_7_l397_d9_self_create_validator_method_skip_return_fast1(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_fast', 1, 1, args)
}

// Ruby method `self.create_validator_method_skip_return_fast2(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type)` at line 431.
pub fn ruby_call_validation_2_7_l431_d10_self_create_validator_method_skip_return_fast2(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_fast', 2, 2, args)
}

// Ruby method `self.create_validator_method_skip_return_fast3(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type)` at line 477.
pub fn ruby_call_validation_2_7_l477_d11_self_create_validator_method_skip_return_fast3(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_fast', 3, 3, args)
}

// Ruby method `self.create_validator_method_skip_return_fast4(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type, arg3_type)` at line 535.
pub fn ruby_call_validation_2_7_l535_d12_self_create_validator_method_skip_return_fast4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_fast', 4, 4, args)
}

// Ruby method `self.create_validator_procedure_fast(mod, original_method, method_sig, original_visibility)` at line 605.
pub fn ruby_call_validation_2_7_l605_d13_self_create_validator_procedure_fast(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_fast', -1, -1, args)
}

// Ruby method `self.create_validator_procedure_fast0(mod, original_method, method_sig, original_visibility)` at line 634.
pub fn ruby_call_validation_2_7_l634_d14_self_create_validator_procedure_fast0(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_fast', 0, 0, args)
}

// Ruby method `self.create_validator_procedure_fast1(mod, original_method, method_sig, original_visibility, arg0_type)` at line 657.
pub fn ruby_call_validation_2_7_l657_d15_self_create_validator_procedure_fast1(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_fast', 1, 1, args)
}

// Ruby method `self.create_validator_procedure_fast2(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type)` at line 692.
pub fn ruby_call_validation_2_7_l692_d16_self_create_validator_procedure_fast2(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_fast', 2, 2, args)
}

// Ruby method `self.create_validator_procedure_fast3(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type)` at line 739.
pub fn ruby_call_validation_2_7_l739_d17_self_create_validator_procedure_fast3(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_fast', 3, 3, args)
}

// Ruby method `self.create_validator_procedure_fast4(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type, arg3_type)` at line 798.
pub fn ruby_call_validation_2_7_l798_d18_self_create_validator_procedure_fast4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_fast', 4, 4, args)
}

// Ruby method `self.create_validator_method_medium(mod, original_method, method_sig, original_visibility)` at line 869.
pub fn ruby_call_validation_2_7_l869_d19_self_create_validator_method_medium(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_medium', -1, -1, args)
}

// Ruby method `self.create_validator_method_medium0(mod, original_method, method_sig, original_visibility, return_type)` at line 901.
pub fn ruby_call_validation_2_7_l901_d20_self_create_validator_method_medium0(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_medium', 0, 0, args)
}

// Ruby method `self.create_validator_method_medium1(mod, original_method, method_sig, original_visibility, return_type, arg0_type)` at line 938.
pub fn ruby_call_validation_2_7_l938_d21_self_create_validator_method_medium1(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_medium', 1, 1, args)
}

// Ruby method `self.create_validator_method_medium2(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type)` at line 987.
pub fn ruby_call_validation_2_7_l987_d22_self_create_validator_method_medium2(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_medium', 2, 2, args)
}

// Ruby method `self.create_validator_method_medium3(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type)` at line 1048.
pub fn ruby_call_validation_2_7_l1048_d23_self_create_validator_method_medium3(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_medium', 3, 3, args)
}

// Ruby method `self.create_validator_method_medium4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)` at line 1121.
pub fn ruby_call_validation_2_7_l1121_d24_self_create_validator_method_medium4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_medium', 4, 4, args)
}

// Ruby method `self.create_validator_method_skip_return_medium(mod, original_method, method_sig, original_visibility)` at line 1206.
pub fn ruby_call_validation_2_7_l1206_d25_self_create_validator_method_skip_return_medium(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_medium', -1, -1, args)
}

// Ruby method `self.create_validator_method_skip_return_medium0(mod, original_method, method_sig, original_visibility)` at line 1235.
pub fn ruby_call_validation_2_7_l1235_d26_self_create_validator_method_skip_return_medium0(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_medium', 0, 0, args)
}

// Ruby method `self.create_validator_method_skip_return_medium1(mod, original_method, method_sig, original_visibility, arg0_type)` at line 1257.
pub fn ruby_call_validation_2_7_l1257_d27_self_create_validator_method_skip_return_medium1(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_medium', 1, 1, args)
}

// Ruby method `self.create_validator_method_skip_return_medium2(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type)` at line 1291.
pub fn ruby_call_validation_2_7_l1291_d28_self_create_validator_method_skip_return_medium2(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_medium', 2, 2, args)
}

// Ruby method `self.create_validator_method_skip_return_medium3(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type)` at line 1337.
pub fn ruby_call_validation_2_7_l1337_d29_self_create_validator_method_skip_return_medium3(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_medium', 3, 3, args)
}

// Ruby method `self.create_validator_method_skip_return_medium4(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type, arg3_type)` at line 1395.
pub fn ruby_call_validation_2_7_l1395_d30_self_create_validator_method_skip_return_medium4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('method_skip_return_medium', 4, 4, args)
}

// Ruby method `self.create_validator_procedure_medium(mod, original_method, method_sig, original_visibility)` at line 1465.
pub fn ruby_call_validation_2_7_l1465_d31_self_create_validator_procedure_medium(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_medium', -1, -1, args)
}

// Ruby method `self.create_validator_procedure_medium0(mod, original_method, method_sig, original_visibility)` at line 1494.
pub fn ruby_call_validation_2_7_l1494_d32_self_create_validator_procedure_medium0(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_medium', 0, 0, args)
}

// Ruby method `self.create_validator_procedure_medium1(mod, original_method, method_sig, original_visibility, arg0_type)` at line 1517.
pub fn ruby_call_validation_2_7_l1517_d33_self_create_validator_procedure_medium1(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_medium', 1, 1, args)
}

// Ruby method `self.create_validator_procedure_medium2(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type)` at line 1552.
pub fn ruby_call_validation_2_7_l1552_d34_self_create_validator_procedure_medium2(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_medium', 2, 2, args)
}

// Ruby method `self.create_validator_procedure_medium3(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type)` at line 1599.
pub fn ruby_call_validation_2_7_l1599_d35_self_create_validator_procedure_medium3(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_medium', 3, 3, args)
}

// Ruby method `self.create_validator_procedure_medium4(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type, arg3_type)` at line 1658.
pub fn ruby_call_validation_2_7_l1658_d36_self_create_validator_procedure_medium4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('procedure_medium', 4, 4, args)
}

// Ruby method `self.create_validator_method_kwargs(mod, original_method, method_sig, original_visibility)` at line 1729.
pub fn ruby_call_validation_2_7_l1729_d37_self_create_validator_method_kwargs(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('kwargs', 0, 0, args)
}

// Ruby method `self.create_validator_method_kwargs0(mod, original_method, method_sig, original_visibility, return_type, kwarg_types)` at line 1735.
pub fn ruby_call_validation_2_7_l1735_d38_self_create_validator_method_kwargs0(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('kwargs', 0, 0, args)
}

// Ruby method `self.create_validator_method_with_block(mod, original_method, method_sig, original_visibility)` at line 1777.
pub fn ruby_call_validation_2_7_l1777_d39_self_create_validator_method_with_block(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('with_block', -1, -1, args)
}

// Ruby method `self.create_validator_method_with_block0(mod, original_method, method_sig, original_visibility, return_type, block_type)` at line 1809.
pub fn ruby_call_validation_2_7_l1809_d40_self_create_validator_method_with_block0(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('with_block', 0, 0, args)
}

// Ruby method `self.create_validator_method_with_block1(mod, original_method, method_sig, original_visibility, return_type, block_type, arg0_type)` at line 1846.
pub fn ruby_call_validation_2_7_l1846_d41_self_create_validator_method_with_block1(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('with_block', 1, 1, args)
}

// Ruby method `self.create_validator_method_with_block2(mod, original_method, method_sig, original_visibility, return_type, block_type, arg0_type, arg1_type)` at line 1894.
pub fn ruby_call_validation_2_7_l1894_d42_self_create_validator_method_with_block2(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('with_block', 2, 2, args)
}

// Ruby method `self.create_validator_method_with_block3(mod, original_method, method_sig, original_visibility, return_type, block_type, arg0_type, arg1_type, arg2_type)` at line 1953.
pub fn ruby_call_validation_2_7_l1953_d43_self_create_validator_method_with_block3(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('with_block', 3, 3, args)
}

// Ruby method `self.create_validator_method_with_block4(mod, original_method, method_sig, original_visibility, return_type, block_type, arg0_type, arg1_type, arg2_type, arg3_type)` at line 2023.
pub fn ruby_call_validation_2_7_l2023_d44_self_create_validator_method_with_block4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('with_block', 4, 4, args)
}

// Ruby method `self.create_validator_method_optional_args(mod, original_method, method_sig, original_visibility)` at line 2104.
pub fn ruby_call_validation_2_7_l2104_d45_self_create_validator_method_optional_args(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', -1, -2, args)
}

// Ruby method `self.create_validator_method_optional_args0_1(mod, original_method, method_sig, original_visibility, return_type, arg0_type)` at line 2165.
pub fn ruby_call_validation_2_7_l2165_d46_self_create_validator_method_optional_args0_1(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', 1, 0, args)
}

// Ruby method `self.create_validator_method_optional_args0_2(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type)` at line 2202.
pub fn ruby_call_validation_2_7_l2202_d47_self_create_validator_method_optional_args0_2(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', 2, 0, args)
}

// Ruby method `self.create_validator_method_optional_args1_2(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type)` at line 2250.
pub fn ruby_call_validation_2_7_l2250_d48_self_create_validator_method_optional_args1_2(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', 2, 1, args)
}

// Ruby method `self.create_validator_method_optional_args0_3(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type)` at line 2298.
pub fn ruby_call_validation_2_7_l2298_d49_self_create_validator_method_optional_args0_3(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', 3, 0, args)
}

// Ruby method `self.create_validator_method_optional_args1_3(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type)` at line 2357.
pub fn ruby_call_validation_2_7_l2357_d50_self_create_validator_method_optional_args1_3(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', 3, 1, args)
}

// Ruby method `self.create_validator_method_optional_args2_3(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type)` at line 2416.
pub fn ruby_call_validation_2_7_l2416_d51_self_create_validator_method_optional_args2_3(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', 3, 2, args)
}

// Ruby method `self.create_validator_method_optional_args0_4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)` at line 2475.
pub fn ruby_call_validation_2_7_l2475_d52_self_create_validator_method_optional_args0_4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', 4, 0, args)
}

// Ruby method `self.create_validator_method_optional_args1_4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)` at line 2545.
pub fn ruby_call_validation_2_7_l2545_d53_self_create_validator_method_optional_args1_4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', 4, 1, args)
}

// Ruby method `self.create_validator_method_optional_args2_4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)` at line 2615.
pub fn ruby_call_validation_2_7_l2615_d54_self_create_validator_method_optional_args2_4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', 4, 2, args)
}

// Ruby method `self.create_validator_method_optional_args3_4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)` at line 2685.
pub fn ruby_call_validation_2_7_l2685_d55_self_create_validator_method_optional_args3_4(args ...brew_runtime.Value) brew_runtime.Value {
	return validator_specialization_boundary('optional_args', 4, 3, args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: # DO NOT EDIT. This file is autogenerated. To regenerate, run:
// 5: #
// 6: #     bazel test //gems/sorbet-runtime:update_call_validation
// 7:
// 8: module T::Private::Methods::CallValidation
// 9:   def self.create_validator_method_fast(mod, original_method, method_sig, original_visibility)
// 10:     if method_sig.effective_return_type.is_a?(T::Private::Types::Void)
// 11:       raise 'Should have used create_validator_procedure_fast'
// 12:     end
// 13:     # trampoline to reduce stack frame size
// 14:     arg_types = method_sig.arg_types
// 15:     case arg_types.length
// 16:     when 0
// 17:       create_validator_method_fast0(mod, original_method, method_sig, original_visibility, method_sig.effective_return_type.raw_type)
// 18:     when 1
// 19:       create_validator_method_fast1(mod, original_method, method_sig, original_visibility, method_sig.effective_return_type.raw_type,
// 20:                                     arg_types[0][1].raw_type)
// 21:     when 2
// 22:       create_validator_method_fast2(mod, original_method, method_sig, original_visibility, method_sig.effective_return_type.raw_type,
// 23:                                     arg_types[0][1].raw_type,
// 24:                                     arg_types[1][1].raw_type)
// 25:     when 3
// 26:       create_validator_method_fast3(mod, original_method, method_sig, original_visibility, method_sig.effective_return_type.raw_type,
// 27:                                     arg_types[0][1].raw_type,
// 28:                                     arg_types[1][1].raw_type,
// 29:                                     arg_types[2][1].raw_type)
// 30:     when 4
// 31:       create_validator_method_fast4(mod, original_method, method_sig, original_visibility, method_sig.effective_return_type.raw_type,
// 32:                                     arg_types[0][1].raw_type,
// 33:                                     arg_types[1][1].raw_type,
// 34:                                     arg_types[2][1].raw_type,
// 35:                                     arg_types[3][1].raw_type)
// 36:     else
// 37:       raise 'should not happen'
// 38:     end
// 39:   end
// 40:
// 41:   def self.create_validator_method_fast0(mod, original_method, method_sig, original_visibility, return_type)
// 42:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |&blk|
// 43:       # This method is a manually sped-up version of more general code in `validate_call`
// 44:       # The following line breaks are intentional to show nice pry message
// 45:
// 46:
// 47:
// 48:
// 49:
// 50:
// 51:
// 52:
// 53:
// 54:
// 55:       # PRY note:
// 56:       # this code is sig validation code.
// 57:       # Please issue `finish` to step out of it
// 58:
// 59:       return_value = original_method.bind_call(self, &blk)
// 60:       unless return_value.is_a?(return_type)
// 61:         message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 62:         if message
// 63:           CallValidation.report_error(
// 64:             method_sig,
// 65:             message,
// 66:             'Return value',
// 67:             nil,
// 68:             method_sig.effective_return_type,
// 69:             return_value,
// 70:             caller_offset: -1
// 71:           )
// 72:         end
// 73:       end
// 74:       return_value
// 75:     end
// 76:   end
// 77:
// 78:   def self.create_validator_method_fast1(mod, original_method, method_sig, original_visibility, return_type, arg0_type)
// 79:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, &blk|
// 80:       # This method is a manually sped-up version of more general code in `validate_call`
// 81:       unless arg0.is_a?(arg0_type)
// 82:         CallValidation.report_error(
// 83:           method_sig,
// 84:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 85:           'Parameter',
// 86:           method_sig.arg_types[0][0],
// 87:           arg0_type,
// 88:           arg0,
// 89:           caller_offset: -1
// 90:         )
// 91:       end
// 92:
// 93:       # The following line breaks are intentional to show nice pry message
// 94:
// 95:
// 96:
// 97:
// 98:
// 99:
// 100:
// 101:
// 102:
// 103:
// 104:       # PRY note:
// 105:       # this code is sig validation code.
// 106:       # Please issue `finish` to step out of it
// 107:
// 108:       return_value = original_method.bind_call(self, arg0, &blk)
// 109:       unless return_value.is_a?(return_type)
// 110:         message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 111:         if message
// 112:           CallValidation.report_error(
// 113:             method_sig,
// 114:             message,
// 115:             'Return value',
// 116:             nil,
// 117:             method_sig.effective_return_type,
// 118:             return_value,
// 119:             caller_offset: -1
// 120:           )
// 121:         end
// 122:       end
// 123:       return_value
// 124:     end
// 125:   end
// 126:
// 127:   def self.create_validator_method_fast2(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type)
// 128:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, &blk|
// 129:       # This method is a manually sped-up version of more general code in `validate_call`
// 130:       unless arg0.is_a?(arg0_type)
// 131:         CallValidation.report_error(
// 132:           method_sig,
// 133:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 134:           'Parameter',
// 135:           method_sig.arg_types[0][0],
// 136:           arg0_type,
// 137:           arg0,
// 138:           caller_offset: -1
// 139:         )
// 140:       end
// 141:
// 142:       unless arg1.is_a?(arg1_type)
// 143:         CallValidation.report_error(
// 144:           method_sig,
// 145:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 146:           'Parameter',
// 147:           method_sig.arg_types[1][0],
// 148:           arg1_type,
// 149:           arg1,
// 150:           caller_offset: -1
// 151:         )
// 152:       end
// 153:
// 154:       # The following line breaks are intentional to show nice pry message
// 155:
// 156:
// 157:
// 158:
// 159:
// 160:
// 161:
// 162:
// 163:
// 164:
// 165:       # PRY note:
// 166:       # this code is sig validation code.
// 167:       # Please issue `finish` to step out of it
// 168:
// 169:       return_value = original_method.bind_call(self, arg0, arg1, &blk)
// 170:       unless return_value.is_a?(return_type)
// 171:         message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 172:         if message
// 173:           CallValidation.report_error(
// 174:             method_sig,
// 175:             message,
// 176:             'Return value',
// 177:             nil,
// 178:             method_sig.effective_return_type,
// 179:             return_value,
// 180:             caller_offset: -1
// 181:           )
// 182:         end
// 183:       end
// 184:       return_value
// 185:     end
// 186:   end
// 187:
// 188:   def self.create_validator_method_fast3(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type)
// 189:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, &blk|
// 190:       # This method is a manually sped-up version of more general code in `validate_call`
// 191:       unless arg0.is_a?(arg0_type)
// 192:         CallValidation.report_error(
// 193:           method_sig,
// 194:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 195:           'Parameter',
// 196:           method_sig.arg_types[0][0],
// 197:           arg0_type,
// 198:           arg0,
// 199:           caller_offset: -1
// 200:         )
// 201:       end
// 202:
// 203:       unless arg1.is_a?(arg1_type)
// 204:         CallValidation.report_error(
// 205:           method_sig,
// 206:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 207:           'Parameter',
// 208:           method_sig.arg_types[1][0],
// 209:           arg1_type,
// 210:           arg1,
// 211:           caller_offset: -1
// 212:         )
// 213:       end
// 214:
// 215:       unless arg2.is_a?(arg2_type)
// 216:         CallValidation.report_error(
// 217:           method_sig,
// 218:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 219:           'Parameter',
// 220:           method_sig.arg_types[2][0],
// 221:           arg2_type,
// 222:           arg2,
// 223:           caller_offset: -1
// 224:         )
// 225:       end
// 226:
// 227:       # The following line breaks are intentional to show nice pry message
// 228:
// 229:
// 230:
// 231:
// 232:
// 233:
// 234:
// 235:
// 236:
// 237:
// 238:       # PRY note:
// 239:       # this code is sig validation code.
// 240:       # Please issue `finish` to step out of it
// 241:
// 242:       return_value = original_method.bind_call(self, arg0, arg1, arg2, &blk)
// 243:       unless return_value.is_a?(return_type)
// 244:         message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 245:         if message
// 246:           CallValidation.report_error(
// 247:             method_sig,
// 248:             message,
// 249:             'Return value',
// 250:             nil,
// 251:             method_sig.effective_return_type,
// 252:             return_value,
// 253:             caller_offset: -1
// 254:           )
// 255:         end
// 256:       end
// 257:       return_value
// 258:     end
// 259:   end
// 260:
// 261:   def self.create_validator_method_fast4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)
// 262:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, arg3, &blk|
// 263:       # This method is a manually sped-up version of more general code in `validate_call`
// 264:       unless arg0.is_a?(arg0_type)
// 265:         CallValidation.report_error(
// 266:           method_sig,
// 267:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 268:           'Parameter',
// 269:           method_sig.arg_types[0][0],
// 270:           arg0_type,
// 271:           arg0,
// 272:           caller_offset: -1
// 273:         )
// 274:       end
// 275:
// 276:       unless arg1.is_a?(arg1_type)
// 277:         CallValidation.report_error(
// 278:           method_sig,
// 279:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 280:           'Parameter',
// 281:           method_sig.arg_types[1][0],
// 282:           arg1_type,
// 283:           arg1,
// 284:           caller_offset: -1
// 285:         )
// 286:       end
// 287:
// 288:       unless arg2.is_a?(arg2_type)
// 289:         CallValidation.report_error(
// 290:           method_sig,
// 291:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 292:           'Parameter',
// 293:           method_sig.arg_types[2][0],
// 294:           arg2_type,
// 295:           arg2,
// 296:           caller_offset: -1
// 297:         )
// 298:       end
// 299:
// 300:       unless arg3.is_a?(arg3_type)
// 301:         CallValidation.report_error(
// 302:           method_sig,
// 303:           method_sig.arg_types[3][1].error_message_for_obj(arg3),
// 304:           'Parameter',
// 305:           method_sig.arg_types[3][0],
// 306:           arg3_type,
// 307:           arg3,
// 308:           caller_offset: -1
// 309:         )
// 310:       end
// 311:
// 312:       # The following line breaks are intentional to show nice pry message
// 313:
// 314:
// 315:
// 316:
// 317:
// 318:
// 319:
// 320:
// 321:
// 322:
// 323:       # PRY note:
// 324:       # this code is sig validation code.
// 325:       # Please issue `finish` to step out of it
// 326:
// 327:       return_value = original_method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
// 328:       unless return_value.is_a?(return_type)
// 329:         message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 330:         if message
// 331:           CallValidation.report_error(
// 332:             method_sig,
// 333:             message,
// 334:             'Return value',
// 335:             nil,
// 336:             method_sig.effective_return_type,
// 337:             return_value,
// 338:             caller_offset: -1
// 339:           )
// 340:         end
// 341:       end
// 342:       return_value
// 343:     end
// 344:   end
// 345:
// 346:   def self.create_validator_method_skip_return_fast(mod, original_method, method_sig, original_visibility)
// 347:     # trampoline to reduce stack frame size
// 348:     arg_types = method_sig.arg_types
// 349:     case arg_types.length
// 350:     when 0
// 351:       create_validator_method_skip_return_fast0(mod, original_method, method_sig, original_visibility)
// 352:     when 1
// 353:       create_validator_method_skip_return_fast1(mod, original_method, method_sig, original_visibility,
// 354:                                     arg_types[0][1].raw_type)
// 355:     when 2
// 356:       create_validator_method_skip_return_fast2(mod, original_method, method_sig, original_visibility,
// 357:                                     arg_types[0][1].raw_type,
// 358:                                     arg_types[1][1].raw_type)
// 359:     when 3
// 360:       create_validator_method_skip_return_fast3(mod, original_method, method_sig, original_visibility,
// 361:                                     arg_types[0][1].raw_type,
// 362:                                     arg_types[1][1].raw_type,
// 363:                                     arg_types[2][1].raw_type)
// 364:     when 4
// 365:       create_validator_method_skip_return_fast4(mod, original_method, method_sig, original_visibility,
// 366:                                     arg_types[0][1].raw_type,
// 367:                                     arg_types[1][1].raw_type,
// 368:                                     arg_types[2][1].raw_type,
// 369:                                     arg_types[3][1].raw_type)
// 370:     else
// 371:       raise 'should not happen'
// 372:     end
// 373:   end
// 374:
// 375:   def self.create_validator_method_skip_return_fast0(mod, original_method, method_sig, original_visibility)
// 376:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |&blk|
// 377:       # This method is a manually sped-up version of more general code in `validate_call`
// 378:       # The following line breaks are intentional to show nice pry message
// 379:
// 380:
// 381:
// 382:
// 383:
// 384:
// 385:
// 386:
// 387:
// 388:
// 389:       # PRY note:
// 390:       # this code is sig validation code.
// 391:       # Please issue `finish` to step out of it
// 392:
// 393:       original_method.bind_call(self, &blk)
// 394:     end
// 395:   end
// 396:
// 397:   def self.create_validator_method_skip_return_fast1(mod, original_method, method_sig, original_visibility, arg0_type)
// 398:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, &blk|
// 399:       # This method is a manually sped-up version of more general code in `validate_call`
// 400:       unless arg0.is_a?(arg0_type)
// 401:         CallValidation.report_error(
// 402:           method_sig,
// 403:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 404:           'Parameter',
// 405:           method_sig.arg_types[0][0],
// 406:           arg0_type,
// 407:           arg0,
// 408:           caller_offset: -1
// 409:         )
// 410:       end
// 411:
// 412:       # The following line breaks are intentional to show nice pry message
// 413:
// 414:
// 415:
// 416:
// 417:
// 418:
// 419:
// 420:
// 421:
// 422:
// 423:       # PRY note:
// 424:       # this code is sig validation code.
// 425:       # Please issue `finish` to step out of it
// 426:
// 427:       original_method.bind_call(self, arg0, &blk)
// 428:     end
// 429:   end
// 430:
// 431:   def self.create_validator_method_skip_return_fast2(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type)
// 432:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, &blk|
// 433:       # This method is a manually sped-up version of more general code in `validate_call`
// 434:       unless arg0.is_a?(arg0_type)
// 435:         CallValidation.report_error(
// 436:           method_sig,
// 437:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 438:           'Parameter',
// 439:           method_sig.arg_types[0][0],
// 440:           arg0_type,
// 441:           arg0,
// 442:           caller_offset: -1
// 443:         )
// 444:       end
// 445:
// 446:       unless arg1.is_a?(arg1_type)
// 447:         CallValidation.report_error(
// 448:           method_sig,
// 449:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 450:           'Parameter',
// 451:           method_sig.arg_types[1][0],
// 452:           arg1_type,
// 453:           arg1,
// 454:           caller_offset: -1
// 455:         )
// 456:       end
// 457:
// 458:       # The following line breaks are intentional to show nice pry message
// 459:
// 460:
// 461:
// 462:
// 463:
// 464:
// 465:
// 466:
// 467:
// 468:
// 469:       # PRY note:
// 470:       # this code is sig validation code.
// 471:       # Please issue `finish` to step out of it
// 472:
// 473:       original_method.bind_call(self, arg0, arg1, &blk)
// 474:     end
// 475:   end
// 476:
// 477:   def self.create_validator_method_skip_return_fast3(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type)
// 478:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, &blk|
// 479:       # This method is a manually sped-up version of more general code in `validate_call`
// 480:       unless arg0.is_a?(arg0_type)
// 481:         CallValidation.report_error(
// 482:           method_sig,
// 483:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 484:           'Parameter',
// 485:           method_sig.arg_types[0][0],
// 486:           arg0_type,
// 487:           arg0,
// 488:           caller_offset: -1
// 489:         )
// 490:       end
// 491:
// 492:       unless arg1.is_a?(arg1_type)
// 493:         CallValidation.report_error(
// 494:           method_sig,
// 495:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 496:           'Parameter',
// 497:           method_sig.arg_types[1][0],
// 498:           arg1_type,
// 499:           arg1,
// 500:           caller_offset: -1
// 501:         )
// 502:       end
// 503:
// 504:       unless arg2.is_a?(arg2_type)
// 505:         CallValidation.report_error(
// 506:           method_sig,
// 507:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 508:           'Parameter',
// 509:           method_sig.arg_types[2][0],
// 510:           arg2_type,
// 511:           arg2,
// 512:           caller_offset: -1
// 513:         )
// 514:       end
// 515:
// 516:       # The following line breaks are intentional to show nice pry message
// 517:
// 518:
// 519:
// 520:
// 521:
// 522:
// 523:
// 524:
// 525:
// 526:
// 527:       # PRY note:
// 528:       # this code is sig validation code.
// 529:       # Please issue `finish` to step out of it
// 530:
// 531:       original_method.bind_call(self, arg0, arg1, arg2, &blk)
// 532:     end
// 533:   end
// 534:
// 535:   def self.create_validator_method_skip_return_fast4(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type, arg3_type)
// 536:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, arg3, &blk|
// 537:       # This method is a manually sped-up version of more general code in `validate_call`
// 538:       unless arg0.is_a?(arg0_type)
// 539:         CallValidation.report_error(
// 540:           method_sig,
// 541:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 542:           'Parameter',
// 543:           method_sig.arg_types[0][0],
// 544:           arg0_type,
// 545:           arg0,
// 546:           caller_offset: -1
// 547:         )
// 548:       end
// 549:
// 550:       unless arg1.is_a?(arg1_type)
// 551:         CallValidation.report_error(
// 552:           method_sig,
// 553:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 554:           'Parameter',
// 555:           method_sig.arg_types[1][0],
// 556:           arg1_type,
// 557:           arg1,
// 558:           caller_offset: -1
// 559:         )
// 560:       end
// 561:
// 562:       unless arg2.is_a?(arg2_type)
// 563:         CallValidation.report_error(
// 564:           method_sig,
// 565:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 566:           'Parameter',
// 567:           method_sig.arg_types[2][0],
// 568:           arg2_type,
// 569:           arg2,
// 570:           caller_offset: -1
// 571:         )
// 572:       end
// 573:
// 574:       unless arg3.is_a?(arg3_type)
// 575:         CallValidation.report_error(
// 576:           method_sig,
// 577:           method_sig.arg_types[3][1].error_message_for_obj(arg3),
// 578:           'Parameter',
// 579:           method_sig.arg_types[3][0],
// 580:           arg3_type,
// 581:           arg3,
// 582:           caller_offset: -1
// 583:         )
// 584:       end
// 585:
// 586:       # The following line breaks are intentional to show nice pry message
// 587:
// 588:
// 589:
// 590:
// 591:
// 592:
// 593:
// 594:
// 595:
// 596:
// 597:       # PRY note:
// 598:       # this code is sig validation code.
// 599:       # Please issue `finish` to step out of it
// 600:
// 601:       original_method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
// 602:     end
// 603:   end
// 604:
// 605:   def self.create_validator_procedure_fast(mod, original_method, method_sig, original_visibility)
// 606:     # trampoline to reduce stack frame size
// 607:     arg_types = method_sig.arg_types
// 608:     case arg_types.length
// 609:     when 0
// 610:       create_validator_procedure_fast0(mod, original_method, method_sig, original_visibility)
// 611:     when 1
// 612:       create_validator_procedure_fast1(mod, original_method, method_sig, original_visibility,
// 613:                                     arg_types[0][1].raw_type)
// 614:     when 2
// 615:       create_validator_procedure_fast2(mod, original_method, method_sig, original_visibility,
// 616:                                     arg_types[0][1].raw_type,
// 617:                                     arg_types[1][1].raw_type)
// 618:     when 3
// 619:       create_validator_procedure_fast3(mod, original_method, method_sig, original_visibility,
// 620:                                     arg_types[0][1].raw_type,
// 621:                                     arg_types[1][1].raw_type,
// 622:                                     arg_types[2][1].raw_type)
// 623:     when 4
// 624:       create_validator_procedure_fast4(mod, original_method, method_sig, original_visibility,
// 625:                                     arg_types[0][1].raw_type,
// 626:                                     arg_types[1][1].raw_type,
// 627:                                     arg_types[2][1].raw_type,
// 628:                                     arg_types[3][1].raw_type)
// 629:     else
// 630:       raise 'should not happen'
// 631:     end
// 632:   end
// 633:
// 634:   def self.create_validator_procedure_fast0(mod, original_method, method_sig, original_visibility)
// 635:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |&blk|
// 636:       # This method is a manually sped-up version of more general code in `validate_call`
// 637:       # The following line breaks are intentional to show nice pry message
// 638:
// 639:
// 640:
// 641:
// 642:
// 643:
// 644:
// 645:
// 646:
// 647:
// 648:       # PRY note:
// 649:       # this code is sig validation code.
// 650:       # Please issue `finish` to step out of it
// 651:
// 652:       original_method.bind_call(self, &blk)
// 653:       T::Private::Types::Void::VOID
// 654:     end
// 655:   end
// 656:
// 657:   def self.create_validator_procedure_fast1(mod, original_method, method_sig, original_visibility, arg0_type)
// 658:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, &blk|
// 659:       # This method is a manually sped-up version of more general code in `validate_call`
// 660:       unless arg0.is_a?(arg0_type)
// 661:         CallValidation.report_error(
// 662:           method_sig,
// 663:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 664:           'Parameter',
// 665:           method_sig.arg_types[0][0],
// 666:           arg0_type,
// 667:           arg0,
// 668:           caller_offset: -1
// 669:         )
// 670:       end
// 671:
// 672:       # The following line breaks are intentional to show nice pry message
// 673:
// 674:
// 675:
// 676:
// 677:
// 678:
// 679:
// 680:
// 681:
// 682:
// 683:       # PRY note:
// 684:       # this code is sig validation code.
// 685:       # Please issue `finish` to step out of it
// 686:
// 687:       original_method.bind_call(self, arg0, &blk)
// 688:       T::Private::Types::Void::VOID
// 689:     end
// 690:   end
// 691:
// 692:   def self.create_validator_procedure_fast2(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type)
// 693:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, &blk|
// 694:       # This method is a manually sped-up version of more general code in `validate_call`
// 695:       unless arg0.is_a?(arg0_type)
// 696:         CallValidation.report_error(
// 697:           method_sig,
// 698:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 699:           'Parameter',
// 700:           method_sig.arg_types[0][0],
// 701:           arg0_type,
// 702:           arg0,
// 703:           caller_offset: -1
// 704:         )
// 705:       end
// 706:
// 707:       unless arg1.is_a?(arg1_type)
// 708:         CallValidation.report_error(
// 709:           method_sig,
// 710:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 711:           'Parameter',
// 712:           method_sig.arg_types[1][0],
// 713:           arg1_type,
// 714:           arg1,
// 715:           caller_offset: -1
// 716:         )
// 717:       end
// 718:
// 719:       # The following line breaks are intentional to show nice pry message
// 720:
// 721:
// 722:
// 723:
// 724:
// 725:
// 726:
// 727:
// 728:
// 729:
// 730:       # PRY note:
// 731:       # this code is sig validation code.
// 732:       # Please issue `finish` to step out of it
// 733:
// 734:       original_method.bind_call(self, arg0, arg1, &blk)
// 735:       T::Private::Types::Void::VOID
// 736:     end
// 737:   end
// 738:
// 739:   def self.create_validator_procedure_fast3(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type)
// 740:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, &blk|
// 741:       # This method is a manually sped-up version of more general code in `validate_call`
// 742:       unless arg0.is_a?(arg0_type)
// 743:         CallValidation.report_error(
// 744:           method_sig,
// 745:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 746:           'Parameter',
// 747:           method_sig.arg_types[0][0],
// 748:           arg0_type,
// 749:           arg0,
// 750:           caller_offset: -1
// 751:         )
// 752:       end
// 753:
// 754:       unless arg1.is_a?(arg1_type)
// 755:         CallValidation.report_error(
// 756:           method_sig,
// 757:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 758:           'Parameter',
// 759:           method_sig.arg_types[1][0],
// 760:           arg1_type,
// 761:           arg1,
// 762:           caller_offset: -1
// 763:         )
// 764:       end
// 765:
// 766:       unless arg2.is_a?(arg2_type)
// 767:         CallValidation.report_error(
// 768:           method_sig,
// 769:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 770:           'Parameter',
// 771:           method_sig.arg_types[2][0],
// 772:           arg2_type,
// 773:           arg2,
// 774:           caller_offset: -1
// 775:         )
// 776:       end
// 777:
// 778:       # The following line breaks are intentional to show nice pry message
// 779:
// 780:
// 781:
// 782:
// 783:
// 784:
// 785:
// 786:
// 787:
// 788:
// 789:       # PRY note:
// 790:       # this code is sig validation code.
// 791:       # Please issue `finish` to step out of it
// 792:
// 793:       original_method.bind_call(self, arg0, arg1, arg2, &blk)
// 794:       T::Private::Types::Void::VOID
// 795:     end
// 796:   end
// 797:
// 798:   def self.create_validator_procedure_fast4(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type, arg3_type)
// 799:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, arg3, &blk|
// 800:       # This method is a manually sped-up version of more general code in `validate_call`
// 801:       unless arg0.is_a?(arg0_type)
// 802:         CallValidation.report_error(
// 803:           method_sig,
// 804:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 805:           'Parameter',
// 806:           method_sig.arg_types[0][0],
// 807:           arg0_type,
// 808:           arg0,
// 809:           caller_offset: -1
// 810:         )
// 811:       end
// 812:
// 813:       unless arg1.is_a?(arg1_type)
// 814:         CallValidation.report_error(
// 815:           method_sig,
// 816:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 817:           'Parameter',
// 818:           method_sig.arg_types[1][0],
// 819:           arg1_type,
// 820:           arg1,
// 821:           caller_offset: -1
// 822:         )
// 823:       end
// 824:
// 825:       unless arg2.is_a?(arg2_type)
// 826:         CallValidation.report_error(
// 827:           method_sig,
// 828:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 829:           'Parameter',
// 830:           method_sig.arg_types[2][0],
// 831:           arg2_type,
// 832:           arg2,
// 833:           caller_offset: -1
// 834:         )
// 835:       end
// 836:
// 837:       unless arg3.is_a?(arg3_type)
// 838:         CallValidation.report_error(
// 839:           method_sig,
// 840:           method_sig.arg_types[3][1].error_message_for_obj(arg3),
// 841:           'Parameter',
// 842:           method_sig.arg_types[3][0],
// 843:           arg3_type,
// 844:           arg3,
// 845:           caller_offset: -1
// 846:         )
// 847:       end
// 848:
// 849:       # The following line breaks are intentional to show nice pry message
// 850:
// 851:
// 852:
// 853:
// 854:
// 855:
// 856:
// 857:
// 858:
// 859:
// 860:       # PRY note:
// 861:       # this code is sig validation code.
// 862:       # Please issue `finish` to step out of it
// 863:
// 864:       original_method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
// 865:       T::Private::Types::Void::VOID
// 866:     end
// 867:   end
// 868:
// 869:   def self.create_validator_method_medium(mod, original_method, method_sig, original_visibility)
// 870:     if method_sig.effective_return_type.is_a?(T::Private::Types::Void)
// 871:       raise 'Should have used create_validator_procedure_medium'
// 872:     end
// 873:     # trampoline to reduce stack frame size
// 874:     arg_types = method_sig.arg_types
// 875:     case arg_types.length
// 876:     when 0
// 877:       create_validator_method_medium0(mod, original_method, method_sig, original_visibility, method_sig.effective_return_type)
// 878:     when 1
// 879:       create_validator_method_medium1(mod, original_method, method_sig, original_visibility, method_sig.effective_return_type,
// 880:                                     arg_types[0][1])
// 881:     when 2
// 882:       create_validator_method_medium2(mod, original_method, method_sig, original_visibility, method_sig.effective_return_type,
// 883:                                     arg_types[0][1],
// 884:                                     arg_types[1][1])
// 885:     when 3
// 886:       create_validator_method_medium3(mod, original_method, method_sig, original_visibility, method_sig.effective_return_type,
// 887:                                     arg_types[0][1],
// 888:                                     arg_types[1][1],
// 889:                                     arg_types[2][1])
// 890:     when 4
// 891:       create_validator_method_medium4(mod, original_method, method_sig, original_visibility, method_sig.effective_return_type,
// 892:                                     arg_types[0][1],
// 893:                                     arg_types[1][1],
// 894:                                     arg_types[2][1],
// 895:                                     arg_types[3][1])
// 896:     else
// 897:       raise 'should not happen'
// 898:     end
// 899:   end
// 900:
// 901:   def self.create_validator_method_medium0(mod, original_method, method_sig, original_visibility, return_type)
// 902:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |&blk|
// 903:       # This method is a manually sped-up version of more general code in `validate_call`
// 904:       # The following line breaks are intentional to show nice pry message
// 905:
// 906:
// 907:
// 908:
// 909:
// 910:
// 911:
// 912:
// 913:
// 914:
// 915:       # PRY note:
// 916:       # this code is sig validation code.
// 917:       # Please issue `finish` to step out of it
// 918:
// 919:       return_value = original_method.bind_call(self, &blk)
// 920:       unless return_type.valid?(return_value)
// 921:         message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 922:         if message
// 923:           CallValidation.report_error(
// 924:             method_sig,
// 925:             message,
// 926:             'Return value',
// 927:             nil,
// 928:             method_sig.effective_return_type,
// 929:             return_value,
// 930:             caller_offset: -1
// 931:           )
// 932:         end
// 933:       end
// 934:       return_value
// 935:     end
// 936:   end
// 937:
// 938:   def self.create_validator_method_medium1(mod, original_method, method_sig, original_visibility, return_type, arg0_type)
// 939:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, &blk|
// 940:       # This method is a manually sped-up version of more general code in `validate_call`
// 941:       unless arg0_type.valid?(arg0)
// 942:         CallValidation.report_error(
// 943:           method_sig,
// 944:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 945:           'Parameter',
// 946:           method_sig.arg_types[0][0],
// 947:           arg0_type,
// 948:           arg0,
// 949:           caller_offset: -1
// 950:         )
// 951:       end
// 952:
// 953:       # The following line breaks are intentional to show nice pry message
// 954:
// 955:
// 956:
// 957:
// 958:
// 959:
// 960:
// 961:
// 962:
// 963:
// 964:       # PRY note:
// 965:       # this code is sig validation code.
// 966:       # Please issue `finish` to step out of it
// 967:
// 968:       return_value = original_method.bind_call(self, arg0, &blk)
// 969:       unless return_type.valid?(return_value)
// 970:         message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 971:         if message
// 972:           CallValidation.report_error(
// 973:             method_sig,
// 974:             message,
// 975:             'Return value',
// 976:             nil,
// 977:             method_sig.effective_return_type,
// 978:             return_value,
// 979:             caller_offset: -1
// 980:           )
// 981:         end
// 982:       end
// 983:       return_value
// 984:     end
// 985:   end
// 986:
// 987:   def self.create_validator_method_medium2(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type)
// 988:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, &blk|
// 989:       # This method is a manually sped-up version of more general code in `validate_call`
// 990:       unless arg0_type.valid?(arg0)
// 991:         CallValidation.report_error(
// 992:           method_sig,
// 993:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 994:           'Parameter',
// 995:           method_sig.arg_types[0][0],
// 996:           arg0_type,
// 997:           arg0,
// 998:           caller_offset: -1
// 999:         )
// 1000:       end
// 1001:
// 1002:       unless arg1_type.valid?(arg1)
// 1003:         CallValidation.report_error(
// 1004:           method_sig,
// 1005:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1006:           'Parameter',
// 1007:           method_sig.arg_types[1][0],
// 1008:           arg1_type,
// 1009:           arg1,
// 1010:           caller_offset: -1
// 1011:         )
// 1012:       end
// 1013:
// 1014:       # The following line breaks are intentional to show nice pry message
// 1015:
// 1016:
// 1017:
// 1018:
// 1019:
// 1020:
// 1021:
// 1022:
// 1023:
// 1024:
// 1025:       # PRY note:
// 1026:       # this code is sig validation code.
// 1027:       # Please issue `finish` to step out of it
// 1028:
// 1029:       return_value = original_method.bind_call(self, arg0, arg1, &blk)
// 1030:       unless return_type.valid?(return_value)
// 1031:         message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 1032:         if message
// 1033:           CallValidation.report_error(
// 1034:             method_sig,
// 1035:             message,
// 1036:             'Return value',
// 1037:             nil,
// 1038:             method_sig.effective_return_type,
// 1039:             return_value,
// 1040:             caller_offset: -1
// 1041:           )
// 1042:         end
// 1043:       end
// 1044:       return_value
// 1045:     end
// 1046:   end
// 1047:
// 1048:   def self.create_validator_method_medium3(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type)
// 1049:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, &blk|
// 1050:       # This method is a manually sped-up version of more general code in `validate_call`
// 1051:       unless arg0_type.valid?(arg0)
// 1052:         CallValidation.report_error(
// 1053:           method_sig,
// 1054:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1055:           'Parameter',
// 1056:           method_sig.arg_types[0][0],
// 1057:           arg0_type,
// 1058:           arg0,
// 1059:           caller_offset: -1
// 1060:         )
// 1061:       end
// 1062:
// 1063:       unless arg1_type.valid?(arg1)
// 1064:         CallValidation.report_error(
// 1065:           method_sig,
// 1066:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1067:           'Parameter',
// 1068:           method_sig.arg_types[1][0],
// 1069:           arg1_type,
// 1070:           arg1,
// 1071:           caller_offset: -1
// 1072:         )
// 1073:       end
// 1074:
// 1075:       unless arg2_type.valid?(arg2)
// 1076:         CallValidation.report_error(
// 1077:           method_sig,
// 1078:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 1079:           'Parameter',
// 1080:           method_sig.arg_types[2][0],
// 1081:           arg2_type,
// 1082:           arg2,
// 1083:           caller_offset: -1
// 1084:         )
// 1085:       end
// 1086:
// 1087:       # The following line breaks are intentional to show nice pry message
// 1088:
// 1089:
// 1090:
// 1091:
// 1092:
// 1093:
// 1094:
// 1095:
// 1096:
// 1097:
// 1098:       # PRY note:
// 1099:       # this code is sig validation code.
// 1100:       # Please issue `finish` to step out of it
// 1101:
// 1102:       return_value = original_method.bind_call(self, arg0, arg1, arg2, &blk)
// 1103:       unless return_type.valid?(return_value)
// 1104:         message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 1105:         if message
// 1106:           CallValidation.report_error(
// 1107:             method_sig,
// 1108:             message,
// 1109:             'Return value',
// 1110:             nil,
// 1111:             method_sig.effective_return_type,
// 1112:             return_value,
// 1113:             caller_offset: -1
// 1114:           )
// 1115:         end
// 1116:       end
// 1117:       return_value
// 1118:     end
// 1119:   end
// 1120:
// 1121:   def self.create_validator_method_medium4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)
// 1122:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, arg3, &blk|
// 1123:       # This method is a manually sped-up version of more general code in `validate_call`
// 1124:       unless arg0_type.valid?(arg0)
// 1125:         CallValidation.report_error(
// 1126:           method_sig,
// 1127:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1128:           'Parameter',
// 1129:           method_sig.arg_types[0][0],
// 1130:           arg0_type,
// 1131:           arg0,
// 1132:           caller_offset: -1
// 1133:         )
// 1134:       end
// 1135:
// 1136:       unless arg1_type.valid?(arg1)
// 1137:         CallValidation.report_error(
// 1138:           method_sig,
// 1139:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1140:           'Parameter',
// 1141:           method_sig.arg_types[1][0],
// 1142:           arg1_type,
// 1143:           arg1,
// 1144:           caller_offset: -1
// 1145:         )
// 1146:       end
// 1147:
// 1148:       unless arg2_type.valid?(arg2)
// 1149:         CallValidation.report_error(
// 1150:           method_sig,
// 1151:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 1152:           'Parameter',
// 1153:           method_sig.arg_types[2][0],
// 1154:           arg2_type,
// 1155:           arg2,
// 1156:           caller_offset: -1
// 1157:         )
// 1158:       end
// 1159:
// 1160:       unless arg3_type.valid?(arg3)
// 1161:         CallValidation.report_error(
// 1162:           method_sig,
// 1163:           method_sig.arg_types[3][1].error_message_for_obj(arg3),
// 1164:           'Parameter',
// 1165:           method_sig.arg_types[3][0],
// 1166:           arg3_type,
// 1167:           arg3,
// 1168:           caller_offset: -1
// 1169:         )
// 1170:       end
// 1171:
// 1172:       # The following line breaks are intentional to show nice pry message
// 1173:
// 1174:
// 1175:
// 1176:
// 1177:
// 1178:
// 1179:
// 1180:
// 1181:
// 1182:
// 1183:       # PRY note:
// 1184:       # this code is sig validation code.
// 1185:       # Please issue `finish` to step out of it
// 1186:
// 1187:       return_value = original_method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
// 1188:       unless return_type.valid?(return_value)
// 1189:         message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 1190:         if message
// 1191:           CallValidation.report_error(
// 1192:             method_sig,
// 1193:             message,
// 1194:             'Return value',
// 1195:             nil,
// 1196:             method_sig.effective_return_type,
// 1197:             return_value,
// 1198:             caller_offset: -1
// 1199:           )
// 1200:         end
// 1201:       end
// 1202:       return_value
// 1203:     end
// 1204:   end
// 1205:
// 1206:   def self.create_validator_method_skip_return_medium(mod, original_method, method_sig, original_visibility)
// 1207:     # trampoline to reduce stack frame size
// 1208:     arg_types = method_sig.arg_types
// 1209:     case arg_types.length
// 1210:     when 0
// 1211:       create_validator_method_skip_return_medium0(mod, original_method, method_sig, original_visibility)
// 1212:     when 1
// 1213:       create_validator_method_skip_return_medium1(mod, original_method, method_sig, original_visibility,
// 1214:                                     arg_types[0][1])
// 1215:     when 2
// 1216:       create_validator_method_skip_return_medium2(mod, original_method, method_sig, original_visibility,
// 1217:                                     arg_types[0][1],
// 1218:                                     arg_types[1][1])
// 1219:     when 3
// 1220:       create_validator_method_skip_return_medium3(mod, original_method, method_sig, original_visibility,
// 1221:                                     arg_types[0][1],
// 1222:                                     arg_types[1][1],
// 1223:                                     arg_types[2][1])
// 1224:     when 4
// 1225:       create_validator_method_skip_return_medium4(mod, original_method, method_sig, original_visibility,
// 1226:                                     arg_types[0][1],
// 1227:                                     arg_types[1][1],
// 1228:                                     arg_types[2][1],
// 1229:                                     arg_types[3][1])
// 1230:     else
// 1231:       raise 'should not happen'
// 1232:     end
// 1233:   end
// 1234:
// 1235:   def self.create_validator_method_skip_return_medium0(mod, original_method, method_sig, original_visibility)
// 1236:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |&blk|
// 1237:       # This method is a manually sped-up version of more general code in `validate_call`
// 1238:       # The following line breaks are intentional to show nice pry message
// 1239:
// 1240:
// 1241:
// 1242:
// 1243:
// 1244:
// 1245:
// 1246:
// 1247:
// 1248:
// 1249:       # PRY note:
// 1250:       # this code is sig validation code.
// 1251:       # Please issue `finish` to step out of it
// 1252:
// 1253:       original_method.bind_call(self, &blk)
// 1254:     end
// 1255:   end
// 1256:
// 1257:   def self.create_validator_method_skip_return_medium1(mod, original_method, method_sig, original_visibility, arg0_type)
// 1258:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, &blk|
// 1259:       # This method is a manually sped-up version of more general code in `validate_call`
// 1260:       unless arg0_type.valid?(arg0)
// 1261:         CallValidation.report_error(
// 1262:           method_sig,
// 1263:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1264:           'Parameter',
// 1265:           method_sig.arg_types[0][0],
// 1266:           arg0_type,
// 1267:           arg0,
// 1268:           caller_offset: -1
// 1269:         )
// 1270:       end
// 1271:
// 1272:       # The following line breaks are intentional to show nice pry message
// 1273:
// 1274:
// 1275:
// 1276:
// 1277:
// 1278:
// 1279:
// 1280:
// 1281:
// 1282:
// 1283:       # PRY note:
// 1284:       # this code is sig validation code.
// 1285:       # Please issue `finish` to step out of it
// 1286:
// 1287:       original_method.bind_call(self, arg0, &blk)
// 1288:     end
// 1289:   end
// 1290:
// 1291:   def self.create_validator_method_skip_return_medium2(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type)
// 1292:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, &blk|
// 1293:       # This method is a manually sped-up version of more general code in `validate_call`
// 1294:       unless arg0_type.valid?(arg0)
// 1295:         CallValidation.report_error(
// 1296:           method_sig,
// 1297:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1298:           'Parameter',
// 1299:           method_sig.arg_types[0][0],
// 1300:           arg0_type,
// 1301:           arg0,
// 1302:           caller_offset: -1
// 1303:         )
// 1304:       end
// 1305:
// 1306:       unless arg1_type.valid?(arg1)
// 1307:         CallValidation.report_error(
// 1308:           method_sig,
// 1309:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1310:           'Parameter',
// 1311:           method_sig.arg_types[1][0],
// 1312:           arg1_type,
// 1313:           arg1,
// 1314:           caller_offset: -1
// 1315:         )
// 1316:       end
// 1317:
// 1318:       # The following line breaks are intentional to show nice pry message
// 1319:
// 1320:
// 1321:
// 1322:
// 1323:
// 1324:
// 1325:
// 1326:
// 1327:
// 1328:
// 1329:       # PRY note:
// 1330:       # this code is sig validation code.
// 1331:       # Please issue `finish` to step out of it
// 1332:
// 1333:       original_method.bind_call(self, arg0, arg1, &blk)
// 1334:     end
// 1335:   end
// 1336:
// 1337:   def self.create_validator_method_skip_return_medium3(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type)
// 1338:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, &blk|
// 1339:       # This method is a manually sped-up version of more general code in `validate_call`
// 1340:       unless arg0_type.valid?(arg0)
// 1341:         CallValidation.report_error(
// 1342:           method_sig,
// 1343:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1344:           'Parameter',
// 1345:           method_sig.arg_types[0][0],
// 1346:           arg0_type,
// 1347:           arg0,
// 1348:           caller_offset: -1
// 1349:         )
// 1350:       end
// 1351:
// 1352:       unless arg1_type.valid?(arg1)
// 1353:         CallValidation.report_error(
// 1354:           method_sig,
// 1355:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1356:           'Parameter',
// 1357:           method_sig.arg_types[1][0],
// 1358:           arg1_type,
// 1359:           arg1,
// 1360:           caller_offset: -1
// 1361:         )
// 1362:       end
// 1363:
// 1364:       unless arg2_type.valid?(arg2)
// 1365:         CallValidation.report_error(
// 1366:           method_sig,
// 1367:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 1368:           'Parameter',
// 1369:           method_sig.arg_types[2][0],
// 1370:           arg2_type,
// 1371:           arg2,
// 1372:           caller_offset: -1
// 1373:         )
// 1374:       end
// 1375:
// 1376:       # The following line breaks are intentional to show nice pry message
// 1377:
// 1378:
// 1379:
// 1380:
// 1381:
// 1382:
// 1383:
// 1384:
// 1385:
// 1386:
// 1387:       # PRY note:
// 1388:       # this code is sig validation code.
// 1389:       # Please issue `finish` to step out of it
// 1390:
// 1391:       original_method.bind_call(self, arg0, arg1, arg2, &blk)
// 1392:     end
// 1393:   end
// 1394:
// 1395:   def self.create_validator_method_skip_return_medium4(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type, arg3_type)
// 1396:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, arg3, &blk|
// 1397:       # This method is a manually sped-up version of more general code in `validate_call`
// 1398:       unless arg0_type.valid?(arg0)
// 1399:         CallValidation.report_error(
// 1400:           method_sig,
// 1401:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1402:           'Parameter',
// 1403:           method_sig.arg_types[0][0],
// 1404:           arg0_type,
// 1405:           arg0,
// 1406:           caller_offset: -1
// 1407:         )
// 1408:       end
// 1409:
// 1410:       unless arg1_type.valid?(arg1)
// 1411:         CallValidation.report_error(
// 1412:           method_sig,
// 1413:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1414:           'Parameter',
// 1415:           method_sig.arg_types[1][0],
// 1416:           arg1_type,
// 1417:           arg1,
// 1418:           caller_offset: -1
// 1419:         )
// 1420:       end
// 1421:
// 1422:       unless arg2_type.valid?(arg2)
// 1423:         CallValidation.report_error(
// 1424:           method_sig,
// 1425:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 1426:           'Parameter',
// 1427:           method_sig.arg_types[2][0],
// 1428:           arg2_type,
// 1429:           arg2,
// 1430:           caller_offset: -1
// 1431:         )
// 1432:       end
// 1433:
// 1434:       unless arg3_type.valid?(arg3)
// 1435:         CallValidation.report_error(
// 1436:           method_sig,
// 1437:           method_sig.arg_types[3][1].error_message_for_obj(arg3),
// 1438:           'Parameter',
// 1439:           method_sig.arg_types[3][0],
// 1440:           arg3_type,
// 1441:           arg3,
// 1442:           caller_offset: -1
// 1443:         )
// 1444:       end
// 1445:
// 1446:       # The following line breaks are intentional to show nice pry message
// 1447:
// 1448:
// 1449:
// 1450:
// 1451:
// 1452:
// 1453:
// 1454:
// 1455:
// 1456:
// 1457:       # PRY note:
// 1458:       # this code is sig validation code.
// 1459:       # Please issue `finish` to step out of it
// 1460:
// 1461:       original_method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
// 1462:     end
// 1463:   end
// 1464:
// 1465:   def self.create_validator_procedure_medium(mod, original_method, method_sig, original_visibility)
// 1466:     # trampoline to reduce stack frame size
// 1467:     arg_types = method_sig.arg_types
// 1468:     case arg_types.length
// 1469:     when 0
// 1470:       create_validator_procedure_medium0(mod, original_method, method_sig, original_visibility)
// 1471:     when 1
// 1472:       create_validator_procedure_medium1(mod, original_method, method_sig, original_visibility,
// 1473:                                     arg_types[0][1])
// 1474:     when 2
// 1475:       create_validator_procedure_medium2(mod, original_method, method_sig, original_visibility,
// 1476:                                     arg_types[0][1],
// 1477:                                     arg_types[1][1])
// 1478:     when 3
// 1479:       create_validator_procedure_medium3(mod, original_method, method_sig, original_visibility,
// 1480:                                     arg_types[0][1],
// 1481:                                     arg_types[1][1],
// 1482:                                     arg_types[2][1])
// 1483:     when 4
// 1484:       create_validator_procedure_medium4(mod, original_method, method_sig, original_visibility,
// 1485:                                     arg_types[0][1],
// 1486:                                     arg_types[1][1],
// 1487:                                     arg_types[2][1],
// 1488:                                     arg_types[3][1])
// 1489:     else
// 1490:       raise 'should not happen'
// 1491:     end
// 1492:   end
// 1493:
// 1494:   def self.create_validator_procedure_medium0(mod, original_method, method_sig, original_visibility)
// 1495:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |&blk|
// 1496:       # This method is a manually sped-up version of more general code in `validate_call`
// 1497:       # The following line breaks are intentional to show nice pry message
// 1498:
// 1499:
// 1500:
// 1501:
// 1502:
// 1503:
// 1504:
// 1505:
// 1506:
// 1507:
// 1508:       # PRY note:
// 1509:       # this code is sig validation code.
// 1510:       # Please issue `finish` to step out of it
// 1511:
// 1512:       original_method.bind_call(self, &blk)
// 1513:       T::Private::Types::Void::VOID
// 1514:     end
// 1515:   end
// 1516:
// 1517:   def self.create_validator_procedure_medium1(mod, original_method, method_sig, original_visibility, arg0_type)
// 1518:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, &blk|
// 1519:       # This method is a manually sped-up version of more general code in `validate_call`
// 1520:       unless arg0_type.valid?(arg0)
// 1521:         CallValidation.report_error(
// 1522:           method_sig,
// 1523:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1524:           'Parameter',
// 1525:           method_sig.arg_types[0][0],
// 1526:           arg0_type,
// 1527:           arg0,
// 1528:           caller_offset: -1
// 1529:         )
// 1530:       end
// 1531:
// 1532:       # The following line breaks are intentional to show nice pry message
// 1533:
// 1534:
// 1535:
// 1536:
// 1537:
// 1538:
// 1539:
// 1540:
// 1541:
// 1542:
// 1543:       # PRY note:
// 1544:       # this code is sig validation code.
// 1545:       # Please issue `finish` to step out of it
// 1546:
// 1547:       original_method.bind_call(self, arg0, &blk)
// 1548:       T::Private::Types::Void::VOID
// 1549:     end
// 1550:   end
// 1551:
// 1552:   def self.create_validator_procedure_medium2(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type)
// 1553:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, &blk|
// 1554:       # This method is a manually sped-up version of more general code in `validate_call`
// 1555:       unless arg0_type.valid?(arg0)
// 1556:         CallValidation.report_error(
// 1557:           method_sig,
// 1558:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1559:           'Parameter',
// 1560:           method_sig.arg_types[0][0],
// 1561:           arg0_type,
// 1562:           arg0,
// 1563:           caller_offset: -1
// 1564:         )
// 1565:       end
// 1566:
// 1567:       unless arg1_type.valid?(arg1)
// 1568:         CallValidation.report_error(
// 1569:           method_sig,
// 1570:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1571:           'Parameter',
// 1572:           method_sig.arg_types[1][0],
// 1573:           arg1_type,
// 1574:           arg1,
// 1575:           caller_offset: -1
// 1576:         )
// 1577:       end
// 1578:
// 1579:       # The following line breaks are intentional to show nice pry message
// 1580:
// 1581:
// 1582:
// 1583:
// 1584:
// 1585:
// 1586:
// 1587:
// 1588:
// 1589:
// 1590:       # PRY note:
// 1591:       # this code is sig validation code.
// 1592:       # Please issue `finish` to step out of it
// 1593:
// 1594:       original_method.bind_call(self, arg0, arg1, &blk)
// 1595:       T::Private::Types::Void::VOID
// 1596:     end
// 1597:   end
// 1598:
// 1599:   def self.create_validator_procedure_medium3(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type)
// 1600:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, &blk|
// 1601:       # This method is a manually sped-up version of more general code in `validate_call`
// 1602:       unless arg0_type.valid?(arg0)
// 1603:         CallValidation.report_error(
// 1604:           method_sig,
// 1605:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1606:           'Parameter',
// 1607:           method_sig.arg_types[0][0],
// 1608:           arg0_type,
// 1609:           arg0,
// 1610:           caller_offset: -1
// 1611:         )
// 1612:       end
// 1613:
// 1614:       unless arg1_type.valid?(arg1)
// 1615:         CallValidation.report_error(
// 1616:           method_sig,
// 1617:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1618:           'Parameter',
// 1619:           method_sig.arg_types[1][0],
// 1620:           arg1_type,
// 1621:           arg1,
// 1622:           caller_offset: -1
// 1623:         )
// 1624:       end
// 1625:
// 1626:       unless arg2_type.valid?(arg2)
// 1627:         CallValidation.report_error(
// 1628:           method_sig,
// 1629:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 1630:           'Parameter',
// 1631:           method_sig.arg_types[2][0],
// 1632:           arg2_type,
// 1633:           arg2,
// 1634:           caller_offset: -1
// 1635:         )
// 1636:       end
// 1637:
// 1638:       # The following line breaks are intentional to show nice pry message
// 1639:
// 1640:
// 1641:
// 1642:
// 1643:
// 1644:
// 1645:
// 1646:
// 1647:
// 1648:
// 1649:       # PRY note:
// 1650:       # this code is sig validation code.
// 1651:       # Please issue `finish` to step out of it
// 1652:
// 1653:       original_method.bind_call(self, arg0, arg1, arg2, &blk)
// 1654:       T::Private::Types::Void::VOID
// 1655:     end
// 1656:   end
// 1657:
// 1658:   def self.create_validator_procedure_medium4(mod, original_method, method_sig, original_visibility, arg0_type, arg1_type, arg2_type, arg3_type)
// 1659:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, arg3, &blk|
// 1660:       # This method is a manually sped-up version of more general code in `validate_call`
// 1661:       unless arg0_type.valid?(arg0)
// 1662:         CallValidation.report_error(
// 1663:           method_sig,
// 1664:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1665:           'Parameter',
// 1666:           method_sig.arg_types[0][0],
// 1667:           arg0_type,
// 1668:           arg0,
// 1669:           caller_offset: -1
// 1670:         )
// 1671:       end
// 1672:
// 1673:       unless arg1_type.valid?(arg1)
// 1674:         CallValidation.report_error(
// 1675:           method_sig,
// 1676:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1677:           'Parameter',
// 1678:           method_sig.arg_types[1][0],
// 1679:           arg1_type,
// 1680:           arg1,
// 1681:           caller_offset: -1
// 1682:         )
// 1683:       end
// 1684:
// 1685:       unless arg2_type.valid?(arg2)
// 1686:         CallValidation.report_error(
// 1687:           method_sig,
// 1688:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 1689:           'Parameter',
// 1690:           method_sig.arg_types[2][0],
// 1691:           arg2_type,
// 1692:           arg2,
// 1693:           caller_offset: -1
// 1694:         )
// 1695:       end
// 1696:
// 1697:       unless arg3_type.valid?(arg3)
// 1698:         CallValidation.report_error(
// 1699:           method_sig,
// 1700:           method_sig.arg_types[3][1].error_message_for_obj(arg3),
// 1701:           'Parameter',
// 1702:           method_sig.arg_types[3][0],
// 1703:           arg3_type,
// 1704:           arg3,
// 1705:           caller_offset: -1
// 1706:         )
// 1707:       end
// 1708:
// 1709:       # The following line breaks are intentional to show nice pry message
// 1710:
// 1711:
// 1712:
// 1713:
// 1714:
// 1715:
// 1716:
// 1717:
// 1718:
// 1719:
// 1720:       # PRY note:
// 1721:       # this code is sig validation code.
// 1722:       # Please issue `finish` to step out of it
// 1723:
// 1724:       original_method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
// 1725:       T::Private::Types::Void::VOID
// 1726:     end
// 1727:   end
// 1728:
// 1729:   def self.create_validator_method_kwargs(mod, original_method, method_sig, original_visibility)
// 1730:     return_type = method_sig.effective_return_type
// 1731:     return_type = nil if return_type.is_a?(T::Private::Types::Void)
// 1732:     create_validator_method_kwargs0(mod, original_method, method_sig, original_visibility, return_type, method_sig.kwarg_types)
// 1733:   end
// 1734:
// 1735:   def self.create_validator_method_kwargs0(mod, original_method, method_sig, original_visibility, return_type, kwarg_types)
// 1736:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |**kwargs, &blk|
// 1737:       # This method is a manually sped-up version of more general code in `validate_call`
// 1738:       # NOTE: like `validate_call`, we don't validate for missing or extra
// 1739:       # kwargs; the `bind_call` below takes care of that.
// 1740:       kwargs.each do |name, val|
// 1741:         type = kwarg_types[name]
// 1742:         next unless type
// 1743:         next if type.valid?(val)
// 1744:         CallValidation.report_error(
// 1745:           method_sig,
// 1746:           type.error_message_for_obj(val),
// 1747:           'Parameter',
// 1748:           name,
// 1749:           type,
// 1750:           val,
// 1751:           caller_offset: 1
// 1752:         )
// 1753:       end
// 1754:       return_value = original_method.bind_call(self, **kwargs, &blk)
// 1755:       if return_type.nil?
// 1756:         T::Private::Types::Void::VOID
// 1757:       else
// 1758:         unless return_type.valid?(return_value)
// 1759:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 1760:           if message
// 1761:             CallValidation.report_error(
// 1762:               method_sig,
// 1763:               message,
// 1764:               'Return value',
// 1765:               nil,
// 1766:               method_sig.effective_return_type,
// 1767:               return_value,
// 1768:               caller_offset: -1
// 1769:             )
// 1770:           end
// 1771:         end
// 1772:         return_value
// 1773:       end
// 1774:     end
// 1775:   end
// 1776:
// 1777:   def self.create_validator_method_with_block(mod, original_method, method_sig, original_visibility)
// 1778:     return_type = method_sig.effective_return_type
// 1779:     return_type = nil if return_type.is_a?(T::Private::Types::Void)
// 1780:     block_type = method_sig.block_type
// 1781:     # trampoline to reduce stack frame size
// 1782:     arg_types = method_sig.arg_types
// 1783:     case arg_types.length
// 1784:     when 0
// 1785:       create_validator_method_with_block0(mod, original_method, method_sig, original_visibility, return_type, block_type)
// 1786:     when 1
// 1787:       create_validator_method_with_block1(mod, original_method, method_sig, original_visibility, return_type, block_type,
// 1788:                                           arg_types[0][1])
// 1789:     when 2
// 1790:       create_validator_method_with_block2(mod, original_method, method_sig, original_visibility, return_type, block_type,
// 1791:                                           arg_types[0][1],
// 1792:                                           arg_types[1][1])
// 1793:     when 3
// 1794:       create_validator_method_with_block3(mod, original_method, method_sig, original_visibility, return_type, block_type,
// 1795:                                           arg_types[0][1],
// 1796:                                           arg_types[1][1],
// 1797:                                           arg_types[2][1])
// 1798:     when 4
// 1799:       create_validator_method_with_block4(mod, original_method, method_sig, original_visibility, return_type, block_type,
// 1800:                                           arg_types[0][1],
// 1801:                                           arg_types[1][1],
// 1802:                                           arg_types[2][1],
// 1803:                                           arg_types[3][1])
// 1804:     else
// 1805:       raise 'should not happen'
// 1806:     end
// 1807:   end
// 1808:
// 1809:   def self.create_validator_method_with_block0(mod, original_method, method_sig, original_visibility, return_type, block_type)
// 1810:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |&blk|
// 1811:       # This method is a manually sped-up version of more general code in `validate_call`
// 1812:       if blk.nil?
// 1813:         CallValidation.report_error(
// 1814:           method_sig,
// 1815:           block_type.error_message_for_obj(blk),
// 1816:           'Block parameter',
// 1817:           method_sig.block_name,
// 1818:           block_type,
// 1819:           blk,
// 1820:           caller_offset: -1
// 1821:         )
// 1822:       end
// 1823:       return_value = original_method.bind_call(self, &blk)
// 1824:       if return_type.nil?
// 1825:         T::Private::Types::Void::VOID
// 1826:       else
// 1827:         unless return_type.valid?(return_value)
// 1828:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 1829:           if message
// 1830:             CallValidation.report_error(
// 1831:               method_sig,
// 1832:               message,
// 1833:               'Return value',
// 1834:               nil,
// 1835:               method_sig.effective_return_type,
// 1836:               return_value,
// 1837:               caller_offset: -1
// 1838:             )
// 1839:           end
// 1840:         end
// 1841:         return_value
// 1842:       end
// 1843:     end
// 1844:   end
// 1845:
// 1846:   def self.create_validator_method_with_block1(mod, original_method, method_sig, original_visibility, return_type, block_type, arg0_type)
// 1847:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, &blk|
// 1848:       # This method is a manually sped-up version of more general code in `validate_call`
// 1849:       unless arg0_type.valid?(arg0)
// 1850:         CallValidation.report_error(
// 1851:           method_sig,
// 1852:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1853:           'Parameter',
// 1854:           method_sig.arg_types[0][0],
// 1855:           arg0_type,
// 1856:           arg0,
// 1857:           caller_offset: -1
// 1858:         )
// 1859:       end
// 1860:       if blk.nil?
// 1861:         CallValidation.report_error(
// 1862:           method_sig,
// 1863:           block_type.error_message_for_obj(blk),
// 1864:           'Block parameter',
// 1865:           method_sig.block_name,
// 1866:           block_type,
// 1867:           blk,
// 1868:           caller_offset: -1
// 1869:         )
// 1870:       end
// 1871:       return_value = original_method.bind_call(self, arg0, &blk)
// 1872:       if return_type.nil?
// 1873:         T::Private::Types::Void::VOID
// 1874:       else
// 1875:         unless return_type.valid?(return_value)
// 1876:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 1877:           if message
// 1878:             CallValidation.report_error(
// 1879:               method_sig,
// 1880:               message,
// 1881:               'Return value',
// 1882:               nil,
// 1883:               method_sig.effective_return_type,
// 1884:               return_value,
// 1885:               caller_offset: -1
// 1886:             )
// 1887:           end
// 1888:         end
// 1889:         return_value
// 1890:       end
// 1891:     end
// 1892:   end
// 1893:
// 1894:   def self.create_validator_method_with_block2(mod, original_method, method_sig, original_visibility, return_type, block_type, arg0_type, arg1_type)
// 1895:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, &blk|
// 1896:       # This method is a manually sped-up version of more general code in `validate_call`
// 1897:       unless arg0_type.valid?(arg0)
// 1898:         CallValidation.report_error(
// 1899:           method_sig,
// 1900:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1901:           'Parameter',
// 1902:           method_sig.arg_types[0][0],
// 1903:           arg0_type,
// 1904:           arg0,
// 1905:           caller_offset: -1
// 1906:         )
// 1907:       end
// 1908:       unless arg1_type.valid?(arg1)
// 1909:         CallValidation.report_error(
// 1910:           method_sig,
// 1911:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1912:           'Parameter',
// 1913:           method_sig.arg_types[1][0],
// 1914:           arg1_type,
// 1915:           arg1,
// 1916:           caller_offset: -1
// 1917:         )
// 1918:       end
// 1919:       if blk.nil?
// 1920:         CallValidation.report_error(
// 1921:           method_sig,
// 1922:           block_type.error_message_for_obj(blk),
// 1923:           'Block parameter',
// 1924:           method_sig.block_name,
// 1925:           block_type,
// 1926:           blk,
// 1927:           caller_offset: -1
// 1928:         )
// 1929:       end
// 1930:       return_value = original_method.bind_call(self, arg0, arg1, &blk)
// 1931:       if return_type.nil?
// 1932:         T::Private::Types::Void::VOID
// 1933:       else
// 1934:         unless return_type.valid?(return_value)
// 1935:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 1936:           if message
// 1937:             CallValidation.report_error(
// 1938:               method_sig,
// 1939:               message,
// 1940:               'Return value',
// 1941:               nil,
// 1942:               method_sig.effective_return_type,
// 1943:               return_value,
// 1944:               caller_offset: -1
// 1945:             )
// 1946:           end
// 1947:         end
// 1948:         return_value
// 1949:       end
// 1950:     end
// 1951:   end
// 1952:
// 1953:   def self.create_validator_method_with_block3(mod, original_method, method_sig, original_visibility, return_type, block_type, arg0_type, arg1_type, arg2_type)
// 1954:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, &blk|
// 1955:       # This method is a manually sped-up version of more general code in `validate_call`
// 1956:       unless arg0_type.valid?(arg0)
// 1957:         CallValidation.report_error(
// 1958:           method_sig,
// 1959:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 1960:           'Parameter',
// 1961:           method_sig.arg_types[0][0],
// 1962:           arg0_type,
// 1963:           arg0,
// 1964:           caller_offset: -1
// 1965:         )
// 1966:       end
// 1967:       unless arg1_type.valid?(arg1)
// 1968:         CallValidation.report_error(
// 1969:           method_sig,
// 1970:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 1971:           'Parameter',
// 1972:           method_sig.arg_types[1][0],
// 1973:           arg1_type,
// 1974:           arg1,
// 1975:           caller_offset: -1
// 1976:         )
// 1977:       end
// 1978:       unless arg2_type.valid?(arg2)
// 1979:         CallValidation.report_error(
// 1980:           method_sig,
// 1981:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 1982:           'Parameter',
// 1983:           method_sig.arg_types[2][0],
// 1984:           arg2_type,
// 1985:           arg2,
// 1986:           caller_offset: -1
// 1987:         )
// 1988:       end
// 1989:       if blk.nil?
// 1990:         CallValidation.report_error(
// 1991:           method_sig,
// 1992:           block_type.error_message_for_obj(blk),
// 1993:           'Block parameter',
// 1994:           method_sig.block_name,
// 1995:           block_type,
// 1996:           blk,
// 1997:           caller_offset: -1
// 1998:         )
// 1999:       end
// 2000:       return_value = original_method.bind_call(self, arg0, arg1, arg2, &blk)
// 2001:       if return_type.nil?
// 2002:         T::Private::Types::Void::VOID
// 2003:       else
// 2004:         unless return_type.valid?(return_value)
// 2005:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2006:           if message
// 2007:             CallValidation.report_error(
// 2008:               method_sig,
// 2009:               message,
// 2010:               'Return value',
// 2011:               nil,
// 2012:               method_sig.effective_return_type,
// 2013:               return_value,
// 2014:               caller_offset: -1
// 2015:             )
// 2016:           end
// 2017:         end
// 2018:         return_value
// 2019:       end
// 2020:     end
// 2021:   end
// 2022:
// 2023:   def self.create_validator_method_with_block4(mod, original_method, method_sig, original_visibility, return_type, block_type, arg0_type, arg1_type, arg2_type, arg3_type)
// 2024:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |arg0, arg1, arg2, arg3, &blk|
// 2025:       # This method is a manually sped-up version of more general code in `validate_call`
// 2026:       unless arg0_type.valid?(arg0)
// 2027:         CallValidation.report_error(
// 2028:           method_sig,
// 2029:           method_sig.arg_types[0][1].error_message_for_obj(arg0),
// 2030:           'Parameter',
// 2031:           method_sig.arg_types[0][0],
// 2032:           arg0_type,
// 2033:           arg0,
// 2034:           caller_offset: -1
// 2035:         )
// 2036:       end
// 2037:       unless arg1_type.valid?(arg1)
// 2038:         CallValidation.report_error(
// 2039:           method_sig,
// 2040:           method_sig.arg_types[1][1].error_message_for_obj(arg1),
// 2041:           'Parameter',
// 2042:           method_sig.arg_types[1][0],
// 2043:           arg1_type,
// 2044:           arg1,
// 2045:           caller_offset: -1
// 2046:         )
// 2047:       end
// 2048:       unless arg2_type.valid?(arg2)
// 2049:         CallValidation.report_error(
// 2050:           method_sig,
// 2051:           method_sig.arg_types[2][1].error_message_for_obj(arg2),
// 2052:           'Parameter',
// 2053:           method_sig.arg_types[2][0],
// 2054:           arg2_type,
// 2055:           arg2,
// 2056:           caller_offset: -1
// 2057:         )
// 2058:       end
// 2059:       unless arg3_type.valid?(arg3)
// 2060:         CallValidation.report_error(
// 2061:           method_sig,
// 2062:           method_sig.arg_types[3][1].error_message_for_obj(arg3),
// 2063:           'Parameter',
// 2064:           method_sig.arg_types[3][0],
// 2065:           arg3_type,
// 2066:           arg3,
// 2067:           caller_offset: -1
// 2068:         )
// 2069:       end
// 2070:       if blk.nil?
// 2071:         CallValidation.report_error(
// 2072:           method_sig,
// 2073:           block_type.error_message_for_obj(blk),
// 2074:           'Block parameter',
// 2075:           method_sig.block_name,
// 2076:           block_type,
// 2077:           blk,
// 2078:           caller_offset: -1
// 2079:         )
// 2080:       end
// 2081:       return_value = original_method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
// 2082:       if return_type.nil?
// 2083:         T::Private::Types::Void::VOID
// 2084:       else
// 2085:         unless return_type.valid?(return_value)
// 2086:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2087:           if message
// 2088:             CallValidation.report_error(
// 2089:               method_sig,
// 2090:               message,
// 2091:               'Return value',
// 2092:               nil,
// 2093:               method_sig.effective_return_type,
// 2094:               return_value,
// 2095:               caller_offset: -1
// 2096:             )
// 2097:           end
// 2098:         end
// 2099:         return_value
// 2100:       end
// 2101:     end
// 2102:   end
// 2103:
// 2104:   def self.create_validator_method_optional_args(mod, original_method, method_sig, original_visibility)
// 2105:     return_type = method_sig.effective_return_type
// 2106:     return_type = nil if return_type.is_a?(T::Private::Types::Void)
// 2107:     # trampoline to reduce stack frame size
// 2108:     arg_types = method_sig.arg_types
// 2109:     case [method_sig.req_arg_count, arg_types.length]
// 2110:     when [0, 1]
// 2111:       create_validator_method_optional_args0_1(mod, original_method, method_sig, original_visibility, return_type,
// 2112:                                                 arg_types[0][1])
// 2113:     when [0, 2]
// 2114:       create_validator_method_optional_args0_2(mod, original_method, method_sig, original_visibility, return_type,
// 2115:                                                 arg_types[0][1],
// 2116:                                                 arg_types[1][1])
// 2117:     when [1, 2]
// 2118:       create_validator_method_optional_args1_2(mod, original_method, method_sig, original_visibility, return_type,
// 2119:                                                 arg_types[0][1],
// 2120:                                                 arg_types[1][1])
// 2121:     when [0, 3]
// 2122:       create_validator_method_optional_args0_3(mod, original_method, method_sig, original_visibility, return_type,
// 2123:                                                 arg_types[0][1],
// 2124:                                                 arg_types[1][1],
// 2125:                                                 arg_types[2][1])
// 2126:     when [1, 3]
// 2127:       create_validator_method_optional_args1_3(mod, original_method, method_sig, original_visibility, return_type,
// 2128:                                                 arg_types[0][1],
// 2129:                                                 arg_types[1][1],
// 2130:                                                 arg_types[2][1])
// 2131:     when [2, 3]
// 2132:       create_validator_method_optional_args2_3(mod, original_method, method_sig, original_visibility, return_type,
// 2133:                                                 arg_types[0][1],
// 2134:                                                 arg_types[1][1],
// 2135:                                                 arg_types[2][1])
// 2136:     when [0, 4]
// 2137:       create_validator_method_optional_args0_4(mod, original_method, method_sig, original_visibility, return_type,
// 2138:                                                 arg_types[0][1],
// 2139:                                                 arg_types[1][1],
// 2140:                                                 arg_types[2][1],
// 2141:                                                 arg_types[3][1])
// 2142:     when [1, 4]
// 2143:       create_validator_method_optional_args1_4(mod, original_method, method_sig, original_visibility, return_type,
// 2144:                                                 arg_types[0][1],
// 2145:                                                 arg_types[1][1],
// 2146:                                                 arg_types[2][1],
// 2147:                                                 arg_types[3][1])
// 2148:     when [2, 4]
// 2149:       create_validator_method_optional_args2_4(mod, original_method, method_sig, original_visibility, return_type,
// 2150:                                                 arg_types[0][1],
// 2151:                                                 arg_types[1][1],
// 2152:                                                 arg_types[2][1],
// 2153:                                                 arg_types[3][1])
// 2154:     when [3, 4]
// 2155:       create_validator_method_optional_args3_4(mod, original_method, method_sig, original_visibility, return_type,
// 2156:                                                 arg_types[0][1],
// 2157:                                                 arg_types[1][1],
// 2158:                                                 arg_types[2][1],
// 2159:                                                 arg_types[3][1])
// 2160:     else
// 2161:       raise 'should not happen'
// 2162:     end
// 2163:   end
// 2164:
// 2165:   def self.create_validator_method_optional_args0_1(mod, original_method, method_sig, original_visibility, return_type, arg0_type)
// 2166:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 2167:       # This method is a manually sped-up version of more general code in `validate_call`
// 2168:       unless args.empty? || arg0_type.valid?(args[0])
// 2169:         CallValidation.report_error(
// 2170:           method_sig,
// 2171:           method_sig.arg_types[0][1].error_message_for_obj(args[0]),
// 2172:           'Parameter',
// 2173:           method_sig.arg_types[0][0],
// 2174:           arg0_type,
// 2175:           args[0],
// 2176:           caller_offset: -1
// 2177:         )
// 2178:       end
// 2179:       return_value = original_method.bind_call(self, *args, &blk)
// 2180:       if return_type.nil?
// 2181:         T::Private::Types::Void::VOID
// 2182:       else
// 2183:         unless return_type.valid?(return_value)
// 2184:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2185:           if message
// 2186:             CallValidation.report_error(
// 2187:               method_sig,
// 2188:               message,
// 2189:               'Return value',
// 2190:               nil,
// 2191:               method_sig.effective_return_type,
// 2192:               return_value,
// 2193:               caller_offset: -1
// 2194:             )
// 2195:           end
// 2196:         end
// 2197:         return_value
// 2198:       end
// 2199:     end
// 2200:   end
// 2201:
// 2202:   def self.create_validator_method_optional_args0_2(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type)
// 2203:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 2204:       # This method is a manually sped-up version of more general code in `validate_call`
// 2205:       unless args.empty? || arg0_type.valid?(args[0])
// 2206:         CallValidation.report_error(
// 2207:           method_sig,
// 2208:           method_sig.arg_types[0][1].error_message_for_obj(args[0]),
// 2209:           'Parameter',
// 2210:           method_sig.arg_types[0][0],
// 2211:           arg0_type,
// 2212:           args[0],
// 2213:           caller_offset: -1
// 2214:         )
// 2215:       end
// 2216:       unless args.length <= 1 || arg1_type.valid?(args[1])
// 2217:         CallValidation.report_error(
// 2218:           method_sig,
// 2219:           method_sig.arg_types[1][1].error_message_for_obj(args[1]),
// 2220:           'Parameter',
// 2221:           method_sig.arg_types[1][0],
// 2222:           arg1_type,
// 2223:           args[1],
// 2224:           caller_offset: -1
// 2225:         )
// 2226:       end
// 2227:       return_value = original_method.bind_call(self, *args, &blk)
// 2228:       if return_type.nil?
// 2229:         T::Private::Types::Void::VOID
// 2230:       else
// 2231:         unless return_type.valid?(return_value)
// 2232:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2233:           if message
// 2234:             CallValidation.report_error(
// 2235:               method_sig,
// 2236:               message,
// 2237:               'Return value',
// 2238:               nil,
// 2239:               method_sig.effective_return_type,
// 2240:               return_value,
// 2241:               caller_offset: -1
// 2242:             )
// 2243:           end
// 2244:         end
// 2245:         return_value
// 2246:       end
// 2247:     end
// 2248:   end
// 2249:
// 2250:   def self.create_validator_method_optional_args1_2(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type)
// 2251:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 2252:       # This method is a manually sped-up version of more general code in `validate_call`
// 2253:       unless arg0_type.valid?(args[0])
// 2254:         CallValidation.report_error(
// 2255:           method_sig,
// 2256:           method_sig.arg_types[0][1].error_message_for_obj(args[0]),
// 2257:           'Parameter',
// 2258:           method_sig.arg_types[0][0],
// 2259:           arg0_type,
// 2260:           args[0],
// 2261:           caller_offset: -1
// 2262:         )
// 2263:       end
// 2264:       unless args.length <= 1 || arg1_type.valid?(args[1])
// 2265:         CallValidation.report_error(
// 2266:           method_sig,
// 2267:           method_sig.arg_types[1][1].error_message_for_obj(args[1]),
// 2268:           'Parameter',
// 2269:           method_sig.arg_types[1][0],
// 2270:           arg1_type,
// 2271:           args[1],
// 2272:           caller_offset: -1
// 2273:         )
// 2274:       end
// 2275:       return_value = original_method.bind_call(self, *args, &blk)
// 2276:       if return_type.nil?
// 2277:         T::Private::Types::Void::VOID
// 2278:       else
// 2279:         unless return_type.valid?(return_value)
// 2280:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2281:           if message
// 2282:             CallValidation.report_error(
// 2283:               method_sig,
// 2284:               message,
// 2285:               'Return value',
// 2286:               nil,
// 2287:               method_sig.effective_return_type,
// 2288:               return_value,
// 2289:               caller_offset: -1
// 2290:             )
// 2291:           end
// 2292:         end
// 2293:         return_value
// 2294:       end
// 2295:     end
// 2296:   end
// 2297:
// 2298:   def self.create_validator_method_optional_args0_3(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type)
// 2299:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 2300:       # This method is a manually sped-up version of more general code in `validate_call`
// 2301:       unless args.empty? || arg0_type.valid?(args[0])
// 2302:         CallValidation.report_error(
// 2303:           method_sig,
// 2304:           method_sig.arg_types[0][1].error_message_for_obj(args[0]),
// 2305:           'Parameter',
// 2306:           method_sig.arg_types[0][0],
// 2307:           arg0_type,
// 2308:           args[0],
// 2309:           caller_offset: -1
// 2310:         )
// 2311:       end
// 2312:       unless args.length <= 1 || arg1_type.valid?(args[1])
// 2313:         CallValidation.report_error(
// 2314:           method_sig,
// 2315:           method_sig.arg_types[1][1].error_message_for_obj(args[1]),
// 2316:           'Parameter',
// 2317:           method_sig.arg_types[1][0],
// 2318:           arg1_type,
// 2319:           args[1],
// 2320:           caller_offset: -1
// 2321:         )
// 2322:       end
// 2323:       unless args.length <= 2 || arg2_type.valid?(args[2])
// 2324:         CallValidation.report_error(
// 2325:           method_sig,
// 2326:           method_sig.arg_types[2][1].error_message_for_obj(args[2]),
// 2327:           'Parameter',
// 2328:           method_sig.arg_types[2][0],
// 2329:           arg2_type,
// 2330:           args[2],
// 2331:           caller_offset: -1
// 2332:         )
// 2333:       end
// 2334:       return_value = original_method.bind_call(self, *args, &blk)
// 2335:       if return_type.nil?
// 2336:         T::Private::Types::Void::VOID
// 2337:       else
// 2338:         unless return_type.valid?(return_value)
// 2339:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2340:           if message
// 2341:             CallValidation.report_error(
// 2342:               method_sig,
// 2343:               message,
// 2344:               'Return value',
// 2345:               nil,
// 2346:               method_sig.effective_return_type,
// 2347:               return_value,
// 2348:               caller_offset: -1
// 2349:             )
// 2350:           end
// 2351:         end
// 2352:         return_value
// 2353:       end
// 2354:     end
// 2355:   end
// 2356:
// 2357:   def self.create_validator_method_optional_args1_3(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type)
// 2358:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 2359:       # This method is a manually sped-up version of more general code in `validate_call`
// 2360:       unless arg0_type.valid?(args[0])
// 2361:         CallValidation.report_error(
// 2362:           method_sig,
// 2363:           method_sig.arg_types[0][1].error_message_for_obj(args[0]),
// 2364:           'Parameter',
// 2365:           method_sig.arg_types[0][0],
// 2366:           arg0_type,
// 2367:           args[0],
// 2368:           caller_offset: -1
// 2369:         )
// 2370:       end
// 2371:       unless args.length <= 1 || arg1_type.valid?(args[1])
// 2372:         CallValidation.report_error(
// 2373:           method_sig,
// 2374:           method_sig.arg_types[1][1].error_message_for_obj(args[1]),
// 2375:           'Parameter',
// 2376:           method_sig.arg_types[1][0],
// 2377:           arg1_type,
// 2378:           args[1],
// 2379:           caller_offset: -1
// 2380:         )
// 2381:       end
// 2382:       unless args.length <= 2 || arg2_type.valid?(args[2])
// 2383:         CallValidation.report_error(
// 2384:           method_sig,
// 2385:           method_sig.arg_types[2][1].error_message_for_obj(args[2]),
// 2386:           'Parameter',
// 2387:           method_sig.arg_types[2][0],
// 2388:           arg2_type,
// 2389:           args[2],
// 2390:           caller_offset: -1
// 2391:         )
// 2392:       end
// 2393:       return_value = original_method.bind_call(self, *args, &blk)
// 2394:       if return_type.nil?
// 2395:         T::Private::Types::Void::VOID
// 2396:       else
// 2397:         unless return_type.valid?(return_value)
// 2398:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2399:           if message
// 2400:             CallValidation.report_error(
// 2401:               method_sig,
// 2402:               message,
// 2403:               'Return value',
// 2404:               nil,
// 2405:               method_sig.effective_return_type,
// 2406:               return_value,
// 2407:               caller_offset: -1
// 2408:             )
// 2409:           end
// 2410:         end
// 2411:         return_value
// 2412:       end
// 2413:     end
// 2414:   end
// 2415:
// 2416:   def self.create_validator_method_optional_args2_3(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type)
// 2417:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 2418:       # This method is a manually sped-up version of more general code in `validate_call`
// 2419:       unless arg0_type.valid?(args[0])
// 2420:         CallValidation.report_error(
// 2421:           method_sig,
// 2422:           method_sig.arg_types[0][1].error_message_for_obj(args[0]),
// 2423:           'Parameter',
// 2424:           method_sig.arg_types[0][0],
// 2425:           arg0_type,
// 2426:           args[0],
// 2427:           caller_offset: -1
// 2428:         )
// 2429:       end
// 2430:       unless arg1_type.valid?(args[1])
// 2431:         CallValidation.report_error(
// 2432:           method_sig,
// 2433:           method_sig.arg_types[1][1].error_message_for_obj(args[1]),
// 2434:           'Parameter',
// 2435:           method_sig.arg_types[1][0],
// 2436:           arg1_type,
// 2437:           args[1],
// 2438:           caller_offset: -1
// 2439:         )
// 2440:       end
// 2441:       unless args.length <= 2 || arg2_type.valid?(args[2])
// 2442:         CallValidation.report_error(
// 2443:           method_sig,
// 2444:           method_sig.arg_types[2][1].error_message_for_obj(args[2]),
// 2445:           'Parameter',
// 2446:           method_sig.arg_types[2][0],
// 2447:           arg2_type,
// 2448:           args[2],
// 2449:           caller_offset: -1
// 2450:         )
// 2451:       end
// 2452:       return_value = original_method.bind_call(self, *args, &blk)
// 2453:       if return_type.nil?
// 2454:         T::Private::Types::Void::VOID
// 2455:       else
// 2456:         unless return_type.valid?(return_value)
// 2457:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2458:           if message
// 2459:             CallValidation.report_error(
// 2460:               method_sig,
// 2461:               message,
// 2462:               'Return value',
// 2463:               nil,
// 2464:               method_sig.effective_return_type,
// 2465:               return_value,
// 2466:               caller_offset: -1
// 2467:             )
// 2468:           end
// 2469:         end
// 2470:         return_value
// 2471:       end
// 2472:     end
// 2473:   end
// 2474:
// 2475:   def self.create_validator_method_optional_args0_4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)
// 2476:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 2477:       # This method is a manually sped-up version of more general code in `validate_call`
// 2478:       unless args.empty? || arg0_type.valid?(args[0])
// 2479:         CallValidation.report_error(
// 2480:           method_sig,
// 2481:           method_sig.arg_types[0][1].error_message_for_obj(args[0]),
// 2482:           'Parameter',
// 2483:           method_sig.arg_types[0][0],
// 2484:           arg0_type,
// 2485:           args[0],
// 2486:           caller_offset: -1
// 2487:         )
// 2488:       end
// 2489:       unless args.length <= 1 || arg1_type.valid?(args[1])
// 2490:         CallValidation.report_error(
// 2491:           method_sig,
// 2492:           method_sig.arg_types[1][1].error_message_for_obj(args[1]),
// 2493:           'Parameter',
// 2494:           method_sig.arg_types[1][0],
// 2495:           arg1_type,
// 2496:           args[1],
// 2497:           caller_offset: -1
// 2498:         )
// 2499:       end
// 2500:       unless args.length <= 2 || arg2_type.valid?(args[2])
// 2501:         CallValidation.report_error(
// 2502:           method_sig,
// 2503:           method_sig.arg_types[2][1].error_message_for_obj(args[2]),
// 2504:           'Parameter',
// 2505:           method_sig.arg_types[2][0],
// 2506:           arg2_type,
// 2507:           args[2],
// 2508:           caller_offset: -1
// 2509:         )
// 2510:       end
// 2511:       unless args.length <= 3 || arg3_type.valid?(args[3])
// 2512:         CallValidation.report_error(
// 2513:           method_sig,
// 2514:           method_sig.arg_types[3][1].error_message_for_obj(args[3]),
// 2515:           'Parameter',
// 2516:           method_sig.arg_types[3][0],
// 2517:           arg3_type,
// 2518:           args[3],
// 2519:           caller_offset: -1
// 2520:         )
// 2521:       end
// 2522:       return_value = original_method.bind_call(self, *args, &blk)
// 2523:       if return_type.nil?
// 2524:         T::Private::Types::Void::VOID
// 2525:       else
// 2526:         unless return_type.valid?(return_value)
// 2527:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2528:           if message
// 2529:             CallValidation.report_error(
// 2530:               method_sig,
// 2531:               message,
// 2532:               'Return value',
// 2533:               nil,
// 2534:               method_sig.effective_return_type,
// 2535:               return_value,
// 2536:               caller_offset: -1
// 2537:             )
// 2538:           end
// 2539:         end
// 2540:         return_value
// 2541:       end
// 2542:     end
// 2543:   end
// 2544:
// 2545:   def self.create_validator_method_optional_args1_4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)
// 2546:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 2547:       # This method is a manually sped-up version of more general code in `validate_call`
// 2548:       unless arg0_type.valid?(args[0])
// 2549:         CallValidation.report_error(
// 2550:           method_sig,
// 2551:           method_sig.arg_types[0][1].error_message_for_obj(args[0]),
// 2552:           'Parameter',
// 2553:           method_sig.arg_types[0][0],
// 2554:           arg0_type,
// 2555:           args[0],
// 2556:           caller_offset: -1
// 2557:         )
// 2558:       end
// 2559:       unless args.length <= 1 || arg1_type.valid?(args[1])
// 2560:         CallValidation.report_error(
// 2561:           method_sig,
// 2562:           method_sig.arg_types[1][1].error_message_for_obj(args[1]),
// 2563:           'Parameter',
// 2564:           method_sig.arg_types[1][0],
// 2565:           arg1_type,
// 2566:           args[1],
// 2567:           caller_offset: -1
// 2568:         )
// 2569:       end
// 2570:       unless args.length <= 2 || arg2_type.valid?(args[2])
// 2571:         CallValidation.report_error(
// 2572:           method_sig,
// 2573:           method_sig.arg_types[2][1].error_message_for_obj(args[2]),
// 2574:           'Parameter',
// 2575:           method_sig.arg_types[2][0],
// 2576:           arg2_type,
// 2577:           args[2],
// 2578:           caller_offset: -1
// 2579:         )
// 2580:       end
// 2581:       unless args.length <= 3 || arg3_type.valid?(args[3])
// 2582:         CallValidation.report_error(
// 2583:           method_sig,
// 2584:           method_sig.arg_types[3][1].error_message_for_obj(args[3]),
// 2585:           'Parameter',
// 2586:           method_sig.arg_types[3][0],
// 2587:           arg3_type,
// 2588:           args[3],
// 2589:           caller_offset: -1
// 2590:         )
// 2591:       end
// 2592:       return_value = original_method.bind_call(self, *args, &blk)
// 2593:       if return_type.nil?
// 2594:         T::Private::Types::Void::VOID
// 2595:       else
// 2596:         unless return_type.valid?(return_value)
// 2597:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2598:           if message
// 2599:             CallValidation.report_error(
// 2600:               method_sig,
// 2601:               message,
// 2602:               'Return value',
// 2603:               nil,
// 2604:               method_sig.effective_return_type,
// 2605:               return_value,
// 2606:               caller_offset: -1
// 2607:             )
// 2608:           end
// 2609:         end
// 2610:         return_value
// 2611:       end
// 2612:     end
// 2613:   end
// 2614:
// 2615:   def self.create_validator_method_optional_args2_4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)
// 2616:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 2617:       # This method is a manually sped-up version of more general code in `validate_call`
// 2618:       unless arg0_type.valid?(args[0])
// 2619:         CallValidation.report_error(
// 2620:           method_sig,
// 2621:           method_sig.arg_types[0][1].error_message_for_obj(args[0]),
// 2622:           'Parameter',
// 2623:           method_sig.arg_types[0][0],
// 2624:           arg0_type,
// 2625:           args[0],
// 2626:           caller_offset: -1
// 2627:         )
// 2628:       end
// 2629:       unless arg1_type.valid?(args[1])
// 2630:         CallValidation.report_error(
// 2631:           method_sig,
// 2632:           method_sig.arg_types[1][1].error_message_for_obj(args[1]),
// 2633:           'Parameter',
// 2634:           method_sig.arg_types[1][0],
// 2635:           arg1_type,
// 2636:           args[1],
// 2637:           caller_offset: -1
// 2638:         )
// 2639:       end
// 2640:       unless args.length <= 2 || arg2_type.valid?(args[2])
// 2641:         CallValidation.report_error(
// 2642:           method_sig,
// 2643:           method_sig.arg_types[2][1].error_message_for_obj(args[2]),
// 2644:           'Parameter',
// 2645:           method_sig.arg_types[2][0],
// 2646:           arg2_type,
// 2647:           args[2],
// 2648:           caller_offset: -1
// 2649:         )
// 2650:       end
// 2651:       unless args.length <= 3 || arg3_type.valid?(args[3])
// 2652:         CallValidation.report_error(
// 2653:           method_sig,
// 2654:           method_sig.arg_types[3][1].error_message_for_obj(args[3]),
// 2655:           'Parameter',
// 2656:           method_sig.arg_types[3][0],
// 2657:           arg3_type,
// 2658:           args[3],
// 2659:           caller_offset: -1
// 2660:         )
// 2661:       end
// 2662:       return_value = original_method.bind_call(self, *args, &blk)
// 2663:       if return_type.nil?
// 2664:         T::Private::Types::Void::VOID
// 2665:       else
// 2666:         unless return_type.valid?(return_value)
// 2667:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2668:           if message
// 2669:             CallValidation.report_error(
// 2670:               method_sig,
// 2671:               message,
// 2672:               'Return value',
// 2673:               nil,
// 2674:               method_sig.effective_return_type,
// 2675:               return_value,
// 2676:               caller_offset: -1
// 2677:             )
// 2678:           end
// 2679:         end
// 2680:         return_value
// 2681:       end
// 2682:     end
// 2683:   end
// 2684:
// 2685:   def self.create_validator_method_optional_args3_4(mod, original_method, method_sig, original_visibility, return_type, arg0_type, arg1_type, arg2_type, arg3_type)
// 2686:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 2687:       # This method is a manually sped-up version of more general code in `validate_call`
// 2688:       unless arg0_type.valid?(args[0])
// 2689:         CallValidation.report_error(
// 2690:           method_sig,
// 2691:           method_sig.arg_types[0][1].error_message_for_obj(args[0]),
// 2692:           'Parameter',
// 2693:           method_sig.arg_types[0][0],
// 2694:           arg0_type,
// 2695:           args[0],
// 2696:           caller_offset: -1
// 2697:         )
// 2698:       end
// 2699:       unless arg1_type.valid?(args[1])
// 2700:         CallValidation.report_error(
// 2701:           method_sig,
// 2702:           method_sig.arg_types[1][1].error_message_for_obj(args[1]),
// 2703:           'Parameter',
// 2704:           method_sig.arg_types[1][0],
// 2705:           arg1_type,
// 2706:           args[1],
// 2707:           caller_offset: -1
// 2708:         )
// 2709:       end
// 2710:       unless arg2_type.valid?(args[2])
// 2711:         CallValidation.report_error(
// 2712:           method_sig,
// 2713:           method_sig.arg_types[2][1].error_message_for_obj(args[2]),
// 2714:           'Parameter',
// 2715:           method_sig.arg_types[2][0],
// 2716:           arg2_type,
// 2717:           args[2],
// 2718:           caller_offset: -1
// 2719:         )
// 2720:       end
// 2721:       unless args.length <= 3 || arg3_type.valid?(args[3])
// 2722:         CallValidation.report_error(
// 2723:           method_sig,
// 2724:           method_sig.arg_types[3][1].error_message_for_obj(args[3]),
// 2725:           'Parameter',
// 2726:           method_sig.arg_types[3][0],
// 2727:           arg3_type,
// 2728:           args[3],
// 2729:           caller_offset: -1
// 2730:         )
// 2731:       end
// 2732:       return_value = original_method.bind_call(self, *args, &blk)
// 2733:       if return_type.nil?
// 2734:         T::Private::Types::Void::VOID
// 2735:       else
// 2736:         unless return_type.valid?(return_value)
// 2737:           message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 2738:           if message
// 2739:             CallValidation.report_error(
// 2740:               method_sig,
// 2741:               message,
// 2742:               'Return value',
// 2743:               nil,
// 2744:               method_sig.effective_return_type,
// 2745:               return_value,
// 2746:               caller_offset: -1
// 2747:             )
// 2748:           end
// 2749:         end
// 2750:         return_value
// 2751:       end
// 2752:     end
// 2753:   end
// 2754:
// 2755: end
