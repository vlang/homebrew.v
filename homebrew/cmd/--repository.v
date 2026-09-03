module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/--repository.rb`.
// The original source is retained below until every stub has a typed V body.

// tap_path translates the shell command paired with this Ruby command class.
// HOMEBREW_REPOSITORY and HOMEBREW_LIBRARY are set by brew.sh in Homebrew;
// the translated executable derives the same values from its source root when
// they are not exported by a caller.
pub fn tap_path(tap string, library string) !string {
	if !tap.contains('/') {
		return error('Invalid tap name: ${tap}')
	}
	user := tap.all_before('/').to_lower()
	mut repository := tap.all_after('/').to_lower()
	for part in [user, repository] {
		if part == '' || part.contains('/') {
			return error('Invalid tap name: ${tap}')
		}
	}
	if repository.starts_with('homebrew-') {
		repository = repository['homebrew-'.len..]
	} else if repository.starts_with('linuxbrew-') {
		repository = repository['linuxbrew-'.len..]
	}
	return '${library}/Taps/${user}/homebrew-${repository}'
}

pub fn repository_lines(arguments []string, repository string, library string) ![]string {
	if arguments.len == 0 {
		return [repository]
	}
	mut paths := []string{cap: arguments.len}
	for tap in arguments {
		paths << tap_path(tap, library)!
	}
	return paths
}

pub fn repository_lines_from_environment(arguments []string) ![]string {
	mut repository := brew_runtime.environment_value('HOMEBREW_REPOSITORY')
	if repository == '' {
		repository = @VMODROOT
	}
	mut library := brew_runtime.environment_value('HOMEBREW_LIBRARY')
	if library == '' {
		// `Library/Homebrew` maps to the top-level `homebrew` module in this
		// translation, so the module's parent is the translated library root.
		library = @VMODROOT
	}
	return repository_lines(arguments, repository, library)
}

// Ruby method `self.command_name = "--repository"` at line 13.
pub fn ruby_repository_l13_d1_self_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('--repository')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "shell_command"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Repository < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       sig { override.returns(String) }
// 13:       def self.command_name = "--repository"
// 14:
// 15:       cmd_args do
// 16:         description <<~EOS
// 17:           Display where Homebrew's Git repository is located.
// 18:
// 19:           If <user>`/`<repo> are provided, display where tap <user>`/`<repo>'s directory is located.
// 20:         EOS
// 21:
// 22:         named_args :tap
// 23:       end
// 24:     end
// 25:   end
// 26: end
