module github

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
