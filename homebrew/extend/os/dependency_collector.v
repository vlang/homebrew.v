module os

// Translated from Homebrew/brew `extend/os/dependency_collector.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: if OS.mac?
// 5:   require "extend/os/mac/dependency_collector"
// 6: elsif OS.linux?
// 7:   require "extend/os/linux/dependency_collector"
// 8: end
