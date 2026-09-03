module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/--version.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct VersionCommandConfig {
pub:
	homebrew_version    string
	core_repository     string
	cask_repository     string
	no_install_from_api bool
	git_executable      string = 'git'
}

// version_string translates the shell function paired with this Ruby command
// class. It reports absent taps and directories without a Git HEAD exactly as
// the Homebrew shell frontend does.
pub fn version_string(repository string, git_executable string) string {
	if !brew_runtime.is_dir(repository) {
		return 'N/A'
	}
	result := brew_runtime.run_command(git_executable, [
		'-C',
		repository,
		'log',
		'-1',
		'--format=%h %cd',
		'--date=short',
		'HEAD',
	])
	revision_and_date := result.output.trim_space()
	if result.exit_code != 0 || revision_and_date == '' || !revision_and_date.contains(' ') {
		return '(no Git repository)'
	}
	return '(git revision ${revision_and_date.all_before(' ')}; last commit ${revision_and_date.all_after(' ')})'
}

pub fn version_lines(config VersionCommandConfig) []string {
	mut lines := ['Homebrew ${config.homebrew_version}']
	if config.no_install_from_api || brew_runtime.is_dir(config.core_repository) {
		lines << 'Homebrew/homebrew-core ${version_string(config.core_repository, config.git_executable)}'
	}
	if brew_runtime.is_dir(config.cask_repository) {
		lines << 'Homebrew/homebrew-cask ${version_string(config.cask_repository, config.git_executable)}'
	}
	return lines
}

fn configured_homebrew_version(repository string, git_executable string) string {
	configured := brew_runtime.environment_value('HOMEBREW_VERSION')
	if configured != '' {
		return configured
	}
	// brew.sh sets HOMEBREW_VERSION from `git describe` and uses this literal
	// fallback for a shallow or non-Git repository.
	result := brew_runtime.run_command(git_executable, [
		'-C',
		repository,
		'describe',
		'--tags',
		'--dirty',
		'--abbrev=7',
	])
	if result.exit_code == 0 && result.output.trim_space() != '' {
		return result.output.trim_space()
	}
	return '>=4.3.0 (shallow or no git repository)'
}

pub fn version_lines_from_environment() []string {
	mut library := brew_runtime.environment_value('HOMEBREW_LIBRARY')
	if library == '' {
		// `Library/Homebrew` maps to the top-level `homebrew` module in this
		// translation, so the module's parent is the translated library root.
		library = @VMODROOT
	}
	mut repository := brew_runtime.environment_value('HOMEBREW_REPOSITORY')
	if repository == '' {
		repository = @VMODROOT
	}
	mut git_executable := brew_runtime.environment_value('HOMEBREW_GIT')
	if git_executable == '' {
		git_executable = 'git'
	}
	mut core_repository := brew_runtime.environment_value('HOMEBREW_CORE_REPOSITORY')
	if core_repository == '' {
		core_repository = '${library}/Taps/homebrew/homebrew-core'
	}
	mut cask_repository := brew_runtime.environment_value('HOMEBREW_CASK_REPOSITORY')
	if cask_repository == '' {
		cask_repository = '${library}/Taps/homebrew/homebrew-cask'
	}
	return version_lines(VersionCommandConfig{
		homebrew_version: configured_homebrew_version(repository, git_executable)
		core_repository: core_repository
		cask_repository: cask_repository
		no_install_from_api: brew_runtime.environment_value('HOMEBREW_NO_INSTALL_FROM_API') != ''
		git_executable: git_executable
	})
}

// Ruby method `self.command_name = "--version"` at line 13.
pub fn ruby_version_l13_d1_self_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('--version')
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
// 9:     class Version < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       sig { override.returns(String) }
// 13:       def self.command_name = "--version"
// 14:
// 15:       cmd_args do
// 16:         description <<~EOS
// 17:           Print the version numbers of Homebrew, Homebrew/homebrew-core and
// 18:           Homebrew/homebrew-cask (if tapped) to standard output.
// 19:         EOS
// 20:       end
// 21:     end
// 22:   end
// 23: end
