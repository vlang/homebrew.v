module main

import os

struct AuditTotals {
mut:
	files        int
	source_lines int
	definitions  int
	markers      int
	functions    int
	stubs        int
	errors       []string
}

fn main() {
	if os.args.len != 3 && os.args.len != 4 {
		eprintln('usage: audit_translation <Ruby source root> <V destination root> [manifest]')
		exit(2)
	}
	source_root := os.real_path(os.args[1])
	destination_root := os.real_path(os.args[2])
	mut totals := AuditTotals{}
	mut source_files := if os.args.len == 4 {
		manifest_source_files(source_root, os.args[3])
	} else {
		os.walk_ext(source_root, '.rb')
	}
	source_files.sort()
	for source_path in source_files {
		audit_file(source_root, source_path, destination_root, mut totals)
	}
	if totals.errors.len > 0 {
		for problem in totals.errors {
			eprintln(problem)
		}
		eprintln('translation audit failed with ${totals.errors.len} error(s)')
		exit(1)
	}
	println('audited ${totals.files} files, ${totals.source_lines} source lines, ${totals.definitions} explicit defs, ${totals.markers} translation markers, ${totals.functions} V functions, ${totals.stubs} explicit stubs')
}

fn manifest_source_files(source_root string, manifest string) []string {
	mut files := []string{}
	for line in os.read_lines(manifest) or { panic(err) } {
		relative_path := line.trim_space()
		if relative_path != '' && !relative_path.starts_with('#') {
			files << os.join_path(source_root, relative_path)
		}
	}
	return files
}

fn audit_file(source_root string, source_path string, destination_root string, mut totals AuditTotals) {
	relative_path := source_path.all_after('${source_root}/')
	destination_path := os.join_path(destination_root, v_destination_relative_path(relative_path))
	if !os.exists(destination_path) {
		totals.errors << '${relative_path}: missing V translation'
		return
	}
	source_lines := os.read_lines(source_path) or {
		totals.errors << '${relative_path}: cannot read Ruby source: ${err}'
		return
	}
	translated := os.read_file(destination_path) or {
		totals.errors << '${relative_path}: cannot read V translation: ${err}'
		return
	}
	totals.files++
	totals.source_lines += source_lines.len
	totals.stubs += translated.count('ruby.unimplemented_fn(')
	translated_lines := translated.split_into_lines()
	marker_index := translated_lines.index('// Original Ruby source (line-for-line):')
	if marker_index < 0 {
		totals.errors << '${relative_path}: missing retained-source marker'
		return
	}
	translation_lines := translated_lines[..marker_index]
	file_markers := translation_lines.filter(it.starts_with('// Ruby ')).len
	file_functions := translation_lines.filter(it.starts_with('pub fn ruby_')).len
	totals.markers += file_markers
	totals.functions += file_functions
	if file_markers != file_functions {
		totals.errors << '${relative_path}: ${file_markers} translation markers but ${file_functions} V functions'
	}
	for index, source_line in source_lines {
		line_number := index + 1
		retained_index := marker_index + line_number
		retained_line := '// ${line_number}: ${source_line}'.trim_right(' \t')
		if retained_index >= translated_lines.len
			|| translated_lines[retained_index].trim_right(' \t') != retained_line {
			totals.errors << '${relative_path}:${line_number}: source line is not retained'
		}
		trimmed := source_line.trim_space()
		method_prefix := ruby_method_prefix(trimmed)
		if method_prefix != '' {
			header := trimmed.all_after(method_prefix).trim_space()
			marker := '// Ruby method `${header}` at line ${line_number}.'
			totals.definitions++
			if !translated.contains(marker) {
				totals.errors << '${relative_path}:${line_number}: missing method translation marker'
			}
		} else if is_generated_definition_line(trimmed)
			&& !translation_lines.any(it.ends_with(' at line ${line_number}.')) {
			totals.errors << '${relative_path}:${line_number}: missing generated-method translation marker'
		}
	}
}

fn ruby_method_prefix(line string) string {
	for prefix in ['def ', 'def\t', 'private def ', 'protected def ', 'public def ',
		'private_class_method def ', 'public_class_method def ', 'module_function def '] {
		if line.starts_with(prefix) {
			return prefix
		}
	}
	return ''
}

fn is_generated_definition_line(line string) bool {
	if line == '' || line.starts_with('#') {
		return false
	}
	for construct in ['define_method', 'define_singleton_method', 'attr_reader', 'attr_writer',
		'attr_accessor', 'attr_atomic', 'attr_volatile', 'alias_method'] {
		if line.contains(construct) {
			return true
		}
	}
	if line.starts_with('alias ') {
		return true
	}
	for construct in ['delegate', 'def_delegator', 'def_delegators', 'def_instance_delegator',
		'def_instance_delegators', 'def_node_matcher', 'def_node_search', 'matcher', 'alias_matcher',
		'let', 'let!', 'subject', 'subject!', 'it', 'specify', 'example'] {
		if (line.starts_with('${construct} ') || line.starts_with('${construct}('))
			&& !line.all_after(construct).trim_space().starts_with('=') {
			return true
		}
	}
	return false
}

fn without_rb_suffix(path string) string {
	if path.ends_with('.rb') {
		return path[..path.len - 3]
	}
	return path
}

fn v_destination_relative_path(relative_path string) string {
	mut components := relative_path.split('/')
	for index in 0 .. components.len - 1 {
		components[index] = components[index].to_lower()
	}
	mut translated_path := without_rb_suffix(components.join('/'))
	if translated_path.ends_with('_test') {
		translated_path += '_ruby'
	}
	return translated_path + '.v'
}
