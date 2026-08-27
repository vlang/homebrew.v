module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/will-fail-if-upgraded.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "will-fail-if-upgraded" do
// 4:   version "1.2.3"
// 5:   sha256 "5e96aeb365aa8fabd51bb0d85f5f2bfe0135d392bb2f4120aa6b8171415906da"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/transmission-2.61.zip"
// 8:   homepage "https://brew.sh/"
// 9:
// 10:   app "container"
// 11: end
