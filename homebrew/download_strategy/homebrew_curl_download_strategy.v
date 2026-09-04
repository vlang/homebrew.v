module download_strategy

import ruby
import os

// Translated from Homebrew/brew `download_strategy/homebrew_curl_download_strategy.rb`.

pub struct HomebrewCurlDownloadStrategy {
pub mut:
	curl CurlDownloadStrategy
}

pub fn new_homebrew_curl_download_strategy(url string, name string, version string, meta DownloadMeta) HomebrewCurlDownloadStrategy {
	return HomebrewCurlDownloadStrategy{
		curl: new_curl_download_strategy(url, name, version, meta)
	}
}

pub fn (mut strategy HomebrewCurlDownloadStrategy) curl_download(resolved_url string, target string, timeout ?f64) !ruby.CommandResult {
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

pub fn (strategy &HomebrewCurlDownloadStrategy) curl_output(arguments []string) !ruby.CommandResult {
	curl := homebrew_curl_executable(strategy.curl.file.base.url)!
	mut all_arguments := strategy.curl.curl_args()
	all_arguments << strategy.curl.curl_opts()
	if strategy.curl.mirrors.len > 0 {
		all_arguments << ['--connect-timeout', '15']
	}
	all_arguments << strategy.curl.expand_deferred_environment_args(arguments)
	result := ruby.run_command(curl, all_arguments)
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
