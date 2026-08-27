module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-conditional-caveats.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-conditional-caveats" do
// 4:   version "1.2.3"
// 5:   sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   homepage "https://brew.sh/"
// 9:
// 10:   depends_on macos: :catalina
// 11:
// 12:   app "Caffeine.app"
// 13:
// 14:   # a do block may print and use a DSL
// 15:   caveats do
// 16:     puts "This caveat is conditional" if String("Caffeine") != "Caffeine"
// 17:   end
// 18: end
