module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/no_base64.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 30.
pub fn ruby_no_base64_l30_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby alias `alias on_csend on_send` at line 44.
pub fn ruby_no_base64_l44_d2_on_csend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_csend', ...args)
}

// Ruby method `on_const(node)` at line 47.
pub fn ruby_no_base64_l47_d3_on_const(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_const', ...args)
}

// Ruby method `require_base64?(node)` at line 61.
pub fn ruby_no_base64_l61_d4_require_base64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('require_base64?', ...args)
}

// Ruby method `top_level_const?(node, name)` at line 72.
pub fn ruby_no_base64_l72_d5_top_level_const(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('top_level_const?', ...args)
}

// Ruby method `autocorrect_base64_call(corrector, node)` at line 81.
pub fn ruby_no_base64_l81_d6_autocorrect_base64_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrect_base64_call', ...args)
}

// Ruby method `chainable?(node)` at line 99.
pub fn ruby_no_base64_l99_d7_chainable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('chainable?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Enforces the use of `String#unpack1` and `Array#pack` over the
// 8:       # `base64` gem, which Homebrew no longer includes.
// 9:       #
// 10:       # ### Example
// 11:       #
// 12:       # ```ruby
// 13:       # # bad
// 14:       # require "base64"
// 15:       # Base64.decode64(encoded)
// 16:       # Base64.strict_encode64(decoded)
// 17:       #
// 18:       # # good
// 19:       # encoded.unpack1("m")
// 20:       # [decoded].pack("m0")
// 21:       # ```
// 22:       class NoBase64 < Base
// 23:         include RangeHelp
// 24:         extend AutoCorrector
// 25:
// 26:         MSG = "Homebrew no longer includes the `base64` gem; " \
// 27:               "use `String#unpack1` or `Array#pack` instead."
// 28:
// 29:         sig { params(node: RuboCop::AST::SendNode).void }
// 30:         def on_send(node)
// 31:           if require_base64?(node)
// 32:             add_offense(node) do |corrector|
// 33:               parent = node.parent
// 34:               next if parent && !parent.begin_type?
// 35:
// 36:               corrector.remove(range_by_whole_lines(node.source_range, include_final_newline: true))
// 37:             end
// 38:           elsif top_level_const?(node.receiver, :Base64)
// 39:             add_offense(node) do |corrector|
// 40:               autocorrect_base64_call(corrector, node)
// 41:             end
// 42:           end
// 43:         end
// 44:         alias on_csend on_send
// 45:
// 46:         sig { params(node: RuboCop::AST::ConstNode).void }
// 47:         def on_const(node)
// 48:           return unless top_level_const?(node, :Base64)
// 49:
// 50:           parent = node.parent
// 51:           return if parent.is_a?(RuboCop::AST::SendNode) && parent.receiver == node
// 52:           # Formulae for base64 tools are legitimately named `Base64`.
// 53:           return if parent.is_a?(RuboCop::AST::ClassNode) && parent.identifier == node
// 54:
// 55:           add_offense(node)
// 56:         end
// 57:
// 58:         private
// 59:
// 60:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 61:         def require_base64?(node)
// 62:           return false unless node.method?(:require)
// 63:
// 64:           receiver = node.receiver
// 65:           return false if receiver && !top_level_const?(receiver, :Kernel)
// 66:
// 67:           arg = node.first_argument
// 68:           node.arguments.one? && arg.is_a?(RuboCop::AST::StrNode) && arg.value == "base64"
// 69:         end
// 70:
// 71:         sig { params(node: T.nilable(RuboCop::AST::Node), name: Symbol).returns(T::Boolean) }
// 72:         def top_level_const?(node, name)
// 73:           return false unless node.is_a?(RuboCop::AST::ConstNode)
// 74:           return false if node.short_name != name
// 75:
// 76:           namespace = node.namespace
// 77:           namespace.nil? || namespace.cbase_type?
// 78:         end
// 79:
// 80:         sig { params(corrector: RuboCop::Cop::Corrector, node: RuboCop::AST::SendNode).void }
// 81:         def autocorrect_base64_call(corrector, node)
// 82:           return unless node.arguments.one?
// 83:
// 84:           arg = node.first_argument
// 85:           replacement = case node.method_name
// 86:           when :decode64, :strict_decode64
// 87:             directive = (node.method_name == :decode64) ? "m" : "m0"
// 88:             "#{arg.source}.unpack1(\"#{directive}\")" if chainable?(arg)
// 89:           when :encode64, :strict_encode64
// 90:             directive = (node.method_name == :encode64) ? "m" : "m0"
// 91:             "[#{arg.source}].pack(\"#{directive}\")" if !arg.splat_type? && !arg.block_pass_type?
// 92:           end
// 93:           return if replacement.nil?
// 94:
// 95:           corrector.replace(node, replacement)
// 96:         end
// 97:
// 98:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 99:         def chainable?(node)
// 100:           if node.is_a?(RuboCop::AST::SendNode)
// 101:             !node.operator_method? && !node.assignment_method?
// 102:           else
// 103:             node.variable? || node.const_type? || node.begin_type? ||
// 104:               (node.literal? && !node.range_type?)
// 105:           end
// 106:         end
// 107:       end
// 108:     end
// 109:   end
// 110: end
