module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/cat.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 27.
pub fn ruby_cat_l27_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class Cat < AbstractCommand
// 10:       include FileUtils
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Display the source of a <formula> or <cask>.
// 15:         EOS
// 16:         switch "--formula", "--formulae",
// 17:                description: "Treat all named arguments as formulae."
// 18:         switch "--cask", "--casks",
// 19:                description: "Treat all named arguments as casks."
// 20:
// 21:         conflicts "--formula", "--cask"
// 22:
// 23:         named_args [:formula, :cask], min: 1, without_api: true
// 24:       end
// 25:
// 26:       sig { override.void }
// 27:       def run
// 28:         cd HOMEBREW_REPOSITORY do
// 29:           pager = if Homebrew::EnvConfig.bat?
// 30:             ENV["BAT_CONFIG_PATH"] = Homebrew::EnvConfig.bat_config_path
// 31:             ENV["BAT_THEME"] = Homebrew::EnvConfig.bat_theme
// 32:             require "formula"
// 33:             T.cast(Formula["bat"].ensure_installed!(
// 34:                      reason:           "displaying <formula>/<cask> source",
// 35:                      # The user might want to capture the output of `brew cat ...`
// 36:                      # Redirect stdout to stderr
// 37:                      output_to_stderr: true,
// 38:                      executable:       "bat",
// 39:                    ), Pathname)
// 40:           else
// 41:             "cat"
// 42:           end
// 43:
// 44:           args.named.to_paths.each do |path|
// 45:             next path if path.exist?
// 46:
// 47:             path = path.basename(".rb") if args.cask?
// 48:
// 49:             ofail "#{path}'s source doesn't exist on disk."
// 50:           end
// 51:
// 52:           if Homebrew.failed?
// 53:             $stderr.puts "The name may be wrong, or the tap hasn't been tapped. Instead try:"
// 54:             treat_as = "--cask " if args.cask?
// 55:             treat_as = "--formula " if args.formula?
// 56:             $stderr.puts "  brew info --github #{treat_as}#{args.named.join(" ")}"
// 57:             return
// 58:           end
// 59:
// 60:           safe_system pager, *args.named.to_paths
// 61:         end
// 62:       end
// 63:     end
// 64:   end
// 65: end
