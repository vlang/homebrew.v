module download_strategy

import os
import time

// Translated from Homebrew/brew `download_strategy/subversion_download_strategy.rb`.

// Ruby method `initialize(url, name, version, **meta)` at line 9.
pub fn new_subversion_download_strategy(url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	mut strategy := new_vcs_download_strategy(url.replace_once('svn+http://', ''), name, version, meta, if version.to_upper() == 'HEAD' {
		'svn-HEAD'
	} else {
		'svn'
	}, .subversion)
	strategy.url = url.replace_once('svn+http://', '')
	return strategy
}

// Ruby method `fetch(timeout: nil)` at line 18.
pub fn (mut strategy VCSDownloadStrategy) subversion_prepare_fetch(deadline ?i64) ! {
	if !os.is_dir(strategy.cached_location_value) {
		return
	}
	repository_url := strategy.subversion_repo_url() or { '' }
	mut valid := strategy.url.trim_right('/') == repository_url
	if valid {
		result := vcs_command('svn', ['switch', strategy.url, strategy.cached_location_value], '', map[string]string{}, deadline)!
		valid = result.exit_code == 0
	}
	if !valid {
		strategy.base.clear_cache(strategy.cached_location_value)!
	}
}

// Ruby method `source_modified_time` at line 29.
pub fn (strategy &VCSDownloadStrategy) subversion_source_modified_time() !i64 {
	mut result := vcs_command('svn', ['info', '--show-item', 'last-changed-date'], strategy.cached_location_value, map[string]string{}, none)!
	mut value := result.output.trim_space()
	if result.exit_code != 0 || value == '' {
		result = vcs_command_checked('svn', ['info'], strategy.cached_location_value, map[string]string{}, none)!
		for line in result.output.split_into_lines() {
			if line.starts_with('Last Changed Date: ') {
				value = line.all_after('Last Changed Date: ').all_before(' (')
				break
			}
		}
	}
	parsed := time.parse_iso8601(value) or { return error('invalid Subversion timestamp `${value}`') }
	return parsed.unix()
}

// Ruby method `source_revision = last_commit` at line 41.
pub fn (strategy &VCSDownloadStrategy) subversion_source_revision() !string {
	return strategy.subversion_last_commit()
}

// Ruby method `last_commit` at line 47.
pub fn (strategy &VCSDownloadStrategy) subversion_last_commit() !string {
	result := vcs_command_checked('svn', ['info', '--show-item', 'revision'], strategy.cached_location_value, map[string]string{}, none)!
	return result.output.trim_space()
}

// Ruby method `repo_url` at line 54.
pub fn (strategy &VCSDownloadStrategy) subversion_repo_url() !string {
	result := vcs_command_checked('svn', ['info'], strategy.cached_location_value, map[string]string{}, none)!
	for line in result.output.split_into_lines() {
		if line.starts_with('URL: ') {
			return line.all_after('URL: ').trim_space()
		}
	}
	return ''
}

// Ruby method `externals(&_block)` at line 59.
pub struct SVNExternal {
pub:
	name string
	url  string
}

pub fn (strategy &VCSDownloadStrategy) subversion_externals() ![]SVNExternal {
	result := vcs_command_checked('svn', ['propget', 'svn:externals', strategy.url], '', map[string]string{}, none)!
	mut externals := []SVNExternal{}
	for line in result.output.trim_space().split_into_lines() {
		fields := line.fields()
		if fields.len >= 2 {
			externals << SVNExternal{fields[0], fields[1]}
		}
	}
	return externals
}

// Ruby method `fetch_repo(target, url, revision = nil, ignore_externals: false, timeout: nil)` at line 71.
pub fn (strategy &VCSDownloadStrategy) subversion_fetch_arguments(target string, url string, revision string, ignore_externals bool) []string {
	mut args := []string{}
	if !strategy.verbose {
		args << '--quiet'
	}
	if revision != '' {
		strategy.base.ohai('Checking out ${strategy.ref}')
		args << '-r'
		args << revision
	}
	if ignore_externals {
		args << '--ignore-externals'
	}
	if strategy.trust_cert {
		args << '--trust-server-cert'
		args << '--non-interactive'
	}
	if os.is_dir(target) {
		mut update_args := ['update']
		update_args << args
		return update_args
	} else {
		mut checkout_args := ['checkout']
		checkout_args << args
		checkout_args << ['--', url, target]
		return checkout_args
	}
}

pub fn (strategy &VCSDownloadStrategy) subversion_fetch_repo(target string, url string, revision string, ignore_externals bool, deadline ?i64) ! {
	arguments := strategy.subversion_fetch_arguments(target, url, revision, ignore_externals)
	if os.is_dir(target) {
		vcs_command_checked('svn', arguments, target, map[string]string{}, deadline)!
	} else {
		vcs_command_checked('svn', arguments, '', map[string]string{}, deadline)!
	}
}

// Ruby method `cache_tag` at line 96.
pub fn (strategy &VCSDownloadStrategy) subversion_cache_tag() string {
	return if strategy.head() { 'svn-HEAD' } else { 'svn' }
}

// Ruby method `repo_valid?` at line 101.
pub fn (strategy &VCSDownloadStrategy) subversion_repo_valid() bool {
	return os.is_dir(os.join_path(strategy.cached_location_value, '.svn'))
}

// Ruby method `clone_repo(timeout: nil)` at line 106.
pub fn (mut strategy VCSDownloadStrategy) subversion_clone_repo(deadline ?i64) ! {
	match strategy.ref_type {
		.revision {
			strategy.subversion_fetch_repo(strategy.cached_location_value, strategy.url, strategy.ref, false, deadline)!
		}
		.revisions {
			strategy.subversion_fetch_repo(strategy.cached_location_value, strategy.url, strategy.revisions['trunk'], true, deadline)!
			for external in strategy.subversion_externals()! {
				strategy.subversion_fetch_repo(os.join_path(strategy.cached_location_value, external.name), external.url, strategy.revisions[external.name], true, deadline)!
			}
		}
		else {
			strategy.subversion_fetch_repo(strategy.cached_location_value, strategy.url, '', false, deadline)!
		}
	}
}

// Ruby alias `alias update clone_repo` at line 123.
pub fn (mut strategy VCSDownloadStrategy) subversion_update(deadline ?i64) ! {
	strategy.subversion_clone_repo(deadline)!
}

// Source entrypoint translations.
