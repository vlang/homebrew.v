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
// The original source is retained below until every stub has a typed V body.

// Ruby method `git_dep_if_needed(tags); end` at line 7.
pub fn ruby_dependency_collector_l7_d1_git_dep_if_needed(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `subversion_dep_if_needed(tags)` at line 9.
pub fn ruby_dependency_collector_l9_d2_subversion_dep_if_needed(args ...ruby.Value) ruby.Value {
	return mac_dependency_value(mac_subversion_dependency(mac_dependency_tags(args)))
}

// Ruby method `cvs_dep_if_needed(tags)` at line 13.
pub fn ruby_dependency_collector_l13_d3_cvs_dep_if_needed(args ...ruby.Value) ruby.Value {
	return mac_dependency_value(mac_cvs_dependency(mac_dependency_tags(args)))
}

// Ruby method `xz_dep_if_needed(tags); end` at line 17.
pub fn ruby_dependency_collector_l17_d4_xz_dep_if_needed(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `unzip_dep_if_needed(tags); end` at line 19.
pub fn ruby_dependency_collector_l19_d5_unzip_dep_if_needed(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `bzip2_dep_if_needed(tags); end` at line 21.
pub fn ruby_dependency_collector_l21_d6_bzip2_dep_if_needed(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: true # rubocop:disable Sorbet/StrictSigil
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module DependencyCollector
// 7:       def git_dep_if_needed(tags); end
// 8:
// 9:       def subversion_dep_if_needed(tags)
// 10:         Dependency.new("subversion", [*tags, :implicit])
// 11:       end
// 12:
// 13:       def cvs_dep_if_needed(tags)
// 14:         Dependency.new("cvs", [*tags, :implicit])
// 15:       end
// 16:
// 17:       def xz_dep_if_needed(tags); end
// 18:
// 19:       def unzip_dep_if_needed(tags); end
// 20:
// 21:       def bzip2_dep_if_needed(tags); end
// 22:     end
// 23:   end
// 24: end
// 25:
// 26: DependencyCollector.prepend(OS::Mac::DependencyCollector)
