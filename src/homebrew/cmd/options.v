module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/options.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 34.
pub fn ruby_options_l34_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `puts_options(formulae)` at line 64.
pub fn ruby_options_l64_d2_puts_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('puts_options', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "options"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class OptionsCmd < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Show install options specific to <formula>.
// 14:         EOS
// 15:         switch "--compact",
// 16:                description: "Show all options on a single line separated by spaces."
// 17:         switch "--installed",
// 18:                description: "Show options for formulae that are currently installed."
// 19:         switch "--eval-all",
// 20:                description: "Evaluate all available formulae and casks, whether installed or not, to show their " \
// 21:                             "options.",
// 22:                env:         :eval_all,
// 23:                odeprecated: true
// 24:         flag   "--command=",
// 25:                description: "Show options for the specified <command>.",
// 26:                odeprecated: true
// 27:
// 28:         conflicts "--command", "--installed", "--eval-all"
// 29:
// 30:         named_args :formula
// 31:       end
// 32:
// 33:       sig { override.void }
// 34:       def run
// 35:         eval_all = args.eval_all?
// 36:         eval_all ||= args.no_named? && Homebrew::EnvConfig.tap_trust_configured?
// 37:
// 38:         if eval_all
// 39:           puts_options(Formula.all(eval_all:).sort)
// 40:         elsif args.installed?
// 41:           puts_options(Formula.installed.sort)
// 42:         elsif args.command.present?
// 43:           cmd_options = Commands.command_options(T.must(args.command))
// 44:           odie "Unknown command: brew #{args.command}" if cmd_options.nil?
// 45:
// 46:           if args.compact?
// 47:             puts cmd_options.sort.map(&:first) * " "
// 48:           else
// 49:             cmd_options.sort.each { |option, desc| puts "#{option}\n\t#{desc}" }
// 50:             puts
// 51:           end
// 52:         elsif args.no_named?
// 53:           raise UsageError,
// 54:                 "`brew options` needs a formula, `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 55:                 "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 56:         else
// 57:           puts_options args.named.to_formulae
// 58:         end
// 59:       end
// 60:
// 61:       private
// 62:
// 63:       sig { params(formulae: T::Array[Formula]).void }
// 64:       def puts_options(formulae)
// 65:         formulae.each do |f|
// 66:           next if f.options.empty?
// 67:
// 68:           if args.compact?
// 69:             puts f.options.as_flags.sort * " "
// 70:           else
// 71:             puts f.full_name if formulae.length > 1
// 72:             Options.dump_for_formula f
// 73:             puts
// 74:           end
// 75:         end
// 76:       end
// 77:     end
// 78:   end
// 79: end
