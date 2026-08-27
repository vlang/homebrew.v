module invalid

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/invalid/invalid-depends-on-macos-and-linux.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "invalid-depends-on-macos-and-linux" do
// 4:   version "1.2.3"
// 5:   sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   homepage "https://brew.sh/invalid-depends-on-macos-and-linux"
// 9:
// 10:   depends_on macos: :monterey
// 11:   depends_on_arg = :linux
// 12:   depends_on depends_on_arg
// 13:
// 14:   app "Caffeine.app"
// 15: end
