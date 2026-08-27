module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/checksum.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 12.
pub fn ruby_checksum_l12_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_sha256(checksum)` at line 27.
pub fn ruby_checksum_l27_d2_audit_sha256(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_sha256', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 50.
pub fn ruby_checksum_l50_d3_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # This cop makes sure that deprecated checksums are not used.
// 10:       class Checksum < FormulaCop
// 11:         sig { override.params(formula_nodes: FormulaNodes).void }
// 12:         def audit_formula(formula_nodes)
// 13:           body_node = formula_nodes.body_node
// 14:
// 15:           problem "MD5 checksums are deprecated, please use SHA-256" if method_called_ever?(body_node, :md5)
// 16:
// 17:           problem "SHA1 checksums are deprecated, please use SHA-256" if method_called_ever?(body_node, :sha1)
// 18:
// 19:           sha256_calls = find_every_method_call_by_name(body_node, :sha256)
// 20:           sha256_calls.each do |sha256_call|
// 21:             sha256_node = get_checksum_node(sha256_call)
// 22:             audit_sha256(sha256_node)
// 23:           end
// 24:         end
// 25:
// 26:         sig { params(checksum: T.nilable(RuboCop::AST::Node)).void }
// 27:         def audit_sha256(checksum)
// 28:           return if checksum.nil?
// 29:
// 30:           if regex_match_group(checksum, /^$/)
// 31:             problem "`sha256` is empty"
// 32:             return
// 33:           end
// 34:
// 35:           if string_content(checksum).size != 64 && regex_match_group(checksum, /^\w*$/)
// 36:             problem "`sha256` should be 64 characters"
// 37:           end
// 38:
// 39:           return unless regex_match_group(checksum, /[^a-f0-9]+/i)
// 40:
// 41:           add_offense(T.must(@offensive_source_range), message: "`sha256` contains invalid characters")
// 42:         end
// 43:       end
// 44:
// 45:       # This cop makes sure that checksum strings are lowercase.
// 46:       class ChecksumCase < FormulaCop
// 47:         extend AutoCorrector
// 48:
// 49:         sig { override.params(formula_nodes: FormulaNodes).void }
// 50:         def audit_formula(formula_nodes)
// 51:           sha256_calls = find_every_method_call_by_name(formula_nodes.body_node, :sha256)
// 52:           sha256_calls.each do |sha256_call|
// 53:             checksum = get_checksum_node(sha256_call)
// 54:             next if checksum.nil?
// 55:             next unless regex_match_group(checksum, /[A-F]+/)
// 56:
// 57:             add_offense(@offensive_source_range, message: "`sha256` should be lowercase") do |corrector|
// 58:               correction = T.must(@offensive_node).source.downcase
// 59:               corrector.insert_before(T.must(@offensive_node).source_range, correction)
// 60:               corrector.remove(T.must(@offensive_node).source_range)
// 61:             end
// 62:           end
// 63:         end
// 64:       end
// 65:     end
// 66:   end
// 67: end
