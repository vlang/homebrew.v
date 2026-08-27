module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/os_depends_on.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_block(node)` at line 41.
pub fn ruby_os_depends_on_l41_d1_on_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_block', ...args)
}

// Ruby method `on_send(node)` at line 51.
pub fn ruby_os_depends_on_l51_d2_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `autocorrect_macos_comparison_strings(node)` at line 60.
pub fn ruby_os_depends_on_l60_d3_autocorrect_macos_comparison_strings(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrect_macos_comparison_strings', ...args)
}

// Ruby method `check_redundant_bare_macos(node)` at line 78.
pub fn ruby_os_depends_on_l78_d4_check_redundant_bare_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_redundant_bare_macos', ...args)
}

// Ruby method `check_conflicting_os_requirements(node)` at line 91.
pub fn ruby_os_depends_on_l91_d5_check_conflicting_os_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_conflicting_os_requirements', ...args)
}

// Ruby method `add_missing_os_dependency(node, os)` at line 107.
pub fn ruby_os_depends_on_l107_d6_add_missing_os_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_missing_os_dependency', ...args)
}

// Ruby method `os_only_stanza?(stanza, os)` at line 159.
pub fn ruby_os_depends_on_l159_d7_os_only_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_only_stanza?', ...args)
}

// Ruby method `cross_platform_cask?(top_level_stanzas, stanzas, os)` at line 178.
pub fn ruby_os_depends_on_l178_d8_cross_platform_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cross_platform_cask?', ...args)
}

// Ruby method `direct_stanzas(node)` at line 189.
pub fn ruby_os_depends_on_l189_d9_direct_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('direct_stanzas', ...args)
}

// Ruby method `platform_block_stanzas(stanza)` at line 200.
pub fn ruby_os_depends_on_l200_d10_platform_block_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('platform_block_stanzas', ...args)
}

// Ruby method `full_stanza_source_range(stanza)` at line 212.
pub fn ruby_os_depends_on_l212_d11_full_stanza_source_range(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_stanza_source_range', ...args)
}

// Ruby method `depends_on_pairs(node)` at line 220.
pub fn ruby_os_depends_on_l220_d12_depends_on_pairs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on_pairs', ...args)
}

// Ruby method `symbol_key(pair)` at line 229.
pub fn ruby_os_depends_on_l229_d13_symbol_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symbol_key', ...args)
}

// Ruby method `sibling_depends_on_pairs(node)` at line 237.
pub fn ruby_os_depends_on_l237_d14_sibling_depends_on_pairs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sibling_depends_on_pairs', ...args)
}

// Ruby method `sibling_depends_on_calls(node)` at line 242.
pub fn ruby_os_depends_on_l242_d15_sibling_depends_on_calls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sibling_depends_on_calls', ...args)
}

// Ruby method `os_depends_on?(node)` at line 249.
pub fn ruby_os_depends_on_l249_d16_os_depends_on(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_depends_on?', ...args)
}

// Ruby method `bare_os_depends_on?(node, os)` at line 260.
pub fn ruby_os_depends_on_l260_d17_bare_os_depends_on(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bare_os_depends_on?', ...args)
}

// Ruby method `top_level_macos_depends_on?(node)` at line 265.
pub fn ruby_os_depends_on_l265_d18_top_level_macos_depends_on(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('top_level_macos_depends_on?', ...args)
}

// Ruby method `top_level_linux_depends_on?(node)` at line 270.
pub fn ruby_os_depends_on_l270_d19_top_level_linux_depends_on(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('top_level_linux_depends_on?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/cask/constants/stanza"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Homebrew
// 9:       class OSDependsOn < Base
// 10:         extend AutoCorrector
// 11:         include RangeHelp
// 12:
// 13:         MACOS_ONLY_CASK_STANZAS = [
// 14:           :app,
// 15:           :audio_unit_plugin,
// 16:           :colorpicker,
// 17:           :dictionary,
// 18:           :input_method,
// 19:           :internet_plugin,
// 20:           :keyboard_layout,
// 21:           :mdimporter,
// 22:           :pkg,
// 23:           :prefpane,
// 24:           :qlplugin,
// 25:           :screen_saver,
// 26:           :service,
// 27:           :suite,
// 28:           :vst_plugin,
// 29:           :vst3_plugin,
// 30:         ].freeze
// 31:         LINUX_ONLY_CASK_STANZAS = [:app_image].freeze
// 32:         PLATFORM_BLOCKS = [:on_arm, :on_intel, :on_system].freeze
// 33:
// 34:         CASK_STANZA_ORDER = T.let(RuboCop::Cask::Constants::STANZA_ORDER, T::Array[Symbol])
// 35:         MACOS_DEPENDENCY_STANZAS = [:macos, :maximum_macos].freeze
// 36:         LINUX_DEPENDENCY_STANZAS = [:linux].freeze
// 37:
// 38:         RESTRICT_ON_SEND = [:depends_on].freeze
// 39:
// 40:         sig { params(node: RuboCop::AST::BlockNode).void }
// 41:         def on_block(node)
// 42:           send_node = node.children.first
// 43:           return unless send_node.is_a?(RuboCop::AST::SendNode)
// 44:           return if send_node.method_name != :cask
// 45:
// 46:           add_missing_os_dependency(node, :macos)
// 47:           add_missing_os_dependency(node, :linux)
// 48:         end
// 49:
// 50:         sig { params(node: RuboCop::AST::SendNode).void }
// 51:         def on_send(node)
// 52:           autocorrect_macos_comparison_strings(node)
// 53:           check_redundant_bare_macos(node)
// 54:           check_conflicting_os_requirements(node)
// 55:         end
// 56:
// 57:         private
// 58:
// 59:         sig { params(node: RuboCop::AST::SendNode).void }
// 60:         def autocorrect_macos_comparison_strings(node)
// 61:           depends_on_pairs(node).each do |pair|
// 62:             key = symbol_key(pair)
// 63:             next unless MACOS_DEPENDENCY_STANZAS.include?(key)
// 64:             next unless pair.value.str_type?
// 65:
// 66:             match = pair.value.value.match(/\A\s*(?<comparator>>=|<=)\s*:(?<version>\S+)\s*\z/)
// 67:             next unless match
// 68:
// 69:             replacement_key = (match[:comparator] == "<=") ? :maximum_macos : :macos
// 70:             message = "Use `depends_on #{replacement_key}: :#{match[:version]}`."
// 71:             add_offense(pair.value.source_range, message:) do |corrector|
// 72:               corrector.replace(pair.source_range, "#{replacement_key}: :#{match[:version]}")
// 73:             end
// 74:           end
// 75:         end
// 76:
// 77:         sig { params(node: RuboCop::AST::SendNode).void }
// 78:         def check_redundant_bare_macos(node)
// 79:           return unless bare_os_depends_on?(node, :macos)
// 80:           return unless sibling_depends_on_pairs(node).any? do |pair|
// 81:             MACOS_DEPENDENCY_STANZAS.include?(symbol_key(pair))
// 82:           end
// 83:
// 84:           message = "Remove redundant `depends_on :macos`."
// 85:           add_offense(node.source_range, message:) do |corrector|
// 86:             corrector.remove(range_by_whole_lines(node.source_range, include_final_newline: true))
// 87:           end
// 88:         end
// 89:
// 90:         sig { params(node: RuboCop::AST::SendNode).void }
// 91:         def check_conflicting_os_requirements(node)
// 92:           return if !bare_os_depends_on?(node, :linux) && !top_level_macos_depends_on?(node)
// 93:           return unless sibling_depends_on_calls(node).any? do |sibling|
// 94:             next false if sibling == node
// 95:
// 96:             if bare_os_depends_on?(node, :linux)
// 97:               bare_os_depends_on?(sibling, :macos) || top_level_macos_depends_on?(sibling)
// 98:             else
// 99:               bare_os_depends_on?(sibling, :linux)
// 100:             end
// 101:           end
// 102:
// 103:           add_offense(node.source_range, message: "`depends_on` cannot be macOS-only and Linux-only.")
// 104:         end
// 105:
// 106:         sig { params(node: RuboCop::AST::BlockNode, os: Symbol).void }
// 107:         def add_missing_os_dependency(node, os)
// 108:           body = node.body
// 109:           return unless body
// 110:
// 111:           top_level_stanzas = direct_stanzas(body)
// 112:           stanzas = top_level_stanzas.flat_map { |stanza| [stanza, *platform_block_stanzas(stanza)] }
// 113:           return if os_depends_on?(body)
// 114:
// 115:           os_stanza = stanzas.find { |stanza| os_only_stanza?(stanza, os) }
// 116:           return unless os_stanza
// 117:
// 118:           os_name = (os == :macos) ? "macOS" : "Linux"
// 119:           if cross_platform_cask?(top_level_stanzas, stanzas, os)
// 120:             add_offense(
// 121:               os_stanza.source_range,
// 122:               message: "Move this #{os_name}-only stanza into an `on_#{os}` block for cross-platform casks.",
// 123:             )
// 124:             return
// 125:           end
// 126:
// 127:           add_offense(os_stanza.source_range,
// 128:                       message: "Add `depends_on :#{os}` for #{os_name}-only casks.") do |corrector|
// 129:             depends_on_stanza_index = CASK_STANZA_ORDER.index(:depends_on) ||
// 130:                                       raise("unexpected nil value for depends_on stanza index")
// 131:             following_stanza = top_level_stanzas.find do |stanza|
// 132:               stanza_index = CASK_STANZA_ORDER.index(stanza.method_name)
// 133:               stanza_index && stanza_index > depends_on_stanza_index
// 134:             end
// 135:
// 136:             if following_stanza
// 137:               corrector.insert_before(
// 138:                 range_by_whole_lines(following_stanza.source_range, include_final_newline: false),
// 139:                 "  depends_on :#{os}\n\n",
// 140:               )
// 141:             elsif (preceding_stanza = top_level_stanzas.rfind do |stanza|
// 142:               stanza_index = CASK_STANZA_ORDER.index(stanza.method_name)
// 143:               stanza_index && stanza_index <= depends_on_stanza_index
// 144:             end)
// 145:               corrector.insert_after(
// 146:                 range_by_whole_lines(full_stanza_source_range(preceding_stanza), include_final_newline: true),
// 147:                 "\n  depends_on :#{os}\n",
// 148:               )
// 149:             else
// 150:               corrector.insert_before(
// 151:                 range_by_whole_lines(os_stanza.source_range, include_final_newline: false),
// 152:                 "  depends_on :#{os}\n\n",
// 153:               )
// 154:             end
// 155:           end
// 156:         end
// 157:
// 158:         sig { params(stanza: RuboCop::AST::SendNode, os: Symbol).returns(T::Boolean) }
// 159:         def os_only_stanza?(stanza, os)
// 160:           if os == :macos
// 161:             return MACOS_ONLY_CASK_STANZAS.include?(stanza.method_name) if stanza.method_name != :installer
// 162:
// 163:             stanza.arguments.any? do |argument|
// 164:               argument.hash_type? && argument.pairs.any? { |pair| symbol_key(pair) == :manual }
// 165:             end
// 166:           else
// 167:             LINUX_ONLY_CASK_STANZAS.include?(stanza.method_name)
// 168:           end
// 169:         end
// 170:
// 171:         sig {
// 172:           params(
// 173:             top_level_stanzas: T::Array[RuboCop::AST::SendNode],
// 174:             stanzas:           T::Array[RuboCop::AST::SendNode],
// 175:             os:                Symbol,
// 176:           ).returns(T::Boolean)
// 177:         }
// 178:         def cross_platform_cask?(top_level_stanzas, stanzas, os)
// 179:           other_os = (os == :macos) ? :linux : :macos
// 180:           other_os_block = (other_os == :macos) ? :on_macos : :on_linux
// 181:
// 182:           # `on_system` always spans both operating systems, so it can never imply a bare OS dependency.
// 183:           stanzas.any? { |stanza| stanza.method_name == :on_system } ||
// 184:             top_level_stanzas.any? { |stanza| stanza.method_name == other_os_block } ||
// 185:             stanzas.any? { |stanza| os_only_stanza?(stanza, other_os) }
// 186:         end
// 187:
// 188:         sig { params(node: RuboCop::AST::Node).returns(T::Array[RuboCop::AST::SendNode]) }
// 189:         def direct_stanzas(node)
// 190:           (node.begin_type? ? node.child_nodes : [node]).filter_map do |child|
// 191:             if child.send_type?
// 192:               T.cast(child, RuboCop::AST::SendNode)
// 193:             elsif child.block_type?
// 194:               T.cast(child, RuboCop::AST::BlockNode).send_node
// 195:             end
// 196:           end
// 197:         end
// 198:
// 199:         sig { params(stanza: RuboCop::AST::SendNode).returns(T::Array[RuboCop::AST::SendNode]) }
// 200:         def platform_block_stanzas(stanza)
// 201:           return [] unless PLATFORM_BLOCKS.include?(stanza.method_name)
// 202:
// 203:           block = stanza.parent
// 204:           return [] unless block.is_a?(RuboCop::AST::BlockNode)
// 205:           return [] unless (body = block.body)
// 206:
// 207:           nested_stanzas = direct_stanzas(body)
// 208:           nested_stanzas + nested_stanzas.flat_map { |nested| platform_block_stanzas(nested) }
// 209:         end
// 210:
// 211:         sig { params(stanza: RuboCop::AST::SendNode).returns(Parser::Source::Range) }
// 212:         def full_stanza_source_range(stanza)
// 213:           parent = stanza.parent
// 214:           return parent.source_range if parent.is_a?(RuboCop::AST::BlockNode) && parent.send_node == stanza
// 215:
// 216:           stanza.source_range
// 217:         end
// 218:
// 219:         sig { params(node: RuboCop::AST::SendNode).returns(T::Array[RuboCop::AST::PairNode]) }
// 220:         def depends_on_pairs(node)
// 221:           node.arguments.filter_map do |argument|
// 222:             next unless argument.hash_type?
// 223:
// 224:             argument.pairs
// 225:           end.flatten
// 226:         end
// 227:
// 228:         sig { params(pair: RuboCop::AST::PairNode).returns(T.nilable(Symbol)) }
// 229:         def symbol_key(pair)
// 230:           key = pair.key
// 231:           return unless key.sym_type?
// 232:
// 233:           key.value
// 234:         end
// 235:
// 236:         sig { params(node: RuboCop::AST::SendNode).returns(T::Array[RuboCop::AST::PairNode]) }
// 237:         def sibling_depends_on_pairs(node)
// 238:           sibling_depends_on_calls(node).flat_map { |sibling| depends_on_pairs(sibling) }
// 239:         end
// 240:
// 241:         sig { params(node: RuboCop::AST::SendNode).returns(T::Array[RuboCop::AST::SendNode]) }
// 242:         def sibling_depends_on_calls(node)
// 243:           parent = node.parent
// 244:           siblings = parent&.begin_type? ? parent.child_nodes : [node]
// 245:           siblings.select { |sibling| sibling.send_type? && sibling.method_name == :depends_on }
// 246:         end
// 247:
// 248:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 249:         def os_depends_on?(node)
// 250:           node.each_node(:send).any? do |send_node|
// 251:             send_node = T.cast(send_node, RuboCop::AST::SendNode)
// 252:             next false if send_node.method_name != :depends_on
// 253:
// 254:             bare_os_depends_on?(send_node, :macos) || bare_os_depends_on?(send_node, :linux) ||
// 255:               top_level_macos_depends_on?(send_node) || top_level_linux_depends_on?(send_node)
// 256:           end
// 257:         end
// 258:
// 259:         sig { params(node: RuboCop::AST::SendNode, os: Symbol).returns(T::Boolean) }
// 260:         def bare_os_depends_on?(node, os)
// 261:           !!(node.first_argument&.sym_type? && node.first_argument.value == os)
// 262:         end
// 263:
// 264:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 265:         def top_level_macos_depends_on?(node)
// 266:           depends_on_pairs(node).any? { |pair| MACOS_DEPENDENCY_STANZAS.include?(symbol_key(pair)) }
// 267:         end
// 268:
// 269:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 270:         def top_level_linux_depends_on?(node)
// 271:           depends_on_pairs(node).any? { |pair| LINUX_DEPENDENCY_STANZAS.include?(symbol_key(pair)) }
// 272:         end
// 273:       end
// 274:     end
// 275:   end
// 276: end
