module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/urls.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 16.
pub fn ruby_urls_l16_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 66.
pub fn ruby_urls_l66_d2_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 105.
pub fn ruby_urls_l105_d3_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `get_pypi_url(url)` at line 126.
pub fn ruby_urls_l126_d4_get_pypi_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_pypi_url', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 136.
pub fn ruby_urls_l136_d5_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby def_node_matcher `def_node_matcher :url_has_revision?, <<~EOS` at line 149.
pub fn ruby_urls_l149_d6_url_has_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url_has_revision?', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 159.
pub fn ruby_urls_l159_d7_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby def_node_matcher `def_node_matcher :url_has_tag?, <<~EOS` at line 172.
pub fn ruby_urls_l172_d8_url_has_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url_has_tag?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/url_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # This cop audits `url`s and `mirror`s in formulae.
// 11:       class Urls < FormulaCop
// 12:         include UrlHelper
// 13:         extend AutoCorrector
// 14:
// 15:         sig { override.params(formula_nodes: FormulaNodes).void }
// 16:         def audit_formula(formula_nodes)
// 17:           return if (body_node = formula_nodes.body_node).nil?
// 18:
// 19:           urls = find_every_func_call_by_name(body_node, :url)
// 20:           mirrors = find_every_func_call_by_name(body_node, :mirror)
// 21:
// 22:           # Identify livecheck URLs, to skip some checks for them
// 23:           livecheck_urls = []
// 24:           find_every_func_call_by_name(body_node, :livecheck).each do |livecheck_node|
// 25:             livecheck_url = find_every_func_call_by_name(livecheck_node.parent, :url).first
// 26:             next unless livecheck_url
// 27:
// 28:             livecheck_url_argument = parameters(livecheck_url).first
// 29:             next unless livecheck_url_argument
// 30:             next if livecheck_url_argument.type == :sym
// 31:
// 32:             livecheck_urls << string_content(livecheck_url_argument)
// 33:           end
// 34:
// 35:           audit_url(:formula, urls, mirrors, livecheck_urls:)
// 36:
// 37:           return if formula_tap != "homebrew-core"
// 38:
// 39:           # Check for binary URLs
// 40:           binary_package_pattern = /(darwin|macos|osx)/i
// 41:           github_pattern = %r{^https://github\.com/[\w-]+/[\w.-]+/(.*)$}i
// 42:           audit_urls(urls, binary_package_pattern) do |match, url|
// 43:             next if T.must(@formula_name).include?(match.to_s.downcase)
// 44:             next if url.match?(/.(patch|diff)(\?full_index=1)?$/)
// 45:             next if url.match(github_pattern)&.then do |match_data|
// 46:               # For GitHub URLs, the username and repository name have no
// 47:               # bearing on whether a file is a binary package. We'll extract the
// 48:               # remainder of the URL and match against the binary pattern.
// 49:               # See: https://github.com/Homebrew/brew/pull/23236
// 50:               !match_data[1].match?(binary_package_pattern)
// 51:             end
// 52:             next if tap_style_exception? :not_a_binary_url_prefix_allowlist
// 53:             next if tap_style_exception? :binary_bootstrap_formula_urls_allowlist
// 54:
// 55:             problem "#{url} looks like a binary package, not a source archive; " \
// 56:                     "homebrew/core is source-only."
// 57:           end
// 58:         end
// 59:       end
// 60:
// 61:       # This cop makes sure that `url`s use HTTPS.
// 62:       class HttpUrls < FormulaCop
// 63:         extend AutoCorrector
// 64:
// 65:         sig { override.params(formula_nodes: FormulaNodes).void }
// 66:         def audit_formula(formula_nodes)
// 67:           return if (body_node = formula_nodes.body_node).nil?
// 68:           return if formula_tap != "homebrew-core"
// 69:           # TODO: Remove the deprecated/disabled check after homebrew/core has no more
// 70:           # deprecated/disabled formulae using http:// URLs
// 71:           return if method_called_ever?(body_node, :deprecate!) || method_called_ever?(body_node, :disable!)
// 72:
// 73:           # Identify livecheck URLs, to skip checking them
// 74:           livecheck_urls = []
// 75:           find_every_func_call_by_name(body_node, :livecheck).each do |livecheck_node|
// 76:             livecheck_url = find_every_func_call_by_name(livecheck_node.parent, :url).first
// 77:             next unless livecheck_url
// 78:
// 79:             livecheck_url_argument = parameters(livecheck_url).first
// 80:             next unless livecheck_url_argument
// 81:             next if livecheck_url_argument.type == :sym
// 82:
// 83:             livecheck_urls << string_content(livecheck_url_argument)
// 84:           end
// 85:
// 86:           find_every_func_call_by_name(body_node, :url).each do |url_node|
// 87:             url_string_node = parameters(url_node).first
// 88:             next unless url_string_node
// 89:
// 90:             url_string = string_content(url_string_node)
// 91:             next unless url_string.start_with?("http://")
// 92:             next if livecheck_urls.include?(url_string)
// 93:
// 94:             offending_node(url_string_node)
// 95:             problem "Formulae in homebrew/core should not use http:// URLs" do |corrector|
// 96:               corrector.replace(url_string_node.source_range, url_string_node.source.sub("http://", "https://"))
// 97:             end
// 98:           end
// 99:         end
// 100:       end
// 101:
// 102:       # This cop makes sure that the correct format for PyPI URLs is used.
// 103:       class PyPiUrls < FormulaCop
// 104:         sig { override.params(formula_nodes: FormulaNodes).void }
// 105:         def audit_formula(formula_nodes)
// 106:           return if (body_node = formula_nodes.body_node).nil?
// 107:
// 108:           urls = find_every_func_call_by_name(body_node, :url)
// 109:           mirrors = find_every_func_call_by_name(body_node, :mirror)
// 110:           urls += mirrors
// 111:
// 112:           # Check pypi URLs
// 113:           pypi_pattern = %r{^https?://pypi\.python\.org/}
// 114:           audit_urls(urls, pypi_pattern) do |_, url|
// 115:             problem "Use the \"Source\" URL found on the PyPI downloads page (#{get_pypi_url(url)})"
// 116:           end
// 117:
// 118:           # Require long files.pythonhosted.org URLs
// 119:           pythonhosted_pattern = %r{^https?://files\.pythonhosted\.org/packages/source/}
// 120:           audit_urls(urls, pythonhosted_pattern) do |_, url|
// 121:             problem "Use the \"Source\" URL found on the PyPI downloads page (#{get_pypi_url(url)})"
// 122:           end
// 123:         end
// 124:
// 125:         sig { params(url: String).returns(String) }
// 126:         def get_pypi_url(url)
// 127:           package_file = File.basename(url)
// 128:           package_name = T.must(package_file.match(/^(.+)-[a-z0-9.]+$/))[1]
// 129:           "https://pypi.org/project/#{package_name}/#files"
// 130:         end
// 131:       end
// 132:
// 133:       # This cop makes sure that git URLs have a `revision`.
// 134:       class GitUrls < FormulaCop
// 135:         sig { override.params(formula_nodes: FormulaNodes).void }
// 136:         def audit_formula(formula_nodes)
// 137:           return if (body_node = formula_nodes.body_node).nil?
// 138:           return if formula_tap != "homebrew-core"
// 139:
// 140:           find_method_calls_by_name(body_node, :url).each do |url|
// 141:             next unless string_content(parameters(url).fetch(0)).match?(/\.git$/)
// 142:             next if url_has_revision?(parameters(url).fetch(-1))
// 143:
// 144:             offending_node(url)
// 145:             problem "Formulae in homebrew/core should specify a revision for Git URLs"
// 146:           end
// 147:         end
// 148:
// 149:         def_node_matcher :url_has_revision?, <<~EOS
// 150:           (hash <(pair (sym :revision) str) ...>)
// 151:         EOS
// 152:       end
// 153:     end
// 154:
// 155:     module FormulaAuditStrict
// 156:       # This cop makes sure that git URLs have a `tag`.
// 157:       class GitUrls < FormulaCop
// 158:         sig { override.params(formula_nodes: FormulaNodes).void }
// 159:         def audit_formula(formula_nodes)
// 160:           return if (body_node = formula_nodes.body_node).nil?
// 161:           return if formula_tap != "homebrew-core"
// 162:
// 163:           find_method_calls_by_name(body_node, :url).each do |url|
// 164:             next unless string_content(parameters(url).fetch(0)).match?(/\.git$/)
// 165:             next if url_has_tag?(parameters(url).fetch(-1))
// 166:
// 167:             offending_node(url)
// 168:             problem "Formulae in homebrew/core should specify a tag for Git URLs"
// 169:           end
// 170:         end
// 171:
// 172:         def_node_matcher :url_has_tag?, <<~EOS
// 173:           (hash <(pair (sym :tag) str) ...>)
// 174:         EOS
// 175:       end
// 176:     end
// 177:   end
// 178: end
