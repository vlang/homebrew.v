module cmd

import brew_runtime
import homebrew.cmd as cmd_core

// Translated from Homebrew/brew `test/cmd/--cellar_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints Homebrew's Cellar", :integration_test do` at line 10.
pub fn ruby_cellar_spec_l10_d1_prints(args ...brew_runtime.Value) brew_runtime.Value {
	cellar := if args.len > 0 { args[0].as_string() } else { '/opt/homebrew/Cellar' }
	return brew_runtime.bool_value(cmd_core.cellar_output(cellar, []) == '${cellar}\n')
}

// Ruby it `it "prints the Cellar for a Formula" do` at line 17.
pub fn ruby_cellar_spec_l17_d2_prints(args ...brew_runtime.Value) brew_runtime.Value {
	cellar := if args.len > 0 { args[0].as_string() } else { '/opt/homebrew/Cellar' }
	return brew_runtime.bool_value(cmd_core.cellar_output(cellar, [
		'${cellar}/testball',
	]) == '${cellar}/testball\n')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/--cellar"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Cellar do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "prints Homebrew's Cellar", :integration_test do
// 11:     expect { brew_sh "--cellar" }
// 12:       .to output("#{ENV.fetch("HOMEBREW_CELLAR")}\n").to_stdout
// 13:       .and not_to_output.to_stderr
// 14:       .and be_a_success
// 15:   end
// 16:
// 17:   it "prints the Cellar for a Formula" do
// 18:     cmd = described_class.new(["testball"])
// 19:     allow(cmd.args.named).to receive(:to_resolved_formulae)
// 20:       .and_return([instance_double(Formula, rack: HOMEBREW_CELLAR/"testball")])
// 21:
// 22:     expect { cmd.run }
// 23:       .to output(%r{#{HOMEBREW_CELLAR}/testball}o).to_stdout
// 24:       .and not_to_output.to_stderr
// 25:   end
// 26: end
