module download_strategy

// Translated from Homebrew/brew `download_strategy/download_strategy_detector.rb`.

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
		else {
			return error('Unknown download strategy ${symbol} was requested.')
		}
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
