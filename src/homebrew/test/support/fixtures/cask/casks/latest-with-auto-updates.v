module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/latest-with-auto-updates.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "latest-with-auto-updates" do
// 4:   version :latest
// 5:   sha256 :no_check
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   name "Latest with Auto-Updates"
// 9:   desc "Unversioned cask which auto-updates"
// 10:   homepage "https://brew.sh/latest-with-auto-updates"
// 11:
// 12:   auto_updates true
// 13:
// 14:   app "Caffeine.app"
// 15: end
