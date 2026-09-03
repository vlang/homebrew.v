module download_strategy

import brew_runtime
import os

// Translated from Homebrew/brew `download_strategy/homebrew_curl_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `_curl_download(resolved_url, to, timeout)` at line 16.
pub fn ruby_homebrew_curl_download_strategy_l16_d1_curl_download(mut strategy HomebrewCurlDownloadStrategy, resolved_url string, target string, timeout ?f64) !brew_runtime.CommandResult {
	return strategy.curl_download(resolved_url, target, timeout)
}

// Ruby method `curl_output(*args, **options)` at line 23.
pub fn ruby_homebrew_curl_download_strategy_l23_d2_curl_output(strategy &HomebrewCurlDownloadStrategy, arguments []string) !brew_runtime.CommandResult {
	return strategy.curl_output(arguments)
}

pub struct HomebrewCurlDownloadStrategy {
pub mut:
	curl CurlDownloadStrategy
}

pub fn new_homebrew_curl_download_strategy(url string, name string, version string, meta DownloadMeta) HomebrewCurlDownloadStrategy {
	return HomebrewCurlDownloadStrategy{
		curl: new_curl_download_strategy(url, name, version, meta)
	}
}

pub fn (mut strategy HomebrewCurlDownloadStrategy) curl_download(resolved_url string, target string, timeout ?f64) !brew_runtime.CommandResult {
	_ = homebrew_curl_executable(strategy.curl.file.base.url)!
	mut arguments := ['--remote-time', '--output', target]
	if strategy.curl.try_partial {
		arguments << ['--continue-at', '-']
	}
	arguments << ['--location', resolved_url]
	if limit := timeout {
		arguments << ['--max-time', format_timeout(limit)]
	}
	return strategy.curl_output(arguments)
}

pub fn (strategy &HomebrewCurlDownloadStrategy) curl_output(arguments []string) !brew_runtime.CommandResult {
	curl := homebrew_curl_executable(strategy.curl.file.base.url)!
	mut all_arguments := strategy.curl.curl_args()
	all_arguments << strategy.curl.curl_opts()
	if strategy.curl.mirrors.len > 0 {
		all_arguments << ['--connect-timeout', '15']
	}
	all_arguments << strategy.curl.expand_deferred_environment_args(arguments)
	result := brew_runtime.run_command(curl, all_arguments)
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
	return result
}

fn homebrew_curl_executable(url string) !string {
	if !homebrew_curl_formula_installed() {
		return error('Download failed: Homebrew-installed `curl` is not installed for: ${url}')
	}
	configured := os.getenv('HOMEBREW_BREWED_CURL_PATH')
	if configured != '' && os.is_executable(configured) {
		return configured
	}
	prefix := os.getenv('HOMEBREW_PREFIX')
	candidate := os.join_path(if prefix != '' { prefix } else { '/usr/local' }, 'opt', 'curl', 'bin', 'curl')
	if os.is_executable(candidate) {
		return candidate
	}
	return error('Download failed: Homebrew-installed `curl` is not installed for: ${url}')
}

fn homebrew_curl_formula_installed() bool {
	mut cellar := os.getenv('HOMEBREW_CELLAR')
	if cellar == '' {
		prefix := os.getenv('HOMEBREW_PREFIX')
		cellar = os.join_path(if prefix != '' { prefix } else { '/usr/local' }, 'Cellar')
	}
	rack := os.join_path(cellar, 'curl')
	if !os.is_dir(rack) {
		return false
	}
	for version in os.ls(rack) or { return false } {
		if os.is_file(os.join_path(rack, version, 'INSTALL_RECEIPT.json')) {
			return true
		}
	}
	return false
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
