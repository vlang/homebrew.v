module os

// Translated from Homebrew/brew `extend/os/hardware.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: if OS.mac?
// 5:   require "extend/os/mac/hardware"
// 6:   require "extend/os/mac/hardware/cpu"
// 7: elsif OS.linux?
// 8:   require "extend/os/linux/hardware/cpu"
// 9: end
