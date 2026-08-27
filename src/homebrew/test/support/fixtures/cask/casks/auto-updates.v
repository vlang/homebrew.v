module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/auto-updates.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "auto-updates" do
// 4:   version "2.61"
// 5:   sha256 "5633c3a0f2e572cbf021507dec78c50998b398c343232bdfc7e26221d0a5db4d"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/MyFancyApp.zip"
// 8:   name "Auto-Updates"
// 9:   desc "Cask which auto-updates"
// 10:   homepage "https://brew.sh/MyFancyApp"
// 11:
// 12:   auto_updates true
// 13:
// 14:   app "MyFancyApp/MyFancyApp.app"
// 15: end
