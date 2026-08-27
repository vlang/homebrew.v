module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/typecheck_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:rbi_file) { Pathname.new("#{TEST_FIXTURE_DIR}/rubocop@x.x.x.rbi") }` at line 11.
pub fn ruby_typecheck_spec_l11_d1_rbi_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rbi_file', ...args)
}

// Ruby let `let(:typecheck) { described_class.new([]) }` at line 12.
pub fn ruby_typecheck_spec_l12_d2_typecheck(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('typecheck', ...args)
}

// Ruby it `it "trims RuboCop RBI file to only include allowlisted classes" do` at line 18.
pub fn ruby_typecheck_spec_l18_d3_trims(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trims', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/typecheck"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Typecheck do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe "#trim_rubocop_rbi" do
// 11:     let(:rbi_file) { Pathname.new("#{TEST_FIXTURE_DIR}/rubocop@x.x.x.rbi") }
// 12:     let(:typecheck) { described_class.new([]) }
// 13:
// 14:     before do
// 15:       allow(Dir).to receive(:glob).and_return([rbi_file.to_s])
// 16:     end
// 17:
// 18:     it "trims RuboCop RBI file to only include allowlisted classes" do
// 19:       old_content = rbi_file.read
// 20:
// 21:       typecheck.trim_rubocop_rbi(path: rbi_file.to_s)
// 22:
// 23:       new_content = rbi_file.read
// 24:
// 25:       expect(new_content).to include("RuboCop::Config")
// 26:       expect(new_content).to include("RuboCop::Cop::Base")
// 27:       expect(new_content).to include("Parser::Source")
// 28:       expect(new_content).to include("VERSION")
// 29:       expect(new_content).to include("SOME_CONSTANT")
// 30:       expect(new_content).not_to include("SomeUnusedCop")
// 31:       expect(new_content).not_to include("UnusedModule")
// 32:       expect(new_content).not_to include("CompletelyUnrelated")
// 33:
// 34:       rbi_file.write(old_content)
// 35:     end
// 36:   end
// 37: end
