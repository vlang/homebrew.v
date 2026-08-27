module livecheck

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/livecheck/livecheck-throttle-reference.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "livecheck-throttle-reference" do
// 4:   version "1.2.5"
// 5:   sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 6:
// 7:   # This cask is used in --online tests, so we use fake URLs to avoid impacting
// 8:   # real servers. The URL paths are specific enough that they'll be
// 9:   # understandable if they appear in local server logs.
// 10:   url "http://localhost/homebrew/test/cask/audit/livecheck/livecheck-throttle-reference-#{version}.dmg"
// 11:   name "Throttle"
// 12:   desc "Cask for testing throttle in a referenced cask"
// 13:   homepage "http://localhost/homebrew/test/cask/audit/livecheck/livecheck-throttle-reference"
// 14:
// 15:   # The referenced check will not work, so livecheck values need to be
// 16:   # controlled using a test double.
// 17:   livecheck do
// 18:     cask "livecheck-throttle"
// 19:   end
// 20:
// 21:   app "TestCask.app"
// 22: end
