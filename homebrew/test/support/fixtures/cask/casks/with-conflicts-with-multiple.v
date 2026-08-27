module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-conflicts-with-multiple.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-conflicts-with-multiple" do
// 4:   version "1.2.3"
// 5:   sha256 "8dd95f83a6cbf67dd73f003c476ea38a5aab367e3af8f56d485c0ff9017b6ee5"
// 6:
// 7:   on_macos do
// 8:     conflicts_with cask: "macos-caffeine"
// 9:   end
// 10:   on_linux do
// 11:     conflicts_with cask: "linux-caffeine"
// 12:   end
// 13:
// 14:   url "https://brew.sh/ConflictsWith-1.2.3.dmg"
// 15:   name "ConflictsWith"
// 16:   homepage "https://brew.sh/"
// 17:
// 18:   conflicts_with cask: "local-caffeine"
// 19:   conflicts_with cask: ["local-caffeine", "with-caffeine"]
// 20: end
