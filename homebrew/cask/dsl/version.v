module dsl

import brew_runtime

// Translated from Homebrew/brew `cask/dsl/version.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `define_divider_methods(divider)` at line 24.
pub fn ruby_version_l24_d1_define_divider_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_divider_methods', ...args)
}

// Ruby method `define_divider_deletion_method(divider)` at line 30.
pub fn ruby_version_l30_d2_define_divider_deletion_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_divider_deletion_method', ...args)
}

// Ruby define_method `define_method(method_name) do` at line 32.
pub fn ruby_version_l32_d3_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_name', ...args)
}

// Ruby method `deletion_method_name(divider)` at line 39.
pub fn ruby_version_l39_d4_deletion_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deletion_method_name', ...args)
}

// Ruby method `define_divider_conversion_methods(left_divider)` at line 44.
pub fn ruby_version_l44_d5_define_divider_conversion_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_divider_conversion_methods', ...args)
}

// Ruby method `define_divider_conversion_method(left_divider, right_divider)` at line 51.
pub fn ruby_version_l51_d6_define_divider_conversion_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_divider_conversion_method', ...args)
}

// Ruby define_method `define_method(method_name) do` at line 53.
pub fn ruby_version_l53_d7_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_name', ...args)
}

// Ruby method `conversion_method_name(left_divider, right_divider)` at line 60.
pub fn ruby_version_l60_d8_conversion_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('conversion_method_name', ...args)
}

// Ruby attr_reader `attr_reader :raw_version` at line 70.
pub fn ruby_version_l70_d9_raw_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raw_version', ...args)
}

// Ruby method `initialize(raw_version)` at line 73.
pub fn ruby_version_l73_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `invalid_characters` at line 82.
pub fn ruby_version_l82_d11_invalid_characters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('invalid_characters', ...args)
}

// Ruby method `unstable?` at line 89.
pub fn ruby_version_l89_d12_unstable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unstable?', ...args)
}

// Ruby method `latest?` at line 101.
pub fn ruby_version_l101_d13_latest(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('latest?', ...args)
}

// Ruby method `major` at line 109.
pub fn ruby_version_l109_d14_major(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('major', ...args)
}

// Ruby method `minor` at line 117.
pub fn ruby_version_l117_d15_minor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('minor', ...args)
}

// Ruby method `patch` at line 125.
pub fn ruby_version_l125_d16_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby method `major_minor` at line 133.
pub fn ruby_version_l133_d17_major_minor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('major_minor', ...args)
}

// Ruby method `major_minor_patch` at line 141.
pub fn ruby_version_l141_d18_major_minor_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('major_minor_patch', ...args)
}

// Ruby method `minor_patch` at line 149.
pub fn ruby_version_l149_d19_minor_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('minor_patch', ...args)
}

// Ruby method `csv` at line 157.
pub fn ruby_version_l157_d20_csv(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('csv', ...args)
}

// Ruby method `before_comma` at line 165.
pub fn ruby_version_l165_d21_before_comma(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('before_comma', ...args)
}

// Ruby method `after_comma` at line 173.
pub fn ruby_version_l173_d22_after_comma(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('after_comma', ...args)
}

// Ruby method `no_dividers` at line 182.
pub fn ruby_version_l182_d23_no_dividers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_dividers', ...args)
}

// Ruby method `chomp(separator = T.unsafe(nil))` at line 191.
pub fn ruby_version_l191_d24_chomp(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('chomp', ...args)
}

// Ruby method `version(&_block)` at line 198.
pub fn ruby_version_l198_d25_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Cask
// 5:   class DSL
// 6:     # Class corresponding to the `version` stanza.
// 7:     class Version < ::String
// 8:       DIVIDERS = T.let({
// 9:         "." => :dots,
// 10:         "-" => :hyphens,
// 11:         "_" => :underscores,
// 12:       }.freeze, T::Hash[String, Symbol])
// 13:
// 14:       DIVIDER_REGEX = /(#{DIVIDERS.keys.map { |v| Regexp.quote(v) }.join("|")})/
// 15:
// 16:       MAJOR_MINOR_PATCH_REGEX = /^([^.,:]+)(?:.([^.,:]+)(?:.([^.,:]+))?)?/
// 17:
// 18:       INVALID_CHARACTERS = /[^0-9a-zA-Z.,:\-_+ ]/
// 19:
// 20:       class << self
// 21:         private
// 22:
// 23:         sig { params(divider: String).void }
// 24:         def define_divider_methods(divider)
// 25:           define_divider_deletion_method(divider)
// 26:           define_divider_conversion_methods(divider)
// 27:         end
// 28:
// 29:         sig { params(divider: String).void }
// 30:         def define_divider_deletion_method(divider)
// 31:           method_name = deletion_method_name(divider)
// 32:           define_method(method_name) do
// 33:             T.bind(self, Version)
// 34:             version { delete(divider) }
// 35:           end
// 36:         end
// 37:
// 38:         sig { params(divider: String).returns(String) }
// 39:         def deletion_method_name(divider)
// 40:           "no_#{DIVIDERS[divider]}"
// 41:         end
// 42:
// 43:         sig { params(left_divider: String).void }
// 44:         def define_divider_conversion_methods(left_divider)
// 45:           (DIVIDERS.keys - [left_divider]).each do |right_divider|
// 46:             define_divider_conversion_method(left_divider, right_divider)
// 47:           end
// 48:         end
// 49:
// 50:         sig { params(left_divider: String, right_divider: String).void }
// 51:         def define_divider_conversion_method(left_divider, right_divider)
// 52:           method_name = conversion_method_name(left_divider, right_divider)
// 53:           define_method(method_name) do
// 54:             T.bind(self, Version)
// 55:             version { gsub(left_divider, right_divider) }
// 56:           end
// 57:         end
// 58:
// 59:         sig { params(left_divider: String, right_divider: String).returns(String) }
// 60:         def conversion_method_name(left_divider, right_divider)
// 61:           "#{DIVIDERS[left_divider]}_to_#{DIVIDERS[right_divider]}"
// 62:         end
// 63:       end
// 64:
// 65:       DIVIDERS.each_key do |divider|
// 66:         define_divider_methods(divider)
// 67:       end
// 68:
// 69:       sig { returns(T.nilable(T.any(String, Symbol))) }
// 70:       attr_reader :raw_version
// 71:
// 72:       sig { params(raw_version: T.nilable(T.any(String, Symbol))).void }
// 73:       def initialize(raw_version)
// 74:         @raw_version = raw_version
// 75:         super(raw_version.to_s)
// 76:
// 77:         invalid = invalid_characters
// 78:         raise TypeError, "#{raw_version} contains invalid characters: #{invalid.uniq.join}!" if invalid.present?
// 79:       end
// 80:
// 81:       sig { returns(T::Array[T.any(T::Array[String], String)]) }
// 82:       def invalid_characters
// 83:         return [] if raw_version.blank? || latest?
// 84:
// 85:         raw_version.to_s.scan(INVALID_CHARACTERS)
// 86:       end
// 87:
// 88:       sig { returns(T::Boolean) }
// 89:       def unstable?
// 90:         return false if latest?
// 91:
// 92:         s = downcase.delete(".").gsub(/[^a-z\d]+/, "-")
// 93:
// 94:         return true if s.match?(/(\d+|\b)(alpha|beta|preview|rc|dev|canary|snapshot)(\d+|\b)/i)
// 95:         return true if s.match?(/\A[a-z\d]+(-\d+)*-?(a|b|pre)(\d+|\b)/i)
// 96:
// 97:         false
// 98:       end
// 99:
// 100:       sig { returns(T::Boolean) }
// 101:       def latest?
// 102:         to_s == "latest"
// 103:       end
// 104:
// 105:       # The major version.
// 106:       #
// 107:       # @api public
// 108:       sig { returns(T.self_type) }
// 109:       def major
// 110:         version { slice(MAJOR_MINOR_PATCH_REGEX, 1) }
// 111:       end
// 112:
// 113:       # The minor version.
// 114:       #
// 115:       # @api public
// 116:       sig { returns(T.self_type) }
// 117:       def minor
// 118:         version { slice(MAJOR_MINOR_PATCH_REGEX, 2) }
// 119:       end
// 120:
// 121:       # The patch version.
// 122:       #
// 123:       # @api public
// 124:       sig { returns(T.self_type) }
// 125:       def patch
// 126:         version { slice(MAJOR_MINOR_PATCH_REGEX, 3) }
// 127:       end
// 128:
// 129:       # The major and minor version.
// 130:       #
// 131:       # @api public
// 132:       sig { returns(T.self_type) }
// 133:       def major_minor
// 134:         version { [major, minor].reject(&:empty?).join(".") }
// 135:       end
// 136:
// 137:       # The major, minor and patch version.
// 138:       #
// 139:       # @api public
// 140:       sig { returns(T.self_type) }
// 141:       def major_minor_patch
// 142:         version { [major, minor, patch].reject(&:empty?).join(".") }
// 143:       end
// 144:
// 145:       # The minor and patch version.
// 146:       #
// 147:       # @api public
// 148:       sig { returns(T.self_type) }
// 149:       def minor_patch
// 150:         version { [minor, patch].reject(&:empty?).join(".") }
// 151:       end
// 152:
// 153:       # The comma separated values of the version as array.
// 154:       #
// 155:       # @api public
// 156:       sig { returns(T::Array[Version]) } # Only top-level T.self_type is supported https://sorbet.org/docs/self-type
// 157:       def csv
// 158:         split(",").map { self.class.new(it) }
// 159:       end
// 160:
// 161:       # The version part before the first comma.
// 162:       #
// 163:       # @api public
// 164:       sig { returns(T.self_type) }
// 165:       def before_comma
// 166:         version { split(",", 2).first }
// 167:       end
// 168:
// 169:       # The version part after the first comma.
// 170:       #
// 171:       # @api public
// 172:       sig { returns(T.self_type) }
// 173:       def after_comma
// 174:         version { split(",", 2).second }
// 175:       end
// 176:
// 177:       # The version without any dividers.
// 178:       #
// 179:       # @see DIVIDER_REGEX
// 180:       # @api public
// 181:       sig { returns(T.self_type) }
// 182:       def no_dividers
// 183:         version { gsub(DIVIDER_REGEX, "") }
// 184:       end
// 185:
// 186:       # The version with the given record separator removed from the end.
// 187:       #
// 188:       # @see String#chomp
// 189:       # @api public
// 190:       sig { params(separator: String).returns(T.self_type) }
// 191:       def chomp(separator = T.unsafe(nil))
// 192:         version { to_s.chomp(separator) }
// 193:       end
// 194:
// 195:       private
// 196:
// 197:       sig { params(_block: T.proc.returns(T.nilable(String))).returns(T.self_type) }
// 198:       def version(&_block)
// 199:         return self if empty? || latest?
// 200:
// 201:         self.class.new(yield)
// 202:       end
// 203:     end
// 204:   end
// 205: end
