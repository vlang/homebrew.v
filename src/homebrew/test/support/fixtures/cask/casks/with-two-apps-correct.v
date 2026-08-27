module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-two-apps-correct.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-two-apps-correct" do
// 4:   version "1.2.3"
// 5:   sha256 "3178fbfd1ea5d87a2a0662a4eb599ebc9a03888e73f37538d9f3f6ee69d2368e"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeines.zip"
// 8:   homepage "https://brew.sh/"
// 9:
// 10:   app "Caffeine Mini.app"
// 11:   app "Caffeine Pro.app"
// 12: end
