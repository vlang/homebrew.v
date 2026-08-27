module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/empty_arch_argument.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 26.
pub fn ruby_empty_arch_argument_l26_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `empty_string_value?(pair)` at line 59.
pub fn ruby_empty_arch_argument_l59_d2_empty_string_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('empty_string_value?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # This cop checks for empty strings in the `arch` stanza.
// 8:       #
// 9:       # ### Example
// 10:       #
// 11:       # ```ruby
// 12:       # # bad
// 13:       # arch arm: "-arm64", intel: ""
// 14:       #
// 15:       # # good
// 16:       # arch arm: "-arm64"
// 17:       # ```
// 18:       class EmptyArchArgument < Base
// 19:         include RangeHelp
// 20:         extend AutoCorrector
// 21:
// 22:         MSG = "Remove the empty `%<key>s:` argument from the `arch` stanza."
// 23:         MSG_STANZA = "Remove the `arch` stanza as all its arguments are empty."
// 24:
// 25:         sig { params(node: RuboCop::AST::SendNode).void }
// 26:         def on_send(node)
// 27:           return if node.method_name != :arch || node.receiver
// 28:           return unless (hash = node.first_argument)&.hash_type?
// 29:
// 30:           pairs = hash.pairs
// 31:           return if pairs.none? { |pair| empty_string_value?(pair) }
// 32:
// 33:           if pairs.all? { |pair| empty_string_value?(pair) }
// 34:             add_offense(node, message: MSG_STANZA) do |corrector|
// 35:               corrector.remove(range_by_whole_lines(node.source_range, include_final_newline: true))
// 36:             end
// 37:             return
// 38:           end
// 39:
// 40:           pairs.each_with_index do |pair, index|
// 41:             next unless empty_string_value?(pair)
// 42:
// 43:             key = (pair.key.sym_type? || pair.key.str_type?) ? pair.key.value : pair.key.source
// 44:
// 45:             add_offense(pair, message: format(MSG, key:)) do |corrector|
// 46:               range = if index.zero?
// 47:                 pair.source_range.join(pairs.fetch(1).source_range.begin)
// 48:               else
// 49:                 pairs.fetch(index - 1).source_range.end.join(pair.source_range.end)
// 50:               end
// 51:               corrector.remove(range)
// 52:             end
// 53:           end
// 54:         end
// 55:
// 56:         private
// 57:
// 58:         sig { params(pair: RuboCop::AST::PairNode).returns(T::Boolean) }
// 59:         def empty_string_value?(pair)
// 60:           pair.value.str_type? && pair.value.value.empty?
// 61:         end
// 62:       end
// 63:     end
// 64:   end
// 65: end
