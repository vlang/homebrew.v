module download_strategy

import ruby
import net.urllib
import os

// Translated from Homebrew/brew `download_strategy/github_git_download_strategy.rb`.

pub struct GitHubGitDownloadStrategy {
pub mut:
	git                        VCSDownloadStrategy
	github_user                string
	github_repo                string
	last_commit_cache          string
	default_branch_cache       string
	default_branch_initialized bool
}

pub fn new_github_git_download_strategy(url string, name string, version string, meta VCSDownloadMeta) GitHubGitDownloadStrategy {
	mut github_user := ''
	mut github_repo := ''
	for prefix in ['http://github.com/', 'https://github.com/'] {
		if url.starts_with(prefix) && url.ends_with('.git') {
			parts := url[prefix.len..url.len - '.git'.len].split('/')
			if parts.len == 2 && parts[0] != '' && parts[1] != '' {
				github_user = parts[0]
				github_repo = parts[1]
			}
			break
		}
	}
	return GitHubGitDownloadStrategy{
		git: new_git_download_strategy(url, name, version, meta)
		github_user: github_user
		github_repo: github_repo
	}
}

pub fn (strategy &GitHubGitDownloadStrategy) user() ?string {
	if strategy.github_user == '' {
		return none
	}
	return strategy.github_user
}

pub fn (strategy &GitHubGitDownloadStrategy) repo() ?string {
	if strategy.github_repo == '' {
		return none
	}
	return strategy.github_repo
}

pub fn (mut strategy GitHubGitDownloadStrategy) last_commit() !string {
	if strategy.last_commit_cache != '' {
		return strategy.last_commit_cache
	}
	if strategy.github_user != '' && strategy.github_repo != '' {
		if commit := github_last_commit(strategy.github_user, strategy.github_repo, strategy.git.ref) {
			strategy.last_commit_cache = commit
			strategy.git.last_commit_cache = commit
			strategy.git.version_commit = commit
			return commit
		}
	}
	strategy.last_commit_cache = strategy.git.git_last_commit()!
	return strategy.last_commit_cache
}

pub fn (mut strategy GitHubGitDownloadStrategy) commit_outdated(commit ?string) !bool {
	value := commit or { return true }
	latest := strategy.last_commit()!
	if latest == '' {
		return strategy.git.commit_outdated(commit)
	}
	if !latest.starts_with(value) {
		return true
	}
	if strategy.github_user != '' && strategy.github_repo != '' && github_multiple_short_commits_exist(strategy.github_user, strategy.github_repo, value) {
		return true
	}
	strategy.git.version_commit = value
	return false
}

pub fn (mut strategy GitHubGitDownloadStrategy) default_refspec() !string {
	branch := strategy.default_branch()!
	if branch != '' {
		return '+refs/heads/${branch}:refs/remotes/origin/${branch}'
	}
	return strategy.git.git_default_refspec()
}

pub fn (mut strategy GitHubGitDownloadStrategy) default_branch() !string {
	if strategy.default_branch_initialized {
		return strategy.default_branch_cache
	}
	vcs_command_checked('git', ['remote', 'set-head', 'origin', '--auto'], strategy.git.cached_location(), strategy.git.git_env(), none)!
	result := vcs_command_checked('git', ['symbolic-ref', 'refs/remotes/origin/HEAD'], strategy.git.cached_location(), strategy.git.git_env(), none)!
	strategy.default_branch_initialized = true
	prefix := 'refs/remotes/origin/'
	line := result.output.trim_space()
	if line.starts_with(prefix) && line.len > prefix.len {
		strategy.default_branch_cache = line[prefix.len..]
		return strategy.default_branch_cache
	}
	return ''
}

fn github_last_commit(user string, repo string, ref string) ?string {
	if environment_truthy('HOMEBREW_NO_GITHUB_API') {
		return none
	}
	curl := ruby.find_executable('curl') or { return none }
	endpoint := github_commit_endpoint(user, repo, ref)
	result := ruby.run_command(curl, ['--silent', '--head', '--location', '--header',
		'Accept: application/vnd.github.sha', endpoint])
	if result.exit_code != 0 {
		return none
	}
	for raw_line in result.output.split_into_lines() {
		line := raw_line.trim_space()
		if !line.to_lower().starts_with('etag:') {
			continue
		}
		commit := line.all_after(':').trim_space().trim('"')
		if commit.len < 7 || !commit.bytes().all(it.is_hex_digit()) {
			return none
		}
		short_commit := commit[..7].to_lower()
		if github_multiple_short_commits_exist(user, repo, short_commit) {
			return none
		}
		return short_commit
	}
	return none
}

fn github_multiple_short_commits_exist(user string, repo string, commit string) bool {
	if environment_truthy('HOMEBREW_NO_GITHUB_API') {
		return false
	}
	curl := ruby.find_executable('curl') or { return true }
	result := ruby.run_command(curl, ['--silent', '--head', '--location', '--header',
		'Accept: application/vnd.github.sha', '--output', os.path_devnull, '--write-out',
		'%{http_code}', github_commit_endpoint(user, repo, commit)])
	return result.exit_code != 0 || result.output.trim_space() != '200'
}

fn github_commit_endpoint(user string, repo string, ref string) string {
	return 'https://api.github.com/repos/${urllib.query_escape(user)}/${urllib.query_escape(repo)}/commits/${urllib.query_escape(ref)}'
}
