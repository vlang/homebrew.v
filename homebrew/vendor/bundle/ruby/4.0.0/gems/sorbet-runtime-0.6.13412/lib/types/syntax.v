module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/syntax.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.included(other)` at line 32.
pub fn ruby_syntax_l32_d1_self_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.included', ...args)
}

// Ruby method `self.extended(other)` at line 37.
pub fn ruby_syntax_l37_d2_self_extended(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.extended', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: strict
// 3:
// 4: # Used as a shortcut for mixing in the three most common "syntax" extensions
// 5: # that Sorbet provides: `sig`, the various sig DSL methods like `abstract` and
// 6: # `override`, and the `final!`/`interface!` etc. syntax for class-level
// 7: # annotations
// 8: module T::Syntax
// 9:   include T::Sig
// 10:   include T::DefMods
// 11:   include T::Helpers
// 12:
// 13:   # ===== NOTE: Must keep in sync with `T::Sig`! ==============================
// 14:   #
// 15:   # However, there are some slight differences:
// 16:   #
// 17:   # - We don't need the extra `include ... MethodHooks` lines, because those
// 18:   #   come from the `include T::Sig` (c.f. `T::DefMods` though, where those
// 19:   #   extra `include` *are* required because there is otherwise no inheritance
// 20:   #   relationship between `T::Sig` and `T::DefMods`)
// 21:   #
// 22:   # - We don't do the TOP_SELF things, because it's not clear that you ever
// 23:   #   really want this for TOP_SELF. e.g. what would it mean to write
// 24:   #   `interface!` there?
// 25:   #
// 26:   #   Rather than encourage people to write `extend T::Syntax` in their script
// 27:   #   top-levels, let's encourage people to just write `extend T::Sig` to keep
// 28:   #   things simpler.
// 29:   #
// 30:   #   (We could revisit this in the future if people do really want this.)
// 31:
// 32:   private_class_method def self.included(other)
// 33:     return unless Module == other
// 34:     other.prepend(T::Private::Methods::MethodHooks)
// 35:   end
// 36:
// 37:   private_class_method def self.extended(other)
// 38:     return unless Module.===(other) && other.singleton_class?
// 39:     other.include(T::Private::Methods::SingletonMethodHooks)
// 40:   end
// 41:   # ===========================================================================
// 42: end
