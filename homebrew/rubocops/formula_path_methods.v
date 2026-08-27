module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/formula_path_methods.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :formula_lookup_name_node, <<~PATTERN` at line 40.
pub fn ruby_formula_path_methods_l40_d1_formula_lookup_name_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_lookup_name_node', ...args)
}

// Ruby def_node_matcher `def_node_matcher :formula_path_name_node, <<~PATTERN` at line 44.
pub fn ruby_formula_path_methods_l44_d2_formula_path_name_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_path_name_node', ...args)
}

// Ruby def_node_matcher `def_node_matcher :cask_new_token_node, <<~PATTERN` at line 51.
pub fn ruby_formula_path_methods_l51_d3_cask_new_token_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_new_token_node', ...args)
}

// Ruby def_node_matcher `def_node_matcher :formula_class?, <<~PATTERN` at line 55.
pub fn ruby_formula_path_methods_l55_d4_formula_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_class?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :utils_path?, <<~PATTERN` at line 59.
pub fn ruby_formula_path_methods_l59_d5_utils_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('utils_path?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :cask_block?, <<~PATTERN` at line 63.
pub fn ruby_formula_path_methods_l63_d6_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_block?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :service_block?, <<~PATTERN` at line 67.
pub fn ruby_formula_path_methods_l67_d7_service_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('service_block?', ...args)
}

// Ruby method `on_send(node)` at line 72.
pub fn ruby_formula_path_methods_l72_d8_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `preferred_method_call(node)` at line 84.
pub fn ruby_formula_path_methods_l84_d9_preferred_method_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preferred_method_call', ...args)
}

// Ruby method `formula_helper_method_call(helper_method, formula_name, node)` at line 123.
pub fn ruby_formula_path_methods_l123_d10_formula_helper_method_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_helper_method_call', ...args)
}

// Ruby method `formula_or_cask_dsl?(node)` at line 129.
pub fn ruby_formula_path_methods_l129_d11_formula_or_cask_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_or_cask_dsl?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks for formula instances created only to build stable opt paths.
// 8:       class FormulaPathMethods < Base
// 9:         extend AutoCorrector
// 10:
// 11:         FORMULA_OPT_HELPERS = T.let({
// 12:           opt_bin:     "formula_opt_bin",
// 13:           opt_lib:     "formula_opt_lib",
// 14:           opt_libexec: "formula_opt_libexec",
// 15:           opt_include: "formula_opt_include",
// 16:           opt_prefix:  "formula_opt_prefix",
// 17:         }.freeze, T::Hash[Symbol, String])
// 18:         SCOPED_FORMULA_HELPERS = [
// 19:           :formula_any_version_installed?,
// 20:           :formula_opt_bin,
// 21:           :formula_opt_include,
// 22:           :formula_opt_lib,
// 23:           :formula_opt_libexec,
// 24:           :formula_opt_prefix,
// 25:         ].freeze
// 26:
// 27:         MSG = "Use `%<preferred>s` instead of `%<current>s`."
// 28:         RESTRICT_ON_SEND = T.let([
// 29:           :any_version_installed?,
// 30:           :installed?,
// 31:           :installed_version,
// 32:           :opt_bin,
// 33:           :opt_include,
// 34:           :opt_lib,
// 35:           :opt_libexec,
// 36:           :opt_prefix,
// 37:           *SCOPED_FORMULA_HELPERS,
// 38:         ].freeze, T::Array[Symbol])
// 39:
// 40:         def_node_matcher :formula_lookup_name_node, <<~PATTERN
// 41:           (send (const {nil? cbase} :Formula) :[] $_)
// 42:         PATTERN
// 43:
// 44:         def_node_matcher :formula_path_name_node, <<~PATTERN
// 45:           {
// 46:             (send (const {nil? cbase} :Formula) :[] $_)
// 47:             (send (const {nil? cbase} :Formulary) :factory $_)
// 48:           }
// 49:         PATTERN
// 50:
// 51:         def_node_matcher :cask_new_token_node, <<~PATTERN
// 52:           (send (const (const {nil? cbase} :Cask) :Cask) :new $_ ...)
// 53:         PATTERN
// 54:
// 55:         def_node_matcher :formula_class?, <<~PATTERN
// 56:           (class _ (const {nil? cbase} :Formula) ...)
// 57:         PATTERN
// 58:
// 59:         def_node_matcher :utils_path?, <<~PATTERN
// 60:           (const (const {nil? cbase} :Utils) :Path)
// 61:         PATTERN
// 62:
// 63:         def_node_matcher :cask_block?, <<~PATTERN
// 64:           (block (send nil? :cask ...) ...)
// 65:         PATTERN
// 66:
// 67:         def_node_matcher :service_block?, <<~PATTERN
// 68:           (block (send nil? :service) ...)
// 69:         PATTERN
// 70:
// 71:         sig { params(node: RuboCop::AST::SendNode).void }
// 72:         def on_send(node)
// 73:           preferred = preferred_method_call(node)
// 74:           return unless preferred
// 75:
// 76:           add_offense(node, message: format(MSG, preferred:, current: node.source)) do |corrector|
// 77:             corrector.replace(node.loc.expression, preferred)
// 78:           end
// 79:         end
// 80:
// 81:         private
// 82:
// 83:         sig { params(node: RuboCop::AST::SendNode).returns(T.nilable(String)) }
// 84:         def preferred_method_call(node)
// 85:           case node.method_name
// 86:           when :any_version_installed?
// 87:             return if node.each_ancestor.any?(&:rescue_type?)
// 88:
// 89:             formula_lookup_name_node(node.receiver) do |formula_name|
// 90:               return unless formula_name.str_type?
// 91:
// 92:               return formula_helper_method_call("formula_any_version_installed?", formula_name, node)
// 93:             end
// 94:             cask_new_token_node(node.receiver) do |cask_token|
// 95:               return "Cask::Caskroom.cask_installed?(#{cask_token.source})"
// 96:             end
// 97:           when :installed?
// 98:             cask_new_token_node(node.receiver) do |cask_token|
// 99:               return "Cask::Caskroom.cask_installed?(#{cask_token.source})"
// 100:             end
// 101:           when :installed_version
// 102:             cask_new_token_node(node.receiver) do |cask_token|
// 103:               return "Cask::Caskroom.cask_installed_version(#{cask_token.source})"
// 104:             end
// 105:           when *SCOPED_FORMULA_HELPERS
// 106:             receiver = node.receiver
// 107:             return unless receiver
// 108:             return unless utils_path?(receiver)
// 109:             return unless node.each_ancestor.any? { |ancestor| service_block?(ancestor) }
// 110:
// 111:             return "#{node.method_name}(#{node.arguments.map(&:source).join(", ")})"
// 112:           else
// 113:             return if node.each_ancestor.any?(&:rescue_type?)
// 114:
// 115:             formula_path_name_node(node.receiver) do |formula_name|
// 116:               return formula_helper_method_call(FORMULA_OPT_HELPERS.fetch(node.method_name), formula_name, node)
// 117:             end
// 118:           end
// 119:           nil
// 120:         end
// 121:
// 122:         sig { params(helper_method: String, formula_name: RuboCop::AST::Node, node: RuboCop::AST::Node).returns(String) }
// 123:         def formula_helper_method_call(helper_method, formula_name, node)
// 124:           helper_receiver = "Utils::Path." unless formula_or_cask_dsl?(node)
// 125:           "#{helper_receiver}#{helper_method}(#{formula_name.source})"
// 126:         end
// 127:
// 128:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 129:         def formula_or_cask_dsl?(node)
// 130:           node.each_ancestor.any? { |ancestor| formula_class?(ancestor) || cask_block?(ancestor) }
// 131:         end
// 132:       end
// 133:     end
// 134:   end
// 135: end
