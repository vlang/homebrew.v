module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/on-linux-asymmetric.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "on-linux-asymmetric" do
// 4:   arch arm: "arm", intel: "intel"
// 5:   os macos: "darwin", linux: "linux"
// 6:
// 7:   version "1.2.3"
// 8:   sha256 arm:          "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94",
// 9:          intel:        "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b",
// 10:          x86_64_linux: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 11:
// 12:   on_linux do
// 13:     depends_on arch: :x86_64
// 14:   end
// 15:
// 16:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine-#{arch}-#{os}.zip"
// 17:   homepage "https://brew.sh/"
// 18:
// 19:   app "Caffeine.app"
// 20: end
