module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/dependency_order.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 17.
pub fn ruby_dependency_order_l17_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `check_uses_from_macos_nodes_order(parent_node)` at line 32.
pub fn ruby_dependency_order_l32_d2_check_uses_from_macos_nodes_order(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_uses_from_macos_nodes_order', ...args)
}

// Ruby method `check_dependency_nodes_order(parent_node)` at line 40.
pub fn ruby_dependency_order_l40_d3_check_dependency_nodes_order(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_dependency_nodes_order', ...args)
}

// Ruby method `ensure_dependency_order(nodes)` at line 48.
pub fn ruby_dependency_order_l48_d4_ensure_dependency_order(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ensure_dependency_order', ...args)
}

// Ruby method `sort_dependencies_by_type(dependency_nodes)` at line 64.
pub fn ruby_dependency_order_l64_d5_sort_dependencies_by_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sort_dependencies_by_type', ...args)
}

// Ruby method `sort_conditional_dependencies!(ordered)` at line 82.
pub fn ruby_dependency_order_l82_d6_sort_conditional_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sort_conditional_dependencies!', ...args)
}

// Ruby method `verify_order_in_source(ordered)` at line 109.
pub fn ruby_dependency_order_l109_d7_verify_order_in_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('verify_order_in_source', ...args)
}

// Ruby def_node_matcher `def_node_matcher :depends_on_node?, <<~EOS` at line 135.
pub fn ruby_dependency_order_l135_d8_depends_on_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on_node?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :uses_from_macos_node?, <<~EOS` at line 140.
pub fn ruby_dependency_order_l140_d9_uses_from_macos_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses_from_macos_node?', ...args)
}

// Ruby def_node_search `def_node_search :buildtime_dependency?, "(sym :build)"` at line 145.
pub fn ruby_dependency_order_l145_d10_buildtime_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('buildtime_dependency?', ...args)
}

// Ruby def_node_search `def_node_search :recommended_dependency?, "(sym :recommended)"` at line 147.
pub fn ruby_dependency_order_l147_d11_recommended_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recommended_dependency?', ...args)
}

// Ruby def_node_search `def_node_search :test_dependency?, "(sym :test)"` at line 149.
pub fn ruby_dependency_order_l149_d12_test_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test_dependency?', ...args)
}

// Ruby def_node_search `def_node_search :optional_dependency?, "(sym :optional)"` at line 151.
pub fn ruby_dependency_order_l151_d13_optional_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('optional_dependency?', ...args)
}

// Ruby def_node_search `def_node_search :negate_normal_dependency?, "(sym {:build :recommended :test :optional})"` at line 153.
pub fn ruby_dependency_order_l153_d14_negate_normal_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('negate_normal_dependency?', ...args)
}

// Ruby def_node_search `def_node_search :dependency_name_node, <<~EOS` at line 156.
pub fn ruby_dependency_order_l156_d15_dependency_name_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependency_name_node', ...args)
}

// Ruby def_node_search `def_node_search :build_with_dependency_node, <<~EOS` at line 162.
pub fn ruby_dependency_order_l162_d16_build_with_dependency_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_with_dependency_node', ...args)
}

// Ruby method `insert_after!(arr, idx1, idx2)` at line 167.
pub fn ruby_dependency_order_l167_d17_insert_after(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('insert_after!', ...args)
}

// Ruby method `build_with_dependency_name(node)` at line 175.
pub fn ruby_dependency_order_l175_d18_build_with_dependency_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_with_dependency_name', ...args)
}

// Ruby method `dependency_name(dependency_node)` at line 182.
pub fn ruby_dependency_order_l182_d19_dependency_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependency_name', ...args)
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
// 9:       # This cop checks for correct order of `depends_on` in formulae.
// 10:       #
// 11:       # precedence order:
// 12:       # build-time > test > normal > recommended > optional
// 13:       class DependencyOrder < FormulaCop
// 14:         extend AutoCorrector
// 15:
// 16:         sig { override.params(formula_nodes: FormulaNodes).void }
// 17:         def audit_formula(formula_nodes)
// 18:           body_node = formula_nodes.body_node
// 19:
// 20:           check_dependency_nodes_order(body_node)
// 21:           check_uses_from_macos_nodes_order(body_node)
// 22:           ([:head, :stable] + on_system_methods).each do |block_name|
// 23:             block = find_block(body_node, block_name)
// 24:             next unless block
// 25:
// 26:             check_dependency_nodes_order(block.body)
// 27:             check_uses_from_macos_nodes_order(block.body)
// 28:           end
// 29:         end
// 30:
// 31:         sig { params(parent_node: T.nilable(RuboCop::AST::Node)).void }
// 32:         def check_uses_from_macos_nodes_order(parent_node)
// 33:           return if parent_node.nil?
// 34:
// 35:           dependency_nodes = parent_node.each_child_node.select { |x| uses_from_macos_node?(x) }
// 36:           ensure_dependency_order(dependency_nodes)
// 37:         end
// 38:
// 39:         sig { params(parent_node: T.nilable(RuboCop::AST::Node)).void }
// 40:         def check_dependency_nodes_order(parent_node)
// 41:           return if parent_node.nil?
// 42:
// 43:           dependency_nodes = parent_node.each_child_node.select { |x| depends_on_node?(x) }
// 44:           ensure_dependency_order(dependency_nodes)
// 45:         end
// 46:
// 47:         sig { params(nodes: T::Array[RuboCop::AST::Node]).void }
// 48:         def ensure_dependency_order(nodes)
// 49:           name_node_pairs = nodes.filter_map do |node|
// 50:             name = dependency_name(node)
// 51:             next unless name
// 52:
// 53:             [name, node]
// 54:           end
// 55:           name_node_pairs.sort_by! { |name, _| name.downcase }
// 56:           ordered = sort_dependencies_by_type(name_node_pairs.map { |_, node| node })
// 57:           sort_conditional_dependencies!(ordered)
// 58:           verify_order_in_source(ordered)
// 59:         end
// 60:
// 61:         # Separate dependencies according to precedence order:
// 62:         # build-time > test > normal > recommended > optional
// 63:         sig { params(dependency_nodes: T::Array[RuboCop::AST::Node]).returns(T::Array[RuboCop::AST::Node]) }
// 64:         def sort_dependencies_by_type(dependency_nodes)
// 65:           unsorted_deps = dependency_nodes.to_a
// 66:           ordered = []
// 67:           ordered.concat(unsorted_deps.select { |dep| buildtime_dependency? dep })
// 68:           unsorted_deps -= ordered
// 69:           ordered.concat(unsorted_deps.select { |dep| test_dependency? dep })
// 70:           unsorted_deps -= ordered
// 71:           ordered.concat(unsorted_deps.reject { |dep| negate_normal_dependency? dep })
// 72:           unsorted_deps -= ordered
// 73:           ordered.concat(unsorted_deps.select { |dep| recommended_dependency? dep })
// 74:           unsorted_deps -= ordered
// 75:           ordered.concat(unsorted_deps.select { |dep| optional_dependency? dep })
// 76:         end
// 77:
// 78:         # `depends_on :apple if build.with? "foo"` should always be defined
// 79:         #  after `depends_on :foo`.
// 80:         # This method reorders the dependencies array according to the above rule.
// 81:         sig { params(ordered: T::Array[RuboCop::AST::Node]).returns(T::Array[RuboCop::AST::Node]) }
// 82:         def sort_conditional_dependencies!(ordered)
// 83:           length = ordered.size
// 84:           idx = 0
// 85:           while idx < length
// 86:             idx1 = T.let(nil, T.nilable(Integer))
// 87:             idx2 = T.let(nil, T.nilable(Integer))
// 88:             ordered.each_with_index do |dep, pos|
// 89:               idx = pos+1
// 90:               match_nodes = build_with_dependency_name(dep)
// 91:               next if match_nodes.blank?
// 92:
// 93:               idx1 = pos
// 94:               ordered.drop(idx1+1).each_with_index do |dep2, pos2|
// 95:                 next unless match_nodes.index(dependency_name(dep2))
// 96:
// 97:                 idx2 = pos2 if idx2.nil? || pos2 > idx2
// 98:               end
// 99:               break if idx2
// 100:             end
// 101:             insert_after!(ordered, idx1, idx2 + idx1) if idx1 &&idx2
// 102:           end
// 103:           ordered
// 104:         end
// 105:
// 106:         # Verify actual order of sorted `depends_on` nodes in source code;
// 107:         # raise RuboCop problem otherwise.
// 108:         sig { params(ordered: T::Array[RuboCop::AST::Node]).void }
// 109:         def verify_order_in_source(ordered)
// 110:           ordered.each_with_index do |node_1, idx|
// 111:             l1 = line_number(node_1)
// 112:             l2 = T.let(nil, T.nilable(Integer))
// 113:             node_2 = T.let(nil, T.nilable(RuboCop::AST::Node))
// 114:             ordered.drop(idx + 1).each do |test_node|
// 115:               l2 = line_number(test_node)
// 116:               node_2 = test_node if l2 < l1
// 117:             end
// 118:             next unless node_2
// 119:
// 120:             offending_node(node_1)
// 121:
// 122:             problem "`dependency \"#{dependency_name(node_1)}\"` (line #{l1}) should be put before " \
// 123:                     "`dependency \"#{dependency_name(node_2)}\"` (line #{l2})" do |corrector|
// 124:               indentation = " " * (start_column(node_2) - line_start_column(node_2))
// 125:               line_breaks = "\n"
// 126:               corrector.insert_before(node_2.source_range,
// 127:                                       node_1.source + line_breaks + indentation)
// 128:               corrector.remove(range_with_surrounding_space(range: node_1.source_range, side: :left))
// 129:             end
// 130:           end
// 131:         end
// 132:
// 133:         # Node pattern method to match
// 134:         # `depends_on` variants.
// 135:         def_node_matcher :depends_on_node?, <<~EOS
// 136:           {(if _ (send nil? :depends_on ...) nil?)
// 137:            (send nil? :depends_on ...)}
// 138:         EOS
// 139:
// 140:         def_node_matcher :uses_from_macos_node?, <<~EOS
// 141:           {(if _ (send nil? :uses_from_macos ...) nil?)
// 142:            (send nil? :uses_from_macos ...)}
// 143:         EOS
// 144:
// 145:         def_node_search :buildtime_dependency?, "(sym :build)"
// 146:
// 147:         def_node_search :recommended_dependency?, "(sym :recommended)"
// 148:
// 149:         def_node_search :test_dependency?, "(sym :test)"
// 150:
// 151:         def_node_search :optional_dependency?, "(sym :optional)"
// 152:
// 153:         def_node_search :negate_normal_dependency?, "(sym {:build :recommended :test :optional})"
// 154:
// 155:         # Node pattern method to extract `name` in `depends_on :name` or `uses_from_macos :name`
// 156:         def_node_search :dependency_name_node, <<~EOS
// 157:           {(send nil? {:depends_on :uses_from_macos} {(hash (pair $_ _) ...) $({str sym dstr} ...) $(const nil? _)} ...)
// 158:            (if _ (send nil? :depends_on {(hash (pair $_ _)) $({str sym dstr} ...) $(const nil? _)}) nil?)}
// 159:         EOS
// 160:
// 161:         # Node pattern method to extract `name` in `build.with? :name`
// 162:         def_node_search :build_with_dependency_node, <<~EOS
// 163:           (send (send nil? :build) :with? $({str sym} _))
// 164:         EOS
// 165:
// 166:         sig { params(arr: T::Array[RuboCop::AST::Node], idx1: Integer, idx2: Integer).void }
// 167:         def insert_after!(arr, idx1, idx2)
// 168:           arr.insert(
// 169:             idx2+1,
// 170:             arr.delete_at(idx1) || raise("unexpected nil value for arr.delete_at(idx1)"),
// 171:           )
// 172:         end
// 173:
// 174:         sig { params(node: RuboCop::AST::Node).returns(T.nilable(T::Array[String])) }
// 175:         def build_with_dependency_name(node)
// 176:           match_nodes = build_with_dependency_node(node)
// 177:           match_nodes = match_nodes.to_a.compact
// 178:           match_nodes.map { |n| string_content(n) } unless match_nodes.empty?
// 179:         end
// 180:
// 181:         sig { params(dependency_node: RuboCop::AST::Node).returns(T.nilable(String)) }
// 182:         def dependency_name(dependency_node)
// 183:           match_node = dependency_name_node(dependency_node).to_a.first
// 184:           string_content(match_node) if match_node
// 185:         end
// 186:       end
// 187:     end
// 188:   end
// 189: end
