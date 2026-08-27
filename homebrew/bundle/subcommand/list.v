module subcommand

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand/list.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 38.
pub fn ruby_list_l38_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "bundle/extensions/extension"
// 6:
// 7: require "bundle/brewfile"
// 8: require "bundle/lister"
// 9: module Homebrew
// 10:   module Cmd
// 11:     class Bundle < Homebrew::AbstractCommand
// 12:       class ListSubcommand < Homebrew::AbstractSubcommand
// 13:         subcommand_args do
// 14:           usage_banner <<~EOS
// 15:             `brew bundle list`:
// 16:             List all dependencies present in the `Brewfile`.
// 17:
// 18:             By default, only Homebrew formula dependencies are listed.
// 19:           EOS
// 20:           named_args :none
// 21:           switch "--install",
// 22:                  description: "Run `install` before listing dependencies."
// 23:           switch "--all",
// 24:                  description: "List all dependencies."
// 25:           switch "--formula", "--formulae", "--brews",
// 26:                  description: "List Homebrew formula dependencies."
// 27:           switch "--cask", "--casks",
// 28:                  description: "List Homebrew cask dependencies."
// 29:           switch "--tap", "--taps",
// 30:                  description: "List Homebrew tap dependencies."
// 31:           Homebrew::Bundle.extensions.each do |extension|
// 32:             switch "--#{extension.flag}",
// 33:                    description: extension.switch_description("List #{extension.banner_name}.")
// 34:           end
// 35:         end
// 36:
// 37:         sig { override.void }
// 38:         def run
// 39:           Homebrew::Bundle::Lister.list(
// 40:             Homebrew::Bundle::Brewfile.read(global: context.global, file: context.file).entries,
// 41:             formulae:        args.formulae? || args.all? || context.no_type_args,
// 42:             casks:           args.casks? || args.all?,
// 43:             taps:            args.taps? || args.all?,
// 44:             extension_types: context.extensions.to_h do |extension|
// 45:               [extension.type, context.extension_selected?(args, extension) || args.all?]
// 46:             end,
// 47:           )
// 48:         end
// 49:       end
// 50:     end
// 51:   end
// 52: end
