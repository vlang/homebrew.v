module subcommand

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand/edit.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 21.
pub fn ruby_edit_l21_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	path := if args.len > 0 { args[0].as_string() } else { 'Brewfile' }
	editor := if args.len > 1 { args[1].as_string() } else { '' }
	plan := run_bundle_edit(path, editor)
	return brew_runtime.structured_value('Bundle::EditSubcommand::Plan', plan.path, {
		'path':   plan.path
		'editor': plan.editor
	})
}

pub struct BundleEditPlan {
pub:
	path   string
	editor string
}

pub fn run_bundle_edit(path string, editor string) BundleEditPlan {
	return BundleEditPlan{
		path: if path.trim_space() != '' { path } else { 'Brewfile' }
		editor: editor
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Bundle < Homebrew::AbstractCommand
// 9:       class EditSubcommand < Homebrew::AbstractSubcommand
// 10:         subcommand_args do
// 11:           usage_banner <<~EOS
// 12:             `brew bundle edit`:
// 13:             Edit the `Brewfile` in your editor.
// 14:           EOS
// 15:           named_args :none
// 16:           switch "--install",
// 17:                  description: "Run `install` before editing the `Brewfile`."
// 18:         end
// 19:
// 20:         sig { override.void }
// 21:         def run
// 22:           require "bundle/brewfile"
// 23:
// 24:           exec_editor(Homebrew::Bundle::Brewfile.path(global: context.global, file: context.file))
// 25:         end
// 26:       end
// 27:     end
// 28:   end
// 29: end
