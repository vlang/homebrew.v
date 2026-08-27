module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/sha256-linux.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "sha256-linux" do
// 4:   arch arm: "arm", intel: "intel"
// 5:
// 6:   version "1.2.3"
// 7:   sha256 arm:          "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94",
// 8:          intel:        "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b",
// 9:          arm64_linux:  "9a1c0967baa46828930ccbbc88668d1b0db07e6edf778800ed4da073c00054f8",
// 10:          x86_64_linux: "244d413861cecb3707cfbcc5c4346d5367daa827da5ea08fb3f3bc2b6276d239"
// 11:
// 12:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine-#{arch}.zip"
// 13:   homepage "https://brew.sh/"
// 14:
// 15:   app "Caffeine.app"
// 16: end
