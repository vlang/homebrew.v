module download_strategy

import brew_runtime

// Translated from Homebrew/brew `download_strategy/curl_post_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `_fetch(url:, resolved_url:, timeout:)` at line 15.
pub fn ruby_curl_post_download_strategy_l15_d1_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('_fetch', ...args)
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
