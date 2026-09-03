module utils

import brew_runtime

// Translated from Homebrew/brew `utils/git_repository.rb`.
// The original source is retained below until every stub has a typed V body.

fn git_repository_query(repo string, arguments []string, safe bool, git_path string) !string {
	if git_path == '' {
		if safe {
			return error('Git is unavailable')
		}
		return ''
	}
	probe := brew_runtime.run_command(git_path, ['-C', repo, 'rev-parse', '--git-dir'])
	if probe.exit_code != 0 {
		if safe {
			return error('Not a Git repository: ${repo}')
		}
		return ''
	}
	mut command_arguments := ['-C', repo]
	command_arguments << arguments
	result := brew_runtime.run_command(git_path, command_arguments)
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
	git := brew_runtime.find_executable('git') or { '' }
	return git_head_with_executable(repo, length, safe, git)
}

pub fn git_short_head(repo string, length ?int, safe bool) !string {
	git := brew_runtime.find_executable('git') or { '' }
	return git_short_head_with_executable(repo, length, safe, git)
}

pub fn git_branch(repo string, safe bool) !string {
	git := brew_runtime.find_executable('git') or { '' }
	return git_branch_with_executable(repo, safe, git)
}

// Ruby method `self.git_head(repo = Pathname.pwd, length: nil, safe: true)` at line 13.
pub fn ruby_git_repository_l13_d1_self_git_head(args ...brew_runtime.Value) brew_runtime.Value {
	repo := if args.len > 0 { args[0].as_string() } else { brew_runtime.current_directory() }
	length := if args.len > 1 && args[1].type_name != 'NilClass' {
		?int(int(args[1].as_int() or { 0 }))
	} else {
		none
	}
	safe := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	result := git_head(repo, length, safe) or { panic(err) }
	return if result == '' {
		brew_runtime.object_value('NilClass', '')
	} else {
		brew_runtime.string_value(result)
	}
}

// Ruby method `self.git_short_head(repo = Pathname.pwd, length: nil, safe: true)` at line 27.
pub fn ruby_git_repository_l27_d2_self_git_short_head(args ...brew_runtime.Value) brew_runtime.Value {
	repo := if args.len > 0 { args[0].as_string() } else { brew_runtime.current_directory() }
	length := if args.len > 1 && args[1].type_name != 'NilClass' {
		?int(int(args[1].as_int() or { 0 }))
	} else {
		none
	}
	safe := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	result := git_short_head(repo, length, safe) or { panic(err) }
	return if result == '' {
		brew_runtime.object_value('NilClass', '')
	} else {
		brew_runtime.string_value(result)
	}
}

// Ruby method `self.git_branch(repo = Pathname.pwd, safe: true)` at line 38.
pub fn ruby_git_repository_l38_d3_self_git_branch(args ...brew_runtime.Value) brew_runtime.Value {
	repo := if args.len > 0 { args[0].as_string() } else { brew_runtime.current_directory() }
	safe := if args.len > 1 { args[1].as_bool() or { true } } else { true }
	result := git_branch(repo, safe) or { panic(err) }
	return if result == '' {
		brew_runtime.object_value('NilClass', '')
	} else {
		brew_runtime.string_value(result)
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # Gets the full commit hash of the HEAD commit.
// 6:   sig {
// 7:     params(
// 8:       repo:   T.any(String, Pathname),
// 9:       length: T.nilable(Integer),
// 10:       safe:   T::Boolean,
// 11:     ).returns(T.nilable(String))
// 12:   }
// 13:   def self.git_head(repo = Pathname.pwd, length: nil, safe: true)
// 14:     return git_short_head(repo, length:) if length
// 15:
// 16:     GitRepository.new(Pathname(repo)).head_ref(safe:)
// 17:   end
// 18:
// 19:   # Gets a short commit hash of the HEAD commit.
// 20:   sig {
// 21:     params(
// 22:       repo:   T.any(String, Pathname),
// 23:       length: T.nilable(Integer),
// 24:       safe:   T::Boolean,
// 25:     ).returns(T.nilable(String))
// 26:   }
// 27:   def self.git_short_head(repo = Pathname.pwd, length: nil, safe: true)
// 28:     GitRepository.new(Pathname(repo)).short_head_ref(length:, safe:)
// 29:   end
// 30:
// 31:   # Gets the name of the currently checked-out branch, or HEAD if the repository is in a detached HEAD state.
// 32:   sig {
// 33:     params(
// 34:       repo: T.any(String, Pathname),
// 35:       safe: T::Boolean,
// 36:     ).returns(T.nilable(String))
// 37:   }
// 38:   def self.git_branch(repo = Pathname.pwd, safe: true)
// 39:     GitRepository.new(Pathname(repo)).branch_name(safe:)
// 40:   end
// 41: end
