module vulns

import net.urllib
import x.json2

// Translated from Homebrew/brew `vulns/osv.rb`.
pub const osv_api_base = 'https://api.osv.dev/v1'
pub const osv_batch_size = 1000
pub const osv_max_pages = 100

pub struct OsvPackage {
pub:
	ecosystem string
	name      string
	version   ?string
}

pub struct OsvQueryPackage {
pub:
	name      string
	ecosystem string
}

pub struct OsvQuery {
pub:
	package    OsvQueryPackage
	version    ?string @[omitempty]
	page_token ?string @[omitempty]
}

pub struct OsvBatchRequest {
pub:
	queries []OsvQuery
}

pub struct OsvVulnerability {
pub:
	id       string
	modified string
	summary  string
	details  string
	aliases  []string
	related  []string
}

pub struct OsvBatchResult {
pub:
	vulns           []OsvVulnerability
	next_page_token ?string @[omitempty]
}

pub struct OsvBatchResponse {
pub:
	results []OsvBatchResult
}

pub struct OsvHttpResult {
pub:
	stdout      string
	success     bool = true
	exit_status int
	stderr      string
}

pub struct OsvJsonResponse {
pub:
	body string
}

pub type OsvHttpRequest = fn ([]string) !OsvHttpResult

struct OsvPendingQuery {
	slot  int
	query OsvQuery
}

pub fn osv_request_arguments(url string, extra_args []string) []string {
	mut arguments := ['--fail', '--location', '--silent']
	arguments << extra_args
	arguments << url
	return arguments
}

pub fn osv_post_arguments(url string, payload OsvBatchRequest) []string {
	return osv_request_arguments(url, ['--json', json2.encode(payload), '--request', 'POST'])
}

pub fn osv_get_arguments(url string) []string {
	return osv_request_arguments(url, []string{})
}

pub fn osv_request(url string, extra_args []string, request OsvHttpRequest) !OsvJsonResponse {
	result := request(osv_request_arguments(url, extra_args))!
	if !result.success {
		return error('OSV API request to ${url} failed (curl exit ${result.exit_status}): ${result.stderr}')
	}
	json2.decode[json2.Any](result.stdout) or {
		return error('Invalid JSON from OSV API at ${url}: ${err.msg()}')
	}
	return OsvJsonResponse{
		body: result.stdout
	}
}

pub fn osv_post(url string, payload OsvBatchRequest, request OsvHttpRequest) !OsvBatchResponse {
	response := osv_request(url, ['--json', json2.encode(payload), '--request', 'POST'], request)!
	return json2.decode[OsvBatchResponse](response.body) or {
		return error('Invalid JSON from OSV API at ${url}: ${err.msg()}')
	}
}

pub fn osv_get(url string, request OsvHttpRequest) !OsvVulnerability {
	response := osv_request(url, []string{}, request)!
	return json2.decode[OsvVulnerability](response.body) or {
		return error('Invalid JSON from OSV API at ${url}: ${err.msg()}')
	}
}

fn osv_query_for_package(package OsvPackage) OsvQuery {
	return OsvQuery{
		package: OsvQueryPackage{
			name: package.name
			ecosystem: package.ecosystem
		}
		version: package.version
	}
}

pub fn osv_query_batch(packages []OsvPackage, request OsvHttpRequest) ![][]OsvVulnerability {
	return osv_query_batch_with_limits(packages, osv_batch_size, osv_max_pages, request)
}

pub fn osv_query_batch_with_limits(packages []OsvPackage, batch_size int, max_pages int,
	request OsvHttpRequest) ![][]OsvVulnerability {
	if packages.len == 0 {
		return [][]OsvVulnerability{}
	}
	if batch_size <= 0 {
		return error('OSV API querybatch batch size must be positive')
	}
	if max_pages <= 0 {
		return error('OSV API querybatch page limit must be positive')
	}
	mut results := [][]OsvVulnerability{cap: packages.len}
	for _ in packages {
		results << []OsvVulnerability{}
	}
	mut batch_start := 0
	for batch_start < packages.len {
		batch_end := if batch_start + batch_size < packages.len {
			batch_start + batch_size
		} else {
			packages.len
		}
		mut pending := []OsvPendingQuery{cap: batch_end - batch_start}
		for index in batch_start .. batch_end {
			pending << OsvPendingQuery{
				slot: index
				query: osv_query_for_package(packages[index])
			}
		}
		mut page := 0
		for pending.len > 0 {
			page++
			if page > max_pages {
				return error('OSV API returned more than ${max_pages} pages for a querybatch; aborting')
			}
			response := osv_post('${osv_api_base}/querybatch', OsvBatchRequest{
				queries: pending.map(it.query)
			}, request)!
			if response.results.len != pending.len {
				return error('OSV API querybatch: expected ${pending.len} results, got ${response.results.len}')
			}
			mut continued := []OsvPendingQuery{}
			for index, result in response.results {
				entry := pending[index]
				results[entry.slot] << result.vulns
				if token := result.next_page_token {
					if token != '' {
						continued << OsvPendingQuery{
							slot: entry.slot
							query: OsvQuery{
								package: entry.query.package
								version: entry.query.version
								page_token: token
							}
						}
					}
				}
			}
			pending = continued.clone()
		}
		batch_start = batch_end
	}
	return results
}

pub fn osv_encode_vulnerability_id(id string) string {
	return urllib.query_escape(id).replace('+', '%20')
}

pub fn osv_vulnerability(id string, request OsvHttpRequest) !OsvVulnerability {
	return osv_get('${osv_api_base}/vulns/${osv_encode_vulnerability_id(id)}', request)
}
