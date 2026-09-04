module utils

import ruby
import net.urllib

// Translated from Homebrew/brew `utils/repology.rb`.
// The original source is retained below until every stub has a typed V body.

pub const repology_api_base = 'https://repology.org/api/v1'
pub const repology_homebrew_core = 'homebrew'
pub const repology_homebrew_cask = 'homebrew_casks'

pub struct RepologyCurlResult {
pub:
	success     bool
	stdout      string
	stderr      string
	exit_status int
}

pub struct RepologyQueryResult {
pub:
	url               string
	arguments         []string
	use_homebrew_curl bool
	data              ruby.Value
	error_output      []string
}

pub struct RepologyRepositoryVersion {
pub:
	status  string
	version string
}

fn repology_url_encode(value string) string {
	return urllib.query_escape(value).replace('+', '%20')
}

pub fn repology_query_api(last_package string, repository string, tls13_supported bool,
	response RepologyCurlResult, developer bool) !RepologyQueryResult {
	cursor := if last_package.len > 0 { '${repology_url_encode(last_package)}/' } else { '' }
	url := '${repology_api_base}/projects/${cursor}?inrepo=${repository}&outdated=1'
	data := ruby.parse_json_value(response.stdout) or {
		message := if developer && response.stderr.len > 0 {
			'${response.stderr}\n${err.msg()}'
		} else {
			err.msg()
		}
		return error(message)
	}
	return RepologyQueryResult{
		url: url
		arguments: ['--fail', '--silent', url]
		use_homebrew_curl: !tls13_supported
		data: data
	}
}

pub fn repology_single_package_query(name string, repository string, tls13_supported bool,
	response RepologyCurlResult, developer bool) RepologyQueryResult {
	_ = repository
	url := '${repology_api_base}/project/${repology_url_encode(name)}'
	arguments := ['--fail', '--location', '--silent', url]
	if !response.success {
		message := 'RuntimeError: curl exit ${response.exit_status}: ${response.stderr.trim_space()}'
		return RepologyQueryResult{
			url: url
			arguments: arguments
			use_homebrew_curl: !tls13_supported
			error_output: [response.stderr, message].filter(it.len > 0)
		}
	}
	data := ruby.parse_json_value(response.stdout) or {
		message := 'JsonError: ${err.msg()}'
		return RepologyQueryResult{
			url: url
			arguments: arguments
			use_homebrew_curl: !tls13_supported
			error_output: [response.stderr, message].filter(it.len > 0)
		}
	}
	_ = developer
	return RepologyQueryResult{
		url: url
		arguments: arguments
		use_homebrew_curl: !tls13_supported
		data: ruby.map_value({
			name: data
		})
	}
}

pub fn repology_latest_version(repositories []RepologyRepositoryVersion) string {
	if repositories.any(it.status == 'unique') {
		return 'present only in Homebrew'
	}
	for repository in repositories {
		if repository.status == 'newest' {
			return repository.version
		}
	}
	return 'no latest version'
}

fn repology_curl_result_from_value(value ruby.Value) RepologyCurlResult {
	return RepologyCurlResult{
		success: (value.map_data['success'] or { ruby.bool_value(false) }).as_bool() or { false }
		stdout: (value.map_data['stdout'] or { ruby.string_value('') }).as_string()
		stderr: (value.map_data['stderr'] or { ruby.string_value('') }).as_string()
		exit_status: int((value.map_data['exit_status'] or { ruby.int_value(0) }).as_int() or { 0 })
	}
}

// Ruby method `self.query_api(last_package_in_response = "", repository:)` at line 17.
pub fn ruby_repology_l17_d1_self_query_api(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'cursor, repository and curl result are required')
	}
	tls := args.len > 3 && (args[3].as_bool() or { false })
	developer := args.len > 4 && (args[4].as_bool() or { false })
	return repology_query_api(args[0].as_string(), args[1].as_string(), tls,
		repology_curl_result_from_value(args[2]), developer) or {
		return ruby.object_value('Error', err.msg())
	}.data
}

// Ruby method `self.single_package_query(name, repository:)` at line 37.
pub fn ruby_repology_l37_d2_self_single_package_query(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'name, repository and curl result are required')
	}
	tls := args.len > 3 && (args[3].as_bool() or { false })
	developer := args.len > 4 && (args[4].as_bool() or { false })
	result := repology_single_package_query(args[0].as_string(), args[1].as_string(), tls,
		repology_curl_result_from_value(args[2]), developer)
	return if result.error_output.len > 0 { ruby.object_value('NilClass', '') } else { result.data }
}

// Ruby method `self.latest_version(repositories)` at line 61.
pub fn ruby_repology_l61_d3_self_latest_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'repositories are required')
	}
	mut repositories := []RepologyRepositoryVersion{}
	for entry in args[0].as_array() or { []ruby.Value{} } {
		repositories << RepologyRepositoryVersion{
			status: (entry.map_data['status'] or { ruby.string_value('') }).as_string()
			version: (entry.map_data['version'] or { ruby.string_value('') }).as_string()
		}
	}
	result := repology_latest_version(repositories)
	return if result in ['present only in Homebrew', 'no latest version'] {
		ruby.string_value(result)
	} else {
		ruby.object_value('Version', result)
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "erb"
// 5: require "utils/curl"
// 6: require "utils/output"
// 7:
// 8: # Repology API client.
// 9: module Repology
// 10:   extend Utils::Output::Mixin
// 11:
// 12:   API_BASE = "https://repology.org/api/v1"
// 13:   HOMEBREW_CORE = "homebrew"
// 14:   HOMEBREW_CASK = "homebrew_casks"
// 15:
// 16:   sig { params(last_package_in_response: T.nilable(String), repository: String).returns(T::Hash[String, T.untyped]) }
// 17:   def self.query_api(last_package_in_response = "", repository:)
// 18:     cursor = last_package_in_response.present? ? "#{ERB::Util.url_encode(last_package_in_response)}/" : ""
// 19:     url = "#{API_BASE}/projects/#{cursor}?inrepo=#{repository}&outdated=1"
// 20:
// 21:     result = Utils::Curl.curl_output(
// 22:       "--fail", "--silent", url,
// 23:       use_homebrew_curl: !Utils::Curl.curl_supports_tls13?
// 24:     )
// 25:     JSON.parse(result.stdout)
// 26:   rescue
// 27:     if Homebrew::EnvConfig.developer?
// 28:       $stderr.puts result&.stderr
// 29:     else
// 30:       odebug result&.stderr.to_s
// 31:     end
// 32:
// 33:     raise
// 34:   end
// 35:
// 36:   sig { params(name: String, repository: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 37:   def self.single_package_query(name, repository:)
// 38:     url = "#{API_BASE}/project/#{ERB::Util.url_encode(name)}"
// 39:
// 40:     result = Utils::Curl.curl_output(
// 41:       "--fail", "--location", "--silent", url,
// 42:       use_homebrew_curl: !Utils::Curl.curl_supports_tls13?
// 43:     )
// 44:     raise "curl exit #{result.exit_status}: #{result.stderr.strip}" unless result.success?
// 45:
// 46:     data = JSON.parse(result.stdout)
// 47:     { name => data }
// 48:   rescue => e
// 49:     require "utils/backtrace"
// 50:     error_output = [result&.stderr, "#{e.class}: #{e}", Utils::Backtrace.clean(e)].compact
// 51:     if Homebrew::EnvConfig.developer?
// 52:       $stderr.puts(*error_output)
// 53:     else
// 54:       odebug(*error_output)
// 55:     end
// 56:
// 57:     nil
// 58:   end
// 59:
// 60:   sig { params(repositories: T::Array[String]).returns(T.any(String, Version)) }
// 61:   def self.latest_version(repositories)
// 62:     # The status is "unique" when the package is present only in Homebrew, so
// 63:     # Repology has no way of knowing if the package is up-to-date.
// 64:     is_unique = repositories.find do |repo|
// 65:       repo["status"] == "unique"
// 66:     end.present?
// 67:
// 68:     return "present only in Homebrew" if is_unique
// 69:
// 70:     latest_version = repositories.find do |repo|
// 71:       repo["status"] == "newest"
// 72:     end
// 73:
// 74:     # Repology cannot identify "newest" versions for packages without a version
// 75:     # scheme
// 76:     return "no latest version" if latest_version.blank?
// 77:
// 78:     Version.new(T.must(latest_version["version"]))
// 79:   end
// 80: end
