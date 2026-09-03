module download_strategy

// Translated from Homebrew/brew `download_strategy/download_strategy_detector.rb`.
// The original source is retained below until every stub has a typed V body.

// DownloadStrategy identifies the concrete Ruby strategy class selected by the detector.
pub enum DownloadStrategy {
	curl_github_packages
	github_git
	git
	curl_apache_mirror
	pypi
	subversion
	cvs
	mercurial
	bazaar
	fossil
	curl
	no_unzip_curl
	homebrew_curl
	curl_post
}

// class_name returns the source Ruby strategy class name.
pub fn (strategy DownloadStrategy) class_name() string {
	return match strategy {
		.curl_github_packages { 'CurlGitHubPackagesDownloadStrategy' }
		.github_git { 'GitHubGitDownloadStrategy' }
		.git { 'GitDownloadStrategy' }
		.curl_apache_mirror { 'CurlApacheMirrorDownloadStrategy' }
		.pypi { 'PyPIDownloadStrategy' }
		.subversion { 'SubversionDownloadStrategy' }
		.cvs { 'CVSDownloadStrategy' }
		.mercurial { 'MercurialDownloadStrategy' }
		.bazaar { 'BazaarDownloadStrategy' }
		.fossil { 'FossilDownloadStrategy' }
		.curl { 'CurlDownloadStrategy' }
		.no_unzip_curl { 'NoUnzipCurlDownloadStrategy' }
		.homebrew_curl { 'HomebrewCurlDownloadStrategy' }
		.curl_post { 'CurlPostDownloadStrategy' }
	}
}

// detect translates DownloadStrategyDetector.detect for a typed strategy-class override.
pub fn detect(url string, using ?DownloadStrategy) DownloadStrategy {
	if strategy := using {
		return strategy
	}
	return detect_from_url(url)
}

// detect_with_symbol translates the Symbol branch of detect.
pub fn detect_with_symbol(url string, using ?string) !DownloadStrategy {
	if symbol := using {
		return detect_from_symbol(symbol)
	}
	return detect_from_url(url)
}

// detect_from_url translates every ordered URL branch without invoking Ruby strategies.
pub fn detect_from_url(url string) DownloadStrategy {
	if is_github_packages_url(url) {
		return .curl_github_packages
	}
	if is_github_git_url(url) {
		return .github_git
	}
	if is_generic_git_url(url) {
		return .git
	}
	if url.starts_with('http://www.apache.org/dyn/closer.cgi')
		|| url.starts_with('https://www.apache.org/dyn/closer.cgi')
		|| url.starts_with('http://www.apache.org/dyn/closer.lua')
		|| url.starts_with('https://www.apache.org/dyn/closer.lua') {
		return .curl_apache_mirror
	}
	if url.starts_with('http://files.pythonhosted.org/packages/')
		|| url.starts_with('https://files.pythonhosted.org/packages/') {
		return .pypi
	}
	if is_subversion_url(url) {
		return .subversion
	}
	if url.starts_with('cvs://') {
		return .cvs
	}
	if is_mercurial_url(url) {
		return .mercurial
	}
	if url.starts_with('bzr://') {
		return .bazaar
	}
	if url.starts_with('fossil://') {
		return .fossil
	}
	return .curl
}

// detect_from_symbol translates every supported :using symbol.
pub fn detect_from_symbol(symbol string) !DownloadStrategy {
	return match symbol {
		'hg' { DownloadStrategy.mercurial }
		'nounzip' { DownloadStrategy.no_unzip_curl }
		'git' { DownloadStrategy.git }
		'bzr' { DownloadStrategy.bazaar }
		'svn' { DownloadStrategy.subversion }
		'curl' { DownloadStrategy.curl }
		'homebrew_curl' { DownloadStrategy.homebrew_curl }
		'cvs' { DownloadStrategy.cvs }
		'post' { DownloadStrategy.curl_post }
		'fossil' { DownloadStrategy.fossil }
		else { return error('Unknown download strategy ${symbol} was requested.') }
	}
}

fn is_github_packages_url(url string) bool {
	path := if url.starts_with('https://ghcr.io/v2/') {
		url['https://ghcr.io/v2/'.len..]
	} else if url.starts_with('docker://ghcr.io/') {
		url['docker://ghcr.io/'.len..]
	} else {
		return false
	}
	parts := path.split('/')
	if parts.len < 2 {
		return false
	}
	return valid_github_package_component(parts[0]) && has_github_package_component_prefix(parts[1])
}

fn valid_github_package_component(value string) bool {
	if value == '' {
		return false
	}
	for character in value {
		if !character.is_alnum() && character !in [`_`, `-`] {
			return false
		}
	}
	return true
}

fn has_github_package_component_prefix(value string) bool {
	if value == '' {
		return false
	}
	return value[0].is_alnum() || value[0] in [`_`, `-`]
}

fn is_github_git_url(url string) bool {
	for prefix in ['http://github.com/', 'https://github.com/'] {
		if url.starts_with(prefix) && url.ends_with('.git') {
			parts := url[prefix.len..].split('/')
			return parts.len == 2 && parts[0] != '' && parts[1] != '.git'
		}
	}
	return false
}

fn is_generic_git_url(url string) bool {
	if ((url.starts_with('http://') || url.starts_with('https://')) && url.ends_with('.git'))
		|| url.starts_with('git://') || url.starts_with('ssh://git') {
		return true
	}
	return exact_two_segment_http_url(url, 'git.sr.ht')
		|| exact_two_segment_http_url(url, 'tangled.sh')
}

fn exact_two_segment_http_url(url string, host string) bool {
	for prefix in ['http://${host}/', 'https://${host}/'] {
		if url.starts_with(prefix) {
			parts := url[prefix.len..].split('/')
			return parts.len == 2 && parts[0] != '' && parts[1] != ''
		}
	}
	return false
}

fn is_subversion_url(url string) bool {
	if url.starts_with('svn://') || url.starts_with('svn+http://')
		|| url.starts_with('http://svn.apache.org/repos/') {
		return true
	}
	host, path := http_host_and_path(url) or { return false }
	return ((host == 'googlecode.com' || host.ends_with('.googlecode.com'))
		&& path.starts_with('/svn')) || host.starts_with('svn.')
		|| ((host == 'sourceforge.net' || host.ends_with('.sourceforge.net'))
		&& path.starts_with('/svnroot/'))
}

fn is_mercurial_url(url string) bool {
	if url.starts_with('hg://') {
		return true
	}
	host, path := http_host_and_path(url) or { return false }
	return ((host == 'googlecode.com' || host.ends_with('.googlecode.com'))
		&& path.starts_with('/hg'))
		|| ((host == 'sourceforge.net' || host.ends_with('.sourceforge.net'))
		&& path.starts_with('/hgweb/'))
}

fn http_host_and_path(url string) ?(string, string) {
	mut remainder := if url.starts_with('http://') {
		url['http://'.len..]
	} else if url.starts_with('https://') {
		url['https://'.len..]
	} else {
		return none
	}
	slash := remainder.index('/') or { return remainder, '' }
	host := remainder[..slash]
	remainder = remainder[slash..]
	return host, remainder
}

// Ruby method `self.detect(url, using = nil)` at line 10.
pub fn ruby_download_strategy_detector_l10_d1_self_detect(url string, using ?string) !DownloadStrategy {
	return detect_with_symbol(url, using)
}

// Ruby method `self.detect_from_url(url)` at line 24.
pub fn ruby_download_strategy_detector_l24_d2_self_detect_from_url(url string) DownloadStrategy {
	return detect_from_url(url)
}

// Ruby method `self.detect_from_symbol(symbol)` at line 64.
pub fn ruby_download_strategy_detector_l64_d3_self_detect_from_symbol(symbol string) !DownloadStrategy {
	return detect_from_symbol(symbol)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Helper class for detecting a download strategy from a URL.
// 5: class DownloadStrategyDetector
// 6:   sig {
// 7:     params(url: String, using: T.nilable(T.any(Symbol, T::Class[AbstractDownloadStrategy])))
// 8:       .returns(T::Class[AbstractDownloadStrategy])
// 9:   }
// 10:   def self.detect(url, using = nil)
// 11:     if using.nil?
// 12:       detect_from_url(url)
// 13:     elsif using.is_a?(Class) && using < AbstractDownloadStrategy
// 14:       using
// 15:     elsif using.is_a?(Symbol)
// 16:       detect_from_symbol(using)
// 17:     else
// 18:       raise TypeError,
// 19:             "Unknown download strategy specification: #{using.inspect}"
// 20:     end
// 21:   end
// 22:
// 23:   sig { params(url: String).returns(T::Class[AbstractDownloadStrategy]) }
// 24:   def self.detect_from_url(url)
// 25:     case url
// 26:     when GitHubPackages::URL_REGEX
// 27:       CurlGitHubPackagesDownloadStrategy
// 28:     when %r{^https?://github\.com/[^/]+/[^/]+\.git$}
// 29:       GitHubGitDownloadStrategy
// 30:     when %r{^https?://.+\.git$},
// 31:          %r{^git://},
// 32:          %r{^https?://git\.sr\.ht/[^/]+/[^/]+$},
// 33:          %r{^https?://tangled\.sh/[^/]+/[^/]+$},
// 34:          %r{^ssh://git}
// 35:       GitDownloadStrategy
// 36:     when %r{^https?://www\.apache\.org/dyn/closer\.cgi},
// 37:          %r{^https?://www\.apache\.org/dyn/closer\.lua}
// 38:       CurlApacheMirrorDownloadStrategy
// 39:     when %r{^https?://files\.pythonhosted\.org/packages/}
// 40:       PyPIDownloadStrategy
// 41:     when %r{^https?://([A-Za-z0-9\-.]+\.)?googlecode\.com/svn},
// 42:          %r{^https?://svn\.},
// 43:          %r{^svn://},
// 44:          %r{^svn\+http://},
// 45:          %r{^http://svn\.apache\.org/repos/},
// 46:          %r{^https?://([A-Za-z0-9\-.]+\.)?sourceforge\.net/svnroot/}
// 47:       SubversionDownloadStrategy
// 48:     when %r{^cvs://}
// 49:       CVSDownloadStrategy
// 50:     when %r{^hg://},
// 51:          %r{^https?://([A-Za-z0-9\-.]+\.)?googlecode\.com/hg},
// 52:          %r{^https?://([A-Za-z0-9\-.]+\.)?sourceforge\.net/hgweb/}
// 53:       MercurialDownloadStrategy
// 54:     when %r{^bzr://}
// 55:       BazaarDownloadStrategy
// 56:     when %r{^fossil://}
// 57:       FossilDownloadStrategy
// 58:     else
// 59:       CurlDownloadStrategy
// 60:     end
// 61:   end
// 62:
// 63:   sig { params(symbol: Symbol).returns(T::Class[AbstractDownloadStrategy]) }
// 64:   def self.detect_from_symbol(symbol)
// 65:     case symbol
// 66:     when :hg                     then MercurialDownloadStrategy
// 67:     when :nounzip                then NoUnzipCurlDownloadStrategy
// 68:     when :git                    then GitDownloadStrategy
// 69:     when :bzr                    then BazaarDownloadStrategy
// 70:     when :svn                    then SubversionDownloadStrategy
// 71:     when :curl                   then CurlDownloadStrategy
// 72:     when :homebrew_curl          then HomebrewCurlDownloadStrategy
// 73:     when :cvs                    then CVSDownloadStrategy
// 74:     when :post                   then CurlPostDownloadStrategy
// 75:     when :fossil                 then FossilDownloadStrategy
// 76:     else
// 77:       raise TypeError, "Unknown download strategy #{symbol} was requested."
// 78:     end
// 79:   end
// 80: end
