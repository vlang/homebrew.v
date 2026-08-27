module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/on_system_conditionals.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask(cask_block)` at line 38.
pub fn ruby_on_system_conditionals_l38_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask', ...args)
}

// Ruby attr_reader `attr_reader :cask_block` at line 57.
pub fn ruby_on_system_conditionals_l57_d2_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_block', ...args)
}

// Ruby def_delegators `def_delegators :cask_block, :toplevel_stanzas, :cask_body` at line 59.
pub fn ruby_on_system_conditionals_l59_d3_toplevel_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('toplevel_stanzas', ...args)
}

// Ruby def_delegators `def_delegators :cask_block, :toplevel_stanzas, :cask_body` at line 59.
pub fn ruby_on_system_conditionals_l59_d4_cask_body(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_body', ...args)
}

// Ruby method `simplify_sha256_stanzas` at line 62.
pub fn ruby_on_system_conditionals_l62_d5_simplify_sha256_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('simplify_sha256_stanzas', ...args)
}

// Ruby method `simplify_arch_version_stanzas` at line 89.
pub fn ruby_on_system_conditionals_l89_d6_simplify_arch_version_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('simplify_arch_version_stanzas', ...args)
}

// Ruby method `comments_in_node_ranges?(*nodes)` at line 138.
pub fn ruby_on_system_conditionals_l138_d7_comments_in_node_ranges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('comments_in_node_ranges?', ...args)
}

// Ruby method `audit_identical_sha256_across_architectures` at line 150.
pub fn ruby_on_system_conditionals_l150_d8_audit_identical_sha256_across_architectures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_identical_sha256_across_architectures', ...args)
}

// Ruby def_node_search `def_node_search :sha256_on_arch_stanzas, <<~PATTERN` at line 186.
pub fn ruby_on_system_conditionals_l186_d9_sha256_on_arch_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sha256_on_arch_stanzas', ...args)
}

// Ruby def_node_search `def_node_search :version_and_sha256_on_arch_stanzas, <<~PATTERN` at line 194.
pub fn ruby_on_system_conditionals_l194_d10_version_and_sha256_on_arch_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version_and_sha256_on_arch_stanzas', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5: require "rubocops/shared/on_system_conditionals_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module Cask
// 10:       # This cop makes sure that OS conditionals are consistent.
// 11:       #
// 12:       # ### Example
// 13:       #
// 14:       # ```ruby
// 15:       # # bad
// 16:       # cask 'foo' do
// 17:       #   if MacOS.version == :tahoe
// 18:       #     sha256 "..."
// 19:       #   end
// 20:       # end
// 21:       #
// 22:       # # good
// 23:       # cask 'foo' do
// 24:       #   on_tahoe do
// 25:       #     sha256 "..."
// 26:       #   end
// 27:       # end
// 28:       # ```
// 29:       class OnSystemConditionals < Base
// 30:         extend Forwardable
// 31:         extend AutoCorrector
// 32:         include OnSystemConditionalsHelper
// 33:         include CaskHelp
// 34:
// 35:         FLIGHT_STANZA_NAMES = [:preflight, :postflight, :uninstall_preflight, :uninstall_postflight].freeze
// 36:
// 37:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 38:         def on_cask(cask_block)
// 39:           @cask_block = T.let(cask_block, T.nilable(RuboCop::Cask::AST::CaskBlock))
// 40:
// 41:           toplevel_stanzas.each do |stanza|
// 42:             next unless FLIGHT_STANZA_NAMES.include? stanza.stanza_name
// 43:
// 44:             audit_on_system_blocks(stanza.stanza_node, stanza.stanza_name)
// 45:           end
// 46:
// 47:           audit_arch_conditionals(cask_body, allowed_blocks: FLIGHT_STANZA_NAMES)
// 48:           audit_macos_version_conditionals(cask_body, recommend_on_system: false, allowed_blocks: FLIGHT_STANZA_NAMES)
// 49:           simplify_sha256_stanzas
// 50:           simplify_arch_version_stanzas
// 51:           audit_identical_sha256_across_architectures
// 52:         end
// 53:
// 54:         private
// 55:
// 56:         sig { returns(T.nilable(RuboCop::Cask::AST::CaskBlock)) }
// 57:         attr_reader :cask_block
// 58:
// 59:         def_delegators :cask_block, :toplevel_stanzas, :cask_body
// 60:
// 61:         sig { void }
// 62:         def simplify_sha256_stanzas
// 63:           grouped_nodes = Hash.new { |hash, key| hash[key] = {} }
// 64:
// 65:           sha256_on_arch_stanzas(cask_body) do |node, method, value|
// 66:             arch = method.to_s.delete_prefix("on_").to_sym
// 67:             ast_node = T.cast(node, RuboCop::AST::Node)
// 68:             grouped_nodes[ast_node.parent][arch] = { node: ast_node, value: }
// 69:           end
// 70:
// 71:           grouped_nodes.each_value do |nodes|
// 72:             next if !nodes.key?(:arm) || !nodes.key?(:intel)
// 73:
// 74:             offending_node(nodes[:arm][:node])
// 75:             replacement_string = "sha256 arm: #{nodes[:arm][:value].inspect}, intel: #{nodes[:intel][:value].inspect}"
// 76:             if comments_in_node_ranges?(nodes[:arm][:node], nodes[:intel][:node])
// 77:               problem "Don't nest only the `sha256` stanzas in `on_intel` and `on_arm` blocks"
// 78:               next
// 79:             end
// 80:
// 81:             problem "Don't nest only the `sha256` stanzas in `on_intel` and `on_arm` blocks" do |corrector|
// 82:               corrector.replace(nodes[:arm][:node].source_range, replacement_string)
// 83:               corrector.remove(range_by_whole_lines(nodes[:intel][:node].source_range, include_final_newline: true))
// 84:             end
// 85:           end
// 86:         end
// 87:
// 88:         sig { void }
// 89:         def simplify_arch_version_stanzas
// 90:           grouped_nodes = Hash.new { |hash, key| hash[key] = {} }
// 91:
// 92:           version_and_sha256_on_arch_stanzas(cask_body) do |block_node, arch_method, version_value, sha256_value|
// 93:             arch = arch_method.to_s.delete_prefix("on_").to_sym
// 94:             ast_block_node = T.cast(block_node, RuboCop::AST::Node)
// 95:             grouped_nodes[ast_block_node.parent][arch] = {
// 96:               node:          ast_block_node,
// 97:               version_value:,
// 98:               sha256_value:,
// 99:             }
// 100:           end
// 101:
// 102:           grouped_nodes.each_value do |nodes|
// 103:             next if !nodes.key?(:arm) || !nodes.key?(:intel)
// 104:
// 105:             arm_version = nodes[:arm][:version_value]
// 106:             intel_version = nodes[:intel][:version_value]
// 107:
// 108:             next if arm_version != intel_version
// 109:
// 110:             arm_sha = nodes[:arm][:sha256_value]
// 111:             intel_sha = nodes[:intel][:sha256_value]
// 112:             arm_node = nodes[:arm][:node]
// 113:             intel_node = nodes[:intel][:node]
// 114:
// 115:             indent = " " * arm_node.loc.column
// 116:             version_str = "version #{arm_version.inspect}"
// 117:             sha256_str = if arm_sha == intel_sha
// 118:               "sha256 #{arm_sha.inspect}"
// 119:             else
// 120:               "sha256 arm: #{arm_sha.inspect}, intel: #{intel_sha.inspect}"
// 121:             end
// 122:             replacement = "#{version_str}\n#{indent}#{sha256_str}"
// 123:
// 124:             offending_node(arm_node)
// 125:             if comments_in_node_ranges?(arm_node, intel_node)
// 126:               problem "Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks"
// 127:               next
// 128:             end
// 129:
// 130:             problem "Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks" do |corrector|
// 131:               corrector.replace(arm_node.source_range, replacement)
// 132:               corrector.remove(range_by_whole_lines(intel_node.source_range, include_final_newline: true))
// 133:             end
// 134:           end
// 135:         end
// 136:
// 137:         sig { params(nodes: RuboCop::AST::Node).returns(T::Boolean) }
// 138:         def comments_in_node_ranges?(*nodes)
// 139:           processed_source.comments.any? do |comment|
// 140:             comment_range = comment.loc.expression
// 141:
// 142:             nodes.any? do |node|
// 143:               node_range = node.source_range
// 144:               node_range.begin_pos <= comment_range.begin_pos && comment_range.end_pos <= node_range.end_pos
// 145:             end
// 146:           end
// 147:         end
// 148:
// 149:         sig { void }
// 150:         def audit_identical_sha256_across_architectures
// 151:           sha256_stanzas = toplevel_stanzas.select { |stanza| stanza.stanza_name == :sha256 }
// 152:
// 153:           sha256_stanzas.each do |stanza|
// 154:             sha256_node = stanza.stanza_node
// 155:             next if sha256_node.arguments.count != 1
// 156:             next unless sha256_node.arguments.first.hash_type?
// 157:
// 158:             hash_node = sha256_node.arguments.first
// 159:             arm_sha = T.let(nil, T.nilable(String))
// 160:             intel_sha = T.let(nil, T.nilable(String))
// 161:
// 162:             hash_node.pairs.each do |pair|
// 163:               key = pair.key
// 164:               next unless key.sym_type?
// 165:
// 166:               value = pair.value
// 167:               next unless value.str_type?
// 168:
// 169:               case key.value
// 170:               when :arm
// 171:                 arm_sha = value.value
// 172:               when :intel
// 173:                 intel_sha = value.value
// 174:               end
// 175:             end
// 176:
// 177:             next unless arm_sha
// 178:             next unless intel_sha
// 179:             next if arm_sha != intel_sha
// 180:
// 181:             offending_node(sha256_node)
// 182:             problem "sha256 values for different architectures should not be identical."
// 183:           end
// 184:         end
// 185:
// 186:         def_node_search :sha256_on_arch_stanzas, <<~PATTERN
// 187:           $(block
// 188:             (send nil? ${:on_intel :on_arm})
// 189:             (args)
// 190:             (send nil? :sha256
// 191:               (str $_)))
// 192:         PATTERN
// 193:
// 194:         def_node_search :version_and_sha256_on_arch_stanzas, <<~PATTERN
// 195:           $(block
// 196:             (send nil? ${:on_intel :on_arm})
// 197:             (args)
// 198:             (begin
// 199:               (send nil? :version (str $_))
// 200:               (send nil? :sha256 (str $_))))
// 201:         PATTERN
// 202:       end
// 203:     end
// 204:   end
// 205: end
