module livecheck

import ruby

// Translated from Homebrew/brew `livecheck/options.rb`.
const livecheck_option_names = ['compressed', 'cookies', 'header', 'homebrew_curl', 'post_form',
	'post_json', 'referer', 'user_agent']

pub struct LivecheckOptions {
pub mut:
	values map[string]ruby.Value
}

fn options_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

pub fn new_livecheck_options(values map[string]ruby.Value) LivecheckOptions {
	mut filtered := map[string]ruby.Value{}
	for key, value in values {
		if key in livecheck_option_names && value.type_name != 'NilClass' {
			filtered[key] = value
		}
	}
	return LivecheckOptions{ values: filtered }
}

pub fn livecheck_options_value(options LivecheckOptions) ruby.Value {
	return ruby.Value{ type_name: 'Homebrew::Livecheck::Options', repr: options.values.str(), map_data: options.values }
}

pub fn livecheck_options_from_value(value ruby.Value) !LivecheckOptions {
	if value.type_name !in ['Homebrew::Livecheck::Options', 'Hash'] {
		return error('expected Livecheck::Options or Hash, got ${value.type_name}')
	}
	return new_livecheck_options(value.map_data)
}

pub fn (options LivecheckOptions) url_options() map[string]ruby.Value {
	mut result := map[string]ruby.Value{}
	for key in livecheck_option_names {
		result[key] = options.values[key] or { options_nil() }
	}
	return result
}

pub fn (options LivecheckOptions) merge(other LivecheckOptions) LivecheckOptions {
	mut values := options.values.clone()
	for key, value in other.values {
		if value.type_name != 'NilClass' {
			values[key] = value
		}
	}
	return new_livecheck_options(values)
}

// merge_in_place mirrors Ruby's `merge!`: only initialized, known option values
// are copied from `other`, and the receiver itself is returned after mutation.
pub fn (mut options LivecheckOptions) merge_in_place(other LivecheckOptions) LivecheckOptions {
	for key, value in other.values {
		if key in livecheck_option_names && value.type_name != 'NilClass' {
			options.values[key] = value
		}
	}
	return options
}

fn option_values_equal(left ruby.Value, right ruby.Value) bool {
	if left.type_name != right.type_name || left.repr != right.repr || left.bool_data != right.bool_data || left.int_data != right.int_data || left.string_array_data != right.string_array_data {
		return false
	}
	if left.array_data.len != right.array_data.len || left.map_data.len != right.map_data.len {
		return false
	}
	for index, value in left.array_data {
		if !option_values_equal(value, right.array_data[index]) {
			return false
		}
	}
	for key, value in left.map_data {
		if other := right.map_data[key] {
			if !option_values_equal(value, other) {
				return false
			}
		} else {
			return false
		}
	}
	return true
}

pub fn (options LivecheckOptions) equals(other LivecheckOptions) bool {
	if options.values.len != other.values.len {
		return false
	}
	for key in livecheck_option_names {
		left := options.values[key] or { options_nil() }
		right := other.values[key] or { options_nil() }
		if !option_values_equal(left, right) {
			return false
		}
	}
	return true
}
