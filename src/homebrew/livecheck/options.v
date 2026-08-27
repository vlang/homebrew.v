module livecheck

import brew_runtime

// Translated from Homebrew/brew `livecheck/options.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `url_options` at line 39.
pub fn ruby_options_l39_d1_url_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url_options', ...args)
}

// Ruby method `to_hash` at line 54.
pub fn ruby_options_l54_d2_to_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_hash', ...args)
}

// Ruby method `to_h = to_hash.transform_keys(&:to_sym)` at line 60.
pub fn ruby_options_l60_d3_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `merge(other)` at line 69.
pub fn ruby_options_l69_d4_merge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge', ...args)
}

// Ruby method `merge!(other)` at line 86.
pub fn ruby_options_l86_d5_merge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge!', ...args)
}

// Ruby method `==(other)` at line 108.
pub fn ruby_options_l108_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby alias `alias eql? ==` at line 120.
pub fn ruby_options_l120_d7_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby method `empty? = to_hash.empty?` at line 124.
pub fn ruby_options_l124_d8_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('empty?', ...args)
}

// Ruby method `present? = !empty?` at line 128.
pub fn ruby_options_l128_d9_present(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('present?', ...args)
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
