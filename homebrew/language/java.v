module language

// Translated from Homebrew/brew `language/java.rb`.
pub struct OpenJdkFormula {
pub:
	name              string
	installed         bool
	installed_version string
	opt_libexec       string
}

pub struct JavaVersionConstraint {
pub:
	major        int
	can_be_newer bool
}

pub type JavaHomeComposer = fn (opt_libexec string) string

pub fn java_portable_home(opt_libexec string) string {
	return opt_libexec
}

pub fn java_macos_home(opt_libexec string) string {
	return '${opt_libexec.trim_right('/')}/openjdk.jdk/Contents/Home'
}

pub fn java_current_platform_home(opt_libexec string) string {
	$if macos {
		return java_macos_home(opt_libexec)
	} $else {
		return java_portable_home(opt_libexec)
	}
}

pub fn java_version_constraint(version string) JavaVersionConstraint {
	mut digits := []u8{}
	for character in version.bytes() {
		if character < `0` || character > `9` {
			break
		}
		digits << character
	}
	return JavaVersionConstraint{
		major: if digits.len == 0 { 0 } else { digits.bytestr().int() }
		can_be_newer: version.ends_with('+')
	}
}

pub fn java_version_major(version string) ?int {
	constraint := java_version_constraint(version)
	if constraint.major == 0 && !version.starts_with('0') {
		return none
	}
	return constraint.major
}

pub fn find_openjdk_formula(version string, formulae []OpenJdkFormula) ?OpenJdkFormula {
	constraint := java_version_constraint(version)
	for formula in formulae {
		if !formula.installed {
			continue
		}
		if constraint.major != 0 {
			major := java_version_major(formula.installed_version) or { continue }
			if major < constraint.major {
				continue
			}
			if major > constraint.major && !constraint.can_be_newer {
				continue
			}
		}
		return formula
	}
	return none
}

pub fn java_home(version string, formulae []OpenJdkFormula,
	compose JavaHomeComposer) ?string {
	formula := find_openjdk_formula(version, formulae) or { return none }
	return compose(formula.opt_libexec)
}

pub fn java_home_for_current_platform(version string,
	formulae []OpenJdkFormula) ?string {
	return java_home(version, formulae, java_current_platform_home)
}

pub fn java_home_shell(version string, formulae []OpenJdkFormula,
	compose JavaHomeComposer) string {
	return java_home(version, formulae, compose) or { '' }
}

pub fn java_home_env(version string, formulae []OpenJdkFormula,
	compose JavaHomeComposer) map[string]string {
	return {
		'JAVA_HOME': java_home_shell(version, formulae, compose)
	}
}

pub fn overridable_java_home_env(version string, formulae []OpenJdkFormula,
	compose JavaHomeComposer) map[string]string {
	return {
		'JAVA_HOME': '\${JAVA_HOME:-${java_home_shell(version, formulae, compose)}}'
	}
}
