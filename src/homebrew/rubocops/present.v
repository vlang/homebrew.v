module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/present.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :exists_and_not_empty?, <<~PATTERN` at line 26.
pub fn ruby_present_l26_d1_exists_and_not_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exists_and_not_empty?', ...args)
}

// Ruby method `on_and(node)` at line 41.
pub fn ruby_present_l41_d2_on_and(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_and', ...args)
}

// Ruby method `on_or(node)` at line 54.
pub fn ruby_present_l54_d3_on_or(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_or', ...args)
}

// Ruby method `autocorrect(corrector, node)` at line 65.
pub fn ruby_present_l65_d4_autocorrect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrect', ...args)
}

// Ruby method `replacement(node)` at line 74.
pub fn ruby_present_l74_d5_replacement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replacement', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks for code that can be simplified using `Object#present?`.
// 8:       #
// 9:       # ### Example
// 10:       #
// 11:       # ```ruby
// 12:       # # bad
// 13:       # !foo.nil? && !foo.empty?
// 14:       #
// 15:       # # bad
// 16:       # foo != nil && !foo.empty?
// 17:       #
// 18:       # # good
// 19:       # foo.present?
// 20:       # ```
// 21:       class Present < Base
// 22:         extend AutoCorrector
// 23:
// 24:         MSG = "Use `%<prefer>s` instead of `%<current>s`."
// 25:
// 26:         def_node_matcher :exists_and_not_empty?, <<~PATTERN
// 27:           (and
// 28:               {
// 29:                 (send (send $_ :nil?) :!)
// 30:                 (send (send $_ :!) :!)
// 31:                 (send $_ :!= nil)
// 32:                 $_
// 33:               }
// 34:               {
// 35:                 (send (send $_ :empty?) :!)
// 36:               }
// 37:           )
// 38:         PATTERN
// 39:
// 40:         sig { params(node: RuboCop::AST::AndNode).void }
// 41:         def on_and(node)
// 42:           exists_and_not_empty?(node) do |var1, var2|
// 43:             return if var1 != var2
// 44:
// 45:             message = format(MSG, prefer: replacement(var1), current: node.source)
// 46:
// 47:             add_offense(node, message:) do |corrector|
// 48:               autocorrect(corrector, node)
// 49:             end
// 50:           end
// 51:         end
// 52:
// 53:         sig { params(node: RuboCop::AST::OrNode).void }
// 54:         def on_or(node)
// 55:           exists_and_not_empty?(node) do |var1, var2|
// 56:             return if var1 != var2
// 57:
// 58:             add_offense(node, message: MSG) do |corrector|
// 59:               autocorrect(corrector, node)
// 60:             end
// 61:           end
// 62:         end
// 63:
// 64:         sig { params(corrector: RuboCop::Cop::Corrector, node: RuboCop::AST::Node).void }
// 65:         def autocorrect(corrector, node)
// 66:           variable1, _variable2 = exists_and_not_empty?(node)
// 67:           range = node.source_range
// 68:           corrector.replace(range, replacement(variable1))
// 69:         end
// 70:
// 71:         private
// 72:
// 73:         sig { params(node: T.nilable(RuboCop::AST::Node)).returns(String) }
// 74:         def replacement(node)
// 75:           node.respond_to?(:source) ? "#{node&.source}.present?" : "present?"
// 76:         end
// 77:       end
// 78:     end
// 79:   end
// 80: end
