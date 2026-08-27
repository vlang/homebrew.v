module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/invalid-sha256.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "invalid-sha256" do
// 4:   version "1.2.3"
// 5:   sha256 "not a valid shasum"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   name "Caffeine"
// 9:   desc "Cask for testing an invalid sha256"
// 10:   homepage "https://brew.sh/"
// 11:
// 12:   depends_on macos: :catalina
// 13:
// 14:   app "Caffeine.app"
// 15: end
