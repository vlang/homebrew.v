module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/pkg-without-uninstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "pkg-without-uninstall" do
// 4:   version "1.2.3"
// 5:   sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/MyFancyPkg.zip"
// 8:   name "PKG without Uninstall"
// 9:   desc "Cask with a package installer and no uninstall stanza"
// 10:   homepage "https://brew.sh/fancy-pkg"
// 11:
// 12:   pkg "Fancy.pkg"
// 13: end
