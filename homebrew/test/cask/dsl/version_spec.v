module dsl

import brew_runtime
import homebrew.cask.dsl as version_dsl

// Translated from Homebrew/brew `test/cask/dsl/version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:version) { described_class.new(raw_version) }` at line 5.
pub fn ruby_version_spec_l5_d1_version(raw_version brew_runtime.Value) !version_dsl.CaskVersion {
	return version_dsl.new_cask_version(raw_version)
}

// Ruby let `let(input_name.to_sym) { input_value }` at line 10.
pub fn ruby_version_spec_l10_d2_let_dynamic(input_value brew_runtime.Value) brew_runtime.Value {
	return input_value
}

// Ruby it `it { is_expected.to eq expected_output }` at line 12.
pub fn ruby_version_spec_l12_d3_anonymous(method string, input_value brew_runtime.Value,
	expected_output brew_runtime.Value) !bool {
	version := ruby_version_spec_l5_d1_version(ruby_version_spec_l10_d2_let_dynamic(input_value))!
	actual := ruby_version_spec_l76_d18_subject_dynamic(version, method)
	if method == 'csv' {
		return actual.string_array_data == expected_output.string_array_data
	}
	if actual.type_name == 'Bool' {
		return actual.bool_data == expected_output.bool_data
	}
	return actual.as_string() == expected_output.as_string()
}

// Ruby let `let(:raw_version) { "1.2.3" }` at line 18.
pub fn ruby_version_spec_l18_d4_raw_version() string {
	return '1.2.3'
}

// Ruby let `let(:other) { nil }` at line 21.
pub fn ruby_version_spec_l21_d5_other() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

// Ruby it `it { is_expected.to be false }` at line 23.
pub fn ruby_version_spec_l23_d6_anonymous() !bool {
	return !ruby_version_spec_l64_d16_subject_dynamic(ruby_version_spec_l5_d1_version(brew_runtime.string_value(ruby_version_spec_l18_d4_raw_version()))!, ruby_version_spec_l21_d5_other())
}

// Ruby let `let(:other) { "1.2.3" }` at line 28.
pub fn ruby_version_spec_l28_d7_other() brew_runtime.Value {
	return brew_runtime.string_value('1.2.3')
}

// Ruby it `it { is_expected.to be true }` at line 30.
pub fn ruby_version_spec_l30_d8_anonymous() !bool {
	return ruby_version_spec_l64_d16_subject_dynamic(ruby_version_spec_l5_d1_version(brew_runtime.string_value(ruby_version_spec_l18_d4_raw_version()))!, ruby_version_spec_l28_d7_other())
}

// Ruby let `let(:other) { "1.2.3.4" }` at line 34.
pub fn ruby_version_spec_l34_d9_other() brew_runtime.Value {
	return brew_runtime.string_value('1.2.3.4')
}

// Ruby it `it { is_expected.to be false }` at line 36.
pub fn ruby_version_spec_l36_d10_anonymous() !bool {
	return !ruby_version_spec_l64_d16_subject_dynamic(ruby_version_spec_l5_d1_version(brew_runtime.string_value(ruby_version_spec_l18_d4_raw_version()))!, ruby_version_spec_l34_d9_other())
}

// Ruby let `let(:other) { described_class.new("1.2.3") }` at line 42.
pub fn ruby_version_spec_l42_d11_other() !brew_runtime.Value {
	return version_dsl.cask_version_value(version_dsl.cask_version_from_string('1.2.3')!)
}

// Ruby it `it { is_expected.to be true }` at line 44.
pub fn ruby_version_spec_l44_d12_anonymous() !bool {
	return ruby_version_spec_l64_d16_subject_dynamic(ruby_version_spec_l5_d1_version(brew_runtime.string_value(ruby_version_spec_l18_d4_raw_version()))!, ruby_version_spec_l42_d11_other()!)
}

// Ruby let `let(:other) { described_class.new("1.2.3.4") }` at line 48.
pub fn ruby_version_spec_l48_d13_other() !brew_runtime.Value {
	return version_dsl.cask_version_value(version_dsl.cask_version_from_string('1.2.3.4')!)
}

// Ruby it `it { is_expected.to be false }` at line 50.
pub fn ruby_version_spec_l50_d14_anonymous() !bool {
	return !ruby_version_spec_l64_d16_subject_dynamic(ruby_version_spec_l5_d1_version(brew_runtime.string_value(ruby_version_spec_l18_d4_raw_version()))!, ruby_version_spec_l48_d13_other()!)
}

// Ruby it `it "raises an error when the version contains a slash" do` at line 56.
pub fn ruby_version_spec_l56_d15_raises() bool {
	version_dsl.new_cask_version(brew_runtime.string_value('0.1,../../directory/traversal')) or {
		return err.msg().contains('invalid characters: /')
	}
	return false
}

// Ruby subject `subject { version == other }` at line 64.
pub fn ruby_version_spec_l64_d16_subject_dynamic(version version_dsl.CaskVersion,
	other brew_runtime.Value) bool {
	if other.type_name == 'NilClass' {
		return false
	}
	if other.type_name == 'Cask::DSL::Version' {
		candidate := version_dsl.cask_version_from_value(other) or { return false }
		return version.text == candidate.text
	}
	return other.type_name == 'String' && version.text == other.as_string()
}

// Ruby subject `subject { version.eql?(other) }` at line 70.
pub fn ruby_version_spec_l70_d17_subject_dynamic(version version_dsl.CaskVersion,
	other brew_runtime.Value) bool {
	return ruby_version_spec_l64_d16_subject_dynamic(version, other)
}

// Ruby subject `subject { version.public_send(method) }` at line 76.
pub fn ruby_version_spec_l76_d18_subject_dynamic(version version_dsl.CaskVersion,
	method string) brew_runtime.Value {
	return match method {
		'latest?' { brew_runtime.bool_value(version.latest()) }
		'major' { version_dsl.cask_version_value(version.major()) }
		'minor' { version_dsl.cask_version_value(version.minor()) }
		'patch' { version_dsl.cask_version_value(version.patch()) }
		'major_minor' { version_dsl.cask_version_value(version.major_minor()) }
		'major_minor_patch' { version_dsl.cask_version_value(version.major_minor_patch()) }
		'minor_patch' { version_dsl.cask_version_value(version.minor_patch()) }
		'csv' { ruby_version_spec_l144_d19_subject_dynamic(version) }
		'before_comma' { version_dsl.cask_version_value(version.before_comma()) }
		'after_comma' { version_dsl.cask_version_value(version.after_comma()) }
		'dots_to_hyphens' { version_dsl.cask_version_value(version.convert_divider('.', '-')) }
		'dots_to_underscores' { version_dsl.cask_version_value(version.convert_divider('.', '_')) }
		'hyphens_to_dots' { version_dsl.cask_version_value(version.convert_divider('-', '.')) }
		'hyphens_to_underscores' {
			version_dsl.cask_version_value(version.convert_divider('-', '_'))
		}
		'underscores_to_dots' { version_dsl.cask_version_value(version.convert_divider('_', '.')) }
		'underscores_to_hyphens' {
			version_dsl.cask_version_value(version.convert_divider('_', '-'))
		}
		'no_dots' { version_dsl.cask_version_value(version.delete_divider('.')) }
		'no_hyphens' { version_dsl.cask_version_value(version.delete_divider('-')) }
		'no_underscores' { version_dsl.cask_version_value(version.delete_divider('_')) }
		'no_dividers' { version_dsl.cask_version_value(version.no_dividers()) }
		else { brew_runtime.object_value('NoMethodError', method) }
	}
}

// Ruby subject `subject { version.csv }` at line 144.
pub fn ruby_version_spec_l144_d19_subject_dynamic(version version_dsl.CaskVersion) brew_runtime.Value {
	return brew_runtime.string_array_value(version.csv().map(it.text))
}

// Ruby it `it "detects` at line 354.
pub fn ruby_version_spec_l354_d20_detects() !bool {
	for value in version_spec_unstable_versions() {
		if !version_dsl.cask_version_from_string(value)!.unstable() {
			return false
		}
	}
	return true
}

// Ruby it `it "does not detect` at line 364.
pub fn ruby_version_spec_l364_d21_does() !bool {
	for value in ['0.20.1,63d9b84e-bbcf-4a00-9427-0bb3f713c769',
		'1.5.4,13:53d8a307-a8ae-4f9b-9a59-a1adb8c67012', 'b226'] {
		if version_dsl.cask_version_from_string(value)!.unstable() {
			return false
		}
	}
	return true
}

fn version_spec_unstable_versions() []string {
	return [
		'0.0.11-beta.7',
		'0.0.23b-alpha',
		'0.1-beta',
		'0.1.0-beta.6',
		'0.10.0b',
		'0.2.0-alpha',
		'0.2.0-beta',
		'0.2.4-beta.9',
		'0.2.588-dev',
		'0.3-beta',
		'0.3.0-SNAPSHOT-624369f',
		'0.4.1-alpha',
		'0.4.9-alpha',
		'0.5.3,beta',
		'0.6-alpha1,a',
		'0.7.1b2',
		'0.7a19',
		'0.8.0b8',
		'0.8b3',
		'0.9.10-alpha',
		'0.9.3b',
		'08b2',
		'1.0-b9',
		'1.0-beta',
		'1.0-beta-7.0',
		'1.0-beta.3',
		'1.0.0-alpha.5',
		'1.0.0-alpha5',
		'1.0.0-beta-2.2,20160421',
		'1.0.0-beta.16',
		'1.0.0-rc',
		'1.0.6b1',
		'1.0.beta-43',
		'1.004,alpha',
		'1.0b10',
		'1.0b12',
		'1.1-alpha-20181201a',
		'1.1.16-beta-rc2',
		'1.1.58.BETA',
		'1.10.1,b87:8941241e',
		'1.13.0-beta.7',
		'1.13beta8',
		'1.15.0.b20190302001',
		'1.16.2-Beta',
		'1.1b23',
		'1.2.0,b200',
		'1.2.1pre1',
		'1.2.2-beta.2845',
		'1.20.0-beta.3',
		'1.2b24',
		'1.3.0,b102',
		'1.3.7a',
		'1.36.0-beta0',
		'1.4.3a',
		'1.6.0_65-b14-468',
		'1.6.4-beta0-4e46f007',
		'1.7,b566',
		'1.7b5',
		'1.9.3a',
		'1.9.3b8',
		'17.03.1-beta',
		'18.0-Leia_rc4',
		'18.2-rc-3',
		'1875Beta',
		'19.3.2,b4188-155116',
		'2.0-rc.22',
		'2.0.0-beta.2',
		'2.0.0-beta14',
		'2.0.0-dev.11,1902221558.a6b3c4a8',
		'2.0.12,b1807-50472cde',
		'2.0b',
		'2.0b2',
		'2.0b3-2020',
		'2.0b5',
		'2.1.1-dev.3',
		'2.12.12beta3',
		'2.12b1',
		'2.2-Beta',
		'2.2.0-RC1',
		'2.2b2',
		'2.3.0-beta1u1',
		'2.3.1,rc4',
		'2.3b19',
		'2.4.0-beta2',
		'2.4.6-beta3u2',
		'2.6.1-dev_2019-02-09_14-04_git-master-c1f194a',
		'2.7.4a1',
		'2.79b',
		'2.99pre5',
		'2019.1-Beta2',
		'2019.1-b112',
		'2019.1-beta1',
		'2019a',
		'26.1-rc1-1',
		'3.0.0-beta.5',
		'3.0.0-beta19',
		'3.0.0-canary.8',
		'3.0.0-preview-27122-01',
		'3.0.0-rc.14',
		'3.0.1-beta.19',
		'3.0.100-preview-010184',
		'3.0.6a',
		'3.00b5',
		'3.1.0-beta.1',
		'3.1.0_b15007',
		'3.2.8beta1',
		'3.21-beta',
		'3.7.9beta03,5210',
		'3b19',
		'4.0.0a',
		'4.2.0-preview',
		'4.3-beta5',
		'4.3b3',
		'4.99beta',
		'5.0.0-RC7',
		'5.5.0-beta-9',
		'6.0.0-beta3,20181228T124823',
		'6.0.0_BETA3,127054',
		'6.1.1b176',
		'6.2.0-preview.4',
		'6.2.0.0.beta1',
		'6.3.9_b16229',
		'6.44b',
		'7.0.6-7A69',
		'7.3.BETA-3',
		'8.5a8',
		'8u202,b08:1961070e4c9b4e26a04e7f5a083f551e',
	]
}

fn version_spec_value(value string) brew_runtime.Value {
	return brew_runtime.string_value(value)
}

fn version_spec_expectation(method string, input string, expected string) !bool {
	return ruby_version_spec_l12_d3_anonymous(method, version_spec_value(input), version_spec_value(expected))
}

pub fn version_spec_all_expectations() !bool {
	for method in ['major', 'minor', 'patch', 'major_minor', 'major_minor_patch', 'minor_patch',
		'before_comma', 'after_comma', 'dots_to_hyphens', 'dots_to_underscores', 'hyphens_to_dots',
		'hyphens_to_underscores', 'underscores_to_dots', 'underscores_to_hyphens', 'no_dots',
		'no_hyphens', 'no_underscores', 'no_dividers'] {
		for raw in [brew_runtime.Value{ type_name: 'Symbol', repr: 'latest' },
			brew_runtime.string_value('latest'), brew_runtime.string_value(''),
			brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }] {
			if !ruby_version_spec_l12_d3_anonymous(method, raw, version_spec_value(if raw.as_string() == 'latest' {
				'latest'} else {
				''}))! {
				return false
			}
		}
	}
	string_cases := {
		'major':                  {
			'1':           '1'
			'1.2':         '1'
			'1.2.3':       '1'
			'1.2.3-4,5:6': '1'
		}
		'minor':                  {
			'1':           ''
			'1.2':         '2'
			'1.2.3':       '2'
			'1.2.3-4,5:6': '2'
		}
		'patch':                  {
			'1':           ''
			'1.2':         ''
			'1.2.3':       '3'
			'1.2.3-4,5:6': '3-4'
		}
		'major_minor':            {
			'1':           '1'
			'1.2':         '1.2'
			'1.2.3':       '1.2'
			'1.2.3-4,5:6': '1.2'
		}
		'major_minor_patch':      {
			'1':           '1'
			'1.2':         '1.2'
			'1.2.3':       '1.2.3'
			'1.2.3-4,5:6': '1.2.3-4'
		}
		'minor_patch':            {
			'1':           ''
			'1.2':         '2'
			'1.2.3':       '2.3'
			'1.2.3-4,5:6': '2.3-4'
		}
		'before_comma':           {
			'1.2.3':     '1.2.3'
			'1.2.3,':    '1.2.3'
			',abc':      ''
			'1.2.3,abc': '1.2.3'
		}
		'after_comma':            {
			'1.2.3':     ''
			'1.2.3,':    ''
			',abc':      'abc'
			'1.2.3,abc': 'abc'
		}
		'dots_to_hyphens':        {
			'1.2.3_4-5': '1-2-3_4-5'
		}
		'dots_to_underscores':    {
			'1.2.3_4-5': '1_2_3_4-5'
		}
		'hyphens_to_dots':        {
			'1.2.3_4-5': '1.2.3_4.5'
		}
		'hyphens_to_underscores': {
			'1.2.3_4-5': '1.2.3_4_5'
		}
		'underscores_to_dots':    {
			'1.2.3_4-5': '1.2.3.4-5'
		}
		'underscores_to_hyphens': {
			'1.2.3_4-5': '1.2.3-4-5'
		}
		'no_dots':                {
			'1.2.3_4-5': '123_4-5'
		}
		'no_hyphens':             {
			'1.2.3_4-5': '1.2.3_45'
		}
		'no_underscores':         {
			'1.2.3_4-5': '1.2.34-5'
		}
		'no_dividers':            {
			'1.2.3_4-5': '12345'
		}
	}
	for method, cases in string_cases {
		for input, expected in cases {
			if !version_spec_expectation(method, input, expected)! {
				return false
			}
		}
	}
	if !ruby_version_spec_l12_d3_anonymous('latest?', brew_runtime.Value{
		type_name: 'Symbol'
		repr: 'latest'
	}, brew_runtime.bool_value(true))! || !ruby_version_spec_l12_d3_anonymous('latest?', brew_runtime.string_value('latest'), brew_runtime.bool_value(true))! || !ruby_version_spec_l12_d3_anonymous('latest?', brew_runtime.string_value(''), brew_runtime.bool_value(false))! || !ruby_version_spec_l12_d3_anonymous('latest?', brew_runtime.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}, brew_runtime.bool_value(false))! || !ruby_version_spec_l12_d3_anonymous('latest?', brew_runtime.string_value('1.2.3'), brew_runtime.bool_value(false))! {
		return false
	}
	csv_cases := {
		'latest':    ['latest']
		'':          []string{}
		'1.2.3':     ['1.2.3']
		'1.2.3,':    ['1.2.3']
		',abc':      ['', 'abc']
		'1.2.3,abc': ['1.2.3', 'abc']
	}
	for input, expected in csv_cases {
		if !ruby_version_spec_l12_d3_anonymous('csv', version_spec_value(input), brew_runtime.string_array_value(expected))! {
			return false
		}
	}
	return true
}

pub struct VersionSpecBoundary {
pub:
	line   int
	passed bool
}

pub fn version_spec_all_boundaries() ![]VersionSpecBoundary {
	return [
		VersionSpecBoundary{ line: 5, passed: ruby_version_spec_l5_d1_version(version_spec_value('1.0'))!.text == '1.0' },
		VersionSpecBoundary{ line: 10, passed: ruby_version_spec_l10_d2_let_dynamic(version_spec_value('x')).as_string() == 'x' },
		VersionSpecBoundary{ line: 12, passed: version_spec_all_expectations()! },
		VersionSpecBoundary{ line: 18, passed: ruby_version_spec_l18_d4_raw_version() == '1.2.3' },
		VersionSpecBoundary{ line: 21, passed: ruby_version_spec_l21_d5_other().type_name == 'NilClass' },
		VersionSpecBoundary{ line: 23, passed: ruby_version_spec_l23_d6_anonymous()! },
		VersionSpecBoundary{ line: 28, passed: ruby_version_spec_l28_d7_other().as_string() == '1.2.3' },
		VersionSpecBoundary{ line: 30, passed: ruby_version_spec_l30_d8_anonymous()! },
		VersionSpecBoundary{ line: 34, passed: ruby_version_spec_l34_d9_other().as_string() == '1.2.3.4' },
		VersionSpecBoundary{ line: 36, passed: ruby_version_spec_l36_d10_anonymous()! },
		VersionSpecBoundary{ line: 42, passed: ruby_version_spec_l42_d11_other()!.as_string() == '1.2.3' },
		VersionSpecBoundary{ line: 44, passed: ruby_version_spec_l44_d12_anonymous()! },
		VersionSpecBoundary{ line: 48, passed: ruby_version_spec_l48_d13_other()!.as_string() == '1.2.3.4' },
		VersionSpecBoundary{ line: 50, passed: ruby_version_spec_l50_d14_anonymous()! },
		VersionSpecBoundary{ line: 56, passed: ruby_version_spec_l56_d15_raises() },
		VersionSpecBoundary{ line: 64, passed: ruby_version_spec_l64_d16_subject_dynamic(version_dsl.cask_version_from_string('1.2.3')!, version_spec_value('1.2.3')) },
		VersionSpecBoundary{ line: 70, passed: ruby_version_spec_l70_d17_subject_dynamic(version_dsl.cask_version_from_string('1.2.3')!, version_spec_value('1.2.3')) },
		VersionSpecBoundary{ line: 76, passed: ruby_version_spec_l76_d18_subject_dynamic(version_dsl.cask_version_from_string('1.2.3')!, 'major').as_string() == '1' },
		VersionSpecBoundary{
			line: 144
			passed: ruby_version_spec_l144_d19_subject_dynamic(version_dsl.cask_version_from_string('1.2.3,abc')!).string_array_data == [
				'1.2.3',
				'abc',
			]
		},
		VersionSpecBoundary{ line: 354, passed: ruby_version_spec_l354_d20_detects()! },
		VersionSpecBoundary{ line: 364, passed: ruby_version_spec_l364_d21_does()! },
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::DSL::Version, :cask do
// 5:   let(:version) { described_class.new(raw_version) }
// 6:
// 7:   shared_examples "expectations hash" do |input_name, expectations|
// 8:     test_each(expectations) do |(input_value, expected_output)|
// 9:       context "when #{input_name} is #{input_value.inspect}" do
// 10:         let(input_name.to_sym) { input_value }
// 11:
// 12:         it { is_expected.to eq expected_output }
// 13:       end
// 14:     end
// 15:   end
// 16:
// 17:   shared_examples "version equality" do
// 18:     let(:raw_version) { "1.2.3" }
// 19:
// 20:     context "when other is nil" do
// 21:       let(:other) { nil }
// 22:
// 23:       it { is_expected.to be false }
// 24:     end
// 25:
// 26:     context "when other is a String" do
// 27:       context "when other == self.raw_version" do
// 28:         let(:other) { "1.2.3" }
// 29:
// 30:         it { is_expected.to be true }
// 31:       end
// 32:
// 33:       context "when other != self.raw_version" do
// 34:         let(:other) { "1.2.3.4" }
// 35:
// 36:         it { is_expected.to be false }
// 37:       end
// 38:     end
// 39:
// 40:     context "when other is a #{described_class}" do
// 41:       context "when other.raw_version == self.raw_version" do
// 42:         let(:other) { described_class.new("1.2.3") }
// 43:
// 44:         it { is_expected.to be true }
// 45:       end
// 46:
// 47:       context "when other.raw_version != self.raw_version" do
// 48:         let(:other) { described_class.new("1.2.3.4") }
// 49:
// 50:         it { is_expected.to be false }
// 51:       end
// 52:     end
// 53:   end
// 54:
// 55:   describe "#initialize" do
// 56:     it "raises an error when the version contains a slash" do
// 57:       expect do
// 58:         described_class.new("0.1,../../directory/traversal")
// 59:       end.to raise_error(TypeError, %r{invalid characters: /})
// 60:     end
// 61:   end
// 62:
// 63:   describe "#==" do
// 64:     subject { version == other }
// 65:
// 66:     include_examples "version equality"
// 67:   end
// 68:
// 69:   describe "#eql?" do
// 70:     subject { version.eql?(other) }
// 71:
// 72:     include_examples "version equality"
// 73:   end
// 74:
// 75:   shared_examples "version expectations hash" do |method, hash|
// 76:     subject { version.public_send(method) }
// 77:
// 78:     include_examples "expectations hash", :raw_version,
// 79:                      { :latest  => "latest",
// 80:                        "latest" => "latest",
// 81:                        ""       => "",
// 82:                        nil      => "" }.merge(hash)
// 83:   end
// 84:
// 85:   describe "#latest?" do
// 86:     include_examples "version expectations hash", :latest?,
// 87:                      :latest  => true,
// 88:                      "latest" => true,
// 89:                      ""       => false,
// 90:                      nil      => false,
// 91:                      "1.2.3"  => false
// 92:   end
// 93:
// 94:   describe "string manipulation helpers" do
// 95:     describe "#major" do
// 96:       include_examples "version expectations hash", :major,
// 97:                        "1"           => "1",
// 98:                        "1.2"         => "1",
// 99:                        "1.2.3"       => "1",
// 100:                        "1.2.3-4,5:6" => "1"
// 101:     end
// 102:
// 103:     describe "#minor" do
// 104:       include_examples "version expectations hash", :minor,
// 105:                        "1"           => "",
// 106:                        "1.2"         => "2",
// 107:                        "1.2.3"       => "2",
// 108:                        "1.2.3-4,5:6" => "2"
// 109:     end
// 110:
// 111:     describe "#patch" do
// 112:       include_examples "version expectations hash", :patch,
// 113:                        "1"           => "",
// 114:                        "1.2"         => "",
// 115:                        "1.2.3"       => "3",
// 116:                        "1.2.3-4,5:6" => "3-4"
// 117:     end
// 118:
// 119:     describe "#major_minor" do
// 120:       include_examples "version expectations hash", :major_minor,
// 121:                        "1"           => "1",
// 122:                        "1.2"         => "1.2",
// 123:                        "1.2.3"       => "1.2",
// 124:                        "1.2.3-4,5:6" => "1.2"
// 125:     end
// 126:
// 127:     describe "#major_minor_patch" do
// 128:       include_examples "version expectations hash", :major_minor_patch,
// 129:                        "1"           => "1",
// 130:                        "1.2"         => "1.2",
// 131:                        "1.2.3"       => "1.2.3",
// 132:                        "1.2.3-4,5:6" => "1.2.3-4"
// 133:     end
// 134:
// 135:     describe "#minor_patch" do
// 136:       include_examples "version expectations hash", :minor_patch,
// 137:                        "1"           => "",
// 138:                        "1.2"         => "2",
// 139:                        "1.2.3"       => "2.3",
// 140:                        "1.2.3-4,5:6" => "2.3-4"
// 141:     end
// 142:
// 143:     describe "#csv" do
// 144:       subject { version.csv }
// 145:
// 146:       include_examples "expectations hash", :raw_version,
// 147:                        :latest     => ["latest"],
// 148:                        "latest"    => ["latest"],
// 149:                        ""          => [],
// 150:                        nil         => [],
// 151:                        "1.2.3"     => ["1.2.3"],
// 152:                        "1.2.3,"    => ["1.2.3"],
// 153:                        ",abc"      => ["", "abc"],
// 154:                        "1.2.3,abc" => ["1.2.3", "abc"]
// 155:     end
// 156:
// 157:     describe "#before_comma" do
// 158:       include_examples "version expectations hash", :before_comma,
// 159:                        "1.2.3"     => "1.2.3",
// 160:                        "1.2.3,"    => "1.2.3",
// 161:                        ",abc"      => "",
// 162:                        "1.2.3,abc" => "1.2.3"
// 163:     end
// 164:
// 165:     describe "#after_comma" do
// 166:       include_examples "version expectations hash", :after_comma,
// 167:                        "1.2.3"     => "",
// 168:                        "1.2.3,"    => "",
// 169:                        ",abc"      => "abc",
// 170:                        "1.2.3,abc" => "abc"
// 171:     end
// 172:
// 173:     describe "#dots_to_hyphens" do
// 174:       include_examples "version expectations hash", :dots_to_hyphens,
// 175:                        "1.2.3_4-5" => "1-2-3_4-5"
// 176:     end
// 177:
// 178:     describe "#dots_to_underscores" do
// 179:       include_examples "version expectations hash", :dots_to_underscores,
// 180:                        "1.2.3_4-5" => "1_2_3_4-5"
// 181:     end
// 182:
// 183:     describe "#hyphens_to_dots" do
// 184:       include_examples "version expectations hash", :hyphens_to_dots,
// 185:                        "1.2.3_4-5" => "1.2.3_4.5"
// 186:     end
// 187:
// 188:     describe "#hyphens_to_underscores" do
// 189:       include_examples "version expectations hash", :hyphens_to_underscores,
// 190:                        "1.2.3_4-5" => "1.2.3_4_5"
// 191:     end
// 192:
// 193:     describe "#underscores_to_dots" do
// 194:       include_examples "version expectations hash", :underscores_to_dots,
// 195:                        "1.2.3_4-5" => "1.2.3.4-5"
// 196:     end
// 197:
// 198:     describe "#underscores_to_hyphens" do
// 199:       include_examples "version expectations hash", :underscores_to_hyphens,
// 200:                        "1.2.3_4-5" => "1.2.3-4-5"
// 201:     end
// 202:
// 203:     describe "#no_dots" do
// 204:       include_examples "version expectations hash", :no_dots,
// 205:                        "1.2.3_4-5" => "123_4-5"
// 206:     end
// 207:
// 208:     describe "#no_hyphens" do
// 209:       include_examples "version expectations hash", :no_hyphens,
// 210:                        "1.2.3_4-5" => "1.2.3_45"
// 211:     end
// 212:
// 213:     describe "#no_underscores" do
// 214:       include_examples "version expectations hash", :no_underscores,
// 215:                        "1.2.3_4-5" => "1.2.34-5"
// 216:     end
// 217:
// 218:     describe "#no_dividers" do
// 219:       include_examples "version expectations hash", :no_dividers,
// 220:                        "1.2.3_4-5" => "12345"
// 221:     end
// 222:   end
// 223:
// 224:   describe "#unstable?" do
// 225:     test_each([
// 226:       "0.0.11-beta.7",
// 227:       "0.0.23b-alpha",
// 228:       "0.1-beta",
// 229:       "0.1.0-beta.6",
// 230:       "0.10.0b",
// 231:       "0.2.0-alpha",
// 232:       "0.2.0-beta",
// 233:       "0.2.4-beta.9",
// 234:       "0.2.588-dev",
// 235:       "0.3-beta",
// 236:       "0.3.0-SNAPSHOT-624369f",
// 237:       "0.4.1-alpha",
// 238:       "0.4.9-alpha",
// 239:       "0.5.3,beta",
// 240:       "0.6-alpha1,a",
// 241:       "0.7.1b2",
// 242:       "0.7a19",
// 243:       "0.8.0b8",
// 244:       "0.8b3",
// 245:       "0.9.10-alpha",
// 246:       "0.9.3b",
// 247:       "08b2",
// 248:       "1.0-b9",
// 249:       "1.0-beta",
// 250:       "1.0-beta-7.0",
// 251:       "1.0-beta.3",
// 252:       "1.0.0-alpha.5",
// 253:       "1.0.0-alpha5",
// 254:       "1.0.0-beta-2.2,20160421",
// 255:       "1.0.0-beta.16",
// 256:       "1.0.0-rc",
// 257:       "1.0.6b1",
// 258:       "1.0.beta-43",
// 259:       "1.004,alpha",
// 260:       "1.0b10",
// 261:       "1.0b12",
// 262:       "1.1-alpha-20181201a",
// 263:       "1.1.16-beta-rc2",
// 264:       "1.1.58.BETA",
// 265:       "1.10.1,b87:8941241e",
// 266:       "1.13.0-beta.7",
// 267:       "1.13beta8",
// 268:       "1.15.0.b20190302001",
// 269:       "1.16.2-Beta",
// 270:       "1.1b23",
// 271:       "1.2.0,b200",
// 272:       "1.2.1pre1",
// 273:       "1.2.2-beta.2845",
// 274:       "1.20.0-beta.3",
// 275:       "1.2b24",
// 276:       "1.3.0,b102",
// 277:       "1.3.7a",
// 278:       "1.36.0-beta0",
// 279:       "1.4.3a",
// 280:       "1.6.0_65-b14-468",
// 281:       "1.6.4-beta0-4e46f007",
// 282:       "1.7,b566",
// 283:       "1.7b5",
// 284:       "1.9.3a",
// 285:       "1.9.3b8",
// 286:       "17.03.1-beta",
// 287:       "18.0-Leia_rc4",
// 288:       "18.2-rc-3",
// 289:       "1875Beta",
// 290:       "19.3.2,b4188-155116",
// 291:       "2.0-rc.22",
// 292:       "2.0.0-beta.2",
// 293:       "2.0.0-beta14",
// 294:       "2.0.0-dev.11,1902221558.a6b3c4a8",
// 295:       "2.0.12,b1807-50472cde",
// 296:       "2.0b",
// 297:       "2.0b2",
// 298:       "2.0b3-2020",
// 299:       "2.0b5",
// 300:       "2.1.1-dev.3",
// 301:       "2.12.12beta3",
// 302:       "2.12b1",
// 303:       "2.2-Beta",
// 304:       "2.2.0-RC1",
// 305:       "2.2b2",
// 306:       "2.3.0-beta1u1",
// 307:       "2.3.1,rc4",
// 308:       "2.3b19",
// 309:       "2.4.0-beta2",
// 310:       "2.4.6-beta3u2",
// 311:       "2.6.1-dev_2019-02-09_14-04_git-master-c1f194a",
// 312:       "2.7.4a1",
// 313:       "2.79b",
// 314:       "2.99pre5",
// 315:       "2019.1-Beta2",
// 316:       "2019.1-b112",
// 317:       "2019.1-beta1",
// 318:       "2019a",
// 319:       "26.1-rc1-1",
// 320:       "3.0.0-beta.5",
// 321:       "3.0.0-beta19",
// 322:       "3.0.0-canary.8",
// 323:       "3.0.0-preview-27122-01",
// 324:       "3.0.0-rc.14",
// 325:       "3.0.1-beta.19",
// 326:       "3.0.100-preview-010184",
// 327:       "3.0.6a",
// 328:       "3.00b5",
// 329:       "3.1.0-beta.1",
// 330:       "3.1.0_b15007",
// 331:       "3.2.8beta1",
// 332:       "3.21-beta",
// 333:       "3.7.9beta03,5210",
// 334:       "3b19",
// 335:       "4.0.0a",
// 336:       "4.2.0-preview",
// 337:       "4.3-beta5",
// 338:       "4.3b3",
// 339:       "4.99beta",
// 340:       "5.0.0-RC7",
// 341:       "5.5.0-beta-9",
// 342:       "6.0.0-beta3,20181228T124823",
// 343:       "6.0.0_BETA3,127054",
// 344:       "6.1.1b176",
// 345:       "6.2.0-preview.4",
// 346:       "6.2.0.0.beta1",
// 347:       "6.3.9_b16229",
// 348:       "6.44b",
// 349:       "7.0.6-7A69",
// 350:       "7.3.BETA-3",
// 351:       "8.5a8",
// 352:       "8u202,b08:1961070e4c9b4e26a04e7f5a083f551e",
// 353:     ]) do |unstable_version|
// 354:       it "detects #{unstable_version.inspect} as unstable" do
// 355:         expect(described_class.new(unstable_version)).to be_unstable
// 356:       end
// 357:     end
// 358:
// 359:     test_each([
// 360:       "0.20.1,63d9b84e-bbcf-4a00-9427-0bb3f713c769",
// 361:       "1.5.4,13:53d8a307-a8ae-4f9b-9a59-a1adb8c67012",
// 362:       "b226",
// 363:     ]) do |stable_version|
// 364:       it "does not detect #{stable_version.inspect} as unstable" do
// 365:         expect(described_class.new(stable_version)).not_to be_unstable
// 366:       end
// 367:     end
// 368:   end
// 369: end
