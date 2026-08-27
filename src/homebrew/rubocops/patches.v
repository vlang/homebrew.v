module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/patches.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 17.
pub fn ruby_patches_l17_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `patch_problems(patch_url_node, sha256_node)` at line 58.
pub fn ruby_patches_l58_d2_patch_problems(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_problems', ...args)
}

// Ruby method `resolves_problems(node)` at line 143.
pub fn ruby_patches_l143_d3_resolves_problems(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolves_problems', ...args)
}

// Ruby method `type_problems(node)` at line 168.
pub fn ruby_patches_l168_d4_type_problems(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type_problems', ...args)
}

// Ruby method `inline_patch_problems(patch)` at line 176.
pub fn ruby_patches_l176_d5_inline_patch_problems(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inline_patch_problems', ...args)
}

// Ruby def_node_search `def_node_search :patch_data?, <<~AST` at line 183.
pub fn ruby_patches_l183_d6_patch_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_data?', ...args)
}

// Ruby method `patch_end?` at line 188.
pub fn ruby_patches_l188_d7_patch_end(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_end?', ...args)
}

// Ruby method `offending_patch_end_node(node)` at line 193.
pub fn ruby_patches_l193_d8_offending_patch_end_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('offending_patch_end_node', ...args)
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
// 9:       # This cop audits `patch`es in formulae.
// 10:       class Patches < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         # Keep in sync with `Patch::TYPES` in `Library/Homebrew/patch.rb`.
// 14:         PATCH_TYPES = [:unofficial, :backport, :cherry_pick].freeze
// 15:
// 16:         sig { override.params(formula_nodes: FormulaNodes).void }
// 17:         def audit_formula(formula_nodes)
// 18:           node = formula_nodes.node
// 19:           @full_source_content = T.let(source_buffer(node).source, T.nilable(String))
// 20:
// 21:           return if (body_node = formula_nodes.body_node).nil?
// 22:
// 23:           external_patches = find_all_blocks(body_node, :patch)
// 24:           external_patches.each do |patch_block|
// 25:             find_every_method_call_by_name(patch_block, :url).each do |url_node|
// 26:               url_string = parameters(url_node).fetch(0)
// 27:               sha256_node = find_every_method_call_by_name(patch_block, :sha256).first
// 28:               sha256_string = parameters(sha256_node).first if sha256_node
// 29:               patch_problems(url_string, sha256_string)
// 30:             end
// 31:             find_every_method_call_by_name(patch_block, :resolves).each do |resolves_node|
// 32:               parameters(resolves_node).each { |arg| resolves_problems(arg) }
// 33:             end
// 34:             find_every_method_call_by_name(patch_block, :type).each do |type_node|
// 35:               parameters(type_node).each { |arg| type_problems(arg) }
// 36:             end
// 37:           end
// 38:
// 39:           inline_patches = find_every_method_call_by_name(body_node, :patch)
// 40:           inline_patches.each { |patch| inline_patch_problems(patch) }
// 41:
// 42:           if inline_patches.empty? && patch_end?
// 43:             offending_patch_end_node(node)
// 44:             add_offense(@offense_source_range, message: "Patch is missing `patch :DATA`")
// 45:           end
// 46:
// 47:           patches_node = find_method_def(body_node, :patches)
// 48:           return if patches_node.nil?
// 49:
// 50:           legacy_patches = find_strings(patches_node)
// 51:           problem "Use the `patch` DSL instead of defining a `patches` method"
// 52:           legacy_patches.each { |p| patch_problems(p, nil) }
// 53:         end
// 54:
// 55:         private
// 56:
// 57:         sig { params(patch_url_node: RuboCop::AST::Node, sha256_node: T.nilable(RuboCop::AST::Node)).void }
// 58:         def patch_problems(patch_url_node, sha256_node)
// 59:           patch_url = string_content(patch_url_node)
// 60:
// 61:           if regex_match_group(patch_url_node, %r{https://github.com/[^/]*/[^/]*/pull})
// 62:             problem "Use a commit hash URL rather than an unstable pull request URL: #{patch_url}"
// 63:           end
// 64:
// 65:           if regex_match_group(patch_url_node, %r{.*gitlab.*/merge_request.*})
// 66:             problem "Use a commit hash URL rather than an unstable merge request URL: #{patch_url}"
// 67:           end
// 68:
// 69:           if regex_match_group(patch_url_node, %r{https://github.com/[^/]*/[^/]*/commit/[a-fA-F0-9]*\.diff})
// 70:             problem "GitHub patches should end with .patch, not .diff: #{patch_url}" do |corrector|
// 71:               # Replace .diff with .patch, keeping either the closing quote or query parameter start
// 72:               correct = patch_url_node.source.sub(/\.diff(["?])/, '.patch\1')
// 73:               corrector.replace(patch_url_node.source_range, correct)
// 74:               corrector.replace(sha256_node.source_range, '""') if sha256_node
// 75:             end
// 76:           end
// 77:
// 78:           bitbucket_regex = %r{bitbucket\.org/([^/]+)/([^/]+)/commits/([a-f0-9]+)/raw}i
// 79:           if regex_match_group(patch_url_node, bitbucket_regex)
// 80:             owner, repo, commit = patch_url_node.source.match(bitbucket_regex).captures
// 81:             correct_url = "https://api.bitbucket.org/2.0/repositories/#{owner}/#{repo}/diff/#{commit}"
// 82:             problem "Bitbucket patches should use the API URL: #{correct_url}" do |corrector|
// 83:               corrector.replace(patch_url_node.source_range, %Q("#{correct_url}"))
// 84:               corrector.replace(sha256_node.source_range, '""') if sha256_node
// 85:             end
// 86:           end
// 87:
// 88:           # Only .diff passes `--full-index` to `git diff` and there is no documented way
// 89:           # to get .patch to behave the same for GitLab.
// 90:           if regex_match_group(patch_url_node, %r{.*gitlab.*/commit/[a-fA-F0-9]*\.patch})
// 91:             problem "GitLab patches should end with .diff, not .patch: #{patch_url}" do |corrector|
// 92:               # Replace .patch with .diff, keeping either the closing quote or query parameter start
// 93:               correct = patch_url_node.source.sub(/\.patch(["?])/, '.diff\1')
// 94:               corrector.replace(patch_url_node.source_range, correct)
// 95:               corrector.replace(sha256_node.source_range, '""') if sha256_node
// 96:             end
// 97:           end
// 98:
// 99:           gh_patch_param_pattern = %r{https?://github\.com/.+/.+/(?:commit|pull)/[a-fA-F0-9]*.(?:patch|diff)}
// 100:           if regex_match_group(patch_url_node, gh_patch_param_pattern) && !patch_url.match?(/\?full_index=\w+$/)
// 101:             problem "GitHub patches should use the full_index parameter: #{patch_url}?full_index=1" do |corrector|
// 102:               correct = patch_url_node.source.sub(/"$/, '?full_index=1"')
// 103:               corrector.replace(patch_url_node.source_range, correct)
// 104:               corrector.replace(sha256_node.source_range, '""') if sha256_node
// 105:             end
// 106:           end
// 107:
// 108:           gh_patch_patterns = Regexp.union([%r{/raw\.github\.com/},
// 109:                                             %r{/raw\.githubusercontent\.com/},
// 110:                                             %r{gist\.github\.com/raw},
// 111:                                             %r{gist\.github\.com/.+/raw},
// 112:                                             %r{gist\.githubusercontent\.com/.+/raw}])
// 113:           if regex_match_group(patch_url_node, gh_patch_patterns) && !patch_url.match?(%r{/[a-fA-F0-9]{6,40}/})
// 114:             problem "GitHub/Gist patches should specify a revision: #{patch_url}"
// 115:           end
// 116:
// 117:           gh_patch_diff_pattern =
// 118:             %r{https?://patch-diff\.githubusercontent\.com/raw/(.+)/(.+)/pull/(.+)\.(?:diff|patch)}
// 119:           if regex_match_group(patch_url_node, gh_patch_diff_pattern)
// 120:             problem "Use a commit hash URL rather than patch-diff: #{patch_url}"
// 121:           end
// 122:
// 123:           if regex_match_group(patch_url_node, %r{macports/trunk})
// 124:             problem "MacPorts patches should specify a revision instead of trunk: #{patch_url}"
// 125:           end
// 126:
// 127:           if regex_match_group(patch_url_node, %r{^http://trac\.macports\.org})
// 128:             problem "Patches from MacPorts Trac should be https://, not http: #{patch_url}" do |corrector|
// 129:               corrector.replace(patch_url_node.source_range,
// 130:                                 patch_url_node.source.sub(%r{\A"http://}, '"https://'))
// 131:             end
// 132:           end
// 133:
// 134:           return unless regex_match_group(patch_url_node, %r{^http://bugs\.debian\.org})
// 135:
// 136:           problem "Patches from Debian should be https://, not http: #{patch_url}" do |corrector|
// 137:             corrector.replace(patch_url_node.source_range,
// 138:                               patch_url_node.source.sub(%r{\A"http://}, '"https://'))
// 139:           end
// 140:         end
// 141:
// 142:         sig { params(node: RuboCop::AST::Node).void }
// 143:         def resolves_problems(node)
// 144:           unless node.str_type?
// 145:             offending_node(node)
// 146:             problem "`resolves` should be passed identifier strings (CVE/GHSA/OSV id or issue URL)"
// 147:             return
// 148:           end
// 149:
// 150:           value = string_content(node)
// 151:           return if value.match?(/\ACVE-\d{4}-\d{4,}\z/)
// 152:           return if value.match?(/\AGHSA(-[23456789cfghjmpqrvwx]{4}){3}\z/)
// 153:           return if value.match?(/\AOSV-\d{4}-\d+\z/)
// 154:           return if value.match?(%r{\Ahttps?://})
// 155:
// 156:           offending_node(node)
// 157:           if (m = value.match(/\ACVE-?(\d{4})-(\d{4,})\z/i))
// 158:             corrected = "CVE-#{m[1]}-#{m[2]}"
// 159:             problem "`resolves` should use the canonical CVE format: #{corrected}" do |corrector|
// 160:               corrector.replace(node.source_range, corrected.inspect)
// 161:             end
// 162:           else
// 163:             problem "`resolves` should be a CVE/GHSA/OSV identifier or issue URL, got: #{value.inspect}"
// 164:           end
// 165:         end
// 166:
// 167:         sig { params(node: RuboCop::AST::Node).void }
// 168:         def type_problems(node)
// 169:           return if node.sym_type? && PATCH_TYPES.include?(T.cast(node, RuboCop::AST::SymbolNode).value)
// 170:
// 171:           offending_node(node)
// 172:           problem "Patch `type` should be one of: #{PATCH_TYPES.map(&:inspect).join(", ")}"
// 173:         end
// 174:
// 175:         sig { params(patch: RuboCop::AST::Node).void }
// 176:         def inline_patch_problems(patch)
// 177:           return if !patch_data?(patch) || patch_end?
// 178:
// 179:           offending_node(patch)
// 180:           problem "Patch is missing `__END__`"
// 181:         end
// 182:
// 183:         def_node_search :patch_data?, <<~AST
// 184:           (send nil? :patch (:sym :DATA))
// 185:         AST
// 186:
// 187:         sig { returns(T::Boolean) }
// 188:         def patch_end?
// 189:           /^__END__$/.match?(@full_source_content)
// 190:         end
// 191:
// 192:         sig { params(node: RuboCop::AST::Node).void }
// 193:         def offending_patch_end_node(node)
// 194:           @offensive_node = T.let(node, T.nilable(RuboCop::AST::Node))
// 195:           @source_buf = T.let(source_buffer(node), T.nilable(Parser::Source::Buffer))
// 196:           @line_no = T.let(node.loc.last_line + 1, T.nilable(Integer))
// 197:           @column = T.let(0, T.nilable(Integer))
// 198:           @length = T.let(7, T.nilable(Integer)) # "__END__".size
// 199:           @offense_source_range = T.let(
// 200:             source_range(@source_buf, @line_no, @column, @length),
// 201:             T.nilable(Parser::Source::Range),
// 202:           )
// 203:         end
// 204:       end
// 205:     end
// 206:   end
// 207: end
