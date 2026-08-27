module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/sha256-linux-only.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "sha256-linux-only" do
// 4:   arch arm: "arm", intel: "intel"
// 5:
// 6:   version "1.2.3"
// 7:   sha256 arm64_linux:  "9a1c0967baa46828930ccbbc88668d1b0db07e6edf778800ed4da073c00054f8",
// 8:          x86_64_linux: "244d413861cecb3707cfbcc5c4346d5367daa827da5ea08fb3f3bc2b6276d239"
// 9:
// 10:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine-#{arch}.zip"
// 11:   homepage "https://brew.sh/"
// 12:
// 13:   depends_on :linux
// 14:
// 15:   app "Caffeine.app"
// 16: end
