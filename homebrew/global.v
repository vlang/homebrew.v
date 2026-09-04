module homebrew

import ruby

// Translated from Homebrew/brew `global.rb`.

// GlobalState is V's explicit equivalent of the mutable singleton instance
// variables on Ruby's Homebrew module. Explicit ownership avoids hidden globals
// while retaining mutation and memoized Messages for a command invocation.
pub struct GlobalState {
pub mut:
	failed                       bool
	raise_deprecation_exceptions bool
	auditing                     bool
	messages                     Messages
	process_euid                 int
	owner_uid                    int
	running_command              string
}

pub fn new_global_state(process_euid int, owner_uid int) GlobalState {
	return GlobalState{
		messages: new_messages()
		process_euid: process_euid
		owner_uid: owner_uid
	}
}

pub fn global_state_from_process(original_brew_file string) !GlobalState {
	return new_global_state(ruby.effective_uid(), ruby.file_owner_uid(original_brew_file)!)
}

pub fn default_prefix(prefix string) bool {
	return prefix == ruby.environment_value('HOMEBREW_DEFAULT_PREFIX')
}

pub fn (state GlobalState) running_as_root() bool {
	return state.process_euid == 0
}

pub fn (state GlobalState) running_as_root_but_not_owned_by_root() bool {
	return state.running_as_root() && state.owner_uid != 0
}

pub fn auto_update_command() bool {
	return ruby.environment_value('HOMEBREW_AUTO_UPDATE_COMMAND').trim_space() != ''
}

pub fn (mut state GlobalState) set_running_command(cmd string, argv []string) {
	state.running_command = '${cmd} ${argv.join(' ')}'.trim_space()
}

pub fn (state GlobalState) running_command_with_args() string {
	return 'brew ${state.running_command}'.trim_space()
}
