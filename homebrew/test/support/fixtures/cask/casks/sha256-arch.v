module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/sha256-arch.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "sha256-arch" do
// 4:   arch arm: "arm", intel: "intel"
// 5:
// 6:   version "1.2.3"
// 7:   sha256 arm:   "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94",
// 8:          intel: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 9:
// 10:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine-#{arch}.zip"
// 11:   homepage "https://brew.sh/"
// 12:
// 13:   app "Caffeine.app"
// 14: end
