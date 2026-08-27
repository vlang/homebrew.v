module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/presence.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :redundant_receiver_and_other, <<~PATTERN` at line 51.
pub fn ruby_presence_l51_d1_redundant_receiver_and_other(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('redundant_receiver_and_other', ...args)
}

// Ruby def_node_matcher `def_node_matcher :redundant_negative_receiver_and_other, <<~PATTERN` at line 66.
pub fn ruby_presence_l66_d2_redundant_negative_receiver_and_other(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('redundant_negative_receiver_and_other', ...args)
}

// Ruby method `on_if(node)` at line 82.
pub fn ruby_presence_l82_d3_on_if(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_if', ...args)
}

// Ruby method `register_offense(node, receiver, other)` at line 103.
pub fn ruby_presence_l103_d4_register_offense(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('register_offense', ...args)
}

// Ruby method `ignore_if_node?(node)` at line 110.
pub fn ruby_presence_l110_d5_ignore_if_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignore_if_node?', ...args)
}

// Ruby method `ignore_other_node?(node)` at line 115.
pub fn ruby_presence_l115_d6_ignore_other_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignore_other_node?', ...args)
}

// Ruby method `message(node, receiver, other)` at line 125.
pub fn ruby_presence_l125_d7_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('message', ...args)
}

// Ruby method `current(node)` at line 132.
pub fn ruby_presence_l132_d8_current(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current', ...args)
}

// Ruby method `replacement(receiver, other, left_sibling)` at line 147.
pub fn ruby_presence_l147_d9_replacement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replacement', ...args)
}

// Ruby method `build_source_for_or_method(other)` at line 161.
pub fn ruby_presence_l161_d10_build_source_for_or_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_source_for_or_method', ...args)
}

// Ruby method `method_range(node)` at line 173.
pub fn ruby_presence_l173_d11_method_range(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_range', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks code that can be written more easily using
// 8:       # `Object#presence` defined by Active Support.
// 9:       #
// 10:       # ### Examples
// 11:       #
// 12:       # ```ruby
// 13:       # # bad
// 14:       # a.present? ? a : nil
// 15:       #
// 16:       # # bad
// 17:       # !a.present? ? nil : a
// 18:       #
// 19:       # # bad
// 20:       # a.blank? ? nil : a
// 21:       #
// 22:       # # bad
// 23:       # !a.blank? ? a : nil
// 24:       #
// 25:       # # good
// 26:       # a.presence
// 27:       # ```
// 28:       #
// 29:       # ```ruby
// 30:       # # bad
// 31:       # a.present? ? a : b
// 32:       #
// 33:       # # bad
// 34:       # !a.present? ? b : a
// 35:       #
// 36:       # # bad
// 37:       # a.blank? ? b : a
// 38:       #
// 39:       # # bad
// 40:       # !a.blank? ? a : b
// 41:       #
// 42:       # # good
// 43:       # a.presence || b
// 44:       # ```
// 45:       class Presence < Base
// 46:         include RangeHelp
// 47:         extend AutoCorrector
// 48:
// 49:         MSG = "Use `%<prefer>s` instead of `%<current>s`."
// 50:
// 51:         def_node_matcher :redundant_receiver_and_other, <<~PATTERN
// 52:           {
// 53:             (if
// 54:               (send $_recv :present?)
// 55:               _recv
// 56:               $!begin
// 57:             )
// 58:             (if
// 59:               (send $_recv :blank?)
// 60:               $!begin
// 61:               _recv
// 62:             )
// 63:           }
// 64:         PATTERN
// 65:
// 66:         def_node_matcher :redundant_negative_receiver_and_other, <<~PATTERN
// 67:           {
// 68:             (if
// 69:               (send (send $_recv :present?) :!)
// 70:               $!begin
// 71:               _recv
// 72:             )
// 73:             (if
// 74:               (send (send $_recv :blank?) :!)
// 75:               _recv
// 76:               $!begin
// 77:             )
// 78:           }
// 79:         PATTERN
// 80:
// 81:         sig { params(node: RuboCop::AST::IfNode).void }
// 82:         def on_if(node)
// 83:           return if ignore_if_node?(node)
// 84:
// 85:           redundant_receiver_and_other(node) do |receiver, other|
// 86:             return if ignore_other_node?(other) || receiver.nil?
// 87:
// 88:             register_offense(node, receiver, other)
// 89:           end
// 90:
// 91:           redundant_negative_receiver_and_other(node) do |receiver, other|
// 92:             return if ignore_other_node?(other) || receiver.nil?
// 93:
// 94:             register_offense(node, receiver, other)
// 95:           end
// 96:         end
// 97:
// 98:         private
// 99:
// 100:         sig {
// 101:           params(node: RuboCop::AST::IfNode, receiver: RuboCop::AST::Node, other: T.nilable(RuboCop::AST::Node)).void
// 102:         }
// 103:         def register_offense(node, receiver, other)
// 104:           add_offense(node, message: message(node, receiver, other)) do |corrector|
// 105:             corrector.replace(node, replacement(receiver, other, node.left_sibling))
// 106:           end
// 107:         end
// 108:
// 109:         sig { params(node: RuboCop::AST::IfNode).returns(T::Boolean) }
// 110:         def ignore_if_node?(node)
// 111:           node.elsif?
// 112:         end
// 113:
// 114:         sig { params(node: T.nilable(RuboCop::AST::Node)).returns(T::Boolean) }
// 115:         def ignore_other_node?(node)
// 116:           return false unless node
// 117:
// 118:           node.if_type? || node.rescue_type? || node.while_type?
// 119:         end
// 120:
// 121:         sig {
// 122:           params(node: RuboCop::AST::IfNode, receiver: RuboCop::AST::Node, other: T.nilable(RuboCop::AST::Node))
// 123:             .returns(String)
// 124:         }
// 125:         def message(node, receiver, other)
// 126:           prefer = replacement(receiver, other, node.left_sibling).gsub(/^\s*|\n/, "")
// 127:           current = current(node).gsub(/^\s*|\n/, "")
// 128:           format(MSG, prefer:, current:)
// 129:         end
// 130:
// 131:         sig { params(node: RuboCop::AST::IfNode).returns(String) }
// 132:         def current(node)
// 133:           if !node.ternary? && node.source.include?("\n")
// 134:             "#{node.loc.keyword.with(end_pos: node.condition.loc.selector.end_pos).source} ... end"
// 135:           else
// 136:             node.source.gsub(/\n\s*/, " ")
// 137:           end
// 138:         end
// 139:
// 140:         sig {
// 141:           params(
// 142:             receiver:     RuboCop::AST::Node,
// 143:             other:        T.nilable(RuboCop::AST::Node),
// 144:             left_sibling: T.nilable(T.any(RuboCop::AST::Node, Symbol)),
// 145:           ).returns(String)
// 146:         }
// 147:         def replacement(receiver, other, left_sibling)
// 148:           or_source = if other.is_a?(RuboCop::AST::SendNode)
// 149:             build_source_for_or_method(other)
// 150:           elsif other.nil? || other.nil_type?
// 151:             ""
// 152:           else
// 153:             " || #{other.source}"
// 154:           end
// 155:
// 156:           replaced = "#{receiver.source}.presence#{or_source}"
// 157:           left_sibling ? "(#{replaced})" : replaced
// 158:         end
// 159:
// 160:         sig { params(other: RuboCop::AST::SendNode).returns(String) }
// 161:         def build_source_for_or_method(other)
// 162:           if other.parenthesized? || other.method?("[]") || other.arithmetic_operation? || !other.arguments?
// 163:             " || #{other.source}"
// 164:           else
// 165:             method = method_range(other).source
// 166:             arguments = other.arguments.map(&:source).join(", ")
// 167:
// 168:             " || #{method}(#{arguments})"
// 169:           end
// 170:         end
// 171:
// 172:         sig { params(node: RuboCop::AST::SendNode).returns(Parser::Source::Range) }
// 173:         def method_range(node)
// 174:           range_between(node.source_range.begin_pos, node.first_argument.source_range.begin_pos - 1)
// 175:         end
// 176:       end
// 177:     end
// 178:   end
// 179: end
