module debrew

import ruby

// Translated from Homebrew/brew `debrew/irb.rb`.
pub struct IrbSessionState {
pub mut:
	setup_done  bool
	stdout_sync bool
}

pub type IrbSetup = fn () !

pub type IrbRunner = fn (ruby.Value) !

pub fn irb_start_within(binding ruby.Value, mut state IrbSessionState, setup IrbSetup,
	run IrbRunner) ! {
	old_stdout_sync := state.stdout_sync
	state.stdout_sync = true
	defer {
		state.stdout_sync = old_stdout_sync
	}
	if !state.setup_done {
		setup()!
		state.setup_done = true
	}
	run(binding)!
}

fn irb_noop_setup() ! {}

fn irb_noop_run(_ ruby.Value) ! {}
