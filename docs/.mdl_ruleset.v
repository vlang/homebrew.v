module homebrew

// Translated from Homebrew/brew `.mdl_ruleset.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: rule "HB034", "Bare unstyled URL used" do
// 5:   tags :links, :url
// 6:   aliases "no-bare-unstyled-urls"
// 7:   check do |doc|
// 8:     doc.matching_text_element_lines(%r{(?<=\s)https?://})
// 9:   end
// 10: end
// 11: rule "HB100", "Full URL for internal link used" do
// 12:   tags :links, :url
// 13:   aliases "no-full-urls-for-internal-links"
// 14:   check do |doc|
// 15:     doc.matching_lines(%r{\]\(https://docs.brew.sh/.+?\)})
// 16:   end
// 17: end
// 18: rule "HB101", "File extension missing from internal link" do
// 19:   tags :links, :url
// 20:   aliases "file-extension-required-for-internal-links"
// 21:   check do |doc|
// 22:     doc.matching_lines(/\]\((?!#|\w+:)(?>[^#.)]+)(?!\.\w+)/)
// 23:   end
// 24: end
