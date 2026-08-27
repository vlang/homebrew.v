module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/blank.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :nil_or_empty?, <<~PATTERN` at line 32.
pub fn ruby_blank_l32_d1_nil_or_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('nil_or_empty?', ...args)
}

// Ruby method `on_or(node)` at line 48.
pub fn ruby_blank_l48_d2_on_or(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_or', ...args)
}

// Ruby method `autocorrect(corrector, node)` at line 62.
pub fn ruby_blank_l62_d3_autocorrect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrect', ...args)
}

// Ruby method `replacement(node)` at line 69.
pub fn ruby_blank_l69_d4_replacement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replacement', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks for code that can be simplified using `Object#blank?`.
// 8:       #
// 9:       # NOTE: Auto-correction for this cop is unsafe because `' '.empty?` returns `false`,
// 10:       #       but `' '.blank?` returns `true`. Therefore, auto-correction is not compatible
// 11:       #       if the receiver is a non-empty blank string.
// 12:       #
// 13:       # ### Example
// 14:       #
// 15:       # ```ruby
// 16:       # # bad
// 17:       # foo.nil? || foo.empty?
// 18:       # foo == nil || foo.empty?
// 19:       #
// 20:       # # good
// 21:       # foo.blank?
// 22:       # ```
// 23:       class Blank < Base
// 24:         extend AutoCorrector
// 25:
// 26:         MSG = "Use `%<prefer>s` instead of `%<current>s`."
// 27:
// 28:         # `(send nil $_)` is not actually a valid match for an offense. Nodes
// 29:         # that have a single method call on the left hand side
// 30:         # (`bar || foo.empty?`) will blow up when checking
// 31:         # `(send (:nil) :== $_)`.
// 32:         def_node_matcher :nil_or_empty?, <<~PATTERN
// 33:           (or
// 34:               {
// 35:                 (send $_ :!)
// 36:                 (send $_ :nil?)
// 37:                 (send $_ :== nil)
// 38:                 (send nil :== $_)
// 39:               }
// 40:               {
// 41:                 (send $_ :empty?)
// 42:                 (send (send (send $_ :empty?) :!) :!)
// 43:               }
// 44:           )
// 45:         PATTERN
// 46:
// 47:         sig { params(node: RuboCop::AST::Node).void }
// 48:         def on_or(node)
// 49:           nil_or_empty?(node) do |var1, var2|
// 50:             return if var1 != var2
// 51:
// 52:             message = format(MSG, prefer: replacement(var1), current: node.source)
// 53:             add_offense(node, message:) do |corrector|
// 54:               autocorrect(corrector, node)
// 55:             end
// 56:           end
// 57:         end
// 58:
// 59:         private
// 60:
// 61:         sig { params(corrector: RuboCop::Cop::Corrector, node: RuboCop::AST::Node).void }
// 62:         def autocorrect(corrector, node)
// 63:           variable1, _variable2 = nil_or_empty?(node)
// 64:           range = node.source_range
// 65:           corrector.replace(range, replacement(variable1))
// 66:         end
// 67:
// 68:         sig { params(node: T.nilable(RuboCop::AST::Node)).returns(String) }
// 69:         def replacement(node)
// 70:           node.respond_to?(:source) ? "#{node&.source}.blank?" : "blank?"
// 71:         end
// 72:       end
// 73:     end
// 74:   end
// 75: end
