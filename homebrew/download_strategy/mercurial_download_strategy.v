module download_strategy

import os

// Translated from Homebrew/brew `download_strategy/mercurial_download_strategy.rb`.

// Ruby method `initialize(url, name, version, **meta)` at line 9.
pub fn new_mercurial_download_strategy(source_url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	url := if source_url.starts_with('hg://') { source_url['hg://'.len..] } else { source_url }
	mut strategy := new_vcs_download_strategy(url, name, version, meta, 'hg', .mercurial)
	strategy.url = url
	return strategy
}

// Ruby method `source_modified_time` at line 18.
pub fn (strategy &VCSDownloadStrategy) mercurial_source_modified_time() !i64 {
	result := vcs_command_checked('hg', ['tip', '--template', '{date|isodate}', '-R',
		strategy.cached_location_value], '', strategy.mercurial_env(), none)!
	return parse_vcs_timestamp(result.output)!
}

// Ruby method `source_revision = current_revision.presence` at line 23.
pub fn (strategy &VCSDownloadStrategy) mercurial_source_revision() !string {
	return strategy.mercurial_current_revision()
}

// Ruby method `last_commit` at line 29.
pub fn (strategy &VCSDownloadStrategy) mercurial_last_commit() !string {
	result := vcs_command_checked('hg', ['parent', '--template', '{node|short}', '-R',
		strategy.cached_location_value], '', strategy.mercurial_env(), none)!
	return result.output.trim_space()
}

// Ruby method `env` at line 36.
pub fn (strategy &VCSDownloadStrategy) mercurial_env() map[string]string {
	_ = strategy
	return formula_opt_bin_environment('mercurial', false)
}

// Ruby method `cache_tag` at line 41.
pub fn (strategy &VCSDownloadStrategy) mercurial_cache_tag() string {
	_ = strategy
	return 'hg'
}

// Ruby method `repo_valid?` at line 46.
pub fn (strategy &VCSDownloadStrategy) mercurial_repo_valid() bool {
	return os.is_dir(os.join_path(strategy.cached_location_value, '.hg'))
}

// Ruby method `clone_repo(timeout: nil)` at line 51.
pub fn (mut strategy VCSDownloadStrategy) mercurial_clone_repo(deadline ?i64) ! {
	mut arguments := ['clone']
	match strategy.ref_type {
		.branch {
			arguments << '--branch'
			arguments << strategy.ref
		}
		.revision, .tag {
			arguments << '--rev'
			arguments << strategy.ref
		}
		else {}
	}
	arguments << strategy.url
	arguments << strategy.cached_location_value
	vcs_command_checked('hg', arguments, '', strategy.mercurial_env(), deadline)!
}

// Ruby method `update(timeout: nil)` at line 66.
pub fn (mut strategy VCSDownloadStrategy) mercurial_update(deadline ?i64) ! {
	mut pull_arguments := ['--cwd', strategy.cached_location_value, 'pull']
	match strategy.ref_type {
		.branch {
			pull_arguments << '--branch'
			pull_arguments << strategy.ref
		}
		.revision, .tag {
			pull_arguments << '--rev'
			pull_arguments << strategy.ref
		}
		else {}
	}
	vcs_command_checked('hg', pull_arguments, '', strategy.mercurial_env(), deadline)!
	mut update_ref := 'default'
	if strategy.ref_type != .unspecified && strategy.ref != '' {
		strategy.base.ohai('Checking out ${strategy.ref_type} ${strategy.ref}')
		update_ref = strategy.ref
	}
	vcs_command_checked('hg', ['--cwd', strategy.cached_location_value, 'update', '--clean',
		update_ref], '', strategy.mercurial_env(), deadline)!
}

// Ruby method `current_revision` at line 90.
pub fn (strategy &VCSDownloadStrategy) mercurial_current_revision() !string {
	result := vcs_command_checked('hg', ['--cwd', strategy.cached_location_value, 'identify', '--id'], '', strategy.mercurial_env(), none)!
	return result.output.trim_space()
}

// Source entrypoint translations.
