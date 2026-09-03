module download_strategy

import json2

// Translated from Homebrew/brew `download_strategy/curl_apache_mirror_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `mirrors` at line 9.
pub fn ruby_curl_apache_mirror_download_strategy_l9_d1_mirrors(mut strategy CurlApacheMirrorDownloadStrategy) ![]string {
	return strategy.mirrors()
}

// Ruby method `combined_mirrors` at line 16.
pub fn ruby_curl_apache_mirror_download_strategy_l16_d2_combined_mirrors(mut strategy CurlApacheMirrorDownloadStrategy) ![]string {
	return strategy.combined_mirrors()
}

// Ruby method `resolve_url_basename_time_file_size(url, timeout: nil)` at line 28.
pub fn ruby_curl_apache_mirror_download_strategy_l28_d3_resolve_url_basename_time_file_size(mut strategy CurlApacheMirrorDownloadStrategy, url string, timeout ?f64) !UrlMetadata {
	return strategy.resolve_url_basename_time_file_size(url, timeout)
}

// Ruby method `apache_mirrors` at line 42.
pub fn ruby_curl_apache_mirror_download_strategy_l42_d4_apache_mirrors(mut strategy CurlApacheMirrorDownloadStrategy) !ApacheMirrors {
	return strategy.apache_mirrors()
}

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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading a file from an Apache Mirror URL.
// 5: #
// 6: # @api public
// 7: class CurlApacheMirrorDownloadStrategy < CurlDownloadStrategy
// 8:   sig { returns(T::Array[String]) }
// 9:   def mirrors
// 10:     combined_mirrors
// 11:   end
// 12:
// 13:   private
// 14:
// 15:   sig { returns(T::Array[String]) }
// 16:   def combined_mirrors
// 17:     return T.must(@combined_mirrors) if defined?(@combined_mirrors)
// 18:
// 19:     backup_mirrors = unless apache_mirrors["in_attic"]
// 20:       apache_mirrors.fetch("backup", [])
// 21:                     .map { |mirror| "#{mirror}#{apache_mirrors["path_info"]}" }
// 22:     end
// 23:
// 24:     T.must(@combined_mirrors = T.let([*@mirrors, *backup_mirrors], T.nilable(T::Array[String])))
// 25:   end
// 26:
// 27:   sig { override.params(url: String, timeout: T.nilable(T.any(Float, Integer))).returns(URLMetadata) }
// 28:   def resolve_url_basename_time_file_size(url, timeout: nil)
// 29:     if url == self.url
// 30:       preferred = if apache_mirrors["in_attic"]
// 31:         "https://archive.apache.org/dist/"
// 32:       else
// 33:         apache_mirrors["preferred"]
// 34:       end
// 35:       super("#{preferred}#{apache_mirrors["path_info"]}", timeout:)
// 36:     else
// 37:       super
// 38:     end
// 39:   end
// 40:
// 41:   sig { returns(T::Hash[String, T.untyped]) }
// 42:   def apache_mirrors
// 43:     return T.must(@apache_mirrors) if defined?(@apache_mirrors)
// 44:
// 45:     json = curl_output("--silent", "--location", "#{url}&asjson=1").stdout
// 46:     T.must(@apache_mirrors = T.let(JSON.parse(json), T.nilable(T::Hash[String, T.untyped])))
// 47:   rescue JSON::ParserError
// 48:     raise CurlDownloadStrategyError.new(url, "Couldn't determine mirror, try again later.")
// 49:   end
// 50: end
