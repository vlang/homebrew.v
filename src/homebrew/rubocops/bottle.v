module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/bottle.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 14.
pub fn ruby_bottle_l14_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 60.
pub fn ruby_bottle_l60_d2_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 95.
pub fn ruby_bottle_l95_d3_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 130.
pub fn ruby_bottle_l130_d4_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `sha256_order(nodes)` at line 187.
pub fn ruby_bottle_l187_d5_sha256_order(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sha256_order', ...args)
}

// Ruby method `sha256_bottle_tag(node)` at line 194.
pub fn ruby_bottle_l194_d6_sha256_bottle_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sha256_bottle_tag', ...args)
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
// 9:       # This cop audits the `bottle` block in formulae.
// 10:       class BottleFormat < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         sig { override.params(formula_nodes: FormulaNodes).void }
// 14:         def audit_formula(formula_nodes)
// 15:           bottle_node = find_block(formula_nodes.body_node, :bottle)
// 16:           return if bottle_node.nil?
// 17:
// 18:           sha256_nodes = find_method_calls_by_name(bottle_node.body, :sha256)
// 19:           cellar_node = find_node_method_by_name(bottle_node.body, :cellar)
// 20:           cellar_source = T.cast(cellar_node, T.nilable(RuboCop::AST::SendNode))&.first_argument&.source
// 21:
// 22:           if sha256_nodes.present? && cellar_node.present?
// 23:             offending_node(cellar_node)
// 24:             problem "`cellar` should be a parameter to `sha256`" do |corrector|
// 25:               corrector.remove(range_by_whole_lines(cellar_node.source_range, include_final_newline: true))
// 26:             end
// 27:           end
// 28:
// 29:           sha256_nodes.each do |sha256_node|
// 30:             sha256_hash = sha256_node.last_argument
// 31:             sha256_pairs = sha256_hash.pairs
// 32:             next if sha256_pairs.count != 1
// 33:
// 34:             sha256_pair = sha256_pairs.first
// 35:             sha256_key = sha256_pair.key
// 36:             sha256_value = sha256_pair.value
// 37:             next unless sha256_value.sym_type?
// 38:
// 39:             tag = sha256_value.value
// 40:             digest_source = sha256_key.source
// 41:             sha256_line = if cellar_source.present?
// 42:               "sha256 cellar: #{cellar_source}, #{tag}: #{digest_source}"
// 43:             else
// 44:               "sha256 #{tag}: #{digest_source}"
// 45:             end
// 46:
// 47:             offending_node(sha256_node)
// 48:             problem "`sha256` should use new syntax" do |corrector|
// 49:               corrector.replace(sha256_node.source_range, sha256_line)
// 50:             end
// 51:           end
// 52:         end
// 53:       end
// 54:
// 55:       # This cop audits the indentation of the bottle tags in the `bottle` block in formulae.
// 56:       class BottleTagIndentation < FormulaCop
// 57:         extend AutoCorrector
// 58:
// 59:         sig { override.params(formula_nodes: FormulaNodes).void }
// 60:         def audit_formula(formula_nodes)
// 61:           bottle_node = find_block(formula_nodes.body_node, :bottle)
// 62:           return if bottle_node.nil?
// 63:
// 64:           sha256_nodes = find_method_calls_by_name(bottle_node.body, :sha256)
// 65:
// 66:           max_tag_column = 0
// 67:           sha256_nodes.each do |sha256_node|
// 68:             sha256_hash = sha256_node.last_argument
// 69:             tag_column = T.let(sha256_hash.pairs.last.source_range.column, Integer)
// 70:
// 71:             max_tag_column = tag_column if tag_column > max_tag_column
// 72:           end
// 73:           # This must be in a separate loop to make sure max_tag_column is truly the maximum
// 74:           sha256_nodes.each do |sha256_node| # rubocop:disable Style/CombinableLoops
// 75:             sha256_hash = sha256_node.last_argument
// 76:             hash = sha256_hash.pairs.last
// 77:             tag_column = hash.source_range.column
// 78:
// 79:             next if tag_column == max_tag_column
// 80:
// 81:             offending_node(hash)
// 82:             problem "Align bottle tags" do |corrector|
// 83:               new_line = (" " * (max_tag_column - tag_column)) + hash.source
// 84:               corrector.replace(hash.source_range, new_line)
// 85:             end
// 86:           end
// 87:         end
// 88:       end
// 89:
// 90:       # This cop audits the indentation of the sha256 digests in the`bottle` block in formulae.
// 91:       class BottleDigestIndentation < FormulaCop
// 92:         extend AutoCorrector
// 93:
// 94:         sig { override.params(formula_nodes: FormulaNodes).void }
// 95:         def audit_formula(formula_nodes)
// 96:           bottle_node = find_block(formula_nodes.body_node, :bottle)
// 97:           return if bottle_node.nil?
// 98:
// 99:           sha256_nodes = find_method_calls_by_name(bottle_node.body, :sha256)
// 100:
// 101:           max_digest_column = 0
// 102:           sha256_nodes.each do |sha256_node|
// 103:             sha256_hash = sha256_node.last_argument
// 104:             digest_column = T.let(sha256_hash.pairs.last.value.source_range.column, Integer)
// 105:
// 106:             max_digest_column = digest_column if digest_column > max_digest_column
// 107:           end
// 108:           # This must be in a separate loop to make sure max_digest_column is truly the maximum
// 109:           sha256_nodes.each do |sha256_node| # rubocop:disable Style/CombinableLoops
// 110:             sha256_hash = sha256_node.last_argument
// 111:             hash = sha256_hash.pairs.last.value
// 112:             digest_column = hash.source_range.column
// 113:
// 114:             next if digest_column == max_digest_column
// 115:
// 116:             offending_node(hash)
// 117:             problem "Align bottle digests" do |corrector|
// 118:               new_line = (" " * (max_digest_column - digest_column)) + hash.source
// 119:               corrector.replace(hash.source_range, new_line)
// 120:             end
// 121:           end
// 122:         end
// 123:       end
// 124:
// 125:       # This cop audits the order of the `bottle` block in formulae.
// 126:       class BottleOrder < FormulaCop
// 127:         extend AutoCorrector
// 128:
// 129:         sig { override.params(formula_nodes: FormulaNodes).void }
// 130:         def audit_formula(formula_nodes)
// 131:           bottle_node = find_block(formula_nodes.body_node, :bottle)
// 132:           return if bottle_node.nil?
// 133:           return if bottle_node.child_nodes.blank?
// 134:
// 135:           non_sha256_nodes = []
// 136:           sha256_nodes = []
// 137:
// 138:           bottle_block_method_calls = if bottle_node.child_nodes.last.begin_type?
// 139:             bottle_node.child_nodes.last.child_nodes
// 140:           else
// 141:             [bottle_node.child_nodes.last]
// 142:           end
// 143:
// 144:           bottle_block_method_calls.each do |node|
// 145:             if node.method_name == :sha256
// 146:               sha256_nodes << node
// 147:             else
// 148:               non_sha256_nodes << node
// 149:             end
// 150:           end
// 151:
// 152:           arm64_macos_nodes = []
// 153:           intel_macos_nodes = []
// 154:           arm64_linux_nodes = []
// 155:           intel_linux_nodes = []
// 156:
// 157:           sha256_nodes.each do |node|
// 158:             version = sha256_bottle_tag node
// 159:             if version == :arm64_linux
// 160:               arm64_linux_nodes << node
// 161:             elsif version.to_s.start_with?("arm64")
// 162:               arm64_macos_nodes << node
// 163:             elsif version.to_s.end_with?("_linux")
// 164:               intel_linux_nodes << node
// 165:             else
// 166:               intel_macos_nodes << node
// 167:             end
// 168:           end
// 169:
// 170:           sorted_nodes = arm64_macos_nodes + intel_macos_nodes + arm64_linux_nodes + intel_linux_nodes
// 171:           return if sha256_order(sha256_nodes) == sha256_order(sorted_nodes)
// 172:
// 173:           offending_node(bottle_node)
// 174:           problem "ARM bottles should be listed before Intel bottles" do |corrector|
// 175:             lines = ["bottle do"]
// 176:             lines += non_sha256_nodes.map { |node| "    #{node.source}" }
// 177:             lines += arm64_macos_nodes.map { |node| "    #{node.source}" }
// 178:             lines += intel_macos_nodes.map { |node| "    #{node.source}" }
// 179:             lines += arm64_linux_nodes.map { |node| "    #{node.source}" }
// 180:             lines += intel_linux_nodes.map { |node| "    #{node.source}" }
// 181:             lines << "  end"
// 182:             corrector.replace(bottle_node.source_range, lines.join("\n"))
// 183:           end
// 184:         end
// 185:
// 186:         sig { params(nodes: T::Array[RuboCop::AST::SendNode]).returns(T::Array[T.any(String, Symbol)]) }
// 187:         def sha256_order(nodes)
// 188:           nodes.map do |node|
// 189:             sha256_bottle_tag node
// 190:           end
// 191:         end
// 192:
// 193:         sig { params(node: AST::SendNode).returns(T.any(String, Symbol)) }
// 194:         def sha256_bottle_tag(node)
// 195:           hash_pair = node.last_argument.pairs.last
// 196:           if hash_pair.key.sym_type?
// 197:             hash_pair.key.value
// 198:           else
// 199:             hash_pair.value.value
// 200:           end
// 201:         end
// 202:       end
// 203:     end
// 204:   end
// 205: end
