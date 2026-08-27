module os

// Translated from Homebrew/brew `extend/os/development_tools.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: if OS.mac?
// 5:   require "extend/os/mac/development_tools"
// 6: elsif OS.linux?
// 7:   require "extend/os/linux/development_tools"
// 8: end
