module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/generic-artifact-relative-target.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "generic-artifact-relative-target" do
// 4:   version "1.2.3"
// 5:   sha256 "d5b2dfbef7ea28c25f7a77cd7fa14d013d82b626db1d82e00e25822464ba19e2"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/AppWithBinary.zip"
// 8:   name "With Binary"
// 9:   desc "Cask with a binary stanza"
// 10:   homepage "https://brew.sh/with-binary"
// 11:
// 12:   artifact "Caffeine.app", target: "Caffeine.app"
// 13: end
