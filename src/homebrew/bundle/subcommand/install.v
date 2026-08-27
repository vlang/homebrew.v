module subcommand

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand/install.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 58.
pub fn ruby_install_l58_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `dsl` at line 104.
pub fn ruby_install_l104_d2_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dsl', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: require "bundle/brewfile"
// 7: require "bundle/installer"
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Bundle < Homebrew::AbstractCommand
// 11:       class InstallSubcommand < Homebrew::AbstractSubcommand
// 12:         subcommand_args alias_options: { "upgrade" => "--upgrade" }, default: true do
// 13:           usage_banner <<~EOS
// 14:             `brew bundle` [`install`|`upgrade`]:
// 15:             Install and upgrade (by default) all dependencies from the `Brewfile`.
// 16:
// 17:             Use this to restore a recorded installed state from a `Brewfile`.
// 18:
// 19:             `brew bundle upgrade` is shorthand for `brew bundle install --upgrade`.
// 20:
// 21:             You can specify the `Brewfile` location using `--file` or by setting the `$HOMEBREW_BUNDLE_FILE` environment variable.
// 22:
// 23:             You can skip the installation of dependencies by adding space-separated values to one or more of the following environment variables: `$HOMEBREW_BUNDLE_BREW_SKIP`, `$HOMEBREW_BUNDLE_CASK_SKIP`, `$HOMEBREW_BUNDLE_MAS_SKIP`, `$HOMEBREW_BUNDLE_TAP_SKIP`.
// 24:           EOS
// 25:           named_args :none
// 26:           switch "-v", "--verbose",
// 27:                  description: "Print output from commands as they are run."
// 28:           switch "--no-upgrade",
// 29:                  description: "Do not run `brew upgrade` on outdated dependencies. " \
// 30:                               "Note they may still be upgraded by `brew install` if needed.",
// 31:                  env:         :bundle_no_upgrade
// 32:           switch "--upgrade",
// 33:                  description: "Run `brew upgrade` on outdated dependencies, " \
// 34:                               "even if `$HOMEBREW_BUNDLE_NO_UPGRADE` is set."
// 35:           flag   "--upgrade-formulae=", "--upgrade-formula=",
// 36:                  description: "Run `brew upgrade` on any of these comma-separated formulae, " \
// 37:                               "even if `$HOMEBREW_BUNDLE_NO_UPGRADE` is set."
// 38:           # odeprecated: change default for 5.2 and document HOMEBREW_BUNDLE_JOBS
// 39:           flag "--jobs=",
// 40:                description: "Run up to this many formula installations in parallel. " \
// 41:                             "Defaults to 1 (sequential). Use `auto` for the number of CPU cores (max 4)."
// 42:           switch "-f", "--force",
// 43:                  description: "Run with `--force`/`--overwrite`."
// 44:           switch "--cleanup",
// 45:                  description: "Ask to perform cleanup after installing dependencies. Requires `--force`, " \
// 46:                               "`--force-cleanup` or `$HOMEBREW_ASK`.",
// 47:                  env:         [:bundle_install_cleanup, "--global"],
// 48:                  odeprecated: true
// 49:           switch "--force-cleanup",
// 50:                  description: "Perform cleanup after installing dependencies without asking.",
// 51:                  env:         [:bundle_force_install_cleanup, "--global"]
// 52:           switch "--zap",
// 53:                  description: "Use `zap` instead of `uninstall` when cleaning up casks after " \
// 54:                               "installing dependencies."
// 55:         end
// 56:
// 57:         sig { override.void }
// 58:         def run
// 59:           if args.zap? && !args.cleanup? && !args.force_cleanup?
// 60:             raise UsageError, "`--zap` cannot be passed without `--cleanup` or `--force-cleanup`."
// 61:           end
// 62:
// 63:           if args.cleanup? && !context.force && !args.force_cleanup? && !context.ask
// 64:             raise UsageError, "`brew bundle install --cleanup` requires `--force`, `--force-cleanup` " \
// 65:                               "or `$HOMEBREW_ASK`."
// 66:           end
// 67:
// 68:           @dsl = Homebrew::Bundle::Brewfile.read(global: context.global, file: context.file)
// 69:           result = Homebrew::Bundle::Installer.install!(
// 70:             @dsl.entries,
// 71:             global:     context.global,
// 72:             file:       context.file,
// 73:             no_lock:    false,
// 74:             no_upgrade: context.no_upgrade,
// 75:             verbose:    context.verbose,
// 76:             force:      context.force,
// 77:             jobs:       context.jobs,
// 78:             quiet:      quiet || args.quiet?,
// 79:           )
// 80:
// 81:           # Mark Brewfile formulae as installed_on_request to prevent autoremove
// 82:           # from removing them when their dependents are uninstalled
// 83:           Homebrew::Bundle.mark_as_installed_on_request!(@dsl.entries)
// 84:
// 85:           result || exit(1)
// 86:
// 87:           return unless cleanup
// 88:
// 89:           cleanup_requested = args.force_cleanup? || args.cleanup?
// 90:           return unless cleanup_requested
// 91:
// 92:           require "bundle/subcommand/cleanup"
// 93:
// 94:           # Don't need to reset cleanup specifically but this resets all the dumper modules.
// 95:           Homebrew::Cmd::Bundle::CleanupSubcommand.reset!
// 96:           Homebrew::Cmd::Bundle::CleanupSubcommand.cleanup(
// 97:             global: context.global, file: context.file, zap: context.zap,
// 98:             force: context.force || args.force_cleanup?,
// 99:             ask: context.ask, dsl:
// 100:           )
// 101:         end
// 102:
// 103:         sig { returns(T.nilable(Homebrew::Bundle::Dsl)) }
// 104:         def dsl
// 105:           @dsl ||= T.let(nil, T.nilable(Homebrew::Bundle::Dsl))
// 106:           @dsl
// 107:         end
// 108:       end
// 109:     end
// 110:   end
// 111: end
