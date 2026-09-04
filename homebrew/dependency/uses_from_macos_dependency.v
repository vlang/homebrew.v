module dependency

import ruby
import hash.fnv1a

// Translated from Homebrew/brew `dependency/uses_from_macos_dependency.rb`.

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
