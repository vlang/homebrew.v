module homebrew

import ruby
import os

// Translated from Homebrew/brew `git_repository.rb`.
pub struct GitRepository {
pub:
	pathname       string
	git_executable string = 'git'
}

pub struct GitRepositoryText {
pub:
	present bool
	value   string
}

pub struct GitRepositoryHeadInfo {
pub:
	head_present           bool
	head                   string
	last_committed_present bool
	last_committed         string
	branch_present         bool
	branch                 string
}

pub struct GitPopenOptions {
pub:
	safe             bool
	err_to_stdout    bool
	no_global_config bool
}

pub type GitRepositoryRunner = fn (GitRepository, []string, GitPopenOptions) !ruby.CapturedCommandResult

fn git_repository_some(value string) GitRepositoryText {
	return GitRepositoryText{
		present: true
		value: value
	}
}

fn default_git_repository_runner(repository GitRepository, arguments []string,
	options GitPopenOptions) !ruby.CapturedCommandResult {
	mut environment := map[string]string{}
	if options.no_global_config {
		environment['GIT_CONFIG_GLOBAL'] = os.path_devnull
	}
	mut argv := [repository.git_executable]
	argv << arguments
	return ruby.run_captured_command(argv, ruby.CapturedCommandOptions{
		environment: environment
		chdir: repository.pathname
	})
}

pub fn new_git_repository(pathname string) GitRepository {
	return GitRepository{
		pathname: pathname
	}
}

pub fn (repository GitRepository) is_git_repository() bool {
	return os.exists(os.join_path(repository.pathname, '.git'))
}

fn git_repository_executable_available(executable string) bool {
	if executable.contains(os.path_separator) {
		return os.is_executable(executable)
	}
	_ := os.find_abs_path_of_executable(executable) or { return false }
	return true
}

pub fn popen_git_with_runner(repository GitRepository, arguments []string,
	options GitPopenOptions, runner GitRepositoryRunner) !GitRepositoryText {
	if !repository.is_git_repository() {
		if options.safe {
			return error('Not a Git repository: ${repository.pathname}')
		}
		return GitRepositoryText{}
	}
	result := runner(repository, arguments, options) or {
		if options.safe {
			return err
		}
		return GitRepositoryText{}
	}
	if result.exit_code != 0 && options.safe {
		return error('Git command failed with status ${result.exit_code}: git ${arguments.join(' ')}')
	}
	output := if options.err_to_stdout {
		result.stdout + result.stderr
	} else {
		result.stdout
	}
	trimmed := output.trim_right('\r\n')
	if trimmed == '' {
		return GitRepositoryText{}
	}
	return git_repository_some(trimmed)
}

pub fn (repository GitRepository) popen_git(arguments []string,
	options GitPopenOptions) !GitRepositoryText {
	if !git_repository_executable_available(repository.git_executable) {
		if options.safe {
			return error('Git is unavailable')
		}
		return GitRepositoryText{}
	}
	return popen_git_with_runner(repository, arguments, options, default_git_repository_runner)
}

fn git_config_include_directive(line string) bool {
	stripped := line.trim_left(' \t').to_lower()
	for prefix in ['[include', '[includeif'] {
		if !stripped.starts_with(prefix) || stripped.len <= prefix.len {
			continue
		}
		next := stripped[prefix.len]
		if next == ` ` || next == `\t` || next == `"` || next == `]` {
			return true
		}
	}
	return false
}

pub fn (repository GitRepository) origin_url_from_config() GitRepositoryText {
	config_file := os.join_path(repository.pathname, '.git', 'config')
	if !os.is_file(config_file) {
		return GitRepositoryText{}
	}
	content := os.read_file(config_file) or { return GitRepositoryText{} }
	for line in content.split_into_lines() {
		if git_config_include_directive(line) {
			return GitRepositoryText{}
		}
	}
	mut in_origin := false
	mut urls := []string{}
	for line in content.split_into_lines() {
		stripped := line.trim_space()
		if stripped.starts_with('[') {
			in_origin = stripped == '[remote "origin"]'
			continue
		}
		if !in_origin || stripped == '' || stripped.starts_with('#') || stripped.starts_with(';') {
			continue
		}
		separator := stripped.index('=') or { continue }
		key := stripped[..separator].trim_space()
		if key.to_lower() != 'url' {
			continue
		}
		urls << stripped[separator + 1..].trim_space()
	}
	if urls.len != 1 {
		return GitRepositoryText{}
	}
	url := urls[0]
	if url == '' || url.contains_any('"#;\\') {
		return GitRepositoryText{}
	}
	return git_repository_some(url)
}

pub fn origin_url_with_runner(repository GitRepository, runner GitRepositoryRunner) !GitRepositoryText {
	from_config := repository.origin_url_from_config()
	if from_config.present {
		return from_config
	}
	return popen_git_with_runner(repository, ['config', '--local', '--get', 'remote.origin.url'], GitPopenOptions{ no_global_config: true }, runner)
}

pub fn (repository GitRepository) origin_url() !GitRepositoryText {
	from_config := repository.origin_url_from_config()
	if from_config.present {
		return from_config
	}
	return repository.popen_git(['config', '--local', '--get', 'remote.origin.url'], GitPopenOptions{ no_global_config: true })
}

pub fn (repository GitRepository) head_ref(safe bool) !GitRepositoryText {
	return repository.popen_git(['rev-parse', '--verify', '--quiet', 'HEAD'], GitPopenOptions{
		safe: safe
	})
}

pub fn (repository GitRepository) short_head_ref(length ?int, safe bool) !GitRepositoryText {
	short_arg := if value := length { '--short=${value}' } else { '--short' }
	return repository.popen_git(['rev-parse', short_arg, '--verify', '--quiet', 'HEAD'], GitPopenOptions{ safe: safe })
}

pub fn (repository GitRepository) last_committed() !GitRepositoryText {
	return repository.popen_git(['show', '-s', '--format=%cr', 'HEAD'], GitPopenOptions{})
}

pub fn (repository GitRepository) head_info() !GitRepositoryHeadInfo {
	output := repository.popen_git(['show', '-s', '--format=%H%n%cr%n%D', 'HEAD'], GitPopenOptions{})!
	if !output.present {
		return GitRepositoryHeadInfo{}
	}
	lines := output.value.split_into_lines()
	head := if lines.len > 0 { lines[0] } else { '' }
	last_committed := if lines.len > 1 { lines[1] } else { '' }
	refs := if lines.len > 2 { lines[2] } else { '' }
	mut branch := 'HEAD'
	if refs.starts_with('HEAD -> ') {
		branch = refs['HEAD -> '.len..].all_before(',')
	}
	return GitRepositoryHeadInfo{
		head_present: head != ''
		head: head
		last_committed_present: last_committed != ''
		last_committed: last_committed
		branch_present: true
		branch: branch
	}
}

pub fn git_branch_name_from_ref(ref string) !GitRepositoryText {
	if ref.trim_space() == '' {
		return GitRepositoryText{}
	}
	if ref == 'HEAD' {
		return git_repository_some('HEAD')
	}
	prefix := 'refs/heads/'
	if ref.starts_with(prefix) {
		return git_repository_some(ref[prefix.len..])
	}
	return error('Unexpected HEAD ref format: ${ref}')
}

pub fn branch_name_with_runner(repository GitRepository, safe bool,
	runner GitRepositoryRunner) !GitRepositoryText {
	ref := popen_git_with_runner(repository, ['rev-parse', '--symbolic-full-name', 'HEAD'], GitPopenOptions{ safe: safe }, runner)!
	if !ref.present {
		return GitRepositoryText{}
	}
	return git_branch_name_from_ref(ref.value)
}

pub fn (repository GitRepository) branch_name(safe bool) !GitRepositoryText {
	ref := repository.popen_git(['rev-parse', '--symbolic-full-name', 'HEAD'], GitPopenOptions{
		safe: safe
	})!
	if !ref.present {
		return GitRepositoryText{}
	}
	return git_branch_name_from_ref(ref.value)
}

pub fn (repository GitRepository) rename_branch(old string, new string) ! {
	repository.popen_git(['branch', '-m', old, new], GitPopenOptions{ safe: true })!
}

pub fn (repository GitRepository) set_upstream_branch(local string, origin string) ! {
	repository.popen_git(['branch', '-u', 'origin/${origin}', local], GitPopenOptions{ safe: true })!
}

pub fn git_origin_branch_name_from_ref(ref string) !GitRepositoryText {
	if ref.trim_space() == '' {
		return GitRepositoryText{}
	}
	prefix := 'refs/remotes/origin/'
	if ref.starts_with(prefix) {
		return git_repository_some(ref[prefix.len..])
	}
	return error('Unexpected origin/HEAD ref format: ${ref}')
}

pub fn origin_branch_name_with_runner(repository GitRepository,
	runner GitRepositoryRunner) !GitRepositoryText {
	ref := popen_git_with_runner(repository, ['symbolic-ref', '-q', 'refs/remotes/origin/HEAD'], GitPopenOptions{}, runner)!
	if !ref.present {
		return GitRepositoryText{}
	}
	return git_origin_branch_name_from_ref(ref.value)
}

pub fn (repository GitRepository) origin_branch_name() !GitRepositoryText {
	ref := repository.popen_git(['symbolic-ref', '-q', 'refs/remotes/origin/HEAD'], GitPopenOptions{})!
	if !ref.present {
		return GitRepositoryText{}
	}
	return git_origin_branch_name_from_ref(ref.value)
}

pub fn (repository GitRepository) default_origin_branch() !bool {
	origin := repository.origin_branch_name()!
	branch := repository.branch_name(false)!
	return origin.present == branch.present && origin.value == branch.value
}

pub fn (repository GitRepository) last_commit_date() !GitRepositoryText {
	return repository.popen_git(['show', '-s', '--format=%cd', '--date=short', 'HEAD'], GitPopenOptions{})
}

pub fn (repository GitRepository) origin_has_branch(branch string) !bool {
	return (repository.popen_git(['ls-remote', '--heads', 'origin', branch], GitPopenOptions{})!).present
}

pub fn (repository GitRepository) set_head_origin_auto() ! {
	repository.popen_git(['remote', 'set-head', 'origin', '--auto'], GitPopenOptions{ safe: true })!
}

pub fn (repository GitRepository) commit_message(commit string, safe bool) !GitRepositoryText {
	message := repository.popen_git(['log', '-1', '--pretty=%B', commit, '--'], GitPopenOptions{
		safe: safe
		err_to_stdout: true
	})!
	if !message.present {
		return message
	}
	return git_repository_some(message.value.trim_space())
}
