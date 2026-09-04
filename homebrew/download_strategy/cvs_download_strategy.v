module download_strategy

import os

// Translated from Homebrew/brew `download_strategy/cvs_download_strategy.rb`.

// Ruby method `initialize(url, name, version, **meta)` at line 9.
pub fn new_cvs_download_strategy(source_url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	mut url := source_url
	if url.starts_with('cvs://') {
		url = url['cvs://'.len..]
	}
	mut module_name := meta.module_name
	if module_name == '' {
		last_slash := url.last_index('/') or { -1 }
		last_colon := url.last_index(':') or { -1 }
		if last_colon > last_slash {
			module_name, url = cvs_split_url(url)
		} else {
			module_name = name
		}
	}
	mut strategy := new_vcs_download_strategy(url, name, version, meta, 'cvs', .cvs)
	strategy.url = url
	strategy.module_name = module_name
	return strategy
}

// Ruby method `source_modified_time` at line 30. CVS administrative
// directories are pruned because CVS sets their mtimes at checkout time.
pub fn (strategy &VCSDownloadStrategy) cvs_source_modified_time() !i64 {
	return cvs_latest_source_mtime(strategy.cached_location_value)
}

fn cvs_latest_source_mtime(directory string) !i64 {
	mut latest := i64(0)
	for entry in os.ls(directory)! {
		path := os.join_path(directory, entry)
		if os.is_dir(path) && !os.is_link(path) {
			if entry == 'CVS' {
				continue
			}
			modified := cvs_latest_source_mtime(path)!
			if modified > latest {
				latest = modified
			}
		} else if os.is_file(path) {
			modified := os.file_last_mod_unix(path)
			if modified > latest {
				latest = modified
			}
		}
	}
	return latest
}

// Ruby method `env` at line 47.
pub fn (strategy &VCSDownloadStrategy) cvs_env() map[string]string {
	_ = strategy
	return formula_opt_bin_environment('cvs', true)
}

// Ruby method `cache_tag` at line 52.
pub fn (strategy &VCSDownloadStrategy) cvs_cache_tag() string {
	_ = strategy
	return 'cvs'
}

// Ruby method `repo_valid?` at line 57.
pub fn (strategy &VCSDownloadStrategy) cvs_repo_valid() bool {
	return os.is_dir(os.join_path(strategy.cached_location_value, 'CVS'))
}

// Ruby method `quiet_flag` at line 62.
pub fn (strategy &VCSDownloadStrategy) cvs_quiet_flag() ?string {
	if !strategy.verbose {
		return '-Q'
	}
	return none
}

fn (strategy &VCSDownloadStrategy) cvs_command_args(arguments []string) []string {
	mut result := []string{}
	if quiet_flag := strategy.cvs_quiet_flag() {
		result << quiet_flag
	}
	result << arguments
	return result
}

// Ruby method `clone_repo(timeout: nil)` at line 67.
pub fn (mut strategy VCSDownloadStrategy) cvs_clone_repo(deadline ?i64) ! {
	if strategy.url.contains('pserver') {
		vcs_command_checked('cvs', strategy.cvs_command_args(['-d', strategy.url, 'login']), '', strategy.cvs_env(), deadline)!
	}
	parent := os.dir(strategy.cached_location_value)
	os.mkdir_all(parent)!
	vcs_command_checked('cvs', strategy.cvs_command_args(['-d', strategy.url, 'checkout', '-d',
		os.file_name(strategy.cached_location_value), strategy.module_name]), parent, strategy.cvs_env(), deadline)!
}

// Ruby method `update(timeout: nil)` at line 81.
pub fn (mut strategy VCSDownloadStrategy) cvs_update(deadline ?i64) ! {
	vcs_command_checked('cvs', strategy.cvs_command_args(['update']), strategy.cached_location_value, strategy.cvs_env(), deadline)!
}

// Ruby method `split_url(in_url)` at line 89.
pub fn cvs_split_url(in_url string) (string, string) {
	colon := in_url.last_index(':') or { return '', in_url }
	return in_url[colon + 1..], in_url[..colon]
}

// Source entrypoint translations.
