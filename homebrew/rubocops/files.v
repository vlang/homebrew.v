module rubocops

import ruby
import os

// Translated from Homebrew/brew `rubocops/files.rb`.
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

fn file_permission_problem_value(problem FilePermissionProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'actual':  problem.actual.str()
		'wanted':  problem.wanted
		'path':    problem.path
		'message': problem.message
	})
}
