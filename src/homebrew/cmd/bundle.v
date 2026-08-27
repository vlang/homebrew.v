module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/bundle.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 61.
pub fn ruby_bundle_l61_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Bundle < AbstractCommand
// 11:       require "bundle/subcommand"
// 12:
// 13:       BUNDLE_EXTENSIONS = T.let(Homebrew::Bundle.extensions.dup.freeze, T::Array[T.class_of(Homebrew::Bundle::Extension)])
// 14:       BUNDLE_SOURCES_DESCRIPTION = T.let(
// 15:         [
// 16:           "Homebrew formulae",
// 17:           "Homebrew casks",
// 18:           *BUNDLE_EXTENSIONS.map(&:banner_name),
// 19:         ].to_sentence.freeze,
// 20:         String,
// 21:       )
// 22:
// 23:       cmd_args do
// 24:         usage_banner <<~EOS
// 25:           `bundle` [<subcommand>]
// 26:
// 27:           Bundler for non-Ruby dependencies from #{BUNDLE_SOURCES_DESCRIPTION}.
// 28:
// 29:           Note: Flatpak support is only available on Linux.
// 30:         EOS
// 31:         flag "--file=",
// 32:              description: "Read from or write to the `Brewfile` from this location. " \
// 33:                           "Use `--file=-` to pipe to stdin/stdout."
// 34:         switch "-g", "--global",
// 35:                description: "Read from or write to the `Brewfile` from `$HOMEBREW_BUNDLE_FILE_GLOBAL` " \
// 36:                             "(if set), `${XDG_CONFIG_HOME}/homebrew/Brewfile` " \
// 37:                             "(if `$XDG_CONFIG_HOME` is set), `~/.homebrew/Brewfile` or `~/.Brewfile` otherwise."
// 38:
// 39:         Homebrew::AbstractSubcommand.define_all(self, command: Homebrew::Cmd::Bundle)
// 40:
// 41:         [
// 42:           [%w[--formula --formulae --brews], %w[--no-formula --no-formulae --no-brews], "--no-brew"],
// 43:           [%w[--cask --casks], %w[--no-cask --no-casks], "--no-cask"],
// 44:           [%w[--tap --taps], %w[--no-tap --no-taps], "--no-tap"],
// 45:         ].each do |enabled_flags, disabled_flags, env_disabled_flag|
// 46:           type = env_disabled_flag.delete_prefix("--no-")
// 47:           enabled_flags.product([*disabled_flags, "--no-cleanup-#{type}", "--no-dump-#{type}"]) do |enabled_flag,
// 48:                                                                                                      disabled_flag|
// 49:             conflicts enabled_flag, disabled_flag
// 50:           end
// 51:         end
// 52:         BUNDLE_EXTENSIONS.select(&:dump_disable_supported?).each do |extension|
// 53:           conflicts "--#{extension.flag}", "--no-#{extension.flag}"
// 54:           conflicts "--#{extension.flag}", "--no-cleanup-#{extension.flag}"
// 55:           conflicts "--#{extension.flag}", "--no-dump-#{extension.flag}"
// 56:         end
// 57:         conflicts "--file", "--global"
// 58:       end
// 59:
// 60:       sig { override.void }
// 61:       def run
// 62:         # Keep this inside `run` to keep --help fast.
// 63:         require "bundle"
// 64:
// 65:         Homebrew::Cmd::Bundle.dispatch(args, extensions: BUNDLE_EXTENSIONS)
// 66:       end
// 67:     end
// 68:   end
// 69: end
