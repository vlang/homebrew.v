module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/url.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_url_stanza(stanza)` at line 17.
pub fn ruby_url_l17_d1_on_url_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_url_stanza', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/url_helper"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Cask
// 9:       # This cop checks that a cask's `url` stanza is formatted correctly.
// 10:       #
// 11:       class Url < Base
// 12:         extend AutoCorrector
// 13:         include OnUrlStanza
// 14:         include UrlHelper
// 15:
// 16:         sig { params(stanza: RuboCop::Cask::AST::Stanza).void }
// 17:         def on_url_stanza(stanza)
// 18:           if stanza.stanza_node.block_type?
// 19:             if cask_tap == "homebrew-cask"
// 20:               add_offense(stanza.stanza_node, message: 'Do not use `url "..." do` blocks in Homebrew/homebrew-cask.')
// 21:             end
// 22:             return
// 23:           end
// 24:
// 25:           stanza_node = T.cast(stanza.stanza_node, RuboCop::AST::SendNode)
// 26:           url_stanza = stanza_node.first_argument
// 27:           hash_node = stanza_node.last_argument
// 28:
// 29:           if url_stanza.nil? || url_stanza.hash_type?
// 30:             add_offense(stanza_node.source_range, message: "The `url` stanza requires a URL argument.")
// 31:             return
// 32:           end
// 33:
// 34:           audit_url(:cask, [stanza_node], [], livecheck_urls: [])
// 35:
// 36:           if cask_tap == "homebrew-cask" && !url_stanza.type?(:str, :dstr)
// 37:             add_offense(url_stanza.source_range, message: "Casks in homebrew/cask should use string literal URLs.")
// 38:           end
// 39:
// 40:           # Check for http:// URLs in homebrew-cask (skip deprecated/disabled casks)
// 41:           # TODO: Remove the deprecated/disabled check after Homebrew/cask has no more
// 42:           # deprecated/disabled casks using http:// URLs
// 43:           deprecated_or_disabled = toplevel_stanzas.any? { |s| [:deprecate!, :disable!].include?(s.stanza_name) }
// 44:           if cask_tap == "homebrew-cask" && !deprecated_or_disabled && url_stanza.source.match?(%r{^"http://})
// 45:             add_offense(
// 46:               stanza_node.source_range,
// 47:               message: "Casks in homebrew/cask should not use http:// URLs",
// 48:             ) do |corrector|
// 49:               corrector.replace(stanza_node.source_range, stanza_node.source.sub("http://", "https://"))
// 50:             end
// 51:           end
// 52:
// 53:           return unless hash_node.hash_type?
// 54:
// 55:           # TODO: also enforce that each keyword parameter after the first
// 56:           #       starts on its own line.
// 57:           return if hash_node.first_line > url_stanza.last_line && hash_node.loc.column > stanza_node.loc.column
// 58:
// 59:           add_offense(
// 60:             stanza_node.source_range,
// 61:             message: "Keyword URL parameter should be on a new indented line.",
// 62:           ) do |corrector|
// 63:             corrector.replace(
// 64:               range_between(url_stanza.source_range.end_pos, hash_node.source_range.begin_pos),
// 65:               ",\n#{" " * url_stanza.loc.column}",
// 66:             )
// 67:           end
// 68:         end
// 69:       end
// 70:     end
// 71:   end
// 72: end
