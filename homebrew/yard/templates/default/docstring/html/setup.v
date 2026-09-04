module html

import ruby

// Translated from Homebrew/brew `yard/templates/default/docstring/html/setup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `init` at line 7.
pub fn ruby_setup_l7_d1_init(args ...ruby.Value) ruby.Value {
	sections := if args.len > 0 { args[0].as_string_array() or { [] } } else { [] }
	return ruby.string_array_value(initialize_docstring_html_sections(sections))
}

// Ruby method `internal` at line 19.
pub fn ruby_setup_l19_d2_internal(args ...ruby.Value) ruby.Value {
	api := if args.len > 0 { args[0].as_string() } else { '' }
	template := if args.len > 1 { args[1].as_string() } else { 'internal' }
	return if rendered := render_internal_docstring(api, template) {
		ruby.string_value(rendered)
	} else {
		ruby.object_value('NilClass', '')
	}
}

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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # This follows the docs at https://github.com/lsegal/yard/blob/main/docs/Templates.md#setuprb
// 5: # rubocop:disable Style/TopLevelMethodDefinition
// 6: sig { void }
// 7: def init
// 8:   # `sorbet` is available transitively through the `yard-sorbet` plugin, but we're
// 9:   # outside of the standalone sorbet config, so `checked` is enabled by default
// 10:   T.bind(self, T.all(T::Class[T.anything], YARD::Templates::Template), checked: false)
// 11:   super
// 12:
// 13:   return if sections.empty?
// 14:
// 15:   sections[:index].place(:internal).before(:private)
// 16: end
// 17:
// 18: sig { returns(T.nilable(String)) }
// 19: def internal
// 20:   T.bind(self, YARD::Templates::Template, checked: false)
// 21:   erb(:internal) if object.has_tag?(:api) && object.tag(:api).text == "internal"
// 22: end
// 23: # rubocop:enable Style/TopLevelMethodDefinition
