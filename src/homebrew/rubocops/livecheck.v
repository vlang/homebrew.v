module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/livecheck.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 15.
pub fn ruby_livecheck_l15_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 45.
pub fn ruby_livecheck_l45_d2_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 69.
pub fn ruby_livecheck_l69_d3_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 128.
pub fn ruby_livecheck_l128_d4_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 156.
pub fn ruby_livecheck_l156_d5_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 184.
pub fn ruby_livecheck_l184_d6_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 213.
pub fn ruby_livecheck_l213_d7_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
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
// 9:       # This cop ensures that no other livecheck information is provided for
// 10:       # skipped formulae.
// 11:       class LivecheckSkip < FormulaCop
// 12:         extend AutoCorrector
// 13:
// 14:         sig { override.params(formula_nodes: FormulaNodes).void }
// 15:         def audit_formula(formula_nodes)
// 16:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 17:           return if livecheck_node.blank?
// 18:
// 19:           skip = T.let(find_every_method_call_by_name(livecheck_node, :skip).first,
// 20:                        T.nilable(T.any(RuboCop::AST::Node, String)))
// 21:           return if skip.blank?
// 22:
// 23:           return if find_every_method_call_by_name(livecheck_node).length < 3
// 24:
// 25:           offending_node(livecheck_node)
// 26:           problem "Skipped formulae must not contain other livecheck information." do |corrector|
// 27:             skip = find_every_method_call_by_name(livecheck_node, :skip).fetch(0)
// 28:             skip = find_strings(skip).fetch(0)
// 29:             skip = string_content(skip) if skip.present?
// 30:             corrector.replace(
// 31:               livecheck_node.source_range,
// 32:               <<~EOS.strip,
// 33:                 livecheck do
// 34:                     skip#{" \"#{skip}\"" if skip.present?}
// 35:                   end
// 36:               EOS
// 37:             )
// 38:           end
// 39:         end
// 40:       end
// 41:
// 42:       # This cop ensures that a `url` is specified in the `livecheck` block.
// 43:       class LivecheckUrlProvided < FormulaCop
// 44:         sig { override.params(formula_nodes: FormulaNodes).void }
// 45:         def audit_formula(formula_nodes)
// 46:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 47:           return unless livecheck_node
// 48:
// 49:           url_node = find_every_method_call_by_name(livecheck_node, :url).first
// 50:           return if url_node
// 51:
// 52:           # A regex and/or strategy is specific to a particular URL, so we
// 53:           # should require an explicit URL.
// 54:           regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
// 55:           strategy_node = find_every_method_call_by_name(livecheck_node, :strategy).first
// 56:           return if !regex_node && !strategy_node
// 57:
// 58:           offending_node(livecheck_node)
// 59:           problem "A `url` should be provided when `regex` or `strategy` are used."
// 60:         end
// 61:       end
// 62:
// 63:       # This cop ensures that a supported symbol (`head`, `stable, `homepage`)
// 64:       # is used when the livecheck `url` is identical to one of these formula URLs.
// 65:       class LivecheckUrlSymbol < FormulaCop
// 66:         extend AutoCorrector
// 67:
// 68:         sig { override.params(formula_nodes: FormulaNodes).void }
// 69:         def audit_formula(formula_nodes)
// 70:           body_node = formula_nodes.body_node
// 71:           livecheck_node = find_block(body_node, :livecheck)
// 72:           return if livecheck_node.blank?
// 73:
// 74:           skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
// 75:           return if skip.present?
// 76:
// 77:           livecheck_url_node = find_every_method_call_by_name(livecheck_node, :url).first
// 78:           return if livecheck_url_node.blank?
// 79:
// 80:           livecheck_url = find_strings(livecheck_url_node).first
// 81:           return if livecheck_url.blank?
// 82:
// 83:           livecheck_url = string_content(livecheck_url)
// 84:
// 85:           head = find_every_method_call_by_name(body_node, :head).first
// 86:           head_url = find_strings(head).first
// 87:
// 88:           if head.present? && head_url.blank?
// 89:             head = find_every_method_call_by_name(head, :url).first
// 90:             head_url = find_strings(head).first
// 91:           end
// 92:
// 93:           head_url = string_content(head_url) if head_url.present?
// 94:
// 95:           stable = find_every_method_call_by_name(body_node, :url).first
// 96:           stable_url = find_strings(stable).first
// 97:
// 98:           if stable_url.blank?
// 99:             stable = find_every_method_call_by_name(body_node, :stable).first
// 100:             stable = find_every_method_call_by_name(stable, :url).first
// 101:             stable_url = find_strings(stable).first
// 102:           end
// 103:
// 104:           stable_url = string_content(stable_url) if stable_url.present?
// 105:
// 106:           homepage = find_every_method_call_by_name(body_node, :homepage).first
// 107:           homepage_url = string_content(find_strings(homepage).fetch(0)) if homepage.present?
// 108:
// 109:           formula_urls = { head: head_url, stable: stable_url, homepage: homepage_url }.compact
// 110:
// 111:           formula_urls.each do |symbol, url|
// 112:             next if url != livecheck_url && url != "#{livecheck_url}/" && "#{url}/" != livecheck_url
// 113:
// 114:             offending_node(livecheck_url_node)
// 115:             problem "Use `url :#{symbol}`" do |corrector|
// 116:               corrector.replace(livecheck_url_node.source_range, "url :#{symbol}")
// 117:             end
// 118:             break
// 119:           end
// 120:         end
// 121:       end
// 122:
// 123:       # This cop ensures that the `regex` call in the `livecheck` block uses parentheses.
// 124:       class LivecheckRegexParentheses < FormulaCop
// 125:         extend AutoCorrector
// 126:
// 127:         sig { override.params(formula_nodes: FormulaNodes).void }
// 128:         def audit_formula(formula_nodes)
// 129:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 130:           return if livecheck_node.blank?
// 131:
// 132:           skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
// 133:           return if skip.present?
// 134:
// 135:           livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
// 136:           return if livecheck_regex_node.blank?
// 137:
// 138:           return if parentheses?(livecheck_regex_node)
// 139:
// 140:           offending_node(livecheck_regex_node)
// 141:           problem "The `regex` call should always use parentheses." do |corrector|
// 142:             pattern = livecheck_regex_node.source.split[1..].join
// 143:             corrector.replace(livecheck_regex_node.source_range, "regex(#{pattern})")
// 144:           end
// 145:         end
// 146:       end
// 147:
// 148:       # This cop ensures that the pattern provided to livecheck's `regex` uses `\.t` instead of
// 149:       # `\.tgz`, `\.tar.gz` and variants.
// 150:       class LivecheckRegexExtension < FormulaCop
// 151:         extend AutoCorrector
// 152:
// 153:         TAR_PATTERN = /\\?\.t(ar|(g|l|x)z$|[bz2]{2,4}$)(\\?\.((g|l|x)z)|[bz2]{2,4}|Z)?$/i
// 154:
// 155:         sig { override.params(formula_nodes: FormulaNodes).void }
// 156:         def audit_formula(formula_nodes)
// 157:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 158:           return if livecheck_node.blank?
// 159:
// 160:           skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
// 161:           return if skip.present?
// 162:
// 163:           livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
// 164:           return if livecheck_regex_node.blank?
// 165:
// 166:           regex_node = livecheck_regex_node.descendants.first
// 167:           pattern = string_content(find_strings(regex_node).fetch(0))
// 168:           match = pattern.match(TAR_PATTERN)
// 169:           return if match.blank?
// 170:
// 171:           offending_node(regex_node)
// 172:           problem "Use `\\.t` instead of `#{match}`" do |corrector|
// 173:             node = find_strings(regex_node).fetch(0)
// 174:             correct = node.source.gsub(TAR_PATTERN, "\\.t")
// 175:             corrector.replace(node.source_range, correct)
// 176:           end
// 177:         end
// 178:       end
// 179:
// 180:       # This cop ensures that a `regex` is provided when `strategy :page_match` is specified
// 181:       # in the `livecheck` block.
// 182:       class LivecheckRegexIfPageMatch < FormulaCop
// 183:         sig { override.params(formula_nodes: FormulaNodes).void }
// 184:         def audit_formula(formula_nodes)
// 185:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 186:           return if livecheck_node.blank?
// 187:
// 188:           skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
// 189:           return if skip.present?
// 190:
// 191:           livecheck_strategy_node = find_every_method_call_by_name(livecheck_node, :strategy).first
// 192:           return if livecheck_strategy_node.blank?
// 193:
// 194:           strategy = livecheck_strategy_node.descendants.first.source
// 195:           return if strategy != ":page_match"
// 196:
// 197:           livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
// 198:           return if livecheck_regex_node.present?
// 199:
// 200:           offending_node(livecheck_node)
// 201:           problem "A `regex` is required if `strategy :page_match` is present."
// 202:         end
// 203:       end
// 204:
// 205:       # This cop ensures that the `regex` provided to livecheck is case-insensitive,
// 206:       # unless sensitivity is explicitly required for proper matching.
// 207:       class LivecheckRegexCaseInsensitive < FormulaCop
// 208:         extend AutoCorrector
// 209:
// 210:         MSG = "Regexes should be case-insensitive unless sensitivity is explicitly required for proper matching."
// 211:
// 212:         sig { override.params(formula_nodes: FormulaNodes).void }
// 213:         def audit_formula(formula_nodes)
// 214:           return if tap_style_exception? :regex_case_sensitive_allowlist
// 215:
// 216:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 217:           return if livecheck_node.blank?
// 218:
// 219:           skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
// 220:           return if skip.present?
// 221:
// 222:           livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
// 223:           return if livecheck_regex_node.blank?
// 224:
// 225:           regex_node = livecheck_regex_node.descendants.first
// 226:           options_node = regex_node.regopt
// 227:           return if options_node.source.include?("i")
// 228:
// 229:           offending_node(regex_node)
// 230:           problem MSG do |corrector|
// 231:             node = regex_node.regopt
// 232:             corrector.replace(node.source_range, "i#{node.source}".chars.sort.join)
// 233:           end
// 234:         end
// 235:       end
// 236:     end
// 237:   end
// 238: end
