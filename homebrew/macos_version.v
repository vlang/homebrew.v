module homebrew

import ruby

// Translated from Homebrew/brew `macos_version.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :version` at line 11.
pub fn ruby_macos_version_l11_d1_version(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.object_value('Nil', '') }
}

// Ruby method `initialize(version)` at line 14.
pub fn ruby_macos_version_l14_d2_initialize(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0].as_string() } else { '' }
	inspected := if args.len == 0 || args[0].type_name == 'Nil' {
		'nil'
	} else if args[0].type_name == 'Symbol' {
		':${value}'
	} else {
		'"${value}"'
	}
	return ruby.structured_value('MacOSVersion::Error',
		'unknown or unsupported macOS version: ${inspected}', {
		'version': value
	})
}

// Ruby method `self.kernel_major_version(macos_version)` at line 37.
pub fn ruby_macos_version_l37_d3_self_kernel_major_version(args ...ruby.Value) ruby.Value {
	version := macos_version_from_args(args) or { panic(err) }
	return ruby.object_value('Version', version.kernel_major_version().to_s())
}

// Ruby method `self.from_symbol(version)` at line 52.
pub fn ruby_macos_version_l52_d4_self_from_symbol(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	return macos_version_value(macos_version_from_symbol(name) or { panic(err) })
}

// Ruby attr_reader `attr_reader :comparison_cache` at line 58.
pub fn ruby_macos_version_l58_d5_comparison_cache(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Hash', '{}', {})
}

// Ruby attr_reader `attr_reader :sym` at line 61.
pub fn ruby_macos_version_l61_d6_sym(args ...ruby.Value) ruby.Value {
	if args.len > 0 && args[0].attributes['sym'].len > 0 {
		return ruby.object_value('Symbol', args[0].attributes['sym'])
	}
	return ruby.object_value('Nil', '')
}

// Ruby method `initialize(version)` at line 64.
pub fn ruby_macos_version_l64_d7_initialize(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0].as_string() } else { '' }
	return macos_version_value(new_macos_version(value) or { panic(err) })
}

// Ruby method `<=>(other)` at line 75.
pub fn ruby_macos_version_l75_d8_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('Nil', '')
	}
	version := macos_version_from_value(args[0]) or { panic(err) }
	comparison := if args[1].type_name == 'Symbol' {
		version.compare_symbol(args[1].as_string())
	} else {
		other := new_version(args[1].as_string()) or { panic(err) }
		version.version.compare_to(other)
	}
	return ruby.int_value(comparison)
}

// Ruby method `strip_patch` at line 96.
pub fn ruby_macos_version_l96_d9_strip_patch(args ...ruby.Value) ruby.Value {
	version := macos_version_from_args(args) or { panic(err) }
	return macos_version_value(version.strip_patch())
}

// Ruby method `to_sym` at line 108.
pub fn ruby_macos_version_l108_d10_to_sym(args ...ruby.Value) ruby.Value {
	version := macos_version_from_args(args) or { panic(err) }
	return ruby.object_value('Symbol', version.to_symbol())
}

// Ruby method `pretty_name` at line 119.
pub fn ruby_macos_version_l119_d11_pretty_name(args ...ruby.Value) ruby.Value {
	version := macos_version_from_args(args) or { panic(err) }
	return ruby.string_value(version.pretty_name())
}

// Ruby method `inspect` at line 130.
pub fn ruby_macos_version_l130_d12_inspect(args ...ruby.Value) ruby.Value {
	version := macos_version_from_args(args) or { panic(err) }
	return ruby.string_value(version.inspect())
}

// Ruby method `outdated_release?` at line 135.
pub fn ruby_macos_version_l135_d13_outdated_release(args ...ruby.Value) ruby.Value {
	version := macos_version_from_args(args) or { panic(err) }
	oldest := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby.environment_value('HOMEBREW_MACOS_OLDEST_SUPPORTED')
	}
	return ruby.bool_value(version.outdated_release(oldest) or { panic(err) })
}

// Ruby method `prerelease?` at line 140.
pub fn ruby_macos_version_l140_d14_prerelease(args ...ruby.Value) ruby.Value {
	version := macos_version_from_args(args) or { panic(err) }
	newest := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby.environment_value('HOMEBREW_MACOS_NEWEST_UNSUPPORTED')
	}
	return ruby.bool_value(version.prerelease(newest) or { panic(err) })
}

// Ruby method `unsupported_release?` at line 145.
pub fn ruby_macos_version_l145_d15_unsupported_release(args ...ruby.Value) ruby.Value {
	version := macos_version_from_args(args) or { panic(err) }
	oldest := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby.environment_value('HOMEBREW_MACOS_OLDEST_SUPPORTED')
	}
	newest := if args.len > 2 {
		args[2].as_string()
	} else {
		ruby.environment_value('HOMEBREW_MACOS_NEWEST_UNSUPPORTED')
	}
	return ruby.bool_value(version.unsupported_release(oldest, newest) or { panic(err) })
}

// Ruby method `requires_nehalem_cpu?` at line 150.
pub fn ruby_macos_version_l150_d16_requires_nehalem_cpu(args ...ruby.Value) ruby.Value {
	version := macos_version_from_args(args) or { panic(err) }
	intel := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	oldest_cpu := if args.len > 2 { args[2].as_string() } else { '' }
	return ruby.bool_value(version.requires_nehalem_cpu(intel, oldest_cpu) or { panic(err) })
}

// Ruby alias `alias requires_sse4? requires_nehalem_cpu?` at line 160.
pub fn ruby_macos_version_l160_d17_requires_sse4(args ...ruby.Value) ruby.Value {
	return ruby_macos_version_l150_d16_requires_nehalem_cpu(...args)
}

// Ruby alias `alias requires_sse41? requires_nehalem_cpu?` at line 161.
pub fn ruby_macos_version_l161_d18_requires_sse41(args ...ruby.Value) ruby.Value {
	return ruby_macos_version_l150_d16_requires_nehalem_cpu(...args)
}

// Ruby alias `alias requires_sse42? requires_nehalem_cpu?` at line 162.
pub fn ruby_macos_version_l162_d19_requires_sse42(args ...ruby.Value) ruby.Value {
	return ruby_macos_version_l150_d16_requires_nehalem_cpu(...args)
}

// Ruby alias `alias requires_popcnt? requires_nehalem_cpu?` at line 163.
pub fn ruby_macos_version_l163_d20_requires_popcnt(args ...ruby.Value) ruby.Value {
	return ruby_macos_version_l150_d16_requires_nehalem_cpu(...args)
}

// MacOSVersion keeps the source's stricter macOS input validation while using
// the translated Version type for ordering and components.
pub struct MacOSVersion {
pub:
	version Version
	is_null bool
}

pub fn macos_symbol_versions() map[string]string {
	return {
		'golden_gate': '27'
		'tahoe':       '26'
		'sequoia':     '15'
		'sonoma':      '14'
		'ventura':     '13'
		'monterey':    '12'
		'big_sur':     '11'
		'catalina':    '10.15'
	}
}

pub fn new_macos_version(value string) !MacOSVersion {
	parts := value.split('.')
	if parts.len == 0 || parts.len > 3 || parts[0].len < 2 || parts.any(it.len == 0
		|| !it.bytes().all(byte_is_digit(it))) {
		return error('unknown or unsupported macOS version: "${value}"')
	}
	return MacOSVersion{
		version: new_version(value)!
	}
}

pub fn null_macos_version() MacOSVersion {
	return MacOSVersion{
		version: null_version()
		is_null: true
	}
}

pub fn macos_version_from_symbol(symbol string) !MacOSVersion {
	versions := macos_symbol_versions()
	value := versions[symbol] or {
		return error('unknown or unsupported macOS version: :${symbol}')
	}
	return new_macos_version(value)
}

pub fn (version MacOSVersion) kernel_major_version() Version {
	major := version.version.major() or { return null_version() }
	major_number := major.number
	kernel_major := if major_number >= 27 {
		major_number
	} else if major_number == 26 {
		major_number - 1
	} else if major_number > 10 {
		major_number + 9
	} else {
		minor := version.version.minor() or { null_version_token() }
		minor.number + 4
	}
	return new_version(kernel_major.str()) or { null_version() }
}

pub fn (version MacOSVersion) compare(other MacOSVersion) int {
	return version.version.compare_to(other.version)
}

pub fn (version MacOSVersion) compare_symbol(symbol string) int {
	if symbol in macos_symbol_versions() && version.to_symbol() == symbol {
		return 0
	}
	other_value := macos_symbol_versions()[symbol] or { symbol }
	other := new_version(other_value) or { return 1 }
	return version.version.compare_to(other)
}

pub fn (version MacOSVersion) strip_patch() MacOSVersion {
	if version.is_null {
		return version
	}
	major := version.version.major() or { return version }
	stripped := if major.number >= 11 {
		major.number.str()
	} else {
		version.version.major_minor().to_s()
	}
	return new_macos_version(stripped) or { version }
}

pub fn (version MacOSVersion) to_symbol() string {
	if version.is_null {
		return 'dunno'
	}
	stripped := version.strip_patch().str()
	for symbol, value in macos_symbol_versions() {
		if value == stripped {
			return symbol
		}
	}
	return 'dunno'
}

pub fn (version MacOSVersion) pretty_name() string {
	return version.to_symbol().split('_').map(title_word(it)).join(' ')
}

pub fn (version MacOSVersion) inspect() string {
	return '#<MacOSVersion: "${version.str()}">'
}

pub fn (version MacOSVersion) outdated_release(oldest_supported string) !bool {
	if oldest_supported.len == 0 {
		return error('HOMEBREW_MACOS_OLDEST_SUPPORTED is not configured')
	}
	return version.compare(new_macos_version(oldest_supported)!) < 0
}

pub fn (version MacOSVersion) prerelease(newest_unsupported string) !bool {
	if newest_unsupported.len == 0 {
		return error('HOMEBREW_MACOS_NEWEST_UNSUPPORTED is not configured')
	}
	return version.compare(new_macos_version(newest_unsupported)!) >= 0
}

pub fn (version MacOSVersion) unsupported_release(oldest_supported string,
	newest_unsupported string) !bool {
	return version.outdated_release(oldest_supported)! || version.prerelease(newest_unsupported)!
}

pub fn (version MacOSVersion) requires_nehalem_cpu(intel bool, oldest_cpu string) !bool {
	if version.is_null {
		return false
	}
	if !intel {
		return error('Unexpected architecture. This only works with Intel architecture.')
	}
	return oldest_cpu == 'nehalem'
}

pub fn (version MacOSVersion) str() string {
	return version.version.to_s()
}

fn byte_is_digit(value u8) bool {
	return value >= `0` && value <= `9`
}

fn title_word(value string) string {
	if value.len == 0 {
		return value
	}
	return value[..1].to_upper() + value[1..]
}

fn macos_version_value(version MacOSVersion) ruby.Value {
	return ruby.structured_value('MacOSVersion', version.str(), {
		'value': version.str()
		'null':  version.is_null.str()
		'sym':   version.to_symbol()
	})
}

fn macos_version_from_args(args []ruby.Value) !MacOSVersion {
	if args.len == 0 {
		return error('missing MacOSVersion receiver')
	}
	return macos_version_from_value(args[0])
}

fn macos_version_from_value(value ruby.Value) !MacOSVersion {
	if value.attributes['null'] == 'true' {
		return null_macos_version()
	}
	return new_macos_version(if value.attributes['value'].len > 0 {
		value.attributes['value']
	} else {
		value.as_string()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strong
// 2: # frozen_string_literal: true
// 3:
// 4: require "version"
// 5:
// 6: # A macOS version.
// 7: class MacOSVersion < Version
// 8:   # Raised when a macOS version is unsupported.
// 9:   class Error < RuntimeError
// 10:     sig { returns(T.nilable(T.any(String, Symbol))) }
// 11:     attr_reader :version
// 12:
// 13:     sig { params(version: T.nilable(T.any(String, Symbol))).void }
// 14:     def initialize(version)
// 15:       @version = version
// 16:       super "unknown or unsupported macOS version: #{version.inspect}"
// 17:     end
// 18:   end
// 19:
// 20:   # NOTE: When removing symbols here, ensure that they are added
// 21:   #       to `DEPRECATED_MACOS_VERSIONS` in `MacOSRequirement`.
// 22:   # NOTE: Changes to this list must match `macos_version_name` in `cmd/update.sh`.
// 23:   SYMBOLS = T.let({
// 24:     golden_gate: "27",
// 25:     tahoe:       "26",
// 26:     sequoia:     "15",
// 27:     sonoma:      "14",
// 28:     ventura:     "13",
// 29:     monterey:    "12",
// 30:     # odisabled: remove support for Big Sur and macOS x86_64 September (or later) 2027
// 31:     big_sur:     "11",
// 32:     # odisabled: remove support for Catalina September (or later) 2026
// 33:     catalina:    "10.15",
// 34:   }.freeze, T::Hash[Symbol, String])
// 35:
// 36:   sig { params(macos_version: MacOSVersion).returns(Version) }
// 37:   def self.kernel_major_version(macos_version)
// 38:     version_major = macos_version.major.to_i
// 39:     if version_major >= 27
// 40:       Version.new(version_major.to_s)
// 41:     elsif version_major == 26
// 42:       Version.new((version_major - 1).to_s)
// 43:     elsif version_major > 10
// 44:       Version.new((version_major + 9).to_s)
// 45:     else
// 46:       version_minor = macos_version.minor.to_i
// 47:       Version.new((version_minor + 4).to_s)
// 48:     end
// 49:   end
// 50:
// 51:   sig { params(version: Symbol).returns(T.attached_class) }
// 52:   def self.from_symbol(version)
// 53:     str = SYMBOLS.fetch(version) { raise MacOSVersion::Error, version }
// 54:     new(str)
// 55:   end
// 56:
// 57:   sig { returns(T::Hash[T.untyped, T.nilable(Integer)]) }
// 58:   attr_reader :comparison_cache
// 59:
// 60:   sig { returns(T.nilable(Symbol)) }
// 61:   attr_reader :sym
// 62:
// 63:   sig { params(version: T.nilable(String)).void }
// 64:   def initialize(version)
// 65:     raise MacOSVersion::Error, version unless /\A\d{2,}(?:\.\d+){0,2}\z/.match?(version)
// 66:
// 67:     super(T.must(version))
// 68:
// 69:     @comparison_cache = T.let({}, T::Hash[T.untyped, T.nilable(Integer)])
// 70:     @pretty_name = T.let(nil, T.nilable(String))
// 71:     @sym = T.let(nil, T.nilable(Symbol))
// 72:   end
// 73:
// 74:   sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
// 75:   def <=>(other)
// 76:     return @comparison_cache[other] if @comparison_cache.key?(other)
// 77:
// 78:     result = case other
// 79:     when Symbol
// 80:       if SYMBOLS.key?(other) && to_sym == other
// 81:         0
// 82:       else
// 83:         v = SYMBOLS.fetch(other) { other.to_s }
// 84:         super(v)
// 85:       end
// 86:     else
// 87:       super
// 88:     end
// 89:
// 90:     @comparison_cache[other] = result unless frozen?
// 91:
// 92:     result
// 93:   end
// 94:
// 95:   sig { returns(T.self_type) }
// 96:   def strip_patch
// 97:     return self if null?
// 98:
// 99:     # Big Sur is 11.x but Catalina is 10.15.x.
// 100:     if T.must(major) >= 11
// 101:       self.class.new(major.to_s)
// 102:     else
// 103:       major_minor
// 104:     end
// 105:   end
// 106:
// 107:   sig { returns(Symbol) }
// 108:   def to_sym
// 109:     return @sym if @sym
// 110:
// 111:     sym = SYMBOLS.invert.fetch(strip_patch.to_s, :dunno)
// 112:
// 113:     @sym = sym unless frozen?
// 114:
// 115:     sym
// 116:   end
// 117:
// 118:   sig { returns(String) }
// 119:   def pretty_name
// 120:     return @pretty_name if @pretty_name
// 121:
// 122:     pretty_name = to_sym.to_s.split("_").map(&:capitalize).join(" ").freeze
// 123:
// 124:     @pretty_name = pretty_name unless frozen?
// 125:
// 126:     pretty_name
// 127:   end
// 128:
// 129:   sig { returns(String) }
// 130:   def inspect
// 131:     "#<#{self.class.name}: #{to_s.inspect}>"
// 132:   end
// 133:
// 134:   sig { returns(T::Boolean) }
// 135:   def outdated_release?
// 136:     self < HOMEBREW_MACOS_OLDEST_SUPPORTED
// 137:   end
// 138:
// 139:   sig { returns(T::Boolean) }
// 140:   def prerelease?
// 141:     self >= HOMEBREW_MACOS_NEWEST_UNSUPPORTED
// 142:   end
// 143:
// 144:   sig { returns(T::Boolean) }
// 145:   def unsupported_release?
// 146:     outdated_release? || prerelease?
// 147:   end
// 148:
// 149:   sig { returns(T::Boolean) }
// 150:   def requires_nehalem_cpu?
// 151:     return false if null?
// 152:
// 153:     require "hardware"
// 154:
// 155:     return Hardware.oldest_cpu(self) == :nehalem if Hardware::CPU.intel?
// 156:
// 157:     raise ArgumentError, "Unexpected architecture: #{Hardware::CPU.arch}. This only works with Intel architecture."
// 158:   end
// 159:   # https://en.wikipedia.org/wiki/Nehalem_(microarchitecture)
// 160:   alias requires_sse4? requires_nehalem_cpu?
// 161:   alias requires_sse41? requires_nehalem_cpu?
// 162:   alias requires_sse42? requires_nehalem_cpu?
// 163:   alias requires_popcnt? requires_nehalem_cpu?
// 164:
// 165:   # Represents the absence of a version.
// 166:   #
// 167:   # NOTE: Constructor needs to called with an arbitrary macOS-like version which is then set to `nil`.
// 168:   NULL = T.let(MacOSVersion.new("10.0").tap do |v|
// 169:     T.let(v, MacOSVersion).instance_variable_set(:@version, nil)
// 170:   end.freeze, MacOSVersion)
// 171: end
