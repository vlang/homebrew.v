module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/on-linux-blocks.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "on-linux-blocks" do
// 4:   version "1.2.3"
// 5:
// 6:   on_macos do
// 7:     sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 8:
// 9:     url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 10:
// 11:     app "Caffeine.app"
// 12:   end
// 13:   on_linux do
// 14:     sha256 arm64_linux:  "9a1c0967baa46828930ccbbc88668d1b0db07e6edf778800ed4da073c00054f8",
// 15:            x86_64_linux: "244d413861cecb3707cfbcc5c4346d5367daa827da5ea08fb3f3bc2b6276d239"
// 16:
// 17:     url "file://#{TEST_FIXTURE_DIR}/cask/caffeine-linux.zip"
// 18:
// 19:     app_image "Caffeine.AppImage"
// 20:   end
// 21:
// 22:   homepage "https://brew.sh/"
// 23: end
