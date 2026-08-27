module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/sig.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.included(other)` at line 10.
pub fn ruby_sig_l10_d1_self_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.included', ...args)
}

// Ruby method `self.extended(other)` at line 24.
pub fn ruby_sig_l24_d2_self_extended(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.extended', ...args)
}

// Ruby method `self.sig(arg0=nil, &blk); end` at line 81.
pub fn ruby_sig_l81_d3_self_sig(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sig', ...args)
}

// Ruby method `self.sig(arg0=nil, &blk); end # rubocop:disable Lint/DuplicateMethods` at line 89.
pub fn ruby_sig_l89_d4_self_sig(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sig', ...args)
}

// Ruby method `sig(arg0=nil, &blk)` at line 98.
pub fn ruby_sig_l98_d5_sig(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sig', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: strict
// 3:
// 4: # Used as a mixin to any class so that you can call `sig`.
// 5: # Docs at https://sorbet.org/docs/sigs
// 6: module T::Sig
// 7:   include T::Private::Methods::MethodHooks
// 8:   include T::Private::Methods::SingletonMethodHooks
// 9:
// 10:   private_class_method def self.included(other)
// 11:     return unless Module == other
// 12:
// 13:     # Module#method_added is normally a no-op method that does not call
// 14:     # `super` and immediately returns `nil`. This means that `method_added`
// 15:     # methods defined on an ancestor of `Module` are never called, so for
// 16:     # `Module` itself, we need to redefine to call `super` to forward to the
// 17:     # `method_added` defined above and which is already in the hierarchy.
// 18:     #
// 19:     # (`singleton_method_added` is defined on `BasicObject`, so ours does
// 20:     # override that one.)
// 21:     other.prepend(T::Private::Methods::MethodHooks)
// 22:   end
// 23:
// 24:   private_class_method def self.extended(other)
// 25:     if other == T::Private::Methods::TOP_SELF
// 26:       # Methods defined via `def foo; end` at the top-level of a file are
// 27:       # actually defined as private instance methods on `Object`, so we have to
// 28:       # register our `method_added` hook there.
// 29:       #
// 30:       # Methods defined via `def self.foo; end` at the top-level are defined on
// 31:       # a special instance of `Object` called `main` (initialized by the VM on
// 32:       # startup), and putting `extend T::Sig` at the top-level of a file has
// 33:       # the effect of putting `singleton_method_added` on the singleton class
// 34:       # of `main`, which is catches those methods.
// 35:       Object.extend(T::Private::Methods::MethodHooks)
// 36:       return
// 37:     end
// 38:
// 39:     return unless Module.===(other) && other.singleton_class?
// 40:
// 41:     # Given this:
// 42:     #
// 43:     #     class A
// 44:     #       class << self
// 45:     #         extend T::Sig
// 46:     #       end
// 47:     #     end
// 48:     #
// 49:     # The `singleton_method_added` hook will end up defined as if
// 50:     # `A.singleton_class.singleton_class#singleton_method_added`[1], so methods
// 51:     # defined via `def self.` inside the `class << self` will be hooked, but
// 52:     # not "instance" methods, because for better or worse Ruby chooses to call
// 53:     # `A.singleton_method_added` even for `def foo` (an instance method) inside
// 54:     # a `class << self` definition.[2]
// 55:     #
// 56:     # This forces a problem on users: they need `extend T::Sig` to make `sig`
// 57:     # callable at the class body, but they need `include T::Sig` to make sure
// 58:     # that the `singleton_method_added` hook lands on the right place. To
// 59:     # avoid users needing to do that, we define an extra
// 60:     # `singleton_method_added` on the `attached_object` of the singleton
// 61:     # class, aka `A.singleton_method_added`.[3]
// 62:     #
// 63:     # [1] Not actually--it will be in the ancestor chain, but callable on
// 64:     #   values of that type.
// 65:     #
// 66:     # [2] I imagine this is for backwards compatibility in the common case of
// 67:     #   one level of `class << self` nesting, so that people can define a
// 68:     #   single `singleton_method_added` hook and have it fire for `def
// 69:     #   self.foo` methods outside and `def foo` inside.
// 70:     #
// 71:     # [3] Before switching to having the hooks defined eagerly `T::Sig`
// 72:     #   itself, this was done lazily via `include(SingletonMethodHooks)`
// 73:     #   instead of `extend(MethodHooks)` on the first call to `sig` inside
// 74:     #   the `class << self`.
// 75:     other.include(T::Private::Methods::SingletonMethodHooks)
// 76:   end
// 77:
// 78:   module WithoutRuntime
// 79:     # At runtime, does nothing, but statically it is treated exactly the same
// 80:     # as T::Sig#sig. Only use it in cases where you can't use T::Sig#sig.
// 81:     def self.sig(arg0=nil, &blk); end
// 82:
// 83:     original_verbose = $VERBOSE
// 84:     $VERBOSE = false
// 85:
// 86:     # At runtime, does nothing, but statically it is treated exactly the same
// 87:     # as T::Sig#sig. Only use it in cases where you can't use T::Sig#sig.
// 88:     T::Sig::WithoutRuntime.sig { params(arg0: T.nilable(Symbol), blk: T.proc.bind(T::Private::Methods::DeclBuilder).void).void }
// 89:     def self.sig(arg0=nil, &blk); end # rubocop:disable Lint/DuplicateMethods
// 90:
// 91:     $VERBOSE = original_verbose
// 92:   end
// 93:
// 94:   # Declares a method with type signatures and/or
// 95:   # abstract/override/... helpers. See the documentation URL on
// 96:   # {T::Helpers}
// 97:   T::Sig::WithoutRuntime.sig { params(arg0: T.nilable(Symbol), blk: T.proc.bind(T::Private::Methods::DeclBuilder).void).void }
// 98:   def sig(arg0=nil, &blk)
// 99:     T::Private::Methods.declare_sig(T.unsafe(self), Kernel.caller_locations(1, 1)&.first, arg0, &blk)
// 100:   end
// 101: end
