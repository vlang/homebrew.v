module homebrew

import brew_runtime

// Translated from Homebrew/brew `api_hashable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `generating_hash!` at line 7.
pub fn ruby_api_hashable_l7_d1_generating_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generating_hash!', ...args)
}

// Ruby method `generating_hash?` at line 23.
pub fn ruby_api_hashable_l23_d2_generating_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generating_hash?', ...args)
}

// Ruby method `deep_remove_placeholders(value)` at line 29.
pub fn ruby_api_hashable_l29_d3_deep_remove_placeholders(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deep_remove_placeholders', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Used to substitute common paths with generic placeholders when generating JSON for the API.
// 5: module APIHashable
// 6:   sig { void }
// 7:   def generating_hash!
// 8:     return if generating_hash?
// 9:
// 10:     # Apply monkeypatches for API generation
// 11:     @old_homebrew_prefix = T.let(HOMEBREW_PREFIX, T.nilable(Pathname))
// 12:     @old_home = T.let(Dir.home, T.nilable(String))
// 13:     @old_git_config_global = T.let(ENV.fetch("GIT_CONFIG_GLOBAL", nil), T.nilable(String))
// 14:     Object.send(:remove_const, :HOMEBREW_PREFIX)
// 15:     Object.const_set(:HOMEBREW_PREFIX, Pathname.new(HOMEBREW_PREFIX_PLACEHOLDER))
// 16:     ENV["HOME"] = HOMEBREW_HOME_PLACEHOLDER
// 17:     ENV["GIT_CONFIG_GLOBAL"] = File.join(@old_home, ".gitconfig")
// 18:
// 19:     @generating_hash = T.let(true, T.nilable(T::Boolean))
// 20:   end
// 21:
// 22:   sig { returns(T::Boolean) }
// 23:   def generating_hash?
// 24:     @generating_hash ||= false
// 25:     @generating_hash == true
// 26:   end
// 27:
// 28:   sig { type_parameters(:U).params(value: T.type_parameter(:U)).returns(T.type_parameter(:U)) }
// 29:   def deep_remove_placeholders(value)
// 30:     return value if generating_hash?
// 31:
// 32:     value = case value
// 33:     when Hash
// 34:       value.transform_values { |v| deep_remove_placeholders(v) }
// 35:     when Array
// 36:       value.map { |v| deep_remove_placeholders(v) }
// 37:     when String
// 38:       value.gsub(HOMEBREW_PREFIX_PLACEHOLDER, HOMEBREW_PREFIX)
// 39:            .gsub(HOMEBREW_CELLAR_PLACEHOLDER, HOMEBREW_CELLAR)
// 40:            .gsub(HOMEBREW_HOME_PLACEHOLDER, Dir.home)
// 41:     else
// 42:       value
// 43:     end
// 44:
// 45:     T.cast(value, T.type_parameter(:U))
// 46:   end
// 47: end
