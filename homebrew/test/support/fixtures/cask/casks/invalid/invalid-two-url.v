module invalid

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/invalid/invalid-two-url.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "invalid-two-url" do
// 4:   version "1.2.3"
// 5:   sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   url "https://brew.sh/caffeine.zip"
// 9:   homepage "https://brew.sh/"
// 10:
// 11:   app "Caffeine.app"
// 12: end
