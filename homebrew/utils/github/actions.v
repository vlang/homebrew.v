module github

import ruby
import homebrew.utils
import os

// Translated from Homebrew/brew `utils/github/actions.rb`.

pub struct ActionsAnnotationOptions {
pub:
	file           string
	title          string
	line           int
	has_line       bool
	end_line       int
	has_end_line   bool
	column         int
	has_column     bool
	end_column     int
	has_end_column bool
	workspace      string
}

pub struct ActionsAnnotation {
pub:
	kind    string
	message string
	options ActionsAnnotationOptions
}

pub fn actions_escape(value string) string {
	return value.replace('%', '%25').replace('\n', '%0A').replace('\r', '%0D')
}

fn actions_relative_path(existing_path string, workspace string) string {
	path := os.real_path(existing_path)
	root := os.real_path(if workspace == '' { os.getwd() } else { workspace })
	path_parts := os.norm_path(path).split(os.path_separator).filter(it != '')
	root_parts := os.norm_path(root).split(os.path_separator).filter(it != '')
	mut common := 0
	for common < path_parts.len && common < root_parts.len
		&& path_parts[common] == root_parts[common] {
		common++
	}
	mut parts := []string{}
	for _ in common .. root_parts.len {
		parts << '..'
	}
	parts << path_parts[common..]
	return if parts.len == 0 { '.' } else { parts.join(os.path_separator) }
}

pub fn actions_path_relative_to_workspace(path string, workspace string) string {
	if !os.exists(path) {
		return path
	}
	return actions_relative_path(path, workspace)
}

pub fn new_actions_annotation(kind string, message string,
	options ActionsAnnotationOptions) !ActionsAnnotation {
	normalized_kind := kind.trim_left(':')
	if normalized_kind !in ['notice', 'warning', 'error'] {
		return error('Unsupported type: :${normalized_kind}')
	}
	if options.title != '' && options.title.contains('::') {
		return error('`title` must not contain `::`')
	}
	return ActionsAnnotation{
		kind: normalized_kind
		message: utils.tty_strip_ansi(message)
		options: ActionsAnnotationOptions{
			...options
			file: if options.file == '' {
				''
			} else {
				actions_path_relative_to_workspace(options.file, options.workspace)
			}
			title: utils.tty_strip_ansi(options.title)
		}
	}
}

pub fn (annotation ActionsAnnotation) str() string {
	mut metadata := annotation.kind
	if annotation.options.file != '' {
		metadata += ' file=${actions_escape(annotation.options.file)}'
		if annotation.options.has_line {
			metadata += ',line=${annotation.options.line}'
			if annotation.options.has_end_line {
				metadata += ',endLine=${annotation.options.end_line}'
			}
			if annotation.options.has_column {
				metadata += ',col=${annotation.options.column}'
				if annotation.options.has_end_column {
					metadata += ',endColumn=${annotation.options.end_column}'
				}
			}
		}
	}
	if annotation.options.title != '' {
		metadata += if annotation.options.file != '' { ',' } else { ' ' }
		metadata += 'title=${actions_escape(annotation.options.title)}'
	}
	if metadata.ends_with(':') {
		metadata += ' '
	}
	return '::${metadata}::${actions_escape(annotation.message)}'
}

pub fn (annotation ActionsAnnotation) relevant() bool {
	if annotation.options.file == '' {
		return true
	}
	return !annotation.options.file.starts_with('../') && annotation.options.file != '..'
}

fn actions_annotation_value(annotation ActionsAnnotation) ruby.Value {
	return ruby.structured_value('GitHub::Actions::Annotation', annotation.str(), {
		'kind':           annotation.kind
		'message':        annotation.message
		'file':           annotation.options.file
		'title':          annotation.options.title
		'line':           annotation.options.line.str()
		'has_line':       annotation.options.has_line.str()
		'end_line':       annotation.options.end_line.str()
		'has_end_line':   annotation.options.has_end_line.str()
		'column':         annotation.options.column.str()
		'has_column':     annotation.options.has_column.str()
		'end_column':     annotation.options.end_column.str()
		'has_end_column': annotation.options.has_end_column.str()
	})
}

fn actions_annotation_from_value(value ruby.Value) ActionsAnnotation {
	return ActionsAnnotation{
		kind: value.attributes['kind']
		message: value.attributes['message']
		options: ActionsAnnotationOptions{
			file: value.attributes['file']
			title: value.attributes['title']
			line: value.attributes['line'].int()
			has_line: value.attributes['has_line'] == 'true'
			end_line: value.attributes['end_line'].int()
			has_end_line: value.attributes['has_end_line'] == 'true'
			column: value.attributes['column'].int()
			has_column: value.attributes['has_column'] == 'true'
			end_column: value.attributes['end_column'].int()
			has_end_column: value.attributes['has_end_column'] == 'true'
		}
	}
}

fn actions_optional_string(args []ruby.Value, index int) string {
	return if index < args.len && args[index].type_name !in ['NilClass', 'Nil'] {
		args[index].as_string()
	} else {
		''
	}
}

fn actions_optional_int(args []ruby.Value, index int) (int, bool) {
	if index >= args.len || args[index].type_name in ['NilClass', 'Nil'] {
		return 0, false
	}
	return int(args[index].as_int() or { 0 }), true
}
