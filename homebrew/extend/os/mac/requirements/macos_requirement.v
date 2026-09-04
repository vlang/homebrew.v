module requirements

import ruby
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

fn macos_requirement_from_boundary(args []ruby.Value) !requirement_api.MacOSRequirement {
	versions := if args.len > 0 && args[0].type_name == 'Array' {
		args[0].as_string_array()!
	} else {
		[]string{}
	}
	comparator := if args.len > 1 { args[1].as_string() } else { '>=' }
	if versions.len > 1 && comparator == '==' {
		return requirement_api.new_macos_range_requirement(versions, []string{})
	}
	return requirement_api.new_macos_requirement(versions, comparator)
}

// Translated from Homebrew/brew `extend/os/mac/requirements/macos_requirement.rb`.
