module tap

import brew_runtime

// Translated from Homebrew/brew `tap/tap_config.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :tap` at line 7.
pub fn ruby_tap_config_l7_d1_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby method `initialize(tap)` at line 10.
pub fn ruby_tap_config_l10_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `[](key)` at line 15.
pub fn ruby_tap_config_l15_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]', ...args)
}

// Ruby method `[]=(key, value)` at line 26.
pub fn ruby_tap_config_l26_d4_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]=', ...args)
}

// Ruby method `delete(key)` at line 34.
pub fn ruby_tap_config_l34_d5_delete(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Permanent configuration per {Tap} using `git-config(1)`.
// 5: class TapConfig
// 6:   sig { returns(Tap) }
// 7:   attr_reader :tap
// 8:
// 9:   sig { params(tap: Tap).void }
// 10:   def initialize(tap)
// 11:     @tap = tap
// 12:   end
// 13:
// 14:   sig { params(key: Symbol).returns(T.nilable(T::Boolean)) }
// 15:   def [](key)
// 16:     return unless tap.git?
// 17:     return unless Utils::Git.available?
// 18:
// 19:     case Homebrew::Settings.read(key, repo: tap.path)
// 20:     when "true" then true
// 21:     when "false" then false
// 22:     end
// 23:   end
// 24:
// 25:   sig { params(key: Symbol, value: T::Boolean).void }
// 26:   def []=(key, value)
// 27:     return unless tap.git?
// 28:     return unless Utils::Git.available?
// 29:
// 30:     Homebrew::Settings.write key, value.to_s, repo: tap.path
// 31:   end
// 32:
// 33:   sig { params(key: Symbol).void }
// 34:   def delete(key)
// 35:     return unless tap.git?
// 36:     return unless Utils::Git.available?
// 37:
// 38:     Homebrew::Settings.delete key, repo: tap.path
// 39:   end
// 40: end
