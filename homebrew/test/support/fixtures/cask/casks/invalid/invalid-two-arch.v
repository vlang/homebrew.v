module invalid

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/invalid/invalid-two-arch.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "invalid-two-arch" do
// 4:   arch arm: "arm", intel: "intel"
// 5:   arch arm: "amd64", intel: "x86_64"
// 6:
// 7:   version "1.2.3"
// 8:   sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 9:
// 10:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 11:   homepage "https://brew.sh/"
// 12:
// 13:   app "Caffeine.app"
// 14: end
