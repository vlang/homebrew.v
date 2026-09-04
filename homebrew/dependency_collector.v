module homebrew

import ruby

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
	ruby.find_executable(name) or { return false }
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

pub fn dependency_collector_value(collector &DependencyCollectorState) ruby.Value {
	return ruby.structured_value('DependencyCollector', 'DependencyCollector', {
		'collector_address': u64(voidptr(collector)).str()
	})
}

fn dependency_collector_from_value(value ruby.Value) &DependencyCollectorState {
	address := value.attributes['collector_address'] or { panic('invalid DependencyCollector') }
	return unsafe { &DependencyCollectorState(voidptr(address.u64())) }
}

fn collector_requirement_value(requirement CollectorRequirement) ruby.Value {
	return ruby.structured_value('${requirement.name.capitalize()}Requirement', requirement.name, {
		'name': requirement.name
		'tags': requirement.tags.join(',')
	})
}

fn collector_result_value(result CollectorResult) ruby.Value {
	return match result.kind {
		.nil_value { ruby.object_value('NilClass', 'nil') }
		.dependency { dependency_boundary_value(result.dependency) }
		.requirement { collector_requirement_value(result.requirement) }
		.dependencies { dependency_list_boundary_value(result.dependencies) }
	}
}

fn collector_tags_from_value(value ruby.Value) []string {
	if value.type_name == 'Array' {
		return value.as_array() or { [] }.map(it.as_string())
	}
	if value.type_name in ['String', 'Symbol'] {
		return [value.as_string()]
	}
	return []string{}
}

fn collector_from_boundary_args(args []ruby.Value) (&DependencyCollectorState, int) {
	if args.len > 0 && args[0].type_name == 'DependencyCollector' {
		return dependency_collector_from_value(args[0]), 1
	}
	return new_dependency_collector(false, map[string]bool{}), 0
}

fn collector_build_boundary(mut collector DependencyCollectorState,
	spec ruby.Value) !CollectorResult {
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
