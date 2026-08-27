module strategy

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategy/gnome.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.match?(url)` at line 44.
pub fn ruby_gnome_l44_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.match?', ...args)
}

// Ruby method `self.generate_input_values(url)` at line 56.
pub fn ruby_gnome_l56_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate_input_values', ...args)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 91.
pub fn ruby_gnome_l91_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # The {Gnome} strategy identifies versions of software at gnome.org by
// 10:       # checking the available downloads found in a project's `cache.json`
// 11:       # file.
// 12:       #
// 13:       # GNOME URLs generally follow a standard format:
// 14:       #
// 15:       # * `https://download.gnome.org/sources/example/1.2/example-1.2.3.tar.xz`
// 16:       #
// 17:       # Before version 40, GNOME used a version scheme where unstable releases
// 18:       # were indicated with a minor that's 90+ or odd. The newer version scheme
// 19:       # uses trailing alpha/beta/rc text to identify unstable versions
// 20:       # (e.g. `40.alpha`).
// 21:       #
// 22:       # When a regex isn't provided in a `livecheck` block, the strategy uses
// 23:       # a default regex that matches versions which don't include trailing text
// 24:       # after the numeric version (e.g. `40.0` instead of `40.alpha`) and it
// 25:       # selectively filters out unstable versions below 40 using the rules for
// 26:       # the older version scheme.
// 27:       #
// 28:       # @api public
// 29:       class Gnome
// 30:         extend Strategic
// 31:
// 32:         # The `Regexp` used to determine if the strategy applies to the URL.
// 33:         URL_MATCH_REGEX = %r{
// 34:           ^https?://download\.gnome\.org
// 35:           /sources
// 36:           /(?<package_name>[^/]+)/ # The GNOME package name
// 37:         }ix
// 38:
// 39:         # Whether the strategy can be applied to the provided URL.
// 40:         #
// 41:         # @param url [String] the URL to match against
// 42:         # @return [Boolean]
// 43:         sig { override.params(url: String).returns(T::Boolean) }
// 44:         def self.match?(url)
// 45:           URL_MATCH_REGEX.match?(url)
// 46:         end
// 47:
// 48:         # Extracts information from a provided URL and uses it to generate
// 49:         # various input values used by the strategy to check for new versions.
// 50:         # Some of these values act as defaults and can be overridden in a
// 51:         # `livecheck` block.
// 52:         #
// 53:         # @param url [String] the URL used to generate values
// 54:         # @return [Hash]
// 55:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 56:         def self.generate_input_values(url)
// 57:           values = {}
// 58:
// 59:           match = url.match(URL_MATCH_REGEX)
// 60:           return values if match.blank?
// 61:
// 62:           values[:url] = "https://download.gnome.org/sources/#{match[:package_name]}/cache.json"
// 63:
// 64:           regex_name = Regexp.escape(T.must(match[:package_name])).gsub("\\-", "-")
// 65:
// 66:           # GNOME archive files seem to use a standard filename format, so we
// 67:           # count on the delimiter between the package name and numeric
// 68:           # version being a hyphen and the file being a tarball.
// 69:           values[:regex] = /#{regex_name}-(\d+(?:\.\d+)*)\.t/i
// 70:
// 71:           values
// 72:         end
// 73:
// 74:         # Generates a URL and regex (if one isn't provided) and passes them
// 75:         # to {PageMatch.find_versions} to identify versions in the content.
// 76:         #
// 77:         # @param url [String] the URL of the content to check
// 78:         # @param regex [Regexp, nil] a regex for matching versions in content
// 79:         # @param content [String, nil] content to check instead of fetching
// 80:         # @param options [Options] options to modify behavior
// 81:         # @return [Hash]
// 82:         sig {
// 83:           override.params(
// 84:             url:     String,
// 85:             regex:   T.nilable(Regexp),
// 86:             content: T.nilable(String),
// 87:             options: Options,
// 88:             block:   T.nilable(Proc),
// 89:           ).returns(T::Hash[Symbol, T.anything])
// 90:         }
// 91:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 92:           generated = generate_input_values(url)
// 93:
// 94:           match_data = PageMatch.find_versions(
// 95:             url:     generated[:url],
// 96:             regex:   regex || generated[:regex],
// 97:             content:,
// 98:             options:,
// 99:             &block
// 100:           )
// 101:
// 102:           if regex.blank?
// 103:             # Filter out unstable versions using the old version scheme where
// 104:             # the major version is below 40.
// 105:             match_data[:matches].reject! do |_, version|
// 106:               next if version.major >= 40
// 107:               next if version.minor.blank?
// 108:
// 109:               (version.minor.to_i.odd? || version.minor >= 90) ||
// 110:                 (version.patch.present? && version.patch >= 90)
// 111:             end
// 112:           end
// 113:
// 114:           match_data
// 115:         end
// 116:       end
// 117:     end
// 118:   end
// 119: end
