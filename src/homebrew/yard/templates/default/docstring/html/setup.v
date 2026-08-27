module html

import brew_runtime

// Translated from Homebrew/brew `yard/templates/default/docstring/html/setup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `init` at line 7.
pub fn ruby_setup_l7_d1_init(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('init', ...args)
}

// Ruby method `internal` at line 19.
pub fn ruby_setup_l19_d2_internal(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('internal', ...args)
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
