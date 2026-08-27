module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/cleanup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 34.
pub fn ruby_cleanup_l34_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "cleanup"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class CleanupCmd < AbstractCommand
// 10:       cmd_args do
// 11:         days = Homebrew::EnvConfig::ENVS[:HOMEBREW_CLEANUP_MAX_AGE_DAYS]&.dig(:default)
// 12:         description <<~EOS
// 13:           Remove stale lock files and outdated downloads for all formulae and casks,
// 14:           and remove old versions of installed formulae. If arguments are specified,
// 15:           only do this for the given formulae and casks. Removes all downloads more than
// 16:           #{days} days old. This can be adjusted with `$HOMEBREW_CLEANUP_MAX_AGE_DAYS`.
// 17:         EOS
// 18:         flag   "--prune=",
// 19:                description: "Remove all cache files older than specified <days>. " \
// 20:                             "If you want to remove everything, use `--prune=all`."
// 21:         switch "-n", "--dry-run",
// 22:                description: "Show what would be removed, but do not actually remove anything."
// 23:         switch "-s", "--scrub",
// 24:                description: "Scrub the cache, including downloads for even the latest versions. " \
// 25:                             "Note that downloads for any installed formulae or casks will still not be deleted. " \
// 26:                             "If you want to delete those too: `rm -rf \"$(brew --cache)\"`"
// 27:         switch "--prune-prefix",
// 28:                description: "Only prune the symlinks and directories from the prefix and remove no other files."
// 29:
// 30:         named_args [:formula, :cask]
// 31:       end
// 32:
// 33:       sig { override.void }
// 34:       def run
// 35:         days = args.prune.presence&.then do |prune|
// 36:           case prune
// 37:           when /\A\d+\Z/
// 38:             prune.to_i
// 39:           when "all"
// 40:             0
// 41:           else
// 42:             raise UsageError, "`--prune` expects an integer or `all`."
// 43:           end
// 44:         end
// 45:
// 46:         cleanup = Cleanup.new(*args.named, dry_run: args.dry_run?, scrub: args.s?, days:)
// 47:         if args.prune_prefix?
// 48:           cleanup.prune_prefix_symlinks_and_directories
// 49:           return
// 50:         end
// 51:
// 52:         cleanup.clean!(quiet: args.quiet?, periodic: false)
// 53:
// 54:         unless cleanup.disk_cleanup_size.zero?
// 55:           disk_space = Formatter.disk_usage_readable(cleanup.disk_cleanup_size)
// 56:           if args.dry_run?
// 57:             ohai "This operation would free approximately #{disk_space} of disk space."
// 58:           else
// 59:             ohai "This operation has freed approximately #{disk_space} of disk space."
// 60:           end
// 61:         end
// 62:
// 63:         return if cleanup.unremovable_kegs.empty?
// 64:
// 65:         ofail <<~EOS
// 66:           Could not cleanup old kegs! Fix your permissions on:
// 67:             #{cleanup.unremovable_kegs.join "\n  "}
// 68:         EOS
// 69:       end
// 70:     end
// 71:   end
// 72: end
