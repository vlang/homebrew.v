module reinstall

import ruby
import os

// Translated from Homebrew/brew `reinstall/reinstall.rb`.

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
