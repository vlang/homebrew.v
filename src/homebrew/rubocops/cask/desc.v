module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/desc.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_desc_stanza(stanza)` at line 18.
pub fn ruby_desc_l18_d1_on_desc_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_desc_stanza', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/cask/mixin/on_desc_stanza"
// 5: require "rubocops/shared/desc_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module Cask
// 10:       # This cop audits `desc` in casks.
// 11:       # See the {DescHelper} module for details of the checks.
// 12:       class Desc < Base
// 13:         include OnDescStanza
// 14:         include DescHelper
// 15:         extend AutoCorrector
// 16:
// 17:         sig { params(stanza: RuboCop::Cask::AST::Stanza).void }
// 18:         def on_desc_stanza(stanza)
// 19:           @name = T.let(cask_block&.header&.cask_token, T.nilable(String))
// 20:           desc_call = stanza.stanza_node
// 21:           audit_desc(:cask, @name, desc_call)
// 22:         end
// 23:       end
// 24:     end
// 25:   end
// 26: end
