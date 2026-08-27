module utils

import brew_runtime

// Translated from Homebrew/brew `utils/repology.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.query_api(last_package_in_response = "", repository:)` at line 17.
pub fn ruby_repology_l17_d1_self_query_api(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.query_api', ...args)
}

// Ruby method `self.single_package_query(name, repository:)` at line 37.
pub fn ruby_repology_l37_d2_self_single_package_query(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.single_package_query', ...args)
}

// Ruby method `self.latest_version(repositories)` at line 61.
pub fn ruby_repology_l61_d3_self_latest_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.latest_version', ...args)
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
