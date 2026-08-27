module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/dependency_collector.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `git_dep_if_needed(tags); end` at line 7.
pub fn ruby_dependency_collector_l7_d1_git_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('git_dep_if_needed', ...args)
}

// Ruby method `subversion_dep_if_needed(tags)` at line 9.
pub fn ruby_dependency_collector_l9_d2_subversion_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subversion_dep_if_needed', ...args)
}

// Ruby method `cvs_dep_if_needed(tags)` at line 13.
pub fn ruby_dependency_collector_l13_d3_cvs_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cvs_dep_if_needed', ...args)
}

// Ruby method `xz_dep_if_needed(tags); end` at line 17.
pub fn ruby_dependency_collector_l17_d4_xz_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('xz_dep_if_needed', ...args)
}

// Ruby method `unzip_dep_if_needed(tags); end` at line 19.
pub fn ruby_dependency_collector_l19_d5_unzip_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unzip_dep_if_needed', ...args)
}

// Ruby method `bzip2_dep_if_needed(tags); end` at line 21.
pub fn ruby_dependency_collector_l21_d6_bzip2_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bzip2_dep_if_needed', ...args)
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
