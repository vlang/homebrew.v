module dsl

import ruby

// Translated from Homebrew/brew `cask/dsl/conflicts_with.rb`.
pub struct CaskConflictsWith {
pub mut:
	conflicts map[string][]string
}

pub fn (mut conflicts CaskConflictsWith) merge(other CaskConflictsWith) {
	for key, values in other.conflicts {
		mut combined := conflicts.conflicts[key] or { []string{} }
		for value in values {
			if value !in combined {
				combined << value
			}
		}
		conflicts.conflicts[key] = combined
	}
}

pub fn cask_conflicts_with_value(conflicts CaskConflictsWith) ruby.Value {
	mut values := map[string]ruby.Value{}
	for key, entries in conflicts.conflicts {
		values[key] = ruby.string_array_value(entries)
	}
	return ruby.Value{
		type_name: 'Cask::DSL::ConflictsWith'
		repr: conflicts.conflicts.str()
		map_data: values
	}
}
