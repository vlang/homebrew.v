module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/safe_navigation_with_blank.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :safe_navigation_blank_in_conditional?, <<~PATTERN` at line 35.
pub fn ruby_safe_navigation_with_blank_l35_d1_safe_navigation_blank_in_conditional(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('safe_navigation_blank_in_conditional?', ...args)
}

// Ruby method `on_if(node)` at line 40.
pub fn ruby_safe_navigation_with_blank_l40_d2_on_if(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_if', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks to make sure safe navigation isn't used with `blank?` in
// 8:       # a conditional.
// 9:       #
// 10:       # NOTE: While the safe navigation operator is generally a good idea, when
// 11:       #       checking `foo&.blank?` in a conditional, `foo` being `nil` will actually
// 12:       #       do the opposite of what the author intends:
// 13:       #
// 14:       #       ```ruby
// 15:       #       foo&.blank? #=> nil
// 16:       #       foo.blank? #=> true
// 17:       #       ```
// 18:       #
// 19:       # ### Example
// 20:       #
// 21:       # ```ruby
// 22:       # # bad
// 23:       # do_something if foo&.blank?
// 24:       # do_something unless foo&.blank?
// 25:       #
// 26:       # # good
// 27:       # do_something if foo.blank?
// 28:       # do_something unless foo.blank?
// 29:       # ```
// 30:       class SafeNavigationWithBlank < Base
// 31:         extend AutoCorrector
// 32:
// 33:         MSG = "Avoid calling `blank?` with the safe navigation operator in conditionals."
// 34:
// 35:         def_node_matcher :safe_navigation_blank_in_conditional?, <<~PATTERN
// 36:           (if $(csend ... :blank?) ...)
// 37:         PATTERN
// 38:
// 39:         sig { params(node: RuboCop::AST::IfNode).void }
// 40:         def on_if(node)
// 41:           return unless safe_navigation_blank_in_conditional?(node)
// 42:
// 43:           add_offense(node) do |corrector|
// 44:             corrector.replace(safe_navigation_blank_in_conditional?(node).location.dot, ".")
// 45:           end
// 46:         end
// 47:       end
// 48:     end
// 49:   end
// 50: end
