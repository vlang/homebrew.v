module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/readall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 37.
pub fn ruby_readall_l37_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "readall"
// 6: require "env_config"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class ReadallCmd < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Import all items from the specified <tap>, or from all installed taps if none is provided.
// 14:           This can be useful for debugging issues across all items when making
// 15:           significant changes to `formula.rb`, testing the performance of loading
// 16:           all items or checking if any current formulae/casks have Ruby issues.
// 17:         EOS
// 18:         flag   "--os=",
// 19:                description: "Read using the given operating system. (Pass `all` to simulate all operating systems.)"
// 20:         flag   "--arch=",
// 21:                description: "Read using the given CPU architecture. (Pass `all` to simulate all architectures.)"
// 22:         switch "--aliases",
// 23:                description: "Verify any alias symlinks in each tap."
// 24:         switch "--syntax",
// 25:                description: "Syntax-check all of Homebrew's Ruby files (if no <tap> is passed)."
// 26:         switch "--eval-all",
// 27:                description: "Evaluate all available formulae and casks, whether installed or not.",
// 28:                env:         :eval_all,
// 29:                odeprecated: true
// 30:         switch "--no-simulate",
// 31:                description: "Don't simulate other system configurations when checking formulae and casks."
// 32:
// 33:         named_args :tap
// 34:       end
// 35:
// 36:       sig { override.void }
// 37:       def run
// 38:         Homebrew.with_no_api_env do
// 39:           if args.syntax? && args.no_named?
// 40:             scan_files = "#{HOMEBREW_LIBRARY_PATH}/**/*.rb"
// 41:             ruby_files = Dir.glob(scan_files).grep_v(%r{/(vendor)/}).map { Pathname(it) }
// 42:
// 43:             Homebrew.failed = true unless Readall.valid_ruby_syntax?(ruby_files)
// 44:           end
// 45:
// 46:           options = {
// 47:             aliases:     args.aliases?,
// 48:             no_simulate: args.no_simulate?,
// 49:           }
// 50:           options[:os_arch_combinations] = args.os_arch_combinations if args.os || args.arch
// 51:
// 52:           eval_all = args.eval_all?
// 53:           eval_all ||= args.no_named? && Homebrew::EnvConfig.tap_trust_configured?
// 54:           taps = if args.no_named?
// 55:             unless eval_all
// 56:               raise UsageError,
// 57:                     "`brew readall` needs a tap, `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 58:                     "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 59:             end
// 60:
// 61:             Tap.installed
// 62:           else
// 63:             args.named.to_installed_taps
// 64:           end
// 65:
// 66:           taps.each do |tap|
// 67:             Homebrew.failed = true unless Readall.valid_tap?(tap, **options)
// 68:           end
// 69:         end
// 70:       end
// 71:     end
// 72:   end
// 73: end
