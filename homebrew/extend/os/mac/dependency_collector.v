module mac

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

// Translated from Homebrew/brew `extend/os/mac/dependency_collector.rb`.
