module homebrew

// Translated from Homebrew/brew `.mdl_style.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: all
// 5: rule "MD007", indent: 2 # Unordered list indentation
// 6: rule "MD026", punctuation: ",;:" # Trailing punctuation in header
// 7: exclude_rule "MD013" # Line length
// 8: exclude_rule "MD029" # Ordered list item prefix
// 9: exclude_rule "MD033" # Inline HTML
// 10: exclude_rule "MD034" # Bare URL used (replaced by HB034)
// 11: exclude_rule "MD046" # Code block style
