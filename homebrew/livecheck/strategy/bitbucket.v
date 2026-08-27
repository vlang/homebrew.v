module strategy

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategy/bitbucket.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.match?(url)` at line 49.
pub fn ruby_bitbucket_l49_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.match?', ...args)
}

// Ruby method `self.generate_input_values(url)` at line 60.
pub fn ruby_bitbucket_l60_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate_input_values', ...args)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 110.
pub fn ruby_bitbucket_l110_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # The {Bitbucket} strategy identifies versions of software at
// 10:       # bitbucket.org by checking a repository's available downloads.
// 11:       #
// 12:       # Bitbucket URLs generally take one of the following formats:
// 13:       #
// 14:       # * `https://bitbucket.org/example/example/get/1.2.3.tar.gz`
// 15:       # * `https://bitbucket.org/example/example/downloads/example-1.2.3.tar.gz`
// 16:       #
// 17:       # The `/get/` archive files are simply automated snapshots of the files
// 18:       # for a given tag. The `/downloads/` archive files are files that have
// 19:       # been uploaded instead.
// 20:       #
// 21:       # It's also possible for an archive to come from a repository's wiki,
// 22:       # like:
// 23:       # `https://bitbucket.org/example/example/wiki/downloads/example-1.2.3.zip`.
// 24:       # This scenario is handled by this strategy as well and the `path` in
// 25:       # this example would be `example/example/wiki` (instead of
// 26:       # `example/example` with the previous URLs).
// 27:       #
// 28:       # The default regex identifies versions in archive files found in `href`
// 29:       # attributes.
// 30:       #
// 31:       # @api public
// 32:       class Bitbucket
// 33:         extend Strategic
// 34:
// 35:         # The `Regexp` used to determine if the strategy applies to the URL.
// 36:         URL_MATCH_REGEX = %r{
// 37:           ^https?://bitbucket\.org
// 38:           /(?<path>.+?) # The path leading up to the get or downloads part
// 39:           /(?<dl_type>get|downloads) # An indicator of the file download type
// 40:           /(?<prefix>(?:[^/]+?[_-])?) # Filename text before the version
// 41:           v?\d+(?:\.\d+)+ # The numeric version
// 42:           (?<suffix>[^/]+) # Filename text after the version
// 43:         }ix
// 44:
// 45:         # Whether the strategy can be applied to the provided URL.
// 46:         #
// 47:         # @param url [String] the URL to match against
// 48:         sig { override.params(url: String).returns(T::Boolean) }
// 49:         def self.match?(url)
// 50:           URL_MATCH_REGEX.match?(url)
// 51:         end
// 52:
// 53:         # Extracts information from a provided URL and uses it to generate
// 54:         # various input values used by the strategy to check for new versions.
// 55:         # Some of these values act as defaults and can be overridden in a
// 56:         # `livecheck` block.
// 57:         #
// 58:         # @param url [String] the URL used to generate values
// 59:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 60:         def self.generate_input_values(url)
// 61:           values = {}
// 62:
// 63:           match = url.match(URL_MATCH_REGEX)
// 64:           return values if match.blank?
// 65:
// 66:           regex_prefix = Regexp.escape(T.must(match[:prefix])).gsub("\\-", "-")
// 67:
// 68:           # `/get/` archives are Git tag snapshots, so we need to check that tab
// 69:           # instead of the main `/downloads/` page
// 70:           if match[:dl_type] == "get"
// 71:             values[:url] = "https://bitbucket.org/#{match[:path]}/downloads/?tab=tags&iframe=true&spa=0"
// 72:
// 73:             # Example tag regexes:
// 74:             # * `/<td[^>]*?class="name"[^>]*?>\s*v?(\d+(?:\.\d+)+)\s*?</im`
// 75:             # * `/<td[^>]*?class="name"[^>]*?>\s*abc-v?(\d+(?:\.\d+)+)\s*?</im`
// 76:             values[:regex] = /<td[^>]*?class="name"[^>]*?>\s*#{regex_prefix}v?(\d+(?:\.\d+)+)\s*?</im
// 77:           else
// 78:             values[:url] = "https://bitbucket.org/#{match[:path]}/downloads/?iframe=true&spa=0"
// 79:
// 80:             # Use `\.t` instead of specific tarball extensions (e.g. .tar.gz)
// 81:             suffix = T.must(match[:suffix]).sub(Strategy::TARBALL_EXTENSION_REGEX, ".t")
// 82:             regex_suffix = Regexp.escape(suffix).gsub("\\-", "-")
// 83:
// 84:             # Example file regexes:
// 85:             # * `/href=.*?v?(\d+(?:\.\d+)+)\.t/i`
// 86:             # * `/href=.*?abc-v?(\d+(?:\.\d+)+)\.t/i`
// 87:             values[:regex] = /href=.*?#{regex_prefix}v?(\d+(?:\.\d+)+)#{regex_suffix}/i
// 88:           end
// 89:
// 90:           values
// 91:         end
// 92:
// 93:         # Generates a URL and regex (if one isn't provided) and passes them
// 94:         # to {PageMatch.find_versions} to identify versions in the content.
// 95:         #
// 96:         # @param url [String] the URL of the content to check
// 97:         # @param regex [Regexp, nil] a regex for matching versions in content
// 98:         # @param content [String, nil] content to check instead of fetching
// 99:         # @param options [Options] options to modify behavior
// 100:         # @return [Hash]
// 101:         sig {
// 102:           override.params(
// 103:             url:     String,
// 104:             regex:   T.nilable(Regexp),
// 105:             content: T.nilable(String),
// 106:             options: Options,
// 107:             block:   T.nilable(Proc),
// 108:           ).returns(T::Hash[Symbol, T.anything])
// 109:         }
// 110:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 111:           generated = generate_input_values(url)
// 112:
// 113:           PageMatch.find_versions(
// 114:             url:     generated[:url],
// 115:             regex:   regex || generated[:regex],
// 116:             content:,
// 117:             options:,
// 118:             &block
// 119:           )
// 120:         end
// 121:       end
// 122:     end
// 123:   end
// 124: end
