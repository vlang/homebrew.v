module test

import ruby
import homebrew
import homebrew.dependency as uses_from_macos_dependency

const dependency_spec_tag_separator = '\x1e'

fn dependency_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn dependency_spec_tags(dependency homebrew.Dependency) []string {
	return dependency.tags.map(it.boundary_string())
}

fn dependency_spec_value(dependency homebrew.Dependency) ruby.Value {
	return ruby.structured_value('Dependency', dependency.name, {
		'name':            dependency.name
		'tags':            dependency_spec_tags(dependency).join(dependency_spec_tag_separator)
		'tap':             dependency.tap
		'uses_from_macos': dependency.uses_from_macos.str()
	})
}

fn dependency_spec_from_value(value ruby.Value) homebrew.Dependency {
	name := value.attributes['name'] or { value.repr }
	tags_text := value.attributes['tags'] or { '' }
	tags := if tags_text == '' {
		[]string{}
	} else {
		tags_text.split(dependency_spec_tag_separator)
	}
	return homebrew.new_dependency(name, tags)
}

fn dependency_spec_accepts_bottle_os_version(method string, bottle_os_version string) bool {
	dependency := homebrew.new_dependency('foo', []string{})
	minimum := homebrew.DependencyMinimum{
		bottle_os_version: bottle_os_version
	}
	installation := homebrew.DependencyInstallation{}
	if method == 'satisfied' {
		_ = dependency.satisfied_from(installation, minimum)
	} else {
		_ = dependency.installed_from(installation, minimum)
	}
	return true
}

fn dependency_spec_uses_from_macos_value() ruby.Value {
	return ruby.structured_value('UsesFromMacOSDependency', 'foo', {
		'name':   'foo'
		'tags':   ''
		'bounds': 'since=sonoma'
	})
}

fn dependency_spec_uses_from_macos_accepts(bottle_os_version string) bool {
	dependency := uses_from_macos_dependency.new_uses_from_macos_dependency('foo', []string{}, {
		'since': 'sonoma'
	})
	installed := dependency.installed(uses_from_macos_dependency.UsesFromMacosContext{
		simulating_or_running_on_macos: bottle_os_version.starts_with('macOS ')
		current_os: if bottle_os_version.starts_with('macOS ') { 'sonoma' } else { 'linux' }
		bottle_os_version: bottle_os_version
	}) or { return false }
	_ = installed
	return true
}

// Translated from Homebrew/brew `test/dependency_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby alias_matcher `alias_matcher :be_a_build_dependency, :be_build` at line 7.
pub fn ruby_dependency_spec_l7_d1_be_a_build_dependency(args ...ruby.Value) ruby.Value {
	dependency := if args.len > 0 {
		dependency_spec_from_value(args[0])
	} else {
		homebrew.new_dependency('foo', [':build'])
	}
	return dependency_spec_bool(dependency.build())
}

// Ruby it `it "accepts a single tag" do` at line 10.
pub fn ruby_dependency_spec_l10_d2_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	dependency := homebrew.new_dependency('foo', ['bar'])
	return dependency_spec_bool(dependency_spec_tags(dependency) == ['bar'])
}

// Ruby it `it "accepts multiple tags" do` at line 15.
pub fn ruby_dependency_spec_l15_d3_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	mut actual := dependency_spec_tags(homebrew.new_dependency('foo', ['bar', 'baz']))
	actual.sort()
	return dependency_spec_bool(actual == ['bar', 'baz'])
}

// Ruby it `it "preserves symbol tags" do` at line 20.
pub fn ruby_dependency_spec_l20_d4_preserves(args ...ruby.Value) ruby.Value {
	_ = args
	dependency := homebrew.new_dependency('foo', [':build'])
	return dependency_spec_bool(dependency.tags.len == 1
		&& dependency.tags[0].kind == .symbol && dependency.tags[0].value == 'build')
}

// Ruby it `it "accepts symbol and string tags" do` at line 25.
pub fn ruby_dependency_spec_l25_d5_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	dependency := homebrew.new_dependency('foo', [':build', 'bar'])
	return dependency_spec_bool(dependency_spec_tags(dependency) == [':build', 'bar'])
}

// Ruby it `it "merges duplicate dependencies" do` at line 32.
pub fn ruby_dependency_spec_l32_d6_merges(args ...ruby.Value) ruby.Value {
	_ = args
	merged := homebrew.merge_repeated_dependencies([
		homebrew.new_dependency('foo', [':build']),
		homebrew.new_dependency('foo', ['bar']),
		homebrew.new_dependency('xyz', ['abc']),
	])
	foo := merged.filter(it.name == 'foo')
	xyz := merged.filter(it.name == 'xyz')
	return dependency_spec_bool(merged.len == 2 && foo.len == 1 && xyz.len == 1
		&& dependency_spec_tags(foo[0]) == ['bar'] && dependency_spec_tags(xyz[0]) == [
		'abc',
	])
}

// Ruby it `it "merges necessity tags" do` at line 47.
pub fn ruby_dependency_spec_l47_d7_merges(args ...ruby.Value) ruby.Value {
	_ = args
	required_dependency := homebrew.new_dependency('foo', []string{})
	recommended_dependency := homebrew.new_dependency('foo', [':recommended'])
	optional_dependency := homebrew.new_dependency('foo', [':optional'])
	required_recommended := homebrew.merge_repeated_dependencies([required_dependency,
		recommended_dependency])
	required_optional := homebrew.merge_repeated_dependencies([required_dependency,
		optional_dependency])
	recommended_optional := homebrew.merge_repeated_dependencies([
		recommended_dependency,
		optional_dependency,
	])
	return dependency_spec_bool(required_recommended.len == 1
		&& required_recommended[0].required() && !required_recommended[0].recommended()
		&& !required_recommended[0].optional() && required_optional.len == 1
		&& required_optional[0].required() && !required_optional[0].recommended()
		&& !required_optional[0].optional() && recommended_optional.len == 1
		&& !recommended_optional[0].required() && recommended_optional[0].recommended()
		&& !recommended_optional[0].optional())
}

// Ruby it `it "merges temporality tags" do` at line 71.
pub fn ruby_dependency_spec_l71_d8_merges(args ...ruby.Value) ruby.Value {
	_ = args
	merged := homebrew.merge_repeated_dependencies([
		homebrew.new_dependency('foo', []string{}),
		homebrew.new_dependency('foo', [':build']),
	])
	return dependency_spec_bool(merged.len == 1 && !merged[0].build())
}

// Ruby specify `specify "equality" do` at line 81.
pub fn ruby_dependency_spec_l81_d9_equality(args ...ruby.Value) ruby.Value {
	_ = args
	foo1 := homebrew.new_dependency('foo', []string{})
	foo2 := homebrew.new_dependency('foo', []string{})
	bar := homebrew.new_dependency('bar', []string{})
	foo3 := homebrew.new_dependency('foo', [':build'])
	ventura := homebrew.new_uses_from_macos_dependency('foo', []homebrew.DependencyTag{}, {
		'since': 'ventura'
	})
	sonoma := homebrew.new_uses_from_macos_dependency('foo', []homebrew.DependencyTag{}, {
		'since': 'sonoma'
	})
	return dependency_spec_bool(foo1.equal(foo2) && !foo1.equal(bar) && !foo1.equal(foo3)
		&& !ventura.equal(sonoma))
}

// Ruby it `it "returns a tap passed a fully-qualified name" do` at line 102.
pub fn ruby_dependency_spec_l102_d10_returns(args ...ruby.Value) ruby.Value {
	_ = args
	dependency := homebrew.new_dependency('foo/bar/dog', []string{})
	tap := dependency.tap_name() or { return dependency_spec_bool(false) }
	return dependency_spec_bool(tap == 'foo/bar')
}

// Ruby it `it "returns no tap passed a simple name" do` at line 107.
pub fn ruby_dependency_spec_l107_d11_returns(args ...ruby.Value) ruby.Value {
	_ = args
	dependency := homebrew.new_dependency('dog', []string{})
	if _ := dependency.tap_name() {
		return dependency_spec_bool(false)
	}
	return dependency_spec_bool(true)
}

// Ruby specify `specify "#option_names" do` at line 113.
pub fn ruby_dependency_spec_l113_d12_option_names(args ...ruby.Value) ruby.Value {
	_ = args
	dependency := homebrew.new_dependency('foo/bar/dog', []string{})
	return dependency_spec_bool(dependency.option_names() == ['dog'])
}

// Ruby it `it "marks dependency as no_linkage" do` at line 119.
pub fn ruby_dependency_spec_l119_d13_marks(args ...ruby.Value) ruby.Value {
	_ = args
	dependency := homebrew.new_dependency('foo', [':no_linkage'])
	return dependency_spec_bool(dependency.no_linkage() && dependency.required()
		&& !dependency.build() && !dependency.test())
}

// Ruby subject `subject(:dependency) { described_class.new("foo") }` at line 129.
pub fn ruby_dependency_spec_l129_d14_dependency(args ...ruby.Value) ruby.Value {
	_ = args
	return dependency_spec_value(homebrew.new_dependency('foo', []string{}))
}

// Ruby it `it "accepts macOS bottle_os_version parameter" do` at line 131.
pub fn ruby_dependency_spec_l131_d15_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	return dependency_spec_bool(dependency_spec_accepts_bottle_os_version('installed', 'macOS 14'))
}

// Ruby it `it "accepts Ubuntu bottle_os_version parameter" do` at line 135.
pub fn ruby_dependency_spec_l135_d16_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	return dependency_spec_bool(dependency_spec_accepts_bottle_os_version('installed', 'Ubuntu 22.04'))
}

// Ruby subject `subject(:dependency) { described_class.new("foo") }` at line 141.
pub fn ruby_dependency_spec_l141_d17_dependency(args ...ruby.Value) ruby.Value {
	return ruby_dependency_spec_l129_d14_dependency(...args)
}

// Ruby it `it "accepts bottle_os_version parameter" do` at line 143.
pub fn ruby_dependency_spec_l143_d18_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	return dependency_spec_bool(dependency_spec_accepts_bottle_os_version('satisfied', 'macOS 14'))
}

// Ruby it `it "accepts Ubuntu bottle_os_version parameter" do` at line 147.
pub fn ruby_dependency_spec_l147_d19_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	return dependency_spec_bool(dependency_spec_accepts_bottle_os_version('installed', 'Ubuntu 22.04'))
}

// Ruby subject `subject(:uses_from_macos) { described_class.new("foo", bounds: { since: :sonoma }) }` at line 153.
pub fn ruby_dependency_spec_l153_d20_uses_from_macos(args ...ruby.Value) ruby.Value {
	_ = args
	return dependency_spec_uses_from_macos_value()
}

// Ruby it `it "accepts macOS bottle_os_version parameter" do` at line 155.
pub fn ruby_dependency_spec_l155_d21_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	return dependency_spec_bool(dependency_spec_uses_from_macos_accepts('macOS 14'))
}

// Ruby it `it "accepts Ubuntu bottle_os_version parameter" do` at line 159.
pub fn ruby_dependency_spec_l159_d22_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	return dependency_spec_bool(dependency_spec_uses_from_macos_accepts('Ubuntu 22.04'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependency"
// 5:
// 6: RSpec.describe Dependency do
// 7:   alias_matcher :be_a_build_dependency, :be_build
// 8:
// 9:   describe "::new" do
// 10:     it "accepts a single tag" do
// 11:       dep = described_class.new("foo", %w[bar])
// 12:       expect(dep.tags).to eq(%w[bar])
// 13:     end
// 14:
// 15:     it "accepts multiple tags" do
// 16:       dep = described_class.new("foo", %w[bar baz])
// 17:       expect(dep.tags.sort).to eq(%w[bar baz].sort)
// 18:     end
// 19:
// 20:     it "preserves symbol tags" do
// 21:       dep = described_class.new("foo", [:build])
// 22:       expect(dep.tags).to eq([:build])
// 23:     end
// 24:
// 25:     it "accepts symbol and string tags" do
// 26:       dep = described_class.new("foo", [:build, "bar"])
// 27:       expect(dep.tags).to eq([:build, "bar"])
// 28:     end
// 29:   end
// 30:
// 31:   describe "::merge_repeats" do
// 32:     it "merges duplicate dependencies" do
// 33:       dep = described_class.new("foo", [:build])
// 34:       dep2 = described_class.new("foo", ["bar"])
// 35:       dep3 = described_class.new("xyz", ["abc"])
// 36:       merged = described_class.merge_repeats([dep, dep2, dep3])
// 37:       expect(merged.count).to eq(2)
// 38:       expect(merged.first).to be_a described_class
// 39:
// 40:       foo_named_dep = T.must(merged.find { |d| d.name == "foo" })
// 41:       expect(foo_named_dep.tags).to eq(["bar"])
// 42:
// 43:       xyz_named_dep = T.must(merged.find { |d| d.name == "xyz" })
// 44:       expect(xyz_named_dep.tags).to eq(["abc"])
// 45:     end
// 46:
// 47:     it "merges necessity tags" do
// 48:       required_dep = described_class.new("foo")
// 49:       recommended_dep = described_class.new("foo", [:recommended])
// 50:       optional_dep = described_class.new("foo", [:optional])
// 51:
// 52:       deps = described_class.merge_repeats([required_dep, recommended_dep])
// 53:       expect(deps.count).to eq(1)
// 54:       expect(deps.first).to be_required
// 55:       expect(deps.first).not_to be_recommended
// 56:       expect(deps.first).not_to be_optional
// 57:
// 58:       deps = described_class.merge_repeats([required_dep, optional_dep])
// 59:       expect(deps.count).to eq(1)
// 60:       expect(deps.first).to be_required
// 61:       expect(deps.first).not_to be_recommended
// 62:       expect(deps.first).not_to be_optional
// 63:
// 64:       deps = described_class.merge_repeats([recommended_dep, optional_dep])
// 65:       expect(deps.count).to eq(1)
// 66:       expect(deps.first).not_to be_required
// 67:       expect(deps.first).to be_recommended
// 68:       expect(deps.first).not_to be_optional
// 69:     end
// 70:
// 71:     it "merges temporality tags" do
// 72:       normal_dep = described_class.new("foo")
// 73:       build_dep = described_class.new("foo", [:build])
// 74:
// 75:       deps = described_class.merge_repeats([normal_dep, build_dep])
// 76:       expect(deps.count).to eq(1)
// 77:       expect(deps.first).not_to be_a_build_dependency
// 78:     end
// 79:   end
// 80:
// 81:   specify "equality" do
// 82:     foo1 = described_class.new("foo")
// 83:     foo2 = described_class.new("foo")
// 84:     expect(foo1).to eq(foo2)
// 85:     expect(foo1).to eql(foo2)
// 86:
// 87:     bar = described_class.new("bar")
// 88:     expect(foo1).not_to eq(bar)
// 89:     expect(foo1).not_to eql(bar)
// 90:
// 91:     foo3 = described_class.new("foo", [:build])
// 92:     expect(foo1).not_to eq(foo3)
// 93:     expect(foo1).not_to eql(foo3)
// 94:
// 95:     uses_from_macos_ventura = UsesFromMacOSDependency.new("foo", [], bounds: { since: :ventura })
// 96:     uses_from_macos_sonoma = UsesFromMacOSDependency.new("foo", [], bounds: { since: :sonoma })
// 97:     expect(uses_from_macos_ventura).not_to eq(uses_from_macos_sonoma)
// 98:     expect(uses_from_macos_ventura).not_to eql(uses_from_macos_sonoma)
// 99:   end
// 100:
// 101:   describe "#tap" do
// 102:     it "returns a tap passed a fully-qualified name" do
// 103:       dependency = described_class.new("foo/bar/dog")
// 104:       expect(dependency.tap).to eq(Tap.fetch("foo", "bar"))
// 105:     end
// 106:
// 107:     it "returns no tap passed a simple name" do
// 108:       dependency = described_class.new("dog")
// 109:       expect(dependency.tap).to be_nil
// 110:     end
// 111:   end
// 112:
// 113:   specify "#option_names" do
// 114:     dependency = described_class.new("foo/bar/dog")
// 115:     expect(dependency.option_names).to eq(%w[dog])
// 116:   end
// 117:
// 118:   describe "with no_linkage tag" do
// 119:     it "marks dependency as no_linkage" do
// 120:       dep = described_class.new("foo", [:no_linkage])
// 121:       expect(dep).to be_no_linkage
// 122:       expect(dep).to be_required
// 123:       expect(dep).not_to be_build
// 124:       expect(dep).not_to be_test
// 125:     end
// 126:   end
// 127:
// 128:   describe "Dependency#installed? with bottle_os_version" do
// 129:     subject(:dependency) { described_class.new("foo") }
// 130:
// 131:     it "accepts macOS bottle_os_version parameter" do
// 132:       expect { dependency.installed?(bottle_os_version: "macOS 14") }.not_to raise_error
// 133:     end
// 134:
// 135:     it "accepts Ubuntu bottle_os_version parameter" do
// 136:       expect { dependency.installed?(bottle_os_version: "Ubuntu 22.04") }.not_to raise_error
// 137:     end
// 138:   end
// 139:
// 140:   describe "Dependency#satisfied? with bottle_os_version" do
// 141:     subject(:dependency) { described_class.new("foo") }
// 142:
// 143:     it "accepts bottle_os_version parameter" do
// 144:       expect { dependency.satisfied?(bottle_os_version: "macOS 14") }.not_to raise_error
// 145:     end
// 146:
// 147:     it "accepts Ubuntu bottle_os_version parameter" do
// 148:       expect { dependency.installed?(bottle_os_version: "Ubuntu 22.04") }.not_to raise_error
// 149:     end
// 150:   end
// 151:
// 152:   describe "UsesFromMacOSDependency#installed? with bottle_os_version" do
// 153:     subject(:uses_from_macos) { described_class.new("foo", bounds: { since: :sonoma }) }
// 154:
// 155:     it "accepts macOS bottle_os_version parameter" do
// 156:       expect { uses_from_macos.installed?(bottle_os_version: "macOS 14") }.not_to raise_error
// 157:     end
// 158:
// 159:     it "accepts Ubuntu bottle_os_version parameter" do
// 160:       expect { uses_from_macos.installed?(bottle_os_version: "Ubuntu 22.04") }.not_to raise_error
// 161:     end
// 162:   end
// 163: end
