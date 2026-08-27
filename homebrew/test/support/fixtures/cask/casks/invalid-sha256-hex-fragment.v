module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/invalid-sha256-hex-fragment.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "invalid-sha256-hex-fragment" do
// 4:   version "1.2.3"
// 5:   sha256 "a\nZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   name "Caffeine"
// 9:   desc "Cask for testing a sha256 whose hexadecimal run is far shorter than 64"
// 10:   homepage "https://brew.sh/"
// 11:
// 12:   app "Caffeine.app"
// 13: end
