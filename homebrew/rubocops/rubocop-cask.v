module rubocops

// Translated from Homebrew/brew `rubocops/rubocop-cask.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocop"
// 5:
// 6: require_relative "cask/constants/stanza"
// 7:
// 8: require_relative "cask/ast/stanza"
// 9: require_relative "cask/ast/cask_header"
// 10: require_relative "cask/ast/cask_block"
// 11: require_relative "cask/extend/node"
// 12: require_relative "cask/mixin/cask_help"
// 13: require_relative "cask/mixin/on_homepage_stanza"
// 14: require_relative "cask/mixin/on_url_stanza"
// 15: require_relative "cask/array_alphabetization"
// 16: require_relative "cask/desc"
// 17: require_relative "cask/discontinued"
// 18: require_relative "cask/empty_arch_argument"
// 19: require_relative "cask/homepage_url_styling"
// 20: require_relative "cask/install_steps"
// 21: require_relative "cask/no_autobump"
// 22: require_relative "cask/no_overrides"
// 23: require_relative "cask/on_system_conditionals"
// 24: require_relative "cask/sha256_arch_order"
// 25: require_relative "cask/shared_filelist_glob"
// 26: require_relative "cask/stanza_order"
// 27: require_relative "cask/stanza_grouping"
// 28: require_relative "cask/uninstall_methods_order"
// 29: require_relative "cask/url"
// 30: require_relative "cask/url_legacy_comma_separators"
// 31: require_relative "cask/variables"
// 32: require_relative "cask/deprecate_disable_unsigned_reason"
