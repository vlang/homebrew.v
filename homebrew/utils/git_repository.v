module utils

import ruby

// Translated from Homebrew/brew `utils/git_repository.rb`.

fn git_repository_query(repo string, arguments []string, safe bool, git_path string) !string {
	if git_path == '' {
		if safe {
			return error('Git is unavailable')
		}
		return ''
	}
	probe := ruby.run_command(git_path, ['-C', repo, 'rev-parse', '--git-dir'])
	if probe.exit_code != 0 {
		if safe {
			return error('Not a Git repository: ${repo}')
		}
		return ''
	}
	mut command_arguments := ['-C', repo]
	command_arguments << arguments
	result := ruby.run_command(git_path, command_arguments)
	if result.exit_code != 0 {
		if safe {
			return error(result.output.trim_space())
		}
		return ''
	}
	return result.output.trim_space()
}

pub fn git_head_with_executable(repo string, length ?int, safe bool, git_path string) !string {
	if short_length := length {
		return git_short_head_with_executable(repo, short_length, safe, git_path)
	}
	return git_repository_query(repo, ['rev-parse', 'HEAD'], safe, git_path)
}

pub fn git_short_head_with_executable(repo string, length ?int, safe bool,
	git_path string) !string {
	arguments := if short_length := length {
		['rev-parse', '--short=${short_length}', 'HEAD']
	} else {
		['rev-parse', '--short', 'HEAD']
	}
	return git_repository_query(repo, arguments, safe, git_path)
}

pub fn git_branch_with_executable(repo string, safe bool, git_path string) !string {
	return git_repository_query(repo, ['rev-parse', '--abbrev-ref', 'HEAD'], safe, git_path)
}

pub fn git_head(repo string, length ?int, safe bool) !string {
	git := ruby.find_executable('git') or { '' }
	return git_head_with_executable(repo, length, safe, git)
}

pub fn git_short_head(repo string, length ?int, safe bool) !string {
	git := ruby.find_executable('git') or { '' }
	return git_short_head_with_executable(repo, length, safe, git)
}

pub fn git_branch(repo string, safe bool) !string {
	git := ruby.find_executable('git') or { '' }
	return git_branch_with_executable(repo, safe, git)
}
