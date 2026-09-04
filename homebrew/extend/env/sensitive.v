module env

import ruby

// Translated from Homebrew/brew `extend/ENV/sensitive.rb`.
// The original source is retained below until every stub has a typed V body.
const deferred_environment_prefix = '{{HOMEBREW_DEFERRED_ENV:'
const deferred_environment_suffix = '}}'

pub struct SensitiveEnvironmentView {
pub mut:
	values map[string]string
}

pub type SensitiveEnvironmentAction = fn(mut SensitiveEnvironmentView) !ruby.Value

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

// Ruby method `sensitive?(key)` at line 21.
pub fn ruby_sensitive_l21_d1_sensitive(key string) bool {
	return environment_key_sensitive(key)
}

// Ruby method `sensitive_environment` at line 26.
pub fn ruby_sensitive_l26_d2_sensitive_environment(values map[string]string) map[string]string {
	return sensitive_environment(values)
}

// Ruby method `clear_sensitive_environment!(except: [], defer: false, &block)` at line 37.
pub fn ruby_sensitive_l37_d3_clear_sensitive_environment(mut values map[string]string,
	except []string, defer_secrets bool) {
	clear_sensitive_environment(mut values, except, defer_secrets)
}

// Ruby method `clear_sensitive_environment_for_eval!(&block)` at line 62.
pub fn ruby_sensitive_l62_d4_clear_sensitive_environment_for_eval(mut values map[string]string,
	action SensitiveEnvironmentAction) !ruby.Value {
	return with_cleared_sensitive_environment(mut values, ['HOMEBREW_GITHUB_API_TOKEN'], true, action)!
}

// Ruby method `expand_deferred_environment(value)` at line 70.
pub fn ruby_sensitive_l70_d5_expand_deferred_environment(value string,
	environment map[string]string, expansion_allowed bool) string {
	return expand_deferred_environment(value, environment, expansion_allowed)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "env_config"
// 5: require "context"
// 6:
// 7: module EnvSensitive
// 8:   extend T::Helpers
// 9:
// 10:   requires_ancestor { Sorbet::Private::Static::ENVClass }
// 11:
// 12:   # `bin/brew` re-execs with only `HOMEBREW_*` variables (plus a fixed
// 13:   # non-secret allowlist) in the environment, so every secret reaching
// 14:   # formula/cask evaluation is `HOMEBREW_*`. These markers wrap a deferred
// 15:   # secret name interpolated into the DSL in place of the real value; the real
// 16:   # value is swapped back in at download time by `expand_deferred_environment`.
// 17:   DEFERRED_PLACEHOLDER_PREFIX = "{{HOMEBREW_DEFERRED_ENV:"
// 18:   DEFERRED_PLACEHOLDER_SUFFIX = "}}"
// 19:
// 20:   sig { params(key: T.any(String, Symbol)).returns(T::Boolean) }
// 21:   def sensitive?(key)
// 22:     key.match?(/(cookie|key|token|password|passphrase|auth)/i)
// 23:   end
// 24:
// 25:   sig { returns(T::Hash[String, String]) }
// 26:   def sensitive_environment
// 27:     select { |key, _| sensitive?(key) }
// 28:   end
// 29:
// 30:   sig {
// 31:     params(
// 32:       except: T::Array[String],
// 33:       defer:  T::Boolean,
// 34:       block:  T.nilable(T.proc.returns(T.untyped)),
// 35:     ).returns(T.untyped)
// 36:   }
// 37:   def clear_sensitive_environment!(except: [], defer: false, &block)
// 38:     unless block
// 39:       each_key do |key|
// 40:         next unless sensitive?(key)
// 41:         next if except.include?(key)
// 42:
// 43:         if defer
// 44:           self[key] = "#{DEFERRED_PLACEHOLDER_PREFIX}#{key}#{DEFERRED_PLACEHOLDER_SUFFIX}"
// 45:         else
// 46:           delete key
// 47:         end
// 48:       end
// 49:       return
// 50:     end
// 51:
// 52:     old_env = to_hash.dup
// 53:     begin
// 54:       clear_sensitive_environment!(except:, defer:)
// 55:       yield
// 56:     ensure
// 57:       replace(old_env)
// 58:     end
// 59:   end
// 60:
// 61:   sig { params(block: T.proc.returns(T.untyped)).returns(T.untyped) }
// 62:   def clear_sensitive_environment_for_eval!(&block)
// 63:     clear_sensitive_environment!(except: ["HOMEBREW_GITHUB_API_TOKEN"], defer: true, &block)
// 64:   end
// 65:
// 66:   # Only the download path (a URL's `header:`/specs) calls this, so a masked
// 67:   # secret is resolved to its real value solely when fetching, never elsewhere
// 68:   # in the DSL.
// 69:   sig { params(value: String).returns(String) }
// 70:   def expand_deferred_environment(value)
// 71:     return value unless value.include?(DEFERRED_PLACEHOLDER_PREFIX)
// 72:     return value unless Context.current.deferred_environment_expansion?
// 73:
// 74:     prefix = Regexp.escape(DEFERRED_PLACEHOLDER_PREFIX)
// 75:     suffix = Regexp.escape(DEFERRED_PLACEHOLDER_SUFFIX)
// 76:     value.gsub(/#{prefix}(HOMEBREW_\w+)#{suffix}/) do
// 77:       name = Regexp.last_match(1)
// 78:       name ? fetch(name, "") : ""
// 79:     end
// 80:   end
// 81: end
// 82:
// 83: ENV.extend(EnvSensitive)
