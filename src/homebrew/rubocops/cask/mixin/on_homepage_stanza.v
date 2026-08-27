module mixin

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/mixin/on_homepage_stanza.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask(cask_block)` at line 13.
pub fn ruby_on_homepage_stanza_l13_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask', ...args)
}

// Ruby attr_reader `attr_reader :cask_block` at line 24.
pub fn ruby_on_homepage_stanza_l24_d2_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_block', ...args)
}

// Ruby def_delegators `def_delegators :cask_block, :toplevel_stanzas` at line 26.
pub fn ruby_on_homepage_stanza_l26_d3_toplevel_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('toplevel_stanzas', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # Common functionality for checking homepage stanzas.
// 8:       module OnHomepageStanza
// 9:         extend Forwardable
// 10:         include CaskHelp
// 11:
// 12:         sig { override.params(cask_block: T.nilable(RuboCop::Cask::AST::CaskBlock)).void }
// 13:         def on_cask(cask_block)
// 14:           @cask_block = T.let(cask_block, T.nilable(RuboCop::Cask::AST::CaskBlock))
// 15:
// 16:           toplevel_stanzas.select(&:homepage?).each do |stanza|
// 17:             on_homepage_stanza(stanza)
// 18:           end
// 19:         end
// 20:
// 21:         private
// 22:
// 23:         sig { returns(T.nilable(RuboCop::Cask::AST::CaskBlock)) }
// 24:         attr_reader :cask_block
// 25:
// 26:         def_delegators :cask_block,
// 27:                        :toplevel_stanzas
// 28:       end
// 29:     end
// 30:   end
// 31: end
