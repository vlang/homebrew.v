module homebrew

import ruby

// Translated from Homebrew/brew `locale.rb`.

// Locale is the V representation of Homebrew's ordered language, script, and
// region components. Empty fields represent Ruby nil.
pub struct Locale {
pub:
	language string
	script   string
	region   string
}

pub fn new_locale(language string, script string, region string) !Locale {
	if language.len == 0 && script.len == 0 && region.len == 0 {
		return error('Locale cannot be empty')
	}
	if language.len > 0 && !valid_language(language) {
		return error("'language' does not match locale language format")
	}
	if script.len > 0 && !valid_script(script) {
		return error("'script' does not match locale script format")
	}
	if region.len > 0 && !valid_region(region) {
		return error("'region' does not match locale region format")
	}
	return Locale{
		language: language
		script: script
		region: region
	}
}

pub fn parse_locale(input string) !Locale {
	return try_parse_locale(input) or { return error("'${input}' cannot be parsed to a Locale") }
}

pub fn try_parse_locale(input string) ?Locale {
	if input.len == 0 || input.starts_with('-') || input.ends_with('-') {
		return none
	}
	parts := input.split('-')
	if parts.len == 0 || parts.len > 3 || parts.any(it.len == 0) {
		return none
	}
	mut language := ''
	mut script := ''
	mut region := ''
	mut position := 0
	if position < parts.len && valid_language(parts[position]) {
		language = parts[position]
		position++
	}
	if position < parts.len && valid_script(parts[position]) {
		script = parts[position]
		position++
	}
	if position < parts.len && valid_region(parts[position]) {
		region = parts[position]
		position++
	}
	if position != parts.len {
		return none
	}
	return new_locale(language, script, region) or { none }
}

pub fn (locale Locale) includes(other Locale) bool {
	return (other.language.len == 0 || locale.language == other.language)
		&& (other.script.len == 0 || locale.script == other.script)
		&& (other.region.len == 0 || locale.region == other.region)
}

pub fn (locale Locale) includes_string(other string) bool {
	parsed := try_parse_locale(other) or { return false }
	return locale.includes(parsed)
}

pub fn (locale Locale) equals(other Locale) bool {
	return locale.language == other.language && locale.script == other.script
		&& locale.region == other.region
}

pub fn (locale Locale) equals_string(other string) bool {
	parsed := try_parse_locale(other) or { return false }
	return locale.equals(parsed)
}

pub fn (locale Locale) detect(locale_groups [][]string) ?[]string {
	for group in locale_groups {
		if group.any(locale.equals_string(it)) {
			return group.clone()
		}
	}
	for group in locale_groups {
		if group.any(locale.includes_string(it)) {
			return group.clone()
		}
	}
	return none
}

pub fn (locale Locale) str() string {
	return [locale.language, locale.script, locale.region].filter(it.len > 0).join('-')
}

fn valid_language(value string) bool {
	return value.len in [2, 3] && value.bytes().all(it >= `a` && it <= `z`)
}

fn valid_script(value string) bool {
	return value.len == 4 && value[0] >= `A` && value[0] <= `Z` && value[1..].bytes().all(it >= `a`
		&& it <= `z`)
}

fn valid_region(value string) bool {
	return (value.len == 2 && value.bytes().all(it >= `A` && it <= `Z`))
		|| (value.len == 3 && value.bytes().all(it >= `0` && it <= `9`))
}

fn locale_value(locale Locale) ruby.Value {
	return ruby.structured_value('Locale', locale.str(), {
		'language': locale.language
		'script':   locale.script
		'region':   locale.region
	})
}

fn locale_from_value(value ruby.Value) !Locale {
	if value.type_name == 'Locale' {
		return new_locale(value.attributes['language'], value.attributes['script'], value.attributes['region'])
	}
	return parse_locale(value.as_string())
}

fn locale_attribute(args []ruby.Value, name string) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('Nil', '')
	}
	value := args[0].attribute(name) or { '' }
	return if value.len > 0 {
		ruby.string_value(value)
	} else {
		ruby.object_value('Nil', '')
	}
}
