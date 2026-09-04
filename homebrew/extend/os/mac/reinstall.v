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
	lookup_formula   fn(string) !MacPkgconfFormula @[required]
	build_context    fn(MacPkgconfFormula, []string) !MacPkgconfInstallContext @[required]
	fetch_formulae   fn([]MacPkgconfInstaller) ! @[required]
	reinstall        fn(MacPkgconfInstallContext) ! @[required]
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
// The original source is retained below until every stub has a typed V body.

// Ruby method `reinstall_pkgconf_if_needed!(dry_run: false)` at line 17.
pub fn ruby_reinstall_l17_d1_reinstall_pkgconf_if_needed(args ...ruby.Value) ruby.Value {
	mismatch := if args.len > 0 { args[0].as_string() } else { '' }
	dry_run := if args.len > 1 { args[1].as_bool() or { panic(err) } } else { false }
	fail := if args.len > 2 { args[2].as_bool() or { panic(err) } } else { false }
	warning := if args.len > 3 { args[3].as_string() } else { 'pkgconf SDK mismatch' }
	return mac_pkgconf_reinstall_result_value(mac_reinstall_pkgconf_if_needed(mac_pkgconf_reinstall_fixture(mismatch, warning, fail), dry_run))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "install"
// 5: require "utils/output"
// 6:
// 7: module OS
// 8:   module Mac
// 9:     module Reinstall
// 10:       module ClassMethods
// 11:         extend T::Helpers
// 12:         include ::Utils::Output::Mixin
// 13:
// 14:         requires_ancestor { ::Homebrew::Reinstall }
// 15:
// 16:         sig { params(dry_run: T::Boolean).void }
// 17:         def reinstall_pkgconf_if_needed!(dry_run: false)
// 18:           mismatch = Homebrew::Pkgconf.macos_sdk_mismatch
// 19:           return unless mismatch
// 20:
// 21:           if dry_run
// 22:             opoo "pkgconf would be reinstalled due to macOS version mismatch"
// 23:             return
// 24:           end
// 25:
// 26:           pkgconf = ::Formula["pkgconf"]
// 27:
// 28:           context = T.unsafe(self).build_install_context(pkgconf, flags: [])
// 29:
// 30:           begin
// 31:             Homebrew::Install.fetch_formulae([context.formula_installer])
// 32:             T.unsafe(self).reinstall_formula(context)
// 33:             ohai "Reinstalled pkgconf due to macOS version mismatch"
// 34:           rescue
// 35:             ofail Homebrew::Pkgconf.mismatch_warning_message(mismatch).to_s
// 36:           end
// 37:         end
// 38:       end
// 39:     end
// 40:   end
// 41: end
// 42:
// 43: Homebrew::Reinstall.singleton_class.prepend(OS::Mac::Reinstall::ClassMethods)
