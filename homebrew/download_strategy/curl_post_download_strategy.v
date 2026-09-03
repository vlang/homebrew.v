module download_strategy

import brew_runtime
import net.urllib

// Translated from Homebrew/brew `download_strategy/curl_post_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `_fetch(url:, resolved_url:, timeout:)` at line 15.
pub fn ruby_curl_post_download_strategy_l15_d1_fetch(mut strategy CurlPostDownloadStrategy, url string, resolved_url string, timeout ?f64) !brew_runtime.CommandResult {
	return strategy.fetch_to_temporary(url, resolved_url, timeout)
}

pub struct CurlPostField {
pub:
	name  string
	value string
}

// CurlPostDownloadStrategy retains the arbitrary `data` metadata which the
// shared curl strategy does not otherwise need.
pub struct CurlPostDownloadStrategy {
pub mut:
	curl     CurlDownloadStrategy
	data     []CurlPostField
	has_data bool
}

pub fn new_curl_post_download_strategy(url string, name string, version string, meta DownloadMeta, data []CurlPostField, has_data bool) CurlPostDownloadStrategy {
	return CurlPostDownloadStrategy{
		curl: new_curl_download_strategy(url, name, version, meta)
		data: data.clone()
		has_data: has_data
	}
}

pub fn (mut strategy CurlPostDownloadStrategy) fetch_to_temporary(url string, resolved_url string, timeout ?f64) !brew_runtime.CommandResult {
	strategy.curl.ensure_no_insecure_redirect(url, resolved_url)!
	mut request := []string{}
	if strategy.has_data {
		request << url
		for field in strategy.data {
			request << '-d'
			request << '${post_form_escape(field.name)}=${post_form_escape(field.value)}'
		}
	} else if query_index := url.index('?') {
		request << url[..query_index]
		request << '-d'
		request << url[query_index + 1..]
	} else {
		request << url
		request << '-X'
		request << 'POST'
	}
	mut arguments := ['--remote-time', '--output', strategy.curl.temporary_path()]
	if strategy.curl.try_partial {
		arguments << ['--continue-at', '-']
	}
	arguments << '--location'
	arguments << request
	if limit := timeout {
		arguments << ['--max-time', format_timeout(limit)]
	}
	return strategy.curl.curl(arguments)
}

fn post_form_escape(value string) string {
	return urllib.query_escape(value).replace('%20', '+')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading via an HTTP POST request using `curl`.
// 5: # Query parameters on the URL are converted into POST parameters.
// 6: #
// 7: # @api public
// 8: class CurlPostDownloadStrategy < CurlDownloadStrategy
// 9:   private
// 10:
// 11:   sig {
// 12:     override.params(url: String, resolved_url: String, timeout: T.nilable(T.any(Float, Integer)))
// 13:             .returns(T.nilable(SystemCommand::Result))
// 14:   }
// 15:   def _fetch(url:, resolved_url:, timeout:)
// 16:     ensure_no_insecure_redirect!(url:, resolved_url:)
// 17:
// 18:     args = if meta.key?(:data)
// 19:       escape_data = ->(d) { ["-d", URI.encode_www_form([d])] }
// 20:       [url, *meta[:data].flat_map(&escape_data)]
// 21:     else
// 22:       url, query = url.split("?", 2)
// 23:       query.nil? ? [url, "-X", "POST"] : [url, "-d", query]
// 24:     end
// 25:
// 26:     curl_download(*args, to: temporary_path, try_partial: @try_partial, timeout:)
// 27:   end
// 28: end
