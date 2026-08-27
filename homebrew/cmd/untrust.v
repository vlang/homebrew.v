module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/untrust.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 31.
pub fn ruby_untrust_l31_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `selected_type` at line 105.
pub fn ruby_untrust_l105_d2_selected_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('selected_type', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "trust"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Untrust < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Stop trusting non-official tap formulae, casks or commands.
// 13:           Trusted entries are stored in `${XDG_CONFIG_HOME}/homebrew/trust.json` if
// 14:           `$XDG_CONFIG_HOME` is set or `~/.homebrew/trust.json` otherwise.
// 15:         EOS
// 16:         switch "--tap",
// 17:                description: "Untrust the named tap."
// 18:         switch "--formula", "--formulae",
// 19:                description: "Untrust the named formula."
// 20:         switch "--cask", "--casks",
// 21:                description: "Untrust the named cask."
// 22:         switch "--command", "--commands",
// 23:                description: "Untrust the named external command."
// 24:
// 25:         conflicts "--tap", "--formula", "--cask", "--command"
// 26:
// 27:         named_args :target
// 28:       end
// 29:
// 30:       sig { override.void }
// 31:       def run
// 32:         if args.no_named?
// 33:           types = selected_type ? [selected_type] : [:tap, :formula, :cask, :command]
// 34:           printed = T.let(false, T::Boolean)
// 35:           types.each do |type|
// 36:             values = Homebrew::Trust.untrusted_taps.flat_map do |tap|
// 37:               case type
// 38:               when :tap
// 39:                 [tap.name]
// 40:               when :formula
// 41:                 tap.formula_files.filter_map do |file|
// 42:                   name = file.basename(file.extname).to_s
// 43:                   full_name = "#{tap.name}/#{name}"
// 44:                   full_name unless Homebrew::Trust.trusted?(:formula, full_name)
// 45:                 end
// 46:               when :cask
// 47:                 tap.cask_files.filter_map do |file|
// 48:                   name = file.basename(file.extname).to_s
// 49:                   full_name = "#{tap.name}/#{name}"
// 50:                   full_name unless Homebrew::Trust.trusted?(:cask, full_name)
// 51:                 end
// 52:               when :command
// 53:                 tap.command_files.filter_map do |file|
// 54:                   name = file.basename(file.extname).to_s.delete_prefix("brew-")
// 55:                   full_name = "#{tap.name}/#{name}"
// 56:                   full_name unless Homebrew::Trust.trusted?(:command, full_name)
// 57:                 end
// 58:               else
// 59:                 raise "Unsupported trust type: #{type}"
// 60:               end
// 61:             end.sort
// 62:             next if values.empty?
// 63:
// 64:             label = case type
// 65:             when :tap then "taps"
// 66:             when :formula then "formulae"
// 67:             when :cask then "casks"
// 68:             when :command then "commands"
// 69:             else raise "Unsupported trust type: #{type}"
// 70:             end
// 71:             puts "Untrusted #{label}:"
// 72:             values.each { |value| puts "  #{value}" }
// 73:             printed = true
// 74:           end
// 75:
// 76:           puts "No untrusted taps, formulae, casks or commands." unless printed
// 77:           return
// 78:         end
// 79:
// 80:         args.named.each do |name|
// 81:           item_types = [:formula, :cask, :command]
// 82:           type, trust_name = Homebrew::Trust.target(name, type: selected_type, include_existing: true)
// 83:           if type == :tap && !Tap.remote_reference?(trust_name) && Tap.fetch(trust_name).official?
// 84:             puts "Official tap #{trust_name} is always trusted."
// 85:             next
// 86:           end
// 87:
// 88:           removed = Homebrew::Trust.untrust!(type, trust_name)
// 89:           if type == :tap
// 90:             item_types.each do |item_type|
// 91:               Homebrew::Trust.trusted_entries(item_type).each do |entry|
// 92:                 removed = true if entry.start_with?("#{trust_name}/") && Homebrew::Trust.untrust!(item_type, entry)
// 93:               end
// 94:             end
// 95:           end
// 96:           action = removed ? "Untrusted" : "Not trusted"
// 97:
// 98:           puts "#{action} #{type}: #{trust_name}"
// 99:         end
// 100:       end
// 101:
// 102:       private
// 103:
// 104:       sig { returns(T.nilable(Symbol)) }
// 105:       def selected_type
// 106:         return :tap if args.tap?
// 107:         return :formula if args.formula?
// 108:         return :cask if args.cask?
// 109:
// 110:         :command if args.command? || args.commands?
// 111:       end
// 112:     end
// 113:   end
// 114: end
