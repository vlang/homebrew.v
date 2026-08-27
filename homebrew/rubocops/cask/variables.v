module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/variables.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask(cask_block)` at line 30.
pub fn ruby_variables_l30_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask', ...args)
}

// Ruby def_delegator `def_delegator :@cask_block, :cask_node` at line 37.
pub fn ruby_variables_l37_d2_cask_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_node', ...args)
}

// Ruby method `add_offenses` at line 40.
pub fn ruby_variables_l40_d3_add_offenses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_offenses', ...args)
}

// Ruby method `blank_node?(node)` at line 65.
pub fn ruby_variables_l65_d4_blank_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('blank_node?', ...args)
}

// Ruby def_node_search `def_node_search :variable_assignment, <<~PATTERN` at line 76.
pub fn ruby_variables_l76_d5_variable_assignment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('variable_assignment', ...args)
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
// 9:       # This cop audits variables in casks.
// 10:       #
// 11:       # ### Example
// 12:       #
// 13:       # ```ruby
// 14:       # # bad
// 15:       # cask do
// 16:       #   arch = Hardware::CPU.intel? ? "darwin" : "darwin-arm64"
// 17:       # end
// 18:       #
// 19:       # # good
// 20:       # cask 'foo' do
// 21:       #   arch arm: "darwin-arm64", intel: "darwin"
// 22:       # end
// 23:       # ```
// 24:       class Variables < Base
// 25:         extend Forwardable
// 26:         extend AutoCorrector
// 27:         include CaskHelp
// 28:
// 29:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 30:         def on_cask(cask_block)
// 31:           @cask_block = T.let(cask_block, T.nilable(RuboCop::Cask::AST::CaskBlock))
// 32:           add_offenses
// 33:         end
// 34:
// 35:         private
// 36:
// 37:         def_delegator :@cask_block, :cask_node
// 38:
// 39:         sig { void }
// 40:         def add_offenses
// 41:           variable_assignment(cask_node) do |node, var_name, arch_condition, true_node, false_node|
// 42:             arm_node, intel_node = if arch_condition == :arm?
// 43:               [true_node, false_node]
// 44:             else
// 45:               [false_node, true_node]
// 46:             end
// 47:
// 48:             replacement_string = if var_name == :arch
// 49:               "arch "
// 50:             else
// 51:               "#{var_name} = on_arch_conditional "
// 52:             end
// 53:             replacement_parameters = []
// 54:             replacement_parameters << "arm: #{arm_node.source}" unless blank_node?(arm_node)
// 55:             replacement_parameters << "intel: #{intel_node.source}" unless blank_node?(intel_node)
// 56:             replacement_string += replacement_parameters.join(", ")
// 57:
// 58:             add_offense(node, message: "Use `#{replacement_string}` instead of `#{node.source}`.") do |corrector|
// 59:               corrector.replace(node, replacement_string)
// 60:             end
// 61:           end
// 62:         end
// 63:
// 64:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 65:         def blank_node?(node)
// 66:           case node.type
// 67:           when :str
// 68:             node.str_content.empty?
// 69:           when :nil
// 70:             true
// 71:           else
// 72:             false
// 73:           end
// 74:         end
// 75:
// 76:         def_node_search :variable_assignment, <<~PATTERN
// 77:           $(lvasgn $_ (if (send (const (const nil? :Hardware) :CPU) ${:arm? :intel?}) $_ $_))
// 78:         PATTERN
// 79:       end
// 80:     end
// 81:   end
// 82: end
