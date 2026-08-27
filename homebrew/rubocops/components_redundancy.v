module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/components_redundancy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 24.
pub fn ruby_components_redundancy_l24_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module FormulaAudit
// 9:       # This cop checks if redundant components are present and for other component errors.
// 10:       #
// 11:       # - `url|checksum|mirror|version` should be inside `stable` block
// 12:       # - `head` and `head do` should not be simultaneously present
// 13:       # - `bottle :unneeded`/`:disable` and `bottle do` should not be simultaneously present
// 14:       # - `stable do` should not be present without a `head` spec
// 15:       # - `stable do` should not be present with only `url|checksum|mirror|version`
// 16:       # - `head do` should not be present with only `url|branch`
// 17:       class ComponentsRedundancy < FormulaCop
// 18:         HEAD_MSG = "`head` and `head do` should not be simultaneously present"
// 19:         BOTTLE_MSG = "`bottle :modifier` and `bottle do` should not be simultaneously present"
// 20:         STABLE_MSG = "`stable do` should not be present without a `head` spec"
// 21:         STABLE_BLOCK_METHODS = [:url, :sha256, :mirror, :version].freeze
// 22:
// 23:         sig { override.params(formula_nodes: FormulaNodes).void }
// 24:         def audit_formula(formula_nodes)
// 25:           return if (body_node = formula_nodes.body_node).nil?
// 26:
// 27:           urls = find_method_calls_by_name(body_node, :url)
// 28:
// 29:           urls.each do |url|
// 30:             url.arguments.each do |arg|
// 31:               next if arg.class != RuboCop::AST::HashNode
// 32:
// 33:               url_args = arg.keys.each.map(&:value)
// 34:               if method_called?(body_node, :sha256) && url_args.include?(:tag) && url_args.include?(:revision)
// 35:                 problem "Do not use both `sha256` and `tag:`/`revision:`."
// 36:               end
// 37:             end
// 38:           end
// 39:
// 40:           stable_block = find_block(body_node, :stable)
// 41:           if stable_block
// 42:             STABLE_BLOCK_METHODS.each do |method_name|
// 43:               problem "`#{method_name}` should be put inside `stable` block" if method_called?(body_node, method_name)
// 44:             end
// 45:
// 46:             unless stable_block.body.nil?
// 47:               child_nodes = stable_block.body.begin_type? ? stable_block.body.child_nodes : [stable_block.body]
// 48:               if child_nodes.all? { |n| n.send_type? && STABLE_BLOCK_METHODS.include?(n.method_name) }
// 49:                 problem "`stable do` should not be present with only #{STABLE_BLOCK_METHODS.join("/")}"
// 50:               end
// 51:             end
// 52:           end
// 53:
// 54:           head_block = find_block(body_node, :head)
// 55:           if head_block && !head_block.body.nil?
// 56:             child_nodes = head_block.body.begin_type? ? head_block.body.child_nodes : [head_block.body]
// 57:             shorthand_head_methods = [:url, :branch]
// 58:             if child_nodes.all? { |n| n.send_type? && shorthand_head_methods.include?(n.method_name) }
// 59:               problem "`head do` should not be present with only #{shorthand_head_methods.join("/")}"
// 60:             end
// 61:           end
// 62:
// 63:           problem HEAD_MSG if method_called?(body_node, :head) &&
// 64:                               find_block(body_node, :head)
// 65:
// 66:           problem BOTTLE_MSG if method_called?(body_node, :bottle) &&
// 67:                                 find_block(body_node, :bottle)
// 68:
// 69:           return if method_called?(body_node, :head) ||
// 70:                     find_block(body_node, :head)
// 71:
// 72:           problem STABLE_MSG if stable_block
// 73:         end
// 74:       end
// 75:     end
// 76:   end
// 77: end
