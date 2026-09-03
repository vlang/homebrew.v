module rubocops

import brew_runtime
import os

// Translated from Homebrew/brew `rubocops/files.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct FilePermissionProblem {
pub:
	actual  int
	wanted  string
	path    string
	message string
}

fn file_permission_octal(mode int) string {
	raw := '${mode & 0o777:o}'
	return '0'.repeat(if raw.len < 3 { 3 - raw.len } else { 0 }) + raw
}

pub fn audit_file_permission_mode(file_path string, actual_mode int) []FilePermissionProblem {
	mut problems := []FilePermissionProblem{}
	actual := actual_mode & 0o777
	if actual_mode & 0o444 != 0o444 {
		problems << FilePermissionProblem{
			actual: actual
			wanted: 'a+r'
			path: file_path
			message: 'Incorrect file permissions (${file_permission_octal(actual)}): chmod a+r ${file_path}'
		}
	}
	if actual_mode & 0o200 != 0o200 {
		problems << FilePermissionProblem{
			actual: actual
			wanted: 'u+w'
			path: file_path
			message: 'Incorrect file permissions (${file_permission_octal(actual)}): chmod u+w ${file_path}'
		}
	}
	if actual_mode & 0o002 == 0o002 {
		problems << FilePermissionProblem{
			actual: actual
			wanted: 'o-w'
			path: file_path
			message: 'Incorrect file permissions (${file_permission_octal(actual)}): chmod o-w ${file_path}'
		}
	}
	return problems
}

pub fn audit_formula_file_permissions(file_path string, codespaces bool) ![]FilePermissionProblem {
	if file_path == '' || codespaces {
		return []FilePermissionProblem{}
	}
	actual_mode := int(os.stat(file_path)!.get_mode().bitmask())
	return audit_file_permission_mode(file_path, actual_mode)
}

fn file_permission_problem_value(problem FilePermissionProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Problem', problem.message, {
		'actual':  problem.actual.str()
		'wanted':  problem.wanted
		'path':    problem.path
		'message': problem.message
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 12.
pub fn ruby_files_l12_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	file_path := if args.len > 0 { args[0].as_string() } else { '' }
	codespaces := os.getenv('CODESPACES') != '' || os.getenv('HOMEBREW_CODESPACES') != ''
	problems := audit_formula_file_permissions(file_path, codespaces) or {
		return brew_runtime.structured_value('Error', err.msg(), {
			'path': file_path
		})
	}
	return if problems.len == 0 {
		brew_runtime.array_value([]brew_runtime.Value{})
	} else {
		brew_runtime.array_value(problems.map(file_permission_problem_value(it)))
	}
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
