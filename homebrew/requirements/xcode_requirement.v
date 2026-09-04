module requirements

import ruby
import homebrew

// Translated from Homebrew/brew `requirements/xcode_requirement.rb`.
pub struct XcodeRequirement {
pub:
	version ?string
	tags    []string
	fatal   bool = true
}

fn looks_like_xcode_version(value string) bool {
	mut dot_groups := 0
	for index, character in value {
		if character == `.` && index > 0 && index + 1 < value.len && value[index - 1].is_digit() && value[index + 1].is_digit() {
			dot_groups++
		}
	}
	return dot_groups > 0
}

pub fn new_xcode_requirement(tags []string) XcodeRequirement {
	if tags.len > 0 && looks_like_xcode_version(tags[0]) {
		return XcodeRequirement{
			version: tags[0]
			tags: tags[1..].clone()
		}
	}
	return XcodeRequirement{
		tags: tags.clone()
	}
}

pub fn (requirement XcodeRequirement) xcode_installed_version(installed bool,
	installed_version string) bool {
	if !installed {
		return false
	}
	required := requirement.version or { return true }
	current := homebrew.new_version(installed_version) or { return false }
	minimum := homebrew.new_version(required) or { return false }
	return current.compare_to(minimum) >= 0
}

pub fn (requirement XcodeRequirement) satisfied() bool {
	if ruby.kernel_info().name == 'Linux' {
		return true
	}
	installed_version := ruby.environment_value('HOMEBREW_XCODE_VERSION')
	return requirement.xcode_installed_version(installed_version.len > 0, installed_version)
}

pub fn (requirement XcodeRequirement) message(latest_version string,
	macos_version string) string {
	required := requirement.version or { '' }
	version_suffix := if required.len > 0 { ' ${required}' } else { '' }
	mut output := 'A full installation of Xcode.app${version_suffix} is required to compile\nthis software. Installing just the Command Line Tools is not sufficient.\n'
	latest := homebrew.new_version(latest_version) or { homebrew.null_version() }
	minimum := homebrew.new_version(required) or { homebrew.null_version() }
	if required.len > 0 && !latest.is_null() && latest.compare_to(minimum) < 0 {
		output += '\nXcode${version_suffix} cannot be installed on macOS ${macos_version}.\nYou must upgrade your version of macOS.\n'
	} else {
		output += '\nXcode can be installed from the App Store.\n'
	}
	return output
}

pub fn (requirement XcodeRequirement) inspect() string {
	version_text := requirement.version or { 'nil' }
	quoted := if version_text == 'nil' { version_text } else { '"${version_text}"' }
	return '#<XcodeRequirement: version>=${quoted} ${requirement_tags_inspect(requirement.tags)}>'
}

pub fn (requirement XcodeRequirement) display_s() string {
	version := requirement.version or { return 'Xcode (on macOS)' }
	return 'Xcode >= ${version} (on macOS)'
}
