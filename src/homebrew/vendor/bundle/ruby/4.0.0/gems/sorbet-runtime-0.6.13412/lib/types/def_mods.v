module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/def_mods.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `abstract(method_name)` at line 22.
pub fn ruby_def_mods_l22_d1_abstract(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('abstract', ...args)
}

// Ruby method `override(method_name, allow_incompatible: false)` at line 34.
pub fn ruby_def_mods_l34_d2_override(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('override', ...args)
}

// Ruby method `final(method_name)` at line 46.
pub fn ruby_def_mods_l46_d3_final(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('final', ...args)
}

// Ruby method `overridable(method_name)` at line 58.
pub fn ruby_def_mods_l58_d4_overridable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('overridable', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Optional mixin providing `abstract`, `override`, `overridable`, and `final`
// 5: # as method-level DSL keywords. Use with `extend T::DefMods`.
// 6: #
// 7: # These are alternatives to writing modifiers inside a `sig { ... }` block:
// 8: #
// 9: #   sig { void }
// 10: #   abstract def foo; end
// 11: #
// 12: # is equivalent to:
// 13: #
// 14: #   sig { abstract.void }
// 15: #   def foo; end
// 16: #
// 17: # They all return the method name, so that they can be chained with methods
// 18: # like `private`. However, unlike those methods, these methods use the `sig`
// 19: # declaration to discover the most-recently-defined method, instead of needing
// 20: # `*_class_method` variants, like `private_class_method`.
// 21: module T::DefMods
// 22:   def abstract(method_name)
// 23:     Kernel.raise TypeError.new("abstract accepts a Symbol, got #{method_name.class}") unless method_name.is_a?(Symbol)
// 24:
// 25:     begin
// 26:       T::Private::Methods.declare_abstract(T.unsafe(self), method_name)
// 27:     rescue T::Private::Methods::DeclBuilder::BuilderError => e
// 28:       T::Configuration.sig_builder_error_handler(e, Kernel.caller_locations(1, 1)&.first)
// 29:     end
// 30:
// 31:     method_name
// 32:   end
// 33:
// 34:   def override(method_name, allow_incompatible: false)
// 35:     Kernel.raise TypeError.new("override accepts a Symbol, got #{method_name.class}") unless method_name.is_a?(Symbol)
// 36:
// 37:     begin
// 38:       T::Private::Methods.declare_override(T.unsafe(self), method_name, allow_incompatible: allow_incompatible)
// 39:     rescue T::Private::Methods::DeclBuilder::BuilderError => e
// 40:       T::Configuration.sig_builder_error_handler(e, Kernel.caller_locations(1, 1)&.first)
// 41:     end
// 42:
// 43:     method_name
// 44:   end
// 45:
// 46:   def final(method_name)
// 47:     Kernel.raise TypeError.new("final accepts a Symbol, got #{method_name.class}") unless method_name.is_a?(Symbol)
// 48:
// 49:     begin
// 50:       T::Private::Methods.declare_final(T.unsafe(self), method_name)
// 51:     rescue T::Private::Methods::DeclBuilder::BuilderError => e
// 52:       T::Configuration.sig_builder_error_handler(e, Kernel.caller_locations(1, 1)&.first)
// 53:     end
// 54:
// 55:     method_name
// 56:   end
// 57:
// 58:   def overridable(method_name)
// 59:     Kernel.raise TypeError.new("overridable accepts a Symbol, got #{method_name.class}") unless method_name.is_a?(Symbol)
// 60:
// 61:     begin
// 62:       T::Private::Methods.declare_overridable(T.unsafe(self), method_name)
// 63:     rescue T::Private::Methods::DeclBuilder::BuilderError => e
// 64:       T::Configuration.sig_builder_error_handler(e, Kernel.caller_locations(1, 1)&.first)
// 65:     end
// 66:
// 67:     method_name
// 68:   end
// 69: end
