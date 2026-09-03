module download_strategies

import homebrew.download_strategy
import os
import regex
import time

// Translated from Homebrew/brew `test/download_strategies/curl_spec.rb`.
// The original source is retained below for source parity.
const curl_spec_deferred_header = 'PRIVATE-TOKEN: {{HOMEBREW_DEFERRED_ENV:HOMEBREW_PRIVATE_TOKEN}}'

pub struct CurlSpecStatus {
pub:
	success     bool
	exit_status int
	term_signal ?int
}

struct CurlSpecFetchResult {
	commands        [][]string
	error_message   string
	cached_location string
}

struct CurlSpecCurlFixture {
	root                 string
	log_path             string
	previous_path        string
	previous_log         string
	previous_head        string
	previous_final_url   string
	previous_failure_url string
}

fn curl_spec_fixture(final_url string, failure_url string) !CurlSpecCurlFixture {
	root := os.join_path(os.temp_dir(), 'brew-v-curl-strategy-spec-${os.getpid()}-${time.now().unix_micro()}')
	bin := os.join_path(root, 'bin')
	os.mkdir_all(bin)!
	log_path := os.join_path(root, 'curl.log')
	script_path := os.join_path(bin, 'curl')
	script := r'#!/bin/sh
printf "%s\n" "__COMMAND__" >> "$BREW_V_CURL_SPEC_LOG"
is_head=0
output=""
previous=""
last=""
for arg in "$@"; do
  printf "%s\n" "$arg" >> "$BREW_V_CURL_SPEC_LOG"
  if [ "$arg" = "--head" ]; then is_head=1; fi
  if [ "$previous" = "--output" ]; then output="$arg"; fi
  previous="$arg"
  last="$arg"
done
if [ "$is_head" = "1" ]; then
  printf "%s" "$BREW_V_CURL_SPEC_HEAD"
  effective="$last"
  if [ -n "$BREW_V_CURL_SPEC_FINAL_URL" ]; then effective="$BREW_V_CURL_SPEC_FINAL_URL"; fi
  printf "\n__BREW_EFFECTIVE_URL__:%s\n" "$effective"
  exit 0
fi
if [ -n "$BREW_V_CURL_SPEC_FAILURE_URL" ]; then
  for arg in "$@"; do
    if [ "$arg" = "$BREW_V_CURL_SPEC_FAILURE_URL" ]; then exit 6; fi
  done
fi
if [ -n "$output" ] && [ "$output" != "/dev/null" ]; then : > "$output"; fi
exit 0
'
	os.write_file(script_path, script)!
	os.chmod(script_path, 0o755)!
	fixture := CurlSpecCurlFixture{
		root: root
		log_path: log_path
		previous_path: os.getenv('PATH')
		previous_log: os.getenv('BREW_V_CURL_SPEC_LOG')
		previous_head: os.getenv('BREW_V_CURL_SPEC_HEAD')
		previous_final_url: os.getenv('BREW_V_CURL_SPEC_FINAL_URL')
		previous_failure_url: os.getenv('BREW_V_CURL_SPEC_FAILURE_URL')
	}
	os.setenv('PATH', '${bin}:${fixture.previous_path}', true)
	os.setenv('BREW_V_CURL_SPEC_LOG', log_path, true)
	os.setenv('BREW_V_CURL_SPEC_HEAD', 'HTTP/2 200\r\nContent-Length: 0\r\n\r\n', true)
	os.setenv('BREW_V_CURL_SPEC_FINAL_URL', final_url, true)
	os.setenv('BREW_V_CURL_SPEC_FAILURE_URL', failure_url, true)
	return fixture
}

fn (fixture CurlSpecCurlFixture) close() {
	os.setenv('PATH', fixture.previous_path, true)
	os.setenv('BREW_V_CURL_SPEC_LOG', fixture.previous_log, true)
	os.setenv('BREW_V_CURL_SPEC_HEAD', fixture.previous_head, true)
	os.setenv('BREW_V_CURL_SPEC_FINAL_URL', fixture.previous_final_url, true)
	os.setenv('BREW_V_CURL_SPEC_FAILURE_URL', fixture.previous_failure_url, true)
	os.rmdir_all(fixture.root) or {}
}

fn (fixture CurlSpecCurlFixture) commands() ![][]string {
	if !os.is_file(fixture.log_path) {
		return []
	}
	mut commands := [][]string{}
	mut current := []string{}
	for line in os.read_lines(fixture.log_path)! {
		if line == '__COMMAND__' {
			if current.len > 0 {
				commands << current
			}
			current = []
		} else {
			current << line
		}
	}
	if current.len > 0 {
		commands << current
	}
	return commands
}

fn curl_spec_capture_download(url string, meta download_strategy.DownloadMeta, resolved_url string, expand_deferred bool) ![]string {
	fixture := curl_spec_fixture('', '')!
	defer {
		fixture.close()
	}
	mut strategy := download_strategy.new_curl_download_strategy(url, 'foo', '1.2.3', meta)
	if expand_deferred {
		strategy.allow_deferred_environment_expansion()
	}
	strategy.curl_download(resolved_url, os.join_path(fixture.root, 'download'), none)!
	commands := fixture.commands()!
	if commands.len == 0 {
		return error('curl command was not recorded')
	}
	return commands.last()
}

fn curl_spec_run_fetch(url string, source_meta download_strategy.DownloadMeta, final_url string, failure_url string) !CurlSpecFetchResult {
	fixture := curl_spec_fixture(final_url, failure_url)!
	defer {
		fixture.close()
	}
	mut meta := source_meta
	meta.cache = os.join_path(fixture.root, 'cache')
	mut strategy := download_strategy.new_curl_download_strategy(url, 'foo', '1.2.3', meta)
	mut error_message := ''
	strategy.fetch(none) or { error_message = err.msg() }
	return CurlSpecFetchResult{
		commands: fixture.commands()!
		error_message: error_message
		cached_location: strategy.cached_location()
	}
}

fn curl_spec_has_pair(arguments []string, first string, second string) bool {
	if arguments.len < 2 {
		return false
	}
	for index in 0 .. arguments.len - 1 {
		if arguments[index] == first && arguments[index + 1] == second {
			return true
		}
	}
	return false
}

fn curl_spec_download_commands(commands [][]string) [][]string {
	return commands.filter('--head' !in it)
}

fn curl_spec_metadata(headers map[string]string) download_strategy.UrlMetadata {
	mut output := 'HTTP/2 200\r\n'
	mut keys := headers.keys()
	keys.sort()
	for key in keys {
		output += '${key}: ${headers[key]}\r\n'
	}
	output += '\r\n__BREW_EFFECTIVE_URL__:https://example.com/foo.tar.gz\n'
	return download_strategy.parse_curl_header_metadata('https://example.com/foo.tar.gz', output)
}

fn curl_spec_cache() string {
	return os.join_path(os.temp_dir(), 'brew-v-curl-strategy-spec-cache')
}

// Ruby subject `subject(:strategy) { described_class.new(url, name, version, **specs) }` at line 7.
pub fn ruby_curl_spec_l7_d1_strategy(specs download_strategy.DownloadMeta) download_strategy.CurlDownloadStrategy {
	return download_strategy.new_curl_download_strategy(ruby_curl_spec_l10_d3_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), specs)
}

// Ruby let `let(:name) { "foo" }` at line 9.
pub fn ruby_curl_spec_l9_d2_name() string {
	return 'foo'
}

// Ruby let `let(:url) { "https://example.com/foo.tar.gz" }` at line 10.
pub fn ruby_curl_spec_l10_d3_url() string {
	return 'https://example.com/foo.tar.gz'
}

// Ruby let `let(:version) { "1.2.3" }` at line 11.
pub fn ruby_curl_spec_l11_d4_version() string {
	return '1.2.3'
}

// Ruby let `let(:specs) { { user: "download:123456" } }` at line 12.
pub fn ruby_curl_spec_l12_d5_specs() download_strategy.DownloadMeta {
	return download_strategy.DownloadMeta{
		user: 'download:123456'
	}
}

// Ruby let `let(:artifact_domain) { nil }` at line 13.
pub fn ruby_curl_spec_l13_d6_artifact_domain() ?string {
	return none
}

// Ruby let `let(:headers) do` at line 14.
pub fn ruby_curl_spec_l14_d7_headers() map[string]string {
	return {
		'accept-ranges':  'bytes'
		'content-length': '37182'
	}
}

// Ruby it `it "parses the opts and sets the corresponding args" do` at line 26.
pub fn ruby_curl_spec_l26_d8_parses() bool {
	strategy := ruby_curl_spec_l7_d1_strategy(ruby_curl_spec_l12_d5_specs())
	return strategy.curl_args() == ['--user', 'download:123456']
}

// Ruby let `let(:specs) { { headers: [header] } }` at line 31.
pub fn ruby_curl_spec_l31_d9_specs() download_strategy.DownloadMeta {
	return download_strategy.DownloadMeta{
		headers: [ruby_curl_spec_l32_d10_header()]
	}
}

// Ruby let `let(:header) do` at line 32.
pub fn ruby_curl_spec_l32_d10_header() string {
	return curl_spec_deferred_header
}

// Ruby it `it "does not expand the placeholder outside Downloadable#fetch" do` at line 39.
pub fn ruby_curl_spec_l39_d11_does() bool {
	header := ruby_curl_spec_l32_d10_header()
	strategy := ruby_curl_spec_l7_d1_strategy(ruby_curl_spec_l31_d9_specs())
	arguments := strategy.curl_args()
	return header.contains('{{HOMEBREW_DEFERRED_ENV:') && header in arguments && curl_spec_has_pair(arguments, '--max-redirs', '0')
}

// Ruby let `let(:url) do` at line 47.
pub fn ruby_curl_spec_l47_d12_url() string {
	return 'https://example.com/foo.tar.gz?private_token={{HOMEBREW_DEFERRED_ENV:HOMEBREW_PRIVATE_TOKEN}}'
}

// Ruby it `it "does not expand the placeholder outside Downloadable#fetch" do` at line 56.
pub fn ruby_curl_spec_l56_d13_does() bool {
	url := ruby_curl_spec_l47_d12_url()
	arguments := curl_spec_capture_download(url, download_strategy.DownloadMeta{}, url, false) or { return false }
	return url.contains('{{HOMEBREW_DEFERRED_ENV:') && url in arguments
}

// Ruby it `it "calls curl with default arguments" do` at line 80.
pub fn ruby_curl_spec_l80_d14_calls() bool {
	url := ruby_curl_spec_l10_d3_url()
	arguments := curl_spec_capture_download(url, ruby_curl_spec_l12_d5_specs(), url, false) or { return false }
	return curl_spec_has_pair(arguments, '--remote-time', '--output') && curl_spec_has_pair(arguments, '--continue-at', '-') && curl_spec_has_pair(arguments, '--location', url)
}

// Ruby let `let(:specs) { { user_agent: "Mozilla/25.0.1" } }` at line 95.
pub fn ruby_curl_spec_l95_d15_specs() download_strategy.DownloadMeta {
	return download_strategy.DownloadMeta{
		user_agent: 'Mozilla/25.0.1'
	}
}

// Ruby it `it "adds the appropriate curl args" do` at line 97.
pub fn ruby_curl_spec_l97_d16_adds() bool {
	arguments := curl_spec_capture_download(ruby_curl_spec_l10_d3_url(), ruby_curl_spec_l95_d15_specs(), ruby_curl_spec_l10_d3_url(), false) or { return false }
	return curl_spec_has_pair(arguments, '--user-agent', 'Mozilla/25.0.1')
}

// Ruby alias_matcher `alias_matcher :a_string_matching, :match` at line 111.
pub fn ruby_curl_spec_l111_d17_a_string_matching(value string) bool {
	mut expression := regex.regex_opt('Mozilla.*Mac OS X 10_15_7.*AppleWebKit') or {
		return false
	}
	start, _ := expression.find(value)
	return start >= 0
}

// Ruby let `let(:specs) { { user_agent: :fake } }` at line 113.
pub fn ruby_curl_spec_l113_d18_specs() download_strategy.DownloadMeta {
	return download_strategy.DownloadMeta{
		user_agent: 'fake'
	}
}

// Ruby it `it "adds the appropriate curl args" do` at line 115.
pub fn ruby_curl_spec_l115_d19_adds() bool {
	arguments := curl_spec_capture_download(ruby_curl_spec_l10_d3_url(), ruby_curl_spec_l113_d18_specs(), ruby_curl_spec_l10_d3_url(), false) or { return false }
	index := arguments.index('--user-agent')
	return index >= 0 && index + 1 < arguments.len && ruby_curl_spec_l111_d17_a_string_matching(arguments[index + 1])
}

// Ruby let `let(:specs) do` at line 132.
pub fn ruby_curl_spec_l132_d20_specs() download_strategy.DownloadMeta {
	return download_strategy.DownloadMeta{
		cookies: {
			'coo': 'k/e'
			'mon': 'ster'
		}
	}
}

// Ruby it `it "adds the appropriate curl args and does not URL-encode the cookies" do` at line 141.
pub fn ruby_curl_spec_l141_d21_adds() bool {
	arguments := curl_spec_capture_download(ruby_curl_spec_l10_d3_url(), ruby_curl_spec_l132_d20_specs(), ruby_curl_spec_l10_d3_url(), false) or { return false }
	return curl_spec_has_pair(arguments, '-b', 'coo=k/e;mon=ster')
}

// Ruby let `let(:specs) { { referer: "https://somehost/also" } }` at line 155.
pub fn ruby_curl_spec_l155_d22_specs() download_strategy.DownloadMeta {
	return download_strategy.DownloadMeta{
		referer: 'https://somehost/also'
	}
}

// Ruby it `it "adds the appropriate curl args" do` at line 157.
pub fn ruby_curl_spec_l157_d23_adds() bool {
	arguments := curl_spec_capture_download(ruby_curl_spec_l10_d3_url(), ruby_curl_spec_l155_d22_specs(), ruby_curl_spec_l10_d3_url(), false) or { return false }
	return curl_spec_has_pair(arguments, '-e', 'https://somehost/also')
}

// Ruby alias_matcher `alias_matcher :a_string_matching, :match` at line 171.
pub fn ruby_curl_spec_l171_d24_a_string_matching(value string) bool {
	return ruby_curl_spec_l111_d17_a_string_matching(value)
}

// Ruby let `let(:specs) { { headers: ["foo", "bar"] } }` at line 173.
pub fn ruby_curl_spec_l173_d25_specs() download_strategy.DownloadMeta {
	return download_strategy.DownloadMeta{
		headers: ['foo', 'bar']
	}
}

// Ruby it `it "adds the appropriate curl args" do` at line 175.
pub fn ruby_curl_spec_l175_d26_adds() bool {
	arguments := curl_spec_capture_download(ruby_curl_spec_l10_d3_url(), ruby_curl_spec_l173_d25_specs(), ruby_curl_spec_l10_d3_url(), false) or { return false }
	return curl_spec_has_pair(arguments, '--header', 'foo') && curl_spec_has_pair(arguments, '--header', 'bar')
}

// Ruby let `let(:specs) { { headers: [header] } }` at line 191.
pub fn ruby_curl_spec_l191_d27_specs() download_strategy.DownloadMeta {
	return download_strategy.DownloadMeta{
		headers: [ruby_curl_spec_l192_d28_header()]
	}
}

// Ruby let `let(:header) do` at line 192.
pub fn ruby_curl_spec_l192_d28_header() string {
	return curl_spec_deferred_header
}

// Ruby it `it "keeps location handling but refuses redirects while sending caller-supplied headers" do` at line 203.
pub fn ruby_curl_spec_l203_d29_keeps() bool {
	os.setenv('HOMEBREW_PRIVATE_TOKEN', 'glpat-secret', true)
	defer {
		os.unsetenv('HOMEBREW_PRIVATE_TOKEN')
	}
	arguments := curl_spec_capture_download(ruby_curl_spec_l10_d3_url(), ruby_curl_spec_l191_d27_specs(), ruby_curl_spec_l10_d3_url(), true) or { return false }
	return curl_spec_has_pair(arguments, '--header', 'PRIVATE-TOKEN: glpat-secret') && '--location' in arguments && curl_spec_has_pair(arguments, '--max-redirs', '0')
}

// Ruby let `let(:specs) { { headers: ["PRIVATE-TOKEN: glpat-secret"] } }` at line 217.
pub fn ruby_curl_spec_l217_d30_specs() download_strategy.DownloadMeta {
	return download_strategy.DownloadMeta{
		headers: ['PRIVATE-TOKEN: glpat-secret']
	}
}

// Ruby it `it "does not forward caller-supplied headers to the new host" do` at line 224.
pub fn ruby_curl_spec_l224_d31_does() bool {
	result := curl_spec_run_fetch(ruby_curl_spec_l10_d3_url(), ruby_curl_spec_l217_d30_specs(), 'https://other.example.org/foo.tar.gz', '') or { return false }
	downloads := curl_spec_download_commands(result.commands)
	return result.error_message == '' && downloads.len == 1 && 'PRIVATE-TOKEN: glpat-secret' !in downloads[0]
}

// Ruby let `let(:artifact_domain) { "https://mirror.example.com/oci" }` at line 235.
pub fn ruby_curl_spec_l235_d32_artifact_domain() string {
	return 'https://mirror.example.com/oci'
}

// Ruby it `it "leaves the URL unchanged" do` at line 238.
pub fn ruby_curl_spec_l238_d33_leaves() bool {
	strategy := download_strategy.new_curl_download_strategy(ruby_curl_spec_l10_d3_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), download_strategy.DownloadMeta{
		artifact_domain: ruby_curl_spec_l235_d32_artifact_domain()
	})
	return strategy.candidate_urls() == [ruby_curl_spec_l10_d3_url()]
}

// Ruby let `let(:resource_path) { "v2/homebrew/core/spec/manifests/0.0" }` at line 252.
pub fn ruby_curl_spec_l252_d34_resource_path() string {
	return 'v2/homebrew/core/spec/manifests/0.0'
}

// Ruby let `let(:url) { "http://#{GitHubPackages::URL_DOMAIN}/#{resource_path}" }` at line 253.
pub fn ruby_curl_spec_l253_d35_url() string {
	return 'http://ghcr.io/${ruby_curl_spec_l252_d34_resource_path()}'
}

// Ruby let `let(:status) { instance_double(Process::Status, success?: true, exitstatus: 0) }` at line 254.
pub fn ruby_curl_spec_l254_d36_status() CurlSpecStatus {
	return CurlSpecStatus{
		success: true
		exit_status: 0
	}
}

// Ruby it `it "rewrites the URL correctly" do` at line 256.
pub fn ruby_curl_spec_l256_d37_rewrites() bool {
	strategy := download_strategy.new_curl_download_strategy(ruby_curl_spec_l253_d35_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), download_strategy.DownloadMeta{
		artifact_domain: ruby_curl_spec_l235_d32_artifact_domain()
	})
	return strategy.candidate_urls()[0] == '${ruby_curl_spec_l235_d32_artifact_domain()}/${ruby_curl_spec_l252_d34_resource_path()}'
}

// Ruby let `let(:resource_path) { "v2/homebrew/core/spec/manifests/0.0" }` at line 270.
pub fn ruby_curl_spec_l270_d38_resource_path() string {
	return 'v2/homebrew/core/spec/manifests/0.0'
}

// Ruby let `let(:url) { "https://#{GitHubPackages::URL_DOMAIN}/#{resource_path}" }` at line 271.
pub fn ruby_curl_spec_l271_d39_url() string {
	return 'https://ghcr.io/${ruby_curl_spec_l270_d38_resource_path()}'
}

// Ruby let `let(:status) { instance_double(Process::Status, success?: true, exitstatus: 0) }` at line 272.
pub fn ruby_curl_spec_l272_d40_status() CurlSpecStatus {
	return CurlSpecStatus{
		success: true
		exit_status: 0
	}
}

// Ruby it `it "rewrites the URL correctly" do` at line 274.
pub fn ruby_curl_spec_l274_d41_rewrites() bool {
	strategy := download_strategy.new_curl_download_strategy(ruby_curl_spec_l271_d39_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), download_strategy.DownloadMeta{
		artifact_domain: ruby_curl_spec_l235_d32_artifact_domain()
	})
	return strategy.candidate_urls()[0] == '${ruby_curl_spec_l235_d32_artifact_domain()}/${ruby_curl_spec_l270_d38_resource_path()}'
}

// Ruby let `let(:artifact_domain) { "https://mirror.example.com/v2/oci" }` at line 287.
pub fn ruby_curl_spec_l287_d42_artifact_domain() string {
	return 'https://mirror.example.com/v2/oci'
}

// Ruby it `it "does not duplicate the /v2/ API path" do` at line 289.
pub fn ruby_curl_spec_l289_d43_does() bool {
	strategy := download_strategy.new_curl_download_strategy(ruby_curl_spec_l271_d39_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), download_strategy.DownloadMeta{
		artifact_domain: ruby_curl_spec_l287_d42_artifact_domain()
	})
	return strategy.candidate_urls()[0] == 'https://mirror.example.com/v2/oci/homebrew/core/spec/manifests/0.0'
}

// Ruby let `let(:artifact_domain) { "https://mirror.example.com/v2/oci/" }` at line 302.
pub fn ruby_curl_spec_l302_d44_artifact_domain() string {
	return 'https://mirror.example.com/v2/oci/'
}

// Ruby it `it "does not duplicate the /v2/ API path" do` at line 304.
pub fn ruby_curl_spec_l304_d45_does() bool {
	strategy := download_strategy.new_curl_download_strategy(ruby_curl_spec_l271_d39_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), download_strategy.DownloadMeta{
		artifact_domain: ruby_curl_spec_l302_d44_artifact_domain()
	})
	return strategy.candidate_urls()[0] == 'https://mirror.example.com/v2/oci/homebrew/core/spec/manifests/0.0'
}

// Ruby let `let(:failed_status) { instance_double(Process::Status, success?: false, exitstatus: 6, termsig: nil) }` at line 318.
pub fn ruby_curl_spec_l318_d46_failed_status() CurlSpecStatus {
	return CurlSpecStatus{
		exit_status: 6
	}
}

// Ruby it `it "falls back to the original ghcr.io URL" do` at line 320.
pub fn ruby_curl_spec_l320_d47_falls() bool {
	url := ruby_curl_spec_l271_d39_url()
	artifact_url := 'https://mirror.example.com/v2/oci/homebrew/core/spec/manifests/0.0'
	result := curl_spec_run_fetch(url, download_strategy.DownloadMeta{
		artifact_domain: ruby_curl_spec_l287_d42_artifact_domain()
	}, '', artifact_url) or { return false }
	downloads := curl_spec_download_commands(result.commands)
	return result.error_message == '' && downloads.len == 2 && artifact_url in downloads[0] && url in downloads[1]
}

// Ruby let `let(:failed_status) { instance_double(Process::Status, success?: false, exitstatus: 6, termsig: nil) }` at line 343.
pub fn ruby_curl_spec_l343_d48_failed_status() CurlSpecStatus {
	return CurlSpecStatus{
		exit_status: 6
	}
}

// Ruby it `it "falls back to the original ghcr.io URL" do` at line 345.
pub fn ruby_curl_spec_l345_d49_falls() bool {
	url := ruby_curl_spec_l271_d39_url()
	artifact_url := '${ruby_curl_spec_l235_d32_artifact_domain()}/${ruby_curl_spec_l270_d38_resource_path()}'
	result := curl_spec_run_fetch(url, download_strategy.DownloadMeta{
		artifact_domain: ruby_curl_spec_l235_d32_artifact_domain()
	}, '', artifact_url) or { return false }
	downloads := curl_spec_download_commands(result.commands)
	return result.error_message == '' && downloads.len == 2 && artifact_url in downloads[0] && url in downloads[1]
}

// Ruby let `let(:failed_status) { instance_double(Process::Status, success?: false, exitstatus: 6, termsig: nil) }` at line 367.
pub fn ruby_curl_spec_l367_d50_failed_status() CurlSpecStatus {
	return CurlSpecStatus{
		exit_status: 6
	}
}

// Ruby it `it "does not fall back to the original URL" do` at line 373.
pub fn ruby_curl_spec_l373_d51_does() bool {
	url := ruby_curl_spec_l271_d39_url()
	artifact_url := '${ruby_curl_spec_l235_d32_artifact_domain()}/${ruby_curl_spec_l270_d38_resource_path()}'
	result := curl_spec_run_fetch(url, download_strategy.DownloadMeta{
		artifact_domain: ruby_curl_spec_l235_d32_artifact_domain()
		artifact_domain_no_fallback: true
	}, '', artifact_url) or { return false }
	downloads := curl_spec_download_commands(result.commands)
	return result.error_message.contains('Failed to download') && downloads.len == 1 && artifact_url in downloads[0] && url !in downloads[0]
}

// Ruby let `let(:headers) do` at line 391.
pub fn ruby_curl_spec_l391_d52_headers() map[string]string {
	return {
		'content-length': '1024'
	}
}

// Ruby it `it "returns the content-length value" do` at line 397.
pub fn ruby_curl_spec_l397_d53_returns() bool {
	metadata := curl_spec_metadata(ruby_curl_spec_l391_d52_headers())
	return metadata.has_file_size && metadata.file_size == 1024
}

// Ruby let `let(:headers) do` at line 404.
pub fn ruby_curl_spec_l404_d54_headers() map[string]string {
	return {
		'content-range': 'bytes 0-1023/1024'
	}
}

// Ruby it `it "returns the total size from content-range" do` at line 410.
pub fn ruby_curl_spec_l410_d55_returns() bool {
	metadata := curl_spec_metadata(ruby_curl_spec_l404_d54_headers())
	return metadata.has_file_size && metadata.file_size == 1024
}

// Ruby let `let(:headers) do` at line 417.
pub fn ruby_curl_spec_l417_d56_headers() map[string]string {
	return {
		'content-length': '0'
		'content-range':  'bytes 0-999/1000'
	}
}

// Ruby it `it "falls back to content-range" do` at line 424.
pub fn ruby_curl_spec_l424_d57_falls() bool {
	metadata := curl_spec_metadata(ruby_curl_spec_l417_d56_headers())
	return metadata.has_file_size && metadata.file_size == 1000
}

// Ruby let `let(:headers) do` at line 431.
pub fn ruby_curl_spec_l431_d58_headers() map[string]string {
	return {
		'content-range': 'bytes */67589'
	}
}

// Ruby it `it "extracts size from unsatisfied range format" do` at line 437.
pub fn ruby_curl_spec_l437_d59_extracts() bool {
	metadata := curl_spec_metadata(ruby_curl_spec_l431_d58_headers())
	return metadata.has_file_size && metadata.file_size == 67589
}

// Ruby let `let(:headers) do` at line 444.
pub fn ruby_curl_spec_l444_d60_headers() map[string]string {
	return {
		'content-range': 'bytes 0-1023/*'
	}
}

// Ruby it `it "raises when size cannot be determined" do` at line 450.
pub fn ruby_curl_spec_l450_d61_raises() bool {
	url := ruby_curl_spec_l10_d3_url()
	mut strategy := ruby_curl_spec_l7_d1_strategy(download_strategy.DownloadMeta{})
	strategy.resolved_info_cache[url] = curl_spec_metadata(ruby_curl_spec_l444_d60_headers())
	strategy.resolved_time_file_size(none) or {
		return err.msg().contains('could not be determined')
	}
	return false
}

// Ruby let `let(:headers) do` at line 458.
pub fn ruby_curl_spec_l458_d62_headers(invalid_value string) map[string]string {
	return {
		'content-range': invalid_value
	}
}

// Ruby it `it "raises when size cannot be parsed" do` at line 464.
pub fn ruby_curl_spec_l464_d63_raises() bool {
	url := ruby_curl_spec_l10_d3_url()
	for invalid_value in ['invalid-format', 'bytes 0-1023', 'bytes 0-1023/abc', 'bytes 0-1023/',
		''] {
		mut strategy := ruby_curl_spec_l7_d1_strategy(download_strategy.DownloadMeta{})
		strategy.resolved_info_cache[url] = curl_spec_metadata(ruby_curl_spec_l458_d62_headers(invalid_value))
		strategy.resolved_time_file_size(none) or { continue }
		return false
	}
	return true
}

// Ruby subject `subject(:cached_location) { strategy.cached_location }` at line 473.
pub fn ruby_curl_spec_l473_d64_cached_location() string {
	mut strategy := ruby_curl_spec_l7_d1_strategy(download_strategy.DownloadMeta{
		cache: curl_spec_cache()
	})
	return strategy.cached_location()
}

// Ruby it `it "falls back to the file name in the URL" do` at line 476.
pub fn ruby_curl_spec_l476_d65_falls() bool {
	expected := os.join_path(curl_spec_cache(), 'downloads', '3d1c0ae7da22be9d83fb1eb774df96b7c4da71d3cf07e1cb28555cf9a5e5af70--foo.tar.gz')
	return ruby_curl_spec_l473_d64_cached_location() == expected
}

// Ruby let `let(:url) { "https://example.com/foo.tar.gz/from/this/mirror" }` at line 484.
pub fn ruby_curl_spec_l484_d66_url() string {
	return 'https://example.com/foo.tar.gz/from/this/mirror'
}

// Ruby it `it "falls back to the file name in the URL" do` at line 486.
pub fn ruby_curl_spec_l486_d67_falls() bool {
	mut strategy := download_strategy.new_curl_download_strategy(ruby_curl_spec_l484_d66_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), download_strategy.DownloadMeta{
		cache: curl_spec_cache()
	})
	expected := os.join_path(curl_spec_cache(), 'downloads', '1ab61269ba52c83994510b1e28dd04167a2f2e8393a35a9c50c1f7d33fd8f619--foo.tar.gz')
	return strategy.cached_location() == expected
}

// Ruby let `let(:url) { "https://example.com/cask.dmg" }` at line 494.
pub fn ruby_curl_spec_l494_d68_url() string {
	return 'https://example.com/cask.dmg'
}

// Ruby it `it "falls back to the file extension in the URL" do` at line 496.
pub fn ruby_curl_spec_l496_d69_falls() bool {
	mut strategy := download_strategy.new_curl_download_strategy(ruby_curl_spec_l494_d68_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), download_strategy.DownloadMeta{
		cache: curl_spec_cache()
	})
	return os.file_ext(strategy.cached_location()) == '.dmg'
}

// Ruby let `let(:url) { "https://example.com/download?file=cask.zip&a=1" }` at line 502.
pub fn ruby_curl_spec_l502_d70_url() string {
	return 'https://example.com/download?file=cask.zip&a=1'
}

// Ruby it `it "falls back to the file extension in the URL" do` at line 504.
pub fn ruby_curl_spec_l504_d71_falls() bool {
	mut strategy := download_strategy.new_curl_download_strategy(ruby_curl_spec_l502_d70_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), download_strategy.DownloadMeta{
		cache: curl_spec_cache()
	})
	return os.file_ext(strategy.cached_location()) == '.zip'
}

// Ruby let `let(:url) { "https://example.com/dl?a=1&file=cask.zip&b=2" }` at line 510.
pub fn ruby_curl_spec_l510_d72_url() string {
	return 'https://example.com/dl?a=1&file=cask.zip&b=2'
}

// Ruby it `it "falls back to the file extension in the URL" do` at line 512.
pub fn ruby_curl_spec_l512_d73_falls() bool {
	mut strategy := download_strategy.new_curl_download_strategy(ruby_curl_spec_l510_d72_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), download_strategy.DownloadMeta{
		cache: curl_spec_cache()
	})
	return os.file_ext(strategy.cached_location()) == '.zip'
}

// Ruby let `let(:url) do` at line 518.
pub fn ruby_curl_spec_l518_d74_url() string {
	return ['https://node49152.ssl.fancycdn.example.com', '/fancycdn/node/49152/file/upload/download',
		'?cask_class=zf920df', '&cask_group=2348779087242312', '&cask_archive_file_name=cask.zip',
		'&signature=CGmDulxL8pmutKTlCleNTUY%2FyO9Xyl5u9yVZUE0',
		'uWrjadjuz67Jp7zx3H7NEOhSyOhu8nzicEHRBjr3uSoOJzwkLC8L',
		'BLKnz%2B2X%2Biq5m6IdwSVFcLp2Q1Hr2kR7ETn3rF1DIq5o0lHC',
		'yzMmyNe5giEKJNW8WF0KXriULhzLTWLSA3ZTLCIofAdRiiGje1kN',
		'YY3C0SBqymQB8CG3ONn5kj7CIGbxrDOq5xI2ZSJdIyPysSX7SLvE',
		'DBw2KdR24q9t1wfjS9LUzelf5TWk6ojj8p9%2FHjl%2Fi%2FVCXN',
		'N4o1mW%2FMayy2tTY1qcC%2FTmqI1ulZS8SNuaSgr9Iys9oDF1%2', 'BPK%2B4Sg=='].join('')
}

// Ruby it `it "falls back to the file extension in the URL" do` at line 536.
pub fn ruby_curl_spec_l536_d75_falls() bool {
	mut strategy := download_strategy.new_curl_download_strategy(ruby_curl_spec_l518_d74_url(), ruby_curl_spec_l9_d2_name(), ruby_curl_spec_l11_d4_version(), download_strategy.DownloadMeta{
		cache: curl_spec_cache()
	})
	location := strategy.cached_location()
	return os.file_ext(location) == '.zip' && location.len > 0 && location.len <= 255
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe CurlDownloadStrategy do
// 7:   subject(:strategy) { described_class.new(url, name, version, **specs) }
// 8:
// 9:   let(:name) { "foo" }
// 10:   let(:url) { "https://example.com/foo.tar.gz" }
// 11:   let(:version) { "1.2.3" }
// 12:   let(:specs) { { user: "download:123456" } }
// 13:   let(:artifact_domain) { nil }
// 14:   let(:headers) do
// 15:     {
// 16:       "accept-ranges"  => "bytes",
// 17:       "content-length" => "37182",
// 18:     }
// 19:   end
// 20:
// 21:   before do
// 22:     allow(strategy).to receive(:curl_headers).with(any_args)
// 23:                                              .and_return({ responses: [{ headers: }] })
// 24:   end
// 25:
// 26:   it "parses the opts and sets the corresponding args" do
// 27:     expect(strategy._curl_args).to eq(["--user", "download:123456"])
// 28:   end
// 29:
// 30:   context "with a deferred HOMEBREW_ secret in a header" do
// 31:     let(:specs) { { headers: [header] } }
// 32:     let(:header) do
// 33:       ENV["HOMEBREW_PRIVATE_TOKEN"] = "glpat-secret"
// 34:       ENV.clear_sensitive_environment_for_eval! { "PRIVATE-TOKEN: #{ENV.fetch("HOMEBREW_PRIVATE_TOKEN", nil)}" }
// 35:     end
// 36:
// 37:     after { ENV.delete("HOMEBREW_PRIVATE_TOKEN") }
// 38:
// 39:     it "does not expand the placeholder outside Downloadable#fetch" do
// 40:       expect(header).to include(EnvSensitive::DEFERRED_PLACEHOLDER_PREFIX)
// 41:       expect(strategy._curl_args).to include(header)
// 42:       expect(strategy._curl_args).to include("--max-redirs", "0")
// 43:     end
// 44:   end
// 45:
// 46:   context "with a deferred HOMEBREW_ secret in the URL" do
// 47:     let(:url) do
// 48:       ENV["HOMEBREW_PRIVATE_TOKEN"] = "glpat-secret"
// 49:       ENV.clear_sensitive_environment_for_eval! do
// 50:         "https://example.com/foo.tar.gz?private_token=#{ENV.fetch("HOMEBREW_PRIVATE_TOKEN", nil)}"
// 51:       end
// 52:     end
// 53:
// 54:     after { ENV.delete("HOMEBREW_PRIVATE_TOKEN") }
// 55:
// 56:     it "does not expand the placeholder outside Downloadable#fetch" do
// 57:       expect(url).to include(EnvSensitive::DEFERRED_PLACEHOLDER_PREFIX)
// 58:       expect(strategy).to receive(:system_command)
// 59:         .with(
// 60:           /curl/,
// 61:           hash_including(args: array_including(url)),
// 62:         )
// 63:         .at_least(:once)
// 64:         .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 65:
// 66:       strategy.temporary_path.dirname.mkpath
// 67:       FileUtils.touch strategy.temporary_path
// 68:       strategy.fetch
// 69:     end
// 70:   end
// 71:
// 72:   describe "#fetch" do
// 73:     before do
// 74:       allow(Homebrew::EnvConfig).to receive(:artifact_domain).and_return(artifact_domain)
// 75:
// 76:       strategy.temporary_path.dirname.mkpath
// 77:       FileUtils.touch strategy.temporary_path
// 78:     end
// 79:
// 80:     it "calls curl with default arguments" do
// 81:       expect(strategy).to receive(:curl).with(
// 82:         "--remote-time",
// 83:         "--output", an_instance_of(String),
// 84:         # example.com supports partial requests.
// 85:         "--continue-at", "-",
// 86:         "--location",
// 87:         url,
// 88:         an_instance_of(Hash)
// 89:       )
// 90:
// 91:       strategy.fetch
// 92:     end
// 93:
// 94:     context "with an explicit user agent" do
// 95:       let(:specs) { { user_agent: "Mozilla/25.0.1" } }
// 96:
// 97:       it "adds the appropriate curl args" do
// 98:         expect(strategy).to receive(:system_command)
// 99:           .with(
// 100:             /curl/,
// 101:             hash_including(args: array_including_cons("--user-agent", "Mozilla/25.0.1")),
// 102:           )
// 103:           .at_least(:once)
// 104:           .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 105:
// 106:         strategy.fetch
// 107:       end
// 108:     end
// 109:
// 110:     context "with a generalized fake user agent" do
// 111:       alias_matcher :a_string_matching, :match
// 112:
// 113:       let(:specs) { { user_agent: :fake } }
// 114:
// 115:       it "adds the appropriate curl args" do
// 116:         expect(strategy).to receive(:system_command)
// 117:           .with(
// 118:             /curl/,
// 119:             hash_including(args: array_including_cons(
// 120:               "--user-agent",
// 121:               a_string_matching(/Mozilla.*Mac OS X 10_15_7.*AppleWebKit/),
// 122:             )),
// 123:           )
// 124:           .at_least(:once)
// 125:           .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 126:
// 127:         strategy.fetch
// 128:       end
// 129:     end
// 130:
// 131:     context "with cookies set" do
// 132:       let(:specs) do
// 133:         {
// 134:           cookies: {
// 135:             coo: "k/e",
// 136:             mon: "ster",
// 137:           },
// 138:         }
// 139:       end
// 140:
// 141:       it "adds the appropriate curl args and does not URL-encode the cookies" do
// 142:         expect(strategy).to receive(:system_command)
// 143:           .with(
// 144:             /curl/,
// 145:             hash_including(args: array_including_cons("-b", "coo=k/e;mon=ster")),
// 146:           )
// 147:           .at_least(:once)
// 148:           .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 149:
// 150:         strategy.fetch
// 151:       end
// 152:     end
// 153:
// 154:     context "with referer set" do
// 155:       let(:specs) { { referer: "https://somehost/also" } }
// 156:
// 157:       it "adds the appropriate curl args" do
// 158:         expect(strategy).to receive(:system_command)
// 159:           .with(
// 160:             /curl/,
// 161:             hash_including(args: array_including_cons("-e", "https://somehost/also")),
// 162:           )
// 163:           .at_least(:once)
// 164:           .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 165:
// 166:         strategy.fetch
// 167:       end
// 168:     end
// 169:
// 170:     context "with headers set" do
// 171:       alias_matcher :a_string_matching, :match
// 172:
// 173:       let(:specs) { { headers: ["foo", "bar"] } }
// 174:
// 175:       it "adds the appropriate curl args" do
// 176:         expect(strategy).to receive(:system_command)
// 177:           .with(
// 178:             /curl/,
// 179:             hash_including(
// 180:               args: array_including_cons("--header", "foo").and(array_including_cons("--header", "bar")),
// 181:             ),
// 182:           )
// 183:           .at_least(:once)
// 184:           .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 185:
// 186:         strategy.fetch
// 187:       end
// 188:     end
// 189:
// 190:     context "with a deferred HOMEBREW_ secret in a header" do
// 191:       let(:specs) { { headers: [header] } }
// 192:       let(:header) do
// 193:         ENV["HOMEBREW_PRIVATE_TOKEN"] = "glpat-secret"
// 194:         ENV.clear_sensitive_environment_for_eval! { "PRIVATE-TOKEN: #{ENV.fetch("HOMEBREW_PRIVATE_TOKEN", nil)}" }
// 195:       end
// 196:
// 197:       before do
// 198:         strategy.allow_deferred_environment_expansion!
// 199:       end
// 200:
// 201:       after { ENV.delete("HOMEBREW_PRIVATE_TOKEN") }
// 202:
// 203:       it "keeps location handling but refuses redirects while sending caller-supplied headers" do
// 204:         expect(strategy).to receive(:system_command) do |_command, options|
// 205:           if options[:args].include?("PRIVATE-TOKEN: glpat-secret")
// 206:             expect(options[:args]).to include("--location", "--max-redirs", "0")
// 207:           end
// 208:
// 209:           instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil)
// 210:         end.at_least(:once)
// 211:
// 212:         strategy.fetch
// 213:       end
// 214:     end
// 215:
// 216:     context "when a redirect crosses to another host" do
// 217:       let(:specs) { { headers: ["PRIVATE-TOKEN: glpat-secret"] } }
// 218:
// 219:       before do
// 220:         allow(strategy).to receive(:resolve_url_basename_time_file_size)
// 221:           .and_return(["https://other.example.org/foo.tar.gz", "foo.tar.gz", nil, 0, nil, true])
// 222:       end
// 223:
// 224:       it "does not forward caller-supplied headers to the new host" do
// 225:         expect(strategy).to receive(:system_command) do |_command, options|
// 226:           expect(options[:args]).not_to include("PRIVATE-TOKEN: glpat-secret")
// 227:           instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil)
// 228:         end.at_least(:once)
// 229:
// 230:         strategy.fetch
// 231:       end
// 232:     end
// 233:
// 234:     context "with artifact_domain set" do
// 235:       let(:artifact_domain) { "https://mirror.example.com/oci" }
// 236:
// 237:       context "with an asset hosted under example.com" do
// 238:         it "leaves the URL unchanged" do
// 239:           expect(strategy).to receive(:system_command)
// 240:             .with(
// 241:               /curl/,
// 242:               hash_including(args: array_including_cons(url)),
// 243:             )
// 244:             .at_least(:once)
// 245:             .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 246:
// 247:           strategy.fetch
// 248:         end
// 249:       end
// 250:
// 251:       context "with an asset hosted under #{GitHubPackages::URL_DOMAIN} (HTTP)" do
// 252:         let(:resource_path) { "v2/homebrew/core/spec/manifests/0.0" }
// 253:         let(:url) { "http://#{GitHubPackages::URL_DOMAIN}/#{resource_path}" }
// 254:         let(:status) { instance_double(Process::Status, success?: true, exitstatus: 0) }
// 255:
// 256:         it "rewrites the URL correctly" do
// 257:           expect(strategy).to receive(:system_command)
// 258:             .with(
// 259:               /curl/,
// 260:               hash_including(args: array_including_cons("#{artifact_domain}/#{resource_path}")),
// 261:             )
// 262:             .at_least(:once)
// 263:             .and_return(SystemCommand::Result.new(["curl"], [[:stdout, ""]], status, secrets: []))
// 264:
// 265:           strategy.fetch
// 266:         end
// 267:       end
// 268:
// 269:       context "with an asset hosted under #{GitHubPackages::URL_DOMAIN} (HTTPS)" do
// 270:         let(:resource_path) { "v2/homebrew/core/spec/manifests/0.0" }
// 271:         let(:url) { "https://#{GitHubPackages::URL_DOMAIN}/#{resource_path}" }
// 272:         let(:status) { instance_double(Process::Status, success?: true, exitstatus: 0) }
// 273:
// 274:         it "rewrites the URL correctly" do
// 275:           expect(strategy).to receive(:system_command)
// 276:             .with(
// 277:               /curl/,
// 278:               hash_including(args: array_including_cons("#{artifact_domain}/#{resource_path}")),
// 279:             )
// 280:             .at_least(:once)
// 281:             .and_return(SystemCommand::Result.new(["curl"], [[:stdout, ""]], status, secrets: []))
// 282:
// 283:           strategy.fetch
// 284:         end
// 285:
// 286:         context "when the artifact domain already contains a /v2 path" do
// 287:           let(:artifact_domain) { "https://mirror.example.com/v2/oci" }
// 288:
// 289:           it "does not duplicate the /v2/ API path" do
// 290:             expect(strategy).to receive(:system_command)
// 291:               .with(
// 292:                 /curl/,
// 293:                 hash_including(args: array_including_cons("https://mirror.example.com/v2/oci/homebrew/core/spec/manifests/0.0")),
// 294:               )
// 295:               .at_least(:once)
// 296:               .and_return(SystemCommand::Result.new(["curl"], [[:stdout, ""]], status, secrets: []))
// 297:
// 298:             strategy.fetch
// 299:           end
// 300:
// 301:           context "with a trailing slash" do
// 302:             let(:artifact_domain) { "https://mirror.example.com/v2/oci/" }
// 303:
// 304:             it "does not duplicate the /v2/ API path" do
// 305:               expect(strategy).to receive(:system_command)
// 306:                 .with(
// 307:                   /curl/,
// 308:                   hash_including(args: array_including_cons("https://mirror.example.com/v2/oci/homebrew/core/spec/manifests/0.0")),
// 309:                 )
// 310:                 .at_least(:once)
// 311:                 .and_return(SystemCommand::Result.new(["curl"], [[:stdout, ""]], status, secrets: []))
// 312:
// 313:               strategy.fetch
// 314:             end
// 315:           end
// 316:
// 317:           context "when the artifact domain is unreachable" do
// 318:             let(:failed_status) { instance_double(Process::Status, success?: false, exitstatus: 6, termsig: nil) }
// 319:
// 320:             it "falls back to the original ghcr.io URL" do
// 321:               artifact_url = "https://mirror.example.com/v2/oci/homebrew/core/spec/manifests/0.0"
// 322:
// 323:               # First call: artifact domain URL fails
// 324:               expect(strategy).to receive(:_fetch)
// 325:                 .with(url: artifact_url, resolved_url: artifact_url,
// 326:                       timeout: anything)
// 327:                 .once
// 328:                 .and_raise(ErrorDuringExecution.new(["curl", artifact_url], status: failed_status))
// 329:
// 330:               # Second call: original ghcr.io URL succeeds
// 331:               expect(strategy).to receive(:_fetch)
// 332:                 .with(url: url, resolved_url: url,
// 333:                       timeout: anything)
// 334:                 .once
// 335:                 .and_return(nil)
// 336:
// 337:               strategy.fetch
// 338:             end
// 339:           end
// 340:         end
// 341:
// 342:         context "when the artifact domain is unreachable" do
// 343:           let(:failed_status) { instance_double(Process::Status, success?: false, exitstatus: 6, termsig: nil) }
// 344:
// 345:           it "falls back to the original ghcr.io URL" do
// 346:             artifact_url = "#{artifact_domain}/#{resource_path}"
// 347:
// 348:             # First call: artifact domain URL fails
// 349:             expect(strategy).to receive(:_fetch)
// 350:               .with(url: artifact_url, resolved_url: artifact_url,
// 351:                     timeout: anything)
// 352:               .once
// 353:               .and_raise(ErrorDuringExecution.new(["curl", artifact_url], status: failed_status))
// 354:
// 355:             # Second call: original ghcr.io URL succeeds
// 356:             expect(strategy).to receive(:_fetch)
// 357:               .with(url: url, resolved_url: url,
// 358:                     timeout: anything)
// 359:               .once
// 360:               .and_return(nil)
// 361:
// 362:             strategy.fetch
// 363:           end
// 364:         end
// 365:
// 366:         context "when artifact_domain_no_fallback is set" do
// 367:           let(:failed_status) { instance_double(Process::Status, success?: false, exitstatus: 6, termsig: nil) }
// 368:
// 369:           before do
// 370:             allow(Homebrew::EnvConfig).to receive(:artifact_domain_no_fallback?).and_return(true)
// 371:           end
// 372:
// 373:           it "does not fall back to the original URL" do
// 374:             artifact_url = "#{artifact_domain}/#{resource_path}"
// 375:
// 376:             expect(strategy).to receive(:_fetch)
// 377:               .with(url: artifact_url, resolved_url: artifact_url,
// 378:                     timeout: anything)
// 379:               .once
// 380:               .and_raise(ErrorDuringExecution.new(["curl", artifact_url], status: failed_status))
// 381:
// 382:             expect { strategy.fetch }.to raise_error(CurlDownloadStrategyError)
// 383:           end
// 384:         end
// 385:       end
// 386:     end
// 387:   end
// 388:
// 389:   describe "#resolved_time_file_size" do
// 390:     context "when content-length header is present" do
// 391:       let(:headers) do
// 392:         {
// 393:           "content-length" => "1024",
// 394:         }
// 395:       end
// 396:
// 397:       it "returns the content-length value" do
// 398:         _, file_size = strategy.resolved_time_file_size
// 399:         expect(file_size).to eq(1024)
// 400:       end
// 401:     end
// 402:
// 403:     context "when only content-range header is present" do
// 404:       let(:headers) do
// 405:         {
// 406:           "content-range" => "bytes 0-1023/1024",
// 407:         }
// 408:       end
// 409:
// 410:       it "returns the total size from content-range" do
// 411:         _, file_size = strategy.resolved_time_file_size
// 412:         expect(file_size).to eq(1024)
// 413:       end
// 414:     end
// 415:
// 416:     context "when content-length is zero and content-range is present" do
// 417:       let(:headers) do
// 418:         {
// 419:           "content-length" => "0",
// 420:           "content-range"  => "bytes 0-999/1000",
// 421:         }
// 422:       end
// 423:
// 424:       it "falls back to content-range" do
// 425:         _, file_size = strategy.resolved_time_file_size
// 426:         expect(file_size).to eq(1000)
// 427:       end
// 428:     end
// 429:
// 430:     context "when content-range has unsatisfied range format (416 response)" do
// 431:       let(:headers) do
// 432:         {
// 433:           "content-range" => "bytes */67589",
// 434:         }
// 435:       end
// 436:
// 437:       it "extracts size from unsatisfied range format" do
// 438:         _, file_size = strategy.resolved_time_file_size
// 439:         expect(file_size).to eq(67589)
// 440:       end
// 441:     end
// 442:
// 443:     context "when content-range has unknown size" do
// 444:       let(:headers) do
// 445:         {
// 446:           "content-range" => "bytes 0-1023/*",
// 447:         }
// 448:       end
// 449:
// 450:       it "raises when size cannot be determined" do
// 451:         expect { strategy.resolved_time_file_size }.to raise_error(TypeError)
// 452:       end
// 453:     end
// 454:
// 455:     context "when content-range has invalid format" do
// 456:       test_each(["invalid-format", "bytes 0-1023", "bytes 0-1023/abc", "bytes 0-1023/", ""]) do |invalid_value|
// 457:         context "with value #{invalid_value.inspect}" do
// 458:           let(:headers) do
// 459:             {
// 460:               "content-range" => invalid_value,
// 461:             }
// 462:           end
// 463:
// 464:           it "raises when size cannot be parsed" do
// 465:             expect { strategy.resolved_time_file_size }.to raise_error(TypeError)
// 466:           end
// 467:         end
// 468:       end
// 469:     end
// 470:   end
// 471:
// 472:   describe "#cached_location" do
// 473:     subject(:cached_location) { strategy.cached_location }
// 474:
// 475:     context "when URL ends with file" do
// 476:       it "falls back to the file name in the URL" do
// 477:         expect(cached_location).to eq(
// 478:           HOMEBREW_CACHE/"downloads/3d1c0ae7da22be9d83fb1eb774df96b7c4da71d3cf07e1cb28555cf9a5e5af70--foo.tar.gz",
// 479:         )
// 480:       end
// 481:     end
// 482:
// 483:     context "when URL file is in middle" do
// 484:       let(:url) { "https://example.com/foo.tar.gz/from/this/mirror" }
// 485:
// 486:       it "falls back to the file name in the URL" do
// 487:         expect(cached_location).to eq(
// 488:           HOMEBREW_CACHE/"downloads/1ab61269ba52c83994510b1e28dd04167a2f2e8393a35a9c50c1f7d33fd8f619--foo.tar.gz",
// 489:         )
// 490:       end
// 491:     end
// 492:
// 493:     context "with a file name trailing the URL path" do
// 494:       let(:url) { "https://example.com/cask.dmg" }
// 495:
// 496:       it "falls back to the file extension in the URL" do
// 497:         expect(cached_location.extname).to eq(".dmg")
// 498:       end
// 499:     end
// 500:
// 501:     context "with a file name trailing the first query parameter" do
// 502:       let(:url) { "https://example.com/download?file=cask.zip&a=1" }
// 503:
// 504:       it "falls back to the file extension in the URL" do
// 505:         expect(cached_location.extname).to eq(".zip")
// 506:       end
// 507:     end
// 508:
// 509:     context "with a file name trailing the second query parameter" do
// 510:       let(:url) { "https://example.com/dl?a=1&file=cask.zip&b=2" }
// 511:
// 512:       it "falls back to the file extension in the URL" do
// 513:         expect(cached_location.extname).to eq(".zip")
// 514:       end
// 515:     end
// 516:
// 517:     context "with an unusually long query string" do
// 518:       let(:url) do
// 519:         [
// 520:           "https://node49152.ssl.fancycdn.example.com",
// 521:           "/fancycdn/node/49152/file/upload/download",
// 522:           "?cask_class=zf920df",
// 523:           "&cask_group=2348779087242312",
// 524:           "&cask_archive_file_name=cask.zip",
// 525:           "&signature=CGmDulxL8pmutKTlCleNTUY%2FyO9Xyl5u9yVZUE0",
// 526:           "uWrjadjuz67Jp7zx3H7NEOhSyOhu8nzicEHRBjr3uSoOJzwkLC8L",
// 527:           "BLKnz%2B2X%2Biq5m6IdwSVFcLp2Q1Hr2kR7ETn3rF1DIq5o0lHC",
// 528:           "yzMmyNe5giEKJNW8WF0KXriULhzLTWLSA3ZTLCIofAdRiiGje1kN",
// 529:           "YY3C0SBqymQB8CG3ONn5kj7CIGbxrDOq5xI2ZSJdIyPysSX7SLvE",
// 530:           "DBw2KdR24q9t1wfjS9LUzelf5TWk6ojj8p9%2FHjl%2Fi%2FVCXN",
// 531:           "N4o1mW%2FMayy2tTY1qcC%2FTmqI1ulZS8SNuaSgr9Iys9oDF1%2",
// 532:           "BPK%2B4Sg==",
// 533:         ].join
// 534:       end
// 535:
// 536:       it "falls back to the file extension in the URL" do
// 537:         expect(cached_location.extname).to eq(".zip")
// 538:         expect(cached_location.to_path.length).to be_between(0, 255)
// 539:       end
// 540:     end
// 541:   end
// 542: end
