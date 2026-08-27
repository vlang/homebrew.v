module homebrew

// Translated from Homebrew/brew `postinstall.rb`.
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
// 9:
// 10: require "cli/parser"
// 11: require "cmd/postinstall"
// 12: require "utils/fork"
// 13: require "extend/pathname/write_mkpath_extension"
// 14:
// 15: begin
// 16:   # Undocumented opt-out for internal use.
// 17:   # We need to allow formulae from paths here due to how we pass them through.
// 18:   ENV["HOMEBREW_INTERNAL_ALLOW_PACKAGES_FROM_PATHS"] = "1"
// 19:
// 20:   args = Homebrew::Cmd::Postinstall.new.args
// 21:   error_pipe = Utils.forked_child_error_pipe
// 22:
// 23:   trap("INT", old_trap)
// 24:
// 25:   formula = args.named.to_resolved_formulae.fetch(0)
// 26:   if args.debug? && !Homebrew::EnvConfig.disable_debrew?
// 27:     require "debrew"
// 28:     formula.extend(Debrew::Formula)
// 29:   end
// 30:
// 31:   Pathname.activate_extensions!
// 32:   formula.run_post_install
// 33:
// 34: # Handle all possible exceptions.
// 35: rescue Exception => e # rubocop:disable Lint/RescueException
// 36:   Utils.report_forked_child_error(error_pipe, e)
// 37:   exit! 1
// 38: end
