module strategy

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategy/ruby_gems.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.match?(url)` at line 46.
pub fn ruby_ruby_gems_l46_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.match?', ...args)
}

// Ruby method `self.generate_input_values(url)` at line 56.
pub fn ruby_ruby_gems_l56_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate_input_values', ...args)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 83.
pub fn ruby_ruby_gems_l83_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # The {RubyGems} strategy identifies the newest version of a RubyGems
// 10:       # package by checking the latest version API endpoint for the gem.
// 11:       #
// 12:       # RubyGems URLs have a standard format:
// 13:       #   `https://rubygems.org/downloads/example-1.2.3.gem`
// 14:       #
// 15:       # @api public
// 16:       class RubyGems
// 17:         extend Strategic
// 18:
// 19:         # The default `strategy` block used to extract version information when
// 20:         # a `strategy` block isn't provided.
// 21:         DEFAULT_BLOCK = T.let(proc do |json|
// 22:           json["version"]
// 23:         end.freeze, T.proc.params(
// 24:           arg0: T::Hash[String, T.anything],
// 25:         ).returns(T.any(String, T::Array[String])))
// 26:
// 27:         FILENAME_REGEX = /
// 28:           (?<gem_name>.+)- # The gem name followed by a hyphen
// 29:           (?<version>\d+(?:\.[0-9A-Za-z]+)*) # The version string
// 30:           (?:-(?<platform>.+))? # The optional platform
// 31:           \.gem$
// 32:         /ix
// 33:
// 34:         # The `Regexp` used to determine if the strategy applies to the URL.
// 35:         URL_MATCH_REGEX = %r{
// 36:           ^https?://rubygems\.org
// 37:           /(?:downloads|gems/[^/]+/versions)
// 38:           /#{FILENAME_REGEX.source.strip} # The gem filename
// 39:         }ix
// 40:
// 41:         # Whether the strategy can be applied to the provided URL.
// 42:         #
// 43:         # @param url [String] the URL to match against
// 44:         # @return [Boolean]
// 45:         sig { override.params(url: String).returns(T::Boolean) }
// 46:         def self.match?(url)
// 47:           URL_MATCH_REGEX.match?(url)
// 48:         end
// 49:
// 50:         # Extracts the gem name from the provided URL and uses it to generate
// 51:         # the RubyGems latest version API URL for the gem.
// 52:         #
// 53:         # @param url [String] the URL used to generate values
// 54:         # @return [Hash]
// 55:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 56:         def self.generate_input_values(url)
// 57:           values = {}
// 58:           return values unless (match = url.match(URL_MATCH_REGEX))
// 59:
// 60:           values[:url] = "https://rubygems.org/api/v1/versions/" \
// 61:                          "#{URI.encode_www_form_component(T.must(match[:gem_name]))}/latest.json"
// 62:
// 63:           values
// 64:         end
// 65:
// 66:         # Generates a RubyGems latest version API URL for the gem and
// 67:         # identifies new versions using {Json#find_versions} with a block.
// 68:         #
// 69:         # @param url [String] the URL of the content to check
// 70:         # @param regex [Regexp, nil] a regex for matching versions in content
// 71:         # @param content [String, nil] content to check instead of fetching
// 72:         # @param options [Options] options to modify behavior
// 73:         # @return [Hash]
// 74:         sig {
// 75:           override.params(
// 76:             url:     String,
// 77:             regex:   T.nilable(Regexp),
// 78:             content: T.nilable(String),
// 79:             options: Options,
// 80:             block:   T.nilable(Proc),
// 81:           ).returns(T::Hash[Symbol, T.anything])
// 82:         }
// 83:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 84:           match_data = { matches: {}, regex:, url: }
// 85:
// 86:           generated = generate_input_values(url)
// 87:           return match_data if generated.blank?
// 88:
// 89:           Json.find_versions(
// 90:             url:     generated[:url],
// 91:             regex:,
// 92:             content:,
// 93:             options:,
// 94:             &block || DEFAULT_BLOCK
// 95:           )
// 96:         end
// 97:       end
// 98:     end
// 99:   end
// 100: end
