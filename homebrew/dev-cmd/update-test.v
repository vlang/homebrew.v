module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `dev-cmd/update-test.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct UpdateTestOptions {
pub:
	repository         string
	working_directory  string
	path               string
	to_tag             bool
	keep_tmp           bool
	commit             string
	before             string
	rev_list_commit    string
	initial_tags       string
	shallow_repository bool
	fetched_tags       string
	merge_base         string
	resolved_start     string
	resolved_end       string
	main_branch_exists bool
	actual_end_commit  string
	start_log          string
	end_log            string
	actual_log         string
}

pub struct GitTagsResult {
pub:
	tags          string
	fetched       bool
	fetch_command []string
}

pub struct UpdateTestResult {
pub:
	environment       map[string]string
	unset_environment []string
	branch            string
	start_commit      string
	end_commit        string
	stdout            string
	headings          []string
	commands          [][]string
	quiet_commands    [][]string
	update_test_dir   string
	removed           bool
}

pub fn update_test_git_tags(initial string, shallow bool, fetched string) !GitTagsResult {
	if initial.trim_space().len > 0 {
		return GitTagsResult{
			tags: initial
		}
	}
	if shallow && fetched.trim_space().len > 0 {
		return GitTagsResult{
			tags: fetched
			fetched: true
			fetch_command: ['git', 'fetch', '--tags', '--depth=1']
		}
	}
	return error('Could not find git tags!')
}

pub fn run_update_test(options UpdateTestOptions) !UpdateTestResult {
	branch := if options.to_tag { 'stable' } else { 'main' }
	mut environment := {
		'HOMEBREW_UPDATE_TEST': '1'
		'HOMEBREW_NO_AUTO_UPDATE': '1'
	}
	if options.to_tag {
		environment['HOMEBREW_UPDATE_TO_TAG'] = '1'
	} else {
		environment['HOMEBREW_DEV_CMD_RUN'] = '1'
	}
	mut commands := [][]string{}
	mut start_reference := ''
	mut end_reference := 'HEAD'
	if options.commit.len > 0 {
		start_reference = options.commit
	} else if options.before.len > 0 {
		start_reference = options.rev_list_commit
	} else if options.to_tag {
		tag_result := update_test_git_tags(options.initial_tags, options.shallow_repository,
			options.fetched_tags)!
		if tag_result.fetched {
			commands << tag_result.fetch_command
		}
		tags := tag_result.tags.split_into_lines().map(it.trim_space()).filter(it.len > 0)
		if tags.len == 0 {
			return error('Could not find current tag in:\n${tag_result.tags}')
		}
		if tags.len < 2 {
			return error('Could not find previous tag in:\n${tag_result.tags}')
		}
		end_reference = '${tags[0]}^0'
		start_reference = '${tags[1]}^0'
	} else {
		start_reference = options.merge_base
	}
	if start_reference.trim_space().len == 0 {
		return error('Could not find start commit!')
	}
	start_commit := options.resolved_start.trim_space()
	if start_commit.len == 0 {
		return error('Could not find start commit!')
	}
	end_commit := options.resolved_end.trim_space()
	if end_commit.len == 0 {
		return error('Could not find end commit!')
	}
	if !options.main_branch_exists {
		commands << ['git', '-C', options.repository, 'branch', 'main', 'origin/HEAD']
	}
	update_test_dir := os.join_path(options.working_directory, 'update-test')
	commands << ['git', 'clone', '${options.repository}/.git', '.', '--branch', 'main', '--single-branch']
	commands << ['git', 'clone', '${options.repository}/.git', 'remote.git', '--bare', '--branch',
		'main', '--single-branch']
	commands << ['git', 'config', 'remote.origin.url', '${update_test_dir}/remote.git']
	environment['HOMEBREW_BREW_GIT_REMOTE'] = '${update_test_dir}/remote.git'
	commands << ['git', 'checkout', '-B', 'main', end_commit]
	commands << ['git', 'push', '--force', 'origin', 'main']
	commands << ['git', 'reset', '--hard', start_commit]
	environment['PATH'] = if options.path.len > 0 {
		'${update_test_dir}/bin:${options.path}'
	} else {
		'${update_test_dir}/bin'
	}
	quiet_commands := [['brew', 'help']]
	commands << ['brew', 'update', '--verbose', '--debug']
	if options.actual_end_commit.trim_space() != end_commit {
		return error("`brew update` didn't update ${branch}!\nStart commit:        ${options.start_log}\nExpected end commit: ${options.end_log}\nActual end commit:   ${options.actual_log}")
	}
	return UpdateTestResult{
		environment: environment
		unset_environment: ['HOMEBREW_AUTO_UPDATE_SECS', 'HOMEBREW_DEVELOPER', 'HOMEBREW_MERGE',
			'HOMEBREW_NO_UPDATE_CLEANUP']
		branch: branch
		start_commit: start_commit
		end_commit: end_commit
		stdout: 'Start commit: ${start_commit}\n  End commit: ${end_commit}\n'
		headings: ['Preparing test environment...', 'Running `brew update`...']
		commands: commands
		quiet_commands: quiet_commands
		update_test_dir: update_test_dir
		removed: !options.keep_tmp
	}
}

@[heap]
pub struct UpdateTestInput {
pub:
	options UpdateTestOptions
}

pub fn update_test_input_boundary(input &UpdateTestInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::UpdateTest::Input', '', {
		'update_test_input_address': u64(voidptr(input)).str()
	})
}

fn update_test_input_from_value(value brew_runtime.Value) &UpdateTestInput {
	address := value.attributes['update_test_input_address'] or { panic('invalid UpdateTest input') }
	return unsafe { &UpdateTestInput(voidptr(address.u64())) }
}

fn update_test_result_value(result UpdateTestResult) brew_runtime.Value {
	mut environment := map[string]brew_runtime.Value{}
	for name, value in result.environment {
		environment[name] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'environment': brew_runtime.map_value(environment)
		'unset_environment': brew_runtime.string_array_value(result.unset_environment)
		'branch': brew_runtime.string_value(result.branch)
		'start_commit': brew_runtime.string_value(result.start_commit)
		'end_commit': brew_runtime.string_value(result.end_commit)
		'stdout': brew_runtime.string_value(result.stdout)
		'headings': brew_runtime.string_array_value(result.headings)
		'commands': brew_runtime.array_value(result.commands.map(brew_runtime.string_array_value(it)))
		'quiet_commands': brew_runtime.array_value(result.quiet_commands.map(brew_runtime.string_array_value(it)))
		'update_test_dir': brew_runtime.string_value(result.update_test_dir)
		'removed': brew_runtime.bool_value(result.removed)
	})
}

// Ruby method `run` at line 30.
pub fn ruby_update_test_l30_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return update_test_result_value(run_update_test(update_test_input_from_value(args[0]).options) or {
		return brew_runtime.object_value('Error', err.msg())
	})
}

// Ruby method `git_tags` at line 146.
pub fn ruby_update_test_l146_d2_git_tags(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	options := update_test_input_from_value(args[0]).options
	result := update_test_git_tags(options.initial_tags, options.shallow_repository, options.fetched_tags) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return brew_runtime.map_value({
		'tags': brew_runtime.string_value(result.tags)
		'fetched': brew_runtime.bool_value(result.fetched)
		'fetch_command': brew_runtime.string_array_value(result.fetch_command)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class UpdateTest < AbstractCommand
// 10:       include FileUtils
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Run a test of `brew update` with a new repository clone.
// 15:           If no options are passed, use `origin/main` as the start commit.
// 16:         EOS
// 17:         switch "--to-tag",
// 18:                description: "Set `$HOMEBREW_UPDATE_TO_TAG` to test updating between tags."
// 19:         switch "--keep-tmp",
// 20:                description: "Retain the temporary directory containing the new repository clone."
// 21:         flag   "--commit=",
// 22:                description: "Use the specified <commit> as the start commit."
// 23:         flag   "--before=",
// 24:                description: "Use the commit at the specified <date> as the start commit."
// 25:
// 26:         named_args :none
// 27:       end
// 28:
// 29:       sig { override.void }
// 30:       def run
// 31:         # Avoid `update-report.rb` tapping Homebrew/homebrew-core
// 32:         ENV["HOMEBREW_UPDATE_TEST"] = "1"
// 33:
// 34:         # Avoid accidentally updating when we don't expect it.
// 35:         ENV["HOMEBREW_NO_AUTO_UPDATE"] = "1"
// 36:
// 37:         # Use default behaviours
// 38:         ENV["HOMEBREW_AUTO_UPDATE_SECS"] = nil
// 39:         ENV["HOMEBREW_DEVELOPER"] = nil
// 40:         ENV["HOMEBREW_DEV_CMD_RUN"] = nil
// 41:         ENV["HOMEBREW_MERGE"] = nil
// 42:         ENV["HOMEBREW_NO_UPDATE_CLEANUP"] = nil
// 43:         ENV["HOMEBREW_UPDATE_TO_TAG"] = nil
// 44:
// 45:         branch = if args.to_tag?
// 46:           ENV["HOMEBREW_UPDATE_TO_TAG"] = "1"
// 47:           "stable"
// 48:         else
// 49:           ENV["HOMEBREW_DEV_CMD_RUN"] = "1"
// 50:           "main"
// 51:         end
// 52:
// 53:         # Utils.popen_read returns a String without a block argument, but that isn't easily typed. We thus label this
// 54:         # as untyped for now.
// 55:         start_commit = T.let("", T.untyped)
// 56:         end_commit = "HEAD"
// 57:         cd HOMEBREW_REPOSITORY do
// 58:           start_commit = if (commit = args.commit)
// 59:             commit
// 60:           elsif (date = args.before)
// 61:             Utils.popen_read("git", "rev-list", "-n1", "--before=#{date}", "origin/main").chomp
// 62:           elsif args.to_tag?
// 63:             tags = git_tags
// 64:             current_tag, previous_tag, = tags.lines
// 65:             current_tag = current_tag.to_s.chomp
// 66:             odie "Could not find current tag in:\n#{tags}" if current_tag.empty?
// 67:             # ^0 ensures this points to the commit rather than the tag object.
// 68:             end_commit = "#{current_tag}^0"
// 69:
// 70:             previous_tag = previous_tag.to_s.chomp
// 71:             odie "Could not find previous tag in:\n#{tags}" if previous_tag.empty?
// 72:             # ^0 ensures this points to the commit rather than the tag object.
// 73:             "#{previous_tag}^0"
// 74:           else
// 75:             Utils.popen_read("git", "merge-base", "origin/main", end_commit).chomp
// 76:           end
// 77:           odie "Could not find start commit!" if start_commit.empty?
// 78:
// 79:           start_commit = Utils.popen_read("git", "rev-parse", start_commit).chomp
// 80:           odie "Could not find start commit!" if start_commit.empty?
// 81:
// 82:           end_commit = Utils.popen_read("git", "rev-parse", end_commit).chomp
// 83:           odie "Could not find end commit!" if end_commit.empty?
// 84:
// 85:           if Utils.popen_read("git", "branch", "--list", "main").blank?
// 86:             safe_system "git", "branch", "main", "origin/HEAD"
// 87:           end
// 88:         end
// 89:
// 90:         puts <<~EOS
// 91:           Start commit: #{start_commit}
// 92:             End commit: #{end_commit}
// 93:         EOS
// 94:
// 95:         mkdir "update-test"
// 96:         chdir "update-test" do
// 97:           curdir = Pathname.new(Dir.pwd)
// 98:
// 99:           oh1 "Preparing test environment..."
// 100:           # copy Homebrew installation
// 101:           safe_system "git", "clone", "#{HOMEBREW_REPOSITORY}/.git", ".",
// 102:                       "--branch", "main", "--single-branch"
// 103:
// 104:           # set git origin to another copy
// 105:           safe_system "git", "clone", "#{HOMEBREW_REPOSITORY}/.git", "remote.git",
// 106:                       "--bare", "--branch", "main", "--single-branch"
// 107:           safe_system "git", "config", "remote.origin.url", "#{curdir}/remote.git"
// 108:           ENV["HOMEBREW_BREW_GIT_REMOTE"] = "#{curdir}/remote.git"
// 109:
// 110:           # force push origin to end_commit
// 111:           safe_system "git", "checkout", "-B", "main", end_commit
// 112:           safe_system "git", "push", "--force", "origin", "main"
// 113:
// 114:           # set test copy to start_commit
// 115:           safe_system "git", "reset", "--hard", start_commit
// 116:
// 117:           # update ENV["PATH"]
// 118:           ENV["PATH"] = PATH.new(ENV.fetch("PATH")).prepend(curdir/"bin").to_s
// 119:
// 120:           # Run `brew help` to install `portable-ruby` (if needed).
// 121:           quiet_system "brew", "help"
// 122:
// 123:           # run brew update
// 124:           oh1 "Running `brew update`..."
// 125:           safe_system "brew", "update", "--verbose", "--debug"
// 126:           actual_end_commit = Utils.popen_read("git", "rev-parse", branch).chomp
// 127:           if actual_end_commit != end_commit
// 128:             start_log = Utils.popen_read("git", "log", "-1", "--decorate", "--oneline", start_commit).chomp
// 129:             end_log = Utils.popen_read("git", "log", "-1", "--decorate", "--oneline", end_commit).chomp
// 130:             actual_log = Utils.popen_read("git", "log", "-1", "--decorate", "--oneline", actual_end_commit).chomp
// 131:             odie <<~EOS
// 132:               `brew update` didn't update #{branch}!
// 133:               Start commit:        #{start_log}
// 134:               Expected end commit: #{end_log}
// 135:               Actual end commit:   #{actual_log}
// 136:             EOS
// 137:           end
// 138:         end
// 139:       ensure
// 140:         FileUtils.rm_rf "update-test" unless args.keep_tmp?
// 141:       end
// 142:
// 143:       private
// 144:
// 145:       sig { returns(String) }
// 146:       def git_tags
// 147:         tags = Utils.popen_read("git", "tag", "--list", "--sort=-version:refname")
// 148:         if tags.blank?
// 149:           tags = if (HOMEBREW_REPOSITORY/".git/shallow").exist?
// 150:             safe_system "git", "fetch", "--tags", "--depth=1"
// 151:             Utils.popen_read("git", "tag", "--list", "--sort=-version:refname")
// 152:           end
// 153:         end
// 154:         odie "Could not find git tags!" if tags.blank?
// 155:         tags
// 156:       end
// 157:     end
// 158:   end
// 159: end
// 160:
// 161: require "extend/os/dev-cmd/update-test"
