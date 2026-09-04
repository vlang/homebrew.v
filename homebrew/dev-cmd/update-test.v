module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/update-test.rb`.

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
		'HOMEBREW_UPDATE_TEST':    '1'
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
		tag_result := update_test_git_tags(options.initial_tags, options.shallow_repository, options.fetched_tags)!
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
	commands << ['git', 'clone', '${options.repository}/.git', '.', '--branch', 'main',
		'--single-branch']
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

pub fn update_test_input_boundary(input &UpdateTestInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::UpdateTest::Input', '', {
		'update_test_input_address': u64(voidptr(input)).str()
	})
}

fn update_test_input_from_value(value ruby.Value) &UpdateTestInput {
	address := value.attributes['update_test_input_address'] or { panic('invalid UpdateTest input') }
	return unsafe { &UpdateTestInput(voidptr(address.u64())) }
}

fn update_test_result_value(result UpdateTestResult) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for name, value in result.environment {
		environment[name] = ruby.string_value(value)
	}
	return ruby.map_value({
		'environment':       ruby.map_value(environment)
		'unset_environment': ruby.string_array_value(result.unset_environment)
		'branch':            ruby.string_value(result.branch)
		'start_commit':      ruby.string_value(result.start_commit)
		'end_commit':        ruby.string_value(result.end_commit)
		'stdout':            ruby.string_value(result.stdout)
		'headings':          ruby.string_array_value(result.headings)
		'commands':          ruby.array_value(result.commands.map(ruby.string_array_value(it)))
		'quiet_commands':    ruby.array_value(result.quiet_commands.map(ruby.string_array_value(it)))
		'update_test_dir':   ruby.string_value(result.update_test_dir)
		'removed':           ruby.bool_value(result.removed)
	})
}
