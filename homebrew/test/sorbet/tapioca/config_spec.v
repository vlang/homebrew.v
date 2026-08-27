module tapioca

import brew_runtime

// Translated from Homebrew/brew `test/sorbet/tapioca/config_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:config) { YAML.load_file(File.join(__dir__, "../../../sorbet/tapioca/config.yml")) }` at line 8.
pub fn ruby_config_spec_l8_d1_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('config', ...args)
}

// Ruby it `it "only excludes dependencies" do` at line 10.
pub fn ruby_config_spec_l10_d2_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundler"
// 5: require "yaml"
// 6:
// 7: RSpec.describe "Tapioca Config", type: :system do
// 8:   let(:config) { YAML.load_file(File.join(__dir__, "../../../sorbet/tapioca/config.yml")) }
// 9:
// 10:   it "only excludes dependencies" do
// 11:     exclusions = config.dig("gem", "exclude")
// 12:     dependencies = Bundler::Definition.build(
// 13:       HOMEBREW_LIBRARY_PATH/"Gemfile",
// 14:       HOMEBREW_LIBRARY_PATH/"Gemfile.lock",
// 15:       false,
// 16:     ).resolve.names
// 17:     expect(exclusions - dependencies).to be_empty
// 18:   end
// 19: end
