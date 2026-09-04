module props

import ruby

pub enum GeneratedValidationMode {
	serialize
	deserialize
}

const serialize_receiver_methods = ['dup', 'map', 'transform_values', 'transform_keys',
	'each_with_object', 'nil?', '[]=', 'serialize']
const deserialize_receiver_methods = ['dup', 'map', 'transform_values', 'transform_keys',
	'each_with_object', 'nil?', '[]=', 'to_f']
const serialize_constant_methods = ['checked_serialize', 'deep_clone', 'deep_clone_object']
const deserialize_constant_methods = ['deserialize', 'from_hash', 'deep_clone', 'deep_clone_object']

pub fn generated_validation_whitelist(mode GeneratedValidationMode) map[string][]string {
	return if mode == .serialize {
		{
			'lvar':  serialize_receiver_methods.clone()
			'ivar':  serialize_receiver_methods.filter(it != 'nil?')
			'const': serialize_constant_methods.clone()
		}
	} else {
		{
			'lvar':  deserialize_receiver_methods.clone()
			'const': deserialize_constant_methods.clone()
		}
	}
}

fn generated_lines(source string) []string {
	return source.split('\n').map(it.trim_space()).filter(it.len > 0)
}

fn generated_method_name(header string) !(string, string) {
	if !header.starts_with('def ') || !header.ends_with(')') {
		return error('Expected generated method definition, got `${header}`')
	}
	body := header[4..]
	open := body.index('(') or { return error('Expected generated method arguments') }
	return body[..open], body[open + 1..body.len - 1]
}

fn validate_generated_expression(expression string, mode GeneratedValidationMode) ! {
	unsafe_fragments := ['`', 'system(', 'exec(', 'spawn(', 'fork(', 'eval(', 'class_eval(',
		'module_eval(', 'instance_eval(', 'remove_const', 'const_set', 'define_method', 'public_send(',
		'__send__(']
	for fragment in unsafe_fragments {
		if expression.contains(fragment) {
			return error('Unexpected side effect in generated expression: ${fragment}')
		}
	}
	whitelist := generated_validation_whitelist(mode)
	mut allowed := []string{}
	allowed << whitelist['lvar'] or { []string{} }
	allowed << whitelist['ivar'] or { []string{} }
	allowed << whitelist['const'] or { []string{} }
	allowed << [
		'key?',
		'freeze',
		'fetch',
		'default',
		'props_with_defaults',
		'decorator',
		'class',
		'required_prop_missing_from_deserialize',
		'raise_nil_deserialize_error',
		'raise_deserialization_error',
	]
	mut rest := expression
	for {
		dot := rest.index('.') or { break }
		rest = rest[dot + 1..]
		mut end := 0
		for end < rest.len && ((rest[end] >= `A` && rest[end] <= `Z`) || (rest[end] >= `a` && rest[end] <= `z`) || (rest[end] >= `0` && rest[end] <= `9`) || rest[end] in [
			`_`,
			`?`,
			`!`,
			`=`,
		]) {
			end++
		}
		if end == 0 {
			continue
		}
		method := rest[..end]
		if method !in allowed {
			return error('Unexpected method ${method} in generated expression')
		}
		rest = rest[end..]
	}
}

pub fn validate_generated_serialize_clause(lines []string) ! {
	if lines.len < 4 || !lines[0].starts_with('if @') || !lines[0].ends_with('.nil?') {
		return error('Expected nil-checking serialize clause')
	}
	else_index := lines.index('else')
	if else_index < 0 || !lines[else_index + 1].starts_with('h[') || !lines[else_index + 1].contains('] = ') || lines[lines.len - 1] != 'end' {
		return error('Expected assignment to serialized hash')
	}
	if else_index > 1 {
		missing := lines[1]
		if !missing.starts_with('required_prop_missing_from_serialize(:') || !missing.ends_with(') if strict') {
			return error('Unexpected required-property handler')
		}
	}
	validate_generated_expression(lines[else_index + 1].all_after(' = '), .serialize)!
}

pub fn validate_generated_deserialize_hash_read(line string) ! {
	if !line.starts_with('val = hash[') || !line.ends_with(']') {
		return error('Expected `val = hash[serialized_form]`')
	}
}

pub fn validate_generated_deserialize_nil_handler(handler string) ! {
	trimmed := handler.trim_space()
	if trimmed in ['{}', '[]', 'true', 'false', 'nil'] || trimmed.starts_with('"') || trimmed.starts_with(':') || trimmed[0].is_digit() {
		return
	}
	allowed := ['required_prop_missing_from_deserialize(:',
		'self.class.decorator.raise_nil_deserialize_error(',
		'self.class.decorator.props_with_defaults.fetch(']
	if allowed.any(trimmed.starts_with(it)) {
		validate_generated_expression(trimmed, .deserialize)!
		return
	}
	return error('Unexpected nil handler: ${handler}')
}

pub fn validate_generated_deserialize_ivar_clause(lines []string) ! {
	if lines.len < 6 || !lines[0].starts_with('@') || !lines[0].ends_with(' = if val.nil?') {
		return error('Expected instance-variable deserialize clause')
	}
	if !lines[1].starts_with('found -= 1 unless hash.key?(') || !lines[1].ends_with('.freeze)') {
		return error('Expected side-effect-free found counter update')
	}
	else_index := lines.index('else')
	if else_index < 0 || lines[lines.len - 1] != 'end' {
		return error('Expected deserialize else branch')
	}
	validate_generated_deserialize_nil_handler(lines[2])!
	validate_generated_expression(lines[else_index + 1], .deserialize)!
}

pub fn validate_generated_serialize(source string) ! {
	lines := generated_lines(source)
	if lines.len < 4 {
		return error('Generated serialize source is incomplete')
	}
	name, argument := generated_method_name(lines[0])!
	if name != '__t_props_generated_serialize' || argument != 'strict' {
		return error('Expected __t_props_generated_serialize(strict)')
	}
	if lines[1] != 'h = {}' || lines[lines.len - 2] != 'h' || lines[lines.len - 1] != 'end' {
		return error('Unexpected generated serialize method structure')
	}
	mut index := 2
	for index < lines.len - 2 {
		if !lines[index].starts_with('if ') {
			return error('Expected serialize property clause')
		}
		mut finish := index
		mut depth := 0
		for finish < lines.len - 2 {
			if lines[finish].starts_with('if ') { depth++ }
			if lines[finish] == 'end' {
				depth--
				if depth == 0 {
					break
				}
			}
			finish++
		}
		validate_generated_serialize_clause(lines[index..finish + 1])!
		index = finish + 1
	}
}

pub fn validate_generated_deserialize(source string) ! {
	lines := generated_lines(source)
	if lines.len < 4 {
		return error('Generated deserialize source is incomplete')
	}
	name, argument := generated_method_name(lines[0])!
	if name != '__t_props_generated_deserialize' || argument != 'hash' {
		return error('Expected __t_props_generated_deserialize(hash)')
	}
	if !lines[1].starts_with('found = ') || lines[lines.len - 2] != 'found' || lines[lines.len - 1] != 'end' {
		return error('Unexpected generated deserialize method structure')
	}
	mut index := 2
	for index < lines.len - 2 {
		validate_generated_deserialize_hash_read(lines[index])!
		index++
		mut finish := index
		for finish < lines.len - 2 && lines[finish] != 'end' {
			finish++
		}
		if finish >= lines.len - 2 {
			return error('Unterminated deserialize property clause')
		}
		validate_generated_deserialize_ivar_clause(lines[index..finish + 1])!
		index = finish + 1
	}
}

fn generated_value_equal(left ruby.Value, right ruby.Value) bool {
	if left.type_name != right.type_name || left.repr != right.repr || left.bool_data != right.bool_data || left.int_data != right.int_data || left.array_data.len != right.array_data.len || left.map_data.len != right.map_data.len {
		return false
	}
	for i, item in left.array_data {
		if !generated_value_equal(item, right.array_data[i]) {
			return false
		}
	}
	for key, item in left.map_data {
		other := right.map_data[key] or { return false }
		if !generated_value_equal(item, other) {
			return false
		}
	}
	return true
}

fn generated_whitelist_value(mode GeneratedValidationMode) ruby.Value {
	mut result := map[string]ruby.Value{}
	for receiver, methods in generated_validation_whitelist(mode) {
		result[receiver] = ruby.string_array_value(methods)
	}
	return ruby.map_value(result)
}

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/generated_code_validation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.validate_deserialize(source)` at line 17.
pub fn ruby_generated_code_validation_l17_d1_self_validate_deserialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('validate_deserialize requires source') }
	validate_generated_deserialize(args[args.len - 1].as_string()) or { panic(err) }
	return props_nil_value()
}

// Ruby method `self.validate_serialize(source)` at line 49.
pub fn ruby_generated_code_validation_l49_d2_self_validate_serialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('validate_serialize requires source') }
	validate_generated_serialize(args[args.len - 1].as_string()) or { panic(err) }
	return props_nil_value()
}

// Ruby method `self.validate_serialize_clause(clause)` at line 74.
pub fn ruby_generated_code_validation_l74_d3_self_validate_serialize_clause(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('validate_serialize_clause requires clause') }
	validate_generated_serialize_clause(generated_lines(args[args.len - 1].as_string())) or { panic(err) }
	return props_nil_value()
}

// Ruby method `self.validate_deserialize_hash_read(clause)` at line 107.
pub fn ruby_generated_code_validation_l107_d4_self_validate_deserialize_hash_read(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('validate_deserialize_hash_read requires clause') }
	validate_generated_deserialize_hash_read(args[args.len - 1].as_string().trim_space()) or { panic(err) }
	return props_nil_value()
}

// Ruby method `self.validate_deserialize_ivar_set(clause)` at line 120.
pub fn ruby_generated_code_validation_l120_d5_self_validate_deserialize_ivar_set(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('validate_deserialize_ivar_set requires clause') }
	validate_generated_deserialize_ivar_clause(generated_lines(args[args.len - 1].as_string())) or { panic(err) }
	return props_nil_value()
}

// Ruby method `self.validate_deserialize_handle_nil(node)` at line 186.
pub fn ruby_generated_code_validation_l186_d6_self_validate_deserialize_handle_nil(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('validate_deserialize_handle_nil requires node') }
	validate_generated_deserialize_nil_handler(args[args.len - 1].as_string()) or { panic(err) }
	return props_nil_value()
}

// Ruby method `self.self_class_decorator` at line 218.
pub fn ruby_generated_code_validation_l218_d7_self_self_class_decorator(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Parser::AST::Node', 'self.class.decorator', {
		'type':   'send'
		'frozen': 'true'
	})
}

// Ruby method `self.validate_lack_of_side_effects(node, whitelisted_methods_by_receiver_type)` at line 222.
pub fn ruby_generated_code_validation_l222_d8_self_validate_lack_of_side_effects(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('validate_lack_of_side_effects requires expression') }
	mode := if args.len > 1 && args[args.len - 1].repr.contains('from_hash') {
		GeneratedValidationMode.deserialize
	} else {
		GeneratedValidationMode.serialize
	}
	validate_generated_expression(args[args.len - if args.len > 1 { 2 } else { 1 }].as_string(), mode) or { panic(err) }
	return props_nil_value()
}

// Ruby method `self.assert_equal(expected, actual)` at line 260.
pub fn ruby_generated_code_validation_l260_d9_self_assert_equal(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('assert_equal requires expected and actual') }
	if !generated_value_equal(args[args.len - 2], args[args.len - 1]) {
		panic('Expected ${args[args.len - 2].repr}, got ${args[args.len - 1].repr}')
	}
	return props_nil_value()
}

// Ruby method `self.whitelisted_methods_for_serialize` at line 267.
pub fn ruby_generated_code_validation_l267_d10_self_whitelisted_methods_for_serialize(args ...ruby.Value) ruby.Value {
	return generated_whitelist_value(.serialize)
}

// Ruby method `self.whitelisted_methods_for_deserialize` at line 276.
pub fn ruby_generated_code_validation_l276_d11_self_whitelisted_methods_for_deserialize(args ...ruby.Value) ruby.Value {
	return generated_whitelist_value(.deserialize)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Props
// 5:   # Helper to validate generated code, to mitigate security concerns around
// 6:   # `class_eval`. Not called by default; the expectation is this will be used
// 7:   # in a test iterating over all T::Props::Serializable subclasses.
// 8:   #
// 9:   # We validate the exact expected structure of the generated methods as far
// 10:   # as we can, and then where cloning produces an arbitrarily nested structure,
// 11:   # we just validate a lack of side effects.
// 12:   module GeneratedCodeValidation
// 13:     extend Private::Parse
// 14:
// 15:     class ValidationError < RuntimeError; end
// 16:
// 17:     def self.validate_deserialize(source)
// 18:       parsed = parse(source)
// 19:
// 20:       # def %<name>(hash)
// 21:       #   ...
// 22:       # end
// 23:       assert_equal(:def, parsed.type)
// 24:       name, args, body = parsed.children
// 25:       assert_equal(:__t_props_generated_deserialize, name)
// 26:       assert_equal(s(:args, s(:arg, :hash)), args)
// 27:
// 28:       assert_equal(:begin, body.type)
// 29:       init, *prop_clauses, ret = body.children
// 30:
// 31:       # found = %<prop_count>
// 32:       # ...
// 33:       # found
// 34:       assert_equal(:lvasgn, init.type)
// 35:       init_name, init_val = init.children
// 36:       assert_equal(:found, init_name)
// 37:       assert_equal(:int, init_val.type)
// 38:       assert_equal(s(:lvar, :found), ret)
// 39:
// 40:       prop_clauses.each_with_index do |clause, i|
// 41:         if i.even?
// 42:           validate_deserialize_hash_read(clause)
// 43:         else
// 44:           validate_deserialize_ivar_set(clause)
// 45:         end
// 46:       end
// 47:     end
// 48:
// 49:     def self.validate_serialize(source)
// 50:       parsed = parse(source)
// 51:
// 52:       # def %<name>(strict)
// 53:       # ...
// 54:       # end
// 55:       assert_equal(:def, parsed.type)
// 56:       name, args, body = parsed.children
// 57:       assert_equal(:__t_props_generated_serialize, name)
// 58:       assert_equal(s(:args, s(:arg, :strict)), args)
// 59:
// 60:       assert_equal(:begin, body.type)
// 61:       init, *prop_clauses, ret = body.children
// 62:
// 63:       # h = {}
// 64:       # ...
// 65:       # h
// 66:       assert_equal(s(:lvasgn, :h, s(:hash)), init)
// 67:       assert_equal(s(:lvar, :h), ret)
// 68:
// 69:       prop_clauses.each do |clause|
// 70:         validate_serialize_clause(clause)
// 71:       end
// 72:     end
// 73:
// 74:     private_class_method def self.validate_serialize_clause(clause)
// 75:       assert_equal(:if, clause.type)
// 76:       condition, if_body, else_body = clause.children
// 77:
// 78:       # if @%<accessor_key>.nil?
// 79:       assert_equal(:send, condition.type)
// 80:       receiver, method = condition.children
// 81:       assert_equal(:ivar, receiver.type)
// 82:       assert_equal(:nil?, method)
// 83:
// 84:       unless if_body.nil?
// 85:         # required_prop_missing_from_serialize(%<prop>) if strict
// 86:         assert_equal(:if, if_body.type)
// 87:         if_strict_condition, if_strict_body, if_strict_else = if_body.children
// 88:         assert_equal(s(:lvar, :strict), if_strict_condition)
// 89:         assert_equal(:send, if_strict_body.type)
// 90:         on_strict_receiver, on_strict_method, on_strict_arg = if_strict_body.children
// 91:         assert_equal(nil, on_strict_receiver)
// 92:         assert_equal(:required_prop_missing_from_serialize, on_strict_method)
// 93:         assert_equal(:sym, on_strict_arg.type)
// 94:         assert_equal(nil, if_strict_else)
// 95:       end
// 96:
// 97:       # h[%<serialized_form>] = ...
// 98:       assert_equal(:send, else_body.type)
// 99:       receiver, method, h_key, h_val = else_body.children
// 100:       assert_equal(s(:lvar, :h), receiver)
// 101:       assert_equal(:[]=, method)
// 102:       assert_equal(:str, h_key.type)
// 103:
// 104:       validate_lack_of_side_effects(h_val, whitelisted_methods_for_serialize)
// 105:     end
// 106:
// 107:     private_class_method def self.validate_deserialize_hash_read(clause)
// 108:       # val = hash[%<serialized_form>s]
// 109:
// 110:       assert_equal(:lvasgn, clause.type)
// 111:       name, val = clause.children
// 112:       assert_equal(:val, name)
// 113:       assert_equal(:send, val.type)
// 114:       receiver, method, arg = val.children
// 115:       assert_equal(s(:lvar, :hash), receiver)
// 116:       assert_equal(:[], method)
// 117:       assert_equal(:str, arg.type)
// 118:     end
// 119:
// 120:     private_class_method def self.validate_deserialize_ivar_set(clause)
// 121:       # %<accessor_key>s = if val.nil?
// 122:       #   found -= 1 unless hash.key?(%<serialized_form>s.freeze)
// 123:       #   %<nil_handler>s
// 124:       # else
// 125:       #   %<serialized_val>s
// 126:       # end
// 127:
// 128:       assert_equal(:ivasgn, clause.type)
// 129:       ivar_name, deser_val = clause.children
// 130:       unless ivar_name.is_a?(Symbol)
// 131:         raise ValidationError.new("Unexpected ivar: #{ivar_name}")
// 132:       end
// 133:
// 134:       assert_equal(:if, deser_val.type)
// 135:       condition, if_body, else_body = deser_val.children
// 136:       assert_equal(s(:send, s(:lvar, :val), :nil?), condition)
// 137:
// 138:       assert_equal(:begin, if_body.type)
// 139:       update_found, handle_nil = if_body.children
// 140:       assert_equal(:if, update_found.type)
// 141:       found_condition, found_if_body, found_else_body = update_found.children
// 142:       assert_equal(:send, found_condition.type)
// 143:       receiver, method, arg = found_condition.children
// 144:       assert_equal(s(:lvar, :hash), receiver)
// 145:       assert_equal(:key?, method)
// 146:       # hash.key?(%<serialized_form>s.freeze), where `.freeze` on a string
// 147:       # literal is side-effect-free (and avoids a per-call allocation)
// 148:       assert_equal(:send, arg.type)
// 149:       arg_receiver, arg_method, *arg_rest = arg.children
// 150:       assert_equal(:str, arg_receiver.type)
// 151:       assert_equal(:freeze, arg_method)
// 152:       assert_equal([], arg_rest)
// 153:       assert_equal(nil, found_if_body)
// 154:       assert_equal(s(:op_asgn, s(:lvasgn, :found), :-, s(:int, 1)), found_else_body)
// 155:
// 156:       validate_deserialize_handle_nil(handle_nil)
// 157:
// 158:       if else_body.type == :kwbegin
// 159:         rescue_expression, = else_body.children
// 160:         assert_equal(:rescue, rescue_expression.type)
// 161:
// 162:         try, rescue_body = rescue_expression.children
// 163:         validate_lack_of_side_effects(try, whitelisted_methods_for_deserialize)
// 164:
// 165:         assert_equal(:resbody, rescue_body.type)
// 166:         exceptions, assignment, handler = rescue_body.children
// 167:         assert_equal(:array, exceptions.type)
// 168:         exceptions.children.each { |c| assert_equal(:const, c.type) }
// 169:         assert_equal(:lvasgn, assignment.type)
// 170:         assert_equal([:e], assignment.children)
// 171:
// 172:         deserialization_error, val_return = handler.children
// 173:
// 174:         assert_equal(:send, deserialization_error.type)
// 175:         receiver, method, *args = deserialization_error.children
// 176:         assert_equal(nil, receiver)
// 177:         assert_equal(:raise_deserialization_error, method)
// 178:         args.each { |a| validate_lack_of_side_effects(a, whitelisted_methods_for_deserialize) }
// 179:
// 180:         validate_lack_of_side_effects(val_return, whitelisted_methods_for_deserialize)
// 181:       else
// 182:         validate_lack_of_side_effects(else_body, whitelisted_methods_for_deserialize)
// 183:       end
// 184:     end
// 185:
// 186:     private_class_method def self.validate_deserialize_handle_nil(node)
// 187:       case node.type
// 188:       when :hash, :array, :str, :sym, :int, :float, :true, :false, :nil, :const # rubocop:disable Lint/BooleanSymbol
// 189:         # Primitives and constants are safe
// 190:       when :send
// 191:         receiver, method, arg = node.children
// 192:         if receiver.nil?
// 193:           # required_prop_missing_from_deserialize(%<prop>)
// 194:           assert_equal(:required_prop_missing_from_deserialize, method)
// 195:           assert_equal(:sym, arg.type)
// 196:         elsif receiver == self_class_decorator
// 197:           # self.class.decorator.raise_nil_deserialize_error(%<serialized_form>)
// 198:           assert_equal(:raise_nil_deserialize_error, method)
// 199:           assert_equal(:str, arg.type)
// 200:         elsif method == :default
// 201:           # self.class.decorator.props_with_defaults.fetch(%<prop>).default
// 202:           assert_equal(:send, receiver.type)
// 203:           inner_receiver, inner_method, inner_arg = receiver.children
// 204:           assert_equal(
// 205:             s(:send, self_class_decorator, :props_with_defaults),
// 206:             inner_receiver,
// 207:           )
// 208:           assert_equal(:fetch, inner_method)
// 209:           assert_equal(:sym, inner_arg.type)
// 210:         else
// 211:           raise ValidationError.new("Unexpected receiver in nil handler: #{node.inspect}")
// 212:         end
// 213:       else
// 214:         raise ValidationError.new("Unexpected nil handler: #{node.inspect}")
// 215:       end
// 216:     end
// 217:
// 218:     private_class_method def self.self_class_decorator
// 219:       @self_class_decorator ||= s(:send, s(:send, s(:self), :class), :decorator).freeze
// 220:     end
// 221:
// 222:     private_class_method def self.validate_lack_of_side_effects(node, whitelisted_methods_by_receiver_type)
// 223:       case node.type
// 224:       when :const
// 225:         # This is ok, because we'll have validated what method has been called
// 226:         # if applicable
// 227:       when :hash, :array, :str, :sym, :int, :float, :true, :false, :nil, :self # rubocop:disable Lint/BooleanSymbol
// 228:         # Primitives & self are ok
// 229:       when :lvar, :arg, :ivar
// 230:         # Reading local & instance variables & arguments is ok
// 231:         unless node.children.all? { |c| c.is_a?(Symbol) }
// 232:           raise ValidationError.new("Unexpected child for #{node.type}: #{node.inspect}")
// 233:         end
// 234:       when :args, :mlhs, :block, :begin, :if
// 235:         # Blocks etc are read-only if their contents are read-only
// 236:         node.children.each { |c| validate_lack_of_side_effects(c, whitelisted_methods_by_receiver_type) if c }
// 237:       when :send
// 238:         # Sends are riskier so check a whitelist
// 239:         receiver, method, *args = node.children
// 240:         if receiver
// 241:           if receiver.type == :send
// 242:             key = receiver
// 243:           else
// 244:             key = receiver.type
// 245:             validate_lack_of_side_effects(receiver, whitelisted_methods_by_receiver_type)
// 246:           end
// 247:
// 248:           if !whitelisted_methods_by_receiver_type[key]&.include?(method)
// 249:             raise ValidationError.new("Unexpected method #{method} called on #{receiver.inspect}")
// 250:           end
// 251:         end
// 252:         args.each do |arg|
// 253:           validate_lack_of_side_effects(arg, whitelisted_methods_by_receiver_type)
// 254:         end
// 255:       else
// 256:         raise ValidationError.new("Unexpected node type #{node.type}: #{node.inspect}")
// 257:       end
// 258:     end
// 259:
// 260:     private_class_method def self.assert_equal(expected, actual)
// 261:       if expected != actual
// 262:         raise ValidationError.new("Expected #{expected}, got #{actual}")
// 263:       end
// 264:     end
// 265:
// 266:     # Method calls generated by SerdeTransform
// 267:     private_class_method def self.whitelisted_methods_for_serialize
// 268:       @whitelisted_methods_for_serialize ||= {
// 269:         lvar: %i{dup map transform_values transform_keys each_with_object nil? []= serialize},
// 270:         ivar: %i[dup map transform_values transform_keys each_with_object serialize],
// 271:         const: %i[checked_serialize deep_clone deep_clone_object],
// 272:       }
// 273:     end
// 274:
// 275:     # Method calls generated by SerdeTransform
// 276:     private_class_method def self.whitelisted_methods_for_deserialize
// 277:       @whitelisted_methods_for_deserialize ||= {
// 278:         lvar: %i{dup map transform_values transform_keys each_with_object nil? []= to_f},
// 279:         const: %i[deserialize from_hash deep_clone deep_clone_object],
// 280:       }
// 281:     end
// 282:   end
// 283: end
