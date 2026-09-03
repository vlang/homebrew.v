module abstract

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/abstract/hooks.rb`.
// The original source is retained below until every stub has a typed V body.
fn abstract_hook_values(args []brew_runtime.Value) (brew_runtime.Value, brew_runtime.Value) {
	if args.len < 2 {
		panic('abstract hook requires a module and consumer')
	}
	return args[0], args[1]
}

pub fn record_abstract_usage(mod brew_runtime.Value, other brew_runtime.Value) brew_runtime.Value {
	mut data := global_abstract_data()
	return data.set(mod, 'last_used_by', other)
}

pub fn record_abstract_inheritance(mod brew_runtime.Value,
	other brew_runtime.Value) brew_runtime.Value {
	mut data := global_abstract_data()
	if !data.has_key(mod, 'abstract_type') {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return data.set(mod, 'last_used_by', other)
}

pub fn reject_abstract_prepend() ! {
	return error('Prepending abstract mixins is not currently supported.')
}

// Ruby method `extend_object(other)` at line 9.
pub fn ruby_hooks_l9_d1_extend_object(args ...brew_runtime.Value) brew_runtime.Value {
	mod, other := abstract_hook_values(args)
	record_abstract_usage(mod, other)
	return other
}

// Ruby method `append_features(other)` at line 18.
pub fn ruby_hooks_l18_d2_append_features(args ...brew_runtime.Value) brew_runtime.Value {
	mod, other := abstract_hook_values(args)
	record_abstract_usage(mod, other)
	return other
}

// Ruby method `inherited(other)` at line 25.
pub fn ruby_hooks_l25_d3_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	mod, other := abstract_hook_values(args)
	return record_abstract_inheritance(mod, other)
}

// Ruby method `prepended(other)` at line 37.
pub fn ruby_hooks_l37_d4_prepended(args ...brew_runtime.Value) brew_runtime.Value {
	reject_abstract_prepend() or { panic(err.msg()) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Abstract::Hooks
// 5:   # This will become the self.extend_object method on a module that extends Abstract::Hooks.
// 6:   # It gets called when *that* module gets extended in another class/module (similar to the
// 7:   # `extended` hook, but this gets calls before the ancestors of `other` get modified, which
// 8:   # is important for our validation).
// 9:   private def extend_object(other)
// 10:     T::Private::Abstract::Data.set(self, :last_used_by, other)
// 11:     super
// 12:   end
// 13:
// 14:   # This will become the self.append_features method on a module that extends Abstract::Hooks.
// 15:   # It gets called when *that* module gets included in another class/module (similar to the
// 16:   # `included` hook, but this gets calls before the ancestors of `other` get modified, which
// 17:   # is important for our validation).
// 18:   private def append_features(other)
// 19:     T::Private::Abstract::Data.set(self, :last_used_by, other)
// 20:     super
// 21:   end
// 22:
// 23:   # This will become the self.inherited method on a class that extends Abstract::Hooks.
// 24:   # It gets called when *that* class gets inherited by another class.
// 25:   private def inherited(other)
// 26:     super
// 27:     # `self` may not actually be abstract -- it could be a concrete class that inherited from an
// 28:     # abstract class. We only need to check this in `inherited` because, for modules being included
// 29:     # or extended, the concrete ones won't have these hooks at all. This is just an optimization.
// 30:     return if !T::AbstractUtils.abstract_module?(T.unsafe(self))
// 31:
// 32:     T::Private::Abstract::Data.set(self, :last_used_by, other)
// 33:   end
// 34:
// 35:   # This will become the self.prepended method on a module that extends Abstract::Hooks.
// 36:   # It will get called when *that* module gets prepended in another class/module.
// 37:   private def prepended(other)
// 38:     # Prepending abstract methods is weird. You'd only be able to override them via other prepended
// 39:     # modules, or in subclasses. Punt until we have a use case.
// 40:     Kernel.raise "Prepending abstract mixins is not currently supported."
// 41:   end
// 42: end
