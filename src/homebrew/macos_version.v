module homebrew

import brew_runtime

// Translated from Homebrew/brew `macos_version.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :version` at line 11.
pub fn ruby_macos_version_l11_d1_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby method `initialize(version)` at line 14.
pub fn ruby_macos_version_l14_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `self.kernel_major_version(macos_version)` at line 37.
pub fn ruby_macos_version_l37_d3_self_kernel_major_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.kernel_major_version', ...args)
}

// Ruby method `self.from_symbol(version)` at line 52.
pub fn ruby_macos_version_l52_d4_self_from_symbol(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_symbol', ...args)
}

// Ruby attr_reader `attr_reader :comparison_cache` at line 58.
pub fn ruby_macos_version_l58_d5_comparison_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('comparison_cache', ...args)
}

// Ruby attr_reader `attr_reader :sym` at line 61.
pub fn ruby_macos_version_l61_d6_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sym', ...args)
}

// Ruby method `initialize(version)` at line 64.
pub fn ruby_macos_version_l64_d7_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `<=>(other)` at line 75.
pub fn ruby_macos_version_l75_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<=>', ...args)
}

// Ruby method `strip_patch` at line 96.
pub fn ruby_macos_version_l96_d9_strip_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strip_patch', ...args)
}

// Ruby method `to_sym` at line 108.
pub fn ruby_macos_version_l108_d10_to_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_sym', ...args)
}

// Ruby method `pretty_name` at line 119.
pub fn ruby_macos_version_l119_d11_pretty_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_name', ...args)
}

// Ruby method `inspect` at line 130.
pub fn ruby_macos_version_l130_d12_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby method `outdated_release?` at line 135.
pub fn ruby_macos_version_l135_d13_outdated_release(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outdated_release?', ...args)
}

// Ruby method `prerelease?` at line 140.
pub fn ruby_macos_version_l140_d14_prerelease(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prerelease?', ...args)
}

// Ruby method `unsupported_release?` at line 145.
pub fn ruby_macos_version_l145_d15_unsupported_release(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unsupported_release?', ...args)
}

// Ruby method `requires_nehalem_cpu?` at line 150.
pub fn ruby_macos_version_l150_d16_requires_nehalem_cpu(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires_nehalem_cpu?', ...args)
}

// Ruby alias `alias requires_sse4? requires_nehalem_cpu?` at line 160.
pub fn ruby_macos_version_l160_d17_requires_sse4(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires_sse4?', ...args)
}

// Ruby alias `alias requires_sse41? requires_nehalem_cpu?` at line 161.
pub fn ruby_macos_version_l161_d18_requires_sse41(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires_sse41?', ...args)
}

// Ruby alias `alias requires_sse42? requires_nehalem_cpu?` at line 162.
pub fn ruby_macos_version_l162_d19_requires_sse42(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires_sse42?', ...args)
}

// Ruby alias `alias requires_popcnt? requires_nehalem_cpu?` at line 163.
pub fn ruby_macos_version_l163_d20_requires_popcnt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires_popcnt?', ...args)
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
