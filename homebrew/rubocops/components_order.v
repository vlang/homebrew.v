module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/components_order.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(config = nil, options = nil)` at line 18.
pub fn ruby_components_order_l18_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 25.
pub fn ruby_components_order_l25_d2_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `check_block_component_order(component_precedence_list, block)` at line 135.
pub fn ruby_components_order_l135_d3_check_block_component_order(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_block_component_order', ...args)
}

// Ruby method `check_on_system_block_content(component_precedence_list, on_system_block)` at line 146.
pub fn ruby_components_order_l146_d4_check_on_system_block_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_on_system_block_content', ...args)
}

// Ruby method `reorder_components(corrector, node1, node2)` at line 194.
pub fn ruby_components_order_l194_d5_reorder_components(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reorder_components', ...args)
}

// Ruby method `get_state(node1)` at line 217.
pub fn ruby_components_order_l217_d6_get_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_state', ...args)
}

// Ruby method `check_order(component_precedence_list, body_node)` at line 230.
pub fn ruby_components_order_l230_d7_check_order(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_order', ...args)
}

// Ruby method `component_problem(component1, component2)` at line 261.
pub fn ruby_components_order_l261_d8_component_problem(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('component_problem', ...args)
}

// Ruby def_node_matcher `def_node_matcher :depends_on_node?, <<~EOS` at line 273.
pub fn ruby_components_order_l273_d9_depends_on_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on_node?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "ast_constants"
// 5: require "rubocops/extend/formula_cop"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # This cop checks for correct order of components in formulae.
// 11:       #
// 12:       # - `component_precedence_list` has component hierarchy in a nested list
// 13:       #   where each sub array contains components' details which are at same precedence level
// 14:       class ComponentsOrder < FormulaCop
// 15:         extend AutoCorrector
// 16:
// 17:         sig { params(config: T.nilable(RuboCop::Config), options: T.nilable(T::Hash[Symbol, T.anything])).void }
// 18:         def initialize(config = nil, options = nil)
// 19:           super
// 20:           @present_components = T.let(nil, T.nilable(T::Array[T::Array[RuboCop::AST::Node]]))
// 21:           @offensive_nodes = T.let(nil, T.nilable(T::Array[RuboCop::AST::Node]))
// 22:         end
// 23:
// 24:         sig { override.params(formula_nodes: FormulaNodes).void }
// 25:         def audit_formula(formula_nodes)
// 26:           return if (body_node = formula_nodes.body_node).nil?
// 27:
// 28:           @present_components, @offensive_nodes = check_order(FORMULA_COMPONENT_PRECEDENCE_LIST, body_node)
// 29:
// 30:           component_problem @offensive_nodes.fetch(0), @offensive_nodes.fetch(1) if @offensive_nodes
// 31:
// 32:           component_precedence_list = [
// 33:             [{ name: :depends_on, type: :method_call }],
// 34:             [{ name: :resource, type: :block_call }],
// 35:             [{ name: :patch, type: :method_call }, { name: :patch, type: :block_call }],
// 36:           ]
// 37:
// 38:           head_blocks = find_blocks(body_node, :head)
// 39:           head_blocks.each do |head_block|
// 40:             check_block_component_order(FORMULA_COMPONENT_PRECEDENCE_LIST, head_block)
// 41:           end
// 42:
// 43:           on_system_methods.each do |on_method|
// 44:             on_method_blocks = find_blocks(body_node, on_method)
// 45:             next if on_method_blocks.empty?
// 46:
// 47:             if on_method_blocks.length > 1
// 48:               @offensive_node = on_method_blocks.second
// 49:               problem "There can only be one `#{on_method}` block in a formula."
// 50:             end
// 51:
// 52:             check_on_system_block_content(component_precedence_list, on_method_blocks.fetch(0))
// 53:           end
// 54:
// 55:           resource_blocks = find_blocks(body_node, :resource)
// 56:           resource_blocks.each do |resource_block|
// 57:             check_block_component_order(FORMULA_COMPONENT_PRECEDENCE_LIST, resource_block)
// 58:
// 59:             on_system_blocks = {}
// 60:
// 61:             on_system_methods.each do |on_method|
// 62:               on_system_blocks[on_method] = find_blocks(resource_block.body, on_method)
// 63:             end
// 64:
// 65:             if on_system_blocks.empty?
// 66:               # Found nothing. Try without .body as depending on the code,
// 67:               # on_{system} might be in .body or not ...
// 68:               on_system_methods.each do |on_method|
// 69:                 on_system_blocks[on_method] = find_blocks(resource_block, on_method)
// 70:               end
// 71:             end
// 72:             next if on_system_blocks.empty?
// 73:
// 74:             @offensive_node = resource_block
// 75:
// 76:             on_system_bodies = T.let([], T::Array[[RuboCop::AST::BlockNode, RuboCop::AST::Node]])
// 77:
// 78:             on_system_blocks.each_value do |blocks|
// 79:               blocks.each do |on_system_block|
// 80:                 on_system_body = on_system_block.body
// 81:                 branches = on_system_body.if_type? ? on_system_body.branches : [on_system_body]
// 82:                 on_system_bodies += branches.map { |branch| [on_system_block, branch] }
// 83:               end
// 84:             end
// 85:
// 86:             message = T.let(nil, T.nilable(String))
// 87:             allowed_methods = [
// 88:               [:url, :sha256],
// 89:               [:url, :mirror, :sha256],
// 90:               [:url, :version, :sha256],
// 91:               [:url, :mirror, :version, :sha256],
// 92:             ]
// 93:             minimum_methods = allowed_methods.first.map { |m| "`#{m}`" }.to_sentence
// 94:             maximum_methods = allowed_methods.last.map { |m| "`#{m}`" }.to_sentence
// 95:
// 96:             on_system_bodies.each do |on_system_block, on_system_body|
// 97:               method_name = on_system_block.method_name
// 98:               child_nodes = on_system_body.begin_type? ? on_system_body.child_nodes : [on_system_body]
// 99:               if child_nodes.all? { |n| n.send_type? || n.block_type? || n.lvasgn_type? }
// 100:                 method_names = child_nodes.filter_map do |node|
// 101:                   next if node.lvasgn_type?
// 102:                   next if node.method_name == :patch
// 103:                   next if on_system_methods.include? node.method_name
// 104:
// 105:                   node.method_name
// 106:                 end
// 107:                 next if method_names.empty? || allowed_methods.include?(method_names)
// 108:               end
// 109:               offending_node(on_system_block)
// 110:               message = "`#{method_name}` blocks within `resource` blocks must contain at least " \
// 111:                         "#{minimum_methods} and at most #{maximum_methods} (in order)."
// 112:               break
// 113:             end
// 114:
// 115:             if message
// 116:               problem message
// 117:               next
// 118:             end
// 119:
// 120:             on_system_blocks.each do |on_method, blocks|
// 121:               if blocks.length > 1
// 122:                 problem "There can only be one `#{on_method}` block in a resource block."
// 123:                 next
// 124:               end
// 125:             end
// 126:           end
// 127:         end
// 128:
// 129:         sig {
// 130:           params(
// 131:             component_precedence_list: T::Array[T::Array[{ name: Symbol, type: Symbol }]],
// 132:             block:                     RuboCop::AST::BlockNode,
// 133:           ).void
// 134:         }
// 135:         def check_block_component_order(component_precedence_list, block)
// 136:           @present_components, offensive_node = check_order(component_precedence_list, block.body)
// 137:           component_problem(*offensive_node) if offensive_node
// 138:         end
// 139:
// 140:         sig {
// 141:           params(
// 142:             component_precedence_list: T::Array[T::Array[{ name: Symbol, type: Symbol }]],
// 143:             on_system_block:           RuboCop::AST::BlockNode,
// 144:           ).void
// 145:         }
// 146:         def check_on_system_block_content(component_precedence_list, on_system_block)
// 147:           if on_system_block.body.block_type? && !on_system_methods.include?(on_system_block.body.method_name) &&
// 148:              on_system_block.body.method_name != :fails_with
// 149:             offending_node(on_system_block)
// 150:             problem "Nest `#{on_system_block.method_name}` blocks inside `#{on_system_block.body.method_name}` " \
// 151:                     "blocks when there is only one inner block." do |corrector|
// 152:               original_source = on_system_block.source.split("\n")
// 153:               new_source = [original_source.second, original_source.first, *original_source.drop(2)]
// 154:               corrector.replace(on_system_block.source_range, new_source.join("\n"))
// 155:             end
// 156:           end
// 157:           on_system_allowed_methods = %w[
// 158:             livecheck
// 159:             keg_only
// 160:             disable!
// 161:             deprecate!
// 162:             depends_on
// 163:             conflicts_with
// 164:             fails_with
// 165:             resource
// 166:             patch
// 167:             pour_bottle?
// 168:           ]
// 169:           on_system_allowed_methods += on_system_methods.map(&:to_s)
// 170:           @present_components, offensive_node = check_order(component_precedence_list, on_system_block.body)
// 171:           component_problem(*offensive_node) if offensive_node
// 172:           child_nodes = on_system_block.body.begin_type? ? on_system_block.body.child_nodes : [on_system_block.body]
// 173:           child_nodes.each do |child|
// 174:             valid_node = depends_on_node?(child)
// 175:             # Check for RuboCop::AST::SendNode and RuboCop::AST::BlockNode instances
// 176:             # only, as we are checking the method_name for `patch`, `resource`, etc.
// 177:             method_type = child.send_type? || child.block_type?
// 178:             next unless method_type
// 179:
// 180:             valid_node ||= on_system_allowed_methods.include? child.method_name.to_s
// 181:
// 182:             @offensive_node = child
// 183:             next if valid_node
// 184:
// 185:             problem "`#{on_system_block.method_name}` cannot include `#{child.method_name}`. " \
// 186:                     "Only #{on_system_allowed_methods.map { |m| "`#{m}`" }.to_sentence} are allowed."
// 187:           end
// 188:         end
// 189:
// 190:         # Reorder two nodes in the source, using the corrector instance in autocorrect method.
// 191:         # Components of same type are grouped together when rewriting the source.
// 192:         # Linebreaks are introduced if components are of two different methods/blocks/multilines.
// 193:         sig { params(corrector: RuboCop::Cop::Corrector, node1: RuboCop::AST::Node, node2: RuboCop::AST::Node).void }
// 194:         def reorder_components(corrector, node1, node2)
// 195:           # order_idx : node1's index in component_precedence_list
// 196:           # curr_p_idx: node1's index in preceding_comp_arr
// 197:           # preceding_comp_arr: array containing components of same type
// 198:           order_idx, curr_p_idx, preceding_comp_arr = get_state(node1)
// 199:
// 200:           # curr_p_idx.positive? means node1 needs to be grouped with its own kind
// 201:           if curr_p_idx.positive?
// 202:             node2 = preceding_comp_arr.fetch(curr_p_idx - 1)
// 203:             indentation = " " * (start_column(node2) - line_start_column(node2))
// 204:             line_breaks = node2.multiline? ? "\n\n" : "\n"
// 205:             corrector.insert_after(node2.source_range, line_breaks + indentation + node1.source)
// 206:           else
// 207:             indentation = " " * (start_column(node2) - line_start_column(node2))
// 208:             # No line breaks up to version_scheme, order_idx == 8
// 209:             line_breaks = (order_idx > 8) ? "\n\n" : "\n"
// 210:             corrector.insert_before(node2.source_range, node1.source + line_breaks + indentation)
// 211:           end
// 212:           corrector.remove(range_with_surrounding_space(range: node1.source_range, side: :left))
// 213:         end
// 214:
// 215:         # Returns precedence index and component's index to properly reorder and group during autocorrect.
// 216:         sig { params(node1: RuboCop::AST::Node).returns([Integer, Integer, T::Array[RuboCop::AST::Node]]) }
// 217:         def get_state(node1)
// 218:           T.must(@present_components).each_with_index do |comp, idx|
// 219:             return [idx, T.must(comp.index(node1)), comp] if comp.member?(node1)
// 220:           end
// 221:           raise "Could not find node1 in present_components"
// 222:         end
// 223:
// 224:         sig {
// 225:           params(
// 226:             component_precedence_list: T::Array[T::Array[{ name: Symbol, type: Symbol }]],
// 227:             body_node:                 RuboCop::AST::Node,
// 228:           ).returns(T.nilable([T::Array[T::Array[RuboCop::AST::Node]], T::Array[RuboCop::AST::Node]]))
// 229:         }
// 230:         def check_order(component_precedence_list, body_node)
// 231:           present_components = component_precedence_list.map do |components|
// 232:             components.flat_map do |component|
// 233:               case component[:type]
// 234:               when :method_call
// 235:                 find_method_calls_by_name(body_node, component[:name]).to_a
// 236:               when :block_call
// 237:                 find_blocks(body_node, component[:name]).to_a
// 238:               when :method_definition
// 239:                 find_method_def(body_node, component[:name])
// 240:               end
// 241:             end.compact
// 242:           end
// 243:
// 244:           # Check if each present_components is above rest of the present_components
// 245:           offensive_nodes = T.let(nil, T.nilable(T::Array[RuboCop::AST::Node]))
// 246:           present_components.take(present_components.size - 1).each_with_index do |preceding_component, p_idx|
// 247:             next if preceding_component.empty?
// 248:
// 249:             present_components.drop(p_idx + 1).each do |succeeding_component|
// 250:               next if succeeding_component.empty?
// 251:
// 252:               offensive_nodes = check_precedence(preceding_component, succeeding_component)
// 253:               return [present_components, offensive_nodes] if offensive_nodes
// 254:             end
// 255:           end
// 256:           nil
// 257:         end
// 258:
// 259:         # Method to report and correct component precedence violations.
// 260:         sig { params(component1: RuboCop::AST::Node, component2: RuboCop::AST::Node).void }
// 261:         def component_problem(component1, component2)
// 262:           return if tap_style_exception? :components_order_exceptions
// 263:
// 264:           problem "`#{format_component(component1)}` (line #{line_number(component1)}) " \
// 265:                   "should be put before `#{format_component(component2)}` " \
// 266:                   "(line #{line_number(component2)})" do |corrector|
// 267:             reorder_components(corrector, component1, component2)
// 268:           end
// 269:         end
// 270:
// 271:         # Node pattern method to match
// 272:         # `depends_on` variants.
// 273:         def_node_matcher :depends_on_node?, <<~EOS
// 274:           {(if _ (send nil? :depends_on ...) nil?)
// 275:            (send nil? :depends_on ...)}
// 276:         EOS
// 277:       end
// 278:     end
// 279:   end
// 280: end
