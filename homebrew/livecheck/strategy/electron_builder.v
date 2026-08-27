module strategy

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategy/electron_builder.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.match?(url)` at line 28.
pub fn ruby_electron_builder_l28_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.match?', ...args)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 48.
pub fn ruby_electron_builder_l48_d2_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.find_versions', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategic"
// 5:
// 6: module Homebrew
// 7:   module Livecheck
// 8:     module Strategy
// 9:       # The {ElectronBuilder} strategy fetches content at a URL and parses it
// 10:       # as an electron-builder appcast in YAML format.
// 11:       #
// 12:       # This strategy is not applied automatically and it's necessary to use
// 13:       # `strategy :electron_builder` in a `livecheck` block to apply it.
// 14:       class ElectronBuilder
// 15:         extend Strategic
// 16:
// 17:         # A priority of zero causes livecheck to skip the strategy. We do this
// 18:         # for {ElectronBuilder} so we can selectively apply it when appropriate.
// 19:         PRIORITY = 0
// 20:
// 21:         # The `Regexp` used to determine if the strategy applies to the URL.
// 22:         URL_MATCH_REGEX = %r{^https?://.+/[^/]+\.ya?ml(?:\?[^/?]+)?$}i
// 23:
// 24:         # Whether the strategy can be applied to the provided URL.
// 25:         #
// 26:         # @param url [String] the URL to match against
// 27:         sig { override.params(url: String).returns(T::Boolean) }
// 28:         def self.match?(url)
// 29:           URL_MATCH_REGEX.match?(url)
// 30:         end
// 31:
// 32:         # Checks the YAML content at the URL for new versions.
// 33:         #
// 34:         # @param url [String] the URL of the content to check
// 35:         # @param regex [Regexp, nil] a regex for matching versions in content
// 36:         # @param content [String, nil] content to check instead of fetching
// 37:         # @param options [Options] options to modify behavior
// 38:         # @return [Hash]
// 39:         sig {
// 40:           override.params(
// 41:             url:     String,
// 42:             regex:   T.nilable(Regexp),
// 43:             content: T.nilable(String),
// 44:             options: Options,
// 45:             block:   T.nilable(Proc),
// 46:           ).returns(T::Hash[Symbol, T.anything])
// 47:         }
// 48:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 49:           if regex.present? && !block_given?
// 50:             raise ArgumentError,
// 51:                   "#{Utils.demodulize(name)} only supports a regex when using a `strategy` block"
// 52:           end
// 53:
// 54:           Yaml.find_versions(
// 55:             url:,
// 56:             regex:,
// 57:             content:,
// 58:             options:,
// 59:             &block || proc { |yaml| yaml["version"] }
// 60:           )
// 61:         end
// 62:       end
// 63:     end
// 64:   end
// 65: end
