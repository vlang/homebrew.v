module converter

// Translated from Homebrew/brew `manpages/converter/kramdown.rb`.

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
			'variable' { kramdown_convert_variable(child, options) }
			'a' { kramdown_convert_a(mut state, child, options) }
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

// Ruby method `convert_variable(element, _options)` at line 17.
pub fn kramdown_convert_variable(element ConverterElement, _options KramdownOptions) string {
	return '*`${element.value}`*'
}

// Ruby method `convert_a(element, options)` at line 22.
pub fn kramdown_convert_a(mut state KramdownConverter, element ConverterElement, options KramdownOptions) string {
	text := kramdown_inner(mut state, element, options)
	if element.attr['href'] or { '' } == text {
		// Don't duplicate the URL if the link text is the same as the URL.
		return '<${text}>'
	}
	return kramdown_base_link(mut state, element, text)
}
