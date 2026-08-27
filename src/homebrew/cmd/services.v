module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/services.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 37.
pub fn ruby_services_l37_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Services < AbstractCommand
// 9:       require "services/subcommand"
// 10:
// 11:       cmd_args do
// 12:         usage_banner <<~EOS
// 13:           `services` [<subcommand>]
// 14:
// 15:           Manage background services with macOS' `launchctl`(1) daemon manager or
// 16:           Linux's `systemctl`(1) service manager.
// 17:
// 18:           If `sudo` is passed, operate on `/Library/LaunchDaemons` or `/usr/lib/systemd/system` (started at boot).
// 19:           Otherwise, operate on `~/Library/LaunchAgents` or `~/.config/systemd/user` (started at login).
// 20:
// 21:           Environment variables can be added or overridden for a service by creating
// 22:           `$HOMEBREW_USER_CONFIG_HOME/services/<formula>.env` (defaults to
// 23:           `~/.homebrew/services/<formula>.env`). The file uses `KEY=value`
// 24:           format, one per line; lines starting with `#` are comments. Changes take
// 25:           effect on the next `brew services restart` and persist across upgrades.
// 26:         EOS
// 27:         flag   "--sudo-service-user=",
// 28:                description: "When run as root on macOS, run the service(s) as this user."
// 29:
// 30:         Homebrew::AbstractSubcommand.define_all(self, command: Homebrew::Cmd::Services)
// 31:
// 32:         conflicts "--all", "--file"
// 33:         conflicts "--max-wait", "--no-wait"
// 34:       end
// 35:
// 36:       sig { override.void }
// 37:       def run
// 38:         Homebrew::Cmd::Services.dispatch(args)
// 39:       end
// 40:     end
// 41:   end
// 42: end
