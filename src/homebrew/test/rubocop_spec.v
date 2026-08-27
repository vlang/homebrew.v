module test

import brew_runtime

// Translated from Homebrew/brew `test/rubocop_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "loads all Formula cops without errors" do` at line 22.
pub fn ruby_rubocop_spec_l22_d1_loads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loads', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5: require "yaml"
// 6:
// 7: RSpec.describe "RuboCop" do
// 8:   context "when calling `rubocop` outside of the Homebrew environment" do
// 9:     before do
// 10:       ENV.each_key do |key|
// 11:         allowlist = %w[
// 12:           HOMEBREW_TESTS
// 13:           HOMEBREW_USE_RUBY_FROM_PATH
// 14:           HOMEBREW_BUNDLER_VERSION
// 15:         ]
// 16:         ENV.delete(key) if key.start_with?("HOMEBREW_") && allowlist.exclude?(key)
// 17:       end
// 18:
// 19:       ENV["XDG_CACHE_HOME"] = (HOMEBREW_CACHE.realpath/"style").to_s
// 20:     end
// 21:
// 22:     it "loads all Formula cops without errors" do
// 23:       stdout, stderr, status = Open3.capture3(RUBY_PATH.to_s, "-W0", "-S", "rubocop", TEST_FIXTURE_DIR/"testball.rb")
// 24:       expect(stderr).to be_empty
// 25:       expect(stdout).to include("no offenses detected")
// 26:       expect(status).to be_a_success
// 27:     end
// 28:   end
// 29: end
