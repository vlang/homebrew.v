module methods

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/methods/call_validation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.wrap_method_if_needed(mod, method_sig, original_method)` at line 18.
pub fn ruby_call_validation_l18_d1_self_wrap_method_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.wrap_method_if_needed', ...args)
}

// Ruby method `self.is_allowed_to_have_fast_path` at line 44.
pub fn ruby_call_validation_l44_d2_self_is_allowed_to_have_fast_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.is_allowed_to_have_fast_path', ...args)
}

// Ruby method `self.disable_fast_path` at line 48.
pub fn ruby_call_validation_l48_d3_self_disable_fast_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.disable_fast_path', ...args)
}

// Ruby method `self.create_abstract_wrapper(mod, method_name, original_visibility)` at line 52.
pub fn ruby_call_validation_l52_d4_self_create_abstract_wrapper(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create_abstract_wrapper', ...args)
}

// Ruby method `#{method_name}(...)` at line 58.
pub fn ruby_call_validation_l58_d5_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{method_name}', ...args)
}

// Ruby method `self.create_validator_method(mod, original_method, method_sig, original_visibility)` at line 74.
pub fn ruby_call_validation_l74_d6_self_create_validator_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create_validator_method', ...args)
}

// Ruby method `self.create_validator_slow_skip_block_type(mod, original_method, method_sig, original_visibility)` at line 168.
pub fn ruby_call_validation_l168_d7_self_create_validator_slow_skip_block_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create_validator_slow_skip_block_type', ...args)
}

// Ruby method `self.validate_call_skip_block_type(instance, original_method, method_sig, args, blk)` at line 174.
pub fn ruby_call_validation_l174_d8_self_validate_call_skip_block_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_call_skip_block_type', ...args)
}

// Ruby method `self.create_validator_slow(mod, original_method, method_sig, original_visibility)` at line 250.
pub fn ruby_call_validation_l250_d9_self_create_validator_slow(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create_validator_slow', ...args)
}

// Ruby method `self.validate_call(instance, original_method, method_sig, args, blk)` at line 256.
pub fn ruby_call_validation_l256_d10_self_validate_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_call', ...args)
}

// Ruby method `self.safe_method_owner_to_s(method_owner)` at line 354.
pub fn ruby_call_validation_l354_d11_self_safe_method_owner_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.safe_method_owner_to_s', ...args)
}

// Ruby method `self.report_error(method_sig, error_message, kind, name, type, value, caller_offset: 0)` at line 363.
pub fn ruby_call_validation_l363_d12_self_report_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.report_error', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Methods::CallValidation
// 5:   CallValidation = T::Private::Methods::CallValidation
// 6:   Modes = T::Private::Methods::Modes
// 7:
// 8:   KERNEL_TO_S = Kernel.instance_method(:to_s)
// 9:   MODULE_TO_S = Module.instance_method(:to_s)
// 10:   private_constant(:KERNEL_TO_S, :MODULE_TO_S)
// 11:
// 12:   # Wraps a method with a layer of validation for the given type signature.
// 13:   # This wrapper is meant to be fast, and is applied by a previous wrapper,
// 14:   # which was placed by `_on_method_added`.
// 15:   #
// 16:   # @param method_sig [T::Private::Methods::Signature]
// 17:   # @return [UnboundMethod] the new wrapper method (or the original one if we didn't wrap it)
// 18:   def self.wrap_method_if_needed(mod, method_sig, original_method)
// 19:     original_visibility = T::Private::ClassUtils.visibility_method_name(mod, method_sig.method_name)
// 20:     if method_sig.mode == T::Private::Methods::Modes.abstract
// 21:       create_abstract_wrapper(mod, method_sig.method_name, original_visibility)
// 22:     # Do nothing in this case; this method was not wrapped in _on_method_added.
// 23:     elsif method_sig.defined_raw
// 24:     # Note, this logic is duplicated (intentionally, for micro-perf) at `Methods._on_method_added`,
// 25:     # make sure to keep changes in sync.
// 26:     # This is a trapdoor point for each method:
// 27:     # if a given method is wrapped, it stays wrapped; and if not, it's never wrapped.
// 28:     # (Therefore, we need the `@wrapped_tests_with_validation` check in `T::RuntimeLevels`.)
// 29:     elsif method_sig.check_level == :always || (method_sig.check_level == :tests && T::Private::RuntimeLevels.check_tests?)
// 30:       create_validator_method(mod, original_method, method_sig, original_visibility)
// 31:     else
// 32:       T::Configuration.without_ruby_warnings do
// 33:         # get all the shims out of the way and put back the original method
// 34:         T::Private::DeclState.current.without_on_method_added do
// 35:           T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility, original_method)
// 36:         end
// 37:       end
// 38:     end
// 39:     # Return the newly created method (or the original one if we didn't replace it)
// 40:     mod.instance_method(method_sig.method_name)
// 41:   end
// 42:
// 43:   @is_allowed_to_have_fast_path = true
// 44:   def self.is_allowed_to_have_fast_path
// 45:     @is_allowed_to_have_fast_path
// 46:   end
// 47:
// 48:   def self.disable_fast_path
// 49:     @is_allowed_to_have_fast_path = false
// 50:   end
// 51:
// 52:   def self.create_abstract_wrapper(mod, method_name, original_visibility)
// 53:     T::Configuration.without_ruby_warnings do
// 54:       T::Private::DeclState.current.without_on_method_added do
// 55:         mod.module_eval(<<~METHOD, __FILE__, __LINE__ + 1)
// 56:           #{original_visibility}
// 57:
// 58:           def #{method_name}(...)
// 59:             # We allow abstract methods to be implemented by things further down the ancestor chain.
// 60:             # So, if a super method exists, call it.
// 61:             if defined?(super)
// 62:               super
// 63:             else
// 64:               raise NotImplementedError.new(
// 65:                 "The method `#{method_name}` on #{mod} is declared as `abstract`. It does not have an implementation."
// 66:               )
// 67:             end
// 68:           end
// 69:         METHOD
// 70:       end
// 71:     end
// 72:   end
// 73:
// 74:   def self.create_validator_method(mod, original_method, method_sig, original_visibility)
// 75:     # Wrapper-shape decisions must read the parameters of the method actually being wrapped, not
// 76:     # `method_sig.parameters` (captured at sig-build time). The two diverge when a sig'd method is
// 77:     # re-wrapped over a different implementation: a stub redefined as `def m(*args, **kwargs, &blk)`
// 78:     # then re-validated against the original fixed-arity sig would otherwise pick a fixed-arity wrapper,
// 79:     # which binds args to named positionals and forwards them without the `ruby2_keywords` flag, turning
// 80:     # a trailing `key: val` into a positional hash. Reading from `original_method` costs one array per
// 81:     # wrap, off the hot path.
// 82:     parameters = original_method.parameters
// 83:     has_fixed_arity = method_sig.kwarg_types.empty? && method_sig.rest_type.nil? && method_sig.keyrest_type.nil? &&
// 84:       parameters.all? { |(kind, _name)| kind == :req || kind == :block }
// 85:
// 86:     # nil implies block_type.nil?
// 87:     # true implies !block_type.nil? and block_type.valid?(nil)
// 88:     # false implies !block_type.nil? and !block_type.valid?(nil)
// 89:     # This formulation avoids a type error without introducing extra method calls or local vars
// 90:     can_skip_block_type = method_sig.block_type&.valid?(nil) != false
// 91:
// 92:     ok_for_fast_path = has_fixed_arity && can_skip_block_type && !method_sig.bind && method_sig.arg_types.length < 5 && is_allowed_to_have_fast_path
// 93:
// 94:     # Like `ok_for_fast_path`, but for the specialized wrappers below, each of
// 95:     # which supports exactly one extra call shape (kwargs, a required block, or
// 96:     # optional positional args) on top of what the fast/medium wrappers support.
// 97:     ok_for_specialized_path = !ok_for_fast_path && !method_sig.bind && method_sig.rest_type.nil? &&
// 98:       method_sig.keyrest_type.nil? && method_sig.arg_types.length < 5 && is_allowed_to_have_fast_path
// 99:
// 100:     # Restricted to methods with no positional args. The kwargs wrapper's `|**kwargs, &blk|` declares a
// 101:     # keyword-rest, which would capture a bare `key: val` hash that a method with a positional parameter
// 102:     # expects to receive positionally, starving that parameter. All-kwargs methods have no such parameter,
// 103:     # so the wrapper matches a direct call. (Most kwargs-shaped sigs take only kwargs.)
// 104:     kwargs_path = ok_for_specialized_path && can_skip_block_type && !method_sig.kwarg_types.empty? &&
// 105:       method_sig.arg_types.empty? &&
// 106:       parameters.all? { |(kind, _name)| kind == :key || kind == :keyreq || kind == :block }
// 107:
// 108:     required_block_path = ok_for_specialized_path && !can_skip_block_type && has_fixed_arity
// 109:
// 110:     # At least one param is `:opt` here (otherwise `ok_for_fast_path` would hold). The wrapper forwards
// 111:     # through a `ruby2_keywords`-flagged `|*args, &blk|` splat (see below), not named optional parameters:
// 112:     # named params have no `*rest` for `def_with_visibility` to flag, so a trailing `key: val` that Ruby
// 113:     # packs into an optional positional would lose the keyword flag the slow path preserves.
// 114:     optional_args_path = ok_for_specialized_path && can_skip_block_type && method_sig.kwarg_types.empty? &&
// 115:       parameters.all? { |(kind, _name)| kind == :req || kind == :opt || kind == :block }
// 116:
// 117:     all_args_are_simple = ok_for_fast_path && method_sig.arg_types.all? { |_name, type| type.is_a?(T::Types::Simple) }
// 118:
// 119:     effective_return_type = method_sig.effective_return_type
// 120:     simple_method = all_args_are_simple && effective_return_type.is_a?(T::Types::Simple)
// 121:     simple_procedure = all_args_are_simple && effective_return_type.is_a?(T::Private::Types::Void)
// 122:
// 123:     # All the types for which valid? unconditionally returns `true`
// 124:     return_is_ignorable =
// 125:       effective_return_type.equal?(T::Types::Untyped::Private::INSTANCE) ||
// 126:       effective_return_type.equal?(T::Types::Anything::Private::INSTANCE) ||
// 127:       effective_return_type.equal?(T::Types::AttachedClassType::Private::INSTANCE) ||
// 128:       effective_return_type.equal?(T::Types::SelfType::Private::INSTANCE) ||
// 129:       effective_return_type.is_a?(T::Types::TypeParameter) ||
// 130:       effective_return_type.is_a?(T::Types::TypeVariable) ||
// 131:       (effective_return_type.is_a?(T::Types::Simple) && effective_return_type.raw_type.equal?(BasicObject))
// 132:
// 133:     returns_anything_method = all_args_are_simple && return_is_ignorable
// 134:
// 135:     T::Configuration.without_ruby_warnings do
// 136:       T::Private::DeclState.current.without_on_method_added do
// 137:         if simple_method
// 138:           create_validator_method_fast(mod, original_method, method_sig, original_visibility)
// 139:         elsif returns_anything_method
// 140:           create_validator_method_skip_return_fast(mod, original_method, method_sig, original_visibility)
// 141:         elsif simple_procedure
// 142:           create_validator_procedure_fast(mod, original_method, method_sig, original_visibility)
// 143:         elsif ok_for_fast_path && effective_return_type.is_a?(T::Private::Types::Void)
// 144:           create_validator_procedure_medium(mod, original_method, method_sig, original_visibility)
// 145:         elsif ok_for_fast_path && return_is_ignorable
// 146:           create_validator_method_skip_return_medium(mod, original_method, method_sig, original_visibility)
// 147:         elsif ok_for_fast_path
// 148:           create_validator_method_medium(mod, original_method, method_sig, original_visibility)
// 149:         elsif kwargs_path
// 150:           create_validator_method_kwargs(mod, original_method, method_sig, original_visibility)
// 151:         elsif required_block_path
// 152:           create_validator_method_with_block(mod, original_method, method_sig, original_visibility)
// 153:         elsif optional_args_path
// 154:           create_validator_method_optional_args(mod, original_method, method_sig, original_visibility)
// 155:         elsif can_skip_block_type
// 156:           # The Ruby VM already validates that any block passed to a method
// 157:           # must be either `nil` or a `Proc` object, so there's no need to also
// 158:           # have sorbet-runtime check that.
// 159:           create_validator_slow_skip_block_type(mod, original_method, method_sig, original_visibility)
// 160:         else
// 161:           create_validator_slow(mod, original_method, method_sig, original_visibility)
// 162:         end
// 163:       end
// 164:       mod.send(original_visibility, method_sig.method_name)
// 165:     end
// 166:   end
// 167:
// 168:   def self.create_validator_slow_skip_block_type(mod, original_method, method_sig, original_visibility)
// 169:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 170:       CallValidation.validate_call_skip_block_type(self, original_method, method_sig, args, blk)
// 171:     end
// 172:   end
// 173:
// 174:   def self.validate_call_skip_block_type(instance, original_method, method_sig, args, blk)
// 175:     # This method is called for every `sig`. It's critical to keep it fast and
// 176:     # reduce number of allocations that happen here.
// 177:
// 178:     if method_sig.bind
// 179:       message = method_sig.bind&.error_message_for_obj(instance)
// 180:       if message
// 181:         CallValidation.report_error(
// 182:           method_sig,
// 183:           message,
// 184:           'Bind',
// 185:           nil,
// 186:           method_sig.bind,
// 187:           instance
// 188:         )
// 189:       end
// 190:     end
// 191:
// 192:     # NOTE: We don't bother validating for missing or extra kwargs;
// 193:     # the method call itself will take care of that.
// 194:     method_sig.each_args_value_type(args) do |name, arg, type|
// 195:       message = type.error_message_for_obj(arg)
// 196:       if message
// 197:         CallValidation.report_error(
// 198:           method_sig,
// 199:           message,
// 200:           'Parameter',
// 201:           name,
// 202:           type,
// 203:           arg,
// 204:           caller_offset: 2
// 205:         )
// 206:       end
// 207:     end
// 208:
// 209:     # The original method definition allows passing `nil` for the `&blk`
// 210:     # argument, so we do not have to do any method_sig.block_type type checks
// 211:     # of our own.
// 212:
// 213:     # The following line breaks are intentional to show nice pry message
// 214:
// 215:
// 216:
// 217:
// 218:
// 219:
// 220:
// 221:
// 222:
// 223:
// 224:     # PRY note:
// 225:     # this code is sig validation code.
// 226:     # Please issue `finish` to step out of it
// 227:
// 228:     return_value = original_method.bind_call(instance, *args, &blk)
// 229:
// 230:     # The only type that is allowed to change the return value is `.void`.
// 231:     # It ignores what you returned and changes it to be a private singleton.
// 232:     if method_sig.effective_return_type.is_a?(T::Private::Types::Void)
// 233:       T::Private::Types::Void::VOID
// 234:     else
// 235:       message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 236:       if message
// 237:         CallValidation.report_error(
// 238:           method_sig,
// 239:           message,
// 240:           'Return value',
// 241:           nil,
// 242:           method_sig.effective_return_type,
// 243:           return_value,
// 244:         )
// 245:       end
// 246:       return_value
// 247:     end
// 248:   end
// 249:
// 250:   def self.create_validator_slow(mod, original_method, method_sig, original_visibility)
// 251:     T::Private::ClassUtils.def_with_visibility(mod, method_sig.method_name, original_visibility) do |*args, &blk|
// 252:       CallValidation.validate_call(self, original_method, method_sig, args, blk)
// 253:     end
// 254:   end
// 255:
// 256:   def self.validate_call(instance, original_method, method_sig, args, blk)
// 257:     # This method is called for every `sig`. It's critical to keep it fast and
// 258:     # reduce number of allocations that happen here.
// 259:
// 260:     if method_sig.bind
// 261:       message = method_sig.bind.error_message_for_obj(instance)
// 262:       if message
// 263:         CallValidation.report_error(
// 264:           method_sig,
// 265:           message,
// 266:           'Bind',
// 267:           nil,
// 268:           method_sig.bind,
// 269:           instance
// 270:         )
// 271:       end
// 272:     end
// 273:
// 274:     # NOTE: We don't bother validating for missing or extra kwargs;
// 275:     # the method call itself will take care of that.
// 276:     method_sig.each_args_value_type(args) do |name, arg, type|
// 277:       message = type.error_message_for_obj(arg)
// 278:       if message
// 279:         CallValidation.report_error(
// 280:           method_sig,
// 281:           message,
// 282:           'Parameter',
// 283:           name,
// 284:           type,
// 285:           arg,
// 286:           caller_offset: 2
// 287:         )
// 288:       end
// 289:     end
// 290:
// 291:     # The Ruby VM already checks that `&blk` is either a `Proc` type or `nil`:
// 292:     # https://github.com/ruby/ruby/blob/v2_7_6/vm_args.c#L1150-L1154
// 293:     # And `T.proc` types don't (can't) do any runtime arg checking, so we can
// 294:     # save work by simply checking that `blk` is non-nil (if the method allows
// 295:     # `nil` for the block, it would not have used this validate_call path).
// 296:     unless blk
// 297:       # Have to use `&.` here, because it's technically a public API that
// 298:       # people can _always_ call `validate_call` to validate any signature
// 299:       # (i.e., the faster validators are merely optimizations).
// 300:       # In practice, this only affects the first call to the method (before the
// 301:       # optimized validators have a chance to replace the initial, slow
// 302:       # wrapper).
// 303:       message = method_sig.block_type&.error_message_for_obj(blk)
// 304:       if message
// 305:         CallValidation.report_error(
// 306:           method_sig,
// 307:           message,
// 308:           'Block parameter',
// 309:           method_sig.block_name,
// 310:           method_sig.block_type,
// 311:           blk
// 312:         )
// 313:       end
// 314:     end
// 315:
// 316:     # The following line breaks are intentional to show nice pry message
// 317:
// 318:
// 319:
// 320:
// 321:
// 322:
// 323:
// 324:
// 325:
// 326:
// 327:     # PRY note:
// 328:     # this code is sig validation code.
// 329:     # Please issue `finish` to step out of it
// 330:
// 331:     return_value = original_method.bind_call(instance, *args, &blk)
// 332:
// 333:     # The only type that is allowed to change the return value is `.void`.
// 334:     # It ignores what you returned and changes it to be a private singleton.
// 335:     if method_sig.effective_return_type.is_a?(T::Private::Types::Void)
// 336:       T::Private::Types::Void::VOID
// 337:     else
// 338:       message = method_sig.effective_return_type.error_message_for_obj(return_value)
// 339:       if message
// 340:         CallValidation.report_error(
// 341:           method_sig,
// 342:           message,
// 343:           'Return value',
// 344:           nil,
// 345:           method_sig.effective_return_type,
// 346:           return_value,
// 347:         )
// 348:       end
// 349:       return_value
// 350:     end
// 351:   end
// 352:
// 353:   # Get the name of a method owner via its `.to_s`, but fallback if its implementation raises or returns `nil`.
// 354:   private_class_method def self.safe_method_owner_to_s(method_owner)
// 355:     case method_owner
// 356:     when Module # methods are usually owned by a Class or Module...
// 357:       MODULE_TO_S.bind_call(method_owner)
// 358:     else # ... but could be a singleton method on any kind of Object.
// 359:       KERNEL_TO_S.bind_call(method_owner)
// 360:     end
// 361:   end
// 362:
// 363:   def self.report_error(method_sig, error_message, kind, name, type, value, caller_offset: 0)
// 364:     caller_loc = T.must(caller_locations(3 + caller_offset, 1))[0]
// 365:     method = method_sig.method
// 366:     definition_file, definition_line = method.source_location
// 367:
// 368:     owner = method.owner
// 369:     pretty_method_name =
// 370:       if owner.singleton_class? && owner.respond_to?(:attached_object)
// 371:         # attached_object is new in Ruby 3.2
// 372:         "#{safe_method_owner_to_s(owner.attached_object)}.#{method.name}"
// 373:       else
// 374:         "#{safe_method_owner_to_s(owner)}##{method.name}"
// 375:       end
// 376:
// 377:     pretty_message = "#{kind}#{name ? " '#{name}'" : ''}: #{error_message}\n" \
// 378:       "Caller: #{caller_loc&.path}:#{caller_loc&.lineno}\n" \
// 379:       "Definition: #{definition_file}:#{definition_line} (#{pretty_method_name})"
// 380:
// 381:     T::Configuration.call_validation_error_handler(
// 382:       method_sig,
// 383:       message: error_message,
// 384:       pretty_message: pretty_message,
// 385:       kind: kind,
// 386:       name: name,
// 387:       type: type,
// 388:       value: value,
// 389:       location: caller_loc
// 390:     )
// 391:   end
// 392: end
// 393:
// 394: require_relative './call_validation_2_7'
