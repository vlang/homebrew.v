module download_strategy

import os

// Translated from Homebrew/brew `download_strategy/bazaar_download_strategy.rb`.

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
