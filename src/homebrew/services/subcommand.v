module services

import brew_runtime

// Translated from Homebrew/brew `services/subcommand.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `dispatch(args)` at line 22.
pub fn ruby_subcommand_l22_d1_dispatch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dispatch', ...args)
}

// Ruby method `targets(args, subcommand:, formulae:)` at line 76.
pub fn ruby_subcommand_l76_d2_targets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('targets', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "cli/parser"
// 6: require "services/cli"
// 7: require "services/formulae"
// 8: require "services/system"
// 9: require "utils/output"
// 10:
// 11: Dir["#{__dir__}/subcommand/*.rb"].each do |subcommand|
// 12:   require "services/subcommand/#{File.basename(subcommand, ".rb")}"
// 13: end
// 14:
// 15: module Homebrew
// 16:   module Cmd
// 17:     class Services < Homebrew::AbstractCommand
// 18:       extend Utils::Output::Mixin
// 19:
// 20:       class << self
// 21:         sig { params(args: T.untyped).void }
// 22:         def dispatch(args)
// 23:           # pbpaste's exit status is a proxy for detecting the use of reattach-to-user-namespace
// 24:           if ENV.fetch("HOMEBREW_TMUX", nil) && File.exist?("/usr/bin/pbpaste") && !quiet_system("/usr/bin/pbpaste")
// 25:             raise UsageError,
// 26:                   "`brew services` cannot run under tmux!"
// 27:           end
// 28:
// 29:           # Keep this after the .parse to keep --help fast.
// 30:           require "utils"
// 31:
// 32:           if !Homebrew::Services::System.launchctl? && !Homebrew::Services::System.systemctl?
// 33:             raise UsageError, Homebrew::Services::System::MISSING_DAEMON_MANAGER_EXCEPTION_MESSAGE
// 34:           end
// 35:
// 36:           if (sudo_service_user = args.sudo_service_user)
// 37:             unless Homebrew::Services::System.root?
// 38:               raise UsageError,
// 39:                     "`brew services --sudo-service-user` is supported only when running as root!"
// 40:             end
// 41:
// 42:             unless Homebrew::Services::System.launchctl?
// 43:               raise UsageError,
// 44:                     "`brew services --sudo-service-user` is currently supported only on macOS " \
// 45:                     "(but we'd love a PR to add Linux support)!"
// 46:             end
// 47:
// 48:             Homebrew::Services::Cli.sudo_service_user = sudo_service_user
// 49:           end
// 50:
// 51:           subcommand = args.subcommand
// 52:           formulae = args.named
// 53:
// 54:           opoo "The `--all` argument overrides provided formula argument!" if formulae.present? && args.all?
// 55:
// 56:           targets = targets(args, subcommand:, formulae:)
// 57:
// 58:           # Exit successfully if --all was used but there is nothing to do
// 59:           return if args.all? && targets.empty?
// 60:
// 61:           if Homebrew::Services::System.systemctl?
// 62:             ENV["DBUS_SESSION_BUS_ADDRESS"] = ENV.fetch("HOMEBREW_DBUS_SESSION_BUS_ADDRESS", nil)
// 63:             ENV["XDG_RUNTIME_DIR"] = ENV.fetch("HOMEBREW_XDG_RUNTIME_DIR", nil)
// 64:           end
// 65:
// 66:           subcommand_class = Homebrew::AbstractSubcommand.subcommands_for(Homebrew::Cmd::Services).find do |candidate|
// 67:             candidate.subcommand_name == subcommand
// 68:           end
// 69:           T.must(subcommand_class).new(args, targets:).run
// 70:         end
// 71:
// 72:         sig {
// 73:           params(args: T.untyped, subcommand: String,
// 74:                  formulae: T::Array[String]).returns(T::Array[Homebrew::Services::FormulaWrapper])
// 75:         }
// 76:         def targets(args, subcommand:, formulae:)
// 77:           if args.all?
// 78:             if subcommand == "start"
// 79:               Homebrew::Services::Formulae.available_services(
// 80:                 loaded:    false,
// 81:                 skip_root: !Homebrew::Services::System.root?,
// 82:               )
// 83:             elsif subcommand == "stop"
// 84:               Homebrew::Services::Formulae.available_services(
// 85:                 loaded:    true,
// 86:                 skip_root: !Homebrew::Services::System.root?,
// 87:               )
// 88:             else
// 89:               Homebrew::Services::Formulae.available_services
// 90:             end
// 91:           elsif formulae.present?
// 92:             formulae.map { |formula| Homebrew::Services::FormulaWrapper.new(Formulary.factory(formula)) }
// 93:           else
// 94:             []
// 95:           end
// 96:         end
// 97:       end
// 98:     end
// 99:   end
// 100: end
