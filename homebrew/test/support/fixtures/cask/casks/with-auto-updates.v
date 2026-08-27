module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-auto-updates.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-auto-updates" do
// 4:   version "1.0"
// 5:   sha256 "e5be907a51cd0d5b128532284afe1c913608c584936a5e55d94c75a9f48c4322"
// 6:
// 7:   url "https://brew.sh/autoupdates_#{version}.zip"
// 8:   name "AutoUpdates"
// 9:   homepage "https://brew.sh/autoupdates"
// 10:
// 11:   auto_updates true
// 12:   depends_on macos: :catalina
// 13:
// 14:   app "AutoUpdates.app"
// 15: end
