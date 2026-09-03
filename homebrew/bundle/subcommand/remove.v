module subcommand

import brew_runtime
import homebrew.bundle

// Translated from Homebrew/brew `bundle/subcommand/remove.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 35.
pub fn ruby_remove_l35_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'items, selected type, and Brewfile are required')
	}
	items := if args[0].type_name == 'Array' {
		args[0].as_array() or { [] }.map(it.as_string())
	} else {
		[args[0].as_string()]
	}
	selected_types := args[1].as_string_array() or { [args[1].as_string()] }
	packages := if args.len > 3 {
		subcommand_remove_packages_from_value(args[3])
	} else {
		[]bundle.BundlePackage{}
	}
	result := run_bundle_remove(BundleRemoveCommandOptions{
		items: items
		selected_types: selected_types
		file: args[2].as_string()
		packages: packages
	}) or { return brew_runtime.object_value('UsageError', err.msg()) }
	return brew_runtime.structured_value('Bundle::RemoveSubcommand::Result', result.path, {
		'path':    result.path
		'content': result.content
		'removed': result.removed.join(',')
		'warning': result.warning
	})
}

pub struct BundleRemoveCommandOptions {
pub:
	items          []string
	selected_types []string
	file           string
	packages       []bundle.BundlePackage
}

pub fn run_bundle_remove(options BundleRemoveCommandOptions) !bundle.BundleRemoveResult {
	if options.selected_types.len != 1 {
		return error('`remove` supports only one type of entry at a time.')
	}
	return bundle.remove_bundle_entries(options.file, options.items, options.selected_types[0], options.packages)
}

fn subcommand_remove_packages_from_value(value brew_runtime.Value) []bundle.BundlePackage {
	values := value.as_array() or { [] }
	return values.map(bundle.BundlePackage{
		kind: if (it.attribute('kind') or { 'formula' }) == 'cask' { .cask } else { .formula }
		name: it.attribute('name') or { it.as_string() }
		full_name: it.attribute('full_name') or { it.as_string() }
		aliases: (it.attribute('aliases') or { '' }).split(',').filter(it != '')
		oldnames: (it.attribute('oldnames') or { '' }).split(',').filter(it != '')
		desc: it.attribute('desc') or { '' }
	})
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
