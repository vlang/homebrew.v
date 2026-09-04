module test

import ruby
import homebrew

// Translated from Homebrew/brew `test/livecheck_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn livecheck_spec_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn livecheck_spec_symbol(name string) ruby.Value {
	return ruby.object_value('Symbol', ':${name}')
}

fn livecheck_spec_package(kind string, name string, version string, arch string, operating_system string) ruby.Value {
	return ruby.Value{
		type_name: kind
		repr: name
		map_data: {
			'name':    ruby.string_value(name)
			'version': ruby.string_value(version)
			'arch':    ruby.string_value(arch)
			'os':      ruby.string_value(operating_system)
		}
	}
}

fn livecheck_spec_formula() ruby.Value {
	return livecheck_spec_package('FormulaClass', 'TestFormula', '0.0.1', '', '')
}

fn livecheck_spec_cask() ruby.Value {
	return livecheck_spec_package('Cask', 'test', '0.0.1,2', '', '')
}

fn livecheck_spec_livecheck(package ruby.Value) ruby.Value {
	return homebrew.ruby_livecheck_l38_d5_initialize(package)
}

fn livecheck_spec_post_hash() ruby.Value {
	return ruby.map_value({
		'empty':   ruby.string_value('')
		'boolean': ruby.string_value('true')
		'number':  ruby.string_value('1')
		'string':  ruby.string_value('a + b = c')
	})
}

fn livecheck_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn livecheck_spec_with_version(kind string) ruby.Value {
	package := livecheck_spec_package(kind, kind.to_lower(), '0.0.1', '', '')
	mut dsl := livecheck_spec_livecheck(package)
	version := homebrew.ruby_livecheck_l236_d17_version(dsl).as_string()
	dsl = homebrew.ruby_livecheck_l199_d13_url(dsl, ruby.string_value('https://brew.sh/${version}'))
	return dsl
}

// Ruby let `let(:f) do` at line 8.
pub fn ruby_livecheck_spec_l8_d1_f(args ...ruby.Value) ruby.Value {
	_ = args
	return livecheck_spec_formula()
}

// Ruby let `let(:livecheck_f) { described_class.new(f.class) }` at line 16.
pub fn ruby_livecheck_spec_l16_d2_livecheck_f(args ...ruby.Value) ruby.Value {
	_ = args
	return livecheck_spec_livecheck(livecheck_spec_formula())
}

// Ruby let `let(:c) do` at line 18.
pub fn ruby_livecheck_spec_l18_d3_c(args ...ruby.Value) ruby.Value {
	_ = args
	return livecheck_spec_cask()
}

// Ruby let `let(:livecheck_c) { described_class.new(c) }` at line 30.
pub fn ruby_livecheck_spec_l30_d4_livecheck_c(args ...ruby.Value) ruby.Value {
	_ = args
	return livecheck_spec_livecheck(livecheck_spec_cask())
}

// Ruby let `let(:post_hash) do` at line 32.
pub fn ruby_livecheck_spec_l32_d5_post_hash(args ...ruby.Value) ruby.Value {
	_ = args
	return livecheck_spec_post_hash()
}

// Ruby it `it "returns nil if not set" do` at line 42.
pub fn ruby_livecheck_spec_l42_d6_returns(args ...ruby.Value) ruby.Value {
	_ = args
	value := homebrew.ruby_livecheck_l82_d7_formula(livecheck_spec_livecheck(livecheck_spec_formula()))
	return livecheck_spec_bool(value.type_name == 'NilClass')
}

// Ruby it `it "returns the String if set" do` at line 46.
pub fn ruby_livecheck_spec_l46_d7_returns(args ...ruby.Value) ruby.Value {
	_ = args
	updated := homebrew.ruby_livecheck_l82_d7_formula(livecheck_spec_livecheck(livecheck_spec_formula()), ruby.string_value('other-formula'))
	return livecheck_spec_bool(homebrew.ruby_livecheck_l82_d7_formula(updated).as_string() == 'other-formula')
}

// Ruby it `it "returns nil if not set" do` at line 53.
pub fn ruby_livecheck_spec_l53_d8_returns(args ...ruby.Value) ruby.Value {
	_ = args
	value := homebrew.ruby_livecheck_l63_d6_cask(livecheck_spec_livecheck(livecheck_spec_cask()))
	return livecheck_spec_bool(value.type_name == 'NilClass')
}

// Ruby it `it "returns the String if set" do` at line 57.
pub fn ruby_livecheck_spec_l57_d9_returns(args ...ruby.Value) ruby.Value {
	_ = args
	updated := homebrew.ruby_livecheck_l63_d6_cask(livecheck_spec_livecheck(livecheck_spec_cask()), ruby.string_value('other-cask'))
	return livecheck_spec_bool(homebrew.ruby_livecheck_l63_d6_cask(updated).as_string() == 'other-cask')
}

// Ruby it `it "returns nil if not set" do` at line 64.
pub fn ruby_livecheck_spec_l64_d10_returns(args ...ruby.Value) ruby.Value {
	_ = args
	value := homebrew.ruby_livecheck_l99_d8_regex(livecheck_spec_livecheck(livecheck_spec_formula()))
	return livecheck_spec_bool(value.type_name == 'NilClass')
}

// Ruby it `it "returns the Regexp if set" do` at line 68.
pub fn ruby_livecheck_spec_l68_d11_returns(args ...ruby.Value) ruby.Value {
	_ = args
	pattern := ruby.object_value('Regexp', '/foo/')
	updated := homebrew.ruby_livecheck_l99_d8_regex(livecheck_spec_livecheck(livecheck_spec_formula()), pattern)
	result := homebrew.ruby_livecheck_l99_d8_regex(updated)
	return livecheck_spec_bool(result.type_name == 'Regexp' && result.repr == '/foo/')
}

// Ruby it `it "sets @skip to true when no argument is provided" do` at line 75.
pub fn ruby_livecheck_spec_l75_d12_sets(args ...ruby.Value) ruby.Value {
	_ = args
	updated := homebrew.ruby_livecheck_l119_d9_skip(livecheck_spec_livecheck(livecheck_spec_formula()))
	return livecheck_spec_bool(homebrew.ruby_livecheck_l127_d10_skip(updated).as_bool() or { false } && homebrew.ruby_livecheck_l26_d2_skip_msg(updated).type_name == 'NilClass')
}

// Ruby it `it "sets @skip to true and @skip_msg to the provided String" do` at line 81.
pub fn ruby_livecheck_spec_l81_d13_sets(args ...ruby.Value) ruby.Value {
	_ = args
	updated := homebrew.ruby_livecheck_l119_d9_skip(livecheck_spec_livecheck(livecheck_spec_formula()), ruby.string_value('foo'))
	return livecheck_spec_bool(homebrew.ruby_livecheck_l127_d10_skip(updated).as_bool() or { false } && homebrew.ruby_livecheck_l26_d2_skip_msg(updated).as_string() == 'foo')
}

// Ruby it `it "returns the value of @skip" do` at line 89.
pub fn ruby_livecheck_spec_l89_d14_returns(args ...ruby.Value) ruby.Value {
	_ = args
	dsl := livecheck_spec_livecheck(livecheck_spec_formula())
	if homebrew.ruby_livecheck_l127_d10_skip(dsl).as_bool() or { true } {
		return livecheck_spec_bool(false)
	}
	updated := homebrew.ruby_livecheck_l119_d9_skip(dsl)
	return livecheck_spec_bool(homebrew.ruby_livecheck_l127_d10_skip(updated).as_bool() or { false })
}

// Ruby let `let(:block) do` at line 98.
pub fn ruby_livecheck_spec_l98_d15_block(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Proc', 'page.scan(regex).map { |match| match[0].tr("_", ".") }')
}

// Ruby it `it "returns nil if not set" do` at line 102.
pub fn ruby_livecheck_spec_l102_d16_returns(args ...ruby.Value) ruby.Value {
	_ = args
	dsl := livecheck_spec_livecheck(livecheck_spec_formula())
	return livecheck_spec_bool(homebrew.ruby_livecheck_l142_d11_strategy(dsl).type_name == 'NilClass' && homebrew.ruby_livecheck_l30_d3_strategy_block(dsl).type_name == 'NilClass')
}

// Ruby it `it "returns the Symbol if set" do` at line 107.
pub fn ruby_livecheck_spec_l107_d17_returns(args ...ruby.Value) ruby.Value {
	_ = args
	updated := homebrew.ruby_livecheck_l142_d11_strategy(livecheck_spec_livecheck(livecheck_spec_formula()), livecheck_spec_symbol('page_match'))
	strategy := homebrew.ruby_livecheck_l142_d11_strategy(updated)
	return livecheck_spec_bool(strategy.type_name == 'Symbol' && strategy.as_string() == ':page_match' && homebrew.ruby_livecheck_l30_d3_strategy_block(updated).type_name == 'NilClass')
}

// Ruby it `it "sets `strategy_block` when provided" do` at line 113.
pub fn ruby_livecheck_spec_l113_d18_sets(args ...ruby.Value) ruby.Value {
	_ = args
	block := ruby_livecheck_spec_l98_d15_block()
	updated := homebrew.ruby_livecheck_l142_d11_strategy(livecheck_spec_livecheck(livecheck_spec_formula()), livecheck_spec_symbol('page_match'), block)
	strategy := homebrew.ruby_livecheck_l142_d11_strategy(updated)
	stored_block := homebrew.ruby_livecheck_l30_d3_strategy_block(updated)
	return livecheck_spec_bool(strategy.as_string() == ':page_match' && stored_block.type_name == 'Proc' && stored_block.as_string() == block.as_string())
}

// Ruby it `it "returns nil if not set" do` at line 121.
pub fn ruby_livecheck_spec_l121_d19_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return livecheck_spec_bool(homebrew.ruby_livecheck_l168_d12_throttle(livecheck_spec_livecheck(livecheck_spec_formula())).type_name == 'NilClass')
}

// Ruby it `it "returns the Integer if set" do` at line 125.
pub fn ruby_livecheck_spec_l125_d20_returns(args ...ruby.Value) ruby.Value {
	_ = args
	updated := homebrew.ruby_livecheck_l168_d12_throttle(livecheck_spec_livecheck(livecheck_spec_formula()), ruby.int_value(10))
	return livecheck_spec_bool(homebrew.ruby_livecheck_l168_d12_throttle(updated).as_int() or { -1 } == 10)
}

// Ruby it `it "sets @throttle_days to provided Integer" do` at line 130.
pub fn ruby_livecheck_spec_l130_d21_sets(args ...ruby.Value) ruby.Value {
	_ = args
	updated := homebrew.ruby_livecheck_l168_d12_throttle(livecheck_spec_livecheck(livecheck_spec_formula()), ruby.map_value({
		'days': ruby.int_value(1)
	}))
	return livecheck_spec_bool(homebrew.ruby_livecheck_l35_d4_throttle_days(updated).as_int() or { -1 } == 1)
}

// Ruby let `let(:url_string) { "https://brew.sh" }` at line 137.
pub fn ruby_livecheck_spec_l137_d22_url_string(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('https://brew.sh')
}

// Ruby let `let(:referer_url) { "https://example.com/referer" }` at line 138.
pub fn ruby_livecheck_spec_l138_d23_referer_url(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('https://example.com/referer')
}

// Ruby it `it "returns nil if not set" do` at line 140.
pub fn ruby_livecheck_spec_l140_d24_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return livecheck_spec_bool(homebrew.ruby_livecheck_l199_d13_url(livecheck_spec_livecheck(livecheck_spec_formula())).type_name == 'NilClass')
}

// Ruby it `it "returns a string when set to a string" do` at line 144.
pub fn ruby_livecheck_spec_l144_d25_returns(args ...ruby.Value) ruby.Value {
	_ = args
	updated := homebrew.ruby_livecheck_l199_d13_url(livecheck_spec_livecheck(livecheck_spec_formula()), ruby_livecheck_spec_l137_d22_url_string())
	return livecheck_spec_bool(homebrew.ruby_livecheck_l199_d13_url(updated).as_string() == 'https://brew.sh')
}

// Ruby it `it "returns the URL symbol if valid" do` at line 149.
pub fn ruby_livecheck_spec_l149_d26_returns(args ...ruby.Value) ruby.Value {
	_ = args
	for shorthand in ['head', 'homepage', 'stable'] {
		updated := homebrew.ruby_livecheck_l199_d13_url(livecheck_spec_livecheck(livecheck_spec_formula()), livecheck_spec_symbol(shorthand))
		if homebrew.ruby_livecheck_l199_d13_url(updated).as_string() != ':${shorthand}' {
			return livecheck_spec_bool(false)
		}
	}
	cask := homebrew.ruby_livecheck_l199_d13_url(livecheck_spec_livecheck(livecheck_spec_cask()), livecheck_spec_symbol('url'))
	return livecheck_spec_bool(homebrew.ruby_livecheck_l199_d13_url(cask).as_string() == ':url')
}

// Ruby it `it "sets `url` options when provided" do` at line 163.
pub fn ruby_livecheck_spec_l163_d27_sets(args ...ruby.Value) ruby.Value {
	_ = args
	post_hash := livecheck_spec_post_hash()
	cookies := ruby.map_value({
		'cookie_key': ruby.string_value('cookie_value')
	})
	mut dsl := homebrew.ruby_livecheck_l199_d13_url(livecheck_spec_livecheck(livecheck_spec_formula()), ruby.string_value('https://brew.sh'), ruby.map_value({
		'compressed':    ruby.bool_value(false)
		'cookies':       cookies
		'header':        ruby.string_value('Accept: */*')
		'homebrew_curl': ruby.bool_value(true)
		'post_form':     post_hash
		'referer':       ruby.string_value('https://example.com/referer')
		'user_agent':    livecheck_spec_symbol('browser')
	}))
	dsl = homebrew.ruby_livecheck_l199_d13_url(dsl, ruby.string_value('https://brew.sh'), ruby.map_value({
		'post_json': post_hash
	}))
	mut options := homebrew.ruby_livecheck_l21_d1_options(dsl).map_data.clone()
	if (options['compressed'] or { livecheck_spec_nil() }).type_name != 'Bool' || (options['compressed'] or { ruby.bool_value(true) }).bool_data || (options['cookies'] or { livecheck_spec_nil() }).map_data != cookies.map_data || (options['header'] or { livecheck_spec_nil() }).as_string() != 'Accept: */*' || !(options['homebrew_curl'] or { ruby.bool_value(false) }).bool_data || (options['post_form'] or { livecheck_spec_nil() }).map_data != post_hash.map_data || (options['post_json'] or { livecheck_spec_nil() }).map_data != post_hash.map_data || (options['referer'] or { livecheck_spec_nil() }).as_string() != 'https://example.com/referer' || (options['user_agent'] or { livecheck_spec_nil() }).as_string() != ':browser' {
		return livecheck_spec_bool(false)
	}
	header_array := ruby.string_array_value(['Accept: */*', 'X-Requested-With: XMLHttpRequest'])
	dsl = homebrew.ruby_livecheck_l199_d13_url(dsl, ruby.string_value('https://brew.sh'), ruby.map_value({
		'header': header_array
	}))
	options = homebrew.ruby_livecheck_l21_d1_options(dsl).map_data.clone()
	if (options['header'] or { livecheck_spec_nil() }).string_array_data != header_array.string_array_data {
		return livecheck_spec_bool(false)
	}
	dsl = homebrew.ruby_livecheck_l199_d13_url(dsl, ruby.string_value('https://brew.sh'), ruby.map_value({
		'user_agent': ruby.string_value('Example')
	}))
	return livecheck_spec_bool((homebrew.ruby_livecheck_l21_d1_options(dsl).map_data['user_agent'] or {
		livecheck_spec_nil()
	}).as_string() == 'Example')
}

// Ruby it `it "raises an ArgumentError if the argument isn't a valid Symbol" do` at line 200.
pub fn ruby_livecheck_spec_l200_d28_raises(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_livecheck_l199_d13_url(livecheck_spec_livecheck(livecheck_spec_formula()), livecheck_spec_symbol('not_a_valid_symbol'))
	return livecheck_spec_bool(result.type_name == 'ArgumentError')
}

// Ruby it `it "raises an ArgumentError if `compressed: true` argument is provided" do` at line 206.
pub fn ruby_livecheck_spec_l206_d29_raises(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_livecheck_l199_d13_url(livecheck_spec_livecheck(livecheck_spec_formula()), livecheck_spec_symbol('stable'), ruby.map_value({
		'compressed': ruby.bool_value(true)
	}))
	return livecheck_spec_bool(result.type_name == 'ArgumentError')
}

// Ruby it `it "raises an ArgumentError if `homebrew_curl: false` argument is provided" do` at line 212.
pub fn ruby_livecheck_spec_l212_d30_raises(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_livecheck_l199_d13_url(livecheck_spec_livecheck(livecheck_spec_formula()), livecheck_spec_symbol('stable'), ruby.map_value({
		'homebrew_curl': ruby.bool_value(false)
	}))
	return livecheck_spec_bool(result.type_name == 'ArgumentError')
}

// Ruby it `it "raises an ArgumentError if both `post_form` and `post_json` arguments are provided" do` at line 218.
pub fn ruby_livecheck_spec_l218_d31_raises(args ...ruby.Value) ruby.Value {
	_ = args
	post_hash := livecheck_spec_post_hash()
	result := homebrew.ruby_livecheck_l199_d13_url(livecheck_spec_livecheck(livecheck_spec_formula()), livecheck_spec_symbol('stable'), ruby.map_value({
		'post_form': post_hash
		'post_json': post_hash
	}))
	return livecheck_spec_bool(result.type_name == 'ArgumentError')
}

// Ruby let `let(:c_arch) do` at line 226.
pub fn ruby_livecheck_spec_l226_d32_c_arch(args ...ruby.Value) ruby.Value {
	arch := if args.len > 0 { args[0].as_string() } else { 'arm' }
	package := livecheck_spec_package('Cask', 'c-arch', '0.0.1', arch, '')
	mut dsl := livecheck_spec_livecheck(package)
	delegated := homebrew.ruby_livecheck_l234_d15_arch(dsl).as_string()
	dsl = homebrew.ruby_livecheck_l199_d13_url(dsl, ruby.string_value('https://brew.sh/${delegated}'))
	return dsl
}

// Ruby it `it "delegates `arch` in `livecheck` block to `package_or_resource`", metadata do` at line 247.
pub fn ruby_livecheck_spec_l247_d33_delegates(args ...ruby.Value) ruby.Value {
	_ = args
	for arch in ['arm', 'intel'] {
		dsl := ruby_livecheck_spec_l226_d32_c_arch(ruby.string_value(arch))
		if homebrew.ruby_livecheck_l199_d13_url(dsl).as_string() != 'https://brew.sh/${arch}' {
			return livecheck_spec_bool(false)
		}
	}
	return livecheck_spec_bool(true)
}

// Ruby let `let(:c_os) do` at line 254.
pub fn ruby_livecheck_spec_l254_d34_c_os(args ...ruby.Value) ruby.Value {
	operating_system := if args.len > 0 { args[0].as_string() } else { 'macos' }
	package := livecheck_spec_package('Cask', 'c-os', '0.0.1', '', operating_system)
	mut dsl := livecheck_spec_livecheck(package)
	delegated := homebrew.ruby_livecheck_l235_d16_os(dsl).as_string()
	dsl = homebrew.ruby_livecheck_l199_d13_url(dsl, ruby.string_value('https://brew.sh/${delegated}'))
	return dsl
}

// Ruby it `it "delegates `os` in `livecheck` block to `package_or_resource`", metadata do` at line 275.
pub fn ruby_livecheck_spec_l275_d35_delegates(args ...ruby.Value) ruby.Value {
	_ = args
	for operating_system in ['macos', 'linux'] {
		dsl := ruby_livecheck_spec_l254_d34_c_os(ruby.string_value(operating_system))
		if homebrew.ruby_livecheck_l199_d13_url(dsl).as_string() != 'https://brew.sh/${operating_system}' {
			return livecheck_spec_bool(false)
		}
	}
	return livecheck_spec_bool(true)
}

// Ruby let `let(:url_with_version) { "https://brew.sh/0.0.1" }` at line 282.
pub fn ruby_livecheck_spec_l282_d36_url_with_version(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('https://brew.sh/0.0.1')
}

// Ruby let `let(:f_version) do` at line 284.
pub fn ruby_livecheck_spec_l284_d37_f_version(args ...ruby.Value) ruby.Value {
	_ = args
	return livecheck_spec_with_version('FormulaClass')
}

// Ruby let `let(:c_version) do` at line 296.
pub fn ruby_livecheck_spec_l296_d38_c_version(args ...ruby.Value) ruby.Value {
	_ = args
	return livecheck_spec_with_version('Cask')
}

// Ruby let `let(:r_version) do` at line 311.
pub fn ruby_livecheck_spec_l311_d39_r_version(args ...ruby.Value) ruby.Value {
	_ = args
	return livecheck_spec_with_version('Resource')
}

// Ruby it `it "delegates `version` in `livecheck` block to `package_or_resource`" do` at line 321.
pub fn ruby_livecheck_spec_l321_d40_delegates(args ...ruby.Value) ruby.Value {
	_ = args
	expected := ruby_livecheck_spec_l282_d36_url_with_version().as_string()
	for dsl in [
		ruby_livecheck_spec_l284_d37_f_version(),
		ruby_livecheck_spec_l296_d38_c_version(),
		ruby_livecheck_spec_l311_d39_r_version(),
	] {
		if homebrew.ruby_livecheck_l199_d13_url(dsl).as_string() != expected {
			return livecheck_spec_bool(false)
		}
	}
	return livecheck_spec_bool(true)
}

// Ruby it `it "returns a Hash of all instance variables" do` at line 329.
pub fn ruby_livecheck_spec_l329_d41_returns(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_livecheck_l241_d18_to_hash(livecheck_spec_livecheck(livecheck_spec_formula()))
	values := result.map_data.clone()
	if values.len != 10 || (values['options'] or { livecheck_spec_nil() }).map_data.len != 0 || (values['skip'] or { ruby.bool_value(true) }).type_name != 'Bool' || (values['skip'] or { ruby.bool_value(true) }).bool_data {
		return livecheck_spec_bool(false)
	}
	for key in ['cask', 'formula', 'regex', 'skip_msg', 'strategy', 'throttle', 'throttle_days',
		'url'] {
		if (values[key] or { ruby.string_value('set') }).type_name != 'NilClass' {
			return livecheck_spec_bool(false)
		}
	}
	return livecheck_spec_bool(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "livecheck"
// 6:
// 7: RSpec.describe Livecheck do
// 8:   let(:f) do
// 9:     formula do
// 10:       T.bind(self, T.class_of(Formula))
// 11:       homepage "https://brew.sh"
// 12:       url "https://brew.sh/test-0.0.1.tgz"
// 13:       head "https://github.com/Homebrew/brew.git", branch: "main"
// 14:     end
// 15:   end
// 16:   let(:livecheck_f) { described_class.new(f.class) }
// 17:
// 18:   let(:c) do
// 19:     Cask::CaskLoader.load(+<<-RUBY)
// 20:       cask "test" do
// 21:         version "0.0.1,2"
// 22:
// 23:         url "https://brew.sh/test-0.0.1.dmg"
// 24:         name "Test"
// 25:         desc "Test cask"
// 26:         homepage "https://brew.sh"
// 27:       end
// 28:     RUBY
// 29:   end
// 30:   let(:livecheck_c) { described_class.new(c) }
// 31:
// 32:   let(:post_hash) do
// 33:     {
// 34:       empty:   "",
// 35:       boolean: "true",
// 36:       number:  "1",
// 37:       string:  "a + b = c",
// 38:     }
// 39:   end
// 40:
// 41:   describe "#formula" do
// 42:     it "returns nil if not set" do
// 43:       expect(livecheck_f.formula).to be_nil
// 44:     end
// 45:
// 46:     it "returns the String if set" do
// 47:       livecheck_f.formula("other-formula")
// 48:       expect(livecheck_f.formula).to eq("other-formula")
// 49:     end
// 50:   end
// 51:
// 52:   describe "#cask" do
// 53:     it "returns nil if not set" do
// 54:       expect(livecheck_c.cask).to be_nil
// 55:     end
// 56:
// 57:     it "returns the String if set" do
// 58:       livecheck_c.cask("other-cask")
// 59:       expect(livecheck_c.cask).to eq("other-cask")
// 60:     end
// 61:   end
// 62:
// 63:   describe "#regex" do
// 64:     it "returns nil if not set" do
// 65:       expect(livecheck_f.regex).to be_nil
// 66:     end
// 67:
// 68:     it "returns the Regexp if set" do
// 69:       livecheck_f.regex(/foo/)
// 70:       expect(livecheck_f.regex).to eq(/foo/)
// 71:     end
// 72:   end
// 73:
// 74:   describe "#skip" do
// 75:     it "sets @skip to true when no argument is provided" do
// 76:       expect(livecheck_f.skip).to be true
// 77:       expect(livecheck_f.skip?).to be true
// 78:       expect(livecheck_f.skip_msg).to be_nil
// 79:     end
// 80:
// 81:     it "sets @skip to true and @skip_msg to the provided String" do
// 82:       expect(livecheck_f.skip("foo")).to be true
// 83:       expect(livecheck_f.skip?).to be true
// 84:       expect(livecheck_f.skip_msg).to eq("foo")
// 85:     end
// 86:   end
// 87:
// 88:   describe "#skip?" do
// 89:     it "returns the value of @skip" do
// 90:       expect(livecheck_f.skip?).to be false
// 91:
// 92:       livecheck_f.skip
// 93:       expect(livecheck_f.skip?).to be true
// 94:     end
// 95:   end
// 96:
// 97:   describe "#strategy" do
// 98:     let(:block) do
// 99:       proc { |page, regex| page.scan(regex).map { |match| match[0].tr("_", ".") } }
// 100:     end
// 101:
// 102:     it "returns nil if not set" do
// 103:       expect(livecheck_f.strategy).to be_nil
// 104:       expect(livecheck_f.strategy_block).to be_nil
// 105:     end
// 106:
// 107:     it "returns the Symbol if set" do
// 108:       livecheck_f.strategy(:page_match)
// 109:       expect(livecheck_f.strategy).to eq(:page_match)
// 110:       expect(livecheck_f.strategy_block).to be_nil
// 111:     end
// 112:
// 113:     it "sets `strategy_block` when provided" do
// 114:       livecheck_f.strategy(:page_match, &block)
// 115:       expect(livecheck_f.strategy).to eq(:page_match)
// 116:       expect(livecheck_f.strategy_block).to eq(block)
// 117:     end
// 118:   end
// 119:
// 120:   describe "#throttle" do
// 121:     it "returns nil if not set" do
// 122:       expect(livecheck_f.throttle).to be_nil
// 123:     end
// 124:
// 125:     it "returns the Integer if set" do
// 126:       livecheck_f.throttle(10)
// 127:       expect(livecheck_f.throttle).to eq(10)
// 128:     end
// 129:
// 130:     it "sets @throttle_days to provided Integer" do
// 131:       livecheck_f.throttle(days: 1)
// 132:       expect(livecheck_f.throttle_days).to eq(1)
// 133:     end
// 134:   end
// 135:
// 136:   describe "#url" do
// 137:     let(:url_string) { "https://brew.sh" }
// 138:     let(:referer_url) { "https://example.com/referer" }
// 139:
// 140:     it "returns nil if not set" do
// 141:       expect(livecheck_f.url).to be_nil
// 142:     end
// 143:
// 144:     it "returns a string when set to a string" do
// 145:       livecheck_f.url(url_string)
// 146:       expect(livecheck_f.url).to eq(url_string)
// 147:     end
// 148:
// 149:     it "returns the URL symbol if valid" do
// 150:       livecheck_f.url(:head)
// 151:       expect(livecheck_f.url).to eq(:head)
// 152:
// 153:       livecheck_f.url(:homepage)
// 154:       expect(livecheck_f.url).to eq(:homepage)
// 155:
// 156:       livecheck_f.url(:stable)
// 157:       expect(livecheck_f.url).to eq(:stable)
// 158:
// 159:       livecheck_c.url(:url)
// 160:       expect(livecheck_c.url).to eq(:url)
// 161:     end
// 162:
// 163:     it "sets `url` options when provided" do
// 164:       cookies = { "cookie_key" => "cookie_value" }
// 165:       header_str = "Accept: */*"
// 166:
// 167:       # This test makes sure that we can set multiple options at once and
// 168:       # options from subsequent `url` calls are merged with existing values
// 169:       # (i.e. existing values aren't reset to `nil`). [We only call `url` once
// 170:       # in a `livecheck` block but this should technically work due to how it's
// 171:       # implemented.]
// 172:       livecheck_f.url(
// 173:         url_string,
// 174:         compressed:    false,
// 175:         cookies:,
// 176:         header:        header_str,
// 177:         homebrew_curl: true,
// 178:         post_form:     post_hash,
// 179:         referer:       referer_url,
// 180:         user_agent:    :browser,
// 181:       )
// 182:       livecheck_f.url(url_string, post_json: post_hash)
// 183:       expect(livecheck_f.options.compressed).to be(false)
// 184:       expect(livecheck_f.options.cookies).to eq(cookies)
// 185:       expect(livecheck_f.options.header).to eq(header_str)
// 186:       expect(livecheck_f.options.homebrew_curl).to be(true)
// 187:       expect(livecheck_f.options.post_form).to eq(post_hash)
// 188:       expect(livecheck_f.options.post_json).to eq(post_hash)
// 189:       expect(livecheck_f.options.referer).to eq(referer_url)
// 190:       expect(livecheck_f.options.user_agent).to eq(:browser)
// 191:
// 192:       header_array = ["Accept: */*", "X-Requested-With: XMLHttpRequest"]
// 193:       livecheck_f.url(url_string, header: header_array)
// 194:       expect(livecheck_f.options.header).to eq(header_array)
// 195:
// 196:       livecheck_f.url(url_string, user_agent: "Example")
// 197:       expect(livecheck_f.options.user_agent).to eq("Example")
// 198:     end
// 199:
// 200:     it "raises an ArgumentError if the argument isn't a valid Symbol" do
// 201:       expect do
// 202:         livecheck_f.url(:not_a_valid_symbol)
// 203:       end.to raise_error ArgumentError
// 204:     end
// 205:
// 206:     it "raises an ArgumentError if `compressed: true` argument is provided" do
// 207:       expect do
// 208:         livecheck_f.url(:stable, compressed: true)
// 209:       end.to raise_error ArgumentError
// 210:     end
// 211:
// 212:     it "raises an ArgumentError if `homebrew_curl: false` argument is provided" do
// 213:       expect do
// 214:         livecheck_f.url(:stable, homebrew_curl: false)
// 215:       end.to raise_error ArgumentError
// 216:     end
// 217:
// 218:     it "raises an ArgumentError if both `post_form` and `post_json` arguments are provided" do
// 219:       expect do
// 220:         livecheck_f.url(:stable, post_form: post_hash, post_json: post_hash)
// 221:       end.to raise_error ArgumentError
// 222:     end
// 223:   end
// 224:
// 225:   describe "#arch" do
// 226:     let(:c_arch) do
// 227:       Cask::Cask.new("c-arch") do
// 228:         arch arm: "arm", intel: "intel"
// 229:
// 230:         version "0.0.1"
// 231:
// 232:         url "https://brew.sh/test-0.0.1.dmg"
// 233:         name "Test"
// 234:         desc "Test cask"
// 235:         homepage "https://brew.sh"
// 236:
// 237:         livecheck do
// 238:           url "https://brew.sh/#{arch}"
// 239:         end
// 240:       end
// 241:     end
// 242:
// 243:     test_each_hash({
// 244:       needs_arm:   "arm",
// 245:       needs_intel: "intel",
// 246:     }) do |metadata, expected_arch|
// 247:       it "delegates `arch` in `livecheck` block to `package_or_resource`", metadata do
// 248:         expect(c_arch.livecheck.url).to eq("https://brew.sh/#{expected_arch}")
// 249:       end
// 250:     end
// 251:   end
// 252:
// 253:   describe "#os" do
// 254:     let(:c_os) do
// 255:       Cask::Cask.new("c-os") do
// 256:         os macos: "macos", linux: "linux"
// 257:
// 258:         version "0.0.1"
// 259:
// 260:         url "https://brew.sh/test-0.0.1.dmg"
// 261:         name "Test"
// 262:         desc "Test cask"
// 263:         homepage "https://brew.sh"
// 264:
// 265:         livecheck do
// 266:           url "https://brew.sh/#{os}"
// 267:         end
// 268:       end
// 269:     end
// 270:
// 271:     test_each_hash({
// 272:       needs_macos: "macos",
// 273:       needs_linux: "linux",
// 274:     }) do |metadata, expected_os|
// 275:       it "delegates `os` in `livecheck` block to `package_or_resource`", metadata do
// 276:         expect(c_os.livecheck.url).to eq("https://brew.sh/#{expected_os}")
// 277:       end
// 278:     end
// 279:   end
// 280:
// 281:   describe "#version" do
// 282:     let(:url_with_version) { "https://brew.sh/0.0.1" }
// 283:
// 284:     let(:f_version) do
// 285:       formula do
// 286:         T.bind(self, T.class_of(Formula))
// 287:         homepage "https://brew.sh"
// 288:         url "https://brew.sh/test-0.0.1.tgz"
// 289:
// 290:         livecheck do
// 291:           url "https://brew.sh/#{version}"
// 292:         end
// 293:       end
// 294:     end
// 295:
// 296:     let(:c_version) do
// 297:       Cask::Cask.new("c-version") do
// 298:         version "0.0.1"
// 299:
// 300:         url "https://brew.sh/test-0.0.1.dmg"
// 301:         name "Test"
// 302:         desc "Test cask"
// 303:         homepage "https://brew.sh"
// 304:
// 305:         livecheck do
// 306:           url "https://brew.sh/#{version}"
// 307:         end
// 308:       end
// 309:     end
// 310:
// 311:     let(:r_version) do
// 312:       Resource.new do
// 313:         url "https://brew.sh/test-0.0.1.tgz"
// 314:
// 315:         livecheck do
// 316:           url "https://brew.sh/#{version}"
// 317:         end
// 318:       end
// 319:     end
// 320:
// 321:     it "delegates `version` in `livecheck` block to `package_or_resource`" do
// 322:       expect(f_version.livecheck.url).to eq(url_with_version)
// 323:       expect(c_version.livecheck.url).to eq(url_with_version)
// 324:       expect(r_version.livecheck.url).to eq(url_with_version)
// 325:     end
// 326:   end
// 327:
// 328:   describe "#to_hash" do
// 329:     it "returns a Hash of all instance variables" do
// 330:       expect(livecheck_f.to_hash).to eq(
// 331:         {
// 332:           "options"       => Homebrew::Livecheck::Options.new.to_hash,
// 333:           "cask"          => nil,
// 334:           "formula"       => nil,
// 335:           "regex"         => nil,
// 336:           "skip"          => false,
// 337:           "skip_msg"      => nil,
// 338:           "strategy"      => nil,
// 339:           "throttle"      => nil,
// 340:           "throttle_days" => nil,
// 341:           "url"           => nil,
// 342:         },
// 343:       )
// 344:     end
// 345:   end
// 346: end
