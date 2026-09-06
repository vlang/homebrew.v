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

fn irb_noop_setup() ! {}

fn irb_noop_run(_ ruby.Value) ! {}
