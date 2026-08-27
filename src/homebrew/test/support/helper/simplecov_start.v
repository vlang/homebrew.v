module helper

// Translated from Homebrew/brew `test/support/helper/simplecov_start.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubygems/version"
// 5:
// 6: simplecov_root = File.expand_path("../../..", __dir__)
// 7: Dir.chdir(simplecov_root) { require "simplecov" }
// 8:
// 9: SimpleCov.start
