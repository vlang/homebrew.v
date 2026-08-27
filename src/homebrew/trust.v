module homebrew

import brew_runtime

// Translated from Homebrew/brew `trust.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.trust_file(home: Dir.home(ENV.fetch("USER")))` at line 27.
pub fn ruby_trust_l27_d1_self_trust_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trust_file', ...args)
}

// Ruby method `self.trust!(type, name)` at line 37.
pub fn ruby_trust_l37_d2_self_trust(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trust!', ...args)
}

// Ruby method `self.untrust!(type, name)` at line 57.
pub fn ruby_trust_l57_d3_self_untrust(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.untrust!', ...args)
}

// Ruby method `self.invalidate_tap_references!(name, remote: nil)` at line 84.
pub fn ruby_trust_l84_d4_self_invalidate_tap_references(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.invalidate_tap_references!', ...args)
}

// Ruby method `self.trust_fully_qualified_items!(names, type: nil)` at line 116.
pub fn ruby_trust_l116_d5_self_trust_fully_qualified_items(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trust_fully_qualified_items!', ...args)
}

// Ruby method `self.clear!(type)` at line 148.
pub fn ruby_trust_l148_d6_self_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.clear!', ...args)
}

// Ruby method `self.replace!(entries)` at line 157.
pub fn ruby_trust_l157_d7_self_replace(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.replace!', ...args)
}

// Ruby method `self.trusted?(type, name)` at line 174.
pub fn ruby_trust_l174_d8_self_trusted(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted?', ...args)
}

// Ruby method `self.trusted_tap?(tap)` at line 203.
pub fn ruby_trust_l203_d9_self_trusted_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_tap?', ...args)
}

// Ruby method `self.explicitly_trusted_tap?(tap)` at line 210.
pub fn ruby_trust_l210_d10_self_explicitly_trusted_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.explicitly_trusted_tap?', ...args)
}

// Ruby method `self.require_trusted_formula!(name, path)` at line 215.
pub fn ruby_trust_l215_d11_self_require_trusted_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.require_trusted_formula!', ...args)
}

// Ruby method `self.require_trusted_cask!(token, path)` at line 229.
pub fn ruby_trust_l229_d12_self_require_trusted_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.require_trusted_cask!', ...args)
}

// Ruby method `self.require_trusted_command!(path, command = nil)` at line 243.
pub fn ruby_trust_l243_d13_self_require_trusted_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.require_trusted_command!', ...args)
}

// Ruby method `self.trusted_formula_file?(path)` at line 256.
pub fn ruby_trust_l256_d14_self_trusted_formula_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_formula_file?', ...args)
}

// Ruby method `self.trusted_cask_file?(path)` at line 261.
pub fn ruby_trust_l261_d15_self_trusted_cask_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_cask_file?', ...args)
}

// Ruby method `self.trusted_formula_files(files)` at line 266.
pub fn ruby_trust_l266_d16_self_trusted_formula_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_formula_files', ...args)
}

// Ruby method `self.trusted_cask_files(files)` at line 271.
pub fn ruby_trust_l271_d17_self_trusted_cask_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_cask_files', ...args)
}

// Ruby method `self.trusted_command_files(files)` at line 276.
pub fn ruby_trust_l276_d18_self_trusted_command_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_command_files', ...args)
}

// Ruby method `self.untrusted_taps` at line 281.
pub fn ruby_trust_l281_d19_self_untrusted_taps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.untrusted_taps', ...args)
}

// Ruby method `self.wholly_untrusted_taps` at line 286.
pub fn ruby_trust_l286_d20_self_wholly_untrusted_taps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.wholly_untrusted_taps', ...args)
}

// Ruby method `self.partially_trusted_tap?(tap)` at line 291.
pub fn ruby_trust_l291_d21_self_partially_trusted_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.partially_trusted_tap?', ...args)
}

// Ruby method `self.setting_key(type)` at line 299.
pub fn ruby_trust_l299_d22_self_setting_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.setting_key', ...args)
}

// Ruby method `self.trusted_entries(type)` at line 304.
pub fn ruby_trust_l304_d23_self_trusted_entries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_entries', ...args)
}

// Ruby method `self.normalise_name(name)` at line 309.
pub fn ruby_trust_l309_d24_self_normalise_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.normalise_name', ...args)
}

// Ruby method `self.target(name, type: nil, include_existing: false, tap_remote: nil)` at line 318.
pub fn ruby_trust_l318_d25_self_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.target', ...args)
}

// Ruby method `self.infer_target(name, include_existing:)` at line 325.
pub fn ruby_trust_l325_d26_self_infer_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.infer_target', ...args)
}

// Ruby method `self.trust_name(type, name, include_existing: false, tap_remote: nil)` at line 364.
pub fn ruby_trust_l364_d27_self_trust_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trust_name', ...args)
}

// Ruby method `self.item_trust_name(type, tap, item_name, include_existing: false, tap_remote: nil)` at line 397.
pub fn ruby_trust_l397_d28_self_item_trust_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.item_trust_name', ...args)
}

// Ruby method `self.fully_qualified_package_name(name, noun)` at line 410.
pub fn ruby_trust_l410_d29_self_fully_qualified_package_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fully_qualified_package_name', ...args)
}

// Ruby method `self.trust_store` at line 419.
pub fn ruby_trust_l419_d30_self_trust_store(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trust_store', ...args)
}

// Ruby method `self.write_trust_store(store)` at line 451.
pub fn ruby_trust_l451_d31_self_write_trust_store(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_trust_store', ...args)
}

// Ruby method `self.ensure_secure_trust_store_directory!(path, description)` at line 499.
pub fn ruby_trust_l499_d32_self_ensure_secure_trust_store_directory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ensure_secure_trust_store_directory!', ...args)
}

// Ruby method `self.assert_secure_trust_store_path!(path, stat, description)` at line 508.
pub fn ruby_trust_l508_d33_self_assert_secure_trust_store_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.assert_secure_trust_store_path!', ...args)
}

// Ruby method `self.with_trust_store_lock(&_block)` at line 527.
pub fn ruby_trust_l527_d34_self_with_trust_store_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.with_trust_store_lock', ...args)
}

// Ruby method `self.tap_from_path(path)` at line 538.
pub fn ruby_trust_l538_d35_self_tap_from_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.tap_from_path', ...args)
}

// Ruby method `self.trusted_file?(type, path)` at line 544.
pub fn ruby_trust_l544_d36_self_trusted_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_file?', ...args)
}

// Ruby method `self.explicitly_allowed?(type, full_name, tap)` at line 560.
pub fn ruby_trust_l560_d37_self_explicitly_allowed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.explicitly_allowed?', ...args)
}

// Ruby method `self.trusted_files(type, files)` at line 574.
pub fn ruby_trust_l574_d38_self_trusted_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_files', ...args)
}

// Ruby method `self.trusted_entry_prefix?(type, tap)` at line 590.
pub fn ruby_trust_l590_d39_self_trusted_entry_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_entry_prefix?', ...args)
}

// Ruby method `self.raise_untrusted!(type, name, tap)` at line 600.
pub fn ruby_trust_l600_d40_self_raise_untrusted(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.raise_untrusted!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "env_config"
// 5: require "etc"
// 6: require "json"
// 7: require "tap"
// 8: require "utils"
// 9: require "utils/output"
// 10:
// 11: module Homebrew
// 12:   class InsecureTrustStoreError < RuntimeError; end
// 13:   class UntrustedTapError < RuntimeError; end
// 14:
// 15:   module Trust
// 16:     extend Utils::Output::Mixin
// 17:
// 18:     SETTING_KEYS = T.let({
// 19:       tap:     :trustedtaps,
// 20:       formula: :trustedformulae,
// 21:       cask:    :trustedcasks,
// 22:       command: :trustedcommands,
// 23:     }.freeze, T::Hash[Symbol, Symbol])
// 24:     private_constant :SETTING_KEYS
// 25:
// 26:     sig { params(home: T.any(String, Pathname)).returns(Pathname) }
// 27:     def self.trust_file(home: Dir.home(ENV.fetch("USER")))
// 28:       user_config_home = Pathname.new(ENV.fetch("HOMEBREW_USER_CONFIG_HOME"))
// 29:       if user_config_home == Pathname.new(Dir.home(ENV.fetch("USER")))/".homebrew"
// 30:         Pathname.new(home.to_s)/".homebrew/trust.json"
// 31:       else
// 32:         user_config_home/"trust.json"
// 33:       end
// 34:     end
// 35:
// 36:     sig { params(type: Symbol, name: T.any(String, Tap)).returns(T::Boolean) }
// 37:     def self.trust!(type, name)
// 38:       if name.is_a?(Tap)
// 39:         raise ArgumentError, "a #{type} trust name must be a String, not a Tap" if type != :tap
// 40:
// 41:         name = name.reference
// 42:       end
// 43:       key = setting_key(type)
// 44:       name = normalise_name(name)
// 45:       with_trust_store_lock do
// 46:         store = trust_store
// 47:         entries = store.fetch(key, [])
// 48:         next false if entries.include?(name)
// 49:
// 50:         store[key] = (entries + [name]).sort
// 51:         write_trust_store(store)
// 52:         true
// 53:       end
// 54:     end
// 55:
// 56:     sig { params(type: Symbol, name: String).returns(T::Boolean) }
// 57:     def self.untrust!(type, name)
// 58:       key = setting_key(type)
// 59:       name = normalise_name(name)
// 60:       entries_to_delete = T.let([name], T::Array[String])
// 61:       if type != :tap && ::Utils.full_name?(name) && (tap_name = ::Utils.tap_from_full_name(name))
// 62:         tap = Tap.fetch(tap_name)
// 63:         entries_to_delete << item_trust_name(type, tap, ::Utils.name_from_full_name(name)) if tap.uses_custom_remote?
// 64:       end
// 65:
// 66:       with_trust_store_lock do
// 67:         store = trust_store
// 68:         entries = store.fetch(key, [])
// 69:         removed = T.let(false, T::Boolean)
// 70:         entries_to_delete.uniq.each { |entry| removed = true if entries.delete(entry) }
// 71:         next false unless removed
// 72:
// 73:         if entries.empty?
// 74:           store.delete(key)
// 75:         else
// 76:           store[key] = entries.sort
// 77:         end
// 78:         write_trust_store(store)
// 79:         true
// 80:       end
// 81:     end
// 82:
// 83:     sig { params(name: String, remote: T.nilable(String)).returns(T::Boolean) }
// 84:     def self.invalidate_tap_references!(name, remote: nil)
// 85:       name = normalise_name(name)
// 86:       references = [name]
// 87:       references << normalise_name(remote) if remote.present?
// 88:       if remote.present? && (remote_reference = Tap.remote_to_reference(remote))
// 89:         references << normalise_name(remote_reference)
// 90:       end
// 91:       references.uniq!
// 92:
// 93:       with_trust_store_lock do
// 94:         store = trust_store
// 95:         changed = T.let(false, T::Boolean)
// 96:         store.keys.each do |key|
// 97:           entries = store.fetch(key)
// 98:           filtered_entries = entries.reject do |entry|
// 99:             references.include?(entry) || entry.start_with?("#{name}/")
// 100:           end
// 101:           next if filtered_entries == entries
// 102:
// 103:           changed = true
// 104:           if filtered_entries.empty?
// 105:             store.delete(key)
// 106:           else
// 107:             store[key] = filtered_entries.sort
// 108:           end
// 109:         end
// 110:         write_trust_store(store) if changed
// 111:         changed
// 112:       end
// 113:     end
// 114:
// 115:     sig { params(names: T::Array[String], type: T.nilable(Symbol)).void }
// 116:     def self.trust_fully_qualified_items!(names, type: nil)
// 117:       names.each do |name|
// 118:         next unless ::Utils.full_name?(name)
// 119:
// 120:         tap_name = name.split("/").first(2).join("/")
// 121:         item_name = ::Utils.name_from_full_name(name)
// 122:         tap = Tap.fetch(tap_name)
// 123:         next if tap.official?
// 124:
// 125:         types = if type == :formula
// 126:           tap.formula_files_by_name.key?(item_name) ? [:formula] : []
// 127:         elsif type == :cask
// 128:           tap.cask_files_by_name.key?(item_name) ? [:cask] : []
// 129:         elsif tap.formula_files_by_name.key?(item_name)
// 130:           [:formula]
// 131:         elsif tap.cask_files_by_name.key?(item_name)
// 132:           [:cask]
// 133:         else
// 134:           []
// 135:         end
// 136:         types.each do |item_type|
// 137:           full_name = "#{tap.name}/#{item_name}"
// 138:           if trust!(item_type, item_trust_name(item_type, tap, item_name))
// 139:             $stderr.ohai "Trusted #{item_type} #{full_name}"
// 140:           end
// 141:         end
// 142:       rescue Tap::InvalidNameError
// 143:         nil
// 144:       end
// 145:     end
// 146:
// 147:     sig { params(type: Symbol).void }
// 148:     def self.clear!(type)
// 149:       with_trust_store_lock do
// 150:         store = trust_store
// 151:         store.delete(setting_key(type))
// 152:         write_trust_store(store)
// 153:       end
// 154:     end
// 155:
// 156:     sig { params(entries: T::Array[[Symbol, String]]).void }
// 157:     def self.replace!(entries)
// 158:       store = T.let({}, T::Hash[String, T::Array[String]])
// 159:       entries.each do |type, name|
// 160:         key = setting_key(type)
// 161:         store[key] ||= []
// 162:         store.fetch(key) << normalise_name(name)
// 163:       end
// 164:       store.keys.each do |key|
// 165:         store[key] = store.fetch(key).uniq.sort
// 166:       end
// 167:
// 168:       with_trust_store_lock do
// 169:         write_trust_store(store)
// 170:       end
// 171:     end
// 172:
// 173:     sig { params(type: Symbol, name: String).returns(T::Boolean) }
// 174:     def self.trusted?(type, name)
// 175:       name = normalise_name(name)
// 176:       entries = trusted_entries(type)
// 177:       return true if entries.include?(name)
// 178:
// 179:       if type == :tap
// 180:         return false if Tap.remote_reference?(name)
// 181:
// 182:         return explicitly_trusted_tap?(Tap.fetch(name))
// 183:       end
// 184:       return false unless (tap_name = ::Utils.tap_from_full_name(name))
// 185:
// 186:       tap = Tap.fetch(tap_name)
// 187:       return true if trusted_tap?(tap)
// 188:
// 189:       item_name = normalise_name(::Utils.name_from_full_name(name))
// 190:       return true if entries.include?(item_trust_name(type, tap, item_name))
// 191:       return false unless tap.uses_custom_remote?
// 192:
// 193:       entries.any? do |entry|
// 194:         next false unless entry.end_with?("/#{item_name}")
// 195:
// 196:         Tap.same_remote?(entry.delete_suffix("/#{item_name}"), tap.remote)
// 197:       end
// 198:     rescue Tap::InvalidNameError
// 199:       false
// 200:     end
// 201:
// 202:     sig { params(tap: Tap).returns(T::Boolean) }
// 203:     def self.trusted_tap?(tap)
// 204:       tap.implicitly_trusted? || explicitly_trusted_tap?(tap)
// 205:     end
// 206:
// 207:     # Whether the tap appears in the trust list, ignoring any implicit official-tap trust. The
// 208:     # entries may be `user/repository` names or remote URLs, so match via {Tap#matches_reference?}.
// 209:     sig { params(tap: Tap).returns(T::Boolean) }
// 210:     def self.explicitly_trusted_tap?(tap)
// 211:       trusted_entries(:tap).any? { |reference| tap.matches_reference?(reference) }
// 212:     end
// 213:
// 214:     sig { params(name: String, path: Pathname).void }
// 215:     def self.require_trusted_formula!(name, path)
// 216:       return if Homebrew::EnvConfig.no_require_tap_trust?
// 217:       return unless (tap = tap_from_path(path))
// 218:       return if trusted_tap?(tap)
// 219:
// 220:       full_name = "#{tap.name}/#{::Utils.name_from_full_name(name)}"
// 221:       return if trusted?(:formula, full_name)
// 222:       return if explicitly_allowed?(:formula, full_name, tap)
// 223:       return unless Homebrew::EnvConfig.require_tap_trust?
// 224:
// 225:       raise_untrusted!(:formula, full_name, tap)
// 226:     end
// 227:
// 228:     sig { params(token: String, path: Pathname).void }
// 229:     def self.require_trusted_cask!(token, path)
// 230:       return if Homebrew::EnvConfig.no_require_tap_trust?
// 231:       return unless (tap = tap_from_path(path))
// 232:       return if trusted_tap?(tap)
// 233:
// 234:       full_name = "#{tap.name}/#{::Utils.name_from_full_name(token)}"
// 235:       return if trusted?(:cask, full_name)
// 236:       return if explicitly_allowed?(:cask, full_name, tap)
// 237:       return unless Homebrew::EnvConfig.require_tap_trust?
// 238:
// 239:       raise_untrusted!(:cask, full_name, tap)
// 240:     end
// 241:
// 242:     sig { params(path: Pathname, command: T.nilable(String)).void }
// 243:     def self.require_trusted_command!(path, command = nil)
// 244:       return if Homebrew::EnvConfig.no_require_tap_trust?
// 245:       return unless (tap = tap_from_path(path))
// 246:       return if trusted_tap?(tap)
// 247:
// 248:       full_name = "#{tap.name}/#{command || path.basename(path.extname).to_s.delete_prefix("brew-")}"
// 249:       return if trusted?(:command, full_name)
// 250:       return unless Homebrew::EnvConfig.require_tap_trust?
// 251:
// 252:       raise_untrusted!(:command, full_name, tap)
// 253:     end
// 254:
// 255:     sig { params(path: Pathname).returns(T::Boolean) }
// 256:     def self.trusted_formula_file?(path)
// 257:       trusted_file?(:formula, path)
// 258:     end
// 259:
// 260:     sig { params(path: Pathname).returns(T::Boolean) }
// 261:     def self.trusted_cask_file?(path)
// 262:       trusted_file?(:cask, path)
// 263:     end
// 264:
// 265:     sig { params(files: T::Array[Pathname]).returns(T::Array[Pathname]) }
// 266:     def self.trusted_formula_files(files)
// 267:       trusted_files(:formula, files)
// 268:     end
// 269:
// 270:     sig { params(files: T::Array[Pathname]).returns(T::Array[Pathname]) }
// 271:     def self.trusted_cask_files(files)
// 272:       trusted_files(:cask, files)
// 273:     end
// 274:
// 275:     sig { params(files: T::Array[Pathname]).returns(T::Array[Pathname]) }
// 276:     def self.trusted_command_files(files)
// 277:       trusted_files(:command, files)
// 278:     end
// 279:
// 280:     sig { returns(T::Array[Tap]) }
// 281:     def self.untrusted_taps
// 282:       Tap.installed.reject(&:official?).reject { |tap| trusted_tap?(tap) }.sort_by(&:name)
// 283:     end
// 284:
// 285:     sig { returns(T::Array[Tap]) }
// 286:     def self.wholly_untrusted_taps
// 287:       untrusted_taps.reject { |tap| partially_trusted_tap?(tap) }
// 288:     end
// 289:
// 290:     sig { params(tap: Tap).returns(T::Boolean) }
// 291:     def self.partially_trusted_tap?(tap)
// 292:       trusted_entry_prefix?(:formula, tap) ||
// 293:         trusted_entry_prefix?(:cask, tap) ||
// 294:         trusted_entry_prefix?(:command, tap)
// 295:     end
// 296:     private_class_method :partially_trusted_tap?
// 297:
// 298:     sig { params(type: Symbol).returns(String) }
// 299:     def self.setting_key(type)
// 300:       SETTING_KEYS.fetch(type).to_s
// 301:     end
// 302:
// 303:     sig { params(type: Symbol).returns(T::Array[String]) }
// 304:     def self.trusted_entries(type)
// 305:       trust_store.fetch(setting_key(type), [])
// 306:     end
// 307:
// 308:     sig { params(name: String).returns(String) }
// 309:     def self.normalise_name(name)
// 310:       name.downcase
// 311:     end
// 312:
// 313:     sig {
// 314:       params(
// 315:         name: String, type: T.nilable(Symbol), include_existing: T::Boolean, tap_remote: T.nilable(String),
// 316:       ).returns([Symbol, String])
// 317:     }
// 318:     def self.target(name, type: nil, include_existing: false, tap_remote: nil)
// 319:       return [type, trust_name(type, name, include_existing:, tap_remote:)] if type
// 320:
// 321:       infer_target(name, include_existing:)
// 322:     end
// 323:
// 324:     sig { params(name: String, include_existing: T::Boolean).returns([Symbol, String]) }
// 325:     def self.infer_target(name, include_existing:)
// 326:       return [:tap, trust_name(:tap, name)] if name.count("/") == 1 || Tap.remote_reference?(name)
// 327:
// 328:       tap_with_name = Tap.with_formula_name(name)
// 329:       unless tap_with_name
// 330:         raise UsageError,
// 331:               "Trust targets must be fully-qualified tap, formula, cask or command names."
// 332:       end
// 333:
// 334:       tap, token = tap_with_name
// 335:       candidate_types = T.let([], T::Array[Symbol])
// 336:       candidate_types << :formula if tap.formula_files_by_name.key?(token)
// 337:       candidate_types << :cask if tap.cask_files_by_name.key?(token)
// 338:       if tap.command_files.any? { |path| path.basename(path.extname).to_s.delete_prefix("brew-") == token }
// 339:         candidate_types << :command
// 340:       end
// 341:       if include_existing
// 342:         full_name = "#{tap.name}/#{token}"
// 343:         candidate_types << :formula if trusted?(:formula, full_name)
// 344:         candidate_types << :cask if trusted?(:cask, full_name)
// 345:         candidate_types << :command if trusted?(:command, full_name)
// 346:       end
// 347:       candidates = T.let([], T::Array[[Symbol, String]])
// 348:       candidate_types.uniq.each do |candidate_type|
// 349:         candidates << [candidate_type, item_trust_name(candidate_type, tap, token, include_existing:)]
// 350:       end
// 351:       return candidates.fetch(0) if candidates.one?
// 352:
// 353:       raise UsageError, "No formula, cask or command found for #{name}." if candidates.empty?
// 354:
// 355:       raise UsageError, "Ambiguous trust target #{name}. Use `--formula`, `--cask` or `--command`."
// 356:     end
// 357:     private_class_method :infer_target
// 358:
// 359:     sig {
// 360:       params(
// 361:         type: Symbol, name: String, include_existing: T::Boolean, tap_remote: T.nilable(String),
// 362:       ).returns(String)
// 363:     }
// 364:     def self.trust_name(type, name, include_existing: false, tap_remote: nil)
// 365:       case type
// 366:       when :tap
// 367:         if Tap.remote_reference?(name)
// 368:           reference = Tap.remote_to_reference(name)
// 369:           raise UsageError, "Invalid tap remote URL: #{name}" if reference.nil?
// 370:
// 371:           reference
// 372:         else
// 373:           Tap.fetch(name).reference(remote: tap_remote)
// 374:         end
// 375:       when :formula
// 376:         tap, formula_name = fully_qualified_package_name(name, "Formulae")
// 377:         item_trust_name(type, tap, formula_name, include_existing:, tap_remote:)
// 378:       when :cask
// 379:         tap, token = fully_qualified_package_name(name, "Casks")
// 380:         item_trust_name(type, tap, token, include_existing:, tap_remote:)
// 381:       when :command
// 382:         tap, command_name = fully_qualified_package_name(name, "Commands")
// 383:         item_trust_name(type, tap, command_name, include_existing:, tap_remote:)
// 384:       else
// 385:         raise UsageError, "Unsupported trust target type: #{type}"
// 386:       end
// 387:     rescue Tap::InvalidNameError => e
// 388:       raise UsageError, e.message
// 389:     end
// 390:     private_class_method :trust_name
// 391:
// 392:     sig {
// 393:       params(
// 394:         type: Symbol, tap: Tap, item_name: String, include_existing: T::Boolean, tap_remote: T.nilable(String),
// 395:       ).returns(String)
// 396:     }
// 397:     def self.item_trust_name(type, tap, item_name, include_existing: false, tap_remote: nil)
// 398:       item_name = normalise_name(item_name)
// 399:       full_name = "#{tap.name}/#{item_name}"
// 400:       return full_name if include_existing && trusted_entries(type).include?(normalise_name(full_name))
// 401:
// 402:       reference = tap.reference(remote: tap_remote)
// 403:       return full_name if reference == tap.name
// 404:
// 405:       "#{normalise_name(reference)}/#{item_name}"
// 406:     end
// 407:     private_class_method :item_trust_name
// 408:
// 409:     sig { params(name: String, noun: String).returns([Tap, String]) }
// 410:     def self.fully_qualified_package_name(name, noun)
// 411:       tap_with_name = Tap.with_formula_name(name)
// 412:       raise UsageError, "#{noun} must be fully-qualified as <user>/<tap>/<name>." unless tap_with_name
// 413:
// 414:       tap_with_name
// 415:     end
// 416:     private_class_method :fully_qualified_package_name
// 417:
// 418:     sig { returns(T::Hash[String, T::Array[String]]) }
// 419:     def self.trust_store
// 420:       trust_path = if Homebrew.running_as_root? &&
// 421:                       (sudo_user = ENV.fetch("HOMEBREW_SUDO_USER", nil).presence) &&
// 422:                       sudo_user != "root"
// 423:         passwd = begin
// 424:           Etc.getpwnam(sudo_user)
// 425:         rescue ArgumentError
// 426:           nil
// 427:         end
// 428:
// 429:         if passwd
// 430:           trust_file(home: passwd.dir)
// 431:         else
// 432:           opoo "Could not determine home directory for `$HOMEBREW_SUDO_USER` (#{sudo_user}); " \
// 433:                "falling back to #{trust_file}."
// 434:           trust_file
// 435:         end
// 436:       else
// 437:         trust_file
// 438:       end
// 439:       return {} unless trust_path.exist?
// 440:
// 441:       parsed_store = JSON.parse(trust_path.read)
// 442:       return {} unless parsed_store.is_a?(Hash)
// 443:
// 444:       parsed_store.transform_values { |entries| Array(entries).map { |entry| normalise_name(entry.to_s) } }
// 445:     rescue Errno::ENOENT, JSON::ParserError
// 446:       {}
// 447:     end
// 448:     private_class_method :trust_store
// 449:
// 450:     sig { params(store: T::Hash[String, T::Array[String]]).void }
// 451:     def self.write_trust_store(store)
// 452:       write_path = trust_file
// 453:       if write_path.symlink?
// 454:         link_parent = write_path.dirname.realpath
// 455:         assert_secure_trust_store_path!(link_parent, link_parent.stat, "symlink directory")
// 456:         if write_path.lstat.uid != Process.euid
// 457:           raise InsecureTrustStoreError,
// 458:                 "Refusing to write insecure trust store: symlink #{write_path} is not owned by the current user."
// 459:         end
// 460:         target_path = write_path.readlink
// 461:         target_path = write_path.dirname/target_path unless target_path.absolute?
// 462:         target_parent = target_path.dirname.realpath
// 463:         assert_secure_trust_store_path!(target_parent, target_parent.stat, "target directory")
// 464:         write_path = target_parent/target_path.basename
// 465:         if write_path.symlink?
// 466:           raise InsecureTrustStoreError,
// 467:                 "Refusing to write insecure trust store: target is a symlink."
// 468:         end
// 469:         if write_path.exist?
// 470:           assert_secure_trust_store_path!(write_path, write_path.stat, "target")
// 471:           unless write_path.file?
// 472:             raise InsecureTrustStoreError,
// 473:                   "Refusing to write insecure trust store: target is not a regular file."
// 474:           end
// 475:         end
// 476:       else
// 477:         ensure_secure_trust_store_directory!(write_path.dirname, "trust store directory")
// 478:         if write_path.exist?
// 479:           assert_secure_trust_store_path!(write_path, write_path.stat, "trust store")
// 480:           unless write_path.file?
// 481:             raise InsecureTrustStoreError,
// 482:                   "Refusing to write insecure trust store: trust store is not a regular file."
// 483:           end
// 484:         end
// 485:       end
// 486:       if store.empty?
// 487:         write_path.unlink if write_path.exist?
// 488:         return
// 489:       end
// 490:
// 491:       write_path.atomic_write("#{JSON.pretty_generate(store)}\n")
// 492:       write_path.chmod(0600)
// 493:     rescue Errno::ENOENT
// 494:       raise InsecureTrustStoreError, "Refusing to write insecure trust store: target directory does not exist."
// 495:     end
// 496:     private_class_method :write_trust_store
// 497:
// 498:     sig { params(path: Pathname, description: String).void }
// 499:     def self.ensure_secure_trust_store_directory!(path, description)
// 500:       existed = path.exist?
// 501:       path.mkpath
// 502:       path.chmod(0700) unless existed
// 503:       assert_secure_trust_store_path!(path, path.stat, description)
// 504:     end
// 505:     private_class_method :ensure_secure_trust_store_directory!
// 506:
// 507:     sig { params(path: Pathname, stat: File::Stat, description: String).void }
// 508:     def self.assert_secure_trust_store_path!(path, stat, description)
// 509:       if stat.uid != Process.euid
// 510:         raise InsecureTrustStoreError,
// 511:               "Refusing to write insecure trust store: #{description} #{path} is not owned by the current user."
// 512:       end
// 513:
// 514:       return if stat.mode.nobits?(022)
// 515:
// 516:       raise InsecureTrustStoreError,
// 517:             "Refusing to write insecure trust store: #{description} #{path} is group or world writable."
// 518:     end
// 519:     private_class_method :assert_secure_trust_store_path!
// 520:
// 521:     # Serialises trust store mutations so concurrent processes or threads
// 522:     # (e.g. parallel `brew bundle` installs) cannot lose entries in the
// 523:     # read-modify-write cycle.
// 524:     sig {
// 525:       type_parameters(:U).params(_block: T.proc.returns(T.type_parameter(:U))).returns(T.type_parameter(:U))
// 526:     }
// 527:     def self.with_trust_store_lock(&_block)
// 528:       lock_path = Pathname.new("#{trust_file}.lock")
// 529:       ensure_secure_trust_store_directory!(lock_path.dirname, "trust store directory")
// 530:       File.open(lock_path, File::RDWR | File::CREAT, 0600) do |lock_file|
// 531:         lock_file.flock(File::LOCK_EX)
// 532:         yield
// 533:       end
// 534:     end
// 535:     private_class_method :with_trust_store_lock
// 536:
// 537:     sig { params(path: Pathname).returns(T.nilable(Tap)) }
// 538:     def self.tap_from_path(path)
// 539:       Tap.from_path(path)
// 540:     end
// 541:     private_class_method :tap_from_path
// 542:
// 543:     sig { params(type: Symbol, path: Pathname).returns(T::Boolean) }
// 544:     def self.trusted_file?(type, path)
// 545:       return true if Homebrew::EnvConfig.no_require_tap_trust?
// 546:       return true unless (tap = tap_from_path(path))
// 547:       return true if trusted_tap?(tap)
// 548:
// 549:       name = path.basename(path.extname).to_s
// 550:       name = name.delete_prefix("brew-") if type == :command
// 551:       full_name = "#{tap.name}/#{name}"
// 552:       return true if trusted?(type, full_name)
// 553:       return true if explicitly_allowed?(type, full_name, tap)
// 554:
// 555:       !Homebrew::EnvConfig.require_tap_trust?
// 556:     end
// 557:     private_class_method :trusted_file?
// 558:
// 559:     sig { params(type: Symbol, full_name: String, tap: Tap).returns(T::Boolean) }
// 560:     def self.explicitly_allowed?(type, full_name, tap)
// 561:       return false if type == :command
// 562:
// 563:       downcased_args = ARGV.map(&:downcase)
// 564:       downcased_full_name = full_name.downcase
// 565:       tap_name = tap.name.downcase
// 566:       downcased_args.include?(downcased_full_name) ||
// 567:         downcased_args.include?(tap_name) ||
// 568:         downcased_args.include?("--tap=#{tap_name}") ||
// 569:         downcased_args.each_cons(2).any? { |option, value| option == "--tap" && value == tap_name }
// 570:     end
// 571:     private_class_method :explicitly_allowed?
// 572:
// 573:     sig { params(type: Symbol, files: T::Array[Pathname]).returns(T::Array[Pathname]) }
// 574:     def self.trusted_files(type, files)
// 575:       trusted_files = files.select { |file| trusted_file?(type, file) }
// 576:       return trusted_files unless Homebrew::EnvConfig.require_tap_trust?
// 577:
// 578:       skipped_taps = (files - trusted_files).filter_map { |file| tap_from_path(file) }.uniq.sort_by(&:name)
// 579:       skipped_taps.each do |tap|
// 580:         next if partially_trusted_tap?(tap)
// 581:
// 582:         opoo "Skipping #{tap.name} because it is not trusted. Run `brew trust #{tap.name}` to trust it."
// 583:       end
// 584:
// 585:       trusted_files
// 586:     end
// 587:     private_class_method :trusted_files
// 588:
// 589:     sig { params(type: Symbol, tap: Tap).returns(T::Boolean) }
// 590:     def self.trusted_entry_prefix?(type, tap)
// 591:       prefixes = T.let([normalise_name(tap.reference)], T::Array[String])
// 592:       prefixes << tap.name if tap.uses_custom_remote?
// 593:       trusted_entries(type).any? do |entry|
// 594:         prefixes.any? { |prefix| entry.start_with?("#{prefix}/") }
// 595:       end
// 596:     end
// 597:     private_class_method :trusted_entry_prefix?
// 598:
// 599:     sig { params(type: Symbol, name: String, tap: Tap).void }
// 600:     def self.raise_untrusted!(type, name, tap)
// 601:       raise UntrustedTapError, "Refusing to load #{type} #{name} from untrusted tap #{tap.name}.\n" \
// 602:                                "Run `brew trust --#{type} #{name}` or `brew trust #{tap.name}` to trust it."
// 603:     end
// 604:     private_class_method :raise_untrusted!
// 605:   end
// 606: end
