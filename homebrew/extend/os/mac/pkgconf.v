module mac

import brew_runtime

pub struct PkgconfMacState {
pub:
	pre_release       bool
	outdated_release  bool
	formula_available bool = true
	installed         bool
	built_on          map[string]string
	current_version   string
}

pub struct PkgconfMacMismatch {
pub:
	built_on_version string
	current_version  string
}

fn pkgconf_strip_patch(version string) string {
	trimmed := version.trim_string_left('macOS ')
	parts := trimmed.split('.')
	return if parts.len > 1 { parts[..parts.len - 1].join('.') } else { trimmed }
}

pub fn pkgconf_macos_sdk_mismatch(state PkgconfMacState) ?PkgconfMacMismatch {
	if state.pre_release || state.outdated_release || !state.formula_available || !state.installed {
		return none
	}
	built_on := state.built_on['os_version'] or { return none }
	built_version := pkgconf_strip_patch(built_on)
	if built_version == state.current_version {
		return none
	}
	return PkgconfMacMismatch{ built_on_version: built_version, current_version: state.current_version }
}

pub fn pkgconf_mismatch_warning_message(mismatch PkgconfMacMismatch) string {
	return 'You have pkgconf installed that was built on macOS ${mismatch.built_on_version},\n        but you are running macOS ${mismatch.current_version}.\n\nThis can cause issues with packages that depend on system libraries, such as libffi.\nTo fix this issue, reinstall pkgconf:\n  brew reinstall pkgconf\n\nFor more information, see: https://github.com/Homebrew/brew/issues/16137\n'
}

fn pkgconf_state_from_value(value brew_runtime.Value) PkgconfMacState {
	mut built_on := map[string]string{}
	for key, item in (value.map_data['built_on'] or { brew_runtime.map_value({}) }).map_data {
		built_on[key] = item.as_string()
	}
	return PkgconfMacState{
		pre_release: (value.attributes['pre_release'] or { 'false' }).bool()
		outdated_release: (value.attributes['outdated_release'] or { 'false' }).bool()
		formula_available: (value.attributes['formula_available'] or { 'true' }).bool()
		installed: (value.attributes['installed'] or { 'false' }).bool()
		built_on: built_on
		current_version: value.attributes['current_version'] or { '' }
	}
}

// Translated from Homebrew/brew `extend/os/mac/pkgconf.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `macos_sdk_mismatch` at line 9.
pub fn ruby_pkgconf_l9_d1_macos_sdk_mismatch(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { pkgconf_state_from_value(args[0]) } else { PkgconfMacState{} }
	mismatch := pkgconf_macos_sdk_mismatch(state) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_array_value([mismatch.built_on_version, mismatch.current_version])
}

// Ruby method `mismatch_warning_message(mismatch)` at line 35.
pub fn ruby_pkgconf_l35_d2_mismatch_warning_message(args ...brew_runtime.Value) brew_runtime.Value {
	values := args[0].as_array() or { [] }.map(it.as_string())
	return brew_runtime.string_value(pkgconf_mismatch_warning_message(PkgconfMacMismatch{
		built_on_version: values[0]
		current_version: values[1]
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Pkgconf
// 6:     module_function
// 7:
// 8:     sig { returns(T.nilable([String, String])) }
// 9:     def macos_sdk_mismatch
// 10:       # We don't provide suitable bottles for these versions.
// 11:       return if OS::Mac.version.prerelease? || OS::Mac.version.outdated_release?
// 12:
// 13:       pkgconf = begin
// 14:         ::Formula["pkgconf"]
// 15:       rescue FormulaUnavailableError
// 16:         nil
// 17:       end
// 18:       return unless pkgconf&.any_version_installed?
// 19:
// 20:       tab = Tab.for_formula(pkgconf)
// 21:       return unless (built_on = tab.built_on)
// 22:
// 23:       built_on_version = built_on["os_version"]
// 24:                          &.delete_prefix("macOS ")
// 25:                          &.sub(/\.\d+$/, "")
// 26:       return unless built_on_version
// 27:
// 28:       current_version = MacOS.version.to_s
// 29:       return if built_on_version == current_version
// 30:
// 31:       [built_on_version, current_version]
// 32:     end
// 33:
// 34:     sig { params(mismatch: [String, String]).returns(String) }
// 35:     def mismatch_warning_message(mismatch)
// 36:       <<~EOS
// 37:         You have pkgconf installed that was built on macOS #{mismatch[0]},
// 38:                 but you are running macOS #{mismatch[1]}.
// 39:
// 40:         This can cause issues with packages that depend on system libraries, such as libffi.
// 41:         To fix this issue, reinstall pkgconf:
// 42:           brew reinstall pkgconf
// 43:
// 44:         For more information, see: https://github.com/Homebrew/brew/issues/16137
// 45:       EOS
// 46:     end
// 47:   end
// 48: end
