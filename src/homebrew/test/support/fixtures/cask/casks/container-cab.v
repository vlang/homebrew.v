module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/container-cab.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "container-cab" do
// 4:   version "1.2.3"
// 5:   sha256 "c267f5cebb14814c8e612a8b7d2bda02aec913f869509b6f1d3883427c0f552b"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/container.cab"
// 8:   homepage "https://brew.sh/container-cab"
// 9:
// 10:   depends_on formula: "cabextract"
// 11:
// 12:   app "container"
// 13: end
