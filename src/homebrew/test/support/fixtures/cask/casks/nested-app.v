module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/nested-app.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "nested-app" do
// 4:   version "1.2.3"
// 5:   sha256 "69034d000fabf804a6e140c8c632f8ce8a3bf303f5f7db2fb0cd86e3aeed9e67"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/NestedApp.zip.tar.gz"
// 8:   homepage "https://brew.sh/nested-app"
// 9:
// 10:   container nested: "NestedApp.zip"
// 11:
// 12:   app "MyNestedApp.app"
// 13: end
