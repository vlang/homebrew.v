module mac

import ruby

pub struct MacPkgconfFormula {
pub:
	name string
}

pub struct MacPkgconfInstaller {
pub:
	formula       MacPkgconfFormula
	prelude_fetch bool
	prelude       bool
	fetch         bool
}

pub struct MacPkgconfInstallContext {
pub:
	formula_installer MacPkgconfInstaller
}

pub struct MacPkgconfReinstallResult {
pub:
	mismatch_found bool
	dry_run        bool
	reinstalled    bool
	warnings       []string
	infos          []string
	failures       []string
}

pub struct MacPkgconfReinstallRuntime {
pub:
	mismatch         string
	mismatch_warning string
	lookup_formula   fn (string) !MacPkgconfFormula @[required]
	build_context    fn (MacPkgconfFormula, []string) !MacPkgconfInstallContext @[required]
	fetch_formulae   fn ([]MacPkgconfInstaller) ! @[required]
	reinstall        fn (MacPkgconfInstallContext) ! @[required]
}

pub fn mac_reinstall_pkgconf_if_needed(runtime MacPkgconfReinstallRuntime,
	dry_run bool) MacPkgconfReinstallResult {
	if runtime.mismatch == '' {
		return MacPkgconfReinstallResult{}
	}
	if dry_run {
		return MacPkgconfReinstallResult{
			mismatch_found: true
			dry_run: true
			warnings: ['pkgconf would be reinstalled due to macOS version mismatch']
		}
	}
	formula := runtime.lookup_formula('pkgconf') or {
		return MacPkgconfReinstallResult{
			mismatch_found: true
			failures: [runtime.mismatch_warning]
		}
	}
	context := runtime.build_context(formula, []string{}) or {
		return MacPkgconfReinstallResult{
			mismatch_found: true
			failures: [runtime.mismatch_warning]
		}
	}
	runtime.fetch_formulae([context.formula_installer]) or {
		return MacPkgconfReinstallResult{
			mismatch_found: true
			failures: [runtime.mismatch_warning]
		}
	}
	runtime.reinstall(context) or {
		return MacPkgconfReinstallResult{
			mismatch_found: true
			failures: [runtime.mismatch_warning]
		}
	}
	return MacPkgconfReinstallResult{
		mismatch_found: true
		reinstalled: true
		infos: ['Reinstalled pkgconf due to macOS version mismatch']
	}
}

fn mac_pkgconf_fixture_lookup(name string) !MacPkgconfFormula {
	if name != 'pkgconf' {
		return error('unknown formula ${name}')
	}
	return MacPkgconfFormula{ name: name }
}

fn mac_pkgconf_fixture_context(formula MacPkgconfFormula,
	flags []string) !MacPkgconfInstallContext {
	if flags.len != 0 {
		return error('pkgconf reinstall takes no flags')
	}
	return MacPkgconfInstallContext{
		formula_installer: MacPkgconfInstaller{
			formula: formula
			prelude_fetch: true
			prelude: true
			fetch: true
		}
	}
}

fn mac_pkgconf_fixture_fetch(installers []MacPkgconfInstaller) ! {
	if installers.len != 1 || installers[0].formula.name != 'pkgconf' {
		return error('unexpected formula installer')
	}
}

fn mac_pkgconf_fixture_reinstall(context MacPkgconfInstallContext) ! {
	if context.formula_installer.formula.name != 'pkgconf' {
		return error('unexpected reinstall context')
	}
}

fn mac_pkgconf_fixture_failure(context MacPkgconfInstallContext) ! {
	return error('reinstall failed for ${context.formula_installer.formula.name}')
}

pub fn mac_pkgconf_reinstall_fixture(mismatch string, warning string,
	fail bool) MacPkgconfReinstallRuntime {
	return MacPkgconfReinstallRuntime{
		mismatch: mismatch
		mismatch_warning: warning
		lookup_formula: mac_pkgconf_fixture_lookup
		build_context: mac_pkgconf_fixture_context
		fetch_formulae: mac_pkgconf_fixture_fetch
		reinstall: if fail { mac_pkgconf_fixture_failure } else { mac_pkgconf_fixture_reinstall }
	}
}

pub fn mac_pkgconf_reinstall_result_value(result MacPkgconfReinstallResult) ruby.Value {
	return ruby.map_value({
		'mismatch_found': ruby.bool_value(result.mismatch_found)
		'dry_run':        ruby.bool_value(result.dry_run)
		'reinstalled':    ruby.bool_value(result.reinstalled)
		'warnings':       ruby.string_array_value(result.warnings)
		'infos':          ruby.string_array_value(result.infos)
		'failures':       ruby.string_array_value(result.failures)
	})
}

// Translated from Homebrew/brew `extend/os/mac/reinstall.rb`.
