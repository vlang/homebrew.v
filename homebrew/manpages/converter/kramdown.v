module converter

// Translated from Homebrew/brew `manpages/converter/kramdown.rb`.
// The original source is retained below until every stub has a typed V body.

// ConverterElement is the subset of a Kramdown element used by Homebrew's two
// converter overrides. Keeping the tree typed also lets the inherited
// converter operations be represented directly instead of hidden behind a
// generic Ruby-value boundary.
pub struct ConverterElement {
pub:
	typ      string
	value    string
	attr     map[string]string
	level    int
	raw_text string
	children []ConverterElement
}

pub struct KramdownOptions {
pub:
	line_width int
}

pub struct KramdownConverter {
pub:
	root    ConverterElement
	options KramdownOptions
pub mut:
	link_references []string
}

fn kramdown_title(title string) string {
	if title.len == 0 {
		return ''
	}
	return ' "${title.replace('"', '&quot;')}"'
}

fn kramdown_inner(mut state KramdownConverter, element ConverterElement, options KramdownOptions) string {
	if element.children.len == 0 {
		return element.value
	}
	mut result := ''
	for child in element.children {
		result += match child.typ {
			'variable' { ruby_kramdown_l17_d2_convert_variable(child, options) }
			'a' { ruby_kramdown_l22_d3_convert_a(mut state, child, options) }
			else { kramdown_inner(mut state, child, options) }
		}
	}
	return result
}

fn kramdown_base_link(mut state KramdownConverter, element ConverterElement, text string) string {
	href := element.attr['href'] or { '' }
	if href.len == 0 {
		return '[${text}]()'
	}
	if href.starts_with('http') || href.starts_with('ftp') || href.count('(') + href.count(')') > 0 {
		mut index := -1
		for reference_index, reference in state.link_references {
			if reference == href {
				index = reference_index
				break
			}
		}
		if index < 0 {
			state.link_references << href
			index = state.link_references.len - 1
		}
		return '[${text}][${index + 1}]'
	}
	return '[${text}](${href}${kramdown_title(element.attr['title'] or { '' })})'
}

// Ruby method `initialize(root, options)` at line 12.
pub fn ruby_kramdown_l12_d1_initialize(root ConverterElement, options KramdownOptions) KramdownConverter {
	// Ruby's merge makes Homebrew's width override any caller-supplied value.
	return KramdownConverter{
		root: root
		options: KramdownOptions{
			...options
			line_width: 80
		}
	}
}

// Ruby method `convert_variable(element, _options)` at line 17.
pub fn ruby_kramdown_l17_d2_convert_variable(element ConverterElement, _options KramdownOptions) string {
	return '*`${element.value}`*'
}

// Ruby method `convert_a(element, options)` at line 22.
pub fn ruby_kramdown_l22_d3_convert_a(mut state KramdownConverter, element ConverterElement, options KramdownOptions) string {
	text := kramdown_inner(mut state, element, options)
	if element.attr['href'] or { '' } == text {
		// Don't duplicate the URL if the link text is the same as the URL.
		return '<${text}>'
	}
	return kramdown_base_link(mut state, element, text)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "kramdown/converter/kramdown"
// 5:
// 6: module Homebrew
// 7:   module Manpages
// 8:     module Converter
// 9:       # Converts our Kramdown-like input to pure Kramdown.
// 10:       class Kramdown < ::Kramdown::Converter::Kramdown
// 11:         sig { override.params(root: ::Kramdown::Element, options: T::Hash[Symbol, T.untyped]).void }
// 12:         def initialize(root, options)
// 13:           super(root, options.merge(line_width: 80))
// 14:         end
// 15:
// 16:         sig { params(element: ::Kramdown::Element, _options: T::Hash[Symbol, T.untyped]).returns(String) }
// 17:         def convert_variable(element, _options)
// 18:           "*`#{element.value}`*"
// 19:         end
// 20:
// 21:         sig { override.params(element: ::Kramdown::Element, options: T::Hash[Symbol, T.untyped]).returns(String) }
// 22:         def convert_a(element, options)
// 23:           text = inner(element, options)
// 24:           if element.attr["href"] == text
// 25:             # Don't duplicate the URL if the link text is the same as the URL.
// 26:             "<#{text}>"
// 27:           else
// 28:             super
// 29:           end
// 30:         end
// 31:       end
// 32:     end
// 33:   end
// 34: end
