module api

import brew_runtime

// Translated from Homebrew/brew `api/packages_index.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.path_for(target)` at line 31.
pub fn ruby_packages_index_l31_d1_self_path_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.path_for', ...args)
}

// Ruby method `self.source_fingerprint(stat)` at line 36.
pub fn ruby_packages_index_l36_d2_self_source_fingerprint(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.source_fingerprint', ...args)
}

// Ruby method `self.load(target, payload:, source_stat:)` at line 44.
pub fn ruby_packages_index_l44_d3_self_load(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.load', ...args)
}

// Ruby method `self.top_level_spans_tile_payload?(payload, top_level)` at line 70.
pub fn ruby_packages_index_l70_d4_self_top_level_spans_tile_payload(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.top_level_spans_tile_payload?', ...args)
}

// Ruby method `self.write!(target, payload:, parsed:, source_stat:)` at line 100.
pub fn ruby_packages_index_l100_d5_self_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write!', ...args)
}

// Ruby method `self.build(payload:, parsed:)` at line 132.
pub fn ruby_packages_index_l132_d6_self_build(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.build', ...args)
}

// Ruby method `self.locate(payload, key, value, position)` at line 181.
pub fn ruby_packages_index_l181_d7_self_locate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.locate', ...args)
}

// Ruby attr_reader `attr_reader :payload` at line 194.
pub fn ruby_packages_index_l194_d8_payload(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('payload', ...args)
}

// Ruby attr_reader `attr_reader :source_stat` at line 197.
pub fn ruby_packages_index_l197_d9_source_stat(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_stat', ...args)
}

// Ruby method `initialize(payload:, source_stat:, top_level:, sections:)` at line 203.
pub fn ruby_packages_index_l203_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `formula_hash(name)` at line 211.
pub fn ruby_packages_index_l211_d11_formula_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_hash', ...args)
}

// Ruby method `cask_hash(name)` at line 216.
pub fn ruby_packages_index_l216_d12_cask_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_hash', ...args)
}

// Ruby method `formula_names` at line 221.
pub fn ruby_packages_index_l221_d13_formula_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_names', ...args)
}

// Ruby method `cask_names` at line 226.
pub fn ruby_packages_index_l226_d14_cask_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_names', ...args)
}

// Ruby method `formula_name?(name)` at line 231.
pub fn ruby_packages_index_l231_d15_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_name?', ...args)
}

// Ruby method `cask_name?(name)` at line 236.
pub fn ruby_packages_index_l236_d16_cask_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_name?', ...args)
}

// Ruby method `top_level_value(key)` at line 241.
pub fn ruby_packages_index_l241_d17_top_level_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('top_level_value', ...args)
}

// Ruby method `entry_value(section, name)` at line 253.
pub fn ruby_packages_index_l253_d18_entry_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('entry_value', ...args)
}

// Ruby method `slice_value(name, location, within: nil)` at line 270.
pub fn ruby_packages_index_l270_d19_slice_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('slice_value', ...args)
}

// Ruby method `outside_span?(start_offset, end_offset, within)` at line 289.
pub fn ruby_packages_index_l289_d20_outside_span(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outside_span?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module API
// 6:     # Byte-offset index into a signature-verified internal packages JWS
// 7:     # payload, so commands can parse only the entries they need instead of
// 8:     # the whole multi-megabyte document.
// 9:     #
// 10:     # The index is derived, unverified cache data guarded in layers: the
// 11:     # payload bytes it points into are signature-verified on every run,
// 12:     # loading requires the recorded top-level spans to tile that payload
// 13:     # exactly (so the formulae and casks section spans are provably the
// 14:     # real top-level values) and every lookup revalidates that its offsets
// 15:     # sit at the expected `"<name>":` key inside the requested section's
// 16:     # span and that the slice parses. A forged or stale index therefore
// 17:     # cannot inject unverified content or remap a name to another entry,
// 18:     # even a matching key in the other section; it fails validation and
// 19:     # callers fall back to a full parse when {Invalid} is raised.
// 20:     class PackagesIndex
// 21:       FORMAT_VERSION = 1
// 22:       SECTION_KEYS = %w[formulae casks].freeze
// 23:       # Bounds index building when payload bytes stop round-tripping through
// 24:       # `JSON.generate`; giving up just means no index is written.
// 25:       MAX_FALSE_MATCH_RETRIES = 100
// 26:
// 27:       # Raised when index contents do not match the verified payload.
// 28:       class Invalid < RuntimeError; end
// 29:
// 30:       sig { params(target: Pathname).returns(Pathname) }
// 31:       def self.path_for(target)
// 32:         Pathname("#{target}.payload.index")
// 33:       end
// 34:
// 35:       sig { params(stat: File::Stat).returns(T::Hash[String, Integer]) }
// 36:       def self.source_fingerprint(stat)
// 37:         {
// 38:           "source_size"     => stat.size,
// 39:           "source_mtime_ns" => (stat.mtime.to_r * 1_000_000_000).to_i,
// 40:         }
// 41:       end
// 42:
// 43:       sig { params(target: Pathname, payload: String, source_stat: File::Stat).returns(T.nilable(PackagesIndex)) }
// 44:       def self.load(target, payload:, source_stat:)
// 45:         data = JSON.parse(path_for(target).read(encoding: Encoding::UTF_8))
// 46:         return unless data.is_a?(Hash)
// 47:         return if data["version"] != FORMAT_VERSION
// 48:         return if source_fingerprint(source_stat).any? { |key, value| data[key] != value }
// 49:         return if data["payload_bytesize"] != payload.bytesize
// 50:
// 51:         top_level = data["top_level"]
// 52:         sections = data.slice(*SECTION_KEYS)
// 53:         return unless top_level.is_a?(Hash)
// 54:         return unless sections.values.all?(Hash)
// 55:         return unless top_level_spans_tile_payload?(payload, top_level)
// 56:
// 57:         new(payload:, source_stat:, top_level:, sections:)
// 58:       rescue SystemCallError, JSON::ParserError
// 59:         nil
// 60:       end
// 61:
// 62:       # The recorded top-level spans must reconstruct the payload's
// 63:       # top-level object exactly: starting at the opening brace, each span
// 64:       # is immediately preceded by its own comma-separated JSON key and the
// 65:       # last ends at the closing brace. This proves every span, including
// 66:       # the section spans entry lookups are bounded by, is the real
// 67:       # top-level value for its key rather than an arbitrary or inflated
// 68:       # byte range.
// 69:       sig { params(payload: String, top_level: T::Hash[String, T.untyped]).returns(T::Boolean) }
// 70:       private_class_method def self.top_level_spans_tile_payload?(payload, top_level)
// 71:         return false if payload.byteslice(0, 1) != "{"
// 72:
// 73:         spans = top_level.map do |key, location|
// 74:           offset, bytesize = location
// 75:           return false if !offset.is_a?(Integer) || !bytesize.is_a?(Integer) || bytesize.negative?
// 76:
// 77:           [key.to_s, offset, bytesize]
// 78:         end
// 79:         spans.sort_by! { |_, offset, _| offset }
// 80:
// 81:         position = 1
// 82:         spans.each_with_index do |(key, offset, bytesize), index|
// 83:           key_bytes = "#{key.to_json}:"
// 84:           key_bytes = ",#{key_bytes}" if index.positive?
// 85:           return false if payload.byteslice(position, key_bytes.bytesize) != key_bytes
// 86:           return false if position + key_bytes.bytesize != offset
// 87:
// 88:           position = offset + bytesize
// 89:         end
// 90:
// 91:         position + 1 == payload.bytesize && payload.byteslice(position, 1) == "}"
// 92:       end
// 93:
// 94:       # Builds and persists an index for a freshly verified and parsed
// 95:       # payload. Failing to build or write one only costs the fast path.
// 96:       sig {
// 97:         params(target: Pathname, payload: String, parsed: T::Hash[String, T.untyped],
// 98:                source_stat: File::Stat).void
// 99:       }
// 100:       def self.write!(target, payload:, parsed:, source_stat:)
// 101:         # Never write to a user-owned cache as root, matching `skip_download?`.
// 102:         return if Homebrew.running_as_root_but_not_owned_by_root?
// 103:         return if (data = build(payload:, parsed:)).nil?
// 104:
// 105:         data = {
// 106:           "version"          => FORMAT_VERSION,
// 107:           **source_fingerprint(source_stat),
// 108:           "payload_bytesize" => payload.bytesize,
// 109:           **data,
// 110:         }
// 111:         index_path = path_for(target)
// 112:         temporary_path = Pathname("#{index_path}.tmp")
// 113:         begin
// 114:           temporary_path.write(JSON.generate(data))
// 115:           File.rename(temporary_path, index_path)
// 116:         ensure
// 117:           temporary_path.unlink if temporary_path.exist?
// 118:         end
// 119:       rescue SystemCallError
// 120:         nil
// 121:       end
// 122:
// 123:       # Locates every top-level value and every formula and cask entry in the
// 124:       # payload bytes. Offsets are found by searching for each JSON key in
// 125:       # document order and validating that the following bytes byte-match the
// 126:       # entry's `JSON.generate` round trip, so every recorded offset provably
// 127:       # reproduces the canonical parse.
// 128:       sig {
// 129:         params(payload: String, parsed: T::Hash[String, T.untyped])
// 130:           .returns(T.nilable(T::Hash[String, T::Hash[String, [Integer, Integer]]]))
// 131:       }
// 132:       def self.build(payload:, parsed:)
// 133:         data = T.let({ "top_level" => {} }, T::Hash[String, T::Hash[String, [Integer, Integer]]])
// 134:         SECTION_KEYS.each { |section| data[section] = {} }
// 135:         retries = 0
// 136:         position = 0
// 137:
// 138:         parsed.each do |key, value|
// 139:           location = locate(payload, key, value, position)
// 140:           return nil if location.nil?
// 141:
// 142:           value_start, value_bytesize = location
// 143:           T.must(data["top_level"])[key] = [value_start, value_bytesize]
// 144:
// 145:           if SECTION_KEYS.include?(key) && value.is_a?(Hash)
// 146:             entry_position = value_start
// 147:             value.each do |name, entry|
// 148:               entry_location = T.let(nil, T.nilable([Integer, Integer]))
// 149:               loop do
// 150:                 entry_location = locate(payload, name, entry, entry_position)
// 151:                 break unless entry_location.nil?
// 152:
// 153:                 retries += 1
// 154:                 return nil if retries > MAX_FALSE_MATCH_RETRIES
// 155:
// 156:                 next_position = payload.byteindex("#{name.to_json}:", entry_position)
// 157:                 return nil if next_position.nil?
// 158:
// 159:                 entry_position = next_position + 1
// 160:               end
// 161:
// 162:               entry_start, entry_bytesize = entry_location
// 163:               T.must(data[key])[name] = [entry_start, entry_bytesize]
// 164:               entry_position = entry_start + entry_bytesize
// 165:             end
// 166:           end
// 167:
// 168:           position = value_start + value_bytesize
// 169:         end
// 170:
// 171:         data
// 172:       end
// 173:
// 174:       # Finds `"<key>":<value>` at or after `position`, returning the value's
// 175:       # byte offset and length only when the payload bytes match the value's
// 176:       # canonical serialisation exactly.
// 177:       sig {
// 178:         params(payload: String, key: String, value: T.untyped, position: Integer)
// 179:           .returns(T.nilable([Integer, Integer]))
// 180:       }
// 181:       private_class_method def self.locate(payload, key, value, position)
// 182:         key_bytes = "#{key.to_json}:"
// 183:         key_position = payload.byteindex(key_bytes, position)
// 184:         return if key_position.nil?
// 185:
// 186:         value_bytes = JSON.generate(value)
// 187:         value_start = key_position + key_bytes.bytesize
// 188:         return if payload.byteslice(value_start, value_bytes.bytesize) != value_bytes
// 189:
// 190:         [value_start, value_bytes.bytesize]
// 191:       end
// 192:
// 193:       sig { returns(String) }
// 194:       attr_reader :payload
// 195:
// 196:       sig { returns(File::Stat) }
// 197:       attr_reader :source_stat
// 198:
// 199:       sig {
// 200:         params(payload: String, source_stat: File::Stat, top_level: T::Hash[String, T.untyped],
// 201:                sections: T::Hash[String, T::Hash[String, T.untyped]]).void
// 202:       }
// 203:       def initialize(payload:, source_stat:, top_level:, sections:)
// 204:         @payload = payload
// 205:         @source_stat = source_stat
// 206:         @top_level = top_level
// 207:         @sections = sections
// 208:       end
// 209:
// 210:       sig { params(name: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 211:       def formula_hash(name)
// 212:         entry_value("formulae", name)
// 213:       end
// 214:
// 215:       sig { params(name: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 216:       def cask_hash(name)
// 217:         entry_value("casks", name)
// 218:       end
// 219:
// 220:       sig { returns(T::Array[String]) }
// 221:       def formula_names
// 222:         @sections.fetch("formulae", {}).keys
// 223:       end
// 224:
// 225:       sig { returns(T::Array[String]) }
// 226:       def cask_names
// 227:         @sections.fetch("casks", {}).keys
// 228:       end
// 229:
// 230:       sig { params(name: String).returns(T::Boolean) }
// 231:       def formula_name?(name)
// 232:         @sections.fetch("formulae", {}).key?(name)
// 233:       end
// 234:
// 235:       sig { params(name: String).returns(T::Boolean) }
// 236:       def cask_name?(name)
// 237:         @sections.fetch("casks", {}).key?(name)
// 238:       end
// 239:
// 240:       sig { params(key: String).returns(T.untyped) }
// 241:       def top_level_value(key)
// 242:         return if SECTION_KEYS.include?(key)
// 243:
// 244:         location = @top_level[key]
// 245:         return if location.nil?
// 246:
// 247:         slice_value(key, location)
// 248:       end
// 249:
// 250:       private
// 251:
// 252:       sig { params(section: String, name: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 253:       def entry_value(section, name)
// 254:         location = @sections.fetch(section, {})[name]
// 255:         return if location.nil?
// 256:
// 257:         section_location = @top_level[section]
// 258:         raise Invalid, "no #{section} span for the #{name} index entry" unless section_location.is_a?(Array)
// 259:
// 260:         value = slice_value(name, location, within: section_location)
// 261:         raise Invalid, "#{section} index entry for #{name} is not a hash" unless value.is_a?(Hash)
// 262:
// 263:         value
// 264:       end
// 265:
// 266:       # Revalidates a recorded location against the verified payload bytes:
// 267:       # it must be preceded by the expected JSON key, sit inside the given
// 268:       # load-validated span and parse cleanly.
// 269:       sig { params(name: String, location: T.untyped, within: T.untyped).returns(T.untyped) }
// 270:       def slice_value(name, location, within: nil)
// 271:         offset, bytesize = location
// 272:         key_bytes = "#{name.to_json}:"
// 273:         key_offset = offset - key_bytes.bytesize if offset.is_a?(Integer)
// 274:         if !offset.is_a?(Integer) || !bytesize.is_a?(Integer) ||
// 275:            key_offset.nil? || key_offset.negative? || (offset + bytesize) > payload.bytesize ||
// 276:            payload.byteslice(key_offset, key_bytes.bytesize) != key_bytes ||
// 277:            outside_span?(key_offset, offset + bytesize, within)
// 278:           raise Invalid, "index location for #{name} does not match the payload"
// 279:         end
// 280:
// 281:         begin
// 282:           JSON.parse(T.must(payload.byteslice(offset, bytesize)), freeze: true)
// 283:         rescue JSON::ParserError
// 284:           raise Invalid, "index slice for #{name} does not parse"
// 285:         end
// 286:       end
// 287:
// 288:       sig { params(start_offset: Integer, end_offset: Integer, within: T.untyped).returns(T::Boolean) }
// 289:       def outside_span?(start_offset, end_offset, within)
// 290:         return false if within.nil?
// 291:
// 292:         within_offset, within_bytesize = within
// 293:         return true if !within_offset.is_a?(Integer) || !within_bytesize.is_a?(Integer)
// 294:
// 295:         start_offset < within_offset || end_offset > within_offset + within_bytesize
// 296:       end
// 297:     end
// 298:   end
// 299: end
