module homebrew

import ruby
import homebrew.upgrade_helpers

pub struct UpgradeExecutionResult {
pub:
	success bool
	values  []ruby.Value
	stdout  string
	stderr  string
}

fn upgrade_bool(value ruby.Value, key string, fallback bool) bool {
	raw := value.attributes[key] or { return fallback }
	return raw == 'true' || raw == '1'
}

fn upgrade_strings(value ruby.Value, key string) []string {
	raw := value.attributes[key] or { return [] }
	return if raw == '' { [] } else { raw.split('\x1f') }
}

fn upgrade_values(value ruby.Value, key string) []ruby.Value {
	item := value.map_data[key] or { return [] }
	return item.as_array() or { [] }
}

fn upgrade_name(value ruby.Value) string {
	return value.attributes['full_specified_name'] or {
		value.attributes['full_name'] or { value.attributes['name'] or { value.repr } }
	}
}

fn upgrade_version(value ruby.Value) string {
	return value.attributes['pkg_version'] or { value.attributes['version'] or { '' } }
}

fn upgrade_unique_values(values []ruby.Value) []ruby.Value {
	mut seen := map[string]bool{}
	mut result := []ruby.Value{}
	for value in values {
		key := upgrade_name(value)
		if seen[key] or { false } {
			continue
		}
		seen[key] = true
		result << value
	}
	return result
}

fn upgrade_result_value(result UpgradeExecutionResult) ruby.Value {
	return ruby.Value{
		type_name: 'UpgradeExecutionResult'
		bool_data: result.success
		attributes: {
			'success': result.success.str()
			'stdout':  result.stdout
			'stderr':  result.stderr
		}
		map_data: {
			'values': ruby.array_value(result.values)
		}
	}
}

fn upgrade_result(value ruby.Value) UpgradeExecutionResult {
	return UpgradeExecutionResult{
		success: upgrade_bool(value, 'success', value.bool_data)
		values: upgrade_values(value, 'values')
		stdout: value.attributes['stdout'] or { '' }
		stderr: value.attributes['stderr'] or { '' }
	}
}

pub fn upgrade_format_summary(upgrades []string) []string {
	return upgrade_helpers.format_summary(upgrades)
}

fn upgrade_installer_formula(value ruby.Value) ruby.Value {
	return value.map_data['formula'] or { value }
}

fn upgrade_installer_value(formula ruby.Value, source ruby.Value) ruby.Value {
	mut attributes := source.attributes.clone()
	attributes['valid'] = (source.attributes['valid'] or { 'true' })
	attributes['upgraded'] = (source.attributes['upgraded'] or { 'true' })
	return ruby.Value{
		type_name: 'FormulaInstaller'
		repr: upgrade_name(formula)
		attributes: attributes
		map_data: {
			'formula':      formula
			'dependencies': source.map_data['dependencies'] or { ruby.array_value([]) }
		}
	}
}

fn upgrade_compare_formula(one ruby.Value, two ruby.Value) int {
	if upgrade_strings(one, 'runtime_dependencies').any(it == (two.attributes['full_name'] or {
		upgrade_name(two)
	})) {
		return 1
	}
	one_name := upgrade_name(one)
	two_name := upgrade_name(two)
	return if one_name < two_name {
		-1
	} else if one_name > two_name { 1 } else { 0 }
}

// Translated from Homebrew/brew `upgrade.rb`.
