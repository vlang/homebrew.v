module download_strategy

import ruby
import net.urllib

// Translated from Homebrew/brew `download_strategy/curl_post_download_strategy.rb`.

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

pub fn (mut strategy CurlPostDownloadStrategy) fetch_to_temporary(url string, resolved_url string, timeout ?f64) !ruby.CommandResult {
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
