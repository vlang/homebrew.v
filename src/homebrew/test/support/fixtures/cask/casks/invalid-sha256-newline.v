module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/invalid-sha256-newline.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "invalid-sha256-newline" do
// 4:   version "1.2.3"
// 5:   sha256 "0123456789abcdef0123456789abcde\n0123456789abcdef0123456789abcdef"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   name "Caffeine"
// 9:   desc "Cask for testing a sha256 that is the right length but not hexadecimal"
// 10:   homepage "https://brew.sh/"
// 11:
// 12:   app "Caffeine.app"
// 13: end
