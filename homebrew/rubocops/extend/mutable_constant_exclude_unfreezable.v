module extend

import brew_runtime

// Translated from Homebrew/brew `rubocops/extend/mutable_constant_exclude_unfreezable.rb`.
// The original source is retained below until every stub has a typed V body.
pub const mutable_constant_exclude_matchers = ['t_let', 't_type_alias?', 'type_member?']

pub struct MutableConstantAssignmentResult {
pub:
	original  string
	value     string
	delegated bool
	excluded  string
}

fn mutable_constant_first_argument(source string) ?string {
	trimmed := source.trim_space()
	if !trimmed.starts_with('T.let(') || !trimmed.ends_with(')') {
		return none
	}
	inner := trimmed['T.let('.len..trimmed.len - 1]
	mut quote := u8(0)
	mut escaped := false
	mut depth := 0
	for index, character in inner.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
		} else if character in [`(`, `[`, `{`] {
			depth++
		} else if character in [`)`, `]`, `}`] && depth > 0 {
			depth--
		} else if character == `,` && depth == 0 {
			return inner[..index].trim_space()
		}
	}
	return none
}

pub fn mutable_constant_assignment(source string) MutableConstantAssignmentResult {
	original := source.trim_space()
	value := mutable_constant_first_argument(original) or { original }
	compact := value.replace(' ', '').replace('\t', '').replace('\n', '')
	if compact.starts_with('T.type_alias{') || compact.starts_with('::T.type_alias{') || compact.starts_with('T.type_aliasdo') || compact.starts_with('::T.type_aliasdo') {
		return MutableConstantAssignmentResult{
			original: original
			value: value
			excluded: 't_type_alias'
		}
	}
	if compact.starts_with('type_member{') || compact.starts_with('type_memberdo') {
		return MutableConstantAssignmentResult{
			original: original
			value: value
			excluded: 'type_member'
		}
	}
	return MutableConstantAssignmentResult{
		original: original
		value: value
		delegated: true
	}
}

fn mutable_constant_result_value(result MutableConstantAssignmentResult) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Style::MutableConstant::AssignmentResult', result.value, {
		'original':  result.original
		'value':     result.value
		'delegated': result.delegated.str()
		'excluded':  result.excluded
	})
}

// Ruby method `prepended(base)` at line 13.
pub fn ruby_mutable_constant_exclude_unfreezable_l13_d1_prepended(args ...brew_runtime.Value) brew_runtime.Value {
	base := if args.len > 0 { args[0].as_string() } else { 'RuboCop::AST::NodePattern::Macros' }
	return brew_runtime.structured_value('RuboCop::AST::NodePattern::Macros', base, {
		'base':          base
		'matchers':      mutable_constant_exclude_matchers.join(',')
		't_let':         '(send (const nil? :T) :let \$_constant _type)'
		't_type_alias?': '(block (send (const {nil? cbase} :T) :type_alias ...) ...)'
		'type_member?':  '(block (send nil? :type_member ...) ...)'
	})
}

// Ruby method `on_assignment(value)` at line 29.
pub fn ruby_mutable_constant_exclude_unfreezable_l29_d2_on_assignment(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return mutable_constant_result_value(mutable_constant_assignment(source))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocop/cop/style/mutable_constant"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Sorbet
// 9:       # TODO: delete this file when https://github.com/Shopify/rubocop-sorbet/pull/256 is available
// 10:       module MutableConstantExcludeUnfreezable
// 11:         class << self
// 12:           sig { params(base: RuboCop::AST::NodePattern::Macros).void }
// 13:           def prepended(base)
// 14:             base.def_node_matcher(:t_let, <<~PATTERN)
// 15:               (send (const nil? :T) :let $_constant _type)
// 16:             PATTERN
// 17:
// 18:             base.def_node_matcher(:t_type_alias?, <<~PATTERN)
// 19:               (block (send (const {nil? cbase} :T) :type_alias ...) ...)
// 20:             PATTERN
// 21:
// 22:             base.def_node_matcher(:type_member?, <<~PATTERN)
// 23:               (block (send nil? :type_member ...) ...)
// 24:             PATTERN
// 25:           end
// 26:         end
// 27:
// 28:         sig { params(value: RuboCop::AST::Node).void }
// 29:         def on_assignment(value)
// 30:           T.unsafe(self).t_let(value) do |constant|
// 31:             value = T.let(constant, RuboCop::AST::Node)
// 32:           end
// 33:           return if T.unsafe(self).t_type_alias?(value)
// 34:           return if T.unsafe(self).type_member?(value)
// 35:
// 36:           super
// 37:         end
// 38:       end
// 39:     end
// 40:   end
// 41: end
// 42:
// 43: RuboCop::Cop::Style::MutableConstant.prepend(
// 44:   RuboCop::Cop::Sorbet::MutableConstantExcludeUnfreezable,
// 45: )
