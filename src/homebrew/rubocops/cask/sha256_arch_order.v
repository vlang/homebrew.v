module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/sha256_arch_order.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask_stanza_block(cask_stanza_block)` at line 32.
pub fn ruby_sha256_arch_order_l32_d1_on_cask_stanza_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask_stanza_block', ...args)
}

// Ruby method `rebuild(node, pairs)` at line 59.
pub fn ruby_sha256_arch_order_l59_d2_rebuild(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rebuild', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # This cop checks that the architecture keys of a cask's `sha256` stanza are ordered
// 8:       # like the tags of a formula's `bottle` block: macOS before Linux, ARM before Intel.
// 9:       #
// 10:       # ### Example
// 11:       #
// 12:       # ```ruby
// 13:       # # bad
// 14:       # sha256 x86_64_linux: "...",
// 15:       #        arm:          "..."
// 16:       #
// 17:       # # good
// 18:       # sha256 arm:          "...",
// 19:       #        x86_64_linux: "..."
// 20:       # ```
// 21:       class Sha256ArchOrder < Base
// 22:         extend AutoCorrector
// 23:         include CaskHelp
// 24:
// 25:         ARCH_ORDER = [:arm, :intel, :x86_64, :arm64_linux, :x86_64_linux].freeze
// 26:
// 27:         MESSAGE = "`sha256` architecture keys should be ordered: arm, intel (or x86_64), arm64_linux, x86_64_linux"
// 28:
// 29:         STANZA_PREFIX = "sha256 "
// 30:
// 31:         sig { override.params(cask_stanza_block: RuboCop::Cask::AST::StanzaBlock).void }
// 32:         def on_cask_stanza_block(cask_stanza_block)
// 33:           cask_stanza_block.stanzas.each do |stanza|
// 34:             node = stanza.stanza_node
// 35:             next if stanza.stanza_name != :sha256 || !node.is_a?(RuboCop::AST::SendNode)
// 36:
// 37:             hash_node = node.last_argument
// 38:             next if hash_node.nil? || !hash_node.hash_type?
// 39:
// 40:             pairs = hash_node.pairs
// 41:             next unless pairs.all? { |pair| pair.key.sym_type? && ARCH_ORDER.include?(pair.key.value) }
// 42:
// 43:             sorted = pairs.each_with_index
// 44:                           .sort_by { |pair, index| [ARCH_ORDER.index(pair.key.value), index] }
// 45:                           .map(&:first)
// 46:             next if pairs == sorted
// 47:
// 48:             add_offense(node, message: MESSAGE) do |corrector|
// 49:               next if comments_in_range(node).any?
// 50:
// 51:               corrector.replace(node.source_range, rebuild(node, sorted))
// 52:             end
// 53:           end
// 54:         end
// 55:
// 56:         private
// 57:
// 58:         sig { params(node: RuboCop::AST::SendNode, pairs: T::Array[RuboCop::AST::PairNode]).returns(String) }
// 59:         def rebuild(node, pairs)
// 60:           width = pairs.map { |pair| pair.key.source.length }.max.to_i
// 61:           indent = " " * (node.loc.column + STANZA_PREFIX.length)
// 62:           pairs.each_with_index.map do |pair, index|
// 63:             key = "#{pair.key.source}:".ljust(width + 2)
// 64:             "#{index.zero? ? STANZA_PREFIX : indent}#{key}#{pair.value.source}"
// 65:           end.join(",\n")
// 66:         end
// 67:       end
// 68:     end
// 69:   end
// 70: end
