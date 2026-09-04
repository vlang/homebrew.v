module utils

import net.http
import os
import x.json2

// Translated from Homebrew/brew `utils/spdx.rb`.
pub const spdx_api_url = 'https://api.github.com/repos/spdx/license-list-data/releases/latest'
pub const spdx_licenseref_prefix = 'LicenseRef-Homebrew-'
pub const spdx_allowed_license_symbols = ['public_domain', 'cannot_represent', 'truncated']

const embedded_spdx_licenses = $embed_file('../data/spdx/spdx_licenses.json')
const embedded_spdx_exceptions = $embed_file('../data/spdx/spdx_exceptions.json')

pub struct SpdxLicenseRecord {
pub:
	id         string
	deprecated bool
}

pub struct SpdxExceptionRecord {
pub:
	id         string
	deprecated bool
}

pub struct SpdxLicenseData {
pub:
	license_list_version string
	release_date         string
	licenses             []SpdxLicenseRecord
}

pub struct SpdxExceptionData {
pub:
	license_list_version string
	release_date         string
	exceptions           []SpdxExceptionRecord
}

pub enum SpdxExpressionKind {
	identifier
	symbol
	any_of
	all_of
	with_exception
}

// SpdxLicenseExpression is the typed equivalent of the source String, Symbol,
// Array and Hash expression union.
pub struct SpdxLicenseExpression {
pub:
	kind      SpdxExpressionKind
	value     string
	exception string
	children  []SpdxLicenseExpression
}

pub struct SpdxLicenseToken {
pub:
	value  string
	symbol bool
}

pub struct SpdxParsedExpression {
pub:
	licenses   []SpdxLicenseToken
	exceptions []string
}

pub struct SpdxLicenseVersionInfo {
pub:
	license     SpdxLicenseToken
	name        string
	version     string
	has_version bool
	or_later    bool
}

pub fn spdx_license(value string) SpdxLicenseExpression {
	return SpdxLicenseExpression{
		kind: .identifier
		value: value
	}
}

pub fn spdx_symbol(value string) SpdxLicenseExpression {
	return SpdxLicenseExpression{
		kind: .symbol
		value: value.trim_string_left(':')
	}
}

pub fn spdx_any_of(children []SpdxLicenseExpression) SpdxLicenseExpression {
	return SpdxLicenseExpression{
		kind: .any_of
		children: children.clone()
	}
}

pub fn spdx_all_of(children []SpdxLicenseExpression) SpdxLicenseExpression {
	return SpdxLicenseExpression{
		kind: .all_of
		children: children.clone()
	}
}

pub fn spdx_license_with_exception(license string, exception string) SpdxLicenseExpression {
	return SpdxLicenseExpression{
		kind: .with_exception
		value: license
		exception: exception
	}
}

pub fn spdx_license_token(value string) SpdxLicenseToken {
	return SpdxLicenseToken{
		value: value
	}
}

pub fn spdx_symbol_token(value string) SpdxLicenseToken {
	return SpdxLicenseToken{
		value: value.trim_string_left(':')
		symbol: true
	}
}

fn spdx_any_string(attributes map[string]json2.Any, key string) string {
	value := attributes[key] or { return '' }
	if value is json2.Null {
		return ''
	}
	return value.str()
}

fn spdx_any_bool(attributes map[string]json2.Any, key string) bool {
	value := attributes[key] or { return false }
	if value is json2.Null {
		return false
	}
	return value.bool()
}

pub fn decode_spdx_license_data(contents string) !SpdxLicenseData {
	root := json2.decode[json2.Any](contents)!.as_map()
	mut licenses := []SpdxLicenseRecord{}
	for value in (root['licenses'] or { json2.Any([]json2.Any{}) }).as_array() {
		attributes := value.as_map()
		licenses << SpdxLicenseRecord{
			id: spdx_any_string(attributes, 'licenseId')
			deprecated: spdx_any_bool(attributes, 'isDeprecatedLicenseId')
		}
	}
	return SpdxLicenseData{
		license_list_version: spdx_any_string(root, 'licenseListVersion')
		release_date: spdx_any_string(root, 'releaseDate')
		licenses: licenses
	}
}

pub fn decode_spdx_exception_data(contents string) !SpdxExceptionData {
	root := json2.decode[json2.Any](contents)!.as_map()
	mut exceptions := []SpdxExceptionRecord{}
	for value in (root['exceptions'] or { json2.Any([]json2.Any{}) }).as_array() {
		attributes := value.as_map()
		exceptions << SpdxExceptionRecord{
			id: spdx_any_string(attributes, 'licenseExceptionId')
			deprecated: spdx_any_bool(attributes, 'isDeprecatedLicenseId')
		}
	}
	return SpdxExceptionData{
		license_list_version: spdx_any_string(root, 'licenseListVersion')
		release_date: spdx_any_string(root, 'releaseDate')
		exceptions: exceptions
	}
}

pub fn spdx_license_data() !SpdxLicenseData {
	return decode_spdx_license_data(embedded_spdx_licenses.to_string())
}

pub fn spdx_exception_data() !SpdxExceptionData {
	return decode_spdx_exception_data(embedded_spdx_exceptions.to_string())
}

pub fn spdx_latest_tag(api_url string) !string {
	response := http.get(api_url)!
	if response.status_code < 200 || response.status_code >= 300 {
		return error('SPDX release request failed with HTTP ${response.status_code}')
	}
	root := json2.decode[json2.Any](response.body)!.as_map()
	tag := spdx_any_string(root, 'tag_name')
	if tag == '' {
		return error('SPDX release response has no tag_name')
	}
	return tag
}

fn download_spdx_file(url string, destination string) ! {
	response := http.get(url)!
	if response.status_code < 200 || response.status_code >= 300 {
		return error('SPDX data download failed with HTTP ${response.status_code}: ${url}')
	}
	os.mkdir_all(os.dir(destination))!
	os.write_file(destination, response.body)!
}

pub fn download_latest_spdx_license_data(destination string) ! {
	tag := spdx_latest_tag(spdx_api_url)!
	base_url := 'https://raw.githubusercontent.com/spdx/license-list-data/refs/tags/${tag}/json'
	download_spdx_file('${base_url}/licenses.json', os.join_path(destination, 'spdx_licenses.json'))!
	download_spdx_file('${base_url}/exceptions.json', os.join_path(destination, 'spdx_exceptions.json'))!
}

pub fn parse_spdx_license_expression(expression SpdxLicenseExpression) SpdxParsedExpression {
	mut licenses := []SpdxLicenseToken{}
	mut exceptions := []string{}
	match expression.kind {
		.identifier {
			licenses << spdx_license_token(expression.value)
		}
		.symbol {
			licenses << spdx_symbol_token(expression.value)
		}
		.with_exception {
			licenses << spdx_license_token(expression.value)
			exceptions << expression.exception
		}
		.any_of, .all_of {
			for child in expression.children {
				parsed := parse_spdx_license_expression(child)
				licenses << parsed.licenses
				exceptions << parsed.exceptions
			}
		}
	}
	return SpdxParsedExpression{
		licenses: licenses
		exceptions: exceptions
	}
}

fn allowed_spdx_symbol(symbol string) bool {
	return symbol.trim_string_left(':') in spdx_allowed_license_symbols
}

pub fn valid_spdx_license(license SpdxLicenseToken) !bool {
	if license.symbol {
		return allowed_spdx_symbol(license.value)
	}
	wanted := license.value.trim_string_right('+').to_lower()
	data := spdx_license_data()!
	return data.licenses.any(it.id.to_lower() == wanted)
}

pub fn deprecated_spdx_license(license SpdxLicenseToken) !bool {
	if license.symbol && allowed_spdx_symbol(license.value) {
		return false
	}
	if !valid_spdx_license(license)! {
		return false
	}
	wanted := license.value.trim_string_right('+').to_lower()
	data := spdx_license_data()!
	return !data.licenses.any(it.id.to_lower() == wanted && !it.deprecated)
}

pub fn valid_spdx_license_exception(exception string) !bool {
	wanted := exception.to_lower()
	data := spdx_exception_data()!
	return data.exceptions.any(it.id.to_lower() == wanted && !it.deprecated)
}

pub fn spdx_license_expression_to_string(expression SpdxLicenseExpression,
	bracket bool) string {
	match expression.kind {
		.identifier {
			return expression.value
		}
		.symbol {
			return spdx_licenseref_prefix + expression.value.replace('_', '-')
		}
		.with_exception {
			rendered := '${expression.value} WITH ${expression.exception}'
			return if bracket { '(${rendered})' } else { rendered }
		}
		.any_of, .all_of {
			operator := if expression.kind == .any_of { ' OR ' } else { ' AND ' }
			mut rendered := []string{}
			for child in expression.children {
				rendered << spdx_license_expression_to_string(child, true)
			}
			joined := rendered.join(operator)
			return if bracket { '(${joined})' } else { joined }
		}
	}
}

fn spdx_has_outer_parentheses(value string) bool {
	if value.len < 2 || value[0] != `(` || value[value.len - 1] != `)` {
		return false
	}
	mut depth := 0
	for index, character in value {
		if character == `(` {
			depth++
		} else if character == `)` {
			depth--
			if depth == 0 && index < value.len - 1 {
				return false
			}
		}
		if depth < 0 {
			return false
		}
	}
	return depth == 0
}

fn split_spdx_top_level(value string, operator string) []string {
	upper := value.to_upper()
	needle := operator.to_upper()
	mut depth := 0
	mut start := 0
	mut parts := []string{}
	mut index := 0
	for index < value.len {
		character := value[index]
		if character == `(` {
			depth++
		} else if character == `)` {
			depth--
		}
		if depth == 0 && index + needle.len <= value.len && upper[index..index + needle.len] == needle {
			parts << value[start..index]
			index += needle.len
			start = index
			continue
		}
		index++
	}
	if parts.len > 0 {
		parts << value[start..]
	}
	return parts
}

pub fn string_to_spdx_license_expression(value string) ?SpdxLicenseExpression {
	mut input := value.trim_space()
	if input == '' {
		return none
	}
	if spdx_has_outer_parentheses(input) {
		input = input[1..input.len - 1].trim_space()
	}
	and_parts := split_spdx_top_level(input, ' AND ')
	if and_parts.len > 1 {
		mut children := []SpdxLicenseExpression{}
		for part in and_parts {
			children << string_to_spdx_license_expression(part) or {
				return spdx_license(input)
			}
		}
		return spdx_all_of(children)
	}
	or_parts := split_spdx_top_level(input, ' OR ')
	if or_parts.len > 1 {
		mut children := []SpdxLicenseExpression{}
		for part in or_parts {
			children << string_to_spdx_license_expression(part) or {
				return spdx_license(input)
			}
		}
		return spdx_any_of(children)
	}
	with_parts := split_spdx_top_level(input, ' WITH ')
	if with_parts.len > 1 {
		return spdx_license_with_exception(with_parts[0].trim_space(), with_parts[1..].join(' WITH ').trim_space())
	}
	if input.starts_with(spdx_licenseref_prefix) {
		symbol := input.trim_string_left(spdx_licenseref_prefix).to_lower().replace('-', '_')
		if allowed_spdx_symbol(symbol) {
			return spdx_symbol(symbol)
		}
	}
	return spdx_license(input)
}

pub fn truncate_spdx_license(license string, limit int) string {
	if license.len <= limit {
		return license
	}
	fallback := spdx_license_expression_to_string(spdx_symbol('cannot_represent'), false)
	mut parts := []string{}
	for segment in license.split(' AND ') {
		if parts.len > 0 && parts.last().count('(') > parts.last().count(')') {
			parts[parts.len - 1] = '${parts.last()} AND ${segment}'
		} else {
			parts << segment
		}
	}
	if parts.len < 2 {
		return fallback
	}
	marker := spdx_license_expression_to_string(spdx_symbol('truncated'), false)
	mut kept := []string{}
	for part in parts {
		mut candidate := kept.clone()
		candidate << part
		candidate << marker
		if candidate.join(' AND ').len > limit {
			break
		}
		kept << part
	}
	if kept.len == 0 {
		return fallback
	}
	kept << marker
	return kept.join(' AND ')
}

fn spdx_version_start(license string) int {
	for index := 0; index + 1 < license.len; index++ {
		if license[index] == `-` && license[index + 1].is_digit() {
			return index
		}
	}
	return -1
}

pub fn spdx_license_version_info(license SpdxLicenseToken) SpdxLicenseVersionInfo {
	if license.symbol && allowed_spdx_symbol(license.value) {
		return SpdxLicenseVersionInfo{
			license: license
			name: license.value
		}
	}
	start := spdx_version_start(license.value)
	if start < 0 {
		return SpdxLicenseVersionInfo{
			license: license
			name: license.value
		}
	}
	mut end := start + 1
	for end < license.value.len && (license.value[end].is_digit() || license.value[end] == `.`) {
		end++
	}
	suffix := license.value[end..]
	return SpdxLicenseVersionInfo{
		license: license
		name: license.value[..start]
		version: license.value[start + 1..end]
		has_version: true
		or_later: suffix.ends_with('+') || suffix.ends_with('-or-later')
	}
}

fn spdx_token_key(token SpdxLicenseToken) string {
	return if token.symbol { ':${token.value}' } else { token.value }
}

pub fn spdx_forbidden_license_map(licenses []SpdxLicenseToken) map[string]SpdxLicenseVersionInfo {
	mut forbidden := map[string]SpdxLicenseVersionInfo{}
	for license in licenses {
		forbidden[spdx_token_key(license)] = spdx_license_version_info(license)
	}
	return forbidden
}

pub fn forbidden_spdx_licenses_include(license SpdxLicenseToken,
	forbidden map[string]SpdxLicenseVersionInfo) bool {
	if spdx_token_key(license) in forbidden {
		return true
	}
	info := spdx_license_version_info(license)
	for _, forbidden_info in forbidden {
		if forbidden_info.name != info.name {
			continue
		}
		if !forbidden_info.has_version && !info.has_version {
			return true
		}
		if !forbidden_info.has_version || !info.has_version {
			continue
		}
		if forbidden_info.or_later && forbidden_info.version <= info.version {
			return true
		}
		if forbidden_info.version == info.version {
			return true
		}
	}
	return false
}

pub fn spdx_licenses_forbid_installation(expression SpdxLicenseExpression,
	forbidden map[string]SpdxLicenseVersionInfo) bool {
	match expression.kind {
		.identifier {
			return forbidden_spdx_licenses_include(spdx_license_token(expression.value), forbidden)
		}
		.symbol {
			return forbidden_spdx_licenses_include(spdx_symbol_token(expression.value), forbidden)
		}
		.with_exception {
			return forbidden_spdx_licenses_include(spdx_license_token(expression.value), forbidden)
		}
		.any_of {
			return expression.children.all(spdx_licenses_forbid_installation(it, forbidden))
		}
		.all_of {
			return expression.children.any(spdx_licenses_forbid_installation(it, forbidden))
		}
	}
}
