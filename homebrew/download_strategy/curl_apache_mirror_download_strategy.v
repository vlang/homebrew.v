module download_strategy

import json2

// Translated from Homebrew/brew `download_strategy/curl_apache_mirror_download_strategy.rb`.

pub struct ApacheMirrors {
pub:
	preferred string
	path_info string
	backup    []string
	in_attic  bool
}

pub struct CurlApacheMirrorDownloadStrategy {
pub mut:
	curl                       CurlDownloadStrategy
	apache_mirrors_cache       ApacheMirrors
	has_apache_mirrors         bool
	combined_mirrors_cache     []string
	has_combined_mirrors_cache bool
}

pub fn new_curl_apache_mirror_download_strategy(url string, name string, version string, meta DownloadMeta) CurlApacheMirrorDownloadStrategy {
	return CurlApacheMirrorDownloadStrategy{
		curl: new_curl_download_strategy(url, name, version, meta)
	}
}

pub fn (mut strategy CurlApacheMirrorDownloadStrategy) mirrors() ![]string {
	return strategy.combined_mirrors()
}

pub fn (mut strategy CurlApacheMirrorDownloadStrategy) combined_mirrors() ![]string {
	if strategy.has_combined_mirrors_cache {
		return strategy.combined_mirrors_cache.clone()
	}
	metadata := strategy.apache_mirrors()!
	mut combined := strategy.curl.mirrors.clone()
	if !metadata.in_attic {
		for mirror in metadata.backup {
			combined << '${mirror}${metadata.path_info}'
		}
	}
	strategy.combined_mirrors_cache = combined
	strategy.has_combined_mirrors_cache = true
	return combined.clone()
}

pub fn (mut strategy CurlApacheMirrorDownloadStrategy) resolve_url_basename_time_file_size(url string, timeout ?f64) !UrlMetadata {
	if url == strategy.curl.file.base.url {
		metadata := strategy.apache_mirrors()!
		preferred := if metadata.in_attic {
			'https://archive.apache.org/dist/'
		} else {
			metadata.preferred
		}
		return strategy.curl.resolve_url_basename_time_file_size('${preferred}${metadata.path_info}', timeout)
	}
	return strategy.curl.resolve_url_basename_time_file_size(url, timeout)
}

pub fn (mut strategy CurlApacheMirrorDownloadStrategy) apache_mirrors() !ApacheMirrors {
	if strategy.has_apache_mirrors {
		return strategy.apache_mirrors_cache
	}
	result := strategy.curl.curl_output(['--silent', '--location',
		'${strategy.curl.file.base.url}&asjson=1']) or {
		return error("Couldn't determine mirror, try again later: ${err.msg()}")
	}
	metadata := json2.decode[ApacheMirrors](result.output) or {
		return error("Couldn't determine mirror, try again later.")
	}
	strategy.apache_mirrors_cache = metadata
	strategy.has_apache_mirrors = true
	return metadata
}
