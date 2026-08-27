module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/negate_include.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :negate_include_call?, <<~PATTERN` at line 31.
pub fn ruby_negate_include_l31_d1_negate_include_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('negate_include_call?', ...args)
}

// Ruby method `on_send(node)` at line 36.
pub fn ruby_negate_include_l36_d2_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Enforces the use of `collection.exclude?(obj)`
// 8:       # over `!collection.include?(obj)`.
// 9:       #
// 10:       # NOTE: This cop is unsafe because false positives will occur for
// 11:       #       receiver objects that do not have an `#exclude?` method (e.g. `IPAddr`).
// 12:       #
// 13:       # ### Example
// 14:       #
// 15:       # ```ruby
// 16:       # # bad
// 17:       # !array.include?(2)
// 18:       # !hash.include?(:key)
// 19:       #
// 20:       # # good
// 21:       # array.exclude?(2)
// 22:       # hash.exclude?(:key)
// 23:       # ```
// 24:       class NegateInclude < Base
// 25:         extend AutoCorrector
// 26:
// 27:         MSG = "Use `.exclude?` and remove the negation part."
// 28:
// 29:         RESTRICT_ON_SEND = [:!].freeze
// 30:
// 31:         def_node_matcher :negate_include_call?, <<~PATTERN
// 32:           (send (send $!nil? :include? $_) :!)
// 33:         PATTERN
// 34:
// 35:         sig { params(node: RuboCop::AST::SendNode).void }
// 36:         def on_send(node)
// 37:           return unless (receiver, obj = negate_include_call?(node))
// 38:
// 39:           add_offense(node) do |corrector|
// 40:             corrector.replace(node, "#{receiver.source}.exclude?(#{obj.source})")
// 41:           end
// 42:         end
// 43:       end
// 44:     end
// 45:   end
// 46: end
