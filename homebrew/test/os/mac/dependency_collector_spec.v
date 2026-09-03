module mac

import brew_runtime
import homebrew
import homebrew.extend.os.mac as dependency_collector_mac

fn mac_dependency_collector_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn mac_dependency_collector_resource(url string, strategy string) brew_runtime.Value {
	mut collector := dependency_collector_mac.mac_dependency_collector(map[string]bool{})
	result := homebrew.collector_add_resource(mut collector, homebrew.CollectorResource{
		url: url
		strategy: strategy
	}, []string{}) or { return mac_dependency_collector_spec_bool(false) }
	return brew_runtime.structured_value('CollectorResult', result.kind.str(), {
		'kind': result.kind.str()
		'name': result.dependency.name
		'tags': result.dependency.tags.map(it.boundary_string()).join(',')
	})
}

// Translated from Homebrew/brew `test/os/mac/dependency_collector_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:collector) { described_class.new }` at line 7.
pub fn ruby_dependency_collector_spec_l7_d1_collector(args ...brew_runtime.Value) brew_runtime.Value {
	return homebrew.dependency_collector_value(dependency_collector_mac.mac_dependency_collector(map[string]bool{}))
}

// Ruby alias_matcher `alias_matcher :need_tar_xz_dependency, :be_tar_needs_xz_dependency` at line 9.
pub fn ruby_dependency_collector_spec_l9_d2_need_tar_xz_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	collector := dependency_collector_mac.mac_dependency_collector(map[string]bool{})
	return brew_runtime.bool_value(collector.archive_dep_if_needed('xz', []string{}) != none)
}

// Ruby specify `specify "Resource dependency from a '.xz' URL" do` at line 11.
pub fn ruby_dependency_collector_spec_l11_d3_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return mac_dependency_collector_spec_bool(mac_dependency_collector_resource('https://brew.sh/foo.tar.xz', 'curl').attributes['kind'] == 'nil_value')
}

// Ruby specify `specify "Resource dependency from a '.zip' URL" do` at line 17.
pub fn ruby_dependency_collector_spec_l17_d4_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return mac_dependency_collector_spec_bool(mac_dependency_collector_resource('https://brew.sh/foo.zip', 'curl').attributes['kind'] == 'nil_value')
}

// Ruby specify `specify "Resource dependency from a '.bz2' URL" do` at line 23.
pub fn ruby_dependency_collector_spec_l23_d5_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return mac_dependency_collector_spec_bool(mac_dependency_collector_resource('https://brew.sh/foo.tar.bz2', 'curl').attributes['kind'] == 'nil_value')
}

// Ruby specify `specify "Resource dependency from a '.git' URL" do` at line 29.
pub fn ruby_dependency_collector_spec_l29_d6_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return mac_dependency_collector_spec_bool(mac_dependency_collector_resource('git://brew.sh/foo/bar.git', 'git').attributes['kind'] == 'nil_value')
}

// Ruby specify `specify "Resource dependency from a Subversion URL" do` at line 35.
pub fn ruby_dependency_collector_spec_l35_d7_resource(args ...brew_runtime.Value) brew_runtime.Value {
	result := mac_dependency_collector_resource('svn://brew.sh/foo/bar', 'subversion')
	return mac_dependency_collector_spec_bool(result.attributes['kind'] == 'dependency' && result.attributes['name'] == 'subversion' && result.attributes['tags'] == ':build,:test,:implicit')
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
