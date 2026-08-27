module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/uninstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 44.
pub fn ruby_uninstall_l44_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "keg"
// 6: require "formula"
// 7: require "diagnostic"
// 8: require "migrator"
// 9: require "cask/cask_loader"
// 10: require "cask/exceptions"
// 11: require "cask/installer"
// 12: require "cask/uninstall"
// 13: require "uninstall"
// 14: require "trust"
// 15:
// 16: module Homebrew
// 17:   module Cmd
// 18:     class UninstallCmd < AbstractCommand
// 19:       cmd_args do
// 20:         description <<~EOS
// 21:           Uninstall a <formula> or <cask>.
// 22:         EOS
// 23:         switch "-f", "--force",
// 24:                description: "Delete all installed versions of <formula>. Uninstall even if <cask> is not " \
// 25:                             "installed, overwrite existing files and ignore errors when removing files."
// 26:         switch "--zap",
// 27:                description: "Remove all files associated with a <cask>. " \
// 28:                             "*May remove files which are shared between applications.*"
// 29:         switch "--ignore-dependencies",
// 30:                description: "Don't fail uninstall, even if <formula> is a dependency of any installed " \
// 31:                             "formulae."
// 32:         switch "--formula", "--formulae",
// 33:                description: "Treat all named arguments as formulae."
// 34:         switch "--cask", "--casks",
// 35:                description: "Treat all named arguments as casks."
// 36:
// 37:         conflicts "--formula", "--cask"
// 38:         conflicts "--formula", "--zap"
// 39:
// 40:         named_args [:installed_formula, :installed_cask], min: 1
// 41:       end
// 42:
// 43:       sig { override.void }
// 44:       def run
// 45:         method = args.force? ? :kegs : :default_kegs
// 46:         results = args.named.to_formulae_and_casks_and_unavailable(method:)
// 47:
// 48:         unavailable_errors = T.let([], T::Array[T.any(FormulaOrCaskUnavailableError, NoSuchKegError)])
// 49:         all_kegs = T.let([], T::Array[Keg])
// 50:         casks = T.let([], T::Array[Cask::Cask])
// 51:         trusted_items_to_remove = T.let([], T::Array[[Symbol, String]])
// 52:
// 53:         results.each do |item|
// 54:           case item
// 55:           when FormulaOrCaskUnavailableError, NoSuchKegError
// 56:             unavailable_errors << item
// 57:           when Cask::Cask
// 58:             casks << item
// 59:             trusted_items_to_remove << [:cask, item.full_name]
// 60:           when Keg
// 61:             all_kegs << item
// 62:             single_keg_tap = item.tab.tap
// 63:             trusted_items_to_remove << [:formula, "#{single_keg_tap.name}/#{item.name}"] if single_keg_tap
// 64:           when Array
// 65:             all_kegs += item
// 66:             item.each do |keg|
// 67:               array_keg_tap = keg.tab.tap
// 68:               trusted_items_to_remove << [:formula, "#{array_keg_tap.name}/#{keg.name}"] if array_keg_tap
// 69:             end
// 70:           end
// 71:         end
// 72:
// 73:         return if all_kegs.blank? && casks.blank? && unavailable_errors.blank?
// 74:
// 75:         kegs_by_rack = all_kegs.group_by(&:rack)
// 76:
// 77:         Uninstall.uninstall_kegs(
// 78:           kegs_by_rack,
// 79:           casks:,
// 80:           force:               args.force?,
// 81:           ignore_dependencies: args.ignore_dependencies?,
// 82:           named_args:          args.named,
// 83:         )
// 84:
// 85:         Cask::Uninstall.check_dependent_casks(*casks, named_args: args.named) unless args.ignore_dependencies?
// 86:
// 87:         return if Homebrew.failed?
// 88:
// 89:         begin
// 90:           if args.zap?
// 91:             caught_exceptions = []
// 92:
// 93:             casks.each do |cask|
// 94:               odebug "Zapping Cask #{cask}"
// 95:
// 96:               raise Cask::CaskNotInstalledError, cask if !cask.installed? && !args.force?
// 97:
// 98:               next unless Cask::Uninstall.unpin_for_removal?(cask, force: args.force?)
// 99:
// 100:               Cask::Installer.new(cask, verbose: args.verbose?, force: args.force?).zap
// 101:             rescue => e
// 102:               caught_exceptions << e
// 103:               next
// 104:             end
// 105:
// 106:             if caught_exceptions.count > 1
// 107:               raise Cask::MultipleCaskErrors, caught_exceptions
// 108:             elsif caught_exceptions.one?
// 109:               raise caught_exceptions.fetch(0)
// 110:             end
// 111:           else
// 112:             Cask::Uninstall.uninstall_casks(
// 113:               *casks,
// 114:               verbose: args.verbose?,
// 115:               force:   args.force?,
// 116:             )
// 117:           end
// 118:         rescue => e
// 119:           ofail e
// 120:         end
// 121:
// 122:         trusted_items_to_remove.uniq.each do |type, name|
// 123:           next unless (tap_name = Utils.tap_from_full_name(name))
// 124:           next if Homebrew::Trust.trusted?(:tap, tap_name)
// 125:
// 126:           Homebrew::Trust.untrust!(type, name)
// 127:         end
// 128:
// 129:         if ENV["HOMEBREW_AUTOREMOVE"].present?
// 130:           opoo "`$HOMEBREW_AUTOREMOVE` is now a no-op as it is the default behaviour. " \
// 131:                "Set `HOMEBREW_NO_AUTOREMOVE=1` to disable it."
// 132:         end
// 133:         Cleanup.autoremove unless Homebrew::EnvConfig.no_autoremove?
// 134:
// 135:         unavailable_errors.each { |e| ofail e } unless args.force?
// 136:       end
// 137:     end
// 138:   end
// 139: end
