module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/no_autobump.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask(cask_block)` at line 19.
pub fn ruby_no_autobump_l19_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask', ...args)
}

// Ruby attr_reader `attr_reader :cask_block` at line 40.
pub fn ruby_no_autobump_l40_d2_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_block', ...args)
}

// Ruby def_delegators `def_delegators :cask_block, :toplevel_stanzas` at line 42.
pub fn ruby_no_autobump_l42_d3_toplevel_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('toplevel_stanzas', ...args)
}

// Ruby def_node_search `def_node_search :reason, <<~EOS` at line 44.
pub fn ruby_no_autobump_l44_d4_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reason', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5: require "rubocops/shared/no_autobump_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module Cask
// 10:       # This cop audits `no_autobump!` reason.
// 11:       # See the {NoAutobumpHelper} module for details of the checks.
// 12:       class NoAutobump < Base
// 13:         extend Forwardable
// 14:         extend AutoCorrector
// 15:         include CaskHelp
// 16:         include NoAutobumpHelper
// 17:
// 18:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 19:         def on_cask(cask_block)
// 20:           @cask_block = T.let(cask_block, T.nilable(RuboCop::Cask::AST::CaskBlock))
// 21:
// 22:           toplevel_stanzas.select(&:no_autobump?).each do |stanza|
// 23:             no_autobump_node = stanza.stanza_node
// 24:
// 25:             reason_found = T.let(false, T::Boolean)
// 26:             reason(no_autobump_node) do |reason_node|
// 27:               reason_found = true
// 28:               audit_no_autobump(:cask, reason_node)
// 29:             end
// 30:
// 31:             next if reason_found
// 32:
// 33:             problem 'Add a reason for exclusion from autobump: `no_autobump! because: "..."`'
// 34:           end
// 35:         end
// 36:
// 37:         private
// 38:
// 39:         sig { returns(T.nilable(RuboCop::Cask::AST::CaskBlock)) }
// 40:         attr_reader :cask_block
// 41:
// 42:         def_delegators :cask_block, :toplevel_stanzas
// 43:
// 44:         def_node_search :reason, <<~EOS
// 45:           (pair (sym :because) ${str sym})
// 46:         EOS
// 47:       end
// 48:     end
// 49:   end
// 50: end
