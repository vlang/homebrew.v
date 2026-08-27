module tap

import brew_runtime

// Translated from Homebrew/brew `tap/abstract_core_tap.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.instance` at line 21.
pub fn ruby_abstract_core_tap_l21_d1_self_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.instance', ...args)
}

// Ruby method `ensure_installed!` at line 26.
pub fn ruby_abstract_core_tap_l26_d2_ensure_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ensure_installed!', ...args)
}

// Ruby method `implicitly_trusted?(remote: self.remote)` at line 36.
pub fn ruby_abstract_core_tap_l36_d3_implicitly_trusted(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('implicitly_trusted?', ...args)
}

// Ruby method `formula_file_to_name(file)` at line 43.
pub fn ruby_abstract_core_tap_l43_d4_formula_file_to_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_file_to_name', ...args)
}

// Ruby method `should_report_analytics?` at line 48.
pub fn ruby_abstract_core_tap_l48_d5_should_report_analytics(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('should_report_analytics?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # An abstract {Tap} class for the homebrew-core and homebrew-cask.
// 5: class AbstractCoreTap < Tap
// 6:   extend T::Helpers
// 7:
// 8:   abstract!
// 9:
// 10:   class << self
// 11:     Cache = type_member { { fixed: T::Hash[T.any(String, Symbol), T.untyped] } }
// 12:     Elem = type_member(:out) { { fixed: Tap } }
// 13:   end
// 14:
// 15:   private_class_method :fetch
// 16:
// 17:   # Get the singleton instance for this {Tap}.
// 18:   #
// 19:   # @api internal
// 20:   sig { returns(T.attached_class) }
// 21:   def self.instance
// 22:     @instance ||= T.let(T.unsafe(self).new, T.nilable(T.attached_class))
// 23:   end
// 24:
// 25:   sig { override.void }
// 26:   def ensure_installed!
// 27:     return unless Homebrew::EnvConfig.no_install_from_api?
// 28:     return if Homebrew::EnvConfig.automatically_set_no_install_from_api?
// 29:
// 30:     super
// 31:   end
// 32:
// 33:   # In API mode the formulae and casks come from the API rather than this tap's
// 34:   # Git remote, so the remote is irrelevant to what is loaded.
// 35:   sig { override.params(remote: T.nilable(String)).returns(T::Boolean) }
// 36:   def implicitly_trusted?(remote: self.remote)
// 37:     return true unless Homebrew::EnvConfig.no_install_from_api?
// 38:
// 39:     super
// 40:   end
// 41:
// 42:   sig { override.params(file: Pathname).returns(String) }
// 43:   def formula_file_to_name(file)
// 44:     file.basename(".rb").to_s
// 45:   end
// 46:
// 47:   sig { override.returns(T::Boolean) }
// 48:   def should_report_analytics?
// 49:     return super if Homebrew::EnvConfig.no_install_from_api?
// 50:
// 51:     true
// 52:   end
// 53: end
