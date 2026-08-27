module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/install_steps_source_independence.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 15.
pub fn ruby_install_steps_source_independence_l15_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby alias `alias on_csend on_send` at line 18.
pub fn ruby_install_steps_source_independence_l18_d2_on_csend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_csend', ...args)
}

// Ruby method `on_const(node)` at line 21.
pub fn ruby_install_steps_source_independence_l21_d3_on_const(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_const', ...args)
}

// Ruby method `source_dependent?(node)` at line 33.
pub fn ruby_install_steps_source_independence_l33_d4_source_dependent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_dependent?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Prevents structured install-step runners from depending on formula
// 8:       # source, formula resources or direct downloads after a bottle is poured.
// 9:       class InstallStepsSourceIndependence < Base
// 10:         MSG = "Install-step runners must use bottled files and API context " \
// 11:               "without loading formula source or resources."
// 12:         SOURCE_CONSTANTS = %w[Formula Formulary Resource].freeze
// 13:
// 14:         sig { params(node: RuboCop::AST::SendNode).void }
// 15:         def on_send(node)
// 16:           add_offense(node) if source_dependent?(node)
// 17:         end
// 18:         alias on_csend on_send
// 19:
// 20:         sig { params(node: RuboCop::AST::ConstNode).void }
// 21:         def on_const(node)
// 22:           return unless SOURCE_CONSTANTS.include?(node.const_name)
// 23:
// 24:           parent = node.parent
// 25:           return if parent.is_a?(RuboCop::AST::SendNode) && parent.receiver == node
// 26:
// 27:           add_offense(node)
// 28:         end
// 29:
// 30:         private
// 31:
// 32:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 33:         def source_dependent?(node)
// 34:           return true if node.method?(:resource)
// 35:
// 36:           receiver = node.receiver
// 37:           return false unless receiver.is_a?(RuboCop::AST::ConstNode)
// 38:           return true if SOURCE_CONSTANTS.include?(receiver.const_name)
// 39:           return true if receiver.const_name == "Utils::Curl"
// 40:
// 41:           receiver.const_name == "URI" && (node.method?(:open) || node.method?(:read))
// 42:         end
// 43:       end
// 44:     end
// 45:   end
// 46: end
