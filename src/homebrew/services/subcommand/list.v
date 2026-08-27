module subcommand

import brew_runtime

// Translated from Homebrew/brew `services/subcommand/list.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 25.
pub fn ruby_list_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `self.print_json(formulae)` at line 47.
pub fn ruby_list_l47_d2_self_print_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.print_json', ...args)
}

// Ruby method `self.print_table(formulae)` at line 58.
pub fn ruby_list_l58_d3_self_print_table(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.print_table', ...args)
}

// Ruby method `self.get_status_string(status)` at line 89.
pub fn ruby_list_l89_d4_self_get_status_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.get_status_string', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: require "services/cli"
// 7: require "services/formulae"
// 8: require "utils/output"
// 9: module Homebrew
// 10:   module Cmd
// 11:     class Services < Homebrew::AbstractCommand
// 12:       class ListSubcommand < Homebrew::AbstractSubcommand
// 13:         subcommand_args aliases: ["ls"], default: true do
// 14:           usage_banner <<~EOS
// 15:             [`sudo`] `brew services` [`list`] [`--json`] [`--debug`]:
// 16:             List information about all managed services for the current user (or root).
// 17:             Provides more output from Homebrew and `launchctl`(1) or `systemctl`(1) if run with `--debug`.
// 18:           EOS
// 19:           named_args :none
// 20:           switch "--json",
// 21:                  description: "Output as JSON."
// 22:         end
// 23:
// 24:         sig { override.void }
// 25:         def run
// 26:           formulae = Homebrew::Services::Formulae.services_list
// 27:           if formulae.blank?
// 28:             opoo "No services available to control with `#{Homebrew::Services::Cli.bin}`" if $stderr.tty?
// 29:             puts "[]" if args.json?
// 30:             return
// 31:           end
// 32:
// 33:           if args.json?
// 34:             self.class.print_json(formulae)
// 35:           else
// 36:             self.class.print_table(formulae)
// 37:           end
// 38:         end
// 39:
// 40:         extend Utils::Output::Mixin
// 41:
// 42:         JSON_FIELDS = [:name, :status, :user, :file, :exit_code].freeze
// 43:
// 44:         # Print the JSON representation in the CLI
// 45:         # @private
// 46:         sig { params(formulae: T::Array[T::Hash[Symbol, T.untyped]]).void }
// 47:         def self.print_json(formulae)
// 48:           services = formulae.map do |formula|
// 49:             formula.slice(*JSON_FIELDS)
// 50:           end
// 51:
// 52:           puts JSON.pretty_generate(services)
// 53:         end
// 54:
// 55:         # Print the table in the CLI
// 56:         # @private
// 57:         sig { params(formulae: T::Array[T::Hash[Symbol, T.untyped]]).void }
// 58:         def self.print_table(formulae)
// 59:           services = formulae.map do |formula|
// 60:             status = T.must(get_status_string(formula[:status]))
// 61:             status += formula[:exit_code].to_s if formula[:status] == :error
// 62:             file    = formula[:file].to_s.gsub(Dir.home, "~").presence if formula[:loaded]
// 63:
// 64:             { name: formula[:name], status:, user: formula[:user], file: }
// 65:           end
// 66:
// 67:           longest_name = [*services.map { |service| service[:name].length }, 4].max
// 68:           longest_status = [*services.map { |service| service[:status].length }, 15].max
// 69:           longest_user = [*services.map { |service| service[:user]&.length }, 4].compact.max
// 70:
// 71:           # `longest_status` includes 9 color characters from `Tty.color` and `Tty.reset`.
// 72:           # We don't have these in the header row, so we don't need to add the extra padding.
// 73:           headers = "#{Tty.bold}%-#{longest_name}.#{longest_name}<name>s " \
// 74:                     "%-#{longest_status - 9}.#{longest_status - 9}<status>s " \
// 75:                     "%-#{longest_user}.#{longest_user}<user>s %<file>s#{Tty.reset}"
// 76:           row = "%-#{longest_name}.#{longest_name}<name>s " \
// 77:                 "%-#{longest_status}.#{longest_status}<status>s " \
// 78:                 "%-#{longest_user}.#{longest_user}<user>s %<file>s"
// 79:
// 80:           puts format(headers, name: "Name", status: "Status", user: "User", file: "File")
// 81:           services.each do |service|
// 82:             puts format(row, **service)
// 83:           end
// 84:         end
// 85:
// 86:         # Get formula status output
// 87:         # @private
// 88:         sig { params(status: Symbol).returns(T.nilable(String)) }
// 89:         def self.get_status_string(status)
// 90:           case status
// 91:           when :started, :scheduled then "#{Tty.green}#{status}#{Tty.reset}"
// 92:           when :stopped, :none then "#{Tty.default}#{status}#{Tty.reset}"
// 93:           when :error   then "#{Tty.red}error  #{Tty.reset}"
// 94:           when :unknown then "#{Tty.yellow}unknown#{Tty.reset}"
// 95:           when :other then "#{Tty.yellow}other#{Tty.reset}"
// 96:           end
// 97:         end
// 98:       end
// 99:     end
// 100:   end
// 101: end
