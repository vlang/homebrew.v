module subcommand

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand/dump.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 77.
pub fn ruby_dump_l77_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "bundle/extensions/extension"
// 6:
// 7: require "bundle/dumper"
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Bundle < Homebrew::AbstractCommand
// 11:       class DumpSubcommand < Homebrew::AbstractSubcommand
// 12:         subcommand_args do
// 13:           extensions = Homebrew::Bundle.extensions
// 14:           usage_banner <<~EOS
// 15:             `brew bundle dump`:
// 16:             Write all installed casks/formulae/images/taps into a `Brewfile` in the current directory or to a custom file specified with the `--file` option. This is useful as an installed-state snapshot and can be kept in version control and diffed.
// 17:           EOS
// 18:           named_args :none
// 19:           switch "--install",
// 20:                  description: "Run `install` before dumping dependencies."
// 21:           switch "-f", "--force",
// 22:                  description: "Overwrite an existing `Brewfile`."
// 23:           switch "--formula", "--formulae", "--brews",
// 24:                  description: "Dump Homebrew formula dependencies."
// 25:           switch "--no-formula", "--no-formulae", "--no-brews",
// 26:                  description: "Dump without Homebrew formula dependencies. " \
// 27:                               "Enabled by default if `$HOMEBREW_BUNDLE_DUMP_NO_BREW` is set."
// 28:           switch "--no-dump-brew",
// 29:                  description: "Dump without Homebrew formula dependencies.",
// 30:                  env:         :bundle_dump_no_brew
// 31:           switch "--cask", "--casks",
// 32:                  description: "Dump Homebrew cask dependencies."
// 33:           switch "--no-cask", "--no-casks",
// 34:                  description: "Dump without Homebrew cask dependencies. " \
// 35:                               "Enabled by default if `$HOMEBREW_BUNDLE_DUMP_NO_CASK` is set."
// 36:           switch "--no-dump-cask",
// 37:                  description: "Dump without Homebrew cask dependencies.",
// 38:                  env:         :bundle_dump_no_cask
// 39:           switch "--tap", "--taps",
// 40:                  description: "Dump Homebrew tap dependencies."
// 41:           switch "--no-tap", "--no-taps",
// 42:                  description: "Dump without Homebrew tap dependencies. " \
// 43:                               "Enabled by default if `$HOMEBREW_BUNDLE_DUMP_NO_TAP` is set."
// 44:           switch "--no-dump-tap",
// 45:                  description: "Dump without Homebrew tap dependencies.",
// 46:                  env:         :bundle_dump_no_tap
// 47:           extensions.select(&:dump_supported?).each do |extension|
// 48:             switch "--#{extension.flag}",
// 49:                    description: extension.switch_description("Dump #{extension.banner_name}.")
// 50:           end
// 51:           extensions.select(&:dump_disable_supported?).each do |extension|
// 52:             env = "HOMEBREW_#{extension.dump_disable_env.to_s.upcase}"
// 53:             switch "--no-#{extension.flag}",
// 54:                    description: "#{extension.dump_disable_description} " \
// 55:                                 "Enabled by default if `$#{env}` is set."
// 56:             switch "--no-dump-#{extension.flag}",
// 57:                    description: extension.dump_disable_description,
// 58:                    env:         extension.dump_disable_env
// 59:           end
// 60:           switch "--no-describe",
// 61:                  description: "Do not add description comments above each line. Description comments are " \
// 62:                               "the default.",
// 63:                  env:         :bundle_no_describe
// 64:           switch "--describe",
// 65:                  description: "Add a description comment above each line, unless the " \
// 66:                               "dependency does not have a description. This is the default unless " \
// 67:                               "`$HOMEBREW_BUNDLE_NO_DESCRIBE` is set.",
// 68:                  env:         :bundle_describe,
// 69:                  replacement: "the default behaviour",
// 70:                  odeprecated: true
// 71:           conflicts "--describe", "--no-describe"
// 72:           switch "--no-restart",
// 73:                  description: "Do not add `restart_service` to formula lines."
// 74:         end
// 75:
// 76:         sig { override.void }
// 77:         def run
// 78:           core_type_options = context.core_type_options(args, "dump")
// 79:           Homebrew::Bundle::Dumper.dump_brewfile(
// 80:             global:          context.global,
// 81:             file:            context.file,
// 82:             describe:        args.describe? && !args.no_describe?,
// 83:             force:           context.force,
// 84:             no_restart:      args.no_restart?,
// 85:             taps:            core_type_options.fetch(:taps),
// 86:             formulae:        core_type_options.fetch(:formulae),
// 87:             casks:           core_type_options.fetch(:casks),
// 88:             extension_types: context.extensions.select(&:dump_supported?).to_h do |extension|
// 89:               disabled = extension.dump_disable_supported? &&
// 90:                          context.extension_dump_disabled?(args, extension)
// 91:               enabled = !disabled &&
// 92:                         (context.extension_selected?(args, extension) || context.no_type_args)
// 93:               [extension.type, enabled]
// 94:             end,
// 95:           )
// 96:         end
// 97:       end
// 98:     end
// 99:   end
// 100: end
