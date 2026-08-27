module linux

import brew_runtime

// Translated from Homebrew/brew `test/os/linux/dependency_collector_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:collector) { described_class.new }` at line 7.
pub fn ruby_dependency_collector_spec_l7_d1_collector(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('collector', ...args)
}

// Ruby alias_matcher `alias_matcher :be_a_build_requirement, :be_build` at line 9.
pub fn ruby_dependency_collector_spec_l9_d2_be_a_build_requirement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('be_a_build_requirement', ...args)
}

// Ruby let `let(:resource) { Resource.new }` at line 12.
pub fn ruby_dependency_collector_spec_l12_d3_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resource', ...args)
}

// Ruby it `it "creates a resource dependency from a '.xz' URL" do` at line 15.
pub fn ruby_dependency_collector_spec_l15_d4_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "creates a resource dependency from a '.zip' URL" do` at line 21.
pub fn ruby_dependency_collector_spec_l21_d5_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "creates a resource dependency from a '.bz2' URL" do` at line 27.
pub fn ruby_dependency_collector_spec_l27_d6_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "does not create a resource dependency from a '.xz' URL" do` at line 35.
pub fn ruby_dependency_collector_spec_l35_d7_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not create a resource dependency from a '.zip' URL" do` at line 41.
pub fn ruby_dependency_collector_spec_l41_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not create a resource dependency from a '.bz2' URL" do` at line 47.
pub fn ruby_dependency_collector_spec_l47_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:formulae) do` at line 56.
pub fn ruby_dependency_collector_spec_l56_d10_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae', ...args)
}

// Ruby method `global_dep_tree` at line 70.
pub fn ruby_dependency_collector_spec_l70_d11_global_dep_tree(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('global_dep_tree', ...args)
}

// Ruby it `it "is empty when build formulae and a libc formula aren't needed" do` at line 74.
pub fn ruby_dependency_collector_spec_l74_d12_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "includes gcc when build formulae are needed" do` at line 78.
pub fn ruby_dependency_collector_spec_l78_d13_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "includes glibc when a libc formula is needed" do` at line 84.
pub fn ruby_dependency_collector_spec_l84_d14_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
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
// 9:   alias_matcher :be_a_build_requirement, :be_build
// 10:
// 11:   describe "#add" do
// 12:     let(:resource) { Resource.new }
// 13:
// 14:     context "when xz, unzip and bzip2 are not available" do
// 15:       it "creates a resource dependency from a '.xz' URL" do
// 16:         resource.url("https://brew.sh/foo.xz")
// 17:         allow_any_instance_of(Object).to receive(:which).with("xz")
// 18:         expect(collector.add(resource)).to eq(Dependency.new("xz", [:build, :test, :implicit]))
// 19:       end
// 20:
// 21:       it "creates a resource dependency from a '.zip' URL" do
// 22:         resource.url("https://brew.sh/foo.zip")
// 23:         allow_any_instance_of(Object).to receive(:which).with("unzip")
// 24:         expect(collector.add(resource)).to eq(Dependency.new("unzip", [:build, :test, :implicit]))
// 25:       end
// 26:
// 27:       it "creates a resource dependency from a '.bz2' URL" do
// 28:         resource.url("https://brew.sh/foo.tar.bz2")
// 29:         allow_any_instance_of(Object).to receive(:which).with("bzip2")
// 30:         expect(collector.add(resource)).to eq(Dependency.new("bzip2", [:build, :test, :implicit]))
// 31:       end
// 32:     end
// 33:
// 34:     context "when xz, zip and bzip2 are available" do
// 35:       it "does not create a resource dependency from a '.xz' URL" do
// 36:         resource.url("https://brew.sh/foo.xz")
// 37:         allow_any_instance_of(Object).to receive(:which).with("xz").and_return(Pathname.new("foo"))
// 38:         expect(collector.add(resource)).to be_nil
// 39:       end
// 40:
// 41:       it "does not create a resource dependency from a '.zip' URL" do
// 42:         resource.url("https://brew.sh/foo.zip")
// 43:         allow_any_instance_of(Object).to receive(:which).with("unzip").and_return(Pathname.new("foo"))
// 44:         expect(collector.add(resource)).to be_nil
// 45:       end
// 46:
// 47:       it "does not create a resource dependency from a '.bz2' URL" do
// 48:         resource.url("https://brew.sh/foo.tar.bz2")
// 49:         allow_any_instance_of(Object).to receive(:which).with("bzip2").and_return(Pathname.new("foo"))
// 50:         expect(collector.add(resource)).to be_nil
// 51:       end
// 52:     end
// 53:   end
// 54:
// 55:   describe "#implicit_dependency_names" do
// 56:     let(:formulae) do
// 57:       Hash.new { |hash, name| hash[name] = instance_double(Formula, deps: []) }
// 58:     end
// 59:
// 60:     before do
// 61:       allow(DevelopmentTools).to receive_messages(needs_build_formulae?: false, needs_libc_formula?: false)
// 62:       allow(Formula).to receive(:[]) { |name| formulae[name] }
// 63:       global_dep_tree.clear
// 64:     end
// 65:
// 66:     after do
// 67:       global_dep_tree.clear
// 68:     end
// 69:
// 70:     def global_dep_tree
// 71:       OS::Linux::DependencyCollector.module_eval { class_variable_get(:@@global_dep_tree) }
// 72:     end
// 73:
// 74:     it "is empty when build formulae and a libc formula aren't needed" do
// 75:       expect(collector.implicit_dependency_names).to eq(Set.new)
// 76:     end
// 77:
// 78:     it "includes gcc when build formulae are needed" do
// 79:       allow(DevelopmentTools).to receive(:needs_build_formulae?).and_return(true)
// 80:
// 81:       expect(collector.implicit_dependency_names).to include(OS::LINUX_PREFERRED_GCC_RUNTIME_FORMULA)
// 82:     end
// 83:
// 84:     it "includes glibc when a libc formula is needed" do
// 85:       allow(DevelopmentTools).to receive(:needs_libc_formula?).and_return(true)
// 86:
// 87:       expect(collector.implicit_dependency_names).to include("glibc")
// 88:     end
// 89:   end
// 90: end
