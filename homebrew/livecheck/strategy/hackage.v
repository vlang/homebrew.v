module strategy

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategy/hackage.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.match?(url)` at line 43.
pub fn ruby_hackage_l43_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.match?', ...args)
}

// Ruby method `self.generate_input_values(url)` at line 55.
pub fn ruby_hackage_l55_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate_input_values', ...args)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 89.
pub fn ruby_hackage_l89_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # The {Hackage} strategy identifies versions of software at
// 10:       # hackage.haskell.org by checking directory listing pages.
// 11:       #
// 12:       # Hackage URLs take one of the following formats:
// 13:       #
// 14:       # * `https://hackage.haskell.org/package/example-1.2.3/example-1.2.3.tar.gz`
// 15:       # * `https://downloads.haskell.org/~ghc/8.10.1/ghc-8.10.1-src.tar.xz`
// 16:       #
// 17:       # The default regex checks for the latest version in an `h3` heading element
// 18:       # with a format like `<h3>example-1.2.3/</h3>`.
// 19:       #
// 20:       # @api public
// 21:       class Hackage
// 22:         extend Strategic
// 23:
// 24:         # A `Regexp` used in determining if the strategy applies to the URL and
// 25:         # also as part of extracting the package name from the URL basename.
// 26:         PACKAGE_NAME_REGEX = /(?<package_name>.+?)-\d+/i
// 27:
// 28:         # A `Regexp` used to extract the package name from the URL basename.
// 29:         FILENAME_REGEX = /^#{PACKAGE_NAME_REGEX.source.strip}/i
// 30:
// 31:         # A `Regexp` used in determining if the strategy applies to the URL.
// 32:         URL_MATCH_REGEX = %r{
// 33:           ^https?://(?:downloads|hackage)\.haskell\.org
// 34:           (?:/[^/]+)+ # Path before the filename
// 35:           #{PACKAGE_NAME_REGEX.source.strip}
// 36:         }ix
// 37:
// 38:         # Whether the strategy can be applied to the provided URL.
// 39:         #
// 40:         # @param url [String] the URL to match against
// 41:         # @return [Boolean]
// 42:         sig { override.params(url: String).returns(T::Boolean) }
// 43:         def self.match?(url)
// 44:           URL_MATCH_REGEX.match?(url)
// 45:         end
// 46:
// 47:         # Extracts information from a provided URL and uses it to generate
// 48:         # various input values used by the strategy to check for new versions.
// 49:         # Some of these values act as defaults and can be overridden in a
// 50:         # `livecheck` block.
// 51:         #
// 52:         # @param url [String] the URL used to generate values
// 53:         # @return [Hash]
// 54:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 55:         def self.generate_input_values(url)
// 56:           values = {}
// 57:
// 58:           match = File.basename(url).match(FILENAME_REGEX)
// 59:           return values if match.blank?
// 60:
// 61:           # A page containing a directory listing of the latest source tarball
// 62:           values[:url] = "https://hackage.haskell.org/package/#{match[:package_name]}/src/"
// 63:
// 64:           regex_name = Regexp.escape(T.must(match[:package_name])).gsub("\\-", "-")
// 65:
// 66:           # Example regex: `%r{<h3>example-(.*?)/?</h3>}i`
// 67:           values[:regex] = %r{<h3>#{regex_name}-(.*?)/?</h3>}i
// 68:
// 69:           values
// 70:         end
// 71:
// 72:         # Generates a URL and regex (if one isn't provided) and passes them
// 73:         # to {PageMatch.find_versions} to identify versions in the content.
// 74:         #
// 75:         # @param url [String] the URL of the content to check
// 76:         # @param regex [Regexp, nil] a regex for matching versions in content
// 77:         # @param content [String, nil] content to check instead of fetching
// 78:         # @param options [Options] options to modify behavior
// 79:         # @return [Hash]
// 80:         sig {
// 81:           override.params(
// 82:             url:     String,
// 83:             regex:   T.nilable(Regexp),
// 84:             content: T.nilable(String),
// 85:             options: Options,
// 86:             block:   T.nilable(Proc),
// 87:           ).returns(T::Hash[Symbol, T.anything])
// 88:         }
// 89:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 90:           generated = generate_input_values(url)
// 91:
// 92:           PageMatch.find_versions(
// 93:             url:     generated[:url],
// 94:             regex:   regex || generated[:regex],
// 95:             content:,
// 96:             options:,
// 97:             &block
// 98:           )
// 99:         end
// 100:       end
// 101:     end
// 102:   end
// 103: end
