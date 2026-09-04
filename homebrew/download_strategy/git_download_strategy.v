module download_strategy

import ruby
import os
import time

// Translated from Homebrew/brew `download_strategy/git_download_strategy.rb`.

// Ruby method `initialize(url, name, version, **meta)` at line 11.
// Git's sparse-checkout cone mode consumes directory patterns with both a
// leading and trailing slash, so normalize the source `only_path` metadata
// before the shared VCS initializer computes its cache tag.
pub fn new_git_download_strategy(url string, name string, version string, source_meta VCSDownloadMeta) VCSDownloadStrategy {
	mut meta := source_meta
	if meta.only_path != '' {
		if !meta.only_path.starts_with('/') {
			meta.only_path = '/${meta.only_path}'
		}
		if !meta.only_path.ends_with('/') {
			meta.only_path += '/'
		}
	}
	mut strategy := new_vcs_download_strategy(url, name, version, meta, if meta.only_path == '' {
		'git'
	} else {
		'git-sparse'
	}, .git)
	if strategy.ref_type == .unspecified {
		strategy.ref_type = .branch
		strategy.ref = 'master'
	}
	return strategy
}

// Ruby method `source_modified_time` at line 31.
pub fn (strategy &VCSDownloadStrategy) git_source_modified_time() !i64 {
	result := vcs_command_checked('git', ['--git-dir', strategy.git_dir(), 'show', '-s',
		'--format=%cD'], '', strategy.git_local_env(), none)!
	parsed := time.parse_rfc2822(result.output.trim_space()) or {
		return error('invalid Git commit time `${result.output.trim_space()}`')
	}
	return parsed.unix()
}

// Ruby method `source_revision = current_revision.presence` at line 40.
pub fn (strategy &VCSDownloadStrategy) git_source_revision() !string {
	return strategy.git_current_revision()
}

// Ruby method `last_commit` at line 46.
pub fn (strategy &VCSDownloadStrategy) git_last_commit() !string {
	result := vcs_command('git', ['--git-dir', strategy.git_dir(), 'rev-parse', '--short=7', 'HEAD'], '', strategy.git_local_env(), none)!
	if result.exit_code != 0 {
		return ''
	}
	return result.output.trim_space()
}

// Ruby method `ref?` at line 53.
pub fn (strategy &VCSDownloadStrategy) git_ref() bool {
	result := vcs_command('git', ['--git-dir', strategy.git_dir(), 'rev-parse', '-q', '--verify',
		'--end-of-options', '${strategy.ref}^{commit}'], '', strategy.git_local_env(), none) or { return false }
	return result.exit_code == 0
}

// Ruby method `clone_args` at line 61.
pub fn (strategy &VCSDownloadStrategy) git_clone_args() []string {
	mut args := ['clone']
	if strategy.ref_type in [.branch, .tag] {
		args << '--branch'
		args << strategy.ref
	}
	if strategy.git_partial_clone_sparse_checkout() {
		args << '--no-checkout'
		args << '--filter=blob:none'
	}
	args << '--config'
	args << 'advice.detachedHead=false'
	args << '--config'
	args << 'core.fsmonitor=false'
	args << '--end-of-options'
	args << strategy.url
	args << strategy.cached_location_value
	return args
}

// Ruby method `env` at line 81.
pub fn (strategy &VCSDownloadStrategy) git_env() map[string]string {
	_ = strategy
	return {
		'GIT_TERMINAL_PROMPT': '0'
	}
}

// Ruby method `local_git_env` at line 90.
pub fn (strategy &VCSDownloadStrategy) git_local_env() map[string]string {
	mut environment := strategy.git_env()
	environment['GIT_CONFIG_GLOBAL'] = '/dev/null'
	return environment
}

// Ruby method `cache_tag` at line 96.
pub fn (strategy &VCSDownloadStrategy) git_cache_tag() string {
	return if strategy.git_partial_clone_sparse_checkout() { 'git-sparse' } else { 'git' }
}

// Ruby method `cache_version` at line 105.
pub fn (strategy &VCSDownloadStrategy) git_cache_version() int {
	_ = strategy
	return 0
}

// Ruby method `update(timeout: nil)` at line 110.
pub fn (mut strategy VCSDownloadStrategy) git_update(deadline ?i64) ! {
	strategy.git_config_repo(deadline)!
	strategy.git_update_repo(deadline)!
	strategy.git_checkout(deadline)!
	strategy.git_reset(deadline)!
	if strategy.git_submodules() {
		strategy.git_update_submodules(deadline)!
	}
}

// Ruby method `shallow_dir?` at line 119.
pub fn (strategy &VCSDownloadStrategy) git_shallow_dir() bool {
	return os.exists(os.join_path(strategy.git_dir(), 'shallow'))
}

// Ruby method `git_dir` at line 124.
pub fn (strategy &VCSDownloadStrategy) git_dir() string {
	return os.join_path(strategy.cached_location_value, '.git')
}

// Ruby method `current_revision` at line 129.
pub fn (strategy &VCSDownloadStrategy) git_current_revision() !string {
	result := vcs_command('git', ['--git-dir', strategy.git_dir(), 'rev-parse', '-q', '--verify',
		'HEAD'], '', strategy.git_local_env(), none)!
	return if result.exit_code == 0 { result.output.trim_space() } else { '' }
}

// Ruby method `repo_valid?` at line 135.
pub fn (strategy &VCSDownloadStrategy) git_repo_valid() bool {
	result := vcs_command('git', ['-C', strategy.cached_location_value, 'status', '-s'], '', strategy.git_env(), none) or { return false }
	return result.exit_code == 0
}

// Ruby method `submodules?` at line 140.
pub fn (strategy &VCSDownloadStrategy) git_submodules() bool {
	return os.exists(os.join_path(strategy.cached_location_value, '.gitmodules'))
}

// Ruby method `partial_clone_sparse_checkout?` at line 145.
pub fn (strategy &VCSDownloadStrategy) git_partial_clone_sparse_checkout() bool {
	if strategy.only_path == '' {
		return false
	}
	result := vcs_command('git', ['--version'], '', map[string]string{}, none) or { return false }
	parts := result.output.trim_space().split(' ').last().split('.')
	if parts.len < 2 {
		return false
	}
	return parts[0].int() > 2 || (parts[0].int() == 2 && parts[1].int() >= 25)
}

// Ruby method `refspec` at line 153.
pub fn (strategy &VCSDownloadStrategy) git_refspec() string {
	return match strategy.ref_type {
		.branch { '+refs/heads/${strategy.ref}:refs/remotes/origin/${strategy.ref}' }
		.tag { '+refs/tags/${strategy.ref}:refs/tags/${strategy.ref}' }
		else { strategy.git_default_refspec() }
	}
}

// Ruby method `default_refspec` at line 162.
pub fn (strategy &VCSDownloadStrategy) git_default_refspec() string {
	_ = strategy
	// https://git-scm.com/book/en/v2/Git-Internals-The-Refspec
	return '+refs/heads/*:refs/remotes/origin/*'
}

// Ruby method `config_repo` at line 168.
pub fn (strategy &VCSDownloadStrategy) git_config_repo(deadline ?i64) ! {
	settings := {
		'remote.origin.url':    strategy.url
		'remote.origin.fetch':  strategy.git_refspec()
		'remote.origin.tagOpt': '--no-tags'
		'advice.detachedHead':  'false'
		'core.fsmonitor':       'false'
	}
	for key, value in settings {
		vcs_command_checked('git', ['config', key, value], strategy.cached_location_value, strategy.git_env(), deadline)!
	}
	if strategy.git_partial_clone_sparse_checkout() {
		vcs_command_checked('git', ['config', 'origin.partialclonefilter', 'blob:none'], strategy.cached_location_value, strategy.git_env(), deadline)!
		strategy.git_configure_sparse_checkout(deadline)!
	}
}

// Ruby method `update_repo(timeout: nil)` at line 194.
pub fn (strategy &VCSDownloadStrategy) git_update_repo(deadline ?i64) ! {
	if strategy.ref_type != .branch && strategy.git_ref() {
		return
	}
	mut args := ['fetch', 'origin']
	if strategy.git_shallow_dir() {
		args << '--unshallow'
	}
	vcs_command_checked('git', args, strategy.cached_location_value, strategy.git_env(), deadline)!
}

// Ruby method `clone_repo(timeout: nil)` at line 214.
pub fn (mut strategy VCSDownloadStrategy) git_clone_repo(deadline ?i64) ! {
	vcs_command_checked('git', strategy.git_clone_args(), '', strategy.git_env(), deadline)!
	vcs_command_checked('git', ['config', 'homebrew.cacheversion',
		strategy.git_cache_version().str()], strategy.cached_location_value, strategy.git_env(), deadline)!
	if strategy.git_partial_clone_sparse_checkout() {
		strategy.git_configure_sparse_checkout(deadline)!
	}
	strategy.git_checkout(deadline)!
	if strategy.git_submodules() {
		strategy.git_update_submodules(deadline)!
	}
}

// Ruby method `checkout(timeout: nil)` at line 232.
pub fn (strategy &VCSDownloadStrategy) git_checkout(deadline ?i64) ! {
	if strategy.ref != '' {
		strategy.base.ohai('Checking out ${strategy.ref_type} ${strategy.ref}')
	}
	vcs_command_checked('git', ['checkout', '-f', strategy.ref, '--'], strategy.cached_location_value, strategy.git_env(), deadline)!
}

// Ruby method `reset` at line 239.
pub fn (strategy &VCSDownloadStrategy) git_reset(deadline ?i64) ! {
	mut args := ['reset', '--hard']
	match strategy.ref_type {
		.branch { args << 'origin/${strategy.ref}' }
		.revision, .tag { args << strategy.ref }
		else {}
	}
	args << '--'
	vcs_command_checked('git', args, strategy.cached_location_value, strategy.git_env(), deadline)!
}

// Ruby method `update_submodules(timeout: nil)` at line 253.
pub fn (strategy &VCSDownloadStrategy) git_update_submodules(deadline ?i64) ! {
	vcs_command_checked('git', ['submodule', 'foreach', '--recursive', 'git submodule sync'], strategy.cached_location_value, strategy.git_env(), deadline)!
	vcs_command_checked('git', ['submodule', 'update', '--init', '--recursive'], strategy.cached_location_value, strategy.git_env(), deadline)!
	strategy.git_fix_absolute_submodule_gitdir_references()!
}

// Ruby method `fix_absolute_submodule_gitdir_references!` at line 275.
pub fn (strategy &VCSDownloadStrategy) git_fix_absolute_submodule_gitdir_references() ! {
	result := vcs_command_checked('git', ['submodule', '--quiet', 'foreach', '--recursive', 'pwd'], strategy.cached_location_value, strategy.git_env(), none)!
	for submodule_dir in result.output.split_into_lines() {
		work_dir := submodule_dir.trim_space()
		if work_dir == '' {
			continue
		}
		dot_git := os.join_path(work_dir, '.git')
		if !os.is_file(dot_git) {
			continue
		}
		line := os.read_file(dot_git)!.trim_space()
		if !line.starts_with('gitdir: ') {
			continue
		}
		git_directory := line.all_after('gitdir: ')
		if !os.is_abs_path(git_directory) {
			continue
		}
		relative := lexical_relative_path(work_dir, git_directory)
		ruby.atomic_write_file(dot_git, 'gitdir: ${relative}\n')!
	}
}

// Ruby method `configure_sparse_checkout` at line 304.
pub fn (strategy &VCSDownloadStrategy) git_configure_sparse_checkout(deadline ?i64) ! {
	vcs_command_checked('git', ['config', 'core.sparseCheckout', 'true'], strategy.cached_location_value, strategy.git_env(), deadline)!
	vcs_command_checked('git', ['config', 'core.sparseCheckoutCone', 'true'], strategy.cached_location_value, strategy.git_env(), deadline)!
	info := os.join_path(strategy.git_dir(), 'info')
	os.mkdir_all(info)!
	os.write_file(os.join_path(info, 'sparse-checkout'), '${strategy.only_path}\n')!
}

fn lexical_relative_path(base string, destination string) string {
	base_parts := os.norm_path(base).split('/').filter(it != '')
	destination_parts := os.norm_path(destination).split('/').filter(it != '')
	mut common_count := 0
	for common_count < base_parts.len && common_count < destination_parts.len && base_parts[common_count] == destination_parts[common_count] {
		common_count++
	}
	mut parts := []string{}
	for _ in common_count .. base_parts.len {
		parts << '..'
	}
	parts << destination_parts[common_count..]
	return if parts.len == 0 { '.' } else { parts.join('/') }
}

// Source entrypoint translations.
