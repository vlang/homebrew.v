module debrew

import brew_runtime

// Translated from Homebrew/brew `debrew/irb.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct IrbSessionState {
pub mut:
	setup_done  bool
	stdout_sync bool
}

pub type IrbSetup = fn() !

pub type IrbRunner = fn(brew_runtime.Value) !

pub fn irb_start_within(binding brew_runtime.Value, mut state IrbSessionState, setup IrbSetup,
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

fn irb_noop_run(_ brew_runtime.Value) ! {}

// Ruby method `self.start_within(binding)` at line 8.
pub fn ruby_irb_l8_d1_self_start_within(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('IRB.start_within requires a binding')
	}
	mut state := IrbSessionState{
		setup_done: if args.len > 1 { args[1].as_bool() or { false } } else { false }
		stdout_sync: if args.len > 2 { args[2].as_bool() or { false } } else { false }
	}
	irb_start_within(args[0], mut state, irb_noop_setup, irb_noop_run) or { panic(err) }
	return brew_runtime.structured_value('IrbSessionState', 'IRB', {
		'setup_done':  state.setup_done.str()
		'stdout_sync': state.stdout_sync.str()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "irb"
// 5:
// 6: module IRB
// 7:   sig { params(binding: Binding).void }
// 8:   def self.start_within(binding)
// 9:     old_stdout_sync = $stdout.sync
// 10:     $stdout.sync = true
// 11:
// 12:     @setup_done ||= T.let(false, T.nilable(T::Boolean))
// 13:     unless @setup_done
// 14:       setup(nil, argv: [])
// 15:       @setup_done = true
// 16:     end
// 17:
// 18:     workspace = WorkSpace.new(binding)
// 19:     irb = Irb.new(workspace)
// 20:     irb.run(conf)
// 21:   ensure
// 22:     $stdout.sync = old_stdout_sync
// 23:   end
// 24: end
