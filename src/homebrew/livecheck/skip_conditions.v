module livecheck

import brew_runtime

// Translated from Homebrew/brew `livecheck/skip_conditions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.package_or_resource_skip(` at line 17.
pub fn ruby_skip_conditions_l17_d1_self_package_or_resource_skip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.package_or_resource_skip', ...args)
}

// Ruby method `self.formula_head_only(formula, _livecheck_defined, full_name: false, verbose: false)` at line 59.
pub fn ruby_skip_conditions_l59_d2_self_formula_head_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_head_only', ...args)
}

// Ruby method `self.formula_deprecated(formula, livecheck_defined, full_name: false, verbose: false)` at line 79.
pub fn ruby_skip_conditions_l79_d3_self_formula_deprecated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_deprecated', ...args)
}

// Ruby method `self.formula_disabled(formula, livecheck_defined, full_name: false, verbose: false)` at line 93.
pub fn ruby_skip_conditions_l93_d4_self_formula_disabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_disabled', ...args)
}

// Ruby method `self.formula_versioned(formula, livecheck_defined, full_name: false, verbose: false)` at line 107.
pub fn ruby_skip_conditions_l107_d5_self_formula_versioned(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_versioned', ...args)
}

// Ruby method `self.cask_deprecated(cask, livecheck_defined, full_name: false, verbose: false)` at line 121.
pub fn ruby_skip_conditions_l121_d6_self_cask_deprecated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_deprecated', ...args)
}

// Ruby method `self.cask_disabled(cask, livecheck_defined, full_name: false, verbose: false)` at line 136.
pub fn ruby_skip_conditions_l136_d7_self_cask_disabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_disabled', ...args)
}

// Ruby method `self.cask_extract_plist(` at line 151.
pub fn ruby_skip_conditions_l151_d8_self_cask_extract_plist(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_extract_plist', ...args)
}

// Ruby method `self.cask_version_latest(cask, livecheck_defined, full_name: false, verbose: false)` at line 177.
pub fn ruby_skip_conditions_l177_d9_self_cask_version_latest(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_version_latest', ...args)
}

// Ruby method `self.cask_url_unversioned(cask, livecheck_defined, full_name: false, verbose: false)` at line 191.
pub fn ruby_skip_conditions_l191_d10_self_cask_url_unversioned(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_url_unversioned', ...args)
}

// Ruby method `self.skip_information(package_or_resource, full_name: false, verbose: false, extract_plist: true)` at line 235.
pub fn ruby_skip_conditions_l235_d11_self_skip_information(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.skip_information', ...args)
}

// Ruby method `self.referenced_skip_information(` at line 273.
pub fn ruby_skip_conditions_l273_d12_self_referenced_skip_information(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.referenced_skip_information', ...args)
}

// Ruby method `self.print_skip_information(skip_hash)` at line 315.
pub fn ruby_skip_conditions_l315_d13_self_print_skip_information(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.print_skip_information', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Livecheck
// 6:     # The `Livecheck::SkipConditions` module primarily contains methods that
// 7:     # check for various formula/cask/resource conditions where a check should be skipped.
// 8:     module SkipConditions
// 9:       sig {
// 10:         params(
// 11:           package_or_resource: T.any(Formula, Cask::Cask, Resource),
// 12:           livecheck_defined:   T::Boolean,
// 13:           full_name:           T::Boolean,
// 14:           verbose:             T::Boolean,
// 15:         ).returns(T::Hash[Symbol, T.untyped])
// 16:       }
// 17:       private_class_method def self.package_or_resource_skip(
// 18:         package_or_resource,
// 19:         livecheck_defined,
// 20:         full_name: false,
// 21:         verbose: false
// 22:       )
// 23:         formula = package_or_resource if package_or_resource.is_a?(Formula)
// 24:
// 25:         if (stable_url = formula&.stable&.url)
// 26:           stable_is_gist = stable_url.match?(%r{https?://gist\.github(?:usercontent)?\.com/}i)
// 27:           stable_from_google_code_archive = stable_url.match?(
// 28:             %r{https?://storage\.googleapis\.com/google-code-archive-downloads/}i,
// 29:           )
// 30:           stable_from_internet_archive = stable_url.match?(%r{https?://web\.archive\.org/}i)
// 31:         end
// 32:
// 33:         skip_message = if package_or_resource.livecheck.skip_msg.present?
// 34:           package_or_resource.livecheck.skip_msg
// 35:         elsif !livecheck_defined
// 36:           if stable_from_google_code_archive
// 37:             "Stable URL is from Google Code Archive"
// 38:           elsif stable_from_internet_archive
// 39:             "Stable URL is from Internet Archive"
// 40:           elsif stable_is_gist
// 41:             "Stable URL is a GitHub Gist"
// 42:           end
// 43:         end
// 44:
// 45:         return {} if !package_or_resource.livecheck.skip? && skip_message.blank?
// 46:
// 47:         skip_messages = skip_message ? [skip_message] : nil
// 48:         Livecheck.status_hash(package_or_resource, "skipped", skip_messages, full_name:, verbose:)
// 49:       end
// 50:
// 51:       sig {
// 52:         params(
// 53:           formula:            Formula,
// 54:           _livecheck_defined: T::Boolean,
// 55:           full_name:          T::Boolean,
// 56:           verbose:            T::Boolean,
// 57:         ).returns(T::Hash[Symbol, T.untyped])
// 58:       }
// 59:       private_class_method def self.formula_head_only(formula, _livecheck_defined, full_name: false, verbose: false)
// 60:         return {} if !formula.head_only? || formula.any_version_installed?
// 61:
// 62:         Livecheck.status_hash(
// 63:           formula,
// 64:           "error",
// 65:           ["HEAD only formula must be installed to be checkable"],
// 66:           full_name:,
// 67:           verbose:,
// 68:         )
// 69:       end
// 70:
// 71:       sig {
// 72:         params(
// 73:           formula:           Formula,
// 74:           livecheck_defined: T::Boolean,
// 75:           full_name:         T::Boolean,
// 76:           verbose:           T::Boolean,
// 77:         ).returns(T::Hash[Symbol, T.untyped])
// 78:       }
// 79:       private_class_method def self.formula_deprecated(formula, livecheck_defined, full_name: false, verbose: false)
// 80:         return {} if !formula.deprecated? || livecheck_defined
// 81:
// 82:         Livecheck.status_hash(formula, "deprecated", full_name:, verbose:)
// 83:       end
// 84:
// 85:       sig {
// 86:         params(
// 87:           formula:           Formula,
// 88:           livecheck_defined: T::Boolean,
// 89:           full_name:         T::Boolean,
// 90:           verbose:           T::Boolean,
// 91:         ).returns(T::Hash[Symbol, T.untyped])
// 92:       }
// 93:       private_class_method def self.formula_disabled(formula, livecheck_defined, full_name: false, verbose: false)
// 94:         return {} if !formula.disabled? || livecheck_defined
// 95:
// 96:         Livecheck.status_hash(formula, "disabled", full_name:, verbose:)
// 97:       end
// 98:
// 99:       sig {
// 100:         params(
// 101:           formula:           Formula,
// 102:           livecheck_defined: T::Boolean,
// 103:           full_name:         T::Boolean,
// 104:           verbose:           T::Boolean,
// 105:         ).returns(T::Hash[Symbol, T.untyped])
// 106:       }
// 107:       private_class_method def self.formula_versioned(formula, livecheck_defined, full_name: false, verbose: false)
// 108:         return {} if !formula.versioned_formula? || livecheck_defined
// 109:
// 110:         Livecheck.status_hash(formula, "versioned", full_name:, verbose:)
// 111:       end
// 112:
// 113:       sig {
// 114:         params(
// 115:           cask:              Cask::Cask,
// 116:           livecheck_defined: T::Boolean,
// 117:           full_name:         T::Boolean,
// 118:           verbose:           T::Boolean,
// 119:         ).returns(T::Hash[Symbol, T.untyped])
// 120:       }
// 121:       private_class_method def self.cask_deprecated(cask, livecheck_defined, full_name: false, verbose: false)
// 122:         return {} if !cask.deprecated? || livecheck_defined
// 123:         return {} if cask.disable_date && cask.deprecation_reason == :fails_gatekeeper_check
// 124:
// 125:         Livecheck.status_hash(cask, "deprecated", full_name:, verbose:)
// 126:       end
// 127:
// 128:       sig {
// 129:         params(
// 130:           cask:              Cask::Cask,
// 131:           livecheck_defined: T::Boolean,
// 132:           full_name:         T::Boolean,
// 133:           verbose:           T::Boolean,
// 134:         ).returns(T::Hash[Symbol, T.untyped])
// 135:       }
// 136:       private_class_method def self.cask_disabled(cask, livecheck_defined, full_name: false, verbose: false)
// 137:         return {} if !cask.disabled? || livecheck_defined
// 138:
// 139:         Livecheck.status_hash(cask, "disabled", full_name:, verbose:)
// 140:       end
// 141:
// 142:       sig {
// 143:         params(
// 144:           cask:               Cask::Cask,
// 145:           _livecheck_defined: T::Boolean,
// 146:           full_name:          T::Boolean,
// 147:           verbose:            T::Boolean,
// 148:           extract_plist:      T::Boolean,
// 149:         ).returns(T::Hash[Symbol, T.untyped])
// 150:       }
// 151:       private_class_method def self.cask_extract_plist(
// 152:         cask,
// 153:         _livecheck_defined,
// 154:         full_name: false,
// 155:         verbose: false,
// 156:         extract_plist: false
// 157:       )
// 158:         return {} if extract_plist || cask.livecheck.strategy != :extract_plist
// 159:
// 160:         Livecheck.status_hash(
// 161:           cask,
// 162:           "skipped",
// 163:           ["Use `--extract-plist` to enable checking multiple casks with ExtractPlist strategy"],
// 164:           full_name:,
// 165:           verbose:,
// 166:         )
// 167:       end
// 168:
// 169:       sig {
// 170:         params(
// 171:           cask:              Cask::Cask,
// 172:           livecheck_defined: T::Boolean,
// 173:           full_name:         T::Boolean,
// 174:           verbose:           T::Boolean,
// 175:         ).returns(T::Hash[Symbol, T.untyped])
// 176:       }
// 177:       private_class_method def self.cask_version_latest(cask, livecheck_defined, full_name: false, verbose: false)
// 178:         return {} if !(cask.present? && cask.version&.latest?) || livecheck_defined
// 179:
// 180:         Livecheck.status_hash(cask, "latest", full_name:, verbose:)
// 181:       end
// 182:
// 183:       sig {
// 184:         params(
// 185:           cask:              Cask::Cask,
// 186:           livecheck_defined: T::Boolean,
// 187:           full_name:         T::Boolean,
// 188:           verbose:           T::Boolean,
// 189:         ).returns(T::Hash[Symbol, T.untyped])
// 190:       }
// 191:       private_class_method def self.cask_url_unversioned(cask, livecheck_defined, full_name: false, verbose: false)
// 192:         return {} if !(cask.present? && cask.url&.unversioned?) || livecheck_defined
// 193:
// 194:         Livecheck.status_hash(cask, "unversioned", full_name:, verbose:)
// 195:       end
// 196:
// 197:       # Skip conditions for formulae.
// 198:       FORMULA_CHECKS = [
// 199:         :package_or_resource_skip,
// 200:         :formula_head_only,
// 201:         :formula_disabled,
// 202:         :formula_deprecated,
// 203:         :formula_versioned,
// 204:       ].freeze
// 205:       private_constant :FORMULA_CHECKS
// 206:
// 207:       # Skip conditions for casks.
// 208:       CASK_CHECKS = [
// 209:         :package_or_resource_skip,
// 210:         :cask_disabled,
// 211:         :cask_deprecated,
// 212:         :cask_extract_plist,
// 213:         :cask_version_latest,
// 214:         :cask_url_unversioned,
// 215:       ].freeze
// 216:       private_constant :CASK_CHECKS
// 217:
// 218:       # Skip conditions for resources.
// 219:       RESOURCE_CHECKS = [
// 220:         :package_or_resource_skip,
// 221:       ].freeze
// 222:       private_constant :RESOURCE_CHECKS
// 223:
// 224:       # If a formula/cask/resource should be skipped, we return a hash from
// 225:       # `Livecheck#status_hash`, which contains a `status` type and sometimes
// 226:       # error `messages`.
// 227:       sig {
// 228:         params(
// 229:           package_or_resource: T.any(Formula, Cask::Cask, Resource),
// 230:           full_name:           T::Boolean,
// 231:           verbose:             T::Boolean,
// 232:           extract_plist:       T::Boolean,
// 233:         ).returns(T::Hash[Symbol, T.untyped])
// 234:       }
// 235:       def self.skip_information(package_or_resource, full_name: false, verbose: false, extract_plist: true)
// 236:         livecheck_defined = package_or_resource.livecheck_defined?
// 237:
// 238:         checks = case package_or_resource
// 239:         when Formula
// 240:           FORMULA_CHECKS
// 241:         when Cask::Cask
// 242:           CASK_CHECKS
// 243:         when Resource
// 244:           RESOURCE_CHECKS
// 245:         end
// 246:
// 247:         checks.each do |method_name|
// 248:           skip_hash = case method_name
// 249:           when :cask_extract_plist
// 250:             send(method_name, package_or_resource, livecheck_defined, full_name:, verbose:, extract_plist:)
// 251:           else
// 252:             send(method_name, package_or_resource, livecheck_defined, full_name:, verbose:)
// 253:           end
// 254:           return skip_hash if skip_hash.present?
// 255:         end
// 256:
// 257:         {}
// 258:       end
// 259:
// 260:       # Skip conditions for formulae/casks/resources referenced in a `livecheck` block
// 261:       # are treated differently than normal. We only respect certain skip
// 262:       # conditions (returning the related hash) and others are treated as
// 263:       # errors.
// 264:       sig {
// 265:         params(
// 266:           livecheck_package_or_resource:     T.any(Formula, Cask::Cask, Resource),
// 267:           original_package_or_resource_name: String,
// 268:           full_name:                         T::Boolean,
// 269:           verbose:                           T::Boolean,
// 270:           extract_plist:                     T::Boolean,
// 271:         ).returns(T.nilable(T::Hash[Symbol, T.untyped]))
// 272:       }
// 273:       def self.referenced_skip_information(
// 274:         livecheck_package_or_resource,
// 275:         original_package_or_resource_name,
// 276:         full_name: false,
// 277:         verbose: false,
// 278:         extract_plist: true
// 279:       )
// 280:         skip_info = SkipConditions.skip_information(
// 281:           livecheck_package_or_resource,
// 282:           full_name:,
// 283:           verbose:,
// 284:           extract_plist:,
// 285:         )
// 286:         return if skip_info.empty?
// 287:
// 288:         referenced_name = Livecheck.package_or_resource_name(livecheck_package_or_resource, full_name:)
// 289:         referenced_type = case livecheck_package_or_resource
// 290:         when Formula
// 291:           :formula
// 292:         when Cask::Cask
// 293:           :cask
// 294:         when Resource
// 295:           :resource
// 296:         end
// 297:
// 298:         if skip_info[:status] != "error" &&
// 299:            !(skip_info[:status] == "skipped" && livecheck_package_or_resource.livecheck.skip?)
// 300:           error_msg_end = if skip_info[:status] == "skipped"
// 301:             "automatically skipped"
// 302:           else
// 303:             "skipped as #{skip_info[:status]}"
// 304:           end
// 305:
// 306:           raise "Referenced #{referenced_type} (#{referenced_name}) is #{error_msg_end}"
// 307:         end
// 308:
// 309:         skip_info[referenced_type] = original_package_or_resource_name
// 310:         skip_info
// 311:       end
// 312:
// 313:       # Prints default livecheck output in relation to skip conditions.
// 314:       sig { params(skip_hash: T::Hash[Symbol, T.untyped]).void }
// 315:       def self.print_skip_information(skip_hash)
// 316:         return unless skip_hash.is_a?(Hash)
// 317:
// 318:         name = if skip_hash[:formula].is_a?(String)
// 319:           skip_hash[:formula]
// 320:         elsif skip_hash[:cask].is_a?(String)
// 321:           skip_hash[:cask]
// 322:         elsif skip_hash[:resource].is_a?(String)
// 323:           "  #{skip_hash[:resource]}"
// 324:         end
// 325:         return unless name
// 326:
// 327:         if skip_hash[:messages].is_a?(Array) && skip_hash[:messages].any?
// 328:           messages = skip_hash[:messages].join("; ")
// 329:           if skip_hash[:status] == "skipped"
// 330:             puts "#{Tty.red}#{name}#{Tty.reset}: skipped - #{messages}"
// 331:           else
// 332:             puts "#{Tty.red}#{name}#{Tty.reset}: #{messages}"
// 333:           end
// 334:         elsif skip_hash[:status].present?
// 335:           puts "#{Tty.red}#{name}#{Tty.reset}: #{skip_hash[:status]}"
// 336:         end
// 337:       end
// 338:     end
// 339:   end
// 340: end
