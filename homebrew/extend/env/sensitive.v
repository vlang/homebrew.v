module env

import ruby

// Translated from Homebrew/brew `extend/ENV/sensitive.rb`.
const deferred_environment_prefix = '{{HOMEBREW_DEFERRED_ENV:'
const deferred_environment_suffix = '}}'

pub struct SensitiveEnvironmentView {
pub mut:
	values map[string]string
}

pub type SensitiveEnvironmentAction = fn (mut SensitiveEnvironmentView) !ruby.Value

pub fn environment_key_sensitive(key string) bool {
	lower := key.to_lower()
	return ['cookie', 'key', 'token', 'password', 'passphrase', 'auth'].any(lower.contains(it))
}

pub fn sensitive_environment(values map[string]string) map[string]string {
	mut sensitive := map[string]string{}
	for key, value in values {
		if environment_key_sensitive(key) {
			sensitive[key] = value
		}
	}
	return sensitive
}

pub fn clear_sensitive_environment(mut values map[string]string, except []string,
	defer_values bool) {
	for key in values.keys() {
		if !environment_key_sensitive(key) || key in except {
			continue
		}
		if defer_values {
			values[key] = '${deferred_environment_prefix}${key}${deferred_environment_suffix}'
		} else {
			values.delete(key)
		}
	}
}

pub fn with_cleared_sensitive_environment(mut values map[string]string, except []string,
	defer_values bool, action SensitiveEnvironmentAction) !ruby.Value {
	original := values.clone()
	defer {
		values.clear()
		for key, value in original {
			values[key] = value
		}
	}
	clear_sensitive_environment(mut values, except, defer_values)
	mut view := SensitiveEnvironmentView{
		values: values.clone()
	}
	return action(mut view)!
}

pub fn expand_deferred_environment(value string, environment map[string]string,
	expansion_allowed bool) string {
	if !expansion_allowed || !value.contains(deferred_environment_prefix) {
		return value
	}
	mut expanded := value
	mut offset := 0
	for {
		relative_start := expanded[offset..].index(deferred_environment_prefix) or { break }
		start := offset + relative_start
		name_start := start + deferred_environment_prefix.len
		relative_end := expanded[name_start..].index(deferred_environment_suffix) or { break }
		name_end := name_start + relative_end
		name := expanded[name_start..name_end]
		if name.len <= 9 || !name.starts_with('HOMEBREW_') || !name[9..].bytes().all((it >= `A` && it <= `Z`) || (it >= `a` && it <= `z`) || (it >= `0` && it <= `9`) || it == `_`) {
			offset = name_end + deferred_environment_suffix.len
			continue
		}
		replacement := environment[name] or { '' }
		expanded = expanded[..start] + replacement + expanded[name_end + deferred_environment_suffix.len..]
		offset = start + replacement.len
	}
	return expanded
}
