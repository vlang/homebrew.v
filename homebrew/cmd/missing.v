module cmd

import ruby

// Translated from Homebrew/brew `cmd/missing.rb`.
pub struct MissingCommandResult {
pub:
	output string
	failed bool
}

pub struct MissingCommandPackage {
pub:
	full_name            string
	display_name         string
	missing_dependencies []string
}

pub fn missing_command(formulae []MissingCommandPackage, casks []MissingCommandPackage,
	storage_exists bool) MissingCommandResult {
	if !storage_exists {
		return MissingCommandResult{}
	}
	mut sorted_formulae := formulae.clone()
	sorted_formulae.sort_with_compare(fn (left &MissingCommandPackage,
		right &MissingCommandPackage) int {
		return compare_strings(left.full_name, right.full_name)
	})
	mut sorted_casks := casks.clone()
	sorted_casks.sort_with_compare(fn (left &MissingCommandPackage,
		right &MissingCommandPackage) int {
		return compare_strings(left.full_name, right.full_name)
	})
	package_count := sorted_formulae.len + sorted_casks.len
	mut lines := []string{}
	for formula in sorted_formulae {
		if formula.missing_dependencies.len == 0 {
			continue
		}
		prefix := if package_count > 1 {
			'${if formula.display_name == '' { formula.full_name } else { formula.display_name }}: '
		} else {
			''
		}
		lines << prefix + formula.missing_dependencies.join(' ')
	}
	for cask in sorted_casks {
		if cask.missing_dependencies.len == 0 {
			continue
		}
		prefix := if package_count > 1 {
			'${if cask.display_name == '' { cask.full_name } else { cask.display_name }}: '
		} else {
			''
		}
		lines << prefix + cask.missing_dependencies.join(' ')
	}
	return MissingCommandResult{
		output: if lines.len == 0 { '' } else { lines.join('\n') + '\n' }
		failed: lines.len > 0
	}
}

fn missing_command_packages_from_value(value ruby.Value) []MissingCommandPackage {
	return value.array_data.map(MissingCommandPackage{
		full_name: it.attributes['full_name'] or { it.as_string() }
		display_name: it.attributes['display_name'] or { it.as_string() }
		missing_dependencies: (it.attributes['missing_dependencies'] or { '' }).split(',').filter(it != '')
	})
}
