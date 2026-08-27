module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/full_name_split.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 46.
pub fn ruby_full_name_split_l46_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `on_csend(node)` at line 51.
pub fn ruby_full_name_split_l51_d2_on_csend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_csend', ...args)
}

// Ruby method `check_full_name_split(node)` at line 58.
pub fn ruby_full_name_split_l58_d3_check_full_name_split(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_full_name_split', ...args)
}

// Ruby method `basename_call?(node)` at line 75.
pub fn ruby_full_name_split_l75_d4_basename_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('basename_call?', ...args)
}

// Ruby method `split_call?(node, split_call)` at line 87.
pub fn ruby_full_name_split_l87_d5_split_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('split_call?', ...args)
}

// Ruby method `full_name_receiver?(receiver)` at line 99.
pub fn ruby_full_name_split_l99_d6_full_name_receiver(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_name_receiver?', ...args)
}

// Ruby method `receiver_identifier(receiver)` at line 108.
pub fn ruby_full_name_split_l108_d7_receiver_identifier(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('receiver_identifier', ...args)
}

// Ruby method `receiver_method_name(receiver)` at line 118.
pub fn ruby_full_name_split_l118_d8_receiver_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('receiver_method_name', ...args)
}

// Ruby method `replacement(node, receiver)` at line 130.
pub fn ruby_full_name_split_l130_d9_replacement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replacement', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks for formula or cask full-name parsing that should use `Utils.name_from_full_name`.
// 8:       #
// 9:       # ### Examples
// 10:       #
// 11:       # ```ruby
// 12:       # # bad
// 13:       # name.split("/").last
// 14:       # token.split("/").fetch(-1)
// 15:       #
// 16:       # # good
// 17:       # Utils.name_from_full_name(name)
// 18:       # Utils.name_from_full_name(token)
// 19:       # ```
// 20:       class FullNameSplit < Base
// 21:         extend AutoCorrector
// 22:
// 23:         MSG = "Use `Utils.name_from_full_name` instead of splitting formula or cask full names."
// 24:
// 25:         RESTRICT_ON_SEND = [:last, :fetch].freeze
// 26:         FULL_NAME_RECEIVER_NAMES = %w[
// 27:           cask_full_name
// 28:           cask_token
// 29:           dep_full_name
// 30:           dep_name
// 31:           formula_full_name
// 32:           formula_name
// 33:           full_name
// 34:           name
// 35:           new_full_name
// 36:           new_name
// 37:           old_full_name
// 38:           old_name
// 39:           resolved_full_name
// 40:           service_name
// 41:           token
// 42:         ].freeze
// 43:         private_constant :FULL_NAME_RECEIVER_NAMES
// 44:
// 45:         sig { params(node: RuboCop::AST::SendNode).void }
// 46:         def on_send(node)
// 47:           check_full_name_split(node)
// 48:         end
// 49:
// 50:         sig { params(node: RuboCop::AST::SendNode).void }
// 51:         def on_csend(node)
// 52:           check_full_name_split(node)
// 53:         end
// 54:
// 55:         private
// 56:
// 57:         sig { params(node: RuboCop::AST::SendNode).void }
// 58:         def check_full_name_split(node)
// 59:           return unless basename_call?(node)
// 60:
// 61:           split_call = node.receiver
// 62:           return unless split_call.is_a?(RuboCop::AST::SendNode)
// 63:           return unless split_call?(node, split_call)
// 64:
// 65:           receiver = split_call.receiver
// 66:           return unless receiver
// 67:           return unless full_name_receiver?(receiver)
// 68:
// 69:           add_offense(node) do |corrector|
// 70:             corrector.replace(node.source_range, replacement(node, receiver))
// 71:           end
// 72:         end
// 73:
// 74:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 75:         def basename_call?(node)
// 76:           return true if node.method?(:last) && node.arguments.empty?
// 77:           return false unless node.method?(:fetch)
// 78:           return false if node.arguments.length != 1
// 79:
// 80:           argument = node.first_argument
// 81:           argument.is_a?(RuboCop::AST::Node) &&
// 82:             argument.int_type? &&
// 83:             T.cast(argument, RuboCop::AST::IntNode).value == -1
// 84:         end
// 85:
// 86:         sig { params(node: RuboCop::AST::SendNode, split_call: RuboCop::AST::SendNode).returns(T::Boolean) }
// 87:         def split_call?(node, split_call)
// 88:           return false unless split_call.method?(:split)
// 89:           return false if split_call.arguments.length != 1
// 90:           return false if split_call.csend_type? != node.csend_type?
// 91:
// 92:           argument = split_call.first_argument
// 93:           argument.is_a?(RuboCop::AST::Node) &&
// 94:             argument.str_type? &&
// 95:             T.cast(argument, RuboCop::AST::StrNode).value == "/"
// 96:         end
// 97:
// 98:         sig { params(receiver: RuboCop::AST::Node).returns(T::Boolean) }
// 99:         def full_name_receiver?(receiver)
// 100:           return false if receiver.source.match?(/(?:\A|[.])tap(?:\.|&\.)full_name\z/)
// 101:
// 102:           identifier = receiver_identifier(receiver)
// 103:
// 104:           !identifier.nil? && FULL_NAME_RECEIVER_NAMES.include?(identifier)
// 105:         end
// 106:
// 107:         sig { params(receiver: RuboCop::AST::Node).returns(T.nilable(String)) }
// 108:         def receiver_identifier(receiver)
// 109:           case receiver.type
// 110:           when :lvar, :ivar, :cvar, :gvar
// 111:             receiver.source.delete_prefix("@@").delete_prefix("@").delete_prefix("$")
// 112:           when :send, :csend
// 113:             receiver_method_name(T.cast(receiver, RuboCop::AST::SendNode))
// 114:           end
// 115:         end
// 116:
// 117:         sig { params(receiver: RuboCop::AST::SendNode).returns(T.nilable(String)) }
// 118:         def receiver_method_name(receiver)
// 119:           return receiver.method_name.to_s unless receiver.method?(:[])
// 120:           return if receiver.arguments.length != 1
// 121:
// 122:           argument = receiver.first_argument
// 123:           return unless argument.is_a?(RuboCop::AST::Node)
// 124:           return unless argument.str_type?
// 125:
// 126:           T.cast(argument, RuboCop::AST::StrNode).value.to_s
// 127:         end
// 128:
// 129:         sig { params(node: RuboCop::AST::SendNode, receiver: RuboCop::AST::Node).returns(String) }
// 130:         def replacement(node, receiver)
// 131:           if node.csend_type?
// 132:             "#{receiver.source}&.then { ::Utils.name_from_full_name(it) }"
// 133:           else
// 134:             "::Utils.name_from_full_name(#{receiver.source})"
// 135:           end
// 136:         end
// 137:       end
// 138:     end
// 139:   end
// 140: end
