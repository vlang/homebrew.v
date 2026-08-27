module ast

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/ast/stanza.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(method_node, all_comments)` at line 21.
pub fn ruby_stanza_l21_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby attr_reader `attr_reader :method_node` at line 27.
pub fn ruby_stanza_l27_d2_method_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_node', ...args)
}

// Ruby alias `alias stanza_node method_node` at line 28.
pub fn ruby_stanza_l28_d3_stanza_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stanza_node', ...args)
}

// Ruby attr_reader `attr_reader :all_comments` at line 31.
pub fn ruby_stanza_l31_d4_all_comments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('all_comments', ...args)
}

// Ruby def_delegator `def_delegator :stanza_node, :parent, :parent_node` at line 33.
pub fn ruby_stanza_l33_d5_parent_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parent_node', ...args)
}

// Ruby def_delegator `def_delegator :stanza_node, :arch_variable?` at line 34.
pub fn ruby_stanza_l34_d6_arch_variable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arch_variable?', ...args)
}

// Ruby def_delegator `def_delegator :stanza_node, :system_variable?` at line 35.
pub fn ruby_stanza_l35_d7_system_variable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('system_variable?', ...args)
}

// Ruby def_delegator `def_delegator :stanza_node, :on_system_block?` at line 36.
pub fn ruby_stanza_l36_d8_on_system_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_system_block?', ...args)
}

// Ruby method `source_range` at line 39.
pub fn ruby_stanza_l39_d9_source_range(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_range', ...args)
}

// Ruby method `source_range_with_comments` at line 44.
pub fn ruby_stanza_l44_d10_source_range_with_comments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_range_with_comments', ...args)
}

// Ruby def_delegator `def_delegator :source_range, :source` at line 50.
pub fn ruby_stanza_l50_d11_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source', ...args)
}

// Ruby def_delegator `def_delegator :source_range_with_comments, :source, :source_with_comments` at line 51.
pub fn ruby_stanza_l51_d12_source_with_comments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_with_comments', ...args)
}

// Ruby method `stanza_name` at line 55.
pub fn ruby_stanza_l55_d13_stanza_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stanza_name', ...args)
}

// Ruby method `stanza_group` at line 64.
pub fn ruby_stanza_l64_d14_stanza_group(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stanza_group', ...args)
}

// Ruby method `stanza_index` at line 69.
pub fn ruby_stanza_l69_d15_stanza_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stanza_index', ...args)
}

// Ruby method `same_group?(other)` at line 74.
pub fn ruby_stanza_l74_d16_same_group(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('same_group?', ...args)
}

// Ruby method `comments` at line 79.
pub fn ruby_stanza_l79_d17_comments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('comments', ...args)
}

// Ruby method `comments_hash` at line 89.
pub fn ruby_stanza_l89_d18_comments_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('comments_hash', ...args)
}

// Ruby method `==(other)` at line 97.
pub fn ruby_stanza_l97_d19_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby alias `alias eql? ==` at line 100.
pub fn ruby_stanza_l100_d20_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby method `#{stanza_name.to_s.chomp("!")}?               # def url?` at line 104.
pub fn ruby_stanza_l104_d21_stanza_name_to_s_chomp(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{stanza_name.to_s.chomp', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5:
// 6: module RuboCop
// 7:   module Cask
// 8:     module AST
// 9:       # This class wraps the AST send/block node that encapsulates the method
// 10:       # call that comprises the stanza. It includes various helper methods to
// 11:       # aid cops in their analysis.
// 12:       class Stanza
// 13:         extend Forwardable
// 14:
// 15:         sig {
// 16:           params(
// 17:             method_node:  T.any(RuboCop::AST::AsgnNode, RuboCop::AST::BlockNode, RuboCop::AST::SendNode),
// 18:             all_comments: T::Array[T.any(String, Parser::Source::Comment)],
// 19:           ).void
// 20:         }
// 21:         def initialize(method_node, all_comments)
// 22:           @method_node = method_node
// 23:           @all_comments = all_comments
// 24:         end
// 25:
// 26:         sig { returns(T.any(RuboCop::AST::AsgnNode, RuboCop::AST::BlockNode, RuboCop::AST::SendNode)) }
// 27:         attr_reader :method_node
// 28:         alias stanza_node method_node
// 29:
// 30:         sig { returns(T::Array[T.any(Parser::Source::Comment, String)]) }
// 31:         attr_reader :all_comments
// 32:
// 33:         def_delegator :stanza_node, :parent, :parent_node
// 34:         def_delegator :stanza_node, :arch_variable?
// 35:         def_delegator :stanza_node, :system_variable?
// 36:         def_delegator :stanza_node, :on_system_block?
// 37:
// 38:         sig { returns(Parser::Source::Range) }
// 39:         def source_range
// 40:           stanza_node.location_expression
// 41:         end
// 42:
// 43:         sig { returns(Parser::Source::Range) }
// 44:         def source_range_with_comments
// 45:           comments.reduce(source_range) do |range, comment|
// 46:             range.join(comment.loc.expression)
// 47:           end
// 48:         end
// 49:
// 50:         def_delegator :source_range, :source
// 51:         def_delegator :source_range_with_comments, :source,
// 52:                       :source_with_comments
// 53:
// 54:         sig { returns(Symbol) }
// 55:         def stanza_name
// 56:           return :on_arch_conditional if arch_variable?
// 57:           return :on_system_conditional if system_variable?
// 58:           return stanza_node.method_node&.method_name if stanza_node.block_type?
// 59:
// 60:           T.cast(stanza_node, RuboCop::AST::SendNode).method_name
// 61:         end
// 62:
// 63:         sig { returns(T.nilable(T::Array[Symbol])) }
// 64:         def stanza_group
// 65:           Constants::STANZA_GROUP_HASH[stanza_name]
// 66:         end
// 67:
// 68:         sig { returns(T.nilable(Integer)) }
// 69:         def stanza_index
// 70:           Constants::STANZA_ORDER.index(stanza_name)
// 71:         end
// 72:
// 73:         sig { params(other: Stanza).returns(T::Boolean) }
// 74:         def same_group?(other)
// 75:           stanza_group == other.stanza_group
// 76:         end
// 77:
// 78:         sig { returns(T::Array[Parser::Source::Comment]) }
// 79:         def comments
// 80:           @comments ||= T.let(
// 81:             stanza_node.each_node.reduce([]) do |comments, node|
// 82:               comments | comments_hash[node.loc]
// 83:             end,
// 84:             T.nilable(T::Array[Parser::Source::Comment]),
// 85:           )
// 86:         end
// 87:
// 88:         sig { returns(T::Hash[Parser::Source::Map, T::Array[Parser::Source::Comment]]) }
// 89:         def comments_hash
// 90:           @comments_hash ||= T.let(
// 91:             Parser::Source::Comment.associate_locations(stanza_node.parent, all_comments),
// 92:             T.nilable(T::Hash[Parser::Source::Map, T::Array[Parser::Source::Comment]]),
// 93:           )
// 94:         end
// 95:
// 96:         sig { params(other: T.untyped).returns(T::Boolean) }
// 97:         def ==(other)
// 98:           self.class == other.class && stanza_node == other.stanza_node
// 99:         end
// 100:         alias eql? ==
// 101:
// 102:         Constants::STANZA_ORDER.each do |stanza_name|
// 103:           class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 104:             def #{stanza_name.to_s.chomp("!")}?               # def url?
// 105:               stanza_name == :#{stanza_name}                  #   stanza_name == :url
// 106:             end                                               # end
// 107:           RUBY
// 108:         end
// 109:       end
// 110:     end
// 111:   end
// 112: end
