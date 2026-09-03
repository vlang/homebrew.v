module download_strategy

import os

// Translated from Homebrew/brew `download_strategy/bazaar_download_strategy.rb`.
// The original source is retained below for line-for-line traceability.

// Ruby method `initialize(url, name, version, **meta)` at line 9.
pub fn new_bazaar_download_strategy(source_url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	url := if source_url.starts_with('bzr://') { source_url['bzr://'.len..] } else { source_url }
	mut strategy := new_vcs_download_strategy(url, name, version, meta, 'bzr', .bazaar)
	strategy.url = url
	return strategy
}

// Ruby method `source_modified_time` at line 18.
pub fn (strategy &VCSDownloadStrategy) bazaar_source_modified_time() !i64 {
	result := vcs_command_checked('bzr', ['log', '-l', '1', '--timezone=utc',
		strategy.cached_location_value], '', strategy.bazaar_env(), none)!
	if result.output.trim_space() == '' {
		return error('Could not get any timestamps from bzr!')
	}
	return parse_vcs_timestamp(result.output)!
}

// Ruby method `source_revision = last_commit.presence` at line 26.
pub fn (strategy &VCSDownloadStrategy) bazaar_source_revision() !string {
	return strategy.bazaar_last_commit()
}

// Ruby method `last_commit` at line 32.
pub fn (strategy &VCSDownloadStrategy) bazaar_last_commit() !string {
	result := vcs_command_checked('bzr', ['revno', strategy.cached_location_value], '', strategy.bazaar_env(), none)!
	return result.output.trim_space()
}

// Ruby method `env` at line 39.
pub fn (strategy &VCSDownloadStrategy) bazaar_env() map[string]string {
	_ = strategy
	mut environment := formula_opt_bin_environment('breezy', false)
	environment['BZR_HOME'] = homebrew_temp_directory()
	return environment
}

// Ruby method `cache_tag` at line 44.
pub fn (strategy &VCSDownloadStrategy) bazaar_cache_tag() string {
	_ = strategy
	return 'bzr'
}

// Ruby method `repo_valid?` at line 49.
pub fn (strategy &VCSDownloadStrategy) bazaar_repo_valid() bool {
	return os.is_dir(os.join_path(strategy.cached_location_value, '.bzr'))
}

// Ruby method `clone_repo(timeout: nil)` at line 54.
pub fn (mut strategy VCSDownloadStrategy) bazaar_clone_repo(deadline ?i64) ! {
	// "lightweight" means history-less.
	vcs_command_checked('bzr', ['checkout', '--lightweight', strategy.url,
		strategy.cached_location_value], '', strategy.bazaar_env(), deadline)!
}

// Ruby method `update(timeout: nil)` at line 62.
pub fn (mut strategy VCSDownloadStrategy) bazaar_update(deadline ?i64) ! {
	vcs_command_checked('bzr', ['update'], strategy.cached_location_value, strategy.bazaar_env(), deadline)!
}

// Source entrypoint translations.
pub fn ruby_bazaar_download_strategy_l9_d1_initialize(url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	return new_bazaar_download_strategy(url, name, version, meta)
}

pub fn ruby_bazaar_download_strategy_l18_d2_source_modified_time(strategy &VCSDownloadStrategy) !i64 {
	return strategy.bazaar_source_modified_time()
}

pub fn ruby_bazaar_download_strategy_l26_d3_source_revision(strategy &VCSDownloadStrategy) !string {
	return strategy.bazaar_source_revision()
}

pub fn ruby_bazaar_download_strategy_l32_d4_last_commit(strategy &VCSDownloadStrategy) !string {
	return strategy.bazaar_last_commit()
}

pub fn ruby_bazaar_download_strategy_l39_d5_env(strategy &VCSDownloadStrategy) map[string]string {
	return strategy.bazaar_env()
}

pub fn ruby_bazaar_download_strategy_l44_d6_cache_tag(strategy &VCSDownloadStrategy) string {
	return strategy.bazaar_cache_tag()
}

pub fn ruby_bazaar_download_strategy_l49_d7_repo_valid(strategy &VCSDownloadStrategy) bool {
	return strategy.bazaar_repo_valid()
}

pub fn ruby_bazaar_download_strategy_l54_d8_clone_repo(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.bazaar_clone_repo(deadline)!
}

pub fn ruby_bazaar_download_strategy_l62_d9_update(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.bazaar_update(deadline)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading a Bazaar repository.
// 5: #
// 6: # @api public
// 7: class BazaarDownloadStrategy < VCSDownloadStrategy
// 8:   sig { params(url: String, name: String, version: T.nilable(T.any(String, Version)), meta: T.untyped).void }
// 9:   def initialize(url, name, version, **meta)
// 10:     super
// 11:     @url = T.let(@url.sub(%r{^bzr://}, ""), String)
// 12:   end
// 13:
// 14:   # Returns the most recent modified time for all files in the current working directory after stage.
// 15:   #
// 16:   # @api public
// 17:   sig { override.returns(Time) }
// 18:   def source_modified_time
// 19:     timestamp = silent_command("bzr", args: ["log", "-l", "1", "--timezone=utc", cached_location]).stdout.chomp
// 20:     raise "Could not get any timestamps from bzr!" if timestamp.blank?
// 21:
// 22:     Time.parse(timestamp)
// 23:   end
// 24:
// 25:   sig { override.returns(T.nilable(String)) }
// 26:   def source_revision = last_commit.presence
// 27:
// 28:   # Return last commit's unique identifier for the repository.
// 29:   #
// 30:   # @api public
// 31:   sig { override.returns(String) }
// 32:   def last_commit
// 33:     silent_command("bzr", args: ["revno", cached_location]).stdout.chomp
// 34:   end
// 35:
// 36:   private
// 37:
// 38:   sig { override.returns(T::Hash[String, String]) }
// 39:   def env
// 40:     Utils::Path.formula_opt_bin_env("breezy").merge("BZR_HOME" => HOMEBREW_TEMP.to_s)
// 41:   end
// 42:
// 43:   sig { override.returns(String) }
// 44:   def cache_tag
// 45:     "bzr"
// 46:   end
// 47:
// 48:   sig { override.returns(T::Boolean) }
// 49:   def repo_valid?
// 50:     (cached_location/".bzr").directory?
// 51:   end
// 52:
// 53:   sig { override.params(timeout: T.nilable(Time)).void }
// 54:   def clone_repo(timeout: nil)
// 55:     # "lightweight" means history-less
// 56:     command! "bzr",
// 57:              args:    ["checkout", "--lightweight", @url, cached_location],
// 58:              timeout: Utils::Timer.remaining(timeout)
// 59:   end
// 60:
// 61:   sig { override.params(timeout: T.nilable(Time)).void }
// 62:   def update(timeout: nil)
// 63:     command! "bzr",
// 64:              args:    ["update"],
// 65:              chdir:   cached_location,
// 66:              timeout: Utils::Timer.remaining(timeout)
// 67:   end
// 68: end
