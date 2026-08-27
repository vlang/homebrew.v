module abstract

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/abstract/validate.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.validate_abstract_module(mod)` at line 10.
pub fn ruby_validate_l10_d1_self_validate_abstract_module(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_abstract_module', ...args)
}

// Ruby method `self.validate_subclass(mod)` at line 17.
pub fn ruby_validate_l17_d2_self_validate_subclass(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_subclass', ...args)
}

// Ruby method `self.validate_interface_all_abstract(mod, method_names)` at line 79.
pub fn ruby_validate_l79_d3_self_validate_interface_all_abstract(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_interface_all_abstract', ...args)
}

// Ruby method `self.validate_interface(mod)` at line 93.
pub fn ruby_validate_l93_d4_self_validate_interface(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_interface', ...args)
}

// Ruby method `self.validate_interface_all_public(mod, method_names)` at line 99.
pub fn ruby_validate_l99_d5_self_validate_interface_all_public(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_interface_all_public', ...args)
}

// Ruby method `self.describe_method(method, show_owner: true)` at line 113.
pub fn ruby_validate_l113_d6_self_describe_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.describe_method', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Abstract::Validate
// 5:   Abstract = T::Private::Abstract
// 6:   AbstractUtils = T::AbstractUtils
// 7:   Methods = T::Private::Methods
// 8:   SignatureValidation = T::Private::Methods::SignatureValidation
// 9:
// 10:   def self.validate_abstract_module(mod)
// 11:     type = Abstract::Data.get(mod, :abstract_type)
// 12:     validate_interface(mod) if :interface == type
// 13:   end
// 14:
// 15:   # Validates a class/module with an abstract class/module as an ancestor. This must be called
// 16:   # after all methods on `mod` have been defined.
// 17:   def self.validate_subclass(mod)
// 18:     can_have_abstract_methods = !T::Private::Abstract::Data.get(mod, :can_have_abstract_methods)
// 19:     unimplemented_methods = []
// 20:
// 21:     T::AbstractUtils.declared_abstract_methods_for(mod).each do |abstract_method|
// 22:       implementation_method = mod.instance_method(abstract_method.name)
// 23:       if AbstractUtils.abstract_method?(implementation_method)
// 24:         # Note that when we end up here, implementation_method might not be the same as
// 25:         # abstract_method; the latter could've been overridden by another abstract method. In either
// 26:         # case, if we have a concrete definition in an ancestor, that will end up as the effective
// 27:         # implementation (see CallValidation.wrap_method_if_needed), so that's what we'll validate
// 28:         # against.
// 29:         implementation_method = T.unsafe(nil)
// 30:         mod.ancestors.each do |ancestor|
// 31:           if ancestor.instance_methods.include?(abstract_method.name)
// 32:             method = ancestor.instance_method(abstract_method.name)
// 33:             T::Private::Methods.maybe_run_sig_block_for_method(method)
// 34:             if !T::AbstractUtils.abstract_method?(method)
// 35:               implementation_method = method
// 36:               break
// 37:             end
// 38:           end
// 39:         end
// 40:         if !implementation_method
// 41:           # There's no implementation
// 42:           if can_have_abstract_methods
// 43:             unimplemented_methods << describe_method(abstract_method)
// 44:           end
// 45:           next # Nothing to validate
// 46:         end
// 47:       end
// 48:
// 49:       implementation_signature = Methods.signature_for_method(implementation_method)
// 50:       # When a signature exists and the method is defined directly on `mod`, we skip the validation
// 51:       # here, because it will have already been done when the method was defined (by
// 52:       # T::Private::Methods._on_method_added).
// 53:       next if implementation_signature&.owner == mod
// 54:
// 55:       # We validate the remaining cases here: (a) methods defined directly on `mod` without a
// 56:       # signature and (b) methods from ancestors (note that these ancestors can come before or
// 57:       # after the abstract module in the inheritance chain -- the former coming from
// 58:       # walking `mod.ancestors` above).
// 59:       abstract_signature = Methods.signature_for_method(abstract_method) || raise("Method being abstract must imply it has a signature")
// 60:       # We allow implementation methods to be defined without a signature.
// 61:       # In that case, get its untyped signature.
// 62:       implementation_signature ||= Methods::Signature.new_untyped(
// 63:         method: implementation_method,
// 64:         mode: Methods::Modes.override
// 65:       )
// 66:       SignatureValidation.validate_override_shape(implementation_signature, abstract_signature)
// 67:       SignatureValidation.validate_override_types(implementation_signature, abstract_signature)
// 68:     end
// 69:
// 70:     method_type = mod.singleton_class? ? "class" : "instance"
// 71:     if !unimplemented_methods.empty?
// 72:       raise "Missing implementation for abstract #{method_type} method(s) in #{mod}:\n" \
// 73:             "#{unimplemented_methods.join("\n")}\n" \
// 74:             "If #{mod} is meant to be an abstract class/module, you can call " \
// 75:             "`abstract!` or `interface!`. Otherwise, you must implement the method(s)."
// 76:     end
// 77:   end
// 78:
// 79:   private_class_method def self.validate_interface_all_abstract(mod, method_names)
// 80:     violations = method_names.map do |method_name|
// 81:       method = mod.instance_method(method_name)
// 82:       if !AbstractUtils.abstract_method?(method)
// 83:         describe_method(method, show_owner: false)
// 84:       end
// 85:     end.compact
// 86:
// 87:     if !violations.empty?
// 88:       raise "`#{mod}` is declared as an interface, but the following methods are not declared " \
// 89:             "with `abstract`:\n#{violations.join("\n")}"
// 90:     end
// 91:   end
// 92:
// 93:   private_class_method def self.validate_interface(mod)
// 94:     interface_methods = T::Utils.methods_excluding_object(mod)
// 95:     validate_interface_all_abstract(mod, interface_methods)
// 96:     validate_interface_all_public(mod, interface_methods)
// 97:   end
// 98:
// 99:   private_class_method def self.validate_interface_all_public(mod, method_names)
// 100:     violations = method_names.map do |method_name|
// 101:       if !mod.public_method_defined?(method_name)
// 102:         describe_method(mod.instance_method(method_name), show_owner: false)
// 103:       end
// 104:     end.compact
// 105:
// 106:     if !violations.empty?
// 107:       raise "All methods on an interface must be public. If you intend to have non-public " \
// 108:             "methods, declare your class/module using `abstract!` instead of `interface!`. " \
// 109:             "The following methods on `#{mod}` are not public: \n#{violations.join("\n")}"
// 110:     end
// 111:   end
// 112:
// 113:   private_class_method def self.describe_method(method, show_owner: true)
// 114:     loc = if (source_loc = method.source_location)
// 115:       source_loc.join(':')
// 116:     else
// 117:       "<unknown location>"
// 118:     end
// 119:
// 120:     owner = if show_owner
// 121:       " declared in #{method.owner}"
// 122:     else
// 123:       ""
// 124:     end
// 125:
// 126:     "    * `#{method.name}`#{owner} at #{loc}"
// 127:   end
// 128: end
