module homebrew

import ruby
import os

// Translated from Homebrew/brew `git_repository.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type GitRepositoryRunner = fn(GitRepository, []string, GitPopenOptions) !ruby.CapturedCommandResult

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

// Ruby attr_reader `attr_reader :pathname` at line 11.
pub fn ruby_git_repository_l11_d1_pathname(repository GitRepository) string {
	return repository.pathname
}

// Ruby method `initialize(pathname)` at line 14.
pub fn ruby_git_repository_l14_d2_initialize(pathname string) GitRepository {
	return new_git_repository(pathname)
}

// Ruby method `git_repository?` at line 19.
pub fn ruby_git_repository_l19_d3_git_repository(repository GitRepository) bool {
	return repository.is_git_repository()
}

// Ruby method `origin_url` at line 25.
pub fn ruby_git_repository_l25_d4_origin_url(repository GitRepository) !GitRepositoryText {
	return repository.origin_url()
}

// Ruby method `head_ref(safe: false)` at line 31.
pub fn ruby_git_repository_l31_d5_head_ref(repository GitRepository, safe bool) !GitRepositoryText {
	return repository.head_ref(safe)
}

// Ruby method `short_head_ref(length: nil, safe: false)` at line 37.
pub fn ruby_git_repository_l37_d6_short_head_ref(repository GitRepository, length ?int,
	safe bool) !GitRepositoryText {
	return repository.short_head_ref(length, safe)
}

// Ruby method `last_committed` at line 44.
pub fn ruby_git_repository_l44_d7_last_committed(repository GitRepository) !GitRepositoryText {
	return repository.last_committed()
}

// Ruby method `head_info` at line 52.
pub fn ruby_git_repository_l52_d8_head_info(repository GitRepository) !GitRepositoryHeadInfo {
	return repository.head_info()
}

// Ruby method `branch_name(safe: false)` at line 63.
pub fn ruby_git_repository_l63_d9_branch_name(repository GitRepository, safe bool) !GitRepositoryText {
	return repository.branch_name(safe)
}

// Ruby method `rename_branch(old:, new:)` at line 76.
pub fn ruby_git_repository_l76_d10_rename_branch(repository GitRepository, old string,
	new string) ! {
	repository.rename_branch(old, new)!
}

// Ruby method `set_upstream_branch(local:, origin:)` at line 82.
pub fn ruby_git_repository_l82_d11_set_upstream_branch(repository GitRepository, local string,
	origin string) ! {
	repository.set_upstream_branch(local, origin)!
}

// Ruby method `origin_branch_name` at line 88.
pub fn ruby_git_repository_l88_d12_origin_branch_name(repository GitRepository) !GitRepositoryText {
	return repository.origin_branch_name()
}

// Ruby method `default_origin_branch?` at line 100.
pub fn ruby_git_repository_l100_d13_default_origin_branch(repository GitRepository) !bool {
	return repository.default_origin_branch()
}

// Ruby method `last_commit_date` at line 106.
pub fn ruby_git_repository_l106_d14_last_commit_date(repository GitRepository) !GitRepositoryText {
	return repository.last_commit_date()
}

// Ruby method `origin_has_branch?(branch)` at line 112.
pub fn ruby_git_repository_l112_d15_origin_has_branch(repository GitRepository,
	branch string) !bool {
	return repository.origin_has_branch(branch)
}

// Ruby method `set_head_origin_auto` at line 117.
pub fn ruby_git_repository_l117_d16_set_head_origin_auto(repository GitRepository) ! {
	repository.set_head_origin_auto()!
}

// Ruby method `commit_message(commit = "HEAD", safe: false)` at line 123.
pub fn ruby_git_repository_l123_d17_commit_message(repository GitRepository, commit string,
	safe bool) !GitRepositoryText {
	return repository.commit_message(commit, safe)
}

// Ruby method `to_s = pathname.to_s` at line 128.
pub fn ruby_git_repository_l128_d18_to_s(repository GitRepository) string {
	return repository.pathname
}

// Ruby method `origin_url_from_config` at line 139.
pub fn ruby_git_repository_l139_d19_origin_url_from_config(repository GitRepository) GitRepositoryText {
	return repository.origin_url_from_config()
}

// Ruby method `popen_git(*args, safe: false, err: nil, no_global_config: false)` at line 174.
pub fn ruby_git_repository_l174_d20_popen_git(repository GitRepository, arguments []string,
	options GitPopenOptions) !GitRepositoryText {
	return repository.popen_git(arguments, options)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/git"
// 5: require "utils/popen"
// 6:
// 7: # Given a {Pathname}, provides methods for querying Git repository information.
// 8: # @see Utils::Git
// 9: class GitRepository
// 10:   sig { returns(Pathname) }
// 11:   attr_reader :pathname
// 12:
// 13:   sig { params(pathname: Pathname).void }
// 14:   def initialize(pathname)
// 15:     @pathname = pathname
// 16:   end
// 17:
// 18:   sig { returns(T::Boolean) }
// 19:   def git_repository?
// 20:     pathname.join(".git").exist?
// 21:   end
// 22:
// 23:   # Gets the URL of the Git origin remote.
// 24:   sig { returns(T.nilable(String)) }
// 25:   def origin_url
// 26:     origin_url_from_config || popen_git("config", "--local", "--get", "remote.origin.url", no_global_config: true)
// 27:   end
// 28:
// 29:   # Gets the full commit hash of the HEAD commit.
// 30:   sig { params(safe: T::Boolean).returns(T.nilable(String)) }
// 31:   def head_ref(safe: false)
// 32:     popen_git("rev-parse", "--verify", "--quiet", "HEAD", safe:)
// 33:   end
// 34:
// 35:   # Gets a short commit hash of the HEAD commit.
// 36:   sig { params(length: T.nilable(Integer), safe: T::Boolean).returns(T.nilable(String)) }
// 37:   def short_head_ref(length: nil, safe: false)
// 38:     short_arg = length.present? ? "--short=#{length}" : "--short"
// 39:     popen_git("rev-parse", short_arg, "--verify", "--quiet", "HEAD", safe:)
// 40:   end
// 41:
// 42:   # Gets the relative date of the last commit, e.g. "1 hour ago"
// 43:   sig { returns(T.nilable(String)) }
// 44:   def last_committed
// 45:     popen_git("show", "-s", "--format=%cr", "HEAD")
// 46:   end
// 47:
// 48:   # Gets the full commit hash of the HEAD commit, the relative date of the
// 49:   # last commit and the currently checked-out branch (or HEAD if the
// 50:   # repository is in a detached HEAD state) in a single Git invocation.
// 51:   sig { returns([T.nilable(String), T.nilable(String), T.nilable(String)]) }
// 52:   def head_info
// 53:     output = popen_git("show", "-s", "--format=%H%n%cr%n%D", "HEAD")
// 54:     return [nil, nil, nil] if output.nil?
// 55:
// 56:     head, last_committed, refs = output.lines(chomp: true)
// 57:     branch = refs&.[](/\AHEAD -> ([^,\n]+)/, 1) || "HEAD"
// 58:     [head, last_committed, branch]
// 59:   end
// 60:
// 61:   # Gets the name of the currently checked-out branch, or HEAD if the repository is in a detached HEAD state.
// 62:   sig { params(safe: T::Boolean).returns(T.nilable(String)) }
// 63:   def branch_name(safe: false)
// 64:     ref = popen_git("rev-parse", "--symbolic-full-name", "HEAD", safe:)
// 65:     return if ref.blank?
// 66:     return "HEAD" if ref == "HEAD"
// 67:
// 68:     refs_format = "refs/heads/"
// 69:     return ref.delete_prefix(refs_format) if ref.start_with?(refs_format)
// 70:
// 71:     raise "Unexpected HEAD ref format: #{ref}"
// 72:   end
// 73:
// 74:   # Change the name of a local branch
// 75:   sig { params(old: String, new: String).void }
// 76:   def rename_branch(old:, new:)
// 77:     popen_git("branch", "-m", old, new)
// 78:   end
// 79:
// 80:   # Set an upstream branch for a local branch to track
// 81:   sig { params(local: String, origin: String).void }
// 82:   def set_upstream_branch(local:, origin:)
// 83:     popen_git("branch", "-u", "origin/#{origin}", local)
// 84:   end
// 85:
// 86:   # Gets the name of the default origin HEAD branch.
// 87:   sig { returns(T.nilable(String)) }
// 88:   def origin_branch_name
// 89:     ref = popen_git("symbolic-ref", "-q", "refs/remotes/origin/HEAD")
// 90:     return if ref.blank?
// 91:
// 92:     refs_format = "refs/remotes/origin/"
// 93:     return ref.delete_prefix(refs_format) if ref.start_with?(refs_format)
// 94:
// 95:     raise "Unexpected origin/HEAD ref format: #{ref}"
// 96:   end
// 97:
// 98:   # Returns true if the repository's current branch matches the default origin branch.
// 99:   sig { returns(T.nilable(T::Boolean)) }
// 100:   def default_origin_branch?
// 101:     origin_branch_name == branch_name
// 102:   end
// 103:
// 104:   # Returns the date of the last commit, in YYYY-MM-DD format.
// 105:   sig { returns(T.nilable(String)) }
// 106:   def last_commit_date
// 107:     popen_git("show", "-s", "--format=%cd", "--date=short", "HEAD")
// 108:   end
// 109:
// 110:   # Returns true if the given branch exists on origin
// 111:   sig { params(branch: String).returns(T::Boolean) }
// 112:   def origin_has_branch?(branch)
// 113:     popen_git("ls-remote", "--heads", "origin", branch).present?
// 114:   end
// 115:
// 116:   sig { void }
// 117:   def set_head_origin_auto
// 118:     popen_git("remote", "set-head", "origin", "--auto")
// 119:   end
// 120:
// 121:   # Gets the full commit message of the specified commit, or of the HEAD commit if unspecified.
// 122:   sig { params(commit: String, safe: T::Boolean).returns(T.nilable(String)) }
// 123:   def commit_message(commit = "HEAD", safe: false)
// 124:     popen_git("log", "-1", "--pretty=%B", commit, "--", safe:, err: :out)&.strip
// 125:   end
// 126:
// 127:   sig { returns(String) }
// 128:   def to_s = pathname.to_s
// 129:
// 130:   private
// 131:
// 132:   # Reads `remote.origin.url` straight from `.git/config` to skip spawning
// 133:   # Git on a hot path. Returns `nil` (so the caller falls back to Git) for
// 134:   # anything the canonical form does not cover: a worktree/submodule `.git`
// 135:   # file, an `include`/`includeIf` directive that can define the URL
// 136:   # elsewhere, a non-canonical section header, more than one `url` value, or a
// 137:   # value whose comments/quoting/escapes need Git's own config parser.
// 138:   sig { returns(T.nilable(String)) }
// 139:   def origin_url_from_config
// 140:     config_file = pathname/".git/config"
// 141:     return unless config_file.file?
// 142:
// 143:     content = config_file.read
// 144:     return if content.match?(/^\s*\[include(?:If)?[\s"\]]/i)
// 145:
// 146:     urls = content.lines
// 147:                   .slice_before { |line| line.lstrip.start_with?("[") }
// 148:                   .select { |section| section.fetch(0).strip == '[remote "origin"]' }
// 149:                   .flat_map do |section|
// 150:       section.drop(1).filter_map do |line|
// 151:         stripped = line.strip
// 152:         next if stripped.empty? || stripped.start_with?("#", ";")
// 153:
// 154:         key, separator, value = stripped.partition("=")
// 155:         next if separator.empty? || !key.strip.casecmp?("url")
// 156:
// 157:         value.strip
// 158:       end
// 159:     end
// 160:     return if urls.length != 1
// 161:
// 162:     url = urls.fetch(0)
// 163:     return if url.empty? || url.match?(/["#;\\]/)
// 164:
// 165:     url
// 166:   rescue SystemCallError
// 167:     nil
// 168:   end
// 169:
// 170:   sig {
// 171:     params(args: T.untyped, safe: T::Boolean, err: T.nilable(Symbol), no_global_config: T::Boolean)
// 172:       .returns(T.nilable(String))
// 173:   }
// 174:   def popen_git(*args, safe: false, err: nil, no_global_config: false)
// 175:     unless git_repository?
// 176:       return unless safe
// 177:
// 178:       raise "Not a Git repository: #{pathname}"
// 179:     end
// 180:
// 181:     unless Utils::Git.available?
// 182:       return unless safe
// 183:
// 184:       raise "Git is unavailable"
// 185:     end
// 186:
// 187:     command = [Utils::Git.git, *args]
// 188:     command.unshift(Utils::Git.no_global_config_env) if no_global_config
// 189:     Utils.popen_read(*command, safe:, chdir: pathname, err:).chomp.presence
// 190:   end
// 191: end
