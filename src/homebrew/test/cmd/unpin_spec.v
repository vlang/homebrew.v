module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/unpin_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "unpins a Formula's version", :integration_test do` at line 10.
pub fn ruby_unpin_spec_l10_d1_unpins(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unpins', ...args)
}

// Ruby it `it "unpins a Cask's version", :cask do` at line 17.
pub fn ruby_unpin_spec_l17_d2_unpins(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unpins', ...args)
}

// Ruby it `it "removes a dangling Cask pin", :cask do` at line 28.
pub fn ruby_unpin_spec_l28_d3_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "cmd/unpin"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Unpin do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "unpins a Formula's version", :integration_test do
// 11:     setup_test_formula "testball", tab_attributes: { installed_on_request: true }
// 12:     Formula["testball"].pin
// 13:
// 14:     expect { brew "unpin", "testball" }.to be_a_success
// 15:   end
// 16:
// 17:   it "unpins a Cask's version", :cask do
// 18:     cask = Cask::CaskLoader.load("local-caffeine")
// 19:     InstallHelper.stub_cask_installation(cask)
// 20:     cask.pin
// 21:
// 22:     expect { described_class.new(["--cask", "local-caffeine"]).run }
// 23:       .to not_to_output.to_stderr
// 24:
// 25:     expect(cask).not_to be_pinned
// 26:   end
// 27:
// 28:   it "removes a dangling Cask pin", :cask do
// 29:     cask = Cask::CaskLoader.load("local-caffeine")
// 30:     InstallHelper.stub_cask_installation(cask)
// 31:     cask.pin
// 32:     FileUtils.rm_r(cask.caskroom_path/"1.2.3")
// 33:
// 34:     expect(cask).not_to be_pinned
// 35:     expect(cask.pin_path).to be_a_symlink
// 36:
// 37:     expect { described_class.new(["--cask", "local-caffeine"]).run }
// 38:       .to not_to_output.to_stderr
// 39:
// 40:     expect(cask.pin_path).not_to be_a_symlink
// 41:   end
// 42: end
