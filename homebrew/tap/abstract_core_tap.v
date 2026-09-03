module tap

import os

// Translated from Homebrew/brew `tap/abstract_core_tap.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum AbstractCoreTapKind {
	core
	cask
}

pub struct AbstractCoreTap {
pub:
	kind AbstractCoreTapKind
}

pub fn abstract_core_tap_instance(kind AbstractCoreTapKind) AbstractCoreTap {
	return AbstractCoreTap{ kind: kind }
}

pub fn abstract_core_tap_should_install(no_install_from_api bool,
	automatically_set_no_install_from_api bool, installed bool) bool {
	return no_install_from_api && !automatically_set_no_install_from_api && !installed
}

pub fn abstract_core_tap_implicitly_trusted(no_install_from_api bool,
	base_implicitly_trusted bool) bool {
	return !no_install_from_api || base_implicitly_trusted
}

pub fn abstract_core_tap_formula_file_to_name(file string) string {
	return os.base(file).trim_string_right('.rb')
}

pub fn abstract_core_tap_should_report_analytics(no_install_from_api bool,
	base_value bool) bool {
	return if no_install_from_api { base_value } else { true }
}

// Ruby method `self.instance` at line 21.
pub fn ruby_abstract_core_tap_l21_d1_self_instance(kind AbstractCoreTapKind) AbstractCoreTap {
	return abstract_core_tap_instance(kind)
}

// Ruby method `ensure_installed!` at line 26.
pub fn ruby_abstract_core_tap_l26_d2_ensure_installed(no_install_from_api bool,
	automatically_set_no_install_from_api bool, installed bool) bool {
	return abstract_core_tap_should_install(no_install_from_api, automatically_set_no_install_from_api, installed)
}

// Ruby method `implicitly_trusted?(remote: self.remote)` at line 36.
pub fn ruby_abstract_core_tap_l36_d3_implicitly_trusted(no_install_from_api bool,
	base_implicitly_trusted bool) bool {
	return abstract_core_tap_implicitly_trusted(no_install_from_api, base_implicitly_trusted)
}

// Ruby method `formula_file_to_name(file)` at line 43.
pub fn ruby_abstract_core_tap_l43_d4_formula_file_to_name(file string) string {
	return abstract_core_tap_formula_file_to_name(file)
}

// Ruby method `should_report_analytics?` at line 48.
pub fn ruby_abstract_core_tap_l48_d5_should_report_analytics(no_install_from_api bool,
	base_value bool) bool {
	return abstract_core_tap_should_report_analytics(no_install_from_api, base_value)
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
