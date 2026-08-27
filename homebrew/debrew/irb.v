module debrew

import brew_runtime

// Translated from Homebrew/brew `debrew/irb.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.start_within(binding)` at line 8.
pub fn ruby_irb_l8_d1_self_start_within(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.start_within', ...args)
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
