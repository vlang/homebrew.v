module reinstall

import brew_runtime

// Translated from Homebrew/brew `reinstall/reinstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `build_install_context(` at line 25.
pub fn ruby_reinstall_l25_d1_build_install_context(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_install_context', ...args)
}

// Ruby method `reinstall_formula(install_context)` at line 79.
pub fn ruby_reinstall_l79_d2_reinstall_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reinstall_formula', ...args)
}

// Ruby method `reinstall_pkgconf_if_needed!(dry_run: false)` at line 115.
pub fn ruby_reinstall_l115_d3_reinstall_pkgconf_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reinstall_pkgconf_if_needed!', ...args)
}

// Ruby method `backup(keg)` at line 120.
pub fn ruby_reinstall_l120_d4_backup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('backup', ...args)
}

// Ruby method `restore_backup(keg, keg_was_linked, verbose:)` at line 136.
pub fn ruby_reinstall_l136_d5_restore_backup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('restore_backup', ...args)
}

// Ruby method `backup_path(keg)` at line 148.
pub fn ruby_reinstall_l148_d6_backup_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('backup_path', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Reinstall
// 6:     extend Utils::Output::Mixin
// 7:
// 8:     class InstallationContext < T::Struct
// 9:       const :formula_installer, ::FormulaInstaller
// 10:       const :keg, T.nilable(Keg)
// 11:       const :formula, Formula
// 12:       const :options, Options
// 13:       const :link_keg, T::Boolean, default: false
// 14:     end
// 15:
// 16:     class << self
// 17:       sig {
// 18:         params(
// 19:           formula: Formula, flags: T::Array[String], force_bottle: T::Boolean,
// 20:           build_from_source_formulae: T::Array[String], interactive: T::Boolean, keep_tmp: T::Boolean,
// 21:           debug_symbols: T::Boolean, force: T::Boolean, debug: T::Boolean, quiet: T::Boolean,
// 22:           verbose: T::Boolean, git: T::Boolean
// 23:         ).returns(InstallationContext)
// 24:       }
// 25:       def build_install_context(
// 26:         formula,
// 27:         flags:,
// 28:         force_bottle: false,
// 29:         build_from_source_formulae: [],
// 30:         interactive: false,
// 31:         keep_tmp: false,
// 32:         debug_symbols: false,
// 33:         force: false,
// 34:         debug: false,
// 35:         quiet: false,
// 36:         verbose: false,
// 37:         git: false
// 38:       )
// 39:         if formula.opt_prefix.directory?
// 40:           keg = Keg.new(formula.opt_prefix.resolved_path)
// 41:           tab = keg.tab
// 42:           link_keg = keg.linked?
// 43:           installed_on_request = tab.installed_on_request == true
// 44:           build_bottle = tab.built_bottle?
// 45:         else
// 46:           link_keg = nil
// 47:           installed_on_request = true
// 48:           build_bottle = false
// 49:         end
// 50:
// 51:         build_options = BuildOptions.new(Options.create(flags), formula.options)
// 52:         options = build_options.used_options
// 53:         options |= formula.build.used_options
// 54:         options &= formula.options
// 55:
// 56:         formula_installer = FormulaInstaller.new(
// 57:           formula,
// 58:           **{
// 59:             options:,
// 60:             link_keg:,
// 61:             installed_on_request:,
// 62:             build_bottle:,
// 63:             force_bottle:,
// 64:             build_from_source_formulae:,
// 65:             git:,
// 66:             interactive:,
// 67:             keep_tmp:,
// 68:             debug_symbols:,
// 69:             force:,
// 70:             debug:,
// 71:             quiet:,
// 72:             verbose:,
// 73:           }.compact,
// 74:         )
// 75:         InstallationContext.new(formula_installer:, keg:, formula:, options:, link_keg: link_keg == true)
// 76:       end
// 77:
// 78:       sig { params(install_context: InstallationContext).void }
// 79:       def reinstall_formula(install_context)
// 80:         formula_installer = install_context.formula_installer
// 81:         keg = install_context.keg
// 82:         formula = install_context.formula
// 83:         options = install_context.options
// 84:         link_keg = install_context.link_keg
// 85:         verbose = formula_installer.verbose?
// 86:
// 87:         formula_installer.check_installation_already_attempted
// 88:
// 89:         oh1 "Reinstalling #{Formatter.identifier(formula.full_name)} #{options.to_a.join " "}"
// 90:
// 91:         backup keg if keg
// 92:         formula_installer.install
// 93:         formula_installer.finish
// 94:       rescue FormulaInstallationAlreadyAttemptedError
// 95:         nil
// 96:         # Any other exceptions we want to restore the previous keg and report the error.
// 97:       rescue Exception # rubocop:disable Lint/RescueException
// 98:         ignore_interrupts { restore_backup(keg, link_keg, verbose:) if keg }
// 99:         raise
// 100:       else
// 101:         if keg
// 102:           backup_keg = backup_path(keg)
// 103:           begin
// 104:             FileUtils.rm_r(backup_keg) if backup_keg.exist?
// 105:           rescue Errno::EACCES, Errno::ENOTEMPTY
// 106:             odie <<~EOS
// 107:               Could not remove #{backup_keg.parent.basename} backup keg! Do so manually:
// 108:                 sudo rm -rf #{backup_keg}
// 109:             EOS
// 110:           end
// 111:         end
// 112:       end
// 113:
// 114:       sig { params(dry_run: T::Boolean).void }
// 115:       def reinstall_pkgconf_if_needed!(dry_run: false)
// 116:         nil
// 117:       end
// 118:
// 119:       sig { params(keg: Keg).void }
// 120:       def backup(keg)
// 121:         keg.unlink
// 122:         begin
// 123:           FileUtils.rm_r(backup_path(keg)) if backup_path(keg).exist?
// 124:           keg.rename backup_path(keg)
// 125:         rescue Errno::EACCES, Errno::ENOTEMPTY
// 126:           odie <<~EOS
// 127:             Could not rename #{keg.name} keg! Check/fix its permissions:
// 128:               sudo chown -R #{ENV.fetch("USER", "$(whoami)")} #{keg}
// 129:           EOS
// 130:         end
// 131:       end
// 132:
// 133:       private
// 134:
// 135:       sig { params(keg: Keg, keg_was_linked: T::Boolean, verbose: T::Boolean).void }
// 136:       def restore_backup(keg, keg_was_linked, verbose:)
// 137:         path = backup_path(keg)
// 138:
// 139:         return unless path.directory?
// 140:
// 141:         FileUtils.rm_r(Pathname.new(keg)) if keg.exist?
// 142:
// 143:         path.rename keg.to_s
// 144:         keg.link(verbose:) if keg_was_linked
// 145:       end
// 146:
// 147:       sig { params(keg: Keg).returns(Pathname) }
// 148:       def backup_path(keg)
// 149:         Pathname.new "#{keg}.reinstall"
// 150:       end
// 151:     end
// 152:   end
// 153: end
