module github

import brew_runtime
import homebrew.utils
import os

// Translated from Homebrew/brew `utils/github/actions.rb`.
// The original source is retained below until every stub has a typed V body.

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

fn actions_annotation_value(annotation ActionsAnnotation) brew_runtime.Value {
	return brew_runtime.structured_value('GitHub::Actions::Annotation', annotation.str(), {
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

fn actions_annotation_from_value(value brew_runtime.Value) ActionsAnnotation {
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

fn actions_optional_string(args []brew_runtime.Value, index int) string {
	return if index < args.len && args[index].type_name !in ['NilClass', 'Nil'] {
		args[index].as_string()
	} else {
		''
	}
}

fn actions_optional_int(args []brew_runtime.Value, index int) (int, bool) {
	if index >= args.len || args[index].type_name in ['NilClass', 'Nil'] {
		return 0, false
	}
	return int(args[index].as_int() or { 0 }), true
}

// Ruby method `self.escape(string)` at line 10.
pub fn ruby_actions_l10_d1_self_escape(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(actions_escape(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `self.env_set?` at line 18.
pub fn ruby_actions_l18_d2_self_env_set(args ...brew_runtime.Value) brew_runtime.Value {
	value := if args.len > 0 { args[0].as_string() } else { os.getenv('GITHUB_ACTIONS') }
	return brew_runtime.bool_value(value != '')
}

// Ruby method `self.puts_annotation_if_env_set!(type, message, file: nil, line: nil)` at line 29.
pub fn ruby_actions_l29_d3_self_puts_annotation_if_env_set(args ...brew_runtime.Value) brew_runtime.Value {
	tests_set := if args.len > 4 {
		args[4].as_bool() or { false }
	} else {
		os.getenv('HOMEBREW_TESTS') != ''
	}
	actions_set := if args.len > 5 {
		args[5].as_bool() or { false }
	} else {
		os.getenv('GITHUB_ACTIONS') != ''
	}
	if tests_set || !actions_set || args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	line, has_line := actions_optional_int(args, 3)
	annotation := new_actions_annotation(args[0].as_string(), args[1].as_string(), ActionsAnnotationOptions{
		file: actions_optional_string(args, 2)
		line: line
		has_line: has_line
	}) or { return brew_runtime.bool_value(false) }
	if annotation.kind == 'notice' {
		println(annotation.str())
	} else {
		eprintln(annotation.str())
	}
	return brew_runtime.bool_value(true)
}

// Ruby method `self.path_relative_to_workspace(path)` at line 45.
pub fn ruby_actions_l45_d4_self_path_relative_to_workspace(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	workspace := if args.len > 1 { args[1].as_string() } else { os.getenv('GITHUB_WORKSPACE') }
	return brew_runtime.object_value('Pathname', actions_path_relative_to_workspace(args[0].as_string(), workspace))
}

// Ruby method `initialize(type, message, file: nil, title: nil, line: nil, end_line: nil, column: nil, end_column: nil)` at line 65.
pub fn ruby_actions_l65_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'type and message are required')
	}
	line, has_line := actions_optional_int(args, 4)
	end_line, has_end_line := actions_optional_int(args, 5)
	column, has_column := actions_optional_int(args, 6)
	end_column, has_end_column := actions_optional_int(args, 7)
	annotation := new_actions_annotation(args[0].as_string(), args[1].as_string(), ActionsAnnotationOptions{
		file: actions_optional_string(args, 2)
		title: actions_optional_string(args, 3)
		line: line
		has_line: has_line
		end_line: end_line
		has_end_line: has_end_line
		column: column
		has_column: has_column
		end_column: end_column
		has_end_column: has_end_column
		workspace: if args.len > 8 { args[8].as_string() } else { os.getenv('GITHUB_WORKSPACE') }
	}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	return actions_annotation_value(annotation)
}

// Ruby method `to_s` at line 81.
pub fn ruby_actions_l81_d6_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value('')
	}
	return brew_runtime.string_value(actions_annotation_from_value(args[0]).str())
}

// Ruby method `relevant?` at line 109.
pub fn ruby_actions_l109_d7_relevant(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && actions_annotation_from_value(args[0]).relevant())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module GitHub
// 5:   # Helper functions for interacting with GitHub Actions.
// 6:   #
// 7:   # @api internal
// 8:   module Actions
// 9:     sig { params(string: String).returns(String) }
// 10:     def self.escape(string)
// 11:       # See https://github.community/t/set-output-truncates-multiline-strings/16852/3.
// 12:       string.gsub("%", "%25")
// 13:             .gsub("\n", "%0A")
// 14:             .gsub("\r", "%0D")
// 15:     end
// 16:
// 17:     sig { returns(T::Boolean) }
// 18:     def self.env_set?
// 19:       ENV.fetch("GITHUB_ACTIONS", false).present?
// 20:     end
// 21:
// 22:     sig {
// 23:       params(
// 24:         type: Symbol, message: String,
// 25:         file: T.nilable(T.any(String, Pathname)),
// 26:         line: T.nilable(Integer)
// 27:       ).returns(T::Boolean)
// 28:     }
// 29:     def self.puts_annotation_if_env_set!(type, message, file: nil, line: nil)
// 30:       # Don't print annotations during tests, too messy to handle these.
// 31:       return false if ENV.fetch("HOMEBREW_TESTS", false)
// 32:       return false unless env_set?
// 33:
// 34:       std = (type == :notice) ? $stdout : $stderr
// 35:       std.puts Annotation.new(type, message)
// 36:
// 37:       true
// 38:     end
// 39:
// 40:     # Helper class for formatting annotations on GitHub Actions.
// 41:     class Annotation
// 42:       ANNOTATION_TYPES = [:notice, :warning, :error].freeze
// 43:
// 44:       sig { params(path: T.any(String, Pathname)).returns(T.nilable(Pathname)) }
// 45:       def self.path_relative_to_workspace(path)
// 46:         workspace = Pathname(ENV.fetch("GITHUB_WORKSPACE", Dir.pwd)).realpath
// 47:         path = Pathname(path)
// 48:         return path unless path.exist?
// 49:
// 50:         path.realpath.relative_path_from(workspace)
// 51:       end
// 52:
// 53:       sig {
// 54:         params(
// 55:           type:       Symbol,
// 56:           message:    String,
// 57:           file:       T.nilable(T.any(String, Pathname)),
// 58:           title:      T.nilable(String),
// 59:           line:       T.nilable(Integer),
// 60:           end_line:   T.nilable(Integer),
// 61:           column:     T.nilable(Integer),
// 62:           end_column: T.nilable(Integer),
// 63:         ).void
// 64:       }
// 65:       def initialize(type, message, file: nil, title: nil, line: nil, end_line: nil, column: nil, end_column: nil)
// 66:         raise ArgumentError, "Unsupported type: #{type.inspect}" if ANNOTATION_TYPES.exclude?(type)
// 67:         raise ArgumentError, "`title` must not contain `::`" if title.present? && title.include?("::")
// 68:
// 69:         require "utils/tty"
// 70:         @type = type
// 71:         @message = T.let(Tty.strip_ansi(message), String)
// 72:         @file = T.let(self.class.path_relative_to_workspace(file), T.nilable(Pathname)) if file.present?
// 73:         @title = T.let(Tty.strip_ansi(title), String) if title
// 74:         @line = T.let(Integer(line), Integer) if line
// 75:         @end_line = T.let(Integer(end_line), Integer) if end_line
// 76:         @column = T.let(Integer(column), Integer) if column
// 77:         @end_column = T.let(Integer(end_column), Integer) if end_column
// 78:       end
// 79:
// 80:       sig { returns(String) }
// 81:       def to_s
// 82:         metadata = @type.to_s.dup
// 83:         if @file
// 84:           metadata << " file=#{Actions.escape(@file.to_s)}"
// 85:
// 86:           if @line
// 87:             metadata << ",line=#{@line}"
// 88:             metadata << ",endLine=#{@end_line}" if @end_line
// 89:
// 90:             if @column
// 91:               metadata << ",col=#{@column}"
// 92:               metadata << ",endColumn=#{@end_column}" if @end_column
// 93:             end
// 94:           end
// 95:         end
// 96:
// 97:         if @title
// 98:           metadata << (@file ? "," : " ")
// 99:           metadata << "title=#{Actions.escape(@title)}"
// 100:         end
// 101:         metadata << " " if metadata.end_with?(":")
// 102:
// 103:         "::#{metadata}::#{Actions.escape(@message)}"
// 104:       end
// 105:
// 106:       # An annotation is only relevant if the corresponding `file` is relative to
// 107:       # the `GITHUB_WORKSPACE` directory or if no `file` is specified.
// 108:       sig { returns(T::Boolean) }
// 109:       def relevant?
// 110:         return true unless @file
// 111:
// 112:         @file.descend.next.to_s != ".."
// 113:       end
// 114:     end
// 115:   end
// 116: end
