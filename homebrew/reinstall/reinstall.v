module reinstall

import ruby
import os

// Translated from Homebrew/brew `reinstall/reinstall.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct ReinstallFormula {
pub:
	name                 string
	full_name            string
	prefix               string
	opt_prefix           string
	resolved_opt_prefix  string
	available_options    []string
	build_used_options   []string
	installed_on_request bool = true
	built_bottle         bool
	keg_linked           bool
}

pub struct BuildInstallContextOptions {
pub:
	flags                      []string
	force_bottle               bool
	build_from_source_formulae []string
	interactive                bool
	keep_tmp                   bool
	debug_symbols              bool
	force                      bool
	debug                      bool
	quiet                      bool
	verbose                    bool
	git                        bool
}

pub struct ReinstallKeg {
pub:
	name string
	path string
pub mut:
	linked bool
}

pub struct ReinstallFormulaInstaller {
pub:
	formula                    ReinstallFormula
	options                    []string
	link_keg                   bool
	installed_on_request       bool
	build_bottle               bool
	force_bottle               bool
	build_from_source_formulae []string
	interactive                bool
	keep_tmp                   bool
	debug_symbols              bool
	force                      bool
	debug                      bool
	quiet                      bool
	verbose                    bool
	git                        bool
pub mut:
	already_attempted bool
	install_error     string
	finish_error      string
	install_files     map[string]string
	installed         bool
	finished          bool
}

@[heap]
pub struct InstallationContext {
pub:
	formula  Formula
	options  []string
	link_keg bool
	has_keg  bool
pub mut:
	formula_installer ReinstallFormulaInstaller
	keg               ReinstallKeg
}

// Formula is the source Formula projection retained by InstallationContext.
// Keeping it as an alias gives callers the source-facing field name without
// coupling this filesystem transaction to the much larger Formula runtime.
pub type Formula = ReinstallFormula

pub struct ReinstallFormulaResult {
pub:
	already_attempted bool
	heading           string
	backup_created    bool
	backup_removed    bool
	installed         bool
	finished          bool
}

fn unique_supported_options(requested []string, build_used []string,
	available []string) []string {
	mut selected := []string{}
	for option in requested {
		if option in available && option !in selected {
			selected << option
		}
	}
	for option in build_used {
		if option in available && option !in selected {
			selected << option
		}
	}
	return selected
}

pub fn build_install_context(formula ReinstallFormula,
	config BuildInstallContextOptions) &InstallationContext {
	mut has_keg := false
	mut keg := ReinstallKeg{}
	mut link_keg := false
	mut installed_on_request := true
	mut build_bottle := false
	if formula.opt_prefix != '' && os.is_dir(formula.opt_prefix) {
		has_keg = true
		keg = ReinstallKeg{
			name: if formula.name != '' { formula.name } else { os.base(formula.prefix) }
			path: if formula.resolved_opt_prefix != '' {
				formula.resolved_opt_prefix
			} else {
				os.real_path(formula.opt_prefix)
			}
			linked: formula.keg_linked
		}
		link_keg = formula.keg_linked
		installed_on_request = formula.installed_on_request
		build_bottle = formula.built_bottle
	}
	options := unique_supported_options(config.flags, formula.build_used_options, formula.available_options)
	installer := ReinstallFormulaInstaller{
		formula: formula
		options: options.clone()
		link_keg: link_keg
		installed_on_request: installed_on_request
		build_bottle: build_bottle
		force_bottle: config.force_bottle
		build_from_source_formulae: config.build_from_source_formulae.clone()
		interactive: config.interactive
		keep_tmp: config.keep_tmp
		debug_symbols: config.debug_symbols
		force: config.force
		debug: config.debug
		quiet: config.quiet
		verbose: config.verbose
		git: config.git
		install_files: map[string]string{}
	}
	return &InstallationContext{
		formula_installer: installer
		keg: keg
		formula: formula
		options: options
		link_keg: link_keg
		has_keg: has_keg
	}
}

fn remove_reinstall_path(path string) ! {
	if !os.exists(path) && !os.is_link(path) {
		return
	}
	if os.is_dir(path) && !os.is_link(path) {
		os.rmdir_all(path)!
	} else {
		os.rm(path)!
	}
}

pub fn backup_path(keg ReinstallKeg) string {
	return '${keg.path}.reinstall'
}

pub fn backup(mut keg ReinstallKeg) ! {
	// Keg#unlink happens before either filesystem operation in the source.
	keg.linked = false
	path := backup_path(keg)
	remove_reinstall_path(path) or {
		return error(reinstall_rename_error(keg))
	}
	if !os.exists(keg.path) {
		return error('No such keg: ${keg.path}')
	}
	os.rename(keg.path, path) or {
		return error(reinstall_rename_error(keg))
	}
}

fn reinstall_rename_error(keg ReinstallKeg) string {
	user := if os.getenv('USER') != '' { os.getenv('USER') } else { r'$(whoami)' }
	return 'Could not rename ${keg.name} keg! Check/fix its permissions:\n  sudo chown -R ${user} ${keg.path}'
}

pub fn restore_backup(mut keg ReinstallKeg, keg_was_linked bool, verbose bool) !bool {
	path := backup_path(keg)
	if !os.is_dir(path) {
		return false
	}
	remove_reinstall_path(keg.path)!
	os.rename(path, keg.path)!
	if keg_was_linked {
		// Keg#link's verbose flag only changes output; the resulting state is the same.
		_ = verbose
		keg.linked = true
	}
	return true
}

fn materialize_reinstalled_keg(keg ReinstallKeg, files map[string]string) ! {
	os.mkdir_all(keg.path)!
	for relative_path, contents in files {
		path := os.join_path(keg.path, relative_path)
		parent := os.dir(path)
		if parent != '.' {
			os.mkdir_all(parent)!
		}
		os.write_file(path, contents)!
	}
}

pub fn reinstall_formula(mut install_context InstallationContext) !ReinstallFormulaResult {
	if install_context.formula_installer.already_attempted {
		return ReinstallFormulaResult{
			already_attempted: true
		}
	}
	full_name := if install_context.formula.full_name != '' {
		install_context.formula.full_name
	} else {
		install_context.formula.name
	}
	heading := 'Reinstalling ${full_name} ${install_context.options.join(' ')}'.trim_space()
	mut keg := install_context.keg
	if install_context.has_keg {
		backup(mut keg)!
		install_context.keg = keg
	}
	if install_context.formula_installer.install_error != '' {
		if install_context.has_keg {
			restore_backup(mut keg, install_context.link_keg, install_context.formula_installer.verbose)!
			install_context.keg = keg
		}
		return error(install_context.formula_installer.install_error)
	}
	if install_context.has_keg {
		materialize_reinstalled_keg(keg, install_context.formula_installer.install_files) or {
			restore_backup(mut keg, install_context.link_keg, install_context.formula_installer.verbose)!
			install_context.keg = keg
			return err
		}
	}
	install_context.formula_installer.installed = true
	if install_context.formula_installer.finish_error != '' {
		if install_context.has_keg {
			restore_backup(mut keg, install_context.link_keg, install_context.formula_installer.verbose)!
			install_context.keg = keg
		}
		return error(install_context.formula_installer.finish_error)
	}
	install_context.formula_installer.finished = true
	if install_context.has_keg {
		keg.linked = install_context.link_keg
		install_context.keg = keg
	}
	mut removed := false
	if install_context.has_keg {
		path := backup_path(keg)
		if os.exists(path) {
			remove_reinstall_path(path) or {
				parent_name := os.base(os.dir(path))
				return error('Could not remove ${parent_name} backup keg! Do so manually:\n  sudo rm -rf ${path}')
			}
			removed = true
		}
	}
	return ReinstallFormulaResult{
		heading: heading
		backup_created: install_context.has_keg
		backup_removed: removed
		installed: true
		finished: true
	}
}

pub fn reinstall_pkgconf_if_needed(dry_run bool) {
	// The base implementation at the pinned commit is deliberately a no-op;
	// macOS provides the platform-specific override.
	_ = dry_run
}

fn reinstall_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn reinstall_error_value(kind string, message string) ruby.Value {
	return ruby.structured_value(kind, message, {
		'message': message
	})
}

pub fn reinstall_formula_boundary(formula &ReinstallFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.full_name, {
		'reinstall_formula_address': u64(voidptr(formula)).str()
	})
}

pub fn reinstall_build_options_boundary(options &BuildInstallContextOptions) ruby.Value {
	return ruby.structured_value('Hash', options.flags.str(), {
		'reinstall_build_options_address': u64(voidptr(options)).str()
	})
}

pub fn reinstall_keg_boundary(keg &ReinstallKeg) ruby.Value {
	return ruby.structured_value('Keg', keg.path, {
		'reinstall_keg_address': u64(voidptr(keg)).str()
	})
}

pub fn reinstall_context_boundary(context &InstallationContext) ruby.Value {
	return ruby.structured_value('Homebrew::Reinstall::InstallationContext', context.formula.full_name, {
		'reinstall_context_address': u64(voidptr(context)).str()
		'has_keg':                   context.has_keg.str()
		'keg':                       context.keg.path
		'link_keg':                  context.link_keg.str()
		'options':                   context.options.join(' ')
	})
}

fn reinstall_formula_from_boundary(value ruby.Value) !&ReinstallFormula {
	address := value.attributes['reinstall_formula_address'] or {
		return error('build_install_context requires a Formula')
	}
	if address.u64() == 0 {
		return error('Formula receiver is invalid')
	}
	return unsafe { &ReinstallFormula(voidptr(address.u64())) }
}

fn reinstall_build_options_from_boundary(args []ruby.Value) BuildInstallContextOptions {
	if args.len < 2 {
		return BuildInstallContextOptions{}
	}
	if address := args[1].attributes['reinstall_build_options_address'] {
		if address.u64() != 0 {
			options := unsafe { &BuildInstallContextOptions(voidptr(address.u64())) }
			return *options
		}
	}
	flags := args[1].as_string_array() or { []string{} }
	return BuildInstallContextOptions{
		flags: flags
	}
}

fn reinstall_context_from_boundary(value ruby.Value) !&InstallationContext {
	address := value.attributes['reinstall_context_address'] or {
		return error('reinstall_formula requires an InstallationContext')
	}
	if address.u64() == 0 {
		return error('InstallationContext receiver is invalid')
	}
	return unsafe { &InstallationContext(voidptr(address.u64())) }
}

fn reinstall_keg_from_boundary(value ruby.Value) !&ReinstallKeg {
	address := value.attributes['reinstall_keg_address'] or {
		return error('a Keg is required')
	}
	if address.u64() == 0 {
		return error('Keg receiver is invalid')
	}
	return unsafe { &ReinstallKeg(voidptr(address.u64())) }
}

// Ruby method `build_install_context(` at line 25.
pub fn ruby_reinstall_l25_d1_build_install_context(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return reinstall_error_value('ArgumentError', 'build_install_context requires a Formula')
	}
	formula := reinstall_formula_from_boundary(args[0]) or {
		return reinstall_error_value('ArgumentError', err.msg())
	}
	options := reinstall_build_options_from_boundary(args)
	mut context := build_install_context(*formula, options)
	return reinstall_context_boundary(context)
}

// Ruby method `reinstall_formula(install_context)` at line 79.
pub fn ruby_reinstall_l79_d2_reinstall_formula(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return reinstall_error_value('ArgumentError', 'reinstall_formula requires an InstallationContext')
	}
	mut context := reinstall_context_from_boundary(args[0]) or {
		return reinstall_error_value('ArgumentError', err.msg())
	}
	reinstall_formula(mut context) or {
		return reinstall_error_value('RuntimeError', err.msg())
	}
	return reinstall_nil_value()
}

// Ruby method `reinstall_pkgconf_if_needed!(dry_run: false)` at line 115.
pub fn ruby_reinstall_l115_d3_reinstall_pkgconf_if_needed(args ...ruby.Value) ruby.Value {
	dry_run := if args.len > 0 { args[0].as_bool() or { false } } else { false }
	reinstall_pkgconf_if_needed(dry_run)
	return reinstall_nil_value()
}

// Ruby method `backup(keg)` at line 120.
pub fn ruby_reinstall_l120_d4_backup(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return reinstall_error_value('ArgumentError', 'backup requires a Keg')
	}
	mut keg := reinstall_keg_from_boundary(args[0]) or {
		return reinstall_error_value('ArgumentError', err.msg())
	}
	backup(mut keg) or { return reinstall_error_value('RuntimeError', err.msg()) }
	return reinstall_nil_value()
}

// Ruby method `restore_backup(keg, keg_was_linked, verbose:)` at line 136.
pub fn ruby_reinstall_l136_d5_restore_backup(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return reinstall_error_value('ArgumentError', 'restore_backup requires a Keg')
	}
	mut keg := reinstall_keg_from_boundary(args[0]) or {
		return reinstall_error_value('ArgumentError', err.msg())
	}
	linked := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	verbose := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	restore_backup(mut keg, linked, verbose) or {
		return reinstall_error_value('RuntimeError', err.msg())
	}
	return reinstall_nil_value()
}

// Ruby method `backup_path(keg)` at line 148.
pub fn ruby_reinstall_l148_d6_backup_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return reinstall_error_value('ArgumentError', 'backup_path requires a Keg')
	}
	keg := reinstall_keg_from_boundary(args[0]) or {
		return reinstall_error_value('ArgumentError', err.msg())
	}
	return ruby.object_value('Pathname', backup_path(*keg))
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
