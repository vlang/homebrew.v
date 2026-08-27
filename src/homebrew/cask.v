module homebrew

// Translated from Homebrew/brew `cask.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact"
// 5: require "cask/audit"
// 6: require "cask/auditor"
// 7: require "cask/cache"
// 8: require "cask/cask_loader"
// 9: require "cask/cask"
// 10: require "cask/caskroom"
// 11: require "cask/config"
// 12: require "cask/exceptions"
// 13: require "cask/denylist"
// 14: require "cask/download"
// 15: require "cask/dsl"
// 16: require "cask/installer"
// 17: require "cask/macos"
// 18: require "cask/metadata"
// 19: require "cask/migrator"
// 20: require "cask/pkg"
// 21: require "cask/quarantine"
// 22: require "cask/staged"
// 23: require "cask/tab"
// 24: require "cask/url"
// 25: require "cask/utils"
