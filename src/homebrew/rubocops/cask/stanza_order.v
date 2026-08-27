module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/stanza_order.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask_stanza_block(stanza_block)` at line 19.
pub fn ruby_stanza_order_l19_d1_on_cask_stanza_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask_stanza_block', ...args)
}

// Ruby method `on_new_investigation` at line 47.
pub fn ruby_stanza_order_l47_d2_on_new_investigation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_new_investigation', ...args)
}

// Ruby method `sort_stanzas(stanzas)` at line 56.
pub fn ruby_stanza_order_l56_d3_sort_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sort_stanzas', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Cask
// 9:       # This cop checks that a cask's stanzas are ordered correctly, including nested within `on_*` blocks.
// 10:       # @see https://docs.brew.sh/Cask-Cookbook#stanza-order
// 11:       class StanzaOrder < Base
// 12:         include IgnoredNode
// 13:         extend AutoCorrector
// 14:         include CaskHelp
// 15:
// 16:         MESSAGE = "`%<stanza>s` stanza out of order"
// 17:
// 18:         sig { override.params(stanza_block: RuboCop::Cask::AST::StanzaBlock).void }
// 19:         def on_cask_stanza_block(stanza_block)
// 20:           stanzas = stanza_block.stanzas
// 21:           ordered_stanzas = sort_stanzas(stanzas)
// 22:
// 23:           return if stanzas == ordered_stanzas
// 24:
// 25:           stanzas.zip(ordered_stanzas).each do |stanza_before, stanza_after|
// 26:             next if stanza_before == stanza_after
// 27:
// 28:             add_offense(
// 29:               stanza_before.method_node,
// 30:               message: format(MESSAGE, stanza: stanza_before.stanza_name),
// 31:             ) do |corrector|
// 32:               next if part_of_ignored_node?(stanza_before.method_node)
// 33:               raise "unexpected nil value for stanza_after" unless stanza_after
// 34:
// 35:               corrector.replace(
// 36:                 stanza_before.source_range_with_comments,
// 37:                 stanza_after.source_with_comments,
// 38:               )
// 39:
// 40:               # Ignore node so that nested content is not auto-corrected and clobbered.
// 41:               ignore_node(stanza_before.method_node)
// 42:             end
// 43:           end
// 44:         end
// 45:
// 46:         sig { override.void }
// 47:         def on_new_investigation
// 48:           super
// 49:
// 50:           ignored_nodes.clear
// 51:         end
// 52:
// 53:         private
// 54:
// 55:         sig { params(stanzas: T::Array[RuboCop::Cask::AST::Stanza]).returns(T::Array[RuboCop::Cask::AST::Stanza]) }
// 56:         def sort_stanzas(stanzas)
// 57:           stanzas.sort do |stanza1, stanza2|
// 58:             i1 = stanza1.stanza_index
// 59:             i2 = stanza2.stanza_index
// 60:
// 61:             if i1 == i2
// 62:               i1 = stanzas.index(stanza1)
// 63:               i2 = stanzas.index(stanza2)
// 64:             end
// 65:             raise "unexpected nil value for i1" unless i1
// 66:             raise "unexpected nil value for i2" unless i2
// 67:
// 68:             i1 - i2
// 69:           end
// 70:         end
// 71:       end
// 72:     end
// 73:   end
// 74: end
