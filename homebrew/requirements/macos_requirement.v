module requirements

import brew_runtime
import homebrew
import x.json2

// Translated from Homebrew/brew `requirements/macos_requirement.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct MacOSRequirement {
pub:
	comparator string
	versions   []homebrew.MacOSVersion
	tags       []string
	fatal      bool = true
}

struct MacOSComparisonArgument {
	comparator string
	version    string
}

pub fn macos_oldest_allowed_version() homebrew.MacOSVersion {
	configured := brew_runtime.environment_value('HOMEBREW_MACOS_OLDEST_ALLOWED')
	value := if configured.len > 0 { configured } else { '10.15' }
	return homebrew.new_macos_version(value) or { panic(err) }
}

pub fn macos_newest_unsupported_version() homebrew.MacOSVersion {
	configured := brew_runtime.environment_value('HOMEBREW_MACOS_NEWEST_UNSUPPORTED')
	value := if configured.len > 0 { configured } else { '27' }
	return homebrew.new_macos_version(value) or { panic(err) }
}

fn macos_requirement_version(value string) !homebrew.MacOSVersion {
	if value in homebrew.macos_symbol_versions() {
		return homebrew.macos_version_from_symbol(value)
	}
	return homebrew.new_macos_version(value)
}

fn disabled_macos_requirement_version(value string) bool {
	return value in ['mojave', 'high_sierra', 'sierra', 'el_capitan']
}

fn macos_comparison_argument(value string) ?MacOSComparisonArgument {
	trimmed := value.trim_space()
	for comparator in ['<=', '>=', '==', '<', '>'] {
		if trimmed.starts_with(comparator) {
			mut version := trimmed[comparator.len..].trim_space()
			if version.starts_with(':') {
				version = version[1..]
			}
			if version.len == 0 || version.contains(' ') || version.contains('\t') {
				return none
			}
			return MacOSComparisonArgument{
				comparator: comparator
				version: version
			}
		}
	}
	return none
}

pub fn new_macos_requirement(tags []string, comparator string) !MacOSRequirement {
	comparison := if comparator.len > 0 { comparator } else { '>=' }
	if comparison !in ['>=', '<=', '==', '>', '<'] {
		return error('unsupported macOS requirement comparator `${comparison}`')
	}
	if tags.len == 0 {
		return MacOSRequirement{
			comparator: comparison
		}
	}
	version := macos_requirement_version(tags[0]) or {
		if disabled_macos_requirement_version(tags[0]) {
			return MacOSRequirement{
				comparator: comparison
				versions: if comparison == '>=' {
					[macos_oldest_allowed_version()]} else {
					[]homebrew.MacOSVersion{}}
				tags: tags[1..].clone()
			}
		}
		return err
	}
	return MacOSRequirement{
		comparator: comparison
		versions: [version]
		tags: tags[1..].clone()
	}
}

pub fn new_macos_range_requirement(version_values []string, tags []string) !MacOSRequirement {
	mut versions := []homebrew.MacOSVersion{}
	for value in version_values {
		version := macos_requirement_version(value) or {
			if disabled_macos_requirement_version(value) {
				continue
			}
			return err
		}
		versions << version
	}
	return MacOSRequirement{
		comparator: '=='
		versions: versions
		tags: tags.clone()
	}
}

pub fn parse_macos_requirement(arguments []string, comparator string) !MacOSRequirement {
	if arguments.len == 0 || arguments[0] == 'any' {
		return new_macos_requirement([]string{}, '>=')
	}
	if arguments.len > 1 {
		return new_macos_range_requirement(arguments, []string{})
	}
	if arguments[0] in homebrew.macos_symbol_versions() {
		return new_macos_requirement(arguments, comparator)
	}
	if comparison := macos_comparison_argument(arguments[0]) {
		return new_macos_requirement([comparison.version], comparison.comparator)
	}
	return new_macos_requirement(arguments, '==')
}

pub fn (requirement MacOSRequirement) version_specified() bool {
	return requirement.versions.len > 0
}

pub fn (requirement MacOSRequirement) macos_version_satisfied() bool {
	return false
}

pub fn (requirement MacOSRequirement) satisfied_on(current homebrew.MacOSVersion,
	running_on_macos bool) bool {
	if !running_on_macos {
		return false
	}
	if !requirement.version_specified() {
		return true
	}
	for version in requirement.versions {
		matches := match requirement.comparator {
			'>=' { current.compare(version) >= 0 }
			'<=' { current.compare(version) <= 0 }
			else { current.compare(version) == 0 }
		}
		if matches {
			return true
		}
	}
	return false
}

pub fn (requirement MacOSRequirement) minimum_version() homebrew.MacOSVersion {
	if requirement.comparator == '<=' || !requirement.version_specified() {
		return macos_oldest_allowed_version()
	}
	mut minimum := requirement.versions[0]
	for version in requirement.versions[1..] {
		if version.compare(minimum) < 0 {
			minimum = version
		}
	}
	return minimum
}

pub fn (requirement MacOSRequirement) maximum_version() homebrew.MacOSVersion {
	if requirement.comparator == '>=' || !requirement.version_specified() {
		return macos_newest_unsupported_version()
	}
	mut maximum := requirement.versions[0]
	for version in requirement.versions[1..] {
		if version.compare(maximum) > 0 {
			maximum = version
		}
	}
	return maximum
}

pub fn (requirement MacOSRequirement) allows(other homebrew.MacOSVersion) bool {
	if !requirement.version_specified() {
		return true
	}
	return match requirement.comparator {
		'>=' { other.compare(requirement.versions[0]) >= 0 }
		'<=' { other.compare(requirement.versions[0]) <= 0 }
		else { requirement.versions.any(it.compare(other) == 0) }
	}
}

pub fn (requirement MacOSRequirement) message(dependent_type string,
	running_on_macos bool) string {
	subject := if dependent_type == 'cask' { 'This cask' } else { 'This formula' }
	if !running_on_macos || !requirement.version_specified() {
		return '${subject} requires macOS.'
	}
	match requirement.comparator {
		'>=' {
			return '${subject} does not run on macOS versions older than ${requirement.versions[0].pretty_name()}.'
		}
		'<=' {
			if dependent_type == 'cask' {
				return '${subject} does not run on macOS versions newer than ${requirement.versions[0].pretty_name()}.'
			}
			return '${subject} either does not compile or function as expected on macOS\nversions newer than ${requirement.versions[0].pretty_name()} due to an upstream incompatibility.\n'
		}
		else {
			pretty_versions := requirement.versions.map(it.pretty_name())
			if pretty_versions.len > 1 {
				return '${subject} does not run on macOS versions other than ${pretty_versions[..pretty_versions.len - 1].join(', ')} and ${pretty_versions.last()}.'
			}
			return '${subject} does not run on macOS versions other than ${pretty_versions[0]}.'
		}
	}
}

pub fn (requirement MacOSRequirement) equals(other MacOSRequirement) bool {
	if requirement.comparator != other.comparator || requirement.tags != other.tags || requirement.versions.len != other.versions.len {
		return false
	}
	for index, version in requirement.versions {
		if version.compare(other.versions[index]) != 0 {
			return false
		}
	}
	return true
}

pub fn (requirement MacOSRequirement) hash_value() i64 {
	mut hash := u64(14695981039346656037)
	for character in '${requirement.comparator}\0${requirement.versions.map(it.str()).join('\0')}\0${requirement.tags.join('\0')}'.bytes() {
		hash = (hash ^ u64(character)) * u64(1099511628211)
	}
	return i64(hash)
}

pub fn (requirement MacOSRequirement) inspect() string {
	version_text := if requirement.versions.len > 1 {
		'[${requirement.versions.map(it.str()).join(', ')}]'
	} else if requirement.versions.len == 1 {
		requirement.versions[0].str()
	} else {
		''
	}
	return '#<MacOSRequirement: version${requirement.comparator}"${version_text}" ${requirement_tags_inspect(requirement.tags)}>'
}

pub fn (requirement MacOSRequirement) display_s() string {
	if !requirement.version_specified() {
		return 'macOS'
	}
	return 'macOS ${requirement.comparator} ${requirement.versions.map(it.str()).join(' / ')}'
}

pub fn (requirement MacOSRequirement) to_h() map[string][]string {
	if !requirement.version_specified() {
		return map[string][]string{}
	}
	return {
		requirement.comparator: requirement.versions.map(it.str())
	}
}

pub fn (requirement MacOSRequirement) to_json() string {
	return json2.encode(requirement.to_h())
}

// Ruby attr_reader `attr_reader :comparator` at line 16.
pub fn ruby_macos_requirement_l16_d1_comparator(requirement MacOSRequirement) string {
	return requirement.comparator
}

// Ruby attr_reader `attr_reader :version` at line 19.
pub fn ruby_macos_requirement_l19_d2_version(requirement MacOSRequirement) []homebrew.MacOSVersion {
	return requirement.versions.clone()
}

// Ruby method `self.parse(args, comparator:)` at line 32.
pub fn ruby_macos_requirement_l32_d3_self_parse(arguments []string,
	comparator string) !MacOSRequirement {
	return parse_macos_requirement(arguments, comparator)
}

// Ruby method `initialize(tags = [], comparator: ">=")` at line 60.
pub fn ruby_macos_requirement_l60_d4_initialize(tags []string,
	comparator string) !MacOSRequirement {
	return new_macos_requirement(tags, comparator)
}

// Ruby method `version_specified?` at line 93.
pub fn ruby_macos_requirement_l93_d5_version_specified(requirement MacOSRequirement) bool {
	return requirement.version_specified()
}

// Ruby method `macos_version_satisfied? = false` at line 103.
pub fn ruby_macos_requirement_l103_d6_macos_version_satisfied(requirement MacOSRequirement) bool {
	return requirement.macos_version_satisfied()
}

// Ruby method `minimum_version` at line 106.
pub fn ruby_macos_requirement_l106_d7_minimum_version(requirement MacOSRequirement) homebrew.MacOSVersion {
	return requirement.minimum_version()
}

// Ruby method `maximum_version` at line 114.
pub fn ruby_macos_requirement_l114_d8_maximum_version(requirement MacOSRequirement) homebrew.MacOSVersion {
	return requirement.maximum_version()
}

// Ruby method `allows?(other)` at line 122.
pub fn ruby_macos_requirement_l122_d9_allows(requirement MacOSRequirement,
	other homebrew.MacOSVersion) bool {
	return requirement.allows(other)
}

// Ruby method `message(type: :formula)` at line 137.
pub fn ruby_macos_requirement_l137_d10_message(requirement MacOSRequirement,
	dependent_type string) string {
	return requirement.message(dependent_type, brew_runtime.kernel_info().name == 'Darwin')
}

// Ruby method `==(other)` at line 143.
pub fn ruby_macos_requirement_l143_d11_anonymous(requirement MacOSRequirement,
	other MacOSRequirement) bool {
	return requirement.equals(other)
}

// Ruby alias `alias eql? ==` at line 146.
pub fn ruby_macos_requirement_l146_d12_eql(requirement MacOSRequirement,
	other MacOSRequirement) bool {
	return requirement.equals(other)
}

// Ruby method `hash` at line 149.
pub fn ruby_macos_requirement_l149_d13_hash(requirement MacOSRequirement) i64 {
	return requirement.hash_value()
}

// Ruby method `inspect` at line 154.
pub fn ruby_macos_requirement_l154_d14_inspect(requirement MacOSRequirement) string {
	return requirement.inspect()
}

// Ruby method `display_s` at line 159.
pub fn ruby_macos_requirement_l159_d15_display_s(requirement MacOSRequirement) string {
	return requirement.display_s()
}

// Ruby method `to_h` at line 172.
pub fn ruby_macos_requirement_l172_d16_to_h(requirement MacOSRequirement) map[string][]string {
	return requirement.to_h()
}

// Ruby method `to_json(options)` at line 182.
pub fn ruby_macos_requirement_l182_d17_to_json(requirement MacOSRequirement,
	_options string) string {
	return requirement.to_json()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "requirement"
// 5: require "utils/output"
// 6:
// 7: # A requirement on macOS.
// 8: class MacOSRequirement < Requirement
// 9:   extend Utils::Output::Mixin
// 10:
// 11:   Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 12:
// 13:   fatal true
// 14:
// 15:   sig { returns(String) }
// 16:   attr_reader :comparator
// 17:
// 18:   sig { returns(T.nilable(T.any(MacOSVersion, T::Array[MacOSVersion]))) }
// 19:   attr_reader :version
// 20:
// 21:   # Keep these around as empty arrays so we can keep the deprecation/disabling code the same.
// 22:   # Treat these like odeprecated/odisabled in terms of deprecation/disabling.
// 23:   DISABLED_MACOS_VERSIONS = [
// 24:     :mojave,
// 25:     :high_sierra,
// 26:     :sierra,
// 27:     :el_capitan,
// 28:   ].freeze
// 29:   DEPRECATED_MACOS_VERSIONS = T.let([].freeze, T::Array[Symbol])
// 30:
// 31:   sig { params(args: T::Array[T.any(String, Symbol)], comparator: String).returns(MacOSRequirement) }
// 32:   def self.parse(args, comparator:)
// 33:     first_arg = args.first
// 34:     first_arg_s = first_arg&.to_s
// 35:
// 36:     if first_arg == :any
// 37:       new
// 38:     elsif args.count > 1
// 39:       new([args], comparator: "==")
// 40:     elsif first_arg.is_a?(Symbol) && MacOSVersion::SYMBOLS.key?(first_arg)
// 41:       new([first_arg], comparator:)
// 42:     elsif (md = /^\s*(?<comparator><|>|[=<>]=)\s*:(?<version>\S+)\s*$/.match(first_arg_s))
// 43:       replacement = if md[:comparator] == "<="
// 44:         "`depends_on maximum_macos: :#{md[:version]}`"
// 45:       elsif md[:comparator] == ">="
// 46:         "`depends_on macos: :#{md[:version]}`"
// 47:       end
// 48:       odeprecated "string comparison format for `depends_on macos:`", replacement
// 49:       new([T.must(md[:version]).to_sym], comparator: T.must(md[:comparator]))
// 50:     elsif (md = /^\s*(?<comparator><|>|[=<>]=)\s*(?<version>\S+)\s*$/.match(first_arg_s))
// 51:       odeprecated "string comparison format for `depends_on macos:`"
// 52:       new([md[:version]], comparator: T.must(md[:comparator]))
// 53:     else
// 54:       odeprecated "strict symbol format for `depends_on macos:`"
// 55:       new([first_arg], comparator: "==")
// 56:     end
// 57:   end
// 58:
// 59:   sig { params(tags: T.untyped, comparator: String).void }
// 60:   def initialize(tags = [], comparator: ">=")
// 61:     @version = T.let(begin
// 62:       if comparator == "==" && tags.first.respond_to?(:map)
// 63:         tags.first.map { |s| MacOSVersion.from_symbol(s) }
// 64:       else
// 65:         MacOSVersion.from_symbol(tags.first) unless tags.empty?
// 66:       end
// 67:     rescue MacOSVersion::Error => e
// 68:       if DISABLED_MACOS_VERSIONS.include?(e.version)
// 69:         # This odisabled should stick around indefinitely.
// 70:         odisabled "`depends_on macos: :#{e.version}`"
// 71:       elsif DEPRECATED_MACOS_VERSIONS.include?(e.version)
// 72:         # This odeprecated should stick around indefinitely.
// 73:         odeprecated "`depends_on macos: :#{e.version}`"
// 74:       else
// 75:         raise
// 76:       end
// 77:
// 78:       # Array of versions: remove the bad ones and try again.
// 79:       if tags.first.respond_to?(:reject)
// 80:         tags = [tags.first.reject { |s| s == e.version }, tags[1..]]
// 81:         retry
// 82:       end
// 83:
// 84:       # Otherwise fallback to the oldest allowed if comparator is >=.
// 85:       MacOSVersion.new(HOMEBREW_MACOS_OLDEST_ALLOWED) if comparator == ">="
// 86:     end, T.nilable(T.any(MacOSVersion, T::Array[MacOSVersion])))
// 87:
// 88:     @comparator = comparator
// 89:     super(tags.drop(1))
// 90:   end
// 91:
// 92:   sig { returns(T::Boolean) }
// 93:   def version_specified?
// 94:     @version.present?
// 95:   end
// 96:
// 97:   satisfy(build_env: false) do
// 98:     T.bind(self, MacOSRequirement)
// 99:     macos_version_satisfied?
// 100:   end
// 101:
// 102:   sig { returns(T::Boolean) }
// 103:   def macos_version_satisfied? = false
// 104:
// 105:   sig { returns(T.nilable(MacOSVersion)) }
// 106:   def minimum_version
// 107:     return MacOSVersion.new(HOMEBREW_MACOS_OLDEST_ALLOWED) if @comparator == "<=" || !version_specified?
// 108:     return T.unsafe(@version).min if @version.respond_to?(:to_ary) || @version.is_a?(Array)
// 109:
// 110:     @version
// 111:   end
// 112:
// 113:   sig { returns(T.nilable(MacOSVersion)) }
// 114:   def maximum_version
// 115:     return MacOSVersion.new(HOMEBREW_MACOS_NEWEST_UNSUPPORTED) if @comparator == ">=" || !version_specified?
// 116:     return T.unsafe(@version).max if @version.respond_to?(:to_ary) || @version.is_a?(Array)
// 117:
// 118:     @version
// 119:   end
// 120:
// 121:   sig { params(other: MacOSVersion).returns(T::Boolean) }
// 122:   def allows?(other)
// 123:     return true unless version_specified?
// 124:
// 125:     version = @version
// 126:     case @comparator
// 127:     when ">=" then other >= T.cast(version, MacOSVersion)
// 128:     when "<=" then other <= T.cast(version, MacOSVersion)
// 129:     else
// 130:       return T.unsafe(version).include?(other) if version.respond_to?(:to_ary) || version.is_a?(Array)
// 131:
// 132:       version == other
// 133:     end
// 134:   end
// 135:
// 136:   sig { override.params(type: Symbol).returns(String) }
// 137:   def message(type: :formula)
// 138:     subject = (type == :cask) ? "This cask" : "This formula"
// 139:     "#{subject} requires macOS."
// 140:   end
// 141:
// 142:   sig { override.params(other: T.untyped).returns(T::Boolean) }
// 143:   def ==(other)
// 144:     super && comparator == other.comparator && version == other.version
// 145:   end
// 146:   alias eql? ==
// 147:
// 148:   sig { override.returns(Integer) }
// 149:   def hash
// 150:     [super, comparator, version].hash
// 151:   end
// 152:
// 153:   sig { returns(String) }
// 154:   def inspect
// 155:     "#<#{self.class.name}: version#{@comparator}#{@version.to_s.inspect} #{tags.inspect}>"
// 156:   end
// 157:
// 158:   sig { returns(String) }
// 159:   def display_s
// 160:     if version_specified?
// 161:       if @version.respond_to?(:to_ary) || @version.is_a?(Array)
// 162:         "macOS #{@comparator} #{T.unsafe(@version).join(" / ")}"
// 163:       else
// 164:         "macOS #{@comparator} #{@version}"
// 165:       end
// 166:     else
// 167:       "macOS"
// 168:     end
// 169:   end
// 170:
// 171:   sig { returns(T::Hash[String, T::Array[String]]) }
// 172:   def to_h
// 173:     return {} unless version_specified?
// 174:
// 175:     comp = @comparator.to_s
// 176:     return { comp => @version.map(&:to_s) } if @version.is_a?(Array)
// 177:
// 178:     { comp => [@version.to_s] }
// 179:   end
// 180:
// 181:   sig { params(options: T.untyped).returns(String) }
// 182:   def to_json(options)
// 183:     to_h.to_json(options)
// 184:   end
// 185: end
// 186:
// 187: require "extend/os/requirements/macos_requirement"
