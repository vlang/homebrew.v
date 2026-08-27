module homebrew

// Translated from Homebrew/brew `test.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: raise "#{__FILE__} must not be loaded via `require`." if $PROGRAM_NAME != __FILE__
// 5:
// 6: old_trap = trap("INT") { exit! 130 }
// 7:
// 8: require_relative "global"
// 9: require "extend/ENV"
// 10: require "timeout"
// 11: require "formula_assertions"
// 12: require "formula_free_port"
// 13: require "cli/parser"
// 14: require "dev-cmd/test"
// 15: require "utils/fork"
// 16: require "extend/pathname/write_mkpath_extension"
// 17:
// 18: DEFAULT_TEST_TIMEOUT_SECONDS = T.let(5 * 60, Integer)
// 19:
// 20: begin
// 21:   # Undocumented opt-out for internal use.
// 22:   # We need to allow formulae from paths here due to how we pass them through.
// 23:   ENV["HOMEBREW_INTERNAL_ALLOW_PACKAGES_FROM_PATHS"] = "1"
// 24:
// 25:   args = Homebrew::DevCmd::Test.new.args
// 26:   Context.current = args.context
// 27:
// 28:   error_pipe = Utils.forked_child_error_pipe
// 29:
// 30:   trap("INT", old_trap)
// 31:
// 32:   if Homebrew::EnvConfig.developer? || ENV["CI"].present?
// 33:     raise "Cannot find child processes without `pgrep`, please install!" unless which("pgrep")
// 34:     raise "Cannot kill child processes without `pkill`, please install!" unless which("pkill")
// 35:   end
// 36:
// 37:   formula = args.named.to_resolved_formulae.fetch(0)
// 38:   formula.extend(Homebrew::Assertions)
// 39:   formula.extend(Homebrew::FreePort)
// 40:   if args.debug? && !Homebrew::EnvConfig.disable_debrew?
// 41:     require "debrew"
// 42:     formula.extend(Debrew::Formula)
// 43:   end
// 44:
// 45:   ENV.extend(Stdenv)
// 46:   ENV.setup_build_environment(formula:, testing_formula: true)
// 47:   Pathname.activate_extensions!
// 48:
// 49:   run_test = proc do |_|
// 50:     # TODO: Replace proc usage with direct `formula.run_test` when removing this.
// 51:     # Also update formula.rb 'TODO: replace `returns(BasicObject)` with `void`'
// 52:     if formula.run_test(keep_tmp: args.keep_tmp?) == false
// 53:       require "utils/output"
// 54:       Utils::Output.odisabled "`return false` in test", "`raise \"<reason for failure>\"`"
// 55:       raise "test returned false"
// 56:     end
// 57:   end
// 58:   if args.debug? # --debug is interactive
// 59:     run_test.call(nil)
// 60:   else
// 61:     # HOMEBREW_TEST_TIMEOUT_SECS is private API and subject to change.
// 62:     timeout = ENV["HOMEBREW_TEST_TIMEOUT_SECS"]&.to_i || DEFAULT_TEST_TIMEOUT_SECONDS
// 63:     Timeout.timeout(timeout, &run_test)
// 64:   end
// 65: # Any exceptions during the test run are reported.
// 66: rescue Exception => e # rubocop:disable Lint/RescueException
// 67:   Utils.report_forked_child_error(error_pipe, e)
// 68: ensure
// 69:   pid = Process.pid.to_s
// 70:   pkill = "/usr/bin/pkill"
// 71:   pgrep = "/usr/bin/pgrep"
// 72:   if File.executable?(pkill) && File.executable?(pgrep) && system(pgrep, "-P", pid, out: File::NULL)
// 73:     $stderr.puts "Killing child processes..."
// 74:     system pkill, "-P", pid
// 75:     sleep 1
// 76:     system pkill, "-9", "-P", pid
// 77:   end
// 78:   exit! 1 if e
// 79: end
