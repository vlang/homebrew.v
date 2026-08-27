module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-non-executable-binary.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-non-executable-binary" do
// 4:   version "1.2.3"
// 5:   sha256 "306c6ca7407560340797866e077e053627ad409277d1b9da58106fce4cf717cb"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/naked_non_executable"
// 8:   homepage "https://brew.sh/with-binary"
// 9:
// 10:   binary "naked_non_executable"
// 11: end
