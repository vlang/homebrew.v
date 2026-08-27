module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/local-transmission.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "local-transmission" do
// 4:   version "2.61"
// 5:   sha256 "e44ffa103fbf83f55c8d0b1bea309a43b2880798dae8620b1ee8da5e1095ec68"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/transmission-2.61.dmg"
// 8:   name "Transmission"
// 9:   desc "BitTorrent client"
// 10:   homepage "https://transmissionbt.com/"
// 11:
// 12:   depends_on macos: :catalina
// 13:
// 14:   app "Transmission.app"
// 15: end
