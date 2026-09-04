module homebrew

import ruby

// Translated from Homebrew/brew `locale.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.parse(string)` at line 28.
pub fn ruby_locale_l28_d1_self_parse(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic("'' cannot be parsed to a Locale")
	}
	return locale_value(parse_locale(args[0].as_string()) or { panic(err) })
}

// Ruby method `self.try_parse(string)` at line 37.
pub fn ruby_locale_l37_d2_self_try_parse(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('Nil', '')
	}
	return if locale := try_parse_locale(args[0].as_string()) {
		locale_value(locale)
	} else {
		ruby.object_value('Nil', '')
	}
}

// Ruby attr_reader `attr_reader :language` at line 60.
pub fn ruby_locale_l60_d3_language(args ...ruby.Value) ruby.Value {
	return locale_attribute(args, 'language')
}

// Ruby attr_reader `attr_reader :script` at line 63.
pub fn ruby_locale_l63_d4_script(args ...ruby.Value) ruby.Value {
	return locale_attribute(args, 'script')
}

// Ruby attr_reader `attr_reader :region` at line 66.
pub fn ruby_locale_l66_d5_region(args ...ruby.Value) ruby.Value {
	return locale_attribute(args, 'region')
}

// Ruby method `initialize(language, script, region)` at line 69.
pub fn ruby_locale_l69_d6_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Locale cannot be empty')
	}
	return locale_value(new_locale(args[0].as_string(), args[1].as_string(), args[2].as_string()) or {
		panic(err)
	})
}

// Ruby method `include?(other)` at line 95.
pub fn ruby_locale_l95_d7_include(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	locale := locale_from_value(args[0]) or { return ruby.bool_value(false) }
	return ruby.bool_value(locale.includes_string(args[1].as_string()))
}

// Ruby method `eql?(other)` at line 109.
pub fn ruby_locale_l109_d8_eql(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	locale := locale_from_value(args[0]) or { return ruby.bool_value(false) }
	return ruby.bool_value(locale.equals_string(args[1].as_string()))
}

// Ruby alias `alias == eql?` at line 119.
pub fn ruby_locale_l119_d9_anonymous(args ...ruby.Value) ruby.Value {
	return ruby_locale_l109_d8_eql(...args)
}

// Ruby method `detect(locale_groups)` at line 128.
pub fn ruby_locale_l128_d10_detect(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('Nil', '')
	}
	locale := locale_from_value(args[0]) or { return ruby.object_value('Nil', '') }
	mut groups := [][]string{}
	for group in args[1].array_data {
		groups << (group.as_string_array() or { [] })
	}
	return if detected := locale.detect(groups) {
		ruby.string_array_value(detected)
	} else {
		ruby.object_value('Nil', '')
	}
}

// Ruby method `to_s` at line 134.
pub fn ruby_locale_l134_d11_to_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	locale := locale_from_value(args[0]) or {
		return ruby.string_value(args[0].as_string())
	}
	return ruby.string_value(locale.str())
}

// Locale is the V representation of Homebrew's ordered language, script, and
// region components. Empty fields represent Ruby nil.
pub struct Locale {
pub:
	language string
	script   string
	region   string
}

pub fn new_locale(language string, script string, region string) !Locale {
	if language.len == 0 && script.len == 0 && region.len == 0 {
		return error('Locale cannot be empty')
	}
	if language.len > 0 && !valid_language(language) {
		return error("'language' does not match locale language format")
	}
	if script.len > 0 && !valid_script(script) {
		return error("'script' does not match locale script format")
	}
	if region.len > 0 && !valid_region(region) {
		return error("'region' does not match locale region format")
	}
	return Locale{
		language: language
		script:   script
		region:   region
	}
}

pub fn parse_locale(input string) !Locale {
	return try_parse_locale(input) or { return error("'${input}' cannot be parsed to a Locale") }
}

pub fn try_parse_locale(input string) ?Locale {
	if input.len == 0 || input.starts_with('-') || input.ends_with('-') {
		return none
	}
	parts := input.split('-')
	if parts.len == 0 || parts.len > 3 || parts.any(it.len == 0) {
		return none
	}
	mut language := ''
	mut script := ''
	mut region := ''
	mut position := 0
	if position < parts.len && valid_language(parts[position]) {
		language = parts[position]
		position++
	}
	if position < parts.len && valid_script(parts[position]) {
		script = parts[position]
		position++
	}
	if position < parts.len && valid_region(parts[position]) {
		region = parts[position]
		position++
	}
	if position != parts.len {
		return none
	}
	return new_locale(language, script, region) or { none }
}

pub fn (locale Locale) includes(other Locale) bool {
	return (other.language.len == 0 || locale.language == other.language)
		&& (other.script.len == 0 || locale.script == other.script)
		&& (other.region.len == 0 || locale.region == other.region)
}

pub fn (locale Locale) includes_string(other string) bool {
	parsed := try_parse_locale(other) or { return false }
	return locale.includes(parsed)
}

pub fn (locale Locale) equals(other Locale) bool {
	return locale.language == other.language && locale.script == other.script
		&& locale.region == other.region
}

pub fn (locale Locale) equals_string(other string) bool {
	parsed := try_parse_locale(other) or { return false }
	return locale.equals(parsed)
}

pub fn (locale Locale) detect(locale_groups [][]string) ?[]string {
	for group in locale_groups {
		if group.any(locale.equals_string(it)) {
			return group.clone()
		}
	}
	for group in locale_groups {
		if group.any(locale.includes_string(it)) {
			return group.clone()
		}
	}
	return none
}

pub fn (locale Locale) str() string {
	return [locale.language, locale.script, locale.region].filter(it.len > 0).join('-')
}

fn valid_language(value string) bool {
	return value.len in [2, 3] && value.bytes().all(it >= `a` && it <= `z`)
}

fn valid_script(value string) bool {
	return value.len == 4 && value[0] >= `A` && value[0] <= `Z` && value[1..].bytes().all(it >= `a`
		&& it <= `z`)
}

fn valid_region(value string) bool {
	return (value.len == 2 && value.bytes().all(it >= `A` && it <= `Z`))
		|| (value.len == 3 && value.bytes().all(it >= `0` && it <= `9`))
}

fn locale_value(locale Locale) ruby.Value {
	return ruby.structured_value('Locale', locale.str(), {
		'language': locale.language
		'script':   locale.script
		'region':   locale.region
	})
}

fn locale_from_value(value ruby.Value) !Locale {
	if value.type_name == 'Locale' {
		return new_locale(value.attributes['language'], value.attributes['script'],
			value.attributes['region'])
	}
	return parse_locale(value.as_string())
}

fn locale_attribute(args []ruby.Value, name string) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('Nil', '')
	}
	value := args[0].attribute(name) or { '' }
	return if value.len > 0 {
		ruby.string_value(value)
	} else {
		ruby.object_value('Nil', '')
	}
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
