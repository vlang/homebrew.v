module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/xorg.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct XorgInputValues {
pub:
	present bool
	url     string
	regex   PageMatchRegex
}

pub struct XorgFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

pub struct XorgPageCache {
pub mut:
	page_data map[string]string
}

fn xorg_module_name(url string) ?string {
	file_name := url.all_after_last('/')
	mut separator := -1
	for index := 0; index + 1 < file_name.len; index++ {
		if file_name[index] == `-` && file_name[index + 1].is_digit() {
			separator = index
		}
	}
	if separator <= 0 {
		return none
	}
	return file_name[..separator]
}

fn xorg_regex_escape(value string) string {
	mut escaped := value
	for character in ['\\', '.', '+', '*', '?', '^', '\$', '(', ')', '[', ']', '{', '}', '|'] {
		escaped = escaped.replace(character, '\\${character}')
	}
	return escaped.replace('\\-', '-')
}

pub fn xorg_matches_url(url string) bool {
	lower := url.to_lower()
	protocol_length := if lower.starts_with('https://') {
		'https://'.len
	} else if lower.starts_with('http://') {
		'http://'.len
	} else {
		return false
	}
	host_end_relative := lower[protocol_length..].index('/') or { return false }
	host_end := protocol_length + host_end_relative
	host := lower[protocol_length..host_end]
	path := lower[host_end + 1..]
	valid_location := if host == 'x.org' || host.ends_with('.x.org') {
		path.starts_with('individual/') || path.contains('/individual/')
	} else if host == 'freedesktop.org' || host.ends_with('.freedesktop.org') {
		path.starts_with('archive/') || path.starts_with('dist/') || path.starts_with('software/')
	} else {
		host == 'archive.mesa3d.org'
	}
	return valid_location && xorg_module_name(url) != none
}

pub fn xorg_generate_input_values(url string) XorgInputValues {
	module_name := xorg_module_name(url) or { return XorgInputValues{} }
	file_name := url.all_after_last('/')
	directory_url := url.replace_once('x.org/pub/', 'x.org/archive/').trim_string_right(file_name)
	regex_name := xorg_regex_escape(module_name)
	return XorgInputValues{
		present: true
		url: directory_url
		regex: PageMatchRegex{
			pattern: 'href=.*?${regex_name}[._-]v?(\\d+(?:\\.\\d+)+)\\.t'
			case_insensitive: true
		}
	}
}

pub fn xorg_set_page_data(mut cache XorgPageCache, page_data map[string]string) {
	cache.page_data = page_data.clone()
}

pub fn xorg_find_versions(mut cache XorgPageCache, request XorgFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := xorg_generate_input_values(request.url)
	generated_regex := if generated.present { ?PageMatchRegex(generated.regex) } else { none }
	effective_regex := if provided := request.regex {
		?PageMatchRegex(provided)
	} else {
		generated_regex
	}
	mut effective_content := request.content
	if request.content == none && generated.url in cache.page_data {
		effective_content = cache.page_data[generated.url]
	}
	match_data := page_match_find_versions(PageMatchFindVersionsRequest{
		url: generated.url
		regex: effective_regex
		content: effective_content
		options: request.options
		has_block: request.has_block
		block: request.block
	}, fetcher)!
	if match_data.has_content && match_data.content.trim_space() != '' {
		cache.page_data[generated.url] = match_data.content
	}
	return match_data
}

fn xorg_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn xorg_match_data_value(result PageMatchData) brew_runtime.Value {
	mut matches := map[string]brew_runtime.Value{}
	for version in result.matches.keys() {
		matches[version] = brew_runtime.object_value('Version', version)
	}
	regex_value := result.regex or { PageMatchRegex{} }
	mut values := {
		'matches': brew_runtime.map_value(matches)
		'regex':   if regex_value.pattern == '' {
			brew_runtime.object_value('NilClass', 'nil')
		} else {
			brew_runtime.object_value('Regexp', regex_value.pattern)
		}
		'url':     brew_runtime.string_value(result.url)
	}
	if result.has_cached {
		values['cached'] = brew_runtime.bool_value(result.cached)
	}
	if result.has_content {
		values['content'] = brew_runtime.string_value(result.content)
	}
	return brew_runtime.map_value(values)
}

// Ruby attr_writer `attr_writer :page_data` at line 68.
pub fn ruby_xorg_l68_d1_page_data(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len == 0 { brew_runtime.map_value({}) } else { args[0] }
}

// Ruby method `self.match?(url)` at line 76.
pub fn ruby_xorg_l76_d2_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(xorg_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 88.
pub fn ruby_xorg_l88_d3_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	generated := xorg_generate_input_values(args[0].as_string())
	if !generated.present {
		return brew_runtime.map_value({})
	}
	return brew_runtime.map_value({
		'url':   brew_runtime.string_value(generated.url)
		'regex': brew_runtime.object_value('Regexp', generated.regex.pattern)
	})
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 131.
pub fn ruby_xorg_l131_d4_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	mut cache := XorgPageCache{
		page_data: map[string]string{}
	}
	result := xorg_find_versions(mut cache, XorgFindRequest{
		url: args[0].as_string()
		content: content
	}, xorg_empty_fetcher) or { return brew_runtime.object_value('Error', err.msg()) }
	return xorg_match_data_value(result)
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
// 9:       # The {Xorg} strategy identifies versions of software at x.org by
// 10:       # checking directory listing pages.
// 11:       #
// 12:       # X.Org URLs take one of the following formats, among several others:
// 13:       #
// 14:       # * `https://www.x.org/archive/individual/app/example-1.2.3.tar.bz2`
// 15:       # * `https://www.x.org/archive/individual/font/example-1.2.3.tar.bz2`
// 16:       # * `https://www.x.org/archive/individual/lib/libexample-1.2.3.tar.bz2`
// 17:       # * `https://ftp.x.org/archive/individual/lib/libexample-1.2.3.tar.bz2`
// 18:       # * `https://www.x.org/pub/individual/doc/example-1.2.3.tar.gz`
// 19:       # * `https://xorg.freedesktop.org/archive/individual/util/example-1.2.3.tar.xz`
// 20:       #
// 21:       # The notable differences between URLs are as follows:
// 22:       #
// 23:       # * `www.x.org` and `ftp.x.org` seem to be interchangeable (we prefer
// 24:       #   `www.x.org`).
// 25:       # * `/archive/` is the current top-level directory and `/pub/` will
// 26:       #   redirect to the same URL using `/archive/` instead. (The strategy
// 27:       #   handles this replacement to avoid the redirection.)
// 28:       # * The `/individual/` directory contains a number of directories (e.g.
// 29:       #   app, data, doc, driver, font, lib, etc.) which contain a number of
// 30:       #   different archive files.
// 31:       #
// 32:       # Since this strategy ends up checking the same directory listing pages
// 33:       # for multiple formulae, we've included a simple method of page caching.
// 34:       # This prevents livecheck from fetching the same page more than once and
// 35:       # also dramatically speeds up these checks. Eventually we hope to
// 36:       # implement a more sophisticated page cache that all strategies using
// 37:       # {PageMatch} can use (allowing us to simplify this strategy accordingly).
// 38:       #
// 39:       # The default regex identifies versions in archive files found in `href`
// 40:       # attributes.
// 41:       #
// 42:       # @api public
// 43:       class Xorg
// 44:         extend Strategic
// 45:
// 46:         # A `Regexp` used in determining if the strategy applies to the URL and
// 47:         # also as part of extracting the module name from the URL basename.
// 48:         MODULE_REGEX = /(?<module_name>.+)-\d+/i
// 49:
// 50:         # The `Regexp` used to determine if the strategy applies to the URL.
// 51:         URL_MATCH_REGEX = %r{
// 52:           ^https?://(?:[^/]+?\.)* # Scheme and any leading subdomains
// 53:           (?:x\.org/(?:[^/]+/)*individual
// 54:             |freedesktop\.org/(?:archive|dist|software)
// 55:             |archive\.mesa3d\.org)
// 56:           /(?:[^/]+/)*#{MODULE_REGEX.source.strip}
// 57:         }ix
// 58:
// 59:         # A `Regexp` used to extract the module name from the URL basename.
// 60:         FILENAME_REGEX = /^#{MODULE_REGEX.source.strip}/i
// 61:
// 62:         # Used to cache page content, so we don't fetch the same pages
// 63:         # repeatedly.
// 64:         @page_data = T.let({}, T::Hash[String, String])
// 65:
// 66:         class << self
// 67:           sig { params(page_data: T::Hash[String, String]).void }
// 68:           attr_writer :page_data
// 69:         end
// 70:
// 71:         # Whether the strategy can be applied to the provided URL.
// 72:         #
// 73:         # @param url [String] the URL to match against
// 74:         # @return [Boolean]
// 75:         sig { override.params(url: String).returns(T::Boolean) }
// 76:         def self.match?(url)
// 77:           URL_MATCH_REGEX.match?(url)
// 78:         end
// 79:
// 80:         # Extracts information from a provided URL and uses it to generate
// 81:         # various input values used by the strategy to check for new versions.
// 82:         # Some of these values act as defaults and can be overridden in a
// 83:         # `livecheck` block.
// 84:         #
// 85:         # @param url [String] the URL used to generate values
// 86:         # @return [Hash]
// 87:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 88:         def self.generate_input_values(url)
// 89:           values = {}
// 90:
// 91:           file_name = File.basename(url)
// 92:           match = file_name.match(FILENAME_REGEX)
// 93:           return values if match.blank?
// 94:
// 95:           # /pub/ URLs redirect to the same URL with /archive/, so we replace
// 96:           # it to avoid the redirection. Removing the filename from the end of
// 97:           # the URL gives us the relevant directory listing page.
// 98:           values[:url] = url.sub("x.org/pub/", "x.org/archive/").delete_suffix(file_name)
// 99:
// 100:           regex_name = Regexp.escape(T.must(match[:module_name])).gsub("\\-", "-")
// 101:
// 102:           # Example regex: `/href=.*?example[._-]v?(\d+(?:\.\d+)+)\.t/i`
// 103:           values[:regex] = /href=.*?#{regex_name}[._-]v?(\d+(?:\.\d+)+)\.t/i
// 104:
// 105:           values
// 106:         end
// 107:
// 108:         # Generates a URL and regex (if one isn't provided) and checks the
// 109:         # content at the URL for new versions (using the regex for matching).
// 110:         #
// 111:         # The behavior in this method for matching text in the content using a
// 112:         # regex is copied and modified from the {PageMatch} strategy, so that
// 113:         # we can add some simple page caching. If this behavior is expanded to
// 114:         # apply to all strategies that use {PageMatch} to identify versions,
// 115:         # then this strategy can be brought in line with the others.
// 116:         #
// 117:         # @param url [String] the URL of the content to check
// 118:         # @param regex [Regexp, nil] a regex for matching versions in content
// 119:         # @param content [String, nil] content to check instead of fetching
// 120:         # @param options [Options] options to modify behavior
// 121:         # @return [Hash]
// 122:         sig {
// 123:           override.params(
// 124:             url:     String,
// 125:             regex:   T.nilable(Regexp),
// 126:             content: T.nilable(String),
// 127:             options: Options,
// 128:             block:   T.nilable(Proc),
// 129:           ).returns(T::Hash[Symbol, T.anything])
// 130:         }
// 131:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 132:           generated = generate_input_values(url)
// 133:           generated_url = generated[:url]
// 134:
// 135:           # Use the cached page content to avoid duplicate fetches
// 136:           cached_content = @page_data[generated_url]
// 137:           match_data = PageMatch.find_versions(
// 138:             url:     generated_url,
// 139:             regex:   regex || generated[:regex],
// 140:             content: content || cached_content,
// 141:             options:,
// 142:             &block
// 143:           )
// 144:           content = match_data[:content]
// 145:           return match_data if content.blank?
// 146:
// 147:           # Cache any new page content
// 148:           @page_data[generated_url] = content
// 149:
// 150:           match_data
// 151:         end
// 152:       end
// 153:     end
// 154:   end
// 155: end
