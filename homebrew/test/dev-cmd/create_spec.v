module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/create_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:url) { "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz" }` at line 8.
pub fn ruby_create_spec_l8_d1_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby let `let(:formula_file) { CoreTap.instance.new_formula_path("testball") }` at line 9.
pub fn ruby_create_spec_l9_d2_formula_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_file', ...args)
}

// Ruby it `it "creates a new Formula file for a given URL", :integration_test do` at line 13.
pub fn ruby_create_spec_l13_d3_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "generates valid cask tokens" do` at line 20.
pub fn ruby_create_spec_l20_d4_generates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generates', ...args)
}

// Ruby it `it "retains @ in cask tokens" do` at line 25.
pub fn ruby_create_spec_l25_d5_retains(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retains', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/create"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Create do
// 8:   let(:url) { "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz" }
// 9:   let(:formula_file) { CoreTap.instance.new_formula_path("testball") }
// 10:
// 11:   it_behaves_like "parseable arguments"
// 12:
// 13:   it "creates a new Formula file for a given URL", :integration_test do
// 14:     brew "create", "--set-name=Testball", url, "HOMEBREW_EDITOR" => "/bin/cat"
// 15:
// 16:     expect(formula_file).to exist
// 17:     expect(formula_file.read).to match(%Q(sha256 "#{TESTBALL_SHA256}"))
// 18:   end
// 19:
// 20:   it "generates valid cask tokens" do
// 21:     t = Cask::Utils.token_from("A FooBar_Baz++!")
// 22:     expect(t).to eq("a-foobar-baz-plus-plus")
// 23:   end
// 24:
// 25:   it "retains @ in cask tokens" do
// 26:     t = Cask::Utils.token_from("test@preview")
// 27:     expect(t).to eq("test@preview")
// 28:   end
// 29: end
