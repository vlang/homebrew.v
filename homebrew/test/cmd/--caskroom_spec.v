module cmd

import brew_runtime
import homebrew.cmd as cmd_core

// Translated from Homebrew/brew `test/cmd/--caskroom_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints Homebrew's Caskroom", :integration_test do` at line 10.
pub fn ruby_caskroom_spec_l10_d1_prints(args ...brew_runtime.Value) brew_runtime.Value {
	caskroom := if args.len > 0 { args[0].as_string() } else { '/opt/homebrew/Caskroom' }
	return brew_runtime.bool_value(cmd_core.caskroom_output(caskroom, []) == '${caskroom}\n')
}

// Ruby it `it "prints the Caskroom for Casks" do` at line 17.
pub fn ruby_caskroom_spec_l17_d2_prints(args ...brew_runtime.Value) brew_runtime.Value {
	caskroom := if args.len > 0 { args[0].as_string() } else { '/opt/homebrew/Caskroom' }
	expected := '${caskroom}/local-transmission\n${caskroom}/local-caffeine\n'
	return brew_runtime.bool_value(cmd_core.caskroom_output(caskroom, [
		'local-transmission',
		'local-caffeine',
	]) == expected)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/--caskroom"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Caskroom do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "prints Homebrew's Caskroom", :integration_test do
// 11:     expect { brew_sh "--caskroom" }
// 12:       .to output("#{ENV.fetch("HOMEBREW_PREFIX")}/Caskroom\n").to_stdout
// 13:       .and not_to_output.to_stderr
// 14:       .and be_a_success
// 15:   end
// 16:
// 17:   it "prints the Caskroom for Casks" do
// 18:     cmd = described_class.new(%w[local-transmission local-caffeine])
// 19:     allow(cmd.args.named).to receive(:to_casks).and_return([
// 20:       instance_double(Cask::Cask, token: "local-transmission"),
// 21:       instance_double(Cask::Cask, token: "local-caffeine"),
// 22:     ])
// 23:
// 24:     expect { cmd.run }
// 25:       .to output("#{HOMEBREW_PREFIX/"Caskroom"/"local-transmission"}\n" \
// 26:                  "#{HOMEBREW_PREFIX/"Caskroom"/"local-caffeine"}\n").to_stdout
// 27:       .and not_to_output.to_stderr
// 28:   end
// 29: end
