module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/bad-checksum.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "bad-checksum" do
// 4:   version "1.2.3"
// 5:   sha256 "badbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadb"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   homepage "https://brew.sh/"
// 9:
// 10:   app "Caffeine.app"
// 11: end
