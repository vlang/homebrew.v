module homebrew

import ruby

// Translated from Homebrew/brew `bottle_specification.rb`.
// The original source is retained below until every stub has a typed V body.

pub enum BottleCellarKind {
	path
	any
	any_skip_relocation
}

// BottleCellar preserves the Ruby String-or-Symbol cellar value without using
// a dynamic runtime value.
pub struct BottleCellar {
pub:
	kind  BottleCellarKind
	value string
}

pub struct BottleLocationContext {
pub:
	prefix                string
	cellar                string
	relocate_build_prefix bool
	linux                 bool
	tab_homebrew_version  string
}

pub struct BottleChecksumSpecification {
pub:
	tag    string
	digest Checksum
	cellar BottleCellar
}

pub struct BottleSpecification {
pub mut:
	tap            string
	has_tap        bool
	collector      BottleTagCollector
	root_url_specs map[string]string
	repository     string
	rebuild_value  int
	root_url_value string
	has_root_url   bool
}

pub fn bottle_cellar_any() BottleCellar {
	return BottleCellar{
		kind: .any
	}
}

pub fn bottle_cellar_any_skip_relocation() BottleCellar {
	return BottleCellar{
		kind: .any_skip_relocation
	}
}

pub fn bottle_cellar_path(path string) BottleCellar {
	return BottleCellar{
		kind:  .path
		value: path
	}
}

pub fn parse_bottle_cellar(value string) BottleCellar {
	normalized := value.trim_string_left(':')
	return match normalized {
		'any' { bottle_cellar_any() }
		'any_skip_relocation' { bottle_cellar_any_skip_relocation() }
		else { bottle_cellar_path(value) }
	}
}

pub fn (cellar BottleCellar) str() string {
	return match cellar.kind {
		.any { 'any' }
		.any_skip_relocation { 'any_skip_relocation' }
		.path { cellar.value }
	}
}

pub fn (cellar BottleCellar) equals(other BottleCellar) bool {
	return cellar.kind == other.kind && cellar.value == other.value
}

pub fn (cellar BottleCellar) relocatable() bool {
	return cellar.kind in [.any, .any_skip_relocation]
}

fn default_bottle_domain() string {
	configured := ruby.environment_value('HOMEBREW_BOTTLE_DOMAIN')
	if configured != '' {
		return configured.trim_string_right('/')
	}
	configured_default := ruby.environment_value('HOMEBREW_BOTTLE_DEFAULT_DOMAIN')
	if configured_default != '' {
		return configured_default.trim_string_right('/')
	}
	return 'https://ghcr.io/v2/homebrew/core'
}

fn default_bottle_repository() string {
	configured := ruby.environment_value('HOMEBREW_DEFAULT_REPOSITORY')
	if configured != '' {
		return configured
	}
	return current_bottle_tag().default_prefix()
}

// github_packages_root_url_if_match translates
// GitHubPackages.root_url_if_match for bottle roots.
pub fn github_packages_root_url_if_match(value string) ?string {
	mut remainder := ''
	if value.starts_with('https://ghcr.io/v2/') {
		remainder = value.trim_string_left('https://ghcr.io/v2/')
	} else if value.starts_with('docker://ghcr.io/') {
		remainder = value.trim_string_left('docker://ghcr.io/')
	} else {
		return none
	}
	parts := remainder.split('/')
	if parts.len < 2 || parts[0] == '' || parts[1] == '' {
		return none
	}
	repository := parts[1].trim_string_left('homebrew-')
	return 'https://ghcr.io/v2/${parts[0].to_lower()}/${repository}'
}

pub fn new_bottle_specification() BottleSpecification {
	return BottleSpecification{
		collector:      new_bottle_tag_collector()
		root_url_specs: map[string]string{}
		repository:     default_bottle_repository()
	}
}

pub fn (specification BottleSpecification) rebuild() int {
	return specification.rebuild_value
}

pub fn (mut specification BottleSpecification) set_rebuild(value int) int {
	specification.rebuild_value = value
	return value
}

pub fn (mut specification BottleSpecification) root_url() string {
	if !specification.has_root_url {
		domain := default_bottle_domain()
		specification.root_url_value = github_packages_root_url_if_match(domain) or { domain }
		specification.has_root_url = true
	}
	return specification.root_url_value
}

pub fn (mut specification BottleSpecification) set_root_url(value string,
	specs map[string]string) string {
	specification.root_url_value = github_packages_root_url_if_match(value) or { value }
	specification.has_root_url = true
	for key, spec in specs {
		specification.root_url_specs[key] = spec
	}
	return specification.root_url_value
}

pub fn (left BottleSpecification) equals(right BottleSpecification) bool {
	mut left_copy := left
	mut right_copy := right
	return left.rebuild_value == right.rebuild_value && left.collector.equals(right.collector)
		&& left_copy.root_url() == right_copy.root_url()
		&& left.root_url_specs == right.root_url_specs && left.tap == right.tap
		&& left.has_tap == right.has_tap
}

pub fn (specification BottleSpecification) tag_to_cellar(tag BottleTag) BottleCellar {
	if tag_specification := specification.collector.specification_for(tag, false) {
		return tag_specification.cellar
	}
	return tag.default_cellar()
}

fn bottle_parent_path(path string) string {
	trimmed := path.trim_string_right('/')
	if index := trimmed.last_index('/') {
		if index == 0 {
			return '/'
		}
		return trimmed[..index]
	}
	return '.'
}

pub fn default_bottle_location_context(tag BottleTag) BottleLocationContext {
	mut prefix := ruby.environment_value('HOMEBREW_PREFIX')
	if prefix == '' {
		prefix = tag.default_prefix()
	}
	mut cellar := ruby.environment_value('HOMEBREW_CELLAR')
	if cellar == '' {
		cellar = '${prefix}/Cellar'
	}
	return BottleLocationContext{
		prefix:                prefix
		cellar:                cellar
		relocate_build_prefix: ruby.environment_value('HOMEBREW_RELOCATE_BUILD_PREFIX') != ''
		linux:                 tag.linux()
	}
}

pub fn (specification BottleSpecification) compatible_locations(tag BottleTag,
	context BottleLocationContext) bool {
	cellar := specification.tag_to_cellar(tag)
	if cellar.relocatable() {
		return true
	}
	cellar_path := cellar.str()
	prefix := bottle_parent_path(cellar_path)
	cellar_relocatable := cellar_path.len >= context.cellar.len && context.relocate_build_prefix
	prefix_relocatable := prefix.len >= context.prefix.len && context.relocate_build_prefix
	compatible_cellar := cellar_path == context.cellar || cellar_relocatable
	compatible_prefix := prefix == context.prefix || prefix_relocatable
	return compatible_cellar && compatible_prefix
}

pub fn (specification BottleSpecification) skip_relocation(tag BottleTag,
	context BottleLocationContext) bool {
	tag_specification := specification.collector.specification_for(tag, false) or { return false }
	if tag_specification.cellar.kind != .any_skip_relocation {
		return false
	}
	if !context.linux {
		return true
	}
	if context.tab_homebrew_version == '' {
		return false
	}
	minimum := new_version('5.1.15') or { return false }
	version := new_version(context.tab_homebrew_version) or { return false }
	return version.compare_to(minimum) >= 0
}

pub fn (specification BottleSpecification) has_tag(tag BottleTag,
	no_older_versions bool) bool {
	return specification.collector.has_tag(tag, no_older_versions)
}

fn valid_bottle_digest(digest string) bool {
	if digest.len != 64 {
		return false
	}
	for character in digest.to_lower() {
		if !(character.is_digit() || character in [`a`, `b`, `c`, `d`, `e`, `f`]) {
			return false
		}
	}
	return true
}

pub fn (mut specification BottleSpecification) sha256(tag_symbol string, digest string,
	cellar ?BottleCellar) ! {
	if !valid_bottle_digest(digest) {
		return error('Invalid sha256 hash: ${digest}')
	}
	tag := bottle_tag_from_symbol(tag_symbol)!
	selected_cellar := cellar or { tag.default_cellar() }
	specification.collector.add(tag, new_checksum(digest), selected_cellar)
}

pub fn (specification BottleSpecification) tag_specification_for(tag BottleTag,
	no_older_versions bool) ?BottleTagSpecification {
	return specification.collector.specification_for(tag, no_older_versions)
}

fn compare_bottle_checksum_tags(left &BottleTag, right &BottleTag) int {
	left_macos := left.macos()
	right_macos := right.macos()
	left_priority := if left_macos {
		if left.standardized_arch() == 'arm64' { 3 } else { 2 }
	} else if left.standardized_arch() == 'arm64' {
		1
	} else {
		0
	}
	right_priority := if right_macos {
		if right.standardized_arch() == 'arm64' { 3 } else { 2 }
	} else if right.standardized_arch() == 'arm64' {
		1
	} else {
		0
	}
	if left_priority != right_priority {
		return if left_priority < right_priority { -1 } else { 1 }
	}
	if left_macos && right_macos {
		left_version := left.macos_version() or { return -1 }
		right_version := right.macos_version() or { return 1 }
		return left_version.compare_to(right_version)
	}
	return if left.symbol() < right.symbol() {
		-1
	} else if left.symbol() > right.symbol() {
		1
	} else {
		0
	}
}

pub fn (specification BottleSpecification) checksums() []BottleChecksumSpecification {
	mut tags := specification.collector.tags()
	tags.sort_with_compare(compare_bottle_checksum_tags)
	mut checksums := []BottleChecksumSpecification{}
	for index := tags.len - 1; index >= 0; index-- {
		tag := tags[index]
		tag_specification := specification.collector.specification_for(tag, true) or { continue }
		checksums << BottleChecksumSpecification{
			tag:    tag_specification.tag.symbol()
			digest: tag_specification.checksum
			cellar: tag_specification.cellar
		}
	}
	return checksums
}

// Ruby attr_accessor `attr_accessor :tap` at line 18.
pub fn ruby_bottle_specification_l18_d1_tap(specification &BottleSpecification) ?string {
	if specification.has_tap {
		return specification.tap
	}
	return none
}

// Ruby attr_accessor `attr_accessor :tap` at line 18.
pub fn ruby_bottle_specification_l18_d2_tap(mut specification BottleSpecification, tap ?string) {
	if value := tap {
		specification.tap = value
		specification.has_tap = true
	} else {
		specification.tap = ''
		specification.has_tap = false
	}
}

// Ruby attr_reader `attr_reader :collector` at line 21.
pub fn ruby_bottle_specification_l21_d3_collector(specification &BottleSpecification) BottleTagCollector {
	return specification.collector
}

// Ruby attr_reader `attr_reader :root_url_specs` at line 24.
pub fn ruby_bottle_specification_l24_d4_root_url_specs(specification &BottleSpecification) map[string]string {
	return specification.root_url_specs.clone()
}

// Ruby attr_reader `attr_reader :repository` at line 27.
pub fn ruby_bottle_specification_l27_d5_repository(specification &BottleSpecification) string {
	return specification.repository
}

// Ruby method `initialize` at line 30.
pub fn ruby_bottle_specification_l30_d6_initialize() BottleSpecification {
	return new_bottle_specification()
}

// Ruby method `rebuild(val = T.unsafe(nil))` at line 39.
pub fn ruby_bottle_specification_l39_d7_rebuild(mut specification BottleSpecification,
	value ?int) int {
	if rebuild := value {
		return specification.set_rebuild(rebuild)
	}
	return specification.rebuild()
}

// Ruby method `root_url(var = nil, specs = {})` at line 44.
pub fn ruby_bottle_specification_l44_d8_root_url(mut specification BottleSpecification,
	value ?string, specs map[string]string) string {
	if url := value {
		return specification.set_root_url(url, specs)
	}
	return specification.root_url()
}

// Ruby method `==(other)` at line 63.
pub fn ruby_bottle_specification_l63_d9_anonymous(left BottleSpecification,
	right BottleSpecification) bool {
	return left.equals(right)
}

// Ruby alias `alias eql? ==` at line 71.
pub fn ruby_bottle_specification_l71_d10_eql(left BottleSpecification,
	right BottleSpecification) bool {
	return left.equals(right)
}

// Ruby method `tag_to_cellar(tag = Utils::Bottles.tag)` at line 74.
pub fn ruby_bottle_specification_l74_d11_tag_to_cellar(specification &BottleSpecification,
	tag BottleTag) BottleCellar {
	return specification.tag_to_cellar(tag)
}

// Ruby method `compatible_locations?(tag: Utils::Bottles.tag)` at line 84.
pub fn ruby_bottle_specification_l84_d12_compatible_locations(specification &BottleSpecification,
	tag BottleTag, context BottleLocationContext) bool {
	return specification.compatible_locations(tag, context)
}

// Ruby method `skip_relocation?(tag: Utils::Bottles.tag, tab: nil)` at line 106.
pub fn ruby_bottle_specification_l106_d13_skip_relocation(specification &BottleSpecification,
	tag BottleTag, context BottleLocationContext) bool {
	return specification.skip_relocation(tag, context)
}

// Ruby method `tag?(tag, no_older_versions: false)` at line 112.
pub fn ruby_bottle_specification_l112_d14_tag(specification &BottleSpecification,
	tag BottleTag, no_older_versions bool) bool {
	return specification.has_tag(tag, no_older_versions)
}

// Ruby method `sha256(hash)` at line 124.
pub fn ruby_bottle_specification_l124_d15_sha256(mut specification BottleSpecification,
	tag string, digest string, cellar ?BottleCellar) ! {
	specification.sha256(tag, digest, cellar)!
}

// Ruby method `tag_specification_for(tag, no_older_versions: false)` at line 149.
pub fn ruby_bottle_specification_l149_d16_tag_specification_for(specification &BottleSpecification,
	tag BottleTag, no_older_versions bool) ?BottleTagSpecification {
	return specification.tag_specification_for(tag, no_older_versions)
}

// Ruby method `checksums` at line 154.
pub fn ruby_bottle_specification_l154_d17_checksums(specification &BottleSpecification) []BottleChecksumSpecification {
	return specification.checksums()
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
