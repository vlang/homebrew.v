module homebrew

// Translated from Homebrew/brew `reinstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "development_tools"
// 5: require "messages"
// 6: require "utils/output"
// 7:
// 8: # Needed to handle circular require dependency.
// 9: # rubocop:disable Lint/EmptyClass
// 10: class FormulaInstaller; end
// 11: # rubocop:enable Lint/EmptyClass
// 12: require "reinstall/reinstall"
// 13:
// 14: require "extend/os/reinstall"
