module download_strategy

import ruby
import net.urllib
import os

// Translated from Homebrew/brew `download_strategy/github_git_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :user` at line 9.
pub fn ruby_github_git_download_strategy_l9_d1_user(strategy &GitHubGitDownloadStrategy) ?string {
	return strategy.user()
}

// Ruby attr_reader `attr_reader :repo` at line 12.
pub fn ruby_github_git_download_strategy_l12_d2_repo(strategy &GitHubGitDownloadStrategy) ?string {
	return strategy.repo()
}

// Ruby method `initialize(url, name, version, **meta)` at line 15.
pub fn ruby_github_git_download_strategy_l15_d3_initialize(url string, name string, version string, meta VCSDownloadMeta) GitHubGitDownloadStrategy {
	return new_github_git_download_strategy(url, name, version, meta)
}

// Ruby method `last_commit` at line 27.
pub fn ruby_github_git_download_strategy_l27_d4_last_commit(mut strategy GitHubGitDownloadStrategy) !string {
	return strategy.last_commit()
}

// Ruby method `commit_outdated?(commit)` at line 34.
pub fn ruby_github_git_download_strategy_l34_d5_commit_outdated(mut strategy GitHubGitDownloadStrategy, commit ?string) !bool {
	return strategy.commit_outdated(commit)
}

// Ruby method `default_refspec` at line 48.
pub fn ruby_github_git_download_strategy_l48_d6_default_refspec(mut strategy GitHubGitDownloadStrategy) !string {
	return strategy.default_refspec()
}

// Ruby method `default_branch` at line 57.
pub fn ruby_github_git_download_strategy_l57_d7_default_branch(mut strategy GitHubGitDownloadStrategy) !string {
	return strategy.default_branch()
}

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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading a Git repository from GitHub.
// 5: #
// 6: # @api public
// 7: class GitHubGitDownloadStrategy < GitDownloadStrategy
// 8:   sig { returns(T.nilable(String)) }
// 9:   attr_reader :user
// 10:
// 11:   sig { returns(T.nilable(String)) }
// 12:   attr_reader :repo
// 13:
// 14:   sig { params(url: String, name: String, version: T.nilable(Version), meta: T.untyped).void }
// 15:   def initialize(url, name, version, **meta)
// 16:     super
// 17:     @version = version
// 18:
// 19:     match_data = %r{^https?://github\.com/(?<user>[^/]+)/(?<repo>[^/]+)\.git$}.match(@url)
// 20:     return unless match_data
// 21:
// 22:     @user = T.let(match_data[:user], T.nilable(String))
// 23:     @repo = T.let(match_data[:repo], T.nilable(String))
// 24:   end
// 25:
// 26:   sig { override.returns(String) }
// 27:   def last_commit
// 28:     @last_commit ||= GitHub.last_commit(T.must(@user), T.must(@repo), @ref, T.cast(T.must(version), Version),
// 29:                                         length: MINIMUM_COMMIT_HASH_LENGTH)
// 30:     @last_commit || super
// 31:   end
// 32:
// 33:   sig { override.params(commit: T.nilable(String)).returns(T::Boolean) }
// 34:   def commit_outdated?(commit)
// 35:     return true unless commit
// 36:     return super if last_commit.blank?
// 37:     return true unless last_commit.start_with?(commit)
// 38:
// 39:     if GitHub.multiple_short_commits_exist?(T.must(@user), T.must(@repo), commit)
// 40:       true
// 41:     else
// 42:       T.must(@version).update_commit(commit)
// 43:       false
// 44:     end
// 45:   end
// 46:
// 47:   sig { returns(String) }
// 48:   def default_refspec
// 49:     if default_branch
// 50:       "+refs/heads/#{default_branch}:refs/remotes/origin/#{default_branch}"
// 51:     else
// 52:       super
// 53:     end
// 54:   end
// 55:
// 56:   sig { returns(T.nilable(String)) }
// 57:   def default_branch
// 58:     return @default_branch if defined?(@default_branch)
// 59:
// 60:     command! "git",
// 61:              args:  ["remote", "set-head", "origin", "--auto"],
// 62:              chdir: cached_location
// 63:
// 64:     result = command! "git",
// 65:                       args:  ["symbolic-ref", "refs/remotes/origin/HEAD"],
// 66:                       chdir: cached_location
// 67:
// 68:     @default_branch = T.let(result.stdout[%r{^refs/remotes/origin/(.*)$}, 1], T.nilable(String))
// 69:   end
// 70: end
