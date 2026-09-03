module homebrew

import brew_runtime

pub struct CollectorRequirement {
pub:
	name string
	tags []string
}

pub struct CollectorResource {
pub:
	url      string
	strategy string
}

pub struct DependencyCollectorState {
pub:
	macos           bool
	available_tools map[string]bool
pub mut:
	deps         []Dependency
	requirements []CollectorRequirement
	frozen       bool
}

pub enum CollectorResultKind {
	nil_value
	dependency
	requirement
	dependencies
}

pub struct CollectorResult {
pub:
	kind         CollectorResultKind
	dependency   Dependency
	requirement  CollectorRequirement
	dependencies []Dependency
}

pub fn new_dependency_collector(macos bool, available_tools map[string]bool) &DependencyCollectorState {
	return &DependencyCollectorState{ macos: macos, available_tools: available_tools.clone() }
}

fn collector_tags(tags []string) []string {
	return tags.clone()
}

fn collector_implicit_dependency(name string, tags []string) Dependency {
	mut values := collector_tags(tags)
	values << ':implicit'
	return new_dependency(name, values)
}

fn (collector DependencyCollectorState) tool_available(name string) bool {
	if name in collector.available_tools {
		return collector.available_tools[name]
	}
	brew_runtime.find_executable(name) or { return false }
	return true
}

pub fn (collector DependencyCollectorState) git_dep_if_needed(tags []string) ?Dependency {
	if collector.macos || collector.tool_available('git') {
		return none
	}
	return collector_implicit_dependency('git', tags)
}

pub fn (collector DependencyCollectorState) subversion_dep_if_needed(tags []string) ?Dependency {
	if !collector.macos && collector.tool_available('svn') {
		return none
	}
	return collector_implicit_dependency('subversion', tags)
}

pub fn (collector DependencyCollectorState) cvs_dep_if_needed(tags []string) ?Dependency {
	if !collector.macos && collector.tool_available('cvs') {
		return none
	}
	return collector_implicit_dependency('cvs', tags)
}

pub fn (collector DependencyCollectorState) archive_dep_if_needed(name string,
	tags []string) ?Dependency {
	if collector.macos && name in ['xz', 'unzip', 'bzip2'] {
		return none
	}
	if collector.tool_available(name) {
		return none
	}
	return collector_implicit_dependency(name, tags)
}

pub fn collector_parse_url(mut collector DependencyCollectorState, url string,
	tags []string) ?Dependency {
	path := url.split('?')[0]
	if path.ends_with('.xz') {
		return collector.archive_dep_if_needed('xz', tags)
	}
	if path.ends_with('.zst') {
		return collector.archive_dep_if_needed('zstd', tags)
	}
	if path.ends_with('.zip') {
		return collector.archive_dep_if_needed('unzip', tags)
	}
	if path.ends_with('.bz2') {
		return collector.archive_dep_if_needed('bzip2', tags)
	}
	if path.ends_with('.lha') || path.ends_with('.lzh') {
		return collector_implicit_dependency('lha', tags)
	}
	if path.ends_with('.lz') {
		return collector_implicit_dependency('lzip', tags)
	}
	if path.ends_with('.rar') {
		return collector_implicit_dependency('libarchive', tags)
	}
	if path.ends_with('.7z') {
		return collector_implicit_dependency('p7zip', tags)
	}
	return none
}

pub fn collector_resource_dependency(mut collector DependencyCollectorState,
	resource CollectorResource, tags []string) !CollectorResult {
	mut combined := tags.clone()
	combined << ':build'
	combined << ':test'
	return match resource.strategy {
		'', 'curl' {
			if dependency := collector_parse_url(mut collector, resource.url, combined) {
				CollectorResult{ kind: .dependency, dependency: dependency }
			} else {
				CollectorResult{}
			}
		}
		'homebrew_curl' {
			mut dependencies := []Dependency{}
			dependencies << collector_implicit_dependency('curl', combined)
			if dependency := collector_parse_url(mut collector, resource.url, combined) {
				dependencies << dependency
			}
			CollectorResult{ kind: .dependencies, dependencies: dependencies }
		}
		'no_unzip' { CollectorResult{} }
		'git' {
			if dependency := collector.git_dep_if_needed(combined) {
				CollectorResult{ kind: .dependency, dependency: dependency }
			} else {
				CollectorResult{}
			}
		}
		'subversion' {
			if dependency := collector.subversion_dep_if_needed(combined) {
				CollectorResult{ kind: .dependency, dependency: dependency }
			} else {
				CollectorResult{}
			}
		}
		'mercurial' {
			CollectorResult{ kind: .dependency, dependency: collector_implicit_dependency('mercurial', combined) }
		}
		'fossil' {
			CollectorResult{ kind: .dependency, dependency: collector_implicit_dependency('fossil', combined) }
		}
		'bazaar' {
			CollectorResult{ kind: .dependency, dependency: collector_implicit_dependency('breezy', combined) }
		}
		'cvs' {
			if dependency := collector.cvs_dep_if_needed(combined) {
				CollectorResult{ kind: .dependency, dependency: dependency }
			} else {
				CollectorResult{}
			}
		}
		'custom' { CollectorResult{} }
		else {
			return error('${resource.strategy} is not an AbstractDownloadStrategy subclass')
		}
	}
}

pub fn collector_parse_symbol(name string, tags []string) !CollectorRequirement {
	if name !in ['arch', 'linux', 'macos', 'maximum_macos', 'xcode'] {
		return error('Unsupported special dependency: :${name}')
	}
	return CollectorRequirement{ name: name, tags: tags.clone() }
}

pub fn collector_parse_class_spec(name string, requirement_subclass bool,
	tags []string) !CollectorRequirement {
	if !requirement_subclass {
		return error('${name} is not a Requirement subclass')
	}
	return CollectorRequirement{ name: name, tags: tags.clone() }
}

fn collector_append_requirement(mut collector DependencyCollectorState,
	requirement CollectorRequirement) {
	if !collector.requirements.any(it.name == requirement.name && it.tags == requirement.tags) {
		collector.requirements << requirement
	}
}

pub fn collector_add_dependency(mut collector DependencyCollectorState, name string,
	tags []string) !CollectorResult {
	if ':implicit' in tags {
		return error('Implicit dependencies cannot be manually specified')
	}
	dependency := new_dependency(name, tags)
	collector.deps << dependency
	return CollectorResult{ kind: .dependency, dependency: dependency }
}

pub fn collector_add_requirement(mut collector DependencyCollectorState, name string,
	tags []string) !CollectorResult {
	if ':implicit' in tags {
		return error('Implicit dependencies cannot be manually specified')
	}
	requirement := collector_parse_symbol(name, tags)!
	collector_append_requirement(mut collector, requirement)
	return CollectorResult{ kind: .requirement, requirement: requirement }
}

pub fn collector_add_resource(mut collector DependencyCollectorState,
	resource CollectorResource, tags []string) !CollectorResult {
	result := collector_resource_dependency(mut collector, resource, tags)!
	match result.kind {
		.dependency { collector.deps << result.dependency }
		.dependencies { collector.deps << result.dependencies }
		else {}
	}
	return result
}

pub fn dependency_collector_value(collector &DependencyCollectorState) brew_runtime.Value {
	return brew_runtime.structured_value('DependencyCollector', 'DependencyCollector', {
		'collector_address': u64(voidptr(collector)).str()
	})
}

fn dependency_collector_from_value(value brew_runtime.Value) &DependencyCollectorState {
	address := value.attributes['collector_address'] or { panic('invalid DependencyCollector') }
	return unsafe { &DependencyCollectorState(voidptr(address.u64())) }
}

fn collector_requirement_value(requirement CollectorRequirement) brew_runtime.Value {
	return brew_runtime.structured_value('${requirement.name.capitalize()}Requirement', requirement.name, {
		'name': requirement.name
		'tags': requirement.tags.join(',')
	})
}

fn collector_result_value(result CollectorResult) brew_runtime.Value {
	return match result.kind {
		.nil_value { brew_runtime.object_value('NilClass', 'nil') }
		.dependency { dependency_boundary_value(result.dependency) }
		.requirement { collector_requirement_value(result.requirement) }
		.dependencies { dependency_list_boundary_value(result.dependencies) }
	}
}

fn collector_tags_from_value(value brew_runtime.Value) []string {
	if value.type_name == 'Array' {
		return value.as_array() or { [] }.map(it.as_string())
	}
	if value.type_name in ['String', 'Symbol'] {
		return [value.as_string()]
	}
	return []string{}
}

fn collector_from_boundary_args(args []brew_runtime.Value) (&DependencyCollectorState, int) {
	if args.len > 0 && args[0].type_name == 'DependencyCollector' {
		return dependency_collector_from_value(args[0]), 1
	}
	return new_dependency_collector(false, map[string]bool{}), 0
}

fn collector_build_boundary(mut collector DependencyCollectorState,
	spec brew_runtime.Value) !CollectorResult {
	if spec.type_name == 'Hash' {
		keys := spec.map_data.keys()
		if keys.len == 0 {
			return CollectorResult{}
		}
		name := keys[0]
		return collector_add_dependency_without_store(name, collector_tags_from_value(spec.map_data[name]))
	}
	if spec.type_name == 'Resource' {
		return collector_resource_dependency(mut collector, CollectorResource{
			url: spec.attributes['url'] or { '' }
			strategy: spec.attributes['strategy'] or { '' }
		}, []string{})
	}
	if spec.type_name == 'Symbol' {
		requirement := collector_parse_symbol(spec.as_string().trim_string_left(':'), []string{})!
		return CollectorResult{ kind: .requirement, requirement: requirement }
	}
	if spec.type_name == 'Dependency' {
		return CollectorResult{ kind: .dependency, dependency: dependency_from_boundary(spec) }
	}
	if spec.type_name.ends_with('Requirement') {
		return CollectorResult{
			kind: .requirement
			requirement: CollectorRequirement{
				name: spec.attributes['name'] or { spec.as_string() }
				tags: (spec.attributes['tags'] or { '' }).split(',').filter(it != '')
			}
		}
	}
	if spec.type_name == 'Class' {
		name := spec.attributes['requirement_name'] or {
			return error('${spec.as_string()} is not a Requirement subclass')
		}
		return CollectorResult{ kind: .requirement, requirement: CollectorRequirement{ name: name } }
	}
	if spec.type_name == 'String' {
		return collector_add_dependency_without_store(spec.as_string(), []string{})
	}
	return CollectorResult{}
}

fn collector_add_dependency_without_store(name string, tags []string) CollectorResult {
	return CollectorResult{ kind: .dependency, dependency: new_dependency(name, tags) }
}

fn collector_store_result(mut collector DependencyCollectorState, result CollectorResult) {
	match result.kind {
		.dependency { collector.deps << result.dependency }
		.dependencies { collector.deps << result.dependencies }
		.requirement { collector_append_requirement(mut collector, result.requirement) }
		else {}
	}
}

// Translated from Homebrew/brew `dependency_collector.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :deps` at line 27.
pub fn ruby_dependency_collector_l27_d1_deps(args ...brew_runtime.Value) brew_runtime.Value {
	collector, _ := collector_from_boundary_args(args)
	return dependency_list_boundary_value(collector.deps)
}

// Ruby attr_reader `attr_reader :requirements` at line 30.
pub fn ruby_dependency_collector_l30_d2_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	collector, _ := collector_from_boundary_args(args)
	return brew_runtime.array_value(collector.requirements.map(collector_requirement_value(it)))
}

// Ruby method `initialize` at line 33.
pub fn ruby_dependency_collector_l33_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	macos := if args.len > 0 { args[0].as_bool() or { false } } else { false }
	return dependency_collector_value(new_dependency_collector(macos, map[string]bool{}))
}

// Ruby method `initialize_dup(other)` at line 42.
pub fn ruby_dependency_collector_l42_d4_initialize_dup(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('initialize_dup requires a collector') }
	other := dependency_collector_from_value(args[0])
	mut duplicate := new_dependency_collector(other.macos, other.available_tools)
	duplicate.deps = other.deps.clone()
	duplicate.requirements = other.requirements.clone()
	return dependency_collector_value(duplicate)
}

// Ruby method `freeze` at line 49.
pub fn ruby_dependency_collector_l49_d5_freeze(args ...brew_runtime.Value) brew_runtime.Value {
	mut collector, _ := collector_from_boundary_args(args)
	collector.frozen = true
	return dependency_collector_value(collector)
}

// Ruby method `add(spec)` at line 56.
pub fn ruby_dependency_collector_l56_d6_add(args ...brew_runtime.Value) brew_runtime.Value {
	mut collector, offset := collector_from_boundary_args(args)
	if args.len <= offset { panic('add requires a specification') }
	result := collector_build_boundary(mut collector, args[offset]) or { panic(err) }
	collector_store_result(mut collector, result)
	return collector_result_value(result)
}

// Ruby method `fetch(spec)` at line 74.
pub fn ruby_dependency_collector_l74_d7_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	mut collector, offset := collector_from_boundary_args(args)
	if args.len <= offset { panic('fetch requires a specification') }
	return collector_result_value(collector_build_boundary(mut collector, args[offset]) or {
		panic(err)
	})
}

// Ruby method `cache_key(spec)` at line 79.
pub fn ruby_dependency_collector_l79_d8_cache_key(args ...brew_runtime.Value) brew_runtime.Value {
	_, offset := collector_from_boundary_args(args)
	if args.len <= offset { panic('cache_key requires a specification') }
	spec := args[offset]
	if spec.type_name == 'Resource' {
		strategy := spec.attributes['strategy'] or { '' }
		url := (spec.attributes['url'] or { '' }).split('?')[0]
		extension := if dot := url.last_index('.') { url[dot..] } else { '' }
		return brew_runtime.string_value(if strategy in ['', 'curl', 'homebrew_curl', 'no_unzip'] {
			'${strategy}${extension}'
		} else {
			strategy
		})
	}
	return spec
}

// Ruby method `build(spec)` at line 91.
pub fn ruby_dependency_collector_l91_d9_build(args ...brew_runtime.Value) brew_runtime.Value {
	mut collector, offset := collector_from_boundary_args(args)
	if args.len <= offset { panic('build requires a specification') }
	return collector_result_value(collector_build_boundary(mut collector, args[offset]) or {
		panic(err)
	})
}

// Ruby method `gcc_dep_if_needed(related_formula_names); end` at line 97.
pub fn ruby_dependency_collector_l97_d10_gcc_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `glibc_dep_if_needed(related_formula_names); end` at line 100.
pub fn ruby_dependency_collector_l100_d11_glibc_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `implicit_dependency_names` at line 105.
pub fn ruby_dependency_collector_l105_d12_implicit_dependency_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value([]string{})
}

// Ruby method `git_dep_if_needed(tags)` at line 113.
pub fn ruby_dependency_collector_l113_d13_git_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	collector, offset := collector_from_boundary_args(args)
	tags := if args.len > offset { collector_tags_from_value(args[offset]) } else { []string{} }
	if dependency := collector.git_dep_if_needed(tags) {
		return dependency_boundary_value(dependency)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `curl_dep_if_needed(tags)` at line 121.
pub fn ruby_dependency_collector_l121_d14_curl_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	_, offset := collector_from_boundary_args(args)
	tags := if args.len > offset { collector_tags_from_value(args[offset]) } else { []string{} }
	return dependency_boundary_value(collector_implicit_dependency('curl', tags))
}

// Ruby method `subversion_dep_if_needed(tags)` at line 126.
pub fn ruby_dependency_collector_l126_d15_subversion_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	collector, offset := collector_from_boundary_args(args)
	tags := if args.len > offset { collector_tags_from_value(args[offset]) } else { []string{} }
	if dependency := collector.subversion_dep_if_needed(tags) {
		return dependency_boundary_value(dependency)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `cvs_dep_if_needed(tags)` at line 134.
pub fn ruby_dependency_collector_l134_d16_cvs_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	collector, offset := collector_from_boundary_args(args)
	tags := if args.len > offset { collector_tags_from_value(args[offset]) } else { []string{} }
	if dependency := collector.cvs_dep_if_needed(tags) {
		return dependency_boundary_value(dependency)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `xz_dep_if_needed(tags)` at line 139.
pub fn ruby_dependency_collector_l139_d17_xz_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	collector, offset := collector_from_boundary_args(args)
	tags := if args.len > offset { collector_tags_from_value(args[offset]) } else { []string{} }
	if dependency := collector.archive_dep_if_needed('xz', tags) {
		return dependency_boundary_value(dependency)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `zstd_dep_if_needed(tags)` at line 144.
pub fn ruby_dependency_collector_l144_d18_zstd_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	collector, offset := collector_from_boundary_args(args)
	tags := if args.len > offset { collector_tags_from_value(args[offset]) } else { []string{} }
	if dependency := collector.archive_dep_if_needed('zstd', tags) {
		return dependency_boundary_value(dependency)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `unzip_dep_if_needed(tags)` at line 149.
pub fn ruby_dependency_collector_l149_d19_unzip_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	collector, offset := collector_from_boundary_args(args)
	tags := if args.len > offset { collector_tags_from_value(args[offset]) } else { []string{} }
	if dependency := collector.archive_dep_if_needed('unzip', tags) {
		return dependency_boundary_value(dependency)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `bzip2_dep_if_needed(tags)` at line 154.
pub fn ruby_dependency_collector_l154_d20_bzip2_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	collector, offset := collector_from_boundary_args(args)
	tags := if args.len > offset { collector_tags_from_value(args[offset]) } else { []string{} }
	if dependency := collector.archive_dep_if_needed('bzip2', tags) {
		return dependency_boundary_value(dependency)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.tar_needs_xz_dependency?` at line 159.
pub fn ruby_dependency_collector_l159_d21_self_tar_needs_xz_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	collector := new_dependency_collector(false, {
		'xz': false
	})
	return brew_runtime.bool_value(collector.archive_dep_if_needed('xz', []string{}) != none)
}

// Ruby method `self.tar_needs_bzip2_dependency?` at line 164.
pub fn ruby_dependency_collector_l164_d22_self_tar_needs_bzip2_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	collector := new_dependency_collector(false, {
		'bzip2': false
	})
	return brew_runtime.bool_value(collector.archive_dep_if_needed('bzip2', []string{}) != none)
}

// Ruby method `init_global_dep_tree_if_needed!; end` at line 171.
pub fn ruby_dependency_collector_l171_d23_init_global_dep_tree_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `parse_spec(spec, tags)` at line 177.
pub fn ruby_dependency_collector_l177_d24_parse_spec(args ...brew_runtime.Value) brew_runtime.Value {
	mut collector, offset := collector_from_boundary_args(args)
	if args.len <= offset { panic('parse_spec requires a specification') }
	return collector_result_value(collector_build_boundary(mut collector, args[offset]) or {
		panic(err)
	})
}

// Ruby method `parse_string_spec(spec, tags)` at line 195.
pub fn ruby_dependency_collector_l195_d25_parse_string_spec(args ...brew_runtime.Value) brew_runtime.Value {
	_, offset := collector_from_boundary_args(args)
	if args.len <= offset { panic('parse_string_spec requires a name') }
	tags := if args.len > offset + 1 {
		collector_tags_from_value(args[offset + 1])
	} else {
		[]string{}
	}
	return dependency_boundary_value(new_dependency(args[offset].as_string(), tags))
}

// Ruby method `parse_symbol_spec(spec, tags)` at line 200.
pub fn ruby_dependency_collector_l200_d26_parse_symbol_spec(args ...brew_runtime.Value) brew_runtime.Value {
	_, offset := collector_from_boundary_args(args)
	if args.len <= offset { panic('parse_symbol_spec requires a symbol') }
	tags := if args.len > offset + 1 {
		collector_tags_from_value(args[offset + 1])
	} else {
		[]string{}
	}
	return collector_requirement_value(collector_parse_symbol(args[offset].as_string().trim_string_left(':'), tags) or { panic(err) })
}

// Ruby method `parse_class_spec(spec, tags)` at line 215.
pub fn ruby_dependency_collector_l215_d27_parse_class_spec(args ...brew_runtime.Value) brew_runtime.Value {
	_, offset := collector_from_boundary_args(args)
	if args.len <= offset { panic('parse_class_spec requires a class') }
	name := args[offset].attributes['requirement_name'] or {
		panic('${args[offset].as_string()} is not a Requirement subclass')
	}
	tags := if args.len > offset + 1 {
		collector_tags_from_value(args[offset + 1])
	} else {
		[]string{}
	}
	return collector_requirement_value(CollectorRequirement{ name: name, tags: tags })
}

// Ruby method `resource_dep(spec, tags)` at line 222.
pub fn ruby_dependency_collector_l222_d28_resource_dep(args ...brew_runtime.Value) brew_runtime.Value {
	mut collector, offset := collector_from_boundary_args(args)
	if args.len <= offset { panic('resource_dep requires a resource') }
	spec := args[offset]
	tags := if args.len > offset + 1 {
		collector_tags_from_value(args[offset + 1])
	} else {
		[]string{}
	}
	return collector_result_value(collector_resource_dependency(mut collector, CollectorResource{
		url: spec.attributes['url'] or { '' }
		strategy: spec.attributes['strategy'] or { '' }
	}, tags) or { panic(err) })
}

// Ruby method `parse_url_spec(url, tags)` at line 253.
pub fn ruby_dependency_collector_l253_d29_parse_url_spec(args ...brew_runtime.Value) brew_runtime.Value {
	mut collector, offset := collector_from_boundary_args(args)
	if args.len <= offset { panic('parse_url_spec requires a URL') }
	tags := if args.len > offset + 1 {
		collector_tags_from_value(args[offset + 1])
	} else {
		[]string{}
	}
	if dependency := collector_parse_url(mut collector, args[offset].as_string(), tags) {
		return dependency_boundary_value(dependency)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependency"
// 5: require "dependencies"
// 6: require "requirement"
// 7: require "requirements"
// 8: require "cachable"
// 9:
// 10: # A dependency is a formula that another formula needs to install.
// 11: # A requirement is something other than a formula that another formula
// 12: # needs to be present. This includes external language modules,
// 13: # command-line tools in the path, or any arbitrary predicate.
// 14: #
// 15: # The `depends_on` method in the formula DSL is used to declare
// 16: # dependencies and requirements.
// 17:
// 18: # This class is used by `depends_on` in the formula DSL to turn dependency
// 19: # specifications into the proper kinds of dependencies and requirements.
// 20: class DependencyCollector
// 21:   extend T::Generic
// 22:   extend Cachable
// 23:
// 24:   Cache = type_template { { fixed: T::Hash[T.untyped, T.untyped] } }
// 25:
// 26:   sig { returns(Dependencies) }
// 27:   attr_reader :deps
// 28:
// 29:   sig { returns(Requirements) }
// 30:   attr_reader :requirements
// 31:
// 32:   sig { void }
// 33:   def initialize
// 34:     # Ensure this is synced with `initialize_dup` and `freeze` (excluding simple objects like integers and booleans)
// 35:     @deps = T.let(Dependencies.new, Dependencies)
// 36:     @requirements = T.let(Requirements.new, Requirements)
// 37:
// 38:     init_global_dep_tree_if_needed!
// 39:   end
// 40:
// 41:   sig { override.params(other: DependencyCollector).void }
// 42:   def initialize_dup(other)
// 43:     super
// 44:     @deps = @deps.dup
// 45:     @requirements = @requirements.dup
// 46:   end
// 47:
// 48:   sig { void }
// 49:   def freeze
// 50:     @deps.freeze
// 51:     @requirements.freeze
// 52:     super
// 53:   end
// 54:
// 55:   sig { params(spec: T.untyped).returns(T.untyped) }
// 56:   def add(spec)
// 57:     case dep = fetch(spec)
// 58:     when Array
// 59:       dep.compact.each { |dep| @deps << dep }
// 60:     when Dependency
// 61:       @deps << dep
// 62:     when Requirement
// 63:       @requirements << dep
// 64:     when nil
// 65:       # no-op when we have a nil value
// 66:       nil
// 67:     else
// 68:       raise ArgumentError, "DependencyCollector#add passed something that isn't a Dependency or Requirement!"
// 69:     end
// 70:     dep
// 71:   end
// 72:
// 73:   sig { params(spec: T.untyped).returns(T.untyped) }
// 74:   def fetch(spec)
// 75:     self.class.cache.fetch(cache_key(spec)) { |key| self.class.cache[key] = build(spec) }
// 76:   end
// 77:
// 78:   sig { params(spec: T.untyped).returns(T.untyped) }
// 79:   def cache_key(spec)
// 80:     if spec.is_a?(Resource)
// 81:       if spec.download_strategy <= CurlDownloadStrategy
// 82:         return "#{spec.download_strategy}#{File.extname(T.must(spec.url)).split("?").first}"
// 83:       end
// 84:
// 85:       return spec.download_strategy
// 86:     end
// 87:     spec
// 88:   end
// 89:
// 90:   sig { params(spec: T.untyped).returns(T.untyped) }
// 91:   def build(spec)
// 92:     spec, tags = spec.is_a?(Hash) ? spec.first : spec
// 93:     parse_spec(spec, Array(tags))
// 94:   end
// 95:
// 96:   sig { params(related_formula_names: T::Set[String]).returns(T.nilable(Dependency)) }
// 97:   def gcc_dep_if_needed(related_formula_names); end
// 98:
// 99:   sig { params(related_formula_names: T::Set[String]).returns(T.nilable(Dependency)) }
// 100:   def glibc_dep_if_needed(related_formula_names); end
// 101:
// 102:   # Names implicitly added to any formula's deps right now, reusing the same checks
// 103:   # `Formula#add_global_deps_to_spec` uses to inject them onto a real formula.
// 104:   sig { returns(T::Set[String]) }
// 105:   def implicit_dependency_names
// 106:     [
// 107:       gcc_dep_if_needed(Set.new),
// 108:       glibc_dep_if_needed(Set.new),
// 109:     ].compact.to_set(&:name)
// 110:   end
// 111:
// 112:   sig { params(tags: T::Array[T.any(String, Symbol)]).returns(T.nilable(Dependency)) }
// 113:   def git_dep_if_needed(tags)
// 114:     require "utils/git"
// 115:     return if Utils::Git.available?
// 116:
// 117:     Dependency.new("git", [*tags, :implicit])
// 118:   end
// 119:
// 120:   sig { params(tags: T::Array[T.any(String, Symbol)]).returns(Dependency) }
// 121:   def curl_dep_if_needed(tags)
// 122:     Dependency.new("curl", [*tags, :implicit])
// 123:   end
// 124:
// 125:   sig { params(tags: T::Array[T.any(String, Symbol)]).returns(T.nilable(Dependency)) }
// 126:   def subversion_dep_if_needed(tags)
// 127:     require "utils/svn"
// 128:     return if Utils::Svn.available?
// 129:
// 130:     Dependency.new("subversion", [*tags, :implicit])
// 131:   end
// 132:
// 133:   sig { params(tags: T::Array[T.any(String, Symbol)]).returns(T.nilable(Dependency)) }
// 134:   def cvs_dep_if_needed(tags)
// 135:     Dependency.new("cvs", [*tags, :implicit]) unless which("cvs")
// 136:   end
// 137:
// 138:   sig { params(tags: T::Array[T.any(String, Symbol)]).returns(T.nilable(Dependency)) }
// 139:   def xz_dep_if_needed(tags)
// 140:     Dependency.new("xz", [*tags, :implicit]) unless which("xz")
// 141:   end
// 142:
// 143:   sig { params(tags: T::Array[T.any(String, Symbol)]).returns(T.nilable(Dependency)) }
// 144:   def zstd_dep_if_needed(tags)
// 145:     Dependency.new("zstd", [*tags, :implicit]) unless which("zstd")
// 146:   end
// 147:
// 148:   sig { params(tags: T::Array[T.any(String, Symbol)]).returns(T.nilable(Dependency)) }
// 149:   def unzip_dep_if_needed(tags)
// 150:     Dependency.new("unzip", [*tags, :implicit]) unless which("unzip")
// 151:   end
// 152:
// 153:   sig { params(tags: T::Array[T.any(String, Symbol)]).returns(T.nilable(Dependency)) }
// 154:   def bzip2_dep_if_needed(tags)
// 155:     Dependency.new("bzip2", [*tags, :implicit]) unless which("bzip2")
// 156:   end
// 157:
// 158:   sig { returns(T::Boolean) }
// 159:   def self.tar_needs_xz_dependency?
// 160:     !new.xz_dep_if_needed([]).nil?
// 161:   end
// 162:
// 163:   sig { returns(T::Boolean) }
// 164:   def self.tar_needs_bzip2_dependency?
// 165:     !new.bzip2_dep_if_needed([]).nil?
// 166:   end
// 167:
// 168:   private
// 169:
// 170:   sig { void }
// 171:   def init_global_dep_tree_if_needed!; end
// 172:
// 173:   sig {
// 174:     params(spec: T.any(String, Resource, Symbol, Requirement, Dependency, T::Class[Requirement]),
// 175:            tags: T::Array[T.any(String, Symbol)]).returns(T.nilable(T.any(Dependency, Requirement, T::Array[T.untyped])))
// 176:   }
// 177:   def parse_spec(spec, tags)
// 178:     raise ArgumentError, "Implicit dependencies cannot be manually specified" if tags.include?(:implicit)
// 179:
// 180:     case spec
// 181:     when String
// 182:       parse_string_spec(spec, tags)
// 183:     when Resource
// 184:       resource_dep(spec, tags)
// 185:     when Symbol
// 186:       parse_symbol_spec(spec, tags)
// 187:     when Requirement, Dependency
// 188:       spec
// 189:     when Class
// 190:       parse_class_spec(spec, tags)
// 191:     end
// 192:   end
// 193:
// 194:   sig { params(spec: String, tags: T::Array[T.any(String, Symbol)]).returns(Dependency) }
// 195:   def parse_string_spec(spec, tags)
// 196:     Dependency.new(spec, tags)
// 197:   end
// 198:
// 199:   sig { params(spec: Symbol, tags: T::Array[T.any(String, Symbol)]).returns(Requirement) }
// 200:   def parse_symbol_spec(spec, tags)
// 201:     # When modifying this list of supported requirements, consider
// 202:     # whether `Homebrew::API::Formula::FormulaStructGenerator::API_SUPPORTED_REQUIREMENTS` should also be changed.
// 203:     case spec
// 204:     when :arch          then ArchRequirement.new(T.cast(tags, T::Array[Symbol]))
// 205:     when :linux         then LinuxRequirement.new(tags)
// 206:     when :macos         then MacOSRequirement.new(tags)
// 207:     when :maximum_macos then MacOSRequirement.new(tags, comparator: "<=")
// 208:     when :xcode         then XcodeRequirement.new(tags)
// 209:     else
// 210:       raise ArgumentError, "Unsupported special dependency: #{spec.inspect}"
// 211:     end
// 212:   end
// 213:
// 214:   sig { params(spec: T::Class[Requirement], tags: T::Array[T.any(String, Symbol)]).returns(Requirement) }
// 215:   def parse_class_spec(spec, tags)
// 216:     raise TypeError, "#{spec.inspect} is not a Requirement subclass" unless spec < Requirement
// 217:
// 218:     spec.new(tags)
// 219:   end
// 220:
// 221:   sig { params(spec: Resource, tags: T::Array[T.any(String, Symbol)]).returns(T.nilable(T.any(Dependency, T::Array[T.nilable(Dependency)]))) }
// 222:   def resource_dep(spec, tags)
// 223:     tags << :build << :test
// 224:     strategy = spec.download_strategy
// 225:     return if strategy.nil?
// 226:
// 227:     if strategy <= HomebrewCurlDownloadStrategy
// 228:       [curl_dep_if_needed(tags), parse_url_spec(T.must(spec.url), tags)]
// 229:     elsif strategy <= NoUnzipCurlDownloadStrategy
// 230:       # ensure NoUnzip never adds any dependencies
// 231:     elsif strategy <= CurlDownloadStrategy
// 232:       parse_url_spec(T.must(spec.url), tags)
// 233:     elsif strategy <= GitDownloadStrategy
// 234:       git_dep_if_needed(tags)
// 235:     elsif strategy <= SubversionDownloadStrategy
// 236:       subversion_dep_if_needed(tags)
// 237:     elsif strategy <= MercurialDownloadStrategy
// 238:       Dependency.new("mercurial", [*tags, :implicit])
// 239:     elsif strategy <= FossilDownloadStrategy
// 240:       Dependency.new("fossil", [*tags, :implicit])
// 241:     elsif strategy <= BazaarDownloadStrategy
// 242:       Dependency.new("breezy", [*tags, :implicit])
// 243:     elsif strategy <= CVSDownloadStrategy
// 244:       cvs_dep_if_needed(tags)
// 245:     elsif strategy < AbstractDownloadStrategy
// 246:       # allow unknown strategies to pass through
// 247:     else
// 248:       raise TypeError, "#{strategy.inspect} is not an AbstractDownloadStrategy subclass"
// 249:     end
// 250:   end
// 251:
// 252:   sig { params(url: String, tags: T::Array[T.any(String, Symbol)]).returns(T.nilable(Dependency)) }
// 253:   def parse_url_spec(url, tags)
// 254:     case File.extname(url)
// 255:     when ".xz"          then xz_dep_if_needed(tags)
// 256:     when ".zst"         then zstd_dep_if_needed(tags)
// 257:     when ".zip"         then unzip_dep_if_needed(tags)
// 258:     when ".bz2"         then bzip2_dep_if_needed(tags)
// 259:     when ".lha", ".lzh" then Dependency.new("lha", [*tags, :implicit])
// 260:     when ".lz"          then Dependency.new("lzip", [*tags, :implicit])
// 261:     when ".rar"         then Dependency.new("libarchive", [*tags, :implicit])
// 262:     when ".7z"          then Dependency.new("p7zip", [*tags, :implicit])
// 263:     end
// 264:   end
// 265: end
// 266:
// 267: require "extend/os/dependency_collector"
