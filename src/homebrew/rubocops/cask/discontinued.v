module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/discontinued.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask_stanza_block(stanza_block)` at line 15.
pub fn ruby_discontinued_l15_d1_on_cask_stanza_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask_stanza_block', ...args)
}

// Ruby def_node_matcher `def_node_matcher :caveats_contains_only_discontinued?, <<~EOS` at line 30.
pub fn ruby_discontinued_l30_d2_caveats_contains_only_discontinued(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('caveats_contains_only_discontinued?', ...args)
}

// Ruby def_node_search `def_node_search :find_discontinued_method_call, <<~EOS` at line 37.
pub fn ruby_discontinued_l37_d3_find_discontinued_method_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_discontinued_method_call', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # This cop corrects `caveats { discontinued }` to `deprecate!`.
// 8:       class Discontinued < Base
// 9:         include CaskHelp
// 10:         extend AutoCorrector
// 11:
// 12:         MESSAGE = "Use `deprecate!` instead of `caveats { discontinued }`."
// 13:
// 14:         sig { override.params(stanza_block: RuboCop::Cask::AST::StanzaBlock).void }
// 15:         def on_cask_stanza_block(stanza_block)
// 16:           stanza_block.stanzas.select(&:caveats?).each do |stanza|
// 17:             find_discontinued_method_call(stanza.stanza_node) do |node|
// 18:               if caveats_contains_only_discontinued?(node.parent)
// 19:                 add_offense(node.parent, message: MESSAGE) do |corrector|
// 20:                   corrector.replace(node.parent.source_range,
// 21:                                     "deprecate! date: \"#{Date.today}\", because: :discontinued")
// 22:                 end
// 23:               else
// 24:                 add_offense(node, message: MESSAGE)
// 25:               end
// 26:             end
// 27:           end
// 28:         end
// 29:
// 30:         def_node_matcher :caveats_contains_only_discontinued?, <<~EOS
// 31:           (block
// 32:             (send nil? :caveats)
// 33:             (args)
// 34:             (send nil? :discontinued))
// 35:         EOS
// 36:
// 37:         def_node_search :find_discontinued_method_call, <<~EOS
// 38:           $(send nil? :discontinued)
// 39:         EOS
// 40:       end
// 41:     end
// 42:   end
// 43: end
