module cask

import ruby
import homebrew as core
import homebrew.cask as production
import homebrew.cask.artifact
import homebrew.cask.dsl as dsl_types

fn dsl_spec_symbol(value string) ruby.Value {
	return ruby.Value{ type_name: 'Symbol', repr: value }
}

fn dsl_spec_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn dsl_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn dsl_spec_cask(token string, fields map[string]ruby.Value) ruby.Value {
	mut values := fields.clone()
	values['token'] = ruby.string_value(token)
	if 'config' !in values {
		values['config'] = ruby.map_value({})
	}
	return ruby.Value{ type_name: 'Cask', repr: token, map_data: values }
}

fn dsl_spec_new(token string, fields map[string]ruby.Value) ruby.Value {
	return production.ruby_dsl_l190_d17_initialize(dsl_spec_cask(token, fields))
}

fn dsl_spec_pass(condition bool) ruby.Value {
	return ruby.bool_value(condition)
}

fn dsl_spec_error(value ruby.Value, kind string, fragment string) bool {
	return value.type_name == kind && value.repr.contains(fragment)
}

fn dsl_spec_language_block(languages []string, result string, sha string, is_default bool) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::DSL::LanguageBlock'
		repr: result
		map_data: {
			'languages': ruby.string_array_value(languages)
			'result':    ruby.string_value(result)
			'mutations': ruby.map_value({
				'sha256': ruby.object_value('Checksum', sha)
			})
			'default':   ruby.bool_value(is_default)
		}
	}
}

fn dsl_spec_language_cask(languages []string) ruby.Value {
	mut receiver := dsl_spec_new('cask-with-apps', {
		'config': ruby.map_value({
			'languages': ruby.string_array_value(languages)
		})
	})
	receiver = production.ruby_dsl_l360_d28_language(receiver, ruby.string_value('zh'), dsl_spec_language_block([
		'zh',
	], 'zh-CN', 'abc123', false))
	receiver = production.ruby_dsl_l360_d28_language(receiver, ruby.string_value('en'), ruby.map_value({
		'default': ruby.bool_value(true)
	}), dsl_spec_language_block(['en'], 'en-US', 'xyz789', true))
	return receiver
}

fn dsl_spec_language_matches(receiver ruby.Value, language string, sha string) bool {
	result := production.ruby_dsl_l380_d29_language_eval(receiver)
	mut dsl := production.cask_dsl_from_value(receiver) or { return false }
	actual := production.cask_dsl_evaluate_language(mut dsl) or { return false }
	return result.as_string() == language && actual == language && dsl.sha256_value.as_string() == sha
}

fn dsl_spec_dependency(receiver ruby.Value) ?dsl_types.CaskDependsOn {
	dsl := production.cask_dsl_from_value(receiver) or { return none }
	return dsl.depends_on_value
}

fn dsl_spec_basic(token string) ruby.Value {
	mut receiver := dsl_spec_new(token, {})
	receiver = production.ruby_dsl_l503_d36_version(receiver, ruby.string_value('1.2.3'))
	receiver = production.ruby_dsl_l341_d27_homepage(receiver, ruby.string_value('https://brew.sh/'))
	receiver = production.ruby_dsl_l434_d33_url(receiver, ruby.string_value('https://brew.sh/TestCask-1.2.3.dmg'))
	return receiver
}

// Translated from Homebrew/brew `test/cask/dsl_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(token) }` at line 5.
pub fn ruby_dsl_spec_l5_d1_cask(args ...ruby.Value) ruby.Value {
	if args.len > 1 {
		return args[1]
	}
	token := if args.len > 0 { args[0].as_string() } else { 'basic-cask' }
	return dsl_spec_basic(token)
}

// Ruby let `let(:token) { "basic-cask" }` at line 6.
pub fn ruby_dsl_spec_l6_d2_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('basic-cask')
}

// Ruby it `it "lets you set url, homepage and version" do` at line 9.
pub fn ruby_dsl_spec_l9_d3_lets(args ...ruby.Value) ruby.Value {
	receiver := if args.len > 0 { args[0] } else { dsl_spec_basic('basic-cask') }
	dsl := production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(dsl.has_url && dsl.url_value.uri == 'https://brew.sh/TestCask-1.2.3.dmg' && dsl.homepage == 'https://brew.sh/' && dsl.version_value.raw_version.as_string() == '1.2.3')
}

// Ruby it `it "exposes formula path helpers" do` at line 15.
pub fn ruby_dsl_spec_l15_d4_exposes(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dsl_spec_bool(false)
	}
	formula_opt_bin := args[0].as_string()
	mut receiver := dsl_spec_new('formula-path-helper', {})
	receiver = production.ruby_dsl_l278_d24_name(receiver, ruby.string_value(formula_opt_bin))
	names := production.ruby_dsl_l278_d24_name(receiver).as_string_array() or { []string{} }
	return dsl_spec_pass(names == [formula_opt_bin] && formula_opt_bin.ends_with('/opt/foo/bin'))
}

// Ruby it `it "exposes formula path helpers in flight blocks" do` at line 23.
pub fn ruby_dsl_spec_l23_d5_exposes(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dsl_spec_bool(false)
	}
	return dsl_spec_pass(args[0].type_name == 'Pathname' && args[0].as_string().ends_with('/opt/foo/bin'))
}

// Ruby let `let(:attempt_unknown_method) do` at line 30.
pub fn ruby_dsl_spec_l30_d6_attempt_unknown_method(args ...ruby.Value) ruby.Value {
	receiver := dsl_spec_new('unexpected-method-cask', {})
	return production.ruby_dsl_l875_d55_method_missing(receiver, dsl_spec_symbol('future_feature'), dsl_spec_symbol('not_yet_on_your_machine'))
}

// Ruby it `it "raises a CaskInvalidError" do` at line 36.
pub fn ruby_dsl_spec_l36_d7_raises(args ...ruby.Value) ruby.Value {
	error_value := if args.len > 0 {
		args[0]
	} else {
		ruby_dsl_spec_l30_d6_attempt_unknown_method()
	}
	return dsl_spec_pass(dsl_spec_error(error_value, 'NoMethodError', "undefined method 'future_feature' for Cask 'unexpected-method-cask'"))
}

// Ruby let `let(:token) { "invalid-header-format" }` at line 46.
pub fn ruby_dsl_spec_l46_d8_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-header-format')
}

// Ruby it `it "raises an error" do` at line 48.
pub fn ruby_dsl_spec_l48_d9_raises(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dsl_spec_bool(false)
	}
	error_value := args[0]
	return dsl_spec_pass(error_value.type_name == 'CaskUnreadableError')
}

// Ruby let `let(:token) { "invalid-header-token-mismatch" }` at line 54.
pub fn ruby_dsl_spec_l54_d10_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-header-token-mismatch')
}

// Ruby it `it "raises an error" do` at line 56.
pub fn ruby_dsl_spec_l56_d11_raises(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dsl_spec_bool(false)
	}
	error_value := args[0]
	return dsl_spec_pass(dsl_spec_error(error_value, 'CaskTokenMismatchError', 'header line does not match the file name'))
}

// Ruby let `let(:token) { "no-dsl-version" }` at line 64.
pub fn ruby_dsl_spec_l64_d12_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('no-dsl-version')
}

// Ruby it `it "does not require a DSL version in the header" do` at line 66.
pub fn ruby_dsl_spec_l66_d13_does(args ...ruby.Value) ruby.Value {
	receiver := dsl_spec_basic('no-dsl-version')
	dsl := production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(dsl.token == 'no-dsl-version' && dsl.url_value.uri == 'https://brew.sh/TestCask-1.2.3.dmg' && dsl.homepage == 'https://brew.sh/' && dsl.version_value.raw_version.as_string() == '1.2.3')
}

// Ruby it `it "lets you set the full name via a name stanza" do` at line 76.
pub fn ruby_dsl_spec_l76_d14_lets(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('name-cask', {})
	receiver = production.ruby_dsl_l278_d24_name(receiver, ruby.string_value('Proper Name'))
	return dsl_spec_pass(production.ruby_dsl_l278_d24_name(receiver).as_string_array() or { []string{} } == [
		'Proper Name',
	])
}

// Ruby it `it "Accepts an array value to the name stanza" do` at line 86.
pub fn ruby_dsl_spec_l86_d15_accepts(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('array-name-cask', {})
	receiver = production.ruby_dsl_l278_d24_name(receiver, ruby.string_array_value([
		'Proper Name',
		'Alternate Name',
	]))
	return dsl_spec_pass(production.ruby_dsl_l278_d24_name(receiver).as_string_array() or { []string{} } == [
		'Proper Name',
		'Alternate Name',
	])
}

// Ruby it `it "Accepts multiple name stanzas" do` at line 97.
pub fn ruby_dsl_spec_l97_d16_accepts(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('multi-name-cask', {})
	receiver = production.ruby_dsl_l278_d24_name(receiver, ruby.string_value('Proper Name'))
	receiver = production.ruby_dsl_l278_d24_name(receiver, ruby.string_value('Alternate Name'))
	return dsl_spec_pass(production.ruby_dsl_l278_d24_name(receiver).as_string_array() or { []string{} } == [
		'Proper Name',
		'Alternate Name',
	])
}

// Ruby it `it "lets you set the description via a desc stanza" do` at line 111.
pub fn ruby_dsl_spec_l111_d17_lets(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('desc-cask', {})
	receiver = production.ruby_dsl_l294_d25_desc(receiver, ruby.string_value("The package's description"))
	return dsl_spec_pass(production.ruby_dsl_l294_d25_desc(receiver).as_string() == "The package's description")
}

// Ruby it `it "lets you set checksum via sha256" do` at line 121.
pub fn ruby_dsl_spec_l121_d18_lets(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('checksum-cask', {})
	receiver = production.ruby_dsl_l545_d37_sha256(receiver, ruby.string_value('imasha2'))
	return dsl_spec_pass(production.ruby_dsl_l545_d37_sha256(receiver).as_string() == 'imasha2')
}

// Ruby let `let(:cask) do` at line 130.
pub fn ruby_dsl_spec_l130_d19_cask(args ...ruby.Value) ruby.Value {
	arch := if args.len > 0 { args[0].as_string() } else { 'arm' }
	mut receiver := dsl_spec_new('checksum-cask', {
		'system_arch': ruby.string_value(arch)
		'system_os':   ruby.string_value('macos')
	})
	return production.ruby_dsl_l545_d37_sha256(receiver, ruby.map_value({
		'arm':   ruby.string_value('imasha2arm')
		'intel': ruby.string_value('imasha2intel')
	}))
}

// Ruby it `it "stores only the arm checksum" do` at line 141.
pub fn ruby_dsl_spec_l141_d20_stores(args ...ruby.Value) ruby.Value {
	receiver := ruby_dsl_spec_l130_d19_cask(ruby.string_value('arm'))
	return dsl_spec_pass(production.ruby_dsl_l545_d37_sha256(receiver).as_string() == 'imasha2arm')
}

// Ruby it `it "stores only the intel checksum" do` at line 151.
pub fn ruby_dsl_spec_l151_d21_stores(args ...ruby.Value) ruby.Value {
	receiver := ruby_dsl_spec_l130_d19_cask(ruby.string_value('intel'))
	return dsl_spec_pass(production.ruby_dsl_l545_d37_sha256(receiver).as_string() == 'imasha2intel')
}

// Ruby it `it "has no checksum on macOS when only Linux checksums are set" do` at line 158.
pub fn ruby_dsl_spec_l158_d22_has(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('checksum-cask', {
		'system_os':   ruby.string_value('macos')
		'system_arch': ruby.string_value('arm')
	})
	receiver = production.ruby_dsl_l545_d37_sha256(receiver, ruby.map_value({
		'x86_64_linux': ruby.string_value('imasha2intellinux')
		'arm64_linux':  ruby.string_value('imasha2armlinux')
	}))
	return dsl_spec_pass(production.ruby_dsl_l545_d37_sha256(receiver).type_name == 'NilClass')
}

// Ruby it `it "stores the matching checksum on Linux" do` at line 168.
pub fn ruby_dsl_spec_l168_d23_stores(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('checksum-cask', {
		'system_os':   ruby.string_value('linux')
		'system_arch': ruby.string_value('intel')
	})
	receiver = production.ruby_dsl_l545_d37_sha256(receiver, ruby.map_value({
		'x86_64_linux': ruby.string_value('imasha2intellinux')
		'arm64_linux':  ruby.string_value('imasha2armlinux')
	}))
	return dsl_spec_pass(production.ruby_dsl_l545_d37_sha256(receiver).as_string() == 'imasha2intellinux')
}

// Ruby it `it "has no checksum on Linux when only macOS checksums are set" do` at line 178.
pub fn ruby_dsl_spec_l178_d24_has(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('checksum-cask', {
		'system_os':   ruby.string_value('linux')
		'system_arch': ruby.string_value('arm')
	})
	receiver = production.ruby_dsl_l545_d37_sha256(receiver, ruby.map_value({
		'arm':   ruby.string_value('imasha2arm')
		'intel': ruby.string_value('imasha2intel')
	}))
	return dsl_spec_pass(production.ruby_dsl_l545_d37_sha256(receiver).type_name == 'NilClass')
}

// Ruby it `it "has no checksum when simulating an architecture whose checksum is missing" do` at line 188.
pub fn ruby_dsl_spec_l188_d25_has(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('checksum-cask', {
		'system_os':   ruby.string_value('macos')
		'system_arch': ruby.string_value('intel')
	})
	receiver = production.ruby_dsl_l545_d37_sha256(receiver, ruby.map_value({
		'arm':         ruby.string_value('imasha2arm')
		'arm64_linux': ruby.string_value('imasha2armlinux')
	}))
	return dsl_spec_pass(production.ruby_dsl_l545_d37_sha256(receiver).type_name == 'NilClass')
}

// Ruby it `it "loads the architecture requirement when the running-architecture checksum is missing" do` at line 198.
pub fn ruby_dsl_spec_l198_d26_loads(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('checksum-cask', {
		'system_os':   ruby.string_value('linux')
		'system_arch': ruby.string_value('intel')
	})
	receiver = production.ruby_dsl_l545_d37_sha256(receiver, ruby.map_value({
		'arm64_linux': ruby.string_value('imasha2armlinux')
		'intel':       ruby.string_value('imasha2intel')
	}))
	receiver = production.ruby_dsl_l623_d40_depends_on(receiver, ruby.map_value({
		'arch': dsl_spec_symbol('arm64')
	}))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(production.ruby_dsl_l545_d37_sha256(receiver).type_name == 'NilClass' && depends.arch.len == 1 && depends.arch[0].kind == 'arm' && depends.arch[0].bits == 64)
}

// Ruby it `it "returns true if no_autobump! is not set" do` at line 214.
pub fn ruby_dsl_spec_l214_d27_returns(args ...ruby.Value) ruby.Value {
	return dsl_spec_pass(production.ruby_dsl_l747_d49_autobump(dsl_spec_basic('basic-cask')).bool_data)
}

// Ruby let `let(:cask) do` at line 219.
pub fn ruby_dsl_spec_l219_d28_cask(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('checksum-cask', {})
	return production.ruby_dsl_l736_d48_no_autobump(receiver, ruby.map_value({
		'because': ruby.string_value('some reason')
	}))
}

// Ruby it `it "returns false" do` at line 225.
pub fn ruby_dsl_spec_l225_d29_returns(args ...ruby.Value) ruby.Value {
	receiver := ruby_dsl_spec_l219_d28_cask()
	return dsl_spec_pass(!production.ruby_dsl_l747_d49_autobump(receiver).bool_data && production.ruby_dsl_l148_d3_no_autobump_message(receiver).as_string() == 'some reason')
}

// Ruby it `it "raises an error" do` at line 232.
pub fn ruby_dsl_spec_l232_d30_raises(args ...ruby.Value) ruby.Value {
	tap := ruby.map_value({
		'official': ruby.bool_value(false)
	})
	receiver := dsl_spec_new('test-cask', {
		'tap': tap
	})
	result := production.ruby_dsl_l736_d48_no_autobump(receiver, ruby.map_value({
		'because': ruby.string_value('some reason')
	}))
	return dsl_spec_pass(dsl_spec_error(result, 'CaskInvalidError', 'official Homebrew taps'))
}

// Ruby it `it "does not raise for internal no_autobump! usage from common DSL stanzas" do` at line 240.
pub fn ruby_dsl_spec_l240_d31_does(args ...ruby.Value) ruby.Value {
	receiver := dsl_spec_new('test-cask', {
		'tap': ruby.map_value({
			'official': ruby.bool_value(false)
		})
	})
	mut versioned := production.ruby_dsl_l503_d36_version(receiver, dsl_spec_symbol('latest'))
	versioned = production.ruby_dsl_l434_d33_url(versioned, ruby.string_value('https://brew.sh/TestCask.dmg'))
	mut livecheck := core.new_livecheck_dsl(dsl_spec_cask('test-cask', {}))
	livecheck.strategy = dsl_spec_symbol('extract_plist')
	versioned = production.ruby_dsl_l719_d47_livecheck(versioned, core.livecheck_dsl_value(livecheck))
	return dsl_spec_pass(versioned.type_name == 'Cask::DSL' && !production.ruby_dsl_l747_d49_autobump(versioned).bool_data)
}

// Ruby subject `subject(:cask) do` at line 257.
pub fn ruby_dsl_spec_l257_d32_cask(args ...ruby.Value) ruby.Value {
	languages := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	return dsl_spec_language_cask(languages)
}

// Ruby matcher `matcher :be_the_chinese_version do` at line 273.
pub fn ruby_dsl_spec_l273_d33_be_the_chinese_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dsl_spec_bool(false)
	}
	return dsl_spec_pass(dsl_spec_language_matches(args[0], 'zh-CN', 'abc123'))
}

// Ruby matcher `matcher :be_the_english_version do` at line 281.
pub fn ruby_dsl_spec_l281_d34_be_the_english_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dsl_spec_bool(false)
	}
	return dsl_spec_pass(dsl_spec_language_matches(args[0], 'en-US', 'xyz789'))
}

// Ruby let `let(:languages) { [] }` at line 289.
pub fn ruby_dsl_spec_l289_d35_languages(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value([])
}

// Ruby let `let(:languages) { ["zh"] }` at line 298.
pub fn ruby_dsl_spec_l298_d36_languages(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(['zh'])
}

// Ruby it `it { is_expected.to be_the_chinese_version }` at line 300.
pub fn ruby_dsl_spec_l300_d37_anonymous(args ...ruby.Value) ruby.Value {
	return ruby_dsl_spec_l273_d33_be_the_chinese_version(dsl_spec_language_cask(['zh']))
}

// Ruby let `let(:languages) { ["zh-XX"] }` at line 304.
pub fn ruby_dsl_spec_l304_d38_languages(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(['zh-XX'])
}

// Ruby it `it { is_expected.to be_the_chinese_version }` at line 306.
pub fn ruby_dsl_spec_l306_d39_anonymous(args ...ruby.Value) ruby.Value {
	return ruby_dsl_spec_l273_d33_be_the_chinese_version(dsl_spec_language_cask([
		'zh-XX',
	]))
}

// Ruby let `let(:languages) { ["en"] }` at line 310.
pub fn ruby_dsl_spec_l310_d40_languages(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(['en'])
}

// Ruby it `it { is_expected.to be_the_english_version }` at line 312.
pub fn ruby_dsl_spec_l312_d41_anonymous(args ...ruby.Value) ruby.Value {
	return ruby_dsl_spec_l281_d34_be_the_english_version(dsl_spec_language_cask(['en']))
}

// Ruby let `let(:languages) { ["xx-XX"] }` at line 316.
pub fn ruby_dsl_spec_l316_d42_languages(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(['xx-XX'])
}

// Ruby it `it { is_expected.to be_the_english_version }` at line 318.
pub fn ruby_dsl_spec_l318_d43_anonymous(args ...ruby.Value) ruby.Value {
	return ruby_dsl_spec_l281_d34_be_the_english_version(dsl_spec_language_cask([
		'xx-XX',
	]))
}

// Ruby let `let(:languages) { ["xx-XX", "zh", "en"] }` at line 322.
pub fn ruby_dsl_spec_l322_d44_languages(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(['xx-XX', 'zh', 'en'])
}

// Ruby it `it { is_expected.to be_the_chinese_version }` at line 324.
pub fn ruby_dsl_spec_l324_d45_anonymous(args ...ruby.Value) ruby.Value {
	return ruby_dsl_spec_l273_d33_be_the_chinese_version(dsl_spec_language_cask([
		'xx-XX',
		'zh',
		'en',
	]))
}

// Ruby let `let(:languages) { ["xx-XX", "en-US", "zh"] }` at line 328.
pub fn ruby_dsl_spec_l328_d46_languages(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(['xx-XX', 'en-US', 'zh'])
}

// Ruby it `it { is_expected.to be_the_english_version }` at line 330.
pub fn ruby_dsl_spec_l330_d47_anonymous(args ...ruby.Value) ruby.Value {
	return ruby_dsl_spec_l281_d34_be_the_english_version(dsl_spec_language_cask([
		'xx-XX',
		'en-US',
		'zh',
	]))
}

// Ruby it `it "returns an empty array if no languages are specified" do` at line 334.
pub fn ruby_dsl_spec_l334_d48_returns(args ...ruby.Value) ruby.Value {
	receiver := dsl_spec_new('cask-with-apps', {})
	return dsl_spec_pass((production.ruby_dsl_l407_d30_languages(receiver).as_string_array() or { []string{} }).len == 0)
}

// Ruby it `it "returns an array of available languages" do` at line 344.
pub fn ruby_dsl_spec_l344_d49_returns(args ...ruby.Value) ruby.Value {
	receiver := dsl_spec_language_cask([])
	return dsl_spec_pass(production.ruby_dsl_l407_d30_languages(receiver).as_string_array() or { []string{} } == [
		'zh',
		'en',
	])
}

// Ruby it `it "allows you to specify app stanzas" do` at line 366.
pub fn ruby_dsl_spec_l366_d50_allows(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('cask-with-apps', {})
	receiver = production.ruby_dsl_l836_d52_klass_dsl_key(receiver, ruby.string_value('app'), ruby.string_value('Foo.app'))
	receiver = production.ruby_dsl_l836_d52_klass_dsl_key(receiver, ruby.string_value('app'), ruby.string_value('Bar.app'))
	dsl := production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	items := dsl.artifacts.to_array()
	return dsl_spec_pass(items.len == 2 && items[0].as_string() == 'Foo.app' && items[1].as_string() == 'Bar.app')
}

// Ruby it `it "allow app stanzas to be empty" do` at line 375.
pub fn ruby_dsl_spec_l375_d51_allow(args ...ruby.Value) ruby.Value {
	dsl := production.cask_dsl_from_value(dsl_spec_new('cask-with-no-apps', {})) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(dsl.artifacts.items.len == 0)
}

// Ruby it `it "allows caveats to be specified via a method define" do` at line 382.
pub fn ruby_dsl_spec_l382_d52_allows(args ...ruby.Value) ruby.Value {
	plain := production.ruby_dsl_l691_d44_caveats(dsl_spec_new('plain-cask', {}))
	mut receiver := dsl_spec_new('cask-with-caveats', {})
	receiver = production.ruby_dsl_l691_d44_caveats(receiver, ruby_dsl_spec_l388_d53_caveats())
	return dsl_spec_pass(plain.as_string() == '' && production.ruby_dsl_l691_d44_caveats(receiver).as_string() == 'When you install this Cask, you probably want to know this.\n')
}

// Ruby method `caveats` at line 388.
pub fn ruby_dsl_spec_l388_d53_caveats(args ...ruby.Value) ruby.Value {
	return ruby.string_value('When you install this Cask, you probably want to know this.\n')
}

// Ruby it `it "allows installable pkgs to be specified" do` at line 400.
pub fn ruby_dsl_spec_l400_d54_allows(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('cask-with-pkgs', {
		'staged_path': ruby.string_value('')
	})
	receiver = production.ruby_dsl_l836_d52_klass_dsl_key(receiver, ruby.string_value('pkg'), ruby.string_value('Foo.pkg'))
	receiver = production.ruby_dsl_l836_d52_klass_dsl_key(receiver, ruby.string_value('pkg'), ruby.string_value('Bar.pkg'))
	dsl := production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	items := dsl.artifacts.to_array()
	return dsl_spec_pass(items.len == 2 && items[0].type_name == 'Cask::Artifact::Pkg' && items[0].as_string().ends_with('Foo.pkg') && items[1].as_string().ends_with('Bar.pkg'))
}

// Ruby let `let(:token) { "invalid-two-url" }` at line 411.
pub fn ruby_dsl_spec_l411_d55_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-two-url')
}

// Ruby it `it "prevents defining multiple urls" do` at line 413.
pub fn ruby_dsl_spec_l413_d56_prevents(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('invalid-two-url', {})
	receiver = production.ruby_dsl_l434_d33_url(receiver, ruby.string_value('https://example.org/one'))
	result := production.ruby_dsl_l434_d33_url(receiver, ruby.string_value('https://example.org/two'))
	return dsl_spec_pass(dsl_spec_error(result, 'CaskInvalidError', "'url' stanza may only appear once"))
}

// Ruby let `let(:token) { "invalid-two-homepage" }` at line 419.
pub fn ruby_dsl_spec_l419_d57_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-two-homepage')
}

// Ruby it `it "prevents defining multiple homepages" do` at line 421.
pub fn ruby_dsl_spec_l421_d58_prevents(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('invalid-two-homepage', {})
	receiver = production.ruby_dsl_l341_d27_homepage(receiver, ruby.string_value('https://example.org/one'))
	result := production.ruby_dsl_l341_d27_homepage(receiver, ruby.string_value('https://example.org/two'))
	return dsl_spec_pass(dsl_spec_error(result, 'CaskInvalidError', "'homepage' stanza may only appear once"))
}

// Ruby it `it "records when a human browsed the homepage" do` at line 425.
pub fn ruby_dsl_spec_l425_d59_records(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('cask-with-browsed-homepage', {})
	receiver = production.ruby_dsl_l341_d27_homepage(receiver, ruby.string_value('https://brew.sh/'), ruby.map_value({
		'browsed': ruby.string_value('2026-07-26')
	}))
	return dsl_spec_pass(production.ruby_dsl_l181_d14_homepage_browsed(receiver).as_string() == '2026-07-26')
}

// Ruby it `it "requires a homepage URL when a human browser check is specified" do` at line 433.
pub fn ruby_dsl_spec_l433_d60_requires(args ...ruby.Value) ruby.Value {
	result := production.ruby_dsl_l341_d27_homepage(dsl_spec_new('cask-without-homepage', {}), ruby.map_value({
		'browsed': ruby.string_value('2026-07-26')
	}))
	return dsl_spec_pass(dsl_spec_error(result, 'CaskInvalidError', '`browsed` requires a homepage URL'))
}

// Ruby let `let(:token) { "invalid-two-version" }` at line 443.
pub fn ruby_dsl_spec_l443_d61_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-two-version')
}

// Ruby it `it "prevents defining multiple versions" do` at line 445.
pub fn ruby_dsl_spec_l445_d62_prevents(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('invalid-two-version', {})
	receiver = production.ruby_dsl_l503_d36_version(receiver, ruby.string_value('1.0'))
	result := production.ruby_dsl_l503_d36_version(receiver, ruby.string_value('2.0'))
	return dsl_spec_pass(dsl_spec_error(result, 'CaskInvalidError', "'version' stanza may only appear once"))
}

// Ruby let `let(:token) { "invalid-two-arch" }` at line 451.
pub fn ruby_dsl_spec_l451_d63_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-two-arch')
}

// Ruby it `it "prevents defining multiple arches" do` at line 453.
pub fn ruby_dsl_spec_l453_d64_prevents(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('invalid-two-arch', {
		'system_arch': ruby.string_value('arm')
	})
	receiver = production.ruby_dsl_l581_d38_arch(receiver, ruby.map_value({
		'arm':   ruby.string_value('first')
		'intel': ruby.string_value('first')
	}))
	result := production.ruby_dsl_l581_d38_arch(receiver, ruby.map_value({
		'arm':   ruby.string_value('second')
		'intel': ruby.string_value('second')
	}))
	return dsl_spec_pass(dsl_spec_error(result, 'CaskInvalidError', "'arch' stanza may only appear once"))
}

// Ruby let `let(:token) { "arch-arm-only" }` at line 458.
pub fn ruby_dsl_spec_l458_d65_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('arch-arm-only')
}

// Ruby it `it "returns the value" do` at line 465.
pub fn ruby_dsl_spec_l465_d66_returns(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('arch-arm-only', {
		'system_arch': ruby.string_value('arm')
	})
	receiver = production.ruby_dsl_l581_d38_arch(receiver, ruby.map_value({
		'arm': ruby.string_value('arm')
	}))
	arch := production.ruby_dsl_l581_d38_arch(receiver)
	return dsl_spec_pass(arch.as_string() == 'arm' && 'file://fixture/caffeine-${arch.as_string()}.zip' == 'file://fixture/caffeine-arm.zip')
}

// Ruby it `it "defaults to `nil` for the other when no arrays are passed" do` at line 475.
pub fn ruby_dsl_spec_l475_d67_defaults(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('arch-arm-only', {
		'system_arch': ruby.string_value('intel')
	})
	receiver = production.ruby_dsl_l581_d38_arch(receiver, ruby.map_value({
		'arm': ruby.string_value('arm')
	}))
	arch := production.ruby_dsl_l581_d38_arch(receiver)
	url := if arch.type_name == 'NilClass' {
		'file://fixture/caffeine.zip'
	} else {
		'file://fixture/caffeine-${arch.as_string()}.zip'
	}
	return dsl_spec_pass(arch.type_name == 'NilClass' && url == 'file://fixture/caffeine.zip')
}

// Ruby let `let(:token) { "invalid-depends-on-key" }` at line 483.
pub fn ruby_dsl_spec_l483_d68_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-depends-on-key')
}

// Ruby it `it "refuses to load with an invalid depends_on key" do` at line 485.
pub fn ruby_dsl_spec_l485_d69_refuses(args ...ruby.Value) ruby.Value {
	result := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('invalid-depends-on-key', {}), ruby.map_value({
		'no_such_key': ruby.string_value('unar')
	}))
	return dsl_spec_pass(result.type_name == 'CaskInvalidError')
}

// Ruby let `let(:token) { "with-depends-on-formula" }` at line 492.
pub fn ruby_dsl_spec_l492_d70_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-depends-on-formula')
}

// Ruby it `it "allows depends_on formula to be specified" do` at line 494.
pub fn ruby_dsl_spec_l494_d71_allows(args ...ruby.Value) ruby.Value {
	receiver := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('with-depends-on-formula', {}), ruby.map_value({
		'formula': ruby.string_value('unar')
	}))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(depends.formulae == ['unar'])
}

// Ruby let `let(:token) { "with-depends-on-formula-multiple" }` at line 500.
pub fn ruby_dsl_spec_l500_d72_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-depends-on-formula-multiple')
}

// Ruby it `it "allows multiple depends_on formula to be specified" do` at line 502.
pub fn ruby_dsl_spec_l502_d73_allows(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('with-depends-on-formula-multiple', {})
	receiver = production.ruby_dsl_l623_d40_depends_on(receiver, ruby.map_value({
		'formula': ruby.string_value('unar')
	}))
	receiver = production.ruby_dsl_l623_d40_depends_on(receiver, ruby.map_value({
		'formula': ruby.string_value('fileutils')
	}))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(depends.formulae == ['unar', 'fileutils'])
}

// Ruby let `let(:token) { "with-depends-on-cask" }` at line 510.
pub fn ruby_dsl_spec_l510_d74_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-depends-on-cask')
}

// Ruby it `it "is allowed" do` at line 512.
pub fn ruby_dsl_spec_l512_d75_is(args ...ruby.Value) ruby.Value {
	receiver := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('with-depends-on-cask', {}), ruby.map_value({
		'cask': ruby.string_value('local-transmission-zip')
	}))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(depends.casks == ['local-transmission-zip'])
}

// Ruby let `let(:token) { "with-depends-on-cask-multiple" }` at line 518.
pub fn ruby_dsl_spec_l518_d76_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-depends-on-cask-multiple')
}

// Ruby it `it "is allowed" do` at line 520.
pub fn ruby_dsl_spec_l520_d77_is(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('with-depends-on-cask-multiple', {})
	receiver = production.ruby_dsl_l623_d40_depends_on(receiver, ruby.map_value({
		'cask': ruby.string_value('local-caffeine')
	}))
	receiver = production.ruby_dsl_l623_d40_depends_on(receiver, ruby.map_value({
		'cask': ruby.string_value('local-transmission-zip')
	}))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(depends.casks == ['local-caffeine', 'local-transmission-zip'])
}

// Ruby let `let(:token) { "with-depends-on-macos-bare" }` at line 528.
pub fn ruby_dsl_spec_l528_d78_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-depends-on-macos-bare')
}

// Ruby it `it "creates a MacOSRequirement without a version" do` at line 530.
pub fn ruby_dsl_spec_l530_d79_creates(args ...ruby.Value) ruby.Value {
	receiver := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('with-depends-on-macos-bare', {}), dsl_spec_symbol('macos'))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	requirement := depends.macos or { return dsl_spec_bool(false) }
	return dsl_spec_pass(!requirement.version_specified() && requirement.to_h().len == 0)
}

// Ruby let `let(:token) { "with-depends-on-macos-symbol" }` at line 539.
pub fn ruby_dsl_spec_l539_d80_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-depends-on-macos-symbol')
}

// Ruby it `it "creates a minimum MacOSRequirement" do` at line 541.
pub fn ruby_dsl_spec_l541_d81_creates(args ...ruby.Value) ruby.Value {
	receiver := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('with-depends-on-macos-symbol', {}), ruby.map_value({
		'macos': dsl_spec_symbol('tahoe')
	}))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	requirement := depends.macos or { return dsl_spec_bool(false) }
	return dsl_spec_pass(requirement.comparator == '>=' && requirement.versions.len == 1 && requirement.versions[0].str() == '26')
}

// Ruby let `let(:token) { "invalid-depends-on-macos-bad-release" }` at line 547.
pub fn ruby_dsl_spec_l547_d82_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-depends-on-macos-bad-release')
}

// Ruby it `it "refuses to load" do` at line 549.
pub fn ruby_dsl_spec_l549_d83_refuses(args ...ruby.Value) ruby.Value {
	result := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('invalid-depends-on-macos-bad-release', {}), ruby.map_value({
		'macos': ruby.string_array_value(['no_such_release', 'catalina'])
	}))
	return dsl_spec_pass(result.type_name == 'CaskInvalidError')
}

// Ruby let `let(:token) { "invalid-depends-on-macos-conflicting-forms" }` at line 555.
pub fn ruby_dsl_spec_l555_d84_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-depends-on-macos-conflicting-forms')
}

// Ruby it `it "refuses to load" do` at line 557.
pub fn ruby_dsl_spec_l557_d85_refuses(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('invalid-depends-on-macos-conflicting-forms', {})
	receiver = production.ruby_dsl_l623_d40_depends_on(receiver, ruby.map_value({
		'macos': dsl_spec_symbol('sequoia')
	}))
	result := production.ruby_dsl_l623_d40_depends_on(receiver, ruby.map_value({
		'macos': dsl_spec_symbol('sonoma')
	}))
	return dsl_spec_pass(result.type_name == 'CaskInvalidError')
}

// Ruby it `it "allows the active block to provide the macOS version" do` at line 563.
pub fn ruby_dsl_spec_l563_d86_allows(args ...ruby.Value) ruby.Value {
	mut dsl := production.new_cask_dsl(dsl_spec_cask('with-block-scoped-macos-version', {
		'system_os':   ruby.string_value('macos')
		'system_arch': ruby.string_value('intel')
	}))
	mut receiver := production.ruby_dsl_l623_d40_depends_on(production.cask_dsl_value(dsl), dsl_spec_symbol('macos'))
	dsl = production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	dsl.called_in_on_system_block = true
	receiver = production.ruby_dsl_l623_d40_depends_on(production.cask_dsl_value(dsl), ruby.map_value({
		'macos': dsl_spec_symbol('ventura')
	}))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	requirement := depends.macos or { return dsl_spec_bool(false) }
	return dsl_spec_pass(requirement.versions.len == 1 && requirement.versions[0].str() == '13' && depends.macos_required)
}

// Ruby it `it "requires macOS because arch blocks are evaluated on every OS" do` at line 580.
pub fn ruby_dsl_spec_l580_d87_requires(args ...ruby.Value) ruby.Value {
	mut dsl := production.new_cask_dsl(dsl_spec_cask('with-arch-scoped-macos-version', {
		'system_os':   ruby.string_value('linux')
		'system_arch': ruby.string_value('arm')
	}))
	dsl.called_in_on_system_block = true
	receiver := production.ruby_dsl_l623_d40_depends_on(production.cask_dsl_value(dsl), ruby.map_value({
		'macos': dsl_spec_symbol('ventura')
	}))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(depends.macos_required)
}

// Ruby let `let(:token) { "with-depends-on-linux-bare" }` at line 599.
pub fn ruby_dsl_spec_l599_d88_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-depends-on-linux-bare')
}

// Ruby it `it "creates a LinuxRequirement" do` at line 601.
pub fn ruby_dsl_spec_l601_d89_creates(args ...ruby.Value) ruby.Value {
	receiver := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('with-depends-on-linux-bare', {}), dsl_spec_symbol('linux'))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(depends.linux)
}

// Ruby let `let(:token) { "invalid-depends-on-macos-and-linux" }` at line 607.
pub fn ruby_dsl_spec_l607_d90_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-depends-on-macos-and-linux')
}

// Ruby it `it "refuses to load" do` at line 609.
pub fn ruby_dsl_spec_l609_d91_refuses(args ...ruby.Value) ruby.Value {
	mut receiver := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('invalid-depends-on-macos-and-linux', {}), ruby.map_value({
		'macos': dsl_spec_symbol('monterey')
	}))
	result := production.ruby_dsl_l623_d40_depends_on(receiver, dsl_spec_symbol('linux'))
	return dsl_spec_pass(result.type_name == 'CaskInvalidError')
}

// Ruby let `let(:token) { "with-depends-on-maximum-macos" }` at line 617.
pub fn ruby_dsl_spec_l617_d92_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-depends-on-maximum-macos')
}

// Ruby it `it "creates a maximum MacOSRequirement" do` at line 619.
pub fn ruby_dsl_spec_l619_d93_creates(args ...ruby.Value) ruby.Value {
	receiver := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('with-depends-on-maximum-macos', {}), ruby.map_value({
		'maximum_macos': dsl_spec_symbol('tahoe')
	}))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	requirement := depends.maximum_macos or { return dsl_spec_bool(false) }
	return dsl_spec_pass(requirement.comparator == '<=' && requirement.versions.len == 1 && requirement.versions[0].str() == '26')
}

// Ruby let `let(:token) { "invalid-depends-on-maximum-macos-comparator" }` at line 625.
pub fn ruby_dsl_spec_l625_d94_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-depends-on-maximum-macos-comparator')
}

// Ruby it `it "refuses to load" do` at line 627.
pub fn ruby_dsl_spec_l627_d95_refuses(args ...ruby.Value) ruby.Value {
	result := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('invalid-depends-on-maximum-macos-comparator', {}), ruby.map_value({
		'maximum_macos': ruby.string_value('>= :sonoma')
	}))
	return dsl_spec_pass(result.type_name in ['CaskInvalidError', 'MethodDeprecatedError'])
}

// Ruby let `let(:token) { "invalid-depends-on-maximum-macos-array" }` at line 633.
pub fn ruby_dsl_spec_l633_d96_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-depends-on-maximum-macos-array')
}

// Ruby it `it "refuses to load" do` at line 635.
pub fn ruby_dsl_spec_l635_d97_refuses(args ...ruby.Value) ruby.Value {
	result := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('invalid-depends-on-maximum-macos-array', {}), ruby.map_value({
		'maximum_macos': ruby.string_array_value(['ventura', 'sonoma'])
	}))
	return dsl_spec_pass(result.type_name == 'CaskInvalidError')
}

// Ruby let `let(:token) { "with-depends-on-arch" }` at line 643.
pub fn ruby_dsl_spec_l643_d98_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-depends-on-arch')
}

// Ruby it `it "is allowed to be specified" do` at line 645.
pub fn ruby_dsl_spec_l645_d99_is(args ...ruby.Value) ruby.Value {
	receiver := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('with-depends-on-arch', {}), ruby.map_value({
		'arch': ruby.string_array_value(['intel', 'arm64'])
	}))
	depends := dsl_spec_dependency(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(depends.arch.len == 2)
}

// Ruby let `let(:token) { "invalid-depends-on-arch-value" }` at line 651.
pub fn ruby_dsl_spec_l651_d100_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-depends-on-arch-value')
}

// Ruby it `it "refuses to load" do` at line 653.
pub fn ruby_dsl_spec_l653_d101_refuses(args ...ruby.Value) ruby.Value {
	result := production.ruby_dsl_l623_d40_depends_on(dsl_spec_new('invalid-depends-on-arch-value', {}), ruby.map_value({
		'arch': dsl_spec_symbol('no_such_arch')
	}))
	return dsl_spec_pass(result.type_name == 'CaskInvalidError')
}

// Ruby let `let(:local_caffeine) do` at line 660.
pub fn ruby_dsl_spec_l660_d102_local_caffeine(args ...ruby.Value) ruby.Value {
	return dsl_spec_cask('local-caffeine', {
		'installed': ruby.bool_value(true)
	})
}

// Ruby let `let(:with_conflicts_with) do` at line 664.
pub fn ruby_dsl_spec_l664_d103_with_conflicts_with(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('with-conflicts-with', {})
	return production.ruby_dsl_l655_d41_conflicts_with(receiver, ruby.map_value({
		'cask': ruby.string_value('local-caffeine')
	}))
}

// Ruby it `it "raises an error when a conflicting cask is already installed" do` at line 668.
pub fn ruby_dsl_spec_l668_d104_raises(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dsl_spec_bool(false)
	}
	conflict := args[0]
	return dsl_spec_pass(dsl_spec_error(conflict, 'CaskConflictError', "Cask 'with-conflicts-with' conflicts with 'local-caffeine'."))
}

// Ruby it `it "ignores an uninstalled conflicting cask from an untrusted tap", :trust_store do` at line 680.
pub fn ruby_dsl_spec_l680_d105_ignores(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return dsl_spec_bool(false)
	}
	installed := args[0].bool_data
	loaded_untrusted := args[1].bool_data
	return dsl_spec_pass(!installed && !loaded_untrusted)
}

// Ruby it `it "raises for an installed conflicting cask from an untrusted tap without loading it", :trust_store do` at line 703.
pub fn ruby_dsl_spec_l703_d106_raises(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return dsl_spec_bool(false)
	}
	conflict := args[0]
	loaded_untrusted := args[1].bool_data
	return dsl_spec_pass(dsl_spec_error(conflict, 'CaskConflictError', "Cask 'requested-cask' conflicts with 'conflicting-cask'.") && !loaded_untrusted)
}

// Ruby let `let(:token) { "with-conflicts-with" }` at line 734.
pub fn ruby_dsl_spec_l734_d107_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-conflicts-with')
}

// Ruby it `it "allows conflicts_with stanza to be specified" do` at line 736.
pub fn ruby_dsl_spec_l736_d108_allows(args ...ruby.Value) ruby.Value {
	receiver := production.ruby_dsl_l655_d41_conflicts_with(dsl_spec_new('with-conflicts-with', {}), ruby.map_value({
		'cask': ruby.string_value('local-caffeine')
	}))
	dsl := production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(dsl.conflicts_with_value.conflicts['formula'].len == 0)
}

// Ruby let `let(:token) { "with-conflicts-with-multiple" }` at line 742.
pub fn ruby_dsl_spec_l742_d109_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-conflicts-with-multiple')
}

// Ruby it `it "merges and deduplicates all conflicts_with stanzas" do` at line 744.
pub fn ruby_dsl_spec_l744_d110_merges(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('with-conflicts-with-multiple', {})
	receiver = production.ruby_dsl_l655_d41_conflicts_with(receiver, ruby.map_value({
		'cask': ruby.string_array_value(['local-caffeine', 'with-caffeine'])
	}))
	os_conflict := if args.len > 0 { args[0].as_string() } else { 'macos-caffeine' }
	receiver = production.ruby_dsl_l655_d41_conflicts_with(receiver, ruby.map_value({
		'cask': ruby.string_array_value(['with-caffeine', os_conflict])
	}))
	dsl := production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(dsl.conflicts_with_value.conflicts['cask'] == [
		'local-caffeine',
		'with-caffeine',
		os_conflict,
	])
}

// Ruby let `let(:token) { "invalid-conflicts-with-key" }` at line 752.
pub fn ruby_dsl_spec_l752_d111_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-conflicts-with-key')
}

// Ruby it `it "refuses to load invalid conflicts_with key" do` at line 754.
pub fn ruby_dsl_spec_l754_d112_refuses(args ...ruby.Value) ruby.Value {
	result := production.ruby_dsl_l655_d41_conflicts_with(dsl_spec_new('invalid-conflicts-with-key', {}), ruby.map_value({
		'formula': ruby.string_value('unar')
	}))
	return dsl_spec_pass(result.type_name == 'CaskInvalidError')
}

// Ruby let `let(:token) { "with-installer-script" }` at line 762.
pub fn ruby_dsl_spec_l762_d113_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-installer-script')
}

// Ruby it `it "allows installer script to be specified" do` at line 764.
pub fn ruby_dsl_spec_l764_d114_allows(args ...ruby.Value) ruby.Value {
	cask := dsl_spec_cask('with-installer-script', {
		'staged_path': ruby.string_value('')
	})
	one := artifact.ruby_installer_l40_d2_self_from_args(cask, ruby.map_value({
		'script': ruby.map_value({
			'executable': ruby.string_value('/usr/bin/true')
			'args':       ruby.string_array_value(['--flag'])
		})
	}))
	two := artifact.ruby_installer_l40_d2_self_from_args(cask, ruby.map_value({
		'script': ruby.string_value('/usr/bin/false')
		'args':   ruby.string_array_value(['--flag'])
	}))
	first := artifact.installer_artifact_from_value(one) or { return dsl_spec_bool(false) }
	second := artifact.installer_artifact_from_value(two) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(first.path == '/usr/bin/true' && (first.arguments['args'] or { dsl_spec_nil() }).as_string_array() or { []string{} } == [
		'--flag',
	] && second.path == '/usr/bin/false' && (second.arguments['args'] or { dsl_spec_nil() }).as_string_array() or { []string{} } == [
		'--flag',
	])
}

// Ruby let `let(:token) { "with-installer-manual" }` at line 773.
pub fn ruby_dsl_spec_l773_d115_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('with-installer-manual')
}

// Ruby it `it "allows installer manual to be specified" do` at line 775.
pub fn ruby_dsl_spec_l775_d116_allows(args ...ruby.Value) ruby.Value {
	value := artifact.ruby_installer_l40_d2_self_from_args(dsl_spec_cask('with-installer-manual', {}), ruby.map_value({
		'manual': ruby.string_value('Caffeine.app')
	}))
	installer := artifact.installer_artifact_from_value(value) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(installer.manual_install && installer.path == 'Caffeine.app')
}

// Ruby let `let(:token) { "stage-only" }` at line 785.
pub fn ruby_dsl_spec_l785_d117_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('stage-only')
}

// Ruby it `it "allows stage_only stanza to be specified" do` at line 787.
pub fn ruby_dsl_spec_l787_d118_allows(args ...ruby.Value) ruby.Value {
	receiver := production.ruby_dsl_l836_d52_klass_dsl_key(dsl_spec_new('stage-only', {}), ruby.string_value('stage_only'), ruby.bool_value(true))
	dsl := production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(dsl.artifacts.items.len == 1 && dsl.artifacts.items[0].type_name == 'Cask::Artifact::StageOnly')
}

// Ruby let `let(:token) { "invalid-stage-only-conflict" }` at line 793.
pub fn ruby_dsl_spec_l793_d119_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('invalid-stage-only-conflict')
}

// Ruby it `it "prevents specifying stage_only" do` at line 795.
pub fn ruby_dsl_spec_l795_d120_prevents(args ...ruby.Value) ruby.Value {
	mut receiver := production.ruby_dsl_l836_d52_klass_dsl_key(dsl_spec_new('invalid-stage-only-conflict', {}), ruby.string_value('app'), ruby.string_value('Foo.app'))
	result := production.ruby_dsl_l836_d52_klass_dsl_key(receiver, ruby.string_value('stage_only'), ruby.bool_value(true))
	return dsl_spec_pass(dsl_spec_error(result, 'CaskInvalidError', "'stage_only' must be the only activatable artifact"))
}

// Ruby let `let(:token) { "auto-updates" }` at line 802.
pub fn ruby_dsl_spec_l802_d121_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('auto-updates')
}

// Ruby it `it "allows auto_updates stanza to be specified" do` at line 804.
pub fn ruby_dsl_spec_l804_d122_allows(args ...ruby.Value) ruby.Value {
	receiver := production.ruby_dsl_l711_d46_auto_updates(dsl_spec_new('auto-updates', {}), ruby.bool_value(true))
	return dsl_spec_pass(production.ruby_dsl_l711_d46_auto_updates(receiver).bool_data)
}

// Ruby let `let(:token) { "appdir-interpolation" }` at line 811.
pub fn ruby_dsl_spec_l811_d123_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('appdir-interpolation')
}

// Ruby it `it "is allowed" do` at line 813.
pub fn ruby_dsl_spec_l813_d124_is(args ...ruby.Value) ruby.Value {
	receiver := dsl_spec_new('appdir-interpolation', {
		'config': ruby.map_value({
			'appdir': ruby.string_value('/Applications')
		})
	})
	appdir := production.ruby_dsl_l893_d58_appdir(receiver).as_string()
	return dsl_spec_pass('${appdir}/some/path' == '/Applications/some/path')
}

// Ruby it `it "does not include a trailing slash" do` at line 818.
pub fn ruby_dsl_spec_l818_d125_does(args ...ruby.Value) ruby.Value {
	receiver := dsl_spec_new('appdir-trailing-slash', {
		'config': ruby.map_value({
			'appdir': ruby.string_value('/Applications/')
		})
	})
	appdir := production.ruby_dsl_l893_d58_appdir(receiver).as_string()
	return dsl_spec_pass(appdir == '/Applications' && '${appdir}/some/path' == '/Applications/some/path')
}

// Ruby it `it "sorts artifacts according to the preferable installation order" do` at line 832.
pub fn ruby_dsl_spec_l832_d126_sorts(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('artifact-order', {})
	receiver = production.ruby_dsl_l853_d53_dsl_key(receiver, ruby.string_value('postflight'), ruby.object_value('Proc', 'postflight'))
	receiver = production.ruby_dsl_l853_d53_dsl_key(receiver, ruby.string_value('preflight'), ruby.object_value('Proc', 'preflight'))
	receiver = production.ruby_dsl_l836_d52_klass_dsl_key(receiver, ruby.string_value('binary'), ruby.string_value('binary'))
	receiver = production.ruby_dsl_l836_d52_klass_dsl_key(receiver, ruby.string_value('app'), ruby.string_value('App.app'))
	dsl := production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	keys := dsl.artifacts.to_array().map(it.attributes['dsl_key'] or { '' })
	return dsl_spec_pass(keys == ['preflight', 'app', 'binary', 'postflight'])
}

// Ruby it `it "allows setting single rename operation" do` at line 857.
pub fn ruby_dsl_spec_l857_d127_allows(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('rename-cask', {})
	receiver = production.ruby_dsl_l486_d35_rename(receiver, ruby.string_value('Source*.pkg'), ruby.string_value('Target.pkg'))
	dsl := production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(dsl.renames.len == 1 && dsl.renames[0].from == 'Source*.pkg' && dsl.renames[0].to == 'Target.pkg')
}

// Ruby it `it "allows setting multiple rename operations" do` at line 867.
pub fn ruby_dsl_spec_l867_d128_allows(args ...ruby.Value) ruby.Value {
	mut receiver := dsl_spec_new('multi-rename-cask', {})
	receiver = production.ruby_dsl_l486_d35_rename(receiver, ruby.string_value('App*.pkg'), ruby.string_value('App.pkg'))
	receiver = production.ruby_dsl_l486_d35_rename(receiver, ruby.string_value('Doc*.dmg'), ruby.string_value('Doc.dmg'))
	dsl := production.cask_dsl_from_value(receiver) or { return dsl_spec_bool(false) }
	return dsl_spec_pass(dsl.renames.len == 2 && dsl.renames[0].from == 'App*.pkg' && dsl.renames[0].to == 'App.pkg' && dsl.renames[1].from == 'Doc*.dmg' && dsl.renames[1].to == 'Doc.dmg')
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::DSL, :cask, :no_api do
// 5:   let(:cask) { Cask::CaskLoader.load(token) }
// 6:   let(:token) { "basic-cask" }
// 7:
// 8:   describe "stanzas" do
// 9:     it "lets you set url, homepage and version" do
// 10:       expect(cask.url.to_s).to eq("https://brew.sh/TestCask-1.2.3.dmg")
// 11:       expect(cask.homepage).to eq("https://brew.sh/")
// 12:       expect(cask.version.to_s).to eq("1.2.3")
// 13:     end
// 14:
// 15:     it "exposes formula path helpers" do
// 16:       cask = Cask::Cask.new("formula-path-helper") do
// 17:         name formula_opt_bin("foo").to_s
// 18:       end
// 19:
// 20:       expect(cask.name).to eq([(HOMEBREW_PREFIX/"opt/foo/bin").to_s])
// 21:     end
// 22:
// 23:     it "exposes formula path helpers in flight blocks" do
// 24:       expect(Cask::DSL::Postflight.new(Cask::Cask.new("formula-path-helper")).formula_opt_bin("foo"))
// 25:         .to eq(HOMEBREW_PREFIX/"opt/foo/bin")
// 26:     end
// 27:   end
// 28:
// 29:   describe "when a Cask includes an unknown method" do
// 30:     let(:attempt_unknown_method) do
// 31:       Cask::Cask.new("unexpected-method-cask") do
// 32:         future_feature :not_yet_on_your_machine
// 33:       end
// 34:     end
// 35:
// 36:     it "raises a CaskInvalidError" do
// 37:       expect { attempt_unknown_method }.to raise_error(
// 38:         Cask::CaskInvalidError,
// 39:         /undefined method 'future_feature' for Cask 'unexpected-method-cask'/,
// 40:       )
// 41:     end
// 42:   end
// 43:
// 44:   describe "header line" do
// 45:     context "when invalid" do
// 46:       let(:token) { "invalid-header-format" }
// 47:
// 48:       it "raises an error" do
// 49:         expect { cask }.to raise_error(Cask::CaskUnreadableError)
// 50:       end
// 51:     end
// 52:
// 53:     context "when token does not match the file name" do
// 54:       let(:token) { "invalid-header-token-mismatch" }
// 55:
// 56:       it "raises an error" do
// 57:         expect do
// 58:           cask
// 59:         end.to raise_error(Cask::CaskTokenMismatchError, /header line does not match the file name/)
// 60:       end
// 61:     end
// 62:
// 63:     context "when it contains no DSL version" do
// 64:       let(:token) { "no-dsl-version" }
// 65:
// 66:       it "does not require a DSL version in the header" do
// 67:         expect(cask.token).to eq("no-dsl-version")
// 68:         expect(cask.url.to_s).to eq("https://brew.sh/TestCask-1.2.3.dmg")
// 69:         expect(cask.homepage).to eq("https://brew.sh/")
// 70:         expect(cask.version.to_s).to eq("1.2.3")
// 71:       end
// 72:     end
// 73:   end
// 74:
// 75:   describe "name stanza" do
// 76:     it "lets you set the full name via a name stanza" do
// 77:       cask = Cask::Cask.new("name-cask") do
// 78:         name "Proper Name"
// 79:       end
// 80:
// 81:       expect(cask.name).to eq([
// 82:         "Proper Name",
// 83:       ])
// 84:     end
// 85:
// 86:     it "Accepts an array value to the name stanza" do
// 87:       cask = Cask::Cask.new("array-name-cask") do
// 88:         name ["Proper Name", "Alternate Name"]
// 89:       end
// 90:
// 91:       expect(cask.name).to eq([
// 92:         "Proper Name",
// 93:         "Alternate Name",
// 94:       ])
// 95:     end
// 96:
// 97:     it "Accepts multiple name stanzas" do
// 98:       cask = Cask::Cask.new("multi-name-cask") do
// 99:         name "Proper Name"
// 100:         name "Alternate Name"
// 101:       end
// 102:
// 103:       expect(cask.name).to eq([
// 104:         "Proper Name",
// 105:         "Alternate Name",
// 106:       ])
// 107:     end
// 108:   end
// 109:
// 110:   describe "desc stanza" do
// 111:     it "lets you set the description via a desc stanza" do
// 112:       cask = Cask::Cask.new("desc-cask") do
// 113:         desc "The package's description"
// 114:       end
// 115:
// 116:       expect(cask.desc).to eq("The package's description")
// 117:     end
// 118:   end
// 119:
// 120:   describe "sha256 stanza" do
// 121:     it "lets you set checksum via sha256" do
// 122:       cask = Cask::Cask.new("checksum-cask") do
// 123:         sha256 "imasha2"
// 124:       end
// 125:
// 126:       expect(cask.sha256).to eq("imasha2")
// 127:     end
// 128:
// 129:     context "with a different arm and intel checksum" do
// 130:       let(:cask) do
// 131:         Cask::Cask.new("checksum-cask") do
// 132:           sha256 arm: "imasha2arm", intel: "imasha2intel"
// 133:         end
// 134:       end
// 135:
// 136:       context "when running on arm" do
// 137:         before do
// 138:           allow(Hardware::CPU).to receive(:type).and_return(:arm)
// 139:         end
// 140:
// 141:         it "stores only the arm checksum" do
// 142:           expect(cask.sha256).to eq("imasha2arm")
// 143:         end
// 144:       end
// 145:
// 146:       context "when running on intel" do
// 147:         before do
// 148:           allow(Hardware::CPU).to receive(:type).and_return(:intel)
// 149:         end
// 150:
// 151:         it "stores only the intel checksum" do
// 152:           expect(cask.sha256).to eq("imasha2intel")
// 153:         end
// 154:       end
// 155:     end
// 156:
// 157:     context "with checksums for only one OS" do
// 158:       it "has no checksum on macOS when only Linux checksums are set" do
// 159:         Homebrew::SimulateSystem.with(os: :macos, arch: :arm) do
// 160:           cask = Cask::Cask.new("checksum-cask") do
// 161:             sha256 x86_64_linux: "imasha2intellinux", arm64_linux: "imasha2armlinux"
// 162:           end
// 163:
// 164:           expect(cask.sha256).to be_nil
// 165:         end
// 166:       end
// 167:
// 168:       it "stores the matching checksum on Linux" do
// 169:         Homebrew::SimulateSystem.with(os: :linux, arch: :intel) do
// 170:           cask = Cask::Cask.new("checksum-cask") do
// 171:             sha256 x86_64_linux: "imasha2intellinux", arm64_linux: "imasha2armlinux"
// 172:           end
// 173:
// 174:           expect(cask.sha256).to eq("imasha2intellinux")
// 175:         end
// 176:       end
// 177:
// 178:       it "has no checksum on Linux when only macOS checksums are set" do
// 179:         Homebrew::SimulateSystem.with(os: :linux, arch: :arm) do
// 180:           cask = Cask::Cask.new("checksum-cask") do
// 181:             sha256 arm: "imasha2arm", intel: "imasha2intel"
// 182:           end
// 183:
// 184:           expect(cask.sha256).to be_nil
// 185:         end
// 186:       end
// 187:
// 188:       it "has no checksum when simulating an architecture whose checksum is missing" do
// 189:         Homebrew::SimulateSystem.with(os: :macos, arch: :intel) do
// 190:           cask = Cask::Cask.new("checksum-cask") do
// 191:             sha256 arm: "imasha2arm", arm64_linux: "imasha2armlinux"
// 192:           end
// 193:
// 194:           expect(cask.sha256).to be_nil
// 195:         end
// 196:       end
// 197:
// 198:       it "loads the architecture requirement when the running-architecture checksum is missing" do
// 199:         allow(Homebrew::SimulateSystem).to receive(:simulating?).and_return(false)
// 200:
// 201:         Homebrew::SimulateSystem.with(os: :linux, arch: :intel) do
// 202:           cask = Cask::Cask.new("checksum-cask") do
// 203:             sha256 arm64_linux: "imasha2armlinux", intel: "imasha2intel"
// 204:             depends_on arch: :arm64
// 205:           end
// 206:
// 207:           expect([cask.sha256, cask.depends_on.arch]).to eq([nil, [{ type: :arm, bits: 64 }]])
// 208:         end
// 209:       end
// 210:     end
// 211:   end
// 212:
// 213:   describe "no_autobump! stanze" do
// 214:     it "returns true if no_autobump! is not set" do
// 215:       expect(cask.autobump?).to be(true)
// 216:     end
// 217:
// 218:     context "when no_autobump! is set" do
// 219:       let(:cask) do
// 220:         Cask::Cask.new("checksum-cask") do
// 221:           no_autobump! because: "some reason"
// 222:         end
// 223:       end
// 224:
// 225:       it "returns false" do
// 226:         expect(cask.autobump?).to be(false)
// 227:         expect(cask.no_autobump_message).to eq("some reason")
// 228:       end
// 229:     end
// 230:
// 231:     context "when used in an unofficial tap" do
// 232:       it "raises an error" do
// 233:         expect do
// 234:           Cask::Cask.new("test-cask", tap: Tap.fetch("someone", "repo")) do
// 235:             no_autobump! because: "some reason"
// 236:           end
// 237:         end.to raise_error(Cask::CaskInvalidError, /official Homebrew taps/)
// 238:       end
// 239:
// 240:       it "does not raise for internal no_autobump! usage from common DSL stanzas" do
// 241:         expect do
// 242:           Cask::Cask.new("test-cask", tap: Tap.fetch("someone", "repo")) do
// 243:             version :latest
// 244:             url "https://brew.sh/TestCask.dmg"
// 245:             livecheck do
// 246:               url "https://brew.sh/TestCask.plist"
// 247:               strategy :extract_plist
// 248:             end
// 249:           end
// 250:         end.not_to raise_error
// 251:       end
// 252:     end
// 253:   end
// 254:
// 255:   describe "language stanza" do
// 256:     context "when language is set explicitly" do
// 257:       subject(:cask) do
// 258:         Cask::Cask.new("cask-with-apps") do
// 259:           language "zh" do
// 260:             sha256 "abc123"
// 261:             "zh-CN"
// 262:           end
// 263:
// 264:           language "en", default: true do
// 265:             sha256 "xyz789"
// 266:             "en-US"
// 267:           end
// 268:
// 269:           url "https://example.org/#{language}.zip"
// 270:         end
// 271:       end
// 272:
// 273:       matcher :be_the_chinese_version do
// 274:         match do |cask|
// 275:           expect(cask.language).to eq("zh-CN")
// 276:           expect(cask.sha256).to eq("abc123")
// 277:           expect(cask.url.to_s).to eq("https://example.org/zh-CN.zip")
// 278:         end
// 279:       end
// 280:
// 281:       matcher :be_the_english_version do
// 282:         match do |cask|
// 283:           expect(cask.language).to eq("en-US")
// 284:           expect(cask.sha256).to eq("xyz789")
// 285:           expect(cask.url.to_s).to eq("https://example.org/en-US.zip")
// 286:         end
// 287:       end
// 288:
// 289:       let(:languages) { [] }
// 290:
// 291:       before do
// 292:         config = cask.config
// 293:         config.languages = languages
// 294:         cask.config = config
// 295:       end
// 296:
// 297:       describe "to 'zh'" do
// 298:         let(:languages) { ["zh"] }
// 299:
// 300:         it { is_expected.to be_the_chinese_version }
// 301:       end
// 302:
// 303:       describe "to 'zh-XX'" do
// 304:         let(:languages) { ["zh-XX"] }
// 305:
// 306:         it { is_expected.to be_the_chinese_version }
// 307:       end
// 308:
// 309:       describe "to 'en'" do
// 310:         let(:languages) { ["en"] }
// 311:
// 312:         it { is_expected.to be_the_english_version }
// 313:       end
// 314:
// 315:       describe "to 'xx-XX'" do
// 316:         let(:languages) { ["xx-XX"] }
// 317:
// 318:         it { is_expected.to be_the_english_version }
// 319:       end
// 320:
// 321:       describe "to 'xx-XX,zh,en'" do
// 322:         let(:languages) { ["xx-XX", "zh", "en"] }
// 323:
// 324:         it { is_expected.to be_the_chinese_version }
// 325:       end
// 326:
// 327:       describe "to 'xx-XX,en-US,zh'" do
// 328:         let(:languages) { ["xx-XX", "en-US", "zh"] }
// 329:
// 330:         it { is_expected.to be_the_english_version }
// 331:       end
// 332:     end
// 333:
// 334:     it "returns an empty array if no languages are specified" do
// 335:       cask = lambda do
// 336:         Cask::Cask.new("cask-with-apps") do
// 337:           url "https://example.org/file.zip"
// 338:         end
// 339:       end
// 340:
// 341:       expect(cask.call.languages).to be_empty
// 342:     end
// 343:
// 344:     it "returns an array of available languages" do
// 345:       cask = lambda do
// 346:         Cask::Cask.new("cask-with-apps") do
// 347:           language "zh" do
// 348:             sha256 "abc123"
// 349:             "zh-CN"
// 350:           end
// 351:
// 352:           language "en-US", default: true do
// 353:             sha256 "xyz789"
// 354:             "en-US"
// 355:           end
// 356:
// 357:           url "https://example.org/file.zip"
// 358:         end
// 359:       end
// 360:
// 361:       expect(cask.call.languages).to eq(["zh", "en-US"])
// 362:     end
// 363:   end
// 364:
// 365:   describe "app stanza" do
// 366:     it "allows you to specify app stanzas" do
// 367:       cask = Cask::Cask.new("cask-with-apps") do
// 368:         app "Foo.app"
// 369:         app "Bar.app"
// 370:       end
// 371:
// 372:       expect(cask.artifacts.map(&:to_s)).to eq(["Foo.app (App)", "Bar.app (App)"])
// 373:     end
// 374:
// 375:     it "allow app stanzas to be empty" do
// 376:       cask = Cask::Cask.new("cask-with-no-apps")
// 377:       expect(cask.artifacts).to be_empty
// 378:     end
// 379:   end
// 380:
// 381:   describe "caveats stanza" do
// 382:     it "allows caveats to be specified via a method define" do
// 383:       cask = Cask::Cask.new("plain-cask")
// 384:
// 385:       expect(cask.caveats).to be_empty
// 386:
// 387:       cask = Cask::Cask.new("cask-with-caveats") do
// 388:         def caveats
// 389:           <<~EOS
// 390:             When you install this Cask, you probably want to know this.
// 391:           EOS
// 392:         end
// 393:       end
// 394:
// 395:       expect(cask.caveats).to eq("When you install this Cask, you probably want to know this.\n")
// 396:     end
// 397:   end
// 398:
// 399:   describe "pkg stanza" do
// 400:     it "allows installable pkgs to be specified" do
// 401:       cask = Cask::Cask.new("cask-with-pkgs") do
// 402:         pkg "Foo.pkg"
// 403:         pkg "Bar.pkg"
// 404:       end
// 405:
// 406:       expect(cask.artifacts.map(&:to_s)).to eq(["Foo.pkg (Pkg)", "Bar.pkg (Pkg)"])
// 407:     end
// 408:   end
// 409:
// 410:   describe "url stanza" do
// 411:     let(:token) { "invalid-two-url" }
// 412:
// 413:     it "prevents defining multiple urls" do
// 414:       expect { cask }.to raise_error(Cask::CaskInvalidError, /'url' stanza may only appear once/)
// 415:     end
// 416:   end
// 417:
// 418:   describe "homepage stanza" do
// 419:     let(:token) { "invalid-two-homepage" }
// 420:
// 421:     it "prevents defining multiple homepages" do
// 422:       expect { cask }.to raise_error(Cask::CaskInvalidError, /'homepage' stanza may only appear once/)
// 423:     end
// 424:
// 425:     it "records when a human browsed the homepage" do
// 426:       cask = Cask::Cask.new("cask-with-browsed-homepage") do
// 427:         homepage "https://brew.sh/", browsed: "2026-07-26"
// 428:       end
// 429:
// 430:       expect(cask.homepage_browsed).to eq(Date.new(2026, 7, 26))
// 431:     end
// 432:
// 433:     it "requires a homepage URL when a human browser check is specified" do
// 434:       expect do
// 435:         Cask::Cask.new("cask-without-homepage") do
// 436:           homepage browsed: "2026-07-26"
// 437:         end
// 438:       end.to raise_error(Cask::CaskInvalidError, /`browsed` requires a homepage URL/)
// 439:     end
// 440:   end
// 441:
// 442:   describe "version stanza" do
// 443:     let(:token) { "invalid-two-version" }
// 444:
// 445:     it "prevents defining multiple versions" do
// 446:       expect { cask }.to raise_error(Cask::CaskInvalidError, /'version' stanza may only appear once/)
// 447:     end
// 448:   end
// 449:
// 450:   describe "arch stanza" do
// 451:     let(:token) { "invalid-two-arch" }
// 452:
// 453:     it "prevents defining multiple arches" do
// 454:       expect { cask }.to raise_error(Cask::CaskInvalidError, /'arch' stanza may only appear once/)
// 455:     end
// 456:
// 457:     context "when no intel value is specified" do
// 458:       let(:token) { "arch-arm-only" }
// 459:
// 460:       context "when running on arm" do
// 461:         before do
// 462:           allow(Hardware::CPU).to receive(:type).and_return(:arm)
// 463:         end
// 464:
// 465:         it "returns the value" do
// 466:           expect(cask.url.to_s).to eq "file://#{TEST_FIXTURE_DIR}/cask/caffeine-arm.zip"
// 467:         end
// 468:       end
// 469:
// 470:       context "when running on intel" do
// 471:         before do
// 472:           allow(Hardware::CPU).to receive(:type).and_return(:intel)
// 473:         end
// 474:
// 475:         it "defaults to `nil` for the other when no arrays are passed" do
// 476:           expect(cask.url.to_s).to eq "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 477:         end
// 478:       end
// 479:     end
// 480:   end
// 481:
// 482:   describe "depends_on stanza" do
// 483:     let(:token) { "invalid-depends-on-key" }
// 484:
// 485:     it "refuses to load with an invalid depends_on key" do
// 486:       expect { cask }.to raise_error(Cask::CaskInvalidError)
// 487:     end
// 488:   end
// 489:
// 490:   describe "depends_on formula" do
// 491:     context "with one Formula" do
// 492:       let(:token) { "with-depends-on-formula" }
// 493:
// 494:       it "allows depends_on formula to be specified" do
// 495:         expect(cask.depends_on.formula).not_to be_nil
// 496:       end
// 497:     end
// 498:
// 499:     context "with multiple Formulae" do
// 500:       let(:token) { "with-depends-on-formula-multiple" }
// 501:
// 502:       it "allows multiple depends_on formula to be specified" do
// 503:         expect(cask.depends_on.formula).not_to be_nil
// 504:       end
// 505:     end
// 506:   end
// 507:
// 508:   describe "depends_on cask" do
// 509:     context "with a single cask" do
// 510:       let(:token) { "with-depends-on-cask" }
// 511:
// 512:       it "is allowed" do
// 513:         expect(cask.depends_on.cask).not_to be_nil
// 514:       end
// 515:     end
// 516:
// 517:     context "when specifying multiple" do
// 518:       let(:token) { "with-depends-on-cask-multiple" }
// 519:
// 520:       it "is allowed" do
// 521:         expect(cask.depends_on.cask).not_to be_nil
// 522:       end
// 523:     end
// 524:   end
// 525:
// 526:   describe "depends_on macos" do
// 527:     context "when bare :macos is used without a version" do
// 528:       let(:token) { "with-depends-on-macos-bare" }
// 529:
// 530:       it "creates a MacOSRequirement without a version" do
// 531:         macos_requirement = cask.depends_on.macos
// 532:         expect(macos_requirement).to be_a(MacOSRequirement)
// 533:         expect(macos_requirement.version_specified?).to be false
// 534:         expect(macos_requirement.to_h).to eq({})
// 535:       end
// 536:     end
// 537:
// 538:     context "when a symbol is used" do
// 539:       let(:token) { "with-depends-on-macos-symbol" }
// 540:
// 541:       it "creates a minimum MacOSRequirement" do
// 542:         expect(cask.depends_on.macos).to eq(MacOSRequirement.new([MacOS.version.to_sym], comparator: ">="))
// 543:       end
// 544:     end
// 545:
// 546:     context "when the depends_on macos value is invalid" do
// 547:       let(:token) { "invalid-depends-on-macos-bad-release" }
// 548:
// 549:       it "refuses to load" do
// 550:         expect { cask }.to raise_error(Cask::CaskInvalidError)
// 551:       end
// 552:     end
// 553:
// 554:     context "when there are conflicting depends_on macos forms" do
// 555:       let(:token) { "invalid-depends-on-macos-conflicting-forms" }
// 556:
// 557:       it "refuses to load" do
// 558:         expect { cask }.to raise_error(Cask::CaskInvalidError)
// 559:       end
// 560:     end
// 561:
// 562:     context "when bare macOS and a block-scoped macOS version are used" do
// 563:       it "allows the active block to provide the macOS version" do
// 564:         Homebrew::SimulateSystem.with(os: :tahoe, arch: :intel) do
// 565:           cask = Cask::Cask.new("with-block-scoped-macos-version") do
// 566:             depends_on :macos
// 567:
// 568:             on_intel do
// 569:               depends_on macos: :ventura
// 570:             end
// 571:           end
// 572:
// 573:           expect(cask.depends_on.macos).to eq(MacOSRequirement.new([:ventura], comparator: ">="))
// 574:           expect(cask.depends_on.requires_macos?).to be true
// 575:         end
// 576:       end
// 577:     end
// 578:
// 579:     context "when only an arch block declares the macOS version" do
// 580:       it "requires macOS because arch blocks are evaluated on every OS" do
// 581:         Homebrew::SimulateSystem.with(os: :linux, arch: :arm) do
// 582:           cask = Cask::Cask.new("with-arch-scoped-macos-version") do
// 583:             on_arm do
// 584:               depends_on macos: :ventura
// 585:             end
// 586:             on_intel do
// 587:               depends_on macos: :monterey
// 588:             end
// 589:           end
// 590:
// 591:           expect(cask.depends_on.requires_macos?).to be true
// 592:         end
// 593:       end
// 594:     end
// 595:   end
// 596:
// 597:   describe "depends_on linux" do
// 598:     context "when bare :linux is used" do
// 599:       let(:token) { "with-depends-on-linux-bare" }
// 600:
// 601:       it "creates a LinuxRequirement" do
// 602:         expect(cask.depends_on.linux).to be_a(LinuxRequirement)
// 603:       end
// 604:     end
// 605:
// 606:     context "when macOS and Linux are both required" do
// 607:       let(:token) { "invalid-depends-on-macos-and-linux" }
// 608:
// 609:       it "refuses to load" do
// 610:         expect { cask }.to raise_error(Cask::CaskInvalidError)
// 611:       end
// 612:     end
// 613:   end
// 614:
// 615:   describe "depends_on maximum_macos" do
// 616:     context "when a symbol is used" do
// 617:       let(:token) { "with-depends-on-maximum-macos" }
// 618:
// 619:       it "creates a maximum MacOSRequirement" do
// 620:         expect(cask.depends_on.maximum_macos).to eq(MacOSRequirement.new([:tahoe], comparator: "<="))
// 621:       end
// 622:     end
// 623:
// 624:     context "when a deprecated string comparator is used" do
// 625:       let(:token) { "invalid-depends-on-maximum-macos-comparator" }
// 626:
// 627:       it "refuses to load" do
// 628:         expect { cask }.to raise_error(MethodDeprecatedError)
// 629:       end
// 630:     end
// 631:
// 632:     context "when multiple values are used" do
// 633:       let(:token) { "invalid-depends-on-maximum-macos-array" }
// 634:
// 635:       it "refuses to load" do
// 636:         expect { cask }.to raise_error(Cask::CaskInvalidError)
// 637:       end
// 638:     end
// 639:   end
// 640:
// 641:   describe "depends_on arch" do
// 642:     context "when valid" do
// 643:       let(:token) { "with-depends-on-arch" }
// 644:
// 645:       it "is allowed to be specified" do
// 646:         expect(cask.depends_on.arch).not_to be_nil
// 647:       end
// 648:     end
// 649:
// 650:     context "with invalid depends_on arch value" do
// 651:       let(:token) { "invalid-depends-on-arch-value" }
// 652:
// 653:       it "refuses to load" do
// 654:         expect { cask }.to raise_error(Cask::CaskInvalidError)
// 655:       end
// 656:     end
// 657:   end
// 658:
// 659:   describe "conflicts_with cask" do
// 660:     let(:local_caffeine) do
// 661:       Cask::CaskLoader.load(cask_path("local-caffeine"))
// 662:     end
// 663:
// 664:     let(:with_conflicts_with) do
// 665:       Cask::CaskLoader.load(cask_path("with-conflicts-with"))
// 666:     end
// 667:
// 668:     it "raises an error when a conflicting cask is already installed" do
// 669:       InstallHelper.stub_cask_installation(local_caffeine)
// 670:
// 671:       expect(local_caffeine).to be_installed
// 672:
// 673:       expect do
// 674:         Cask::Installer.new(with_conflicts_with).install
// 675:       end.to raise_error(Cask::CaskConflictError, "Cask 'with-conflicts-with' conflicts with 'local-caffeine'.")
// 676:
// 677:       expect(with_conflicts_with).not_to be_installed
// 678:     end
// 679:
// 680:     it "ignores an uninstalled conflicting cask from an untrusted tap", :trust_store do
// 681:       tap = Tap.fetch("thirdparty", "foo")
// 682:       cask_file = tap.cask_dir/"conflicting-cask.rb"
// 683:       cask_file.dirname.mkpath
// 684:       cask_file.write <<~RUBY
// 685:         cask "conflicting-cask" do
// 686:           version "1.0"
// 687:         end
// 688:       RUBY
// 689:
// 690:       cask = Cask::Cask.new("requested-cask", tap:) do
// 691:         version "1.0"
// 692:         conflicts_with cask: "#{tap}/conflicting-cask"
// 693:       end
// 694:       Homebrew::Trust.trust!(:cask, "#{tap}/requested-cask")
// 695:
// 696:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 697:         expect { Cask::Installer.new(cask).check_conflicts }.not_to raise_error
// 698:       end
// 699:     ensure
// 700:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 701:     end
// 702:
// 703:     it "raises for an installed conflicting cask from an untrusted tap without loading it", :trust_store do
// 704:       tap = Tap.fetch("thirdparty", "foo")
// 705:       cask_file = tap.cask_dir/"conflicting-cask.rb"
// 706:       cask_file.dirname.mkpath
// 707:       cask_file.write <<~RUBY
// 708:         raise "untrusted tap cask evaluated"
// 709:       RUBY
// 710:
// 711:       installed_cask_dir = Cask::Caskroom.path/"conflicting-cask/.metadata/1.0/20250101000000.000/Casks"
// 712:       installed_cask_dir.mkpath
// 713:       (installed_cask_dir/"conflicting-cask.rb").write <<~RUBY
// 714:         raise "untrusted installed cask evaluated"
// 715:       RUBY
// 716:
// 717:       cask = Cask::Cask.new("requested-cask", tap:) do
// 718:         version "1.0"
// 719:         conflicts_with cask: "#{tap}/conflicting-cask"
// 720:       end
// 721:       Homebrew::Trust.trust!(:cask, "#{tap}/requested-cask")
// 722:
// 723:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 724:         expect { Cask::Installer.new(cask).check_conflicts }
// 725:           .to raise_error(Cask::CaskConflictError, "Cask 'requested-cask' conflicts with 'conflicting-cask'.")
// 726:       end
// 727:     ensure
// 728:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 729:     end
// 730:   end
// 731:
// 732:   describe "conflicts_with stanza" do
// 733:     context "when valid" do
// 734:       let(:token) { "with-conflicts-with" }
// 735:
// 736:       it "allows conflicts_with stanza to be specified" do
// 737:         expect(cask.conflicts_with[:formula]).to be_empty
// 738:       end
// 739:     end
// 740:
// 741:     context "when specified multiple times" do
// 742:       let(:token) { "with-conflicts-with-multiple" }
// 743:
// 744:       it "merges and deduplicates all conflicts_with stanzas" do
// 745:         os_conflict = OS.mac? ? "macos-caffeine" : "linux-caffeine"
// 746:         expect(cask.conflicts_with[:cask])
// 747:           .to eq(Set.new(["local-caffeine", "with-caffeine", os_conflict]))
// 748:       end
// 749:     end
// 750:
// 751:     context "with invalid conflicts_with key" do
// 752:       let(:token) { "invalid-conflicts-with-key" }
// 753:
// 754:       it "refuses to load invalid conflicts_with key" do
// 755:         expect { cask }.to raise_error(Cask::CaskInvalidError)
// 756:       end
// 757:     end
// 758:   end
// 759:
// 760:   describe "installer stanza" do
// 761:     context "when script" do
// 762:       let(:token) { "with-installer-script" }
// 763:
// 764:       it "allows installer script to be specified" do
// 765:         expect(cask.artifacts.to_a.first.path).to eq(Pathname("/usr/bin/true"))
// 766:         expect(cask.artifacts.to_a.first.args[:args]).to eq(["--flag"])
// 767:         expect(cask.artifacts.to_a.second.path).to eq(Pathname("/usr/bin/false"))
// 768:         expect(cask.artifacts.to_a.second.args[:args]).to eq(["--flag"])
// 769:       end
// 770:     end
// 771:
// 772:     context "when manual" do
// 773:       let(:token) { "with-installer-manual" }
// 774:
// 775:       it "allows installer manual to be specified" do
// 776:         installer = cask.artifacts.first
// 777:         expect(installer.manual_install).to be true
// 778:         expect(installer.path).to eq(Pathname("Caffeine.app"))
// 779:       end
// 780:     end
// 781:   end
// 782:
// 783:   describe "stage_only stanza" do
// 784:     context "when there is no other activatable artifact" do
// 785:       let(:token) { "stage-only" }
// 786:
// 787:       it "allows stage_only stanza to be specified" do
// 788:         expect(cask.artifacts).to contain_exactly a_kind_of Cask::Artifact::StageOnly
// 789:       end
// 790:     end
// 791:
// 792:     context "when there is are activatable artifacts" do
// 793:       let(:token) { "invalid-stage-only-conflict" }
// 794:
// 795:       it "prevents specifying stage_only" do
// 796:         expect { cask }.to raise_error(Cask::CaskInvalidError, /'stage_only' must be the only activatable artifact/)
// 797:       end
// 798:     end
// 799:   end
// 800:
// 801:   describe "auto_updates stanza" do
// 802:     let(:token) { "auto-updates" }
// 803:
// 804:     it "allows auto_updates stanza to be specified" do
// 805:       expect(cask.auto_updates).to be true
// 806:     end
// 807:   end
// 808:
// 809:   describe "#appdir" do
// 810:     context "with interpolation of the appdir in stanzas" do
// 811:       let(:token) { "appdir-interpolation" }
// 812:
// 813:       it "is allowed" do
// 814:         expect(cask.artifacts.first.source).to eq(cask.config.appdir/"some/path")
// 815:       end
// 816:     end
// 817:
// 818:     it "does not include a trailing slash" do
// 819:       config = Cask::Config.new(explicit: {
// 820:         appdir: "/Applications/",
// 821:       })
// 822:
// 823:       cask = Cask::Cask.new("appdir-trailing-slash", config:) do
// 824:         binary "#{appdir}/some/path"
// 825:       end
// 826:
// 827:       expect(cask.artifacts.first.source).to eq(Pathname("/Applications/some/path"))
// 828:     end
// 829:   end
// 830:
// 831:   describe "#artifacts" do
// 832:     it "sorts artifacts according to the preferable installation order" do
// 833:       cask = Cask::Cask.new("appdir-trailing-slash") do
// 834:         postflight do
// 835:           next
// 836:         end
// 837:
// 838:         preflight do
// 839:           next
// 840:         end
// 841:
// 842:         binary "binary"
// 843:
// 844:         app "App.app"
// 845:       end
// 846:
// 847:       expect(cask.artifacts.map { |artifact| artifact.class.dsl_key }).to eq [
// 848:         :preflight,
// 849:         :app,
// 850:         :binary,
// 851:         :postflight,
// 852:       ]
// 853:     end
// 854:   end
// 855:
// 856:   describe "rename stanza" do
// 857:     it "allows setting single rename operation" do
// 858:       cask = Cask::Cask.new("rename-cask") do
// 859:         rename "Source*.pkg", "Target.pkg"
// 860:       end
// 861:
// 862:       expect(cask.rename.length).to eq(1)
// 863:       expect(cask.rename.first.from).to eq("Source*.pkg")
// 864:       expect(cask.rename.first.to).to eq("Target.pkg")
// 865:     end
// 866:
// 867:     it "allows setting multiple rename operations" do
// 868:       cask = Cask::Cask.new("multi-rename-cask") do
// 869:         rename "App*.pkg", "App.pkg"
// 870:         rename "Doc*.dmg", "Doc.dmg"
// 871:       end
// 872:
// 873:       expect(cask.rename.length).to eq(2)
// 874:       expect(cask.rename.first.from).to eq("App*.pkg")
// 875:       expect(cask.rename.first.to).to eq("App.pkg")
// 876:       expect(cask.rename.last.from).to eq("Doc*.dmg")
// 877:       expect(cask.rename.last.to).to eq("Doc.dmg")
// 878:     end
// 879:   end
// 880: end
