module utils

// Translated from Homebrew/brew `cask/utils/copy_xattrs.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "standalone"
// 5: require "os/mac/ffi"
// 6:
// 7: OS::Mac::FFI.copy_xattrs(ARGV.fetch(0), ARGV.fetch(1))
