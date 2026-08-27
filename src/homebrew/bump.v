module homebrew

import brew_runtime

// Translated from Homebrew/brew `bump.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.pr_message(command, user_message:)` at line 34.
pub fn ruby_bump_l34_d1_self_pr_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.pr_message', ...args)
}

// Ruby method `self.create_pr(info, dry_run: false, no_fork: false, fork_org: nil, commit: false)` at line 49.
pub fn ruby_bump_l49_d2_self_create_pr(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create_pr', ...args)
}

// Ruby method `self.add_auth_token_to_url!(url)` at line 141.
pub fn ruby_bump_l141_d3_self_add_auth_token_to_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.add_auth_token_to_url!', ...args)
}

// Ruby method `self.redacted_url(url)` at line 150.
pub fn ruby_bump_l150_d4_self_redacted_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.redacted_url', ...args)
}

// Ruby method `self.forked_repo_info!(tap_remote_repo, org: nil)` at line 155.
pub fn ruby_bump_l155_d5_self_forked_repo_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.forked_repo_info!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5: require "tap"
// 6: require "utils/formatter"
// 7: require "utils/git"
// 8: require "utils/github"
// 9: require "utils/output"
// 10: require "utils/popen"
// 11:
// 12: module Homebrew
// 13:   # @api internal
// 14:   module Bump
// 15:     extend SystemCommand::Mixin
// 16:     extend Utils::Output::Mixin
// 17:
// 18:     class Commit < T::Struct
// 19:       const :sourcefile_path, Pathname
// 20:       const :old_contents, String
// 21:       const :commit_message, String
// 22:       const :additional_files, T::Array[Pathname], default: []
// 23:     end
// 24:
// 25:     class BumpInfo < T::Struct
// 26:       const :package_tap, Tap
// 27:       const :branch_name, String
// 28:       const :pr_title, String
// 29:       const :pr_message, String
// 30:       const :commits, T::Array[Commit]
// 31:     end
// 32:
// 33:     sig { params(command: String, user_message: T.nilable(String)).returns(String) }
// 34:     def self.pr_message(command, user_message:)
// 35:       pr_message = ""
// 36:       if user_message.present?
// 37:         pr_message += <<~EOS
// 38:           #{user_message}
// 39:
// 40:           ---
// 41:
// 42:         EOS
// 43:       end
// 44:       pr_message += "Created with `brew #{command}`."
// 45:       pr_message
// 46:     end
// 47:
// 48:     sig { params(info: BumpInfo, dry_run: T::Boolean, no_fork: T::Boolean, fork_org: T.nilable(String), commit: T::Boolean).returns(T.nilable(String)) }
// 49:     def self.create_pr(info, dry_run: false, no_fork: false, fork_org: nil, commit: false)
// 50:       tap = info.package_tap
// 51:       branch = info.branch_name
// 52:       pr_message = info.pr_message
// 53:       pr_title = info.pr_title
// 54:       commits = info.commits
// 55:
// 56:       tap_remote_repo = tap.remote_repository
// 57:       raise ArgumentError, "The tap #{tap.name} does not have a remote repository!" unless tap_remote_repo
// 58:
// 59:       remote_branch = tap.git_repository.origin_branch_name
// 60:       raise "The tap #{tap.name} does not have a default branch!" if remote_branch.blank?
// 61:
// 62:       remote_url = T.let(nil, T.nilable(String))
// 63:       username = T.let(nil, T.nilable(String))
// 64:
// 65:       tap.path.cd do
// 66:         if no_fork
// 67:           remote_url = Utils.popen_read("git", "remote", "get-url", "--push", "origin").chomp
// 68:           username = tap.user
// 69:           add_auth_token_to_url!(remote_url)
// 70:         else
// 71:           begin
// 72:             remote_url, username = forked_repo_info!(tap_remote_repo, org: fork_org)
// 73:           rescue *GitHub::API::ERRORS => e
// 74:             commits.each do |commit|
// 75:               commit.sourcefile_path.atomic_write(commit.old_contents)
// 76:             end
// 77:             odie "Unable to fork: #{e.message}!"
// 78:           end
// 79:         end
// 80:
// 81:         next if dry_run
// 82:
// 83:         git_dir = Utils.popen_read("git", "rev-parse", "--git-dir").chomp
// 84:         shallow = !git_dir.empty? && File.exist?("#{git_dir}/shallow")
// 85:         safe_system "git", "fetch", "--unshallow", "origin" if !commit && shallow
// 86:         safe_system "git", "checkout", "--no-track", "-b", branch, "origin/#{remote_branch}" unless commit
// 87:         Utils::Git.set_name_email!
// 88:       end
// 89:
// 90:       commits.each do |commit|
// 91:         sourcefile_path = commit.sourcefile_path
// 92:         commit_message = commit.commit_message
// 93:         additional_files = commit.additional_files
// 94:
// 95:         sourcefile_path.parent.cd do
// 96:           git_dir = Utils.popen_read("git", "rev-parse", "--git-dir").chomp
// 97:           shallow = !git_dir.empty? && File.exist?("#{git_dir}/shallow")
// 98:           changed_files = [sourcefile_path]
// 99:           changed_files += additional_files if additional_files.present?
// 100:
// 101:           if dry_run
// 102:             ohai "git checkout --no-track -b #{branch} origin/#{remote_branch}"
// 103:             ohai "git fetch --unshallow origin" if shallow
// 104:             ohai "git add #{changed_files.join(" ")}"
// 105:             ohai "git commit --no-edit --verbose --message='#{commit_message}' " \
// 106:                  "-- #{changed_files.join(" ")}"
// 107:             ohai "git push --set-upstream #{redacted_url(remote_url)} #{branch}:#{branch}"
// 108:             ohai "git checkout --quiet -"
// 109:             ohai "create pull request with GitHub API (base branch: #{remote_branch})"
// 110:           else
// 111:             safe_system "git", "add", *changed_files
// 112:             Utils::Git.set_name_email!
// 113:             safe_system "git", "commit", "--no-edit", "--verbose",
// 114:                         "--message=#{commit_message}",
// 115:                         "--", *changed_files
// 116:           end
// 117:         end
// 118:       end
// 119:
// 120:       return if commit || dry_run
// 121:       return unless remote_url
// 122:
// 123:       tap.path.cd do
// 124:         system_command!("git", args:         ["push", "--set-upstream", remote_url, "#{branch}:#{branch}"],
// 125:                                print_stdout: true)
// 126:         safe_system "git", "checkout", "--quiet", "-"
// 127:
// 128:         begin
// 129:           return GitHub.create_pull_request(tap_remote_repo, pr_title,
// 130:                                             "#{username}:#{branch}", remote_branch, pr_message)["html_url"]
// 131:         rescue *GitHub::API::ERRORS => e
// 132:           commits.each do |commit|
// 133:             commit.sourcefile_path.atomic_write(commit.old_contents)
// 134:           end
// 135:           odie "Unable to open pull request for #{tap_remote_repo}: #{e.message}!"
// 136:         end
// 137:       end
// 138:     end
// 139:
// 140:     sig { params(url: String).returns(String) }
// 141:     private_class_method def self.add_auth_token_to_url!(url)
// 142:       if GitHub::API.credentials_type == :env_token
// 143:         url.sub!(%r{^https://github\.com/}, "https://x-access-token:#{GitHub::API.credentials}@github.com/")
// 144:       end
// 145:       url
// 146:     end
// 147:
// 148:     # Redact any token `add_auth_token_to_url!` embedded, so dry-run output doesn't leak it.
// 149:     sig { params(url: T.nilable(String)).returns(String) }
// 150:     def self.redacted_url(url)
// 151:       Formatter.redact_secrets(url.to_s, [GitHub::API.credentials].compact)
// 152:     end
// 153:
// 154:     sig { params(tap_remote_repo: String, org: T.nilable(String)).returns([String, String]) }
// 155:     private_class_method def self.forked_repo_info!(tap_remote_repo, org: nil)
// 156:       response = GitHub.create_fork(tap_remote_repo, org:)
// 157:       # GitHub API responds immediately but fork takes a few seconds to be ready.
// 158:       sleep 1 until GitHub.fork_exists?(tap_remote_repo, org:)
// 159:       remote_url = if system("git", "config", "--local", "--get-regexp", "remote..*.url", "git@github.com:.*")
// 160:         response.fetch("ssh_url")
// 161:       else
// 162:         add_auth_token_to_url!(response.fetch("clone_url"))
// 163:       end
// 164:       username = response.fetch("owner").fetch("login")
// 165:       [remote_url, username]
// 166:     end
// 167:   end
// 168: end
