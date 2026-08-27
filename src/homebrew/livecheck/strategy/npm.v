module strategy

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategy/npm.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.match?(url)` at line 40.
pub fn ruby_npm_l40_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.match?', ...args)
}

// Ruby method `self.generate_input_values(url)` at line 50.
pub fn ruby_npm_l50_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate_input_values', ...args)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 76.
pub fn ruby_npm_l76_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # The {Npm} strategy identifies versions of software at
// 10:       # registry.npmjs.org by checking the latest version for a package.
// 11:       #
// 12:       # npm URLs take one of the following formats:
// 13:       #
// 14:       # * `https://registry.npmjs.org/example/-/example-1.2.3.tgz`
// 15:       # * `https://registry.npmjs.org/@example/example/-/example-1.2.3.tgz`
// 16:       #
// 17:       # @api public
// 18:       class Npm
// 19:         extend Strategic
// 20:
// 21:         # The default `strategy` block used to extract version information when
// 22:         # a `strategy` block isn't provided.
// 23:         DEFAULT_BLOCK = T.let(proc do |json|
// 24:           json["version"]
// 25:         end.freeze, T.proc.params(
// 26:           arg0: T::Hash[String, T.anything],
// 27:         ).returns(T.any(String, T::Array[String])))
// 28:
// 29:         # The `Regexp` used to determine if the strategy applies to the URL.
// 30:         URL_MATCH_REGEX = %r{
// 31:           ^https?://registry\.npmjs\.org
// 32:           /(?<package_name>.+?)/-/ # The npm package name
// 33:         }ix
// 34:
// 35:         # Whether the strategy can be applied to the provided URL.
// 36:         #
// 37:         # @param url [String] the URL to match against
// 38:         # @return [Boolean]
// 39:         sig { override.params(url: String).returns(T::Boolean) }
// 40:         def self.match?(url)
// 41:           URL_MATCH_REGEX.match?(url)
// 42:         end
// 43:
// 44:         # Extracts information from a provided URL and uses it to generate
// 45:         # various input values used by the strategy to check for new versions.
// 46:         #
// 47:         # @param url [String] the URL used to generate values
// 48:         # @return [Hash]
// 49:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 50:         def self.generate_input_values(url)
// 51:           values = {}
// 52:           return values unless (match = url.match(URL_MATCH_REGEX))
// 53:
// 54:           values[:url] = "https://registry.npmjs.org/#{URI.encode_www_form_component(match[:package_name])}/latest"
// 55:
// 56:           values
// 57:         end
// 58:
// 59:         # Generates a URL and checks the content at the URL for new versions
// 60:         # using {Json.versions_from_content}.
// 61:         #
// 62:         # @param url [String] the URL of the content to check
// 63:         # @param regex [Regexp, nil] a regex for matching versions in content
// 64:         # @param content [String, nil] content to check instead of fetching
// 65:         # @param options [Options] options to modify behavior
// 66:         # @return [Hash]
// 67:         sig {
// 68:           override.params(
// 69:             url:     String,
// 70:             regex:   T.nilable(Regexp),
// 71:             content: T.nilable(String),
// 72:             options: Options,
// 73:             block:   T.nilable(Proc),
// 74:           ).returns(T::Hash[Symbol, T.anything])
// 75:         }
// 76:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 77:           match_data = { matches: {}, regex:, url: }
// 78:           match_data[:cached] = true if content
// 79:
// 80:           generated = generate_input_values(url)
// 81:           return match_data if generated.blank?
// 82:
// 83:           match_data[:url] = generated[:url]
// 84:
// 85:           unless match_data[:cached]
// 86:             match_data.merge!(Strategy.page_content(match_data[:url], options:))
// 87:             content = match_data[:content]
// 88:           end
// 89:           return match_data if content.blank?
// 90:
// 91:           Json.versions_from_content(content, regex, &block || DEFAULT_BLOCK).each do |match_text|
// 92:             match_data[:matches][match_text] = Version.new(match_text)
// 93:           end
// 94:
// 95:           match_data
// 96:         end
// 97:       end
// 98:     end
// 99:   end
// 100: end
