module html

import ruby

// Translated from Homebrew/brew `yard/templates/default/docstring/html/setup.rb`.

pub fn initialize_docstring_html_sections(sections []string) []string {
	if sections.len == 0 || 'internal' in sections {
		return sections.clone()
	}
	mut initialized := sections.clone()
	private_index := initialized.index('private')
	if private_index >= 0 {
		initialized.insert(private_index, 'internal')
	} else {
		initialized << 'internal'
	}
	return initialized
}

pub fn render_internal_docstring(api string, template string) ?string {
	if api != 'internal' {
		return none
	}
	return template
}
