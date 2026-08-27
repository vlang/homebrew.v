module subcommand

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand/add.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 46.
pub fn ruby_add_l46_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "bundle/extensions/extension"
// 6:
// 7: require "bundle/adder"
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Bundle < Homebrew::AbstractCommand
// 11:       class AddSubcommand < Homebrew::AbstractSubcommand
// 12:         subcommand_args do
// 13:           extensions = Homebrew::Bundle.extensions
// 14:           usage_banner <<~EOS
// 15:             `brew bundle add` <name> [...]:
// 16:             Add entries to your `Brewfile`. Adds formulae by default. Use #{["`--cask`", "`--tap`", *extensions.select(&:add_supported?).map { |extension| "`--#{extension.flag}`" }].to_sentence} to add the corresponding entry instead.
// 17:           EOS
// 18:           named_args min: 1
// 19:           switch "--install",
// 20:                  description: "Run `install` before adding entries."
// 21:           switch "--formula", "--formulae", "--brews",
// 22:                  description: "Add Homebrew formula entries."
// 23:           switch "--cask", "--casks",
// 24:                  description: "Add Homebrew cask entries."
// 25:           switch "--tap", "--taps",
// 26:                  description: "Add Homebrew tap entries."
// 27:           extensions.select(&:add_supported?).each do |extension|
// 28:             switch "--#{extension.flag}",
// 29:                    description: extension.switch_description("Add entries for #{extension.banner_name}.")
// 30:           end
// 31:           switch "--no-describe",
// 32:                  description: "Do not add description comments above each line. Description comments are " \
// 33:                               "the default.",
// 34:                  env:         :bundle_no_describe
// 35:           switch "--describe",
// 36:                  description: "Add a description comment above each line, unless the " \
// 37:                               "dependency does not have a description. This is the default unless " \
// 38:                               "`$HOMEBREW_BUNDLE_NO_DESCRIBE` is set.",
// 39:                  env:         :bundle_describe,
// 40:                  replacement: "the default behaviour",
// 41:                  odeprecated: true
// 42:           conflicts "--describe", "--no-describe"
// 43:         end
// 44:
// 45:         sig { override.void }
// 46:         def run
// 47:           selected_types = context.selected_types(args)
// 48:           raise UsageError, "`add` supports only one type of entry at a time." if selected_types.count != 1
// 49:
// 50:           type = case (t = selected_types.first)
// 51:           when :none then :brew
// 52:           when :mas then raise UsageError, "`add` does not support `--mas`."
// 53:           else t
// 54:           end
// 55:
// 56:           extension = Homebrew::Bundle.extension(type)
// 57:           if extension && !extension.add_supported?
// 58:             raise UsageError,
// 59:                   "`add` does not support `--#{extension.flag}`."
// 60:           end
// 61:
// 62:           Homebrew::Bundle::Adder.add(
// 63:             *args.named,
// 64:             type:,
// 65:             global:   context.global,
// 66:             file:     context.file,
// 67:             describe: args.describe? && !args.no_describe?,
// 68:           )
// 69:         end
// 70:       end
// 71:     end
// 72:   end
// 73: end
