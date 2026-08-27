module homebrew

import brew_runtime

// Translated from Homebrew/brew `brew.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby top-level program body from `brew.rb`.
pub fn ruby_brew_file_body(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brew.rb:<top-level>', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: phase_timings_output = ENV.delete("HOMEBREW_PHASE_TIMINGS")
// 5: if phase_timings_output
// 6:   phase_timings_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC).to_f
// 7:   phase_timings_command = ARGV.dup
// 8: end
// 9:
// 10: # `HOMEBREW_STACKPROF` should be set via `brew prof --stackprof`, not manually.
// 11: if ENV["HOMEBREW_STACKPROF"]
// 12:   require "rubygems"
// 13:   require "stackprof"
// 14:   StackProf.start(mode: :wall, raw: true)
// 15: end
// 16:
// 17: raise "HOMEBREW_BREW_FILE was not exported! Please call bin/brew directly!" unless ENV["HOMEBREW_BREW_FILE"]
// 18: if $PROGRAM_NAME != __FILE__ && !$PROGRAM_NAME.end_with?("/bin/ruby-prof")
// 19:   raise "#{__FILE__} must not be loaded via `require`."
// 20: end
// 21:
// 22: std_trap = trap("INT") { exit! 130 } # no backtrace thanks
// 23:
// 24: require_relative "global"
// 25: require "utils/output"
// 26:
// 27: require "utils/phase_timings"
// 28: if phase_timings_output
// 29:   Homebrew::PhaseTimings.start!(
// 30:     output_path: phase_timings_output,
// 31:     started_at:  phase_timings_started_at,
// 32:     command:     phase_timings_command,
// 33:   )
// 34: end
// 35:
// 36: begin
// 37:   trap("INT", std_trap) # restore default CTRL-C handler
// 38:
// 39:   if ENV["CI"]
// 40:     $stdout.sync = true
// 41:     $stderr.sync = true
// 42:   end
// 43:
// 44:   empty_argv = ARGV.empty?
// 45:   help_flag_list = %w[-h --help --usage -?]
// 46:   help_flag = !ENV["HOMEBREW_HELP"].nil?
// 47:   help_cmd_index = T.let(nil, T.nilable(Integer))
// 48:   cmd = T.let(nil, T.nilable(String))
// 49:
// 50:   ARGV.each_with_index do |arg, i|
// 51:     break if help_flag && cmd
// 52:
// 53:     if arg == "help" && !cmd
// 54:       # Command-style help: `help <cmd>` is fine, but `<cmd> help` is not.
// 55:       help_flag = true
// 56:       help_cmd_index = i
// 57:     elsif !cmd && help_flag_list.exclude?(arg)
// 58:       cmd = ARGV.delete_at(i)
// 59:     end
// 60:   end
// 61:
// 62:   ARGV.delete_at(help_cmd_index) if help_cmd_index
// 63:
// 64:   args = Homebrew::PhaseTimings.measure("cli_parse") do
// 65:     require "cli/parser"
// 66:     Homebrew::CLI::Parser.new(Homebrew::Cmd::Brew).parse(ARGV.dup.freeze, ignore_invalid_options: true)
// 67:   end
// 68:   Context.current = args.context
// 69:
// 70:   path = PATH.new(ENV.fetch("PATH"))
// 71:   homebrew_path = PATH.new(ENV.fetch("HOMEBREW_PATH"))
// 72:
// 73:   # Add shared wrappers.
// 74:   path.prepend(HOMEBREW_SHIMS_PATH/"shared")
// 75:   homebrew_path.prepend(HOMEBREW_SHIMS_PATH/"shared")
// 76:
// 77:   ENV["PATH"] = path.to_s
// 78:
// 79:   require "commands"
// 80:
// 81:   internal_cmd = T.let(false, T::Boolean)
// 82:   external_ruby_v2_cmd = T.let(false, T::Boolean)
// 83:   external_ruby_cmd_path = T.let(nil, T.nilable(Pathname))
// 84:   external_cmd_path = T.let(nil, T.nilable(Pathname))
// 85:
// 86:   # `valid_internal_cmd?` requires the command's file, so this covers the
// 87:   # command's entire `require` graph: usually the largest phase of all.
// 88:   Homebrew::PhaseTimings.measure("command_load") do
// 89:     if cmd
// 90:       cmd = Commands::HOMEBREW_INTERNAL_COMMAND_ALIASES.fetch(cmd, cmd)
// 91:       internal_cmd = Commands.valid_internal_cmd?(cmd) || Commands.valid_internal_dev_cmd?(cmd)
// 92:
// 93:       unless internal_cmd
// 94:         # Add contributed commands to PATH before checking.
// 95:         homebrew_path.append(Commands.tap_cmd_directories)
// 96:
// 97:         # External commands expect a normal PATH
// 98:         ENV["PATH"] = homebrew_path.to_s
// 99:
// 100:         external_ruby_v2_cmd = !Commands.external_ruby_v2_cmd_path(cmd).nil?
// 101:         external_ruby_cmd_path = Commands.external_ruby_cmd_path(cmd) unless external_ruby_v2_cmd
// 102:         external_cmd_path = Commands.external_cmd_path(cmd) if !external_ruby_v2_cmd && external_ruby_cmd_path.nil?
// 103:       end
// 104:     end
// 105:   end
// 106:
// 107:   # Usage instructions should be displayed if and only if one of:
// 108:   # - a help flag is passed AND a command is matched
// 109:   # - a help flag is passed AND there is no command specified
// 110:   # - no arguments are passed
// 111:   if empty_argv || help_flag
// 112:     require "help"
// 113:     # `Homebrew::Help.help` may defer to a self-documenting external command's own
// 114:     # `--help` (e.g. `brew help <cmd>`). Pass `--help`, not the Homebrew help flag
// 115:     # that triggered this (`-h`, `--usage`, `-?`), which the command may not know.
// 116:     if external_cmd_path
// 117:       ARGV.reject! { |arg| help_flag_list.include?(arg) }
// 118:       ARGV.push("--help")
// 119:     end
// 120:     Homebrew::Help.help cmd, remaining_args: args.remaining, empty_argv:
// 121:     # `Homebrew::Help.help` never returns, except for unknown and deferred commands.
// 122:   end
// 123:
// 124:   if cmd.nil?
// 125:     raise UsageError, "Unknown command: brew #{ARGV.join(" ")}"
// 126:   elsif internal_cmd || external_ruby_v2_cmd
// 127:     cmd_class = Homebrew::AbstractCommand.command(cmd)
// 128:     if cmd_class&.include?(Homebrew::ShellCommand)
// 129:       exec (HOMEBREW_LIBRARY_PATH.parent.parent/"bin/brew").to_s, cmd, *ARGV
// 130:     end
// 131:     Homebrew.running_command = cmd
// 132:     if cmd_class
// 133:       install_from_api = !Homebrew::EnvConfig.no_install_from_api?
// 134:       require "api" if install_from_api
// 135:       Homebrew::PhaseTimings.install! if phase_timings_output
// 136:       Homebrew::API.fetch_api_files! if install_from_api
// 137:
// 138:       command_instance = Homebrew::PhaseTimings.measure("cli_parse") { cmd_class.new }
// 139:
// 140:       require "utils/analytics"
// 141:       Utils::Analytics.report_command_run(command_instance)
// 142:       command_instance.run
// 143:     else
// 144:       Utils::Output.odisabled "Calling `brew #{cmd}` without subclassing `AbstractCommand`",
// 145:                               "subclassing of `Homebrew::AbstractCommand` " \
// 146:                               "(see https://docs.brew.sh/External-Commands)"
// 147:       begin
// 148:         Homebrew.public_send Commands.method_name(cmd)
// 149:       rescue NoMethodError => e
// 150:         converted_cmd = cmd.downcase.tr("-", "_")
// 151:         case_error = "undefined method `#{converted_cmd}' for module Homebrew"
// 152:         private_method_error = "private method `#{converted_cmd}' called for module Homebrew"
// 153:         Utils::Output.odie "Unknown command: brew #{cmd}" if [case_error, private_method_error].include?(e.message)
// 154:
// 155:         raise
// 156:       end
// 157:     end
// 158:   elsif external_ruby_cmd_path
// 159:     Homebrew.running_command = cmd
// 160:     Homebrew.require?(external_ruby_cmd_path)
// 161:     exit Homebrew.failed? ? 1 : 0
// 162:   elsif external_cmd_path
// 163:     ENV["HOMEBREW_CACHE"] = HOMEBREW_CACHE.to_s
// 164:     ENV["HOMEBREW_LIBRARY_PATH"] = HOMEBREW_LIBRARY_PATH.to_s
// 165:     exec external_cmd_path.to_s, *ARGV
// 166:   else
// 167:     raise UsageError, "Unknown command: brew #{cmd}#{Commands.suggestion_message(cmd)}"
// 168:   end
// 169: rescue UsageError => e
// 170:   require "help"
// 171:   Homebrew::Help.help cmd, remaining_args: args&.remaining || [], usage_error: e.message
// 172: rescue SystemExit => e
// 173:   Utils::Output.onoe "Kernel.exit" if args&.debug? && !e.success?
// 174:   if args&.debug? || ARGV.include?("--debug")
// 175:     require "utils/backtrace"
// 176:     $stderr.puts Utils::Backtrace.clean(e)
// 177:   end
// 178:   raise
// 179: rescue Interrupt
// 180:   $stderr.puts # seemingly a newline is typical
// 181:   exit 130
// 182: rescue BuildError => e
// 183:   Utils::Analytics.report_build_error(e)
// 184:   e.dump(verbose: args&.verbose? || false)
// 185:
// 186:   if OS.not_tier_one_configuration?
// 187:     $stderr.puts <<~EOS
// 188:       This build failure was expected, as this is not a Tier 1 configuration:
// 189:         #{Formatter.url("https://docs.brew.sh/Support-Tiers")}
// 190:       #{Formatter.bold("Do not report any issues to Homebrew/* repositories!")}
// 191:       Read the above document instead before opening any issues or PRs.
// 192:     EOS
// 193:   elsif (formula = e.formula) && (formula.head? || formula.deprecated? || formula.disabled?)
// 194:     reason = if formula.head?
// 195:       "was built from an unstable upstream --HEAD"
// 196:     elsif formula.deprecated?
// 197:       "is deprecated"
// 198:     elsif formula.disabled?
// 199:       "is disabled"
// 200:     end
// 201:     $stderr.puts <<~EOS
// 202:       #{formula.name}'s formula #{reason}.
// 203:       This build failure is expected behaviour.
// 204:     EOS
// 205:   end
// 206:
// 207:   exit 1
// 208: rescue RuntimeError, SystemCallError => e
// 209:   raise if e.message.empty?
// 210:
// 211:   Utils::Output.onoe e
// 212:   if args&.debug? || ARGV.include?("--debug")
// 213:     require "utils/backtrace"
// 214:     $stderr.puts Utils::Backtrace.clean(e)
// 215:   end
// 216:
// 217:   exit 1
// 218: # Catch any other types of exceptions.
// 219: rescue Exception => e # rubocop:disable Lint/RescueException
// 220:   Utils::Output.onoe e
// 221:
// 222:   method_deprecated_error = e.is_a?(MethodDeprecatedError)
// 223:   require "utils/backtrace"
// 224:   $stderr.puts Utils::Backtrace.clean(e) if args&.debug? || ARGV.include?("--debug") || !method_deprecated_error
// 225:
// 226:   if OS.not_tier_one_configuration?
// 227:     $stderr.puts <<~EOS
// 228:       This error was expected, as this is not a Tier 1 configuration:
// 229:         #{Formatter.url("https://docs.brew.sh/Support-Tiers")}
// 230:       #{Formatter.bold("Do not report any issues to Homebrew/* repositories!")}
// 231:       Read the above document instead before opening any issues or PRs.
// 232:     EOS
// 233:   elsif Homebrew::EnvConfig.no_auto_update? &&
// 234:         (fetch_head = HOMEBREW_REPOSITORY/".git/FETCH_HEAD") &&
// 235:         (!fetch_head.exist? || (fetch_head.mtime.to_date < Date.today))
// 236:     $stderr.puts "#{Tty.bold}You have disabled automatic updates and have not updated today.#{Tty.reset}"
// 237:     $stderr.puts "#{Tty.bold}Do not report this issue until you've run `brew update` and tried again.#{Tty.reset}"
// 238:   elsif (issues_url = (method_deprecated_error && e.issues_url) || Utils::Backtrace.tap_error_url(e))
// 239:     $stderr.puts Utils::Output.issue_reporting_message(issues_url)
// 240:   elsif internal_cmd && !method_deprecated_error
// 241:     if OS.nix_managed_homebrew?
// 242:       $stderr.puts Utils::Output.issue_reporting_message(OS::ISSUES_URL)
// 243:     else
// 244:       $stderr.puts Utils::Output.issue_reporting_message(OS::ISSUES_URL, homebrew: true)
// 245:     end
// 246:   end
// 247:
// 248:   exit 1
// 249: else
// 250:   exit 1 if Homebrew.failed?
// 251: ensure
// 252:   if ENV["HOMEBREW_STACKPROF"]
// 253:     StackProf.stop
// 254:     StackProf.results("prof/stackprof.dump")
// 255:   end
// 256:   Homebrew::PhaseTimings.write! if phase_timings_output
// 257: end
