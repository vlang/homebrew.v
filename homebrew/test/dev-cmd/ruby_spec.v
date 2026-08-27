module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/ruby_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "can execute Ruby code without Sorbet runtime", :integration_test do` at line 10.
pub fn ruby_ruby_spec_l10_d1_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby method `check; end` at line 16.
pub fn ruby_ruby_spec_l16_d2_check(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check', ...args)
}

// Ruby it `it "passes Homebrew libraries and code to Ruby" do` at line 35.
pub fn ruby_ruby_spec_l35_d3_passes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('passes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/ruby"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Ruby do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "can execute Ruby code without Sorbet runtime", :integration_test do
// 11:     ruby = <<~RUBY
// 12:       class SorbetRuntimeTest
// 13:         extend T::Sig
// 14:
// 15:         sig { void }
// 16:         def check; end
// 17:       end
// 18:
// 19:       abort if T::Utils.signature_for_method(SorbetRuntimeTest.instance_method(:check))
// 20:     RUBY
// 21:     env = {
// 22:       "HOMEBREW_DEV_CMD_RUN"             => "1",
// 23:       "HOMEBREW_TESTS_NO_SORBET_RUNTIME" => "1",
// 24:       "HOMEBREW_SORBET_RUNTIME"          => "1",
// 25:       "HOMEBREW_SORBET_RECURSIVE"        => "1",
// 26:     }
// 27:
// 28:     expect { brew_sh "ruby", "--", "-e", ruby, env }
// 29:       .to be_a_success
// 30:       .and not_to_output.to_stdout
// 31:       .and not_to_output.to_stderr
// 32:   end
// 33:
// 34:   # Keep the richer expression path in-process as `brew ruby` subprocesses are slow.
// 35:   it "passes Homebrew libraries and code to Ruby" do
// 36:     cmd = described_class.new(["-e", "puts 'testball'.f.path"])
// 37:
// 38:     expect(cmd).to receive(:exec).with(
// 39:       *HOMEBREW_RUBY_EXEC_ARGS,
// 40:       "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 41:       "-rglobal", "-rbrew_irb_helpers",
// 42:       "-e puts 'testball'.f.path"
// 43:     )
// 44:
// 45:     cmd.run
// 46:   end
// 47: end
