module strategy

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategy/json.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.match?(url)` at line 45.
pub fn ruby_json_l45_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.match?', ...args)
}

// Ruby method `self.parse_json(content)` at line 52.
pub fn ruby_json_l52_d2_self_parse_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.parse_json', ...args)
}

// Ruby method `self.versions_from_content(content, regex = nil, &block)` at line 77.
pub fn ruby_json_l77_d3_self_versions_from_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.versions_from_content', ...args)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 108.
pub fn ruby_json_l108_d4_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # The {Json} strategy fetches content at a URL, parses it as JSON and
// 10:       # provides the parsed data to a `strategy` block. If a regex is present
// 11:       # in the `livecheck` block, it should be passed as the second argument to
// 12:       # the `strategy` block.
// 13:       #
// 14:       # This is a generic strategy that doesn't contain any logic for finding
// 15:       # versions, as the structure of JSON data varies. Instead, a `strategy`
// 16:       # block must be used to extract version information from the JSON data.
// 17:       #
// 18:       # This strategy is not applied automatically and it is necessary to use
// 19:       # `strategy :json` in a `livecheck` block (in conjunction with a
// 20:       # `strategy` block) to use it.
// 21:       #
// 22:       # This strategy's {find_versions} method can be used in other strategies
// 23:       # that work with JSON content, so it should only be necessary to write
// 24:       # the version-finding logic that works with the parsed JSON data.
// 25:       #
// 26:       # @api public
// 27:       class Json
// 28:         extend Strategic
// 29:
// 30:         # A priority of zero causes livecheck to skip the strategy. We do this
// 31:         # for {Json} so we can selectively apply it only when a strategy block
// 32:         # is provided in a `livecheck` block.
// 33:         PRIORITY = 0
// 34:
// 35:         # The `Regexp` used to determine if the strategy applies to the URL.
// 36:         URL_MATCH_REGEX = %r{^https?://}i
// 37:
// 38:         # Whether the strategy can be applied to the provided URL.
// 39:         # {Json} will technically match any HTTP URL but is only usable with
// 40:         # a `livecheck` block containing a `strategy` block.
// 41:         #
// 42:         # @param url [String] the URL to match against
// 43:         # @return [Boolean]
// 44:         sig { override.params(url: String).returns(T::Boolean) }
// 45:         def self.match?(url)
// 46:           URL_MATCH_REGEX.match?(url)
// 47:         end
// 48:
// 49:         # Parses JSON text and returns the parsed data.
// 50:         # @param content [String] the JSON text to parse
// 51:         sig { params(content: String).returns(T.untyped) }
// 52:         def self.parse_json(content)
// 53:           require "json"
// 54:
// 55:           begin
// 56:             JSON.parse(content, allow_duplicate_key: true)
// 57:           rescue JSON::ParserError
// 58:             raise "Content could not be parsed as JSON."
// 59:           end
// 60:         end
// 61:
// 62:         # Parses JSON text and identifies versions using a `strategy` block.
// 63:         # If the block has two parameters, the parsed JSON data will be used as
// 64:         # the first argument and the regex (if any) will be the second.
// 65:         # Otherwise, only the parsed JSON data will be passed to the block.
// 66:         #
// 67:         # @param content [String] the JSON text to parse and check
// 68:         # @param regex [Regexp, nil] a regex for use in a strategy block
// 69:         # @return [Array]
// 70:         sig {
// 71:           params(
// 72:             content: String,
// 73:             regex:   T.nilable(Regexp),
// 74:             block:   T.nilable(Proc),
// 75:           ).returns(T::Array[String])
// 76:         }
// 77:         def self.versions_from_content(content, regex = nil, &block)
// 78:           return [] if content.blank? || !block_given?
// 79:
// 80:           json = parse_json(content)
// 81:           return [] if json.blank?
// 82:
// 83:           block_return_value = if block.arity == 2
// 84:             yield(json, regex)
// 85:           else
// 86:             yield(json)
// 87:           end
// 88:           Strategy.handle_block_return(block_return_value)
// 89:         end
// 90:
// 91:         # Checks the JSON content at the URL for versions, using the provided
// 92:         # `strategy` block to extract version information.
// 93:         #
// 94:         # @param url [String] the URL of the content to check
// 95:         # @param regex [Regexp, nil] a regex for matching versions in content
// 96:         # @param content [String, nil] content to check instead of fetching
// 97:         # @param options [Options] options to modify behavior
// 98:         # @return [Hash]
// 99:         sig {
// 100:           override.params(
// 101:             url:     String,
// 102:             regex:   T.nilable(Regexp),
// 103:             content: T.nilable(String),
// 104:             options: Options,
// 105:             block:   T.nilable(Proc),
// 106:           ).returns(T::Hash[Symbol, T.anything])
// 107:         }
// 108:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 109:           raise ArgumentError, "#{Utils.demodulize(name)} requires a `strategy` block" unless block_given?
// 110:
// 111:           match_data = { matches: {}, regex:, url: }
// 112:           match_data[:cached] = true if content
// 113:           return match_data if url.blank?
// 114:
// 115:           unless match_data[:cached]
// 116:             match_data.merge!(Strategy.page_content(url, options:))
// 117:             content = match_data[:content]
// 118:           end
// 119:           return match_data if content.blank?
// 120:
// 121:           versions_from_content(content, regex, &block).each do |match_text|
// 122:             match_data[:matches][match_text] = Version.new(match_text)
// 123:           end
// 124:
// 125:           match_data
// 126:         end
// 127:       end
// 128:     end
// 129:   end
// 130: end
