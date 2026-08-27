module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/caveats.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(_formula_nodes)` at line 42.
pub fn ruby_caveats_l42_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module FormulaAudit
// 9:       # This cop ensures that caveats don't have problematic text or logic.
// 10:       #
// 11:       # ### Example
// 12:       #
// 13:       # ```ruby
// 14:       # # bad
// 15:       # def caveats
// 16:       #   if File.exist?("/etc/issue")
// 17:       #     "This caveat only when file exists that won't work with JSON API."
// 18:       #   end
// 19:       # end
// 20:       #
// 21:       # # good
// 22:       # def caveats
// 23:       #   "This caveat always works regardless of the JSON API."
// 24:       # end
// 25:       #
// 26:       # # bad
// 27:       # def caveats
// 28:       #   <<~EOS
// 29:       #     Use `setuid` to allow running the executable by non-root users.
// 30:       #   EOS
// 31:       # end
// 32:       #
// 33:       # # good
// 34:       # def caveats
// 35:       #   <<~EOS
// 36:       #     Use `sudo` to run the executable.
// 37:       #   EOS
// 38:       # end
// 39:       # ```
// 40:       class Caveats < FormulaCop
// 41:         sig { override.params(_formula_nodes: FormulaNodes).void }
// 42:         def audit_formula(_formula_nodes)
// 43:           caveats_strings.each do |n|
// 44:             if regex_match_group(n, /\bsetuid\b/i)
// 45:               problem "Instead of recommending `setuid` in the caveats, suggest `sudo`."
// 46:             end
// 47:
// 48:             problem "Don't use ANSI escape codes in the caveats." if regex_match_group(n, /\e/)
// 49:           end
// 50:
// 51:           return if formula_tap != "homebrew-core"
// 52:
// 53:           # Forbid dynamic logic in caveats (only if/else/unless)
// 54:           caveats_method = find_method_def(@body, :caveats)
// 55:           return unless caveats_method
// 56:
// 57:           dynamic_nodes = caveats_method.each_descendant.select do |descendant|
// 58:             descendant.type == :if
// 59:           end
// 60:           dynamic_nodes.each do |node|
// 61:             @offensive_node = node
// 62:             problem "Don't use dynamic logic (if/else/unless) in caveats."
// 63:           end
// 64:         end
// 65:       end
// 66:     end
// 67:   end
// 68: end
