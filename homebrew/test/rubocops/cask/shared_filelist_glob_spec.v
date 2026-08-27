module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/shared_filelist_glob_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports an offense when a zap trash array includes an .sfl2 or .sfl3 file" do` at line 7.
pub fn ruby_shared_filelist_glob_spec_l7_d1_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::SharedFilelistGlob, :config do
// 7:   it "reports an offense when a zap trash array includes an .sfl2 or .sfl3 file" do
// 8:     expect_offense(<<~CASK)
// 9:       cask "foo" do
// 10:         url "https://example.com/foo.zip"
// 11:
// 12:         zap trash: ["~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/org.mozilla.firefox.sfl2"]
// 13:                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a glob (*) instead of a specific version (ie. sfl2) for trashing Shared File List paths
// 14:       end
// 15:     CASK
// 16:
// 17:     expect_correction(<<~CASK)
// 18:       cask "foo" do
// 19:         url "https://example.com/foo.zip"
// 20:
// 21:         zap trash: ["~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/org.mozilla.firefox.sfl*"]
// 22:       end
// 23:     CASK
// 24:   end
// 25: end
