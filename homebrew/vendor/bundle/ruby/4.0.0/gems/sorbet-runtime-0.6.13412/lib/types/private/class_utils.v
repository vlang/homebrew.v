module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/class_utils.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.visibility_method_name(mod, name)` at line 13.
pub fn ruby_class_utils_l13_d1_self_visibility_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.visibility_method_name', ...args)
}

// Ruby method `self.def_with_visibility(mod, name, visibility, method=nil, &block)` at line 31.
pub fn ruby_class_utils_l31_d2_self_def_with_visibility(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.def_with_visibility', ...args)
}

// Ruby define_method `define_method(name, method)` at line 41.
pub fn ruby_class_utils_l41_d3_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby define_method `define_method(name, &block)` at line 43.
pub fn ruby_class_utils_l43_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `self.replace_method(original_method, mod, name, &blk)` at line 67.
pub fn ruby_class_utils_l67_d5_self_replace_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.replace_method', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Cut down version of Chalk::Tools::ClassUtils with only :replace_method functionality.
// 5: # Extracted to a separate namespace so the type system can be used standalone.
// 6: #
// 7: # Note: the functionality to "restore" a method was removed, because it is no
// 8: # longer being used by sorbet-runtime. Restoring a method requires care--if you
// 9: # need to reintroduce this functionality, consult the git history for how to do
// 10: # it safely.
// 11: module T::Private::ClassUtils
// 12:   # `name` must be an instance method (for class methods, pass in mod.singleton_class)
// 13:   def self.visibility_method_name(mod, name)
// 14:     if mod.public_method_defined?(name)
// 15:       :public
// 16:     elsif mod.protected_method_defined?(name)
// 17:       :protected
// 18:     elsif mod.private_method_defined?(name)
// 19:       :private
// 20:     else
// 21:       # Raises a NameError formatted like the Ruby VM would (the exact text formatting
// 22:       # of these errors changed across Ruby VM versions, in ways that would sometimes
// 23:       # cause tests to fail if they were dependent on hard coding errors).
// 24:       mod.method(name)
// 25:       # This is just to prove to Sorbet that this method raises.
// 26:       # This line should be unreachable in practice due to the above call.
// 27:       raise NameError.new("undefined method `#{name}' for class `#{mod}'")
// 28:     end
// 29:   end
// 30:
// 31:   def self.def_with_visibility(mod, name, visibility, method=nil, &block)
// 32:     mod.module_exec do
// 33:       # Start a visibility (public/protected/private) region, so that
// 34:       # all of the method redefinitions happen with the right visibility
// 35:       # from the beginning. This ensures that any other code that is
// 36:       # triggered by `method_added`, sees the redefined method with the
// 37:       # right visibility.
// 38:       send(visibility)
// 39:
// 40:       if method
// 41:         define_method(name, method)
// 42:       else
// 43:         define_method(name, &block)
// 44:       end
// 45:
// 46:       if block && block.arity < 0 && respond_to?(:ruby2_keywords, true)
// 47:         # Fetch .parameters once: each call builds a fresh array.
// 48:         parameters = instance_method(name).parameters
// 49:         has_rest = parameters.any? { |kind, _| kind == :rest }
// 50:         has_keywords = parameters.any? { |kind, _| kind == :keyrest || kind == :keyreq || kind == :key }
// 51:         ruby2_keywords(name) if has_rest && !has_keywords
// 52:       end
// 53:     end
// 54:   end
// 55:
// 56:   # Replaces a method, either by overwriting it (if it is defined directly on
// 57:   # `mod`) or by overriding it (if it is defined by one of mod's ancestors).
// 58:   #
// 59:   # Takes the `original_method` as a parameter, so it does not return anything.
// 60:   #
// 61:   # Can also avoid `T.let` pinning errors by letting the caller pre-compute the
// 62:   # `original_method`, so it knows that it will always be defined (because it
// 63:   # doesn't know that the block will always run once)
// 64:   #
// 65:   # Does not share code with `replace_method_with_handle`, for performance (do
// 66:   # not want to increase the call stack, as this is a very sensitive code path).
// 67:   def self.replace_method(original_method, mod, name, &blk)
// 68:     original_visibility = visibility_method_name(mod, name)
// 69:     original_owner = original_method.owner
// 70:
// 71:     # In the common case the method is owned by `mod` itself, in which case the loop below
// 72:     # would always `break` before the raise could match (`mod` precedes any non-prepended
// 73:     # ancestor in its own ancestor chain), so skip computing `mod.ancestors` entirely.
// 74:     if original_owner != mod
// 75:       mod.ancestors.each do |ancestor|
// 76:         break if ancestor == mod
// 77:         if ancestor == original_owner
// 78:           # If we get here, that means the method we're trying to replace exists on a *prepended*
// 79:           # mixin, which means in order to supersede it, we'd need to create a method on a new
// 80:           # module that we'd prepend before `ancestor`. The problem with that approach is there'd
// 81:           # be no way to remove that new module after prepending it, so we'd be left with these
// 82:           # empty anonymous modules in the ancestor chain after calling `restore`.
// 83:           #
// 84:           # That's not necessarily a deal breaker, but for now, we're keeping it as unsupported.
// 85:           raise "You're trying to replace `#{name}` on `#{mod}`, but that method exists in a " \
// 86:                 "prepended module (#{ancestor}), which we don't currently support."
// 87:         end
// 88:       end
// 89:     end
// 90:
// 91:     T::Configuration.without_ruby_warnings do
// 92:       T::Private::DeclState.current.without_on_method_added do
// 93:         def_with_visibility(mod, name, original_visibility, &blk)
// 94:       end
// 95:     end
// 96:
// 97:     nil
// 98:   end
// 99: end
