module download_strategy

import brew_runtime

// Translated from Homebrew/brew `download_strategy/curl_apache_mirror_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `mirrors` at line 9.
pub fn ruby_curl_apache_mirror_download_strategy_l9_d1_mirrors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mirrors', ...args)
}

// Ruby method `combined_mirrors` at line 16.
pub fn ruby_curl_apache_mirror_download_strategy_l16_d2_combined_mirrors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('combined_mirrors', ...args)
}

// Ruby method `resolve_url_basename_time_file_size(url, timeout: nil)` at line 28.
pub fn ruby_curl_apache_mirror_download_strategy_l28_d3_resolve_url_basename_time_file_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolve_url_basename_time_file_size', ...args)
}

// Ruby method `apache_mirrors` at line 42.
pub fn ruby_curl_apache_mirror_download_strategy_l42_d4_apache_mirrors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('apache_mirrors', ...args)
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
