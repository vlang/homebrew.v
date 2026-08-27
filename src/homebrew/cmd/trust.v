module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/trust.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 37.
pub fn ruby_trust_l37_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `print_json` at line 79.
pub fn ruby_trust_l79_d2_print_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_json', ...args)
}

// Ruby method `types` at line 96.
pub fn ruby_trust_l96_d3_types(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('types', ...args)
}

// Ruby method `selected_type` at line 104.
pub fn ruby_trust_l104_d4_selected_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('selected_type', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "json"
// 6: require "trust"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Trust < AbstractCommand
// 11:       VALID_TYPES = [:tap, :formula, :cask, :command].freeze
// 12:
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Trust non-official tap formulae, casks or commands so Homebrew may load them.
// 16:           Trusted entries are stored in `${XDG_CONFIG_HOME}/homebrew/trust.json` if
// 17:           `$XDG_CONFIG_HOME` is set or `~/.homebrew/trust.json` otherwise.
// 18:         EOS
// 19:         switch "--tap", "--taps",
// 20:                description: "Trust the named tap."
// 21:         switch "--formula", "--formulae",
// 22:                description: "Trust the named formula."
// 23:         switch "--cask", "--casks",
// 24:                description: "Trust the named cask."
// 25:         switch "--command", "--commands",
// 26:                description: "Trust the named external command."
// 27:         flag "--json=",
// 28:              description: "Print trusted entries as JSON. A <version> number is required. " \
// 29:                           "The only accepted value for <version> is `v1`."
// 30:
// 31:         conflicts "--tap", "--formula", "--cask", "--command"
// 32:
// 33:         named_args :target
// 34:       end
// 35:
// 36:       sig { override.void }
// 37:       def run
// 38:         if args.json
// 39:           raise UsageError, "invalid JSON version: #{args.json}" if args.json != "v1"
// 40:           raise UsageError, "`--json=v1` requires no named arguments." if args.named.present?
// 41:
// 42:           print_json
// 43:           return
// 44:         end
// 45:
// 46:         if args.no_named?
// 47:           puts "All official taps and commands are trusted."
// 48:           printed = T.let(false, T::Boolean)
// 49:           types.each do |type|
// 50:             values = Homebrew::Trust.trusted_entries(type)
// 51:             next if values.empty?
// 52:
// 53:             label = Utils.pluralize(type.to_s, 2)
// 54:             puts "Trusted #{label}:"
// 55:             values.each { |value| puts "  #{value}" }
// 56:             printed = true
// 57:           end
// 58:
// 59:           puts "No trusted taps, formulae, casks or commands." unless printed
// 60:           return
// 61:         end
// 62:
// 63:         args.named.each do |name|
// 64:           type, trust_name = Homebrew::Trust.target(name, type: selected_type)
// 65:           if type == :tap && !Tap.remote_reference?(trust_name) && Tap.fetch(trust_name).official?
// 66:             puts "Official tap #{trust_name} is always trusted."
// 67:             next
// 68:           end
// 69:
// 70:           action = Homebrew::Trust.trust!(type, trust_name) ? "Trusted" : "Already trusted"
// 71:
// 72:           puts "#{action} #{type}: #{trust_name}"
// 73:         end
// 74:       end
// 75:
// 76:       private
// 77:
// 78:       sig { void }
// 79:       def print_json
// 80:         if (type = selected_type)
// 81:           puts JSON.pretty_generate(Homebrew::Trust.trusted_entries(type))
// 82:           return
// 83:         end
// 84:
// 85:         json = T.let({}, T::Hash[String, T::Array[String]])
// 86:
// 87:         types.each do |type|
// 88:           key = Utils.pluralize(type.to_s, 2)
// 89:           json[key] = Homebrew::Trust.trusted_entries(type)
// 90:         end
// 91:
// 92:         puts JSON.pretty_generate(json)
// 93:       end
// 94:
// 95:       sig { returns(T::Array[Symbol]) }
// 96:       def types
// 97:         type = selected_type
// 98:         return [type] if type
// 99:
// 100:         VALID_TYPES
// 101:       end
// 102:
// 103:       sig { returns(T.nilable(Symbol)) }
// 104:       def selected_type
// 105:         return :tap if args.tap?
// 106:         return :formula if args.formula?
// 107:         return :cask if args.cask?
// 108:
// 109:         :command if args.command? || args.commands?
// 110:       end
// 111:     end
// 112:   end
// 113: end
