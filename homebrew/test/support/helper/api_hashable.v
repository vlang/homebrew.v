module helper

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/api_hashable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `generated_hash!` at line 10.
pub fn ruby_api_hashable_l10_d1_generated_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generated_hash!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "api_hashable"
// 5:
// 6: # `generating_hash!` monkeypatches global state for API generation. The commands
// 7: # that generate the API exit once they are done, so only tests need to revert it.
// 8: module APIHashable
// 9:   sig { void }
// 10:   def generated_hash!
// 11:     return unless generating_hash?
// 12:
// 13:     # `Module#remove_const` is private Ruby core API with no public alternative.
// 14:     Object.send(:remove_const, :HOMEBREW_PREFIX) # rubocop:disable Homebrew/NoSendInTests
// 15:     Object.const_set(:HOMEBREW_PREFIX, @old_homebrew_prefix)
// 16:     ENV["HOME"] = @old_home
// 17:     ENV["GIT_CONFIG_GLOBAL"] = @old_git_config_global
// 18:
// 19:     @generating_hash = false
// 20:   end
// 21: end
