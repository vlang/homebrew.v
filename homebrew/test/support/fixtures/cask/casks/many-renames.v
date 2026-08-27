module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/many-renames.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "many-renames" do
// 4:   version "1.2.3"
// 5:   sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/ManyArtifacts.zip"
// 8:   homepage "https://brew.sh/many-artifacts"
// 9:
// 10:   rename "Foobar.app", "Foo.app"
// 11:   rename "Foo.app", "Bar.app"
// 12:
// 13:   app "Bar.app"
// 14:
// 15:   preflight do
// 16:     # do nothing
// 17:   end
// 18:
// 19:   postflight do
// 20:     # do nothing
// 21:   end
// 22:
// 23:   uninstall_preflight do
// 24:     # do nothing
// 25:   end
// 26:
// 27:   uninstall_postflight do
// 28:     # do nothing
// 29:   end
// 30: end
