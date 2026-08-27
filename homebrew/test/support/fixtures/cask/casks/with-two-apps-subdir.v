module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-two-apps-subdir.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-two-apps-subdir" do
// 4:   version "1.2.3"
// 5:   sha256 "d687c22a21c02bd8f07da9302c8292b93a04df9a929e3f04d09aea6c76f75c65"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeines-subdir.zip"
// 8:   homepage "https://brew.sh/"
// 9:
// 10:   app "Caffeines/Caffeine Mini.app"
// 11:   app "Caffeines/Caffeine Pro.app"
// 12: end
