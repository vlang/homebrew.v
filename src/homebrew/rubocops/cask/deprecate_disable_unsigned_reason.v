module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/deprecate_disable_unsigned_reason.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask_stanza_block(stanza_block)` at line 26.
pub fn ruby_deprecate_disable_unsigned_reason_l26_d1_on_cask_stanza_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask_stanza_block', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # This cop checks for use of `because: :unsigned` in `deprecate!`/`disable!`
// 8:       # and replaces it with the preferred `:fails_gatekeeper_check` reason.
// 9:       #
// 10:       # Example
// 11:       #   # bad
// 12:       #   deprecate! date: "2024-01-01", because: :unsigned
// 13:       #   disable! because: :unsigned
// 14:       #
// 15:       #   # good
// 16:       #   deprecate! date: "2024-01-01", because: :fails_gatekeeper_check
// 17:       #   disable! because: :fails_gatekeeper_check
// 18:       class DeprecateDisableUnsignedReason < Base
// 19:         include CaskHelp
// 20:         extend AutoCorrector
// 21:
// 22:         STANZAS_TO_CHECK = [:deprecate!, :disable!].freeze
// 23:         MESSAGE = "Use `:fails_gatekeeper_check` instead of `:unsigned` for deprecate!/disable! reason."
// 24:
// 25:         sig { override.params(stanza_block: RuboCop::Cask::AST::StanzaBlock).void }
// 26:         def on_cask_stanza_block(stanza_block)
// 27:           stanzas = stanza_block.stanzas.select { |s| STANZAS_TO_CHECK.include?(s.stanza_name) }
// 28:           stanzas.each do |stanza|
// 29:             stanza_node = T.cast(stanza.stanza_node, RuboCop::AST::SendNode)
// 30:             hash_node = stanza_node.last_argument
// 31:             next unless hash_node&.hash_type?
// 32:
// 33:             # find `because: :unsigned` pairs
// 34:             T.cast(hash_node, RuboCop::AST::HashNode).each_pair do |key_node, value_node|
// 35:               next if !key_node.sym_type? || key_node.value != :because
// 36:               next if !value_node.sym_type? || value_node.value != :unsigned
// 37:
// 38:               add_offense(value_node, message: MESSAGE) do |corrector|
// 39:                 corrector.replace(value_node.source_range, ":fails_gatekeeper_check")
// 40:               end
// 41:             end
// 42:           end
// 43:         end
// 44:       end
// 45:     end
// 46:   end
// 47: end
