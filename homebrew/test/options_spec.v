module test

import homebrew

// Translated from Homebrew/brew `test/options_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:options) { described_class.new }` at line 7.
pub fn ruby_options_spec_l7_d1_options() homebrew.Options {
	return homebrew.new_options()
}

// Ruby it `it "removes duplicate options" do` at line 9.
pub fn ruby_options_spec_l9_d2_removes() bool {
	mut options := ruby_options_spec_l7_d1_options()
	options.add(homebrew.new_option('foo'))
	options.add(homebrew.new_option('foo'))
	return options.contains('--foo') && options.len() == 1
}

// Ruby it `it "preserves existing member when adding a duplicate" do` at line 16.
pub fn ruby_options_spec_l16_d3_preserves() bool {
	mut options := ruby_options_spec_l7_d1_options()
	a := homebrew.new_option('foo', 'bar')
	b := homebrew.new_option('foo', 'qux')
	options.add(a)
	options.add(b)
	items := options.to_array()
	return items.len == 1 && items[0].equal(a) && items[0].description == a.description
}

// Ruby specify `specify "#include?" do` at line 25.
pub fn ruby_options_spec_l25_d4_include() bool {
	mut options := ruby_options_spec_l7_d1_options()
	options.add(homebrew.new_option('foo'))
	return options.contains('--foo') && options.contains('foo') && options.contains_option(homebrew.new_option('foo'))
}

// Ruby it `it "returns options" do` at line 33.
pub fn ruby_options_spec_l33_d5_returns() bool {
	result := ruby_options_spec_l7_d1_options().plus(homebrew.new_options())
	return result.len() == 0
}

// Ruby it `it "returns options" do` at line 39.
pub fn ruby_options_spec_l39_d6_returns() bool {
	result := ruby_options_spec_l7_d1_options().minus(homebrew.new_options())
	return result.len() == 0
}

// Ruby specify `specify "#&" do` at line 44.
pub fn ruby_options_spec_l44_d7_anonymous() bool {
	foo := homebrew.new_option('foo')
	bar := homebrew.new_option('bar')
	baz := homebrew.new_option('baz')
	mut other_options := homebrew.new_options()
	other_options.add(foo)
	other_options.add(bar)
	mut options := ruby_options_spec_l7_d1_options()
	options.add(foo)
	options.add(baz)
	result := options.intersection(other_options).to_array()
	return result.len == 1 && result[0].equal(foo)
}

// Ruby specify `specify "#|" do` at line 51.
pub fn ruby_options_spec_l51_d8_anonymous() bool {
	foo := homebrew.new_option('foo')
	bar := homebrew.new_option('bar')
	baz := homebrew.new_option('baz')
	mut other_options := homebrew.new_options()
	other_options.add(foo)
	other_options.add(bar)
	mut options := ruby_options_spec_l7_d1_options()
	options.add(foo)
	options.add(baz)
	mut names := options.union(other_options).to_array().map(it.name)
	names.sort()
	return names == ['bar', 'baz', 'foo']
}

// Ruby specify `specify "#*" do` at line 58.
pub fn ruby_options_spec_l58_d9_anonymous() bool {
	mut options := ruby_options_spec_l7_d1_options()
	for name in ['aa', 'bb', 'cc'] {
		options.add(homebrew.new_option(name))
	}
	mut flags := options.join('XX').split('XX')
	flags.sort()
	return flags == ['--aa', '--bb', '--cc']
}

// Ruby it `it "returns itself" do` at line 64.
pub fn ruby_options_spec_l64_d10_returns() bool {
	mut options := ruby_options_spec_l7_d1_options()
	options.add(homebrew.new_option('foo'))
	return options.contains('foo')
}

// Ruby specify `specify "#as_flags" do` at line 69.
pub fn ruby_options_spec_l69_d11_as_flags() bool {
	mut options := ruby_options_spec_l7_d1_options()
	options.add(homebrew.new_option('foo'))
	return options.as_flags() == ['--foo']
}

// Ruby specify `specify "#to_a" do` at line 74.
pub fn ruby_options_spec_l74_d12_to_a() bool {
	option := homebrew.new_option('foo')
	mut options := ruby_options_spec_l7_d1_options()
	options.add(option)
	items := options.to_array()
	return items.len == 1 && items[0].equal(option)
}

// Ruby specify `specify "#to_ary" do` at line 80.
pub fn ruby_options_spec_l80_d13_to_ary() bool {
	return ruby_options_spec_l74_d12_to_a()
}

// Ruby specify `specify "::create_with_array" do` at line 86.
pub fn ruby_options_spec_l86_d14_create_with_array() bool {
	mut actual := homebrew.new_options('--foo', '--bar').to_array().map(it.name)
	actual.sort()
	return actual == ['bar', 'foo']
}

// Ruby specify `specify "#to_s" do` at line 93.
pub fn ruby_options_spec_l93_d15_to_s() bool {
	mut options := ruby_options_spec_l7_d1_options()
	if options.str() != '' {
		return false
	}
	options.add(homebrew.new_option('first'))
	if options.str() != '--first' {
		return false
	}
	options.add(homebrew.new_option('second'))
	return options.str() == '--first --second'
}

// Ruby specify `specify "#inspect" do` at line 101.
pub fn ruby_options_spec_l101_d16_inspect() bool {
	mut options := ruby_options_spec_l7_d1_options()
	if options.inspect() != '#<Options: []>' {
		return false
	}
	options.add(homebrew.new_option('foo'))
	return options.inspect() == '#<Options: [#<Option: "--foo">]>'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "options"
// 5:
// 6: RSpec.describe Options do
// 7:   subject(:options) { described_class.new }
// 8:
// 9:   it "removes duplicate options" do
// 10:     options << Option.new("foo")
// 11:     options << Option.new("foo")
// 12:     expect(options).to include("--foo")
// 13:     expect(options.count).to eq(1)
// 14:   end
// 15:
// 16:   it "preserves existing member when adding a duplicate" do
// 17:     a = Option.new("foo", "bar")
// 18:     b = Option.new("foo", "qux")
// 19:     options << a << b
// 20:     expect(options.count).to eq(1)
// 21:     expect(options.first).to be(a)
// 22:     expect(options.first.description).to eq(a.description)
// 23:   end
// 24:
// 25:   specify "#include?" do
// 26:     options << Option.new("foo")
// 27:     expect(options).to include("--foo")
// 28:     expect(options).to include("foo")
// 29:     expect(options).to include(Option.new("foo"))
// 30:   end
// 31:
// 32:   describe "#+" do
// 33:     it "returns options" do
// 34:       expect(options + described_class.new).to be_an_instance_of(described_class)
// 35:     end
// 36:   end
// 37:
// 38:   describe "#-" do
// 39:     it "returns options" do
// 40:       expect(options - described_class.new).to be_an_instance_of(described_class)
// 41:     end
// 42:   end
// 43:
// 44:   specify "#&" do
// 45:     foo, bar, baz = %w[foo bar baz].map { |o| Option.new(o) }
// 46:     other_options = described_class.new << T.must(foo) << T.must(bar)
// 47:     options << foo << baz
// 48:     expect((options & other_options).to_a).to eq([foo])
// 49:   end
// 50:
// 51:   specify "#|" do
// 52:     foo, bar, baz = %w[foo bar baz].map { |o| Option.new(o) }
// 53:     other_options = described_class.new << T.must(foo) << T.must(bar)
// 54:     options << foo << baz
// 55:     expect((options | other_options).sort).to eq([foo, bar, baz].sort)
// 56:   end
// 57:
// 58:   specify "#*" do
// 59:     options << Option.new("aa") << Option.new("bb") << Option.new("cc")
// 60:     expect((options * "XX").split("XX").sort).to eq(%w[--aa --bb --cc])
// 61:   end
// 62:
// 63:   describe "<<" do
// 64:     it "returns itself" do
// 65:       expect(options << Option.new("foo")).to be options
// 66:     end
// 67:   end
// 68:
// 69:   specify "#as_flags" do
// 70:     options << Option.new("foo")
// 71:     expect(options.as_flags).to eq(%w[--foo])
// 72:   end
// 73:
// 74:   specify "#to_a" do
// 75:     option = Option.new("foo")
// 76:     options << option
// 77:     expect(options.to_a).to eq([option])
// 78:   end
// 79:
// 80:   specify "#to_ary" do
// 81:     option = Option.new("foo")
// 82:     options << option
// 83:     expect(options.to_ary).to eq([option])
// 84:   end
// 85:
// 86:   specify "::create_with_array" do
// 87:     array = %w[--foo --bar]
// 88:     option1 = Option.new("foo")
// 89:     option2 = Option.new("bar")
// 90:     expect(described_class.create(array).sort).to eq([option1, option2].sort)
// 91:   end
// 92:
// 93:   specify "#to_s" do
// 94:     expect(options.to_s).to eq("")
// 95:     options << Option.new("first")
// 96:     expect(options.to_s).to eq("--first")
// 97:     options << Option.new("second")
// 98:     expect(options.to_s).to eq("--first --second")
// 99:   end
// 100:
// 101:   specify "#inspect" do
// 102:     expect(options.inspect).to eq("#<Options: []>")
// 103:     options << Option.new("foo")
// 104:     expect(options.inspect).to eq("#<Options: [#<Option: \"--foo\">]>")
// 105:   end
// 106: end
