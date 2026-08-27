module livecheck

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/livecheck/livecheck-installer-manual.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "livecheck-installer-manual" do
// 4:   version "1.2.3"
// 5:   sha256 "78c670559a609f5d89a5d75eee49e2a2dab48aa3ea36906d14d5f7104e483bb9"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine-incl-plist.zip"
// 8:   name "With Installer Manual"
// 9:   desc "Cask with a manual installer"
// 10:   homepage "https://brew.sh/"
// 11:
// 12:   livecheck do
// 13:     url :url
// 14:     strategy :extract_plist
// 15:   end
// 16:
// 17:   installer manual: "Caffeine.app"
// 18: end
