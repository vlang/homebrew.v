module homebrew

// Translated from Homebrew/brew `download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "time"
// 6: require "unpack_strategy"
// 7: require "lock_file"
// 8: require "system_command"
// 9: require "utils/output"
// 10: require "utils/path"
// 11:
// 12: # Need to define this before requiring Mechanize to avoid:
// 13: #   uninitialized constant Mechanize
// 14: # rubocop:disable Lint/EmptyClass
// 15: class Mechanize; end
// 16: require "vendor/gems/mechanize/lib/mechanize/http/content_disposition_parser"
// 17: # rubocop:enable Lint/EmptyClass
// 18:
// 19: require "utils/curl"
// 20: require "utils/github"
// 21: require "utils/timer"
// 22:
// 23: require "github_packages"
// 24: require "download_strategy/abstract_download_strategy"
// 25: require "download_strategy/vcs_download_strategy"
// 26: require "download_strategy/abstract_file_download_strategy"
// 27: require "download_strategy/curl_download_strategy"
// 28: require "download_strategy/pypi_download_strategy"
// 29: require "download_strategy/homebrew_curl_download_strategy"
// 30: require "download_strategy/curl_github_packages_download_strategy"
// 31: require "download_strategy/curl_apache_mirror_download_strategy"
// 32: require "download_strategy/curl_post_download_strategy"
// 33: require "download_strategy/no_unzip_curl_download_strategy"
// 34: require "download_strategy/local_bottle_download_strategy"
// 35: require "download_strategy/subversion_download_strategy"
// 36: require "download_strategy/git_download_strategy"
// 37: require "download_strategy/github_git_download_strategy"
// 38: require "download_strategy/cvs_download_strategy"
// 39: require "download_strategy/mercurial_download_strategy"
// 40: require "download_strategy/bazaar_download_strategy"
// 41: require "download_strategy/fossil_download_strategy"
// 42: require "download_strategy/download_strategy_detector"
// 43:
// 44: AbstractDownloadStrategy::HOMEBREW_CONTROLLED_STRATEGIES = T.let([
// 45:   CurlApacheMirrorDownloadStrategy,
// 46:   CurlDownloadStrategy,
// 47:   CurlGitHubPackagesDownloadStrategy,
// 48:   CurlPostDownloadStrategy,
// 49:   HomebrewCurlDownloadStrategy,
// 50:   NoUnzipCurlDownloadStrategy,
// 51:   PyPIDownloadStrategy,
// 52: ].freeze, T::Array[T::Class[AbstractDownloadStrategy]])
// 53: AbstractDownloadStrategy.private_constant :HOMEBREW_CONTROLLED_STRATEGIES
