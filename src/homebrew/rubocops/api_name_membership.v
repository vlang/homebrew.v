module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/api_name_membership.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :api_name_membership?, <<~PATTERN` at line 34.
pub fn ruby_api_name_membership_l34_d1_api_name_membership(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_name_membership?', ...args)
}

// Ruby method `on_send(node)` at line 42.
pub fn ruby_api_name_membership_l42_d2_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Enforces the use of `Homebrew::API.formula_name?`/`Homebrew::API.cask_token?`
// 8:       # over membership checks on `Homebrew::API.formula_names`/`Homebrew::API.cask_tokens`,
// 9:       # which allocate and linearly scan an array of every name in the API.
// 10:       #
// 11:       # ### Example
// 12:       #
// 13:       # ```ruby
// 14:       # # bad
// 15:       # Homebrew::API.formula_names.include?(name)
// 16:       # Homebrew::API.cask_tokens.exclude?(token)
// 17:       #
// 18:       # # good
// 19:       # Homebrew::API.formula_name?(name)
// 20:       # !Homebrew::API.cask_token?(token)
// 21:       # ```
// 22:       class ApiNameMembership < Base
// 23:         extend AutoCorrector
// 24:
// 25:         MSG = "Use `Homebrew::API.%<predicate>s` instead of scanning `Homebrew::API.%<list>s`."
// 26:
// 27:         RESTRICT_ON_SEND = [:include?, :exclude?].freeze
// 28:
// 29:         PREDICATES = T.let({
// 30:           formula_names: "formula_name?",
// 31:           cask_tokens:   "cask_token?",
// 32:         }.freeze, T::Hash[Symbol, String])
// 33:
// 34:         def_node_matcher :api_name_membership?, <<~PATTERN
// 35:           (send
// 36:             (send
// 37:               $(const (const {nil? cbase} :Homebrew) :API) ${:formula_names :cask_tokens})
// 38:             {:include? :exclude?} $_)
// 39:         PATTERN
// 40:
// 41:         sig { params(node: RuboCop::AST::SendNode).void }
// 42:         def on_send(node)
// 43:           return unless (api, list, arg = api_name_membership?(node))
// 44:
// 45:           predicate = PREDICATES.fetch(list)
// 46:           add_offense(node, message: format(MSG, predicate:, list:)) do |corrector|
// 47:             negation = (node.method_name == :exclude?) ? "!" : ""
// 48:             corrector.replace(node, "#{negation}#{api.source}.#{predicate}(#{arg.source})")
// 49:           end
// 50:         end
// 51:       end
// 52:     end
// 53:   end
// 54: end
