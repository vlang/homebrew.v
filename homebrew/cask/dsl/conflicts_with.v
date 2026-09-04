module dsl

import ruby

// Translated from Homebrew/brew `cask/dsl/conflicts_with.rb`.
pub struct CaskConflictsWith {
pub mut:
	conflicts map[string][]string
}

pub fn new_cask_conflicts_with(options map[string]ruby.Value) !CaskConflictsWith {
	for key in options.keys() {
		if key.trim_left(':') != 'cask' {
			return error('Unknown key: :${key.trim_left(':')}')
		}
	}
	mut conflicts := map[string][]string{}
	if value := options['cask'] {
		mut entries := if value.type_name == 'Array' {
			value.as_array()!.map(it.as_string())
		} else {
			[value.as_string()]
		}
		mut unique := []string{}
		for entry in entries {
			if entry !in unique {
				unique << entry
			}
		}
		conflicts['cask'] = unique
	}
	return CaskConflictsWith{
		conflicts: conflicts
	}
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

pub fn cask_conflicts_with_from_value(value ruby.Value) !CaskConflictsWith {
	if value.type_name != 'Cask::DSL::ConflictsWith' && value.type_name != 'Hash' {
		return error('expected Cask::DSL::ConflictsWith, got ${value.type_name}')
	}
	return new_cask_conflicts_with(value.map_data)
}

fn cask_conflicts_receiver(args []ruby.Value) ?CaskConflictsWith {
	if args.len == 0 {
		return none
	}
	return cask_conflicts_with_from_value(args[0]) or { return none }
}
