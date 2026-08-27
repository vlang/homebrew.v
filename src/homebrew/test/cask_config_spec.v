module test

import brew_runtime

// Translated from Homebrew/brew `test/cask_config_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uses the current operating system language provider" do` at line 8.
pub fn ruby_cask_config_spec_l8_d1_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/config"
// 5:
// 6: RSpec.describe Cask::Config do
// 7:   describe "#languages" do
// 8:     it "uses the current operating system language provider" do
// 9:       expected_languages = if OS.mac?
// 10:         allow(OS::Mac).to receive(:languages).and_return(["en-US"])
// 11:         ["en-US"]
// 12:       elsif OS.linux?
// 13:         allow(OS::Linux).to receive(:languages).and_return(["en-US"])
// 14:         ["en-US"]
// 15:       else
// 16:         []
// 17:       end
// 18:
// 19:       expect(described_class.new.languages).to eq(expected_languages)
// 20:     end
// 21:   end
// 22: end
