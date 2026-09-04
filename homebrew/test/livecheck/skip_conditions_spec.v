module livecheck

import homebrew.livecheck as livecheck_core

// Translated from Homebrew/brew `test/livecheck/skip_conditions_spec.rb`.
pub type SkipConditionsPackage = livecheck_core.SkipConditionsPackage

pub type SkipConditionsPackageKind = livecheck_core.SkipConditionsPackageKind

pub type SkipConditionsMeta = livecheck_core.SkipConditionsMeta

pub type SkipConditionsOutput = livecheck_core.SkipConditionsOutput

pub type SkipInformation = livecheck_core.SkipInformation

fn skip_spec_formulae() map[string]SkipConditionsPackage {
	return {
		'basic':               SkipConditionsPackage{
			kind: .formula
			name: 'test'
			full_name: 'test'
			stable_url: 'https://brew.sh/test-0.0.1.tgz'
			livecheck_defined: true
			present: true
		}
		'deprecated':          SkipConditionsPackage{
			kind: .formula
			name: 'test_deprecated'
			full_name: 'test_deprecated'
			stable_url: 'https://brew.sh/test-0.0.1.tgz'
			deprecated: true
			present: true
		}
		'disabled':            SkipConditionsPackage{
			kind: .formula
			name: 'test_disabled'
			full_name: 'test_disabled'
			stable_url: 'https://brew.sh/test-0.0.1.tgz'
			disabled: true
			present: true
		}
		'head_only':           SkipConditionsPackage{
			kind: .formula
			name: 'test_head_only'
			full_name: 'test_head_only'
			head_only: true
			present: true
		}
		'gist':                SkipConditionsPackage{
			kind: .formula
			name: 'test_gist'
			full_name: 'test_gist'
			stable_url: 'https://gist.github.com/Homebrew/0000000000'
			present: true
		}
		'google_code_archive': SkipConditionsPackage{
			kind: .formula
			name: 'test_google_code_archive'
			full_name: 'test_google_code_archive'
			stable_url: 'https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/brew/brew-1.0.0.tar.gz'
			present: true
		}
		'internet_archive':    SkipConditionsPackage{
			kind: .formula
			name: 'test_internet_archive'
			full_name: 'test_internet_archive'
			stable_url: 'https://web.archive.org/web/20200101000000/https://brew.sh/test-0.0.1.tgz'
			present: true
		}
		'skip':                SkipConditionsPackage{
			kind: .formula
			name: 'test_skip'
			full_name: 'test_skip'
			stable_url: 'https://brew.sh/test-0.0.1.tgz'
			livecheck_defined: true
			livecheck_skip: true
			present: true
		}
		'skip_with_message':   SkipConditionsPackage{
			kind: .formula
			name: 'test_skip_with_message'
			full_name: 'test_skip_with_message'
			stable_url: 'https://brew.sh/test-0.0.1.tgz'
			livecheck_defined: true
			livecheck_skip: true
			livecheck_skip_message: 'Not maintained'
			present: true
		}
		'versioned':           SkipConditionsPackage{
			kind: .formula
			name: 'test@0.0.1'
			full_name: 'test@0.0.1'
			stable_url: 'https://brew.sh/test-0.0.1.tgz'
			versioned: true
			present: true
		}
	}
}

fn skip_spec_casks() map[string]SkipConditionsPackage {
	return {
		'basic':                                 SkipConditionsPackage{
			kind: .cask
			name: 'test'
			full_name: 'test'
			livecheck_defined: true
			present: true
		}
		'deprecated':                            SkipConditionsPackage{
			kind: .cask
			name: 'test_deprecated'
			full_name: 'test_deprecated'
			deprecated: true
			present: true
		}
		'disabled':                              SkipConditionsPackage{
			kind: .cask
			name: 'test_disabled'
			full_name: 'test_disabled'
			disabled: true
			present: true
		}
		'future_disable_fails_gatekeeper_check': SkipConditionsPackage{
			kind: .cask
			name: 'test_future_disable_fails_gatekeeper_check'
			full_name: 'test_future_disable_fails_gatekeeper_check'
			deprecated: true
			has_disable_date: true
			deprecation_reason: 'fails_gatekeeper_check'
			present: true
		}
		'extract_plist':                         SkipConditionsPackage{
			kind: .cask
			name: 'test_extract_plist_skip'
			full_name: 'test_extract_plist_skip'
			livecheck_defined: true
			livecheck_strategy: 'extract_plist'
			present: true
		}
		'latest':                                SkipConditionsPackage{
			kind: .cask
			name: 'test_latest'
			full_name: 'test_latest'
			present: true
			version_latest: true
		}
		'unversioned':                           SkipConditionsPackage{
			kind: .cask
			name: 'test_unversioned'
			full_name: 'test_unversioned'
			present: true
			url_unversioned: true
		}
		'skip':                                  SkipConditionsPackage{
			kind: .cask
			name: 'test_skip'
			full_name: 'test_skip'
			livecheck_defined: true
			livecheck_skip: true
			present: true
		}
		'skip_with_message':                     SkipConditionsPackage{
			kind: .cask
			name: 'test_skip_with_message'
			full_name: 'test_skip_with_message'
			livecheck_defined: true
			livecheck_skip: true
			livecheck_skip_message: 'Not maintained'
			present: true
		}
	}
}

fn skip_spec_status(kind SkipConditionsPackageKind, name string, status string, messages []string,
	livecheck_defined bool, head_only bool) SkipInformation {
	return SkipInformation{
		present: true
		package_kind: kind
		package_name: name
		status: status
		messages: messages.clone()
		has_messages: messages.len > 0
		meta: SkipConditionsMeta{
			livecheck_defined: livecheck_defined
			head_only: head_only
		}
	}
}

fn skip_spec_status_hashes() map[string]SkipInformation {
	return {
		'formula.deprecated':          skip_spec_status(.formula, 'test_deprecated', 'deprecated', [], false, false)
		'formula.disabled':            skip_spec_status(.formula, 'test_disabled', 'disabled', [], false, false)
		'formula.versioned':           skip_spec_status(.formula, 'test@0.0.1', 'versioned', [], false, false)
		'formula.head_only':           skip_spec_status(.formula, 'test_head_only', 'error', [
			'HEAD only formula must be installed to be checkable',
		], false, true)
		'formula.gist':                skip_spec_status(.formula, 'test_gist', 'skipped', [
			'Stable URL is a GitHub Gist',
		], false, false)
		'formula.google_code_archive': skip_spec_status(.formula, 'test_google_code_archive', 'skipped', [
			'Stable URL is from Google Code Archive',
		], false, false)
		'formula.internet_archive':    skip_spec_status(.formula, 'test_internet_archive', 'skipped', [
			'Stable URL is from Internet Archive',
		], false, false)
		'formula.skip':                skip_spec_status(.formula, 'test_skip', 'skipped', [], true, false)
		'formula.skip_with_message':   skip_spec_status(.formula, 'test_skip_with_message', 'skipped', [
			'Not maintained',
		], true, false)
		'formula.skip_with_messages':  skip_spec_status(.formula, 'test_skip_with_messages', 'skipped', [
			'First message',
			'Second message',
		], true, false)
		'formula.error_with_messages': skip_spec_status(.formula, 'test_error_with_messages', 'error', [
			'First error',
			'Second error',
		], true, false)
		'cask.deprecated':             skip_spec_status(.cask, 'test_deprecated', 'deprecated', [], false, false)
		'cask.disabled':               skip_spec_status(.cask, 'test_disabled', 'disabled', [], false, false)
		'cask.extract_plist':          skip_spec_status(.cask, 'test_extract_plist_skip', 'skipped', [
			'Use `--extract-plist` to enable checking multiple casks with ExtractPlist strategy',
		], true, false)
		'cask.latest':                 skip_spec_status(.cask, 'test_latest', 'latest', [], false, false)
		'cask.unversioned':            skip_spec_status(.cask, 'test_unversioned', 'unversioned', [], false, false)
		'cask.skip':                   skip_spec_status(.cask, 'test_skip', 'skipped', [], true, false)
		'cask.skip_with_message':      skip_spec_status(.cask, 'test_skip_with_message', 'skipped', [
			'Not maintained',
		], true, false)
		'cask.skip_with_messages':     skip_spec_status(.cask, 'test_skip_with_messages', 'skipped', [
			'First message',
			'Second message',
		], true, false)
		'cask.error_with_messages':    skip_spec_status(.cask, 'test_error_with_messages', 'error', [
			'First error',
			'Second error',
		], true, false)
	}
}

fn skip_spec_information(package SkipConditionsPackage, expected SkipInformation,
	extract_plist bool) bool {
	actual := livecheck_core.skip_conditions_skip_information(package, false, false, extract_plist)
	return livecheck_core.skip_information_equal(actual, expected)
}

fn skip_spec_reference_error(package SkipConditionsPackage, expected string,
	extract_plist bool) bool {
	mut message := ''
	livecheck_core.ruby_skip_conditions_l273_d12_self_referenced_skip_information(package, 'original', false, false, extract_plist) or { message = err.msg() }
	return message == expected
}

fn skip_spec_referenced(package SkipConditionsPackage, expected SkipInformation,
	extract_plist bool) bool {
	result := livecheck_core.ruby_skip_conditions_l273_d12_self_referenced_skip_information(package, 'original', false, false, extract_plist) or { return false }
	return result.has_information && livecheck_core.skip_information_equal(result.information, expected)
}

fn skip_spec_print(information SkipInformation, expected string) bool {
	mut output := SkipConditionsOutput{}
	livecheck_core.ruby_skip_conditions_l315_d13_self_print_skip_information(information, mut output)
	return output.text() == expected
}

// Ruby subject `subject(:skip_conditions) { described_class }` at line 8.
pub fn ruby_skip_conditions_spec_l8_d1_skip_conditions() string {
	return 'Homebrew::Livecheck::SkipConditions'
}

// Ruby let `let(:formulae) do` at line 10.
pub fn ruby_skip_conditions_spec_l10_d2_formulae() map[string]SkipConditionsPackage {
	return skip_spec_formulae()
}

// Ruby let `let(:casks) do` at line 90.
pub fn ruby_skip_conditions_spec_l90_d3_casks() map[string]SkipConditionsPackage {
	return skip_spec_casks()
}

// Ruby let `let(:status_hashes) do` at line 193.
pub fn ruby_skip_conditions_spec_l193_d4_status_hashes() map[string]SkipInformation {
	return skip_spec_status_hashes()
}

// Ruby it `it "skips" do` at line 356.
pub fn ruby_skip_conditions_spec_l356_d5_skips() bool {
	return skip_spec_information(skip_spec_formulae()['deprecated'], skip_spec_status_hashes()['formula.deprecated'], true)
}

// Ruby it `it "skips" do` at line 363.
pub fn ruby_skip_conditions_spec_l363_d6_skips() bool {
	return skip_spec_information(skip_spec_formulae()['disabled'], skip_spec_status_hashes()['formula.disabled'], true)
}

// Ruby it `it "skips" do` at line 370.
pub fn ruby_skip_conditions_spec_l370_d7_skips() bool {
	return skip_spec_information(skip_spec_formulae()['versioned'], skip_spec_status_hashes()['formula.versioned'], true)
}

// Ruby it `it "skips" do` at line 377.
pub fn ruby_skip_conditions_spec_l377_d8_skips() bool {
	return skip_spec_information(skip_spec_formulae()['head_only'], skip_spec_status_hashes()['formula.head_only'], true)
}

// Ruby it `it "skips" do` at line 384.
pub fn ruby_skip_conditions_spec_l384_d9_skips() bool {
	return skip_spec_information(skip_spec_formulae()['gist'], skip_spec_status_hashes()['formula.gist'], true)
}

// Ruby it `it "skips" do` at line 391.
pub fn ruby_skip_conditions_spec_l391_d10_skips() bool {
	return skip_spec_information(skip_spec_formulae()['google_code_archive'], skip_spec_status_hashes()['formula.google_code_archive'], true)
}

// Ruby it `it "skips" do` at line 398.
pub fn ruby_skip_conditions_spec_l398_d11_skips() bool {
	return skip_spec_information(skip_spec_formulae()['internet_archive'], skip_spec_status_hashes()['formula.internet_archive'], true)
}

// Ruby it `it "skips" do` at line 405.
pub fn ruby_skip_conditions_spec_l405_d12_skips() bool {
	formulae := skip_spec_formulae()
	statuses := skip_spec_status_hashes()
	return skip_spec_information(formulae['skip'], statuses['formula.skip'], true) && skip_spec_information(formulae['skip_with_message'], statuses['formula.skip_with_message'], true)
}

// Ruby it `it "skips" do` at line 415.
pub fn ruby_skip_conditions_spec_l415_d13_skips() bool {
	return skip_spec_information(skip_spec_casks()['deprecated'], skip_spec_status_hashes()['cask.deprecated'], true)
}

// Ruby it `it "skips" do` at line 422.
pub fn ruby_skip_conditions_spec_l422_d14_skips() bool {
	return skip_spec_information(skip_spec_casks()['disabled'], skip_spec_status_hashes()['cask.disabled'], true)
}

// Ruby it `it "does not skip" do` at line 430.
pub fn ruby_skip_conditions_spec_l430_d15_does() bool {
	return !livecheck_core.skip_conditions_skip_information(skip_spec_casks()['future_disable_fails_gatekeeper_check'], false, false, true).present
}

// Ruby it `it "skips" do` at line 436.
pub fn ruby_skip_conditions_spec_l436_d16_skips() bool {
	return skip_spec_information(skip_spec_casks()['extract_plist'], skip_spec_status_hashes()['cask.extract_plist'], false)
}

// Ruby it `it "skips" do` at line 443.
pub fn ruby_skip_conditions_spec_l443_d17_skips() bool {
	return skip_spec_information(skip_spec_casks()['latest'], skip_spec_status_hashes()['cask.latest'], true)
}

// Ruby it `it "skips" do` at line 450.
pub fn ruby_skip_conditions_spec_l450_d18_skips() bool {
	return skip_spec_information(skip_spec_casks()['unversioned'], skip_spec_status_hashes()['cask.unversioned'], true)
}

// Ruby it `it "skips" do` at line 457.
pub fn ruby_skip_conditions_spec_l457_d19_skips() bool {
	casks := skip_spec_casks()
	statuses := skip_spec_status_hashes()
	return skip_spec_information(casks['skip'], statuses['cask.skip'], true) && skip_spec_information(casks['skip_with_message'], statuses['cask.skip_with_message'], true)
}

// Ruby it `it "returns an empty hash for a non-skippable formula" do` at line 466.
pub fn ruby_skip_conditions_spec_l466_d20_returns() bool {
	return !livecheck_core.skip_conditions_skip_information(skip_spec_formulae()['basic'], false, false, true).present
}

// Ruby it `it "returns an empty hash for a non-skippable cask" do` at line 470.
pub fn ruby_skip_conditions_spec_l470_d21_returns() bool {
	return !livecheck_core.skip_conditions_skip_information(skip_spec_casks()['basic'], false, false, true).present
}

// Ruby let `let(:original_name) { "original" }` at line 476.
pub fn ruby_skip_conditions_spec_l476_d22_original_name() string {
	return 'original'
}

// Ruby it `it "errors" do` at line 479.
pub fn ruby_skip_conditions_spec_l479_d23_errors() bool {
	return skip_spec_reference_error(skip_spec_formulae()['deprecated'], 'Referenced formula (test_deprecated) is skipped as deprecated', true)
}

// Ruby it `it "errors" do` at line 486.
pub fn ruby_skip_conditions_spec_l486_d24_errors() bool {
	return skip_spec_reference_error(skip_spec_formulae()['disabled'], 'Referenced formula (test_disabled) is skipped as disabled', true)
}

// Ruby it `it "errors" do` at line 493.
pub fn ruby_skip_conditions_spec_l493_d25_errors() bool {
	return skip_spec_reference_error(skip_spec_formulae()['versioned'], 'Referenced formula (test@0.0.1) is skipped as versioned', true)
}

// Ruby it `it "skips" do` at line 500.
pub fn ruby_skip_conditions_spec_l500_d26_skips() bool {
	mut expected := skip_spec_status_hashes()['formula.head_only']
	expected.package_name = 'original'
	return skip_spec_referenced(skip_spec_formulae()['head_only'], expected, true)
}

// Ruby it `it "errors" do` at line 507.
pub fn ruby_skip_conditions_spec_l507_d27_errors() bool {
	return skip_spec_reference_error(skip_spec_formulae()['gist'], 'Referenced formula (test_gist) is automatically skipped', true)
}

// Ruby it `it "errors" do` at line 514.
pub fn ruby_skip_conditions_spec_l514_d28_errors() bool {
	return skip_spec_reference_error(skip_spec_formulae()['google_code_archive'], 'Referenced formula (test_google_code_archive) is automatically skipped', true)
}

// Ruby it `it "errors" do` at line 521.
pub fn ruby_skip_conditions_spec_l521_d29_errors() bool {
	return skip_spec_reference_error(skip_spec_formulae()['internet_archive'], 'Referenced formula (test_internet_archive) is automatically skipped', true)
}

// Ruby it `it "skips" do` at line 528.
pub fn ruby_skip_conditions_spec_l528_d30_skips() bool {
	formulae := skip_spec_formulae()
	statuses := skip_spec_status_hashes()
	mut expected_skip := statuses['formula.skip']
	expected_skip.package_name = 'original'
	mut expected_message := statuses['formula.skip_with_message']
	expected_message.package_name = 'original'
	return skip_spec_referenced(formulae['skip'], expected_skip, true) && skip_spec_referenced(formulae['skip_with_message'], expected_message, true)
}

// Ruby it `it "errors" do` at line 538.
pub fn ruby_skip_conditions_spec_l538_d31_errors() bool {
	return skip_spec_reference_error(skip_spec_casks()['deprecated'], 'Referenced cask (test_deprecated) is skipped as deprecated', true)
}

// Ruby it `it "errors" do` at line 545.
pub fn ruby_skip_conditions_spec_l545_d32_errors() bool {
	return skip_spec_reference_error(skip_spec_casks()['disabled'], 'Referenced cask (test_disabled) is skipped as disabled', true)
}

// Ruby it `it "skips" do` at line 552.
pub fn ruby_skip_conditions_spec_l552_d33_skips() bool {
	return skip_spec_reference_error(skip_spec_casks()['extract_plist'], 'Referenced cask (test_extract_plist_skip) is automatically skipped', false)
}

// Ruby it `it "errors" do` at line 561.
pub fn ruby_skip_conditions_spec_l561_d34_errors() bool {
	return skip_spec_reference_error(skip_spec_casks()['latest'], 'Referenced cask (test_latest) is skipped as latest', true)
}

// Ruby it `it "errors" do` at line 568.
pub fn ruby_skip_conditions_spec_l568_d35_errors() bool {
	return skip_spec_reference_error(skip_spec_casks()['unversioned'], 'Referenced cask (test_unversioned) is skipped as unversioned', true)
}

// Ruby it `it "skips" do` at line 575.
pub fn ruby_skip_conditions_spec_l575_d36_skips() bool {
	casks := skip_spec_casks()
	statuses := skip_spec_status_hashes()
	mut expected_skip := statuses['cask.skip']
	expected_skip.package_name = 'original'
	mut expected_message := statuses['cask.skip_with_message']
	expected_message.package_name = 'original'
	return skip_spec_referenced(casks['skip'], expected_skip, true) && skip_spec_referenced(casks['skip_with_message'], expected_message, true)
}

// Ruby it `it "returns an empty hash for a non-skippable formula" do` at line 584.
pub fn ruby_skip_conditions_spec_l584_d37_returns() bool {
	result := livecheck_core.ruby_skip_conditions_l273_d12_self_referenced_skip_information(skip_spec_formulae()['basic'], 'original', false, false, true) or { return false }
	return !result.has_information
}

// Ruby it `it "returns an empty hash for a non-skippable cask" do` at line 588.
pub fn ruby_skip_conditions_spec_l588_d38_returns() bool {
	result := livecheck_core.ruby_skip_conditions_l273_d12_self_referenced_skip_information(skip_spec_casks()['basic'], 'original', false, false, true) or { return false }
	return !result.has_information
}

// Ruby it `it "prints skip information" do` at line 595.
pub fn ruby_skip_conditions_spec_l595_d39_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['formula.deprecated'], 'test_deprecated: deprecated\n')
}

// Ruby it `it "prints skip information" do` at line 603.
pub fn ruby_skip_conditions_spec_l603_d40_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['formula.disabled'], 'test_disabled: disabled\n')
}

// Ruby it `it "prints skip information" do` at line 611.
pub fn ruby_skip_conditions_spec_l611_d41_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['formula.versioned'], 'test@0.0.1: versioned\n')
}

// Ruby it `it "prints skip information" do` at line 619.
pub fn ruby_skip_conditions_spec_l619_d42_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['formula.head_only'], 'test_head_only: HEAD only formula must be installed to be checkable\n')
}

// Ruby it `it "prints skip information" do` at line 627.
pub fn ruby_skip_conditions_spec_l627_d43_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['formula.gist'], 'test_gist: skipped - Stable URL is a GitHub Gist\n')
}

// Ruby it `it "prints skip information" do` at line 635.
pub fn ruby_skip_conditions_spec_l635_d44_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['formula.google_code_archive'], 'test_google_code_archive: skipped - Stable URL is from Google Code Archive\n')
}

// Ruby it `it "prints skip information" do` at line 643.
pub fn ruby_skip_conditions_spec_l643_d45_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['formula.internet_archive'], 'test_internet_archive: skipped - Stable URL is from Internet Archive\n')
}

// Ruby it `it "prints skip information" do` at line 651.
pub fn ruby_skip_conditions_spec_l651_d46_prints() bool {
	statuses := skip_spec_status_hashes()
	return skip_spec_print(statuses['formula.skip'], 'test_skip: skipped\n') && skip_spec_print(statuses['formula.skip_with_message'], 'test_skip_with_message: skipped - Not maintained\n')
}

// Ruby it `it "prints skip information" do` at line 663.
pub fn ruby_skip_conditions_spec_l663_d47_prints() bool {
	statuses := skip_spec_status_hashes()
	return skip_spec_print(statuses['formula.skip_with_messages'], 'test_skip_with_messages: skipped - First message; Second message\n') && skip_spec_print(statuses['formula.error_with_messages'], 'test_error_with_messages: First error; Second error\n')
}

// Ruby it `it "prints skip information" do` at line 679.
pub fn ruby_skip_conditions_spec_l679_d48_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['cask.deprecated'], 'test_deprecated: deprecated\n')
}

// Ruby it `it "prints skip information" do` at line 687.
pub fn ruby_skip_conditions_spec_l687_d49_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['cask.disabled'], 'test_disabled: disabled\n')
}

// Ruby it `it "prints skip information" do` at line 695.
pub fn ruby_skip_conditions_spec_l695_d50_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['cask.latest'], 'test_latest: latest\n')
}

// Ruby it `it "prints skip information" do` at line 703.
pub fn ruby_skip_conditions_spec_l703_d51_prints() bool {
	return skip_spec_print(skip_spec_status_hashes()['cask.unversioned'], 'test_unversioned: unversioned\n')
}

// Ruby it `it "prints skip information" do` at line 711.
pub fn ruby_skip_conditions_spec_l711_d52_prints() bool {
	statuses := skip_spec_status_hashes()
	return skip_spec_print(statuses['cask.skip'], 'test_skip: skipped\n') && skip_spec_print(statuses['cask.skip_with_message'], 'test_skip_with_message: skipped - Not maintained\n')
}

// Ruby it `it "prints skip information" do` at line 723.
pub fn ruby_skip_conditions_spec_l723_d53_prints() bool {
	statuses := skip_spec_status_hashes()
	return skip_spec_print(statuses['cask.skip_with_messages'], 'test_skip_with_messages: skipped - First message; Second message\n') && skip_spec_print(statuses['cask.error_with_messages'], 'test_error_with_messages: First error; Second error\n')
}

// Ruby it `it "prints nothing" do` at line 739.
pub fn ruby_skip_conditions_spec_l739_d54_prints() bool {
	return skip_spec_print(SkipInformation{}, '')
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/livecheck"
// 5: require "livecheck/skip_conditions"
// 6:
// 7: RSpec.describe Homebrew::Livecheck::SkipConditions do
// 8:   subject(:skip_conditions) { described_class }
// 9:
// 10:   let(:formulae) do
// 11:     {
// 12:       basic:               formula("test") do
// 13:         T.bind(self, T.class_of(Formula))
// 14:         desc "Test formula"
// 15:         homepage "https://brew.sh"
// 16:         url "https://brew.sh/test-0.0.1.tgz"
// 17:         head "https://github.com/Homebrew/brew.git", branch: "main"
// 18:
// 19:         livecheck do
// 20:           url "https://formulae.brew.sh/api/formula/ruby.json"
// 21:           regex(/"stable":"(\d+(?:\.\d+)+)"/i)
// 22:         end
// 23:       end,
// 24:       deprecated:          formula("test_deprecated") do
// 25:         T.bind(self, T.class_of(Formula))
// 26:         desc "Deprecated test formula"
// 27:         homepage "https://brew.sh"
// 28:         url "https://brew.sh/test-0.0.1.tgz"
// 29:         deprecate! date: "2020-06-25", because: :unmaintained
// 30:       end,
// 31:       disabled:            formula("test_disabled") do
// 32:         T.bind(self, T.class_of(Formula))
// 33:         desc "Disabled test formula"
// 34:         homepage "https://brew.sh"
// 35:         url "https://brew.sh/test-0.0.1.tgz"
// 36:         disable! date: "2020-06-25", because: :unmaintained
// 37:       end,
// 38:       head_only:           formula("test_head_only") do
// 39:         T.bind(self, T.class_of(Formula))
// 40:         desc "HEAD-only test formula"
// 41:         homepage "https://brew.sh"
// 42:         head "https://github.com/Homebrew/brew.git", branch: "main"
// 43:       end,
// 44:       gist:                formula("test_gist") do
// 45:         T.bind(self, T.class_of(Formula))
// 46:         desc "Gist test formula"
// 47:         homepage "https://brew.sh"
// 48:         url "https://gist.github.com/Homebrew/0000000000"
// 49:       end,
// 50:       google_code_archive: formula("test_google_code_archive") do
// 51:         T.bind(self, T.class_of(Formula))
// 52:         desc "Google Code Archive test formula"
// 53:         homepage "https://brew.sh"
// 54:         url "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/brew/brew-1.0.0.tar.gz"
// 55:       end,
// 56:       internet_archive:    formula("test_internet_archive") do
// 57:         T.bind(self, T.class_of(Formula))
// 58:         desc "Internet Archive test formula"
// 59:         homepage "https://brew.sh"
// 60:         url "https://web.archive.org/web/20200101000000/https://brew.sh/test-0.0.1.tgz"
// 61:       end,
// 62:       skip:                formula("test_skip") do
// 63:         T.bind(self, T.class_of(Formula))
// 64:         desc "Skipped test formula"
// 65:         homepage "https://brew.sh"
// 66:         url "https://brew.sh/test-0.0.1.tgz"
// 67:
// 68:         livecheck do
// 69:           skip
// 70:         end
// 71:       end,
// 72:       skip_with_message:   formula("test_skip_with_message") do
// 73:         T.bind(self, T.class_of(Formula))
// 74:         desc "Skipped test formula"
// 75:         homepage "https://brew.sh"
// 76:         url "https://brew.sh/test-0.0.1.tgz"
// 77:
// 78:         livecheck do
// 79:           skip "Not maintained"
// 80:         end
// 81:       end,
// 82:       versioned:           formula("test@0.0.1") do
// 83:         T.bind(self, T.class_of(Formula))
// 84:         desc "Versioned test formula"
// 85:         homepage "https://brew.sh"
// 86:         url "https://brew.sh/test-0.0.1.tgz"
// 87:       end,
// 88:     }
// 89:   end
// 90:   let(:casks) do
// 91:     {
// 92:       basic:                                 Cask::Cask.new("test") do
// 93:         version "0.0.1,2"
// 94:
// 95:         url "https://brew.sh/test-#{version.csv.first}.tgz"
// 96:         name "Test"
// 97:         desc "Test cask"
// 98:         homepage "https://brew.sh"
// 99:
// 100:         livecheck do
// 101:           url "https://formulae.brew.sh/api/formula/ruby.json"
// 102:           regex(/"stable":"(\d+(?:\.\d+)+)"/i)
// 103:         end
// 104:       end,
// 105:       deprecated:                            Cask::Cask.new("test_deprecated") do
// 106:         version "0.0.1"
// 107:         sha256 :no_check
// 108:
// 109:         url "https://brew.sh/test-#{version}.tgz"
// 110:         name "Test Deprecate"
// 111:         desc "Deprecated test cask"
// 112:         homepage "https://brew.sh"
// 113:
// 114:         deprecate! date: "2020-06-25", because: :discontinued
// 115:       end,
// 116:       disabled:                              Cask::Cask.new("test_disabled") do
// 117:         version "0.0.1"
// 118:         sha256 :no_check
// 119:
// 120:         url "https://brew.sh/test-#{version}.tgz"
// 121:         name "Test Disable"
// 122:         desc "Disabled test cask"
// 123:         homepage "https://brew.sh"
// 124:
// 125:         disable! date: "2020-06-25", because: :discontinued
// 126:       end,
// 127:       future_disable_fails_gatekeeper_check: Cask::Cask.new("test_future_disable_fails_gatekeeper_check") do
// 128:         version "0.0.1"
// 129:
// 130:         url "https://brew.sh/test-#{version}.tgz"
// 131:         name "Test Future Disabled Fails Gatekeeper Check"
// 132:         desc "Future Disable Fails Gatekeeper Check test cask"
// 133:         homepage "https://brew.sh"
// 134:
// 135:         disable! date: "3000-06-25", because: :fails_gatekeeper_check
// 136:       end,
// 137:       extract_plist:                         Cask::Cask.new("test_extract_plist_skip") do
// 138:         version "0.0.1"
// 139:
// 140:         url "https://brew.sh/test-#{version}.tgz"
// 141:         name "Test ExtractPlist Skip"
// 142:         desc "Skipped test cask"
// 143:         homepage "https://brew.sh"
// 144:
// 145:         livecheck do
// 146:           strategy :extract_plist
// 147:         end
// 148:       end,
// 149:       latest:                                Cask::Cask.new("test_latest") do
// 150:         version :latest
// 151:         sha256 :no_check
// 152:
// 153:         url "https://brew.sh/test-0.0.1.tgz"
// 154:         name "Test Latest"
// 155:         desc "Latest test cask"
// 156:         homepage "https://brew.sh"
// 157:       end,
// 158:       unversioned:                           Cask::Cask.new("test_unversioned") do
// 159:         version "1.2.3"
// 160:         sha256 :no_check
// 161:
// 162:         url "https://brew.sh/test.tgz"
// 163:         name "Test Unversioned"
// 164:         desc "Unversioned test cask"
// 165:         homepage "https://brew.sh"
// 166:       end,
// 167:       skip:                                  Cask::Cask.new("test_skip") do
// 168:         version "0.0.1"
// 169:
// 170:         url "https://brew.sh/test-#{version}.tgz"
// 171:         name "Test Skip"
// 172:         desc "Skipped test cask"
// 173:         homepage "https://brew.sh"
// 174:
// 175:         livecheck do
// 176:           skip
// 177:         end
// 178:       end,
// 179:       skip_with_message:                     Cask::Cask.new("test_skip_with_message") do
// 180:         version "0.0.1"
// 181:
// 182:         url "https://brew.sh/test-#{version}.tgz"
// 183:         name "Test Skip"
// 184:         desc "Skipped test cask"
// 185:         homepage "https://brew.sh"
// 186:
// 187:         livecheck do
// 188:           skip "Not maintained"
// 189:         end
// 190:       end,
// 191:     }
// 192:   end
// 193:   let(:status_hashes) do
// 194:     {
// 195:       formula: {
// 196:         deprecated:          {
// 197:           formula: "test_deprecated",
// 198:           status:  "deprecated",
// 199:           meta:    {
// 200:             livecheck_defined: false,
// 201:           },
// 202:         },
// 203:         disabled:            {
// 204:           formula: "test_disabled",
// 205:           status:  "disabled",
// 206:           meta:    {
// 207:             livecheck_defined: false,
// 208:           },
// 209:         },
// 210:         versioned:           {
// 211:           formula: "test@0.0.1",
// 212:           status:  "versioned",
// 213:           meta:    {
// 214:             livecheck_defined: false,
// 215:           },
// 216:         },
// 217:         head_only:           {
// 218:           formula:  "test_head_only",
// 219:           status:   "error",
// 220:           messages: ["HEAD only formula must be installed to be checkable"],
// 221:           meta:     {
// 222:             livecheck_defined: false,
// 223:             head_only:         true,
// 224:           },
// 225:         },
// 226:         gist:                {
// 227:           formula:  "test_gist",
// 228:           status:   "skipped",
// 229:           messages: ["Stable URL is a GitHub Gist"],
// 230:           meta:     {
// 231:             livecheck_defined: false,
// 232:           },
// 233:         },
// 234:         google_code_archive: {
// 235:           formula:  "test_google_code_archive",
// 236:           status:   "skipped",
// 237:           messages: ["Stable URL is from Google Code Archive"],
// 238:           meta:     {
// 239:             livecheck_defined: false,
// 240:           },
// 241:         },
// 242:         internet_archive:    {
// 243:           formula:  "test_internet_archive",
// 244:           status:   "skipped",
// 245:           messages: ["Stable URL is from Internet Archive"],
// 246:           meta:     {
// 247:             livecheck_defined: false,
// 248:           },
// 249:         },
// 250:         skip:                {
// 251:           formula: "test_skip",
// 252:           status:  "skipped",
// 253:           meta:    {
// 254:             livecheck_defined: true,
// 255:           },
// 256:         },
// 257:         skip_with_message:   {
// 258:           formula:  "test_skip_with_message",
// 259:           status:   "skipped",
// 260:           messages: ["Not maintained"],
// 261:           meta:     {
// 262:             livecheck_defined: true,
// 263:           },
// 264:         },
// 265:         skip_with_messages:  {
// 266:           formula:  "test_skip_with_messages",
// 267:           status:   "skipped",
// 268:           messages: ["First message", "Second message"],
// 269:           meta:     {
// 270:             livecheck_defined: true,
// 271:           },
// 272:         },
// 273:         error_with_messages: {
// 274:           formula:  "test_error_with_messages",
// 275:           status:   "error",
// 276:           messages: ["First error", "Second error"],
// 277:           meta:     {
// 278:             livecheck_defined: true,
// 279:           },
// 280:         },
// 281:       },
// 282:       cask:    {
// 283:         deprecated:          {
// 284:           cask:   "test_deprecated",
// 285:           status: "deprecated",
// 286:           meta:   {
// 287:             livecheck_defined: false,
// 288:           },
// 289:         },
// 290:         disabled:            {
// 291:           cask:   "test_disabled",
// 292:           status: "disabled",
// 293:           meta:   {
// 294:             livecheck_defined: false,
// 295:           },
// 296:         },
// 297:         extract_plist:       {
// 298:           cask:     "test_extract_plist_skip",
// 299:           status:   "skipped",
// 300:           messages: ["Use `--extract-plist` to enable checking multiple casks with ExtractPlist strategy"],
// 301:           meta:     {
// 302:             livecheck_defined: true,
// 303:           },
// 304:         },
// 305:         latest:              {
// 306:           cask:   "test_latest",
// 307:           status: "latest",
// 308:           meta:   {
// 309:             livecheck_defined: false,
// 310:           },
// 311:         },
// 312:         unversioned:         {
// 313:           cask:   "test_unversioned",
// 314:           status: "unversioned",
// 315:           meta:   {
// 316:             livecheck_defined: false,
// 317:           },
// 318:         },
// 319:         skip:                {
// 320:           cask:   "test_skip",
// 321:           status: "skipped",
// 322:           meta:   {
// 323:             livecheck_defined: true,
// 324:           },
// 325:         },
// 326:         skip_with_message:   {
// 327:           cask:     "test_skip_with_message",
// 328:           status:   "skipped",
// 329:           messages: ["Not maintained"],
// 330:           meta:     {
// 331:             livecheck_defined: true,
// 332:           },
// 333:         },
// 334:         skip_with_messages:  {
// 335:           cask:     "test_skip_with_messages",
// 336:           status:   "skipped",
// 337:           messages: ["First message", "Second message"],
// 338:           meta:     {
// 339:             livecheck_defined: true,
// 340:           },
// 341:         },
// 342:         error_with_messages: {
// 343:           cask:     "test_error_with_messages",
// 344:           status:   "error",
// 345:           messages: ["First error", "Second error"],
// 346:           meta:     {
// 347:             livecheck_defined: true,
// 348:           },
// 349:         },
// 350:       },
// 351:     }
// 352:   end
// 353:
// 354:   describe "::skip_information" do
// 355:     context "when a formula without a `livecheck` block is deprecated" do
// 356:       it "skips" do
// 357:         expect(skip_conditions.skip_information(formulae[:deprecated]))
// 358:           .to eq(status_hashes[:formula][:deprecated])
// 359:       end
// 360:     end
// 361:
// 362:     context "when a formula without a `livecheck` block is disabled" do
// 363:       it "skips" do
// 364:         expect(skip_conditions.skip_information(formulae[:disabled]))
// 365:           .to eq(status_hashes[:formula][:disabled])
// 366:       end
// 367:     end
// 368:
// 369:     context "when a formula without a `livecheck` block is versioned" do
// 370:       it "skips" do
// 371:         expect(skip_conditions.skip_information(formulae[:versioned]))
// 372:           .to eq(status_hashes[:formula][:versioned])
// 373:       end
// 374:     end
// 375:
// 376:     context "when a formula is HEAD-only and not installed" do
// 377:       it "skips" do
// 378:         expect(skip_conditions.skip_information(formulae[:head_only]))
// 379:           .to eq(status_hashes[:formula][:head_only])
// 380:       end
// 381:     end
// 382:
// 383:     context "when a formula without a `livecheck` block has a GitHub Gist stable URL" do
// 384:       it "skips" do
// 385:         expect(skip_conditions.skip_information(formulae[:gist]))
// 386:           .to eq(status_hashes[:formula][:gist])
// 387:       end
// 388:     end
// 389:
// 390:     context "when a formula without a `livecheck` block has a Google Code Archive stable URL" do
// 391:       it "skips" do
// 392:         expect(skip_conditions.skip_information(formulae[:google_code_archive]))
// 393:           .to eq(status_hashes[:formula][:google_code_archive])
// 394:       end
// 395:     end
// 396:
// 397:     context "when a formula without a `livecheck` block has an Internet Archive stable URL" do
// 398:       it "skips" do
// 399:         expect(skip_conditions.skip_information(formulae[:internet_archive]))
// 400:           .to eq(status_hashes[:formula][:internet_archive])
// 401:       end
// 402:     end
// 403:
// 404:     context "when a formula has a `livecheck` block containing `skip`" do
// 405:       it "skips" do
// 406:         expect(skip_conditions.skip_information(formulae[:skip]))
// 407:           .to eq(status_hashes[:formula][:skip])
// 408:
// 409:         expect(skip_conditions.skip_information(formulae[:skip_with_message]))
// 410:           .to eq(status_hashes[:formula][:skip_with_message])
// 411:       end
// 412:     end
// 413:
// 414:     context "when a cask without a `livecheck` block is deprecated" do
// 415:       it "skips" do
// 416:         expect(skip_conditions.skip_information(casks[:deprecated]))
// 417:           .to eq(status_hashes[:cask][:deprecated])
// 418:       end
// 419:     end
// 420:
// 421:     context "when a cask without a `livecheck` block is disabled" do
// 422:       it "skips" do
// 423:         expect(skip_conditions.skip_information(casks[:disabled]))
// 424:           .to eq(status_hashes[:cask][:disabled])
// 425:       end
// 426:     end
// 427:
// 428:     context "when a cask without a `livecheck` block is deprecated" \
// 429:             "with a future disable date because `:fails_gatekeeper_check`" do
// 430:       it "does not skip" do
// 431:         expect(skip_conditions.skip_information(casks[:future_disable_fails_gatekeeper_check])).to eq({})
// 432:       end
// 433:     end
// 434:
// 435:     context "when a cask has a `livecheck` block using `ExtractPlist` and `--extract-plist` is not used" do
// 436:       it "skips" do
// 437:         expect(skip_conditions.skip_information(casks[:extract_plist], extract_plist: false))
// 438:           .to eq(status_hashes[:cask][:extract_plist])
// 439:       end
// 440:     end
// 441:
// 442:     context "when a cask without a `livecheck` block has `version :latest`" do
// 443:       it "skips" do
// 444:         expect(skip_conditions.skip_information(casks[:latest]))
// 445:           .to eq(status_hashes[:cask][:latest])
// 446:       end
// 447:     end
// 448:
// 449:     context "when a cask without a `livecheck` block has an unversioned URL" do
// 450:       it "skips" do
// 451:         expect(skip_conditions.skip_information(casks[:unversioned]))
// 452:           .to eq(status_hashes[:cask][:unversioned])
// 453:       end
// 454:     end
// 455:
// 456:     context "when a cask has a `livecheck` block containing `skip`" do
// 457:       it "skips" do
// 458:         expect(skip_conditions.skip_information(casks[:skip]))
// 459:           .to eq(status_hashes[:cask][:skip])
// 460:
// 461:         expect(skip_conditions.skip_information(casks[:skip_with_message]))
// 462:           .to eq(status_hashes[:cask][:skip_with_message])
// 463:       end
// 464:     end
// 465:
// 466:     it "returns an empty hash for a non-skippable formula" do
// 467:       expect(skip_conditions.skip_information(formulae[:basic])).to eq({})
// 468:     end
// 469:
// 470:     it "returns an empty hash for a non-skippable cask" do
// 471:       expect(skip_conditions.skip_information(casks[:basic])).to eq({})
// 472:     end
// 473:   end
// 474:
// 475:   describe "::referenced_skip_information" do
// 476:     let(:original_name) { "original" }
// 477:
// 478:     context "when a formula without a `livecheck` block is deprecated" do
// 479:       it "errors" do
// 480:         expect { skip_conditions.referenced_skip_information(formulae[:deprecated], original_name) }
// 481:           .to raise_error(RuntimeError, "Referenced formula (test_deprecated) is skipped as deprecated")
// 482:       end
// 483:     end
// 484:
// 485:     context "when a formula without a `livecheck` block is disabled" do
// 486:       it "errors" do
// 487:         expect { skip_conditions.referenced_skip_information(formulae[:disabled], original_name) }
// 488:           .to raise_error(RuntimeError, "Referenced formula (test_disabled) is skipped as disabled")
// 489:       end
// 490:     end
// 491:
// 492:     context "when a formula without a `livecheck` block is versioned" do
// 493:       it "errors" do
// 494:         expect { skip_conditions.referenced_skip_information(formulae[:versioned], original_name) }
// 495:           .to raise_error(RuntimeError, "Referenced formula (test@0.0.1) is skipped as versioned")
// 496:       end
// 497:     end
// 498:
// 499:     context "when a formula is HEAD-only and not installed" do
// 500:       it "skips" do
// 501:         expect(skip_conditions.referenced_skip_information(formulae[:head_only], original_name))
// 502:           .to eq(status_hashes[:formula][:head_only].merge({ formula: original_name }))
// 503:       end
// 504:     end
// 505:
// 506:     context "when a formula without a `livecheck` block has a GitHub Gist stable URL" do
// 507:       it "errors" do
// 508:         expect { skip_conditions.referenced_skip_information(formulae[:gist], original_name) }
// 509:           .to raise_error(RuntimeError, "Referenced formula (test_gist) is automatically skipped")
// 510:       end
// 511:     end
// 512:
// 513:     context "when a formula without a `livecheck` block has a Google Code Archive stable URL" do
// 514:       it "errors" do
// 515:         expect { skip_conditions.referenced_skip_information(formulae[:google_code_archive], original_name) }
// 516:           .to raise_error(RuntimeError, "Referenced formula (test_google_code_archive) is automatically skipped")
// 517:       end
// 518:     end
// 519:
// 520:     context "when a formula without a `livecheck` block has an Internet Archive stable URL" do
// 521:       it "errors" do
// 522:         expect { skip_conditions.referenced_skip_information(formulae[:internet_archive], original_name) }
// 523:           .to raise_error(RuntimeError, "Referenced formula (test_internet_archive) is automatically skipped")
// 524:       end
// 525:     end
// 526:
// 527:     context "when a formula has a `livecheck` block containing `skip`" do
// 528:       it "skips" do
// 529:         expect(skip_conditions.referenced_skip_information(formulae[:skip], original_name))
// 530:           .to eq(status_hashes[:formula][:skip].merge({ formula: original_name }))
// 531:
// 532:         expect(skip_conditions.referenced_skip_information(formulae[:skip_with_message], original_name))
// 533:           .to eq(status_hashes[:formula][:skip_with_message].merge({ formula: original_name }))
// 534:       end
// 535:     end
// 536:
// 537:     context "when a cask without a `livecheck` block is deprecated" do
// 538:       it "errors" do
// 539:         expect { skip_conditions.referenced_skip_information(casks[:deprecated], original_name) }
// 540:           .to raise_error(RuntimeError, "Referenced cask (test_deprecated) is skipped as deprecated")
// 541:       end
// 542:     end
// 543:
// 544:     context "when a cask without a `livecheck` block is disabled" do
// 545:       it "errors" do
// 546:         expect { skip_conditions.referenced_skip_information(casks[:disabled], original_name) }
// 547:           .to raise_error(RuntimeError, "Referenced cask (test_disabled) is skipped as disabled")
// 548:       end
// 549:     end
// 550:
// 551:     context "when a cask has a `livecheck` block using `ExtractPlist` and `--extract-plist` is not used" do
// 552:       it "skips" do
// 553:         expect do
// 554:           skip_conditions.referenced_skip_information(casks[:extract_plist], original_name, extract_plist: false)
// 555:         end
// 556:           .to raise_error(RuntimeError, "Referenced cask (test_extract_plist_skip) is automatically skipped")
// 557:       end
// 558:     end
// 559:
// 560:     context "when a cask without a `livecheck` block has `version :latest`" do
// 561:       it "errors" do
// 562:         expect { skip_conditions.referenced_skip_information(casks[:latest], original_name) }
// 563:           .to raise_error(RuntimeError, "Referenced cask (test_latest) is skipped as latest")
// 564:       end
// 565:     end
// 566:
// 567:     context "when a cask without a `livecheck` block has an unversioned URL" do
// 568:       it "errors" do
// 569:         expect { skip_conditions.referenced_skip_information(casks[:unversioned], original_name) }
// 570:           .to raise_error(RuntimeError, "Referenced cask (test_unversioned) is skipped as unversioned")
// 571:       end
// 572:     end
// 573:
// 574:     context "when a cask has a `livecheck` block containing `skip`" do
// 575:       it "skips" do
// 576:         expect(skip_conditions.referenced_skip_information(casks[:skip], original_name))
// 577:           .to eq(status_hashes[:cask][:skip].merge({ cask: original_name }))
// 578:
// 579:         expect(skip_conditions.referenced_skip_information(casks[:skip_with_message], original_name))
// 580:           .to eq(status_hashes[:cask][:skip_with_message].merge({ cask: original_name }))
// 581:       end
// 582:     end
// 583:
// 584:     it "returns an empty hash for a non-skippable formula" do
// 585:       expect(skip_conditions.referenced_skip_information(formulae[:basic], original_name)).to be_nil
// 586:     end
// 587:
// 588:     it "returns an empty hash for a non-skippable cask" do
// 589:       expect(skip_conditions.referenced_skip_information(casks[:basic], original_name)).to be_nil
// 590:     end
// 591:   end
// 592:
// 593:   describe "::print_skip_information" do
// 594:     context "when a formula without a `livecheck` block is deprecated" do
// 595:       it "prints skip information" do
// 596:         expect { skip_conditions.print_skip_information(status_hashes[:formula][:deprecated]) }
// 597:           .to output("test_deprecated: deprecated\n").to_stdout
// 598:           .and not_to_output.to_stderr
// 599:       end
// 600:     end
// 601:
// 602:     context "when a formula without a `livecheck` block is disabled" do
// 603:       it "prints skip information" do
// 604:         expect { skip_conditions.print_skip_information(status_hashes[:formula][:disabled]) }
// 605:           .to output("test_disabled: disabled\n").to_stdout
// 606:           .and not_to_output.to_stderr
// 607:       end
// 608:     end
// 609:
// 610:     context "when a formula without a `livecheck` block is versioned" do
// 611:       it "prints skip information" do
// 612:         expect { skip_conditions.print_skip_information(status_hashes[:formula][:versioned]) }
// 613:           .to output("test@0.0.1: versioned\n").to_stdout
// 614:           .and not_to_output.to_stderr
// 615:       end
// 616:     end
// 617:
// 618:     context "when a formula is HEAD-only and not installed" do
// 619:       it "prints skip information" do
// 620:         expect { skip_conditions.print_skip_information(status_hashes[:formula][:head_only]) }
// 621:           .to output("test_head_only: HEAD only formula must be installed to be checkable\n").to_stdout
// 622:           .and not_to_output.to_stderr
// 623:       end
// 624:     end
// 625:
// 626:     context "when a formula has a GitHub Gist stable URL" do
// 627:       it "prints skip information" do
// 628:         expect { skip_conditions.print_skip_information(status_hashes[:formula][:gist]) }
// 629:           .to output("test_gist: skipped - Stable URL is a GitHub Gist\n").to_stdout
// 630:           .and not_to_output.to_stderr
// 631:       end
// 632:     end
// 633:
// 634:     context "when a formula has a Google Code Archive stable URL" do
// 635:       it "prints skip information" do
// 636:         expect { skip_conditions.print_skip_information(status_hashes[:formula][:google_code_archive]) }
// 637:           .to output("test_google_code_archive: skipped - Stable URL is from Google Code Archive\n").to_stdout
// 638:           .and not_to_output.to_stderr
// 639:       end
// 640:     end
// 641:
// 642:     context "when a formula has an Internet Archive stable URL" do
// 643:       it "prints skip information" do
// 644:         expect { skip_conditions.print_skip_information(status_hashes[:formula][:internet_archive]) }
// 645:           .to output("test_internet_archive: skipped - Stable URL is from Internet Archive\n").to_stdout
// 646:           .and not_to_output.to_stderr
// 647:       end
// 648:     end
// 649:
// 650:     context "when a formula has a `livecheck` block containing `skip`" do
// 651:       it "prints skip information" do
// 652:         expect { skip_conditions.print_skip_information(status_hashes[:formula][:skip]) }
// 653:           .to output("test_skip: skipped\n").to_stdout
// 654:           .and not_to_output.to_stderr
// 655:
// 656:         expect { skip_conditions.print_skip_information(status_hashes[:formula][:skip_with_message]) }
// 657:           .to output("test_skip_with_message: skipped - Not maintained\n").to_stdout
// 658:           .and not_to_output.to_stderr
// 659:       end
// 660:     end
// 661:
// 662:     context "when a formula produces multiple messages" do
// 663:       it "prints skip information" do
// 664:         expect do
// 665:           skip_conditions.print_skip_information(status_hashes[:formula][:skip_with_messages])
// 666:         end.to output(
// 667:           "test_skip_with_messages: skipped - First message; Second message\n",
// 668:         ).to_stdout.and not_to_output.to_stderr
// 669:
// 670:         expect do
// 671:           skip_conditions.print_skip_information(status_hashes[:formula][:error_with_messages])
// 672:         end.to output(
// 673:           "test_error_with_messages: First error; Second error\n",
// 674:         ).to_stdout.and not_to_output.to_stderr
// 675:       end
// 676:     end
// 677:
// 678:     context "when the cask is deprecated without a `livecheck` block" do
// 679:       it "prints skip information" do
// 680:         expect { skip_conditions.print_skip_information(status_hashes[:cask][:deprecated]) }
// 681:           .to output("test_deprecated: deprecated\n").to_stdout
// 682:           .and not_to_output.to_stderr
// 683:       end
// 684:     end
// 685:
// 686:     context "when the cask is disabled without a `livecheck` block" do
// 687:       it "prints skip information" do
// 688:         expect { skip_conditions.print_skip_information(status_hashes[:cask][:disabled]) }
// 689:           .to output("test_disabled: disabled\n").to_stdout
// 690:           .and not_to_output.to_stderr
// 691:       end
// 692:     end
// 693:
// 694:     context "when the cask has `version :latest` without a `livecheck` block" do
// 695:       it "prints skip information" do
// 696:         expect { skip_conditions.print_skip_information(status_hashes[:cask][:latest]) }
// 697:           .to output("test_latest: latest\n").to_stdout
// 698:           .and not_to_output.to_stderr
// 699:       end
// 700:     end
// 701:
// 702:     context "when the cask has an unversioned URL without a `livecheck` block" do
// 703:       it "prints skip information" do
// 704:         expect { skip_conditions.print_skip_information(status_hashes[:cask][:unversioned]) }
// 705:           .to output("test_unversioned: unversioned\n").to_stdout
// 706:           .and not_to_output.to_stderr
// 707:       end
// 708:     end
// 709:
// 710:     context "when the cask has a `livecheck` block containing `skip`" do
// 711:       it "prints skip information" do
// 712:         expect { skip_conditions.print_skip_information(status_hashes[:cask][:skip]) }
// 713:           .to output("test_skip: skipped\n").to_stdout
// 714:           .and not_to_output.to_stderr
// 715:
// 716:         expect { skip_conditions.print_skip_information(status_hashes[:cask][:skip_with_message]) }
// 717:           .to output("test_skip_with_message: skipped - Not maintained\n").to_stdout
// 718:           .and not_to_output.to_stderr
// 719:       end
// 720:     end
// 721:
// 722:     context "when a cask produces multiple messages" do
// 723:       it "prints skip information" do
// 724:         expect do
// 725:           skip_conditions.print_skip_information(status_hashes[:cask][:skip_with_messages])
// 726:         end.to output(
// 727:           "test_skip_with_messages: skipped - First message; Second message\n",
// 728:         ).to_stdout.and not_to_output.to_stderr
// 729:
// 730:         expect do
// 731:           skip_conditions.print_skip_information(status_hashes[:cask][:error_with_messages])
// 732:         end.to output(
// 733:           "test_error_with_messages: First error; Second error\n",
// 734:         ).to_stdout.and not_to_output.to_stderr
// 735:       end
// 736:     end
// 737:
// 738:     context "with a blank parameter" do
// 739:       it "prints nothing" do
// 740:         expect { skip_conditions.print_skip_information({}) }
// 741:           .to not_to_output.to_stdout
// 742:           .and not_to_output.to_stderr
// 743:       end
// 744:     end
// 745:   end
// 746: end
