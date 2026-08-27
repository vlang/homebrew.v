module download_strategy

import brew_runtime

// Translated from Homebrew/brew `download_strategy/homebrew_curl_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `_curl_download(resolved_url, to, timeout)` at line 16.
pub fn ruby_homebrew_curl_download_strategy_l16_d1_curl_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('_curl_download', ...args)
}

// Ruby method `curl_output(*args, **options)` at line 23.
pub fn ruby_homebrew_curl_download_strategy_l23_d2_curl_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('curl_output', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5:
// 6: # Strategy for downloading a file using Homebrew's `curl`.
// 7: #
// 8: # @api public
// 9: class HomebrewCurlDownloadStrategy < CurlDownloadStrategy
// 10:   private
// 11:
// 12:   sig {
// 13:     params(resolved_url: String, to: T.any(Pathname, String), timeout: T.nilable(T.any(Float, Integer)))
// 14:       .returns(T.nilable(SystemCommand::Result))
// 15:   }
// 16:   def _curl_download(resolved_url, to, timeout)
// 17:     raise HomebrewCurlDownloadStrategyError, url unless Utils::Path.formula_any_version_installed?("curl")
// 18:
// 19:     curl_download resolved_url, to:, try_partial: @try_partial, timeout:, use_homebrew_curl: true
// 20:   end
// 21:
// 22:   sig { override.params(args: String, options: T.untyped).returns(SystemCommand::Result) }
// 23:   def curl_output(*args, **options)
// 24:     raise HomebrewCurlDownloadStrategyError, url unless Utils::Path.formula_any_version_installed?("curl")
// 25:
// 26:     options[:use_homebrew_curl] = true
// 27:     super
// 28:   end
// 29: end
