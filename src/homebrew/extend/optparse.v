module extend

// Translated from Homebrew/brew `extend/optparse.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "optparse"
// 5:
// 6: OptionParser.accept Pathname do |path|
// 7:   Pathname(path).expand_path if path
// 8: end
