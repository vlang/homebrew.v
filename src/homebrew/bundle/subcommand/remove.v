module subcommand

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand/remove.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 35.
pub fn ruby_remove_l35_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "bundle/extensions/extension"
// 6:
// 7: require "bundle/remover"
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Bundle < Homebrew::AbstractCommand
// 11:       class RemoveSubcommand < Homebrew::AbstractSubcommand
// 12:         subcommand_args do
// 13:           extensions = Homebrew::Bundle.extensions
// 14:           usage_banner <<~EOS
// 15:             `brew bundle remove` <name> [...]:
// 16:             Remove entries that match `name` from your `Brewfile`. Use #{["`--formula`", "`--cask`", "`--tap`", *extensions.select(&:remove_supported?).map { |extension| "`--#{extension.flag}`" }].to_sentence} to remove only entries of the corresponding type. Passing `--formula` also removes matches against formula aliases and old formula names.
// 17:           EOS
// 18:           named_args min: 1
// 19:           switch "--install",
// 20:                  description: "Run `install` before removing entries."
// 21:           switch "--formula", "--formulae", "--brews",
// 22:                  description: "Remove Homebrew formula entries, including matches against formula aliases " \
// 23:                               "and old names."
// 24:           switch "--cask", "--casks",
// 25:                  description: "Remove Homebrew cask entries."
// 26:           switch "--tap", "--taps",
// 27:                  description: "Remove Homebrew tap entries."
// 28:           extensions.select(&:remove_supported?).each do |extension|
// 29:             switch "--#{extension.flag}",
// 30:                    description: extension.switch_description("Remove entries for #{extension.banner_name}.")
// 31:           end
// 32:         end
// 33:
// 34:         sig { override.void }
// 35:         def run
// 36:           selected_types = context.selected_types(args)
// 37:           raise UsageError, "`remove` supports only one type of entry at a time." if selected_types.count != 1
// 38:
// 39:           Homebrew::Bundle::Remover.remove(
// 40:             *args.named,
// 41:             type:   selected_types.first,
// 42:             global: context.global,
// 43:             file:   context.file,
// 44:           )
// 45:         end
// 46:       end
// 47:     end
// 48:   end
// 49: end
