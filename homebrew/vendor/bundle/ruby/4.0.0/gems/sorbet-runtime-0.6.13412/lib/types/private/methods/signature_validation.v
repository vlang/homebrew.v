module methods

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/methods/signature_validation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.validate(signature)` at line 8.
pub fn ruby_signature_validation_l8_d1_self_validate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate', ...args)
}

// Ruby method `self.pretty_mode(mode)` at line 101.
pub fn ruby_signature_validation_l101_d2_self_pretty_mode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.pretty_mode', ...args)
}

// Ruby method `self.validate_override_mode(signature, super_signature)` at line 109.
pub fn ruby_signature_validation_l109_d3_self_validate_override_mode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_override_mode', ...args)
}

// Ruby method `self.validate_non_override_mode(mode, method_name, method, source_loc=method.source_location)` at line 143.
pub fn ruby_signature_validation_l143_d4_self_validate_non_override_mode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_non_override_mode', ...args)
}

// Ruby method `self.validate_override_shape(signature, super_signature)` at line 180.
pub fn ruby_signature_validation_l180_d5_self_validate_override_shape(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_override_shape', ...args)
}

// Ruby method `self.check_level_active?(sig)` at line 245.
pub fn ruby_signature_validation_l245_d6_self_check_level_active(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check_level_active?', ...args)
}

// Ruby method `self.validate_override_types(signature, super_signature)` at line 249.
pub fn ruby_signature_validation_l249_d7_self_validate_override_types(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_override_types', ...args)
}

// Ruby method `self.validate_override_visibility(signature, super_signature)` at line 316.
pub fn ruby_signature_validation_l316_d8_self_validate_override_visibility(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_override_visibility', ...args)
}

// Ruby method `self.method_visibility(method)` at line 339.
pub fn ruby_signature_validation_l339_d9_self_method_visibility(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.method_visibility', ...args)
}

// Ruby method `self.visibility_strength(vis)` at line 347.
pub fn ruby_signature_validation_l347_d10_self_visibility_strength(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.visibility_strength', ...args)
}

// Ruby method `self.base_override_loc_str(signature, super_signature)` at line 351.
pub fn ruby_signature_validation_l351_d11_self_base_override_loc_str(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.base_override_loc_str', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Methods::SignatureValidation
// 5:   Methods = T::Private::Methods
// 6:   Modes = Methods::Modes
// 7:
// 8:   def self.validate(signature)
// 9:     # Constructors in any language are always a bit weird: they're called in a
// 10:     # static context, but their bodies are implemented by instance methods. So
// 11:     # a mix of the rules that apply to instance methods and class methods
// 12:     # apply.
// 13:     #
// 14:     # In languages like Java and Scala, static methods/companion object methods
// 15:     # are never inherited. (In Java it almost looks like you can inherit them,
// 16:     # because `Child.static_parent_method` works, but this method is simply
// 17:     # resolved statically to `Parent.static_parent_method`). Even though most
// 18:     # instance methods overrides have variance checking done, constructors are
// 19:     # not treated like this, because static methods are never
// 20:     # inherited/overridden, and the constructor can only ever be called
// 21:     # indirectly by way of the static method. (Note: this is only a mental
// 22:     # model--there's not actually a static method for the constructor in Java,
// 23:     # there's an `invokespecial` JVM instruction that handles this).
// 24:     #
// 25:     # But Ruby is not like Java: singleton class methods in Ruby *are*
// 26:     # inherited, unlike static methods in Java. In fact, this is similar to how
// 27:     # JavaScript works. TypeScript simply then sidesteps the issue with
// 28:     # structural typing: `typeof Parent` is not compatible with `typeof Child`
// 29:     # if their constructors are different. (In a nominal type system, simply
// 30:     # having Child descend from Parent should be the only factor in determining
// 31:     # whether those types are compatible).
// 32:     #
// 33:     # Flow has nominal subtyping for classes. When overriding (static and
// 34:     # instance) methods in a child class, the overrides must satisfy variance
// 35:     # constraints. But it still carves out an exception for constructors,
// 36:     # because then literally every class would have to have the same
// 37:     # constructor. This is simply unsound. Hack does a similar thing--static
// 38:     # method overrides are checked, but not constructors. Though what Hack
// 39:     # *does* have is a way to opt into override checking for constructors with
// 40:     # a special annotation.
// 41:     #
// 42:     # It turns out, Sorbet already has this special annotation: either
// 43:     # `abstract` or `overridable`. At time of writing, *no* static override
// 44:     # checking happens unless marked with these keywords (though at runtime, it
// 45:     # always happens). Getting the static system to parity with the runtime by
// 46:     # always checking overrides would be a great place to get to one day, but
// 47:     # for now we can take advantage of it by only doing override checks for
// 48:     # constructors if they've opted in.
// 49:     #
// 50:     # (When we get around to more widely checking overrides statically, we will
// 51:     # need to build a matching special case for constructors statically.)
// 52:     #
// 53:     # Note that this breaks with tradition: normally, constructors are not
// 54:     # allowed to be abstract. But that's kind of a side-effect of everything
// 55:     # above: in Java/Scala, singleton class methods are never abstract because
// 56:     # they're not inherited, and this extends to constructors. TypeScript
// 57:     # simply rejects `new klass()` entirely if `klass` is
// 58:     # `typeof AbstractClass`, requiring instead that you write
// 59:     # `{ new(): AbstractClass }`. We may want to consider building some
// 60:     # analogue to `T.class_of` in the future that works like this `{new():
// 61:     # ...}` type.
// 62:     if signature.method_name == :initialize && signature.method.owner.is_a?(Class) &&
// 63:         signature.mode == Modes.standard
// 64:       return
// 65:     end
// 66:
// 67:     super_method = signature.method.super_method
// 68:
// 69:     if super_method && super_method.owner != signature.method.owner
// 70:       # No need to run the sig block for super_method explicitly:
// 71:       # signature_for_method forces it internally (via signature_for_key ->
// 72:       # maybe_run_sig_block_for_key on the identical registry key).
// 73:       super_signature = Methods.signature_for_method(super_method)
// 74:
// 75:       # If the super_method has any kwargs we can't build a
// 76:       # Signature for it, so we'll just skip validation in that case.
// 77:       if !super_signature && !super_method.parameters.select { |kind, _| kind == :rest || kind == :kwrest }.empty?
// 78:         nil
// 79:       else
// 80:         # super_signature can be nil when we're overriding a method (perhaps a builtin) that didn't use
// 81:         # one of the method signature helpers. Use an untyped signature so we can still validate
// 82:         # everything but types.
// 83:         #
// 84:         # We treat these signatures as overridable, that way people can use `.override` with
// 85:         # overrides of builtins. In the future we could try to distinguish when the method is a
// 86:         # builtin and treat non-builtins as non-overridable (so you'd be forced to declare them with
// 87:         # `.overridable`).
// 88:         #
// 89:         super_signature ||= Methods::Signature.new_untyped(method: super_method)
// 90:
// 91:         validate_override_mode(signature, super_signature)
// 92:         validate_override_shape(signature, super_signature)
// 93:         validate_override_types(signature, super_signature)
// 94:         validate_override_visibility(signature, super_signature)
// 95:       end
// 96:     else
// 97:       validate_non_override_mode(signature.mode, signature.method_name, signature.method)
// 98:     end
// 99:   end
// 100:
// 101:   private_class_method def self.pretty_mode(mode)
// 102:     if mode == Modes.overridable_override
// 103:       'overridable.override'
// 104:     else
// 105:       mode
// 106:     end
// 107:   end
// 108:
// 109:   def self.validate_override_mode(signature, super_signature)
// 110:     case signature.mode
// 111:     when *Modes::OVERRIDE_MODES
// 112:       # Peaceful
// 113:     when Modes.abstract
// 114:       # Either the parent method is abstract, or it's not.
// 115:       #
// 116:       # If it's abstract, we want to allow overriding abstract with abstract to
// 117:       # possibly narrow the type or provide more specific documentation.
// 118:       #
// 119:       # If it's not, then marking this method `abstract` will silently be a no-op.
// 120:       # That's bad and we probably want to report an error, but fixing that
// 121:       # will have to be a separate fix (that bad behavior predates this current
// 122:       # comment, introduced when we fixed the abstract/abstract case).
// 123:       #
// 124:       # Therefore:
// 125:       # Peaceful (mostly)
// 126:     when *Modes::NON_OVERRIDE_MODES
// 127:       if super_signature.mode == Modes.standard
// 128:         # Peaceful
// 129:       elsif super_signature.mode == Modes.abstract
// 130:         raise "You must use `.override` when overriding the abstract method `#{signature.method_name}`.\n" \
// 131:               "  Abstract definition: #{super_signature.method_desc}\n" \
// 132:               "  Implementation definition: #{signature.method_desc}\n"
// 133:       elsif super_signature.mode != Modes.untyped
// 134:         raise "You must use `.override` when overriding the existing method `#{signature.method_name}`.\n" \
// 135:               "  Parent definition: #{super_signature.method_desc}\n" \
// 136:               "  Child definition:  #{signature.method_desc}\n"
// 137:       end
// 138:     else
// 139:       raise "Unexpected mode: #{signature.mode}. Please report this bug at https://github.com/sorbet/sorbet/issues"
// 140:     end
// 141:   end
// 142:
// 143:   def self.validate_non_override_mode(mode, method_name, method, source_loc=method.source_location)
// 144:     case mode
// 145:     when Modes.override
// 146:       if method_name == :each && method.owner < Enumerable
// 147:         # Enumerable#each is the only method in Sorbet's RBI payload that defines an abstract method.
// 148:         # Enumerable#each does not actually exist at runtime, but it is required to be implemented by
// 149:         # any class which includes Enumerable. We want to declare Enumerable#each as abstract so that
// 150:         # people can call it anything which implements the Enumerable interface, and so that it's a
// 151:         # static error to forget to implement it.
// 152:         #
// 153:         # This is a one-off hack, and we should think carefully before adding more methods here.
// 154:         nil
// 155:       else
// 156:         raise "You marked `#{method_name}` as #{pretty_mode(mode)}, but that method doesn't already exist in this class/module to be overridden.\n" \
// 157:           "  Either check for typos and for missing includes or super classes to make the parent method shows up\n" \
// 158:           "  ... or remove #{pretty_mode(mode)} here: #{T::Private::Methods::Signature.method_desc(method, method_name, source_loc)}\n"
// 159:       end
// 160:     when Modes.standard, *Modes::NON_OVERRIDE_MODES
// 161:       # Peaceful
// 162:       nil
// 163:     else
// 164:       raise "Unexpected mode: #{mode}. Please report this bug at https://github.com/sorbet/sorbet/issues"
// 165:     end
// 166:
// 167:     # Given a singleton class, we can check if it belongs to a
// 168:     # module by looking at its superclass; given `module M`,
// 169:     # `M.singleton_class.superclass == Module`, which is not true
// 170:     # for any class.
// 171:     owner = method.owner
// 172:     if (mode == Modes.abstract || Modes::OVERRIDABLE_MODES.include?(mode)) &&
// 173:         owner.singleton_class? && Class === owner && owner.superclass == Module
// 174:       raise "Defining an overridable class method (via #{pretty_mode(mode)}) " \
// 175:             "on a module is not allowed. Class methods on " \
// 176:             "modules do not get inherited and thus cannot be overridden."
// 177:     end
// 178:   end
// 179:
// 180:   def self.validate_override_shape(signature, super_signature)
// 181:     return if signature.override_allow_incompatible == true
// 182:     return if super_signature.mode == Modes.untyped
// 183:
// 184:     method_name = signature.method_name
// 185:     mode_verb = super_signature.mode == Modes.abstract ? 'implements' : 'overrides'
// 186:
// 187:     if signature.rest_type.nil? && signature.arg_count < super_signature.arg_count
// 188:       raise "Your definition of `#{method_name}` must accept at least #{super_signature.arg_count} " \
// 189:             "positional arguments to be compatible with the method it #{mode_verb}: " \
// 190:             "#{base_override_loc_str(signature, super_signature)}"
// 191:     end
// 192:
// 193:     if signature.rest_type.nil? && !super_signature.rest_type.nil?
// 194:       raise "Your definition of `#{method_name}` must have `*#{super_signature.rest_name}` " \
// 195:             "to be compatible with the method it #{mode_verb}: " \
// 196:             "#{base_override_loc_str(signature, super_signature)}"
// 197:     end
// 198:
// 199:     if signature.req_arg_count > super_signature.req_arg_count
// 200:       raise "Your definition of `#{method_name}` must have no more than #{super_signature.req_arg_count} " \
// 201:             "required argument(s) to be compatible with the method it #{mode_verb}: " \
// 202:             "#{base_override_loc_str(signature, super_signature)}"
// 203:     end
// 204:
// 205:     # The kwarg_types.empty? guard is an exact implication (an empty super
// 206:     # kwarg set can never yield missing kwargs) that skips two fresh
// 207:     # `.keys` arrays plus the Array#- for the common kwarg-free method.
// 208:     if signature.keyrest_type.nil? && !super_signature.kwarg_types.empty?
// 209:       # O(nm), but n and m are tiny here
// 210:       missing_kwargs = super_signature.kwarg_names - signature.kwarg_names
// 211:       if !missing_kwargs.empty?
// 212:         raise "Your definition of `#{method_name}` is missing these keyword arg(s): #{missing_kwargs} " \
// 213:               "which are defined in the method it #{mode_verb}: " \
// 214:               "#{base_override_loc_str(signature, super_signature)}"
// 215:       end
// 216:     end
// 217:
// 218:     if signature.keyrest_type.nil? && !super_signature.keyrest_type.nil?
// 219:       raise "Your definition of `#{method_name}` must have `**#{super_signature.keyrest_name}` " \
// 220:             "to be compatible with the method it #{mode_verb}: " \
// 221:             "#{base_override_loc_str(signature, super_signature)}"
// 222:     end
// 223:
// 224:     # Guard on the minuend: an empty req_kwarg_names can never yield extras.
// 225:     if !signature.req_kwarg_names.empty?
// 226:       # O(nm), but n and m are tiny here
// 227:       extra_req_kwargs = signature.req_kwarg_names - super_signature.req_kwarg_names
// 228:       if !extra_req_kwargs.empty?
// 229:         raise "Your definition of `#{method_name}` has extra required keyword arg(s) " \
// 230:               "#{extra_req_kwargs} relative to the method it #{mode_verb}, making it incompatible: " \
// 231:               "#{base_override_loc_str(signature, super_signature)}"
// 232:       end
// 233:     end
// 234:
// 235:     if super_signature.block_name && !signature.block_name
// 236:       raise "Your definition of `#{method_name}` must accept a block parameter to be compatible " \
// 237:             "with the method it #{mode_verb}: " \
// 238:             "#{base_override_loc_str(signature, super_signature)}"
// 239:     end
// 240:   end
// 241:
// 242:   # Evaluation order matters: check_tests? must only run for a :tests-checked
// 243:   # sig (it side-effectfully arms the @wrapped_tests_with_validation trapdoor
// 244:   # in RuntimeLevels).
// 245:   private_class_method def self.check_level_active?(sig)
// 246:     sig.check_level == :always || (sig.check_level == :tests && T::Private::RuntimeLevels.check_tests?)
// 247:   end
// 248:
// 249:   def self.validate_override_types(signature, super_signature)
// 250:     return if signature.override_allow_incompatible == true
// 251:     return if super_signature.mode == Modes.untyped
// 252:     return unless check_level_active?(signature) && check_level_active?(super_signature)
// 253:     mode_noun = super_signature.mode == Modes.abstract ? 'implementation' : 'override'
// 254:
// 255:     # arg types must be contravariant
// 256:     #
// 257:     # An index loop avoids allocating a pair array per positional arg.
// 258:     # Iterating to super's length is deliberate: extra override positionals
// 259:     # go unchecked, and when the override folds the remaining base positionals
// 260:     # into a rest param, each is checked against the rest param's type
// 261:     # (validate_override_shape guarantees such a rest param exists here).
// 262:     super_arg_types = super_signature.arg_types
// 263:     arg_types = signature.arg_types
// 264:     rest_type = signature.rest_type
// 265:     index = 0
// 266:     while index < super_arg_types.length
// 267:       super_type = super_arg_types.fetch(index)[1]
// 268:       pair = arg_types[index]
// 269:       if pair
// 270:         name = pair[0]
// 271:         type = pair[1]
// 272:       else
// 273:         name = signature.rest_name
// 274:         type = rest_type
// 275:       end
// 276:       if !super_type.subtype_of?(type)
// 277:         raise "Incompatible type for arg ##{index + 1} (`#{name}`) in signature for #{mode_noun} of method " \
// 278:               "`#{signature.method_name}`:\n" \
// 279:               "* Base: `#{super_type}` (in #{super_signature.method_desc})\n" \
// 280:               "* #{mode_noun.capitalize}: `#{type}` (in #{signature.method_desc})\n" \
// 281:               "(The types must be contravariant.)"
// 282:       end
// 283:       index += 1
// 284:     end
// 285:
// 286:     # kwarg types must be contravariant
// 287:     super_signature.kwarg_types.each do |name, super_type|
// 288:       type = signature.kwarg_types[name]
// 289:       if !super_type.subtype_of?(type)
// 290:         raise "Incompatible type for arg `#{name}` in signature for #{mode_noun} of method `#{signature.method_name}`:\n" \
// 291:               "* Base: `#{super_type}` (in #{super_signature.method_desc})\n" \
// 292:               "* #{mode_noun.capitalize}: `#{type}` (in #{signature.method_desc})\n" \
// 293:               "(The types must be contravariant.)"
// 294:       end
// 295:     end
// 296:
// 297:     # return types must be covariant
// 298:     super_signature_return_type = super_signature.effective_return_type
// 299:
// 300:     if super_signature_return_type == T::Private::Types::Void::Private::INSTANCE
// 301:       # Treat `.void` as `T.anything` (see corresponding comment in definition_valitor for more)
// 302:       super_signature_return_type = T::Types::Anything::Private::INSTANCE
// 303:     end
// 304:
// 305:     if !signature.effective_return_type.subtype_of?(super_signature_return_type)
// 306:       raise "Incompatible return type in signature for #{mode_noun} of method `#{signature.method_name}`:\n" \
// 307:             "* Base: `#{super_signature.effective_return_type}` (in #{super_signature.method_desc})\n" \
// 308:             "* #{mode_noun.capitalize}: `#{signature.effective_return_type}` (in #{signature.method_desc})\n" \
// 309:             "(The types must be covariant.)"
// 310:     end
// 311:   end
// 312:
// 313:   ALLOW_INCOMPATIBLE_VISIBILITY = [:visibility, true].freeze
// 314:   private_constant :ALLOW_INCOMPATIBLE_VISIBILITY
// 315:
// 316:   def self.validate_override_visibility(signature, super_signature)
// 317:     return if super_signature.mode == Modes.untyped
// 318:     # This departs from the behavior of other `validate_override_whatever` functions in that it
// 319:     # only comes into effect when the child signature explicitly says the word `override`. This was
// 320:     # done because the primary method for silencing these errors (`allow_incompatible: :visibility`)
// 321:     # requires an `override` node to attach to. Once we have static override checking for implicitly
// 322:     # overridden methods, we can remove this.
// 323:     return unless Modes::OVERRIDE_MODES.include?(signature.mode)
// 324:     return if ALLOW_INCOMPATIBLE_VISIBILITY.include?(signature.override_allow_incompatible)
// 325:     method = signature.method
// 326:     super_method = super_signature.method
// 327:     mode_noun = super_signature.mode == Modes.abstract ? 'implementation' : 'override'
// 328:     vis = method_visibility(method)
// 329:     super_vis = method_visibility(super_method)
// 330:
// 331:     if visibility_strength(vis) > visibility_strength(super_vis)
// 332:       raise "Incompatible visibility for #{mode_noun} of method #{method.name}\n" \
// 333:             "* Base: #{super_vis} (in #{super_signature.method_desc})\n" \
// 334:             "* #{mode_noun.capitalize}: #{vis} (in #{signature.method_desc})\n" \
// 335:             "(The override must be at least as permissive as the supermethod)" \
// 336:     end
// 337:   end
// 338:
// 339:   private_class_method def self.method_visibility(method)
// 340:     T::Private::ClassUtils.visibility_method_name(method.owner, method.name)
// 341:   end
// 342:
// 343:   # Higher = more restrictive.
// 344:   METHOD_VISIBILITIES = %i[public protected private].freeze
// 345:   private_constant :METHOD_VISIBILITIES
// 346:
// 347:   private_class_method def self.visibility_strength(vis)
// 348:     METHOD_VISIBILITIES.find_index(vis) || raise("Unexpected visibility `#{vis}`")
// 349:   end
// 350:
// 351:   private_class_method def self.base_override_loc_str(signature, super_signature)
// 352:     mode_noun = super_signature.mode == Modes.abstract ? 'Implementation' : 'Override'
// 353:     "\n * Base definition: in #{super_signature.method_desc}" \
// 354:     "\n * #{mode_noun}: in #{signature.method_desc}"
// 355:   end
// 356: end
