module extend

import ruby

// Translated from Homebrew/brew `rubocops/extend/mutable_constant_exclude_unfreezable.rb`.
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

fn mutable_constant_result_value(result MutableConstantAssignmentResult) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Style::MutableConstant::AssignmentResult', result.value, {
		'original':  result.original
		'value':     result.value
		'delegated': result.delegated.str()
		'excluded':  result.excluded
	})
}
