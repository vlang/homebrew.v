module cask

import brew_runtime
import os

// Translated from Homebrew/brew `cask/staged.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn staged_paths_from_value(value brew_runtime.Value) []string {
	return if value.type_name == 'Array' {
		value.as_string_array() or { [] }
	} else {
		[value.as_string()]
	}
}

fn staged_state_value(state &StagedState) brew_runtime.Value {
	return brew_runtime.structured_value('Cask::Staged', state.cask, {
		'staged_state_address': u64(voidptr(state)).str()
	})
}

fn staged_state_from_value(value brew_runtime.Value) &StagedState {
	address := value.attributes['staged_state_address'] or { panic('invalid Cask::Staged state') }
	return unsafe { &StagedState(voidptr(address.u64())) }
}

pub fn staged_state_boundary(state &StagedState) brew_runtime.Value {
	return staged_state_value(state)
}

// Ruby method `set_permissions(paths, permissions_str)` at line 19.
pub fn ruby_staged_l19_d1_set_permissions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'state, paths and permissions are required')
	}
	mut state := staged_state_from_value(args[0])
	state.set_permissions(staged_paths_from_value(args[1]), args[2].as_string())
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `set_ownership(paths, user: T.must(User.current), group: "staff")` at line 28.
pub fn ruby_staged_l28_d2_set_ownership(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'state and paths are required')
	}
	mut state := staged_state_from_value(args[0])
	user := if args.len > 2 { args[2].as_string() } else { state.current_user }
	group := if args.len > 3 { args[3].as_string() } else { 'staff' }
	state.set_ownership(staged_paths_from_value(args[1]), user, group) or {
		return brew_runtime.object_value('Cask::CaskError', err.msg())
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `remove_nonexistent(paths)` at line 58.
pub fn ruby_staged_l58_d3_remove_nonexistent(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.string_array_value([])
	}
	return brew_runtime.string_array_value(staged_state_from_value(args[0]).remove_nonexistent(staged_paths_from_value(args[1])))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/quarantine"
// 5: require "utils/user"
// 6: require "utils/output"
// 7:
// 8: module Cask
// 9:   # Helper functions for staged casks.
// 10:   module Staged
// 11:     include ::Utils::Output::Mixin
// 12:     extend T::Helpers
// 13:
// 14:     requires_ancestor { ::Cask::DSL::Base }
// 15:
// 16:     Paths = T.type_alias { T.any(String, Pathname, T::Array[T.any(String, Pathname)]) }
// 17:
// 18:     sig { params(paths: Paths, permissions_str: String).void }
// 19:     def set_permissions(paths, permissions_str)
// 20:       full_paths = remove_nonexistent(paths)
// 21:       return if full_paths.empty?
// 22:
// 23:       command.run!("chmod", args: ["-R", "--", permissions_str, *full_paths],
// 24:                             sudo: false)
// 25:     end
// 26:
// 27:     sig { params(paths: Paths, user: T.any(String, User), group: String).void }
// 28:     def set_ownership(paths, user: T.must(User.current), group: "staff")
// 29:       full_paths = remove_nonexistent(paths)
// 30:       return if full_paths.empty?
// 31:
// 32:       # On macOS Ventura or later, modifying the contents of an app bundle
// 33:       # requires App Management permissions, even when using `sudo`. Without
// 34:       # them, every `chown` fails with `Operation not permitted`, so check
// 35:       # upfront: this triggers the system permission prompt (which a plain
// 36:       # `chown` does not) and allows giving the user an actionable error
// 37:       # message instead of a wall of `chown` errors.
// 38:       full_paths.each do |path|
// 39:         next if Quarantine.app_management_permissions_granted?(app: path, command:)
// 40:
// 41:         raise CaskError, <<~EOS
// 42:           Cannot change the ownership of '#{path}' because your terminal does not have App Management permissions.
// 43:           macOS prevents modifying apps without these permissions, even when using `sudo`.
// 44:           To fix this, approve the permissions prompt (if one was just shown) or go to
// 45:           System Settings → Privacy & Security → App Management and add or enable your terminal.
// 46:           Then run this command again.
// 47:         EOS
// 48:       end
// 49:
// 50:       ohai "Changing ownership of paths required by #{cask} with `sudo` (which may request your password)..."
// 51:       command.run!("chown", args: ["-R", "--", "#{user}:#{group}", *full_paths],
// 52:                             sudo: true)
// 53:     end
// 54:
// 55:     private
// 56:
// 57:     sig { params(paths: Paths).returns(T::Array[Pathname]) }
// 58:     def remove_nonexistent(paths)
// 59:       Array(paths).map { |p| Pathname(p).expand_path }.select(&:exist?)
// 60:     end
// 61:   end
// 62: end
