module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/io_read.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 14.
pub fn ruby_io_read_l14_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `safe?(node)` at line 24.
pub fn ruby_io_read_l24_d2_safe(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('safe?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # This cop restricts usage of `IO.read` functions for security reasons.
// 8:       class IORead < Base
// 9:         MSG = "The use of `IO.%<method>s` is a security risk."
// 10:
// 11:         RESTRICT_ON_SEND = [:read, :readlines].freeze
// 12:
// 13:         sig { params(node: RuboCop::AST::SendNode).void }
// 14:         def on_send(node)
// 15:           return if node.receiver != s(:const, nil, :IO)
// 16:           return if safe?(node.arguments.first)
// 17:
// 18:           add_offense(node, message: format(MSG, method: node.method_name))
// 19:         end
// 20:
// 21:         private
// 22:
// 23:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 24:         def safe?(node)
// 25:           if node.str_type?
// 26:             !node.str_content.empty? && !node.str_content.start_with?("|")
// 27:           elsif node.dstr_type? || (node.send_type? && T.cast(node, RuboCop::AST::SendNode).method?(:+))
// 28:             safe?(node.children.first)
// 29:           else
// 30:             false
// 31:           end
// 32:         end
// 33:       end
// 34:     end
// 35:   end
// 36: end
