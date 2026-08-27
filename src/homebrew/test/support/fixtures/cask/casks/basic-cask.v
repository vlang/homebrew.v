module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/basic-cask.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "basic-cask" do
// 4:   version "1.2.3"
// 5:   sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 6:
// 7:   url "https://brew.sh/TestCask-#{version}.dmg"
// 8:   name "Basic Cask"
// 9:   desc "Cask for testing basic functionality"
// 10:   homepage "https://brew.sh/"
// 11:
// 12:   app "TestCask.app"
// 13: end
