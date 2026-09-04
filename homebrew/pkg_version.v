module homebrew

// Translated from Homebrew/brew `pkg_version.rb`.

// PkgVersion is the source-derived combination of a Version and formula revision.
pub struct PkgVersion {
pub:
	version  Version
	revision int
}

// parse_pkg_version translates PkgVersion.parse.
pub fn parse_pkg_version(path string) !PkgVersion {
	if path == '' {
		return error('Version must not be empty')
	}
	mut version_text := path
	mut revision := 0
	if underscore := path.last_index('_') {
		candidate := path[underscore + 1..]
		if candidate != '' && pkg_all_digits(candidate) {
			version_text = path[..underscore]
			revision = candidate.int()
		}
	}
	return PkgVersion{
		version: new_version(version_text)!
		revision: revision
	}
}

fn pkg_all_digits(value string) bool {
	for character in value {
		if !character.is_digit() {
			return false
		}
	}
	return true
}

// new_pkg_version translates PkgVersion#initialize.
pub fn new_pkg_version(version Version, revision int) PkgVersion {
	return PkgVersion{
		version: version
		revision: revision
	}
}

// head translates PkgVersion#head?.
pub fn (version PkgVersion) head() bool {
	return version.version.head()
}

// to_s translates PkgVersion#to_str and #to_s.
pub fn (version PkgVersion) to_s() string {
	if version.revision > 0 {
		return '${version.version.to_s()}_${version.revision}'
	}
	return version.version.to_s()
}

// compare_to translates PkgVersion#<=>.
pub fn (version PkgVersion) compare_to(other PkgVersion) int {
	version_comparison := version.version.compare_to(other.version)
	if version_comparison != 0 {
		return version_comparison
	}
	return if version.revision < other.revision {
		-1
	} else if version.revision > other.revision {
		1
	} else {
		0
	}
}

// equals translates Comparable equality and eql?.
pub fn (version PkgVersion) equals(other PkgVersion) bool {
	return version.compare_to(other) == 0
}

// hash translates the [version, revision] hash composition.
pub fn (version PkgVersion) hash() u64 {
	mut result := version.version.hash()
	for shift in 0 .. 8 {
		result = (result ^ u64((version.revision >> (shift * 8)) & 0xff)) * u64(1099511628211)
	}
	return result
}

// major delegates to Version#major.
pub fn (version PkgVersion) major() ?VersionToken {
	return version.version.major()
}

// minor delegates to Version#minor.
pub fn (version PkgVersion) minor() ?VersionToken {
	return version.version.minor()
}

// patch delegates to Version#patch.
pub fn (version PkgVersion) patch() ?VersionToken {
	return version.version.patch()
}

// major_minor delegates to Version#major_minor.
pub fn (version PkgVersion) major_minor() Version {
	return version.version.major_minor()
}

// major_minor_patch delegates to Version#major_minor_patch.
pub fn (version PkgVersion) major_minor_patch() Version {
	return version.version.major_minor_patch()
}
