module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/private/setter_factory.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.build_setter_proc(klass, prop, rules)` at line 26.
pub fn ruby_setter_factory_l26_d1_self_build_setter_proc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.build_setter_proc', ...args)
}

// Ruby method `self.simple_non_nil_proc(prop, accessor_key, non_nil_type, klass)` at line 65.
pub fn ruby_setter_factory_l65_d2_self_simple_non_nil_proc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.simple_non_nil_proc', ...args)
}

// Ruby method `self.non_nil_proc(prop, accessor_key, non_nil_type, klass, validate)` at line 114.
pub fn ruby_setter_factory_l114_d3_self_non_nil_proc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.non_nil_proc', ...args)
}

// Ruby method `self.simple_nilable_proc(prop, accessor_key, non_nil_type, klass)` at line 178.
pub fn ruby_setter_factory_l178_d4_self_simple_nilable_proc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.simple_nilable_proc', ...args)
}

// Ruby method `self.nilable_proc(prop, accessor_key, non_nil_type, klass, validate)` at line 227.
pub fn ruby_setter_factory_l227_d5_self_nilable_proc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.nilable_proc', ...args)
}

// Ruby method `self.raise_pretty_error(klass, prop, type, val)` at line 298.
pub fn ruby_setter_factory_l298_d6_self_raise_pretty_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.raise_pretty_error', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: strict
// 3:
// 4: module T::Props
// 5:   module Private
// 6:     module SetterFactory
// 7:       extend T::Sig
// 8:
// 9:       SetterProc = T.type_alias { T.proc.params(val: T.untyped).void }
// 10:       ValueValidationProc = T.type_alias { T.proc.params(val: T.untyped).void }
// 11:       # Same validation/assignment as SetterProc, but takes the instance
// 12:       # explicitly so per-prop construction/prop_set paths skip the
// 13:       # self-rebinding instance_exec dispatch.
// 14:       BoundSetterProc = T.type_alias { T.proc.params(instance: T.untyped, val: T.untyped).void }
// 15:       ValidateProc = T.type_alias { T.proc.params(prop: Symbol, value: T.untyped).void }
// 16:
// 17:       sig do
// 18:         params(
// 19:           klass: T.all(T::Module[T.anything], T::Props::ClassMethods),
// 20:           prop: Symbol,
// 21:           rules: T::Hash[Symbol, T.untyped]
// 22:         )
// 23:         .returns([SetterProc, ValueValidationProc, BoundSetterProc])
// 24:         .checked(:never)
// 25:       end
// 26:       def self.build_setter_proc(klass, prop, rules)
// 27:         # Our nil check works differently than a simple T.nilable for various
// 28:         # reasons (including the `raise_on_nil_write` setting and the existence
// 29:         # of defaults & factories), so unwrap any T.nilable and do a check
// 30:         # manually.
// 31:         non_nil_type = T::Utils::Nilable.get_underlying_type_object(rules.fetch(:type_object))
// 32:         accessor_key = rules.fetch(:accessor_key)
// 33:         validate = rules[:setter_validate]
// 34:
// 35:         # It seems like a bug that this affects the behavior of setters, but
// 36:         # some existing code relies on this behavior
// 37:         has_explicit_nil_default = rules.key?(:default) && rules.fetch(:default).nil?
// 38:
// 39:         # Use separate methods in order to ensure that we only close over necessary
// 40:         # variables
// 41:         if !T::Props::Utils.need_nil_write_check?(rules) || has_explicit_nil_default
// 42:           if validate.nil? && non_nil_type.is_a?(T::Types::Simple)
// 43:             simple_nilable_proc(prop, accessor_key, non_nil_type.raw_type, klass)
// 44:           else
// 45:             nilable_proc(prop, accessor_key, non_nil_type, klass, validate)
// 46:           end
// 47:         else
// 48:           if validate.nil? && non_nil_type.is_a?(T::Types::Simple)
// 49:             simple_non_nil_proc(prop, accessor_key, non_nil_type.raw_type, klass)
// 50:           else
// 51:             non_nil_proc(prop, accessor_key, non_nil_type, klass, validate)
// 52:           end
// 53:         end
// 54:       end
// 55:
// 56:       sig do
// 57:         params(
// 58:           prop: Symbol,
// 59:           accessor_key: Symbol,
// 60:           non_nil_type: T::Module[T.anything],
// 61:           klass: T.all(T::Module[T.anything], T::Props::ClassMethods),
// 62:         )
// 63:         .returns([SetterProc, ValueValidationProc, BoundSetterProc])
// 64:       end
// 65:       private_class_method def self.simple_non_nil_proc(prop, accessor_key, non_nil_type, klass)
// 66:         [
// 67:           proc do |val|
// 68:             unless val.is_a?(non_nil_type)
// 69:               T::Props::Private::SetterFactory.raise_pretty_error(
// 70:                 klass,
// 71:                 prop,
// 72:                 T::Utils.coerce(non_nil_type),
// 73:                 val,
// 74:               )
// 75:             end
// 76:             instance_variable_set(accessor_key, val)
// 77:           end,
// 78:           proc do |val|
// 79:             unless val.is_a?(non_nil_type)
// 80:               T::Props::Private::SetterFactory.raise_pretty_error(
// 81:                 klass,
// 82:                 prop,
// 83:                 T::Utils.coerce(non_nil_type),
// 84:                 val,
// 85:               )
// 86:             end
// 87:           end,
// 88:           # The ivar set is unconditional, exactly as above: the value must
// 89:           # still be set when call_validation_error_handler does not raise.
// 90:           proc do |instance, val|
// 91:             unless val.is_a?(non_nil_type)
// 92:               T::Props::Private::SetterFactory.raise_pretty_error(
// 93:                 klass,
// 94:                 prop,
// 95:                 T::Utils.coerce(non_nil_type),
// 96:                 val,
// 97:               )
// 98:             end
// 99:             instance.instance_variable_set(accessor_key, val)
// 100:           end,
// 101:         ]
// 102:       end
// 103:
// 104:       sig do
// 105:         params(
// 106:           prop: Symbol,
// 107:           accessor_key: Symbol,
// 108:           non_nil_type: T::Types::Base,
// 109:           klass: T.all(T::Module[T.anything], T::Props::ClassMethods),
// 110:           validate: T.nilable(ValidateProc)
// 111:         )
// 112:         .returns([SetterProc, ValueValidationProc, BoundSetterProc])
// 113:       end
// 114:       private_class_method def self.non_nil_proc(prop, accessor_key, non_nil_type, klass, validate)
// 115:         [
// 116:           proc do |val|
// 117:             # this use of recursively_valid? is intentional: unlike for
// 118:             # methods, we want to make sure data at the 'edge'
// 119:             # (e.g. models that go into databases or structs serialized
// 120:             # from disk) are correct, so we use more thorough runtime
// 121:             # checks there
// 122:             if non_nil_type.recursively_valid?(val)
// 123:               validate&.call(prop, val)
// 124:             else
// 125:               T::Props::Private::SetterFactory.raise_pretty_error(
// 126:                 klass,
// 127:                 prop,
// 128:                 non_nil_type,
// 129:                 val,
// 130:               )
// 131:             end
// 132:             instance_variable_set(accessor_key, val)
// 133:           end,
// 134:           proc do |val|
// 135:             # this use of recursively_valid? is intentional: unlike for
// 136:             # methods, we want to make sure data at the 'edge'
// 137:             # (e.g. models that go into databases or structs serialized
// 138:             # from disk) are correct, so we use more thorough runtime
// 139:             # checks there
// 140:             if non_nil_type.recursively_valid?(val)
// 141:               validate&.call(prop, val)
// 142:             else
// 143:               T::Props::Private::SetterFactory.raise_pretty_error(
// 144:                 klass,
// 145:                 prop,
// 146:                 non_nil_type,
// 147:                 val,
// 148:               )
// 149:             end
// 150:           end,
// 151:           # The ivar set is unconditional, exactly as above: the value must
// 152:           # still be set when call_validation_error_handler does not raise.
// 153:           proc do |instance, val|
// 154:             if non_nil_type.recursively_valid?(val)
// 155:               validate&.call(prop, val)
// 156:             else
// 157:               T::Props::Private::SetterFactory.raise_pretty_error(
// 158:                 klass,
// 159:                 prop,
// 160:                 non_nil_type,
// 161:                 val,
// 162:               )
// 163:             end
// 164:             instance.instance_variable_set(accessor_key, val)
// 165:           end,
// 166:         ]
// 167:       end
// 168:
// 169:       sig do
// 170:         params(
// 171:           prop: Symbol,
// 172:           accessor_key: Symbol,
// 173:           non_nil_type: T::Module[T.anything],
// 174:           klass: T.all(T::Module[T.anything], T::Props::ClassMethods),
// 175:         )
// 176:         .returns([SetterProc, ValueValidationProc, BoundSetterProc])
// 177:       end
// 178:       private_class_method def self.simple_nilable_proc(prop, accessor_key, non_nil_type, klass)
// 179:         [
// 180:           proc do |val|
// 181:             unless val.nil? || val.is_a?(non_nil_type)
// 182:               T::Props::Private::SetterFactory.raise_pretty_error(
// 183:                 klass,
// 184:                 prop,
// 185:                 T::Utils.coerce(non_nil_type),
// 186:                 val,
// 187:               )
// 188:             end
// 189:             instance_variable_set(accessor_key, val)
// 190:           end,
// 191:           proc do |val|
// 192:             unless val.nil? || val.is_a?(non_nil_type)
// 193:               T::Props::Private::SetterFactory.raise_pretty_error(
// 194:                 klass,
// 195:                 prop,
// 196:                 T::Utils.coerce(non_nil_type),
// 197:                 val,
// 198:               )
// 199:             end
// 200:           end,
// 201:           # The ivar set is unconditional, exactly as above: the value must
// 202:           # still be set when call_validation_error_handler does not raise.
// 203:           proc do |instance, val|
// 204:             unless val.nil? || val.is_a?(non_nil_type)
// 205:               T::Props::Private::SetterFactory.raise_pretty_error(
// 206:                 klass,
// 207:                 prop,
// 208:                 T::Utils.coerce(non_nil_type),
// 209:                 val,
// 210:               )
// 211:             end
// 212:             instance.instance_variable_set(accessor_key, val)
// 213:           end,
// 214:         ]
// 215:       end
// 216:
// 217:       sig do
// 218:         params(
// 219:           prop: Symbol,
// 220:           accessor_key: Symbol,
// 221:           non_nil_type: T::Types::Base,
// 222:           klass: T.all(T::Module[T.anything], T::Props::ClassMethods),
// 223:           validate: T.nilable(ValidateProc),
// 224:         )
// 225:         .returns([SetterProc, ValueValidationProc, BoundSetterProc])
// 226:       end
// 227:       private_class_method def self.nilable_proc(prop, accessor_key, non_nil_type, klass, validate)
// 228:         [
// 229:           proc do |val|
// 230:             if val.nil?
// 231:               instance_variable_set(accessor_key, nil)
// 232:             # this use of recursively_valid? is intentional: unlike for
// 233:             # methods, we want to make sure data at the 'edge'
// 234:             # (e.g. models that go into databases or structs serialized
// 235:             # from disk) are correct, so we use more thorough runtime
// 236:             # checks there
// 237:             elsif non_nil_type.recursively_valid?(val)
// 238:               validate&.call(prop, val)
// 239:               instance_variable_set(accessor_key, val)
// 240:             else
// 241:               T::Props::Private::SetterFactory.raise_pretty_error(
// 242:                 klass,
// 243:                 prop,
// 244:                 non_nil_type,
// 245:                 val,
// 246:               )
// 247:               instance_variable_set(accessor_key, val)
// 248:             end
// 249:           end,
// 250:           proc do |val|
// 251:             if val.nil?
// 252:             # this use of recursively_valid? is intentional: unlike for
// 253:             # methods, we want to make sure data at the 'edge'
// 254:             # (e.g. models that go into databases or structs serialized
// 255:             # from disk) are correct, so we use more thorough runtime
// 256:             # checks there
// 257:             elsif non_nil_type.recursively_valid?(val)
// 258:               validate&.call(prop, val)
// 259:             else
// 260:               T::Props::Private::SetterFactory.raise_pretty_error(
// 261:                 klass,
// 262:                 prop,
// 263:                 non_nil_type,
// 264:                 val,
// 265:               )
// 266:             end
// 267:           end,
// 268:           # Branch structure (including the set-after-soft-error in the
// 269:           # invalid arm) replicated exactly from the first proc above.
// 270:           proc do |instance, val|
// 271:             if val.nil?
// 272:               instance.instance_variable_set(accessor_key, nil)
// 273:             elsif non_nil_type.recursively_valid?(val)
// 274:               validate&.call(prop, val)
// 275:               instance.instance_variable_set(accessor_key, val)
// 276:             else
// 277:               T::Props::Private::SetterFactory.raise_pretty_error(
// 278:                 klass,
// 279:                 prop,
// 280:                 non_nil_type,
// 281:                 val,
// 282:               )
// 283:               instance.instance_variable_set(accessor_key, val)
// 284:             end
// 285:           end,
// 286:         ]
// 287:       end
// 288:
// 289:       sig do
// 290:         params(
// 291:           klass: T.all(T::Module[T.anything], T::Props::ClassMethods),
// 292:           prop: Symbol,
// 293:           type: T.any(T::Types::Base, T::Module[T.anything]),
// 294:           val: T.untyped,
// 295:         )
// 296:         .void
// 297:       end
// 298:       def self.raise_pretty_error(klass, prop, type, val)
// 299:         base_message = "Can't set #{klass.name}.#{prop} to #{val.inspect} (instance of #{val.class}) - need a #{type}"
// 300:
// 301:         pretty_message = "Parameter '#{prop}': #{base_message}\n"
// 302:         caller_loc = caller_locations.find { |l| !l.to_s.include?('sorbet-runtime/lib/types/props') }
// 303:         if caller_loc
// 304:           pretty_message += "Caller: #{caller_loc.path}:#{caller_loc.lineno}\n"
// 305:         end
// 306:
// 307:         T::Configuration.call_validation_error_handler(
// 308:           nil,
// 309:           message: base_message,
// 310:           pretty_message: pretty_message,
// 311:           kind: 'Parameter',
// 312:           name: prop,
// 313:           type: type,
// 314:           value: val,
// 315:           location: caller_loc,
// 316:         )
// 317:       end
// 318:     end
// 319:   end
// 320: end
