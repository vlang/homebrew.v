module homebrew

// Translated from Homebrew/brew `startup.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # This file should be the first `require` in all entrypoints of `brew`.
// 5: # Bootsnap should be loaded as early as possible.
// 6:
// 7: require_relative "standalone/init"
// 8: require_relative "startup/bootsnap"
// 9: require_relative "startup/ruby_path"
// 10: require "startup/config"
// 11: require_relative "standalone/sorbet"
