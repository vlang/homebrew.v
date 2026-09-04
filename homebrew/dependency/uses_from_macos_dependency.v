module dependency

import ruby
import hash.fnv1a

// Translated from Homebrew/brew `dependency/uses_from_macos_dependency.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :bounds` at line 7.
pub fn ruby_uses_from_macos_dependency_l7_d1_bounds(args ...ruby.Value) ruby.Value {
	dependency := uses_from_macos_dependency_from_args(args) or { panic(err) }
	return uses_from_macos_bounds_value(dependency.bounds)
}

// Ruby method `initialize(name, tags = [], bounds:)` at line 10.
pub fn ruby_uses_from_macos_dependency_l10_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('UsesFromMacOSDependency requires a name')
	}
	mut tags := []string{}
	mut bounds_index := 2
	if args.len > 1 && args[1].type_name == 'Array' {
		tags = dependency_tags_from_value(args[1]) or { panic(err) }
	} else {
		bounds_index = 1
	}
	bounds := if args.len > bounds_index {
		uses_from_macos_bounds_from_value(args[bounds_index]) or { panic(err) }
	} else {
		map[string]string{}
	}
	return uses_from_macos_dependency_value(new_uses_from_macos_dependency(args[0].as_string(), tags, bounds))
}

// Ruby method `==(other)` at line 17.
pub fn ruby_uses_from_macos_dependency_l17_d3_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'UsesFromMacOSDependency' {
		return ruby.bool_value(false)
	}
	dependency := uses_from_macos_dependency_from_args(args) or { panic(err) }
	other := uses_from_macos_dependency_from_value(args[1]) or { panic(err) }
	return ruby.bool_value(dependency.equal(other))
}

// Ruby alias `alias eql? ==` at line 24.
pub fn ruby_uses_from_macos_dependency_l24_d4_eql(args ...ruby.Value) ruby.Value {
	return ruby_uses_from_macos_dependency_l17_d3_anonymous(...args)
}

// Ruby method `hash` at line 27.
pub fn ruby_uses_from_macos_dependency_l27_d5_hash(args ...ruby.Value) ruby.Value {
	dependency := uses_from_macos_dependency_from_args(args) or { panic(err) }
	return ruby.int_value(i64(dependency.hash_code()))
}

// Ruby method `installed?(minimum_version: nil, minimum_revision: nil, minimum_compatibility_version: nil,` at line 39.
pub fn ruby_uses_from_macos_dependency_l39_d6_installed(args ...ruby.Value) ruby.Value {
	dependency := uses_from_macos_dependency_from_args(args) or { panic(err) }
	context := uses_from_macos_context_from_args(args, 1)
	return ruby.bool_value(dependency.installed(context) or { panic(err) })
}

// Ruby method `use_macos_install?(bottle_os_version: nil)` at line 45.
pub fn ruby_uses_from_macos_dependency_l45_d7_use_macos_install(args ...ruby.Value) ruby.Value {
	dependency := uses_from_macos_dependency_from_args(args) or { panic(err) }
	context := uses_from_macos_context_from_args(args, 1)
	return ruby.bool_value(dependency.use_macos_install(context) or { panic(err) })
}

// Ruby method `uses_from_macos?` at line 81.
pub fn ruby_uses_from_macos_dependency_l81_d8_uses_from_macos(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Ruby method `dup_with_formula_name(formula)` at line 86.
pub fn ruby_uses_from_macos_dependency_l86_d9_dup_with_formula_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('dup_with_formula_name requires a formula')
	}
	dependency := uses_from_macos_dependency_from_args(args) or { panic(err) }
	full_name := args[1].attribute('full_name') or { args[1].as_string() }
	return uses_from_macos_dependency_value(dependency.dup_with_formula_name(full_name))
}

// Ruby method `inspect` at line 91.
pub fn ruby_uses_from_macos_dependency_l91_d10_inspect(args ...ruby.Value) ruby.Value {
	dependency := uses_from_macos_dependency_from_args(args) or { panic(err) }
	return ruby.string_value(dependency.inspect())
}

// UsesFromMacosDependency is the concrete V representation of the Ruby
// Dependency subclass. Symbol tags retain their leading colon at this boundary.
pub struct UsesFromMacosDependency {
pub:
	name   string
	tags   []string
	bounds map[string]string
}

// UsesFromMacosContext makes the two pieces of ambient Ruby state explicit:
// SimulateSystem's OS and the result of Dependency#installed?.
pub struct UsesFromMacosContext {
pub:
	simulating_or_running_on_macos bool
	current_os                     string
	bottle_os_version              string
	inherited_installed            bool
}

struct ComparableMacosVersion {
	components []int
	is_null    bool
}

pub fn new_uses_from_macos_dependency(name string, tags []string,
	bounds map[string]string) UsesFromMacosDependency {
	return UsesFromMacosDependency{
		name: name
		tags: tags.clone()
		bounds: bounds.clone()
	}
}

pub fn (dependency UsesFromMacosDependency) equal(other UsesFromMacosDependency) bool {
	return dependency.name == other.name && dependency.tags == other.tags
		&& dependency.bounds == other.bounds
}

fn (dependency UsesFromMacosDependency) identity_string() string {
	mut parts := ['${dependency.name.len}:${dependency.name}']
	for tag in dependency.tags {
		parts << '${tag.len}:${tag}'
	}
	mut bound_names := dependency.bounds.keys()
	bound_names.sort()
	for name in bound_names {
		value := dependency.bounds[name]
		parts << '${name.len}:${name}:${value.len}:${value}'
	}
	return parts.join('\x1f')
}

pub fn (dependency UsesFromMacosDependency) hash_code() u64 {
	return fnv1a.sum64_string(dependency.identity_string())
}

pub fn (dependency UsesFromMacosDependency) installed(context UsesFromMacosContext) !bool {
	return dependency.use_macos_install(context)! || context.inherited_installed
}

pub fn (dependency UsesFromMacosDependency) use_macos_install(context UsesFromMacosContext) !bool {
	// Check whether macOS is new enough for dependency to not be required.
	if context.simulating_or_running_on_macos {
		// If there's no since bound, the dependency is always available from macOS
		since_os_bounds := dependency.bounds['since'] or { return true }
		if since_os_bounds.trim_space() == '' {
			return true
		}

		// When installing a bottle built on an older macOS version, use that version
		// to determine if the dependency should come from macOS or Homebrew
		effective_os := if context.bottle_os_version != ''
			&& context.bottle_os_version.starts_with('macOS ') {
			// bottle_os_version is a string like "14" for Sonoma, "15" for Sequoia
			// Convert it to a MacOS version symbol for comparison
			new_comparable_macos_version(context.bottle_os_version.all_after('macOS '))!
		} else if context.current_os == 'macos' {
			// Assume the oldest macOS version when simulating a generic macOS version
			// Version::NULL is always treated as less than any other version.
			null_comparable_macos_version()
		} else {
			comparable_macos_version_from_symbol(context.current_os)!
		}

		// If we can't parse the bound, it means it's an unsupported macOS version
		// so let's default to the oldest possible macOS version
		since_os := comparable_macos_version_from_symbol(since_os_bounds) or {
			null_comparable_macos_version()
		}
		return effective_os.compare(since_os) >= 0
	}

	return false
}

pub fn (dependency UsesFromMacosDependency) uses_from_macos() bool {
	return true
}

pub fn (dependency UsesFromMacosDependency) dup_with_formula_name(full_name string) UsesFromMacosDependency {
	return new_uses_from_macos_dependency(full_name, dependency.tags, dependency.bounds)
}

fn ruby_inspect_string(value string) string {
	escaped := value.replace('\\', '\\\\').replace('"', '\\"')
	return '"${escaped}"'
}

fn ruby_inspect_tag(tag string) string {
	return if tag.starts_with(':') { tag } else { ruby_inspect_string(tag) }
}

fn (dependency UsesFromMacosDependency) bounds_inspect() string {
	mut names := dependency.bounds.keys()
	names.sort()
	mut entries := []string{cap: names.len}
	for name in names {
		value := dependency.bounds[name]
		entries << ':${name}=>:${value}'
	}
	return '{${entries.join(', ')}}'
}

pub fn (dependency UsesFromMacosDependency) inspect() string {
	tags := dependency.tags.map(ruby_inspect_tag(it)).join(', ')
	return '#<UsesFromMacOSDependency: ${ruby_inspect_string(dependency.name)} [${tags}] ${dependency.bounds_inspect()}>'
}

fn macos_symbol_versions() map[string]string {
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

fn null_comparable_macos_version() ComparableMacosVersion {
	return ComparableMacosVersion{
		is_null: true
	}
}

fn new_comparable_macos_version(value string) !ComparableMacosVersion {
	parts := value.split('.')
	if parts.len == 0 || parts.len > 3 || parts[0].len < 2 {
		return error('unknown or unsupported macOS version: "${value}"')
	}
	mut components := []int{cap: 3}
	for part in parts {
		if part == '' || !part.bytes().all(it >= `0` && it <= `9`) {
			return error('unknown or unsupported macOS version: "${value}"')
		}
		components << part.int()
	}
	for components.len < 3 {
		components << 0
	}
	return ComparableMacosVersion{
		components: components
	}
}

fn comparable_macos_version_from_symbol(symbol string) !ComparableMacosVersion {
	value := macos_symbol_versions()[symbol] or {
		return error('unknown or unsupported macOS version: :${symbol}')
	}
	return new_comparable_macos_version(value)
}

fn (version ComparableMacosVersion) compare(other ComparableMacosVersion) int {
	if version.is_null {
		return if other.is_null { 0 } else { -1 }
	}
	if other.is_null {
		return 1
	}
	for index in 0 .. 3 {
		if version.components[index] < other.components[index] {
			return -1
		}
		if version.components[index] > other.components[index] {
			return 1
		}
	}
	return 0
}

fn uses_from_macos_bounds_value(bounds map[string]string) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, value in bounds {
		values[name] = ruby.object_value('Symbol', value)
	}
	return ruby.map_value(values)
}

fn uses_from_macos_bounds_from_value(value ruby.Value) !map[string]string {
	values := value.as_map()!
	mut bounds := map[string]string{}
	for name, bound in values {
		bounds[name.trim_string_left(':')] = bound.as_string().trim_string_left(':')
	}
	return bounds
}

fn dependency_tags_from_value(value ruby.Value) ![]string {
	values := value.as_array()!
	return values.map(if it.type_name == 'Symbol' { ':${it.as_string()}' } else { it.as_string() })
}

fn uses_from_macos_dependency_value(dependency UsesFromMacosDependency) ruby.Value {
	mut tag_values := []ruby.Value{cap: dependency.tags.len}
	for tag in dependency.tags {
		tag_values << if tag.starts_with(':') {
			ruby.object_value('Symbol', tag.trim_string_left(':'))
		} else {
			ruby.string_value(tag)
		}
	}
	return ruby.Value{
		type_name: 'UsesFromMacOSDependency'
		repr: dependency.inspect()
		map_data: {
			'name':   ruby.string_value(dependency.name)
			'tags':   ruby.array_value(tag_values)
			'bounds': uses_from_macos_bounds_value(dependency.bounds)
		}
	}
}

fn uses_from_macos_dependency_from_value(value ruby.Value) !UsesFromMacosDependency {
	if value.type_name != 'UsesFromMacOSDependency' {
		return error('expected UsesFromMacOSDependency, got ${value.type_name}')
	}
	name_value := value.map_data['name'] or { return error('dependency has no name') }
	tags_value := value.map_data['tags'] or { return error('dependency has no tags') }
	bounds_value := value.map_data['bounds'] or { return error('dependency has no bounds') }
	return new_uses_from_macos_dependency(name_value.as_string(), dependency_tags_from_value(tags_value)!, uses_from_macos_bounds_from_value(bounds_value)!)
}

fn uses_from_macos_dependency_from_args(args []ruby.Value) !UsesFromMacosDependency {
	if args.len == 0 {
		return error('missing UsesFromMacOSDependency receiver')
	}
	return uses_from_macos_dependency_from_value(args[0])
}

// Generic adapters pass bottle_os_version, the inherited installed? result,
// SimulateSystem's macOS predicate, and current_os after the receiver.
fn uses_from_macos_context_from_args(args []ruby.Value, offset int) UsesFromMacosContext {
	return UsesFromMacosContext{
		bottle_os_version: if args.len > offset { args[offset].as_string() } else { '' }
		inherited_installed: if args.len > offset + 1 {
			args[offset + 1].as_bool() or { false }
		} else {
			false
		}
		simulating_or_running_on_macos: if args.len > offset + 2 {
			args[offset + 2].as_bool() or { false }
		} else {
			false
		}
		current_os: if args.len > offset + 3 { args[offset + 3].as_string() } else { 'linux' }
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A dependency that's marked as "installed" on macOS
// 5: class UsesFromMacOSDependency < Dependency
// 6:   sig { returns(T::Hash[Symbol, Symbol]) }
// 7:   attr_reader :bounds
// 8:
// 9:   sig { params(name: String, tags: T::Array[T.any(String, Symbol, T::Array[T.untyped])], bounds: T::Hash[Symbol, Symbol]).void }
// 10:   def initialize(name, tags = [], bounds:)
// 11:     super(name, tags)
// 12:
// 13:     @bounds = bounds
// 14:   end
// 15:
// 16:   sig { override.params(other: BasicObject).returns(T::Boolean) }
// 17:   def ==(other)
// 18:     case other
// 19:     when UsesFromMacOSDependency
// 20:       name == other.name && tags == other.tags && bounds == other.bounds
// 21:     else false
// 22:     end
// 23:   end
// 24:   alias eql? ==
// 25:
// 26:   sig { override.returns(Integer) }
// 27:   def hash
// 28:     [name, tags, bounds].hash
// 29:   end
// 30:
// 31:   sig {
// 32:     params(
// 33:       minimum_version:               T.nilable(Version),
// 34:       minimum_revision:              T.nilable(Integer),
// 35:       minimum_compatibility_version: T.nilable(Integer),
// 36:       bottle_os_version:             T.nilable(String),
// 37:     ).returns(T::Boolean)
// 38:   }
// 39:   def installed?(minimum_version: nil, minimum_revision: nil, minimum_compatibility_version: nil,
// 40:                  bottle_os_version: nil)
// 41:     use_macos_install?(bottle_os_version:) || super
// 42:   end
// 43:
// 44:   sig { params(bottle_os_version: T.nilable(String)).returns(T::Boolean) }
// 45:   def use_macos_install?(bottle_os_version: nil)
// 46:     # Check whether macOS is new enough for dependency to not be required.
// 47:     if Homebrew::SimulateSystem.simulating_or_running_on_macos?
// 48:       # If there's no since bound, the dependency is always available from macOS
// 49:       since_os_bounds = bounds[:since]
// 50:       return true if since_os_bounds.blank?
// 51:
// 52:       # When installing a bottle built on an older macOS version, use that version
// 53:       # to determine if the dependency should come from macOS or Homebrew
// 54:       effective_os = if bottle_os_version.present? &&
// 55:                         bottle_os_version.start_with?("macOS ")
// 56:         # bottle_os_version is a string like "14" for Sonoma, "15" for Sequoia
// 57:         # Convert it to a MacOS version symbol for comparison
// 58:         MacOSVersion.new(bottle_os_version.delete_prefix("macOS "))
// 59:       elsif Homebrew::SimulateSystem.current_os == :macos
// 60:         # Assume the oldest macOS version when simulating a generic macOS version
// 61:         # Version::NULL is always treated as less than any other version.
// 62:         Version::NULL
// 63:       else
// 64:         MacOSVersion.from_symbol(Homebrew::SimulateSystem.current_os)
// 65:       end
// 66:
// 67:       since_os = begin
// 68:         MacOSVersion.from_symbol(since_os_bounds)
// 69:       rescue MacOSVersion::Error
// 70:         # If we can't parse the bound, it means it's an unsupported macOS version
// 71:         # so let's default to the oldest possible macOS version
// 72:         Version::NULL
// 73:       end
// 74:       return true if effective_os >= since_os
// 75:     end
// 76:
// 77:     false
// 78:   end
// 79:
// 80:   sig { override.returns(T::Boolean) }
// 81:   def uses_from_macos?
// 82:     true
// 83:   end
// 84:
// 85:   sig { override.params(formula: Formula).returns(T.self_type) }
// 86:   def dup_with_formula_name(formula)
// 87:     self.class.new(formula.full_name.to_s, tags, bounds:)
// 88:   end
// 89:
// 90:   sig { returns(String) }
// 91:   def inspect
// 92:     "#<#{self.class.name}: #{name.inspect} #{tags.inspect} #{bounds.inspect}>"
// 93:   end
// 94: end
