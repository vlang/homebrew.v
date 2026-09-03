module vulns

import net.urllib
import x.json2

// Translated from Homebrew/brew `vulns/osv.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type OsvHttpRequest = fn([]string) !OsvHttpResult

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

// Ruby method `self.query_batch(packages)` at line 24.
pub fn ruby_osv_l24_d1_self_query_batch(packages []OsvPackage,
	request OsvHttpRequest) ![][]OsvVulnerability {
	return osv_query_batch(packages, request)
}

// Ruby method `self.vulnerability(id)` at line 74.
pub fn ruby_osv_l74_d2_self_vulnerability(id string,
	request OsvHttpRequest) !OsvVulnerability {
	return osv_vulnerability(id, request)
}

// Ruby method `self.post(url, payload)` at line 79.
pub fn ruby_osv_l79_d3_self_post(url string, payload OsvBatchRequest,
	request OsvHttpRequest) !OsvBatchResponse {
	return osv_post(url, payload, request)
}

// Ruby method `self.get(url)` at line 84.
pub fn ruby_osv_l84_d4_self_get(url string, request OsvHttpRequest) !OsvVulnerability {
	return osv_get(url, request)
}

// Ruby method `self.request(url, *extra_args)` at line 89.
pub fn ruby_osv_l89_d5_self_request(url string, extra_args []string,
	request OsvHttpRequest) !OsvJsonResponse {
	return osv_request(url, extra_args, request)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "utils/curl"
// 6:
// 7: module Homebrew
// 8:   module Vulns
// 9:     # Client for https://google.github.io/osv.dev/api/.
// 10:     module OSV
// 11:       API_BASE = "https://api.osv.dev/v1"
// 12:       BATCH_SIZE = 1000
// 13:       MAX_PAGES = 100
// 14:
// 15:       class Error < RuntimeError; end
// 16:       class ApiError < Error; end
// 17:
// 18:       Package = T.type_alias { { ecosystem: String, name: String, version: T.nilable(String) } }
// 19:
// 20:       # POST /v1/querybatch. Returns one array of vuln hashes per input package,
// 21:       # in the same order. Follows per-result `next_page_token` continuations.
// 22:       # A `nil` version queries all known vulnerabilities for the package.
// 23:       sig { params(packages: T::Array[Package]).returns(T::Array[T::Array[T::Hash[String, T.untyped]]]) }
// 24:       def self.query_batch(packages)
// 25:         return [] if packages.empty?
// 26:
// 27:         results = Array.new(packages.size) { [] }
// 28:
// 29:         packages.each_slice(BATCH_SIZE).with_index do |batch, batch_index|
// 30:           offset = batch_index * BATCH_SIZE
// 31:           pending = batch.map.with_index do |pkg, index|
// 32:             query = T.let({ package: { name: pkg.fetch(:name), ecosystem: pkg.fetch(:ecosystem) } },
// 33:                           T::Hash[Symbol, T.untyped])
// 34:             query[:version] = pkg.fetch(:version) if pkg.fetch(:version)
// 35:             { slot: offset + index, query: }
// 36:           end
// 37:
// 38:           page = 0
// 39:           while pending.any?
// 40:             page += 1
// 41:             if page > MAX_PAGES
// 42:               raise ApiError, "OSV API returned more than #{MAX_PAGES} pages for a querybatch; aborting"
// 43:             end
// 44:
// 45:             response = post("#{API_BASE}/querybatch", { queries: pending.map { |p| p.fetch(:query) } })
// 46:             batch_results = response["results"]
// 47:             if !batch_results.is_a?(Array) || batch_results.length != pending.length
// 48:               got = batch_results.is_a?(Array) ? batch_results.length : batch_results.class
// 49:               raise ApiError,
// 50:                     "OSV API querybatch: expected #{pending.length} results, got #{got}"
// 51:             end
// 52:
// 53:             continued = []
// 54:             batch_results.each_with_index do |result, index|
// 55:               entry = pending.fetch(index)
// 56:               results.fetch(entry.fetch(:slot)).concat(Array(result["vulns"]))
// 57:               token = result["next_page_token"]
// 58:               next if token.to_s.empty?
// 59:
// 60:               continued << {
// 61:                 slot:  entry.fetch(:slot),
// 62:                 query: entry.fetch(:query).merge(page_token: token),
// 63:               }
// 64:             end
// 65:             pending = continued
// 66:           end
// 67:         end
// 68:
// 69:         results
// 70:       end
// 71:
// 72:       # GET /v1/vulns/{id}.
// 73:       sig { params(id: String).returns(T::Hash[String, T.untyped]) }
// 74:       def self.vulnerability(id)
// 75:         get("#{API_BASE}/vulns/#{ERB::Util.url_encode(id)}")
// 76:       end
// 77:
// 78:       sig { params(url: String, payload: T::Hash[T.untyped, T.untyped]).returns(T::Hash[String, T.untyped]) }
// 79:       private_class_method def self.post(url, payload)
// 80:         request(url, "--json", JSON.generate(payload), "--request", "POST")
// 81:       end
// 82:
// 83:       sig { params(url: String).returns(T::Hash[String, T.untyped]) }
// 84:       private_class_method def self.get(url)
// 85:         request(url)
// 86:       end
// 87:
// 88:       sig { params(url: String, extra_args: String).returns(T::Hash[String, T.untyped]) }
// 89:       private_class_method def self.request(url, *extra_args)
// 90:         result = Utils::Curl.curl_output("--fail", "--location", "--silent", *extra_args, url)
// 91:         unless result.success?
// 92:           raise ApiError, "OSV API request to #{url} failed (curl exit #{result.exit_status}): #{result.stderr}"
// 93:         end
// 94:
// 95:         JSON.parse(result.stdout)
// 96:       rescue JSON::ParserError => e
// 97:         raise ApiError, "Invalid JSON from OSV API at #{url}: #{e.message}"
// 98:       end
// 99:     end
// 100:   end
// 101: end
