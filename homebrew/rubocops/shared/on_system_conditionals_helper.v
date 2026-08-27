module shared

import brew_runtime

// Translated from Homebrew/brew `rubocops/shared/on_system_conditionals_helper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_on_system_blocks(body_node, parent_name)` at line 33.
pub fn ruby_on_system_conditionals_helper_l33_d1_audit_on_system_blocks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_on_system_blocks', ...args)
}

// Ruby method `audit_arch_conditionals(body_node, allowed_methods: [], allowed_blocks: [])` at line 95.
pub fn ruby_on_system_conditionals_helper_l95_d2_audit_arch_conditionals(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_arch_conditionals', ...args)
}

// Ruby method `audit_base_os_conditionals(body_node, allowed_methods: [], allowed_blocks: [])` at line 126.
pub fn ruby_on_system_conditionals_helper_l126_d3_audit_base_os_conditionals(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_base_os_conditionals', ...args)
}

// Ruby method `audit_macos_version_conditionals(body_node, allowed_methods: [], allowed_blocks: [],` at line 152.
pub fn ruby_on_system_conditionals_helper_l152_d4_audit_macos_version_conditionals(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_macos_version_conditionals', ...args)
}

// Ruby method `audit_macos_references(body_node, allowed_methods: [], allowed_blocks: [])` at line 194.
pub fn ruby_on_system_conditionals_helper_l194_d5_audit_macos_references(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_macos_references', ...args)
}

// Ruby method `if_statement_problem(if_node, if_statement_string, on_system_method_string,` at line 219.
pub fn ruby_on_system_conditionals_helper_l219_d6_if_statement_problem(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('if_statement_problem', ...args)
}

// Ruby method `node_is_allowed?(node, allowed_methods: [], allowed_blocks: [])` at line 243.
pub fn ruby_on_system_conditionals_helper_l243_d7_node_is_allowed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('node_is_allowed?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :on_macos_version_method_call, <<~PATTERN` at line 265.
pub fn ruby_on_system_conditionals_helper_l265_d8_on_macos_version_method_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_macos_version_method_call', ...args)
}

// Ruby def_node_matcher `def_node_matcher :on_system_method_call, <<~PATTERN` at line 269.
pub fn ruby_on_system_conditionals_helper_l269_d9_on_system_method_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_system_method_call', ...args)
}

// Ruby def_node_search `def_node_search :hardware_cpu_search, <<~PATTERN` at line 273.
pub fn ruby_on_system_conditionals_helper_l273_d10_hardware_cpu_search(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hardware_cpu_search', ...args)
}

// Ruby def_node_search `def_node_search :macos_version_comparison_search, <<~PATTERN` at line 277.
pub fn ruby_on_system_conditionals_helper_l277_d11_macos_version_comparison_search(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_version_comparison_search', ...args)
}

// Ruby def_node_search `def_node_search :if_arch_node_search, <<~PATTERN` at line 281.
pub fn ruby_on_system_conditionals_helper_l281_d12_if_arch_node_search(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('if_arch_node_search', ...args)
}

// Ruby def_node_search `def_node_search :if_base_os_node_search, <<~PATTERN` at line 285.
pub fn ruby_on_system_conditionals_helper_l285_d13_if_base_os_node_search(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('if_base_os_node_search', ...args)
}

// Ruby def_node_search `def_node_search :if_macos_version_node_search, <<~PATTERN` at line 289.
pub fn ruby_on_system_conditionals_helper_l289_d14_if_macos_version_node_search(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('if_macos_version_node_search', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "macos_version"
// 5: require "rubocops/shared/helper_functions"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     # This module performs common checks on `on_{system}` blocks in both formulae and casks.
// 10:     module OnSystemConditionalsHelper
// 11:       extend NodePattern::Macros
// 12:       include HelperFunctions
// 13:
// 14:       ARCH_OPTIONS = [:arm, :intel].freeze
// 15:       BASE_OS_OPTIONS = [:macos, :linux].freeze
// 16:       MACOS_VERSION_OPTIONS = T.let(MacOSVersion::SYMBOLS.keys.freeze, T::Array[Symbol])
// 17:       ON_SYSTEM_OPTIONS = T.let(
// 18:         [*ARCH_OPTIONS, *BASE_OS_OPTIONS, *MACOS_VERSION_OPTIONS, :system].freeze,
// 19:         T::Array[Symbol],
// 20:       )
// 21:       MACOS_MODULE_NAMES = ["MacOS", "OS::Mac"].freeze
// 22:
// 23:       MACOS_VERSION_CONDITIONALS = T.let(
// 24:         {
// 25:           "==" => nil,
// 26:           "<=" => :or_older,
// 27:           ">=" => :or_newer,
// 28:         }.freeze,
// 29:         T::Hash[String, T.nilable(Symbol)],
// 30:       )
// 31:
// 32:       sig { params(body_node: RuboCop::AST::Node, parent_name: Symbol).void }
// 33:       def audit_on_system_blocks(body_node, parent_name)
// 34:         return unless body_node.source.include?("on_")
// 35:
// 36:         parent_string = if body_node.def_type?
// 37:           "def #{parent_name}"
// 38:         else
// 39:           "#{parent_name} do"
// 40:         end
// 41:
// 42:         ON_SYSTEM_OPTIONS.each do |on_system_option|
// 43:           on_system_method = :"on_#{on_system_option}"
// 44:           if_statement_string = if ARCH_OPTIONS.include?(on_system_option)
// 45:             "if Hardware::CPU.#{on_system_option}?"
// 46:           elsif BASE_OS_OPTIONS.include?(on_system_option)
// 47:             "if OS.#{(on_system_option == :macos) ? "mac" : "linux"}?"
// 48:           elsif on_system_option == :system
// 49:             "if OS.linux? || MacOS.version"
// 50:           else
// 51:             "if MacOS.version"
// 52:           end
// 53:
// 54:           find_every_method_call_by_name(body_node, on_system_method).each do |on_system_node|
// 55:             if_conditional = ""
// 56:             if MACOS_VERSION_OPTIONS.include? on_system_option
// 57:               on_macos_version_method_call(on_system_node, on_method: on_system_method) do |on_method_parameters|
// 58:                 if on_method_parameters.empty?
// 59:                   if_conditional = " == :#{on_system_option}"
// 60:                 else
// 61:                   if_condition_operator = MACOS_VERSION_CONDITIONALS.key(on_method_parameters.first)
// 62:                   if_conditional = " #{if_condition_operator} :#{on_system_option}"
// 63:                 end
// 64:               end
// 65:             elsif on_system_option == :system
// 66:               on_system_method_call(on_system_node) do |macos_symbol|
// 67:                 base_os, condition = macos_symbol.to_s.split(/_(?=or_)/).map(&:to_sym)
// 68:                 if_condition_operator = MACOS_VERSION_CONDITIONALS.key(condition)
// 69:                 if_conditional = " #{if_condition_operator} :#{base_os}"
// 70:               end
// 71:             end
// 72:
// 73:             @offensive_node = on_system_node
// 74:             problem "Instead of using `#{on_system_node.source}` in `#{parent_string}`, " \
// 75:                     "use `#{if_statement_string}#{if_conditional}`." do |corrector|
// 76:               block_node = @offensive_node.parent
// 77:               next if block_node.type != :block
// 78:
// 79:               # TODO: could fix corrector to handle this but punting for now.
// 80:               next if block_node.single_line?
// 81:
// 82:               source_range = @offensive_node.source_range.join(@offensive_node.parent.loc.begin)
// 83:               corrector.replace(source_range, "#{if_statement_string}#{if_conditional}")
// 84:             end
// 85:           end
// 86:         end
// 87:       end
// 88:
// 89:       sig {
// 90:         params(
// 91:           body_node: RuboCop::AST::Node, allowed_methods: T::Array[Symbol],
// 92:           allowed_blocks: T::Array[Symbol]
// 93:         ).void
// 94:       }
// 95:       def audit_arch_conditionals(body_node, allowed_methods: [], allowed_blocks: [])
// 96:         return unless body_node.source.include?("Hardware")
// 97:
// 98:         ARCH_OPTIONS.each do |arch_option|
// 99:           else_method = (arch_option == :arm) ? :on_intel : :on_arm
// 100:           if_arch_node_search(body_node, arch: :"#{arch_option}?") do |if_node, else_node|
// 101:             next if node_is_allowed?(if_node, allowed_methods:, allowed_blocks:)
// 102:
// 103:             if_statement_problem(if_node, "if Hardware::CPU.#{arch_option}?", "on_#{arch_option}",
// 104:                                  else_method:, else_node:)
// 105:           end
// 106:         end
// 107:
// 108:         [:arch, :arm?, :intel?].each do |method|
// 109:           hardware_cpu_search(body_node, method:) do |method_node|
// 110:             # These should already be caught by `if_arch_node_search`
// 111:             next if method_node.parent.source.start_with? "if #{method_node.source}"
// 112:             next if node_is_allowed?(method_node, allowed_methods:, allowed_blocks:)
// 113:
// 114:             offending_node(method_node)
// 115:             problem "Instead of `#{method_node.source}`, use `on_arm` and `on_intel` blocks."
// 116:           end
// 117:         end
// 118:       end
// 119:
// 120:       sig {
// 121:         params(
// 122:           body_node: RuboCop::AST::Node, allowed_methods: T::Array[Symbol],
// 123:           allowed_blocks: T::Array[Symbol]
// 124:         ).void
// 125:       }
// 126:       def audit_base_os_conditionals(body_node, allowed_methods: [], allowed_blocks: [])
// 127:         return unless body_node.source.include?("OS")
// 128:
// 129:         BASE_OS_OPTIONS.each do |base_os_option|
// 130:           os_method, else_method = if base_os_option == :macos
// 131:             [:mac?, :on_linux]
// 132:           else
// 133:             [:linux?, :on_macos]
// 134:           end
// 135:           if_base_os_node_search(body_node, base_os: os_method) do |if_node, else_node|
// 136:             next if node_is_allowed?(if_node, allowed_methods:, allowed_blocks:)
// 137:
// 138:             if_statement_problem(if_node, "if OS.#{os_method}", "on_#{base_os_option}",
// 139:                                  else_method:, else_node:)
// 140:           end
// 141:         end
// 142:       end
// 143:
// 144:       sig {
// 145:         params(
// 146:           body_node:           RuboCop::AST::Node,
// 147:           allowed_methods:     T::Array[Symbol],
// 148:           allowed_blocks:      T::Array[Symbol],
// 149:           recommend_on_system: T::Boolean,
// 150:         ).void
// 151:       }
// 152:       def audit_macos_version_conditionals(body_node, allowed_methods: [], allowed_blocks: [],
// 153:                                            recommend_on_system: true)
// 154:         return unless body_node.source.include?("MacOS")
// 155:
// 156:         MACOS_VERSION_OPTIONS.each do |macos_version_option|
// 157:           if_macos_version_node_search(body_node, os_version: macos_version_option) do |if_node, operator, else_node|
// 158:             next if node_is_allowed?(if_node, allowed_methods:, allowed_blocks:)
// 159:
// 160:             else_node = T.let(else_node, T.nilable(RuboCop::AST::Node))
// 161:             autocorrect = else_node.blank? && MACOS_VERSION_CONDITIONALS.key?(operator.to_s)
// 162:             on_system_method_string = if recommend_on_system && operator == :<
// 163:               "on_system"
// 164:             elsif recommend_on_system && operator == :<=
// 165:               "on_system :linux, macos: :#{macos_version_option}_or_older"
// 166:             elsif operator != :== && MACOS_VERSION_CONDITIONALS.key?(operator.to_s)
// 167:               "on_#{macos_version_option} :#{MACOS_VERSION_CONDITIONALS[operator.to_s]}"
// 168:             else
// 169:               "on_#{macos_version_option}"
// 170:             end
// 171:
// 172:             if_statement_problem(if_node, "if MacOS.version #{operator} :#{macos_version_option}",
// 173:                                  on_system_method_string, autocorrect:)
// 174:           end
// 175:
// 176:           macos_version_comparison_search(body_node, os_version: macos_version_option) do |method_node|
// 177:             # These should already be caught by `if_macos_version_node_search`
// 178:             next if method_node.parent.source.start_with? "if #{method_node.source}"
// 179:             next if node_is_allowed?(method_node, allowed_methods:, allowed_blocks:)
// 180:
// 181:             offending_node(method_node)
// 182:             problem "Instead of `#{method_node.source}`, use `on_{macos_version}` blocks."
// 183:           end
// 184:         end
// 185:       end
// 186:
// 187:       sig {
// 188:         params(
// 189:           body_node:       RuboCop::AST::Node,
// 190:           allowed_methods: T::Array[Symbol],
// 191:           allowed_blocks:  T::Array[Symbol],
// 192:         ).void
// 193:       }
// 194:       def audit_macos_references(body_node, allowed_methods: [], allowed_blocks: [])
// 195:         return if !body_node.source.include?("MacOS") && !body_node.source.include?("OS")
// 196:
// 197:         MACOS_MODULE_NAMES.each do |macos_module_name|
// 198:           find_const(body_node, macos_module_name) do |node|
// 199:             next if node_is_allowed?(node, allowed_methods:, allowed_blocks:)
// 200:
// 201:             offending_node(node)
// 202:             problem "Don't use `#{macos_module_name}` where it could be called on Linux."
// 203:           end
// 204:         end
// 205:       end
// 206:
// 207:       private
// 208:
// 209:       sig {
// 210:         params(
// 211:           if_node:                 RuboCop::AST::IfNode,
// 212:           if_statement_string:     String,
// 213:           on_system_method_string: String,
// 214:           else_method:             T.nilable(Symbol),
// 215:           else_node:               T.nilable(RuboCop::AST::Node),
// 216:           autocorrect:             T::Boolean,
// 217:         ).void
// 218:       }
// 219:       def if_statement_problem(if_node, if_statement_string, on_system_method_string,
// 220:                                else_method: nil, else_node: nil, autocorrect: true)
// 221:         offending_node(if_node)
// 222:         problem "Instead of `#{if_statement_string}`, use `#{on_system_method_string} do`." do |corrector|
// 223:           next unless autocorrect
// 224:           # TODO: could fix corrector to handle this but punting for now.
// 225:           next if if_node.unless?
// 226:
// 227:           if else_method.present? && else_node.present?
// 228:             corrector.replace(if_node.source_range,
// 229:                               "#{on_system_method_string} do\n#{if_node.body.source}\nend\n" \
// 230:                               "#{else_method} do\n#{else_node.source}\nend")
// 231:           else
// 232:             corrector.replace(if_node.source_range, "#{on_system_method_string} do\n#{if_node.body.source}\nend")
// 233:           end
// 234:         end
// 235:       end
// 236:
// 237:       sig {
// 238:         params(
// 239:           node: RuboCop::AST::Node, allowed_methods: T::Array[Symbol],
// 240:           allowed_blocks: T::Array[Symbol]
// 241:         ).returns(T::Boolean)
// 242:       }
// 243:       def node_is_allowed?(node, allowed_methods: [], allowed_blocks: [])
// 244:         # TODO: check to see if it's legal
// 245:         valid = T.let(false, T::Boolean)
// 246:         node.each_ancestor do |ancestor|
// 247:           valid_method_names = case ancestor.type
// 248:           when :def
// 249:             allowed_methods
// 250:           when :block
// 251:             allowed_blocks
// 252:           else
// 253:             next
// 254:           end
// 255:           next unless valid_method_names.include?(ancestor.method_name)
// 256:
// 257:           valid = true
// 258:           break
// 259:         end
// 260:         return true if valid
// 261:
// 262:         false
// 263:       end
// 264:
// 265:       def_node_matcher :on_macos_version_method_call, <<~PATTERN
// 266:         (send nil? %on_method (sym ${:or_newer :or_older})?)
// 267:       PATTERN
// 268:
// 269:       def_node_matcher :on_system_method_call, <<~PATTERN
// 270:         (send nil? :on_system (sym :linux) (hash (pair (sym :macos) (sym $_))))
// 271:       PATTERN
// 272:
// 273:       def_node_search :hardware_cpu_search, <<~PATTERN
// 274:         (send (const (const nil? :Hardware) :CPU) %method)
// 275:       PATTERN
// 276:
// 277:       def_node_search :macos_version_comparison_search, <<~PATTERN
// 278:         (send (send (const nil? :MacOS) :version) {:== :<= :< :>= :> :!=} (sym %os_version))
// 279:       PATTERN
// 280:
// 281:       def_node_search :if_arch_node_search, <<~PATTERN
// 282:         $(if (send (const (const nil? :Hardware) :CPU) %arch) _ $_)
// 283:       PATTERN
// 284:
// 285:       def_node_search :if_base_os_node_search, <<~PATTERN
// 286:         $(if (send (const nil? :OS) %base_os) _ $_)
// 287:       PATTERN
// 288:
// 289:       def_node_search :if_macos_version_node_search, <<~PATTERN
// 290:         $(if (send (send (const nil? :MacOS) :version) ${:== :<= :< :>= :> :!=} (sym %os_version)) _ $_)
// 291:       PATTERN
// 292:     end
// 293:   end
// 294: end
