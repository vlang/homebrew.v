module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/untap.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 25.
pub fn ruby_untap_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `installed_formulae_for(tap:)` at line 108.
pub fn ruby_untap_l108_d2_installed_formulae_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_formulae_for', ...args)
}

// Ruby method `installed_casks_for(tap:)` at line 127.
pub fn ruby_untap_l127_d3_installed_casks_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_casks_for', ...args)
}

// Ruby method `installed_formulae_names` at line 145.
pub fn ruby_untap_l145_d4_installed_formulae_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_formulae_names', ...args)
}

// Ruby method `installed_cask_tokens` at line 150.
pub fn ruby_untap_l150_d5_installed_cask_tokens(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_cask_tokens', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "English"
// 5: require "abstract_command"
// 6: require "ask"
// 7: require "cask/uninstall"
// 8: require "uninstall"
// 9: require "utils"
// 10:
// 11: module Homebrew
// 12:   module Cmd
// 13:     class Untap < AbstractCommand
// 14:       cmd_args do
// 15:         description <<~EOS
// 16:           Remove a tapped formula repository.
// 17:         EOS
// 18:         switch "-f", "--force",
// 19:                description: "Uninstall all formulae and casks from this tap with `--force` before untapping."
// 20:
// 21:         named_args :tap, min: 1
// 22:       end
// 23:
// 24:       sig { override.void }
// 25:       def run
// 26:         taps = begin
// 27:           args.named.to_installed_taps
// 28:         rescue Tap::InvalidNameError => e
// 29:           odie e.message
// 30:         end
// 31:
// 32:         taps.each do |tap|
// 33:           if tap.core_tap? && Homebrew::EnvConfig.no_install_from_api?
// 34:             ofail "Untapping #{tap} is not allowed"
// 35:             next
// 36:           end
// 37:
// 38:           if Homebrew::EnvConfig.no_install_from_api? || (!tap.core_tap? && !tap.core_cask_tap?)
// 39:             installed_tap_formulae = installed_formulae_for(tap:)
// 40:             installed_tap_casks = installed_casks_for(tap:)
// 41:
// 42:             if installed_tap_formulae.present? || installed_tap_casks.present?
// 43:               installed_formulae_names = installed_tap_formulae.map(&:full_name)
// 44:               installed_cask_names = installed_tap_casks.map(&:full_name)
// 45:               installed_package_types = if installed_formulae_names.empty?
// 46:                 "casks"
// 47:               elsif installed_cask_names.empty?
// 48:                 "formulae"
// 49:               else
// 50:                 "formulae and casks"
// 51:               end
// 52:               installed_names = (installed_formulae_names + installed_cask_names).join("\n")
// 53:               if Homebrew::EnvConfig.developer? && !args.force?
// 54:                 opoo <<~EOS
// 55:                   Untapping #{tap} even though it contains the following installed #{installed_package_types}:
// 56:                   #{installed_names}
// 57:                 EOS
// 58:               else
// 59:                 unless args.force?
// 60:                   ohai "Would untap #{tap} after uninstalling the following #{installed_package_types}:"
// 61:                   puts installed_names
// 62:                   confirmed = begin
// 63:                     Homebrew::Ask.confirm?(action: "changes")
// 64:                   rescue SystemExit
// 65:                     false
// 66:                   end
// 67:                   unless confirmed
// 68:                     ofail <<~EOS
// 69:                       Refusing to untap #{tap} because it contains the following installed #{installed_package_types}:
// 70:                       #{installed_names}
// 71:                     EOS
// 72:                     next
// 73:                   end
// 74:                 end
// 75:
// 76:                 named_args = installed_formulae_names + installed_cask_names
// 77:                 kegs_by_rack = installed_tap_formulae.flat_map do |formula|
// 78:                   formula.installed_kegs.select { |keg| keg.tab.tap == tap }
// 79:                 end.group_by(&:rack)
// 80:
// 81:                 Cask::Uninstall.check_dependent_casks(*installed_tap_casks, named_args:)
// 82:                 next if Homebrew.failed?
// 83:
// 84:                 Uninstall.uninstall_kegs(kegs_by_rack, casks: installed_tap_casks, force: args.force?, named_args:)
// 85:                 next if Homebrew.failed?
// 86:
// 87:                 begin
// 88:                   Cask::Uninstall.uninstall_casks(*installed_tap_casks, force: args.force?)
// 89:                 rescue
// 90:                   ofail $ERROR_INFO
// 91:                   next
// 92:                 end
// 93:
// 94:                 if installed_formulae_for(tap:).present? || installed_casks_for(tap:).present?
// 95:                   ofail "Failed to fully uninstall #{installed_package_types} from #{tap}"
// 96:                   next
// 97:                 end
// 98:               end
// 99:             end
// 100:           end
// 101:
// 102:           tap.uninstall manual: true
// 103:         end
// 104:       end
// 105:
// 106:       # All installed formulae currently available in a tap by formula full name.
// 107:       sig { params(tap: Tap).returns(T::Array[Formula]) }
// 108:       def installed_formulae_for(tap:)
// 109:         tap.formula_names.filter_map do |formula_name|
// 110:           next unless installed_formulae_names.include?(Utils.name_from_full_name(formula_name))
// 111:
// 112:           formula = begin
// 113:             Formulary.factory(formula_name)
// 114:           rescue FormulaUnavailableError, FormulaSpecificationError
// 115:             # Don't blow up because of a single unavailable or invalid formula.
// 116:             next
// 117:           end
// 118:
// 119:           # Can't use Formula#any_version_installed? because it doesn't consider
// 120:           # taps correctly.
// 121:           formula if formula.installed_kegs.any? { |keg| keg.tab.tap == tap }
// 122:         end
// 123:       end
// 124:
// 125:       # All installed casks currently available in a tap by cask full name.
// 126:       sig { params(tap: Tap).returns(T::Array[Cask::Cask]) }
// 127:       def installed_casks_for(tap:)
// 128:         tap.cask_tokens.filter_map do |cask_token|
// 129:           next unless installed_cask_tokens.include?(Utils.name_from_full_name(cask_token))
// 130:
// 131:           cask = begin
// 132:             Cask::CaskLoader.load(cask_token)
// 133:           rescue Cask::CaskUnavailableError, MethodDeprecatedError
// 134:             # Don't blow up because of a single unavailable cask or a deprecated method.
// 135:             next
// 136:           end
// 137:
// 138:           cask if cask.installed?
// 139:         end
// 140:       end
// 141:
// 142:       private
// 143:
// 144:       sig { returns(T::Set[String]) }
// 145:       def installed_formulae_names
// 146:         @installed_formulae_names ||= T.let(Formula.installed_formula_names.to_set.freeze, T.nilable(T::Set[String]))
// 147:       end
// 148:
// 149:       sig { returns(T::Set[String]) }
// 150:       def installed_cask_tokens
// 151:         @installed_cask_tokens ||= T.let(Cask::Caskroom.tokens.to_set.freeze, T.nilable(T::Set[String]))
// 152:       end
// 153:     end
// 154:   end
// 155: end
