module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/no_send_in_tests.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 52.
pub fn ruby_no_send_in_tests_l52_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby alias `alias on_csend on_send` at line 67.
pub fn ruby_no_send_in_tests_l67_d2_on_csend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_csend', ...args)
}

// Ruby method `directly_callable_name?(argument)` at line 72.
pub fn ruby_no_send_in_tests_l72_d3_directly_callable_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('directly_callable_name?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Flags `send`-family dispatch in tests. Tests should exercise methods the way real
// 8:       # callers do: a private method poked via `send` should be made public and called
// 9:       # directly instead.
// 10:       #
// 11:       # - `send`/`__send__` are always flagged: with a static method name the call can be
// 12:       #   written directly (after making the method public if needed); with a dynamic one
// 13:       #   it must go through `public_send` so it cannot bypass method visibility.
// 14:       # - `public_send` is flagged only when the method name is a literal that could have
// 15:       #   been written as a direct call: an identifier, setter or operator name such as
// 16:       #   `:[]` or `:<<`. A dynamic name (`public_send(method_name)`,
// 17:       #   `public_send(:"#{artifact_dsl_key}_phase")`) is the one legitimate use:
// 18:       #   parameterised dispatch to public API. A literal name with no direct call syntax
// 19:       #   (e.g. `:"gcc-9"`) is also allowed, as no direct call can spell it.
// 20:       #
// 21:       # ### Example
// 22:       #
// 23:       # ```ruby
// 24:       # # bad
// 25:       # formula.send(:active_spec)
// 26:       #
// 27:       # # good (with `active_spec` made public)
// 28:       # formula.active_spec
// 29:       #
// 30:       # # good (dynamic dispatch to public API in a parameterised example)
// 31:       # subject.public_send(:"#{artifact_dsl_key}_phase")
// 32:       # ```
// 33:       class NoSendInTests < Base
// 34:         MSG_SEND = "Make the method public and call it directly instead of using `%<method>s` in tests."
// 35:         MSG_SEND_DYNAMIC = "Use `public_send` instead of `%<method>s` in tests; " \
// 36:                            "`%<method>s` bypasses method visibility."
// 37:         MSG_PUBLIC_SEND = "Call the method directly instead of using `public_send` with a static method name."
// 38:         RESTRICT_ON_SEND = [:send, :__send__, :public_send].freeze
// 39:
// 40:         # A literal method name that direct call syntax can spell, including setters
// 41:         # (`public_send(:foo=, value)` can be written `receiver.foo = value`).
// 42:         DIRECTLY_CALLABLE_NAME = /\A[a-zA-Z_][a-zA-Z0-9_]*[?!=]?\z/
// 43:         # Operator method names that direct call syntax can also spell, e.g.
// 44:         # `receiver[key]`, `receiver[key] = value`, `receiver << value`, `!receiver`.
// 45:         # `rubocop-ast`'s `OPERATOR_METHODS` is a private constant and includes
// 46:         # `` ` ``, which no direct call on an explicit receiver can spell.
// 47:         DIRECTLY_CALLABLE_OPERATORS = %w(
// 48:           [] []= + - * / % ** == != < <= > >= <=> === =~ !~ & | ^ << >> ~ ! +@ -@
// 49:         ).freeze
// 50:
// 51:         sig { params(node: RuboCop::AST::SendNode).void }
// 52:         def on_send(node)
// 53:           directly_callable = directly_callable_name?(node.first_argument)
// 54:
// 55:           message = if node.method_name == :public_send
// 56:             return unless directly_callable
// 57:
// 58:             MSG_PUBLIC_SEND
// 59:           elsif directly_callable
// 60:             format(MSG_SEND, method: node.method_name)
// 61:           else
// 62:             format(MSG_SEND_DYNAMIC, method: node.method_name)
// 63:           end
// 64:
// 65:           add_offense(node.loc.selector, message:)
// 66:         end
// 67:         alias on_csend on_send
// 68:
// 69:         private
// 70:
// 71:         sig { params(argument: T.nilable(RuboCop::AST::Node)).returns(T::Boolean) }
// 72:         def directly_callable_name?(argument)
// 73:           return false unless argument
// 74:           return false if !argument.sym_type? && !argument.str_type?
// 75:
// 76:           name = argument.children.first.to_s
// 77:           name.match?(DIRECTLY_CALLABLE_NAME) || DIRECTLY_CALLABLE_OPERATORS.include?(name)
// 78:         end
// 79:       end
// 80:     end
// 81:   end
// 82: end
