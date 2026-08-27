module mac

import brew_runtime

// Translated from Homebrew/brew `test/os/mac/dependency_collector_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:collector) { described_class.new }` at line 7.
pub fn ruby_dependency_collector_spec_l7_d1_collector(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('collector', ...args)
}

// Ruby alias_matcher `alias_matcher :need_tar_xz_dependency, :be_tar_needs_xz_dependency` at line 9.
pub fn ruby_dependency_collector_spec_l9_d2_need_tar_xz_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('need_tar_xz_dependency', ...args)
}

// Ruby specify `specify "Resource dependency from a '.xz' URL" do` at line 11.
pub fn ruby_dependency_collector_spec_l11_d3_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('Resource', ...args)
}

// Ruby specify `specify "Resource dependency from a '.zip' URL" do` at line 17.
pub fn ruby_dependency_collector_spec_l17_d4_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('Resource', ...args)
}

// Ruby specify `specify "Resource dependency from a '.bz2' URL" do` at line 23.
pub fn ruby_dependency_collector_spec_l23_d5_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('Resource', ...args)
}

// Ruby specify `specify "Resource dependency from a '.git' URL" do` at line 29.
pub fn ruby_dependency_collector_spec_l29_d6_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('Resource', ...args)
}

// Ruby specify `specify "Resource dependency from a Subversion URL" do` at line 35.
pub fn ruby_dependency_collector_spec_l35_d7_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('Resource', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependency_collector"
// 5:
// 6: RSpec.describe DependencyCollector do
// 7:   subject(:collector) { described_class.new }
// 8:
// 9:   alias_matcher :need_tar_xz_dependency, :be_tar_needs_xz_dependency
// 10:
// 11:   specify "Resource dependency from a '.xz' URL" do
// 12:     resource = Resource.new
// 13:     resource.url("https://brew.sh/foo.tar.xz")
// 14:     expect(collector.add(resource)).to be_nil
// 15:   end
// 16:
// 17:   specify "Resource dependency from a '.zip' URL" do
// 18:     resource = Resource.new
// 19:     resource.url("https://brew.sh/foo.zip")
// 20:     expect(collector.add(resource)).to be_nil
// 21:   end
// 22:
// 23:   specify "Resource dependency from a '.bz2' URL" do
// 24:     resource = Resource.new
// 25:     resource.url("https://brew.sh/foo.tar.bz2")
// 26:     expect(collector.add(resource)).to be_nil
// 27:   end
// 28:
// 29:   specify "Resource dependency from a '.git' URL" do
// 30:     resource = Resource.new
// 31:     resource.url("git://brew.sh/foo/bar.git")
// 32:     expect(collector.add(resource)).to be_nil
// 33:   end
// 34:
// 35:   specify "Resource dependency from a Subversion URL" do
// 36:     resource = Resource.new
// 37:     resource.url("svn://brew.sh/foo/bar")
// 38:     expect(collector.add(resource)).to eq(Dependency.new("subversion", [:build, :test, :implicit]))
// 39:   end
// 40: end
