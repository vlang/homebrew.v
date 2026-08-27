module test

import brew_runtime

// Translated from Homebrew/brew `test/os_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "detects nix-homebrew from its repository" do` at line 7.
pub fn ruby_os_spec_l7_d1_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Ruby it `it "detects nix-homebrew from its prefix marker" do` at line 15.
pub fn ruby_os_spec_l15_d2_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Ruby it `it "detects nix-homebrew from update environment values" do` at line 26.
pub fn ruby_os_spec_l26_d3_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Ruby it `it "detects nix-darwin from a Nix store Brewfile" do` at line 42.
pub fn ruby_os_spec_l42_d4_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os"
// 5:
// 6: RSpec.describe OS do
// 7:   it "detects nix-homebrew from its repository" do
// 8:     stub_const("HOMEBREW_REPOSITORY", HOMEBREW_PREFIX/"Library/.homebrew-is-managed-by-nix")
// 9:
// 10:     expect(described_class.nix_managed_homebrew?).to be(true)
// 11:     expect(described_class.nix_managed_homebrew_issues_url)
// 12:       .to eq("https://github.com/zhaofengli/nix-homebrew/issues")
// 13:   end
// 14:
// 15:   it "detects nix-homebrew from its prefix marker" do
// 16:     mktmpdir do |prefix|
// 17:       stub_const("HOMEBREW_PREFIX", prefix)
// 18:       stub_const("HOMEBREW_REPOSITORY", prefix/"Library/Homebrew")
// 19:
// 20:       (prefix/".managed_by_nix_darwin").write("")
// 21:
// 22:       expect(described_class.nix_managed_homebrew?).to be(true)
// 23:     end
// 24:   end
// 25:
// 26:   it "detects nix-homebrew from update environment values" do
// 27:     old_update_before = ENV.fetch("HOMEBREW_UPDATE_BEFORE", nil)
// 28:     old_update_after = ENV.fetch("HOMEBREW_UPDATE_AFTER", nil)
// 29:     mktmpdir do |prefix|
// 30:       stub_const("HOMEBREW_PREFIX", prefix)
// 31:       stub_const("HOMEBREW_REPOSITORY", prefix/"Library/Homebrew")
// 32:       ENV["HOMEBREW_UPDATE_BEFORE"] = "nix"
// 33:       ENV["HOMEBREW_UPDATE_AFTER"] = "nix"
// 34:
// 35:       expect(described_class.nix_managed_homebrew?).to be(true)
// 36:     end
// 37:   ensure
// 38:     ENV["HOMEBREW_UPDATE_BEFORE"] = old_update_before
// 39:     ENV["HOMEBREW_UPDATE_AFTER"] = old_update_after
// 40:   end
// 41:
// 42:   it "detects nix-darwin from a Nix store Brewfile" do
// 43:     mktmpdir do |prefix|
// 44:       stub_const("HOMEBREW_PREFIX", prefix)
// 45:       stub_const("HOMEBREW_REPOSITORY", prefix/"Library/Homebrew")
// 46:       stub_const("ARGV", ["bundle", "--file=/nix/store/example-Brewfile"])
// 47:
// 48:       expect(described_class.nix_managed_homebrew?).to be(true)
// 49:       expect(described_class.nix_managed_homebrew_issues_url)
// 50:         .to eq("https://github.com/nix-darwin/nix-darwin/issues")
// 51:     end
// 52:   end
// 53: end
