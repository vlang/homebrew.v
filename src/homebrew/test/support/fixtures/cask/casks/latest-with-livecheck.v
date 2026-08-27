module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/latest-with-livecheck.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "latest-with-livecheck" do
// 4:   version :latest
// 5:   sha256 :no_check
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   homepage "https://brew.sh/with-livecheck"
// 9:
// 10:   livecheck do
// 11:     url "https://brew.sh/with-livecheck/changelog"
// 12:   end
// 13:
// 14:   app "Caffeine.app"
// 15: end
