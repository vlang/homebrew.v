module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/files.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 12.
pub fn ruby_files_l12_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # This cop makes sure that a formula's file permissions are correct.
// 10:       class Files < FormulaCop
// 11:         sig { override.params(formula_nodes: FormulaNodes).void }
// 12:         def audit_formula(formula_nodes)
// 13:           return unless file_path
// 14:
// 15:           # Codespaces routinely screws up all permissions so don't complain there.
// 16:           return if ENV["CODESPACES"] || ENV["HOMEBREW_CODESPACES"]
// 17:
// 18:           offending_node(formula_nodes.node)
// 19:           actual_mode = File.stat(file_path).mode
// 20:           # Check that the file is world-readable.
// 21:           if actual_mode & 0444 != 0444
// 22:             problem format("Incorrect file permissions (%03<actual>o): chmod %<wanted>s %<path>s",
// 23:                            actual: actual_mode & 0777,
// 24:                            wanted: "a+r",
// 25:                            path:   file_path)
// 26:           end
// 27:           # Check that the file is user-writeable.
// 28:           if actual_mode & 0200 != 0200
// 29:             problem format("Incorrect file permissions (%03<actual>o): chmod %<wanted>s %<path>s",
// 30:                            actual: actual_mode & 0777,
// 31:                            wanted: "u+w",
// 32:                            path:   file_path)
// 33:           end
// 34:           # Check that the file is *not* other-writeable.
// 35:           return if actual_mode & 0002 != 002
// 36:
// 37:           problem format("Incorrect file permissions (%03<actual>o): chmod %<wanted>s %<path>s",
// 38:                          actual: actual_mode & 0777,
// 39:                          wanted: "o-w",
// 40:                          path:   file_path)
// 41:         end
// 42:       end
// 43:     end
// 44:   end
// 45: end
