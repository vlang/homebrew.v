module mixin

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/mixin/cask_help.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask(cask_block); end` at line 12.
pub fn ruby_cask_help_l12_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask', ...args)
}

// Ruby method `on_cask_stanza_block(cask_stanza_block); end` at line 15.
pub fn ruby_cask_help_l15_d2_on_cask_stanza_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask_stanza_block', ...args)
}

// Ruby method `on_block(block_node)` at line 18.
pub fn ruby_cask_help_l18_d3_on_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_block', ...args)
}

// Ruby alias `alias on_itblock on_block` at line 34.
pub fn ruby_cask_help_l34_d4_on_itblock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_itblock', ...args)
}

// Ruby method `on_system_methods(cask_stanzas)` at line 43.
pub fn ruby_cask_help_l43_d5_on_system_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_system_methods', ...args)
}

// Ruby method `inner_stanzas(block_node, comments)` at line 55.
pub fn ruby_cask_help_l55_d6_inner_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inner_stanzas', ...args)
}

// Ruby method `cask_tap` at line 62.
pub fn ruby_cask_help_l62_d7_cask_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_tap', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # Common functionality for cops checking casks.
// 8:       module CaskHelp
// 9:         prepend CommentsHelp # Update the rbi file if changing this: https://github.com/sorbet/sorbet/issues/259
// 10:
// 11:         sig { overridable.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 12:         def on_cask(cask_block); end
// 13:
// 14:         sig { overridable.params(cask_stanza_block: RuboCop::Cask::AST::StanzaBlock).void }
// 15:         def on_cask_stanza_block(cask_stanza_block); end
// 16:
// 17:         sig { params(block_node: RuboCop::AST::BlockNode).void }
// 18:         def on_block(block_node)
// 19:           super if defined? super
// 20:
// 21:           return if !block_node.cask_block? && !block_node.cask_on_system_block?
// 22:
// 23:           comments = comments_in_range(block_node).to_a
// 24:           stanza_block = RuboCop::Cask::AST::StanzaBlock.new(block_node, comments)
// 25:           on_cask_stanza_block(stanza_block)
// 26:
// 27:           return unless block_node.cask_block?
// 28:
// 29:           @file_path = T.let(processed_source.file_path, T.nilable(String))
// 30:
// 31:           cask_block = RuboCop::Cask::AST::CaskBlock.new(block_node, comments)
// 32:           on_cask(cask_block)
// 33:         end
// 34:         alias on_itblock on_block
// 35:
// 36:         sig {
// 37:           params(
// 38:             cask_stanzas: T::Array[RuboCop::Cask::AST::Stanza],
// 39:           ).returns(
// 40:             T::Array[RuboCop::Cask::AST::Stanza],
// 41:           )
// 42:         }
// 43:         def on_system_methods(cask_stanzas)
// 44:           cask_stanzas.select(&:on_system_block?)
// 45:         end
// 46:
// 47:         sig {
// 48:           params(
// 49:             block_node: RuboCop::AST::BlockNode,
// 50:             comments:   T::Array[Parser::Source::Comment],
// 51:           ).returns(
// 52:             T::Array[RuboCop::Cask::AST::Stanza],
// 53:           )
// 54:         }
// 55:         def inner_stanzas(block_node, comments)
// 56:           block_contents = block_node.child_nodes.select(&:begin_type?)
// 57:           inner_nodes = block_contents.map(&:child_nodes).flatten.select(&:send_type?)
// 58:           inner_nodes.map { |n| RuboCop::Cask::AST::Stanza.new(n, comments) }
// 59:         end
// 60:
// 61:         sig { returns(T.nilable(String)) }
// 62:         def cask_tap
// 63:           return unless (match_obj = @file_path&.match(%r{(?:/Taps/[\w-]+|^)/(homebrew-[\w-]+)/}))
// 64:
// 65:           match_obj[1]
// 66:         end
// 67:       end
// 68:     end
// 69:   end
// 70: end
