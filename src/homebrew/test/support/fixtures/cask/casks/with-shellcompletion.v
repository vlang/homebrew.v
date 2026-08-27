module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-shellcompletion.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-shellcompletion" do
// 4:   version "1.2.3"
// 5:   sha256 "957978d9b30adfda8e1f914ba8c8019e016545c8f7e16c6ab0234d189fac8146"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/AppWithShellCompletion.zip"
// 8:   homepage "https://brew.sh/with-autodetected-manpage-section"
// 9:
// 10:   bash_completion "test.bash"
// 11:   fish_completion "test.fish"
// 12:   zsh_completion "_test"
// 13: end
