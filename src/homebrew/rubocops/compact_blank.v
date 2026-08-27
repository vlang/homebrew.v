module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/compact_blank.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :reject_with_block?, <<~PATTERN` at line 51.
pub fn ruby_compact_blank_l51_d1_reject_with_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reject_with_block?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :reject_with_block_pass?, <<~PATTERN` at line 59.
pub fn ruby_compact_blank_l59_d2_reject_with_block_pass(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reject_with_block_pass?', ...args)
}

// Ruby method `on_send(node)` at line 66.
pub fn ruby_compact_blank_l66_d3_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `bad_method?(node)` at line 79.
pub fn ruby_compact_blank_l79_d4_bad_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bad_method?', ...args)
}

// Ruby method `use_single_value_block_argument?(arguments, receiver_in_block)` at line 93.
pub fn ruby_compact_blank_l93_d5_use_single_value_block_argument(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('use_single_value_block_argument?', ...args)
}

// Ruby method `use_hash_value_block_argument?(arguments, receiver_in_block)` at line 100.
pub fn ruby_compact_blank_l100_d6_use_hash_value_block_argument(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('use_hash_value_block_argument?', ...args)
}

// Ruby method `offense_range(node)` at line 105.
pub fn ruby_compact_blank_l105_d7_offense_range(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('offense_range', ...args)
}

// Ruby method `preferred_method(node)` at line 116.
pub fn ruby_compact_blank_l116_d8_preferred_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preferred_method', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks if collection can be blank-compacted with `compact_blank`.
// 8:       #
// 9:       # NOTE: It is unsafe by default because false positives may occur in the
// 10:       #       blank check of block arguments to the receiver object.
// 11:       #
// 12:       #       For example, `[[1, 2], [3, nil]].reject { |first, second| second.blank? }` and
// 13:       #       `[[1, 2], [3, nil]].compact_blank` are not compatible. The same is true for `blank?`.
// 14:       #       This will work fine when the receiver is a hash object.
// 15:       #
// 16:       #       And `compact_blank!` has different implementations for `Array`, `Hash` and
// 17:       #       `ActionController::Parameters`.
// 18:       #       `Array#compact_blank!`, `Hash#compact_blank!` are equivalent to `delete_if(&:blank?)`.
// 19:       #       `ActionController::Parameters#compact_blank!` is equivalent to `reject!(&:blank?)`.
// 20:       #       If the cop makes a mistake, autocorrected code may get unexpected behavior.
// 21:       #
// 22:       # ### Examples
// 23:       #
// 24:       # ```ruby
// 25:       # # bad
// 26:       # collection.reject(&:blank?)
// 27:       # collection.reject { |_k, v| v.blank? }
// 28:       #
// 29:       # # good
// 30:       # collection.compact_blank
// 31:       # ```
// 32:       #
// 33:       # ```ruby
// 34:       # # bad
// 35:       # collection.delete_if(&:blank?)           # Same behavior as `Array#compact_blank!` and `Hash#compact_blank!`
// 36:       # collection.delete_if { |_, v| v.blank? } # Same behavior as `Array#compact_blank!` and `Hash#compact_blank!`
// 37:       # collection.reject!(&:blank?)             # Same behavior as `ActionController::Parameters#compact_blank!`
// 38:       # collection.reject! { |_k, v| v.blank? }  # Same behavior as `ActionController::Parameters#compact_blank!`
// 39:       #
// 40:       # # good
// 41:       # collection.compact_blank!
// 42:       # ```
// 43:       class CompactBlank < Base
// 44:         include RangeHelp
// 45:         extend AutoCorrector
// 46:
// 47:         MSG = "Use `%<preferred_method>s` instead."
// 48:
// 49:         RESTRICT_ON_SEND = [:reject, :delete_if, :reject!].freeze
// 50:
// 51:         def_node_matcher :reject_with_block?, <<~PATTERN
// 52:           (block
// 53:             (send _ {:reject :delete_if :reject!})
// 54:             $(args ...)
// 55:             (send
// 56:               $(lvar _) :blank?))
// 57:         PATTERN
// 58:
// 59:         def_node_matcher :reject_with_block_pass?, <<~PATTERN
// 60:           (send _ {:reject :delete_if :reject!}
// 61:             (block_pass
// 62:               (sym :blank?)))
// 63:         PATTERN
// 64:
// 65:         sig { params(node: RuboCop::AST::SendNode).void }
// 66:         def on_send(node)
// 67:           return unless bad_method?(node)
// 68:
// 69:           range = offense_range(node)
// 70:           preferred_method = preferred_method(node)
// 71:           add_offense(range, message: format(MSG, preferred_method:)) do |corrector|
// 72:             corrector.replace(range, preferred_method)
// 73:           end
// 74:         end
// 75:
// 76:         private
// 77:
// 78:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 79:         def bad_method?(node)
// 80:           return true if reject_with_block_pass?(node)
// 81:
// 82:           if (arguments, receiver_in_block = reject_with_block?(node.parent))
// 83:             return use_single_value_block_argument?(arguments, receiver_in_block) ||
// 84:                    use_hash_value_block_argument?(arguments, receiver_in_block)
// 85:           end
// 86:
// 87:           false
// 88:         end
// 89:
// 90:         sig {
// 91:           params(arguments: RuboCop::AST::ArgsNode, receiver_in_block: RuboCop::AST::Node).returns(T::Boolean)
// 92:         }
// 93:         def use_single_value_block_argument?(arguments, receiver_in_block)
// 94:           arguments.length == 1 && arguments.fetch(0).source == receiver_in_block.source
// 95:         end
// 96:
// 97:         sig {
// 98:           params(arguments: RuboCop::AST::ArgsNode, receiver_in_block: RuboCop::AST::Node).returns(T::Boolean)
// 99:         }
// 100:         def use_hash_value_block_argument?(arguments, receiver_in_block)
// 101:           arguments.length == 2 && arguments.fetch(1).source == receiver_in_block.source
// 102:         end
// 103:
// 104:         sig { params(node: RuboCop::AST::SendNode).returns(Parser::Source::Range) }
// 105:         def offense_range(node)
// 106:           end_pos = if node.parent&.block_type? && node.parent&.send_node == node
// 107:             node.parent.source_range.end_pos
// 108:           else
// 109:             node.source_range.end_pos
// 110:           end
// 111:
// 112:           range_between(node.loc.selector.begin_pos, end_pos)
// 113:         end
// 114:
// 115:         sig { params(node: RuboCop::AST::SendNode).returns(String) }
// 116:         def preferred_method(node)
// 117:           node.method?(:reject) ? "compact_blank" : "compact_blank!"
// 118:         end
// 119:       end
// 120:     end
// 121:   end
// 122: end
