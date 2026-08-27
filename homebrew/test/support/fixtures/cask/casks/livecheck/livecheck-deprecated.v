module livecheck

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/livecheck/livecheck-deprecated.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "livecheck-deprecated" do
// 4:   version "1.2.3"
// 5:   sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 6:
// 7:   # This cask is used in --online tests, so we use fake URLs to avoid impacting
// 8:   # real servers. The URL paths are specific enough that they'll be
// 9:   # understandable if they appear in local server logs.
// 10:   url "http://localhost/homebrew/test/cask/audit/livecheck/deprecated-#{version}.dmg"
// 11:   name "Deprecated"
// 12:   desc "Cask for testing deprecated in livecheck"
// 13:   homepage "http://localhost/homebrew/test/cask/audit/livecheck/deprecated"
// 14:
// 15:   deprecate! date: "2023-01-01", because: :discontinued
// 16:
// 17:   app "TestCask.app"
// 18: end
