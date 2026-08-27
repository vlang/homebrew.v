module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/installer-with-uninstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "installer-with-uninstall" do
// 4:   version "1.2.3"
// 5:   sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   homepage "https://brew.sh/"
// 9:
// 10:   installer manual: "Caffeine.app"
// 11:
// 12:   uninstall delete: "/Applications/Caffeine.app"
// 13: end
