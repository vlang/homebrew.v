module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/runtime_levels.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.check_tests?` at line 23.
pub fn ruby_runtime_levels_l23_d1_self_check_tests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check_tests?', ...args)
}

// Ruby method `self.enable_checking_in_tests` at line 32.
pub fn ruby_runtime_levels_l32_d2_self_enable_checking_in_tests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.enable_checking_in_tests', ...args)
}

// Ruby method `self.default_checked_level` at line 47.
pub fn ruby_runtime_levels_l47_d3_self_default_checked_level(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.default_checked_level', ...args)
}

// Ruby method `self.default_checked_level=(default_checked_level)` at line 52.
pub fn ruby_runtime_levels_l52_d4_self_default_checked_level(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.default_checked_level=', ...args)
}

// Ruby method `self._toggle_checking_tests(checked)` at line 63.
pub fn ruby_runtime_levels_l63_d5_self_toggle_checking_tests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self._toggle_checking_tests', ...args)
}

// Ruby method `self.set_enable_checking_in_tests_from_environment` at line 67.
pub fn ruby_runtime_levels_l67_d6_self_set_enable_checking_in_tests_from_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.set_enable_checking_in_tests_from_environment',
		...args)
}

// Ruby method `self.set_default_checked_level_from_environment` at line 74.
pub fn ruby_runtime_levels_l74_d7_self_set_default_checked_level_from_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.set_default_checked_level_from_environment', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Used in `sig.checked(level)` to determine when runtime type checking
// 5: # is enabled on a method.
// 6: module T::Private::RuntimeLevels
// 7:   LEVELS = [
// 8:     # Validate every call in every environment
// 9:     :always,
// 10:     # Validate in tests, but not in production
// 11:     :tests,
// 12:     # Don't even validate in tests, b/c too expensive,
// 13:     # or b/c we fully trust the static typing
// 14:     :never,
// 15:   ].freeze
// 16:
// 17:   @check_tests = false
// 18:   @wrapped_tests_with_validation = false
// 19:
// 20:   @has_read_default_checked_level = false
// 21:   @default_checked_level = :always
// 22:
// 23:   def self.check_tests?
// 24:     # Assume that this code path means that some `sig.checked(:tests)`
// 25:     # has been wrapped (or not wrapped) already, which is a trapdoor
// 26:     # for toggling `@check_tests`.
// 27:     @wrapped_tests_with_validation = true
// 28:
// 29:     @check_tests
// 30:   end
// 31:
// 32:   def self.enable_checking_in_tests
// 33:     if !@check_tests && @wrapped_tests_with_validation
// 34:       all_checked_tests_sigs = T::Private::Methods.all_checked_tests_sigs
// 35:       locations = all_checked_tests_sigs.map { |sig| sig.method.source_location&.join(':') }.join("\n- ")
// 36:       msg = "Toggle `:tests`-level runtime type checking earlier. " \
// 37:         "There are already some methods or type aliases wrapped with `.checked(:tests)`"
// 38:       if !locations.empty?
// 39:         msg += ":\n- #{locations}"
// 40:       end
// 41:       raise msg
// 42:     end
// 43:
// 44:     _toggle_checking_tests(true)
// 45:   end
// 46:
// 47:   def self.default_checked_level
// 48:     @has_read_default_checked_level = true
// 49:     @default_checked_level
// 50:   end
// 51:
// 52:   def self.default_checked_level=(default_checked_level)
// 53:     if @has_read_default_checked_level
// 54:       raise "Set the default checked level earlier. There are already some methods whose sig blocks have evaluated which would not be affected by the new default."
// 55:     end
// 56:     if !LEVELS.include?(default_checked_level)
// 57:       raise "Invalid `checked` level '#{default_checked_level}'. Use one of: #{LEVELS}."
// 58:     end
// 59:
// 60:     @default_checked_level = default_checked_level
// 61:   end
// 62:
// 63:   def self._toggle_checking_tests(checked)
// 64:     @check_tests = checked
// 65:   end
// 66:
// 67:   private_class_method def self.set_enable_checking_in_tests_from_environment
// 68:     if ENV['SORBET_RUNTIME_ENABLE_CHECKING_IN_TESTS']
// 69:       enable_checking_in_tests
// 70:     end
// 71:   end
// 72:   set_enable_checking_in_tests_from_environment
// 73:
// 74:   private_class_method def self.set_default_checked_level_from_environment
// 75:     level = ENV['SORBET_RUNTIME_DEFAULT_CHECKED_LEVEL']
// 76:     if level
// 77:       self.default_checked_level = level.to_sym
// 78:     end
// 79:   end
// 80:   set_default_checked_level_from_environment
// 81: end
