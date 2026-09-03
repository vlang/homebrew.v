module converter

import time

// Translated from Homebrew/brew `manpages/converter/roff.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `convert_header(element, options)` at line 14.
pub fn ruby_roff_l14_d1_convert_header(element ConverterElement, options RoffOptions) RoffHeaderResult {
	if element.level == 1 {
		date_label := if options.date_label.len > 0 {
			options.date_label
		} else {
			roff_month_year()
		}
		mut attributes := element.attr.clone()
		attributes['data-date'] = date_label
		attributes['data-extra'] = 'Homebrew'
		updated := ConverterElement{
			typ: element.typ
			value: element.value
			attr: attributes
			level: element.level
			raw_text: element.raw_text
			children: element.children.clone()
		}
		return RoffHeaderResult{
			element: updated
			output: options.result + roff_base_top_header(updated, date_label)
		}
	}

	result := roff_inner(element).replace(' [', ' \\fR[') // make args not bold
	macro_name := if element.level == 2 { 'SH' } else { 'SS' }
	return RoffHeaderResult{
		element: element
		output: options.result + roff_macro(macro_name, roff_quote(result))
	}
}

// Ruby method `convert_variable(element, options)` at line 33.
pub fn ruby_roff_l33_d2_convert_variable(element ConverterElement, options RoffOptions) string {
	return options.result + '\\fI${roff_escape(element.value)}\\fP'
}

// Ruby method `convert_a(element, options)` at line 38.
pub fn ruby_roff_l38_d3_convert_a(element ConverterElement, options RoffOptions) string {
	href := element.attr['href'] or { '' }
	if href.starts_with('#') {
		// Hide internal links - just make them italicised
		return options.result + '\\fI${roff_inner(element)}\\fP'
	}

	mut result := roff_newline(options.result)
	if element.children.len == 1 && element.children[0].typ == 'text'
		&& href == element.children[0].value {
		result += roff_macro('UR', roff_escape(href))
		result += roff_macro('UE')
	} else if href.starts_with('mailto:') {
		result += roff_macro('MT', roff_escape(href['mailto:'.len..]))
		result += roff_macro('UE')
	} else {
		result += roff_macro('UR', roff_escape(href))
		result += roff_inner(element)
		result = roff_newline(result)
		result += roff_macro('UE')
	}

	// Remove the space after links if the next character is not a space.
	if result.ends_with('.UE\n') {
		if next_element := options.next_element {
			if next_element.typ == 'text' && next_element.value.len > 0
				&& !next_element.value[0].is_space() {
				result = result.trim_right('\n') + ' '
			}
		}
	}
	return result
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "kramdown/converter/man"
// 5:
// 6: module Homebrew
// 7:   module Manpages
// 8:     module Converter
// 9:       # Converts our Kramdown-like input to roff.
// 10:       class Roff < ::Kramdown::Converter::Man
// 11:         # Override that adds Homebrew metadata for the top level header
// 12:         # and doesn't escape the text inside subheaders.
// 13:         sig { override.params(element: ::Kramdown::Element, options: T::Hash[Symbol, T.untyped]).void }
// 14:         def convert_header(element, options)
// 15:           if element.options[:level] == 1
// 16:             element.attr["data-date"] = Date.today.strftime("%B %Y")
// 17:             element.attr["data-extra"] = "Homebrew"
// 18:             return super
// 19:           end
// 20:
// 21:           result = +""
// 22:           inner(element, options.merge(result:))
// 23:           result.gsub!(" [", ' \fR[') # make args not bold
// 24:
// 25:           options[:result] << if element.options[:level] == 2
// 26:             macro("SH", quote(result))
// 27:           else
// 28:             macro("SS", quote(result))
// 29:           end
// 30:         end
// 31:
// 32:         sig { params(element: ::Kramdown::Element, options: T::Hash[Symbol, T.untyped]).void }
// 33:         def convert_variable(element, options)
// 34:           options[:result] << "\\fI#{escape(element.value)}\\fP"
// 35:         end
// 36:
// 37:         sig { override.params(element: ::Kramdown::Element, options: T::Hash[Symbol, T.untyped]).void }
// 38:         def convert_a(element, options)
// 39:           if element.attr["href"].chr == "#"
// 40:             # Hide internal links - just make them italicised
// 41:             convert_em(element, options)
// 42:           else
// 43:             super
// 44:             # Remove the space after links if the next character is not a space
// 45:             if options[:result].end_with?(".UE\n") &&
// 46:                (next_element = options[:next]) &&
// 47:                next_element.type == :text &&
// 48:                next_element.value.chr.present? # i.e. not a space character
// 49:               options[:result].chomp!
// 50:               options[:result] << " "
// 51:             end
// 52:           end
// 53:         end
// 54:       end
// 55:     end
// 56:   end
// 57: end
