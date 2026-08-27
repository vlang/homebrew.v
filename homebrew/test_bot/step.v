module test_bot

import brew_runtime

// Translated from Homebrew/brew `test_bot/step.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.runner_os_title` at line 10.
pub fn ruby_step_l10_d1_self_runner_os_title(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.runner_os_title', ...args)
}

// Ruby method `self.runner_os_title_with_arch` at line 15.
pub fn ruby_step_l15_d2_self_runner_os_title_with_arch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.runner_os_title_with_arch', ...args)
}

// Ruby attr_reader `attr_reader :command` at line 25.
pub fn ruby_step_l25_d3_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby attr_reader `attr_reader :name` at line 28.
pub fn ruby_step_l28_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby attr_reader `attr_reader :status` at line 31.
pub fn ruby_step_l31_d5_status(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('status', ...args)
}

// Ruby attr_reader `attr_reader :output` at line 34.
pub fn ruby_step_l34_d6_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output', ...args)
}

// Ruby attr_reader `attr_reader :start_time, :end_time` at line 37.
pub fn ruby_step_l37_d7_start_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('start_time', ...args)
}

// Ruby attr_reader `attr_reader :start_time, :end_time` at line 37.
pub fn ruby_step_l37_d8_end_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('end_time', ...args)
}

// Ruby method `initialize(command, env:, verbose:, named_args: nil, ignore_failures: false, repository: nil)` at line 52.
pub fn ruby_step_l52_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `command_trimmed` at line 66.
pub fn ruby_step_l66_d10_command_trimmed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command_trimmed', ...args)
}

// Ruby method `command_short` at line 75.
pub fn ruby_step_l75_d11_command_short(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command_short', ...args)
}

// Ruby method `passed?` at line 95.
pub fn ruby_step_l95_d12_passed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('passed?', ...args)
}

// Ruby method `failed?` at line 100.
pub fn ruby_step_l100_d13_failed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('failed?', ...args)
}

// Ruby method `ignored?` at line 105.
pub fn ruby_step_l105_d14_ignored(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignored?', ...args)
}

// Ruby method `puts_command` at line 110.
pub fn ruby_step_l110_d15_puts_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('puts_command', ...args)
}

// Ruby method `puts_result` at line 115.
pub fn ruby_step_l115_d16_puts_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('puts_result', ...args)
}

// Ruby method `puts_github_actions_annotation(message, title, file, line)` at line 120.
pub fn ruby_step_l120_d17_puts_github_actions_annotation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('puts_github_actions_annotation', ...args)
}

// Ruby method `puts_in_github_actions_group(title, &_block)` at line 136.
pub fn ruby_step_l136_d18_puts_in_github_actions_group(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('puts_in_github_actions_group', ...args)
}

// Ruby method `output?` at line 143.
pub fn ruby_step_l143_d19_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output?', ...args)
}

// Ruby method `time` at line 151.
pub fn ruby_step_l151_d20_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('time', ...args)
}

// Ruby method `puts_full_output` at line 156.
pub fn ruby_step_l156_d21_puts_full_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('puts_full_output', ...args)
}

// Ruby method `annotation_location(name)` at line 165.
pub fn ruby_step_l165_d22_annotation_location(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('annotation_location', ...args)
}

// Ruby method `truncate_output(output, max_kb:, context_lines:)` at line 181.
pub fn ruby_step_l181_d23_truncate_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('truncate_output', ...args)
}

// Ruby method `run(dry_run: false, fail_fast: false)` at line 208.
pub fn ruby_step_l208_d24_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5: require "utils/github/actions"
// 6:
// 7: module Homebrew
// 8:   module TestBot
// 9:     sig { returns(String) }
// 10:     def self.runner_os_title
// 11:       raise NotImplementedError, "Homebrew::TestBot.runner_os_title must be implemented in extend/os."
// 12:     end
// 13:
// 14:     sig { returns(String) }
// 15:     def self.runner_os_title_with_arch
// 16:       runner_os_title
// 17:     end
// 18:
// 19:     # Wraps command invocations. Instantiated by Test#test.
// 20:     # Handles logging and pretty-printing.
// 21:     class Step
// 22:       include SystemCommand::Mixin
// 23:
// 24:       sig { returns(T::Array[String]) }
// 25:       attr_reader :command
// 26:
// 27:       sig { returns(T.nilable(String)) }
// 28:       attr_reader :name
// 29:
// 30:       sig { returns(Symbol) }
// 31:       attr_reader :status
// 32:
// 33:       sig { returns(T.nilable(String)) }
// 34:       attr_reader :output
// 35:
// 36:       sig { returns(T.nilable(Time)) }
// 37:       attr_reader :start_time, :end_time
// 38:
// 39:       # Instantiates a Step object.
// 40:       # @param command Command to execute and arguments.
// 41:       # @param env Environment variables to set when running command.
// 42:       sig {
// 43:         params(
// 44:           command:         T::Array[String],
// 45:           env:             T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))],
// 46:           verbose:         T::Boolean,
// 47:           named_args:      T.nilable(T.any(String, T::Array[String])),
// 48:           ignore_failures: T::Boolean,
// 49:           repository:      T.nilable(Pathname),
// 50:         ).void
// 51:       }
// 52:       def initialize(command, env:, verbose:, named_args: nil, ignore_failures: false, repository: nil)
// 53:         @named_args = T.let([named_args].flatten.compact.map(&:to_s), T::Array[String])
// 54:         @command = T.let(command + @named_args, T::Array[String])
// 55:         @env = env
// 56:         @verbose = verbose
// 57:         @ignore_failures = ignore_failures
// 58:         @repository = repository
// 59:
// 60:         @name = T.let(command[1]&.delete("-"), T.nilable(String))
// 61:         @status = T.let(:running, Symbol)
// 62:         @output = T.let(nil, T.nilable(String))
// 63:       end
// 64:
// 65:       sig { returns(String) }
// 66:       def command_trimmed
// 67:         command.reject { |arg| arg.to_s.start_with?("--exclude") }
// 68:                .join(" ")
// 69:                .delete_prefix("#{HOMEBREW_LIBRARY}/Taps/")
// 70:                .delete_prefix("#{HOMEBREW_PREFIX}/")
// 71:                .delete_prefix("/usr/bin/")
// 72:       end
// 73:
// 74:       sig { returns(String) }
// 75:       def command_short
// 76:         (@command - %W[
// 77:           brew
// 78:           -C
// 79:           #{HOMEBREW_PREFIX}
// 80:           #{HOMEBREW_REPOSITORY}
// 81:           #{@repository}
// 82:           #{Dir.pwd}
// 83:           --force
// 84:           --retry
// 85:           --verbose
// 86:           --json
// 87:         ].freeze).join(" ")
// 88:           .gsub(HOMEBREW_PREFIX.to_s, "")
// 89:           .gsub(HOMEBREW_REPOSITORY.to_s, "")
// 90:           .gsub(@repository.to_s, "")
// 91:           .gsub(Dir.pwd, "")
// 92:       end
// 93:
// 94:       sig { returns(T::Boolean) }
// 95:       def passed?
// 96:         @status == :passed
// 97:       end
// 98:
// 99:       sig { returns(T::Boolean) }
// 100:       def failed?
// 101:         @status == :failed
// 102:       end
// 103:
// 104:       sig { returns(T::Boolean) }
// 105:       def ignored?
// 106:         @status == :ignored
// 107:       end
// 108:
// 109:       sig { void }
// 110:       def puts_command
// 111:         puts Formatter.headline(command_trimmed, color: :blue)
// 112:       end
// 113:
// 114:       sig { void }
// 115:       def puts_result
// 116:         puts Formatter.headline(Formatter.error("FAILED"), color: :red) unless passed?
// 117:       end
// 118:
// 119:       sig { params(message: String, title: String, file: String, line: T.nilable(Integer)).void }
// 120:       def puts_github_actions_annotation(message, title, file, line)
// 121:         return unless GitHub::Actions.env_set?
// 122:
// 123:         type = if passed?
// 124:           :notice
// 125:         elsif ignored?
// 126:           :warning
// 127:         else
// 128:           :error
// 129:         end
// 130:
// 131:         annotation = GitHub::Actions::Annotation.new(type, message, title:, file:, line:)
// 132:         puts annotation
// 133:       end
// 134:
// 135:       sig { params(title: String, _block: T.proc.void).void }
// 136:       def puts_in_github_actions_group(title, &_block)
// 137:         puts "::group::#{title}" if GitHub::Actions.env_set?
// 138:         yield
// 139:         puts "::endgroup::" if GitHub::Actions.env_set?
// 140:       end
// 141:
// 142:       sig { returns(T::Boolean) }
// 143:       def output?
// 144:         @output.present?
// 145:       end
// 146:
// 147:       # The execution time of the task.
// 148:       # Precondition: Step#run has been called.
// 149:       # @return execution time in seconds
// 150:       sig { returns(Float) }
// 151:       def time
// 152:         T.must(end_time) - T.must(start_time)
// 153:       end
// 154:
// 155:       sig { void }
// 156:       def puts_full_output
// 157:         return if @output.blank? || @verbose
// 158:
// 159:         puts_in_github_actions_group("Full #{command_short} output") do
// 160:           puts @output
// 161:         end
// 162:       end
// 163:
// 164:       sig { params(name: String).returns([T.nilable(String), T.nilable(Integer)]) }
// 165:       def annotation_location(name)
// 166:         formula = Formulary.factory(name)
// 167:         method_sym = command.fetch(1).to_sym
// 168:         method_location = formula.method(method_sym).source_location if formula.respond_to?(method_sym)
// 169:
// 170:         if method_location.present? && (method_location.first == formula.path.to_s)
// 171:           method_location
// 172:         else
// 173:           [formula.path.to_s, nil]
// 174:         end
// 175:       rescue FormulaUnavailableError
// 176:         glob_result = @repository ? @repository.glob("**/#{name}*").first&.to_s : nil
// 177:         [glob_result, nil]
// 178:       end
// 179:
// 180:       sig { params(output: String, max_kb: Integer, context_lines: Integer).returns(String) }
// 181:       def truncate_output(output, max_kb:, context_lines:)
// 182:         output_lines = output.lines
// 183:         first_error_index = output_lines.find_index do |line|
// 184:           !line.strip.match?(/^::error( .*)?::/) &&
// 185:             (line.match?(/\berror:\s+/i) || line.match?(/\bcmake error\b/i))
// 186:         end
// 187:
// 188:         if first_error_index.blank?
// 189:           output = []
// 190:
// 191:           # Collect up to max_kb worth of the last lines of output.
// 192:           output_lines.reverse_each do |line|
// 193:             # Check output.present? so that we at least have _some_ output.
// 194:             break if line.length + output.join.length > max_kb && output.present?
// 195:
// 196:             output.unshift line
// 197:           end
// 198:
// 199:           output.join
// 200:         else
// 201:           start = [first_error_index - context_lines, 0].max
// 202:           # Let GitHub Actions truncate us to 4KB if needed.
// 203:           T.must(output_lines[start..]).join
// 204:         end
// 205:       end
// 206:
// 207:       sig { params(dry_run: T::Boolean, fail_fast: T::Boolean).void }
// 208:       def run(dry_run: false, fail_fast: false)
// 209:         @start_time = T.let(Time.now, T.nilable(Time))
// 210:
// 211:         puts_command
// 212:         if dry_run
// 213:           @status = :passed
// 214:           puts_result
// 215:           return
// 216:         end
// 217:
// 218:         raise "git should always be called with -C!" if command[0] == "git" && %w[-C clone].exclude?(command[1])
// 219:
// 220:         executable, *args = command
// 221:
// 222:         result = system_command T.must(executable), args:,
// 223:                                                     print_stdout: @verbose,
// 224:                                                     print_stderr: @verbose,
// 225:                                                     env:          @env
// 226:
// 227:         @end_time = T.let(Time.now, T.nilable(Time))
// 228:
// 229:         @status = if result.success?
// 230:           :passed
// 231:         elsif @ignore_failures
// 232:           :ignored
// 233:         else
// 234:           :failed
// 235:         end
// 236:
// 237:         puts_result
// 238:
// 239:         output = result.merged_output
// 240:
// 241:         # ActiveSupport can barf on some Unicode so don't use .present?
// 242:         if output.empty?
// 243:           puts if @verbose
// 244:           exit 1 if fail_fast && failed?
// 245:           return
// 246:         end
// 247:
// 248:         output.force_encoding(Encoding::UTF_8)
// 249:         @output = if output.valid_encoding?
// 250:           output
// 251:         else
// 252:           output.encode!(Encoding::UTF_16, invalid: :replace)
// 253:           output.encode!(Encoding::UTF_8)
// 254:         end
// 255:
// 256:         return if passed?
// 257:
// 258:         puts_full_output
// 259:
// 260:         unless GitHub::Actions.env_set?
// 261:           puts
// 262:           exit 1 if fail_fast && failed?
// 263:           return
// 264:         end
// 265:
// 266:         @named_args.each do |name|
// 267:           next if name.blank?
// 268:
// 269:           path, line = annotation_location(name)
// 270:           next if path.blank?
// 271:
// 272:           # GitHub Actions has a 4KB maximum for annotations.
// 273:           annotation_output = truncate_output(@output, max_kb: 4, context_lines: 5)
// 274:
// 275:           annotation_title = "`#{command_trimmed}` failed on #{Homebrew::TestBot.runner_os_title_with_arch}!"
// 276:           file = path.delete_prefix("#{@repository}/")
// 277:           puts_in_github_actions_group("Truncated #{command_short} output") do
// 278:             puts_github_actions_annotation(annotation_output, annotation_title, file, line)
// 279:           end
// 280:         end
// 281:
// 282:         exit 1 if fail_fast && failed?
// 283:       end
// 284:     end
// 285:   end
// 286: end
