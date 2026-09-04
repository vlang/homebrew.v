module homebrew

// Translated from Homebrew/brew `minimum_version.rb`.

pub fn formula_kegs_below_minimum(formula Formula, minimum_version ?string) ![]Keg {
	minimum_text := minimum_version or { '' }
	if minimum_text.trim_space() == '' {
		return formula.outdated_kegs()
	}
	minimum_pkg_version := parse_pkg_version(minimum_text)!
	mut outdated := []Keg{}
	for keg in formula.installed_kegs() {
		installed := keg.version() or { continue }
		if keg.version_scheme() < formula.reference.version_scheme
			|| (keg.version_scheme() == formula.reference.version_scheme
				&& installed.compare_to(minimum_pkg_version) < 0) {
			outdated << keg
		}
	}
	return outdated
}

pub fn comparable_cask_version(version string) ?Version {
	if version.trim_space() == '' || version.trim_space().to_lower() == 'latest' {
		return none
	}
	return new_version(version) or { return none }
}

pub fn cask_installed_below(installed_version string, minimum_version string) !bool {
	minimum := comparable_cask_version(minimum_version) or {
		return error('invalid `--minimum-version`: ${minimum_version}')
	}
	if installed_version.trim_space() == '' {
		return false
	}
	installed := comparable_cask_version(installed_version) or { return false }
	return installed.compare_to(minimum) < 0
}
