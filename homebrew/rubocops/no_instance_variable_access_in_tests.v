module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/no_instance_variable_access_in_tests.rb`.
// The original source is retained below until every stub has a typed V body.
pub const no_instance_variable_access_message_template = 'Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of `%s` in tests.'

pub struct InstanceVariableAccessOffense {
pub:
	method    string
	begin_pos int
	end_pos   int
	message   string
}

pub fn audit_instance_variable_access(source string) []InstanceVariableAccessOffense {
	mut offenses := []InstanceVariableAccessOffense{}
	for method in ['instance_variable_get', 'instance_variable_set'] {
		mut offset := 0
		for offset < source.len {
			relative := source[offset..].index(method) or { break }
			begin_pos := offset + relative
			after := begin_pos + method.len
			if after < source.len && source[after] == `(` {
				offenses << InstanceVariableAccessOffense{
					method: method
					begin_pos: begin_pos
					end_pos: after
					message: no_instance_variable_access_message_template.replace('%s', method)
				}
			}
			offset = after
		}
	}
	offenses.sort(a.begin_pos < b.begin_pos)
	return offenses
}

fn instance_variable_access_value(offense InstanceVariableAccessOffense) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', offense.message, {
		'method':    offense.method
		'begin_pos': offense.begin_pos.str()
		'end_pos':   offense.end_pos.str()
		'message':   offense.message
	})
}

// Ruby attr_reader `MSG = "Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of " \` at line 22.
pub fn ruby_no_instance_variable_access_in_tests_l22_d1_attr_reader_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	method := if args.len > 0 { args[0].as_string() } else { '%<method>s' }
	return brew_runtime.string_value(no_instance_variable_access_message_template.replace('%s', method))
}

// Ruby method `on_send(node)` at line 27.
pub fn ruby_no_instance_variable_access_in_tests_l27_d2_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	offenses := audit_instance_variable_access(source)
	return if offenses.len == 0 {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		instance_variable_access_value(offenses[0])
	}
}

// Ruby alias `alias on_csend on_send` at line 30.
pub fn ruby_no_instance_variable_access_in_tests_l30_d3_on_csend(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_no_instance_variable_access_in_tests_l27_d2_on_send(...args)
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
