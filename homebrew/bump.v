module homebrew

// Translated from Homebrew/brew `bump.rb`.
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
