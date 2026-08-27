module utils

import brew_runtime

// Translated from Homebrew/brew `utils/shell_completion.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.default_completion_shells(format)` at line 10.
pub fn ruby_shell_completion_l10_d1_self_default_completion_shells(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.default_completion_shells', ...args)
}

// Ruby method `self.completion_shell_parameter(format, shell, executable, env)` at line 27.
pub fn ruby_shell_completion_l27_d2_self_completion_shell_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.completion_shell_parameter', ...args)
}

// Ruby method `self.generate_completion_output(commands, shell_parameter, env)` at line 64.
pub fn ruby_shell_completion_l64_d3_self_generate_completion_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate_completion_output', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # Shared logic for generating shell completion scripts.
// 6:   # Used by both {Formula#generate_completions_from_executable} and
// 7:   # {Cask::Artifact::GeneratedCompletion}.
// 8:   module ShellCompletion
// 9:     sig { params(format: T.nilable(T.any(Symbol, String))).returns(T::Array[Symbol]) }
// 10:     def self.default_completion_shells(format)
// 11:       case format
// 12:       when :cobra, :typer
// 13:         [:bash, :zsh, :fish, :pwsh]
// 14:       else
// 15:         [:bash, :zsh, :fish]
// 16:       end
// 17:     end
// 18:
// 19:     sig {
// 20:       params(
// 21:         format:     T.nilable(T.any(Symbol, String)),
// 22:         shell:      Symbol,
// 23:         executable: String,
// 24:         env:        T::Hash[String, String],
// 25:       ).returns(T.nilable(T.any(String, T::Array[String])))
// 26:     }
// 27:     def self.completion_shell_parameter(format, shell, executable, env)
// 28:       # Go's cobra and Rust's clap accept "powershell".
// 29:       shell_parameter = (shell == :pwsh) ? "powershell" : shell.to_s
// 30:
// 31:       case format
// 32:       when nil
// 33:         shell_parameter
// 34:       when :arg
// 35:         "--shell=#{shell_parameter}"
// 36:       when :clap
// 37:         env["COMPLETE"] = shell_parameter
// 38:         nil
// 39:       when :click
// 40:         prog_name = File.basename(executable).upcase.tr("-", "_")
// 41:         env["_#{prog_name}_COMPLETE"] = "#{shell_parameter}_source"
// 42:         nil
// 43:       when :cobra
// 44:         ["completion", shell_parameter]
// 45:       when :flag
// 46:         "--#{shell_parameter}"
// 47:       when :none
// 48:         nil
// 49:       when :typer
// 50:         env["_TYPER_COMPLETE_TEST_DISABLE_SHELL_DETECTION"] = "1"
// 51:         ["--show-completion", shell_parameter]
// 52:       else
// 53:         "#{format}#{shell}"
// 54:       end
// 55:     end
// 56:
// 57:     sig {
// 58:       params(
// 59:         commands:        T::Array[T.any(Pathname, String)],
// 60:         shell_parameter: T.nilable(T.any(String, T::Array[String])),
// 61:         env:             T::Hash[String, String],
// 62:       ).returns(String)
// 63:     }
// 64:     def self.generate_completion_output(commands, shell_parameter, env)
// 65:       args = T.let(commands + Array(shell_parameter), T::Array[T.any(Pathname, String)])
// 66:       options = T.let({}, T::Hash[Symbol, Symbol])
// 67:       options[:err] = :err unless ENV["HOMEBREW_STDERR"]
// 68:       Utils.safe_popen_read(env, *args, **options)
// 69:     end
// 70:   end
// 71: end
