module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-depends-on-macos-failure.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-depends-on-macos-failure" do
// 4:   # guarantee a mismatched release
// 5:   on_big_sur :or_older do
// 6:     version "1.2.3"
// 7:     sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 8:   end
// 9:   on_ventura :or_newer do
// 10:     version "1.2.3"
// 11:     sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 12:   end
// 13:
// 14:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 15:   homepage "https://brew.sh/with-depends-on-macos-failure"
// 16:
// 17:   depends_on maximum_macos: :monterey
// 18:
// 19:   app "Caffeine.app"
// 20: end
