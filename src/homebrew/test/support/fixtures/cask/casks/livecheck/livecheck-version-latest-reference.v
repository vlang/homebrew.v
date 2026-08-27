module livecheck

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/livecheck/livecheck-version-latest-reference.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "livecheck-version-latest-reference" do
// 4:   version :latest
// 5:   sha256 :no_check
// 6:
// 7:   # This cask is used in --online tests, so we use fake URLs to avoid impacting
// 8:   # real servers. The URL paths are specific enough that they'll be
// 9:   # understandable if they appear in local server logs.
// 10:   url "http://localhost/homebrew/test/cask/audit/livecheck/version-latest.dmg"
// 11:   name "Version Latest Reference"
// 12:   desc "Cask for testing a livecheck reference to a cask where version is :latest"
// 13:   homepage "http://localhost/homebrew/test/cask/audit/livecheck/version-latest"
// 14:
// 15:   livecheck do
// 16:     cask "livecheck-version-latest"
// 17:   end
// 18:
// 19:   app "TestCask.app"
// 20: end
