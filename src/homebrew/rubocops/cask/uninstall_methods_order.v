module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/uninstall_methods_order.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 27.
pub fn ruby_uninstall_methods_order_l27_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `check_ordering(hash_node, comments)` at line 47.
pub fn ruby_uninstall_methods_order_l47_d2_check_ordering(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_ordering', ...args)
}

// Ruby method `report_and_correct_ordering_offense(method, hash_node, expected_order, comments)` at line 67.
pub fn ruby_uninstall_methods_order_l67_d3_report_and_correct_ordering_offense(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('report_and_correct_ordering_offense', ...args)
}

// Ruby method `check_metadata(hash_node, comments)` at line 86.
pub fn ruby_uninstall_methods_order_l86_d4_check_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_metadata', ...args)
}

// Ruby method `report_fully_invalid_metadata(on_upgrade_pair)` at line 108.
pub fn ruby_uninstall_methods_order_l108_d5_report_fully_invalid_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('report_fully_invalid_metadata', ...args)
}

// Ruby method `report_and_correct_useless_metadata(` at line 121.
pub fn ruby_uninstall_methods_order_l121_d6_report_and_correct_useless_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('report_and_correct_useless_metadata', ...args)
}

// Ruby method `report_partially_invalid_metadata(value_node, invalid_syms)` at line 146.
pub fn ruby_uninstall_methods_order_l146_d7_report_partially_invalid_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('report_partially_invalid_metadata', ...args)
}

// Ruby method `build_uninstall_body(pairs, comments, indentation)` at line 159.
pub fn ruby_uninstall_methods_order_l159_d8_build_uninstall_body(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_uninstall_body', ...args)
}

// Ruby method `on_upgrade_symbols(value_node)` at line 174.
pub fn ruby_uninstall_methods_order_l174_d9_on_upgrade_symbols(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_upgrade_symbols', ...args)
}

// Ruby method `method_order_index(method_node)` at line 187.
pub fn ruby_uninstall_methods_order_l187_d10_method_order_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_order_index', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/helper_functions"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Cask
// 9:       # This cop checks for the correct order of methods within the
// 10:       # 'uninstall' and 'zap' stanzas and validates related metadata.
// 11:       class UninstallMethodsOrder < Base
// 12:         extend AutoCorrector
// 13:         include HelperFunctions
// 14:
// 15:         MSG = "`%<method>s` method out of order"
// 16:
// 17:         # These keys are ignored when checking method order.
// 18:         # Mirrors AbstractUninstall::METADATA_KEYS.
// 19:         METADATA_KEYS = [:on_upgrade].freeze
// 20:
// 21:         USELESS_METADATA_MSG =
// 22:           "`on_upgrade` has no effect without matching `uninstall signal:` directive"
// 23:
// 24:         PARTIAL_METADATA_MSG = "`on_upgrade` lists %<symbols>s without matching `uninstall` directives"
// 25:
// 26:         sig { params(node: AST::SendNode).void }
// 27:         def on_send(node)
// 28:           return unless [:zap, :uninstall].include?(node.method_name)
// 29:
// 30:           hash_node = node.arguments.first
// 31:           return if hash_node.nil? || (!hash_node.is_a?(AST::Node) && !hash_node.hash_type?)
// 32:
// 33:           comments = processed_source.comments
// 34:
// 35:           check_ordering(hash_node, comments)
// 36:           check_metadata(hash_node, comments)
// 37:         end
// 38:
// 39:         private
// 40:
// 41:         sig {
// 42:           params(
// 43:             hash_node: AST::HashNode,
// 44:             comments:  T::Array[Parser::Source::Comment],
// 45:           ).void
// 46:         }
// 47:         def check_ordering(hash_node, comments)
// 48:           method_nodes = hash_node.pairs.map(&:key).reject do |method|
// 49:             name = method.children.first
// 50:             METADATA_KEYS.include?(name)
// 51:           end
// 52:
// 53:           expected_order = method_nodes.sort_by { |method| method_order_index(method) }
// 54:           method_nodes.each_with_index do |method, index|
// 55:             next if method == expected_order[index]
// 56:
// 57:             report_and_correct_ordering_offense(method, hash_node, expected_order, comments)
// 58:           end
// 59:         end
// 60:
// 61:         sig {
// 62:           params(method:         AST::Node,
// 63:                  hash_node:      AST::HashNode,
// 64:                  expected_order: T::Array[AST::Node],
// 65:                  comments:       T::Array[Parser::Source::Comment]).void
// 66:         }
// 67:         def report_and_correct_ordering_offense(method, hash_node, expected_order, comments)
// 68:           add_offense(method, message: format(MSG, method: method.children.first)) do |corrector|
// 69:             ordered_pairs = expected_order.map do |expected_method|
// 70:               hash_node.pairs.find { |pair| pair.key == expected_method }
// 71:             end
// 72:
// 73:             indentation = " " * (start_column(method) - line_start_column(method))
// 74:             new_code = build_uninstall_body(ordered_pairs, comments, indentation)
// 75:
// 76:             corrector.replace(hash_node.source_range, new_code)
// 77:           end
// 78:         end
// 79:
// 80:         sig {
// 81:           params(
// 82:             hash_node: AST::HashNode,
// 83:             comments:  T::Array[Parser::Source::Comment],
// 84:           ).void
// 85:         }
// 86:         def check_metadata(hash_node, comments)
// 87:           on_upgrade_pair = hash_node.pairs.find { |p| p.key.value == :on_upgrade }
// 88:           return unless on_upgrade_pair
// 89:
// 90:           requested = on_upgrade_symbols(on_upgrade_pair.value)
// 91:           return report_fully_invalid_metadata(on_upgrade_pair) if requested.empty?
// 92:
// 93:           available = []
// 94:           available << :signal if hash_node.pairs.any? { |p| p.key.value == :signal }
// 95:
// 96:           valid_syms   = requested & available
// 97:           invalid_syms = requested - available
// 98:
// 99:           if valid_syms.empty?
// 100:             remaining_pairs = hash_node.pairs.reject { |p| p == on_upgrade_pair }
// 101:             report_and_correct_useless_metadata(hash_node, on_upgrade_pair, remaining_pairs, comments)
// 102:           elsif invalid_syms.any?
// 103:             report_partially_invalid_metadata(on_upgrade_pair.value, invalid_syms)
// 104:           end
// 105:         end
// 106:
// 107:         sig { params(on_upgrade_pair: AST::PairNode).void }
// 108:         def report_fully_invalid_metadata(on_upgrade_pair)
// 109:           add_offense(on_upgrade_pair.value,
// 110:                       message: "`on_upgrade` value must be :signal or an array [:signal]")
// 111:         end
// 112:
// 113:         sig {
// 114:           params(
// 115:             hash_node:       AST::HashNode,
// 116:             on_upgrade_pair: AST::PairNode,
// 117:             remaining_pairs: T::Array[AST::PairNode],
// 118:             comments:        T::Array[Parser::Source::Comment],
// 119:           ).void
// 120:         }
// 121:         def report_and_correct_useless_metadata(
// 122:           hash_node,
// 123:           on_upgrade_pair,
// 124:           remaining_pairs,
// 125:           comments
// 126:         )
// 127:           if remaining_pairs.empty?
// 128:             # Only on_upgrade is present: report but do not attempt autocorrect
// 129:             # to avoid generating an empty uninstall hash or removing the stanza.
// 130:             add_offense(on_upgrade_pair.key, message: USELESS_METADATA_MSG)
// 131:             return
// 132:           end
// 133:
// 134:           add_offense(on_upgrade_pair.key, message: USELESS_METADATA_MSG) do |corrector|
// 135:             first_pair = remaining_pairs.fetch(0)
// 136:             indentation = " " * (start_column(first_pair.key) - line_start_column(first_pair.key))
// 137:
// 138:             new_code = build_uninstall_body(remaining_pairs, comments, indentation)
// 139:             corrector.replace(hash_node.source_range, new_code)
// 140:           end
// 141:         end
// 142:
// 143:         sig {
// 144:           params(value_node: AST::Node, invalid_syms: T::Array[Symbol]).void
// 145:         }
// 146:         def report_partially_invalid_metadata(value_node, invalid_syms)
// 147:           symbols_str = invalid_syms.map { |s| ":#{s}" }.join(", ")
// 148:           add_offense(value_node,
// 149:                       message: format(PARTIAL_METADATA_MSG, symbols: symbols_str))
// 150:         end
// 151:
// 152:         sig {
// 153:           params(
// 154:             pairs:       T::Array[AST::PairNode],
// 155:             comments:    T::Array[Parser::Source::Comment],
// 156:             indentation: String,
// 157:           ).returns(String)
// 158:         }
// 159:         def build_uninstall_body(pairs, comments, indentation)
// 160:           pairs.map do |pair|
// 161:             source = pair.source
// 162:
// 163:             # Find and attach a comment on the same line as the pair, if any
// 164:             inline_comment = comments.find do |comment|
// 165:               comment.location.line == pair.loc.line &&
// 166:                 comment.location.column > pair.loc.column
// 167:             end
// 168:
// 169:             inline_comment ? "#{source} #{inline_comment.text}" : source
// 170:           end.join(",\n#{indentation}")
// 171:         end
// 172:
// 173:         sig { params(value_node: AST::Node).returns(T::Array[Symbol]) }
// 174:         def on_upgrade_symbols(value_node)
// 175:           if value_node.sym_type?
// 176:             [T.cast(value_node, AST::SymbolNode).value]
// 177:           elsif value_node.array_type?
// 178:             value_node.children.select(&:sym_type?).map do |child|
// 179:               T.cast(child, AST::SymbolNode).value
// 180:             end
// 181:           else
// 182:             []
// 183:           end
// 184:         end
// 185:
// 186:         sig { params(method_node: AST::SymbolNode).returns(Integer) }
// 187:         def method_order_index(method_node)
// 188:           method_name = method_node.children.first
// 189:           RuboCop::Cask::Constants::UNINSTALL_METHODS_ORDER.index(method_name) || -1
// 190:         end
// 191:       end
// 192:     end
// 193:   end
// 194: end
