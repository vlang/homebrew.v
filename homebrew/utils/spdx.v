module utils

import brew_runtime

// Translated from Homebrew/brew `utils/spdx.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `license_data` at line 21.
pub fn ruby_spdx_l21_d1_license_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('license_data', ...args)
}

// Ruby method `exception_data` at line 26.
pub fn ruby_spdx_l26_d2_exception_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exception_data', ...args)
}

// Ruby method `latest_tag` at line 32.
pub fn ruby_spdx_l32_d3_latest_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('latest_tag', ...args)
}

// Ruby method `download_latest_license_data!(to: DATA_PATH)` at line 37.
pub fn ruby_spdx_l37_d4_download_latest_license_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download_latest_license_data!', ...args)
}

// Ruby method `parse_license_expression(license_expression)` at line 57.
pub fn ruby_spdx_l57_d5_parse_license_expression(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_license_expression', ...args)
}

// Ruby method `valid_license?(license)` at line 87.
pub fn ruby_spdx_l87_d6_valid_license(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_license?', ...args)
}

// Ruby method `deprecated_license?(license)` at line 95.
pub fn ruby_spdx_l95_d7_deprecated_license(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deprecated_license?', ...args)
}

// Ruby method `valid_license_exception?(exception)` at line 106.
pub fn ruby_spdx_l106_d8_valid_license_exception(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_license_exception?', ...args)
}

// Ruby method `license_expression_to_string(license_expression, bracket: false, hash_type: nil)` at line 119.
pub fn ruby_spdx_l119_d9_license_expression_to_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('license_expression_to_string', ...args)
}

// Ruby method `string_to_license_expression(string)` at line 167.
pub fn ruby_spdx_l167_d10_string_to_license_expression(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('string_to_license_expression', ...args)
}

// Ruby method `truncate_license(license, limit: 255)` at line 211.
pub fn ruby_spdx_l211_d11_truncate_license(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('truncate_license', ...args)
}

// Ruby method `license_version_info(license)` at line 252.
pub fn ruby_spdx_l252_d12_license_version_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('license_version_info', ...args)
}

// Ruby method `licenses_forbid_installation?(license_expression, forbidden_licenses)` at line 270.
pub fn ruby_spdx_l270_d13_licenses_forbid_installation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('licenses_forbid_installation?', ...args)
}

// Ruby method `forbidden_licenses_include?(license, forbidden_licenses)` at line 295.
pub fn ruby_spdx_l295_d14_forbidden_licenses_include(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('forbidden_licenses_include?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/curl"
// 5: require "utils/github"
// 6:
// 7: # Helper module for updating SPDX license data.
// 8: module SPDX
// 9:   module_function
// 10:
// 11:   DATA_PATH = T.let((HOMEBREW_DATA_PATH/"spdx").freeze, Pathname)
// 12:   API_URL = "https://api.github.com/repos/spdx/license-list-data/releases/latest"
// 13:   LICENSEREF_PREFIX = "LicenseRef-Homebrew-"
// 14:   ALLOWED_LICENSE_SYMBOLS = [
// 15:     :public_domain,
// 16:     :cannot_represent,
// 17:     :truncated,
// 18:   ].freeze
// 19:
// 20:   sig { returns(T::Hash[String, T.untyped]) }
// 21:   def license_data
// 22:     @license_data ||= T.let(JSON.parse((DATA_PATH/"spdx_licenses.json").read), T.nilable(T::Hash[String, T.untyped]))
// 23:   end
// 24:
// 25:   sig { returns(T::Hash[String, T.untyped]) }
// 26:   def exception_data
// 27:     @exception_data ||= T.let(JSON.parse((DATA_PATH/"spdx_exceptions.json").read),
// 28:                               T.nilable(T::Hash[String, T.untyped]))
// 29:   end
// 30:
// 31:   sig { returns(String) }
// 32:   def latest_tag
// 33:     @latest_tag ||= T.let(GitHub::API.open_rest(API_URL)["tag_name"], T.nilable(String))
// 34:   end
// 35:
// 36:   sig { params(to: Pathname).void }
// 37:   def download_latest_license_data!(to: DATA_PATH)
// 38:     data_url = "https://raw.githubusercontent.com/spdx/license-list-data/refs/tags/#{latest_tag}/json/"
// 39:     Utils::Curl.curl_download("#{data_url}licenses.json", to: to/"spdx_licenses.json")
// 40:     Utils::Curl.curl_download("#{data_url}exceptions.json", to: to/"spdx_exceptions.json")
// 41:   end
// 42:
// 43:   sig {
// 44:     params(
// 45:       license_expression: T.any(
// 46:         String,
// 47:         Symbol,
// 48:         T::Hash[T.any(Symbol, String), T.untyped],
// 49:         T::Array[String],
// 50:       ),
// 51:     ).returns(
// 52:       [
// 53:         T::Array[T.any(String, Symbol)], T::Array[String]
// 54:       ],
// 55:     )
// 56:   }
// 57:   def parse_license_expression(license_expression)
// 58:     licenses = T.let([], T::Array[T.any(String, Symbol)])
// 59:     exceptions = T.let([], T::Array[String])
// 60:
// 61:     case license_expression
// 62:     when String, Symbol
// 63:       licenses.push license_expression
// 64:     when Hash, Array
// 65:       if license_expression.is_a? Hash
// 66:         license_expression = license_expression.filter_map do |key, value|
// 67:           if key.is_a? String
// 68:             licenses.push key
// 69:             exceptions.push value[:with]
// 70:             next
// 71:           end
// 72:           value
// 73:         end
// 74:       end
// 75:
// 76:       license_expression.each do |license|
// 77:         sub_license, sub_exception = parse_license_expression license
// 78:         licenses += sub_license
// 79:         exceptions += sub_exception
// 80:       end
// 81:     end
// 82:
// 83:     [licenses, exceptions]
// 84:   end
// 85:
// 86:   sig { params(license: T.any(String, Symbol)).returns(T::Boolean) }
// 87:   def valid_license?(license)
// 88:     return ALLOWED_LICENSE_SYMBOLS.include? license if license.is_a? Symbol
// 89:
// 90:     license = license.delete_suffix "+"
// 91:     license_data["licenses"].any? { |spdx_license| spdx_license["licenseId"].downcase == license.downcase }
// 92:   end
// 93:
// 94:   sig { params(license: T.any(String, Symbol)).returns(T::Boolean) }
// 95:   def deprecated_license?(license)
// 96:     return false if ALLOWED_LICENSE_SYMBOLS.include? license
// 97:     return false unless valid_license?(license)
// 98:
// 99:     license = license.to_s.delete_suffix "+"
// 100:     license_data["licenses"].none? do |spdx_license|
// 101:       spdx_license["licenseId"].downcase == license.downcase && !spdx_license["isDeprecatedLicenseId"]
// 102:     end
// 103:   end
// 104:
// 105:   sig { params(exception: String).returns(T::Boolean) }
// 106:   def valid_license_exception?(exception)
// 107:     exception_data["exceptions"].any? do |spdx_exception|
// 108:       spdx_exception["licenseExceptionId"].downcase == exception.downcase && !spdx_exception["isDeprecatedLicenseId"]
// 109:     end
// 110:   end
// 111:
// 112:   sig {
// 113:     params(
// 114:       license_expression: T.any(String, Symbol, T::Hash[T.nilable(T.any(Symbol, String)), T.untyped]),
// 115:       bracket:            T::Boolean,
// 116:       hash_type:          T.nilable(T.any(String, Symbol)),
// 117:     ).returns(T.nilable(String))
// 118:   }
// 119:   def license_expression_to_string(license_expression, bracket: false, hash_type: nil)
// 120:     case license_expression
// 121:     when String
// 122:       license_expression
// 123:     when Symbol
// 124:       LICENSEREF_PREFIX + license_expression.to_s.tr("_", "-")
// 125:     when Hash
// 126:       expressions = []
// 127:
// 128:       if license_expression.keys.length == 1
// 129:         hash_type = license_expression.keys.first
// 130:         if hash_type.is_a? String
// 131:           expressions.push "#{hash_type} WITH #{license_expression[hash_type][:with]}"
// 132:         else
// 133:           expressions += license_expression[hash_type].map do |license|
// 134:             license_expression_to_string license, bracket: true, hash_type:
// 135:           end
// 136:         end
// 137:       else
// 138:         bracket = false
// 139:         license_expression.each do |expression|
// 140:           expressions.push license_expression_to_string([expression].to_h, bracket: true)
// 141:         end
// 142:       end
// 143:
// 144:       operator = if hash_type == :any_of
// 145:         " OR "
// 146:       else
// 147:         " AND "
// 148:       end
// 149:
// 150:       if bracket
// 151:         "(#{expressions.join operator})"
// 152:       else
// 153:         expressions.join operator
// 154:       end
// 155:     end
// 156:   end
// 157:
// 158:   LicenseExpression = T.type_alias do
// 159:     T.any(
// 160:       String,
// 161:       Symbol,
// 162:       T::Hash[T.any(String, Symbol), T.anything],
// 163:     )
// 164:   end
// 165:
// 166:   sig { params(string: T.nilable(String)).returns(T.nilable(LicenseExpression)) }
// 167:   def string_to_license_expression(string)
// 168:     return if string.blank?
// 169:
// 170:     result = string
// 171:     result_type = nil
// 172:
// 173:     and_parts = string.split(/ and (?![^(]*\))/i)
// 174:     if and_parts.length > 1
// 175:       result = and_parts
// 176:       result_type = :all_of
// 177:     else
// 178:       or_parts = string.split(/ or (?![^(]*\))/i)
// 179:       if or_parts.length > 1
// 180:         result = or_parts
// 181:         result_type = :any_of
// 182:       end
// 183:     end
// 184:
// 185:     if result_type
// 186:       result.map! do |part|
// 187:         part = part[1..-2] if part[0] == "(" && part[-1] == ")"
// 188:         string_to_license_expression(part)
// 189:       end
// 190:       { result_type => result }
// 191:     else
// 192:       with_parts = string.split(/ with /i, 2)
// 193:       if with_parts.length > 1
// 194:         { with_parts.first => { with: with_parts.second } }
// 195:       else
// 196:         return result unless result.start_with?(LICENSEREF_PREFIX)
// 197:
// 198:         license_sym = result.delete_prefix(LICENSEREF_PREFIX).downcase.tr("-", "_").to_sym
// 199:         ALLOWED_LICENSE_SYMBOLS.include?(license_sym) ? license_sym : result
// 200:       end
// 201:     end
// 202:   end
// 203:
// 204:   # The `org.opencontainers.image.licenses` OCI annotation only accepts a limited
// 205:   # length (`limit`). GHCR rejects 256-character values on OCI child manifests, so
// 206:   # the default is 255. Shorten an over-long licence to a valid prefix rather than
// 207:   # discarding it entirely. Only top-level `AND` expressions can be shortened safely:
// 208:   # a prefix of "A AND B AND ..." still holds, whereas dropping `OR` alternatives
// 209:   # would change the licence, so those fall back to `:cannot_represent`.
// 210:   sig { params(license: String, limit: Integer).returns(String) }
// 211:   def truncate_license(license, limit: 255)
// 212:     return license if license.length <= limit
// 213:
// 214:     fallback = license_expression_to_string(:cannot_represent) || license
// 215:
// 216:     # Split on top-level `AND`, re-joining any segment split inside a bracketed
// 217:     # sub-expression so each part stays a valid, balanced licence. A single part
// 218:     # means a top-level `OR` (or a lone licence) that cannot be safely shortened.
// 219:     parts = T.let([], T::Array[String])
// 220:     license.split(" AND ").each do |segment|
// 221:       previous = parts.last
// 222:       if previous && previous.count("(") > previous.count(")")
// 223:         parts[-1] = "#{previous} AND #{segment}"
// 224:       else
// 225:         parts << segment
// 226:       end
// 227:     end
// 228:     return fallback if parts.length < 2
// 229:
// 230:     marker = license_expression_to_string(:truncated) || "truncated"
// 231:     kept = T.let([], T::Array[String])
// 232:     parts.each do |part|
// 233:       break if [*kept, part, marker].join(" AND ").length > limit
// 234:
// 235:       kept << part
// 236:     end
// 237:     return fallback if kept.empty?
// 238:
// 239:     [*kept, marker].join(" AND ")
// 240:   end
// 241:
// 242:   sig {
// 243:     params(
// 244:       license: T.any(String, Symbol),
// 245:     ).returns(
// 246:       T.any(
// 247:         [T.any(String, Symbol)],
// 248:         [String, T.nilable(String), T::Boolean],
// 249:       ),
// 250:     )
// 251:   }
// 252:   def license_version_info(license)
// 253:     return [license] if ALLOWED_LICENSE_SYMBOLS.include? license
// 254:
// 255:     match = license.match(/-(?<version>[0-9.]+)(?:-.*?)??(?<or_later>\+|-only|-or-later)?$/)
// 256:     return [license] if match.blank?
// 257:
// 258:     license_name = license.to_s.split(match[0].to_s).first
// 259:     or_later = match["or_later"].present? && %w[+ -or-later].include?(match["or_later"])
// 260:
// 261:     # [name, version, later versions allowed?]
// 262:     # e.g. GPL-2.0-or-later --> ["GPL", "2.0", true]
// 263:     [license_name, match["version"], or_later]
// 264:   end
// 265:
// 266:   sig {
// 267:     params(license_expression: T.any(String, Symbol, T::Hash[T.any(Symbol, String), T.untyped]),
// 268:            forbidden_licenses: T::Hash[T.any(Symbol, String), T.untyped]).returns(T::Boolean)
// 269:   }
// 270:   def licenses_forbid_installation?(license_expression, forbidden_licenses)
// 271:     case license_expression
// 272:     when String, Symbol
// 273:       forbidden_licenses_include? license_expression, forbidden_licenses
// 274:     when Hash
// 275:       key = license_expression.keys.first
// 276:       return false if key.nil?
// 277:
// 278:       case key
// 279:       when :any_of
// 280:         license_expression[key].all? { |license| licenses_forbid_installation? license, forbidden_licenses }
// 281:       when :all_of
// 282:         license_expression[key].any? { |license| licenses_forbid_installation? license, forbidden_licenses }
// 283:       else
// 284:         forbidden_licenses_include? key, forbidden_licenses
// 285:       end
// 286:     end
// 287:   end
// 288:
// 289:   sig {
// 290:     params(
// 291:       license:            T.any(Symbol, String),
// 292:       forbidden_licenses: T::Hash[T.any(Symbol, String), T.untyped],
// 293:     ).returns(T::Boolean)
// 294:   }
// 295:   def forbidden_licenses_include?(license, forbidden_licenses)
// 296:     return true if forbidden_licenses.key? license
// 297:
// 298:     name, version, = license_version_info license
// 299:
// 300:     forbidden_licenses.each_value do |license_info|
// 301:       forbidden_name, forbidden_version, forbidden_or_later = *license_info
// 302:       next if forbidden_name != name
// 303:
// 304:       return true if forbidden_or_later && forbidden_version <= version
// 305:
// 306:       return true if forbidden_version == version
// 307:     end
// 308:     false
// 309:   end
// 310: end
