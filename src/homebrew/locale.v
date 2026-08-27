module homebrew

import brew_runtime

// Translated from Homebrew/brew `locale.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.parse(string)` at line 28.
pub fn ruby_locale_l28_d1_self_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.parse', ...args)
}

// Ruby method `self.try_parse(string)` at line 37.
pub fn ruby_locale_l37_d2_self_try_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.try_parse', ...args)
}

// Ruby attr_reader `attr_reader :language` at line 60.
pub fn ruby_locale_l60_d3_language(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('language', ...args)
}

// Ruby attr_reader `attr_reader :script` at line 63.
pub fn ruby_locale_l63_d4_script(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('script', ...args)
}

// Ruby attr_reader `attr_reader :region` at line 66.
pub fn ruby_locale_l66_d5_region(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('region', ...args)
}

// Ruby method `initialize(language, script, region)` at line 69.
pub fn ruby_locale_l69_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `include?(other)` at line 95.
pub fn ruby_locale_l95_d7_include(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('include?', ...args)
}

// Ruby method `eql?(other)` at line 109.
pub fn ruby_locale_l109_d8_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby alias `alias == eql?` at line 119.
pub fn ruby_locale_l119_d9_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby method `detect(locale_groups)` at line 128.
pub fn ruby_locale_l128_d10_detect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detect', ...args)
}

// Ruby method `to_s` at line 134.
pub fn ruby_locale_l134_d11_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Representation of a system locale.
// 5: #
// 6: # Used to compare the system language and languages defined using the cask `language` stanza.
// 7: class Locale
// 8:   # Error when a string cannot be parsed to a `Locale`.
// 9:   class ParserError < StandardError
// 10:   end
// 11:
// 12:   # ISO 639-1 or ISO 639-2
// 13:   LANGUAGE_REGEX = /(?:[a-z]{2,3})/
// 14:   private_constant :LANGUAGE_REGEX
// 15:
// 16:   # ISO 15924
// 17:   SCRIPT_REGEX = /(?:[A-Z][a-z]{3})/
// 18:   private_constant :SCRIPT_REGEX
// 19:
// 20:   # ISO 3166-1 or UN M.49
// 21:   REGION_REGEX = /(?:[A-Z]{2}|\d{3})/
// 22:   private_constant :REGION_REGEX
// 23:
// 24:   LOCALE_REGEX = /\A((?:#{LANGUAGE_REGEX}|#{REGION_REGEX}|#{SCRIPT_REGEX})(?:-|$)){1,3}\Z/
// 25:   private_constant :LOCALE_REGEX
// 26:
// 27:   sig { params(string: String).returns(T.attached_class) }
// 28:   def self.parse(string)
// 29:     if (locale = try_parse(string))
// 30:       return locale
// 31:     end
// 32:
// 33:     raise ParserError, "'#{string}' cannot be parsed to a #{self}"
// 34:   end
// 35:
// 36:   sig { params(string: String).returns(T.nilable(T.attached_class)) }
// 37:   def self.try_parse(string)
// 38:     return if string.blank?
// 39:
// 40:     scanner = StringScanner.new(string)
// 41:
// 42:     if (language = scanner.scan(LANGUAGE_REGEX))
// 43:       sep = scanner.scan("-")
// 44:       return if (sep && scanner.eos?) || (sep.nil? && !scanner.eos?)
// 45:     end
// 46:
// 47:     if (script = scanner.scan(SCRIPT_REGEX))
// 48:       sep = scanner.scan("-")
// 49:       return if (sep && scanner.eos?) || (sep.nil? && !scanner.eos?)
// 50:     end
// 51:
// 52:     region = scanner.scan(REGION_REGEX)
// 53:
// 54:     return unless scanner.eos?
// 55:
// 56:     new(language, script, region)
// 57:   end
// 58:
// 59:   sig { returns(T.nilable(String)) }
// 60:   attr_reader :language
// 61:
// 62:   sig { returns(T.nilable(String)) }
// 63:   attr_reader :script
// 64:
// 65:   sig { returns(T.nilable(String)) }
// 66:   attr_reader :region
// 67:
// 68:   sig { params(language: T.nilable(String), script: T.nilable(String), region: T.nilable(String)).void }
// 69:   def initialize(language, script, region)
// 70:     raise ArgumentError, "#{self.class} cannot be empty" if language.nil? && region.nil? && script.nil?
// 71:
// 72:     unless language.nil?
// 73:       regex = LANGUAGE_REGEX
// 74:       raise ParserError, "'language' does not match #{regex}" unless language.match?(regex)
// 75:
// 76:       @language = T.let(language, T.nilable(String))
// 77:     end
// 78:
// 79:     unless script.nil?
// 80:       regex = SCRIPT_REGEX
// 81:       raise ParserError, "'script' does not match #{regex}" unless script.match?(regex)
// 82:
// 83:       @script = T.let(script, T.nilable(String))
// 84:     end
// 85:
// 86:     return if region.nil?
// 87:
// 88:     regex = REGION_REGEX
// 89:     raise ParserError, "'region' does not match #{regex}" unless region.match?(regex)
// 90:
// 91:     @region = region
// 92:   end
// 93:
// 94:   sig { params(other: T.any(String, Locale)).returns(T::Boolean) }
// 95:   def include?(other)
// 96:     unless other.is_a?(self.class)
// 97:       other = self.class.try_parse(other)
// 98:       return false if other.nil?
// 99:     end
// 100:
// 101:     [:language, :script, :region].all? do |var|
// 102:       next true if other.public_send(var).nil?
// 103:
// 104:       public_send(var) == other.public_send(var)
// 105:     end
// 106:   end
// 107:
// 108:   sig { params(other: T.any(String, Locale)).returns(T::Boolean) }
// 109:   def eql?(other)
// 110:     unless other.is_a?(self.class)
// 111:       other = self.class.try_parse(other)
// 112:       return false if other.nil?
// 113:     end
// 114:
// 115:     [:language, :script, :region].all? do |var|
// 116:       public_send(var) == other.public_send(var)
// 117:     end
// 118:   end
// 119:   alias == eql?
// 120:
// 121:   sig {
// 122:     params(
// 123:       locale_groups: T::Enumerable[T::Enumerable[T.any(String, Locale)]],
// 124:     ).returns(
// 125:       T.nilable(T::Enumerable[T.any(String, Locale)]),
// 126:     )
// 127:   }
// 128:   def detect(locale_groups)
// 129:     locale_groups.find { |locales| locales.any? { |locale| eql?(locale) } } ||
// 130:       locale_groups.find { |locales| locales.any? { |locale| include?(locale) } }
// 131:   end
// 132:
// 133:   sig { returns(String) }
// 134:   def to_s
// 135:     [@language, @script, @region].compact.join("-")
// 136:   end
// 137: end
