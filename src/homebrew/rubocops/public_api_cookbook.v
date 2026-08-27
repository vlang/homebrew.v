module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/public_api_cookbook.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_new_investigation` at line 27.
pub fn ruby_public_api_cookbook_l27_d1_on_new_investigation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_new_investigation', ...args)
}

// Ruby attr_reader `match = target_line.match(/\A(?:def\s+(?:self\.)?|attr_reader\s+:|attr_accessor\s+:)(\w+[!?]?)/) ||` at line 81.
pub fn ruby_public_api_cookbook_l81_d2_attr_reader_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_reader_dynamic', ...args)
}

// Ruby method `build_api_public_targets` at line 102.
pub fn ruby_public_api_cookbook_l102_d3_build_api_public_targets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_api_public_targets', ...args)
}

// Ruby method `check_cookbook_methods(cookbook_methods, cookbook_name, relative_path, api_public_targets)` at line 145.
pub fn ruby_public_api_cookbook_l145_d4_check_cookbook_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_cookbook_methods', ...args)
}

// Ruby attr_reader `next unless [:attr_reader, :attr_accessor].include?(node.method_name)` at line 156.
pub fn ruby_public_api_cookbook_l156_d5_attr_accessor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_accessor]', ...args)
}

// Ruby method `check_service_cookbook_list` at line 182.
pub fn ruby_public_api_cookbook_l182_d6_check_service_cookbook_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_service_cookbook_list', ...args)
}

// Ruby method `check_service_methods(relative_path, api_public_targets)` at line 206.
pub fn ruby_public_api_cookbook_l206_d7_check_service_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_service_methods', ...args)
}

// Ruby method `parse_service_block_table` at line 225.
pub fn ruby_public_api_cookbook_l225_d8_parse_service_block_table(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_service_block_table', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/api_annotation_helper"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Homebrew
// 9:       # Ensures that methods and DSL calls documented in the Formula Cookbook
// 10:       # or Cask Cookbook are annotated with `@api public` in their source
// 11:       # definitions.
// 12:       #
// 13:       # Both cookbook method lists live in {ApiAnnotationHelper} and are
// 14:       # validated by this cop.
// 15:       class PublicApiCookbook < Base
// 16:         MSG = "Method `%<method>s` is referenced in the %<cookbook>s but is not annotated with `@api public`."
// 17:         MISSING_FORMULA_LIST_MSG = "Formula Cookbook references methods missing from " \
// 18:                                    "`FORMULA_COOKBOOK_METHODS`: %<methods>s."
// 19:         MISSING_CASK_LIST_MSG = "Method `%<method>s` is annotated with `@api public` in `%<file>s` but is " \
// 20:                                 "missing from `CASK_COOKBOOK_METHODS`."
// 21:         MISSING_SERVICE_LIST_MSG = "Method `%<method>s` is annotated with `@api public` in `service.rb` but is " \
// 22:                                    "missing from the Formula Cookbook's \"Service block methods\" table."
// 23:         MISMATCHED_SERVICE_LIST_MSG = "`SERVICE_COOKBOOK_METHODS` is out of sync with the Formula Cookbook's " \
// 24:                                       "\"Service block methods\" table: %<diff>s."
// 25:
// 26:         sig { void }
// 27:         def on_new_investigation
// 28:           super
// 29:
// 30:           file_path = processed_source.file_path
// 31:           return if file_path.nil?
// 32:
// 33:           relative_path = file_path.sub(%r{.*/Library/Homebrew/}, "")
// 34:
// 35:           if relative_path == "rubocops/shared/api_annotation_helper.rb"
// 36:             missing_formula = (HOMEBREW_LIBRARY_PATH.parent.parent/"docs/Formula-Cookbook.md").read
// 37:                               .scan(
// 38:                                 %r{/rubydoc/\w+(?:/\w+)*\.html#(\w+[!?]?)-(?:class|instance)_method},
// 39:                               )
// 40:                               .flatten -
// 41:                               ApiAnnotationHelper::FORMULA_COOKBOOK_METHODS.keys
// 42:             missing_formula.sort!
// 43:
// 44:             if missing_formula.any?
// 45:               add_offense(
// 46:                 processed_source.ast&.each_descendant(:casgn)&.find do |node|
// 47:                   node.const_name == "FORMULA_COOKBOOK_METHODS"
// 48:                 end || processed_source.ast || processed_source.buffer.source_range,
// 49:                 message: format(
// 50:                   MISSING_FORMULA_LIST_MSG,
// 51:                   methods: missing_formula.map { |method| "`#{method}`" }.join(", "),
// 52:                 ),
// 53:               )
// 54:             end
// 55:
// 56:             check_service_cookbook_list
// 57:
// 58:             return
// 59:           end
// 60:
// 61:           api_public_targets = build_api_public_targets
// 62:
// 63:           check_cookbook_methods(ApiAnnotationHelper::FORMULA_COOKBOOK_METHODS,
// 64:                                  "Formula Cookbook", relative_path, api_public_targets)
// 65:           check_cookbook_methods(ApiAnnotationHelper::CASK_COOKBOOK_METHODS,
// 66:                                  "Cask Cookbook", relative_path, api_public_targets)
// 67:           check_service_methods(relative_path, api_public_targets)
// 68:
// 69:           return unless %w[cask/dsl.rb cask/cask.rb cask/dsl/version.rb].include?(relative_path)
// 70:
// 71:           cookbook_methods = ApiAnnotationHelper::CASK_COOKBOOK_METHODS.keys.to_set
// 72:           lines = processed_source.lines
// 73:
// 74:           processed_source.comments.each do |comment|
// 75:             next unless ["# @api public", "@api public"].include?(comment.text.strip)
// 76:
// 77:             (1..5).each do |offset|
// 78:               target_line = lines[comment.loc.line - 1 + offset]&.strip
// 79:               break if target_line.blank?
// 80:
// 81:               match = target_line.match(/\A(?:def\s+(?:self\.)?|attr_reader\s+:|attr_accessor\s+:)(\w+[!?]?)/) ||
// 82:                       target_line.match(/\Adelegate\s+(\w+[!?]?):/)
// 83:               next if match.nil?
// 84:
// 85:               method_name = match[1].to_s
// 86:               break if cookbook_methods.include?(method_name)
// 87:
// 88:               add_offense(comment, message: format(MISSING_CASK_LIST_MSG, method: method_name, file: relative_path))
// 89:               break
// 90:             end
// 91:           end
// 92:         end
// 93:
// 94:         private
// 95:
// 96:         # Build a set of line numbers for definitions that are directly
// 97:         # preceded by an `@api public` annotation in their doc block.
// 98:         # Walks forward from each `@api public` comment to find the next
// 99:         # def/attr_reader/delegate, matching only the immediately following
// 100:         # definition; not one 20 lines away.
// 101:         sig { returns(T::Set[Integer]) }
// 102:         def build_api_public_targets
// 103:           targets = T.let(Set.new, T::Set[Integer])
// 104:           lines = processed_source.lines
// 105:
// 106:           processed_source.comments.each do |comment|
// 107:             text = comment.text.strip
// 108:             next if text != "# @api public" && text != "@api public"
// 109:
// 110:             # Scan forward from the annotation to find the definition it applies to.
// 111:             # Skip blank lines, comments, and sig blocks (including multi-line).
// 112:             line_idx = comment.loc.line # 1-based; lines array is 0-based
// 113:             in_sig = T.let(false, T::Boolean)
// 114:             (1..15).each do |offset|
// 115:               target_line = lines[line_idx - 1 + offset]&.strip
// 116:               break if target_line.nil?
// 117:               next if target_line.empty? || target_line.start_with?("#")
// 118:
// 119:               if target_line.match?(/(?:\A|\.|\})sig[\s({]/)
// 120:                 in_sig = !target_line.include?("}")
// 121:                 next
// 122:               end
// 123:
// 124:               if in_sig
// 125:                 in_sig = !target_line.include?("}")
// 126:                 next
// 127:               end
// 128:
// 129:               targets.add(line_idx + offset)
// 130:               break
// 131:             end
// 132:           end
// 133:
// 134:           targets
// 135:         end
// 136:
// 137:         sig {
// 138:           params(
// 139:             cookbook_methods:   T::Hash[String, String],
// 140:             cookbook_name:      String,
// 141:             relative_path:      String,
// 142:             api_public_targets: T::Set[Integer],
// 143:           ).void
// 144:         }
// 145:         def check_cookbook_methods(cookbook_methods, cookbook_name, relative_path, api_public_targets)
// 146:           relevant_methods = cookbook_methods.select { |_, file| file == relative_path }
// 147:           return if relevant_methods.empty?
// 148:
// 149:           method_names = relevant_methods.keys.to_set
// 150:
// 151:           processed_source.ast&.each_descendant(:def, :defs, :send) do |node|
// 152:             method_name = case node.type
// 153:             when :def, :defs
// 154:               node.method_name.to_s
// 155:             when :send
// 156:               next unless [:attr_reader, :attr_accessor].include?(node.method_name)
// 157:
// 158:               node.arguments.each do |arg|
// 159:                 next unless arg.sym_type?
// 160:
// 161:                 attr_name = arg.value.to_s
// 162:                 next unless method_names.include?(attr_name)
// 163:                 next if api_public_targets.include?(node.loc.line)
// 164:
// 165:                 add_offense(node,
// 166:                             message: format(MSG, method: attr_name, cookbook: cookbook_name))
// 167:               end
// 168:               next
// 169:             end
// 170:
// 171:             next if method_name.nil?
// 172:             next unless method_names.include?(method_name)
// 173:             next if api_public_targets.include?(node.loc.line)
// 174:
// 175:             add_offense(node, message: format(MSG, method: method_name, cookbook: cookbook_name))
// 176:           end
// 177:         end
// 178:
// 179:         # Ensure `SERVICE_COOKBOOK_METHODS` stays a 1:1 mirror of the cookbook's
// 180:         # "Service block methods" table.
// 181:         sig { void }
// 182:         def check_service_cookbook_list
// 183:           table = parse_service_block_table
// 184:           list = ApiAnnotationHelper::SERVICE_COOKBOOK_METHODS
// 185:           return if table == list
// 186:
// 187:           diff = []
// 188:           if (missing_from_list = (table - list).to_a.sort).any?
// 189:             diff << "missing from the list: #{missing_from_list.map { |m| "`#{m}`" }.join(", ")}"
// 190:           end
// 191:           if (missing_from_table = (list - table).to_a.sort).any?
// 192:             diff << "not in the cookbook table: #{missing_from_table.map { |m| "`#{m}`" }.join(", ")}"
// 193:           end
// 194:
// 195:           node = processed_source.ast&.each_descendant(:casgn)&.find do |casgn|
// 196:             casgn.const_name == "SERVICE_COOKBOOK_METHODS"
// 197:           end
// 198:           add_offense(node || processed_source.ast || processed_source.buffer.source_range,
// 199:                       message: format(MISMATCHED_SERVICE_LIST_MSG, diff: diff.join("; ")))
// 200:         end
// 201:
// 202:         # Cross-check `service.rb`'s `@api public` annotations against the
// 203:         # "Service block methods" table: every documented method must be
// 204:         # `@api public` and every `@api public` method must be documented.
// 205:         sig { params(relative_path: String, api_public_targets: T::Set[Integer]).void }
// 206:         def check_service_methods(relative_path, api_public_targets)
// 207:           return if relative_path != "service.rb"
// 208:
// 209:           documented = ApiAnnotationHelper::SERVICE_COOKBOOK_METHODS
// 210:           processed_source.ast&.each_descendant(:def, :defs) do |node|
// 211:             method_name = node.method_name.to_s
// 212:             annotated = api_public_targets.include?(node.loc.line)
// 213:
// 214:             if documented.include?(method_name) && !annotated
// 215:               add_offense(node, message: format(MSG, method: method_name, cookbook: "Formula Cookbook"))
// 216:             elsif annotated && !documented.include?(method_name)
// 217:               add_offense(node, message: format(MISSING_SERVICE_LIST_MSG, method: method_name))
// 218:             end
// 219:           end
// 220:         end
// 221:
// 222:         # Method names in the first (backticked) column of the "Service block
// 223:         # methods" table in docs/Formula-Cookbook.md.
// 224:         sig { returns(T::Set[String]) }
// 225:         def parse_service_block_table
// 226:           path = HOMEBREW_LIBRARY_PATH.parent.parent/"docs/Formula-Cookbook.md"
// 227:           return Set.new unless path.exist?
// 228:
// 229:           lines = path.readlines
// 230:           start = lines.index { |line| line.start_with?("#### Service block methods") }
// 231:           return Set.new if start.nil?
// 232:
// 233:           rest = lines[(start + 1)..] || []
// 234:           finish = rest.index { |line| line.start_with?("#") } || rest.length
// 235:           rest[0, finish].filter_map { |line| line[/\A\|\s*`([^`]+)`/, 1] }.to_set
// 236:         end
// 237:       end
// 238:     end
// 239:   end
// 240: end
