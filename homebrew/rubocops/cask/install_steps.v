module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/install_steps.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask(cask_block)` at line 58.
pub fn ruby_install_steps_l58_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask', ...args)
}

// Ruby method `autocorrect_flight_block?(flight_stanza, steps_block)` at line 96.
pub fn ruby_install_steps_l96_d2_autocorrect_flight_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrect_flight_block?', ...args)
}

// Ruby method `keychain_certificate_step_lines(body_node)` at line 120.
pub fn ruby_install_steps_l120_d3_keychain_certificate_step_lines(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keychain_certificate_step_lines', ...args)
}

// Ruby method `keychain_delete_sequence_name(nodes)` at line 151.
pub fn ruby_install_steps_l151_d4_keychain_delete_sequence_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keychain_delete_sequence_name', ...args)
}

// Ruby method `fingerprint_keychain_step_lines(nodes)` at line 163.
pub fn ruby_install_steps_l163_d5_fingerprint_keychain_step_lines(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fingerprint_keychain_step_lines', ...args)
}

// Ruby method `keychain_find_certificate_name(node)` at line 189.
pub fn ruby_install_steps_l189_d6_keychain_find_certificate_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keychain_find_certificate_name', ...args)
}

// Ruby method `certificate_path(node)` at line 229.
pub fn ruby_install_steps_l229_d7_certificate_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('certificate_path', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/install_steps_helper"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Cask
// 9:       # This cop checks declarative install step usage.
// 10:       class InstallSteps < Base
// 11:         extend AutoCorrector
// 12:         include CaskHelp
// 13:         include ::RuboCop::Cop::InstallStepsHelper
// 14:
// 15:         INSTALL_STEP_PAIRS = T.let(
// 16:           {
// 17:             preflight:            :preflight_steps,
// 18:             postflight:           :postflight_steps,
// 19:             uninstall_preflight:  :uninstall_preflight_steps,
// 20:             uninstall_postflight: :uninstall_postflight_steps,
// 21:           }.freeze,
// 22:           T::Hash[Symbol, Symbol],
// 23:         )
// 24:         LEGACY_FLIGHT_MSG = "Casks in official Homebrew taps must use `%<steps>s` instead of `%<flight>s`."
// 25:         KEYCHAIN_HASHES_SOURCE =
// 26:           'hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }'
// 27:         KEYCHAIN_DELETE_SOURCE = T.let(
// 28:           <<~RUBY.gsub(/\s+/, " ").strip.freeze,
// 29:             hashes.each do |h|
// 30:               system_command "/usr/bin/security",
// 31:                              args: ["delete-certificate", "-Z", h],
// 32:                              sudo: true
// 33:             end
// 34:           RUBY
// 35:           String,
// 36:         )
// 37:         CERTIFICATE_EXISTS_GUARD_SOURCE = "next unless cert.exist?"
// 38:         CERTIFICATE_FINGERPRINT_SOURCE = T.let(
// 39:           <<~RUBY.gsub(/\s+/, " ").strip.freeze,
// 40:             stdout, * = system_command "/usr/bin/openssl",
// 41:                                        args: ["x509", "-fingerprint", "-sha256", "-noout", "-in", cert]
// 42:           RUBY
// 43:           String,
// 44:         )
// 45:         CERTIFICATE_HASH_SOURCE = 'hash = stdout.lines.first.split("=").second.delete(":").strip'
// 46:         CERTIFICATE_HASH_DELETE_SOURCE = T.let(
// 47:           <<~RUBY.gsub(/\s+/, " ").strip.freeze,
// 48:             if hashes.include?(hash)
// 49:               system_command "/usr/bin/security",
// 50:                              args: ["delete-certificate", "-Z", hash],
// 51:                              sudo: true
// 52:             end
// 53:           RUBY
// 54:           String,
// 55:         )
// 56:
// 57:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 58:         def on_cask(cask_block)
// 59:           stanzas = cask_block.stanzas
// 60:           INSTALL_STEP_PAIRS.each do |flight_block, steps_block|
// 61:             next unless (flight_stanza = stanzas.find { |stanza| stanza.stanza_name == flight_block })
// 62:
// 63:             steps_stanza = stanzas.find { |stanza| stanza.stanza_name == steps_block }
// 64:             converted_flight = autocorrect_flight_block?(flight_stanza, steps_block) if steps_stanza.nil?
// 65:
// 66:             # odeprecated: remove the official-tap scope in the next major or minor release.
// 67:             next unless official_homebrew_tap?(processed_source.file_path)
// 68:             next if converted_flight
// 69:
// 70:             add_offense(flight_stanza.method_node,
// 71:                         message: format(LEGACY_FLIGHT_MSG, steps: steps_block, flight: flight_block))
// 72:           end
// 73:
// 74:           stanzas.each do |stanza|
// 75:             next unless INSTALL_STEP_PAIRS.value?(stanza.stanza_name)
// 76:             next unless stanza.method_node.block_type?
// 77:
// 78:             block_node = T.cast(stanza.method_node, RuboCop::AST::BlockNode)
// 79:             add_compatibility_step_offenses(block_node, allowed_methods: CASK_ALLOWED_STEP_METHODS)
// 80:             if (offense_node = brew_ruby_step_node(block_node))
// 81:               add_offense(offense_node, message: BREW_RUBY_STEP_MSG)
// 82:               next
// 83:             end
// 84:             next unless (offense_node = install_step_block_offense_node(
// 85:               block_node,
// 86:               allowed_methods: CASK_ALLOWED_STEP_METHODS,
// 87:             ))
// 88:
// 89:             add_offense(offense_node, message: step_block_msg(CASK_ALLOWED_STEP_METHODS))
// 90:           end
// 91:         end
// 92:
// 93:         private
// 94:
// 95:         sig { params(flight_stanza: RuboCop::Cask::AST::Stanza, steps_block: Symbol).returns(T::Boolean) }
// 96:         def autocorrect_flight_block?(flight_stanza, steps_block)
// 97:           return false unless flight_stanza.method_node.block_type?
// 98:
// 99:           block_node = T.cast(flight_stanza.method_node, RuboCop::AST::BlockNode)
// 100:           step_lines = keychain_certificate_step_lines(block_node.body) ||
// 101:                        simple_install_step_lines(block_node.body,
// 102:                                                  default_base:        :staged_path,
// 103:                                                  default_source_base: :staged_path,
// 104:                                                  default_target_base: :staged_path,
// 105:                                                  rebuild_actions:     false,
// 106:                                                  permission_actions:  true)
// 107:           return false if step_lines.blank?
// 108:
// 109:           add_offense(block_node.source_range,
// 110:                       message: format(SIMPLE_STEP_CONVERSION_MSG, steps_block:)) do |corrector|
// 111:             corrector.replace(
// 112:               block_node.source_range,
// 113:               install_steps_block_source(steps_block, step_lines, block_node.source_range.column),
// 114:             )
// 115:           end
// 116:           true
// 117:         end
// 118:
// 119:         sig { params(body_node: T.nilable(RuboCop::AST::Node)).returns(T.nilable(T::Array[String])) }
// 120:         def keychain_certificate_step_lines(body_node)
// 121:           direct_nodes = direct_install_step_nodes(body_node)
// 122:           return fingerprint_keychain_step_lines(direct_nodes) if direct_nodes.length == 7
// 123:
// 124:           if (name_node = keychain_delete_sequence_name(direct_nodes))&.str_type?
// 125:             return ["delete_keychain_certificates #{T.cast(name_node, RuboCop::AST::StrNode).str_content.inspect}"]
// 126:           end
// 127:
// 128:           return if body_node.nil? || !body_node.block_type?
// 129:
// 130:           block_node = T.cast(body_node, RuboCop::AST::BlockNode)
// 131:           send_node = block_node.send_node
// 132:           names_node = send_node.receiver
// 133:           return if send_node.method_name != :each || send_node.arguments.present? || !names_node&.array_type?
// 134:
// 135:           block_arguments = block_node.arguments.children
// 136:           return if block_arguments.length != 1 || block_arguments.first&.children != [:cert_name]
// 137:
// 138:           name_nodes = names_node.child_nodes
// 139:           return unless name_nodes.all?(&:str_type?)
// 140:
// 141:           sequence_name_node = keychain_delete_sequence_name(direct_install_step_nodes(block_node.body))
// 142:           return unless sequence_name_node&.lvar_type?
// 143:           return if sequence_name_node.children != [:cert_name]
// 144:
// 145:           name_nodes.map do |name|
// 146:             "delete_keychain_certificates #{T.cast(name, RuboCop::AST::StrNode).str_content.inspect}"
// 147:           end
// 148:         end
// 149:
// 150:         sig { params(nodes: T::Array[RuboCop::AST::Node]).returns(T.nilable(RuboCop::AST::Node)) }
// 151:         def keychain_delete_sequence_name(nodes)
// 152:           return if nodes.length != 3
// 153:
// 154:           name_node = keychain_find_certificate_name(nodes.fetch(0))
// 155:           return if name_node.nil?
// 156:           return if normalised_install_step_source(nodes.fetch(1)) != KEYCHAIN_HASHES_SOURCE
// 157:           return if normalised_install_step_source(nodes.fetch(2)) != KEYCHAIN_DELETE_SOURCE
// 158:
// 159:           name_node
// 160:         end
// 161:
// 162:         sig { params(nodes: T::Array[RuboCop::AST::Node]).returns(T.nilable(T::Array[String])) }
// 163:         def fingerprint_keychain_step_lines(nodes)
// 164:           path_node = certificate_path(nodes.fetch(0))
// 165:           return if path_node.nil?
// 166:           return if normalised_install_step_source(nodes.fetch(1)) != CERTIFICATE_EXISTS_GUARD_SOURCE
// 167:
// 168:           fingerprint_source = normalised_install_step_source(nodes.fetch(2))
// 169:                                .gsub(/\[\s+/, "[")
// 170:                                .gsub(/\s+\]/, "]")
// 171:           return if fingerprint_source != CERTIFICATE_FINGERPRINT_SOURCE
// 172:           return if normalised_install_step_source(nodes.fetch(3)) != CERTIFICATE_HASH_SOURCE
// 173:
// 174:           name_node = keychain_find_certificate_name(nodes.fetch(4))
// 175:           return if name_node.nil? || !name_node.str_type?
// 176:           return if normalised_install_step_source(nodes.fetch(5)) != KEYCHAIN_HASHES_SOURCE
// 177:           return if normalised_install_step_source(nodes.fetch(6)) != CERTIFICATE_HASH_DELETE_SOURCE
// 178:
// 179:           name = T.cast(name_node, RuboCop::AST::StrNode).str_content.inspect
// 180:           path = T.cast(path_node, RuboCop::AST::StrNode).str_content.inspect
// 181:           source = <<~RUBY.chomp
// 182:             delete_keychain_certificates #{name},
// 183:                                          fingerprint_of: #{path}
// 184:           RUBY
// 185:           [source]
// 186:         end
// 187:
// 188:         sig { params(node: RuboCop::AST::Node).returns(T.nilable(RuboCop::AST::Node)) }
// 189:         def keychain_find_certificate_name(node)
// 190:           return unless node.masgn_type?
// 191:           return if node.child_nodes.length != 2
// 192:
// 193:           assignment = node.child_nodes.fetch(0)
// 194:           command_node = node.child_nodes.fetch(1)
// 195:           return if normalised_install_step_source(assignment) != "stdout, *"
// 196:           return unless command_node.send_type?
// 197:
// 198:           command = T.cast(command_node, RuboCop::AST::SendNode)
// 199:           return if command.receiver || command.method_name != :system_command || command.arguments.length != 2
// 200:           return unless command.arguments.fetch(0).str_type?
// 201:           return if T.cast(command.arguments.fetch(0), RuboCop::AST::StrNode).str_content != "/usr/bin/security"
// 202:
// 203:           options = command.arguments.fetch(1)
// 204:           return unless options.hash_type?
// 205:
// 206:           pairs = T.cast(options, RuboCop::AST::HashNode).pairs
// 207:           return if pairs.length != 2 || pairs.any? { |pair| !pair.key.sym_type? }
// 208:           return if pairs.map { |pair| pair.key.value } != [:args, :sudo]
// 209:           return unless pairs.fetch(1).value.true_type?
// 210:
// 211:           arguments = pairs.fetch(0).value
// 212:           return unless arguments.array_type?
// 213:
// 214:           values = arguments.child_nodes
// 215:           return if values.length != 5
// 216:
// 217:           fixed_value_nodes = [0, 1, 2, 4].map { |index| values.fetch(index) }
// 218:           return unless fixed_value_nodes.all?(&:str_type?)
// 219:
// 220:           fixed_values = fixed_value_nodes.map do |value|
// 221:             T.cast(value, RuboCop::AST::StrNode).str_content
// 222:           end
// 223:           return if fixed_values != ["find-certificate", "-a", "-c", "-Z"]
// 224:
// 225:           values.fetch(3)
// 226:         end
// 227:
// 228:         sig { params(node: RuboCop::AST::Node).returns(T.nilable(RuboCop::AST::Node)) }
// 229:         def certificate_path(node)
// 230:           return unless node.lvasgn_type?
// 231:           return if node.children.first != :cert
// 232:
// 233:           expand_node = node.child_nodes.first
// 234:           return unless expand_node&.send_type?
// 235:
// 236:           expand = T.cast(expand_node, RuboCop::AST::SendNode)
// 237:           return if expand.method_name != :expand_path || expand.arguments.present?
// 238:           return unless expand.receiver&.send_type?
// 239:
// 240:           pathname = T.cast(expand.receiver, RuboCop::AST::SendNode)
// 241:           return if pathname.receiver || pathname.method_name != :Pathname || pathname.arguments.length != 1
// 242:
// 243:           path = pathname.arguments.fetch(0)
// 244:           path if path.str_type?
// 245:         end
// 246:       end
// 247:     end
// 248:   end
// 249: end
