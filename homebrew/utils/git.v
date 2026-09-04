module utils

import ruby
import os

// Translated from Homebrew/brew `utils/git.rb`.

pub struct GitCommandResult {
pub:
	exit_code int
	stdout    string
	stderr    string
}

pub type GitCommandRunner = fn ([]string) !GitCommandResult

pub type GitInstaller = fn () !string

pub struct GitClient {
pub:
	git string
mut:
	runner         GitCommandRunner = git_run_command
	version_runner GitCommandRunner = git_run_version_command
	version_loaded bool
	version_value  string
	path_loaded    bool
	path_present   bool
	path_value     string
}

pub struct GitRevisionFiles {
pub:
	commit string
	paths  []string
}

pub struct GitInstallOptions {
pub:
	core_tap_installed  bool
	generic_os          bool
	installer           ?GitInstaller
	post_install_runner ?GitCommandRunner
}

pub struct GitIdentityConfig {
pub:
	git_name            string
	git_committer_name  string
	git_email           string
	git_committer_email string
}

pub fn git_no_global_config_file() string {
	return os.path_devnull
}

pub fn git_default_client() GitClient {
	return GitClient{ git: git_default_executable() }
}

pub fn git_client_with_runner(git string, runner GitCommandRunner) GitClient {
	return GitClient{ git: git, runner: runner, version_runner: runner }
}

pub fn git_client_version(mut client GitClient) string {
	if client.version_loaded {
		return client.version_value
	}
	client.version_loaded = true
	result := client.version_runner([client.git, '--version']) or { return '' }
	if result.exit_code != 0 {
		return ''
	}
	client.version_value = git_parse_version(result.stdout)
	return client.version_value
}

pub fn git_client_available(mut client GitClient) bool {
	return git_client_version(mut client) != ''
}

pub fn git_client_path(mut client GitClient) ?string {
	if !git_client_available(mut client) {
		return none
	}
	if client.path_loaded {
		return if client.path_present { client.path_value } else { none }
	}
	client.path_loaded = true
	result := client.runner([client.git, '--homebrew=print-path']) or { return none }
	client.path_value = result.stdout.trim_space()
	client.path_present = client.path_value != ''
	return if client.path_present { client.path_value } else { none }
}

pub fn git_client_remote_exists(mut client GitClient, url string) bool {
	if !git_client_available(mut client) {
		return true
	}
	result := client.runner(['git', 'ls-remote', '--end-of-options', url]) or { return false }
	return result.exit_code == 0
}

pub fn git_client_clear_available_cache(mut client GitClient) {
	client.version_loaded = false
	client.version_value = ''
	client.path_loaded = false
	client.path_present = false
	client.path_value = ''
}

pub fn git_last_revision_commit_of_file(git string, repo string, file string, before_commit string,
	runner GitCommandRunner) !string {
	mut command := [git, '-C', repo, 'log', '--format=%h', '--abbrev=7', '--max-count=1']
	command << git_before_commit_args(before_commit)
	command << ['--', file]
	return runner(command)!.stdout.trim_space()
}

pub fn git_last_revision_commit_of_files(git string, repo string, files []string, before_commit string,
	runner GitCommandRunner) !GitRevisionFiles {
	mut command := [git, '-C', repo, 'log', '--pretty=format:%h', '--abbrev=7', '--max-count=1',
		'--diff-filter=d', '--name-only']
	command << git_before_commit_args(before_commit)
	command << '--'
	command << files
	lines := runner(command)!.stdout.split_into_lines().map(it.trim_string_right('\r')).filter(it != '')
	return GitRevisionFiles{
		commit: if lines.len > 0 { lines[0] } else { '' }
		paths: if lines.len > 1 { lines[1..].clone() } else { []string{} }
	}
}

pub fn git_last_revision_of_file(git string, repo string, file string, before_commit string,
	runner GitCommandRunner) !string {
	relative_file := git_relative_file(repo, file)
	commit := git_last_revision_commit_of_file(git, repo, relative_file, before_commit, runner)!
	return git_file_at_commit(git, repo, file, commit, runner)
}

pub fn git_file_at_commit(git string, repo string, file string, commit string,
	runner GitCommandRunner) !string {
	relative_file := git_relative_file(repo, file)
	return runner([git, '-C', repo, 'show', '${commit}:${relative_file}'])!.stdout
}

pub fn git_changed_files(git string, repository string, runner GitCommandRunner) ![]string {
	base_result := runner([git, '-C', repository, 'merge-base', 'origin/HEAD', 'HEAD'])!
	base_ref := if base_result.stdout.trim_space() != '' {
		base_result.stdout.trim_space()
	} else {
		'main'
	}
	result := runner([git, '-C', repository, 'diff', '--name-only', '--no-relative', base_ref])!
	return result.stdout.trim_string_right('\n').split('\n').filter(it != '')
}

pub fn git_ensure_installed(mut client GitClient, options GitInstallOptions) ! {
	if git_client_available(mut client) {
		return
	}
	if options.core_tap_installed {
		if options.generic_os {
			return error('Git is unavailable')
		}
		if installer := options.installer {
			installer() or { return error('Git is unavailable') }
			if runner := options.post_install_runner {
				client.runner = runner
				client.version_runner = runner
			}
			git_client_clear_available_cache(mut client)
		} else {
			return error('Git is unavailable')
		}
	}
	if !git_client_available(mut client) {
		return error('Git is unavailable')
	}
}

pub fn git_name_email_environment(environment map[string]string, config GitIdentityConfig, author bool,
	committer bool) map[string]string {
	mut output := environment.clone()
	if config.git_name != '' {
		if author {
			output['GIT_AUTHOR_NAME'] = config.git_name
		}
		if committer {
			output['GIT_COMMITTER_NAME'] = config.git_name
		}
	}
	if config.git_committer_name != '' && committer {
		output['GIT_COMMITTER_NAME'] = config.git_committer_name
	}
	if config.git_email != '' {
		if author {
			output['GIT_AUTHOR_EMAIL'] = config.git_email
		}
		if committer {
			output['GIT_COMMITTER_EMAIL'] = config.git_email
		}
	}
	if committer && config.git_committer_email != '' {
		output['GIT_COMMITTER_EMAIL'] = config.git_committer_email
	}
	return output
}

pub fn git_setup_gpg_path(prefix string, current_path string) string {
	gnupg_bin := path_formula_opt_bin(prefix, 'gnupg')
	return if os.is_dir(gnupg_bin) {
		[gnupg_bin, current_path].filter(it != '').join(os.path_delimiter)
	} else {
		current_path
	}
}

pub fn git_cherry_pick(git string, repo string, args []string, resolve bool, verbose bool,
	runner GitCommandRunner) !string {
	mut command := [git, '-C', repo, 'cherry-pick']
	command << args
	result := runner(command)!
	output := result.stdout + result.stderr
	if result.exit_code == 0 {
		if verbose { print(output) }
		return output
	}
	if !resolve {
		_ = runner([git, '-C', repo, 'cherry-pick', '--abort']) or { GitCommandResult{} }
	}
	return error('ErrorDuringExecution: ${command.join(' ')}\n${output}')
}

pub fn git_supports_partial_clone_sparse_checkout(version string) bool {
	return git_compare_versions(version, '2.20.0') >= 0
}

pub fn git_parse_version(output string) string {
	marker := 'git version '
	start := output.index(marker) or { return '' }
	mut version := ''
	for character in output[start + marker.len..] {
		if (character >= `0` && character <= `9`) || character == `.` {
			version += character.ascii_str()
		} else {
			break
		}
	}
	return version.trim_string_right('.')
}

fn git_before_commit_args(before_commit string) []string {
	return if before_commit == '' {
		['--skip=1']
	} else {
		[
			before_commit.all_before('..'),
		]
	}
}

fn git_relative_file(repo string, file string) string {
	absolute_repo := os.norm_path(os.abs_path(repo))
	absolute_file := os.norm_path(os.abs_path(file))
	if os.is_abs_path(file) && path_child_of(absolute_repo, absolute_file) {
		return absolute_file.trim_string_left('${absolute_repo}${os.path_separator}')
	}
	return file
}

fn git_compare_versions(left string, right string) int {
	left_parts := left.split('.').map(it.int())
	right_parts := right.split('.').map(it.int())
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_value := if index < left_parts.len { left_parts[index] } else { 0 }
		right_value := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_value < right_value {
			return -1
		}
		if left_value > right_value {
			return 1
		}
	}
	return 0
}

fn git_run_command(command []string) !GitCommandResult {
	result := ruby.run_captured_command(command, ruby.CapturedCommandOptions{
		environment: ruby.environment()
	})!
	return GitCommandResult{ exit_code: result.exit_code, stdout: result.stdout, stderr: result.stderr }
}

fn git_run_version_command(command []string) !GitCommandResult {
	mut environment := ruby.environment()
	environment['GIT_CONFIG_GLOBAL'] = git_no_global_config_file()
	result := ruby.run_captured_command(command, ruby.CapturedCommandOptions{
		environment: environment
	})!
	return GitCommandResult{ exit_code: result.exit_code, stdout: result.stdout, stderr: result.stderr }
}

fn git_default_executable() string {
	shims := os.getenv('HOMEBREW_SHIMS_PATH')
	if shims != '' {
		return os.join_path(shims, 'shared', 'git')
	}
	return os.find_abs_path_of_executable('git') or { 'git' }
}

fn git_homebrew_prefix() string {
	prefix := os.getenv('HOMEBREW_PREFIX')
	return if prefix != '' { prefix } else { '/usr/local' }
}

fn git_client_from_args(args []ruby.Value) GitClient {
	git := if args.len > 0 && args[0].type_name == 'String' {
		args[0].as_string()
	} else {
		git_default_executable()
	}
	return GitClient{ git: git }
}

fn git_nil_value() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}
