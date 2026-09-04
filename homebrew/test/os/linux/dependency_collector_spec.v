module linux

import ruby
import homebrew
import homebrew.extend.os.linux as production_linux

// Translated from Homebrew/brew `test/os/linux/dependency_collector_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn linux_dependency_collector_spec_formulae() map[string]production_linux.LinuxCollectorFormula {
	return {
		'gcc':   production_linux.LinuxCollectorFormula{
			name: 'gcc'
		}
		'glibc': production_linux.LinuxCollectorFormula{
			name: 'glibc'
		}
	}
}

fn linux_dependency_collector_spec_resource(url string, tool string,
	available bool) homebrew.CollectorResult {
	mut collector := homebrew.new_dependency_collector(false, {
		tool: available
	})
	return homebrew.collector_add_resource(mut collector, homebrew.CollectorResource{
		url: url
		strategy: 'curl'
	}, []string{}) or { return homebrew.CollectorResult{} }
}

fn linux_dependency_collector_spec_resource_matches(url string, tool string,
	available bool) bool {
	result := linux_dependency_collector_spec_resource(url, tool, available)
	if available {
		return result.kind == .nil_value
	}
	return result.kind == .dependency && result.dependency.name == tool
		&& result.dependency.tags.map(it.boundary_string()) == [':build', ':test', ':implicit']
}

fn linux_dependency_collector_spec_implicit_names(needs_build bool, needs_libc bool) []string {
	mut collector := production_linux.new_linux_dependency_collector(needs_build, needs_libc, linux_dependency_collector_spec_formulae())
	mut names := []string{}
	if dependency := collector.gcc_dep_if_needed([]) {
		names << dependency.name
	}
	if dependency := collector.glibc_dep_if_needed([]) {
		names << dependency.name
	}
	return names
}

// Ruby subject `subject(:collector) { described_class.new }` at line 7.
pub fn ruby_dependency_collector_spec_l7_d1_collector(args ...ruby.Value) ruby.Value {
	_ = args
	return homebrew.dependency_collector_value(homebrew.new_dependency_collector(false, map[string]bool{}))
}

// Ruby alias_matcher `alias_matcher :be_a_build_requirement, :be_build` at line 9.
pub fn ruby_dependency_collector_spec_l9_d2_be_a_build_requirement(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(homebrew.new_dependency('fixture', [':build']).has_symbol_tag('build'))
}

// Ruby let `let(:resource) { Resource.new }` at line 12.
pub fn ruby_dependency_collector_spec_l12_d3_resource(args ...ruby.Value) ruby.Value {
	url := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.structured_value('Resource', url, {
		'url':      url
		'strategy': 'curl'
	})
}

// Ruby it `it "creates a resource dependency from a '.xz' URL" do` at line 15.
pub fn ruby_dependency_collector_spec_l15_d4_creates(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(linux_dependency_collector_spec_resource_matches('https://brew.sh/foo.xz', 'xz', false))
}

// Ruby it `it "creates a resource dependency from a '.zip' URL" do` at line 21.
pub fn ruby_dependency_collector_spec_l21_d5_creates(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(linux_dependency_collector_spec_resource_matches('https://brew.sh/foo.zip', 'unzip', false))
}

// Ruby it `it "creates a resource dependency from a '.bz2' URL" do` at line 27.
pub fn ruby_dependency_collector_spec_l27_d6_creates(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(linux_dependency_collector_spec_resource_matches('https://brew.sh/foo.tar.bz2', 'bzip2', false))
}

// Ruby it `it "does not create a resource dependency from a '.xz' URL" do` at line 35.
pub fn ruby_dependency_collector_spec_l35_d7_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(linux_dependency_collector_spec_resource_matches('https://brew.sh/foo.xz', 'xz', true))
}

// Ruby it `it "does not create a resource dependency from a '.zip' URL" do` at line 41.
pub fn ruby_dependency_collector_spec_l41_d8_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(linux_dependency_collector_spec_resource_matches('https://brew.sh/foo.zip', 'unzip', true))
}

// Ruby it `it "does not create a resource dependency from a '.bz2' URL" do` at line 47.
pub fn ruby_dependency_collector_spec_l47_d9_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(linux_dependency_collector_spec_resource_matches('https://brew.sh/foo.tar.bz2', 'bzip2', true))
}

// Ruby let `let(:formulae) do` at line 56.
pub fn ruby_dependency_collector_spec_l56_d10_formulae(args ...ruby.Value) ruby.Value {
	_ = args
	mut values := map[string]ruby.Value{}
	for name, formula in linux_dependency_collector_spec_formulae() {
		values[name] = ruby.structured_value('Formula', formula.name, {
			'name': formula.name
			'deps': ''
		})
	}
	return ruby.map_value(values)
}

// Ruby method `global_dep_tree` at line 70.
pub fn ruby_dependency_collector_spec_l70_d11_global_dep_tree(args ...ruby.Value) ruby.Value {
	needs_build := args.len > 0 && (args[0].as_bool() or { false })
	needs_libc := args.len > 1 && (args[1].as_bool() or { false })
	collector := production_linux.new_linux_dependency_collector(needs_build, needs_libc, linux_dependency_collector_spec_formulae())
	mut tree := map[string]ruby.Value{}
	for name, dependencies in collector.global_dep_tree {
		tree[name] = ruby.string_array_value(dependencies)
	}
	return ruby.map_value(tree)
}

// Ruby it `it "is empty when build formulae and a libc formula aren't needed" do` at line 74.
pub fn ruby_dependency_collector_spec_l74_d12_is(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(linux_dependency_collector_spec_implicit_names(false, false).len == 0)
}

// Ruby it `it "includes gcc when build formulae are needed" do` at line 78.
pub fn ruby_dependency_collector_spec_l78_d13_includes(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_linux.linux_dependency_collector_gcc in linux_dependency_collector_spec_implicit_names(true, false))
}

// Ruby it `it "includes glibc when a libc formula is needed" do` at line 84.
pub fn ruby_dependency_collector_spec_l84_d14_includes(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_linux.linux_dependency_collector_glibc in linux_dependency_collector_spec_implicit_names(false, true))
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
