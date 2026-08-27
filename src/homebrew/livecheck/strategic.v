module livecheck

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategic.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `match?(url); end` at line 18.
pub fn ruby_strategic_l18_d1_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('match?', ...args)
}

// Ruby method `find_versions(url:, regex: nil, content: nil, options: Options.new, &block); end` at line 37.
pub fn ruby_strategic_l37_d2_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_versions', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strong
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Livecheck
// 6:     # The interface for livecheck strategies. Because third-party strategies
// 7:     # are not required to extend this module, we do not provide any default
// 8:     # method implementations here.
// 9:     module Strategic
// 10:       extend T::Helpers
// 11:
// 12:       interface!
// 13:
// 14:       # Whether the strategy can be applied to the provided URL.
// 15:       #
// 16:       # @param url [String] the URL to match against
// 17:       sig { abstract.params(url: String).returns(T::Boolean) }
// 18:       def match?(url); end
// 19:
// 20:       # Checks the content at the URL for new versions. Implementations may not
// 21:       # support all options.
// 22:       #
// 23:       # @param url the URL of the content to check
// 24:       # @param regex a regex for matching versions in content
// 25:       # @param content content to check instead of fetching
// 26:       # @param options options to modify behavior
// 27:       # @param block a block to match the content
// 28:       sig {
// 29:         abstract.params(
// 30:           url:     String,
// 31:           regex:   T.nilable(Regexp),
// 32:           content: T.nilable(String),
// 33:           options: Options,
// 34:           block:   T.nilable(Proc),
// 35:         ).returns(T::Hash[Symbol, T.anything])
// 36:       }
// 37:       def find_versions(url:, regex: nil, content: nil, options: Options.new, &block); end
// 38:     end
// 39:   end
// 40: end
