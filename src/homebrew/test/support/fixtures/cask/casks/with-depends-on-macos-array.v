module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-depends-on-macos-array.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: cask "with-depends-on-macos-array" do
// 5:   version "1.2.3"
// 6:   sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 7:
// 8:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 9:   homepage "https://brew.sh/with-depends-on-macos-array"
// 10:
// 11:   # since all OS releases are included, this should always pass
// 12:   depends_on macos: [:catalina, MacOS.version.to_sym]
// 13:
// 14:   app "Caffeine.app"
// 15: end
