module livecheck

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/livecheck/livecheck-extract-plist-with-url.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "livecheck-extract-plist-with-url" do
// 4:   version "1.2.3"
// 5:   sha256 "78c670559a609f5d89a5d75eee49e2a2dab48aa3ea36906d14d5f7104e483bb9"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine-suite.zip"
// 8:   name "ExtractPlist livecheck with a URL string"
// 9:   desc "Cask with an ExtractPlist livecheck block using a URL string"
// 10:   homepage "https://brew.sh/"
// 11:
// 12:   livecheck do
// 13:     url "file://#{TEST_FIXTURE_DIR}/cask/caffeine-with-plist.zip"
// 14:     strategy :extract_plist
// 15:   end
// 16:
// 17:   app "Caffeine.app"
// 18: end
