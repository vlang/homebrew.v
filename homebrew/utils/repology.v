module utils

import ruby
import net.urllib

// Translated from Homebrew/brew `utils/repology.rb`.

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
