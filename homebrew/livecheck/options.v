module livecheck

import brew_runtime

// Translated from Homebrew/brew `livecheck/options.rb`.
// The original source is retained below until every stub has a typed V body.
const livecheck_option_names = ['compressed', 'cookies', 'header', 'homebrew_curl', 'post_form',
	'post_json', 'referer', 'user_agent']

pub struct LivecheckOptions {
pub mut:
	values map[string]brew_runtime.Value
}

fn options_nil() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

pub fn new_livecheck_options(values map[string]brew_runtime.Value) LivecheckOptions {
	mut filtered := map[string]brew_runtime.Value{}
	for key, value in values {
		if key in livecheck_option_names && value.type_name != 'NilClass' {
			filtered[key] = value
		}
	}
	return LivecheckOptions{ values: filtered }
}

pub fn livecheck_options_value(options LivecheckOptions) brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'Homebrew::Livecheck::Options', repr: options.values.str(), map_data: options.values }
}

pub fn livecheck_options_from_value(value brew_runtime.Value) !LivecheckOptions {
	if value.type_name !in ['Homebrew::Livecheck::Options', 'Hash'] {
		return error('expected Livecheck::Options or Hash, got ${value.type_name}')
	}
	return new_livecheck_options(value.map_data)
}

pub fn (options LivecheckOptions) url_options() map[string]brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
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

fn option_values_equal(left brew_runtime.Value, right brew_runtime.Value) bool {
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

// Ruby method `url_options` at line 39.
pub fn ruby_options_l39_d1_url_options(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'url_options requires a receiver')
	}
	options := livecheck_options_from_value(args[0]) or { return brew_runtime.object_value('TypeError', err.msg()) }
	return brew_runtime.map_value(options.url_options())
}

// Ruby method `to_hash` at line 54.
pub fn ruby_options_l54_d2_to_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'to_hash requires a receiver')
	}
	options := livecheck_options_from_value(args[0]) or { return brew_runtime.object_value('TypeError', err.msg()) }
	return brew_runtime.map_value(options.values)
}

// Ruby method `to_h = to_hash.transform_keys(&:to_sym)` at line 60.
pub fn ruby_options_l60_d3_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_options_l54_d2_to_hash(...args)
}

// Ruby method `merge(other)` at line 69.
pub fn ruby_options_l69_d4_merge(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'merge requires another Options or Hash')
	}
	options := livecheck_options_from_value(args[0]) or { return brew_runtime.object_value('TypeError', err.msg()) }
	other := livecheck_options_from_value(args[1]) or { return brew_runtime.object_value('TypeError', err.msg()) }
	return livecheck_options_value(options.merge(other))
}

// Ruby method `merge!(other)` at line 86.
pub fn ruby_options_l86_d5_merge(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'merge! requires another Options or Hash')
	}
	mut options := livecheck_options_from_value(args[0]) or {
		return brew_runtime.object_value('TypeError', err.msg())
	}
	other := livecheck_options_from_value(args[1]) or {
		return brew_runtime.object_value('TypeError', err.msg())
	}
	return livecheck_options_value(options.merge_in_place(other))
}

// Ruby method `==(other)` at line 108.
pub fn ruby_options_l108_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	options := livecheck_options_from_value(args[0]) or { return brew_runtime.bool_value(false) }
	other := livecheck_options_from_value(args[1]) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(options.equals(other))
}

// Ruby alias `alias eql? ==` at line 120.
pub fn ruby_options_l120_d7_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_options_l108_d6_anonymous(...args)
}

// Ruby method `empty? = to_hash.empty?` at line 124.
pub fn ruby_options_l124_d8_empty(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'empty? requires a receiver')
	}
	options := livecheck_options_from_value(args[0]) or { return brew_runtime.object_value('TypeError', err.msg()) }
	return brew_runtime.bool_value(options.values.len == 0)
}

// Ruby method `present? = !empty?` at line 128.
pub fn ruby_options_l128_d9_present(args ...brew_runtime.Value) brew_runtime.Value {
	value := ruby_options_l124_d8_empty(...args)
	return if value.type_name == 'Bool' { brew_runtime.bool_value(!value.bool_data) } else { value }
}

// Original Ruby source (line-for-line):
// 1: # typed: strong
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Livecheck
// 6:     # Options to modify livecheck's behavior. These primarily come from
// 7:     # `livecheck` blocks but they can also be set by livecheck at runtime.
// 8:     #
// 9:     # Option values use a `nil` default to indicate that the value has not been
// 10:     # set.
// 11:     class Options < T::Struct
// 12:       # Whether to request a compressed response.
// 13:       prop :compressed, T.nilable(FalseClass)
// 14:
// 15:       # Cookies for curl to use when making a request.
// 16:       prop :cookies, T.nilable(T::Hash[String, String])
// 17:
// 18:       # Header(s) for curl to use when making a request.
// 19:       prop :header, T.nilable(T.any(String, T::Array[String]))
// 20:
// 21:       # Whether to use brewed curl.
// 22:       prop :homebrew_curl, T.nilable(TrueClass)
// 23:
// 24:       # Form data to use when making a `POST` request.
// 25:       prop :post_form, T.nilable(T::Hash[Symbol, String])
// 26:
// 27:       # JSON data to use when making a `POST` request.
// 28:       prop :post_json, T.nilable(T::Hash[Symbol, T.anything])
// 29:
// 30:       # Referer for curl to use when making a request.
// 31:       prop :referer, T.nilable(String)
// 32:
// 33:       # User agent for curl to use when making a request. Symbol arguments
// 34:       # should use a value supported by {Utils::Curl.curl_args}.
// 35:       prop :user_agent, T.nilable(T.any(String, Symbol))
// 36:
// 37:       # Returns a `Hash` of options that are provided as arguments to `url`.
// 38:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 39:       def url_options
// 40:         {
// 41:           compressed:,
// 42:           cookies:,
// 43:           header:,
// 44:           homebrew_curl:,
// 45:           post_form:,
// 46:           post_json:,
// 47:           referer:,
// 48:           user_agent:,
// 49:         }
// 50:       end
// 51:
// 52:       # Returns a `Hash` of all instance variables, using `String` keys.
// 53:       sig { returns(T::Hash[String, T.untyped]) }
// 54:       def to_hash
// 55:         T.let(serialize, T::Hash[String, T.untyped])
// 56:       end
// 57:
// 58:       # Returns a `Hash` of all instance variables, using `Symbol` keys.
// 59:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 60:       def to_h = to_hash.transform_keys(&:to_sym)
// 61:
// 62:       # Returns a new object formed by merging `other` values with a copy of
// 63:       # `self`.
// 64:       #
// 65:       # `nil` values are removed from `other` before merging if it is an
// 66:       # `Options` object, as these are unitiailized values. This ensures that
// 67:       # existing values in `self` aren't unexpectedly overwritten with defaults.
// 68:       sig { params(other: T.any(Options, T::Hash[Symbol, T.untyped])).returns(Options) }
// 69:       def merge(other)
// 70:         return dup if other.empty?
// 71:
// 72:         this_hash = to_h
// 73:         other_hash = other.is_a?(Options) ? other.to_h : other
// 74:         return dup if this_hash == other_hash
// 75:
// 76:         new_options = this_hash.merge(other_hash)
// 77:         Options.new(**new_options)
// 78:       end
// 79:
// 80:       # Merges values from `other` into `self` and returns `self`.
// 81:       #
// 82:       # `nil` values are removed from `other` before merging if it is an
// 83:       # `Options` object, as these are unitiailized values. This ensures that
// 84:       # existing values in `self` aren't unexpectedly overwritten with defaults.
// 85:       sig { params(other: T.any(Options, T::Hash[Symbol, T.untyped])).returns(Options) }
// 86:       def merge!(other)
// 87:         return self if other.empty?
// 88:
// 89:         if other.is_a?(Options)
// 90:           return self if self == other
// 91:
// 92:           other.instance_variables.each do |ivar|
// 93:             next if (v = T.let(other.instance_variable_get(ivar), Object)).nil?
// 94:
// 95:             instance_variable_set(ivar, v)
// 96:           end
// 97:         else
// 98:           other.each do |k, v|
// 99:             cmd = :"#{k}="
// 100:             send(cmd, v) if respond_to?(cmd)
// 101:           end
// 102:         end
// 103:
// 104:         self
// 105:       end
// 106:
// 107:       sig { params(other: Object).returns(T::Boolean) }
// 108:       def ==(other)
// 109:         return false unless other.is_a?(Options)
// 110:
// 111:         @compressed == other.compressed &&
// 112:           @cookies == other.cookies &&
// 113:           @header == other.header &&
// 114:           @homebrew_curl == other.homebrew_curl &&
// 115:           @post_form == other.post_form &&
// 116:           @post_json == other.post_json &&
// 117:           @referer == other.referer &&
// 118:           @user_agent == other.user_agent
// 119:       end
// 120:       alias eql? ==
// 121:
// 122:       # Whether the object has only default values.
// 123:       sig { returns(T::Boolean) }
// 124:       def empty? = to_hash.empty?
// 125:
// 126:       # Whether the object has any non-default values.
// 127:       sig { returns(T::Boolean) }
// 128:       def present? = !empty?
// 129:     end
// 130:   end
// 131: end
