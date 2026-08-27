module utils

// Translated from Homebrew/brew `utils/rubocop.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: #!/usr/bin/env ruby
// 2: # typed: strict
// 3: # frozen_string_literal: true
// 4:
// 5: require_relative "../standalone"
// 6: require_relative "../warnings"
// 7:
// 8: Warnings.ignore :parser_syntax do
// 9:   require "rubocop"
// 10: end
// 11:
// 12: exit RuboCop::CLI.new.run
