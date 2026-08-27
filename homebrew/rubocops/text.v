module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/text.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 14.
pub fn ruby_text_l14_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 135.
pub fn ruby_text_l135_d2_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `path_starts_with?(path, starts_with, bin: false)` at line 172.
pub fn ruby_text_l172_d3_path_starts_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path_starts_with?', ...args)
}

// Ruby method `path_starts_with_bin?(path, starts_with)` at line 178.
pub fn ruby_text_l178_d4_path_starts_with_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path_starts_with_bin?', ...args)
}

// Ruby def_node_search `def_node_search :interpolated_share_path_starts_with, <<~EOS` at line 185.
pub fn ruby_text_l185_d5_interpolated_share_path_starts_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('interpolated_share_path_starts_with', ...args)
}

// Ruby def_node_search `def_node_search :interpolated_bin_path_starts_with, <<~EOS` at line 190.
pub fn ruby_text_l190_d6_interpolated_bin_path_starts_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('interpolated_bin_path_starts_with', ...args)
}

// Ruby def_node_search `def_node_search :share_path_starts_with, <<~EOS` at line 195.
pub fn ruby_text_l195_d7_share_path_starts_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('share_path_starts_with', ...args)
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
// 9:       # This cop checks for various problems in a formula's source code.
// 10:       class Text < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         sig { override.params(formula_nodes: FormulaNodes).void }
// 14:         def audit_formula(formula_nodes)
// 15:           node = formula_nodes.node
// 16:           full_source_content = source_buffer(node).source
// 17:
// 18:           if (match = full_source_content.match(/^require ['"]formula['"]$/))
// 19:             range = source_range(source_buffer(node), match.pre_match.count("\n") + 1, 0, match[0].length)
// 20:             add_offense(range, message: "`#{match}` is now unnecessary") do |corrector|
// 21:               corrector.remove(range_with_surrounding_space(range:))
// 22:             end
// 23:           end
// 24:
// 25:           return if (body_node = formula_nodes.body_node).nil?
// 26:
// 27:           if find_method_def(body_node, :plist)
// 28:             problem "`def plist` is deprecated. Please use services instead: https://docs.brew.sh/Formula-Cookbook#service-files"
// 29:           end
// 30:
// 31:           if (depends_on?("openssl") || depends_on?("openssl@3")) && depends_on?("libressl")
// 32:             problem "Formulae should not depend on both OpenSSL and LibreSSL (even optionally)."
// 33:           end
// 34:
// 35:           if formula_tap == "homebrew-core"
// 36:             if depends_on?("veclibfort") || depends_on?("lapack")
// 37:               problem "Formulae in homebrew/core should use OpenBLAS as the default serial linear algebra library."
// 38:             end
// 39:
// 40:             if find_node_method_by_name(body_node, :keg_only)&.source&.include?("HOMEBREW_PREFIX")
// 41:               problem "`keg_only` reason should not include `$HOMEBREW_PREFIX` " \
// 42:                       "as it creates confusing `brew info` output."
// 43:             end
// 44:           end
// 45:
// 46:           # processed_source.ast is passed instead of body_node because `require` would be outside body_node
// 47:           find_method_with_args(processed_source.ast, :require, "language/go") do
// 48:             problem '`require "language/go"` is no longer necessary or correct'
// 49:           end
// 50:
// 51:           find_instance_method_call(body_node, "Formula", :factory) do
// 52:             problem "`Formula.factory(name)` is deprecated in favour of `Formula[name]`"
// 53:           end
// 54:
// 55:           find_method_with_args(body_node, :revision, 0) do
// 56:             problem "`revision 0` is unnecessary"
// 57:           end
// 58:
// 59:           find_method_with_args(body_node, :system, "xcodebuild") do
// 60:             problem "Use `xcodebuild *args` instead of `system 'xcodebuild', *args`"
// 61:           end
// 62:
// 63:           if !depends_on?(:xcode) && method_called_ever?(body_node, :xcodebuild)
// 64:             problem "`xcodebuild` needs an Xcode dependency"
// 65:           end
// 66:
// 67:           if (method_node = find_method_def(body_node, :install))
// 68:             find_method_with_args(method_node, :system, "go", "get") do
// 69:               problem "Do not use `go get`. Please ask upstream to implement Go vendoring"
// 70:             end
// 71:
// 72:             find_method_with_args(method_node, :system, "cargo", "build") do |m|
// 73:               next if parameters_passed?(m, [/--lib/])
// 74:
// 75:               problem 'Use `"cargo", "install", *std_cargo_args`'
// 76:             end
// 77:           end
// 78:
// 79:           find_method_with_args(body_node, :system, "dep", "ensure") do |d|
// 80:             next if parameters_passed?(d, [/vendor-only/])
// 81:             next if @formula_name == "goose" # needed in 2.3.0
// 82:
// 83:             problem 'Use `"dep", "ensure", "-vendor-only"`'
// 84:           end
// 85:
// 86:           find_every_method_call_by_name(body_node, :system).each do |m|
// 87:             next unless parameters_passed?(m, [/make && make/])
// 88:
// 89:             offending_node(m)
// 90:             problem "Use separate `make` calls"
// 91:           end
// 92:
// 93:           find_every_method_call_by_name(body_node, :+).each do |plus_node|
// 94:             next unless plus_node.receiver&.send_type?
// 95:             next unless plus_node.first_argument&.str_type?
// 96:
// 97:             receiver_method = plus_node.receiver.method_name
// 98:             path_arg = plus_node.first_argument.str_content
// 99:
// 100:             case receiver_method
// 101:             when :prefix
// 102:               next unless (match = path_arg.match(%r{^(bin|include|libexec|lib|sbin|share|Frameworks)(?:/| |$)}))
// 103:
// 104:               offending_node(plus_node)
// 105:               problem "Use `#{match[1].downcase}` instead of `prefix + \"#{match[1]}\"`"
// 106:             when :bin, :include, :libexec, :lib, :sbin, :share
// 107:               next if path_arg.empty?
// 108:
// 109:               offending_node(plus_node)
// 110:               good = "#{receiver_method}/\"#{path_arg}\""
// 111:               problem "Use `#{good}` instead of `#{plus_node.source}`" do |corrector|
// 112:                 corrector.replace(plus_node.loc.expression, good)
// 113:               end
// 114:             end
// 115:           end
// 116:
// 117:           body_node.each_descendant(:dstr) do |dstr_node|
// 118:             dstr_node.each_descendant(:begin) do |interpolation_node|
// 119:               next unless interpolation_node.source.match?(/#\{\w+\s*\+\s*['"][^}]+\}/)
// 120:
// 121:               offending_node(interpolation_node)
// 122:               problem "Do not concatenate paths in string interpolation"
// 123:             end
// 124:           end
// 125:         end
// 126:       end
// 127:     end
// 128:
// 129:     module FormulaAuditStrict
// 130:       # This cop contains stricter checks for various problems in a formula's source code.
// 131:       class Text < FormulaCop
// 132:         extend AutoCorrector
// 133:
// 134:         sig { override.params(formula_nodes: FormulaNodes).void }
// 135:         def audit_formula(formula_nodes)
// 136:           return if (body_node = formula_nodes.body_node).nil?
// 137:
// 138:           find_method_with_args(body_node, :env, :userpaths) do
// 139:             problem "`env :userpaths` in homebrew/core formulae is deprecated"
// 140:           end
// 141:
// 142:           share_path_starts_with(body_node, T.must(@formula_name)) do |share_node|
// 143:             offending_node(share_node)
// 144:             problem "Use `pkgshare` instead of `share/\"#{@formula_name}\"`"
// 145:           end
// 146:
// 147:           interpolated_share_path_starts_with(body_node, "/#{@formula_name}") do |share_node|
// 148:             offending_node(share_node)
// 149:             problem "Use `\#{pkgshare}` instead of `\#{share}/#{@formula_name}`"
// 150:           end
// 151:
// 152:           interpolated_bin_path_starts_with(body_node, "/#{@formula_name}") do |bin_node|
// 153:             next if bin_node.ancestors.any?(&:array_type?)
// 154:
// 155:             offending_node(bin_node)
// 156:             cmd = bin_node.source.match(%r{\#{bin}/(\S+)})[1]&.delete_suffix('"') || @formula_name
// 157:             problem "Use `bin/\"#{cmd}\"` instead of `\"\#{bin}/#{cmd}\"`" do |corrector|
// 158:               corrector.replace(bin_node.loc.expression, "bin/\"#{cmd}\"")
// 159:             end
// 160:           end
// 161:
// 162:           return if formula_tap != "homebrew-core"
// 163:
// 164:           find_method_with_args(body_node, :env, :std) do
// 165:             problem "`env :std` in homebrew/core formulae is deprecated"
// 166:           end
// 167:         end
// 168:
// 169:         # Check whether value starts with the formula name and then a "/", " " or EOS.
// 170:         # If we're checking for "#\\{bin}", we also check for "-" b/c similar binaries don't also need interpolation.
// 171:         sig { params(path: String, starts_with: String, bin: T::Boolean).returns(T::Boolean) }
// 172:         def path_starts_with?(path, starts_with, bin: false)
// 173:           ending = bin ? "/|-|$" : "/| |$"
// 174:           path.match?(/^#{Regexp.escape(starts_with)}(#{ending})/)
// 175:         end
// 176:
// 177:         sig { params(path: String, starts_with: String).returns(T::Boolean) }
// 178:         def path_starts_with_bin?(path, starts_with)
// 179:           return false if path.include?(" ")
// 180:
// 181:           path_starts_with?(path, starts_with, bin: true)
// 182:         end
// 183:
// 184:         # Find "#{share}/foo"
// 185:         def_node_search :interpolated_share_path_starts_with, <<~EOS
// 186:           $(dstr (begin (send nil? :share)) (str #path_starts_with?(%1)))
// 187:         EOS
// 188:
// 189:         # Find "#{bin}/foo" and "#{bin}/foo-bar"
// 190:         def_node_search :interpolated_bin_path_starts_with, <<~EOS
// 191:           $(dstr (begin (send nil? :bin)) (str #path_starts_with_bin?(%1)))
// 192:         EOS
// 193:
// 194:         # Find share/"foo"
// 195:         def_node_search :share_path_starts_with, <<~EOS
// 196:           $(send (send nil? :share) :/ (str #path_starts_with?(%1)))
// 197:         EOS
// 198:       end
// 199:     end
// 200:   end
// 201: end
