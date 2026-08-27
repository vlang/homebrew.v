module invalid

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/invalid/invalid-conflicts-with-key.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "invalid-conflicts-with-key" do
// 4:   version "1.2.3"
// 5:   sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   homepage "https://brew.sh/invalid-conflicts-with-key"
// 9:
// 10:   conflicts_with no_such_key: "unar"
// 11:
// 12:   app "Caffeine.app"
// 13: end
