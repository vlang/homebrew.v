module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/generated_completion.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.dsl_key` at line 18.
pub fn ruby_generated_completion_l18_d1_self_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dsl_key', ...args)
}

// Ruby method `self.from_args(cask, *args, base_name: nil, shell_parameter_format: nil, shells: nil)` at line 31.
pub fn ruby_generated_completion_l31_d2_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_args', ...args)
}

// Ruby method `initialize(cask, commands, base_name:, shell_parameter_format:, shells:)` at line 64.
pub fn ruby_generated_completion_l64_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby attr_reader `attr_reader :commands` at line 75.
pub fn ruby_generated_completion_l75_d4_commands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('commands', ...args)
}

// Ruby attr_reader `attr_reader :base_name` at line 78.
pub fn ruby_generated_completion_l78_d5_base_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('base_name', ...args)
}

// Ruby attr_reader `attr_reader :shell_parameter_format` at line 81.
pub fn ruby_generated_completion_l81_d6_shell_parameter_format(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shell_parameter_format', ...args)
}

// Ruby attr_reader `attr_reader :shells` at line 84.
pub fn ruby_generated_completion_l84_d7_shells(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shells', ...args)
}

// Ruby method `summarize` at line 87.
pub fn ruby_generated_completion_l87_d8_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('summarize', ...args)
}

// Ruby method `install_phase(**_options)` at line 92.
pub fn ruby_generated_completion_l92_d9_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 124.
pub fn ruby_generated_completion_l124_d10_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
}

// Ruby method `write_completion(completion, executable)` at line 138.
pub fn ruby_generated_completion_l138_d11_write_completion(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_completion', ...args)
}

// Ruby method `resolved_base_name` at line 151.
pub fn ruby_generated_completion_l151_d12_resolved_base_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolved_base_name', ...args)
}

// Ruby method `completion_script_path(shell)` at line 162.
pub fn ruby_generated_completion_l162_d13_completion_script_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('completion_script_path', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_artifact"
// 5: require "cask/artifact/bashcompletion"
// 6: require "cask/artifact/fishcompletion"
// 7: require "cask/artifact/zshcompletion"
// 8: require "extend/hash/keys"
// 9: require "utils/shell_completion"
// 10:
// 11: module Cask
// 12:   module Artifact
// 13:     # Artifact corresponding to the `generate_completions_from_executable` stanza.
// 14:     class GeneratedCompletion < AbstractArtifact
// 15:       SUPPORTED_SHELLS = [:bash, :zsh, :fish, :pwsh].freeze
// 16:
// 17:       sig { override.returns(Symbol) }
// 18:       def self.dsl_key
// 19:         :generate_completions_from_executable
// 20:       end
// 21:
// 22:       sig {
// 23:         params(
// 24:           cask:                   Cask,
// 25:           args:                   T.any(Pathname, String),
// 26:           base_name:              T.nilable(String),
// 27:           shell_parameter_format: T.nilable(T.any(Symbol, String)),
// 28:           shells:                 T.nilable(T::Array[T.any(Symbol, String)]),
// 29:         ).returns(T.attached_class)
// 30:       }
// 31:       def self.from_args(cask, *args, base_name: nil, shell_parameter_format: nil, shells: nil)
// 32:         raise CaskInvalidError.new(cask.token, "'#{dsl_key}' requires at least one command") if args.empty?
// 33:
// 34:         commands = args.to_a
// 35:         resolved_shells = (shells || ::Utils::ShellCompletion.default_completion_shells(shell_parameter_format))
// 36:                           .map(&:to_sym)
// 37:
// 38:         unsupported_shells = resolved_shells - SUPPORTED_SHELLS
// 39:         unless unsupported_shells.empty?
// 40:           raise CaskInvalidError.new(
// 41:             cask.token,
// 42:             "'#{dsl_key}' does not support shell(s): #{unsupported_shells.join(", ")}",
// 43:           )
// 44:         end
// 45:
// 46:         new(
// 47:           cask,
// 48:           commands,
// 49:           base_name:,
// 50:           shell_parameter_format:,
// 51:           shells:                 resolved_shells,
// 52:         )
// 53:       end
// 54:
// 55:       sig {
// 56:         params(
// 57:           cask:                   Cask,
// 58:           commands:               T::Array[T.any(Pathname, String)],
// 59:           base_name:              T.nilable(String),
// 60:           shell_parameter_format: T.nilable(T.any(Symbol, String)),
// 61:           shells:                 T::Array[Symbol],
// 62:         ).void
// 63:       }
// 64:       def initialize(cask, commands, base_name:, shell_parameter_format:, shells:)
// 65:         super(cask, *commands, base_name:, shell_parameter_format:, shells:)
// 66:
// 67:         @commands = commands
// 68:         @base_name = base_name
// 69:         @shell_parameter_format = shell_parameter_format
// 70:         @shells = shells
// 71:         @resolved_base_name = T.let(nil, T.nilable(String))
// 72:       end
// 73:
// 74:       sig { returns(T::Array[T.any(Pathname, String)]) }
// 75:       attr_reader :commands
// 76:
// 77:       sig { returns(T.nilable(String)) }
// 78:       attr_reader :base_name
// 79:
// 80:       sig { returns(T.nilable(T.any(Symbol, String))) }
// 81:       attr_reader :shell_parameter_format
// 82:
// 83:       sig { returns(T::Array[Symbol]) }
// 84:       attr_reader :shells
// 85:
// 86:       sig { override.returns(String) }
// 87:       def summarize
// 88:         "#{commands.join(" ")} (base_name: #{resolved_base_name}, shells: #{shells.join(", ")})"
// 89:       end
// 90:
// 91:       sig { params(_options: T.untyped).void }
// 92:       def install_phase(**_options)
// 93:         executable = staged_path_join_executable(commands.fetch(0))
// 94:         completion_commands = [executable, *commands[1..]]
// 95:         completions = shells.map do |shell|
// 96:           popen_read_env = { "SHELL" => shell.to_s }
// 97:           {
// 98:             "shell"           => shell.to_s,
// 99:             "commands"        => completion_commands.map(&:to_s),
// 100:             "shell_parameter" => ::Utils::ShellCompletion.completion_shell_parameter(
// 101:               shell_parameter_format, shell, executable.to_s, popen_read_env
// 102:             ),
// 103:             "env"             => popen_read_env,
// 104:             "output_path"     => completion_script_path(shell).to_s,
// 105:           }
// 106:         end
// 107:
// 108:         if (sandbox = cask_sandbox)
// 109:           completions.map { |completion| Pathname(completion.fetch("output_path")).dirname }.uniq.each do |directory|
// 110:             sandbox.allow_write_path directory
// 111:           end
// 112:           begin
// 113:             run_cask_sandbox(sandbox, { "action" => "generated_completions", "completions" => completions })
// 114:           rescue => e
// 115:             opoo e
// 116:           end
// 117:           return
// 118:         end
// 119:
// 120:         completions.each { |completion| write_completion(completion, executable) }
// 121:       end
// 122:
// 123:       sig { params(command: T.class_of(SystemCommand), _options: T.untyped).void }
// 124:       def uninstall_phase(command: SystemCommand, **_options)
// 125:         shells.each do |shell|
// 126:           path = completion_script_path(shell)
// 127:           next unless path.exist?
// 128:
// 129:           Utils.gain_permissions_remove(path, command:)
// 130:         rescue => e
// 131:           opoo "Failed to remove #{shell} generated completions: #{e}"
// 132:         end
// 133:       end
// 134:
// 135:       private
// 136:
// 137:       sig { params(completion: T::Hash[String, T.untyped], executable: Pathname).void }
// 138:       def write_completion(completion, executable)
// 139:         output_path = Pathname(completion.fetch("output_path"))
// 140:         output_path.dirname.mkpath
// 141:         output_path.write(
// 142:           ::Utils::ShellCompletion.generate_completion_output(
// 143:             completion.fetch("commands"), completion["shell_parameter"], completion.fetch("env")
// 144:           ),
// 145:         )
// 146:       rescue => e
// 147:         opoo "Failed to generate #{completion.fetch("shell")} completions from #{executable}: #{e}"
// 148:       end
// 149:
// 150:       sig { returns(String) }
// 151:       def resolved_base_name
// 152:         @resolved_base_name ||= T.let(begin
// 153:           executable = staged_path_join_executable(commands.fetch(0))
// 154:           name = base_name || File.basename(executable.to_s)
// 155:           name = cask.token if name.empty?
// 156:           name
// 157:         end, T.nilable(String))
// 158:         @resolved_base_name
// 159:       end
// 160:
// 161:       sig { params(shell: Symbol).returns(Pathname) }
// 162:       def completion_script_path(shell)
// 163:         case shell
// 164:         when :bash
// 165:           BashCompletion.new(cask, resolved_base_name).resolve_target(resolved_base_name)
// 166:         when :zsh
// 167:           ZshCompletion.new(cask, resolved_base_name).resolve_target(resolved_base_name)
// 168:         when :fish
// 169:           FishCompletion.new(cask, resolved_base_name).resolve_target(resolved_base_name)
// 170:         when :pwsh
// 171:           HOMEBREW_PREFIX/"share/pwsh/completions"/"_#{resolved_base_name}.ps1"
// 172:         else
// 173:           raise ArgumentError, "unsupported shell: #{shell}"
// 174:         end
// 175:       end
// 176:     end
// 177:   end
// 178: end
