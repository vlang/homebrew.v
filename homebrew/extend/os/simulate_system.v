module os

// Translated from Homebrew/brew `extend/os/simulate_system.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: if OS.mac?
// 5:   require "extend/os/mac/simulate_system"
// 6: elsif OS.linux?
// 7:   require "extend/os/linux/simulate_system"
// 8: end
