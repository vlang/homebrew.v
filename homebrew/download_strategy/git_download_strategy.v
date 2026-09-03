module download_strategy

import brew_runtime
import os
import time

// Translated from Homebrew/brew `download_strategy/git_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

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
		brew_runtime.atomic_write_file(dot_git, 'gitdir: ${relative}\n')!
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
pub fn ruby_git_download_strategy_l11_d1_initialize(url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	return new_git_download_strategy(url, name, version, meta)
}

pub fn ruby_git_download_strategy_l31_d2_source_modified_time(strategy &VCSDownloadStrategy) !i64 {
	return strategy.git_source_modified_time()
}

pub fn ruby_git_download_strategy_l40_d3_source_revision(strategy &VCSDownloadStrategy) !string {
	return strategy.git_source_revision()
}

pub fn ruby_git_download_strategy_l46_d4_last_commit(strategy &VCSDownloadStrategy) !string {
	return strategy.git_last_commit()
}

pub fn ruby_git_download_strategy_l53_d5_ref(strategy &VCSDownloadStrategy) bool {
	return strategy.git_ref()
}

pub fn ruby_git_download_strategy_l61_d6_clone_args(strategy &VCSDownloadStrategy) []string {
	return strategy.git_clone_args()
}

pub fn ruby_git_download_strategy_l81_d7_env(strategy &VCSDownloadStrategy) map[string]string {
	return strategy.git_env()
}

pub fn ruby_git_download_strategy_l90_d8_local_git_env(strategy &VCSDownloadStrategy) map[string]string {
	return strategy.git_local_env()
}

pub fn ruby_git_download_strategy_l96_d9_cache_tag(strategy &VCSDownloadStrategy) string {
	return strategy.git_cache_tag()
}

pub fn ruby_git_download_strategy_l105_d10_cache_version(strategy &VCSDownloadStrategy) int {
	return strategy.git_cache_version()
}

pub fn ruby_git_download_strategy_l110_d11_update(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.git_update(deadline)!
}

pub fn ruby_git_download_strategy_l119_d12_shallow_dir(strategy &VCSDownloadStrategy) bool {
	return strategy.git_shallow_dir()
}

pub fn ruby_git_download_strategy_l124_d13_git_dir(strategy &VCSDownloadStrategy) string {
	return strategy.git_dir()
}

pub fn ruby_git_download_strategy_l129_d14_current_revision(strategy &VCSDownloadStrategy) !string {
	return strategy.git_current_revision()
}

pub fn ruby_git_download_strategy_l135_d15_repo_valid(strategy &VCSDownloadStrategy) bool {
	return strategy.git_repo_valid()
}

pub fn ruby_git_download_strategy_l140_d16_submodules(strategy &VCSDownloadStrategy) bool {
	return strategy.git_submodules()
}

pub fn ruby_git_download_strategy_l145_d17_partial_clone_sparse_checkout(strategy &VCSDownloadStrategy) bool {
	return strategy.git_partial_clone_sparse_checkout()
}

pub fn ruby_git_download_strategy_l153_d18_refspec(strategy &VCSDownloadStrategy) string {
	return strategy.git_refspec()
}

pub fn ruby_git_download_strategy_l162_d19_default_refspec(strategy &VCSDownloadStrategy) string {
	return strategy.git_default_refspec()
}

pub fn ruby_git_download_strategy_l168_d20_config_repo(strategy &VCSDownloadStrategy, deadline ?i64) ! {
	strategy.git_config_repo(deadline)!
}

pub fn ruby_git_download_strategy_l194_d21_update_repo(strategy &VCSDownloadStrategy, deadline ?i64) ! {
	strategy.git_update_repo(deadline)!
}

pub fn ruby_git_download_strategy_l214_d22_clone_repo(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.git_clone_repo(deadline)!
}

pub fn ruby_git_download_strategy_l232_d23_checkout(strategy &VCSDownloadStrategy, deadline ?i64) ! {
	strategy.git_checkout(deadline)!
}

pub fn ruby_git_download_strategy_l239_d24_reset(strategy &VCSDownloadStrategy, deadline ?i64) ! {
	strategy.git_reset(deadline)!
}

pub fn ruby_git_download_strategy_l253_d25_update_submodules(strategy &VCSDownloadStrategy, deadline ?i64) ! {
	strategy.git_update_submodules(deadline)!
}

pub fn ruby_git_download_strategy_l275_d26_fix_absolute_submodule_gitdir_references(strategy &VCSDownloadStrategy) ! {
	strategy.git_fix_absolute_submodule_gitdir_references()!
}

pub fn ruby_git_download_strategy_l304_d27_configure_sparse_checkout(strategy &VCSDownloadStrategy, deadline ?i64) ! {
	strategy.git_configure_sparse_checkout(deadline)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading a Git repository.
// 5: #
// 6: # @api public
// 7: class GitDownloadStrategy < VCSDownloadStrategy
// 8:   MINIMUM_COMMIT_HASH_LENGTH = 7
// 9:
// 10:   sig { params(url: String, name: String, version: T.nilable(T.any(String, Version)), meta: T.untyped).void }
// 11:   def initialize(url, name, version, **meta)
// 12:     # Needs to be before the call to `super`, as the VCSDownloadStrategy's
// 13:     # constructor calls `cache_tag` and sets the cache path.
// 14:     @only_path = meta[:only_path]
// 15:
// 16:     if @only_path.present?
// 17:       # "Cone" mode of sparse checkout requires patterns to be directories
// 18:       @only_path = T.let("/#{@only_path}", String) unless @only_path.start_with?("/")
// 19:       @only_path = T.let("#{@only_path}/", String) unless @only_path.end_with?("/")
// 20:     end
// 21:
// 22:     super
// 23:     @ref_type ||= T.let(:branch, T.nilable(Symbol))
// 24:     @ref ||= T.let("master", T.untyped)
// 25:   end
// 26:
// 27:   # Returns the most recent modified time for all files in the current working directory after stage.
// 28:   #
// 29:   # @api public
// 30:   sig { override.returns(Time) }
// 31:   def source_modified_time
// 32:     result = system_command("git", args: ["--git-dir", git_dir, "show", "-s", "--format=%cD"],
// 33:                                    env:  local_git_env, print_stderr: false)
// 34:     raise "Failed to read the Git commit time:\n#{result.stderr}" unless result.success?
// 35:
// 36:     Time.parse(result.stdout)
// 37:   end
// 38:
// 39:   sig { override.returns(T.nilable(String)) }
// 40:   def source_revision = current_revision.presence
// 41:
// 42:   # Return last commit's unique identifier for the repository if fetched locally.
// 43:   #
// 44:   # @api public
// 45:   sig { override.returns(String) }
// 46:   def last_commit
// 47:     args = ["--git-dir", git_dir, "rev-parse", "--short=#{MINIMUM_COMMIT_HASH_LENGTH}", "HEAD"]
// 48:     @last_commit ||= system_command("git", args:, env: local_git_env, print_stderr: false).stdout.chomp.presence
// 49:     @last_commit || ""
// 50:   end
// 51:
// 52:   sig { returns(T::Boolean) }
// 53:   def ref?
// 54:     silent_command("git",
// 55:                    args: ["--git-dir", git_dir, "rev-parse", "-q", "--verify", "--end-of-options",
// 56:                           "#{@ref}^{commit}"])
// 57:       .success?
// 58:   end
// 59:
// 60:   sig { returns(T::Array[String]) }
// 61:   def clone_args
// 62:     args = %w[clone]
// 63:
// 64:     case @ref_type
// 65:     when :branch, :tag
// 66:       args << "--branch" << @ref
// 67:     end
// 68:
// 69:     args << "--no-checkout" << "--filter=blob:none" if partial_clone_sparse_checkout?
// 70:
// 71:     args << "--config" << "advice.detachedHead=false" # Silences “detached head” warning.
// 72:     args << "--config" << "core.fsmonitor=false" # Prevent `fsmonitor` from watching this repository.
// 73:     args << "--end-of-options" << @url << cached_location.to_s
// 74:   end
// 75:
// 76:   private
// 77:
// 78:   # Read user Git config so credential helpers work for private downloads,
// 79:   # but never block on an interactive credential prompt.
// 80:   sig { override.returns(T::Hash[String, String]) }
// 81:   def env
// 82:     { "GIT_TERMINAL_PROMPT" => "0" }
// 83:   end
// 84:
// 85:   # Local, read-only repository inspections (`git --git-dir … rev-parse`/`show`)
// 86:   # can run while staging inside the sandbox, where reading the user's global Git
// 87:   # config is denied and makes Git exit. Null it here, unlike the download-time
// 88:   # commands that read it for credential helpers.
// 89:   sig { returns(T::Hash[String, String]) }
// 90:   def local_git_env
// 91:     require "utils/git"
// 92:     env.merge(Utils::Git.no_global_config_env)
// 93:   end
// 94:
// 95:   sig { override.returns(String) }
// 96:   def cache_tag
// 97:     if partial_clone_sparse_checkout?
// 98:       "git-sparse"
// 99:     else
// 100:       "git"
// 101:     end
// 102:   end
// 103:
// 104:   sig { returns(Integer) }
// 105:   def cache_version
// 106:     0
// 107:   end
// 108:
// 109:   sig { override.params(timeout: T.nilable(Time)).void }
// 110:   def update(timeout: nil)
// 111:     config_repo
// 112:     update_repo(timeout:)
// 113:     checkout(timeout:)
// 114:     reset
// 115:     update_submodules(timeout:) if submodules?
// 116:   end
// 117:
// 118:   sig { returns(T::Boolean) }
// 119:   def shallow_dir?
// 120:     (git_dir/"shallow").exist?
// 121:   end
// 122:
// 123:   sig { returns(Pathname) }
// 124:   def git_dir
// 125:     cached_location/".git"
// 126:   end
// 127:
// 128:   sig { override.returns(String) }
// 129:   def current_revision
// 130:     system_command("git", args: ["--git-dir", git_dir, "rev-parse", "-q", "--verify", "HEAD"],
// 131:                           env: local_git_env, print_stderr: false).stdout.strip
// 132:   end
// 133:
// 134:   sig { override.returns(T::Boolean) }
// 135:   def repo_valid?
// 136:     silent_command("git", args: ["-C", cached_location, "status", "-s"]).success?
// 137:   end
// 138:
// 139:   sig { returns(T::Boolean) }
// 140:   def submodules?
// 141:     (cached_location/".gitmodules").exist?
// 142:   end
// 143:
// 144:   sig { returns(T::Boolean) }
// 145:   def partial_clone_sparse_checkout?
// 146:     return false if @only_path.blank?
// 147:
// 148:     require "utils/git"
// 149:     Utils::Git.supports_partial_clone_sparse_checkout?
// 150:   end
// 151:
// 152:   sig { returns(String) }
// 153:   def refspec
// 154:     case @ref_type
// 155:     when :branch then "+refs/heads/#{@ref}:refs/remotes/origin/#{@ref}"
// 156:     when :tag    then "+refs/tags/#{@ref}:refs/tags/#{@ref}"
// 157:     else              default_refspec
// 158:     end
// 159:   end
// 160:
// 161:   sig { returns(String) }
// 162:   def default_refspec
// 163:     # https://git-scm.com/book/en/v2/Git-Internals-The-Refspec
// 164:     "+refs/heads/*:refs/remotes/origin/*"
// 165:   end
// 166:
// 167:   sig { void }
// 168:   def config_repo
// 169:     command! "git",
// 170:              args:  ["config", "remote.origin.url", @url],
// 171:              chdir: cached_location
// 172:     command! "git",
// 173:              args:  ["config", "remote.origin.fetch", refspec],
// 174:              chdir: cached_location
// 175:     command! "git",
// 176:              args:  ["config", "remote.origin.tagOpt", "--no-tags"],
// 177:              chdir: cached_location
// 178:     command! "git",
// 179:              args:  ["config", "advice.detachedHead", "false"],
// 180:              chdir: cached_location
// 181:     command! "git",
// 182:              args:  ["config", "core.fsmonitor", "false"],
// 183:              chdir: cached_location
// 184:
// 185:     return unless partial_clone_sparse_checkout?
// 186:
// 187:     command! "git",
// 188:              args:  ["config", "origin.partialclonefilter", "blob:none"],
// 189:              chdir: cached_location
// 190:     configure_sparse_checkout
// 191:   end
// 192:
// 193:   sig { params(timeout: T.nilable(Time)).void }
// 194:   def update_repo(timeout: nil)
// 195:     return if @ref_type != :branch && ref?
// 196:
// 197:     # Convert any shallow clone to full clone
// 198:     if shallow_dir?
// 199:       command! "git",
// 200:                args:      ["fetch", "origin", "--unshallow"],
// 201:                chdir:     cached_location,
// 202:                timeout:   Utils::Timer.remaining(timeout),
// 203:                reset_uid: true
// 204:     else
// 205:       command! "git",
// 206:                args:      ["fetch", "origin"],
// 207:                chdir:     cached_location,
// 208:                timeout:   Utils::Timer.remaining(timeout),
// 209:                reset_uid: true
// 210:     end
// 211:   end
// 212:
// 213:   sig { override.params(timeout: T.nilable(Time)).void }
// 214:   def clone_repo(timeout: nil)
// 215:     command! "git",
// 216:              args:      clone_args,
// 217:              timeout:   Utils::Timer.remaining(timeout),
// 218:              reset_uid: true
// 219:
// 220:     command! "git",
// 221:              args:    ["config", "homebrew.cacheversion", cache_version],
// 222:              chdir:   cached_location,
// 223:              timeout: Utils::Timer.remaining(timeout)
// 224:
// 225:     configure_sparse_checkout if partial_clone_sparse_checkout?
// 226:
// 227:     checkout(timeout:)
// 228:     update_submodules(timeout:) if submodules?
// 229:   end
// 230:
// 231:   sig { params(timeout: T.nilable(Time)).void }
// 232:   def checkout(timeout: nil)
// 233:     ohai "Checking out #{@ref_type} #{@ref}" if @ref
// 234:     command! "git", args: ["checkout", "-f", @ref, "--"], chdir: cached_location,
// 235:                     timeout: Utils::Timer.remaining(timeout)
// 236:   end
// 237:
// 238:   sig { void }
// 239:   def reset
// 240:     ref = case @ref_type
// 241:     when :branch
// 242:       "origin/#{@ref}"
// 243:     when :revision, :tag
// 244:       @ref
// 245:     end
// 246:
// 247:     command! "git",
// 248:              args:  ["reset", "--hard", *ref, "--"],
// 249:              chdir: cached_location
// 250:   end
// 251:
// 252:   sig { params(timeout: T.nilable(Time)).void }
// 253:   def update_submodules(timeout: nil)
// 254:     command! "git",
// 255:              args:      ["submodule", "foreach", "--recursive", "git submodule sync"],
// 256:              chdir:     cached_location,
// 257:              timeout:   Utils::Timer.remaining(timeout),
// 258:              reset_uid: true
// 259:     command! "git",
// 260:              args:      ["submodule", "update", "--init", "--recursive"],
// 261:              chdir:     cached_location,
// 262:              timeout:   Utils::Timer.remaining(timeout),
// 263:              reset_uid: true
// 264:     fix_absolute_submodule_gitdir_references!
// 265:   end
// 266:
// 267:   # When checking out Git repositories with recursive submodules, some Git
// 268:   # versions create `.git` files with absolute instead of relative `gitdir:`
// 269:   # pointers. This works for the cached location, but breaks various Git
// 270:   # operations once the affected Git resource is staged, i.e. recursively
// 271:   # copied to a new location. (This bug was introduced in Git 2.7.0 and fixed
// 272:   # in 2.8.3. Clones created with affected version remain broken.)
// 273:   # See https://github.com/Homebrew/homebrew-core/pull/1520 for an example.
// 274:   sig { void }
// 275:   def fix_absolute_submodule_gitdir_references!
// 276:     submodule_dirs = command!("git",
// 277:                               args:      ["submodule", "--quiet", "foreach", "--recursive", "pwd"],
// 278:                               chdir:     cached_location,
// 279:                               reset_uid: true).stdout
// 280:
// 281:     submodule_dirs.lines.map(&:chomp).each do |submodule_dir|
// 282:       work_dir = Pathname.new(submodule_dir)
// 283:
// 284:       # Only check and fix if `.git` is a regular file, not a directory.
// 285:       dot_git = work_dir/".git"
// 286:       next unless dot_git.file?
// 287:
// 288:       git_dir = dot_git.read.chomp[/^gitdir: (.*)$/, 1]
// 289:       if git_dir.nil?
// 290:         onoe "Failed to parse '#{dot_git}'." if Homebrew::EnvConfig.developer?
// 291:         next
// 292:       end
// 293:
// 294:       # Only attempt to fix absolute paths.
// 295:       next unless git_dir.start_with?("/")
// 296:
// 297:       # Make the `gitdir:` reference relative to the working directory.
// 298:       relative_git_dir = Pathname.new(git_dir).relative_path_from(work_dir)
// 299:       dot_git.atomic_write("gitdir: #{relative_git_dir}\n")
// 300:     end
// 301:   end
// 302:
// 303:   sig { void }
// 304:   def configure_sparse_checkout
// 305:     command! "git",
// 306:              args:  ["config", "core.sparseCheckout", "true"],
// 307:              chdir: cached_location
// 308:     command! "git",
// 309:              args:  ["config", "core.sparseCheckoutCone", "true"],
// 310:              chdir: cached_location
// 311:
// 312:     (git_dir/"info").mkpath
// 313:     (git_dir/"info/sparse-checkout").atomic_write("#{@only_path}\n")
// 314:   end
// 315: end
