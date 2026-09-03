module support

import brew_runtime

// Translated from Homebrew/brew `test/support/quiet_progress_formatter.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `dump_summary(notification); end` at line 9.
pub fn ruby_quiet_progress_formatter_l9_d1_dump_summary(args ...brew_runtime.Value) brew_runtime.Value {
	return quiet_progress_formatter_noop(args)
}

// Ruby method `seed(notification); end` at line 10.
pub fn ruby_quiet_progress_formatter_l10_d2_seed(args ...brew_runtime.Value) brew_runtime.Value {
	return quiet_progress_formatter_noop(args)
}

// Ruby method `close(notification); end` at line 11.
pub fn ruby_quiet_progress_formatter_l11_d3_close(args ...brew_runtime.Value) brew_runtime.Value {
	return quiet_progress_formatter_noop(args)
}

pub fn quiet_progress_formatter_noop(_notification []brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rspec/core/formatters/progress_formatter"
// 5:
// 6: class QuietProgressFormatter < RSpec::Core::Formatters::ProgressFormatter
// 7:   RSpec::Core::Formatters.register self, :seed
// 8:
// 9:   def dump_summary(notification); end
// 10:   def seed(notification); end
// 11:   def close(notification); end
// 12: end
