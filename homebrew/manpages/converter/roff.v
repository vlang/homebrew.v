module converter

import time

// Translated from Homebrew/brew `manpages/converter/roff.rb`.

pub struct RoffOptions {
pub:
	result       string
	next_element ?ConverterElement
	date_label   string
}

pub struct RoffHeaderResult {
pub:
	element ConverterElement
	output  string
}

fn roff_month_year() string {
	now := time.now()
	return '${time.long_months[now.month - 1]} ${now.year}'
}

fn roff_collapse_whitespace(value string) string {
	mut result := []u8{}
	mut in_whitespace := false
	for character in value.bytes() {
		if character.is_space() {
			if !in_whitespace {
				result << ` `
			}
			in_whitespace = true
		} else {
			result << character
			in_whitespace = false
		}
	}
	return result.bytestr()
}

fn roff_escape(value string) string {
	mut escaped := roff_collapse_whitespace(value).replace('\\', '\\e')
	if escaped.starts_with('.') {
		escaped = '\\&${escaped}'
	}
	mut result := ''
	for character in escaped.bytes() {
		if character in [`.`, `'`, `-`] {
			result += '\\'
		}
		result += character.ascii_str()
	}
	return result
}

fn roff_quote(value string) string {
	return '"${value.replace('"', '\\"')}"'
}

fn roff_macro(name string, arguments ...string) string {
	mut present := []string{}
	for argument in arguments {
		if argument.len > 0 {
			present << argument
		}
	}
	return if present.len == 0 { '.${name}\n' } else { '.${name} ${present.join(' ')}\n' }
}

fn roff_newline(value string) string {
	return if value.ends_with('\n') { value } else { '${value}\n' }
}

fn roff_inner(element ConverterElement) string {
	if element.children.len == 0 {
		return match element.typ {
			'variable' { '\\fI${roff_escape(element.value)}\\fP' }
			else { roff_escape(element.value) }
		}
	}
	mut result := ''
	for child in element.children {
		inner := roff_inner(child)
		result += match child.typ {
			'em' { '\\fI${inner}\\fP' }
			'strong' { '\\fB${inner}\\fP' }
			else { inner }
		}
	}
	return result
}

fn roff_title_parts(raw_text string) (string, string, string) {
	open := raw_text.index('(') or { -1 }
	if open > 0 {
		close_relative := raw_text[open + 1..].index(')') or { -1 }
		if close_relative >= 0 {
			close := open + 1 + close_relative
			section := raw_text[open + 1..close]
			if section.len > 0 && section[0].is_digit() {
				name := raw_text[..open].trim_space()
				remaining := raw_text[close + 1..].trim_space()
				description := if remaining.starts_with('-') {
					remaining.trim_left('-').trim_space()
				} else {
					''
				}
				return name, section, description
			}
		}
	}
	parts := raw_text.fields()
	if parts.len == 0 {
		return '', '', ''
	}
	return parts[0], '', raw_text.all_after(parts[0]).trim_space().trim_left('-').trim_space()
}

fn roff_base_top_header(element ConverterElement, date_label string) string {
	name, parsed_section, description := roff_title_parts(element.raw_text)
	if name.len == 0 {
		return ''
	}
	section := if parsed_section.len == 0 {
		element.attr['data-section'] or { '7' }
	} else {
		parsed_section
	}
	mut output := roff_macro('TH', roff_quote(roff_escape(name.to_upper())), roff_quote(section), roff_quote(date_label), roff_quote(roff_escape(element.attr['data-extra'] or { '' })))
	if description.len > 0 {
		output += roff_macro('SH', 'NAME')
		output += '${roff_escape(name + ' - ' + description)}\n'
	}
	return output
}
