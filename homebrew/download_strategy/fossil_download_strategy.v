module download_strategy

// Translated from Homebrew/brew `download_strategy/fossil_download_strategy.rb`.

// Ruby method `initialize(url, name, version, **meta)` at line 9.
pub fn new_fossil_download_strategy(source_url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	url := if source_url.starts_with('fossil://') {
		source_url['fossil://'.len..]
	} else {
		source_url
	}
	mut strategy := new_vcs_download_strategy(url, name, version, meta, 'fossil', .fossil)
	strategy.url = url
	return strategy
}

fn (strategy &VCSDownloadStrategy) fossil_tip_info() !string {
	result := vcs_command_checked('fossil', ['info', 'tip', '-R', strategy.cached_location_value], '', strategy.fossil_env(), none)!
	return result.output
}

fn fossil_tip_line(output string) !string {
	for line in output.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.starts_with('hash:') || trimmed.starts_with('uuid:') {
			return trimmed
		}
	}
	return error('Could not read the Fossil tip')
}

// Ruby method `source_modified_time` at line 18.
pub fn (strategy &VCSDownloadStrategy) fossil_source_modified_time() !i64 {
	line := fossil_tip_line(strategy.fossil_tip_info()!)!
	fields := line.fields()
	if fields.len < 3 {
		return error('Could not read the Fossil tip timestamp')
	}
	return parse_vcs_timestamp(fields[2..].join(' '))!
}

// Ruby method `source_revision = last_commit.presence` at line 24.
pub fn (strategy &VCSDownloadStrategy) fossil_source_revision() !string {
	return strategy.fossil_last_commit()
}

// Ruby method `last_commit` at line 30.
pub fn (strategy &VCSDownloadStrategy) fossil_last_commit() !string {
	line := fossil_tip_line(strategy.fossil_tip_info()!)!
	fields := line.fields()
	if fields.len < 2 {
		return error('Could not read the Fossil tip hash')
	}
	return fields[1]
}

// Ruby method `repo_valid?` at line 36.
pub fn (strategy &VCSDownloadStrategy) fossil_repo_valid() bool {
	result := vcs_command('fossil', ['branch', '-R', strategy.cached_location_value], '', strategy.fossil_env(), none) or { return false }
	return result.exit_code == 0
}

// Ruby method `env` at line 43.
pub fn (strategy &VCSDownloadStrategy) fossil_env() map[string]string {
	_ = strategy
	return formula_opt_bin_environment('fossil', false)
}

// Ruby method `cache_tag` at line 48.
pub fn (strategy &VCSDownloadStrategy) fossil_cache_tag() string {
	_ = strategy
	return 'fossil'
}

// Ruby method `clone_repo(timeout: nil)` at line 53.
pub fn (mut strategy VCSDownloadStrategy) fossil_clone_repo(deadline ?i64) ! {
	vcs_command_checked('fossil', ['clone', strategy.url, strategy.cached_location_value], '', strategy.fossil_env(), deadline)!
}

// Ruby method `update(timeout: nil)` at line 58.
pub fn (mut strategy VCSDownloadStrategy) fossil_update(deadline ?i64) ! {
	vcs_command_checked('fossil', ['pull', '-R', strategy.cached_location_value], '', strategy.fossil_env(), deadline)!
}

// Source entrypoint translations.
