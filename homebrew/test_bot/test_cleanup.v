module test_bot

import ruby

pub struct CleanupAction {
pub:
	kind        string
	command     []string
	paths       []string
	repository  string
	destination string
	seconds     int
}

pub struct CleanupPath {
pub:
	path            string
	symlink         bool
	exists          bool = true
	resolved_exists bool = true
	owned           bool = true
	readable        bool = true
	writable        bool = true
}

pub struct CleanupTap {
pub:
	name string
	path string
}

pub struct CleanupRepositoryState {
pub:
	repository     string
	origin_head    string
	current_branch string
	diff_quiet     bool = true
	clean_dry_run  string
	gc_output      string
	pr_locks       []string
}

pub struct DeleteOrMoveInput {
pub:
	paths                 []CleanupPath
	github_actions        bool
	self_hosted           bool
	sudo                  bool
	temporary_directories []string
}

pub struct CleanupSharedInput {
pub:
	git                   string = 'git'
	repository            string
	repository_exists     bool
	homebrew_repository   string
	homebrew_prefix       string
	homebrew_cellar       string
	homebrew_library      string
	working_directory     string
	has_tap               bool
	tap_name              string
	installed_taps        []CleanupTap
	tap_repositories      []string
	repositories          []CleanupRepositoryState
	prefix_paths          []CleanupPath
	must_be_writable      []string
	github_actions        bool
	self_hosted           bool
	temporary_directories []string
}

pub struct CleanupPlan {
pub:
	actions        []CleanupAction
	paths_to_purge []string
}

fn cleanup_action_value(action CleanupAction) ruby.Value {
	return ruby.map_value({
		'kind':        ruby.string_value(action.kind)
		'command':     ruby.string_array_value(action.command)
		'paths':       ruby.string_array_value(action.paths)
		'repository':  ruby.string_value(action.repository)
		'destination': ruby.string_value(action.destination)
		'seconds':     ruby.int_value(action.seconds)
	})
}

fn cleanup_actions_value(actions []CleanupAction) ruby.Value {
	return ruby.array_value(actions.map(cleanup_action_value(it)))
}

fn cleanup_plan_value(plan CleanupPlan) ruby.Value {
	return ruby.map_value({
		'actions':        cleanup_actions_value(plan.actions)
		'paths_to_purge': ruby.string_array_value(plan.paths_to_purge)
	})
}

fn cleanup_value_string(args []ruby.Value, index int, fallback string) string {
	if index >= args.len {
		return fallback
	}
	return args[index].as_string()
}

fn cleanup_value_bool(args []ruby.Value, index int, fallback bool) bool {
	if index >= args.len || args[index].type_name != 'Bool' {
		return fallback
	}
	return args[index].bool_data
}

fn cleanup_value_strings(args []ruby.Value, index int) []string {
	if index >= args.len {
		return []string{}
	}
	return args[index].as_string_array() or { return []string{} }
}

fn cleanup_default_ref(origin_head string) string {
	ref := origin_head.trim_space()
	if ref == '' {
		return 'origin/main'
	}
	return ref
}

fn cleanup_default_branch(origin_head string) string {
	default_ref := cleanup_default_ref(origin_head)
	slash := default_ref.index('/') or { return default_ref }
	return default_ref[slash + 1..]
}

fn cleanup_git(git string) string {
	if git == '' {
		return 'git'
	}
	return git
}

fn cleanup_append_strings(prefix []string, suffix []string) []string {
	mut values := prefix.clone()
	values << suffix
	return values
}

pub fn reset_if_needed_plan(state CleanupRepositoryState, git string) []CleanupAction {
	if state.diff_quiet {
		return []CleanupAction{}
	}
	default_ref := cleanup_default_ref(state.origin_head)
	return [CleanupAction{
		kind: 'command'
		command: [cleanup_git(git), '-C', state.repository, 'reset', '--hard', default_ref]
		repository: state.repository
	}]
}

pub fn checkout_branch_if_needed_plan(state CleanupRepositoryState, git string) []CleanupAction {
	default_branch := cleanup_default_branch(state.origin_head)
	if state.current_branch.trim_space() == default_branch {
		return []CleanupAction{}
	}
	return [CleanupAction{
		kind: 'command'
		command: [cleanup_git(git), '-C', state.repository, 'checkout', '-f', default_branch]
		repository: state.repository
	}]
}

pub fn cleanup_git_meta_plan(state CleanupRepositoryState) []CleanupAction {
	mut actions := []CleanupAction{}
	if state.pr_locks.len > 0 {
		actions << CleanupAction{
			kind: 'remove_file'
			paths: state.pr_locks.clone()
			repository: state.repository
		}
	}
	actions << CleanupAction{
		kind: 'remove_file'
		paths: ['${state.repository}/.git/gc.log']
		repository: state.repository
	}
	return actions
}

fn clean_arguments() []string {
	return ['-dx', '--exclude=/*.bottle*.*', '--exclude=/Library/Taps',
		'--exclude=/Library/Homebrew/vendor']
}

pub fn clean_if_needed_plan(state CleanupRepositoryState, git string, homebrew_prefix string, homebrew_repository string) []CleanupAction {
	if state.repository == homebrew_prefix && homebrew_prefix != homebrew_repository {
		return []CleanupAction{}
	}
	if state.clean_dry_run.trim_space() == '' {
		return []CleanupAction{}
	}
	return [CleanupAction{
		kind: 'command'
		command: cleanup_append_strings([cleanup_git(git), '-C', state.repository, 'clean', '-ff'], clean_arguments())
		repository: state.repository
	}]
}

pub fn prune_if_needed_plan(state CleanupRepositoryState, git string) []CleanupAction {
	if !state.gc_output.contains('git prune') {
		return []CleanupAction{}
	}
	return [CleanupAction{
		kind: 'command'
		command: [cleanup_git(git), '-C', state.repository, 'prune']
		repository: state.repository
	}]
}

pub fn delete_or_move_plan(input DeleteOrMoveInput) []CleanupAction {
	if input.paths.len == 0 {
		return []CleanupAction{}
	}
	mut actions := []CleanupAction{}
	symlinks := input.paths.filter(it.symlink).map(it.path)
	if symlinks.len > 0 {
		actions << CleanupAction{
			kind: 'remove_file'
			paths: symlinks
		}
	}
	if !input.github_actions {
		return actions
	}
	paths := input.paths.filter(!it.symlink && it.exists).map(it.path)
	if paths.len == 0 {
		return actions
	}
	if input.self_hosted {
		if input.sudo {
			actions << CleanupAction{
				kind: 'command'
				command: cleanup_append_strings(['sudo', 'rm', '-rf'], paths)
				paths: paths
			}
		} else {
			actions << CleanupAction{
				kind: 'remove_tree'
				paths: paths
			}
		}
		return actions
	}
	for index, path in paths {
		destination := if index < input.temporary_directories.len {
			input.temporary_directories[index]
		} else {
			'/tmp/homebrew-test-bot-cleanup-${index}'
		}
		if input.sudo {
			actions << CleanupAction{
				kind: 'command'
				command: ['sudo', 'mv', path, destination]
				paths: [path]
				destination: destination
			}
		} else {
			actions << CleanupAction{
				kind: 'move'
				paths: [path]
				destination: destination
			}
		}
	}
	return actions
}

fn cleanup_repository_state(input CleanupSharedInput, repository string) CleanupRepositoryState {
	for state in input.repositories {
		if state.repository == repository {
			return state
		}
	}
	return CleanupRepositoryState{
		repository: repository
	}
}

fn cleanup_path_basename(path string) string {
	parts := path.split('/')
	if parts.len == 0 {
		return path
	}
	return parts[parts.len - 1]
}

fn cleanup_is_fuse_path(path string) bool {
	mut relative := ''
	if marker := path.index('/include/') {
		relative = path[marker + 9..]
	} else if marker := path.index('/lib/') {
		relative = path[marker + 5..]
	} else {
		return false
	}
	for prefix in ['lib', 'osxfuse/', 'pkgconfig/'] {
		if relative.starts_with(prefix) {
			relative = relative[prefix.len..]
			break
		}
	}
	if !relative.starts_with('fuse') && !relative.starts_with('osxfuse')
		&& !relative.starts_with('macfuse') {
		return false
	}
	return !relative.contains('.') || relative.ends_with('.dylib') || relative.ends_with('.h')
		|| relative.ends_with('.la') || relative.ends_with('.pc')
}

fn cleanup_should_purge_path(input CleanupSharedInput, path CleanupPath) bool {
	if path.path in input.must_be_writable {
		return false
	}
	if path.path == '${input.homebrew_prefix}/bin/brew' || path.path == '${input.homebrew_prefix}/var'
		|| path.path == '${input.homebrew_prefix}/var/homebrew' {
		return false
	}
	basename := cleanup_path_basename(path.path)
	if basename == '.' || basename == '.keepme' {
		return false
	}
	if path.path.starts_with(input.homebrew_repository)
		|| path.path.starts_with(input.working_directory) {
		return false
	}
	if (!path.symlink || path.resolved_exists) && cleanup_is_fuse_path(path.path) {
		return false
	}
	return true
}

pub fn cleanup_shared_plan(input CleanupSharedInput) CleanupPlan {
	mut actions := [CleanupAction{
		kind: 'chmod_recursive'
		paths: [input.homebrew_cellar]
	}]
	if input.repository_exists {
		repository_state := cleanup_repository_state(input, input.repository)
		actions << cleanup_git_meta_plan(repository_state)
		actions << clean_if_needed_plan(repository_state, input.git, input.homebrew_prefix, input.homebrew_repository)
		actions << prune_if_needed_plan(repository_state, input.git)
	}
	mut paths_to_purge := []CleanupPath{}
	if input.homebrew_repository != input.homebrew_prefix {
		actions << CleanupAction{
			kind: 'info_header'
			paths: ['Determining ${input.homebrew_prefix} files to purge...']
		}
		for path in input.must_be_writable {
			actions << CleanupAction{
				kind: 'mkdir'
				paths: [path]
			}
		}
		for path in input.prefix_paths {
			if !cleanup_should_purge_path(input, path) {
				continue
			}
			if path.owned && (!path.readable || !path.writable) {
				actions << CleanupAction{
					kind: 'chmod'
					paths: [path.path]
				}
			}
			paths_to_purge << path
		}
		actions << CleanupAction{
			kind: 'info_header'
			paths: ['Purging...']
		}
		actions << delete_or_move_plan(DeleteOrMoveInput{
			paths: paths_to_purge
			github_actions: input.github_actions
			self_hosted: input.self_hosted
			temporary_directories: input.temporary_directories
		})
	}
	if input.has_tap {
		homebrew_state := cleanup_repository_state(input, input.homebrew_repository)
		actions << checkout_branch_if_needed_plan(homebrew_state, input.git)
		actions << reset_if_needed_plan(homebrew_state, input.git)
		actions << clean_if_needed_plan(homebrew_state, input.git, input.homebrew_prefix, input.homebrew_repository)
	}
	mut seen_tap_paths := map[string]bool{}
	mut taps_to_remove := []CleanupPath{}
	for tap in input.installed_taps {
		if tap.name == input.tap_name || tap.name == 'homebrew/core' || tap.name == 'homebrew/cask'
			|| tap.path in seen_tap_paths {
			continue
		}
		seen_tap_paths[tap.path] = true
		taps_to_remove << CleanupPath{
			path: tap.path
		}
	}
	actions << delete_or_move_plan(DeleteOrMoveInput{
		paths: taps_to_remove
		github_actions: input.github_actions
		self_hosted: input.self_hosted
		temporary_directories: input.temporary_directories
	})
	for repository in input.tap_repositories {
		state := cleanup_repository_state(input, repository)
		actions << cleanup_git_meta_plan(state)
		if repository == input.repository {
			continue
		}
		actions << checkout_branch_if_needed_plan(state, input.git)
		actions << reset_if_needed_plan(state, input.git)
		actions << clean_if_needed_plan(state, input.git, input.homebrew_prefix, input.homebrew_repository)
		actions << prune_if_needed_plan(state, input.git)
	}
	if !input.github_actions || input.self_hosted {
		actions << CleanupAction{
			kind: 'command'
			command: ['brew', 'cleanup', '--prune=3']
		}
	}
	return CleanupPlan{
		actions: actions
		paths_to_purge: paths_to_purge.map(it.path)
	}
}

// Translated from Homebrew/brew `test_bot/test_cleanup.rb`.
