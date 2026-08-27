module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/homepage_url_styling.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_homepage_stanza(stanza)` at line 21.
pub fn ruby_homepage_url_styling_l21_d1_on_homepage_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_homepage_stanza', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5: require "uri"
// 6: require "rubocops/shared/homepage_helper"
// 7:
// 8: module RuboCop
// 9:   module Cop
// 10:     module Cask
// 11:       # This cop audits the `homepage` URL in casks.
// 12:       class HomepageUrlStyling < Base
// 13:         include OnHomepageStanza
// 14:         include HelperFunctions
// 15:         include HomepageHelper
// 16:         extend AutoCorrector
// 17:
// 18:         MSG_NO_SLASH = "'%<url>s' must have a slash after the domain."
// 19:
// 20:         sig { params(stanza: RuboCop::Cask::AST::Stanza).void }
// 21:         def on_homepage_stanza(stanza)
// 22:           @name = T.let(cask_block&.header&.cask_token, T.nilable(String))
// 23:           desc_call = T.cast(stanza.stanza_node, RuboCop::AST::SendNode)
// 24:           url_node = desc_call.first_argument
// 25:
// 26:           url = if url_node.dstr_type?
// 27:             # Remove quotes from interpolated string.
// 28:             url_node.source[1..-2]
// 29:           else
// 30:             url_node.str_content
// 31:           end
// 32:
// 33:           audit_homepage(:cask, url, desc_call, url_node)
// 34:
// 35:           return unless url&.match?(%r{^.+://[^/]+$})
// 36:
// 37:           domain = URI(string_content(url_node, strip_dynamic: true)).host
// 38:           return if domain.blank?
// 39:
// 40:           # This also takes URLs like 'https://example.org?path'
// 41:           # and 'https://example.org#path' into account.
// 42:           corrected_source = url_node.source.sub("://#{domain}", "://#{domain}/")
// 43:
// 44:           add_offense(url_node.loc.expression, message: format(MSG_NO_SLASH, url:)) do |corrector|
// 45:             corrector.replace(url_node.source_range, corrected_source)
// 46:           end
// 47:         end
// 48:       end
// 49:     end
// 50:   end
// 51: end
