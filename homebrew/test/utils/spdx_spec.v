module utils

import os
import homebrew.utils as spdx

type SpdxLicenseExpression = spdx.SpdxLicenseExpression

type SpdxLicenseToken = spdx.SpdxLicenseToken

type SpdxLicenseVersionInfo = spdx.SpdxLicenseVersionInfo

type SpdxParsedExpression = spdx.SpdxParsedExpression

const spdx_licenseref_prefix = 'LicenseRef-Homebrew-'

fn spdx_license_data() !spdx.SpdxLicenseData {
	return spdx.spdx_license_data()
}

fn spdx_exception_data() !spdx.SpdxExceptionData {
	return spdx.spdx_exception_data()
}

fn download_latest_spdx_license_data(destination string) ! {
	spdx.download_latest_spdx_license_data(destination)!
}

fn spdx_license(value string) SpdxLicenseExpression {
	return spdx.spdx_license(value)
}

fn spdx_symbol(value string) SpdxLicenseExpression {
	return spdx.spdx_symbol(value)
}

fn spdx_any_of(children []SpdxLicenseExpression) SpdxLicenseExpression {
	return spdx.spdx_any_of(children)
}

fn spdx_all_of(children []SpdxLicenseExpression) SpdxLicenseExpression {
	return spdx.spdx_all_of(children)
}

fn spdx_license_with_exception(license string, exception string) SpdxLicenseExpression {
	return spdx.spdx_license_with_exception(license, exception)
}

fn spdx_license_token(value string) SpdxLicenseToken {
	return spdx.spdx_license_token(value)
}

fn spdx_symbol_token(value string) SpdxLicenseToken {
	return spdx.spdx_symbol_token(value)
}

fn parse_spdx_license_expression(expression SpdxLicenseExpression) SpdxParsedExpression {
	return spdx.parse_spdx_license_expression(expression)
}

fn valid_spdx_license(license SpdxLicenseToken) !bool {
	return spdx.valid_spdx_license(license)
}

fn deprecated_spdx_license(license SpdxLicenseToken) !bool {
	return spdx.deprecated_spdx_license(license)
}

fn valid_spdx_license_exception(exception string) !bool {
	return spdx.valid_spdx_license_exception(exception)
}

fn spdx_license_expression_to_string(expression SpdxLicenseExpression, bracket bool) string {
	return spdx.spdx_license_expression_to_string(expression, bracket)
}

fn string_to_spdx_license_expression(value string) ?SpdxLicenseExpression {
	return spdx.string_to_spdx_license_expression(value)
}

fn truncate_spdx_license(license string, limit int) string {
	return spdx.truncate_spdx_license(license, limit)
}

fn spdx_license_version_info(license SpdxLicenseToken) SpdxLicenseVersionInfo {
	return spdx.spdx_license_version_info(license)
}

fn spdx_forbidden_license_map(licenses []SpdxLicenseToken) map[string]SpdxLicenseVersionInfo {
	return spdx.spdx_forbidden_license_map(licenses)
}

fn spdx_licenses_forbid_installation(expression SpdxLicenseExpression,
	forbidden map[string]SpdxLicenseVersionInfo) bool {
	return spdx.spdx_licenses_forbid_installation(expression, forbidden)
}

fn forbidden_spdx_licenses_include(license SpdxLicenseToken,
	forbidden map[string]SpdxLicenseVersionInfo) bool {
	return spdx.forbidden_spdx_licenses_include(license, forbidden)
}

// Translated from Homebrew/brew `test/utils/spdx_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn spdx_spec_token_values(parsed SpdxParsedExpression) []string {
	mut values := []string{}
	for token in parsed.licenses {
		values << if token.symbol { ':${token.value}' } else { token.value }
	}
	return values
}

fn spdx_spec_expression_shape(expression SpdxLicenseExpression) string {
	match expression.kind {
		.identifier {
			return expression.value
		}
		.symbol {
			return ':${expression.value}'
		}
		.with_exception {
			return '${expression.value} WITH ${expression.exception}'
		}
		.any_of, .all_of {
			mut children := []string{}
			for child in expression.children {
				children << spdx_spec_expression_shape(child)
			}
			kind := if expression.kind == .any_of { 'any' } else { 'all' }
			return '${kind}(${children.join(',')})'
		}
	}
}

fn spdx_spec_forbidden(values ...string) map[string]SpdxLicenseVersionInfo {
	mut tokens := []SpdxLicenseToken{}
	for value in values {
		tokens << spdx_license_token(value)
	}
	return spdx_forbidden_license_map(tokens)
}

fn spdx_spec_mit_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_forbidden('MIT')
}

fn spdx_spec_epl_1_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_forbidden('EPL-1.0')
}

fn spdx_spec_epl_1_plus_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_forbidden('EPL-1.0+')
}

fn spdx_spec_multiple_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_forbidden('MIT', '0BSD')
}

fn spdx_spec_any_of_license() SpdxLicenseExpression {
	return spdx_any_of([spdx_license('MIT'), spdx_license('0BSD')])
}

fn spdx_spec_all_of_license() SpdxLicenseExpression {
	return spdx_all_of([spdx_license('MIT'), spdx_license('0BSD')])
}

fn spdx_spec_nested_licenses() SpdxLicenseExpression {
	return spdx_any_of([
		spdx_license('MIT'),
		spdx_license_with_exception('MIT', 'LLVM-exception'),
		spdx_any_of([spdx_license('MIT'), spdx_license('0BSD')]),
	])
}

fn spdx_spec_license_exception() SpdxLicenseExpression {
	return spdx_license_with_exception('MIT', 'LLVM-exception')
}

fn spdx_spec_result(spec int) !bool {
	match spec {
		1 {
			return spdx_license_data()!.license_list_version != ''
		}
		2 {
			return spdx_license_data()!.release_date != ''
		}
		3 {
			return spdx_license_data()!.licenses.len > 0
		}
		4 {
			return spdx_exception_data()!.license_list_version != ''
		}
		5 {
			return spdx_exception_data()!.release_date != ''
		}
		6 {
			return spdx_exception_data()!.exceptions.len > 0
		}
		9 {
			return spdx_spec_token_values(parse_spdx_license_expression(spdx_license('MIT'))) == [
				'MIT',
			] && spdx_spec_token_values(parse_spdx_license_expression(spdx_license('Apache-2.0+'))) == [
				'Apache-2.0+',
			] && spdx_spec_token_values(parse_spdx_license_expression(spdx_spec_any_of_license())) == [
				'MIT',
				'0BSD',
			] && spdx_spec_token_values(parse_spdx_license_expression(spdx_spec_all_of_license())) == [
				'MIT',
				'0BSD',
			] && spdx_spec_token_values(parse_spdx_license_expression(spdx_any_of([
				spdx_license('MIT'),
				spdx_license('EPL-1.0+'),
			]))) == ['MIT', 'EPL-1.0+'] && spdx_spec_token_values(parse_spdx_license_expression(spdx_all_of([
				spdx_license('MIT'),
				spdx_license('EPL-1.0+'),
			]))) == ['MIT', 'EPL-1.0+'] && spdx_spec_token_values(parse_spdx_license_expression(spdx_symbol('public_domain'))) == [
				':public_domain',
			] && spdx_spec_token_values(parse_spdx_license_expression(spdx_symbol('cannot_represent'))) == [
				':cannot_represent',
			]
		}
		10 {
			parsed := parse_spdx_license_expression(spdx_spec_license_exception())
			return spdx_spec_token_values(parsed) == ['MIT'] && parsed.exceptions == [
				'LLVM-exception',
			]
		}
		11 {
			parsed := parse_spdx_license_expression(spdx_any_of([
				spdx_license('MIT'),
				spdx_symbol('public_domain'),
				spdx_license_with_exception('curl', 'LLVM-exception'),
				spdx_all_of([spdx_license('0BSD'), spdx_license('Zlib')]),
			]))
			return spdx_spec_token_values(parsed) == ['MIT', ':public_domain', 'curl', '0BSD', 'Zlib'] && parsed.exceptions == [
				'LLVM-exception',
			]
		}
		12 {
			return valid_spdx_license(spdx_license_token('MIT'))!
		}
		13 {
			return !valid_spdx_license(spdx_license_token('foo'))!
		}
		14 {
			return valid_spdx_license(spdx_license_token('GPL-1.0'))!
		}
		15 {
			return valid_spdx_license(spdx_license_token('Apache-2.0+'))!
		}
		16 {
			return valid_spdx_license(spdx_symbol_token('public_domain'))!
		}
		17 {
			return valid_spdx_license(spdx_symbol_token('cannot_represent'))!
		}
		18 {
			return !valid_spdx_license(spdx_symbol_token('invalid_symbol'))!
		}
		19 {
			return deprecated_spdx_license(spdx_license_token('GPL-1.0'))!
		}
		20 {
			return deprecated_spdx_license(spdx_license_token('GPL-1.0+'))!
		}
		21 {
			return !deprecated_spdx_license(spdx_license_token('MIT'))!
		}
		22 {
			return !deprecated_spdx_license(spdx_license_token('EPL-1.0+'))!
		}
		23 {
			return !deprecated_spdx_license(spdx_license_token('foo'))!
		}
		24 {
			return !deprecated_spdx_license(spdx_symbol_token('public_domain'))!
		}
		25 {
			return !deprecated_spdx_license(spdx_symbol_token('cannot_represent'))!
		}
		26 {
			return valid_spdx_license_exception('LLVM-exception')!
		}
		27 {
			return !valid_spdx_license_exception('foo')!
		}
		28 {
			return !valid_spdx_license_exception('Nokia-Qt-exception-1.1')!
		}
		29 {
			return spdx_license_expression_to_string(spdx_license('MIT'), false) == 'MIT'
		}
		30 {
			return spdx_license_expression_to_string(spdx_license('Apache-2.0+'), false) == 'Apache-2.0+'
		}
		31 {
			return spdx_license_expression_to_string(spdx_spec_any_of_license(), false) == 'MIT OR 0BSD'
		}
		32 {
			return spdx_license_expression_to_string(spdx_spec_all_of_license(), false) == 'MIT AND 0BSD'
		}
		33 {
			return spdx_license_expression_to_string(spdx_any_of([spdx_license('MIT'),
				spdx_license('EPL-1.0+')]), false) == 'MIT OR EPL-1.0+'
		}
		34 {
			return spdx_license_expression_to_string(spdx_spec_license_exception(), false) == 'MIT WITH LLVM-exception'
		}
		35 {
			expression := spdx_any_of([
				spdx_license('MIT'),
				spdx_symbol('public_domain'),
				spdx_all_of([spdx_license('0BSD'), spdx_license('Zlib')]),
				spdx_license_with_exception('curl', 'LLVM-exception'),
			])
			return spdx_license_expression_to_string(expression, false) == 'MIT OR LicenseRef-Homebrew-public-domain OR (0BSD AND Zlib) OR (curl WITH LLVM-exception)'
		}
		36 {
			return spdx_license_expression_to_string(spdx_symbol('public_domain'), false) == 'LicenseRef-Homebrew-public-domain'
		}
		37 {
			return spdx_license_expression_to_string(spdx_symbol('cannot_represent'), false) == 'LicenseRef-Homebrew-cannot-represent'
		}
		38 {
			return truncate_spdx_license('MIT AND Apache-2.0', 255) == 'MIT AND Apache-2.0'
		}
		39 {
			return truncate_spdx_license('MIT AND Apache-2.0 AND BSD-3-Clause AND GPL-2.0-only', 40) == 'MIT AND LicenseRef-Homebrew-truncated'
		}
		40 {
			return truncate_spdx_license('MIT OR Apache-2.0 OR BSD-3-Clause OR GPL-2.0-only', 40) == 'LicenseRef-Homebrew-cannot-represent'
		}
		41 {
			return truncate_spdx_license('Apache-2.0 AND MIT AND BSD-3-Clause AND ISC', 20) == 'LicenseRef-Homebrew-cannot-represent'
		}
		42, 43 {
			input := if spec == 42 {
				'Apache-2.0 and (Apache-2.0 with LLVM-exception) and (MIT or NCSA)'
			} else {
				'Apache-2.0 AND (Apache-2.0 WITH LLVM-exception) AND (MIT OR NCSA)'
			}
			expression := string_to_spdx_license_expression(input) or { return false }
			return spdx_spec_expression_shape(expression) == 'all(Apache-2.0,Apache-2.0 WITH LLVM-exception,any(MIT,NCSA))'
		}
		44 {
			expression := string_to_spdx_license_expression('A AND (B OR (C AND D))') or {
				return false
			}
			return spdx_spec_expression_shape(expression) == 'all(A,any(B,all(C,D)))'
		}
		45, 46 {
			name := if spec == 45 { 'public_domain' } else { 'cannot_represent' }
			expression := string_to_spdx_license_expression('${spdx_licenseref_prefix}${name.replace('_', '-')}') or {
				return false
			}
			return spdx_spec_expression_shape(expression) == ':${name}'
		}
		47 {
			return !spdx_license_version_info(spdx_license_token('MIT')).has_version
		}
		48 {
			return !spdx_license_version_info(spdx_symbol_token('public_domain')).has_version
		}
		49, 50, 51, 52, 53, 54 {
			license := match spec {
				49 { 'Apache-2.0' }
				50 { 'Apache-2.0+' }
				51 { 'CC-BY-3.0-AT' }
				52 { 'CC-BY-3.0-AT+' }
				53 { 'GPL-3.0-only' }
				else { 'GPL-3.0-or-later' }
			}
			info := spdx_license_version_info(spdx_license_token(license))
			expected_name := if spec in [49, 50] {
				'Apache'
			} else if spec in [51, 52] { 'CC-BY' } else { 'GPL' }
			expected_version := if spec in [49, 50] { '2.0' } else { '3.0' }
			return info.name == expected_name && info.version == expected_version && info.or_later == (spec in [
				50,
				52,
				54,
			])
		}
		63 {
			return !spdx_licenses_forbid_installation(spdx_license('MIT'), map[string]SpdxLicenseVersionInfo{})
		}
		64 {
			return !spdx_licenses_forbid_installation(spdx_license('0BSD'), spdx_spec_mit_forbidden())
		}
		65 {
			return spdx_licenses_forbid_installation(spdx_license('MIT'), spdx_spec_mit_forbidden())
		}
		66 {
			return !spdx_licenses_forbid_installation(spdx_license('EPL-2.0'), spdx_spec_epl_1_forbidden())
		}
		67 {
			return spdx_licenses_forbid_installation(spdx_license('EPL-2.0'), spdx_spec_epl_1_plus_forbidden())
		}
		68 {
			return !spdx_licenses_forbid_installation(spdx_spec_any_of_license(), spdx_spec_mit_forbidden())
		}
		69 {
			return spdx_licenses_forbid_installation(spdx_spec_any_of_license(), spdx_spec_multiple_forbidden())
		}
		70 {
			return spdx_licenses_forbid_installation(spdx_spec_all_of_license(), spdx_spec_mit_forbidden())
		}
		71 {
			return !spdx_licenses_forbid_installation(spdx_spec_license_exception(), spdx_spec_epl_1_forbidden())
		}
		72 {
			return spdx_licenses_forbid_installation(spdx_spec_license_exception(), spdx_spec_mit_forbidden())
		}
		73 {
			return !spdx_licenses_forbid_installation(spdx_spec_nested_licenses(), spdx_spec_epl_1_forbidden())
		}
		74 {
			return !spdx_licenses_forbid_installation(spdx_spec_nested_licenses(), spdx_spec_mit_forbidden())
		}
		75 {
			return spdx_licenses_forbid_installation(spdx_spec_nested_licenses(), spdx_spec_multiple_forbidden())
		}
		79 {
			return !forbidden_spdx_licenses_include(spdx_license_token('MIT'), map[string]SpdxLicenseVersionInfo{})
		}
		80 {
			return !forbidden_spdx_licenses_include(spdx_license_token('MIT'), spdx_spec_epl_1_forbidden())
		}
		81 {
			return forbidden_spdx_licenses_include(spdx_license_token('MIT'), spdx_spec_mit_forbidden())
		}
		82 {
			return !forbidden_spdx_licenses_include(spdx_license_token('EPL-2.0'), spdx_spec_epl_1_forbidden())
		}
		83 {
			return forbidden_spdx_licenses_include(spdx_license_token('EPL-2.0'), spdx_spec_epl_1_plus_forbidden())
		}
		else {
			return error('unknown SPDX spec ${spec}')
		}
	}
}

// Ruby it `it "has the license list version" do` at line 8.
pub fn ruby_spdx_spec_l8_d1_has() !bool {
	return spdx_spec_result(1)
}

// Ruby it `it "has the release date" do` at line 12.
pub fn ruby_spdx_spec_l12_d2_has() !bool {
	return spdx_spec_result(2)
}

// Ruby it `it "has licenses" do` at line 16.
pub fn ruby_spdx_spec_l16_d3_has() !bool {
	return spdx_spec_result(3)
}

// Ruby it `it "has the license list version" do` at line 22.
pub fn ruby_spdx_spec_l22_d4_has() !bool {
	return spdx_spec_result(4)
}

// Ruby it `it "has the release date" do` at line 26.
pub fn ruby_spdx_spec_l26_d5_has() !bool {
	return spdx_spec_result(5)
}

// Ruby it `it "has exceptions" do` at line 30.
pub fn ruby_spdx_spec_l30_d6_has() !bool {
	return spdx_spec_result(6)
}

// Ruby let `let(:download_dir) { mktmpdir }` at line 36.
pub fn ruby_spdx_spec_l36_d7_download_dir() !string {
	directory := os.join_path(os.temp_dir(), 'homebrew-spdx-spec-${os.getpid()}')
	if os.exists(directory) {
		os.rmdir_all(directory)!
	}
	os.mkdir_all(directory)!
	return directory
}

// Ruby it `it "downloads latest license data" do` at line 38.
pub fn ruby_spdx_spec_l38_d8_downloads() !bool {
	directory := ruby_spdx_spec_l36_d7_download_dir()!
	defer {
		os.rmdir_all(directory) or {}
	}
	download_latest_spdx_license_data(directory)!
	return os.exists(os.join_path(directory, 'spdx_licenses.json')) && os.exists(os.join_path(directory, 'spdx_exceptions.json'))
}

// Ruby specify `specify do` at line 46.
pub fn ruby_spdx_spec_l46_d9_do() !bool {
	return spdx_spec_result(9)
}

// Ruby it `it "returns license and exception" do` at line 57.
pub fn ruby_spdx_spec_l57_d10_returns() !bool {
	return spdx_spec_result(10)
}

// Ruby it `it "returns licenses and exceptions for complex license expressions" do` at line 62.
pub fn ruby_spdx_spec_l62_d11_returns() !bool {
	return spdx_spec_result(11)
}

// Ruby it `it "returns true for valid license identifier" do` at line 78.
pub fn ruby_spdx_spec_l78_d12_returns() !bool {
	return spdx_spec_result(12)
}

// Ruby it `it "returns false for invalid license identifier" do` at line 82.
pub fn ruby_spdx_spec_l82_d13_returns() !bool {
	return spdx_spec_result(13)
}

// Ruby it `it "returns true for deprecated license identifier" do` at line 86.
pub fn ruby_spdx_spec_l86_d14_returns() !bool {
	return spdx_spec_result(14)
}

// Ruby it `it "returns true for license identifier with plus" do` at line 90.
pub fn ruby_spdx_spec_l90_d15_returns() !bool {
	return spdx_spec_result(15)
}

// Ruby it `it "returns true for :public_domain" do` at line 94.
pub fn ruby_spdx_spec_l94_d16_returns() !bool {
	return spdx_spec_result(16)
}

// Ruby it `it "returns true for :cannot_represent" do` at line 98.
pub fn ruby_spdx_spec_l98_d17_returns() !bool {
	return spdx_spec_result(17)
}

// Ruby it `it "returns false for invalid symbol" do` at line 102.
pub fn ruby_spdx_spec_l102_d18_returns() !bool {
	return spdx_spec_result(18)
}

// Ruby it `it "returns true for deprecated license identifier" do` at line 108.
pub fn ruby_spdx_spec_l108_d19_returns() !bool {
	return spdx_spec_result(19)
}

// Ruby it `it "returns true for deprecated license identifier with plus" do` at line 112.
pub fn ruby_spdx_spec_l112_d20_returns() !bool {
	return spdx_spec_result(20)
}

// Ruby it `it "returns false for non-deprecated license identifier" do` at line 116.
pub fn ruby_spdx_spec_l116_d21_returns() !bool {
	return spdx_spec_result(21)
}

// Ruby it `it "returns false for non-deprecated license identifier with plus" do` at line 120.
pub fn ruby_spdx_spec_l120_d22_returns() !bool {
	return spdx_spec_result(22)
}

// Ruby it `it "returns false for invalid license identifier" do` at line 124.
pub fn ruby_spdx_spec_l124_d23_returns() !bool {
	return spdx_spec_result(23)
}

// Ruby it `it "returns false for :public_domain" do` at line 128.
pub fn ruby_spdx_spec_l128_d24_returns() !bool {
	return spdx_spec_result(24)
}

// Ruby it `it "returns false for :cannot_represent" do` at line 132.
pub fn ruby_spdx_spec_l132_d25_returns() !bool {
	return spdx_spec_result(25)
}

// Ruby it `it "returns true for valid license exception identifier" do` at line 138.
pub fn ruby_spdx_spec_l138_d26_returns() !bool {
	return spdx_spec_result(26)
}

// Ruby it `it "returns false for invalid license exception identifier" do` at line 142.
pub fn ruby_spdx_spec_l142_d27_returns() !bool {
	return spdx_spec_result(27)
}

// Ruby it `it "returns false for deprecated license exception identifier" do` at line 146.
pub fn ruby_spdx_spec_l146_d28_returns() !bool {
	return spdx_spec_result(28)
}

// Ruby it `it "returns a single license" do` at line 152.
pub fn ruby_spdx_spec_l152_d29_returns() !bool {
	return spdx_spec_result(29)
}

// Ruby it `it "returns a single license with plus" do` at line 156.
pub fn ruby_spdx_spec_l156_d30_returns() !bool {
	return spdx_spec_result(30)
}

// Ruby it `it "returns multiple licenses with :any" do` at line 160.
pub fn ruby_spdx_spec_l160_d31_returns() !bool {
	return spdx_spec_result(31)
}

// Ruby it `it "returns multiple licenses with :all" do` at line 164.
pub fn ruby_spdx_spec_l164_d32_returns() !bool {
	return spdx_spec_result(32)
}

// Ruby it `it "returns multiple licenses with plus" do` at line 168.
pub fn ruby_spdx_spec_l168_d33_returns() !bool {
	return spdx_spec_result(33)
}

// Ruby it `it "returns license and exception" do` at line 172.
pub fn ruby_spdx_spec_l172_d34_returns() !bool {
	return spdx_spec_result(34)
}

// Ruby it `it "returns licenses and exceptions for complex license expressions" do` at line 177.
pub fn ruby_spdx_spec_l177_d35_returns() !bool {
	return spdx_spec_result(35)
}

// Ruby it `it "returns :public_domain" do` at line 191.
pub fn ruby_spdx_spec_l191_d36_returns() !bool {
	return spdx_spec_result(36)
}

// Ruby it `it "returns :cannot_represent" do` at line 195.
pub fn ruby_spdx_spec_l195_d37_returns() !bool {
	return spdx_spec_result(37)
}

// Ruby it `it "returns the license unchanged when within the limit" do` at line 202.
pub fn ruby_spdx_spec_l202_d38_returns() !bool {
	return spdx_spec_result(38)
}

// Ruby it `it "truncates an over-long conjunction to a valid prefix with a marker" do` at line 206.
pub fn ruby_spdx_spec_l206_d39_truncates() !bool {
	return spdx_spec_result(39)
}

// Ruby it `it "falls back to :cannot_represent for over-long disjunctions" do` at line 211.
pub fn ruby_spdx_spec_l211_d40_falls() !bool {
	return spdx_spec_result(40)
}

// Ruby it `it "falls back to :cannot_represent when even the first term does not fit" do` at line 216.
pub fn ruby_spdx_spec_l216_d41_falls() !bool {
	return spdx_spec_result(41)
}

// Ruby it `it "returns the correct result for 'and', 'or' and 'with'" do` at line 223.
pub fn ruby_spdx_spec_l223_d42_returns() !bool {
	return spdx_spec_result(42)
}

// Ruby it `it "returns the correct result for 'AND', 'OR' and 'WITH'" do` at line 234.
pub fn ruby_spdx_spec_l234_d43_returns() !bool {
	return spdx_spec_result(43)
}

// Ruby it `it "handles nested brackets" do` at line 246.
pub fn ruby_spdx_spec_l246_d44_handles() !bool {
	return spdx_spec_result(44)
}

// Ruby it `it "returns :public_domain" do` at line 258.
pub fn ruby_spdx_spec_l258_d45_returns() !bool {
	return spdx_spec_result(45)
}

// Ruby it `it "returns :cannot_represent" do` at line 262.
pub fn ruby_spdx_spec_l262_d46_returns() !bool {
	return spdx_spec_result(46)
}

// Ruby it `it "returns license without version" do` at line 269.
pub fn ruby_spdx_spec_l269_d47_returns() !bool {
	return spdx_spec_result(47)
}

// Ruby it `it "returns :public_domain without version" do` at line 273.
pub fn ruby_spdx_spec_l273_d48_returns() !bool {
	return spdx_spec_result(48)
}

// Ruby it `it "returns license with version" do` at line 277.
pub fn ruby_spdx_spec_l277_d49_returns() !bool {
	return spdx_spec_result(49)
}

// Ruby it `it "returns license with version and plus" do` at line 281.
pub fn ruby_spdx_spec_l281_d50_returns() !bool {
	return spdx_spec_result(50)
}

// Ruby it `it "returns more complicated license with version" do` at line 285.
pub fn ruby_spdx_spec_l285_d51_returns() !bool {
	return spdx_spec_result(51)
}

// Ruby it `it "returns more complicated license with version and plus" do` at line 289.
pub fn ruby_spdx_spec_l289_d52_returns() !bool {
	return spdx_spec_result(52)
}

// Ruby it `it "returns license with -only" do` at line 293.
pub fn ruby_spdx_spec_l293_d53_returns() !bool {
	return spdx_spec_result(53)
}

// Ruby it `it "returns license with -or-later" do` at line 297.
pub fn ruby_spdx_spec_l297_d54_returns() !bool {
	return spdx_spec_result(54)
}

// Ruby let `let(:mit_forbidden) { { "MIT" => described_class.license_version_info("MIT") } }` at line 303.
pub fn ruby_spdx_spec_l303_d55_mit_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_mit_forbidden()
}

// Ruby let `let(:epl_1_forbidden) { { "EPL-1.0" => described_class.license_version_info("EPL-1.0") } }` at line 304.
pub fn ruby_spdx_spec_l304_d56_epl_1_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_epl_1_forbidden()
}

// Ruby let `let(:epl_1_plus_forbidden) { { "EPL-1.0+" => described_class.license_version_info("EPL-1.0+") } }` at line 305.
pub fn ruby_spdx_spec_l305_d57_epl_1_plus_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_epl_1_plus_forbidden()
}

// Ruby let `let(:multiple_forbidden) do` at line 306.
pub fn ruby_spdx_spec_l306_d58_multiple_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_multiple_forbidden()
}

// Ruby let `let(:any_of_license) { { any_of: ["MIT", "0BSD"] } }` at line 312.
pub fn ruby_spdx_spec_l312_d59_any_of_license() SpdxLicenseExpression {
	return spdx_spec_any_of_license()
}

// Ruby let `let(:all_of_license) { { all_of: ["MIT", "0BSD"] } }` at line 313.
pub fn ruby_spdx_spec_l313_d60_all_of_license() SpdxLicenseExpression {
	return spdx_spec_all_of_license()
}

// Ruby let `let(:nested_licenses) do` at line 314.
pub fn ruby_spdx_spec_l314_d61_nested_licenses() SpdxLicenseExpression {
	return spdx_spec_nested_licenses()
}

// Ruby let `let(:license_exception) { { "MIT" => { with: "LLVM-exception" } } }` at line 323.
pub fn ruby_spdx_spec_l323_d62_license_exception() SpdxLicenseExpression {
	return spdx_spec_license_exception()
}

// Ruby it `it "allows installation with no forbidden licenses" do` at line 325.
pub fn ruby_spdx_spec_l325_d63_allows() !bool {
	return spdx_spec_result(63)
}

// Ruby it `it "allows installation with non-forbidden license" do` at line 329.
pub fn ruby_spdx_spec_l329_d64_allows() !bool {
	return spdx_spec_result(64)
}

// Ruby it `it "forbids installation with forbidden license" do` at line 333.
pub fn ruby_spdx_spec_l333_d65_forbids() !bool {
	return spdx_spec_result(65)
}

// Ruby it `it "allows installation of later license version" do` at line 337.
pub fn ruby_spdx_spec_l337_d66_allows() !bool {
	return spdx_spec_result(66)
}

// Ruby it `it "forbids installation of later license version with plus in forbidden license list" do` at line 341.
pub fn ruby_spdx_spec_l341_d67_forbids() !bool {
	return spdx_spec_result(67)
}

// Ruby it `it "allows installation when one of the any_of licenses is allowed" do` at line 345.
pub fn ruby_spdx_spec_l345_d68_allows() !bool {
	return spdx_spec_result(68)
}

// Ruby it `it "forbids installation when none of the any_of licenses are allowed" do` at line 349.
pub fn ruby_spdx_spec_l349_d69_forbids() !bool {
	return spdx_spec_result(69)
}

// Ruby it `it "forbids installation when one of the all_of licenses is allowed" do` at line 353.
pub fn ruby_spdx_spec_l353_d70_forbids() !bool {
	return spdx_spec_result(70)
}

// Ruby it `it "allows installation with license + exception that aren't forbidden" do` at line 357.
pub fn ruby_spdx_spec_l357_d71_allows() !bool {
	return spdx_spec_result(71)
}

// Ruby it `it "forbids installation with license + exception that are't forbidden" do` at line 361.
pub fn ruby_spdx_spec_l361_d72_forbids() !bool {
	return spdx_spec_result(72)
}

// Ruby it `it "allows installation with nested licenses with no forbidden licenses" do` at line 365.
pub fn ruby_spdx_spec_l365_d73_allows() !bool {
	return spdx_spec_result(73)
}

// Ruby it `it "allows installation with nested licenses when second hash item matches" do` at line 369.
pub fn ruby_spdx_spec_l369_d74_allows() !bool {
	return spdx_spec_result(74)
}

// Ruby it `it "forbids installation with nested licenses when all licenses are forbidden" do` at line 373.
pub fn ruby_spdx_spec_l373_d75_forbids() !bool {
	return spdx_spec_result(75)
}

// Ruby let `let(:mit_forbidden) { { "MIT" => described_class.license_version_info("MIT") } }` at line 379.
pub fn ruby_spdx_spec_l379_d76_mit_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_mit_forbidden()
}

// Ruby let `let(:epl_1_forbidden) { { "EPL-1.0" => described_class.license_version_info("EPL-1.0") } }` at line 380.
pub fn ruby_spdx_spec_l380_d77_epl_1_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_epl_1_forbidden()
}

// Ruby let `let(:epl_1_plus_forbidden) { { "EPL-1.0+" => described_class.license_version_info("EPL-1.0+") } }` at line 381.
pub fn ruby_spdx_spec_l381_d78_epl_1_plus_forbidden() map[string]SpdxLicenseVersionInfo {
	return spdx_spec_epl_1_plus_forbidden()
}

// Ruby it `it "returns false with no forbidden licenses" do` at line 383.
pub fn ruby_spdx_spec_l383_d79_returns() !bool {
	return spdx_spec_result(79)
}

// Ruby it `it "returns false with no matching forbidden licenses" do` at line 387.
pub fn ruby_spdx_spec_l387_d80_returns() !bool {
	return spdx_spec_result(80)
}

// Ruby it `it "returns true with matching license" do` at line 391.
pub fn ruby_spdx_spec_l391_d81_returns() !bool {
	return spdx_spec_result(81)
}

// Ruby it `it "returns false with later version of forbidden license" do` at line 395.
pub fn ruby_spdx_spec_l395_d82_returns() !bool {
	return spdx_spec_result(82)
}

// Ruby it `it "returns true with later version of forbidden license with later versions forbidden" do` at line 399.
pub fn ruby_spdx_spec_l399_d83_returns() !bool {
	return spdx_spec_result(83)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/spdx"
// 5:
// 6: RSpec.describe SPDX do
// 7:   describe ".license_data" do
// 8:     it "has the license list version" do
// 9:       expect(described_class.license_data["licenseListVersion"]).not_to be_nil
// 10:     end
// 11:
// 12:     it "has the release date" do
// 13:       expect(described_class.license_data["releaseDate"]).not_to be_nil
// 14:     end
// 15:
// 16:     it "has licenses" do
// 17:       expect(described_class.license_data["licenses"].length).not_to eq(0)
// 18:     end
// 19:   end
// 20:
// 21:   describe ".exception_data" do
// 22:     it "has the license list version" do
// 23:       expect(described_class.exception_data["licenseListVersion"]).not_to be_nil
// 24:     end
// 25:
// 26:     it "has the release date" do
// 27:       expect(described_class.exception_data["releaseDate"]).not_to be_nil
// 28:     end
// 29:
// 30:     it "has exceptions" do
// 31:       expect(described_class.exception_data["exceptions"].length).not_to eq(0)
// 32:     end
// 33:   end
// 34:
// 35:   describe ".download_latest_license_data!", :needs_network do
// 36:     let(:download_dir) { mktmpdir }
// 37:
// 38:     it "downloads latest license data" do
// 39:       described_class.download_latest_license_data! to: download_dir
// 40:       expect(download_dir/"spdx_licenses.json").to exist
// 41:       expect(download_dir/"spdx_exceptions.json").to exist
// 42:     end
// 43:   end
// 44:
// 45:   describe ".parse_license_expression" do
// 46:     specify do
// 47:       expect(described_class.parse_license_expression("MIT").first).to eq ["MIT"]
// 48:       expect(described_class.parse_license_expression("Apache-2.0+").first).to eq ["Apache-2.0+"]
// 49:       expect(described_class.parse_license_expression(any_of: ["MIT", "0BSD"]).first).to eq ["MIT", "0BSD"]
// 50:       expect(described_class.parse_license_expression(all_of: ["MIT", "0BSD"]).first).to eq ["MIT", "0BSD"]
// 51:       expect(described_class.parse_license_expression(any_of: ["MIT", "EPL-1.0+"]).first).to eq ["MIT", "EPL-1.0+"]
// 52:       expect(described_class.parse_license_expression(["MIT", "EPL-1.0+"]).first).to eq ["MIT", "EPL-1.0+"]
// 53:       expect(described_class.parse_license_expression(:public_domain).first).to eq [:public_domain]
// 54:       expect(described_class.parse_license_expression(:cannot_represent).first).to eq [:cannot_represent]
// 55:     end
// 56:
// 57:     it "returns license and exception" do
// 58:       license_expression = { "MIT" => { with: "LLVM-exception" } }
// 59:       expect(described_class.parse_license_expression(license_expression)).to eq [["MIT"], ["LLVM-exception"]]
// 60:     end
// 61:
// 62:     it "returns licenses and exceptions for complex license expressions" do
// 63:       license_expression = { any_of: [
// 64:         "MIT",
// 65:         :public_domain,
// 66:         # The final array item is legitimately a hash in the case of license expressions.
// 67:         {
// 68:           all_of: ["0BSD", "Zlib"],
// 69:           "curl" => { with: "LLVM-exception" },
// 70:         },
// 71:       ] }
// 72:       result = [["MIT", :public_domain, "curl", "0BSD", "Zlib"], ["LLVM-exception"]]
// 73:       expect(described_class.parse_license_expression(license_expression)).to eq result
// 74:     end
// 75:   end
// 76:
// 77:   describe ".valid_license?" do
// 78:     it "returns true for valid license identifier" do
// 79:       expect(described_class.valid_license?("MIT")).to be true
// 80:     end
// 81:
// 82:     it "returns false for invalid license identifier" do
// 83:       expect(described_class.valid_license?("foo")).to be false
// 84:     end
// 85:
// 86:     it "returns true for deprecated license identifier" do
// 87:       expect(described_class.valid_license?("GPL-1.0")).to be true
// 88:     end
// 89:
// 90:     it "returns true for license identifier with plus" do
// 91:       expect(described_class.valid_license?("Apache-2.0+")).to be true
// 92:     end
// 93:
// 94:     it "returns true for :public_domain" do
// 95:       expect(described_class.valid_license?(:public_domain)).to be true
// 96:     end
// 97:
// 98:     it "returns true for :cannot_represent" do
// 99:       expect(described_class.valid_license?(:cannot_represent)).to be true
// 100:     end
// 101:
// 102:     it "returns false for invalid symbol" do
// 103:       expect(described_class.valid_license?(:invalid_symbol)).to be false
// 104:     end
// 105:   end
// 106:
// 107:   describe ".deprecated_license?" do
// 108:     it "returns true for deprecated license identifier" do
// 109:       expect(described_class.deprecated_license?("GPL-1.0")).to be true
// 110:     end
// 111:
// 112:     it "returns true for deprecated license identifier with plus" do
// 113:       expect(described_class.deprecated_license?("GPL-1.0+")).to be true
// 114:     end
// 115:
// 116:     it "returns false for non-deprecated license identifier" do
// 117:       expect(described_class.deprecated_license?("MIT")).to be false
// 118:     end
// 119:
// 120:     it "returns false for non-deprecated license identifier with plus" do
// 121:       expect(described_class.deprecated_license?("EPL-1.0+")).to be false
// 122:     end
// 123:
// 124:     it "returns false for invalid license identifier" do
// 125:       expect(described_class.deprecated_license?("foo")).to be false
// 126:     end
// 127:
// 128:     it "returns false for :public_domain" do
// 129:       expect(described_class.deprecated_license?(:public_domain)).to be false
// 130:     end
// 131:
// 132:     it "returns false for :cannot_represent" do
// 133:       expect(described_class.deprecated_license?(:cannot_represent)).to be false
// 134:     end
// 135:   end
// 136:
// 137:   describe ".valid_license_exception?" do
// 138:     it "returns true for valid license exception identifier" do
// 139:       expect(described_class.valid_license_exception?("LLVM-exception")).to be true
// 140:     end
// 141:
// 142:     it "returns false for invalid license exception identifier" do
// 143:       expect(described_class.valid_license_exception?("foo")).to be false
// 144:     end
// 145:
// 146:     it "returns false for deprecated license exception identifier" do
// 147:       expect(described_class.valid_license_exception?("Nokia-Qt-exception-1.1")).to be false
// 148:     end
// 149:   end
// 150:
// 151:   describe ".license_expression_to_string" do
// 152:     it "returns a single license" do
// 153:       expect(described_class.license_expression_to_string("MIT")).to eq "MIT"
// 154:     end
// 155:
// 156:     it "returns a single license with plus" do
// 157:       expect(described_class.license_expression_to_string("Apache-2.0+")).to eq "Apache-2.0+"
// 158:     end
// 159:
// 160:     it "returns multiple licenses with :any" do
// 161:       expect(described_class.license_expression_to_string({ any_of: ["MIT", "0BSD"] })).to eq "MIT OR 0BSD"
// 162:     end
// 163:
// 164:     it "returns multiple licenses with :all" do
// 165:       expect(described_class.license_expression_to_string({ all_of: ["MIT", "0BSD"] })).to eq "MIT AND 0BSD"
// 166:     end
// 167:
// 168:     it "returns multiple licenses with plus" do
// 169:       expect(described_class.license_expression_to_string({ any_of: ["MIT", "EPL-1.0+"] })).to eq "MIT OR EPL-1.0+"
// 170:     end
// 171:
// 172:     it "returns license and exception" do
// 173:       license_expression = { "MIT" => { with: "LLVM-exception" } }
// 174:       expect(described_class.license_expression_to_string(license_expression)).to eq "MIT WITH LLVM-exception"
// 175:     end
// 176:
// 177:     it "returns licenses and exceptions for complex license expressions" do
// 178:       license_expression = { any_of: [
// 179:         "MIT",
// 180:         :public_domain,
// 181:         # The final array item is legitimately a hash in the case of license expressions.
// 182:         {
// 183:           all_of: ["0BSD", "Zlib"],
// 184:           "curl" => { with: "LLVM-exception" },
// 185:         },
// 186:       ] }
// 187:       result = "MIT OR LicenseRef-Homebrew-public-domain OR (0BSD AND Zlib) OR (curl WITH LLVM-exception)"
// 188:       expect(described_class.license_expression_to_string(license_expression)).to eq result
// 189:     end
// 190:
// 191:     it "returns :public_domain" do
// 192:       expect(described_class.license_expression_to_string(:public_domain)).to eq "LicenseRef-Homebrew-public-domain"
// 193:     end
// 194:
// 195:     it "returns :cannot_represent" do
// 196:       result = "LicenseRef-Homebrew-cannot-represent"
// 197:       expect(described_class.license_expression_to_string(:cannot_represent)).to eq result
// 198:     end
// 199:   end
// 200:
// 201:   describe ".truncate_license" do
// 202:     it "returns the license unchanged when within the limit" do
// 203:       expect(described_class.truncate_license("MIT AND Apache-2.0")).to eq "MIT AND Apache-2.0"
// 204:     end
// 205:
// 206:     it "truncates an over-long conjunction to a valid prefix with a marker" do
// 207:       license = "MIT AND Apache-2.0 AND BSD-3-Clause AND GPL-2.0-only"
// 208:       expect(described_class.truncate_license(license, limit: 40)).to eq "MIT AND LicenseRef-Homebrew-truncated"
// 209:     end
// 210:
// 211:     it "falls back to :cannot_represent for over-long disjunctions" do
// 212:       license = "MIT OR Apache-2.0 OR BSD-3-Clause OR GPL-2.0-only"
// 213:       expect(described_class.truncate_license(license, limit: 40)).to eq "LicenseRef-Homebrew-cannot-represent"
// 214:     end
// 215:
// 216:     it "falls back to :cannot_represent when even the first term does not fit" do
// 217:       license = "Apache-2.0 AND MIT AND BSD-3-Clause AND ISC"
// 218:       expect(described_class.truncate_license(license, limit: 20)).to eq "LicenseRef-Homebrew-cannot-represent"
// 219:     end
// 220:   end
// 221:
// 222:   describe ".string_to_license_expression" do
// 223:     it "returns the correct result for 'and', 'or' and 'with'" do
// 224:       expr_string = "Apache-2.0 and (Apache-2.0 with LLVM-exception) and (MIT or NCSA)"
// 225:       expect(described_class.string_to_license_expression(expr_string)).to eq({
// 226:         all_of: [
// 227:           "Apache-2.0",
// 228:           { "Apache-2.0" => { with: "LLVM-exception" } },
// 229:           { any_of: ["MIT", "NCSA"] },
// 230:         ],
// 231:       })
// 232:     end
// 233:
// 234:     it "returns the correct result for 'AND', 'OR' and 'WITH'" do
// 235:       expr_string = "Apache-2.0 AND (Apache-2.0 WITH LLVM-exception) AND (MIT OR NCSA)"
// 236:       expect(described_class.string_to_license_expression(expr_string)).to eq({
// 237:         all_of: [
// 238:           "Apache-2.0",
// 239:           { "Apache-2.0" => { with: "LLVM-exception" } },
// 240:           { any_of: ["MIT", "NCSA"] },
// 241:         ],
// 242:       })
// 243:     end
// 244:
// 245:     # The final array item is legitimately a hash in the case of license expressions.
// 246:     it "handles nested brackets" do
// 247:       expect(described_class.string_to_license_expression("A AND (B OR (C AND D))")).to eq({
// 248:         all_of: [
// 249:           "A",
// 250:           { any_of: [
// 251:             "B",
// 252:             { all_of: ["C", "D"] },
// 253:           ] },
// 254:         ],
// 255:       })
// 256:     end
// 257:
// 258:     it "returns :public_domain" do
// 259:       expect(described_class.string_to_license_expression("LicenseRef-Homebrew-public-domain")).to eq :public_domain
// 260:     end
// 261:
// 262:     it "returns :cannot_represent" do
// 263:       expr_string = "LicenseRef-Homebrew-cannot-represent"
// 264:       expect(described_class.string_to_license_expression(expr_string)).to eq :cannot_represent
// 265:     end
// 266:   end
// 267:
// 268:   describe ".license_version_info" do
// 269:     it "returns license without version" do
// 270:       expect(described_class.license_version_info("MIT")).to eq ["MIT"]
// 271:     end
// 272:
// 273:     it "returns :public_domain without version" do
// 274:       expect(described_class.license_version_info(:public_domain)).to eq [:public_domain]
// 275:     end
// 276:
// 277:     it "returns license with version" do
// 278:       expect(described_class.license_version_info("Apache-2.0")).to eq ["Apache", "2.0", false]
// 279:     end
// 280:
// 281:     it "returns license with version and plus" do
// 282:       expect(described_class.license_version_info("Apache-2.0+")).to eq ["Apache", "2.0", true]
// 283:     end
// 284:
// 285:     it "returns more complicated license with version" do
// 286:       expect(described_class.license_version_info("CC-BY-3.0-AT")).to eq ["CC-BY", "3.0", false]
// 287:     end
// 288:
// 289:     it "returns more complicated license with version and plus" do
// 290:       expect(described_class.license_version_info("CC-BY-3.0-AT+")).to eq ["CC-BY", "3.0", true]
// 291:     end
// 292:
// 293:     it "returns license with -only" do
// 294:       expect(described_class.license_version_info("GPL-3.0-only")).to eq ["GPL", "3.0", false]
// 295:     end
// 296:
// 297:     it "returns license with -or-later" do
// 298:       expect(described_class.license_version_info("GPL-3.0-or-later")).to eq ["GPL", "3.0", true]
// 299:     end
// 300:   end
// 301:
// 302:   describe ".licenses_forbid_installation?" do
// 303:     let(:mit_forbidden) { { "MIT" => described_class.license_version_info("MIT") } }
// 304:     let(:epl_1_forbidden) { { "EPL-1.0" => described_class.license_version_info("EPL-1.0") } }
// 305:     let(:epl_1_plus_forbidden) { { "EPL-1.0+" => described_class.license_version_info("EPL-1.0+") } }
// 306:     let(:multiple_forbidden) do
// 307:       {
// 308:         "MIT"  => described_class.license_version_info("MIT"),
// 309:         "0BSD" => described_class.license_version_info("0BSD"),
// 310:       }
// 311:     end
// 312:     let(:any_of_license) { { any_of: ["MIT", "0BSD"] } }
// 313:     let(:all_of_license) { { all_of: ["MIT", "0BSD"] } }
// 314:     let(:nested_licenses) do
// 315:       {
// 316:         any_of: [
// 317:           "MIT",
// 318:           { "MIT" => { with: "LLVM-exception" } },
// 319:           { any_of: ["MIT", "0BSD"] },
// 320:         ],
// 321:       }
// 322:     end
// 323:     let(:license_exception) { { "MIT" => { with: "LLVM-exception" } } }
// 324:
// 325:     it "allows installation with no forbidden licenses" do
// 326:       expect(described_class.licenses_forbid_installation?("MIT", {})).to be false
// 327:     end
// 328:
// 329:     it "allows installation with non-forbidden license" do
// 330:       expect(described_class.licenses_forbid_installation?("0BSD", mit_forbidden)).to be false
// 331:     end
// 332:
// 333:     it "forbids installation with forbidden license" do
// 334:       expect(described_class.licenses_forbid_installation?("MIT", mit_forbidden)).to be true
// 335:     end
// 336:
// 337:     it "allows installation of later license version" do
// 338:       expect(described_class.licenses_forbid_installation?("EPL-2.0", epl_1_forbidden)).to be false
// 339:     end
// 340:
// 341:     it "forbids installation of later license version with plus in forbidden license list" do
// 342:       expect(described_class.licenses_forbid_installation?("EPL-2.0", epl_1_plus_forbidden)).to be true
// 343:     end
// 344:
// 345:     it "allows installation when one of the any_of licenses is allowed" do
// 346:       expect(described_class.licenses_forbid_installation?(any_of_license, mit_forbidden)).to be false
// 347:     end
// 348:
// 349:     it "forbids installation when none of the any_of licenses are allowed" do
// 350:       expect(described_class.licenses_forbid_installation?(any_of_license, multiple_forbidden)).to be true
// 351:     end
// 352:
// 353:     it "forbids installation when one of the all_of licenses is allowed" do
// 354:       expect(described_class.licenses_forbid_installation?(all_of_license, mit_forbidden)).to be true
// 355:     end
// 356:
// 357:     it "allows installation with license + exception that aren't forbidden" do
// 358:       expect(described_class.licenses_forbid_installation?(license_exception, epl_1_forbidden)).to be false
// 359:     end
// 360:
// 361:     it "forbids installation with license + exception that are't forbidden" do
// 362:       expect(described_class.licenses_forbid_installation?(license_exception, mit_forbidden)).to be true
// 363:     end
// 364:
// 365:     it "allows installation with nested licenses with no forbidden licenses" do
// 366:       expect(described_class.licenses_forbid_installation?(nested_licenses, epl_1_forbidden)).to be false
// 367:     end
// 368:
// 369:     it "allows installation with nested licenses when second hash item matches" do
// 370:       expect(described_class.licenses_forbid_installation?(nested_licenses, mit_forbidden)).to be false
// 371:     end
// 372:
// 373:     it "forbids installation with nested licenses when all licenses are forbidden" do
// 374:       expect(described_class.licenses_forbid_installation?(nested_licenses, multiple_forbidden)).to be true
// 375:     end
// 376:   end
// 377:
// 378:   describe ".forbidden_licenses_include?" do
// 379:     let(:mit_forbidden) { { "MIT" => described_class.license_version_info("MIT") } }
// 380:     let(:epl_1_forbidden) { { "EPL-1.0" => described_class.license_version_info("EPL-1.0") } }
// 381:     let(:epl_1_plus_forbidden) { { "EPL-1.0+" => described_class.license_version_info("EPL-1.0+") } }
// 382:
// 383:     it "returns false with no forbidden licenses" do
// 384:       expect(described_class.forbidden_licenses_include?("MIT", {})).to be false
// 385:     end
// 386:
// 387:     it "returns false with no matching forbidden licenses" do
// 388:       expect(described_class.forbidden_licenses_include?("MIT", epl_1_forbidden)).to be false
// 389:     end
// 390:
// 391:     it "returns true with matching license" do
// 392:       expect(described_class.forbidden_licenses_include?("MIT", mit_forbidden)).to be true
// 393:     end
// 394:
// 395:     it "returns false with later version of forbidden license" do
// 396:       expect(described_class.forbidden_licenses_include?("EPL-2.0", epl_1_forbidden)).to be false
// 397:     end
// 398:
// 399:     it "returns true with later version of forbidden license with later versions forbidden" do
// 400:       expect(described_class.forbidden_licenses_include?("EPL-2.0", epl_1_plus_forbidden)).to be true
// 401:     end
// 402:   end
// 403: end
