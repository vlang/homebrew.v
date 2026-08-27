module github

import brew_runtime

// Translated from Homebrew/brew `utils/github/actions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.escape(string)` at line 10.
pub fn ruby_actions_l10_d1_self_escape(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.escape', ...args)
}

// Ruby method `self.env_set?` at line 18.
pub fn ruby_actions_l18_d2_self_env_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.env_set?', ...args)
}

// Ruby method `self.puts_annotation_if_env_set!(type, message, file: nil, line: nil)` at line 29.
pub fn ruby_actions_l29_d3_self_puts_annotation_if_env_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.puts_annotation_if_env_set!', ...args)
}

// Ruby method `self.path_relative_to_workspace(path)` at line 45.
pub fn ruby_actions_l45_d4_self_path_relative_to_workspace(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.path_relative_to_workspace', ...args)
}

// Ruby method `initialize(type, message, file: nil, title: nil, line: nil, end_line: nil, column: nil, end_column: nil)` at line 65.
pub fn ruby_actions_l65_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_s` at line 81.
pub fn ruby_actions_l81_d6_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `relevant?` at line 109.
pub fn ruby_actions_l109_d7_relevant(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('relevant?', ...args)
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
