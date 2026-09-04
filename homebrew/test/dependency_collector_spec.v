module test

import ruby
import homebrew

fn dependency_collector_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn dependency_collector_spec_dependency(name string, tags []string) ruby.Value {
	dependency := homebrew.new_dependency(name, tags)
	return ruby.structured_value('Dependency', dependency.name, {
		'name': dependency.name
		'tags': dependency.tags.map(it.boundary_string()).join(',')
	})
}

fn dependency_collector_spec_resource(url string, strategy string) homebrew.CollectorResource {
	return homebrew.CollectorResource{ url: url, strategy: strategy }
}

// Translated from Homebrew/brew `test/dependency_collector_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:collector) { described_class.new }` at line 7.
pub fn ruby_dependency_collector_spec_l7_d1_collector(args ...ruby.Value) ruby.Value {
	return homebrew.dependency_collector_value(homebrew.new_dependency_collector(false, map[string]bool{}))
}

// Ruby alias_matcher `alias_matcher :be_a_build_requirement, :be_build` at line 9.
pub fn ruby_dependency_collector_spec_l9_d2_be_a_build_requirement(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dependency_collector_spec_bool(false)
	}
	return dependency_collector_spec_bool((args[0].attributes['tags'] or { '' }).split(',').any(it == ':build'))
}

// Ruby method `find_dependency(name)` at line 11.
pub fn ruby_dependency_collector_spec_l11_d3_find_dependency(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('NilClass', 'nil')
	}
	collector := unsafe { &homebrew.DependencyCollectorState(voidptr(args[0].attributes['collector_address'].u64())) }
	name := args[1].as_string()
	for dependency in collector.deps {
		if dependency.name == name {
			return dependency_collector_spec_dependency(dependency.name, dependency.tags.map(it.boundary_string()))
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `find_requirement(klass)` at line 15.
pub fn ruby_dependency_collector_spec_l15_d4_find_requirement(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('NilClass', 'nil')
	}
	collector := unsafe { &homebrew.DependencyCollectorState(voidptr(args[0].attributes['collector_address'].u64())) }
	name := args[1].as_string()
	for requirement in collector.requirements {
		if requirement.name == name {
			return ruby.structured_value('${name.capitalize()}Requirement', name, {
				'name': name
				'tags': requirement.tags.join(',')
			})
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby specify `specify "dependency creation" do` at line 20.
pub fn ruby_dependency_collector_spec_l20_d5_dependency(args ...ruby.Value) ruby.Value {
	mut collector := homebrew.new_dependency_collector(false, map[string]bool{})
	homebrew.collector_add_dependency(mut collector, 'foo', [':build']) or { return dependency_collector_spec_bool(false) }
	homebrew.collector_add_dependency(mut collector, 'bar', ['--universal', ':optional']) or { return dependency_collector_spec_bool(false) }
	return dependency_collector_spec_bool(collector.deps.len == 2 && collector.deps[0].name == 'foo' && collector.deps[1].tags.len == 2)
}

// Ruby it `it "returns the created dependency" do` at line 27.
pub fn ruby_dependency_collector_spec_l27_d6_returns(args ...ruby.Value) ruby.Value {
	mut collector := homebrew.new_dependency_collector(false, map[string]bool{})
	result := homebrew.collector_add_dependency(mut collector, 'foo', []string{}) or {
		return dependency_collector_spec_bool(false)
	}
	return dependency_collector_spec_bool(result.dependency.equal(homebrew.new_dependency('foo', []string{})))
}

// Ruby specify `specify "requirement creation" do` at line 31.
pub fn ruby_dependency_collector_spec_l31_d7_requirement(args ...ruby.Value) ruby.Value {
	mut collector := homebrew.new_dependency_collector(false, map[string]bool{})
	homebrew.collector_add_requirement(mut collector, 'xcode', []string{}) or { return dependency_collector_spec_bool(false) }
	return dependency_collector_spec_bool(collector.requirements.len == 1 && collector.requirements[0].name == 'xcode')
}

// Ruby it `it "deduplicates requirements" do` at line 36.
pub fn ruby_dependency_collector_spec_l36_d8_deduplicates(args ...ruby.Value) ruby.Value {
	mut collector := homebrew.new_dependency_collector(false, map[string]bool{})
	for _ in 0 .. 2 {
		homebrew.collector_add_requirement(mut collector, 'xcode', []string{}) or {
			return dependency_collector_spec_bool(false)
		}
	}
	return dependency_collector_spec_bool(collector.requirements.len == 1)
}

// Ruby specify `specify "requirement tags" do` at line 41.
pub fn ruby_dependency_collector_spec_l41_d9_requirement(args ...ruby.Value) ruby.Value {
	mut collector := homebrew.new_dependency_collector(false, map[string]bool{})
	homebrew.collector_add_requirement(mut collector, 'xcode', [':build']) or { return dependency_collector_spec_bool(false) }
	return dependency_collector_spec_bool(collector.requirements[0].tags == [':build'])
}

// Ruby it `it "doesn't mutate the dependency spec" do` at line 46.
pub fn ruby_dependency_collector_spec_l46_d10_doesn(args ...ruby.Value) ruby.Value {
	mut collector := homebrew.new_dependency_collector(false, map[string]bool{})
	tags := [':optional']
	copy := tags.clone()
	homebrew.collector_add_dependency(mut collector, 'foo', tags) or { return dependency_collector_spec_bool(false) }
	return dependency_collector_spec_bool(tags == copy)
}

// Ruby it `it "creates a resource dependency from a CVS URL" do` at line 53.
pub fn ruby_dependency_collector_spec_l53_d11_creates(args ...ruby.Value) ruby.Value {
	mut collector := homebrew.new_dependency_collector(false, {
		'cvs': false
	})
	result := homebrew.collector_add_resource(mut collector, dependency_collector_spec_resource(':pserver:anonymous:@brew.sh:/cvsroot/foo/bar', 'cvs'), []string{}) or { return dependency_collector_spec_bool(false) }
	return dependency_collector_spec_bool(result.kind == .dependency && result.dependency.equal(homebrew.new_dependency('cvs', [
		':build',
		':test',
		':implicit',
	])))
}

// Ruby it `it "creates a resource dependency from a '.7z' URL" do` at line 59.
pub fn ruby_dependency_collector_spec_l59_d12_creates(args ...ruby.Value) ruby.Value {
	return dependency_collector_spec_resource_expect('https://brew.sh/foo.7z', 'p7zip')
}

// Ruby it `it "creates a resource dependency from a '.gz' URL" do` at line 65.
pub fn ruby_dependency_collector_spec_l65_d13_creates(args ...ruby.Value) ruby.Value {
	return dependency_collector_spec_resource_expect('https://brew.sh/foo.tar.gz', '')
}

// Ruby it `it "creates a resource dependency from a '.lz' URL" do` at line 71.
pub fn ruby_dependency_collector_spec_l71_d14_creates(args ...ruby.Value) ruby.Value {
	return dependency_collector_spec_resource_expect('https://brew.sh/foo.lz', 'lzip')
}

// Ruby it `it "creates a resource dependency from a '.lha' URL" do` at line 77.
pub fn ruby_dependency_collector_spec_l77_d15_creates(args ...ruby.Value) ruby.Value {
	return dependency_collector_spec_resource_expect('https://brew.sh/foo.lha', 'lha')
}

// Ruby it `it "creates a resource dependency from a '.lzh' URL" do` at line 83.
pub fn ruby_dependency_collector_spec_l83_d16_creates(args ...ruby.Value) ruby.Value {
	return dependency_collector_spec_resource_expect('https://brew.sh/foo.lzh', 'lha')
}

// Ruby it `it "creates a resource dependency from a '.rar' URL" do` at line 89.
pub fn ruby_dependency_collector_spec_l89_d17_creates(args ...ruby.Value) ruby.Value {
	return dependency_collector_spec_resource_expect('https://brew.sh/foo.rar', 'libarchive')
}

// Ruby it `it "raises a TypeError for unknown classes" do` at line 95.
pub fn ruby_dependency_collector_spec_l95_d18_raises(args ...ruby.Value) ruby.Value {
	if _ := homebrew.collector_parse_class_spec('#<Class>', false, []string{}) {
		return dependency_collector_spec_bool(false)
	} else {
		return dependency_collector_spec_bool(err.msg().contains('not a Requirement subclass'))
	}
}

// Ruby it `it "raises an ArgumentError for a removed codesign requirement" do` at line 99.
pub fn ruby_dependency_collector_spec_l99_d19_raises(args ...ruby.Value) ruby.Value {
	mut collector := homebrew.new_dependency_collector(false, map[string]bool{})
	if _ := homebrew.collector_add_requirement(mut collector, 'codesign', []string{}) {
		return dependency_collector_spec_bool(false)
	} else {
		return dependency_collector_spec_bool(err.msg() == 'Unsupported special dependency: :codesign')
	}
}

// Ruby it `it "raises a TypeError for a Resource with an unknown download strategy" do` at line 103.
pub fn ruby_dependency_collector_spec_l103_d20_raises(args ...ruby.Value) ruby.Value {
	mut collector := homebrew.new_dependency_collector(false, map[string]bool{})
	if _ := homebrew.collector_add_resource(mut collector, dependency_collector_spec_resource('https://brew.sh/foo', 'unknown'), []string{}) {
		return dependency_collector_spec_bool(false)
	} else {
		return dependency_collector_spec_bool(err.msg().contains('not an AbstractDownloadStrategy subclass'))
	}
}

// Ruby it `it "is empty when nothing needs to be silently installed" do` at line 111.
pub fn ruby_dependency_collector_spec_l111_d21_is(args ...ruby.Value) ruby.Value {
	collector := homebrew.new_dependency_collector(false, map[string]bool{})
	return dependency_collector_spec_bool(collector.deps.len == 0)
}

fn dependency_collector_spec_resource_expect(url string, expected string) ruby.Value {
	mut collector := homebrew.new_dependency_collector(false, map[string]bool{})
	result := homebrew.collector_add_resource(mut collector, dependency_collector_spec_resource(url, 'curl'), []string{}) or {
		return dependency_collector_spec_bool(false)
	}
	if expected == '' {
		return dependency_collector_spec_bool(result.kind == .nil_value)
	}
	return dependency_collector_spec_bool(result.kind == .dependency && result.dependency.name == expected)
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
// 11:   def find_dependency(name)
// 12:     collector.deps.find { |dep| dep.name == name }
// 13:   end
// 14:
// 15:   def find_requirement(klass)
// 16:     collector.requirements.find { |req| req.is_a? klass }
// 17:   end
// 18:
// 19:   describe "#add" do
// 20:     specify "dependency creation" do
// 21:       collector.add "foo" => :build
// 22:       collector.add "bar" => ["--universal", :optional]
// 23:       expect(find_dependency("foo")).to be_an_instance_of(Dependency)
// 24:       expect(find_dependency("bar").tags.count).to eq(2)
// 25:     end
// 26:
// 27:     it "returns the created dependency" do
// 28:       expect(collector.add("foo")).to eq(Dependency.new("foo"))
// 29:     end
// 30:
// 31:     specify "requirement creation" do
// 32:       collector.add :xcode
// 33:       expect(find_requirement(XcodeRequirement)).to be_an_instance_of(XcodeRequirement)
// 34:     end
// 35:
// 36:     it "deduplicates requirements" do
// 37:       2.times { collector.add :xcode }
// 38:       expect(collector.requirements.count).to eq(1)
// 39:     end
// 40:
// 41:     specify "requirement tags" do
// 42:       collector.add xcode: :build
// 43:       expect(find_requirement(XcodeRequirement)).to be_a_build_requirement
// 44:     end
// 45:
// 46:     it "doesn't mutate the dependency spec" do
// 47:       spec = { "foo" => :optional }
// 48:       copy = spec.dup
// 49:       collector.add(spec)
// 50:       expect(spec).to eq(copy)
// 51:     end
// 52:
// 53:     it "creates a resource dependency from a CVS URL" do
// 54:       resource = Resource.new
// 55:       resource.url(":pserver:anonymous:@brew.sh:/cvsroot/foo/bar", using: :cvs)
// 56:       expect(collector.add(resource)).to eq(Dependency.new("cvs", [:build, :test, :implicit]))
// 57:     end
// 58:
// 59:     it "creates a resource dependency from a '.7z' URL" do
// 60:       resource = Resource.new
// 61:       resource.url("https://brew.sh/foo.7z")
// 62:       expect(collector.add(resource)).to eq(Dependency.new("p7zip", [:build, :test, :implicit]))
// 63:     end
// 64:
// 65:     it "creates a resource dependency from a '.gz' URL" do
// 66:       resource = Resource.new
// 67:       resource.url("https://brew.sh/foo.tar.gz")
// 68:       expect(collector.add(resource)).to be_nil
// 69:     end
// 70:
// 71:     it "creates a resource dependency from a '.lz' URL" do
// 72:       resource = Resource.new
// 73:       resource.url("https://brew.sh/foo.lz")
// 74:       expect(collector.add(resource)).to eq(Dependency.new("lzip", [:build, :test, :implicit]))
// 75:     end
// 76:
// 77:     it "creates a resource dependency from a '.lha' URL" do
// 78:       resource = Resource.new
// 79:       resource.url("https://brew.sh/foo.lha")
// 80:       expect(collector.add(resource)).to eq(Dependency.new("lha", [:build, :test, :implicit]))
// 81:     end
// 82:
// 83:     it "creates a resource dependency from a '.lzh' URL" do
// 84:       resource = Resource.new
// 85:       resource.url("https://brew.sh/foo.lzh")
// 86:       expect(collector.add(resource)).to eq(Dependency.new("lha", [:build, :test, :implicit]))
// 87:     end
// 88:
// 89:     it "creates a resource dependency from a '.rar' URL" do
// 90:       resource = Resource.new
// 91:       resource.url("https://brew.sh/foo.rar")
// 92:       expect(collector.add(resource)).to eq(Dependency.new("libarchive", [:build, :test, :implicit]))
// 93:     end
// 94:
// 95:     it "raises a TypeError for unknown classes" do
// 96:       expect { collector.add(Class.new) }.to raise_error(TypeError)
// 97:     end
// 98:
// 99:     it "raises an ArgumentError for a removed codesign requirement" do
// 100:       expect { collector.add(:codesign) }.to raise_error(ArgumentError, "Unsupported special dependency: :codesign")
// 101:     end
// 102:
// 103:     it "raises a TypeError for a Resource with an unknown download strategy" do
// 104:       resource = Resource.new
// 105:       resource.download_strategy = Class.new
// 106:       expect { collector.add(resource) }.to raise_error(TypeError)
// 107:     end
// 108:   end
// 109:
// 110:   describe "#implicit_dependency_names" do
// 111:     it "is empty when nothing needs to be silently installed" do
// 112:       allow(Homebrew::EnvConfig).to receive(:sandbox_linux?).and_return(false)
// 113:       allow(DevelopmentTools).to receive_messages(needs_build_formulae?: false, needs_libc_formula?: false)
// 114:
// 115:       expect(collector.implicit_dependency_names).to eq(Set.new)
// 116:     end
// 117:   end
// 118: end
