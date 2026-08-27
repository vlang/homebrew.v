module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/unreferenced_let.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :definition_name, <<~PATTERN` at line 79.
pub fn ruby_unreferenced_let_l79_d1_definition_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('definition_name', ...args)
}

// Ruby method `on_send(node)` at line 84.
pub fn ruby_unreferenced_let_l84_d2_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `exempt_from_deletion?(name, block)` at line 109.
pub fn ruby_unreferenced_let_l109_d3_exempt_from_deletion(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exempt_from_deletion?', ...args)
}

// Ruby method `removal_range(node)` at line 125.
pub fn ruby_unreferenced_let_l125_d4_removal_range(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removal_range', ...args)
}

// Ruby method `absorbable_comment?(source_line)` at line 148.
pub fn ruby_unreferenced_let_l148_d5_absorbable_comment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('absorbable_comment?', ...args)
}

// Ruby method `blank_line?(source_line)` at line 156.
pub fn ruby_unreferenced_let_l156_d6_blank_line(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('blank_line?', ...args)
}

// Ruby method `let_or_subject_line?(source_line)` at line 163.
pub fn ruby_unreferenced_let_l163_d7_let_or_subject_line(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('let_or_subject_line?', ...args)
}

// Ruby method `preceding_sig(node)` at line 170.
pub fn ruby_unreferenced_let_l170_d8_preceding_sig(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preceding_sig', ...args)
}

// Ruby method `within_shared_definition?(node)` at line 179.
pub fn ruby_unreferenced_let_l179_d9_within_shared_definition(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('within_shared_definition?', ...args)
}

// Ruby method `consumes_shared_examples?` at line 184.
pub fn ruby_unreferenced_let_l184_d10_consumes_shared_examples(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('consumes_shared_examples?', ...args)
}

// Ruby method `dynamic_dispatch?` at line 197.
pub fn ruby_unreferenced_let_l197_d11_dynamic_dispatch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dynamic_dispatch?', ...args)
}

// Ruby method `overridden?(name)` at line 211.
pub fn ruby_unreferenced_let_l211_d12_overridden(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('overridden?', ...args)
}

// Ruby method `definitions_by_name` at line 216.
pub fn ruby_unreferenced_let_l216_d13_definitions_by_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('definitions_by_name', ...args)
}

// Ruby method `referenced?(name)` at line 232.
pub fn ruby_unreferenced_let_l232_d14_referenced(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('referenced?', ...args)
}

// Ruby method `referenced_names` at line 246.
pub fn ruby_unreferenced_let_l246_d15_referenced_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('referenced_names', ...args)
}

// Ruby method `definition_name_argument?(sym_node)` at line 273.
pub fn ruby_unreferenced_let_l273_d16_definition_name_argument(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('definition_name_argument?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocop-rspec"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Homebrew
// 9:       # Flags lazy `let` declarations whose name is never referenced. A lazy `let(:name) { ... }`
// 10:       # is only evaluated when `name` is called, so an unreferenced one is dead code -- its block
// 11:       # never runs -- and is deleted.
// 12:       #
// 13:       # Eager `let!` is intentionally out of scope: it runs its block before every example for its
// 14:       # side effect even when unreferenced, so it cannot simply be deleted. Only plain `let` is
// 15:       # handled here.
// 16:       #
// 17:       # Detection is file-scoped: a `let` referenced only from another file (through a shared
// 18:       # example or an included test harness) cannot be seen, so the cop stays conservative and
// 19:       # prefers false negatives over false positives:
// 20:       # - a name defined more than once in the file by `let`/`let!`/`subject` (an override /
// 21:       #   `super` chain, including a `subject` that overrides a `let` of the same name) is never
// 22:       #   flagged;
// 23:       # - a `let` declared lexically inside a `shared_examples` / `shared_examples_for` /
// 24:       #   `shared_context` block is skipped (its consumers live in other files);
// 25:       # - every `let` in a file that uses `it_behaves_like` / `it_should_behave_like` /
// 26:       #   `include_examples` / `include_context` is skipped, because an included shared block may
// 27:       #   reference the binding by a name we cannot follow statically;
// 28:       # - `let(:cop_config)` is skipped: it is a rubocop-rspec contract consumed by the `:config`
// 29:       #   shared context, not by a reference in the spec file; and
// 30:       # - every `let` in a file that reflectively dispatches through a name we cannot resolve
// 31:       #   statically (e.g. `send("expected_#{type}")`) is skipped, since any `let` could be the
// 32:       #   target.
// 33:       # A name counts as referenced if it is called bare (`foo`), appears as a symbol (`:foo`)
// 34:       # anywhere but the let's own name argument, or appears as an identifier-shaped token inside
// 35:       # any string/heredoc literal -- covering dynamic dispatch, `:foo` entries in data tables the
// 36:       # spec later dispatches on, and bindings named only inside raw SQL/GraphQL text.
// 37:       #
// 38:       # Because a bare `:foo` symbol anywhere counts as a reference, commonly-named lets
// 39:       # (`let(:formula)`, `let(:cask)`, `let(:id)`) are essentially never flagged. This conservative
// 40:       # bias means the cop realistically only deletes distinctively-named dead lets; it is not a
// 41:       # complete dead-`let` finder.
// 42:       #
// 43:       # ### Example
// 44:       #
// 45:       # ```ruby
// 46:       # # bad (name never referenced -- deleted, the block never runs)
// 47:       # let(:unused) { create(:thing) }
// 48:       #
// 49:       # # good
// 50:       # let(:thing) { create(:thing) }
// 51:       # it { expect(thing).to be_present }
// 52:       # ```
// 53:       class UnreferencedLet < ::RuboCop::Cop::RSpec::Base
// 54:         extend AutoCorrector
// 55:         include RangeHelp
// 56:
// 57:         DEFINITION_METHODS = [:let, :let!, :subject].freeze
// 58:         # `let`s consumed by a test framework rather than by a reference in the spec file. RuboCop's
// 59:         # own `:config` shared context (used by every cop spec) reads `cop_config`, `other_cops`,
// 60:         # `cop_options` and `gem_versions` by name from inside the framework, so they are live even
// 61:         # though the spec never names them.
// 62:         FRAMEWORK_RESERVED_NAMES = [:cop_config, :other_cops, :cop_options, :gem_versions].freeze
// 63:         # Reflective dispatch methods whose target is the first argument. When that argument is not
// 64:         # a statically-resolvable name (a `sym` or plain `str`) -- e.g. `send("expected_#{type}")` --
// 65:         # the called name cannot be known, so the whole file is left untouched.
// 66:         DYNAMIC_DISPATCH_METHODS = [:send, :public_send, :__send__, :try, :try!, :method, :public_method,
// 67:                                     :respond_to?].freeze
// 68:         # Identifier-shaped tokens inside a string/heredoc literal. A `let` whose name appears only
// 69:         # inside string text -- e.g. a binding or column referenced in raw SQL/GraphQL the spec
// 70:         # later executes -- counts as referenced, so it is not deleted.
// 71:         IDENTIFIER_IN_STRING = /[A-Za-z_]\w*[!?]?/
// 72:         MSG = "Remove unreferenced `let(:%<name>s)` -- its name is never used, so the block never runs."
// 73:         RESTRICT_ON_SEND = [:let].freeze
// 74:
// 75:         # The name symbol of any definition (`let`/`let!`/`subject`) in any block form -- used to
// 76:         # count how many times a name is defined, so override / `super` chains (including a
// 77:         # `subject` that overrides a `let` of the same name) are never flagged.
// 78:         # @!method definition_name(node)
// 79:         def_node_matcher :definition_name, <<~PATTERN
// 80:           (any_block (send nil? {#{DEFINITION_METHODS.map { |method| ":#{method}" }.join(" ")}} (sym $_) ...) ...)
// 81:         PATTERN
// 82:
// 83:         sig { params(node: RuboCop::AST::SendNode).void }
// 84:         def on_send(node)
// 85:           return unless node.receiver.nil?
// 86:
// 87:           name_argument = node.first_argument
// 88:           return unless name_argument&.sym_type?
// 89:
// 90:           block = node.block_node
// 91:           return unless block
// 92:
// 93:           name = name_argument.value
// 94:           return if exempt_from_deletion?(name, block)
// 95:
// 96:           add_offense(node.loc.selector, message: format(MSG, name:)) do |corrector|
// 97:             corrector.remove(removal_range(block))
// 98:           end
// 99:         end
// 100:
// 101:         private
// 102:
// 103:         # A lazy `let` is exempt from deletion whenever file-scoped analysis cannot prove its name
// 104:         # is dead: its name is a framework-reserved contract (e.g. `cop_config`), the file
// 105:         # dispatches through a name we cannot resolve statically, it consumes shared examples, the
// 106:         # `let` is lexically inside a shared-example definition, it is overridden by another
// 107:         # definition of the same name, or it is referenced somewhere in the file.
// 108:         sig { params(name: Symbol, block: RuboCop::AST::BlockNode).returns(T::Boolean) }
// 109:         def exempt_from_deletion?(name, block)
// 110:           FRAMEWORK_RESERVED_NAMES.include?(name) ||
// 111:             dynamic_dispatch? ||
// 112:             consumes_shared_examples? ||
// 113:             within_shared_definition?(block) ||
// 114:             overridden?(name) ||
// 115:             referenced?(name)
// 116:         end
// 117:
// 118:         # Delete the `let` block, plus:
// 119:         # - an immediately-preceding `sig { ... }` (so a Sorbet signature is not left dangling),
// 120:         # - explanatory comment lines attached directly above it (so they are not orphaned), and
// 121:         # - a single trailing blank line where removal would otherwise leave a stray/duplicate
// 122:         #   blank -- unless the line above is a `let`/`subject`, where that blank is the required
// 123:         #   separator after the now-final let and must stay.
// 124:         sig { params(node: RuboCop::AST::BlockNode).returns(Parser::Source::Range) }
// 125:         def removal_range(node)
// 126:           lines = processed_source.lines
// 127:           start_line = node.source_range.first_line
// 128:           end_line = node.source_range.last_line
// 129:
// 130:           sig = preceding_sig(node)
// 131:           start_line = sig.source_range.first_line if sig
// 132:
// 133:           start_line -= 1 while start_line > 1 && absorbable_comment?(lines[start_line - 2])
// 134:
// 135:           if end_line < lines.size && blank_line?(lines[end_line]) &&
// 136:              !(start_line > 1 && let_or_subject_line?(lines[start_line - 2]))
// 137:             end_line += 1
// 138:           end
// 139:
// 140:           buffer = processed_source.buffer
// 141:           range_by_whole_lines(
// 142:             buffer.line_range(start_line).join(buffer.line_range(end_line)),
// 143:             include_final_newline: true,
// 144:           )
// 145:         end
// 146:
// 147:         sig { params(source_line: T.nilable(String)).returns(T::Boolean) }
// 148:         def absorbable_comment?(source_line)
// 149:           return false if source_line.nil?
// 150:
// 151:           stripped = source_line.strip
// 152:           stripped.start_with?("#") && !stripped.start_with?("# rubocop:")
// 153:         end
// 154:
// 155:         sig { params(source_line: T.nilable(String)).returns(T::Boolean) }
// 156:         def blank_line?(source_line)
// 157:           return false if source_line.nil?
// 158:
// 159:           source_line.strip.empty?
// 160:         end
// 161:
// 162:         sig { params(source_line: T.nilable(String)).returns(T::Boolean) }
// 163:         def let_or_subject_line?(source_line)
// 164:           return false if source_line.nil?
// 165:
// 166:           source_line.match?(/\A\s*(?:let!?|subject)\b/)
// 167:         end
// 168:
// 169:         sig { params(node: RuboCop::AST::BlockNode).returns(T.nilable(RuboCop::AST::BlockNode)) }
// 170:         def preceding_sig(node)
// 171:           sibling = node.left_sibling
// 172:           return unless sibling.is_a?(::RuboCop::AST::BlockNode)
// 173:           return unless sibling.method?(:sig)
// 174:
// 175:           sibling
// 176:         end
// 177:
// 178:         sig { params(node: RuboCop::AST::BlockNode).returns(T::Boolean) }
// 179:         def within_shared_definition?(node)
// 180:           node.each_ancestor(:any_block).any? { |ancestor| shared_group?(ancestor) }
// 181:         end
// 182:
// 183:         sig { returns(T::Boolean) }
// 184:         def consumes_shared_examples?
// 185:           @consumes_shared_examples = T.let(@consumes_shared_examples, T.nilable(T::Boolean))
// 186:           return @consumes_shared_examples unless @consumes_shared_examples.nil?
// 187:
// 188:           ast = processed_source.ast
// 189:           @consumes_shared_examples = !ast.nil? && ast.each_node(:call).any? { |send_node| include?(send_node) }
// 190:         end
// 191:
// 192:         # True when the file reflectively dispatches through a name we cannot resolve statically --
// 193:         # `send`/`public_send`/`method`/etc. called with anything other than a `sym` or plain `str`
// 194:         # first argument (most commonly an interpolated string, `send("expected_#{type}")`). In
// 195:         # that case any `let` in the file could be the dispatch target, so none are deleted.
// 196:         sig { returns(T::Boolean) }
// 197:         def dynamic_dispatch?
// 198:           @dynamic_dispatch = T.let(@dynamic_dispatch, T.nilable(T::Boolean))
// 199:           return @dynamic_dispatch unless @dynamic_dispatch.nil?
// 200:
// 201:           ast = processed_source.ast
// 202:           @dynamic_dispatch = !ast.nil? && ast.each_node(:call).any? do |send_node|
// 203:             next false unless DYNAMIC_DISPATCH_METHODS.include?(send_node.method_name)
// 204:
// 205:             target = send_node.first_argument
// 206:             !target.nil? && !target.sym_type? && !target.str_type?
// 207:           end
// 208:         end
// 209:
// 210:         sig { params(name: Symbol).returns(T::Boolean) }
// 211:         def overridden?(name)
// 212:           definitions_by_name.fetch(name, 0) > 1
// 213:         end
// 214:
// 215:         sig { returns(T::Hash[Symbol, Integer]) }
// 216:         def definitions_by_name
// 217:           @definitions_by_name ||= T.let(
// 218:             begin
// 219:               ast = processed_source.ast
// 220:               counts = Hash.new(0)
// 221:               ast&.each_node(:any_block) do |node|
// 222:                 name = definition_name(node)
// 223:                 counts[name] += 1 if name
// 224:               end
// 225:               counts
// 226:             end,
// 227:             T.nilable(T::Hash[Symbol, Integer]),
// 228:           )
// 229:         end
// 230:
// 231:         sig { params(name: Symbol).returns(T::Boolean) }
// 232:         def referenced?(name)
// 233:           referenced_names.include?(name)
// 234:         end
// 235:
// 236:         # A name is "referenced" if it is called as a bare method (`foo`), appears as a symbol
// 237:         # literal (`:foo`) other than the let/subject's own name argument, or appears as an
// 238:         # identifier-shaped token inside any string/heredoc literal. The symbol and string cases
// 239:         # cover indirect invocation -- `send(:foo)` / `send("foo")`, a `:foo`/`"foo"` listed in a
// 240:         # data table the spec later dispatches on, or a binding named only inside raw SQL/GraphQL
// 241:         # text the spec executes -- which file-scoped analysis cannot otherwise follow. (Tokenizing
// 242:         # string bodies, rather than matching the whole string, keeps a `let` referenced only from
// 243:         # inside a multi-word heredoc from being deleted.) Interpolated-string *dispatch* is handled
// 244:         # separately by `dynamic_dispatch?`, which exempts the whole file.
// 245:         sig { returns(T::Set[Symbol]) }
// 246:         def referenced_names
// 247:           @referenced_names ||= T.let(
// 248:             begin
// 249:               ast = processed_source.ast
// 250:               names = Set.new
// 251:               ast&.each_node(:sym, :str, :call) do |node|
// 252:                 if node.sym_type?
// 253:                   names << node.value unless definition_name_argument?(node)
// 254:                 elsif node.str_type?
// 255:                   # A string with invalid encoding (e.g. a deliberate bad-UTF-8 test fixture) cannot
// 256:                   # contain an identifier-shaped reference and would raise on `scan`, so skip it.
// 257:                   if node.value.valid_encoding?
// 258:                     node.value.scan(IDENTIFIER_IN_STRING) do |token|
// 259:                       names << token.to_sym
// 260:                     end
// 261:                   end
// 262:                 elsif node.receiver.nil? && node.arguments.empty?
// 263:                   names << node.method_name
// 264:                 end
// 265:               end
// 266:               names
// 267:             end,
// 268:             T.nilable(T::Set[Symbol]),
// 269:           )
// 270:         end
// 271:
// 272:         sig { params(sym_node: RuboCop::AST::Node).returns(T::Boolean) }
// 273:         def definition_name_argument?(sym_node)
// 274:           parent = sym_node.parent
// 275:           return false if parent.nil? || !parent.send_type? || !parent.receiver.nil?
// 276:
// 277:           DEFINITION_METHODS.include?(parent.method_name)
// 278:         end
// 279:       end
// 280:     end
// 281:   end
// 282: end
