module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/stanza_grouping.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask(cask_block)` at line 21.
pub fn ruby_stanza_grouping_l21_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask', ...args)
}

// Ruby attr_reader `attr_reader :cask_block` at line 38.
pub fn ruby_stanza_grouping_l38_d2_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_block', ...args)
}

// Ruby def_delegators `def_delegators :cask_block, :cask_node, :toplevel_stanzas` at line 40.
pub fn ruby_stanza_grouping_l40_d3_cask_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_node', ...args)
}

// Ruby def_delegators `def_delegators :cask_block, :cask_node, :toplevel_stanzas` at line 40.
pub fn ruby_stanza_grouping_l40_d4_toplevel_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('toplevel_stanzas', ...args)
}

// Ruby method `add_offenses(stanzas)` at line 43.
pub fn ruby_stanza_grouping_l43_d5_add_offenses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_offenses', ...args)
}

// Ruby method `line_ops` at line 56.
pub fn ruby_stanza_grouping_l56_d6_line_ops(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('line_ops', ...args)
}

// Ruby method `missing_line_after?(stanza, next_stanza)` at line 61.
pub fn ruby_stanza_grouping_l61_d7_missing_line_after(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('missing_line_after?', ...args)
}

// Ruby method `extra_line_after?(stanza, next_stanza)` at line 67.
pub fn ruby_stanza_grouping_l67_d8_extra_line_after(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extra_line_after?', ...args)
}

// Ruby method `empty_line_after?(stanza)` at line 73.
pub fn ruby_stanza_grouping_l73_d9_empty_line_after(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('empty_line_after?', ...args)
}

// Ruby method `source_line_after(stanza)` at line 78.
pub fn ruby_stanza_grouping_l78_d10_source_line_after(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_line_after', ...args)
}

// Ruby method `index_of_line_after(stanza)` at line 83.
pub fn ruby_stanza_grouping_l83_d11_index_of_line_after(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('index_of_line_after', ...args)
}

// Ruby method `add_offense_missing_line(stanza)` at line 88.
pub fn ruby_stanza_grouping_l88_d12_add_offense_missing_line(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_offense_missing_line', ...args)
}

// Ruby method `add_offense_extra_line(stanza)` at line 97.
pub fn ruby_stanza_grouping_l97_d13_add_offense_extra_line(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_offense_extra_line', ...args)
}

// Ruby method `add_offense(line_index, message:, &block)` at line 106.
pub fn ruby_stanza_grouping_l106_d14_add_offense(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_offense', ...args)
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
// 9:       # This cop checks that a cask's stanzas are grouped correctly, including nested within `on_*` blocks.
// 10:       # @see https://docs.brew.sh/Cask-Cookbook#stanza-order
// 11:       class StanzaGrouping < Base
// 12:         extend Forwardable
// 13:         extend AutoCorrector
// 14:         include CaskHelp
// 15:         include RangeHelp
// 16:
// 17:         MISSING_LINE_MSG = "stanza groups should be separated by a single empty line"
// 18:         EXTRA_LINE_MSG = "stanzas within the same group should have no lines between them"
// 19:
// 20:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 21:         def on_cask(cask_block)
// 22:           @cask_block = T.let(cask_block, T.nilable(RuboCop::Cask::AST::CaskBlock))
// 23:           @line_ops = T.let({}, T.nilable(T::Hash[Integer, Symbol]))
// 24:           cask_stanzas = cask_block.toplevel_stanzas
// 25:           add_offenses(cask_stanzas)
// 26:
// 27:           return if (on_blocks = on_system_methods(cask_stanzas)).none?
// 28:
// 29:           on_blocks.map(&:method_node).select(&:block_type?).each do |on_block|
// 30:             stanzas = inner_stanzas(T.cast(on_block, RuboCop::AST::BlockNode), processed_source.comments)
// 31:             add_offenses(stanzas)
// 32:           end
// 33:         end
// 34:
// 35:         private
// 36:
// 37:         sig { returns(T.nilable(RuboCop::Cask::AST::CaskBlock)) }
// 38:         attr_reader :cask_block
// 39:
// 40:         def_delegators :cask_block, :cask_node, :toplevel_stanzas
// 41:
// 42:         sig { params(stanzas: T::Array[RuboCop::Cask::AST::Stanza]).void }
// 43:         def add_offenses(stanzas)
// 44:           stanzas.each_cons(2) do |stanza, next_stanza|
// 45:             next if !stanza || !next_stanza
// 46:
// 47:             if missing_line_after?(stanza, next_stanza)
// 48:               add_offense_missing_line(stanza)
// 49:             elsif extra_line_after?(stanza, next_stanza)
// 50:               add_offense_extra_line(stanza)
// 51:             end
// 52:           end
// 53:         end
// 54:
// 55:         sig { returns(T::Hash[Integer, Symbol]) }
// 56:         def line_ops
// 57:           @line_ops || raise("Call to line_ops before it has been initialized")
// 58:         end
// 59:
// 60:         sig { params(stanza: RuboCop::Cask::AST::Stanza, next_stanza: RuboCop::Cask::AST::Stanza).returns(T::Boolean) }
// 61:         def missing_line_after?(stanza, next_stanza)
// 62:           !(stanza.same_group?(next_stanza) ||
// 63:             empty_line_after?(stanza))
// 64:         end
// 65:
// 66:         sig { params(stanza: RuboCop::Cask::AST::Stanza, next_stanza: RuboCop::Cask::AST::Stanza).returns(T::Boolean) }
// 67:         def extra_line_after?(stanza, next_stanza)
// 68:           stanza.same_group?(next_stanza) &&
// 69:             empty_line_after?(stanza)
// 70:         end
// 71:
// 72:         sig { params(stanza: RuboCop::Cask::AST::Stanza).returns(T::Boolean) }
// 73:         def empty_line_after?(stanza)
// 74:           source_line_after(stanza).empty?
// 75:         end
// 76:
// 77:         sig { params(stanza: RuboCop::Cask::AST::Stanza).returns(String) }
// 78:         def source_line_after(stanza)
// 79:           processed_source[index_of_line_after(stanza)]
// 80:         end
// 81:
// 82:         sig { params(stanza: RuboCop::Cask::AST::Stanza).returns(Integer) }
// 83:         def index_of_line_after(stanza)
// 84:           stanza.source_range.last_line
// 85:         end
// 86:
// 87:         sig { params(stanza: RuboCop::Cask::AST::Stanza).void }
// 88:         def add_offense_missing_line(stanza)
// 89:           line_index = index_of_line_after(stanza)
// 90:           line_ops[line_index] = :insert
// 91:           add_offense(line_index, message: MISSING_LINE_MSG) do |corrector|
// 92:             corrector.insert_before(@range, "\n")
// 93:           end
// 94:         end
// 95:
// 96:         sig { params(stanza: RuboCop::Cask::AST::Stanza).void }
// 97:         def add_offense_extra_line(stanza)
// 98:           line_index = index_of_line_after(stanza)
// 99:           line_ops[line_index] = :remove
// 100:           add_offense(line_index, message: EXTRA_LINE_MSG) do |corrector|
// 101:             corrector.remove(@range)
// 102:           end
// 103:         end
// 104:
// 105:         sig { params(line_index: Integer, message: String, block: T.proc.params(corrector: RuboCop::Cop::Corrector).void).void }
// 106:         def add_offense(line_index, message:, &block)
// 107:           line_length = [processed_source[line_index].size, 1].max
// 108:           @range = T.let(
// 109:             source_range(processed_source.buffer, line_index + 1, 0, line_length),
// 110:             T.nilable(Parser::Source::Range),
// 111:           )
// 112:           super(@range, message:, &block)
// 113:         end
// 114:       end
// 115:     end
// 116:   end
// 117: end
