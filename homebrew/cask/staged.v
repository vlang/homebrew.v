module cask

import ruby
import os

// Translated from Homebrew/brew `cask/staged.rb`.
pub struct StagedCommandInvocation {
pub:
	executable string
	args       []string
	sudo       bool
}

@[heap]
pub struct StagedState {
pub:
	cask                  string
	current_user          string = 'root'
	existing_paths        []string
	app_management_denied []string
pub mut:
	invocations []StagedCommandInvocation
	messages    []string
}

pub fn new_staged_state(cask string, current_user string, existing_paths []string,
	app_management_denied []string) &StagedState {
	return &StagedState{
		cask: cask
		current_user: current_user
		existing_paths: existing_paths.map(os.abs_path(it))
		app_management_denied: app_management_denied.map(os.abs_path(it))
	}
}

pub fn (state &StagedState) remove_nonexistent(paths []string) []string {
	mut existing := []string{}
	for path in paths {
		full_path := os.abs_path(path)
		if full_path in state.existing_paths || os.exists(full_path) || os.is_link(full_path) {
			existing << full_path
		}
	}
	return existing
}

pub fn (mut state StagedState) system_command(executable string, args []string, sudo bool) {
	state.invocations << StagedCommandInvocation{
		executable: executable
		args: args.clone()
		sudo: sudo
	}
}

pub fn (mut state StagedState) set_permissions(paths []string, permissions string) {
	full_paths := state.remove_nonexistent(paths)
	if full_paths.len == 0 {
		return
	}
	mut command_args := ['-R', '--', permissions]
	command_args << full_paths
	state.invocations << StagedCommandInvocation{
		executable: 'chmod'
		args: command_args
		sudo: false
	}
}

pub fn (mut state StagedState) set_ownership(paths []string, user string, group string) ! {
	full_paths := state.remove_nonexistent(paths)
	if full_paths.len == 0 {
		return
	}
	for path in full_paths {
		if path in state.app_management_denied {
			return error("Cannot change the ownership of '${path}' because your terminal does not have App Management permissions.\nmacOS prevents modifying apps without these permissions, even when using `sudo`.\nTo fix this, approve the permissions prompt (if one was just shown) or go to\nSystem Settings → Privacy & Security → App Management and add or enable your terminal.\nThen run this command again.")
		}
	}
	effective_user := if user != '' { user } else { state.current_user }
	effective_group := if group != '' { group } else { 'staff' }
	state.messages << 'Changing ownership of paths required by ${state.cask} with `sudo` (which may request your password)...'
	mut command_args := ['-R', '--', '${effective_user}:${effective_group}']
	command_args << full_paths
	state.invocations << StagedCommandInvocation{
		executable: 'chown'
		args: command_args
		sudo: true
	}
}

fn staged_paths_from_value(value ruby.Value) []string {
	return if value.type_name == 'Array' {
		value.as_string_array() or { [] }
	} else {
		[value.as_string()]
	}
}

fn staged_state_value(state &StagedState) ruby.Value {
	return ruby.structured_value('Cask::Staged', state.cask, {
		'staged_state_address': u64(voidptr(state)).str()
	})
}

fn staged_state_from_value(value ruby.Value) &StagedState {
	address := value.attributes['staged_state_address'] or { panic('invalid Cask::Staged state') }
	return unsafe { &StagedState(voidptr(address.u64())) }
}

pub fn staged_state_boundary(state &StagedState) ruby.Value {
	return staged_state_value(state)
}
