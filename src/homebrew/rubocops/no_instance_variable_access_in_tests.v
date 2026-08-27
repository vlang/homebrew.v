module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/no_instance_variable_access_in_tests.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `MSG = "Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of " \` at line 22.
pub fn ruby_no_instance_variable_access_in_tests_l22_d1_attr_reader_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_reader_dynamic', ...args)
}

// Ruby method `on_send(node)` at line 27.
pub fn ruby_no_instance_variable_access_in_tests_l27_d2_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby alias `alias on_csend on_send` at line 30.
pub fn ruby_no_instance_variable_access_in_tests_l30_d3_on_csend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_csend', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Flags `instance_variable_get`/`instance_variable_set` in tests. Tests should read
// 8:       # and write object state through public accessors: add a public `attr_reader`/
// 9:       # `attr_writer` (or use an existing accessor) on the class instead of reaching into
// 10:       # its instance variables.
// 11:       #
// 12:       # ### Example
// 13:       #
// 14:       # ```ruby
// 15:       # # bad
// 16:       # formula.instance_variable_set(:@tap, CoreTap.instance)
// 17:       #
// 18:       # # good (with a public `attr_writer :tap`)
// 19:       # formula.tap = CoreTap.instance
// 20:       # ```
// 21:       class NoInstanceVariableAccessInTests < Base
// 22:         MSG = "Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of " \
// 23:               "`%<method>s` in tests."
// 24:         RESTRICT_ON_SEND = [:instance_variable_get, :instance_variable_set].freeze
// 25:
// 26:         sig { params(node: RuboCop::AST::SendNode).void }
// 27:         def on_send(node)
// 28:           add_offense(node.loc.selector, message: format(MSG, method: node.method_name))
// 29:         end
// 30:         alias on_csend on_send
// 31:       end
// 32:     end
// 33:   end
// 34: end
