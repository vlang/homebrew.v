module test

import ruby
import homebrew

// Translated from Homebrew/brew `test/dependable_spec.rb`.
// The original source is retained below until every stub has a typed V body.

const dependable_spec_tag_separator = '\x1f'

fn dependable_spec_dependency(tags []string) homebrew.Dependency {
	return homebrew.new_dependency('dependable-spec', tags)
}

fn dependable_spec_default() homebrew.Dependency {
	return dependable_spec_dependency(['foo', 'bar', ':build'])
}

fn dependable_spec_no_linkage() homebrew.Dependency {
	return dependable_spec_dependency([':no_linkage'])
}

fn dependable_spec_value(dependency homebrew.Dependency) ruby.Value {
	return ruby.structured_value('DependableSpecSubject', dependency.name, {
		'name': dependency.name
		'tags': dependency.tags.map(it.boundary_string()).join(dependable_spec_tag_separator)
	})
}

fn dependable_spec_from_value(value ruby.Value) homebrew.Dependency {
	name := value.attributes['name'] or { value.repr }
	encoded_tags := value.attributes['tags'] or { '' }
	tags := if encoded_tags == '' {
		[]string{}
	} else {
		encoded_tags.split(dependable_spec_tag_separator)
	}
	return homebrew.new_dependency(name, tags)
}

// Ruby alias_matcher `alias_matcher :be_a_build_dependency, :be_build` at line 7.
pub fn ruby_dependable_spec_l7_d1_be_a_build_dependency(args ...ruby.Value) ruby.Value {
	dependency := if args.len > 0 {
		dependable_spec_from_value(args[0])
	} else {
		dependable_spec_default()
	}
	return ruby.bool_value(dependency.build())
}

// Ruby subject `subject(:dependable) do` at line 9.
pub fn ruby_dependable_spec_l9_d2_dependable(args ...ruby.Value) ruby.Value {
	return ruby_dependable_spec_l13_d3_initialize(...args)
}

// Ruby method `initialize` at line 13.
pub fn ruby_dependable_spec_l13_d3_initialize(args ...ruby.Value) ruby.Value {
	_ = args
	return dependable_spec_value(dependable_spec_default())
}

// Ruby specify `specify do` at line 19.
pub fn ruby_dependable_spec_l19_d4_do(args ...ruby.Value) ruby.Value {
	_ = args
	dependency := dependable_spec_default()
	flags := dependency.options().as_flags().sorted()
	return ruby.bool_value(flags == ['--bar', '--foo'] && dependency.build()
		&& !dependency.optional() && !dependency.recommended() && !dependency.no_linkage())
}

// Ruby subject `subject(:dependable_no_linkage) do` at line 28.
pub fn ruby_dependable_spec_l28_d5_dependable_no_linkage(args ...ruby.Value) ruby.Value {
	return ruby_dependable_spec_l32_d6_initialize(...args)
}

// Ruby method `initialize` at line 32.
pub fn ruby_dependable_spec_l32_d6_initialize(args ...ruby.Value) ruby.Value {
	_ = args
	return dependable_spec_value(dependable_spec_no_linkage())
}

// Ruby specify `specify do` at line 38.
pub fn ruby_dependable_spec_l38_d7_do(args ...ruby.Value) ruby.Value {
	_ = args
	dependency := dependable_spec_no_linkage()
	return ruby.bool_value(dependency.no_linkage() && dependency.required())
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependable"
// 5:
// 6: RSpec.describe Dependable do
// 7:   alias_matcher :be_a_build_dependency, :be_build
// 8:
// 9:   subject(:dependable) do
// 10:     Class.new do
// 11:       include Dependable
// 12:
// 13:       def initialize
// 14:         @tags = ["foo", "bar", :build]
// 15:       end
// 16:     end.new
// 17:   end
// 18:
// 19:   specify do
// 20:     expect(dependable.options.as_flags.sort).to eq(%w[--foo --bar].sort)
// 21:     expect(dependable).to be_a_build_dependency
// 22:     expect(dependable).not_to be_optional
// 23:     expect(dependable).not_to be_recommended
// 24:     expect(dependable).not_to be_no_linkage
// 25:   end
// 26:
// 27:   describe "with no_linkage tag" do
// 28:     subject(:dependable_no_linkage) do
// 29:       Class.new do
// 30:         include Dependable
// 31:
// 32:         def initialize
// 33:           @tags = [:no_linkage]
// 34:         end
// 35:       end.new
// 36:     end
// 37:
// 38:     specify do
// 39:       expect(dependable_no_linkage).to be_no_linkage
// 40:       expect(dependable_no_linkage).to be_required
// 41:     end
// 42:   end
// 43: end
