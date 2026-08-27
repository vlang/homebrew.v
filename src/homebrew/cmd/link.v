module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/link.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 31.
pub fn ruby_link_l31_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `puts_keg_only_path_message(keg)` at line 132.
pub fn ruby_link_l132_d2_puts_keg_only_path_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('puts_keg_only_path_message', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "caveats"
// 6: require "unlink"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Link < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Symlink all of <formula>'s installed files into Homebrew's prefix.
// 14:           This is done automatically when you install formulae but can be useful
// 15:           for manual installations.
// 16:         EOS
// 17:         switch "--overwrite",
// 18:                description: "Delete files that already exist in the prefix while linking."
// 19:         switch "-n", "--dry-run",
// 20:                description: "List files which would be linked or deleted by " \
// 21:                             "`brew link --overwrite` without actually linking or deleting any files."
// 22:         switch "-f", "--force",
// 23:                description: "Allow keg-only formulae to be linked."
// 24:         switch "--HEAD",
// 25:                description: "Link the HEAD version of the formula if it is installed."
// 26:
// 27:         named_args :installed_formula, min: 1
// 28:       end
// 29:
// 30:       sig { override.void }
// 31:       def run
// 32:         options = {
// 33:           overwrite: args.overwrite?,
// 34:           dry_run:   args.dry_run?,
// 35:           verbose:   args.verbose?,
// 36:         }
// 37:
// 38:         kegs = if args.HEAD?
// 39:           args.named.to_kegs.group_by(&:name).filter_map do |name, resolved_kegs|
// 40:             head_keg = resolved_kegs.find { |keg| keg.version.head? }
// 41:             next head_keg if head_keg.present?
// 42:
// 43:             opoo <<~EOS
// 44:               No HEAD keg installed for #{name}
// 45:               To install, run:
// 46:                 brew install --HEAD #{name}
// 47:             EOS
// 48:
// 49:             nil
// 50:           end
// 51:         else
// 52:           args.named.to_latest_kegs
// 53:         end
// 54:
// 55:         kegs.freeze.each do |keg|
// 56:           keg_only = Formulary.keg_only?(keg.rack)
// 57:           formula = begin
// 58:             keg.to_formula
// 59:           rescue FormulaUnavailableError
// 60:             # Not all kegs may belong to current formulae
// 61:             nil
// 62:           end
// 63:           versioned_keg_only_formula = formula.present? && formula.keg_only_reason&.versioned_formula?
// 64:
// 65:           if keg.linked?
// 66:             opoo "Already linked: #{keg}"
// 67:             name_and_flag = +""
// 68:             name_and_flag << "--HEAD " if args.HEAD?
// 69:             name_and_flag << "--force " if keg_only && !versioned_keg_only_formula
// 70:             name_and_flag << keg.name
// 71:             puts <<~EOS
// 72:               To relink, run:
// 73:                 brew unlink #{keg.name} && brew link #{name_and_flag}
// 74:             EOS
// 75:             next
// 76:           end
// 77:
// 78:           if args.dry_run?
// 79:             if args.overwrite?
// 80:               puts "Would remove:"
// 81:             else
// 82:               puts "Would link:"
// 83:             end
// 84:             keg.link(**options)
// 85:             puts_keg_only_path_message(keg) if keg_only && !versioned_keg_only_formula
// 86:             next
// 87:           end
// 88:
// 89:           if keg_only
// 90:             if HOMEBREW_PREFIX.to_s == HOMEBREW_DEFAULT_PREFIX && formula.present? &&
// 91:                formula.keg_only_reason.by_macos?
// 92:               caveats = Caveats.new(formula)
// 93:               opoo <<~EOS
// 94:                 Refusing to link macOS provided/shadowed software: #{keg.name}
// 95:                 #{T.must(caveats.keg_only_text(skip_reason: true)).strip}
// 96:               EOS
// 97:               next
// 98:             end
// 99:
// 100:             if !args.force? && (formula.nil? || !formula.keg_only_reason.versioned_formula?)
// 101:               opoo "#{keg.name} is keg-only and must be linked with `--force`."
// 102:               puts_keg_only_path_message(keg)
// 103:               next
// 104:             end
// 105:           end
// 106:
// 107:           Unlink.unlink_link_overwrite_formulae(formula, verbose: args.verbose?) if formula
// 108:
// 109:           keg.lock do
// 110:             print "Linking #{keg}... "
// 111:             puts if args.verbose?
// 112:
// 113:             begin
// 114:               n = keg.link(**options)
// 115:             rescue Keg::LinkError
// 116:               puts
// 117:               raise
// 118:             else
// 119:               puts "#{n} symlinks created."
// 120:             end
// 121:
// 122:             if keg_only && !versioned_keg_only_formula && !Homebrew::EnvConfig.developer?
// 123:               puts_keg_only_path_message(keg)
// 124:             end
// 125:           end
// 126:         end
// 127:       end
// 128:
// 129:       private
// 130:
// 131:       sig { params(keg: Keg).void }
// 132:       def puts_keg_only_path_message(keg)
// 133:         bin = keg/"bin"
// 134:         sbin = keg/"sbin"
// 135:         return if !bin.directory? && !sbin.directory?
// 136:
// 137:         opt = HOMEBREW_PREFIX/"opt/#{keg.name}"
// 138:         puts "\nIf you need to have this software first in your PATH instead consider running:"
// 139:         puts "  #{Utils::Shell.prepend_path_in_profile(opt/"bin")}"  if bin.directory?
// 140:         puts "  #{Utils::Shell.prepend_path_in_profile(opt/"sbin")}" if sbin.directory?
// 141:       end
// 142:     end
// 143:   end
// 144: end
