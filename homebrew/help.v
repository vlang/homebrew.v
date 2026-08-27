module homebrew

import brew_runtime

// Translated from Homebrew/brew `help.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.help(cmd = nil, empty_argv: false, usage_error: nil, remaining_args: [])` at line 22.
pub fn ruby_help_l22_d1_self_help(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.help', ...args)
}

// Ruby method `self.command_help(cmd, path, remaining_args:, usage_error:)` at line 71.
pub fn ruby_help_l71_d2_self_command_help(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.command_help', ...args)
}

// Ruby method `self.parser_help(path, remaining_args:, usage_error:)` at line 101.
pub fn ruby_help_l101_d3_self_parser_help(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.parser_help', ...args)
}

// Ruby method `self.command_help_lines(path)` at line 114.
pub fn ruby_help_l114_d4_self_command_help_lines(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.command_help_lines', ...args)
}

// Ruby method `self.comment_help(path)` at line 123.
pub fn ruby_help_l123_d5_self_comment_help(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.comment_help', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cli/parser"
// 5: require "commands"
// 6: require "tap"
// 7: require "utils/output"
// 8:
// 9: module Homebrew
// 10:   # Helper module for printing help output.
// 11:   module Help
// 12:     extend Utils::Output::Mixin
// 13:
// 14:     sig {
// 15:       params(
// 16:         cmd:            T.nilable(String),
// 17:         empty_argv:     T::Boolean,
// 18:         usage_error:    T.nilable(String),
// 19:         remaining_args: T::Array[String],
// 20:       ).void
// 21:     }
// 22:     def self.help(cmd = nil, empty_argv: false, usage_error: nil, remaining_args: [])
// 23:       if cmd.nil?
// 24:         # Handle `brew` (no arguments).
// 25:         if empty_argv
// 26:           $stderr.puts HOMEBREW_HELP_MESSAGE
// 27:           exit 1
// 28:         end
// 29:
// 30:         # Handle `brew (-h|--help|--usage|-?|help)` (no other arguments).
// 31:         puts HOMEBREW_HELP_MESSAGE
// 32:         exit 0
// 33:       end
// 34:
// 35:       # Resolve command aliases and find file containing the implementation.
// 36:       path = Commands.path(cmd)
// 37:
// 38:       # Display command-specific (or generic) help in response to `UsageError`.
// 39:       if usage_error
// 40:         $stderr.puts path ? command_help(cmd, path, remaining_args:, usage_error: true) : HOMEBREW_HELP_MESSAGE
// 41:         $stderr.puts
// 42:         onoe usage_error
// 43:         exit 1
// 44:       end
// 45:
// 46:       # Resume execution in `brew.rb` for unknown commands.
// 47:       return if path.nil?
// 48:
// 49:       # An external command with no `#:` comments documents itself by running its
// 50:       # own `--help`, so resume execution in `brew.rb` to do that. Internal commands
// 51:       # and Ruby commands (`*.rb`, which generate their own help) are excluded.
// 52:       undocumented_external_cmd = !Commands.valid_internal_cmd?(cmd) &&
// 53:                                   !Commands.valid_internal_dev_cmd?(cmd) &&
// 54:                                   path.extname != ".rb" &&
// 55:                                   command_help_lines(path).blank?
// 56:       return if undocumented_external_cmd
// 57:
// 58:       # Display help for internal command (or generic help if undocumented).
// 59:       puts command_help(cmd, path, remaining_args:, usage_error: false)
// 60:       exit 0
// 61:     end
// 62:
// 63:     sig {
// 64:       params(
// 65:         cmd:            String,
// 66:         path:           Pathname,
// 67:         remaining_args: T::Array[String],
// 68:         usage_error:    T::Boolean,
// 69:       ).returns(String)
// 70:     }
// 71:     def self.command_help(cmd, path, remaining_args:, usage_error:)
// 72:       # Only some types of commands can have a parser.
// 73:       output = if Commands.valid_internal_cmd?(cmd) ||
// 74:                   Commands.valid_internal_dev_cmd?(cmd) ||
// 75:                   Commands.external_ruby_v2_cmd_path(cmd)
// 76:         parser_help(path, remaining_args:, usage_error:)
// 77:       end
// 78:
// 79:       output ||= comment_help(path)
// 80:
// 81:       if output.present?
// 82:         if (tap = Tap.from_path(path)) && !tap.official?
// 83:           output = "From tap: #{tap.name}\n#{output}"
// 84:         end
// 85:       else
// 86:         opoo "No help text in: #{path}" if Homebrew::EnvConfig.developer?
// 87:         output = HOMEBREW_HELP_MESSAGE
// 88:       end
// 89:
// 90:       output
// 91:     end
// 92:     private_class_method :command_help
// 93:
// 94:     sig {
// 95:       params(
// 96:         path:           Pathname,
// 97:         remaining_args: T::Array[String],
// 98:         usage_error:    T::Boolean,
// 99:       ).returns(T.nilable(String))
// 100:     }
// 101:     def self.parser_help(path, remaining_args:, usage_error:)
// 102:       # Let OptionParser generate help text for commands which have a parser.
// 103:       cmd_parser = CLI::Parser.from_cmd_path(path)
// 104:       return unless cmd_parser
// 105:
// 106:       # Try parsing arguments here in order to show formula options in help output.
// 107:       cmd_parser.parse(remaining_args, ignore_invalid_options: true)
// 108:       remaining_args = cmd_parser.args.remaining if usage_error || cmd_parser.subcommands.present?
// 109:       cmd_parser.generate_help_text(remaining_args:)
// 110:     end
// 111:     private_class_method :parser_help
// 112:
// 113:     sig { params(path: Pathname).returns(T::Array[String]) }
// 114:     def self.command_help_lines(path)
// 115:       path.read
// 116:           .lines
// 117:           .grep(/^#:/)
// 118:           .filter_map { |line| line.slice(2..-1)&.delete_prefix("  ") }
// 119:     end
// 120:     private_class_method :command_help_lines
// 121:
// 122:     sig { params(path: Pathname).returns(T.nilable(String)) }
// 123:     def self.comment_help(path)
// 124:       # Otherwise read #: lines from the file.
// 125:       help_lines = command_help_lines(path)
// 126:       return if help_lines.blank?
// 127:
// 128:       Formatter.format_help_text(help_lines.join, width: Formatter::COMMAND_DESC_WIDTH)
// 129:                .sub("@hide_from_man_page ", "")
// 130:                .sub(/^\* /, "#{Tty.bold}Usage: brew#{Tty.reset} ")
// 131:                .gsub(/`(.*?)`/m, "#{Tty.bold}\\1#{Tty.reset}")
// 132:                .gsub(%r{<([^\s]+?://[^\s]+?)>}) { |url| Formatter.url(url) }
// 133:                .gsub(/<(.*?)>/m, "#{Tty.underline}\\1#{Tty.reset}")
// 134:                .gsub(/\*(.*?)\*/m, "#{Tty.underline}\\1#{Tty.reset}")
// 135:     end
// 136:     private_class_method :comment_help
// 137:   end
// 138: end
