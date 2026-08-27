module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/url_legacy_comma_separators.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_url_stanza(stanza)` at line 16.
pub fn ruby_url_legacy_comma_separators_l16_d1_on_url_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_url_stanza', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # This cop checks for `version.before_comma` and `version.after_comma`.
// 8:       class UrlLegacyCommaSeparators < Url
// 9:         include OnUrlStanza
// 10:         extend AutoCorrector
// 11:
// 12:         MSG_CSV = "Use `version.csv.first` instead of `version.before_comma` " \
// 13:                   "and `version.csv.second` instead of `version.after_comma`."
// 14:
// 15:         sig { override.params(stanza: RuboCop::Cask::AST::Stanza).void }
// 16:         def on_url_stanza(stanza)
// 17:           return if stanza.stanza_node.block_type?
// 18:
// 19:           url_node = T.cast(stanza.stanza_node, RuboCop::AST::SendNode).first_argument
// 20:
// 21:           legacy_comma_separator_pattern = /version\.(before|after)_comma/
// 22:
// 23:           url = url_node.source
// 24:
// 25:           return unless url.match?(legacy_comma_separator_pattern)
// 26:
// 27:           corrected_url = url.sub("before_comma", "csv.first")&.sub("after_comma", "csv.second")
// 28:
// 29:           add_offense(url_node.loc.expression, message: format(MSG_CSV, url:)) do |corrector|
// 30:             corrector.replace(url_node.source_range, corrected_url)
// 31:           end
// 32:         end
// 33:       end
// 34:     end
// 35:   end
// 36: end
