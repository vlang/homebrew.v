module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/depends-on-arch-arm64.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "depends-on-arch-arm64" do
// 4:   arch arm: "arm", intel: "intel"
// 5:
// 6:   version "1.2.3"
// 7:   sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 8:
// 9:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine-#{arch}-darwin.zip"
// 10:   homepage "https://brew.sh/"
// 11:
// 12:   depends_on arch: :arm64
// 13:
// 14:   app "Caffeine.app"
// 15: end
