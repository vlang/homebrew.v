module homebrew

import brew_runtime

// Translated from Homebrew/brew `bottle_specification.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :tap` at line 18.
pub fn ruby_bottle_specification_l18_d1_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby attr_accessor `attr_accessor :tap` at line 18.
pub fn ruby_bottle_specification_l18_d2_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap=', ...args)
}

// Ruby attr_reader `attr_reader :collector` at line 21.
pub fn ruby_bottle_specification_l21_d3_collector(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('collector', ...args)
}

// Ruby attr_reader `attr_reader :root_url_specs` at line 24.
pub fn ruby_bottle_specification_l24_d4_root_url_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('root_url_specs', ...args)
}

// Ruby attr_reader `attr_reader :repository` at line 27.
pub fn ruby_bottle_specification_l27_d5_repository(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('repository', ...args)
}

// Ruby method `initialize` at line 30.
pub fn ruby_bottle_specification_l30_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `rebuild(val = T.unsafe(nil))` at line 39.
pub fn ruby_bottle_specification_l39_d7_rebuild(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rebuild', ...args)
}

// Ruby method `root_url(var = nil, specs = {})` at line 44.
pub fn ruby_bottle_specification_l44_d8_root_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('root_url', ...args)
}

// Ruby method `==(other)` at line 63.
pub fn ruby_bottle_specification_l63_d9_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby alias `alias eql? ==` at line 71.
pub fn ruby_bottle_specification_l71_d10_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby method `tag_to_cellar(tag = Utils::Bottles.tag)` at line 74.
pub fn ruby_bottle_specification_l74_d11_tag_to_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tag_to_cellar', ...args)
}

// Ruby method `compatible_locations?(tag: Utils::Bottles.tag)` at line 84.
pub fn ruby_bottle_specification_l84_d12_compatible_locations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compatible_locations?', ...args)
}

// Ruby method `skip_relocation?(tag: Utils::Bottles.tag, tab: nil)` at line 106.
pub fn ruby_bottle_specification_l106_d13_skip_relocation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip_relocation?', ...args)
}

// Ruby method `tag?(tag, no_older_versions: false)` at line 112.
pub fn ruby_bottle_specification_l112_d14_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tag?', ...args)
}

// Ruby method `sha256(hash)` at line 124.
pub fn ruby_bottle_specification_l124_d15_sha256(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sha256', ...args)
}

// Ruby method `tag_specification_for(tag, no_older_versions: false)` at line 149.
pub fn ruby_bottle_specification_l149_d16_tag_specification_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tag_specification_for', ...args)
}

// Ruby method `checksums` at line 154.
pub fn ruby_bottle_specification_l154_d17_checksums(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checksums', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class BottleSpecification
// 5:   include Utils::Output::Mixin
// 6:
// 7:   # Relocatable cellar using placeholders, e.g. `@@HOMEBREW_PREFIX@@`.
// 8:   # Requires relocating text files and binaries.
// 9:   ANY_CELLAR = :any
// 10:
// 11:   # Relocatable cellar using placeholders, e.g. `@@HOMEBREW_PREFIX@@`.
// 12:   # Does not need to relocate binaries but still relocates text files.
// 13:   ANY_SKIP_RELOCATION_CELLAR = :any_skip_relocation
// 14:
// 15:   RELOCATABLE_CELLARS = T.let([ANY_CELLAR, ANY_SKIP_RELOCATION_CELLAR].freeze, T::Array[Symbol])
// 16:
// 17:   sig { returns(T.nilable(Tap)) }
// 18:   attr_accessor :tap
// 19:
// 20:   sig { returns(Utils::Bottles::Collector) }
// 21:   attr_reader :collector
// 22:
// 23:   sig { returns(T::Hash[Symbol, T.untyped]) }
// 24:   attr_reader :root_url_specs
// 25:
// 26:   sig { returns(String) }
// 27:   attr_reader :repository
// 28:
// 29:   sig { void }
// 30:   def initialize
// 31:     @rebuild = T.let(0, Integer)
// 32:     @repository = T.let(Homebrew::DEFAULT_REPOSITORY, String)
// 33:     @collector = T.let(Utils::Bottles::Collector.new, Utils::Bottles::Collector)
// 34:     @root_url_specs = T.let({}, T::Hash[Symbol, T.untyped])
// 35:     @root_url = T.let(nil, T.nilable(String))
// 36:   end
// 37:
// 38:   sig { params(val: Integer).returns(Integer) }
// 39:   def rebuild(val = T.unsafe(nil))
// 40:     val.nil? ? @rebuild : @rebuild = val
// 41:   end
// 42:
// 43:   sig { params(var: T.nilable(String), specs: T::Hash[Symbol, T.untyped]).returns(String) }
// 44:   def root_url(var = nil, specs = {})
// 45:     if var.nil?
// 46:       @root_url ||= if (github_packages_url = GitHubPackages.root_url_if_match(Homebrew::EnvConfig.bottle_domain))
// 47:         github_packages_url
// 48:       else
// 49:         Homebrew::EnvConfig.bottle_domain
// 50:       end
// 51:     else
// 52:       @root_url = if (github_packages_url = GitHubPackages.root_url_if_match(var))
// 53:         github_packages_url
// 54:       else
// 55:         var
// 56:       end
// 57:       @root_url_specs.merge!(specs)
// 58:       @root_url
// 59:     end
// 60:   end
// 61:
// 62:   sig { override.params(other: BasicObject).returns(T::Boolean) }
// 63:   def ==(other)
// 64:     case other
// 65:     when self.class
// 66:       rebuild == other.rebuild && collector == other.collector &&
// 67:         root_url == other.root_url && root_url_specs == other.root_url_specs && tap == other.tap
// 68:     else false
// 69:     end
// 70:   end
// 71:   alias eql? ==
// 72:
// 73:   sig { params(tag: Utils::Bottles::Tag).returns(T.any(Symbol, String)) }
// 74:   def tag_to_cellar(tag = Utils::Bottles.tag)
// 75:     spec = collector.specification_for(tag)
// 76:     if spec.present?
// 77:       spec.cellar
// 78:     else
// 79:       tag.default_cellar
// 80:     end
// 81:   end
// 82:
// 83:   sig { params(tag: Utils::Bottles::Tag).returns(T::Boolean) }
// 84:   def compatible_locations?(tag: Utils::Bottles.tag)
// 85:     cellar = tag_to_cellar(tag)
// 86:
// 87:     return true if RELOCATABLE_CELLARS.include?(cellar)
// 88:
// 89:     prefix = Pathname(cellar.to_s).parent.to_s
// 90:
// 91:     cellar_relocatable = cellar.size >= HOMEBREW_CELLAR.to_s.size && ENV["HOMEBREW_RELOCATE_BUILD_PREFIX"].present?
// 92:     prefix_relocatable = prefix.size >= HOMEBREW_PREFIX.to_s.size && ENV["HOMEBREW_RELOCATE_BUILD_PREFIX"].present?
// 93:
// 94:     compatible_cellar = cellar == HOMEBREW_CELLAR.to_s || cellar_relocatable
// 95:     compatible_prefix = prefix == HOMEBREW_PREFIX.to_s || prefix_relocatable
// 96:
// 97:     compatible_cellar && compatible_prefix
// 98:   end
// 99:
// 100:   # Does the {Bottle} this {BottleSpecification} belongs to need to be relocated?
// 101:   #
// 102:   # This will always return false on Linux unless a `tab` is provided that
// 103:   # reports the bottle was built with Homebrew 5.1.15 or newer. The caller must
// 104:   # make sure that the provided `tab` is for the requested `tag`.
// 105:   sig { params(tag: Utils::Bottles::Tag, tab: T.nilable(Tab)).returns(T::Boolean) }
// 106:   def skip_relocation?(tag: Utils::Bottles.tag, tab: nil)
// 107:     spec = collector.specification_for(tag)
// 108:     spec&.cellar == ANY_SKIP_RELOCATION_CELLAR
// 109:   end
// 110:
// 111:   sig { params(tag: Utils::Bottles::Tag, no_older_versions: T::Boolean).returns(T::Boolean) }
// 112:   def tag?(tag, no_older_versions: false)
// 113:     collector.tag?(tag, no_older_versions:)
// 114:   end
// 115:
// 116:   # Checksum methods in the DSL's bottle block take
// 117:   # a Hash, which indicates the platform the checksum applies on.
// 118:   # Example bottle block syntax:
// 119:   # bottle do
// 120:   #  sha256 cellar: :any_skip_relocation, big_sur: "69489ae397e4645..."
// 121:   #  sha256 cellar: :any, catalina: "449de5ea35d0e94..."
// 122:   # end
// 123:   sig { params(hash: T::Hash[T.any(Symbol, String), T.any(String, Symbol)]).void }
// 124:   def sha256(hash)
// 125:     sha256_regex = /^[a-f0-9]{64}$/i
// 126:
// 127:     # find new `sha256 big_sur: "69489ae397e4645..."` format
// 128:     tag, digest = hash.find do |key, value|
// 129:       # Don't use `odie` in this case. We want to be able to catch this exception
// 130:       # in runtime when getting committed version info in formula auditor
// 131:       raise LegacyDSLError.new(:sha256, hash) if key.is_a?(String) && key.match?(sha256_regex) && value.is_a?(Symbol)
// 132:
// 133:       key.is_a?(Symbol) && value.is_a?(String) && value.match?(sha256_regex)
// 134:     end
// 135:
// 136:     odie "Invalid sha256 hash: #{digest}" if !tag || !digest
// 137:
// 138:     tag = Utils::Bottles::Tag.from_symbol(T.cast(tag, Symbol))
// 139:
// 140:     cellar = hash[:cellar] || tag.default_cellar
// 141:
// 142:     collector.add(tag, checksum: Checksum.new(digest.to_s), cellar:)
// 143:   end
// 144:
// 145:   sig {
// 146:     params(tag: Utils::Bottles::Tag, no_older_versions: T::Boolean)
// 147:       .returns(T.nilable(Utils::Bottles::TagSpecification))
// 148:   }
// 149:   def tag_specification_for(tag, no_older_versions: false)
// 150:     collector.specification_for(tag, no_older_versions:)
// 151:   end
// 152:
// 153:   sig { returns(T::Array[{ "tag" => Symbol, "digest" => Checksum, "cellar" => T.any(Symbol, String) }]) }
// 154:   def checksums
// 155:     tags = collector.tags.sort_by do |tag|
// 156:       version = tag.to_macos_version
// 157:       # Give `arm64` bottles a higher priority so they are first.
// 158:       priority = (tag.arch == :arm64) ? 3 : 2
// 159:       "#{priority}.#{version}_#{tag}"
// 160:     rescue MacOSVersion::Error
// 161:       # Sort non-macOS tags below macOS tags, and arm64 tags before other tags.
// 162:       priority = (tag.arch == :arm64) ? 1 : 0
// 163:       "#{priority}.#{tag}"
// 164:     end
// 165:     tags.reverse.map do |tag|
// 166:       spec = collector.specification_for(tag)
// 167:       odie "Specification for tag #{tag} is nil" if spec.nil?
// 168:       {
// 169:         "tag"    => spec.tag.to_sym,
// 170:         "digest" => spec.checksum,
// 171:         "cellar" => spec.cellar,
// 172:       }
// 173:     end
// 174:   end
// 175: end
// 176:
// 177: require "extend/os/bottle_specification"
