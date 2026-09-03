module test_bot

import brew_runtime

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

fn cleanup_action_value(action CleanupAction) brew_runtime.Value {
	return brew_runtime.map_value({
		'kind':        brew_runtime.string_value(action.kind)
		'command':     brew_runtime.string_array_value(action.command)
		'paths':       brew_runtime.string_array_value(action.paths)
		'repository':  brew_runtime.string_value(action.repository)
		'destination': brew_runtime.string_value(action.destination)
		'seconds':     brew_runtime.int_value(action.seconds)
	})
}

fn cleanup_actions_value(actions []CleanupAction) brew_runtime.Value {
	return brew_runtime.array_value(actions.map(cleanup_action_value(it)))
}

fn cleanup_plan_value(plan CleanupPlan) brew_runtime.Value {
	return brew_runtime.map_value({
		'actions':        cleanup_actions_value(plan.actions)
		'paths_to_purge': brew_runtime.string_array_value(plan.paths_to_purge)
	})
}

fn cleanup_value_string(args []brew_runtime.Value, index int, fallback string) string {
	if index >= args.len {
		return fallback
	}
	return args[index].as_string()
}

fn cleanup_value_bool(args []brew_runtime.Value, index int, fallback bool) bool {
	if index >= args.len || args[index].type_name != 'Bool' {
		return fallback
	}
	return args[index].bool_data
}

fn cleanup_value_strings(args []brew_runtime.Value, index int) []string {
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
// The original source is retained below until every stub has a typed V body.

// Ruby method `reset_if_needed(repository)` at line 18.
pub fn ruby_test_cleanup_l18_d1_reset_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	repository := cleanup_value_string(args, 0, '')
	return cleanup_actions_value(reset_if_needed_plan(CleanupRepositoryState{
		repository: repository
		origin_head: cleanup_value_string(args, 2, '')
		diff_quiet: cleanup_value_bool(args, 3, true)
	}, cleanup_value_string(args, 1, 'git')))
}

// Ruby method `delete_or_move(paths, sudo: false)` at line 29.
pub fn ruby_test_cleanup_l29_d2_delete_or_move(args ...brew_runtime.Value) brew_runtime.Value {
	paths := cleanup_value_strings(args, 0)
	symlinks := cleanup_value_strings(args, 1)
	existing := cleanup_value_strings(args, 2)
	mut path_inputs := []CleanupPath{}
	for path in paths {
		path_inputs << CleanupPath{
			path: path
			symlink: path in symlinks
			exists: path in existing
		}
	}
	return cleanup_actions_value(delete_or_move_plan(DeleteOrMoveInput{
		paths: path_inputs
		github_actions: cleanup_value_bool(args, 3, false)
		self_hosted: cleanup_value_bool(args, 4, false)
		sudo: cleanup_value_bool(args, 5, false)
		temporary_directories: cleanup_value_strings(args, 6)
	}))
}

// Ruby method `cleanup_shared` at line 58.
pub fn ruby_test_cleanup_l58_d3_cleanup_shared(args ...brew_runtime.Value) brew_runtime.Value {
	repository := cleanup_value_string(args, 0, '')
	homebrew_repository := cleanup_value_string(args, 2, repository)
	prefix := cleanup_value_string(args, 3, homebrew_repository)
	has_tap := cleanup_value_bool(args, 4, false)
	return cleanup_plan_value(cleanup_shared_plan(CleanupSharedInput{
		repository: repository
		repository_exists: cleanup_value_bool(args, 1, false)
		homebrew_repository: homebrew_repository
		homebrew_prefix: prefix
		homebrew_cellar: '${prefix}/Cellar'
		has_tap: has_tap
		tap_name: cleanup_value_string(args, 5, '')
		github_actions: cleanup_value_bool(args, 6, false)
		self_hosted: cleanup_value_bool(args, 7, false)
		repositories: [CleanupRepositoryState{
			repository: homebrew_repository
			origin_head: 'origin/main'
			current_branch: 'main'
		}]
	}))
}

// Ruby method `default_origin_ref(repository)` at line 139.
pub fn ruby_test_cleanup_l139_d4_default_origin_ref(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(cleanup_default_ref(cleanup_value_string(args, 1, '')))
}

// Ruby method `checkout_branch_if_needed(repository)` at line 148.
pub fn ruby_test_cleanup_l148_d5_checkout_branch_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return cleanup_actions_value(checkout_branch_if_needed_plan(CleanupRepositoryState{
		repository: cleanup_value_string(args, 0, '')
		origin_head: cleanup_value_string(args, 2, '')
		current_branch: cleanup_value_string(args, 3, '')
	}, cleanup_value_string(args, 1, 'git')))
}

// Ruby method `cleanup_git_meta(repository)` at line 160.
pub fn ruby_test_cleanup_l160_d6_cleanup_git_meta(args ...brew_runtime.Value) brew_runtime.Value {
	return cleanup_actions_value(cleanup_git_meta_plan(CleanupRepositoryState{
		repository: cleanup_value_string(args, 0, '')
		pr_locks: cleanup_value_strings(args, 1)
	}))
}

// Ruby method `clean_if_needed(repository)` at line 167.
pub fn ruby_test_cleanup_l167_d7_clean_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return cleanup_actions_value(clean_if_needed_plan(CleanupRepositoryState{
		repository: cleanup_value_string(args, 0, '')
		clean_dry_run: cleanup_value_string(args, 2, '')
	}, cleanup_value_string(args, 1, 'git'), cleanup_value_string(args, 3, ''), cleanup_value_string(args, 4, '')))
}

// Ruby method `prune_if_needed(repository)` at line 184.
pub fn ruby_test_cleanup_l184_d8_prune_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return cleanup_actions_value(prune_if_needed_plan(CleanupRepositoryState{
		repository: cleanup_value_string(args, 0, '')
		gc_output: cleanup_value_string(args, 2, '')
	}, cleanup_value_string(args, 1, 'git')))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os"
// 5: require "tap"
// 6:
// 7: module Homebrew
// 8:   module TestBot
// 9:     class TestCleanup < Test
// 10:       protected
// 11:
// 12:       ALLOWED_TAPS = T.let([
// 13:         CoreTap.instance.name,
// 14:         CoreCaskTap.instance.name,
// 15:       ].freeze, T::Array[String])
// 16:
// 17:       sig { params(repository: String).void }
// 18:       def reset_if_needed(repository)
// 19:         default_ref = default_origin_ref(repository)
// 20:
// 21:         return if system(git.to_s, "-C", repository, "diff", "--quiet", default_ref)
// 22:
// 23:         test git.to_s, "-C", repository, "reset", "--hard", default_ref
// 24:       end
// 25:
// 26:       # Moving files is faster than removing them,
// 27:       # so move them if the current runner is ephemeral.
// 28:       sig { params(paths: T::Array[Pathname], sudo: T::Boolean).void }
// 29:       def delete_or_move(paths, sudo: false)
// 30:         return if paths.blank?
// 31:
// 32:         symlinks, paths = paths.partition(&:symlink?)
// 33:
// 34:         FileUtils.rm_f symlinks
// 35:         return if ENV["HOMEBREW_GITHUB_ACTIONS"].blank?
// 36:
// 37:         paths.select!(&:exist?)
// 38:         return if paths.blank?
// 39:
// 40:         if ENV["GITHUB_ACTIONS_HOMEBREW_SELF_HOSTED"].present?
// 41:           if sudo
// 42:             test "sudo", "rm", "-rf", *paths.map(&:to_s)
// 43:           else
// 44:             FileUtils.rm_rf paths
// 45:           end
// 46:         else
// 47:           paths.each do |path|
// 48:             if sudo
// 49:               test "sudo", "mv", path.to_s, Dir.mktmpdir
// 50:             else
// 51:               FileUtils.mv path, Dir.mktmpdir, force: true
// 52:             end
// 53:           end
// 54:         end
// 55:       end
// 56:
// 57:       sig { void }
// 58:       def cleanup_shared
// 59:         FileUtils.chmod_R("u+X", HOMEBREW_CELLAR, force: true)
// 60:
// 61:         if repository.exist?
// 62:           repo = repository.to_s
// 63:           cleanup_git_meta(repo)
// 64:           clean_if_needed(repo)
// 65:           prune_if_needed(repo)
// 66:         end
// 67:
// 68:         if HOMEBREW_REPOSITORY != HOMEBREW_PREFIX
// 69:           paths_to_delete = []
// 70:
// 71:           info_header "Determining #{HOMEBREW_PREFIX} files to purge..."
// 72:           Keg.must_be_writable_directories.each(&:mkpath)
// 73:           Pathname.glob("#{HOMEBREW_PREFIX}/**/*", File::FNM_DOTMATCH).each do |path|
// 74:             next if Keg.must_be_writable_directories.include?(path)
// 75:             next if path == HOMEBREW_PREFIX/"bin/brew"
// 76:             next if path == HOMEBREW_PREFIX/"var"
// 77:             next if path == HOMEBREW_PREFIX/"var/homebrew"
// 78:
// 79:             basename = path.basename.to_s
// 80:             next if basename == "."
// 81:             next if basename == ".keepme"
// 82:
// 83:             path_string = path.to_s
// 84:             next if path_string.start_with?(HOMEBREW_REPOSITORY.to_s)
// 85:             next if path_string.start_with?(Dir.pwd.to_s)
// 86:
// 87:             # allow deleting non-existent osxfuse symlinks.
// 88:             if (!path.symlink? || path.resolved_path_exists?) &&
// 89:                # don't try to delete other osxfuse files
// 90:                path_string.match?("(include|lib)/(lib|osxfuse/|pkgconfig/)?(osx|mac)?fuse(.*.(dylib|h|la|pc))?$")
// 91:               next
// 92:             end
// 93:
// 94:             FileUtils.chmod("u+rw", path) if path.owned? && (!path.readable? || !path.writable?)
// 95:             paths_to_delete << path
// 96:           end
// 97:
// 98:           # Do this in a second pass so that all children have their permissions fixed before we delete the parent.
// 99:           info_header "Purging..."
// 100:           delete_or_move paths_to_delete
// 101:         end
// 102:
// 103:         if tap
// 104:           checkout_branch_if_needed(HOMEBREW_REPOSITORY.to_s)
// 105:           reset_if_needed(HOMEBREW_REPOSITORY.to_s)
// 106:           clean_if_needed(HOMEBREW_REPOSITORY.to_s)
// 107:         end
// 108:
// 109:         # Keep all "brew" invocations after HOMEBREW_REPOSITORY operations
// 110:         # (which cleans up Homebrew/brew)
// 111:         taps_to_remove = Tap.map do |t|
// 112:           next if t.name == tap&.name
// 113:           next if ALLOWED_TAPS.include?(t.name)
// 114:
// 115:           t.path
// 116:         end.uniq.compact
// 117:         delete_or_move taps_to_remove
// 118:
// 119:         Pathname.glob("#{HOMEBREW_LIBRARY}/Taps/*/*").each do |git_repo|
// 120:           git_repo_str = git_repo.to_s
// 121:           cleanup_git_meta(git_repo_str)
// 122:           next if repository == git_repo
// 123:
// 124:           checkout_branch_if_needed(git_repo_str)
// 125:           reset_if_needed(git_repo_str)
// 126:           clean_if_needed(git_repo_str)
// 127:           prune_if_needed(git_repo_str)
// 128:         end
// 129:
// 130:         # don't need to do `brew cleanup` unless we're self-hosted.
// 131:         return if ENV["HOMEBREW_GITHUB_ACTIONS"] && !ENV["GITHUB_ACTIONS_HOMEBREW_SELF_HOSTED"]
// 132:
// 133:         test "brew", "cleanup", "--prune=3"
// 134:       end
// 135:
// 136:       private
// 137:
// 138:       sig { params(repository: String).returns(String) }
// 139:       def default_origin_ref(repository)
// 140:         default_branch = Utils.popen_read(
// 141:           git, "-C", repository, "symbolic-ref", "refs/remotes/origin/HEAD", "--short"
// 142:         ).strip.presence
// 143:         default_branch ||= "origin/main"
// 144:         default_branch
// 145:       end
// 146:
// 147:       sig { params(repository: String).void }
// 148:       def checkout_branch_if_needed(repository)
// 149:         # We limit this to two parts, because branch names can have slashes in
// 150:         default_branch = default_origin_ref(repository).split("/", 2).last
// 151:         current_branch = Utils.safe_popen_read(
// 152:           git, "-C", repository, "symbolic-ref", "HEAD", "--short"
// 153:         ).strip
// 154:         return if default_branch == current_branch
// 155:
// 156:         test git.to_s, "-C", repository, "checkout", "-f", default_branch.to_s
// 157:       end
// 158:
// 159:       sig { params(repository: String).void }
// 160:       def cleanup_git_meta(repository)
// 161:         pr_locks = "#{repository}/.git/refs/remotes/*/pr/*/*.lock"
// 162:         Dir.glob(pr_locks) { |lock| FileUtils.rm_f lock }
// 163:         FileUtils.rm_f "#{repository}/.git/gc.log"
// 164:       end
// 165:
// 166:       sig { params(repository: String).void }
// 167:       def clean_if_needed(repository)
// 168:         return if repository == HOMEBREW_PREFIX && HOMEBREW_PREFIX != HOMEBREW_REPOSITORY
// 169:
// 170:         clean_args = [
// 171:           "-dx",
// 172:           "--exclude=/*.bottle*.*",
// 173:           "--exclude=/Library/Taps",
// 174:           "--exclude=/Library/Homebrew/vendor",
// 175:         ]
// 176:         return if Utils.safe_popen_read(
// 177:           git, "-C", repository, "clean", "--dry-run", *clean_args
// 178:         ).strip.empty?
// 179:
// 180:         test git.to_s, "-C", repository, "clean", "-ff", *clean_args
// 181:       end
// 182:
// 183:       sig { params(repository: String).void }
// 184:       def prune_if_needed(repository)
// 185:         return unless Utils.safe_popen_read(
// 186:           "#{git} -C '#{repository}' -c gc.autoDetach=false gc --auto 2>&1",
// 187:         ).include?("git prune")
// 188:
// 189:         test git.to_s, "-C", repository, "prune"
// 190:       end
// 191:     end
// 192:   end
// 193: end
