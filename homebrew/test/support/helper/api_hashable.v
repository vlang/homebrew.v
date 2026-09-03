module helper

import brew_runtime
import homebrew
import os

// Translated from Homebrew/brew `test/support/helper/api_hashable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `generated_hash!` at line 10.
pub fn ruby_api_hashable_l10_d1_generated_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	mut state := homebrew.ApiHashableState{
		generating_hash: (args[0].attribute('generating_hash') or { 'false' }).bool()
		old_homebrew_prefix: args[0].attribute('old_homebrew_prefix') or { '' }
		old_home: args[0].attribute('old_home') or { '' }
		old_git_config_global: args[0].attribute('old_git_config_global') or { '' }
		homebrew_prefix: args[0].attribute('homebrew_prefix') or { '' }
		home: args[0].attribute('home') or { '' }
		git_config_global: args[0].attribute('git_config_global') or { '' }
	}
	state.finish_generating_hash()
	os.setenv('HOME', state.home, true)
	if state.git_config_global == '' {
		os.unsetenv('GIT_CONFIG_GLOBAL')
	} else {
		os.setenv('GIT_CONFIG_GLOBAL', state.git_config_global, true)
	}
	return brew_runtime.structured_value('APIHashableState', state.homebrew_prefix, {
		'generating_hash':       state.generating_hash.str()
		'old_homebrew_prefix':   state.old_homebrew_prefix
		'old_home':              state.old_home
		'old_git_config_global': state.old_git_config_global
		'homebrew_prefix':       state.homebrew_prefix
		'home':                  state.home
		'git_config_global':     state.git_config_global
	})
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
