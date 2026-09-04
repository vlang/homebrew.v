module mac

import ruby
import homebrew

pub fn mac_dependency_collector(missing_tools map[string]bool) &homebrew.DependencyCollectorState {
	return homebrew.new_dependency_collector(true, missing_tools)
}

pub fn mac_subversion_dependency(tags []string) homebrew.Dependency {
	mut values := tags.clone()
	values << ':implicit'
	return homebrew.new_dependency('subversion', values)
}

pub fn mac_cvs_dependency(tags []string) homebrew.Dependency {
	mut values := tags.clone()
	values << ':implicit'
	return homebrew.new_dependency('cvs', values)
}

fn mac_dependency_value(dependency homebrew.Dependency) ruby.Value {
	return ruby.structured_value('Dependency', dependency.name, {
		'name': dependency.name
		'tags': dependency.tags.map(it.boundary_string()).join(',')
	})
}

fn mac_dependency_tags(args []ruby.Value) []string {
	if args.len == 0 {
		return []string{}
	}
	value := args.last()
	if value.type_name == 'Array' {
		return value.as_array() or { [] }.map(it.as_string())
	}
	return []string{}
}

// Translated from Homebrew/brew `extend/os/mac/dependency_collector.rb`.
