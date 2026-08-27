module utils

import brew_runtime

// Translated from Homebrew/brew `utils/git.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.available?` at line 15.
pub fn ruby_git_l15_d1_self_available(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.available?', ...args)
}

// Ruby method `self.no_global_config_env` at line 20.
pub fn ruby_git_l20_d2_self_no_global_config_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.no_global_config_env', ...args)
}

// Ruby method `self.no_global_config_file` at line 25.
pub fn ruby_git_l25_d3_self_no_global_config_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.no_global_config_file', ...args)
}

// Ruby method `self.version` at line 30.
pub fn ruby_git_l30_d4_self_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.version', ...args)
}

// Ruby method `self.path` at line 40.
pub fn ruby_git_l40_d5_self_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.path', ...args)
}

// Ruby method `self.git` at line 48.
pub fn ruby_git_l48_d6_self_git(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.git', ...args)
}

// Ruby method `self.remote_exists?(url)` at line 53.
pub fn ruby_git_l53_d7_self_remote_exists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.remote_exists?', ...args)
}

// Ruby method `self.clear_available_cache` at line 60.
pub fn ruby_git_l60_d8_self_clear_available_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.clear_available_cache', ...args)
}

// Ruby method `self.last_revision_commit_of_file(repo, file, before_commit: nil)` at line 70.
pub fn ruby_git_l70_d9_self_last_revision_commit_of_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.last_revision_commit_of_file', ...args)
}

// Ruby method `self.last_revision_commit_of_files(repo, files, before_commit: nil)` at line 87.
pub fn ruby_git_l87_d10_self_last_revision_commit_of_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.last_revision_commit_of_files', ...args)
}

// Ruby method `self.last_revision_of_file(repo, file, before_commit: nil)` at line 112.
pub fn ruby_git_l112_d11_self_last_revision_of_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.last_revision_of_file', ...args)
}

// Ruby method `self.file_at_commit(repo, file, commit)` at line 119.
pub fn ruby_git_l119_d12_self_file_at_commit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.file_at_commit', ...args)
}

// Ruby method `self.changed_files(repository)` at line 131.
pub fn ruby_git_l131_d13_self_changed_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.changed_files', ...args)
}

// Ruby method `self.ensure_installed!` at line 138.
pub fn ruby_git_l138_d14_self_ensure_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ensure_installed!', ...args)
}

// Ruby method `self.set_name_email!(author: true, committer: true)` at line 160.
pub fn ruby_git_l160_d15_self_set_name_email(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.set_name_email!', ...args)
}

// Ruby method `self.setup_gpg!` at line 182.
pub fn ruby_git_l182_d16_self_setup_gpg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.setup_gpg!', ...args)
}

// Ruby method `self.cherry_pick!(repo, *args, resolve: false, verbose: false)` at line 192.
pub fn ruby_git_l192_d17_self_cherry_pick(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cherry_pick!', ...args)
}

// Ruby method `self.supports_partial_clone_sparse_checkout?` at line 205.
pub fn ruby_git_l205_d18_self_supports_partial_clone_sparse_checkout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.supports_partial_clone_sparse_checkout?', ...args)
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
