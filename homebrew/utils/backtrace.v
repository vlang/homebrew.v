module utils

import brew_runtime

// Translated from Homebrew/brew `utils/backtrace.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.clean(error)` at line 17.
pub fn ruby_backtrace_l17_d1_self_clean(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.clean', ...args)
}

// Ruby method `self.sorbet_runtime_path` at line 30.
pub fn ruby_backtrace_l30_d2_self_sorbet_runtime_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sorbet_runtime_path', ...args)
}

// Ruby method `self.print_backtrace_message` at line 35.
pub fn ruby_backtrace_l35_d3_self_print_backtrace_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.print_backtrace_message', ...args)
}

// Ruby method `self.tap_error_url(error)` at line 46.
pub fn ruby_backtrace_l46_d4_self_tap_error_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.tap_error_url', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module Utils
// 7:   module Backtrace
// 8:     extend Utils::Output::Mixin
// 9:
// 10:     @print_backtrace_message = T.let(false, T::Boolean)
// 11:
// 12:     # Cleans `sorbet-runtime` gem paths from the backtrace unless...
// 13:     # 1. `verbose` is set
// 14:     # 2. first backtrace line starts with `sorbet-runtime`
// 15:     #   - This implies that the error is related to Sorbet.
// 16:     sig { params(error: Exception).returns(T.nilable(T::Array[String])) }
// 17:     def self.clean(error)
// 18:       backtrace = error.backtrace
// 19:
// 20:       return backtrace if Context.current.verbose?
// 21:       return backtrace if backtrace.blank?
// 22:       return backtrace if backtrace.fetch(0).start_with?(sorbet_runtime_path)
// 23:
// 24:       old_backtrace_length = backtrace.length
// 25:       backtrace.reject { |line| line.start_with?(sorbet_runtime_path) }
// 26:                .tap { |new_backtrace| print_backtrace_message if old_backtrace_length > new_backtrace.length }
// 27:     end
// 28:
// 29:     sig { returns(String) }
// 30:     def self.sorbet_runtime_path
// 31:       @sorbet_runtime_path ||= T.let("#{Gem.paths.home}/gems/sorbet-runtime", T.nilable(String))
// 32:     end
// 33:
// 34:     sig { void }
// 35:     def self.print_backtrace_message
// 36:       return if @print_backtrace_message
// 37:
// 38:       # This is just unactionable noise in GitHub Actions.
// 39:       opoo_outside_github_actions "Removed Sorbet lines from backtrace!"
// 40:       puts "Rerun with `--verbose` to see the original backtrace" unless Homebrew::EnvConfig.no_env_hints?
// 41:
// 42:       @print_backtrace_message = true
// 43:     end
// 44:
// 45:     sig { params(error: Exception).returns(T.nilable(String)) }
// 46:     def self.tap_error_url(error)
// 47:       backtrace = error.backtrace
// 48:       return if backtrace.blank?
// 49:
// 50:       backtrace.each do |line|
// 51:         if (tap = line.match(%r{/Library/Taps/([^/]+/[^/]+)/}))
// 52:           return "https://github.com/#{tap[1]}/issues/new"
// 53:         end
// 54:       end
// 55:
// 56:       nil
// 57:     end
// 58:   end
// 59: end
