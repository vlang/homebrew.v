module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/irb_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "deprecates the Pry option" do` at line 10.
pub fn ruby_irb_spec_l10_d1_deprecates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deprecates', ...args)
}

// Ruby let `let(:history_file) { Pathname("#{Dir.home}/.brew_irb_history") }` at line 16.
pub fn ruby_irb_spec_l16_d2_history_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('history_file', ...args)
}

// Ruby it `it "starts an interactive Homebrew shell session", :integration_test do` at line 22.
pub fn ruby_irb_spec_l22_d3_starts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('starts', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/irb"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Irb do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "deprecates the Pry option" do
// 11:     expect { described_class.new(["--pry"]) }
// 12:       .to raise_error(MethodDeprecatedError, /default IRB backend.*Pry is largely unmaintained upstream/i)
// 13:   end
// 14:
// 15:   describe "integration test" do
// 16:     let(:history_file) { Pathname("#{Dir.home}/.brew_irb_history") }
// 17:
// 18:     after do
// 19:       history_file.delete if history_file.exist?
// 20:     end
// 21:
// 22:     it "starts an interactive Homebrew shell session", :integration_test do
// 23:       setup_test_formula "testball"
// 24:
// 25:       irb_test = HOMEBREW_TEMP/"irb-test.rb"
// 26:       irb_test.write <<~RUBY
// 27:         "testball".f
// 28:         :testball.f
// 29:         exit
// 30:       RUBY
// 31:
// 32:       # Coverage integration tests can load `io-console` before `irb`; Linux
// 33:       # may warn when `irb` loads the native extension again.
// 34:       expect { brew "irb", irb_test }
// 35:         .to output(/Interactive Homebrew Shell.*<Formula testball \(stable\)/m).to_stdout
// 36:         .and be_a_success
// 37:
// 38:       # TODO: newer Ruby only supports history saving in interactive sessions
// 39:       #       and not if you feed in data from a file or stdin like we are doing here.
// 40:       #       The test will need to be adjusted for this to work.
// 41:       # expect(history_file).to exist
// 42:     end
// 43:   end
// 44: end
