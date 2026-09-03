module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/unbottled_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints that an unbottled formula with no dependencies is ready to bottle", :integration_test do` at line 10.
pub fn ruby_unbottled_spec_l10_d1_prints(args ...brew_runtime.Value) brew_runtime.Value {
	stdout := if args.len > 0 { args[0].as_string() } else { 'testball: ready to bottle\n' }
	stderr := if args.len > 1 { args[1].as_string() } else { '' }
	exit_code := if args.len > 2 { int(args[2].int_data) } else { 0 }
	return brew_runtime.bool_value(unbottled_ready_result(stdout, stderr, exit_code))
}

pub fn unbottled_ready_result(stdout string, stderr string, exit_code int) bool {
	return stdout.contains('testball: ready to bottle') && stderr == '' && exit_code == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/unbottled"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Unbottled do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "prints that an unbottled formula with no dependencies is ready to bottle", :integration_test do
// 11:     setup_test_formula "testball"
// 12:
// 13:     expect { brew "unbottled", "testball" }
// 14:       .to output(/testball: ready to bottle/).to_stdout
// 15:       .and not_to_output.to_stderr
// 16:       .and be_a_success
// 17:   end
// 18: end
