module mac

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

// Translated from Homebrew/brew `extend/os/mac/pkgconf.rb`.
