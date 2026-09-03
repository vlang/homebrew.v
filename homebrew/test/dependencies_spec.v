module test

import brew_runtime
import homebrew

// Translated from Homebrew/brew `test/dependencies_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:dependencies) { described_class.new }` at line 8.
pub fn ruby_dependencies_spec_l8_d1_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return homebrew.ruby_dependencies_l15_d1_initialize()
}

// Ruby it `it "returns itself" do` at line 11.
pub fn ruby_dependencies_spec_l11_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	mut dependencies := homebrew.new_dependencies()
	result := dependencies.add(homebrew.new_dependency('foo', []string{}))
	return brew_runtime.bool_value(result.equal(dependencies))
}

// Ruby it `it "preserves order" do` at line 15.
pub fn ruby_dependencies_spec_l15_d3_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	names := ['foo', 'bar', 'baz']
	mut dependencies := homebrew.new_dependencies()
	for name in names {
		dependencies.add(homebrew.new_dependency(name, []string{}))
	}
	return brew_runtime.bool_value(dependencies.to_a().map(it.name) == names)
}

// Ruby specify `specify "#*" do` at line 28.
pub fn ruby_dependencies_spec_l28_d4_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	dependencies := homebrew.new_dependencies(homebrew.new_dependency('foo', []string{}), homebrew.new_dependency('bar', []string{}))
	return brew_runtime.bool_value(dependencies.join(', ') == 'foo, bar')
}

// Ruby specify `specify "#to_a" do` at line 34.
pub fn ruby_dependencies_spec_l34_d5_to_a(args ...brew_runtime.Value) brew_runtime.Value {
	dependency := homebrew.new_dependency('foo', []string{})
	dependencies := homebrew.new_dependencies(dependency)
	values := dependencies.to_a()
	return brew_runtime.bool_value(values.len == 1 && values[0].equal(dependency))
}

// Ruby specify `specify "#to_ary" do` at line 40.
pub fn ruby_dependencies_spec_l40_d6_to_ary(args ...brew_runtime.Value) brew_runtime.Value {
	dependency := homebrew.new_dependency('foo', []string{})
	dependencies := homebrew.new_dependencies(dependency)
	values := dependencies.to_ary()
	return brew_runtime.bool_value(values.len == 1 && values[0].equal(dependency))
}

// Ruby specify `specify "type helpers" do` at line 46.
pub fn ruby_dependencies_spec_l46_d7_type(args ...brew_runtime.Value) brew_runtime.Value {
	foo := homebrew.new_dependency('foo', []string{})
	bar := homebrew.new_dependency('bar', [':optional'])
	baz := homebrew.new_dependency('baz', [':build'])
	qux := homebrew.new_dependency('qux', [':recommended'])
	quux := homebrew.new_dependency('quux', []string{})
	dependencies := homebrew.new_dependencies(foo, bar, baz, qux, quux)
	return brew_runtime.bool_value(dependencies.required().map(it.name) == ['foo', 'quux']
		&& dependencies.optional().map(it.name) == ['bar']
		&& dependencies.build().map(it.name) == ['baz']
		&& dependencies.recommended().map(it.name) == ['qux']
		&& dependencies.default_dependencies().map(it.name) == ['baz', 'foo', 'quux', 'qux'])
}

// Ruby specify `specify "equality" do` at line 60.
pub fn ruby_dependencies_spec_l60_d8_equality(args ...brew_runtime.Value) brew_runtime.Value {
	dependency := homebrew.new_dependency('foo', []string{})
	mut a := homebrew.new_dependencies()
	mut b := homebrew.new_dependencies()
	a.add(dependency)
	b.add(dependency)
	equal_before := a.equal(b)
	b.add(homebrew.new_dependency('bar', [':optional']))
	return brew_runtime.bool_value(equal_before && !a.equal(b))
}

// Ruby specify `specify "#empty?" do` at line 78.
pub fn ruby_dependencies_spec_l78_d9_empty(args ...brew_runtime.Value) brew_runtime.Value {
	mut dependencies := homebrew.new_dependencies()
	empty_before := dependencies.empty()
	dependencies.add(homebrew.new_dependency('foo', []string{}))
	return brew_runtime.bool_value(empty_before && !dependencies.empty())
}

// Ruby specify `specify "#inspect" do` at line 85.
pub fn ruby_dependencies_spec_l85_d10_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	mut dependencies := homebrew.new_dependencies()
	empty_inspect := dependencies.inspect()
	dependencies.add(homebrew.new_dependency('foo', []string{}))
	return brew_runtime.bool_value(empty_inspect == '#<Dependencies: []>'
		&& dependencies.inspect() == '#<Dependencies: [#<Dependency: "foo" []>]>')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependencies"
// 5: require "dependency"
// 6:
// 7: RSpec.describe Dependencies do
// 8:   subject(:dependencies) { described_class.new }
// 9:
// 10:   describe "#<<" do
// 11:     it "returns itself" do
// 12:       expect(dependencies << Dependency.new("foo")).to eq(dependencies)
// 13:     end
// 14:
// 15:     it "preserves order" do
// 16:       hash = { 0 => "foo", 1 => "bar", 2 => "baz" }
// 17:
// 18:       dependencies << Dependency.new(hash[0])
// 19:       dependencies << Dependency.new(hash[1])
// 20:       dependencies << Dependency.new(hash[2])
// 21:
// 22:       dependencies.each_with_index do |dep, i|
// 23:         expect(dep.name).to eq(hash[i])
// 24:       end
// 25:     end
// 26:   end
// 27:
// 28:   specify "#*" do
// 29:     dependencies << Dependency.new("foo")
// 30:     dependencies << Dependency.new("bar")
// 31:     expect(dependencies * ", ").to eq("foo, bar")
// 32:   end
// 33:
// 34:   specify "#to_a" do
// 35:     dep = Dependency.new("foo")
// 36:     dependencies << dep
// 37:     expect(dependencies.to_a).to eq([dep])
// 38:   end
// 39:
// 40:   specify "#to_ary" do
// 41:     dep = Dependency.new("foo")
// 42:     dependencies << dep
// 43:     expect(dependencies.to_ary).to eq([dep])
// 44:   end
// 45:
// 46:   specify "type helpers" do
// 47:     foo = Dependency.new("foo")
// 48:     bar = Dependency.new("bar", [:optional])
// 49:     baz = Dependency.new("baz", [:build])
// 50:     qux = Dependency.new("qux", [:recommended])
// 51:     quux = Dependency.new("quux")
// 52:     dependencies << foo << bar << baz << qux << quux
// 53:     expect(dependencies.required).to eq([foo, quux])
// 54:     expect(dependencies.optional).to eq([bar])
// 55:     expect(dependencies.build).to eq([baz])
// 56:     expect(dependencies.recommended).to eq([qux])
// 57:     expect(dependencies.default.sort_by(&:name)).to eq([foo, baz, quux, qux].sort_by(&:name))
// 58:   end
// 59:
// 60:   specify "equality" do
// 61:     a = described_class.new
// 62:     b = described_class.new
// 63:
// 64:     dep = Dependency.new("foo")
// 65:
// 66:     a << dep
// 67:     b << dep
// 68:
// 69:     expect(a).to eq(b)
// 70:     expect(a).to eql(b)
// 71:
// 72:     b << Dependency.new("bar", [:optional])
// 73:
// 74:     expect(a).not_to eq(b)
// 75:     expect(a).not_to eql(b)
// 76:   end
// 77:
// 78:   specify "#empty?" do
// 79:     expect(dependencies).to be_empty
// 80:
// 81:     dependencies << Dependency.new("foo")
// 82:     expect(dependencies).not_to be_empty
// 83:   end
// 84:
// 85:   specify "#inspect" do
// 86:     expect(dependencies.inspect).to eq("#<Dependencies: []>")
// 87:
// 88:     dependencies << Dependency.new("foo")
// 89:     expect(dependencies.inspect).to eq("#<Dependencies: [#<Dependency: \"foo\" []>]>")
// 90:   end
// 91: end
