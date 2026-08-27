module strategy

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategy/gnu.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.match?(url)` at line 48.
pub fn ruby_gnu_l48_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.match?', ...args)
}

// Ruby method `self.generate_input_values(url)` at line 60.
pub fn ruby_gnu_l60_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate_input_values', ...args)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 101.
pub fn ruby_gnu_l101_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # The {Gnu} strategy identifies versions of software at gnu.org by
// 10:       # checking directory listing pages.
// 11:       #
// 12:       # GNU URLs use a variety of formats:
// 13:       #
// 14:       # * Archive file URLs:
// 15:       #   * `https://ftp.gnu.org/gnu/example/example-1.2.3.tar.gz`
// 16:       #   * `https://ftp.gnu.org/gnu/example/1.2.3/example-1.2.3.tar.gz`
// 17:       # * Homepage URLs:
// 18:       #   * `https://www.gnu.org/software/example/`
// 19:       #   * `https://example.gnu.org`
// 20:       #
// 21:       # There are other URL formats that this strategy currently doesn't
// 22:       # support:
// 23:       #
// 24:       # * `https://ftp.gnu.org/non-gnu/example/source/feature/1.2.3/example-1.2.3.tar.gz`
// 25:       # * `https://savannah.nongnu.org/download/example/example-1.2.3.tar.gz`
// 26:       # * `https://download.savannah.gnu.org/releases/example/example-1.2.3.tar.gz`
// 27:       # * `https://download.savannah.nongnu.org/releases/example/example-1.2.3.tar.gz`
// 28:       #
// 29:       # The default regex identifies versions in archive files found in `href`
// 30:       # attributes.
// 31:       #
// 32:       # @api public
// 33:       class Gnu
// 34:         extend Strategic
// 35:
// 36:         # The `Regexp` used to determine if the strategy applies to the URL.
// 37:         URL_MATCH_REGEX = %r{
// 38:           ^https?://
// 39:           (?:(?:[^/]+?\.)*gnu\.org/(?:gnu|software)/(?<project_name>[^/]+)/
// 40:           |(?<project_name>[^/]+)\.gnu\.org/?$)
// 41:         }ix
// 42:
// 43:         # Whether the strategy can be applied to the provided URL.
// 44:         #
// 45:         # @param url [String] the URL to match against
// 46:         # @return [Boolean]
// 47:         sig { override.params(url: String).returns(T::Boolean) }
// 48:         def self.match?(url)
// 49:           URL_MATCH_REGEX.match?(url) && url.exclude?("savannah.")
// 50:         end
// 51:
// 52:         # Extracts information from a provided URL and uses it to generate
// 53:         # various input values used by the strategy to check for new versions.
// 54:         # Some of these values act as defaults and can be overridden in a
// 55:         # `livecheck` block.
// 56:         #
// 57:         # @param url [String] the URL used to generate values
// 58:         # @return [Hash]
// 59:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 60:         def self.generate_input_values(url)
// 61:           values = {}
// 62:
// 63:           match = url.match(URL_MATCH_REGEX)
// 64:           return values if match.blank?
// 65:
// 66:           # The directory listing page for the project's files
// 67:           values[:url] = "https://ftpmirror.gnu.org/gnu/#{match[:project_name]}/"
// 68:
// 69:           regex_name = Regexp.escape(T.must(match[:project_name])).gsub("\\-", "-")
// 70:
// 71:           # The default regex consists of the following parts:
// 72:           # * `href=.*?`: restricts matching to URLs in `href` attributes
// 73:           # * The project name
// 74:           # * `[._-]`: the generic delimiter between project name and version
// 75:           # * `v?(\d+(?:\.\d+)*)`: the numeric version
// 76:           # * `(?:\.[a-z]+|/)`: the file extension (a trailing delimiter)
// 77:           #
// 78:           # Example regex: `%r{href=.*?example[._-]v?(\d+(?:\.\d+)*)(?:\.[a-z]+|/)}i`
// 79:           values[:regex] = %r{href=.*?#{regex_name}[._-]v?(\d+(?:\.\d+)*)(?:\.[a-z]+|/)}i
// 80:
// 81:           values
// 82:         end
// 83:
// 84:         # Generates a URL and regex (if one isn't provided) and passes them
// 85:         # to {PageMatch.find_versions} to identify versions in the content.
// 86:         #
// 87:         # @param url [String] the URL of the content to check
// 88:         # @param regex [Regexp, nil] a regex for matching versions in content
// 89:         # @param content [String, nil] content to check instead of fetching
// 90:         # @param options [Options] options to modify behavior
// 91:         # @return [Hash]
// 92:         sig {
// 93:           override.params(
// 94:             url:     String,
// 95:             regex:   T.nilable(Regexp),
// 96:             content: T.nilable(String),
// 97:             options: Options,
// 98:             block:   T.nilable(Proc),
// 99:           ).returns(T::Hash[Symbol, T.anything])
// 100:         }
// 101:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 102:           generated = generate_input_values(url)
// 103:
// 104:           PageMatch.find_versions(
// 105:             url:     generated[:url],
// 106:             regex:   regex || generated[:regex],
// 107:             content:,
// 108:             options:,
// 109:             &block
// 110:           )
// 111:         end
// 112:       end
// 113:     end
// 114:   end
// 115: end
