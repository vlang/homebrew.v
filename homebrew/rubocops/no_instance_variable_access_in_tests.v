module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/no_instance_variable_access_in_tests.rb`.
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

fn instance_variable_access_value(offense InstanceVariableAccessOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'method':    offense.method
		'begin_pos': offense.begin_pos.str()
		'end_pos':   offense.end_pos.str()
		'message':   offense.message
	})
}
