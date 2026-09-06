module requirements

import homebrew
import homebrew.requirements as requirement_api

pub fn macos_requirement_satisfied(requirement requirement_api.MacOSRequirement,
	current homebrew.MacOSVersion) bool {
	return requirement.satisfied_on(current, true)
}

pub fn macos_requirement_message(requirement requirement_api.MacOSRequirement,
	dependent_type string) string {
	return requirement.message(dependent_type, true)
}

// Translated from Homebrew/brew `extend/os/mac/requirements/macos_requirement.rb`.
