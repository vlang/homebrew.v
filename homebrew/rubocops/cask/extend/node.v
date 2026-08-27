module extend

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/extend/node.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :method_node, "{$(send ...) (block $(send ...) ...)}"` at line 10.
pub fn ruby_node_l10_d1_method_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_node', ...args)
}

// Ruby def_node_matcher `def_node_matcher :block_body,  "(block _ _ $_)"` at line 11.
pub fn ruby_node_l11_d2_block_body(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('block_body', ...args)
}

// Ruby def_node_matcher `def_node_matcher :cask_block?, "(block (send nil? :cask ...) args ...)"` at line 12.
pub fn ruby_node_l12_d3_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_block?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :on_system_block?, "(block (send nil? {#{ON_SYSTEM_METHODS.map(&:inspect).join(" ")}} ...) args ...)"` at line 13.
pub fn ruby_node_l13_d4_on_system_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_system_block?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :arch_variable?, "(lvasgn _ (send nil? :on_arch_conditional ...))"` at line 15.
pub fn ruby_node_l15_d5_arch_variable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arch_variable?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :system_variable?, "(lvasgn _ (send nil? :on_system_conditional ...))"` at line 16.
pub fn ruby_node_l16_d6_system_variable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('system_variable?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :begin_block?, "(begin ...)"` at line 17.
pub fn ruby_node_l17_d7_begin_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('begin_block?', ...args)
}

// Ruby method `cask_on_system_block?` at line 20.
pub fn ruby_node_l20_d8_cask_on_system_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_on_system_block?', ...args)
}

// Ruby method `stanza?` at line 25.
pub fn ruby_node_l25_d9_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stanza?', ...args)
}

// Ruby method `heredoc?` at line 37.
pub fn ruby_node_l37_d10_heredoc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('heredoc?', ...args)
}

// Ruby method `location_expression` at line 42.
pub fn ruby_node_l42_d11_location_expression(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('location_expression', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module AST
// 6:     # Extensions for RuboCop's AST Node class.
// 7:     class Node
// 8:       include RuboCop::Cask::Constants
// 9:
// 10:       def_node_matcher :method_node, "{$(send ...) (block $(send ...) ...)}"
// 11:       def_node_matcher :block_body,  "(block _ _ $_)"
// 12:       def_node_matcher :cask_block?, "(block (send nil? :cask ...) args ...)"
// 13:       def_node_matcher :on_system_block?,
// 14:                        "(block (send nil? {#{ON_SYSTEM_METHODS.map(&:inspect).join(" ")}} ...) args ...)"
// 15:       def_node_matcher :arch_variable?, "(lvasgn _ (send nil? :on_arch_conditional ...))"
// 16:       def_node_matcher :system_variable?, "(lvasgn _ (send nil? :on_system_conditional ...))"
// 17:       def_node_matcher :begin_block?, "(begin ...)"
// 18:
// 19:       sig { returns(T::Boolean) }
// 20:       def cask_on_system_block?
// 21:         (on_system_block? && each_ancestor.any?(&:cask_block?)) || false
// 22:       end
// 23:
// 24:       sig { returns(T::Boolean) }
// 25:       def stanza?
// 26:         return true if arch_variable?
// 27:         return true if system_variable?
// 28:
// 29:         case self
// 30:         when RuboCop::AST::BlockNode, RuboCop::AST::SendNode
// 31:           ON_SYSTEM_METHODS.include?(method_name) || STANZA_ORDER.include?(method_name)
// 32:         else false
// 33:         end
// 34:       end
// 35:
// 36:       sig { returns(T::Boolean) }
// 37:       def heredoc?
// 38:         loc.is_a?(Parser::Source::Map::Heredoc)
// 39:       end
// 40:
// 41:       sig { returns(Parser::Source::Range) }
// 42:       def location_expression
// 43:         base_expression = loc.expression
// 44:         descendants.select(&:heredoc?).reduce(base_expression) do |expr, node|
// 45:           expr.join(node.loc.heredoc_end)
// 46:         end
// 47:       end
// 48:     end
// 49:   end
// 50: end
