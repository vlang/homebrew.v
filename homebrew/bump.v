module homebrew

import brew_runtime

// Translated from Homebrew/brew `bump.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct BumpCommit {
pub:
	sourcefile_path  string
	old_contents     string
	commit_message   string
	additional_files []string
}

pub struct BumpTapInfo {
pub:
	name              string
	remote_repository string
	origin_branch     string
	origin_push_url   string
	user              string
	shallow           bool
}

@[heap]
pub struct BumpInfo {
pub:
	package_tap BumpTapInfo
	branch_name string
	pr_title    string
	pr_message  string
	commits     []BumpCommit
}

pub struct BumpCreateOptions {
pub:
	dry_run  bool
	no_fork  bool
	fork_org ?string
	commit   bool
}

@[heap]
pub struct BumpState {
pub:
	credentials_type   string
	credentials        string
	fork_clone_url     string
	fork_ssh_url       string
	fork_owner         string
	fork_ready         bool = true
	ssh_remote         bool
	pull_request_url   string
	fork_error         string
	pull_request_error string
pub mut:
	commands       [][]string
	messages       []string
	restored_files []string
}

pub fn bump_pr_message(command string, user_message ?string) string {
	mut message := ''
	if value := user_message {
		if value.trim_space() != '' {
			message = '${value}\n\n---\n\n'
		}
	}
	return message + 'Created with `brew ${command}`.'
}

pub fn bump_add_auth_token_to_url(url string, state &BumpState) string {
	if state.credentials_type == 'env_token' && url.starts_with('https://github.com/') {
		return 'https://x-access-token:${state.credentials}@github.com/${url['https://github.com/'.len..]}'
	}
	return url
}

pub fn bump_redacted_url(url string, credentials ?string) string {
	if credential := credentials {
		if credential != '' {
			return url.replace(credential, '******')
		}
	}
	return url
}

pub fn bump_forked_repo_info(repository string, org ?string, state &BumpState) !(string, string) {
	_ = repository
	_ = org
	if state.fork_error != '' {
		return error(state.fork_error)
	}
	if !state.fork_ready {
		return error('fork is not ready')
	}
	url := if state.ssh_remote {
		state.fork_ssh_url
	} else {
		bump_add_auth_token_to_url(state.fork_clone_url, state)
	}
	return url, state.fork_owner
}

fn (mut state BumpState) restore(commits []BumpCommit) {
	for commit in commits {
		state.restored_files << commit.sourcefile_path
	}
}

pub fn (mut state BumpState) create_pr(info BumpInfo, options BumpCreateOptions) !string {
	tap := info.package_tap
	if tap.remote_repository == '' {
		return error('The tap ${tap.name} does not have a remote repository!')
	}
	if tap.origin_branch.trim_space() == '' {
		return error('The tap ${tap.name} does not have a default branch!')
	}
	mut remote_url := ''
	mut username := ''
	if options.no_fork {
		remote_url = bump_add_auth_token_to_url(tap.origin_push_url, state)
		username = tap.user
	} else {
		remote_url, username = bump_forked_repo_info(tap.remote_repository, options.fork_org, state) or {
			state.restore(info.commits)
			return error('Unable to fork: ${err.msg()}!')
		}
	}
	if !options.dry_run {
		if !options.commit && tap.shallow {
			state.commands << ['git', 'fetch', '--unshallow', 'origin']
		}
		if !options.commit {
			state.commands << ['git', 'checkout', '--no-track', '-b', info.branch_name,
				'origin/${tap.origin_branch}']
		}
	}
	for commit in info.commits {
		mut changed_files := [commit.sourcefile_path]
		changed_files << commit.additional_files
		if options.dry_run {
			state.messages << 'git checkout --no-track -b ${info.branch_name} origin/${tap.origin_branch}'
			if tap.shallow {
				state.messages << 'git fetch --unshallow origin'
			}
			state.messages << 'git add ${changed_files.join(' ')}'
			state.messages << "git commit --no-edit --verbose --message='${commit.commit_message}' -- ${changed_files.join(' ')}"
			state.messages << 'git push --set-upstream ${bump_redacted_url(remote_url, state.credentials)} ${info.branch_name}:${info.branch_name}'
			state.messages << 'git checkout --quiet -'
			state.messages << 'create pull request with GitHub API (base branch: ${tap.origin_branch})'
		} else {
			mut add_command := ['git', 'add']
			add_command << changed_files
			state.commands << add_command
			mut commit_command := ['git', 'commit', '--no-edit', '--verbose',
				'--message=${commit.commit_message}', '--']
			commit_command << changed_files
			state.commands << commit_command
		}
	}
	if options.commit || options.dry_run {
		return ''
	}
	state.commands << ['git', 'push', '--set-upstream', remote_url,
		'${info.branch_name}:${info.branch_name}']
	state.commands << ['git', 'checkout', '--quiet', '-']
	if state.pull_request_error != '' {
		state.restore(info.commits)
		return error('Unable to open pull request for ${tap.remote_repository}: ${state.pull_request_error}!')
	}
	_ = username
	return state.pull_request_url
}

fn bump_state_value(state &BumpState) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Bump::State', '', {
		'bump_state_address': u64(voidptr(state)).str()
	})
}

fn bump_state_from_value(value brew_runtime.Value) &BumpState {
	address := value.attributes['bump_state_address'] or { panic('invalid Bump state') }
	return unsafe { &BumpState(voidptr(address.u64())) }
}

pub fn bump_state_boundary(state &BumpState) brew_runtime.Value {
	return bump_state_value(state)
}

fn bump_info_value(info &BumpInfo) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Bump::BumpInfo', info.pr_title, {
		'bump_info_address': u64(voidptr(info)).str()
	})
}

fn bump_info_from_value(value brew_runtime.Value) &BumpInfo {
	address := value.attributes['bump_info_address'] or { panic('invalid BumpInfo') }
	return unsafe { &BumpInfo(voidptr(address.u64())) }
}

pub fn bump_info_boundary(info &BumpInfo) brew_runtime.Value {
	return bump_info_value(info)
}

// Ruby method `self.pr_message(command, user_message:)` at line 34.
pub fn ruby_bump_l34_d1_self_pr_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value('')
	}
	user_message := if args.len > 1 && args[1].type_name != 'NilClass' {
		?string(args[1].as_string())
	} else {
		none
	}
	return brew_runtime.string_value(bump_pr_message(args[0].as_string(), user_message))
}

// Ruby method `self.create_pr(info, dry_run: false, no_fork: false, fork_org: nil, commit: false)` at line 49.
pub fn ruby_bump_l49_d2_self_create_pr(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'state and info are required')
	}
	mut state := bump_state_from_value(args[0])
	options_values := if args.len > 2 {
		args[2].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	fork_org_value := options_values['fork_org'] or { brew_runtime.object_value('NilClass', 'nil') }
	result := state.create_pr(*bump_info_from_value(args[1]), BumpCreateOptions{
		dry_run: (options_values['dry_run'] or { brew_runtime.bool_value(false) }).bool_data
		no_fork: (options_values['no_fork'] or { brew_runtime.bool_value(false) }).bool_data
		fork_org: if fork_org_value.type_name == 'NilClass' {
			?string(none)
		} else {
			fork_org_value.as_string()
		}
		commit: (options_values['commit'] or { brew_runtime.bool_value(false) }).bool_data
	}) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return if result == '' {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		brew_runtime.string_value(result)
	}
}

// Ruby method `self.add_auth_token_to_url!(url)` at line 141.
pub fn ruby_bump_l141_d3_self_add_auth_token_to_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'state and URL are required')
	}
	return brew_runtime.string_value(bump_add_auth_token_to_url(args[1].as_string(), bump_state_from_value(args[0])))
}

// Ruby method `self.redacted_url(url)` at line 150.
pub fn ruby_bump_l150_d4_self_redacted_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value('')
	}
	if args.len == 1 {
		return brew_runtime.string_value(args[0].as_string())
	}
	state := bump_state_from_value(args[0])
	return brew_runtime.string_value(bump_redacted_url(args[1].as_string(), state.credentials))
}

// Ruby method `self.forked_repo_info!(tap_remote_repo, org: nil)` at line 155.
pub fn ruby_bump_l155_d5_self_forked_repo_info(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'state and repository are required')
	}
	state := bump_state_from_value(args[0])
	org := if args.len > 2 && args[2].type_name != 'NilClass' {
		?string(args[2].as_string())
	} else {
		none
	}
	url, username := bump_forked_repo_info(args[1].as_string(), org, state) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.string_array_value([url, username])
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
