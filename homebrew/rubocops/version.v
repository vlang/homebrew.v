module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/version.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct VersionAuditOffense {
pub:
	begin_pos int
	end_pos   int
	version   string
	message   string
}

fn version_string_node(source string) ?VersionAuditOffense {
	mut offset := 0
	for line in source.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.starts_with('version ') {
			indent := line.index('version') or { 0 }
			remainder := trimmed['version '.len..].trim_space()
			if remainder.len >= 2 && remainder[0] in [`'`, `"`] && remainder[remainder.len - 1] == remainder[0] {
				return VersionAuditOffense{
					begin_pos: offset + indent
					end_pos: offset + line.len
					version: remainder[1..remainder.len - 1]
				}
			}
		}
		offset += line.len + 1
	}
	return none
}

pub fn audit_formula_version(source string) []VersionAuditOffense {
	node := version_string_node(source) or { return [] }
	mut offenses := []VersionAuditOffense{}
	if node.version == '' {
		offenses << VersionAuditOffense{
			...node
			message: 'Version is set to an empty string'
		}
	}
	if node.version.starts_with('v') {
		offenses << VersionAuditOffense{
			...node
			message: "Version ${node.version} should not have a leading 'v'"
		}
	}
	underscore := node.version.last_index('_') or { -1 }
	if underscore >= 0 && underscore + 1 < node.version.len && node.version[underscore + 1..].bytes().all(it.is_digit()) {
		offenses << VersionAuditOffense{
			...node
			message: 'Version ${node.version} should not end with an underline and a number'
		}
	}
	return offenses
}

// Ruby method `audit_formula(formula_nodes)` at line 12.
pub fn ruby_version_l12_d1_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_formula_version(source).map(ruby.structured_value('RuboCop::Cop::Offense', it.message, {
		'message':   it.message
		'begin_pos': it.begin_pos.str()
		'end_pos':   it.end_pos.str()
		'version':   it.version
	})))
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
// 9:       # This cop makes sure that a `version` is in the correct format.
// 10:       class Version < FormulaCop
// 11:         sig { override.params(formula_nodes: FormulaNodes).void }
// 12:         def audit_formula(formula_nodes)
// 13:           version_node = find_node_method_by_name(formula_nodes.body_node, :version)
// 14:           return unless version_node
// 15:
// 16:           version = string_content(parameters(version_node).fetch(0))
// 17:
// 18:           problem "Version is set to an empty string" if version.empty?
// 19:
// 20:           problem "Version #{version} should not have a leading 'v'" if version.start_with?("v")
// 21:
// 22:           return unless version.match?(/_\d+$/)
// 23:
// 24:           problem "Version #{version} should not end with an underline and a number"
// 25:         end
// 26:       end
// 27:     end
// 28:   end
// 29: end
