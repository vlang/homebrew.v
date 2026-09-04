module dsl

import ruby

// Translated from Homebrew/brew `cask/dsl/version.rb`.
const cask_version_dividers = {
	'.': 'dots'
	'-': 'hyphens'
	'_': 'underscores'
}

pub struct CaskVersion {
pub:
	raw_version ruby.Value
	text        string
}

fn cask_version_nil() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

pub fn new_cask_version(raw_version ruby.Value) !CaskVersion {
	mut text := raw_version.as_string()
	if raw_version.type_name == 'Symbol' {
		text = text.trim_left(':')
	}
	if raw_version.type_name == 'NilClass' || raw_version.type_name == '' {
		text = ''
	}
	version := CaskVersion{
		raw_version: raw_version
		text: text
	}
	invalid := version.invalid_characters()
	if invalid.len > 0 {
		mut unique := []string{}
		for character in invalid {
			if character !in unique {
				unique << character
			}
		}
		return error('${raw_version.as_string()} contains invalid characters: ${unique.join('')}!')
	}
	return version
}

pub fn cask_version_from_string(value string) !CaskVersion {
	return new_cask_version(ruby.string_value(value))
}

pub fn cask_version_value(version CaskVersion) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::DSL::Version'
		repr: version.text
		map_data: {
			'raw_version': version.raw_version
		}
		attributes: {
			'raw_type': version.raw_version.type_name
		}
	}
}

pub fn cask_version_from_value(value ruby.Value) !CaskVersion {
	if value.type_name == 'Cask::DSL::Version' {
		raw := value.map_data['raw_version'] or { ruby.string_value(value.as_string()) }
		return new_cask_version(raw)
	}
	return new_cask_version(value)
}

pub fn (version CaskVersion) invalid_characters() []string {
	if version.text == '' || version.latest() {
		return []string{}
	}
	mut invalid := []string{}
	for character in version.text.runes() {
		if !(character >= `0` && character <= `9`) && !(character >= `a` && character <= `z`) && !(character >= `A` && character <= `Z`) && character !in [
			`.`,
			`,`,
			`:`,
			`-`,
			`_`,
			`+`,
			` `,
		] {
			invalid << character.str()
		}
	}
	return invalid
}

pub fn (version CaskVersion) latest() bool {
	return version.text == 'latest'
}

fn cask_version_unstable_text(value string) string {
	mut normalized := ''
	mut separator := false
	for character in value.to_lower().replace('.', '').runes() {
		if (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`) {
			normalized += character.str()
			separator = false
		} else if !separator {
			normalized += '-'
			separator = true
		}
	}
	return normalized
}

fn cask_version_prerelease_word(value string) bool {
	for word in ['alpha', 'beta', 'preview', 'rc', 'dev', 'canary', 'snapshot'] {
		mut offset := 0
		for offset <= value.len - word.len {
			relative := value[offset..].index(word) or { break }
			start := offset + relative
			end := start + word.len
			before := start == 0 || value[start - 1].is_digit() || value[start - 1] == `-`
			after := end == value.len || value[end].is_digit() || value[end] == `-`
			if before && after {
				return true
			}
			offset = start + 1
		}
	}
	return false
}

fn cask_version_abbreviated_prefix(prefix string) bool {
	if prefix == '' || !prefix[0].is_alnum() {
		return false
	}
	parts := prefix.split('-')
	if parts[0] == '' || !parts[0].bytes().all(it.is_alnum()) {
		return false
	}
	for index in 1 .. parts.len {
		part := parts[index]
		if index == parts.len - 1 && part == '' {
			continue
		}
		if part == '' || !part.bytes().all(it.is_digit()) {
			return false
		}
	}
	return true
}

fn cask_version_abbreviated_prerelease(value string) bool {
	for qualifier in ['pre', 'a', 'b'] {
		mut offset := 1
		for offset <= value.len - qualifier.len {
			relative := value[offset..].index(qualifier) or { break }
			start := offset + relative
			end := start + qualifier.len
			if cask_version_abbreviated_prefix(value[..start]) && (end == value.len || value[end].is_digit() || value[end] == `-`) {
				return true
			}
			offset = start + 1
		}
	}
	return false
}

pub fn (version CaskVersion) unstable() bool {
	if version.latest() {
		return false
	}
	value := cask_version_unstable_text(version.text)
	return cask_version_prerelease_word(value) || cask_version_abbreviated_prerelease(value)
}

fn cask_version_components(text string) []string {
	mut result := []string{}
	mut start := 0
	for index, character in text {
		if character in [`.`, `,`, `:`] {
			result << text[start..index]
			start = index + 1
			if result.len == 3 {
				break
			}
		}
	}
	if result.len < 3 && start <= text.len {
		result << text[start..]
	}
	for result.len < 3 {
		result << ''
	}
	return result[..3]
}

fn cask_version_derived(version CaskVersion, text string) CaskVersion {
	if version.text == '' || version.latest() {
		return version
	}
	raw := if text == '' { cask_version_nil() } else { ruby.string_value(text) }
	return new_cask_version(raw) or { CaskVersion{ raw_version: raw, text: text } }
}

pub fn (version CaskVersion) major() CaskVersion {
	return cask_version_derived(version, cask_version_components(version.text)[0])
}

pub fn (version CaskVersion) minor() CaskVersion {
	return cask_version_derived(version, cask_version_components(version.text)[1])
}

pub fn (version CaskVersion) patch() CaskVersion {
	return cask_version_derived(version, cask_version_components(version.text)[2])
}

pub fn (version CaskVersion) major_minor() CaskVersion {
	return cask_version_derived(version, [version.major().text, version.minor().text].filter(it != '').join('.'))
}

pub fn (version CaskVersion) major_minor_patch() CaskVersion {
	return cask_version_derived(version, [version.major().text, version.minor().text,
		version.patch().text].filter(it != '').join('.'))
}

pub fn (version CaskVersion) minor_patch() CaskVersion {
	return cask_version_derived(version, [version.minor().text, version.patch().text].filter(it != '').join('.'))
}

pub fn (version CaskVersion) csv() []CaskVersion {
	if version.text == '' {
		return []
	}
	mut parts := version.text.split(',')
	for parts.len > 0 && parts.last() == '' {
		parts.delete_last()
	}
	return parts.map(cask_version_from_string(it) or { CaskVersion{ text: it } })
}

pub fn (version CaskVersion) before_comma() CaskVersion {
	return cask_version_derived(version, version.text.all_before(','))
}

pub fn (version CaskVersion) after_comma() CaskVersion {
	return cask_version_derived(version, if version.text.contains(',') {
		version.text.all_after(',')
	} else {
		''
	})
}

pub fn (version CaskVersion) no_dividers() CaskVersion {
	return cask_version_derived(version, version.text.replace('.', '').replace('-', '').replace('_', ''))
}

pub fn (version CaskVersion) delete_divider(divider string) CaskVersion {
	return cask_version_derived(version, version.text.replace(divider, ''))
}

pub fn (version CaskVersion) convert_divider(left string, right string) CaskVersion {
	return cask_version_derived(version, version.text.replace(left, right))
}

pub fn (version CaskVersion) chomp(separator ?string) CaskVersion {
	mut text := version.text
	if value := separator {
		if value == '' {
			text = text.trim_right('\r\n')
		} else if text.ends_with(value) {
			text = text[..text.len - value.len]
		}
	} else if text.ends_with('\r\n') {
		text = text[..text.len - 2]
	} else if text.ends_with('\n') || text.ends_with('\r') {
		text = text[..text.len - 1]
	}
	return cask_version_derived(version, text)
}

fn cask_version_argument(args []ruby.Value, index int) ruby.Value {
	return if args.len > index { args[index] } else { cask_version_nil() }
}

fn cask_version_receiver(args []ruby.Value) ?CaskVersion {
	if args.len == 0 {
		return none
	}
	return cask_version_from_value(args[0]) or { return none }
}

fn cask_version_error(message string) ruby.Value {
	return ruby.object_value('TypeError', message)
}
