module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/multiple-versions.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "multiple-versions" do
// 4:   arch arm: "arm", intel: "intel"
// 5:   platform = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 6:
// 7:   on_catalina :or_older do
// 8:     version "1.0.0"
// 9:     sha256 "1866dfa833b123bb8fe7fa7185ebf24d28d300d0643d75798bc23730af734216"
// 10:   end
// 11:   on_big_sur do
// 12:     version "1.2.0"
// 13:     sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 14:   end
// 15:   on_monterey :or_newer do
// 16:     version "1.2.3"
// 17:     sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 18:   end
// 19:
// 20:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine/#{platform}/#{version}/#{arch}.zip"
// 21:   homepage "https://brew.sh/"
// 22:
// 23:   app "Caffeine.app"
// 24: end
