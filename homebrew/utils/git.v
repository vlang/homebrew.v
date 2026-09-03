module utils

import brew_runtime
import os

// Translated from Homebrew/brew `utils/git.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.available?` at line 15.
pub fn ruby_git_l15_d1_self_available(args ...brew_runtime.Value) brew_runtime.Value {
	mut client := git_client_from_args(args)
	return brew_runtime.bool_value(git_client_available(mut client))
}

// Ruby method `self.no_global_config_env` at line 20.
pub fn ruby_git_l20_d2_self_no_global_config_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.map_value({
		'GIT_CONFIG_GLOBAL': brew_runtime.string_value(git_no_global_config_file())
	})
}

// Ruby method `self.no_global_config_file` at line 25.
pub fn ruby_git_l25_d3_self_no_global_config_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(git_no_global_config_file())
}

// Ruby method `self.version` at line 30.
pub fn ruby_git_l30_d4_self_version(args ...brew_runtime.Value) brew_runtime.Value {
	mut client := git_client_from_args(args)
	version := git_client_version(mut client)
	return brew_runtime.object_value('Version', if version == '' { 'NULL' } else { version })
}

// Ruby method `self.path` at line 40.
pub fn ruby_git_l40_d5_self_path(args ...brew_runtime.Value) brew_runtime.Value {
	mut client := git_client_from_args(args)
	if path := git_client_path(mut client) {
		return brew_runtime.string_value(path)
	}
	return git_nil_value()
}

// Ruby method `self.git` at line 48.
pub fn ruby_git_l48_d6_self_git(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(git_default_executable())
}

// Ruby method `self.remote_exists?(url)` at line 53.
pub fn ruby_git_l53_d7_self_remote_exists(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Utils::Git.remote_exists? requires a URL') }
	mut client := git_default_client()
	return brew_runtime.bool_value(git_client_remote_exists(mut client, args[0].as_string()))
}

// Ruby method `self.clear_available_cache` at line 60.
pub fn ruby_git_l60_d8_self_clear_available_cache(args ...brew_runtime.Value) brew_runtime.Value {
	mut client := git_client_from_args(args)
	git_client_clear_available_cache(mut client)
	return git_nil_value()
}

// Ruby method `self.last_revision_commit_of_file(repo, file, before_commit: nil)` at line 70.
pub fn ruby_git_l70_d9_self_last_revision_commit_of_file(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('last_revision_commit_of_file requires repo and file') }
	before := if args.len > 2 && args[2].type_name != 'NilClass' { args[2].as_string() } else { '' }
	result := git_last_revision_commit_of_file(git_default_executable(), args[0].as_string(), args[1].as_string(), before, git_run_command) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return brew_runtime.string_value(result)
}

// Ruby method `self.last_revision_commit_of_files(repo, files, before_commit: nil)` at line 87.
pub fn ruby_git_l87_d10_self_last_revision_commit_of_files(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('last_revision_commit_of_files requires repo and files') }
	before := if args.len > 2 && args[2].type_name != 'NilClass' { args[2].as_string() } else { '' }
	result := git_last_revision_commit_of_files(git_default_executable(), args[0].as_string(), args[1].as_string_array() or { args[1].array_data.map(it.as_string()) }, before, git_run_command) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return brew_runtime.map_value({
		'commit': if result.commit == '' {
			git_nil_value()
		} else {
			brew_runtime.string_value(result.commit)
		}
		'paths':  brew_runtime.string_array_value(result.paths)
	})
}

// Ruby method `self.last_revision_of_file(repo, file, before_commit: nil)` at line 112.
pub fn ruby_git_l112_d11_self_last_revision_of_file(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('last_revision_of_file requires repo and file') }
	before := if args.len > 2 && args[2].type_name != 'NilClass' { args[2].as_string() } else { '' }
	result := git_last_revision_of_file(git_default_executable(), args[0].as_string(), args[1].as_string(), before, git_run_command) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return brew_runtime.string_value(result)
}

// Ruby method `self.file_at_commit(repo, file, commit)` at line 119.
pub fn ruby_git_l119_d12_self_file_at_commit(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('file_at_commit requires repo, file and commit') }
	result := git_file_at_commit(git_default_executable(), args[0].as_string(), args[1].as_string(), args[2].as_string(), git_run_command) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return brew_runtime.string_value(result)
}

// Ruby method `self.changed_files(repository)` at line 131.
pub fn ruby_git_l131_d13_self_changed_files(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('changed_files requires a repository') }
	result := git_changed_files(git_default_executable(), args[0].as_string(), git_run_command) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.string_array_value(result)
}

// Ruby method `self.ensure_installed!` at line 138.
pub fn ruby_git_l138_d14_self_ensure_installed(args ...brew_runtime.Value) brew_runtime.Value {
	mut client := git_default_client()
	git_ensure_installed(mut client, GitInstallOptions{}) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return git_nil_value()
}

// Ruby method `self.set_name_email!(author: true, committer: true)` at line 160.
pub fn ruby_git_l160_d15_self_set_name_email(args ...brew_runtime.Value) brew_runtime.Value {
	author := if args.len > 0 { args[0].bool_data } else { true }
	committer := if args.len > 1 { args[1].bool_data } else { true }
	values := git_name_email_environment(brew_runtime.environment(), GitIdentityConfig{
		git_name: os.getenv('HOMEBREW_GIT_NAME')
		git_committer_name: os.getenv('HOMEBREW_GIT_COMMITTER_NAME')
		git_email: os.getenv('HOMEBREW_GIT_EMAIL')
		git_committer_email: os.getenv('HOMEBREW_GIT_COMMITTER_EMAIL')
	}, author, committer)
	for key, value in values {
		os.setenv(key, value, true)
	}
	return git_nil_value()
}

// Ruby method `self.setup_gpg!` at line 182.
pub fn ruby_git_l182_d16_self_setup_gpg(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := if args.len > 0 { args[0].as_string() } else { git_homebrew_prefix() }
	updated := git_setup_gpg_path(prefix, os.getenv('PATH'))
	if updated != os.getenv('PATH') { os.setenv('PATH', updated, true) }
	return git_nil_value()
}

// Ruby method `self.cherry_pick!(repo, *args, resolve: false, verbose: false)` at line 192.
pub fn ruby_git_l192_d17_self_cherry_pick(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('cherry_pick! requires repo and commit arguments') }
	resolve := if args.len > 2 { args[2].bool_data } else { false }
	verbose := if args.len > 3 { args[3].bool_data } else { false }
	output := git_cherry_pick(git_default_executable(), args[0].as_string(), [
		args[1].as_string(),
	], resolve, verbose, git_run_command) or { return brew_runtime.object_value('ErrorDuringExecution', err.msg()) }
	return brew_runtime.string_value(output)
}

// Ruby method `self.supports_partial_clone_sparse_checkout?` at line 205.
pub fn ruby_git_l205_d18_self_supports_partial_clone_sparse_checkout(args ...brew_runtime.Value) brew_runtime.Value {
	mut client := git_client_from_args(args)
	return brew_runtime.bool_value(git_supports_partial_clone_sparse_checkout(git_client_version(mut client)))
}

pub struct GitCommandResult {
pub:
	exit_code int
	stdout    string
	stderr    string
}

pub type GitCommandRunner = fn([]string) !GitCommandResult

pub type GitInstaller = fn() !string

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
	result := brew_runtime.run_captured_command(command, brew_runtime.CapturedCommandOptions{
		environment: brew_runtime.environment()
	})!
	return GitCommandResult{ exit_code: result.exit_code, stdout: result.stdout, stderr: result.stderr }
}

fn git_run_version_command(command []string) !GitCommandResult {
	mut environment := brew_runtime.environment()
	environment['GIT_CONFIG_GLOBAL'] = git_no_global_config_file()
	result := brew_runtime.run_captured_command(command, brew_runtime.CapturedCommandOptions{
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

fn git_client_from_args(args []brew_runtime.Value) GitClient {
	git := if args.len > 0 && args[0].type_name == 'String' {
		args[0].as_string()
	} else {
		git_default_executable()
	}
	return GitClient{ git: git }
}

fn git_nil_value() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5: require "utils/path"
// 6:
// 7: module Utils
// 8:   # Helper functions for querying Git information.
// 9:   #
// 10:   # @see GitRepository
// 11:   module Git
// 12:     extend SystemCommand::Mixin
// 13:
// 14:     sig { returns(T::Boolean) }
// 15:     def self.available?
// 16:       !version.null?
// 17:     end
// 18:
// 19:     sig { returns(T::Hash[String, String]) }
// 20:     def self.no_global_config_env
// 21:       { "GIT_CONFIG_GLOBAL" => no_global_config_file }
// 22:     end
// 23:
// 24:     sig { returns(String) }
// 25:     def self.no_global_config_file
// 26:       File::NULL
// 27:     end
// 28:
// 29:     sig { returns(Version) }
// 30:     def self.version
// 31:       @version ||= T.let(begin
// 32:         stdout, _, status = system_command(git, args: ["--version"], env: no_global_config_env,
// 33:                                                 verbose: false, print_stderr: false).to_a
// 34:         version_str = status.success? ? stdout.chomp[/git version (\d+(?:\.\d+)*)/, 1] : nil
// 35:         version_str.nil? ? Version::NULL : Version.new(version_str)
// 36:       end, T.nilable(Version))
// 37:     end
// 38:
// 39:     sig { returns(T.nilable(String)) }
// 40:     def self.path
// 41:       return unless available?
// 42:       return @path if defined?(@path)
// 43:
// 44:       @path = T.let(Utils.popen_read(git, "--homebrew=print-path").chomp.presence, T.nilable(String))
// 45:     end
// 46:
// 47:     sig { returns(Pathname) }
// 48:     def self.git
// 49:       @git ||= T.let(HOMEBREW_SHIMS_PATH/"shared/git", T.nilable(Pathname))
// 50:     end
// 51:
// 52:     sig { params(url: String).returns(T::Boolean) }
// 53:     def self.remote_exists?(url)
// 54:       return true unless available?
// 55:
// 56:       quiet_system "git", "ls-remote", "--end-of-options", url
// 57:     end
// 58:
// 59:     sig { void }
// 60:     def self.clear_available_cache
// 61:       remove_instance_variable(:@version) if defined?(@version)
// 62:       remove_instance_variable(:@path) if defined?(@path)
// 63:       remove_instance_variable(:@git) if defined?(@git)
// 64:     end
// 65:
// 66:     sig {
// 67:       params(repo: T.any(Pathname, String), file: T.any(Pathname, String),
// 68:              before_commit: T.nilable(String)).returns(String)
// 69:     }
// 70:     def self.last_revision_commit_of_file(repo, file, before_commit: nil)
// 71:       args = if before_commit.nil?
// 72:         ["--skip=1"]
// 73:       else
// 74:         [before_commit.split("..").first]
// 75:       end
// 76:
// 77:       Utils.popen_read(git, "-C", repo, "log", "--format=%h", "--abbrev=7", "--max-count=1", *args, "--", file).chomp
// 78:     end
// 79:
// 80:     sig {
// 81:       params(
// 82:         repo:          T.any(Pathname, String),
// 83:         files:         T::Array[T.any(Pathname, String)],
// 84:         before_commit: T.nilable(String),
// 85:       ).returns([T.nilable(String), T::Array[String]])
// 86:     }
// 87:     def self.last_revision_commit_of_files(repo, files, before_commit: nil)
// 88:       args = if before_commit.nil?
// 89:         ["--skip=1"]
// 90:       else
// 91:         [before_commit.split("..").first]
// 92:       end
// 93:
// 94:       # git log output format:
// 95:       #   <commit_hash>
// 96:       #   <file_path1>
// 97:       #   <file_path2>
// 98:       #   ...
// 99:       # return [<commit_hash>, [file_path1, file_path2, ...]]
// 100:       rev, *paths = Utils.popen_read(
// 101:         git, "-C", repo, "log",
// 102:         "--pretty=format:%h", "--abbrev=7", "--max-count=1",
// 103:         "--diff-filter=d", "--name-only", *args, "--", *files
// 104:       ).lines.map(&:chomp).reject(&:empty?)
// 105:       [rev, paths]
// 106:     end
// 107:
// 108:     sig {
// 109:       params(repo: T.any(Pathname, String), file: T.any(Pathname, String), before_commit: T.nilable(String))
// 110:         .returns(String)
// 111:     }
// 112:     def self.last_revision_of_file(repo, file, before_commit: nil)
// 113:       relative_file = Pathname(file).relative_path_from(repo)
// 114:       commit_hash = last_revision_commit_of_file(repo, relative_file, before_commit:)
// 115:       file_at_commit(repo, file, commit_hash)
// 116:     end
// 117:
// 118:     sig { params(repo: T.any(Pathname, String), file: T.any(Pathname, String), commit: String).returns(String) }
// 119:     def self.file_at_commit(repo, file, commit)
// 120:       relative_file = Pathname(file)
// 121:       relative_file = relative_file.relative_path_from(repo) if relative_file.absolute?
// 122:       Utils.popen_read(git, "-C", repo, "show", "#{commit}:#{relative_file}")
// 123:     end
// 124:
// 125:     # The paths (relative to `repository`'s root) changed in its working tree
// 126:     # since it diverged from the upstream default branch. The base is the
// 127:     # `origin/HEAD` merge-base rather than the local default branch ref, which
// 128:     # is often stale (e.g. in worktrees and freshly-cloned taps); it falls back
// 129:     # to `main` when `origin/HEAD` is unavailable.
// 130:     sig { params(repository: T.any(Pathname, String)).returns(T::Array[String]) }
// 131:     def self.changed_files(repository)
// 132:       base_ref = Utils.popen_read(git, "-C", repository, "merge-base", "origin/HEAD", "HEAD").chomp.presence
// 133:       base_ref ||= "main"
// 134:       Utils.popen_read(git, "-C", repository, "diff", "--name-only", "--no-relative", base_ref).split("\n")
// 135:     end
// 136:
// 137:     sig { void }
// 138:     def self.ensure_installed!
// 139:       return if available?
// 140:
// 141:       # we cannot install brewed git if homebrew/core is unavailable.
// 142:       if CoreTap.instance.installed?
// 143:         begin
// 144:           # Otherwise `git` will be installed from source in tests that need it. This is slow
// 145:           # and will also likely fail due to `OS::Linux` and `OS::Mac` being undefined.
// 146:           raise "Refusing to install Git on a generic OS." if ENV["HOMEBREW_TEST_GENERIC_OS"]
// 147:
// 148:           require "formula"
// 149:           Formula["git"].ensure_installed!(executable: "git")
// 150:           clear_available_cache
// 151:         rescue
// 152:           raise "Git is unavailable"
// 153:         end
// 154:       end
// 155:
// 156:       raise "Git is unavailable" unless available?
// 157:     end
// 158:
// 159:     sig { params(author: T::Boolean, committer: T::Boolean).void }
// 160:     def self.set_name_email!(author: true, committer: true)
// 161:       if Homebrew::EnvConfig.git_name
// 162:         ENV["GIT_AUTHOR_NAME"] = Homebrew::EnvConfig.git_name if author
// 163:         ENV["GIT_COMMITTER_NAME"] = Homebrew::EnvConfig.git_name if committer
// 164:       end
// 165:
// 166:       if Homebrew::EnvConfig.git_committer_name && committer
// 167:         ENV["GIT_COMMITTER_NAME"] = Homebrew::EnvConfig.git_committer_name
// 168:       end
// 169:
// 170:       if Homebrew::EnvConfig.git_email
// 171:         ENV["GIT_AUTHOR_EMAIL"] = Homebrew::EnvConfig.git_email if author
// 172:         ENV["GIT_COMMITTER_EMAIL"] = Homebrew::EnvConfig.git_email if committer
// 173:       end
// 174:
// 175:       return unless committer
// 176:       return unless Homebrew::EnvConfig.git_committer_email
// 177:
// 178:       ENV["GIT_COMMITTER_EMAIL"] = Homebrew::EnvConfig.git_committer_email
// 179:     end
// 180:
// 181:     sig { void }
// 182:     def self.setup_gpg!
// 183:       gnupg_bin = Utils::Path.formula_opt_bin("gnupg")
// 184:       return unless gnupg_bin.directory?
// 185:
// 186:       ENV["PATH"] = PATH.new(ENV.fetch("PATH")).prepend(gnupg_bin).to_s
// 187:     end
// 188:
// 189:     # Special case of `git cherry-pick` that permits non-verbose output and
// 190:     # optional resolution on merge conflict.
// 191:     sig { params(repo: T.any(Pathname, String), args: String, resolve: T::Boolean, verbose: T::Boolean).returns(String) }
// 192:     def self.cherry_pick!(repo, *args, resolve: false, verbose: false)
// 193:       cmd = [git.to_s, "-C", repo, "cherry-pick"] + args
// 194:       output = Utils.popen_read(*cmd, err: :out)
// 195:       if $CHILD_STATUS.success?
// 196:         puts output if verbose
// 197:         output
// 198:       else
// 199:         system git.to_s, "-C", repo.to_s, "cherry-pick", "--abort" unless resolve
// 200:         raise ErrorDuringExecution.new(cmd, status: $CHILD_STATUS, output: [[:stdout, output]])
// 201:       end
// 202:     end
// 203:
// 204:     sig { returns(T::Boolean) }
// 205:     def self.supports_partial_clone_sparse_checkout?
// 206:       # There is some support for partial clones prior to 2.20, but we avoid using it
// 207:       # due to performance issues
// 208:       version >= Version.new("2.20.0")
// 209:     end
// 210:   end
// 211: end
